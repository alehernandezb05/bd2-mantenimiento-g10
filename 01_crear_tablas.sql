CREATE DATABASE IF NOT EXISTS aa_mantenimiento;
USE aa_mantenimiento;

CREATE TABLE IF NOT EXISTS region (
    id_region      TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nombre_region  VARCHAR(10) NOT NULL UNIQUE,
    CONSTRAINT ck_region_nombre
        CHECK (nombre_region IN ('ESTE', 'CENTRAL', 'OESTE'))
);

CREATE TABLE IF NOT EXISTS aeropuerto (
    id_aeropuerto  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo_iata    CHAR(3) NOT NULL UNIQUE,
    id_region      TINYINT UNSIGNED NOT NULL,
    CONSTRAINT fk_aeropuerto_region
        FOREIGN KEY (id_region) REFERENCES region (id_region)
);

CREATE TABLE IF NOT EXISTS hub (
    id_hub         INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_aeropuerto  INT UNSIGNED NOT NULL UNIQUE,
    CONSTRAINT fk_hub_aeropuerto
        FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto (id_aeropuerto)
);