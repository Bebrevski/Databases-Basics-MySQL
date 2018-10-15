CREATE DATABASE buhtig;
USE buhtig;

#                           Section 1: Data Definition Language (DDL)
#-- 01.	Table Design
CREATE TABLE users (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    password VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL
);

CREATE TABLE repositories (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE repositories_contributors (
    repository_id INT(11),
    contributor_id INT(11),
    CONSTRAINT fk_repositories_contributors_repositories
		FOREIGN KEY (repository_id)
        REFERENCES repositories (id),
    CONSTRAINT fk_repositories_contributors_users
		FOREIGN KEY (contributor_id)
        REFERENCES users (id)
);

CREATE TABLE issues (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    issue_status VARCHAR(6) NOT NULL,
    repository_id INT(11) NOT NULL,
    assignee_id INT(11) NOT NULL,
    CONSTRAINT fk_issues_repositories
		FOREIGN KEY (repository_id)
        REFERENCES repositories (id),
	CONSTRAINT fk_issues_users
		FOREIGN KEY (assignee_id)
        REFERENCES users (id)
);

CREATE TABLE commits(
	id INT(11) AUTO_INCREMENT PRIMARY KEY,
	message VARCHAR(255) NOT NULL,
	issue_id INT(11),
	repository_id INT(11) NOT NULL,
	contributor_id INT(11) NOT NULL,
	CONSTRAINT fk_commits_issues
		FOREIGN KEY (issue_id)
        REFERENCES issues (id),
	CONSTRAINT fk_commits_repositories
		FOREIGN KEY (repository_id)
        REFERENCES repositories (id),
	CONSTRAINT fk_commits_users
		FOREIGN KEY (contributor_id)
        REFERENCES users (id)
);

CREATE TABLE files (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    size DECIMAL(10 , 2 ) NOT NULL,
    parent_id INT(11),
    commit_id INT(11) NOT NULL,
    CONSTRAINT fk_files_files
		FOREIGN KEY (parent_id)
        REFERENCES files (id),
	CONSTRAINT fk_files_commits
		FOREIGN KEY (commit_id)
        REFERENCES commits (id)
);

#                     Section 2: Data Manipulation Language (DML)
#-- 02.	Data Insertion
INSERT INTO issues(title, issue_status, repository_id, assignee_id)
	SELECT
		CONCAT('Critical Problem With ', f.name, '!') AS title,
        'open' AS issue_status,
        CEIL((f.id * 2) / 3) AS repository_id,
        c.contributor_id AS assignee_id
	FROM files AS f
    INNER JOIN commits AS c ON f.commit_id = c.id
    WHERE f.id BETWEEN 46 AND 50;

#-- 03.	Data Update
UPDATE repositories_contributors AS rc
JOIN(	
    SELECT 
        r.id AS repo
    FROM
        repositories AS r
    WHERE r.id NOT IN 
			(SELECT 
                repository_id
            FROM
                repositories_contributors)
                
			ORDER BY r.id
			LIMIT 1
	) AS j 
SET 
    rc.repository_id = j.repo
WHERE
    rc.contributor_id = rc.repository_id;

#-- 04.	Data Deletion
DELETE r 
FROM repositories AS r
LEFT JOIN issues AS i ON r.id = i.repository_id
WHERE i.id IS NULL;

#                             Section 3: Querying
#-- 05.	Users
SELECT u.id, u.username
FROM users AS u
ORDER BY u.id;

#--06.	Lucky Numbers
SELECT *
FROM repositories_contributors AS rc
WHERE rc.repository_id = rc.contributor_id
ORDER BY rc.repository_id;

#-- 07.	Heavy HTML
SELECT f.id, f.name, f.size
FROM files AS f
WHERE f.size > 1000 AND f.name LIKE '%html%'
ORDER BY f.size DESC;

#-- 08.	Issues and Users
SELECT 
    i.id,
    CONCAT_WS(' : ', u.username, i.title) AS issue_assignee
FROM issues AS i
	JOIN users AS u 
	ON i.assignee_id = u.id
ORDER BY i.id DESC;

#-- 09.	Non-Directory Files
SELECT
	f.id,
    f.name,
    CONCAT(f.size, 'KB') AS 'size'
FROM files AS f
	LEFT JOIN files AS f2
	ON f.id = f2.parent_id
	WHERE f2.id IS NULL;

#-- 10.	Active Repositories
SELECT
	r.id,
    r.name,
    COUNT(i.id) AS issues
FROM repositories AS r
	INNER JOIN issues AS i
    ON i.repository_id = r.id
GROUP BY r.id
ORDER BY issues DESC, r.id
LIMIT 5;

#-- 11.	Most Contributed Repository






