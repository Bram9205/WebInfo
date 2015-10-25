<?php

//This file is only used for testing

include 'Main.php';

$main = new Main();

echo "This file is only used for testing<br/>";

echo '<pre>';

$rootUrl = filter_input(INPUT_GET, 'rootUrl');

if (!$rootUrl)
{
    return;
}

$crawler = new Crawler($rootUrl, 15);

$page = new Page($rootUrl, $crawler);
$page1 = new Page($page->getLinks()[0], $crawler);
$page2 = new Page($page->getLinks()[1], $crawler);
$page3 = new Page($page->getLinks()[2], $crawler);
$page4 = new Page($page->getLinks()[3], $crawler);

echo "url: ".$page->getPageUrl()."| title: ".$page->getTitle()."\n";
echo "url: ".$page1->getPageUrl()."| title: ".$page1->getTitle()."\n";
echo "url: ".$page2->getPageUrl()."| title: ".$page2->getTitle()."\n";
echo "url: ".$page3->getPageUrl()."| title: ".$page3->getTitle()."\n";
echo "url: ".$page4->getPageUrl()."| title: ".$page4->getTitle()."\n";

echo '</pre>';


