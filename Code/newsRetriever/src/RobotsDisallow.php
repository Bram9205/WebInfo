<?php

/**
 * Representation of a Disallow rule from robots.txt
 *
 * @author Guus
 */
class RobotsDisallow {

    private $userAgent;
    private $url;

    public function __construct($userAgent, $url)
    {
        if (substr($url, 0, 1) !== '/')
        {
            $url = substr($url, 1);
        }
        $this->userAgent = $userAgent;
        $this->url = $url;
    }

    public function getUrl()
    {
        return $this->url;
    }

    public function getUserAgent()
    {
        return $this->userAgent;
    }

}
