<?php

include_once('P2000Scraper.php');

$Scraper = new P2000Scraper("http://www.p2000-online.net/alleregiosf.html");
$Scraper->scrapePages(10, 60 / 100.0);

echo  htmlspecialchars($Scraper->getRawNotifications()[0]);
echo "<br/>";

echo "Count: ".count($Scraper->getRawNotifications());

?>
