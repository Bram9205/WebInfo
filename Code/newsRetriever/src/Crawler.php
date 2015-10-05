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
    private $ignore;
    private $currentStopDate;
    private $lastCrawlTime;
    private static $WAIT_BETWEEN_CRAWLS = 6; //seconds

    public function __construct($rootUrl)
    {
        $this->rootUrl = $rootUrl;
        $this->robots = $this->parseRobotsTxt($rootUrl);
        $this->urlFrontier = array();
        $this->crawled = array();
        $this->ignore = Database::getRetrievedLinks($rootUrl);
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

    public function crawl($NrOfDaysBack)
    {
        $this->currentStopDate = new DateTime();
        $this->currentStopDate->add(DateInterval::createFromDateString("-$NrOfDaysBack days"));
        $this->currentStopDate->setTime(0, 0, 0);
        array_push($this->urlFrontier, $this->rootUrl);
        echo "first crawlstep...\n";
        $this->crawlStep(true);
    }

    function crawlStep($isRootStep = false)
    {
        echo "Frontier size: " . count($this->urlFrontier) . "\n";
        if (count($this->urlFrontier) < 1)
        {
            return;
        }

        $url = $this->urlFrontier[0];
        echo "retrieving page at $url\n";
        $this->lastCrawlTime = new DateTime();
        $page = new Page($url, $this);

        array_splice($this->urlFrontier, 0, 1);

        if ($page && $page->getDate() >= $this->currentStopDate)
        {
            array_push($this->crawled, $page->getPageUrl());

            $links = $page->getLinks();
            
            foreach ($links as $link)
            {
                if (in_array($link, $this->urlFrontier) || in_array($link, $this->crawled) || in_array($link, $this->ignore))
                {
                    continue;
                }
                array_push($this->urlFrontier, $link);
            }

            if (!$isRootStep)
            {
                echo "storing $url\n";
                Database::storePage($page, $this->rootUrl);
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
