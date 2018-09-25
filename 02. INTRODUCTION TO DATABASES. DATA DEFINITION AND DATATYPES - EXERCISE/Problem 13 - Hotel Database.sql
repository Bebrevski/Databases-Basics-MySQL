CREATE DATABASE `hotel`;
USE `hotel`;

CREATE TABLE `employees` (
	`id` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`first_name` VARCHAR(30) NOT NULL,
	`last_name` VARCHAR(30) NOT NULL,
	`title` VARCHAR(30) NOT NULL,
	`notes` VARCHAR(128)
);

INSERT INTO `employees`
		(`first_name`, `last_name`, `title`, `notes`)
	VALUES 
		('Gosho', 'Goshev', 'Boss', ''),
		('Pesho', 'Peshev', 'Supervisor', ''),
		('Bai', 'Ivan', 'Worker', 'Can do any work');

CREATE TABLE `customers` (
	`account_number` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`first_name` VARCHAR(30) NOT NULL,
	`last_name` VARCHAR(30) NOT NULL,
	`phone_number` VARCHAR(20) NOT NULL,
	`emergency_name` VARCHAR(50),
	`emergency_number` VARCHAR(20),
	`notes` VARCHAR(128)
);

INSERT INTO `customers`
		(`first_name`, `last_name`, `phone_number`)
	VALUES 
		('Gosho', 'Goshev', '123'),
		('Pesho', 'Peshev', '44-2432'),
		('Bai', 'Ivan', '007');

CREATE TABLE `room_status` (
	`room_status` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`notes` VARCHAR(128)
);

INSERT INTO `room_status` 
		(`notes`)
	VALUES 
		('Free'),
		('For clean'),
		('Occupied');

CREATE TABLE `room_types` (
	`room_type` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`notes` VARCHAR(128)
);

INSERT INTO `room_types` 
		(`notes`)
	VALUES 
		('Small'),
		('Medium'),
		('Appartment');


CREATE TABLE `bed_types` (
	`bed_type` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`notes` VARCHAR(128)
);

INSERT INTO `bed_types` 
		(`notes`)
	VALUES 
		('Single'),
		('Double'),
		('Water-filled');

CREATE TABLE `rooms` (
	`room_number` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`room_type` INT UNSIGNED NOT NULL,
	`bed_type` INT UNSIGNED NOT NULL,
	`rate` DOUBLE DEFAULT 0,
	`room_status` INT UNSIGNED NOT NULL,
	`notes` VARCHAR(128)
);

INSERT INTO `rooms` 
		(`room_type`, `bed_type`, `room_status`)
	VALUES 
		(1, 1, 1),
		(2, 2, 2),
		(3, 3, 3);

CREATE TABLE `payments` (
	`id` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`employee_id` INT UNSIGNED NOT NULL,
	`payment_date` DATE NOT NULL,
	`account_number` INT UNSIGNED NOT NULL,
	`first_date_occupied` DATE,
	`last_date_occupied` DATE,
	`total_days` INT UNSIGNED,
	`amount_charged` DOUBLE,
	`tax_rate` DOUBLE,
	`tax_amount` DOUBLE,
	`payment_total` DOUBLE,
	`notes` VARCHAR(128)
);

INSERT INTO `payments` 
		(`employee_id`, `payment_date`, `account_number`)
	VALUES 
		(1, DATE(NOW()), 1),
		(2, DATE(NOW()), 2),
		(3, DATE(NOW()), 3);


CREATE TABLE `occupancies` (
	`id` INT UNSIGNED PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT,
	`employee_id` INT UNSIGNED NOT NULL,
	`date_occupied` DATE NOT NULL,
	`account_number` INT UNSIGNED NOT NULL,
	`room_number` INT UNSIGNED NOT NULL,
	`rate_applied` DOUBLE,
	`phone_charge` DOUBLE,
	`notes` VARCHAR(128)
);

INSERT INTO `occupancies` 
		(`employee_id`, `date_occupied`, `account_number`, `room_number`)
	VALUES 
		(1, DATE(NOW()), 1, 1),
		(2, DATE(NOW()), 2, 2),
		(3, DATE(NOW()), 3, 3);
