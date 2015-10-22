<?php
	require_once "get_twitter.php";

	$arr = array('date' => '1444694400', 'town' => 'amsterdam', 'type' => 'Ambulance');
	$myfile = fopen("13102015.json", "w") or die("Unable to open file!");
	fwrite($myfile, getTweets($arr ));
	
?>