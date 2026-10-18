BEGIN;
SET search_path TO aa_mantenimiento, public;

-- 1. Agregar la columna a la tabla orden_trabajo
ALTER TABLE orden_trabajo 
ADD COLUMN IF NOT EXISTS id_aeropuerto INT;

-- 2. Agregar a otras tablas operacionales si les faltara
ALTER TABLE componente 
ADD COLUMN IF NOT EXISTS id_aeropuerto INT;

ALTER TABLE orden_repuesto 
ADD COLUMN IF NOT EXISTS id_aeropuerto INT;

COMMIT;


BEGIN;
SET search_path TO aa_mantenimiento, public;

-- A. Heredar id_aeropuerto desde la discrepancia -> inspección de origen
UPDATE orden_trabajo ot
SET id_aeropuerto = i.id_aeropuerto
FROM discrepancia_tecnica dt
JOIN inspeccion i ON dt.id_inspeccion = i.id_inspeccion
WHERE ot.id_discrepancia = dt.id_discrepancia
  AND ot.id_aeropuerto IS NULL;

UPDATE orden_trabajo
SET id_aeropuerto = (SELECT id_aeropuerto FROM aeropuerto ORDER BY id_aeropuerto LIMIT 1)
WHERE id_aeropuerto IS NULL;
COMMIT;


BEGIN;
UPDATE orden_repuesto ord_rep
SET id_aeropuerto = ot.id_aeropuerto
FROM orden_trabajo ot
WHERE ord_rep.id_orden = ot.id_orden;

UPDATE componente c
SET id_aeropuerto = subquery.id_aeropuerto
FROM (
    SELECT DISTINCT ON (id_componente) id_componente, id_aeropuerto
    FROM orden_trabajo
    WHERE id_componente IS NOT NULL AND id_aeropuerto IS NOT NULL
    ORDER BY id_componente, fecha_apertura DESC
) subquery
WHERE c.id_componente = subquery.id_componente;
COMMIT;

BEGIN;
ALTER TABLE discrepancia_tecnica ADD COLUMN IF NOT EXISTS id_aeropuerto INT;
UPDATE discrepancia_tecnica dt
SET id_aeropuerto = i.id_aeropuerto
FROM inspeccion i
WHERE dt.id_inspeccion = i.id_inspeccion
  AND dt.id_aeropuerto IS NULL;
UPDATE discrepancia_tecnica
SET id_aeropuerto = (SELECT id_aeropuerto FROM aeropuerto ORDER BY id_aeropuerto LIMIT 1)
WHERE id_aeropuerto IS NULL;
COMMIT;

BEGIN;
ALTER TABLE inventario_repuesto ADD COLUMN IF NOT EXISTS id_aeropuerto INT;
UPDATE inventario_repuesto
SET id_aeropuerto = ((id_repuesto % (SELECT COUNT(*) FROM aeropuerto)) + 1)
WHERE id_aeropuerto IS NULL;
COMMIT;

Begin;
ALTER TABLE aa_mantenimiento.discrepancia_tecnica 
    ALTER COLUMN id_aeropuerto TYPE BIGINT;

ALTER TABLE aa_mantenimiento.orden_trabajo 
    ALTER COLUMN id_aeropuerto TYPE BIGINT;

ALTER TABLE aa_mantenimiento.inventario_repuesto 
    ALTER COLUMN id_aeropuerto TYPE BIGINT;

ALTER TABLE aa_mantenimiento.componente 
    ALTER COLUMN id_aeropuerto TYPE BIGINT;

ALTER TABLE aa_mantenimiento.orden_repuesto 
    ALTER COLUMN id_aeropuerto TYPE BIGINT;
commit;

-- CHEQUEO DE INTEGRIDAD. Hay datos inconsistentes que necesitan ser reemplazados
SET search_path TO aa_mantenimiento, public;

DELETE FROM aa_mantenimiento.orden_repuesto o
WHERE NOT EXISTS (
    SELECT 1 
    FROM aa_mantenimiento.inventario_repuesto i
    WHERE i.id_repuesto = o.id_repuesto 
      AND i.id_aeropuerto = o.id_aeropuerto
);

WITH ordenes_generadas AS (
    SELECT 
        id_orden,
        id_aeropuerto
    FROM aa_mantenimiento.orden_trabajo
),
repuestos_candidatos AS (
    SELECT 
        og.id_orden,
        ir.id_repuesto,
        og.id_aeropuerto,
        ROW_NUMBER() OVER (PARTITION BY og.id_orden ORDER BY random()) AS rn,
        floor(random() * 4 + 1)::int AS limite_repuestos
    FROM ordenes_generadas og
    JOIN aa_mantenimiento.inventario_repuesto ir 
      ON ir.id_aeropuerto = og.id_aeropuerto
)
INSERT INTO aa_mantenimiento.orden_repuesto (id_orden, id_repuesto, cantidad_utilizada, id_aeropuerto)
SELECT 
    rc.id_orden,
    rc.id_repuesto,
    floor(random() * 10 + 1)::int AS cantidad_utilizada,
    rc.id_aeropuerto
FROM repuestos_candidatos rc
WHERE rc.rn <= rc.limite_repuestos
ON CONFLICT (id_orden, id_repuesto, id_aeropuerto) DO NOTHING;
INSERT INTO aa_mantenimiento.orden_repuesto (id_orden, id_repuesto, cantidad_utilizada, id_aeropuerto)
SELECT 
    rc.id_orden,
    rc.id_repuesto,
    floor(random() * 10 + 1)::int AS cantidad_utilizada,
    rc.id_aeropuerto
FROM repuestos_candidatos rc
WHERE rc.rn <= rc.limite_repuestos
ON CONFLICT (id_orden, id_repuesto, id_aeropuerto) DO NOTHING;