CREATE DATABASE `one_to_one`;
USE `one_to_one`;

#-- 1.	One-To-One Relationship
CREATE TABLE `persons` (
    `person_id` INT(11) UNSIGNED UNIQUE NOT NULL AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `salary` DECIMAL(10 , 2 ) NOT NULL DEFAULT 0,
    `passport_id` INT(11) UNSIGNED NOT NULL UNIQUE
);

CREATE TABLE `passports` (
    `passport_id` INT(11) UNSIGNED UNIQUE PRIMARY KEY AUTO_INCREMENT ,
    `passport_number` VARCHAR(8) NOT NULL UNIQUE
)  AUTO_INCREMENT=101;

INSERT 
	INTO `persons` (`first_name`, `salary`, `passport_id`) 
	VALUES 
		('Roberto', 43300, 102), 
		('Tom', 56100, 103), 
		('Yana', 60200, 101);

INSERT 
	INTO `passports` (`passport_number`) 
    VALUES ('N34FG21B'), ('K65LO4R7'), ('ZE657QP2');

ALTER TABLE `persons` 
	ADD CONSTRAINT `pk_persons` 
		PRIMARY KEY (`person_id`),
    ADD CONSTRAINT `fk_persons_passports` 
		FOREIGN KEY(`passport_id`) 
        REFERENCES `passports`(`passport_id`);

#-- 2.	One-To-Many Relationship
CREATE DATABASE `one_to_many`;
USE `one_to_many`;

CREATE TABLE `manufacturers` (
    `manufacturer_id` INT(11) UNSIGNED UNIQUE NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL UNIQUE,
    `established_on` DATE NOT NULL
);

CREATE TABLE `models` (
    `model_id` INT(11) UNSIGNED UNIQUE NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL,
    `manufacturer_id` INT(11) UNSIGNED NOT NULL
)  AUTO_INCREMENT=101;

ALTER TABLE `manufacturers`
	ADD CONSTRAINT `pk_manufacturers`
    PRIMARY KEY (`manufacturer_id`);
    
ALTER TABLE `models`
	ADD CONSTRAINT `pk_models`
		PRIMARY KEY (`model_id`),
ADD CONSTRAINT `fk_models_manufacturers`
		FOREIGN KEY (`manufacturer_id`)
    REFERENCES `manufacturers`(`manufacturer_id`);

INSERT 
	INTO `manufacturers` (`name`, `established_on`) 
	VALUES 
		('BMW', '1916-03-01'), 
		('Tesla', '2003-01-01'), 
		('Lada', '1966-05-01');
        
INSERT 
	INTO `models` (`name`, `manufacturer_id`) 
	VALUES 
		('X1', 1), 
		('i6', 1), 
		('Model S', 2),
        ('Model X', 2),
        ('Model 3', 2),
        ('Nova', 3);

#-- 3.	Many-To-Many Relationship
CREATE DATABASE `many_to_many`;
USE `many_to_many`;

CREATE TABLE `students` (
    `student_id` INT(11) UNSIGNED UNIQUE NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL
);

CREATE TABLE `exams` (
    `exam_id` INT(11) UNSIGNED UNIQUE NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL
)  AUTO_INCREMENT=101;

CREATE TABLE `students_exams` (
    `student_id` INT(11) UNSIGNED NOT NULL,
    `exam_id` INT(11) UNSIGNED NOT NULL
);

ALTER TABLE `students`
	ADD CONSTRAINT `pk_students`
    PRIMARY KEY (`student_id`);
    
ALTER TABLE `exams`
	ADD CONSTRAINT `pk_exams`
    PRIMARY KEY (`exam_id`);
    
ALTER TABLE `students_exams`
	ADD CONSTRAINT `pk_students_exams`
		PRIMARY KEY (`student_id`, `exam_id`),
    ADD CONSTRAINT `fk_students_exams_students`
		FOREIGN KEY (`student_id`)
		REFERENCES `students` (`student_id`),
    ADD CONSTRAINT `fk_students_exams_exams`
		FOREIGN KEY (`exam_id`)
		REFERENCES `exams` (`exam_id`);

INSERT
	INTO `students` (`name`) 
		VALUES 
			('Mila'), 
			('Toni'), 
			('Ron');
            
INSERT
	INTO `exams` (`name`) 
		VALUES 
			('Spring MVC'), 
			('Neo4j'), 
			('Oracle 11g');
            
INSERT 
	INTO `students_exams`
    VALUES  
		(1, 101),
		(1, 102),
		(2, 101),
		(3, 103),
		(2, 102),
		(2, 103);






