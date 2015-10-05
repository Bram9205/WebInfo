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
	public function getMapData($city = null, $startDate = null, $endDate = null){
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
	public function retrieveData(){
		$this->getAndIndexNotifications();
		// $testNotifications = $this->getTestNotifications(); //TODO: remove this line and function
		// $this->indexNotifications($testNotifications);//TODO: change to $rawNotifications);
	}

	/**
	 * Return an array of raw html notifications
	 */
	private function getAndIndexNotifications($startDate = null, $endDate = null){
		$Scraper = new P2000Scraper("http://www.p2000-online.net/alleregiosf.html");
        $Scraper->scrapePages(10, 60 / 100.0);
		$this->indexNotifications($Scraper->getRawNotifications());               
	}

	/**
	 * Split and store Notification objects
	 */
	private function indexNotifications($rawNotifications){
		if($rawNotifications == null || empty($rawNotifications)){
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
			preg_match_all('/[0-9]{4}\s?[a-zA-Z]{2}/', $content, $postals);
			$postal = (!empty($postals[0])) ? $postals[0][0] : "";

			$notification = new Notification($date, $time, $type, $region, $postal, $content);

			if (count($raw) >= 4) {
				for ($i=1; $i < count($raw)-2; $i++) { 
					$capContent = explode("<", explode(">", $raw[$i])[10])[0];
					$capCode = explode(" ", $capContent)[0];
					$cc = new Capcode($capCode, $capContent);
					$notification->addCapCode($cc);
				}
			}

			if(!$notification->store()){
				echo '<span style="color: red;">Notification was already in database! Nothing stored.</span><br/>';
			}

			// $notification->printNotification(); echo "<hr>"; //TODO: remove, just for testing
		}
	}

	//Temporary function for testing, TODO: remove
	private function getTestNotifications(){
		$testResult = array();
		$testRawNotification = '<tr><td class="DT">02-10-15</td><td class="DT">15:26:24</td><td class="Am">Ambulance</td><td class="Regio">Gelderland-Midden</td><td class="Md">A1 Renkumseheide X Renkum 6871NR X 69658</td></tr>
								<tr><td></td><td></td><td></td><td></td><td class="OmsAm">0920113 Ambulance Ambulance-07-113</td></tr>
								<tr><td class="Oms">&nbsp;</td></tr>';
		$testRawNotification2 = '<tr><td class="DT">02-10-15</td><td class="DT">19:05:42</td><td class="Br">Brandweer</td><td class="Regio">Limburg-Noord</td><td class="Md">ONTALARMERING 1 AM AUTOM.BRAND MELDING Kleermakersgroes, Zorgcentra P Kleermakersgroes 20 GENN</td></tr>
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