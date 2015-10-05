<?php

include_once('simple_html_dom.php');
set_time_limit(0); // disable maximum time limit

class P2000Scraper {

    private $target_url; // url to be scraped
    private $html; // html_dom object
    private $form_base; // fixed part of url before hidden input
    public  $rawNotifications; // output array of raw notifications

    function __construct($url) {
        $this->target_url = $url;
        $this->html = new simple_html_dom(); // creat new object
        $this->html->load_file($url); // load target url
        $this->loadIframe(); // load iframe in target url
        $this->form_base = explode("?", $this->target_url, 2)[0] . "?";
        $this->rawNotifications = array();
    }

    function __destruct() {
        $this->html->clear();
    }

    private function loadIframe() {
        if ($this->html->find('iframe') != null) {
            $new_target = $this->html->find('iframe')[0]->src;
            //echo "Found iframe with src: " . $new_target . "<br/>";
            $this->html->load_file($new_target);
            $this->target_url = $new_target;
        } else {
            //echo "Found no more iframes <br/>";
        }
    }

    public function getRawNotifications() {
        return $this->rawNotifications;
    }
    
    public function clearRawNotifications() {
        $this->rawNotifications = array();
    }

    public function scrapePage() {
        foreach ($this->html->find('table[style=align:center]') as $table) {
            $startwrapper = "<" . $table->tag . ">"; // used for testing
            $endwrapper = "</" . $table->tag . ">"; // used for testing

            foreach ($table->find('tr') as $tr) {
                //echo $tr . "<br/>";
                static $prevLength = 0;
                $length = count($tr->find('td'));

                // mutually exclusive row types:
                $firstRow = $length > $prevLength;
                $capCodeRow = $length == $prevLength;
                $emptyRow = !$firstRow && !$capCodeRow;

                if ($firstRow) {
                    $rawRow = $tr->outertext;
                } else if ($capCodeRow) {
                    $rawRow = $rawRow . $tr->outertext;
                } else if ($emptyRow) {
                    $rawRow = $rawRow . $tr->outertext;
                    //echo $startwrapper . $rawRow . $endwrapper; // used for testing
                    array_push($this->rawNotifications, $rawRow);
                }
                $prevLength = $length;
            }
        }
        
    }

    public function loadNextPage() {
        $formStr = "";

        foreach ($this->html->find('table form') as $form) {
            foreach ($form->find('button') as $button) {

                if (strcmp($button->plaintext, ">>") == 0) {
                    // extract get variables
                    foreach ($form->find('input[type=hidden]') as $input) {
                        $formStr = $formStr . $input->name . "=" . $input->value . "&";
                    }
                    $formStr = substr($formStr, 0, -1); // remove last '&'
                    $this->html->load_file($this->form_base . $formStr);
                    return; // break foreach
                }
            }
        }
    }

}

?>
