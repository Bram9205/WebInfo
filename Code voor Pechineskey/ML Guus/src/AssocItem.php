<?php

/**
 * Description of P2000
 *
 * @author Guus
 */
class AssocItem {
    private $id;
    private $labels;
    private $date;
    private $location;
    
    function __construct($id, $labels, $date, $location)
    {
        $this->id = $id;
        $this->labels = $labels;
        $this->date = $date;
        $this->location = $location;
    }

    function getId()
    {
        return $this->id;
    }

    function getLabels()
    {
        return $this->labels;
    }
    
    function getDate()
    {
        return $this->date;
    }
    
    function getLocation()
    {
        return $this->location;
    }

}
