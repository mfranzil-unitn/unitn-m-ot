<html>

<body>
    <?php

    // START OF MAIN CODE

    $user = htmlentities($_GET["user"]);
    $pass = htmlentities($_GET["pass"]);
    $choice = htmlentities($_GET["drop"]);
    $amount = htmlentities($_GET["amount"]);

    $mysqli = new mysqli('localhost', 'editor', 'KAWQfaSfn2REWhc@T#i^9F87cnm%8^', 'ctf2');

    if (!$mysqli) {
        die('Could not connect: ' . $mysqli->error());
    }

    if (!isset($user) || !isset($pass)) {
        exit("Input fields cannot be empty.</body></html>");
    }

    if (!validateString($user)) {
        exit("Username contains prohibited characters.</body></html>");
    }
    if (!validateString($pass)) {
        exit("Password contains prohibited characters.</body></html>");
    }

    $url = sprintf("process.php?user=%s&pass=%s&drop=balance", $user, $pass);
    #$url = "process.php?user=$user&pass=$pass&drop=balance";

    switch ($choice) {
        case "register":
            registerUser($user, $pass);
            logger();
            print "Registraction successful!\n";
            print "<A HREF='index.php'>Home</A>";
            break;
        case "balance":
            displayBalance($user, $pass);
            logger();
            break;
        case "deposit":
            #TODO: return true/false and print accordingly.
            deposit($amount, $user, $pass);
            logger();
            print "Deposit successful!\n";
            print "<A HREF='index.php'>Home</A>";
            break;
            //Deposit
        case "withdraw":
            withdraw($amount, $user, $pass);
            logger();
            print "Withdraw successful!\n";
            print "<A HREF='index.php'>Home</A>";
            break;
            //Withdraw
        default:
            exit("Unknown request.\n\n<A HREF='index.php'>Home</A></body></html>");
    }

    $mysqli->close();

    // END OF MAIN CODE

    function registerUser($user, $pass) {
        global $mysqli;

        if (strlen($user) < 3 || strlen($user) > 32 || strlen($pass) < 16 || strlen($pass) > 256) {
            exit("Username must be 4-32 characters long, password must be between 16-256.\n\n</body></html>");
            # TODO: different messages for different cases
        }

        if (!exists($user)) {
            $hashedpass = password_hash($pass, PASSWORD_ARGON2I);
            $stmt = $mysqli->prepare("INSERT INTO users(user,pass) VALUES (?,?)");
            $stmt->bind_param("ss", $user, $hashedpass);
            $stmt->execute() or die("AAAAAAAAAAAAAAAA");
            $stmt->close();
        } else {
            exit("User already exists.\n\n</body></html>");
        }
    }

    function getBalance($user) {
        global $mysqli;
        $stmt = $mysqli->prepare("SELECT balance FROM users WHERE user = ?");
        $stmt->bind_param("s", $user);
        $stmt->execute() or die("Error retrieving balance... </body></html>");
        $result = $stmt->get_result();
        $rval = $result->fetch_array()['balance'];
        $stmt->close();
        return $rval;
    }

    function displayBalance($user, $pass) {
        global $mysqli;

        if (!authenticate($user, $pass)) {
            exit("User authentication failed.</body></html>");
        }

        $balance = getBalance($user);
        if (is_null($balance)) {
            exit("<H1>Balance and transfer history for $user</H1><P><table border=1><tr><th>Action</th><th>Amount</th></tr><tr><td>Total</td><td>0</td></tr></table><A HREF='index.php'>Home</A></body></html>");
        }
        print "<H1>Balance and transfer history for $user</H1><P>";
        print "<table border=1><tr><th>Action</th><th>Amount</th></tr>";

        //Only shows latest 100 transactions
        $stmt = $mysqli->prepare("SELECT amount FROM transfers WHERE user = ? LIMIT 100");
        $stmt->bind_param("s", $user);
        $stmt->execute() or die("Error retrieving transaction list</body></html>");
        $result = $stmt->get_result();

        while ($row = $result->fetch_array()) {
            $action = ($row['amount'] < 0) ? "Withdrawal" : "Deposit";
            print "<tr><td>" . $action . "</td><td>" . $row['amount'] . "</td></tr>";
        }
        print "<tr><td>Total</td><td>" . $balance . "</td></tr></table>";
        print "<A HREF='index.php'>Home</A>";
        $stmt->close();
    }

    function deposit($amount, $user, $pass) {

        # Returns intval($amount) on success, a negative number of failure.
        $value = validateInt($amount);

        #Exit if authentication fail
        if (!authenticate($user, $pass)) {
            exit("User authentication failed.</body></html>");
        }

        #Exit if post-sum integer overflow
        if ($value + getBalance($user) <= 0) {
            exit("Deposit limit overcomed.</body></html>");
        }

        execute_transfer($user, $value);
    }

    function execute_transfer($user, $amount) {
        global $mysqli;

        $stmt = $mysqli->prepare("UPDATE users SET balance = balance + ? WHERE user = ?");
        $stmt->bind_param("is", $amount, $user);
        $stmt->execute() or die("Error updating balance... </body></html>");
        #100000000000
        $tid = bin2hex(random_bytes(16));
        $stmt = $mysqli->prepare("INSERT INTO transfers (tid,user,amount) values (?,?,?)");
        $stmt->bind_param("ssi", $tid, $user, $amount);
        $stmt->execute() or die("Error during deposit... </body></html>");
        $stmt->close();
    }

    function withdraw($amount, $user, $pass) {

        # Returns intval($amount) on success, a negative number of failure.
        $value = validateInt($amount);

        #Exit on authentication failure
        if (!authenticate($user, $pass)) {
            exit("User authentication failed.</body></html>");
        }

        #Exit if not valid withdraw
        if (getBalance($user) - $value < 0) {
            exit("Cannot withdraw this amount</body></html>");
        }

        $value *= -1;
        execute_transfer($user, $value);
    }

    function authenticate($user, $pass) {
        global $mysqli;
        $stmt = $mysqli->prepare("SELECT pass FROM users WHERE user = ?");
        $stmt->bind_param("s", $user);
        $stmt->execute() or die("Authentication failed.</body></html>");
        $result = $stmt->get_result();
        $hashedpass = $result->fetch_array();
        $stmt->close();

        return count($hashedpass) == 2 && password_verify($pass, $hashedpass['pass']);
    }

    function exists($user) {
        global $mysqli;
        $stmt = $mysqli->prepare("SELECT user FROM users WHERE user = ?");
        $stmt->bind_param("s", $user);
        $stmt->execute() or die("AAAAAAAAAAAAAAAA</body></html>");
        $result = $stmt->get_result();
        $usr = $result->fetch_array();
        $stmt->close();

        return $usr != null;
    }

    function validateInt($val) {
        $retval = -1;

        if (filter_var($val, FILTER_VALIDATE_INT) === 0 || filter_var($val, FILTER_VALIDATE_INT)) {
            $retval = intval($val);
        }

        if ($retval <= 0) {
            exit("Invalid amount</body></html>");
        }

        return $retval;
    }

    function validateString($str) {
        #Apparentemente il % ha problemi ma va beh
        $filtered = filter_var($str, FILTER_SANITIZE_EMAIL);
        return strcmp($str, $filtered) === 0;
    }

    //Log data for scoring

    function logger() {
        global $mysqli;
        $fh = fopen("/tmp/request.log", 'a') or exit(1);
        $result = $mysqli->query("SELECT * FROM transfers");
        fwrite($fh, "BEGIN\n");
        fwrite($fh, "TRANSFERS\n");
        while ($row = $result->fetch_array()) {
            fwrite($fh, $row['user'] . " " . $row['amount'] . " " . $row['creation_time'] . "\n");
        }

        $result = $mysqli->query("SELECT * FROM users");
        fwrite($fh, "USERS\n");
        while ($row = $result->fetch_array()) {
            fwrite($fh, $row['user'] . " " . $row['pass'] . "\n");
        }
        fwrite($fh, "END\n");
        fclose($fh);
    }

    ?>

</body>

</html>