<?php

$passw = bin2hex(random_bytes(8));

$mysqli = new mysqli('localhost', 'editor', 'KAWQfaSfn2REWhc@T#i^9F87cnm%8^', 'ctf2');

$users = array("jelena" => 100, "john" => 100, "kate" => 300);
$fh = fopen("/var/tmp/x.log", 'a');

foreach ($users as $user => $balance) {
    $pass = generatePassword(16);
    fwrite($fh, $pass . "\n");
    $hash = password_hash($pass, PASSWORD_ARGON2I);
    $query = "INSERT INTO users VALUES('$user','$hash', $balance)";
    $mysqli->query($query);
    $uuid = bin2hex(random_bytes(16));
    $query = "INSERT INTO transfers (tid, user, amount) VALUES('$uuid','$user', $balance)";
    $mysqli->query($query);
}
fclose($fh);
$mysqli->close();

function generatePassword($len) {
    $chars = str_split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*");
    $pwd = "";
    for ($i = 1; $i <= $len; $i++) {
        $pwd = $pwd . $chars[random_int(0, sizeof($chars) - 1)];
    }
    return $pwd;
}

/*
$hashedpass = password_hash("abcdef", PASSWORD_ARGON2I);
$query = "INSERT INTO users VALUES('jelena','$hashedpass', 100)";
$mysqli->query($query);

$hashedpass = password_hash("abcdef", PASSWORD_ARGON2I);
$query = "INSERT INTO users VALUES('john','$hashedpass', 100)";
$mysqli->query($query);

$hashedpass = password_hash("abcdef", PASSWORD_ARGON2I);
$query = "INSERT INTO users VALUES('kate','$hashedpass', 300)";
$mysqli->query($query);

$uuid = bin2hex(random_bytes(16));
$query = "INSERT INTO transfers (tid, user, amount) VALUES('$uuid','jelena', 100)";
$mysqli->query($query) or die($mysqli->error);

$uuid = bin2hex(random_bytes(16));
$query = "INSERT INTO transfers (tid, user, amount) VALUES('$uuid','john', 100)";
$mysqli->query($query);

$uuid = bin2hex(random_bytes(16));
$query = "INSERT INTO transfers (tid, user, amount) VALUES('$uuid','kate', 300)";
$mysqli->query($query);

$mysqli->close();
*/