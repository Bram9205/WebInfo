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

//$crawler = new Crawler($rootUrl);

echo '</pre>';


