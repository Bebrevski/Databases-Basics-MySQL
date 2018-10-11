#-- 1.	Managers
USE soft_uni;

SELECT 
    e.employee_id,
    CONCAT_WS(' ', e.first_name, e.last_name) AS full_name,
    d.department_id,
    d.name AS department_id
FROM
    employees AS e
        INNER JOIN
    departments AS d 
		ON e.employee_id = d.manager_id
ORDER BY e.employee_id
LIMIT 5;

#-- 2.	Towns Adresses
SELECT 
    t.town_id, t.name AS town_name, a.address_text
FROM
    towns AS t
        INNER JOIN
    addresses AS a 
		ON t.town_id = a.town_id
WHERE t.name IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY town_id, address_id;

#-- 3.	Employees Without Managers
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    department_id, 
    salary
FROM
    employees
WHERE
    manager_id IS NULL;

#-- 4.	Higher Salary
SELECT 
    COUNT(employee_id) AS 'count'
FROM
    employees e
WHERE
    e.salary > (SELECT AVG(salary)
				FROM employees);