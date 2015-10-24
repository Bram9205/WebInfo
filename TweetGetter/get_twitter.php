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
		$keywords = array("sirene", "gevaar", "ongeluk", "ambulance", "ziekenwagen", "ongeval", "gewond", "letsel",
		"brand", "vlam", "vuur", "brandweer", "blus", "water", "overval", "politie", "dief", "wapen", "letsel", "inbraak", "schiet", "misdrijf");
		$start_date = "since:" . date(DATE_FORMAT, $date);
		$end_date = "until:" . date(DATE_FORMAT, strtotime("+1 day", $date));
		//$search_string = $notification['town'] . " " . implode(" OR ", $keywords) . " -p2000 " . $start_date . " " . $end_date;
		$search_string = implode(" OR ", KEYWORDS_GEN) . " -p2000 -RT " . $start_date . " " . $end_date;

		$cur_min = min(100, $notification["num_tweets"]);

		$params = array('q' => $search_string
		,'lang'	=>	'nl'	//Welke taal doen we?
		,'count' =>	$cur_min	//How many tweets do we want for every notification?
		);	

		//$statuses = json_encode((array)$twitter->get("search/tweets", $params));
		$temp = (array)$twitter->get("search/tweets", $params);
		$statuses = $temp["statuses"];
		
		$total_num = count($statuses);
		$num_stat = count($statuses);
		
		$min_id = $statuses[$num_stat - 1]->id;
		
		while($total_num < $notification["num_tweets"] && $num_stat >= $cur_min) {
			$cur_min = min($notification["num_tweets"] - $total_num, 100);
			
			$params = array('q' => $search_string
				,'lang'	=>	'nl'	//Welke taal doen we?
				,'count' =>	$cur_min	//How many tweets do we want for every notification?
				,'max_id' => $min_id
			);
				
			$new_temp = ((array)$twitter->get("search/tweets", $params));
			$new_stat = $new_temp["statuses"];
			
			$num_stat = count($new_stat);
			$total_num = $total_num + $num_stat;
			
			$min_id = $new_stat[$num_stat - 1]->id;
			$statuses = array_merge($statuses, $new_stat);
		}
		
		//What do I do with the statuses?
		return json_encode($statuses);
	}

	//EXAMPLE: 
	//$arr = array('date' => '1444737600', 'num_tweets' => '1000');
	//print_r(getTweets($arr));
?>