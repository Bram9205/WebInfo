<?php

/**
 * Class to hold a page that is being crawled
 *
 * @author Guus
 */
class Page {

    private $crawler;
    private $pageUrl;
    private $dom;
    private $links;
    private $metaTags;
    private $title;
    private $date;

    public function __construct($pageUrl, $crawler)
    {
        $this->crawler = $crawler;
        $this->pageUrl = $pageUrl;

        $this->dom = new DOMDocument();
        $this->dom->strictErrorChecking = false;
        @$this->dom->loadHTMLFile($pageUrl);

        $this->metaTags = "";

        $this->links = $this->getRelevantLinks();

        $this->date = $this->extractDate();

        //echo '<br/>'.date_format($this->date,"Y-m-d").'<br/>';

        $this->processPage();
    }
    
    public function getPageAsHtml()
    {
        return $this->metaTags.$this->dom->saveHTML();
    }

    public function getDom()
    {
        return $this->dom;
    }

    function getPageUrl()
    {
        return $this->pageUrl;
    }

    function getLinks()
    {
        return $this->links;
    }

    function getMetaTags()
    {
        return $this->metaTags;
    }

    function getTitle()
    {
        return $this->title;
    }

    function getDate()
    {
        return $this->date;
    }

    private function extractDate()
    {
        $dateMatches = array();
        preg_match(Util::getDateRegex(), $this->dom->saveHTML(), $dateMatches);
        if (!isset($dateMatches[0]))
        {
            return new DateTime();
        }
        return Util::parseDateString($dateMatches[0]);
    }

    private function processPage()
    {
        $this->title = $this->dom->getElementsByTagName('title')->item(0)->nodeValue;
        $metaTags = $this->dom->getElementsByTagName('meta');
        
        foreach ($metaTags as $metaTag)
        {
            $this->metaTags .= $metaTag->C14N();
        }

        foreach (PageProcessRules::$REMOVE_TAGS as $tag)
        {
            $list = $this->dom->getElementsByTagName($tag);

            while ($list->length > 0)
            {
                $element = $list->item(0);
                $element->parentNode->removeChild($element);
            }
        }

        foreach (PageProcessRules::$REMOVE_CLASSES as $class)
        {
            $list = Util::getElementsByClassName($this->dom, $class);

            $nodes = array();

            foreach ($list as $node)
            {
                array_push($nodes, $node);
            }

            while (count($nodes) > 0)
            {
                $element = $nodes[count($nodes) - 1];
                if ($element->parentNode)
                {
                    $element->parentNode->removeChild($element);
                }
                array_pop($nodes);
            }
        }

    }

    private function getRelevantLinks()
    {
        $allLinks = $this->dom->getElementsByTagName('a');

        $relevantLinks = new ArrayObject();

        foreach ($allLinks as $link)
        {
            $url = $link->getAttribute('href');
            if (!Util::filterLink($url, $this->pageUrl, $this->crawler))
            {
                //echo "link $url did not pass filter \n";
                continue;
            }
            
            if (Util::isRelative($url))
            {
                $url = Util::removeParams($this->pageUrl).$url;
            }
            
            if (in_array($url, $this->crawler->getCrawled()) || in_array($url, $this->crawler->getCrawled()))
            {
                //echo "link $url is already crawled or ignored \n";
                continue;
            }
            
            $relevantLinks->append($url);
        }

        return $relevantLinks;
    }

}
