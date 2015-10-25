<?php

class Capcode {

    private $code;
    private $content;

    function __construct($code, $content) {
    	$this->code = $code;
    	$this->content = $content;
    }

    public function getCode() {
    	return $this->code;
    }

    public function getContent() {
    	return $this->content;
    }

}

?>