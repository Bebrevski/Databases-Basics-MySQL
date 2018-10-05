CREATE DATABASE `table_relations_lab`;
USE `table_relations_lab`;

CREATE TABLE `mountains`(
	`id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `peaks`(
	`id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `mountain_id` INT(11) NOT NULL,
    CONSTRAINT fk_peaks_mountains
    FOREIGN KEY (`mountain_id`)
    REFERENCES `mountains`(`id`)
);

