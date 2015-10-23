<?php
	require_once "get_twitter.php";

	$arr = array('date' => '1444737600', 'num_tweets' => '20000', 'type' => 'Ambulance');
	$myfile = fopen("newfile.json", "w") or die("Unable to open file!");
	fwrite($myfile, getTweets($arr ));
	
?>