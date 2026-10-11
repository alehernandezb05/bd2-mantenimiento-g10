USE aa_mantenimiento;

DROP TABLE IF EXISTS orden_repuesto;
DROP TABLE IF EXISTS orden_trabajo;
DROP TABLE IF EXISTS discrepancia_tecnica;
DROP TABLE IF EXISTS inspeccion;
DROP TABLE IF EXISTS inventario_repuesto;
DROP TABLE IF EXISTS componente;


CREATE TABLE componente (
    id_componente BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    numero_serie VARCHAR(50) NOT NULL UNIQUE,
    numero_parte VARCHAR(50) NOT NULL,
    nombre_componente VARCHAR(100) NOT NULL,
    horas_acumuladas NUMERIC(8,2) NOT NULL DEFAULT 0.00,
    ciclos_acumulados INT UNSIGNED NOT NULL DEFAULT 0,
    estado VARCHAR(20) NOT NULL DEFAULT 'OPERATIVO',

    CONSTRAINT ck_componente_horas
        CHECK (horas_acumuladas >= 0),

    CONSTRAINT ck_componente_estado
        CHECK (
            estado IN (
                'OPERATIVO',
                'EN_REPARACION',
                'INSPECCION',
                'DESCARTADO'
            )
        )
);


CREATE TABLE inventario_repuesto (
    id_repuesto BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo_repuesto VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NOT NULL,
    cantidad_disponible INT UNSIGNED NOT NULL DEFAULT 0,
    cantidad_minima INT UNSIGNED NOT NULL DEFAULT 1,
    costo_unitario NUMERIC(10,2) NOT NULL,
    id_aeropuerto_bodega INT UNSIGNED NOT NULL,

    CONSTRAINT fk_inventario_aeropuerto
        FOREIGN KEY (id_aeropuerto_bodega)
        REFERENCES aeropuerto (id_aeropuerto),

    CONSTRAINT ck_inventario_costo
        CHECK (costo_unitario >= 0)
);


CREATE TABLE inspeccion (
    id_inspeccion BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo_inspeccion CHAR(10) NOT NULL UNIQUE,
    tipo_inspeccion VARCHAR(20) NOT NULL,
    fecha_inspeccion DATETIME NOT NULL,
    matricula_aeronave VARCHAR(10) NOT NULL,
    id_aeropuerto INT UNSIGNED NOT NULL,
    resultado VARCHAR(20) NOT NULL DEFAULT 'APROBADO',

    CONSTRAINT fk_inspeccion_aeropuerto
        FOREIGN KEY (id_aeropuerto)
        REFERENCES aeropuerto (id_aeropuerto),

    CONSTRAINT ck_inspeccion_tipo
        CHECK (
            tipo_inspeccion IN (
                'DIARIA',
                'PREFLIGHT',
                'CHECK_A',
                'CHECK_B',
                'CHECK_C',
                'CHECK_D'
            )
        ),

    CONSTRAINT ck_inspeccion_resultado
        CHECK (
            resultado IN (
                'APROBADO',
                'CON_DISCREPANCIA',
                'RECHAZADO'
            )
        )
);


CREATE TABLE discrepancia_tecnica (
    id_discrepancia BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo_discrepancia CHAR(10) NOT NULL UNIQUE,
    id_inspeccion BIGINT UNSIGNED NULL,
    matricula_aeronave VARCHAR(10) NOT NULL,
    severidad CHAR(1) NOT NULL,
    fecha_reporte DATETIME NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'ABIERTA',

    CONSTRAINT fk_discrepancia_inspeccion
        FOREIGN KEY (id_inspeccion)
        REFERENCES inspeccion (id_inspeccion),

    CONSTRAINT ck_discrepancia_severidad
        CHECK (severidad IN ('1', '2', '3', '4')),

    CONSTRAINT ck_discrepancia_estado
        CHECK (
            estado IN (
                'ABIERTA',
                'EN_REVISION',
                'RESUELTA',
                'DIFERIDA'
            )
        )
);


CREATE TABLE orden_trabajo (
    id_orden BIGINT PRIMARY KEY,
    codigo_orden CHAR(12) NOT NULL UNIQUE,
    fecha_apertura DATE NOT NULL,
    horas_hombre NUMERIC(6,2) NOT NULL,
    prioridad CHAR(1) NOT NULL,
    estado VARCHAR(20) NOT NULL,

    matricula_aeronave VARCHAR(10) NOT NULL,
    fecha_cierre DATE NULL,
    id_discrepancia BIGINT UNSIGNED NULL,
    id_componente BIGINT UNSIGNED NULL,

    CONSTRAINT fk_orden_discrepancia
        FOREIGN KEY (id_discrepancia)
        REFERENCES discrepancia_tecnica (id_discrepancia),

    CONSTRAINT fk_orden_componente
        FOREIGN KEY (id_componente)
        REFERENCES componente (id_componente),

    CONSTRAINT ck_orden_horas
        CHECK (horas_hombre >= 0),

    CONSTRAINT ck_orden_prioridad
        CHECK (
            prioridad IN ('A', 'B', 'C', 'D')
        ),

    CONSTRAINT ck_orden_estado
        CHECK (
            estado IN (
                'ABIERTA',
                'EN_PROCESO',
                'CERRADA',
                'PENDIENTE_REPUESTO'
            )
        ),

    CONSTRAINT ck_orden_fechas
        CHECK (
            fecha_cierre IS NULL
            OR fecha_cierre >= fecha_apertura
        )
);


CREATE TABLE orden_repuesto (
    id_orden BIGINT NOT NULL,
    id_repuesto BIGINT UNSIGNED NOT NULL,
    cantidad_utilizada INT UNSIGNED NOT NULL,

    PRIMARY KEY (id_orden, id_repuesto),

    CONSTRAINT fk_or_orden
        FOREIGN KEY (id_orden)
        REFERENCES orden_trabajo (id_orden),

    CONSTRAINT fk_or_repuesto
        FOREIGN KEY (id_repuesto)
        REFERENCES inventario_repuesto (id_repuesto),

    CONSTRAINT ck_orden_repuesto_cantidad
        CHECK (cantidad_utilizada > 0)
);