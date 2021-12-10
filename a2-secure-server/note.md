# CREATE AN USER WITH R/W PRIVILAGE ON THE TWO TABLES USERS AND TRANSACTIONS

Create the `editor`:
  
    CREATE USER 'editor'@'localhost' IDENTIFIED BY 'verysecurepassword';

Grant the permission to the `editor`:

    GRANT SELECT, INSERT ON ctf2.* TO 'editor'@'localhost';
