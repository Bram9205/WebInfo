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
        $db = Database::getConnection();
        $stmt = $db->prepare("INSERT INTO notifications (date, time, type, region, postal_code, content) VALUES (?,?,?,?,?,?)");
        $date = $this->date->format('Y/m/d');
        $stmt->bind_param("ssssss", $date, $this->time, $this->type, $this->region, $this->postalCode, $this->content);
        $stmt->execute();
        $stmt->close();
    }

    function printNotification() {
        echo "Date: " . $this->date->format('d-m-Y') . "<br/>Time: " . $this->time . "<br/>Type: " . $this->type . "<br/>Region: " . $this->region . 
        "<br/>Postal code: " . $this->postalCode . "<br/>Content: " . $this->content;
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

    function setCapCode($capCode) {
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

