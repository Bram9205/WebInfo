<?php

class GeoCoder {

// function to geocode address, it will return false if unable to geocode address
    public static function geocode($address) {
        
        // url encode the address
        $urladdress = urlencode($address);

        // google map geocode api url
        $apiurl = "http://maps.google.com/maps/api/geocode/json?sensor=false&address={$urladdress}";
        
        
        // get the json response
        $resp_json = file_get_contents($apiurl);

        // decode the json
        $resp = json_decode($resp_json, true);

        // response status will be 'OK', if able to geocode given address 
        if ($resp['status'] == 'OK') {

            // get the important data
            $lati = $resp['results'][0]['geometry']['location']['lat'];
            $longi = $resp['results'][0]['geometry']['location']['lng'];

            // verify if data is complete
            if ($lati && $longi) {

                // put the data in the array
                $data_arr = array();

                array_push(
                        $data_arr, $lati, $longi
                );

                return $data_arr;
            } else {
                return false;
            }
        } else {
            fwrite(STDOUT, "GeoCode API Response: " . $resp['status'] . ".\n");
            return false;
        }

    }

}

?>