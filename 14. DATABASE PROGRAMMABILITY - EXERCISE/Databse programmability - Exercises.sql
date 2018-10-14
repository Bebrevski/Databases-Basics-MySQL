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

#-- 7.	Define Function
CREATE FUNCTION ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
RETURNS BIT
DETERMINISTIC
RETURN word REGEXP (CONCAT('^[', set_of_letters, ']+$'));

SELECT ufn_is_word_comprised('oistmiahf', 'Sofia');

#-- 8.	Find Full Name
USE bank;

DELIMITER $$
CREATE PROCEDURE usp_get_holders_full_name()
BEGIN
	SELECT CONCAT_WS(' ', ah.first_name, ah.last_name) AS full_name
    FROM account_holders AS ah
    ORDER BY full_name, ah.id;
END $$

DELIMITER ;
CALL usp_get_holders_full_name();

#-- 9.	People with Balance Higher Than
DELIMITER $$
CREATE PROCEDURE usp_get_holders_with_balance_higher_than(balance_limit DECIMAL(20,4))
BEGIN
	SELECT ah.first_name, ah.last_name
    FROM account_holders AS ah
    INNER JOIN (
		SELECT a.id, a.account_holder_id, SUM(a.balance) AS total_balance
        FROM accounts AS a
        GROUP BY a.account_holder_id
        HAVING total_balance > balance_limit
    ) AS a ON ah.id = a.account_holder_id
    ORDER BY ah.first_name, ah.last_name;
END $$

DELIMITER ;
CALL usp_get_holders_with_balance_higher_than(7000);

#-- 10.	Future Value Function
DELIMITER $$
CREATE FUNCTION ufn_calculate_future_value(
	in_sum DOUBLE, 
    yearly_interest_rate DOUBLE, 
    number_of_years INT)
RETURNS DOUBLE
DETERMINISTIC
BEGIN
	DECLARE result DOUBLE;
    SET result := in_sum * POW((1 + yearly_interest_rate), number_of_years);
	RETURN result;
END $$

DELIMITER ;
SELECT ufn_calculate_future_value(1000, 0.1, 5);

#-- 11.	Calculating Interest
DELIMITER $$
CREATE PROCEDURE usp_calculate_future_value_for_account(
	in_account_id INT, 
	interest_rate DECIMAL(19, 4))
BEGIN
	SELECT 
		a.id AS account_id, 
        ah.first_name, 
        ah.last_name,
        a.balance AS current_balance,
        ufn_calculate_future_value(a.balance, interest_rate, 5) AS balance_in_5_years
	FROM account_holders AS ah
    INNER JOIN accounts AS a
    ON a.account_holder_id = ah.id
    WHERE a.id = in_account_id;
END $$

DELIMITER ;

CALL usp_calculate_future_value_for_account(1, 0.1);

#Another solution without using the procedure from the previous task

#CREATE PROCEDURE usp_calculate_future_value_for_account(
#    acc_id INT(11),
#    rate DECIMAL(19,4))
#BEGIN
#    DECLARE value DECIMAL(19,4);
#    DECLARE balance DECIMAL(19,4);
#    SET balance := (SELECT a.balance FROM accounts AS a WHERE a.id = acc_id);
#    SET value := balance * (pow(1 + rate, 5));
#    SELECT
#        a.id AS 'account_id',
#        ah.first_name,
#        ah.last_name,
#        balance AS 'current_balance',
#        value AS 'balance_in_5_years'
#    FROM accounts AS a
#        JOIN account_holders AS ah
#        ON a.account_holder_id = ah.id
#        AND
#        a.id = acc_id;
#END

#-- 12.	Deposit Money
DELIMITER $$
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
	IF money_amount > 0 THEN
		START TRANSACTION;
		
		UPDATE accounts AS a
		SET a.balance = a.balance + money_amount
		WHERE a.id = account_id;
		
		IF (
			SELECT a.balance
			FROM accounts AS a
			WHERE a.id = account_id
		) < 0
		THEN ROLLBACK;
		ELSE COMMIT;
		END IF;
	END IF;
END $$

DELIMITER ;

CALL usp_deposit_money(1, 10);

SELECT 
    a.id AS account_id, a.account_holder_id, a.balance
FROM
    accounts AS a
WHERE
    a.id = 1;
    
#-- 13.	Withdraw Money
DELIMITER $$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19, 4))
BEGIN
	IF money_amount > 0 THEN
		START TRANSACTION;
		
		UPDATE accounts AS a
		SET a.balance = a.balance - money_amount
		WHERE a.id = account_id;
		
		IF (
			SELECT a.balance
			FROM accounts AS a
			WHERE a.id = account_id
		) < money_amount
		THEN ROLLBACK;
		ELSE COMMIT;
		END IF;
	END IF;
END $$

DELIMITER ;

CALL usp_withdraw_money(1, 10);

SELECT 
    a.id AS account_id, a.account_holder_id, a.balance
FROM
    accounts AS a
WHERE
    a.id = 1;
    
#-- 14.	Money Transfer


