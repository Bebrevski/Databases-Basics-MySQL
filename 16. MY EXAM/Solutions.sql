CREATE DATABASE softunia;
USE softunia;

CREATE TABLE planets(
	id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(30) NOT NULL
);

CREATE TABLE spaceports(
	id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    planet_id INT(11),
    CONSTRAINT fk_spaceports_planets
		FOREIGN KEY spaceports(planet_id)
        REFERENCES planets(id)
);

CREATE TABLE spaceships(
	id INT(11) PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    manufacturer VARCHAR(30) NOT NULL,
    light_speed_rate INT(11) DEFAULT 0
);

CREATE TABLE colonists(
	id INT(11) PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    ucn CHAR(10) NOT NULL UNIQUE,
    birth_date DATE NOT NULL
);

CREATE TABLE journeys(
	id INT(11) PRIMARY KEY AUTO_INCREMENT,
    journey_start DATETIME NOT NULL,
    journey_end DATETIME NOT NULL,
    purpose ENUM('Medical', 'Technical', 'Educational', 'Military'),
    destination_spaceport_id INT(11),
    spaceship_id INT(11),
    CONSTRAINT fk_journeys_spaceports
		FOREIGN KEY journeys(destination_spaceport_id)
        REFERENCES spaceports(id),
	CONSTRAINT fk_journeys_spaceships
		FOREIGN KEY joutneys(spaceship_id)
        REFERENCES spaceships(id)
);

CREATE TABLE travel_cards(
	id INT(11) PRIMARY KEY AUTO_INCREMENT,
    card_number CHAR(10) NOT NULL UNIQUE,
    job_during_journey ENUM('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook'),
    colonist_id INT(11),
    journey_id INT(11),
    CONSTRAINT fk_travel_cards_colonists
		FOREIGN KEY travel_cards(colonist_id)
        REFERENCES colonists(id),
	CONSTRAINT fk_travel_cards_journeys
		FOREIGN KEY travel_cards(journey_id)
        REFERENCES journeys(id)
);

#-- 01.	Data Insertion
INSERT INTO travel_cards(card_number, job_during_journey, colonist_id, journey_id)
SELECT 
	CASE 
		WHEN DATE(c.birth_date) > '1980-01-01'
		THEN CONCAT_WS('',YEAR(c.birth_date), DAY(c.birth_date), SUBSTRING(c.ucn, 1, 4)) 
		ELSE CONCAT_WS('',YEAR(c.birth_date), MONTH(c.birth_date), SUBSTRING(c.ucn, 7))
	END AS card_number,
    CASE 
		WHEN c.id % 2 = 0 THEN 'Pilot' 
		WHEN c.id % 3 = 0 THEN 'Cook'
        ELSE 'Engineer'
	END AS job_during_journey,
    c.id AS colonist_id,
    SUBSTRING(c.ucn, 1, 1) AS journey_id
FROM colonists AS c
WHERE id BETWEEN 96 AND 100;

#-- 02.	Data Update
UPDATE journeys AS j
SET j.purpose = CASE 
					WHEN j.id % 2 = 0 THEN 'Medical'
                    WHEN j.id % 3 = 0 THEN 'Technical'
                    WHEN j.id % 5 = 0 THEN 'Educational'
                    WHEN j.id % 7 = 0 THEN 'Military'
                    ELSE j.purpose
				END
;

#-- 03.	Data Deletion
DELETE c
FROM colonists AS c
LEFT JOIN travel_cards AS tc ON c.id = tc.colonist_id
LEFT JOIN journeys AS j ON tc.journey_id = j.id
WHERE j.id IS NULL;

#-- 04.Extract all travel cards
SELECT card_number, job_during_journey
FROM travel_cards
ORDER BY card_number;

#-- 05. Extract all colonists
SELECT id, CONCAT(first_name, ' ', last_name) AS full_name, ucn
FROM colonists
ORDER BY first_name, last_name, id;

#-- 06.	Extract all military journeys
SELECT
	id,
    journey_start,
    journey_end
FROM journeys
WHERE purpose = 'Military'
ORDER BY journey_start;

#-- 07.	Extract all pilots
SELECT
	c.id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name
FROM colonists AS c
LEFT JOIN travel_cards AS tc ON c.id = tc.colonist_id
WHERE tc.job_during_journey = 'Pilot'
ORDER BY id;

#-- 08.	Count all colonists that are on technical journey
SELECT COUNT(c.id) AS count
FROM colonists AS c
LEFT JOIN travel_cards AS tc ON c.id = tc.colonist_id
LEFT JOIN journeys AS j ON tc.journey_id = j.id
WHERE j.purpose = 'Technical';

#-- 09.Extract the fastest spaceship
SELECT
	ss.name AS spaceship_name,
    sp.name AS spaceport_name
FROM spaceships AS ss
JOIN journeys AS j ON ss.id = j.spaceship_id
JOIN spaceports AS sp ON j.destination_spaceport_id = sp.id
WHERE ss.id = (
			SELECT id
			FROM spaceships 
			ORDER BY light_speed_rate DESC
			LIMIT 1);
          
#-- 10.Extract spaceships with pilots younger than 30 years
SELECT
	DISTINCT(sp.name),
    sp.manufacturer
FROM spaceships AS sp
	JOIN journeys AS j ON sp.id = j.spaceship_id
    JOIN travel_cards AS tc ON tc.journey_id = j.id
    JOIN colonists AS c ON tc.colonist_id = c.id
WHERE DATE_SUB('2019-01-01', INTERVAL 30 YEAR) < c.birth_date
ORDER BY sp.name; 

#-- 11. Extract all educational mission planets and spaceports
SELECT
	p.name AS planet_name,
    sp.name AS spaceport_name
FROM planets AS p
LEFT JOIN spaceports AS sp ON p.id = sp.planet_id
LEFT JOIN journeys AS j ON sp.id = j.destination_spaceport_id
WHERE j.purpose = 'Educational'
ORDER BY spaceport_name DESC;

#-- 12. Extract all planets and their journey count
SELECT
	p.name AS planet_name,
    COUNT(j.id) AS journey_count
FROM planets AS p
 JOIN spaceports AS sp ON p.id = sp.planet_id
 JOIN journeys AS j ON sp.id = j.destination_spaceport_id
GROUP BY p.id
ORDER BY journey_count DESC, planet_name;

#-- 13.Extract the shortest journey
SELECT
	j.id,
    p.name AS planet_name,
    sp.name AS spaceport_name,
    j.purpose AS journey_purpose
FROM journeys AS j
LEFT JOIN spaceports AS sp ON j.destination_spaceport_id = sp.id
LEFT JOIN planets AS p ON sp.planet_id = p.id
ORDER BY DATE(journey_end) - DATE(journey_start)
LIMIT 1; 

#-- 14.Extract the less popular job
SELECT tc.job_during_journey AS job_name
FROM (
		SELECT *
		from travel_cards
		GROUP BY journey_id) AS tc
WHERE tc.journey_id = (
						SELECT id
						FROM journeys
						ORDER BY DATE(journey_end) - DATE(journey_start) DESC
                        LIMIT 1);

#-- 15. Get colonists count
DROP FUNCTION udf_count_colonists_by_destination_planet;

CREATE FUNCTION udf_count_colonists_by_destination_planet (planet_name VARCHAR (30))
RETURNS INT(11)
DETERMINISTIC
RETURN (
	SELECT COUNT(p.id)
    FROM planets AS p
		JOIN spaceports AS sp ON p.id = sp.planet_id
		JOIN journeys AS j ON j.destination_spaceport_id = sp.id
		JOIN travel_cards AS tc ON j.id = tc.journey_id
        JOIN colonists AS c ON tc.colonist_id = c.id
WHERE p.name = planet_name
);

SELECT p.name, udf_count_colonists_by_destination_planet('Otroyphus') AS count
FROM planets AS p
WHERE p.name = 'Otroyphus';

#-- 16. Modify spaceship
#DROP PROCEDURE udp_modify_spaceship_light_speed_rate;

DELIMITER $$

CREATE PROCEDURE udp_modify_spaceship_light_speed_rate
(spaceship_name VARCHAR(50), light_speed_rate_increse INT(11))
BEGIN

	IF 1 <> (SELECT COUNT(*) FROM spaceships AS sp WHERE sp.name = spaceship_name)
    THEN 
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Spaceship you are trying to modify does not exists.';
    END IF;
    
    UPDATE spaceships AS sp
    SET sp.light_speed_rate = sp.light_speed_rate + light_speed_rate_increse
    WHERE sp.name = spaceship_name;

END $$

DELIMITER ;
CALL udp_modify_spaceship_light_speed_rate ('Na Pesho koraba', 1914);

CALL udp_modify_spaceship_light_speed_rate ('USS Templar', 5);
SELECT name, light_speed_rate FROM spaceships WHERE name = 'USS Templar';





