<?php

/**
 * Contains helper functions
 *
 * @author Guus
 */
class Util {

    private static $MONTH_REGEX = '/januari|februari|maart|april|mei|juni|juli|augustus|september|oktober|november|december/i';
    private static $DATE_REGEX = '/((0[1-9]|[1-2][0-9]|3[0-1]|[1-9])\s+(januari|februari|maart|april|mei|juni|juli|augustus|september|oktober|november|december)\s+([0-9]{4}|[0-9]{2}))|((0[1-9]|[1-2][0-9]|3[0-1]|[1-9])-(0[1-9]|1[0-2]|[1-9])-[0-9]{4})|([0-9]{4}-(0[1-9]|1[0-2]|[1-9])-(0[1-9]|[1-2][0-9]|3[0-1]|[1-9]))/i';
    private static $QUERY_REGEX = '/(\?|\#).*/';
    private static $DATE_TRANSLATE = [
        'januari' => 'january',
        'februari' => 'february',
        'maart' => 'march',
        'april' => 'april',
        'mei' => 'may',
        'juni' => 'june',
        'juli' => 'july',
        'augustus' => 'august',
        'september' => 'september',
        'oktober' => 'october',
        'november' => 'november',
        'december' => 'december',
    ];

    public static function getHttpResponseCode($url)
    {
        $headers = get_headers($url);
        return substr($headers[0], 9, 3);
    }

    public static function startsWith($haystack, $needle)
    {
        $haystackTrim = trim($haystack);
        $needleTrim = trim($needle);
        return strpos($haystackTrim, $needleTrim) === 0;
    }

    public static function endsWith($haystack, $needle)
    {
        $haystackTrim = trim($haystack);
        $needleTrim = trim($needle);
        return strpos($haystackTrim, $needleTrim) === strlen($haystack) - 1;
    }

    public static function removeLastUrlPart($url)
    {
        $lastPosition = strrpos($url, '/');
        if (!$lastPosition)
        {
            return $url;
        }
        return $pageUrl = substr($url, 0, $lastPosition);
    }

    public static function filterLink($link, $pageUrl, Crawler $crawler)
    {
        if (Util::isRelative($link))
        {
            return self::getUrlEnd($link) !== self::getUrlEnd($pageUrl) 
                    && !in_array(self::getUrlEnd($link), $crawler->getCrawledUrlEnds(), true);
        }
        $parseLink = parse_url($link);
        $parsePage = parse_url($pageUrl);
        if (!isset($parseLink['host']))
        {
            return false;
        }

        $path = $link;

        if (isset($parseLink['path']))
        {
            $path = $parseLink['path'];
        }

        $Linkhost = Util::getSignificantHostPart($parseLink['host']);
        $PageHost = Util::getSignificantHostPart($parsePage['host']);

        return $Linkhost === $PageHost && $crawler->getRobots()->checkAllowed($path);
    }

    public static function removeParams($url)
    {
        return preg_replace(Util::$QUERY_REGEX, '', $url);
    }

    public static function isRelative($url)
    {
        return Util::startsWith($url, "/") || Util::startsWith($url, "?") || Util::startsWith($url, "#");
    }

    public static function getDateRegex()
    {
        return self::$DATE_REGEX;
    }

    public static function getElementsByClassName($dom, $classname)
    {
        $finder = new DomXPath($dom);
        $nodes = $finder->query("//*[contains(concat(' ', "
                . "normalize-space(@class), ' '), ' $classname ')]");
        return $nodes;
    }

    public static function parseDateString($dateString)
    {
        $found = array();
        preg_match(self::$MONTH_REGEX, $dateString, $found);
        if (count($found) > 0)
        {
            $dateString = str_ireplace($found[0], self::$DATE_TRANSLATE[$found[0]], $dateString);
        }

        $dateArray = date_parse($dateString);
        $dateFormattedString = $dateArray['day'] . '-' . $dateArray['month'] . '-' . $dateArray['year'];
        $dateObject = DateTime::createFromFormat('d-m-Y', $dateFormattedString);
        return $dateObject;
    }

    public static function getSignificantHostPart($Fullhost)
    {
        $hostParts = explode('.', $Fullhost);
        $hostPartCount = count($hostParts);
        if ($hostPartCount < 2)
        {
            return $Fullhost;
        }

        $lastPart = explode('/', $hostParts[$hostPartCount - 1]);

        return $hostParts[$hostPartCount - 2] . '.' . $lastPart[0];
    }

    public static function getHostPart($url)
    {
        $parse = parse_url($url);
        return $parse['scheme'] . '://' . $parse['host'];
    }

    public static function getUrlEnd($url)
    {
        $urlParts = explode("/", $url);
        if (count($urlParts) < 2)
        {
            return $url;
        }
        return $urlParts[count($urlParts) - 1];
    }

}
