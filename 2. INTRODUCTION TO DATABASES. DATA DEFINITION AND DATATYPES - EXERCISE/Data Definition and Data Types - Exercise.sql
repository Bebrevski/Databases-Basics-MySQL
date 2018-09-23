CREATE DATABASE movies;
USE movies;

CREATE TABLE directors (
	id INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
    director_name VARCHAR(30) NOT NULL,
    notes TEXT
);

CREATE TABLE genres (
	id INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	genre_name VARCHAR(30) NOT NULL,
	notes TEXT
);

CREATE TABLE categories (
	id INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	category_name VARCHAR(30) NOT NULL,
	notes TEXT
);

CREATE TABLE movies (
	id INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
    title VARCHAR(30) NOT NULL,
    director_id INT UNSIGNED NOT NULL,
    copyright_year YEAR NOT NULL,
    length TIME NOT NULL,
    genre_id INT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    rating DOUBLE NOT NULL DEFAULT 0,
    notes TEXT
);

INSERT INTO movies
	(id, title, director_id, copyright_year, length, genre_id, category_id)
VALUES
	(11,"aaa",2,'2015',23,1,2),
	(10,"bbb",2,'2016',23,1,2),
	(13,"ccc",2,'2017',23,1,2),
	(14,"ddd",2,'2018',23,1,2),
	(15,"eee",1,'2019',23,1,2);

INSERT INTO directors
	(id, director_name, notes)
VALUES
	(1,'dasdasd','fasdfasdfasdfa'),
	(2,'dasdasd','fasdfasdfasdfa'),
	(3,'dasdasd','fasdfasdfasdfa'),
	(4,'dasdasd','fasdfasdfasdfa'),
	(5,'dasdasd','fasdfasdfasdfa');

INSERT INTO categories
	(id, category_name)
VALUES
	(1,'wi-fi'),
	(2,'wi-fi'),
	(3,'wi-fi'),
	(4,'wi-fi'),
	(5,'wi-fi');

INSERT INTO genres
	( id, genre_name, notes)
VALUES
	(2,'dasdad','dfhdfh'),
	(1,'dasdad','dfhdfh'),
	(3,'dasdad','dfhdfh'),
	(4,'dasdad','dfhdfh'),
	(5,'dasdad','dfhdfh');