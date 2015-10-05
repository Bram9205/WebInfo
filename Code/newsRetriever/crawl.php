<?php
//This file can be executed from the command line to let the crawler retrieve web pages

//Arguments are (in order):
//1 - the nr of days the crawler should crawl back, starting atthe current day
//2 - the URL where to start crawling

include 'Main.php';

$daysBack = $_SERVER['argv'][1];
$rootUrl = $_SERVER['argv'][2];

$main = new Main();

$crawledNr = $main->crawlForNews($daysBack, $rootUrl);

echo "Finished, $crawledNr pages crawled on $rootUrl.";
