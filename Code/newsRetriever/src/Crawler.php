<?php

/**
 * Main crawler class, used to crawl a specified root URL (seed)
 *
 * @author Guus
 */
class Crawler {

    private $rootUrl;
    private $robots;
    private $urlFrontier;
    private $crawled;
    private $crawledUrlEnds;
    private $ignore;
    private $dateLimitHigh;
    private $dateLimitLow;
    private $lastCrawlTime;
    private $startDate;
    private $timeToLive;
    private static $WAIT_BETWEEN_CRAWLS = 6; //seconds

    public function __construct($rootUrl, $timeToLive)
    {
        $this->crawledUrlEnds = array();
        $this->rootUrl = Util::getHostPart($rootUrl);
        $this->robots = $this->parseRobotsTxt($rootUrl);
        $this->urlFrontier = array();
        array_push($this->urlFrontier, $rootUrl);
        $this->crawled = array();
        $this->ignore = Database::getRetrievedLinks($rootUrl);
        $this->startDate = new DateTime();
        $this->timeToLive = $timeToLive;
    }
    
    function getCrawledUrlEnds()
    {
        return $this->crawledUrlEnds;
    }

    function getRootUrl()
    {
        return $this->rootUrl;
    }

    public function getRobots()
    {
        return $this->robots;
    }

    function getCrawled()
    {
        return $this->crawled;
    }

    function getIgnored()
    {
        return $this->ignore;
    }

    public function crawl($NrOfDaysBack, $dateLimitHigh = null)
    {
        if ($dateLimitHigh === null)
        {
            $this->dateLimitHigh = new DateTime();
        }
        else
        {
            $this->dateLimitHigh = $dateLimitHigh;
        }
        $this->crawledTitles = array();
        $this->dateLimitHigh->setTime(23, 59, 59);
        $this->dateLimitLow = DateTime::createFromFormat("d-m-Y", $this->dateLimitHigh->format("d-m-Y"));
        $this->dateLimitLow->add(DateInterval::createFromDateString("-$NrOfDaysBack days"));
        $this->dateLimitLow->setTime(0, 0, 0);
        echo "first crawlstep...\n";
        $this->crawlStep(true);
    }

    function crawlStep($isRootStep = false)
    {
        $now = new DateTime();
        $timeLeft = ($this->startDate->getTimestamp() + ($this->timeToLive * 60)) - $now->getTimestamp();
        echo "$timeLeft seconds left in this crawl session\n";
        if ($timeLeft <= 0)
        {
            return;
        }

        echo "Frontier size: " . count($this->urlFrontier) . "\n";
        if (count($this->urlFrontier) < 1)
        {
            return;
        }

        $url = "";

        while ($url === "" || in_array($url, $this->ignore, true))
        {
            if (count($this->urlFrontier) < 1)
            {
                return;
            }
            $url = $this->urlFrontier[0];
            array_splice($this->urlFrontier, 0, 1);
        }

        echo "retrieving page at $url\n";
        $this->lastCrawlTime = new DateTime();
        $page = new Page($url, $this);

        if ($page)
        {
            array_push($this->crawled, $page->getPageUrl());
            array_push($this->crawledUrlEnds, Util::getUrlEnd($page->getPageUrl()));

            $links = $page->getLinks();
            
            $pushToFrontier = array();

            foreach ($links as $link)
            {
                if (in_array($link, $this->urlFrontier, true) || in_array($link, $this->crawled, true) 
                        || in_array($link, $this->ignore, true))
                {
                    continue;
                }
                if (!filter_var($link, FILTER_VALIDATE_URL))
                {
                    continue;
                }
                else if (!filter_var($link, FILTER_VALIDATE_URL))
                {
                    continue;
                }
                array_push($pushToFrontier, $link);
            }

            if ($page->getDate() >= $this->dateLimitLow && $page->getDate() <= $this->dateLimitHigh)
            {
                foreach ($pushToFrontier as $value)
                {
                    array_unshift($this->urlFrontier, $value);
                }
                if (!$isRootStep)
                {
                    echo "storing $url\n";
                    Database::storePage($page, $this->rootUrl);
                }
            }
            else
            {
                foreach ($pushToFrontier as $value)
                {
                    array_push($this->urlFrontier, $value);
                }
                array_push($this->ignore, $page->getPageUrl());
            }
        }

        $now = new DateTime();
        $nowStamp = $now->getTimestamp();
        $lastStamp = $this->lastCrawlTime->getTimestamp();
        if ($lastStamp + self::$WAIT_BETWEEN_CRAWLS > $nowStamp)
        {
            $seconds = ($lastStamp + self::$WAIT_BETWEEN_CRAWLS) - $nowStamp;
            echo "wait $seconds seconds\n";
            sleep($seconds);
        }

        echo "next crawlstep\n";
        $this->crawlStep();
    }

    public function parseRobotsTxt($rootUrl)
    {
        $robotsUrl = $rootUrl . "/robots.txt";

        $responseCode = Util::getHttpResponseCode($robotsUrl);

        if ($responseCode === '200')
        {
            $content = file_get_contents($robotsUrl);
            return new RobotsTxt($content);
        }
        return new RobotsTxt('');
    }

}
