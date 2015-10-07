<?php

class Database {

    private static $db;
    private $connection;

    private function __construct() {
        $this->connection = new MySQLi('95.85.50.60','admin','t249DJK8','test');
        if ($this->connection->connect_errno) {
            printf("Connect failed: %s\n", $this->connection->connect_error);
        }
    }

    function __destruct() {
        $this->connection->close();
    }

    public static function getConnection() {
        if (self::$db == null) {
            self::$db = new Database();
        }
        return self::$db->connection;
    }
}

?>