CREATE DATABASE closed_judge_system;
USE closed_judge_system;

#-- 01.	Table Design
CREATE TABLE users(
	id	INT(11) PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL
);

CREATE TABLE categories(
	id INT(11) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    parent_id INT(11),
    CONSTRAINT fk_categories_categories
		FOREIGN KEY categories(parent_id)
        REFERENCES categories(id)
);

CREATE TABLE contests(
	id INT(11) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    category_id INT(11),
    CONSTRAINT fk_contests_categories
		FOREIGN KEY contests(category_id)
        REFERENCES categories(id)
);

CREATE TABLE problems(
	id INT(11) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    points INT(11) NOT NULL,
    tests INT(11) DEFAULT 0,
    contest_id INT(11),
    CONSTRAINT fk_problems_contests
		FOREIGN KEY problems(contest_id)
        REFERENCES contests(id)
);

CREATE TABLE submissions(
	id INT(11) PRIMARY KEY AUTO_INCREMENT,
    passed_tests INT(11) NOT NULL,
    problem_id INT(11),
    user_id INT(11),
    CONSTRAINT fk_submissions_problems
		FOREIGN KEY submissions(problem_id)
        REFERENCES problems(id),
	CONSTRAINT fk_submissions_users
		FOREIGN KEY submissions(user_id)
        REFERENCES users(id)
);

CREATE TABLE users_contests(
	user_id INT(11),
    contest_id INT(11)
);

ALTER TABLE users_contests
	ADD CONSTRAINT pk_users_contests
		PRIMARY KEY (user_id, contest_id),
	ADD CONSTRAINT fk_users_contests_users
		FOREIGN KEY users_contests(user_id)
        REFERENCES users(id),
	ADD CONSTRAINT fk_users_contests_contests
		FOREIGN KEY users_contests(contest_id)
        REFERENCES contests(id);

#-- 02.	Data Insertion

#-- 03.	Data Update

#-- 04.	Date Deletion

#-- 05.	Users
SELECT
	id, username, email
FROM users
ORDER BY id;

#-- 06.	Root Categories
SELECT
	id, name
FROM categories
WHERE parent_id IS NULL
ORDER BY id;
  
#-- 07.	Well Tested Problems
SELECT 
	id, name, tests
FROM problems
WHERE tests > points AND name LIKE '% %'
ORDER BY id DESC;

#-- 08.	Full Path Problems
SELECT
	p.id, 
    CONCAT(cat.name, ' - ', con.name, ' - ', p.name) AS full_path
FROM problems AS p
INNER JOIN contests AS con ON p.contest_id = con.id
INNER JOIN categories AS cat ON con.category_id = cat.id
ORDER BY p.id;

#-- 09.	Leaf Categories
SELECT
	id, name
FROM categories
WHERE id NOT IN
	(SELECT 
		CASE WHEN parent_id IS NULL 
        THEN 0 
        ELSE parent_id 
        END 
	FROM categories)
ORDER BY name, id DESC;

#-- 10.	Mainstream Passwords
SELECT 
	DISTINCT(u.id), u.username, u.password
FROM users AS u
INNER JOIN users AS u2 ON u.password = u2.password AND u.id <> u2.id
WHERE u.password = u2.password
ORDER BY u.username, u.id;

#-- 11.	Most Participated Contests
SELECT *
FROM 
	(SELECT
		c.id, c.name, COUNT(uc.user_id) AS contestants
	FROM contests AS c
	LEFT JOIN users_contests AS uc ON c.id = uc.contest_id
	GROUP BY c.id
	ORDER BY contestants DESC, c.id DESC # The opposite of the requested order !!!!!!
    LIMIT 5) AS f
ORDER BY f.contestants, f.id;

#-- 12.	Most Valuable Person

#-- 13.	Contests Maximum Points

#-- 14.	Contestants’ Submissions

#-- 15.	Login
CREATE TABLE logged_in_users(
	id	INT(11) PRIMARY KEY,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL
);

DELIMITER $$
DROP PROCEDURE udp_login;

CREATE PROCEDURE udp_login(username VARCHAR(30), password VARCHAR(30))
BEGIN

	DECLARE user_id INT(11);
    DECLARE email VARCHAR(50);
	
    IF 1 <> (SELECT COUNT(*) FROM users AS u WHERE u.username = username)
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Username does not exist!';
    END IF;
    
    IF 1 <> (
		SELECT COUNT(*) FROM users AS u 
		WHERE u.username = username AND u.password = password
	)
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Password is incorrect!';
    END IF;
    
    IF 1 = (SELECT COUNT(*) FROM logged_in_users AS liu WHERE liu.username = username)
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'User is already logged in!';
    END IF;
    
    SET user_id := (
		SELECT u.id
		FROM users AS u
		WHERE u.username = username
		);
        
	SET email := (
		SELECT u.email
		FROM users AS u
		WHERE u.username = username
		);
        
	INSERT INTO logged_in_users(id, username, password, email)
    VALUES (user_id, username, password, email);
    
END $$

DELIMITER ;
CALL udp_login('doge', 'doge');
SELECT * FROM logged_in_users;

CALL udp_login('dogeeee', 'doge');

CALL udp_login('doge', 'dogeeee');

CALL udp_login('doge', 'doge');

# Another way to make validation checks

#IF ((SELECT u.id FROM `users` AS u WHERE u.username = username) IS NULL) THEN
#        SIGNAL SQLSTATE '45000' 
#            SET MESSAGE_TEXT = 'Username does not exist!';
#    ELSEIF ((SELECT u.id FROM `users` AS u WHERE u.username = username AND u.password = password) IS NULL) THEN
#        SIGNAL SQLSTATE '45000' 
#            SET MESSAGE_TEXT = 'Password is incorrect!';
#    ELSEIF ((SELECT l.id FROM `logged_in_users` AS l WHERE l.username = username) IS NOT NULL) THEN
#        SIGNAL SQLSTATE '45000' 
#            SET MESSAGE_TEXT = 'User is already logged in!';
#    ELSE
#        INSERT INTO ... SELECT * FROM ... AS ... WHERE ...
#   END IF;

#-- 16.	Evaluate Submission
CREATE TABLE evaluated_submissions(
	id INT(11) PRIMARY KEY AUTO_INCREMENT,
    problem VARCHAR(100) NOT NULL,
    user VARCHAR(30) NOT NULL,
    result INT(11) NOT NULL
);

DROP PROCEDURE udp_evaluate;

DELIMITER $$
CREATE PROCEDURE udp_evaluate(id INT(11))
BEGIN

	DECLARE problem VARCHAR(100);
    DECLARE username VARCHAR(30);
    DECLARE result INT(11);
		
	 IF 1 <> (SELECT COUNT(*) FROM submissions AS s WHERE s.id = id)
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Submission does not exist!';
    END IF;
    
    SET problem := (
			SELECT p.name
            FROM problems AS p
            JOIN submissions AS s 
            ON s.problem_id = p.id
            WHERE s.id = id
	);
    
    SET username := (
			SELECT u.username
            FROM users AS u
            JOIN submissions AS s 
            ON s.user_id = u.id
            WHERE s.id = id
    );
    
    SET result := (
			SELECT p.points / p.tests * s.passed_tests
            FROM submissions s
            JOIN problems AS p ON s.problem_id = p.id 
            WHERE s.id = id
    );
    
    INSERT INTO evaluated_submissions(id, problem, user, result)
    VALUES(id, problem, username, result);
	
END $$

DELIMITER ;

CALL udp_evaluate(1);








