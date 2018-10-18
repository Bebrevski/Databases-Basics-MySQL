CREATE DATABASE instagraph;
USE instagraph;

#                             Section 1: Data Definition Language (DDL)
#-- 01.	Table Design
CREATE TABLE pictures(
	id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    path VARCHAR(255) NOT NULL,
    size DECIMAL(10, 2) NOT NULL
);

CREATE TABLE users(
	id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    password VARCHAR(30) NOT NULL,
    profile_picture_id INT(11),
		CONSTRAINT fk_users_pictures
			FOREIGN KEY users (profile_picture_id)
			REFERENCES pictures (id)
);

CREATE TABLE posts (
    id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    caption VARCHAR(255) NOT NULL,
    user_id INT(11) NOT NULL,
    picture_id INT(11) NOT NULL,
		CONSTRAINT fk_posts_users 
			FOREIGN KEY (user_id)
			REFERENCES users (id),
        CONSTRAINT fk_posts_pictures
			FOREIGN KEY posts (picture_id)
            REFERENCES pictures (id)
);

CREATE TABLE comments(
	id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
    content VARCHAR(255) NOT NULL,
    user_id INT(11) NOT NULL,
    post_id INT(11) NOT NULL,
		CONSTRAINT fk_comments_users
			FOREIGN KEY comments (user_id)
            REFERENCES users (id),
		CONSTRAINT fk_comments_posts
			FOREIGN KEY comments (post_id)
            REFERENCES posts (id)
);

CREATE TABLE users_followers(
	user_id INT(11),
    follower_id INT(11),
		CONSTRAINT fk_users_followers_users
			FOREIGN KEY users_followers (user_id)
            REFERENCES users (id),
		CONSTRAINT fk_users_followers_followers
			FOREIGN KEY users_followers (follower_id)
            REFERENCES users (id)
);


#                           Section 2: Data Manipulation Language (DML) 
#-- 02.	Data Insertion
INSERT INTO comments(content, user_id, post_id)
	SELECT
		
        CONCAT('Omg!', u.username, '!This is so cool!') AS content,
        
		CEIL(p.id * 3 / 2) AS user_id,
        
        p.id AS post_id
        
	FROM posts AS p
    JOIN users AS u ON p.user_id = u.id
    WHERE p.id BETWEEN 1 AND 10;

#-- 03.	Data Update
UPDATE users AS u 
SET u.profile_picture_id = (SELECT COUNT(uf.follower_id) 
							FROM users_followers AS uf
                            WHERE u.id = uf.user_id
                            GROUP BY uf.user_id)
WHERE u.profile_picture_id IS NULL;
                            

#-- 04.	Data Deletion
DELETE u 
FROM users AS u
LEFT JOIN users_followers AS uf
ON u.id = uf.user_id
WHERE uf.user_id IS NULL AND uf.follower_id IS NULL;

#                                     Section 3: Querying
#-- 05.	Users
SELECT u.id, u.username
FROM users AS u
ORDER BY u.id;

#-- 06.	Cheaters
SELECT u.id, u.username
FROM users_followers AS uf
INNER JOIN users AS u 
ON uf.user_id = u.id
WHERE user_id = follower_id
ORDER BY user_id;

#-- 07.	High Quality Pictures
SELECT id, path, size
FROM pictures
WHERE size > 50000 AND (path LIKE ('%.jpeg') OR path LIKE ('%.png'))
ORDER BY size DESC;

#-- 08.	Comments and Users
SELECT 
	c.id,
    CONCAT(u.username, ' : ', c.content) AS full_comment
FROM comments AS c
JOIN users AS u
ON c.user_id = u.id
ORDER BY c.id DESC;

#-- 09.	Profile Pictures
SELECT 
	u1.id,
    u1.username,
    CONCAT(p.size, 'KB') AS size
FROM users AS u1
JOIN users AS u2
ON u1.profile_picture_id = u2.profile_picture_id AND u1.id <> u2.id
JOIN pictures AS p
ON u1.profile_picture_id = p.id
GROUP BY u1.id
ORDER BY u1.id;

#-- 10.	Spam Posts (след обръщане на таблиците минават всички тестове!)
SELECT 
	p.id,
    p.caption,
    COUNT(c.id) AS comments
FROM posts AS p
LEFT JOIN comments AS c ON c.post_id = p.id
GROUP BY p.id
ORDER BY comments DESC, p.id
LIMIT 5;

#-- 11.	Most Popular User
SELECT
	u.id,
    u.username,
    (
		SELECT COUNT(p.id) AS posts
		FROM posts AS p
		WHERE p.user_id = uf.user_id
		GROUP BY p.user_id
    ) AS posts,
    COUNT(uf.follower_id) AS followers
FROM users_followers AS uf
INNER JOIN users AS u
ON uf.user_id = u.id
GROUP BY uf.user_id
ORDER BY followers DESC
LIMIT 1;

#-- 12.	Commenting Myself (!!!)
SELECT 
	u.id, 
    u.username, 
    (CASE 
		WHEN  tb.my_comments IS NULL 
        THEN 0 
        ELSE tb.my_comments 
	END) as my_comments
FROM users u
LEFT JOIN
	(
		SELECT p.id, p.user_id, count(p.id) as my_comments
		FROM posts p
		JOIN comments c
		ON p.id = c.post_id
		WHERE p.user_id = c.user_id
		GROUP BY p.user_id
    ) as tb
ON u.id = tb.user_id
ORDER BY tb.my_comments DESC, u.id;

#-- 13.	User Top Posts
SELECT cq.user_id, u.username, cq.caption
FROM 
(
	SELECT p.id, p.user_id, p.caption, count(c.id) AS comments_count
    FROM posts AS p
    LEFT JOIN comments AS c ON c.post_id = p.id
    GROUP BY p.id
    ORDER BY comments_count DESC, p.id
) AS cq
JOIN users AS u ON cq.user_id = u.id
GROUP BY cq.user_id
ORDER BY cq.user_id;

#--14.	Posts and Commentators
SELECT 
	p.id, 
    p.caption, 
    COUNT(DISTINCT(c.user_id)) AS users
FROM posts AS p
LEFT JOIN comments AS c ON c.post_id = p.id
GROUP BY p.id
ORDER BY users DESC, p.id;
    
#                             Section 4: Programmability
#-- 15.	Post
#DROP PROCEDURE udp_post;
DELIMITER $$
CREATE PROCEDURE udp_post(
	username VARCHAR(30),
	password VARCHAR(30), 
	caption VARCHAR(255), 
	path VARCHAR(255))
BEGIN

	DECLARE user_id INT(11);
    DECLARE picture_id INT(11);

	IF ((
		SELECT u.password 
        FROM users AS u
        WHERE u.username = username
	) <> password)
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Password is incorrect!';
	END IF;
    
    IF ((
		SELECT COUNT(p.path) 
        FROM pictures AS p
        WHERE p.path = path) = 0)
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'The picture does not exist!';
    END IF;
    
    SET user_id := (
		SELECT id
		FROM users AS u
		WHERE u.username = username 
	);
    
    SET picture_id := (
		SELECT p.id
		FROM pictures AS p
		WHERE p.path LIKE path 
	);
    
    INSERT INTO posts (caption, user_id, picture_id)
    VALUES (caption, user_id, picture_id);
    
END $$

DELIMITER ;

CALL udp_post (
		'UnderSinduxrein',
        '4l8nYGTKMW',
        '#new #procedure',
        'src/folders/resources/images/story/reformatted/img/hRI3TW31rC.img'
		);

CALL udp_post (
		'UnderSinduxrein',
        '4l8nYGTKMW',
        '#new #procedure',
        'src/.img'
		);
        
CALL udp_post (
		'UnderSinduxrein',
        '***',
        '#new #procedure',
        'src/folders/resources/images/story/reformatted/img/hRI3TW31rC.img'
		);
        
#-- 16.	Filter
#DROP PROCEDURE udp_filter;
DELIMITER $$
CREATE PROCEDURE udp_filter(hashtag VARCHAR(255))
BEGIN

	SELECT
		p.id,
		p.caption,
        u.username
    FROM posts AS p
    JOIN users AS u
    ON p.user_id = u.id
    WHERE p.caption LIKE CONCAT('%', CONCAT('#', hashtag), '%')
    ORDER BY p.id;

END $$

DELIMITER ;

CALL udp_filter('cool');









