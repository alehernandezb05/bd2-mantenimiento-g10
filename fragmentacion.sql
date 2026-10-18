SET search_path TO aa_mantenimiento, public;
-- Clave de distribucion
Begin;
ALTER TABLE orden_trabajo ALTER COLUMN id_aeropuerto SET NOT NULL;
ALTER TABLE orden_repuesto ALTER COLUMN id_aeropuerto SET NOT NULL;
ALTER TABLE componente ALTER COLUMN id_aeropuerto SET NOT NULL;

ALTER TABLE orden_trabajo DROP CONSTRAINT IF EXISTS fk_orden_aeropuerto;
ALTER TABLE orden_trabajo ADD CONSTRAINT fk_orden_aeropuerto 
FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

ALTER TABLE orden_repuesto DROP CONSTRAINT IF EXISTS fk_orden_repuesto_aeropuerto;
ALTER TABLE orden_repuesto ADD CONSTRAINT fk_orden_repuesto_aeropuerto 
FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

ALTER TABLE componente DROP CONSTRAINT IF EXISTS fk_componente_aeropuerto;
ALTER TABLE componente ADD CONSTRAINT fk_componente_aeropuerto 
FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);


ALTER TABLE orden_trabajo DROP CONSTRAINT "idx_16430_primary" CASCADE;
ALTER TABLE orden_trabajo ADD PRIMARY KEY (id_orden, id_aeropuerto);

ALTER TABLE inspeccion DROP CONSTRAINT "idx_16415_primary" CASCADE;
ALTER TABLE inspeccion ADD PRIMARY KEY (id_inspeccion, id_aeropuerto);

ALTER TABLE discrepancia_tecnica DROP CONSTRAINT "idx_16404_primary" CASCADE;
ALTER TABLE discrepancia_tecnica ADD PRIMARY KEY (id_discrepancia, id_aeropuerto);

ALTER TABLE inventario_repuesto DROP CONSTRAINT "idx_16421_primary" CASCADE;
ALTER TABLE inventario_repuesto ADD PRIMARY KEY (id_repuesto, id_aeropuerto);

ALTER TABLE componente DROP CONSTRAINT "idx_16396_primary" CASCADE;
ALTER TABLE componente ADD PRIMARY KEY (id_componente, id_aeropuerto);

ALTER TABLE orden_repuesto DROP CONSTRAINT "idx_16427_primary" CASCADE;
ALTER TABLE orden_repuesto ADD PRIMARY KEY (id_orden, id_repuesto, id_aeropuerto);

Commit;


BEGIN;
SET search_path TO aa_mantenimiento, public;

ALTER TABLE hub DROP CONSTRAINT IF EXISTS fk_hub_aeropuerto;
ALTER TABLE aeropuerto DROP CONSTRAINT IF EXISTS fk_aeropuerto_region;

ALTER TABLE inspeccion DROP CONSTRAINT IF EXISTS fk_inspeccion_aeropuerto;
ALTER TABLE discrepancia_tecnica DROP CONSTRAINT IF EXISTS fk_discrepancia_aeropuerto;
ALTER TABLE orden_trabajo DROP CONSTRAINT IF EXISTS fk_orden_aeropuerto;
ALTER TABLE inventario_repuesto DROP CONSTRAINT IF EXISTS fk_inventario_aeropuerto;
ALTER TABLE componente DROP CONSTRAINT IF EXISTS fk_componente_aeropuerto;
ALTER TABLE orden_repuesto DROP CONSTRAINT IF EXISTS fk_orden_repuesto_aeropuerto;
COMMIT;

BEGIN;
SET search_path TO aa_mantenimiento, public;
DROP INDEX IF EXISTS idx_16391_codigo_iata CASCADE;
DROP INDEX IF EXISTS idx_16415_codigo_inspeccion;
DROP INDEX IF EXISTS aa_mantenimiento.idx_16404_codigo_discrepancia;
DROP INDEX IF EXISTS aa_mantenimiento.idx_16430_codigo_orden;
DROP INDEX IF EXISTS aa_mantenimiento.idx_16430_numero_orden;
DROP INDEX IF EXISTS aa_mantenimiento.orden_trabajo_codigo_key;
DROP INDEX IF EXISTS aa_mantenimiento.idx_16421_codigo_repuesto;
DROP INDEX IF EXISTS aa_mantenimiento.idx_16396_numero_serie;
CREATE UNIQUE INDEX IF NOT EXISTS uq_inspeccion_codigo_shard 
ON aa_mantenimiento.inspeccion (codigo_inspeccion, id_aeropuerto);
CREATE UNIQUE INDEX IF NOT EXISTS uq_discrepancia_codigo_shard 
ON aa_mantenimiento.discrepancia_tecnica (codigo_discrepancia, id_aeropuerto);
CREATE UNIQUE INDEX IF NOT EXISTS uq_orden_trabajo_codigo_shard 
ON aa_mantenimiento.orden_trabajo (codigo_orden, id_aeropuerto);
CREATE UNIQUE INDEX IF NOT EXISTS uq_inventario_repuesto_codigo_shard 
ON aa_mantenimiento.inventario_repuesto (codigo_repuesto, id_aeropuerto);
CREATE UNIQUE INDEX IF NOT EXISTS uq_componente_serie_shard 
ON aa_mantenimiento.componente (numero_serie, id_aeropuerto);
COMMIT;

ALTER TABLE aa_mantenimiento.hub DROP CONSTRAINT IF EXISTS "idx_16410_primary" CASCADE;
ALTER TABLE aa_mantenimiento.hub ADD PRIMARY KEY (id_hub, id_aeropuerto);



-- Para restaurar la base de datos, solo debería hacer falta ejecutar esta parte


-- Tablas replicadas
SELECT create_reference_table('region');

-- Distribuir la tabla raíz
SELECT create_distributed_table('aeropuerto', 'id_aeropuerto');
SELECT create_distributed_table('hub', 'id_aeropuerto');

-- Distribuir tablas operacionales co-ubicadas con aeropuerto
SELECT create_distributed_table('inspeccion', 'id_aeropuerto');
SELECT create_distributed_table('discrepancia_tecnica', 'id_aeropuerto');
SELECT create_distributed_table('orden_trabajo', 'id_aeropuerto');
SELECT create_distributed_table('inventario_repuesto', 'id_aeropuerto');
SELECT create_distributed_table('componente', 'id_aeropuerto');
SELECT create_distributed_table('orden_repuesto', 'id_aeropuerto');


-- Fin de la parte a ejecutar


BEGIN;
SET search_path TO aa_mantenimiento, public;

-- FKs entre tablas de referencia / raíz
ALTER TABLE aeropuerto 
ADD CONSTRAINT fk_aeropuerto_region 
FOREIGN KEY (id_region) REFERENCES region(id_region);

ALTER TABLE aa_mantenimiento.hub 
ADD CONSTRAINT fk_hub_aeropuerto 
FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

-- FKs hacia la tabla distribuida raíz aeropuerto
ALTER TABLE inspeccion ADD CONSTRAINT fk_inspeccion_aeropuerto 
FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

ALTER TABLE aa_mantenimiento.discrepancia_tecnica 
    ADD CONSTRAINT fk_discrepancia_aeropuerto 
    FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

ALTER TABLE aa_mantenimiento.orden_trabajo 
    ADD CONSTRAINT fk_orden_aeropuerto 
    FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

ALTER TABLE aa_mantenimiento.inventario_repuesto 
    ADD CONSTRAINT fk_inventario_aeropuerto 
    FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

ALTER TABLE aa_mantenimiento.componente 
    ADD CONSTRAINT fk_componente_aeropuerto 
    FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

ALTER TABLE aa_mantenimiento.orden_repuesto 
    ADD CONSTRAINT fk_orden_repuesto_aeropuerto 
    FOREIGN KEY (id_aeropuerto) REFERENCES aeropuerto(id_aeropuerto);

-------------------------------------------------------------------------------
-- PASO 5: Recrear FKs Compuestas entre Tablas Operacionales Co-ubicadas
-------------------------------------------------------------------------------
-- Discrepancia -> Inspección
ALTER TABLE aa_mantenimiento.discrepancia_tecnica 
    ADD CONSTRAINT fk_discrepancia_inspeccion 
    FOREIGN KEY (id_inspeccion, id_aeropuerto) 
    REFERENCES inspeccion(id_inspeccion, id_aeropuerto);

-- Orden Trabajo -> Discrepancia
ALTER TABLE aa_mantenimiento.orden_trabajo 
    ADD CONSTRAINT fk_orden_discrepancia 
    FOREIGN KEY (id_discrepancia, id_aeropuerto) 
    REFERENCES discrepancia_tecnica(id_discrepancia, id_aeropuerto);

-- Orden Repuesto -> Orden Trabajo
ALTER TABLE aa_mantenimiento.orden_repuesto 
    ADD CONSTRAINT fk_orden_repuesto_orden 
    FOREIGN KEY (id_orden, id_aeropuerto) 
    REFERENCES orden_trabajo(id_orden, id_aeropuerto);

-- Orden Repuesto -> Inventario Repuesto
ALTER TABLE aa_mantenimiento.orden_repuesto 
    ADD CONSTRAINT fk_orden_repuesto_inventario 
    FOREIGN KEY (id_repuesto, id_aeropuerto) 
    REFERENCES inventario_repuesto(id_repuesto, id_aeropuerto);

COMMIT;
rollback;

SELECT 
    logicalrelid::regclass AS tabla,
    CASE 
        WHEN partmethod = 'n' THEN 'Distribuida (Hash)'
        WHEN partmethod = 'a' THEN 'Distribuida (Append)'
        WHEN partmethod = 'r' THEN 'Reference (Replicada)'
        ELSE 'Local'
    END AS tipo_de_tabla,
    CASE 
        WHEN partmethod = 'r' THEN 'N/A (Réplica en todos los nodos)'
        ELSE column_to_column_name(logicalrelid, partkey)
    END AS columna_de_distribucion,
    colocationid AS id_colocacion,
    repmodel AS modelo_replicacion
FROM 
    pg_dist_partition
WHERE 
    logicalrelid::text LIKE 'aa_mantenimiento.%'
ORDER BY 
    tipo_de_tabla DESC, tabla;