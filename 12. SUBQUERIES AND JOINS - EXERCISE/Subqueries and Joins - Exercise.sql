USE soft_uni;

#-- 1.	Employee Address
SELECT 
    e.employee_id, e.job_title, e.address_id, a.address_text
FROM
    employees AS e
INNER JOIN
    addresses AS a
ON 
	e.address_id = a.address_id
ORDER BY e.address_id
LIMIT 5;

#-- 2.	Addresses with Towns
SELECT 
    e.first_name, e.last_name, t.name AS 'town', a.address_text
FROM
    employees AS e
INNER JOIN
    addresses AS a
ON 
	e.address_id = a.address_id
INNER JOIN
	towns AS t
ON 
	a.town_id = t.town_id
ORDER BY first_name, last_name
LIMIT 5;

#-- 3.	Sales Employee
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.name AS 'department_name'
FROM
    employees AS e
        JOIN
    departments AS d 
		ON e.department_id = d.department_id
WHERE
    d.name LIKE ('Sales')
ORDER BY e.employee_id DESC;

#-- 4.	Employee Departments











