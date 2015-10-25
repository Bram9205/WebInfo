<?php

class Notification {

    public $date;
    public $time;
    public $type;
    public $region;
    public $content;
    public $postalCode;
    public $town;
    public $capCodes = array();
    public $cluster;
    public $coords;
    private $minContentLength = 5;
    private $filterWords = array('test','scenario','proefalarm','dienstwissel');
    private $clusterDeltaTime = 30; //minutes before and after a notification that can be taken into a cluster
    private $matchpercentage = 72; //percentage of whole words of shortest message that has to occur in both notifications to qualify for a cluster

    function __construct($date, $time, $type, $region, $postalCode, $content, $coords) {
        $this->date = DateTime::createFromFormat('d-m-y', $date);
        $this->time = $time;
        $this->type = $type;
        $this->region = $region;
        $this->postalCode = $postalCode;
        $this->content = $content;
        $this->coords = $coords;
    }

    /**
     * Store in database
     */
    public function store(){
        if($this->existsInDatabase()){
            return false;
        }
        $db = Database::getConnection();
        $stmt = $db->prepare("INSERT INTO notifications (date, time, type, region, postal_code, town, content, cluster, coordinates) VALUES (?,?,?,?,?,?,?,?,?)");
        $date = $this->date->format('Y/m/d');
        $stmt->bind_param("sssssssss", $date, $this->time, $this->type, $this->region, $this->postalCode, $this->town, $this->content, $this->cluster, $this->coords);
        $stmt->execute();
        $nId = $db->insert_id;
        $stmt->close();
        foreach ($this->capCodes as $capcode) {
            $stmt = $db->prepare("INSERT INTO capcodes (notification_id, code, content) VALUES (?,?,?)");
            $code = $capcode->getCode();
            $content = $capcode->getContent();
            $stmt->bind_param("iss", $nId, $code, $content);
            $stmt->execute();
            $stmt->close();
        }
        return true;
    }

    function printNotification() {
        echo "Date: " . $this->date->format('d-m-Y') . "<br/>Time: " . $this->time . "<br/>Type: " . $this->type . "<br/>Region: " . $this->region . 
        "<br/>Postal code: " . $this->postalCode . "<br/>Content: " . $this->content;
        if (count($this->capCodes)) {
            echo "<br/>Capcodes:<br/>";
        }
        foreach ($this->capCodes as $capcode) {
            echo "&nbsp;&nbsp;Code: " . $capcode->getCode() . "<br/>&nbsp;&nbsp;Content: " . $capcode->getContent() . "<br/>";
        }
    }

    public function existsInDatabase() {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT COUNT(*) FROM notifications WHERE date = ? AND time = ? AND region = ?");
        $date = $this->date->format('Y/m/d');
        $stmt->bind_param("sss", $date, $this->time, $this->region);
        $stmt->execute();
        $stmt->bind_result($amount);
        $stmt->fetch();
        $stmt->close();
        return $amount > 0;
    }

    /**
     * Sets the cluster id if there is another notification that seems to be concerning the same incident
     * null otherwise
     * @pre detectTown called
     * @return whether a cluster has been found
     */
    public function cluster(){
        $db = Database::getConnection();
        $query = 'SELECT id, content FROM notifications WHERE date = ? AND time BETWEEN ? AND ?';
        
        $date = $this->date->format("Y/m/d");
        $dt = DateTime::createFromFormat('H:i:s',$this->time);
        $low = $dt->sub(DateInterval::createFromDateString($this->clusterDeltaTime . " minutes"))->format("H:i:s");
        $high = $dt->add(DateInterval::createFromDateString(2*$this->clusterDeltaTime . " minutes"))->format("H:i:s");

        if(isset($this->postalCode) && $this->postalCode != ""){
            if (isset($this->town) && $this->town != "") {
                //postal code and town present in $this: Match at least one of two + if postal code present, it has to match
                $query .= ' AND (postal_code = ? OR (postal_code = "" && town = ?)) ORDER BY id ASC';
                $stmt = $db->prepare($query);
                $stmt->bind_param('sssss', $date, $low, $high, $this->postalCode, $this->town);
            } else {
                //just postal code here (not probable as town can be deduced using postal code), postal code has to match
                $query .= ' AND postal_code = ? ORDER BY id ASC';
                $stmt = $db->prepare($query);
                $stmt->bind_param('ssss', $date, $low, $high, $this->postalCode);
            }
        } else {
            if (isset($this->town) && $this->town != "") {
                //we only have the town, town has to match
                $query .= ' AND town = ? ORDER BY id ASC';
                $stmt = $db->prepare($query);
                $stmt->bind_param('ssss', $date, $low, $high, $this->town);
            } else {
                //we neither have the town, nor the postal code here, no clustering
                return false;
            }
        } 

        $stmt->execute();
        $stmt->bind_result($cluster, $content);
        $clusters = array();
        while ($stmt->fetch()) {
            //only if $this->matchpercentage% of whole words match, cluster
            if($this->wordMatchPercentage($content, $this->content) > ($this->matchpercentage/100)){
                $clusters[] = array('cluster' => $cluster, 'content' => $content);
            }
        }
        $stmt->close();
        if(count($clusters) > 1){
            $min = PHP_INT_MAX;
            foreach ($clusters as $c) {
                $min = min($c['cluster'], $min);
            }
            $this->cluster = $min;
        } else if (count($clusters) == 1) {
            $this->cluster = $clusters[0]['cluster'];
        } else {
            return false; //no cluster found
        }
        return true;
    }

    /**
     * Tries to deduce a town from postal code and if that fails from content.
     * Stores (in object, not db) and returns the town
     */
    public function detectTown(){
        if($this->postalCode !== null && $this->postalCode != ""){
            $address = Notification::get_address($this->postalCode);
            if($address['success']){
                $this->town = $address['resource']['town'];
                return $this->town;
            }
        }
        $towns = array();
        $db = Database::getConnection();
        if ($result = $db->query("SELECT name FROM towns")) {
            foreach ($result as $townarr) {
                if(preg_match("#\b(".$townarr['name'].")\b#i", $this->content)){ //If isolated word (\b is non word character, like begin of string or ","), /i for non-case-sensitive
                    $towns[] = $townarr['name'];
                }
            }
            $result->close();
        }
        if(!empty($towns)) {
            $this->town =  implode("||", $towns);
        } else {
            $this->town =  "";
        }
        return $this->town;
    }

    /*
     * Returns whether the notification content contains one of the filter words or is shorter than $this->minContentLength characters
     * Also notifications with a date of '00-00-00' are skipped
     */
    public function isActualNotification(){
        if (strlen($this->content) < $this->minContentLength) {
            return false;
        } else if (strcmp($this->date->format('d-m-y'),DateTime::createFromFormat('d-m-y', '00-00-00')->format('d-m-y'))==0){
            return false;
        }
        foreach ($this->filterWords as $word) {
            if (strpos($this->content, $word) !== false) {
                return false;
            }
        }
        return true;
    }

    function setDate($date) {
        $this->date = DateTime::createFromFormat('d-m-y', $date);
    }

    function setTime($time) {
        $this->time = $time;
    }

    function setType($type) {
        $this->type = $type;
    }

    function setRegion($region) {
        $this->region = $region;
    }

    function setContent($content) {
        $this->content = $content;
    }

    function setTown($town) {
        $this->town = $town;
    }

    function addCapCode($capCode) {
        array_push($this->capCodes, $capCode);
    }

    function getDate() {
        return $this->date;
    }

    function getTime() {
        return $this->time;
    }

    function getType() {
        return $this->type;
    }

    function getRegion() {
        return $this->region;
    }

    function getContent() {
        return $this->content;
    }

    function getCapCodes() {
        return $this->capCodes;
    }

    public static function get_address($postcode){ 
        $postcode=strtoupper(preg_replace("/\s+/", '', $postcode));
        $url="http://api.postcodeapi.nu/".$postcode;

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array ('Accept: */*','Content-Type: application/x-www-form-urlencoded;','charset=UTF-8','Accept-Language: en',
            'Api-Key: 7c733f30911b0398c363ef34e81dea08e2d2ad77'));
        $result = curl_exec($ch);
        curl_close($ch);

        $json = json_decode($result, true);

        return $json;
    }

    /**
     * Helper function to calculate the percentage of words that match between two sentences, relative to the shortest sentence.
     */
    public static function wordMatchPercentage($sentence1, $sentence2, $caseSensitive = false){
        if(!$caseSensitive){
            $sentence1 = strtolower($sentence1);
            $sentence2 = strtolower($sentence2);
        }
        preg_match_all("/\b\w+\b/", $sentence1, $words1);
        preg_match_all("/\b\w+\b/", $sentence2, $words2);
        
        if (count($words1[0]) == 0 || count($words2[0]) == 0) {
            return 0; //no match if a sentence has no words
        }

        if (count($words1[0]) < count($words2[0])) {
            $shortSentence = $words1[0]; $longSentence = $words2[0];
        } else {
            $shortSentence = $words2[0]; $longSentence = $words1[0];
        }

        $matches = 0;
        foreach ($shortSentence as $word) {
            if(($key = array_search($word, $longSentence)) !== false){
                $matches++;
                unset($longSentence[$key]); //only want to match each word once (e.g. "word word word","word bla bla bla" should give 1/3 match, not 3/3)
            }
        }
        return $matches/count($shortSentence);
    }
}

?>

