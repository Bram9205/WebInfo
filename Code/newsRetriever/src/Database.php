<?php

/**
 * Database connection class, change the values of $CONN_ARGS to modify the 
 * connection parameters
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
        $sqlPage = "CREATE TABLE IF NOT EXISTS `test`.`news_retriever_page` "
                . "( `id` INT NOT NULL AUTO_INCREMENT , `date` DATE NOT NULL , "
                . "`title` TEXT NOT NULL , `siteroot` TEXT NOT NULL , "
                . "`pageurl` TEXT NOT NULL, `content` LONGTEXT NOT NULL , "
                . "PRIMARY KEY (`id`));";

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

    public static function storePage(Page $page, $rootUrl)
    {
        $mysqli = self::connect();

        $query = "INSERT INTO news_retriever_page (date, title, siteroot, pageurl, content) VALUES(?,?,?,?,?)";

        $statement = $mysqli->prepare($query);

        $date = $page->getDate()->format('Y-m-d');
        $title = $page->getTitle();
        $content = $page->getPageAsHtml();

        $statement->bind_param('sssss', $date, $title, $rootUrl, $page->getPageUrl(), $content);

        $statement->execute();

        $mysqli->close();
    }

    public static function retrievePages(DateTime $startDate, DateTime $endDate, $rootUrl)
    {
        $mysqli = self::connect();

        $query = "SELECT date, title, siteroot, pageurl, content FROM news_retriever_page WHERE (date BETWEEN ? AND ?) AND siteroot=?";

        $statement = $mysqli->prepare($query);
        $statement->bind_param('sss', $startDate->format('Y-m-d'), $endDate->format('Y-m-d'), $rootUrl);
        $statement->execute();

        $statement->bind_result($date, $title, $siteRoot, $pageUrl, $content);

        $articles = array();

        if ($result)
        {
            while ($row = $result->fetch_assoc())
            {
                $article = new Article($title, $date, $pageUrl, $siteRoot, $content);
                array_push($articles, $article);
            }
        }

        $mysqli->close();
        return $articles;
    }

    public static function getRetrievedLinks($rootUrl)
    {
        $mysqli = self::connect();

        $query = "SELECT DISTINCT pageurl FROM news_retriever_page WHERE siteroot=?";

        $statement = $mysqli->prepare($query);
        $statement->bind_param('s', $rootUrl);

        $statement->execute();

        $statement->bind_result($pageurl);

        $titles = array();

        while ($statement->fetch())
        {
            array_push($titles, $pageurl);
        }

        $mysqli->close();
        return $titles;
    }

    public static function removeDupicates()
    {
        $titles = array();

        $duplicateIds = array();

        $mysqli = self::connect();

        $query = "SELECT id, title, siteroot FROM news_retriever_page";

        $statement = $mysqli->prepare($query);

        $statement->execute();

        $statement->bind_result($id, $title, $siteroot);

        while ($statement->fetch())
        {
            $titleRoot = $title . $siteroot;
            if (!in_array($titleRoot, $titles, true))
            {
                array_push($titles, $titleRoot);
                continue;
            }
            array_push($duplicateIds, $id);
        }

        $removed = 0;
        
        foreach ($duplicateIds as $dId)
        {
            $clause = implode(',', $duplicateIds);
            
            $query = "DELETE FROM news_retriever_page WHERE id IN ($clause)";

            $statement = $mysqli->prepare($query);

            $statement->execute();
            
            $removed++;
        }

        $mysqli->close();
        
        return $removed;
    }

}
