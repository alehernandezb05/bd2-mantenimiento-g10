-- Pregunta 3.2 comparación con y sin índices

EXPLAIN ANALYZE SELECT * FROM orden_trabajo IGNORE INDEX (idx_orden_estado_prioridad)
WHERE estado = 'PENDIENTE_REPUESTO' AND prioridad = 'A';
EXPLAIN ANALYZE SELECT * FROM orden_trabajo
WHERE estado = 'PENDIENTE_REPUESTO' AND prioridad = 'A';

EXPLAIN ANALYZE SELECT codigo_orden, fecha_apertura, estado FROM orden_trabajo IGNORE INDEX (idx_orden_fecha_apertura)
WHERE fecha_apertura BETWEEN '2026-09-01' AND '2026-09-15';
EXPLAIN ANALYZE SELECT codigo_orden, fecha_apertura, estado FROM orden_trabajo
WHERE fecha_apertura BETWEEN '2026-09-01' AND '2026-09-15';

EXPLAIN ANALYZE SELECT * FROM inspeccion IGNORE INDEX (idx_inspeccion_matricula_fecha)
WHERE matricula_aeronave = 'N597AA' ORDER BY fecha_inspeccion DESC;
EXPLAIN ANALYZE SELECT * FROM inspeccion
WHERE matricula_aeronave = 'N597AA' ORDER BY fecha_inspeccion DESC;

EXPLAIN ANALYZE SELECT * FROM discrepancia_tecnica IGNORE INDEX (idx_discrepancia_estado_severidad)
WHERE estado = 'ABIERTA' AND severidad = '1';
EXPLAIN ANALYZE SELECT * FROM discrepancia_tecnica
WHERE estado = 'ABIERTA' AND severidad = '1';

EXPLAIN ANALYZE SELECT * FROM inventario_repuesto
WHERE descripcion LIKE '%sensor%';
EXPLAIN ANALYZE SELECT * FROM inventario_repuesto
WHERE MATCH(descripcion) AGAINST('sensor');

EXPLAIN ANALYZE SELECT * FROM componente
WHERE nombre_componente LIKE '%turbina%';
EXPLAIN ANALYZE SELECT * FROM componente
WHERE MATCH(nombre_componente) AGAINST('turbina');