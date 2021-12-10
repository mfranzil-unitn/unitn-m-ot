<?php

$handle = fopen("sql-strings.txt", "r");
if ($handle) {
    while (($line = fgets($handle)) !== false) {
		$line=htmlentities(urldecode($line));
        echo htmlspecialchars(filter_var($line, FILTER_SANITIZE_EMAIL));
        echo "\n";
    }
    fclose($handle);
} else {
    // error opening the file.
}

?>
