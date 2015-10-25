<?php

date_default_timezone_set('Europe/Amsterdam');

function __autoload($class_name) {
    include $class_name . '.php';
}

$clusterDeltaTime = '30';

$db = Database::getConnection();
//Start by latest notification, then set cluster to the _cluster_ value of candidate with highest id found, or to own id if none found 
//otherwise notification 1 might point to notification 30 (cluster 30) while 30 points to 60 (if 60 is out of time range 1, this may happen)
//don't retrieve cluster yet, as it may be updated when we actually need it
$stmt = $db->prepare('SELECT id, date, time, region, postal_code, town, content FROM notifications WHERE postal_code != "" ORDER BY date ASC, time ASC');
$stmt->execute();
$stmt->bind_result($id, $date, $time, $region, $postal, $town, $content);
$notifications = array();
while($stmt->fetch()){
	$notifications[] = array(
		'id' => $id,
		'date' => $date,
		'time' => $time,
		'region' => $region,
		'postal' => $postal,
		'town' => $town,
		'content' => $content
		);
}
$stmt->close();

fwrite(STDOUT, count($notifications) . " notifications retrieved\n");
$i = 0;
foreach ($notifications as $notification) {
	// if($i > 50){
	// 	continue;
	// } else {
		fwrite(STDOUT, "Iteration: ".$i." (id ".$notification['id']."): ");
	// }
	//Get all cluster candidates (within half an hour before, same postal and region), those all have higher (or equal?) id
	//set this cluster to cluster of highest id notification. If none found, set it to own id.
	$dt = DateTime::createFromFormat('H:i:s',$notification['time']);
	$halfPastMidnight = DateTime::createFromFormat('H:i:s',"00:30:00");
	$timeQueryPart = "";
	if ($dt < $halfPastMidnight) {
		$low = $dt->sub(DateInterval::createFromDateString($clusterDeltaTime . " minutes"))->format("H:i:s");
    	$current = $dt->add(DateInterval::createFromDateString($clusterDeltaTime . " minutes"))->format("H:i:s");
		$timeQueryPart .= '((time BETWEEN "' . $low . '" AND "23:59:59") OR (time BETWEEN "00:00:00" AND "' . $current . '"))';
	} else {
		$low = $dt->sub(DateInterval::createFromDateString($clusterDeltaTime . " minutes"))->format("H:i:s");
    	$current = $dt->add(DateInterval::createFromDateString($clusterDeltaTime . " minutes"))->format("H:i:s");
		$timeQueryPart .= 'time BETWEEN "' . $low . '" AND "' . $current . '"';
	}
	$stmt = $db->prepare('SELECT id, cluster FROM notifications WHERE date = ? AND '.$timeQueryPart.' AND region = ? AND postal_code = ? AND id != ?');
	// fwrite(STDOUT, 'SELECT id, cluster FROM notifications WHERE date = ? AND '.$timeQueryPart.' AND region = ? AND postal_code = ? AND id != ?');
    $low = $dt->sub(DateInterval::createFromDateString($clusterDeltaTime . " minutes"))->format("H:i:s");
    $current = $dt->add(DateInterval::createFromDateString($clusterDeltaTime . " minutes"))->format("H:i:s");
    $stmt->bind_param("sssi", $notification['date'], $notification['region'], $notification['postal'], $notification['id']);
    // if($notification['id'] == 52067){
    // 	fwrite(STDOUT, 'SELECT id, cluster FROM notifications WHERE date = '.$notification['date'].' AND time BETWEEN '.$low.' AND '.$current.' AND region = '.$notification['region'].' AND postal_code = '.$notification['postal'].' AND id != '.$notification['id']);
    // }
    $stmt->execute();
    $stmt->bind_result($id, $cluster);
    $cluster_candidates = array();
	while($stmt->fetch()){
		$cluster_candidates[] = array(
			'id' => $id,
			'cluster' => $cluster
			);
	}
	$stmt->close();
	$amount = count($cluster_candidates);
	$candidateId = -1;
	if($amount === 0){
		$finalCluster = $notification['id'];
	} else if ($amount === 1) {
		$finalCluster = $cluster_candidates[0]['cluster'];
		$candidateId = $cluster_candidates[0]['id'];
	} else {
		$maxId = 0;
		$index = 0;
		foreach ($cluster_candidates as $key => $cand) {
			if($cand['id'] > $maxId){
				$maxId = $cand['id'];
				$index = $key;
			}
		}
		$finalCluster = $cluster_candidates[$index]['cluster'];
	}
	fwrite(STDOUT, $amount . " candidates (id ".$candidateId."), cluster id = " . $finalCluster . "\n");
	$stmt = $db->prepare("UPDATE notifications SET cluster = ? WHERE id = ?");
	$stmt->bind_param("ii", $finalCluster, $notification['id']);
	$stmt->execute();
	$stmt->close();
	$i++;
}


?>