--Script de transacción exitosa
BEGIN;

-- Asumimos que el repuesto con id=1 existe en el aeropuerto 1
UPDATE aa_mantenimiento.inventario_repuesto 
SET cantidad_disponible = cantidad_disponible - 1
WHERE id_repuesto = 1 AND id_aeropuerto = 1;

-- Asumimos que el aeropuerto 38 (que cayó en el worker 2) recibe el repuesto
UPDATE aa_mantenimiento.inventario_repuesto 
SET cantidad_disponible = cantidad_disponible + 1
WHERE id_repuesto = 1 AND id_aeropuerto = 38;

Commit;

SELECT * FROM pg_dist_transaction;

-- Script de transacción fallida

BEGIN;

UPDATE aa_mantenimiento.inventario_repuesto 
SET cantidad_disponible = cantidad_disponible - 1000
WHERE id_repuesto = 42 AND id_aeropuerto = 1;

UPDATE aa_mantenimiento.inventario_repuesto 
SET cantidad_disponible = cantidad_disponible + 1000
WHERE id_repuesto = 14 AND id_aeropuerto = 15;

COMMIT;