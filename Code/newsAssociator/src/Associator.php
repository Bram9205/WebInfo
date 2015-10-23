<?php

/**
 * Description of Associator
 *
 * @author Guus
 */
class Associator {

    private $assocRules;
    private $p2000List;
    private $newsList;

    public function __construct($p2000List, $newsList)
    {
        $this->assocRules = array();
        $this->p2000List = $p2000List;
        $this->newsList = $newsList;
    }

    function getAssocRules()
    {
        return $this->assocRules;
    }
    
    function cmp($a, $b)
    {
        if ($a->getDate() && !$b->getDate())
        {
            return 1;
        }
        if ($b->getDate() && !$a->getDate())
        {
            return -1;
        }
        return $a->getScore() > $b->getScore();
    }

    public function createAssociations()
    {
        foreach ($this->p2000List as $p2000)
        {
            if (!$p2000->getLocation())
            {
                continue;
            }
            foreach ($this->newsList as $news)
            {
                $association = $this->getAssociation($p2000, $news);
                if ($association)
                {
                    if ($association->getDate())
                    {
                        array_unshift($this->assocRules, $association);
                        continue;
                    }
                    array_push($this->assocRules, $association);
                }
            }
        }

        foreach ($this->assocRules as $assocRule)
        {
            $this->setAssocProperties($assocRule);
        }
        usort($this->assocRules, array($this, "cmp"));
        Database::storeAssociations($this->assocRules);
    }

    private function getAssociation(P2000 $p2000, News $news)
    {
        $p2000id = $p2000->getId();
        $newsid = $news->getId();
        $leftLabels = array();
        $rightLabels = array();

        if (strtolower($p2000->getLocation()) !== strtolower($news->getLocation()))
        {
            return false;
        }

        foreach ($p2000->getLabels() as $pLabel)
        {
            $date = null;
            $match = false;
            foreach ($news->getLabels() as $nLabel)
            {
                if (strtolower($nLabel) === "overig")
                {
                    continue;
                }
                if (Util::labelsMatch($pLabel, $nLabel))
                {
                    if (!$match)
                    {
                        $match = true;
                    }
                    if (!in_array($pLabel, $leftLabels, true))
                    {
                        array_push($leftLabels, $pLabel);
                    }
                    if (!in_array($nLabel, $rightLabels, true))
                    {
                        array_push($rightLabels, $nLabel);
                    }
                }
            }
            if ($match)
            {
                $p2000date = $p2000->getDate()->format('d-m-Y');
                $newsDate = $news->getDate()->format('d-m-Y');
                if ($p2000date === $newsDate && !in_array($p2000date, $leftLabels, true))
                {
                    array_push($leftLabels, $p2000->getDate()->format('d-m-Y'));
                    $date = $p2000->getDate();
                }
            }
        }

        if (count($leftLabels) < 1)
        {
            return false;
        }

        return new AssocRule($p2000id, $newsid, $leftLabels, $rightLabels, $date);
    }

    private function setAssocProperties(AssocRule $inputRule)
    {

        $leftCount = 0;
        $rightCount = 0;
        $leftRightCount = 0;
        foreach ($this->assocRules as $rule)
        {
            $leftInput = $inputRule->getFullLeftTerms();
            $leftCompare = $rule->getFullLeftTerms();
            $rightInput = $inputRule->getFullRightTerms();
            $rightCompare = $rule->getFullRightTerms();
            
            Util::translateArr($leftInput);
            Util::translateArr($leftCompare);
            Util::translateArr($rightInput);
            Util::translateArr($rightCompare);
            
            if (count(array_intersect($leftInput, $leftCompare)) === count($leftInput))
            {
                $leftCount++;
                if (count(array_intersect($rightInput, $rightCompare)) === count($rightInput))
                {
                    $leftRightCount++;
                }
            }
            if (count(array_intersect($rightInput, $rightCompare)) === count($rightInput))
            {
                $rightCount++;
            }
        }

        $total = count($this->assocRules);
        $inputRule->setP2000Support($leftCount / $total);
        $inputRule->setNewsSupport($rightCount / $total);
        $inputRule->setTotalSupport($leftRightCount / $total);
        $inputRule->setConfidenceLeft($inputRule->getTotalSupport() / $inputRule->getP2000Support());
        $inputRule->setConfidenceRight($inputRule->getTotalSupport() / $inputRule->getNewsSupport());
        $inputRule->setLift($inputRule->getTotalSupport() / ($inputRule->getP2000Support()*$inputRule->getNewsSupport()));
    }

}
