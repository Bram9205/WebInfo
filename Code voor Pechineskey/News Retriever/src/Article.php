<?php

/**
 * Used for retrieving articles that have been crawled from the database
 *
 * @author Guus
 */
class Article {
    
    private $title;
    private $date;
    private $pageUrl;
    private $riteRoot;
    private $content;
    
    function __construct($title, $date, $pageUrl, $riteRoot, $content)
    {
        $this->title = $title;
        $this->date = $date;
        $this->pageUrl = $pageUrl;
        $this->riteRoot = $riteRoot;
        $this->content = $content;
    }

    function getTitle()
    {
        return $this->title;
    }

    function getDate()
    {
        return $this->date;
    }

    function getPageUrl()
    {
        return $this->pageUrl;
    }

    function getRiteRoot()
    {
        return $this->riteRoot;
    }

    function getContent()
    {
        return $this->content;
    }

}
