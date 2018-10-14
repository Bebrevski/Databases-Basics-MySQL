#-- 1.	Employees with Salary Above 35000
USE soft_uni;

DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above_35000()
BEGIN
	SELECT e.first_name, e.last_name
    FROM employees AS e
    WHERE e.salary > 35000
    ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

DELIMITER ;
CALL usp_get_employees_salary_above_35000();

#-- 2.	Employees with Salary Above Number
DELIMITER $$
CREATE PROCEDURE usp_get_employees_salary_above(given_number DECIMAL(20, 4))
BEGIN
	SELECT e.first_name, e.last_name
    FROM employees AS e
    WHERE e.salary >= given_number
    ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

DELIMITER ;
CALL usp_get_employees_salary_above(48100);

#-- 3.	Town Names Starting With
DELIMITER $$
CREATE PROCEDURE usp_get_towns_starting_with (starts_with_pattern VARCHAR(20))
BEGIN
	SELECT t.name AS town_name
    FROM towns AS t
    WHERE t.name LIKE CONCAT(starts_with_pattern, '%')
    ORDER BY town_name;
END $$

DELIMITER ;
CALL usp_get_towns_starting_with ('b');

#-- 4.	Employees from Town
DELIMITER $$
CREATE PROCEDURE usp_get_employees_from_town(town_name VARCHAR(20))
BEGIN
	SELECT e.first_name, e.last_name
    FROM employees AS e
    INNER JOIN addresses AS a ON e.address_id = a.address_id
    INNER JOIN towns as t ON t.town_id = a.town_id
    WHERE t.name = town_name
    ORDER BY e.first_name, e.last_name, e.employee_id;
END $$

DELIMITER ;
CALL  usp_get_employees_from_town('Sofia');

#-- 5.	Salary Level Function
CREATE FUNCTION ufn_get_salary_level (salary_of_an_employee DECIMAL(20,4))
RETURNS VARCHAR(10)
DETERMINISTIC
RETURN(
	CASE
		WHEN salary_of_an_employee < 30000 THEN 'Low'
        WHEN salary_of_an_employee <= 50000 THEN 'Average'
        ELSE 'High'
    END
);

SELECT salary, ufn_get_salary_level(e.salary) FROM employees AS e;

#-- 6.	Employees by Salary Level
DELIMITER $$
CREATE PROCEDURE usp_get_employees_by_salary_level(salary_level VARCHAR(7))
BEGIN
    SELECT e.first_name, e.last_name
    FROM employees AS e
    WHERE e.salary < 30000 AND salary_level = 'low'
        OR e.salary >= 30000 AND e.salary <= 50000 AND salary_level = 'average'
        OR e.salary > 50000 AND salary_level = 'high'
    ORDER BY e.first_name DESC, e.last_name DESC;
END $$
DELIMITER ;
	










