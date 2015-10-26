<?php
date_default_timezone_set('Europe/Amsterdam');

function __autoload($class_name) {
    include $class_name . '.php';
}


$db = Database::getConnection();
//retrieve notifications which dont have a postal code but do have a town.
$stmt = $db->prepare('SELECT id, postal_code FROM notifications WHERE postal_code != "" AND coordinates = ""');
$stmt->execute();
$stmt->bind_result($id, $postal);
$notifications = array();
while($stmt->fetch()){
	$notifications[] = array(
		'id' => $id,
		'postal' => $postal
		);
}
$stmt->close();

fwrite(STDOUT, count($notifications) . " notifications retrieved\n");

$i = 0;
$added = 0;
//for each notification without postal with town, try to find the street in the content. If found find postal code belonging to this town and street.
foreach ($notifications as $notification) {
	// if($i<10){
		fwrite(STDOUT, "Iteration " . $i . " (id ".$notification['id'].", pc ".$notification['postal']."): ");	
	// } else {
	// 	continue;
	// }
	$address = Notification::get_address($notification['postal']);
	$success = ($address['success']) ? "yes" : "no";
	fwrite(STDOUT, "success: ".$success);
	if($address['success']){
		$added++;
		$lat = $address['resource']['latitude'];
		$long = $address['resource']['longitude'];
		$coordinates = "{lat: ".$lat.", lng: ".$long."}";
		fwrite(STDOUT, $coordinates);
		$stmt = $db->prepare("UPDATE notifications SET coordinates = ? WHERE id = ?");
		$stmt->bind_param("si", $coordinates, $notification['id']);
		if($stmt->execute()){
			$added++;
		} else {
			fwrite(STDOUT, "error: " . $db->error);
		}
	}
	fwrite(STDOUT, "\n");
	usleep(360000);//delay for API limit
	$i++;
}
fwrite(STDOUT, "Added " . $added . " coordinates!");



?>