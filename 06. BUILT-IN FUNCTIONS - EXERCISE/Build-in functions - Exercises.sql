USE `soft_uni`;
#-- 1.	Find Names of All Employees by First Name
SELECT `first_name`, `last_name`
FROM `employees`
WHERE LEFT(`first_name`, 2) = 'Sa'
ORDER BY `employee_id`;

#-- 2.	Find Names of All employees by Last Name 
SELECT `first_name`, `last_name`
FROM `employees`
WHERE `last_name` LIKE ('%ei%')
ORDER BY `employee_id`;

#-- 3.	Find First Names of All Employees
SELECT `first_name`, `last_name`
FROM `employees`
WHERE 
	`department_id` in (3, 10) AND
    YEAR(`hire_date`) >= 1995 AND
    YEAR(`hire_date`) <= 2005
ORDER BY `employee_id`;

#-- 4.	Find All Employees Except Engineers
SELECT `first_name`, `last_name`
FROM `employees`
WHERE `job_title` NOT LIKE ('%engineer%')
ORDER BY `employee_id`;

#-- 5.	Find Towns with Name Length
SELECT `name`
FROM `towns`
WHERE CHAR_LENGTH(`name`) IN (5, 6)
ORDER BY `name`;

#-- 6.	 Find Towns Starting With
SELECT `town_id`, `name`
FROM `towns`
WHERE `name` REGEXP '^[MmKkBbEe]'
ORDER BY `name`;

#-- 7.	 Find Towns Not Starting With
SELECT `town_id`, `name`
FROM `towns`
WHERE `name` REGEXP '^[^RBDrbd]'
ORDER BY `name`;

#-- 8.	Create View Employees Hired After 2000 Year
