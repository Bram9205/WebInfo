<?php

date_default_timezone_set('Europe/Amsterdam');

function __autoload($class_name) {
    include $class_name . '.php';
}


$db = Database::getConnection();
//retrieve notifications which dont have a postal code but do have a town.
$stmt = $db->prepare('SELECT id, town, content FROM notifications WHERE postal_code = "" AND town != "" AND id < 30390 AND id > 300');
$stmt->execute();
$stmt->bind_result($id, $town, $content);
$notifications = array();
while($stmt->fetch()){
	$notifications[] = array(
		'id' => $id,
		'town' => $town,
		'content' => $content
		);
}
$stmt->close();

fwrite(STDOUT, count($notifications) . " notifications retrieved\n");
//retrieve possible street names
$stmt = $db->prepare('SELECT street FROM postal_street GROUP BY street');
$stmt->execute();
$stmt->bind_result($street);
$streets = array();
while($stmt->fetch()){
	$streets[] = $street;
}
$stmt->close();


fwrite(STDOUT, count($streets) . " streets retrieved\n");
$i = 0;
$added = 0;
//for each notification without postal with town, try to find the street in the content. If found find postal code belonging to this town and street.
foreach ($notifications as $notification) {
	fwrite(STDOUT, "Iteration " . $i . ": ");	
	$street_candidates = array();
	foreach ($streets as $street) {
		if(preg_match("#\b" . $street . "\b#", $notification['content'])){
			$street_candidates[] = addslashes($street);
		}
	}
	if(count($street_candidates) < 1){
		$i++;
		fwrite(STDOUT, "\n");
		continue; //no street found, no postal code (or we could just get one for each town, but then we have a lot of )
	}
	$street_candidates = "'".join("','", $street_candidates)."'";
	$town_candidates = "'".join("','",explode("||", addslashes($notification['town'])))."'";
	// fwrite(STDOUT, "Content: " . $notification['content'] . "\n");	fwrite(STDOUT, "Query: SELECT postal_code FROM postal_street WHERE town IN (".$town_candidates.") AND street IN (".$street_candidates.")");
	//find possible postal codes
	$stmt = $db->prepare('SELECT postal_code FROM postal_street WHERE town IN ('.$town_candidates.') AND street IN ('.$street_candidates.')');
	// $stmt->bind_param('ss', $town_candidates, $street_candidates);
	if($stmt){
		$stmt->execute();
	}
	$stmt->bind_result($pc);
	$postal_candidates = array();
	while ($stmt->fetch()) {
		$postal_candidates[] = $pc;
	}
	$stmt->close();
	
	if(count($postal_candidates) > 0){
		fwrite(STDOUT, "Postal code added: " . $postal_candidates[0]);
		$stmt = $db->prepare("UPDATE notifications SET postal_code = ? WHERE id = ?");
		$stmt->bind_param("si", $postal_candidates[0], $notification['id']);
		if($stmt->execute()){
			$added++;
		} else {
			fwrite(STDOUT, "error: " . $db->error);
		}
	}
	fwrite(STDOUT, "\n");
	$i++;
}
fwrite(STDOUT, "Added " . $added . " postal codes!");


?>