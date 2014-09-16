CREATE DATABASE `sksdb` CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';

CREATE USER 'sksuser'@'localhost' IDENTIFIED BY 'password';

GRANT USAGE ON * . * TO 'sksuser'@'localhost' IDENTIFIED BY 'password' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;

GRANT ALL PRIVILEGES ON `sksdb` . * TO 'sksuser'@'localhost';
