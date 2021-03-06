CREATE DATABASE FSD;
USE FSD;

CREATE TABLE countries (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(45) NOT NULL
);
CREATE TABLE towns (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(45) NOT NULL,
country_id INT NOT NULL,
CONSTRAINT `fk_countrie_id`
FOREIGN KEY (country_id)
REFERENCES countries (id)
);
CREATE TABLE stadiums (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(45) NOT NULL,
capacity INT NOT NULL,
town_id INT NOT NULL,
CONSTRAINT `fk_town_id`
FOREIGN KEY (town_id)
REFERENCES towns (id)
);
CREATE TABLE teams (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(45) NOT NULL,
established DATE NOT NULL,
fan_base BIGINT(20) NOT NULL DEFAULT 0,
stadium_id INT NOT NULL,
CONSTRAINT `fk_stadium_id`
FOREIGN KEY (stadium_id)
REFERENCES stadiums (id)
);
CREATE TABLE coaches (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
coach_level INT NOT NULL DEFAULT 0
);
CREATE TABLE skills_data (
id INT PRIMARY KEY AUTO_INCREMENT, 
dribbling  INT DEFAULT 0,
pace  INT DEFAULT 0,
passing INT DEFAULT 0,
shooting INT DEFAULT 0,
speed  INT DEFAULT 0,
strength  INT DEFAULT 0
);
CREATE TABLE players (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
first_name VARCHAR(10) NOT NULL,
last_name VARCHAR(20) NOT NULL,
age INT NOT NULL DEFAULT 0,
position CHAR(1) NOT NULL,
salary DECIMAL(10,2) NOT NULL DEFAULT 0,
hire_date DATETIME, 
skills_data_id INT NOT NULL,
team_id INT,
CONSTRAINT `fk_skills_data_id`
FOREIGN KEY (skills_data_id)
REFERENCES skills_data (id),
CONSTRAINT `fk_team_id`
FOREIGN KEY (team_id)
REFERENCES teams (id)
);
CREATE TABLE players_coaches (
player_id INT,
coach_id INT,
CONSTRAINT `pk_players_coaches`
PRIMARY KEY (player_id, coach_id),
CONSTRAINT `fk_player_id`
FOREIGN KEY (player_id)
REFERENCES players (id),
CONSTRAINT `fk_coach_id`
FOREIGN KEY (coach_id)
REFERENCES coaches (id)
);

INSERT INTO coaches (first_name, last_name, salary, coach_level) 
SELECT first_name, last_name, salary*2, CHAR_LENGTH(first_name) 
FROM players 
WHERE age >= 45; 

UPDATE coaches 
SET coach_level = coach_level + 1
WHERE first_name LIKE 'A%'
AND (SELECT COUNT(*) FROM players_coaches WHERE coach_id = id) > 0;

DELETE FROM players WHERE age >= 45; 

SELECT first_name, age, salary FROM players
ORDER BY salary DESC; 

SELECT p.id, CONCAT(first_name, ' ', last_name) AS full_name, age, position, hire_date FROM players AS p
JOIN skills_data AS s ON p.skills_data_id = s.id
WHERE age < 23 AND position LIKE 'A' AND hire_date IS NULL AND strength > 50
ORDER BY salary, age;

SELECT `name` AS team_name, established, fan_base, 
(SELECT COUNT(*) FROM players WHERE team_id = t.id) AS players_count 
FROM teams AS t
ORDER BY players_count DESC, fan_base DESC;

SELECT MAX(sd.speed) AS max_speed, t.`name` AS town_name FROM towns AS t
LEFT JOIN stadiums AS s ON t.id = s.town_id
LEFT JOIN teams AS tm ON s.id = tm.stadium_id
LEFT JOIN players AS p ON tm.id = p.team_id
LEFT JOIN skills_data AS sd ON p.skills_data_id = sd.id
WHERE tm.`name` <> 'Devify'
GROUP BY t.`name`
ORDER BY max_speed DESC, town_name;

SELECT c.`name`, (SELECT COUNT(*) FROM players AS p
JOIN teams AS tm ON tm.id = p.team_id
JOIN stadiums AS s ON s.id = tm.stadium_id
JOIN towns AS t ON t.id = s.town_id
WHERE c.id = t.country_id) AS total_count_of_players,
(SELECT SUM(p.salary) FROM players AS p
JOIN teams AS tm ON tm.id = p.team_id
JOIN stadiums AS s ON s.id = tm.stadium_id
JOIN towns AS t ON t.id = s.town_id
WHERE c.id = t.country_id) AS total_sum_of_salaries
FROM countries AS c
ORDER BY total_count_of_players DESC, c.`name`;

DELIMITER $$$
CREATE FUNCTION udf_stadium_players_count (stadium_name VARCHAR(30))
RETURNS INT
DETERMINISTIC 
BEGIN 
RETURN (SELECT COUNT(*) FROM players AS p 
JOIN teams AS tm ON tm.id = p.team_id
JOIN stadiums AS s ON s.id = tm.stadium_id
WHERE s.`name` LIKE stadium_name);
END
$$$
DELIMITER ;

DELIMITER $$$
CREATE PROCEDURE udp_find_playmaker (min_dribble_points INT, team_name  VARCHAR(45))
BEGIN 
SELECT CONCAT(first_name, ' ', last_name) AS full_name, age, salary, dribbling, speed, tm.`name` AS team_name FROM players AS p 
JOIN teams AS tm ON tm.id = p.team_id
JOIN skills_data AS sd ON p.skills_data_id = sd.id
WHERE tm.`name` LIKE team_name AND dribbling > min_dribble_points AND speed > (SELECT AVG(speed) FROM skills_data)
ORDER BY speed DESC
LIMIT 1;
END
$$$
DELIMITER ;

SELECT CONCAT(first_name, ' ', last_name) AS full_name, age, salary, dribbling, speed, tm.`name` AS team_name FROM players AS p 
JOIN teams AS tm ON tm.id = p.team_id
JOIN skills_data AS sd ON p.skills_data_id = sd.id
WHERE tm.`name` LIKE 'Skyble' AND dribbling > 20 AND speed > (SELECT AVG(speed) FROM skills_data)
ORDER BY speed DESC
LIMIT 1;

CALL udp_find_playmaker (25, 'Ntags');