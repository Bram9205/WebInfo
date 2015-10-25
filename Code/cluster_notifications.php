<?php

date_default_timezone_set('Europe/Amsterdam');

function __autoload($class_name) {
    include $class_name . '.php';
}

$clusterDeltaTime = '30';

$db = Database::getConnection();
//Start by highest id, then set cluster to the _cluster_ value of candidate with highest id found, or to own id if none found 
//otherwise notification 1 might point to notification 30 (cluster 30) while 30 points to 60 (if 60 is out of time range 1, this may happen)
//don't retrieve cluster yet, as it may be updated when we actually need it
$stmt = $db->prepare("SELECT id, date, time, region, postal_code, town, content FROM notifications WHERE postal_code != "" ORDER BY id DESC");
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

echo count($notifications) . " notifications retrieved";

foreach ($notifications as $notification) {
	//Get all cluster candidates (within half an hour before, same postal and region), those all have higher (or equal?) id
	//set this cluster to cluster of highest id notification. If none found, set it to own id.
	$stmt = $db->prepare('SELECT id, cluster FROM notifications WHERE date = ? AND time BETWEEN ? AND ? AND region = ? AND postal_code = ?');
	$dt = DateTime::createFromFormat('H:i:s',$notification['time']);
    $low = $dt->sub(DateInterval::createFromDateString($clusterDeltaTime . " minutes"))->format("H:i:s");
    $current = $dt->add(DateInterval::createFromDateString($clusterDeltaTime . " minutes"))->format("H:i:s");
    $stmt->bind_param("sssss", $notification['date'], $low, $current, $notification['region'], $notification['postal']);
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
	if($amount === 0){
		$finalCluster = $notification['id'];
	} else if ($amount === 1) {
		$finalCluster = $cluster_candidates[0]['cluster'];
	} else {
		$maxId = 0;
		foreach ($cluster_candidates as $cand) {
			$maxId = max($cand['id'], $max);
		}
		$finalCluster = $cluster_candidates[$maxId]['cluster'];
	}
	$stmt = $db->prepare("UPDATE notifications SET cluster = ? WHERE id = ?");
	$stmt->bind_param("ii", $finalCluster, $notification['id']);
	$stmt->execute();
	$stmt->close();
}


?>