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

echo Util::removeLastUrlPart($rootUrl);

//$crawler = new Crawler($rootUrl, 15);
//$crawler->crawl(1);

echo '</pre>';


