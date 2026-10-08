-- Avance 2: corregir la coherencia de los datos en el staging PostgreSQL.
-- La migracion se hizo con la version del poblar anterior a la correccion.
-- Ejecutar sobre la base central PostgreSQL, despues de 09_checks_postgresql.sql.

BEGIN;

SET LOCAL search_path TO aa_mantenimiento, public;

-- 1. la discrepancia es del mismo avion que se inspecciono
UPDATE discrepancia_tecnica d
SET matricula_aeronave = i.matricula_aeronave
FROM inspeccion i
WHERE d.id_inspeccion = i.id_inspeccion
  AND d.matricula_aeronave <> i.matricula_aeronave;

-- 2. la orden es del mismo avion que su discrepancia
UPDATE orden_trabajo o
SET matricula_aeronave = d.matricula_aeronave
FROM discrepancia_tecnica d
WHERE o.id_discrepancia = d.id_discrepancia
  AND o.matricula_aeronave <> d.matricula_aeronave;

-- 3. el resultado de la inspeccion coincide con sus discrepancias
UPDATE inspeccion i
SET resultado = 'CON_DISCREPANCIA'
WHERE i.resultado = 'APROBADO'
  AND EXISTS (SELECT 1 FROM discrepancia_tecnica d WHERE d.id_inspeccion = i.id_inspeccion);

UPDATE inspeccion i
SET resultado = 'APROBADO'
WHERE i.resultado IN ('CON_DISCREPANCIA', 'RECHAZADO')
  AND NOT EXISTS (SELECT 1 FROM discrepancia_tecnica d WHERE d.id_inspeccion = i.id_inspeccion);

-- 4. estado de la discrepancia segun sus ordenes
UPDATE discrepancia_tecnica d
SET estado = CASE
    WHEN o.abiertas = 0 THEN 'RESUELTA'
    WHEN d.estado = 'RESUELTA' THEN 'EN_REVISION'
    WHEN d.estado = 'ABIERTA' AND o.cerradas > 0 THEN 'EN_REVISION'
    ELSE d.estado END
FROM (SELECT id_discrepancia,
             COUNT(*) FILTER (WHERE estado <> 'CERRADA') AS abiertas,
             COUNT(*) FILTER (WHERE estado = 'CERRADA') AS cerradas
      FROM orden_trabajo GROUP BY id_discrepancia) o
WHERE o.id_discrepancia = d.id_discrepancia;

UPDATE discrepancia_tecnica d
SET estado = 'ABIERTA'
WHERE d.estado = 'RESUELTA'
  AND NOT EXISTS (SELECT 1 FROM orden_trabajo o WHERE o.id_discrepancia = d.id_discrepancia);

-- 5. componentes descartados con ordenes activas
UPDATE componente c
SET estado = 'EN_REPARACION'
WHERE c.estado = 'DESCARTADO'
  AND EXISTS (SELECT 1 FROM orden_trabajo o WHERE o.id_componente = c.id_componente AND o.estado <> 'CERRADA');

-- 6. sin fechas de cierre en el futuro
UPDATE orden_trabajo
SET fecha_cierre = GREATEST(fecha_apertura, DATE '2026-09-29')
WHERE fecha_cierre > DATE '2026-09-29';

-- 7. codigo de orden con el anio real de apertura
UPDATE orden_trabajo
SET codigo_orden = 'OT' || to_char(fecha_apertura, 'YY') || substr(codigo_orden, 5);

-- 8. un avion no puede tener dos inspecciones a la misma hora
UPDATE inspeccion i
SET fecha_inspeccion = i.fecha_inspeccion - INTERVAL '1 hour'
FROM (SELECT MAX(id_inspeccion) AS id FROM inspeccion
      GROUP BY matricula_aeronave, fecha_inspeccion HAVING COUNT(*) > 1) x
WHERE i.id_inspeccion = x.id;

COMMIT;
