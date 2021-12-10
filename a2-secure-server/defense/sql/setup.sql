drop database if exists ctf2;

create database ctf2;

/* creating the database and now create the two tables */
use ctf2;

create table users (
    user VARCHAR(32) NOT NULL UNIQUE, 
    pass VARCHAR(1024) NOT NULL, 
    balance BIGINT NOT NULL DEFAULT 0,
    primary key (user)
) ENGINE=InnoDB;

create table transfers (
    tid VARCHAR(36) NOT NULL,
    user VARCHAR(32) NOT NULL, 
    amount BIGINT NOT NULL,
    creation_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (tid), 
    FOREIGN KEY (user) REFERENCES users (user) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


/* creating the editor profile with just the privilage needed to perform insert and select into the database */
CREATE USER 'editor'@'localhost' IDENTIFIED BY 'KAWQfaSfn2REWhc@T#i^9F87cnm%8^';
GRANT SELECT, INSERT, UPDATE ON ctf2.users TO 'editor'@'localhost';
GRANT SELECT, INSERT ON ctf2.transfers TO 'editor'@'localhost';

CREATE USER 'monitor'@'localhost' IDENTIFIED BY 'dfvYp$6^L4rNv3RdCWF6hef*LSnfi&';
GRANT SELECT ON ctf2.users TO 'monitor'@'localhost';
GRANT SELECT ON ctf2.transfers TO 'monitor'@'localhost';
GRANT LOCK TABLES ON ctf2.* TO 'monitor'@'localhost';
GRANT PROCESS ON *.* TO 'monitor'@'localhost';
