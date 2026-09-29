USE aa_mantenimiento;

-- =========================================================
-- 1. MANEJO DE MEMORIA
-- =========================================================

-- tamano de pagina de innodb
SHOW VARIABLES LIKE 'innodb_page_size';

-- avg_row_length, data_length y cantidad de registros por tabla
SELECT table_name, row_format, table_rows, avg_row_length, data_length, index_length
FROM information_schema.tables
WHERE table_schema = 'aa_mantenimiento'
ORDER BY data_length DESC;

-- tipos de cada columna (para el calculo manual del tamano de registro)
SELECT table_name, column_name, column_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'aa_mantenimiento'
ORDER BY table_name, ordinal_position;

-- tipo de scan sin indices (ALL = full table scan)
EXPLAIN SELECT * FROM orden_trabajo IGNORE INDEX (idx_orden_estado_prioridad)
WHERE estado = 'ABIERTA';

EXPLAIN ANALYZE SELECT * FROM orden_trabajo IGNORE INDEX (idx_orden_estado_prioridad)
WHERE estado = 'ABIERTA';

EXPLAIN ANALYZE SELECT * FROM inspeccion IGNORE INDEX (idx_inspeccion_matricula_fecha)
WHERE matricula_aeronave = 'N597AA';


-- =========================================================
-- 2. MANEJO DE INDICES
-- =========================================================

SHOW INDEX FROM orden_trabajo;
SHOW INDEX FROM inspeccion;
SHOW INDEX FROM discrepancia_tecnica;
SHOW INDEX FROM inventario_repuesto;
SHOW INDEX FROM componente;

-- indice 1: idx_orden_estado_prioridad
EXPLAIN ANALYZE SELECT * FROM orden_trabajo IGNORE INDEX (idx_orden_estado_prioridad)
WHERE estado = 'PENDIENTE_REPUESTO' AND prioridad = 'A';
EXPLAIN ANALYZE SELECT * FROM orden_trabajo
WHERE estado = 'PENDIENTE_REPUESTO' AND prioridad = 'A';

-- indice 2: idx_orden_fecha_apertura
EXPLAIN ANALYZE SELECT codigo_orden, fecha_apertura, estado FROM orden_trabajo IGNORE INDEX (idx_orden_fecha_apertura)
WHERE fecha_apertura BETWEEN '2026-09-01' AND '2026-09-15';
EXPLAIN ANALYZE SELECT codigo_orden, fecha_apertura, estado FROM orden_trabajo
WHERE fecha_apertura BETWEEN '2026-09-01' AND '2026-09-15';

-- indice 3: idx_inspeccion_matricula_fecha
EXPLAIN ANALYZE SELECT * FROM inspeccion IGNORE INDEX (idx_inspeccion_matricula_fecha)
WHERE matricula_aeronave = 'N597AA' ORDER BY fecha_inspeccion DESC;
EXPLAIN ANALYZE SELECT * FROM inspeccion
WHERE matricula_aeronave = 'N597AA' ORDER BY fecha_inspeccion DESC;

-- indice 4: idx_discrepancia_estado_severidad
EXPLAIN ANALYZE SELECT * FROM discrepancia_tecnica IGNORE INDEX (idx_discrepancia_estado_severidad)
WHERE estado = 'ABIERTA' AND severidad = '1';
EXPLAIN ANALYZE SELECT * FROM discrepancia_tecnica
WHERE estado = 'ABIERTA' AND severidad = '1';

-- indice 5: ft_repuesto_descripcion (sin fulltext se busca con LIKE)
EXPLAIN ANALYZE SELECT * FROM inventario_repuesto
WHERE descripcion LIKE '%sensor%';
EXPLAIN ANALYZE SELECT * FROM inventario_repuesto
WHERE MATCH(descripcion) AGAINST('sensor');

-- indice 6: ft_componente_nombre
EXPLAIN ANALYZE SELECT * FROM componente
WHERE nombre_componente LIKE '%turbina%';
EXPLAIN ANALYZE SELECT * FROM componente
WHERE MATCH(nombre_componente) AGAINST('turbina');

-- estadisticas de los b-tree (paginas totales y paginas hoja)
SELECT table_name, index_name, stat_name, stat_value, stat_description
FROM mysql.innodb_index_stats
WHERE database_name = 'aa_mantenimiento'
  AND index_name IN ('idx_orden_estado_prioridad', 'idx_orden_fecha_apertura',
                     'idx_inspeccion_matricula_fecha', 'idx_discrepancia_estado_severidad')
  AND stat_name IN ('size', 'n_leaf_pages')
ORDER BY table_name, index_name, stat_name;


-- =========================================================
-- 3. OPTIMIZACION DE CONSULTAS
-- horas hombre de ordenes de prioridad alta por tipo de inspeccion
-- =========================================================

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

-- plan estimado
EXPLAIN
SELECT i.tipo_inspeccion, d.severidad, COUNT(*) AS total_ordenes, SUM(o.horas_hombre) AS horas_totales
FROM orden_trabajo o
JOIN discrepancia_tecnica d ON o.id_discrepancia = d.id_discrepancia
JOIN inspeccion i ON d.id_inspeccion = i.id_inspeccion
WHERE o.prioridad = 'A' AND o.fecha_apertura >= '2026-07-01'
GROUP BY i.tipo_inspeccion, d.severidad
HAVING COUNT(*) > 10
ORDER BY horas_totales DESC;

-- plan real con indices
EXPLAIN ANALYZE
SELECT i.tipo_inspeccion, d.severidad, COUNT(*) AS total_ordenes, SUM(o.horas_hombre) AS horas_totales
FROM orden_trabajo o
JOIN discrepancia_tecnica d ON o.id_discrepancia = d.id_discrepancia
JOIN inspeccion i ON d.id_inspeccion = i.id_inspeccion
WHERE o.prioridad = 'A' AND o.fecha_apertura >= '2026-07-01'
GROUP BY i.tipo_inspeccion, d.severidad
HAVING COUNT(*) > 10
ORDER BY horas_totales DESC;

-- plan real sin los indices secundarios
EXPLAIN ANALYZE
SELECT i.tipo_inspeccion, d.severidad, COUNT(*) AS total_ordenes, SUM(o.horas_hombre) AS horas_totales
FROM orden_trabajo o IGNORE INDEX (idx_orden_fecha_apertura, idx_orden_estado_prioridad)
JOIN discrepancia_tecnica d IGNORE INDEX (idx_discrepancia_estado_severidad) ON o.id_discrepancia = d.id_discrepancia
JOIN inspeccion i IGNORE INDEX (idx_inspeccion_matricula_fecha) ON d.id_inspeccion = i.id_inspeccion
WHERE o.prioridad = 'A' AND o.fecha_apertura >= '2026-07-01'
GROUP BY i.tipo_inspeccion, d.severidad
HAVING COUNT(*) > 10
ORDER BY horas_totales DESC;
