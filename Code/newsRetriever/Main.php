<?php

function classAutoLoader($class)
{
    include 'src/' . $class . '.php';
}

/**
 * Contains the main functions that can be used by the other modules of the 
 * application.
 *
 * @author Guus
 */
class Main {
    
    /**
     * Initializes the class by registering all model classes and creating the
     * database if it doesn't exist yet
     */
    public function __construct()
    {
        spl_autoload_register('classAutoLoader');
        Database::createDB();
    }
    
    /**
     * Start the crawler to retrieve pages from a given news website
     * @param type $nrOfDaysBack The nr of days the crawler should go back (counting from today)
     * @param type $newsSiteUrl The root URL of the news site (the seed of the crawler)
     * @return type
     */
    public function crawlForNews($nrOfDaysBack, $newsSiteUrl, $timeToLive)
    {
        $crawler = new Crawler($newsSiteUrl, $timeToLive);
        $crawler->crawl($nrOfDaysBack);
        return count($crawler->getCrawled());
    }
    
    /**
     * Returns all stored articles for a given website between two given dates
     * @param DateTime $startDate The lower date
     * @param DateTime $endDate The upper date
     * @param type $rootUrl
     * @return type
     */
    public function getRetrievedArticles(DateTime $startDate, DateTime $endDate, $rootUrl)
    {
        return Database::retrievePages($startDate, $endDate);
    }
}
