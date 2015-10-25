<?php

/**
 * Represents the robots.txt file on a webserver
 *
 * @author Guus
 */
class RobotsTxt {

    private $rules;
    private $sitemapUrl;

    public function __construct($robotsTxt)
    {
        $this->rules = new ArrayObject();

        $lines = explode(PHP_EOL, $robotsTxt);

        $currentUserAgent = '';
        foreach ($lines as $line)
        {
            if (trim($line) === '')
            {
                continue;
            }
            $parts = explode(':', $line);
            if (count($parts) !== 2)
            {
                continue;
            }

            $key = trim($parts[0]);
            $value = trim($parts[1]);


            switch ($key)
            {
                case 'User-agent':
                    $currentUserAgent = $value;
                    break;
                case 'Disallow':
                    $this->rules->append(new RobotsDisallow($currentUserAgent, $value));
                    break;
                case 'Sitemap':
                    $this->sitemapUrl = $value;
                    break;
            }
        }
    }

    public function getAllRules()
    {
        return $this->rules;
    }

    public function getRulesForUserAgent($userAgent)
    {
        $returnRules = new ArrayObject();

        foreach ($this->rules as $rule)
        {
            if ($rule->getUserAgent() === $userAgent)
            {
                $returnRules->append($rule);
            }
        }

        return $returnRules;
    }

    public function getSiteMap()
    {
        if (isset($this->sitemapUrl))
        {
            return $this->sitemapUrl;
        }
        return '';
    }

    public function checkAllowed($url)
    {
        foreach ($this->rules as $rule)
        {
            if (strpos($rule->getUrl(), $url) !== false)
            {
                return false;
            }
        }
        return true;
    }

}
