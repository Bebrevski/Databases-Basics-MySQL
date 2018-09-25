USE `soft_uni`;

SELECT * FROM `towns`;
SELECT * FROM `departments`;
SELECT * FROM `employees`;


-- 19. Basic Select All Fields and Order Them
-- Modify queries from previous problem by sorting:
-- towns - alphabetically by name
-- departments - alphabetically by name
-- employees - descending by salary

SELECT * FROM `towns` ORDER BY `name`;
SELECT * FROM `departments` ORDER BY `name`;
SELECT * FROM `employees` ORDER BY `salary` DESC;