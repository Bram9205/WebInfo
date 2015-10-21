<?php

include 'src/Database.php';

echo "Remove all duplicate title-siteroot rows from database\n";

$removed = Database::removeDupicates();

echo "Finished. Removed $removed rows\n";