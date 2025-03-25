SHOW DATABASES;
CREATE DATABASE IF NOT EXISTS webapp;
USE webapp;
SHOW TABLES;
CREATE TABLE IF NOT EXISTS dataset (
    id int,
    data1 varchar(50),
    data2 varchar(50),
    hostname varchar(50),
    ip varchar(50)
);
SHOW TABLES;
DESC TABLE dataset;