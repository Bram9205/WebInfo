<?php

//This file can be executed from the command line to let the crawler retrieve web pages
//Arguments are (in order):
//1 - the nr of days the crawler should crawl back, starting atthe current day
//2 - the URL where to start crawling
//3 - how long the script should keep running
//4 - (Optional) highest date to crawl (in d-m-Y)

include 'Main.php';

$daysBack = $_SERVER['argv'][1];
$url = $_SERVER['argv'][2];
$timeToLive = $_SERVER['argv'][3];

$main = new Main();

if (isset($_SERVER['argv'][4]))
{
    $startDate = DateTime::createFromFormat('d-m-Y', $_SERVER['argv'][4]);
    $crawledNr = $main->crawlForNews($daysBack, $url, $timeToLive, $startDate);
}
else
{
    $crawledNr = $main->crawlForNews($daysBack, $url, $timeToLive);
}

echo "Finished, $crawledNr pages crawled on $url.";
