<?php
	require_once "get_twitter.php";
/*
	$arr = array('date' => '1444996800', 'num_tweets' => '5000', 'type' => 'Ambulance');
	$myfile = fopen("16.json", "w") or die("Unable to open file!");
	fwrite($myfile, getTweets($arr ));

	$arr = array('date' => '1445083200', 'num_tweets' => '5000', 'type' => 'Ambulance');
	$myfile = fopen("17.json", "w") or die("Unable to open file!");
	fwrite($myfile, getTweets($arr ));
	
	$arr = array('date' => '1445169600', 'num_tweets' => '5000', 'type' => 'Ambulance');
	$myfile = fopen("18.json", "w") or die("Unable to open file!");
	fwrite($myfile, getTweets($arr ));
*/
	$arr = array('date' => '1445256000', 'num_tweets' => '5000', 'type' => 'Ambulance');
	$myfile = fopen("19.json", "w") or die("Unable to open file!");
	fwrite($myfile, getTweets($arr ));
	
	$arr = array('date' => '1445343400', 'num_tweets' => '5000', 'type' => 'Ambulance');
	$myfile = fopen("20.json", "w") or die("Unable to open file!");
	fwrite($myfile, getTweets($arr ));
	
	
?>