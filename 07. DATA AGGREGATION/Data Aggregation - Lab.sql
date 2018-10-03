USE `restaurant`;

#-- 1.	 Departments Info
SELECT 
    `department_id`, COUNT(`id`)
FROM
    `employees`
GROUP BY `department_id`
ORDER BY `department_id`, COUNT(`id`);

#-- 2.	Average Salary
SELECT 
    `department_id`, ROUND(AVG(`salary`), 2)
FROM
    `employees`
GROUP BY `department_id`
ORDER BY `department_id`;

#-- 3.	 Min Salary
SELECT 
    `department_id`, ROUND(MIN(`salary`), 2) AS 'Min Salary'
FROM
    `employees`
WHERE
    `salary` > 800
GROUP BY `department_id`
ORDER BY `department_id`
LIMIT 1;

#-- 4.	 Appetizers Count







