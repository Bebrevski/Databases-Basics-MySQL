#-- 1.	Managers
USE soft_uni;

SELECT 
    e.employee_id,
    CONCAT_WS(' ', e.first_name, e.last_name) AS full_name,
    d.department_id,
    d.name AS department_id
FROM
    departments AS d
        INNER JOIN
    employees AS e 
		ON e.employee_id = d.manager_id
ORDER BY e.employee_id
LIMIT 5;

#-- 2.	Towns Adresses