-- QUERY ON THE DATABASE

-- Get list of users
	SELECT user FROM mysql.user;

-- Get list of permission of a user
	SHOW GRANTS;

--________________________________________________________________________________________________________

--  QUERY ON USERS

-- Insert a user
	insert into users values('kate','ba3253876aed6bc22d4a6ff53d8406c6ad864195ed144ab5c87621b6c233b548baeae6956df346ec8c17f5ea10f35ee3cbc514797ed7ddd3145464e2a0bab413');

-- Retrive all users 
    SELECT * FROM users;

-- Retrive specific users
    SELECT * FROM users WHERE user = '';


-- QUERY ON TRANSFERS

-- Insert a transfer 
	INSERT INTO transfers VALUES ('213f908bcdfbd88214f567702a9d3626', 'kate','300', '2021-12-01 05:51:08');

-- Retrive all transfers 
	SELECT * FROM transfers;

-- Retrive all the transfers made from a user 
	SELECT * FROM transfers WHERE user = '';

-- Retrive a transfers with a specific ID 
	SELECT * FROM transfers WHERE tid = '';

-- Retrive all the transfers made in a specific moment 
	SELECT * FROM transfers WHERE creation_time LIKE '%05:00:00';

-- Retrive all the transfers made in a specific timestamp 
	SELECT * FROM transfers WHERE creation_time LIKE '%05:50:%' AND creation_time NOT LIKE '%05:51:%';

-- Retrive all the transaction not associated with a user 
	SELECT * FROM transfers WHERE user NOT IN (SELECT user FROM users);

-- Retrive the balance of a user
	SELECT SUM(amount) as balance FROM transfers USE INDEX (user) WHERE user = '' ORDER BY NULL;

-- Retrive all the user with a balance < 0 
	SELECT user, SUM(amount) AS total FROM transfers GROUP BY (user) HAVING total < 0 ;