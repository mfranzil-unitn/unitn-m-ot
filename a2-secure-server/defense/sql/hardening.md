USEFUL PARAMS

  ssh -L 7777:server.cctf-ss.offtech:80 deter

  root QH^T%U@gy4e3kd9*d^k6ixkzQ
  editor KAWQfaSfn2REWhc@T#i^9F87cnm%8^
  monitor dfvYp$6^L4rNv3RdCWF6hef*LSnfi&

Get information about current user and other useful information
    status

Get the list of the database
    show databases;

Get the list of the table of a databases
    show tables;

Show information about the table
    describe "name of table";

Show connected user (root required)
    show processlist;

Seems to be some default user such as:
    debian-sys-maint with password Tr8dWXFtKqJNl5Xo # better not to delete it
    sys.mysql # not possible to login using this user
    session.mysql # not possible to login using this user

In case you want to drop it anyways:
    DROP USER 'debian-sys-maint'@'localhost';

--secure-file-priv option should be enabled to avoid mysql to access local file with command such as (disabled by default):
    LOAD DATA INFILE '~/test.txt' INTO TABLE ctf2.users FIELDS TERMINATED BY ',';

where text.txt contains:
    lorenzo,pippo

Access is allowed only from localhost by default

Rename the root account
    RENAME USER ‘root’@’localhost’ TO ‘adminsuperpower’@’localhost’;7
    FLUSH PRIVILEGES;

Installing the access control plugin, it will add an increasing delay after 3 failed login:

At runtime

    INSTALL PLUGIN CONNECTION_CONTROL SONAME 'connection_control.so';
    INSTALL PLUGIN CONNECTION_CONTROL_FAILED_LOGIN_ATTEMPTS SONAME 'connection_control.so';
    SET PERSIST connection_control_failed_connections_threshold = 3;
    SET PERSIST connection_control_min_connection_delay = 1000;

In my.cnf:

    [mysqld]
    plugin-load-add=connection_control.so
    connection_control_failed_connections_threshold=3
    connection_control_min_connection_delay=2000 

Logging in real time in a file

    sudo touch /var/log/mysql/general.log
    sudo chown mysql:adm /var/log/mysql/general.log  

    [mysqld]
    general_log = on
    general_log_file=/var/log/mysql/general.log


Logging in real time in a table (use file to switch back to filemode)

    SET GLOBAL general_log = 'ON';
    SET global log_output = 'table'; 

    SET GLOBAL general_log='OFF';

    SELECT * FROM mysql.general_log WHERE user_host LIKE '%editor%';

    SELECT * FROM mysql.general_log WHERE user_host LIKE '%editor%' AND event_time BETWEEN DATE_SUB(NOW(), INTERVAL 45 MINUTE) AND NOW();
