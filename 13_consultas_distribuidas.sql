-- Consultas distribuidas

-- Consultas inter-nodo

--Consulta 1
-- Ejemplo 1 Co-located Join
EXPLAIN ANALYZE
SELECT a.codigo_iata, ot.prioridad, COUNT(ot.id_orden) AS total_ordenes
FROM aa_mantenimiento.orden_trabajo ot
JOIN aa_mantenimiento.aeropuerto a
ON ot.id_aeropuerto = a.id_aeropuerto
WHERE ot.estado = 'ABIERTA'
GROUP BY a.codigo_iata, ot.prioridad
ORDER BY total_ordenes DESC;

-- Ejemplo 2 Reference Table
EXPLAIN ANALYZE
SELECT a.codigo_iata, ot.prioridad, COUNT(ot.id_orden) AS total_ordenes
FROM aa_mantenimiento.orden_trabajo ot
JOIN aa_mantenimiento.aeropuerto a
ON ot.id_aeropuerto = a.id_aeropuerto
JOIN aa_mantenimiento.region r
ON a.id_region = r.id_region -- join con la tabla de referencia
WHERE ot.estado = 'ABIERTA'
GROUP BY a.codigo_iata, ot.prioridad
ORDER BY total_ordenes DESC;


--Consulta 2
-- Ejemplo 1 Co-located join
EXPLAIN ANALYZE
SELECT c.nombre_componente, SUM(orep.cantidad_utilizada) AS total_repuestos
FROM aa_mantenimiento.orden_repuesto orep
JOIN aa_mantenimiento.orden_trabajo ot 
  ON orep.id_orden = ot.id_orden 
 AND orep.id_aeropuerto = ot.id_aeropuerto -- Fuerza Co-location
JOIN aa_mantenimiento.componente c 
  ON ot.id_componente = c.id_componente 
 AND ot.id_aeropuerto = c.id_aeropuerto     -- Fuerza Co-location
GROUP BY c.nombre_componente;

-- Ejemplo 2 Gather en coordinador
-- Tabla temporal
CREATE TEMP TABLE tmp_repuestos_componente AS
SELECT c.nombre_componente, orep.cantidad_utilizada
FROM aa_mantenimiento.orden_repuesto orep
JOIN aa_mantenimiento.orden_trabajo ot
ON orep.id_orden = ot.id_orden AND orep.id_aeropuerto = ot.id_aeropuerto
JOIN aa_mantenimiento.componente c
ON ot.id_componente = c.id_componente AND ot.id_aeropuerto = c.id_aeropuerto;

-- Consulta
EXPLAIN ANALYZE
SELECT nombre_componente, SUM(cantidad_utilizada) AS total_repuestos
FROM tmp_repuestos_componente
GROUP BY nombre_componente;

-- eliminar tabla temporal
DROP TABLE IF EXISTS tmp_repuestos_componente;


-- Consultas Staging

EXPLAIN ANALYZE
SELECT a.codigo_iata, ot.prioridad, COUNT(ot.id_orden) AS total_ordenes
FROM aa_mantenimiento.orden_trabajo ot
JOIN aa_mantenimiento.discrepancia_tecnica dt ON ot.id_discrepancia = dt.id_discrepancia
JOIN aa_mantenimiento.inspeccion i ON dt.id_inspeccion = i.id_inspeccion
JOIN aa_mantenimiento.aeropuerto a ON i.id_aeropuerto = a.id_aeropuerto
WHERE ot.estado = 'ABIERTA'
GROUP BY a.codigo_iata, ot.prioridad
ORDER BY total_ordenes DESC;

EXPLAIN ANALYZE
SELECT a.codigo_iata, ot.prioridad, COUNT(ot.id_orden) AS total_ordenes
FROM aa_mantenimiento.orden_trabajo ot
JOIN aa_mantenimiento.discrepancia_tecnica dt ON ot.id_discrepancia = dt.id_discrepancia
JOIN aa_mantenimiento.inspeccion i ON dt.id_inspeccion = i.id_inspeccion
JOIN aa_mantenimiento.aeropuerto a ON i.id_aeropuerto = a.id_aeropuerto
JOIN aa_mantenimiento.region r ON a.id_region = r.id_region
WHERE ot.estado = 'ABIERTA'
GROUP BY a.codigo_iata, ot.prioridad
ORDER BY total_ordenes DESC;

EXPLAIN ANALYZE
SELECT c.nombre_componente, SUM(orep.cantidad_utilizada) AS total_repuestos
FROM aa_mantenimiento.orden_repuesto orep
JOIN aa_mantenimiento.orden_trabajo ot ON orep.id_orden = ot.id_orden
JOIN aa_mantenimiento.componente c ON ot.id_componente = c.id_componente
GROUP BY c.nombre_componente;

-- Tabla temporal (staging)
EXPLAIN ANALYZE
CREATE TEMP TABLE tmp_repuestos_componente AS
SELECT c.nombre_componente, orep.cantidad_utilizada
FROM aa_mantenimiento.orden_repuesto orep
JOIN aa_mantenimiento.orden_trabajo ot ON orep.id_orden = ot.id_orden
JOIN aa_mantenimiento.componente c ON ot.id_componente = c.id_componente;

EXPLAIN ANALYZE
SELECT nombre_componente, SUM(cantidad_utilizada) AS total_repuestos
FROM tmp_repuestos_componente
GROUP BY nombre_componente;

DROP TABLE IF EXISTS tmp_repuestos_componente;