<?php

date_default_timezone_set('Europe/Amsterdam');

function __autoload($class_name) {
    include $class_name . '.php';
}

class Main {

    /**
     * Return the events (involving emergency services) to create a map using the parameters supplied.
     *
     * @param $city If supplied, only return data for this city
     * @param $startDate If supplied, only return events after this date
     * @param $endDate If supplied, only return events before this date
     */
    public function getMapData($city = null, $startDate = null, $endDate = null) {
        //Not implemented yet
        return false;
    }

    /**
     * Main function to populate the database, which calls functions to do the following:
     * Collect P2000 notifications, news feeds and twitter data. 
     * Do a spell check on those. 
     * Index them.
     * Retrieve and store keywords of P2000 notifications
     * Classify P2000, news feed and twitter data (and store result)
     * Cluster P2000 notifications, news feeds and twitter data (and store clusters)
     * Find associations between the P2000 notifications and news feed and twitter data
     */
    public function retrieveData() {
        $this->getAndIndexNotifications();
    }

    /**
     * Return an array of raw html notifications, delay in [s]
     */
    private function getAndIndexNotifications($daysBack = 14, $delay = 0.5) {
        $date = new DateTime(); // DateTime::createFromFormat('d-m-Y', $enddate);
        date_sub($date, date_interval_create_from_date_string($daysBack . ' days'));

        $p = 0;
        $alreadyStoredPages = 0;

        // remove database entries older than given date
        $this->deleteEntriesInDatabase($date);

        $Scraper = new P2000Scraper("http://www.p2000-online.net/alleregiosf.html");
        while ($this->entriesInDatabase($date) == 0) {//&& $alreadyStoredPages<5) {
            $Scraper->scrapePage();

                    
            $now = round(microtime(true) * 1000);
            $alreadyStored = $this->indexNotifications($Scraper->getRawNotifications());
            $elapsed = round(microtime(true) * 1000) - $now;

            if ($elapsed < $delay * 1000.0) { // ensure proper delay between requests
                usleep(($delay - $elapsed / 1000.0) * 1000000);
            }
            $end = round(microtime(true) * 1000) - $now;

            if ($alreadyStored == 15) {
                $alreadyStoredPages++;
            }
            $Scraper->clearRawNotifications();
            $Scraper->loadNextPage();
            $p++;
            //echo "Scraped " . $p . " pages - Time elapsed: " . $elapsed . "[ms] <br/>"; // for webpage
            fwrite(STDOUT, "\n\tScraped " . $p . " pages - Time elapsed: " . $end . "[ms]\n"); // for CLI

            $amount = $this->entriesInDatabase($date);
            fwrite(STDOUT, $amount . " pages indexed of date: " . $date->format('d-m-Y') . "\n"); //->format('d-m-Y')."\n");
        }
    }

    /*
     * Removes entries in database up to given input date
     */

    private function deleteEntriesInDatabase($inputdate) {
        if ($this->entriesInDatabase($inputdate) > 0) {
            $db = Database::getConnection();
            $stmt = $db->prepare("DELETE FROM notifications WHERE date <= ?");
            $date = $inputdate->format('Y/m/d');
            $stmt->bind_param("s", $date);
            $stmt->execute();
            $stmt->close();
            fwrite(STDOUT, "----- Deleted entries! -----");
            // delete orphan capcodes
            $stmt = $db->prepare("DELETE FROM capcodes WHERE notification_id NOT IN (SELECT id FROM notifications)");
            $stmt->execute();
            $stmt->close();

            return true;
        } else {
            return false;
        }
    }

    /*
     * Returns number of entries in database with given input date
     */

    private function entriesInDatabase($inputdate) {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT COUNT(*) FROM notifications WHERE date <= ?");
        $date = $inputdate->format('Y/m/d');
        $stmt->bind_param("s", $date);
        $stmt->execute();
        $stmt->bind_result($amount);
        $stmt->fetch();
        $stmt->close();
        return $amount;
    }

    /**
     * Split and store Notification objects
     */
    private function indexNotifications($rawNotifications) {
        $alreadyStored = 0;
        if ($rawNotifications == null || empty($rawNotifications)) {
            return false;
        }
        foreach ($rawNotifications as $raw) {
            $raw = explode("</tr>", $raw);
            $row1 = explode("</td>", $raw[0]);
            $date = str_replace("<tr><td class=\"DT\">", "", $row1[0]);
            $time = explode(">", $row1[1])[1];
            $type = explode(">", $row1[2])[1];
            $region = explode(">", $row1[3])[1];
            $content = explode(">", $row1[4])[1];
            preg_match_all('/\b[0-9]{4}\s?[a-zA-Z]{2}\b/', $content, $postals);
            $postal = (!empty($postals[0])) ? $postals[0][0] : "";

            $notification = new Notification($date, $time, $type, $region, $postal, $content);

            if (!$notification->isActualNotification()) {
                continue; //Skip current iteration, this notification won't be stored
            }

            if (count($raw) >= 4) {
                for ($i = 1; $i < count($raw) - 2; $i++) {
                    $capContent = explode("<", explode(">", $raw[$i])[10])[0];
                    $capCode = explode(" ", $capContent)[0];
                    $cc = new Capcode($capCode, $capContent);
                    $notification->addCapCode($cc);
                }
            }

            if ($notification->existsInDatabase()) {
                $alreadyStored++;
                continue; // Skip detectTown() and store()
            }

            

            if ($notification->detectTown() == "") {
                //echo "No town detected (no postal code and no town in content)\n";
                fwrite(STDOUT, "No town detected (no postal code and no town in content)\n"); // for running on CLI
            }

            $notification->cluster(); //sets the cluster this notification belongs to, if any. Call after detectTown

            if (!$notification->store()) {
                //echo '<span style="color: blue;">Notification was already in database! Nothing stored.</span><br/>';
                fwrite(STDOUT, "Notification was already in database! Nothing stored.\n"); // for CLI
            }
            
            // TEST GEOCODE ---------------------------------------------------------------------------------------------
            if (strlen($notification->postalCode) == 6) {
                $output = GeoCoder::geocode($notification->postalCode);                
                if ($output){
                    fwrite(STDOUT, "Lat: ".$output[0]."\tLong: ".$output[1]."\n"); 
                }            
            }
            // END TEST -------------------------------------------------------------------------------------------------
            
            // $notification->printNotification(); echo "<hr>"; //TODO: remove, just for testing
        }
        return $alreadyStored;
    }

    //TODO: delete this function which is solely for testing
    public function test() {
        $rawNotifications = $this->getTestNotifications();
        foreach ($rawNotifications as $raw) {
            $raw = explode("</tr>", $raw);
            $row1 = explode("</td>", $raw[0]);
            $date = str_replace("<tr><td class=\"DT\">", "", $row1[0]);
            $time = explode(">", $row1[1])[1];
            $type = explode(">", $row1[2])[1];
            $region = explode(">", $row1[3])[1];
            $content = explode(">", $row1[4])[1];
            preg_match_all('/[0-9]{4}\s?[a-zA-Z]{2}/', $content, $postals);
            $postal = (!empty($postals[0])) ? $postals[0][0] : "";

            $notification = new Notification($date, $time, $type, $region, $postal, $content);
            if ($notification->detectTown() == "") {
                echo "No town detected (no postal code and no town in content)\n";
                //fwrite(STDOUT, "No town detected (no postal code and no town in content)\n"); // for running on CLI
            }
            $notification->cluster();
            $notification->store();
        }
    }

    //Temporary function for testing, TODO: remove
    private function getTestNotifications() {
        $testResult = array();
        $testRawNotification = '<tr><td class="DT">02-10-15</td><td class="DT">15:26:24</td><td class="Am">Ambulance</td><td class="Regio">Gelderland-Midden</td><td class="Md">A1 Renkumseheide X Renkum 6871NR X 69658</td></tr>
								<tr><td></td><td></td><td></td><td></td><td class="OmsAm">0920113 Ambulance Ambulance-07-113</td></tr>
								<tr><td class="Oms">&nbsp;</td></tr>';
        $testRawNotification2 = '<tr><td class="DT">02-10-15</td><td class="DT">19:05:42</td><td class="Br">Brandweer</td><td class="Regio">Limburg-Noord</td><td class="Md">ONTALARMERING 1 AM AUTOM.BRAND MELDING Kleermakersgroes, Heijenrath Zorgcentra P Kleermakersgroes 20 GENN</td></tr>
								<tr><td></td><td></td><td></td><td></td><td class="OmsBr">1001576 Brandweer Gennep Blusgroep 1</td></tr>
								<tr><td></td><td></td><td></td><td></td><td class="OmsBr">1001577 Brandweer Gennep Blusgroep 2</td></tr>
								<tr><td class="Oms"> </td></tr>'; //with multiple capcodes
        $testRawNotification3 = '<tr><td class="DT">04-10-15</td><td class="DT">21:52:28</td><td class="Am">Ambulance</td><td class="Regio">Brabant Noord</td><td class="Md">B1 5481AD X : Hoofdstraat Schijndel Obj: Vws VWS SCHIJNDEL Rit: 43045</td></tr>
								<tr><td class="Oms"> </td></tr>'; //without capcodes
        array_push($testResult, $testRawNotification);
        array_push($testResult, $testRawNotification2);
        array_push($testResult, $testRawNotification3);
        return $testResult;
    }

}
