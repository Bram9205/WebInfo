<?php

/**
 * Description of Database
 *
 * @author Guus
 */
class Database {

    private static $CONN_ARGS = [
        "95.85.50.60", //178.62.156.148
        "admin",
        "t249DJK8",
        "test",
        3306
    ];

    public static function createDB()
    {
        echo "setting up DB\n";
        $sqlPage = "CREATE TABLE IF NOT EXISTS `test`.`p2000_news_assoc` "
                . "( `id` INT NOT NULL AUTO_INCREMENT , `p2000Id` INT NOT NULL , "
                . "`newsId` INT NOT NULL,`date` DATETIME, `score` DOUBLE NOT NULL ,"
                . "`supportP2000` DOUBLE NOT NULL , `supportNews` DOUBLE NOT NULL, "
                . "`supportTotal` DOUBLE NOT NULL, `confP2000` DOUBLE NOT NULL,"
                . "`confNews` DOUBLE NOT NULL, `lift` DOUBLE NOT NULL, PRIMARY KEY (`id`));";

        $mysqli = self::connect();

        if (!$mysqli)
        {
            echo "Connection failed";
            exit();
        }

        $mysqli->query($sqlPage);

        $mysqli->close();
    }

    private static function connect()
    {
        $mysqli = new mysqli(self::$CONN_ARGS[0], self::$CONN_ARGS[1], self::$CONN_ARGS[2], self::$CONN_ARGS[3], self::$CONN_ARGS[4]);
        $mysqli->set_charset('utf8');
        return $mysqli;
    }

    public static function getAllP2000()
    {
        $mysqli = self::connect();

        $query = "SELECT l.notification, l.label, l.sublabel, n.date, n.town "
                . "FROM labels l, notifications n WHERE l.notification = n.id";

        $statement = $mysqli->prepare($query);
        $statement->execute();

        $statement->bind_result($id, $label, $sublabel, $date, $loc);

        $p2000List = array();

        while ($statement->fetch())
        {
            $labels = [$label, $sublabel];
            $p2000 = new P2000($id, $labels, DateTime::createFromFormat("Y-m-d", $date), trim($loc));
            array_push($p2000List, $p2000);
        }

        $mysqli->close();
        return $p2000List;
    }

    public static function getAllNews()
    {
        $mysqli = self::connect();

        $query = "SELECT n.news_id, l.label, n.datum, n.locatie "
                . "FROM labels_news l, news n WHERE l.news_id = n.id";

        $statement = $mysqli->prepare($query);
        $statement->execute();

        $statement->bind_result($id, $label, $date, $loc);

        $newsList = array();

        while ($statement->fetch())
        {
            $news = new News($id, [$label], DateTime::createFromFormat("Y-m-d", $date), trim($loc));
            array_push($newsList, $news);
        }

        $mysqli->close();
        return $newsList;
    }

    private static function clearTable()
    {
        $mysqli = self::connect();

        $query = "TRUNCATE TABLE p2000_news_assoc";

        $statement = $mysqli->prepare($query);

        $statement->execute();
    }

    public static function storeAssociations($assocList)
    {
        self::clearTable();

        foreach ($assocList as $rule)
        {
            self::storeAssociation($rule);
        }
    }

    private static function storeAssociation(AssocRule $rule)
    {
        $mysqli = self::connect();

        $query = "INSERT INTO p2000_news_assoc (p2000Id, newsId, date, score, "
                . "supportP2000, supportNews, supportTotal, confP2000, confNews, lift) "
                . "VALUES(?,?,?,?,?,?,?,?,?,?)";

        $statement = $mysqli->prepare($query);

        $p2000id = $rule->getP2000id();
        $newsId = $rule->getNewsId();
        $date = "";
        if ($rule->getDate())
        {
            $date = $rule->getDate()->format("Y-m-d");
        }
        $score = $rule->getScore();
        $supportP2000 = $rule->getP2000Support();
        $supportNews = $rule->getNewsSupport();
        $supportTotal = $rule->getTotalSupport();
        $confP2000 = $rule->getConfidenceLeft();
        $confNews = $rule->getConfidenceRight();
        $lift = $rule->getLift();

        $statement->bind_param('iisddddddd', $p2000id, $newsId, $date, $score, $supportP2000, $supportNews, $supportTotal, $confP2000, $confNews, $lift);

        $statement->execute();

        $mysqli->close();
    }

}
