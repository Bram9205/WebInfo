<?php

class Notification {

    public $date;
    public $time;
    public $type;
    public $region;
    public $content;
    public $postalCode;
    public $capCodes = array();

    function __construct($date, $time, $type, $region, $postalCode, $content) {
        $this->date = DateTime::createFromFormat('d-m-y', $date);
        $this->time = $time;
        $this->type = $type;
        $this->region = $region;
        $this->postalCode = $postalCode;
        $this->content = $content;
    }

    public function store(){
        if($this->existsInDatabase()){
            return false;
        }
        $db = Database::getConnection();
        $stmt = $db->prepare("INSERT INTO notifications (date, time, type, region, postal_code, content) VALUES (?,?,?,?,?,?)");
        $date = $this->date->format('Y/m/d');
        $stmt->bind_param("ssssss", $date, $this->time, $this->type, $this->region, $this->postalCode, $this->content);
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

    private function existsInDatabase() {
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

}

?>
