USE aa_mantenimiento;

SHOW VARIABLES LIKE 'innodb_page_size';

SELECT table_name, row_format, table_rows, avg_row_length, data_length, index_length
FROM information_schema.tables
WHERE table_schema = 'aa_mantenimiento'
ORDER BY data_length DESC;

SELECT table_name, column_name, column_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'aa_mantenimiento'
ORDER BY table_name, ordinal_position;

EXPLAIN SELECT * FROM orden_trabajo IGNORE INDEX (idx_orden_estado_prioridad)
WHERE estado = 'ABIERTA';

EXPLAIN ANALYZE SELECT * FROM orden_trabajo IGNORE INDEX (idx_orden_estado_prioridad)
WHERE estado = 'ABIERTA';

EXPLAIN ANALYZE SELECT * FROM inspeccion IGNORE INDEX (idx_inspeccion_matricula_fecha)
WHERE matricula_aeronave = 'N597AA';

SELECT table_name, index_name, stat_name, stat_value, stat_description
FROM mysql.innodb_index_stats
WHERE database_name = 'aa_mantenimiento'
  AND index_name IN ('idx_orden_estado_prioridad', 'idx_orden_fecha_apertura',
                     'idx_inspeccion_matricula_fecha', 'idx_discrepancia_estado_severidad')
  AND stat_name IN ('size', 'n_leaf_pages')
ORDER BY table_name, index_name, stat_name;

SELECT i.tipo_inspeccion, d.severidad,
       COUNT(*) AS total_ordenes,
       SUM(o.horas_hombre) AS horas_totales
FROM orden_trabajo o
JOIN discrepancia_tecnica d ON o.id_discrepancia = d.id_discrepancia
JOIN inspeccion i ON d.id_inspeccion = i.id_inspeccion
WHERE o.prioridad = 'A' AND o.fecha_apertura >= '2026-07-01'
GROUP BY i.tipo_inspeccion, d.severidad
HAVING COUNT(*) > 10
ORDER BY horas_totales DESC;

EXPLAIN
SELECT i.tipo_inspeccion, d.severidad, COUNT(*) AS total_ordenes, SUM(o.horas_hombre) AS horas_totales
FROM orden_trabajo o
JOIN discrepancia_tecnica d ON o.id_discrepancia = d.id_discrepancia
JOIN inspeccion i ON d.id_inspeccion = i.id_inspeccion
WHERE o.prioridad = 'A' AND o.fecha_apertura >= '2026-07-01'
GROUP BY i.tipo_inspeccion, d.severidad
HAVING COUNT(*) > 10
ORDER BY horas_totales DESC;

EXPLAIN ANALYZE
SELECT i.tipo_inspeccion, d.severidad, COUNT(*) AS total_ordenes, SUM(o.horas_hombre) AS horas_totales
FROM orden_trabajo o
JOIN discrepancia_tecnica d ON o.id_discrepancia = d.id_discrepancia
JOIN inspeccion i ON d.id_inspeccion = i.id_inspeccion
WHERE o.prioridad = 'A' AND o.fecha_apertura >= '2026-07-01'
GROUP BY i.tipo_inspeccion, d.severidad
HAVING COUNT(*) > 10
ORDER BY horas_totales DESC;

EXPLAIN ANALYZE
SELECT i.tipo_inspeccion, d.severidad, COUNT(*) AS total_ordenes, SUM(o.horas_hombre) AS horas_totales
FROM orden_trabajo o IGNORE INDEX (idx_orden_fecha_apertura, idx_orden_estado_prioridad)
JOIN discrepancia_tecnica d IGNORE INDEX (idx_discrepancia_estado_severidad) ON o.id_discrepancia = d.id_discrepancia
JOIN inspeccion i IGNORE INDEX (idx_inspeccion_matricula_fecha) ON d.id_inspeccion = i.id_inspeccion
WHERE o.prioridad = 'A' AND o.fecha_apertura >= '2026-07-01'
GROUP BY i.tipo_inspeccion, d.severidad
HAVING COUNT(*) > 10
ORDER BY horas_totales DESC;
