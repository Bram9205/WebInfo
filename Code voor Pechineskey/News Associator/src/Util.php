<?php

/**
 * Description of Util
 *
 * @author Guus
 */
class Util {
    
    private static $SYNONYMS = 
        [
            "misdrijf" => "criminaliteit",
            "brand" => "brandweer",
            "ongeval" => "ongeluk"
        ];
    
    public static function labelsMatch($label1, $label2)
    {
        $lower1 = strtolower($label1);
        $lower2 = strtolower($label2);
        
        return $lower1 === $lower2 || self::compareWithSynonym($lower1, $lower2);
    }
    
    public static function translate($label)
    {
        if (array_key_exists($label, self::$SYNONYMS))
        {
            return self::$SYNONYMS[$label];
        }
        return $label;
    }
    
    public static function translateArr($labels)
    {
        for ($i = 0; $i < count($labels); $i++)
        {
            $labels[$i] = self::translate($labels[$i]);
        }
    }
    
    public static function compareWithSynonym($label1, $label2)
    {
        if (array_key_exists($label1, self::$SYNONYMS))
        {
            return self::$SYNONYMS[$label1] === $label2;
        }
        else if (array_key_exists($label2, self::$SYNONYMS))
        {
            return self::$SYNONYMS[$label2] === $label1;
        }
        return false;
    }
    
}
