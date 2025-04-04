# DCL DATA CONTROL LANGUAGE
# ---------------------------------
# ---------------------------------
# ---------------------------------

CREATE USER 'new_user'@'localhost' IDENTIFIED BY 'password';

SELECT User, Host
FROM mysql.user;

GRANT SELECT, INSERT, UPDATE ON simply_cars.* TO 'new_user'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'new_user'@'localhost';

REVOKE INSERT ON simply_cars.* FROM 'new_user'@'localhost';

FLUSH PRIVILEGES;

DROP USER 'new_user'@'localhost';


# SQL Constraints
# ---------------------------------
# ---------------------------------
# ---------------------------------

ALTER TABLE simply_cars.cars
    MODIFY COLUMN vin VARCHAR(255) NOT NULL;

ALTER TABLE simply_cars.cars
    ADD CONSTRAINT unique_vin UNIQUE (vin);

ALTER TABLE simply_cars.cars
    ADD PRIMARY KEY (id);

ALTER TABLE simply_cars.models
    ADD CONSTRAINT fk_make FOREIGN KEY (make_id) REFERENCES simply_cars.makes(id);

ALTER TABLE simply_cars.cars
    ADD CONSTRAINT check_year CHECK (year >= 1886 AND year <= 2025);

ALTER TABLE simply_cars.cars
    MODIFY COLUMN price VARCHAR(255) DEFAULT '0';

CREATE INDEX idx_model_id ON simply_cars.cars (model_id);


ALTER TABLE simply_cars.makes
    ADD CONSTRAINT unique_make_name UNIQUE (name);

ALTER TABLE simply_cars.cars
    ADD CONSTRAINT check_price CHECK (price >= 0);

# Strings
# ---------------------------------
# ---------------------------------
# ---------------------------------


SELECT vin, LENGTH(vin) AS vin_length
FROM simply_cars.cars
WHERE LENGTH(vin) > 11;

SELECT CONCAT(mk.name, ' ', md.name, ' (', c.year, ')') AS car_description,
       c.vin
FROM simply_cars.cars c
         JOIN simply_cars.models md ON c.model_id = md.id
         JOIN simply_cars.makes mk ON md.make_id = mk.id;

SELECT vin, SUBSTRING(vin, 1, 3) AS wmi
FROM simply_cars.cars
WHERE vin IS NOT NULL;

SELECT UPPER(mk.name) AS make_upper,
       LOWER(md.name) AS model_lower,
       c.vin
FROM simply_cars.cars c
         JOIN simply_cars.models md ON c.model_id = md.id
         JOIN simply_cars.makes mk ON md.make_id = mk.id;

SELECT price               AS original_price,
       TRIM(price)         AS trimmed_price,
       LENGTH(price)       AS original_length,
       LENGTH(TRIM(price)) AS trimmed_length
FROM simply_cars.cars;



# JSON
# ---------------------------------
# ---------------------------------
# ---------------------------------

SELECT JSON_LENGTH('{
  "price": "50000",
  "year": 2020
}') AS json_length;

SELECT vin, JSON_SEARCH(JSON_OBJECT('vin', vin, 'model_id', model_id), 'one', '2T1BU4EE9AC123456') AS search_result
FROM simply_cars.cars;

SELECT JSON_EXTRACT(JSON_OBJECT('vin', vin, 'model_id', model_id), '$.vin') AS vin
FROM simply_cars.cars;

# Aggregations
# ---------------------------------
# ---------------------------------
# ---------------------------------
SELECT COUNT(*)
FROM cars;
SELECT SUM(price)
FROM cars;
SELECT AVG(price)
FROM cars;
SELECT MAX(price)
FROM cars;
SELECT MIN(price)
FROM cars;

# Grouping
# ---------------------------------
# ---------------------------------
# ---------------------------------
SELECT m.name AS make_name, c.year, COUNT(c.id) AS car_count
FROM simply_cars.makes m
         JOIN simply_cars.models md ON md.make_id = m.id
         JOIN simply_cars.cars c ON c.model_id = md.id
GROUP BY m.name, c.year;

SELECT md.name AS model_name, COUNT(c.id) AS car_count
FROM simply_cars.models md
         LEFT JOIN simply_cars.cars c ON c.model_id = md.id
GROUP BY md.name
HAVING COUNT(c.id) >= 2;

SELECT models.name, GROUP_CONCAT(cars.vin) AS vin_list
FROM models
         LEFT JOIN cars ON cars.model_id = models.id
where vin is not null
GROUP BY models.name;

# Subqueries
# ---------------------------------
# ---------------------------------
# ---------------------------------
# Single-Row Subquery

SELECT vin, price
FROM simply_cars.cars
WHERE price = (SELECT MAX(price) FROM simply_cars.cars);

# Multiple-Row Subquery

SELECT vin, price
FROM cars
WHERE model_id IN (SELECT id
                   FROM models
                   WHERE make_id = (SELECT id FROM makes WHERE name = 'Toyota'));

# Multiple-Column Subquery

SELECT vin, year, price
FROM simply_cars.cars
WHERE (year, price) IN (SELECT year, price FROM simply_cars.cars WHERE vin = 'ABC123');

# Correlated Subquery

SELECT vin, price
FROM simply_cars.cars c
WHERE price > (SELECT AVG(price) FROM simply_cars.cars WHERE model_id = c.model_id);

# Scalar Subquery
SELECT vin, (SELECT MAX(price) FROM simply_cars.cars) AS max_price
FROM simply_cars.cars;

# EXISTS Subquery
SELECT name
FROM simply_cars.makes mk
WHERE EXISTS (SELECT 1
              FROM simply_cars.models md
                       JOIN simply_cars.cars c ON c.model_id = md.id
              WHERE md.make_id = mk.id
                AND c.price > 50000);

