USE soft_uni;

#-- 1.	Count Employees by Town
CREATE FUNCTION ufn_count_employees_by_town(town_name VARCHAR(20))
RETURNS INT
DETERMINISTIC
RETURN (
		SELECT COUNT(e.employee_id) 
		FROM employees AS e
			JOIN addresses AS a ON a.address_id = e.address_id
			JOIN towns AS t ON t.town_id = a.town_id
        WHERE t.name = town_name
);

DELIMITER ;

#Test
SELECT ufn_count_employees_by_town('Sofia');

#Cleanup
DROP FUNCTION IF EXISTS ufn_count_employees_by_town;

#-- 2.	Employees Promotion
