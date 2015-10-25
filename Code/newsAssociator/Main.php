<?php


function classAutoLoader($class)
{
    include 'src/' . $class . '.php';
}

/**
 * Description of Main
 *
 * @author Guus
 */
class Main {
    
    private $associator;
    
    /**
     * Initializes the class by registering all model classes and creating the
     * database if it doesn't exist yet
     */
    public function __construct()
    {
        spl_autoload_register('classAutoLoader');
        Database::createDB();
        $this->associator = new Associator(Database::getAllP2000(), Database::getAllNews());
    }
    
    function getAssociator()
    {
        return $this->associator;
    }

}
