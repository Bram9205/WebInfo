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
    private $minContentLength = 5;
    private $filterWords = array('test','scenario','proefalarm','dienstwissel');

    function __construct($date, $time, $type, $region, $postalCode, $content) {
        $this->date = DateTime::createFromFormat('d-m-y', $date);
        $this->time = $time;
        $this->type = $type;
        $this->region = $region;
        $this->postalCode = $postalCode;
        $this->content = $content;
    }

    /**
     * Store in database
     */
    public function store(){
        if($this->existsInDatabase()){
            return false;
        }
        $db = Database::getConnection();
        $stmt = $db->prepare("INSERT INTO notifications (date, time, type, region, postal_code, town, content) VALUES (?,?,?,?,?,?,?)");
        $date = $this->date->format('Y/m/d');
        $stmt->bind_param("sssssss", $date, $this->time, $this->type, $this->region, $this->postalCode, $this->town, $this->content);
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
     * Tries to deduce a town from postal code and if that fails from content.
     * Stores (in object, not db) and returns the town
     */
    public function detectTown(){
        if($this->postalCode !== null && $this->postalCode != ""){
            $address = $this->get_address($this->postalCode);
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

    function get_address($postcode){ 
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

}

?>

