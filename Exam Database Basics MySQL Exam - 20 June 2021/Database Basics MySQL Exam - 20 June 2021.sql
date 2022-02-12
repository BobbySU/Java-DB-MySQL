CREATE DATABASE stc;
DROP DATABASE stc;
USE stc;

CREATE TABLE addresses (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(100) NOT NULL
);

CREATE TABLE categories (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
`name` VARCHAR(10) NOT NULL
);

CREATE TABLE clients (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
full_name VARCHAR(50) NOT NULL,
phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE drivers (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
age INT NOT NULL,
rating FLOAT DEFAULT 5.5
);

CREATE TABLE cars (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
make VARCHAR(20) NOT NULL,
model VARCHAR(20),
`year` INT NOT NULL DEFAULT 0,
mileage INT DEFAULT 0,
`condition` CHAR(1) NOT NULL,
category_id INT NOT NULL,
CONSTRAINT `fk_category_id`
FOREIGN KEY (category_id)
REFERENCES categories (id)
);

CREATE TABLE cars_drivers (
car_id INT NOT NULL, 
driver_id INT NOT NULL,
CONSTRAINT `pk_cars_drivers`
PRIMARY KEY (car_id, driver_id), 
CONSTRAINT `fk_car_id`
FOREIGN KEY (car_id)
REFERENCES cars (id),
CONSTRAINT `fk_driver_id`
FOREIGN KEY (driver_id)
REFERENCES drivers (id)
);

CREATE TABLE courses (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
from_address_id INT NOT NULL, 
`start` DATETIME NOT NULL,
car_id INT NOT NULL,
client_id INT NOT NULL,
bill DECIMAL(10,2) DEFAULT 10,
CONSTRAINT `fk_from_address_id`
FOREIGN KEY (from_address_id)
REFERENCES addresses (id),
CONSTRAINT `fk_car1_id`
FOREIGN KEY (car_id)
REFERENCES cars (id),
CONSTRAINT `fk_client_id`
FOREIGN KEY (client_id)
REFERENCES clients (id)
);

INSERT INTO clients (full_name, phone_number) 
SELECT CONCAT(first_name, ' ', last_name), CONCAT('(088) 9999', d.id*2) 
FROM drivers AS d
WHERE d.id BETWEEN 10 AND 20; 

UPDATE cars 
SET `condition` = 'C'
WHERE ((mileage >= 800000 OR mileage IS NULL) AND year <= 2010) 
AND make <> 'Mercedes-Benz';

DELETE FROM clients
WHERE id NOT IN (SELECT client_id FROM courses) 
AND CHAR_LENGTH(full_name) > 3; 

SELECT make, model, `condition` FROM cars
ORDER BY id;

SELECT d.first_name, d.last_name, c.make, c.model, c.mileage FROM drivers AS d
JOIN cars_drivers AS cd ON d.id = cd.driver_id
JOIN cars AS c ON c.id = cd.car_id
WHERE  c.mileage IS NOT NULL
ORDER BY c.mileage DESC, d.first_name;

SELECT c.id AS car_id, c.make, c.mileage, COUNT(co.car_id) AS count_of_courses, ROUND(AVG(bill),2) AS avg_bill FROM cars AS c
LEFT JOIN courses AS co ON c.id = co.car_id
GROUP BY c.id
HAVING count_of_courses != 2
ORDER BY count_of_courses DESC, c.id;

SELECT full_name, COUNT(co.car_id) AS count_of_cars, SUM(bill) AS total_sum FROM clients AS cl
JOIN courses AS co ON cl.id = co.client_id
WHERE full_name LIKE '_a%' 
GROUP BY cl.id
HAVING count_of_cars > 1 
ORDER BY full_name;

SELECT a.`name`, 
CASE 
WHEN HOUR(`start`) BETWEEN 6 AND 20 THEN 'Day'
WHEN HOUR(`start`) >= 21 OR HOUR(`start`) <= 5 THEN 'Night'
END 
AS day_time, co.bill, cl.full_name, c.make, c.model, ca.`name` AS category_name 
FROM courses AS co
JOIN addresses AS a ON a.id = co.from_address_id
JOIN clients AS cl ON cl.id = co.client_id
JOIN cars AS c ON c.id = co.car_id
JOIN categories AS ca ON ca.id = c.category_id
ORDER BY co.id;

DELIMITER $$$
CREATE FUNCTION udf_courses_by_client (phone_num VARCHAR (20))
RETURNS INT
DETERMINISTIC 
BEGIN 
RETURN (SELECT COUNT(*) FROM courses AS c 
JOIN clients AS cl ON cl.id = c.client_id
WHERE cl.phone_number LIKE phone_num);
END
$$$
DELIMITER ;

SELECT COUNT(*) FROM courses AS c 
JOIN clients AS cl ON cl.id = c.client_id
WHERE cl.phone_number LIKE '(803) 6386812'

DELIMITER $$$
CREATE PROCEDURE udp_courses_by_address (address_name  VARCHAR(100))
BEGIN 
SELECT a.`name`, cl.full_name AS full_names, 
CASE 
WHEN bill <= 20 THEN 'Low'
WHEN bill <= 30 THEN 'Medium'
ELSE 'High'
END 
AS level_of_bill, c.make, c.`condition`, ca.`name` AS cat_name FROM courses AS co
JOIN addresses AS a ON a.id = co.from_address_id
JOIN clients AS cl ON cl.id = co.client_id
JOIN cars AS c ON c.id = co.car_id
JOIN categories AS ca ON c.category_id = ca.id
WHERE a.`name` LIKE address_name
ORDER BY c.make, full_names;
END
$$$
DELIMITER ;

SELECT a.`name`, cl.full_name AS full_names, 
CASE 
WHEN bill <= 20 THEN 'Low'
WHEN bill <= 30 THEN 'Medium'
ELSE 'High'
END 
AS level_of_bill, c.make, c.`condition`, ca.`name` AS cat_name FROM courses AS co
JOIN addresses AS a ON a.id = co.from_address_id
JOIN clients AS cl ON cl.id = co.client_id
JOIN cars AS c ON c.id = co.car_id
JOIN categories AS ca ON c.category_id = ca.id
WHERE a.`name` LIKE '700 Monterey Avenue'
ORDER BY c.make, full_names;







