<?php
	require "twitteroauth/autoload.php";
	use Abraham\TwitterOAuth\TwitterOAuth;
	
	const CONSUMER_KEY = 'N01iKqrpEFJwzXoW9kgSCB5yl';
	const CONSUMER_SECRET = 'S4PsiarjdgQSkzBHxQhRGsinUJYNp9NAzmYH2jpYU1MZzm0IQK';
	const ACCESS_TOKEN = '3167527647-GMqI8F4xngDwQS5IUERiIqeaLIjTbwzpCC9BXxw';
	const ACCESS_TOKEN_SECRET = '8jFBylVtlt8ovNJBbnutuHCzrgFYvWFQOS1ztv9KfqKEZ';
	
	const DATE_FORMAT = "Y-m-d";
	const KEYWORDS_GEN = array("sirene", "gevaar", "ongeluk", "ambulance", "ziekenwagen", "ongeval", "gewond", "letsel",
		"brand", "vlam", "vuur", "brandweer", "blus", "water", "overval", "politie", "dief", "wapen", "letsel", "inbraak", "schiet", "misdrijf");
	
	function getTweets($notification) {
		$twitter = new TwitterOAuth(CONSUMER_KEY, CONSUMER_SECRET, ACCESS_TOKEN, ACCESS_TOKEN_SECRET);
		
		$date = $notification['date'];
		$start_date = "since:" . date(DATE_FORMAT, $date);
		$end_date = "until:" . date(DATE_FORMAT, strtotime("+1 day", $date));
		//$search_string = $notification['town'] . " " . implode(" OR ", $keywords) . " -p2000 " . $start_date . " " . $end_date;
		$search_string = implode(" OR ", KEYWORDS_GEN) . " -p2000 " . $start_date . " " . $end_date;
		
		
		$params = array('q' 	=> $search_string
						,'lang'	=>	'nl'			//Welke taal doen we?
						,'count' =>	'1000'			//How many tweets do we want for every notification?
						);		
		
		$statuses = json_encode((array)$twitter->get("search/tweets", $params));
		
		//What do I do with the statuses?
		return $statuses;
	}
	
	//EXAMPLE: 
	//$arr = array('date' => '1444478400', 'town' => 'amsterdam', 'type' => 'Ambulance');
	//print_r(getTweets($arr));
?>