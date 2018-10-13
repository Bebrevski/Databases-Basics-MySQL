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
SELECT 
    e.employee_id,
    e.first_name,
    e.salary,
    d.name AS 'department_name'
FROM
    employees AS e
        JOIN
    departments AS d 
		ON e.department_id = d.department_id
WHERE
    e.salary > 15000
ORDER BY d.department_id DESC
LIMIT 5;

#-- 5.	Employees Without Project
SELECT 
    e.employee_id, e.first_name
FROM
    employees AS e
        LEFT JOIN
    employees_projects AS ep 
		ON ep.employee_id = e.employee_id
WHERE
    ep.employee_id IS NULL
ORDER BY e.employee_id DESC
LIMIT 3;

#-- 6.	Employees Hired After
SELECT 
    e.first_name,
    e.last_name,
    e.hire_date,
    d.name AS 'dept_name'
FROM
    employees AS e
        JOIN
    departments AS d 
		ON e.department_id = d.department_id
WHERE
        DATE(e.hire_date) > '1999-01-01'
        AND d.name IN ('Sales' , 'Finance')
ORDER BY hire_date ASC;

#-- 7.	Employees with Project
SELECT 
    e.employee_id, e.first_name, p.name AS 'project_name'
FROM
    employees AS e
        JOIN
    employees_projects AS ep 
		ON ep.employee_id = e.employee_id
        JOIN
    projects AS p 
		ON ep.project_id = p.project_id
WHERE
    DATE(p.start_date) > '2002-08-13' 
    AND p.end_date IS NULL
ORDER BY e.first_name , p.name
LIMIT 5;

#-- 8.	Employee 24
SELECT 
    e.employee_id,
    e.first_name,
    IF(YEAR(p.start_date) >= '2005',
        NULL,
        p.name) AS 'project_name'
FROM
    employees AS e
        JOIN
    employees_projects AS ep ON e.employee_id = ep.employee_id
        JOIN
    projects AS p ON ep.project_id = p.project_id
WHERE
    e.employee_id = 24
ORDER BY p.name;

#-- 9.	Employee Manager
SELECT 
    e.employee_id,
    e.first_name,
    e.manager_id,
    emp.first_name AS 'manager_name'
FROM
    employees AS e
        JOIN
    employees AS emp 
		ON emp.employee_id = e.manager_id
WHERE
    e.manager_id IN (3 , 7)
ORDER BY e.first_name;

#-- 10.	Employee Summary
SELECT 
    e.employee_id,
    CONCAT_WS(' ', e.first_name, e.last_name) AS employee_name,
    CONCAT_WS(' ', emp.first_name, emp.last_name) AS manager_name,
    d.name AS 'department_name'
FROM
    employees AS e
        JOIN
    employees AS emp 
		ON emp.employee_id = e.manager_id
        JOIN
    departments AS d 
		ON e.department_id = d.department_id
ORDER BY e.employee_id
LIMIT 5;

#-- 11.	Min Average Salary
SELECT 
    AVG(salary) AS min_average_salary
FROM
    employees
GROUP BY department_id
ORDER BY min_average_salary
LIMIT 1;

#-- 12.	Highest Peaks in Bulgaria
USE geography;

SELECT 
    mc.country_code, m.mountain_range, p.peak_name, p.elevation
FROM
    mountains_countries AS mc
        JOIN
    mountains AS m 
		ON mc.mountain_id = m.id
        JOIN
    peaks AS p 
		ON m.id = p.mountain_id
WHERE
    mc.country_code LIKE ('BG')
        AND p.elevation > 2835
ORDER BY p.elevation DESC;

#-- 13.	Count Mountain Ranges
SELECT 
    c.country_code, COUNT(mc.mountain_id) AS mountain_range
FROM
    countries AS c
        JOIN
    mountains_countries AS mc 
		ON c.country_code = mc.country_code
WHERE
    c.country_code IN ('US' , 'RU', 'BG')
GROUP BY c.country_code
ORDER BY mountain_range DESC;

#-- 14.	Countries with Rivers
SELECT 
    c.country_name, r.river_name
FROM
    countries AS c
        LEFT JOIN
    countries_rivers AS cr 
		ON c.country_code = cr.country_code
        LEFT JOIN
    rivers AS r 
		ON r.id = cr.river_id
        JOIN
    continents AS cn 
		ON cn.continent_code = c.continent_code
WHERE
    cn.continent_name = 'Africa'
ORDER BY c.country_name
LIMIT 5;

#-- 16.	Countries without any Mountains
SELECT 
    COUNT(*) AS 'country_count'
FROM
    (SELECT 
        mc.country_code AS 'mc_country_code'
    FROM
        mountains_countries AS mc
    GROUP BY mc.country_code) AS d
        RIGHT JOIN
    countries AS c 
		ON c.country_code = d.mc_country_code
WHERE
    d.mc_country_code IS NULL;
    
#-- 17.	Highest Peak and Longest River by Country
SELECT 
    c.country_name,
    MAX(p.elevation) AS 'highest_peak_elevation',
    MAX(r.length) AS 'longest_river_length'
FROM
    countries AS c
        LEFT JOIN
    mountains_countries AS mc ON c.country_code = mc.country_code
        LEFT JOIN
    peaks AS p ON mc.mountain_id = p.mountain_id
        LEFT JOIN
    countries_rivers AS cr ON c.country_code = cr.country_code
        LEFT JOIN
    rivers AS r ON cr.river_id = r.id
GROUP BY c.country_name
ORDER BY highest_peak_elevation DESC , longest_river_length DESC , c.country_name
LIMIT 5;


