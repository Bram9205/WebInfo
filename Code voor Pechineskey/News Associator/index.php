<?php

//This file is only used for testing

include 'Main.php';

$main = new Main();
$assoc = $main->getAssociator();
$assoc->createAssociations();

echo "This file is only used for testing<br/>";

echo '<pre>';

foreach ($assoc->getAssocRules() as $rule)
{
    echo $rule->toString();
}

echo '</pre>';