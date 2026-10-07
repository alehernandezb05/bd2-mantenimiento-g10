-- Avance 2: recuperar CHECK omitidos por pgLoader.
-- Ejecutar sobre la base central PostgreSQL.
-- También recuperar cantidades no negativas de columnas UNSIGNED.

BEGIN;

SET LOCAL search_path TO aa_mantenimiento, public;

ALTER TABLE region
    ADD CONSTRAINT ck_region_nombre
    CHECK (nombre_region IN ('ESTE', 'CENTRAL', 'OESTE'));

ALTER TABLE componente
    ADD CONSTRAINT ck_componente_horas
    CHECK (horas_acumuladas >= 0),
    ADD CONSTRAINT ck_componente_estado
    CHECK (estado IN (
        'OPERATIVO', 'EN_REPARACION', 'INSPECCION', 'DESCARTADO'
    )),
    ADD CONSTRAINT ck_componente_ciclos
    CHECK (ciclos_acumulados >= 0);

ALTER TABLE inventario_repuesto
    ADD CONSTRAINT ck_inventario_costo
    CHECK (costo_unitario >= 0),
    ADD CONSTRAINT ck_inventario_disponible
    CHECK (cantidad_disponible >= 0),
    ADD CONSTRAINT ck_inventario_minima
    CHECK (cantidad_minima >= 0);

ALTER TABLE inspeccion
    ADD CONSTRAINT ck_inspeccion_tipo
    CHECK (tipo_inspeccion IN (
        'DIARIA', 'PREFLIGHT', 'CHECK_A', 'CHECK_B', 'CHECK_C', 'CHECK_D'
    )),
    ADD CONSTRAINT ck_inspeccion_resultado
    CHECK (resultado IN (
        'APROBADO', 'CON_DISCREPANCIA', 'RECHAZADO'
    ));

ALTER TABLE discrepancia_tecnica
    ADD CONSTRAINT ck_discrepancia_severidad
    CHECK (severidad IN ('1', '2', '3', '4')),
    ADD CONSTRAINT ck_discrepancia_estado
    CHECK (estado IN (
        'ABIERTA', 'EN_REVISION', 'RESUELTA', 'DIFERIDA'
    ));

ALTER TABLE orden_trabajo
    ADD CONSTRAINT ck_orden_horas
    CHECK (horas_hombre >= 0),
    ADD CONSTRAINT ck_orden_prioridad
    CHECK (prioridad IN ('A', 'B', 'C', 'D')),
    ADD CONSTRAINT ck_orden_estado
    CHECK (estado IN (
        'ABIERTA', 'EN_PROCESO', 'CERRADA', 'PENDIENTE_REPUESTO'
    )),
    ADD CONSTRAINT ck_orden_fechas
    CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_apertura);

ALTER TABLE orden_repuesto
    ADD CONSTRAINT ck_orden_repuesto_cantidad
    CHECK (cantidad_utilizada > 0);

COMMIT;