SET search_path TO aa_mantenimiento, public;
-- Con EXPLAIN
EXPLAIN 
SELECT * 
FROM orden_trabajo 
WHERE estado = 'EN_PROCESO';

-- Con EXPLAIN ANALYZE
EXPLAIN ANALYZE 
SELECT * 
FROM orden_trabajo 
WHERE estado = 'EN_PROCESO';