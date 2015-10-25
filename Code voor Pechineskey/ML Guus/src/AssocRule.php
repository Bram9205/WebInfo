<?php

/**
 * Description of AssocRule
 *
 * @author Guus
 */
class AssocRule {

    private $p2000id;
    private $newsId;
    private $leftTerms;
    private $rightTerms;
    private $date;
    private $p2000Support;
    private $newsSupport;
    private $totalSupport;
    private $confidenceLeft;
    private $confidenceRight;
    private $lift;

    function __construct($p2000id, $newsId, $leftTerms, $rightTerms, $date = null)
    {
        $this->p2000id = $p2000id;
        $this->newsId = $newsId;
        $this->leftTerms = $leftTerms;
        $this->rightTerms = $rightTerms;
        $this->p2000Support = 0;
        $this->newsSupport = 0;
        $this->totalSupport = 0;
        $this->confidenceLeft = 0;
        $this->confidenceRight = 0;
        $this->date = $date;
    }

    function getLeftTerms()
    {
        return $this->leftTerms;
    }

    function getRightTerms()
    {
        return $this->rightTerms;
    }

    function getDate()
    {
        return $this->date;
    }

    function setDate($date)
    {
        $this->date = $date;
    }
    
    function getP2000id()
    {
        return $this->p2000id;
    }

    function getNewsId()
    {
        return $this->newsId;
    }

    function getP2000Support()
    {
        return $this->p2000Support;
    }

    function getNewsSupport()
    {
        return $this->newsSupport;
    }

    function getTotalSupport()
    {
        return $this->totalSupport;
    }

    function getConfidenceLeft()
    {
        return $this->confidenceLeft;
    }

    function setP2000id($p2000id)
    {
        $this->p2000id = $p2000id;
    }

    function setNewsId($newsId)
    {
        $this->newsId = $newsId;
    }

    function setP2000Support($p2000Support)
    {
        $this->p2000Support = $p2000Support;
    }

    function setNewsSupport($newsSupport)
    {
        $this->newsSupport = $newsSupport;
    }

    function setTotalSupport($totalSupport)
    {
        $this->totalSupport = $totalSupport;
    }

    function setConfidenceLeft($confidence)
    {
        $this->confidenceLeft = $confidence;
    }
    
    function getConfidenceRight()
    {
        return $this->confidenceRight;
    }

    function setConfidenceRight($confidenceRight)
    {
        $this->confidenceRight = $confidenceRight;
    }

    function getLift()
    {
        return $this->lift;
    }

    function setLift($lift)
    {
        $this->lift = $lift;
    }

    function getFullLeftTerms()
    {
        $output = $this->leftTerms;
        array_unshift($output, "p_" . $this->p2000id);
        return $output;
    }

    function getFullRightTerms()
    {
        $output = $this->rightTerms;
        array_unshift($output, "p_" . $this->newsId);
        return $output;
    }

    function leftTermsToString()
    {
        return "{" . implode(",", $this->getFullLeftTerms()) . "}";
    }

    function rightTermsToString()
    {
        return "{" . implode(",", $this->getFullRightTerms()) . "}";
    }
    
    function getScore()
    {
        $initial = 0;
        if ($this->getDate())
        {
            $initial = 1;
        }
        return $initial + ($this->newsSupport * (1-$this->p2000Support));
    }

    function toString()
    {
        $supportL = round($this->p2000Support, 6);
        $supportR = round($this->newsSupport, 6);
        $supportT = round($this->totalSupport, 6);
        $confL = round($this->confidenceLeft, 6);
        $confR = round($this->confidenceRight, 6);
        $lift = round($this->lift, 6);
        
        
        $left = $this->leftTermsToString();
        $right = $this->rightTermsToString();
        return "$left => $right; supL: " . $supportL . "; supR: " . $supportR . "; supT: " .$supportT. "; confL: " . $confL . "; confR: " . $confR . "; lift: " . $lift . "; lift: " . $this->getLift() . "; score: ". $this->getScore() . "\n";
    }

}
