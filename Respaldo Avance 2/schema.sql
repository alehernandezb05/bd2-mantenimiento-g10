--
-- PostgreSQL database dump
--

-- Dumped from database version 16.6 (Debian 16.6-1.pgdg120+1)
-- Dumped by pg_dump version 16.6 (Debian 16.6-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: aa_mantenimiento; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA aa_mantenimiento;


ALTER SCHEMA aa_mantenimiento OWNER TO postgres;

--
-- Name: citus; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citus WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION citus; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citus IS 'Citus distributed database';


--
-- Name: citus_columnar; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citus_columnar WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION citus_columnar; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citus_columnar IS 'Citus Columnar extension';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aeropuerto; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.aeropuerto (
    id_aeropuerto bigint NOT NULL,
    codigo_iata character(3) NOT NULL,
    id_region smallint NOT NULL
);


ALTER TABLE aa_mantenimiento.aeropuerto OWNER TO postgres;

--
-- Name: aeropuerto_id_aeropuerto_seq; Type: SEQUENCE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE SEQUENCE aa_mantenimiento.aeropuerto_id_aeropuerto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aa_mantenimiento.aeropuerto_id_aeropuerto_seq OWNER TO postgres;

--
-- Name: aeropuerto_id_aeropuerto_seq; Type: SEQUENCE OWNED BY; Schema: aa_mantenimiento; Owner: postgres
--

ALTER SEQUENCE aa_mantenimiento.aeropuerto_id_aeropuerto_seq OWNED BY aa_mantenimiento.aeropuerto.id_aeropuerto;


--
-- Name: componente; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.componente (
    id_componente bigint NOT NULL,
    numero_serie character varying(50) NOT NULL,
    numero_parte character varying(50) NOT NULL,
    nombre_componente character varying(100) NOT NULL,
    horas_acumuladas numeric(8,2) DEFAULT 0.00 NOT NULL,
    ciclos_acumulados bigint DEFAULT '0'::bigint NOT NULL,
    estado character varying(20) DEFAULT 'OPERATIVO'::character varying NOT NULL,
    id_aeropuerto bigint NOT NULL,
    CONSTRAINT ck_componente_ciclos CHECK ((ciclos_acumulados >= 0)),
    CONSTRAINT ck_componente_estado CHECK (((estado)::text = ANY (ARRAY[('OPERATIVO'::character varying)::text, ('EN_REPARACION'::character varying)::text, ('INSPECCION'::character varying)::text, ('DESCARTADO'::character varying)::text]))),
    CONSTRAINT ck_componente_horas CHECK ((horas_acumuladas >= (0)::numeric))
);


ALTER TABLE aa_mantenimiento.componente OWNER TO postgres;

--
-- Name: componente_id_componente_seq; Type: SEQUENCE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE SEQUENCE aa_mantenimiento.componente_id_componente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aa_mantenimiento.componente_id_componente_seq OWNER TO postgres;

--
-- Name: componente_id_componente_seq; Type: SEQUENCE OWNED BY; Schema: aa_mantenimiento; Owner: postgres
--

ALTER SEQUENCE aa_mantenimiento.componente_id_componente_seq OWNED BY aa_mantenimiento.componente.id_componente;


--
-- Name: discrepancia_tecnica; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.discrepancia_tecnica (
    id_discrepancia bigint NOT NULL,
    codigo_discrepancia character(10) NOT NULL,
    id_inspeccion bigint,
    matricula_aeronave character varying(10) NOT NULL,
    severidad character(1) NOT NULL,
    fecha_reporte timestamp with time zone NOT NULL,
    estado character varying(20) DEFAULT 'ABIERTA'::character varying NOT NULL,
    id_aeropuerto bigint NOT NULL,
    CONSTRAINT ck_discrepancia_estado CHECK (((estado)::text = ANY (ARRAY[('ABIERTA'::character varying)::text, ('EN_REVISION'::character varying)::text, ('RESUELTA'::character varying)::text, ('DIFERIDA'::character varying)::text]))),
    CONSTRAINT ck_discrepancia_severidad CHECK ((severidad = ANY (ARRAY['1'::bpchar, '2'::bpchar, '3'::bpchar, '4'::bpchar])))
);


ALTER TABLE aa_mantenimiento.discrepancia_tecnica OWNER TO postgres;

--
-- Name: discrepancia_tecnica_id_discrepancia_seq; Type: SEQUENCE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE SEQUENCE aa_mantenimiento.discrepancia_tecnica_id_discrepancia_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aa_mantenimiento.discrepancia_tecnica_id_discrepancia_seq OWNER TO postgres;

--
-- Name: discrepancia_tecnica_id_discrepancia_seq; Type: SEQUENCE OWNED BY; Schema: aa_mantenimiento; Owner: postgres
--

ALTER SEQUENCE aa_mantenimiento.discrepancia_tecnica_id_discrepancia_seq OWNED BY aa_mantenimiento.discrepancia_tecnica.id_discrepancia;


--
-- Name: hub; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.hub (
    id_hub bigint NOT NULL,
    id_aeropuerto bigint NOT NULL
);


ALTER TABLE aa_mantenimiento.hub OWNER TO postgres;

--
-- Name: hub_id_hub_seq; Type: SEQUENCE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE SEQUENCE aa_mantenimiento.hub_id_hub_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aa_mantenimiento.hub_id_hub_seq OWNER TO postgres;

--
-- Name: hub_id_hub_seq; Type: SEQUENCE OWNED BY; Schema: aa_mantenimiento; Owner: postgres
--

ALTER SEQUENCE aa_mantenimiento.hub_id_hub_seq OWNED BY aa_mantenimiento.hub.id_hub;


--
-- Name: inspeccion; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.inspeccion (
    id_inspeccion bigint NOT NULL,
    codigo_inspeccion character(10) NOT NULL,
    tipo_inspeccion character varying(20) NOT NULL,
    fecha_inspeccion timestamp with time zone NOT NULL,
    matricula_aeronave character varying(10) NOT NULL,
    id_aeropuerto bigint NOT NULL,
    resultado character varying(20) DEFAULT 'APROBADO'::character varying NOT NULL,
    CONSTRAINT ck_inspeccion_resultado CHECK (((resultado)::text = ANY (ARRAY[('APROBADO'::character varying)::text, ('CON_DISCREPANCIA'::character varying)::text, ('RECHAZADO'::character varying)::text]))),
    CONSTRAINT ck_inspeccion_tipo CHECK (((tipo_inspeccion)::text = ANY (ARRAY[('DIARIA'::character varying)::text, ('PREFLIGHT'::character varying)::text, ('CHECK_A'::character varying)::text, ('CHECK_B'::character varying)::text, ('CHECK_C'::character varying)::text, ('CHECK_D'::character varying)::text])))
);


ALTER TABLE aa_mantenimiento.inspeccion OWNER TO postgres;

--
-- Name: inspeccion_id_inspeccion_seq; Type: SEQUENCE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE SEQUENCE aa_mantenimiento.inspeccion_id_inspeccion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aa_mantenimiento.inspeccion_id_inspeccion_seq OWNER TO postgres;

--
-- Name: inspeccion_id_inspeccion_seq; Type: SEQUENCE OWNED BY; Schema: aa_mantenimiento; Owner: postgres
--

ALTER SEQUENCE aa_mantenimiento.inspeccion_id_inspeccion_seq OWNED BY aa_mantenimiento.inspeccion.id_inspeccion;


--
-- Name: inventario_repuesto; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.inventario_repuesto (
    id_repuesto bigint NOT NULL,
    codigo_repuesto character varying(30) NOT NULL,
    descripcion character varying(150) NOT NULL,
    cantidad_disponible bigint DEFAULT '0'::bigint NOT NULL,
    cantidad_minima bigint DEFAULT '1'::bigint NOT NULL,
    costo_unitario numeric(10,2) NOT NULL,
    id_aeropuerto_bodega bigint NOT NULL,
    id_aeropuerto bigint NOT NULL,
    CONSTRAINT ck_inventario_costo CHECK ((costo_unitario >= (0)::numeric)),
    CONSTRAINT ck_inventario_disponible CHECK ((cantidad_disponible >= 0)),
    CONSTRAINT ck_inventario_minima CHECK ((cantidad_minima >= 0))
);


ALTER TABLE aa_mantenimiento.inventario_repuesto OWNER TO postgres;

--
-- Name: inventario_repuesto_id_repuesto_seq; Type: SEQUENCE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE SEQUENCE aa_mantenimiento.inventario_repuesto_id_repuesto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aa_mantenimiento.inventario_repuesto_id_repuesto_seq OWNER TO postgres;

--
-- Name: inventario_repuesto_id_repuesto_seq; Type: SEQUENCE OWNED BY; Schema: aa_mantenimiento; Owner: postgres
--

ALTER SEQUENCE aa_mantenimiento.inventario_repuesto_id_repuesto_seq OWNED BY aa_mantenimiento.inventario_repuesto.id_repuesto;


--
-- Name: orden_repuesto; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.orden_repuesto (
    id_orden bigint NOT NULL,
    id_repuesto bigint NOT NULL,
    cantidad_utilizada bigint NOT NULL,
    id_aeropuerto bigint NOT NULL,
    CONSTRAINT ck_orden_repuesto_cantidad CHECK ((cantidad_utilizada > 0))
);


ALTER TABLE aa_mantenimiento.orden_repuesto OWNER TO postgres;

--
-- Name: orden_trabajo; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.orden_trabajo (
    id_orden bigint NOT NULL,
    codigo_orden character(12) NOT NULL,
    fecha_apertura date NOT NULL,
    horas_hombre numeric(6,2) NOT NULL,
    prioridad character(1) NOT NULL,
    estado character varying(20) NOT NULL,
    matricula_aeronave character varying(10) NOT NULL,
    fecha_cierre date,
    id_discrepancia bigint,
    id_componente bigint,
    id_aeropuerto bigint NOT NULL,
    CONSTRAINT ck_orden_estado CHECK (((estado)::text = ANY (ARRAY[('ABIERTA'::character varying)::text, ('EN_PROCESO'::character varying)::text, ('CERRADA'::character varying)::text, ('PENDIENTE_REPUESTO'::character varying)::text]))),
    CONSTRAINT ck_orden_fechas CHECK (((fecha_cierre IS NULL) OR (fecha_cierre >= fecha_apertura))),
    CONSTRAINT ck_orden_horas CHECK ((horas_hombre >= (0)::numeric)),
    CONSTRAINT ck_orden_prioridad CHECK ((prioridad = ANY (ARRAY['A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar])))
);


ALTER TABLE aa_mantenimiento.orden_trabajo OWNER TO postgres;

--
-- Name: region; Type: TABLE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE TABLE aa_mantenimiento.region (
    id_region integer NOT NULL,
    nombre_region character varying(10) NOT NULL,
    CONSTRAINT ck_region_nombre CHECK (((nombre_region)::text = ANY (ARRAY[('ESTE'::character varying)::text, ('CENTRAL'::character varying)::text, ('OESTE'::character varying)::text])))
);


ALTER TABLE aa_mantenimiento.region OWNER TO postgres;

--
-- Name: region_id_region_seq; Type: SEQUENCE; Schema: aa_mantenimiento; Owner: postgres
--

CREATE SEQUENCE aa_mantenimiento.region_id_region_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aa_mantenimiento.region_id_region_seq OWNER TO postgres;

--
-- Name: region_id_region_seq; Type: SEQUENCE OWNED BY; Schema: aa_mantenimiento; Owner: postgres
--

ALTER SEQUENCE aa_mantenimiento.region_id_region_seq OWNED BY aa_mantenimiento.region.id_region;


--
-- Name: aeropuerto id_aeropuerto; Type: DEFAULT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.aeropuerto ALTER COLUMN id_aeropuerto SET DEFAULT nextval('aa_mantenimiento.aeropuerto_id_aeropuerto_seq'::regclass);


--
-- Name: componente id_componente; Type: DEFAULT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.componente ALTER COLUMN id_componente SET DEFAULT nextval('aa_mantenimiento.componente_id_componente_seq'::regclass);


--
-- Name: discrepancia_tecnica id_discrepancia; Type: DEFAULT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.discrepancia_tecnica ALTER COLUMN id_discrepancia SET DEFAULT nextval('aa_mantenimiento.discrepancia_tecnica_id_discrepancia_seq'::regclass);


--
-- Name: hub id_hub; Type: DEFAULT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.hub ALTER COLUMN id_hub SET DEFAULT nextval('aa_mantenimiento.hub_id_hub_seq'::regclass);


--
-- Name: inspeccion id_inspeccion; Type: DEFAULT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.inspeccion ALTER COLUMN id_inspeccion SET DEFAULT nextval('aa_mantenimiento.inspeccion_id_inspeccion_seq'::regclass);


--
-- Name: inventario_repuesto id_repuesto; Type: DEFAULT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.inventario_repuesto ALTER COLUMN id_repuesto SET DEFAULT nextval('aa_mantenimiento.inventario_repuesto_id_repuesto_seq'::regclass);


--
-- Name: region id_region; Type: DEFAULT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.region ALTER COLUMN id_region SET DEFAULT nextval('aa_mantenimiento.region_id_region_seq'::regclass);


--
-- Name: componente componente_pkey; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.componente
    ADD CONSTRAINT componente_pkey PRIMARY KEY (id_componente, id_aeropuerto);


--
-- Name: discrepancia_tecnica discrepancia_tecnica_pkey; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.discrepancia_tecnica
    ADD CONSTRAINT discrepancia_tecnica_pkey PRIMARY KEY (id_discrepancia, id_aeropuerto);


--
-- Name: hub hub_pkey; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.hub
    ADD CONSTRAINT hub_pkey PRIMARY KEY (id_hub, id_aeropuerto);


--
-- Name: aeropuerto idx_16391_primary; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.aeropuerto
    ADD CONSTRAINT idx_16391_primary PRIMARY KEY (id_aeropuerto);


--
-- Name: region idx_16434_primary; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.region
    ADD CONSTRAINT idx_16434_primary PRIMARY KEY (id_region);


--
-- Name: inspeccion inspeccion_pkey; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.inspeccion
    ADD CONSTRAINT inspeccion_pkey PRIMARY KEY (id_inspeccion, id_aeropuerto);


--
-- Name: inventario_repuesto inventario_repuesto_pkey; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.inventario_repuesto
    ADD CONSTRAINT inventario_repuesto_pkey PRIMARY KEY (id_repuesto, id_aeropuerto);


--
-- Name: orden_repuesto orden_repuesto_pkey; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.orden_repuesto
    ADD CONSTRAINT orden_repuesto_pkey PRIMARY KEY (id_orden, id_repuesto, id_aeropuerto);


--
-- Name: orden_trabajo orden_trabajo_pkey; Type: CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.orden_trabajo
    ADD CONSTRAINT orden_trabajo_pkey PRIMARY KEY (id_orden, id_aeropuerto);


--
-- Name: idx_16391_fk_aeropuerto_region; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE INDEX idx_16391_fk_aeropuerto_region ON aa_mantenimiento.aeropuerto USING btree (id_region);


--
-- Name: idx_16404_fk_discrepancia_inspeccion; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE INDEX idx_16404_fk_discrepancia_inspeccion ON aa_mantenimiento.discrepancia_tecnica USING btree (id_inspeccion);


--
-- Name: idx_16410_id_aeropuerto; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE UNIQUE INDEX idx_16410_id_aeropuerto ON aa_mantenimiento.hub USING btree (id_aeropuerto);


--
-- Name: idx_16415_fk_inspeccion_aeropuerto; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE INDEX idx_16415_fk_inspeccion_aeropuerto ON aa_mantenimiento.inspeccion USING btree (id_aeropuerto);


--
-- Name: idx_16421_fk_inventario_aeropuerto; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE INDEX idx_16421_fk_inventario_aeropuerto ON aa_mantenimiento.inventario_repuesto USING btree (id_aeropuerto_bodega);


--
-- Name: idx_16427_fk_or_repuesto; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE INDEX idx_16427_fk_or_repuesto ON aa_mantenimiento.orden_repuesto USING btree (id_repuesto);


--
-- Name: idx_16430_fk_orden_componente; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE INDEX idx_16430_fk_orden_componente ON aa_mantenimiento.orden_trabajo USING btree (id_componente);


--
-- Name: idx_16430_fk_orden_discrepancia; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE INDEX idx_16430_fk_orden_discrepancia ON aa_mantenimiento.orden_trabajo USING btree (id_discrepancia);


--
-- Name: idx_16434_nombre_region; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE UNIQUE INDEX idx_16434_nombre_region ON aa_mantenimiento.region USING btree (nombre_region);


--
-- Name: uq_componente_serie_shard; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE UNIQUE INDEX uq_componente_serie_shard ON aa_mantenimiento.componente USING btree (numero_serie, id_aeropuerto);


--
-- Name: uq_discrepancia_codigo_shard; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE UNIQUE INDEX uq_discrepancia_codigo_shard ON aa_mantenimiento.discrepancia_tecnica USING btree (codigo_discrepancia, id_aeropuerto);


--
-- Name: uq_inspeccion_codigo_shard; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE UNIQUE INDEX uq_inspeccion_codigo_shard ON aa_mantenimiento.inspeccion USING btree (codigo_inspeccion, id_aeropuerto);


--
-- Name: uq_inventario_repuesto_codigo_shard; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE UNIQUE INDEX uq_inventario_repuesto_codigo_shard ON aa_mantenimiento.inventario_repuesto USING btree (codigo_repuesto, id_aeropuerto);


--
-- Name: uq_orden_trabajo_codigo_shard; Type: INDEX; Schema: aa_mantenimiento; Owner: postgres
--

CREATE UNIQUE INDEX uq_orden_trabajo_codigo_shard ON aa_mantenimiento.orden_trabajo USING btree (codigo_orden, id_aeropuerto);


--
-- Name: aeropuerto fk_aeropuerto_region; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.aeropuerto
    ADD CONSTRAINT fk_aeropuerto_region FOREIGN KEY (id_region) REFERENCES aa_mantenimiento.region(id_region);


--
-- Name: componente fk_componente_aeropuerto; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.componente
    ADD CONSTRAINT fk_componente_aeropuerto FOREIGN KEY (id_aeropuerto) REFERENCES aa_mantenimiento.aeropuerto(id_aeropuerto);


--
-- Name: discrepancia_tecnica fk_discrepancia_aeropuerto; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.discrepancia_tecnica
    ADD CONSTRAINT fk_discrepancia_aeropuerto FOREIGN KEY (id_aeropuerto) REFERENCES aa_mantenimiento.aeropuerto(id_aeropuerto);


--
-- Name: discrepancia_tecnica fk_discrepancia_inspeccion; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.discrepancia_tecnica
    ADD CONSTRAINT fk_discrepancia_inspeccion FOREIGN KEY (id_inspeccion, id_aeropuerto) REFERENCES aa_mantenimiento.inspeccion(id_inspeccion, id_aeropuerto);


--
-- Name: hub fk_hub_aeropuerto; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.hub
    ADD CONSTRAINT fk_hub_aeropuerto FOREIGN KEY (id_aeropuerto) REFERENCES aa_mantenimiento.aeropuerto(id_aeropuerto);


--
-- Name: inspeccion fk_inspeccion_aeropuerto; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.inspeccion
    ADD CONSTRAINT fk_inspeccion_aeropuerto FOREIGN KEY (id_aeropuerto) REFERENCES aa_mantenimiento.aeropuerto(id_aeropuerto);


--
-- Name: inventario_repuesto fk_inventario_aeropuerto; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.inventario_repuesto
    ADD CONSTRAINT fk_inventario_aeropuerto FOREIGN KEY (id_aeropuerto) REFERENCES aa_mantenimiento.aeropuerto(id_aeropuerto);


--
-- Name: orden_trabajo fk_orden_aeropuerto; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.orden_trabajo
    ADD CONSTRAINT fk_orden_aeropuerto FOREIGN KEY (id_aeropuerto) REFERENCES aa_mantenimiento.aeropuerto(id_aeropuerto);


--
-- Name: orden_trabajo fk_orden_discrepancia; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.orden_trabajo
    ADD CONSTRAINT fk_orden_discrepancia FOREIGN KEY (id_discrepancia, id_aeropuerto) REFERENCES aa_mantenimiento.discrepancia_tecnica(id_discrepancia, id_aeropuerto);


--
-- Name: orden_repuesto fk_orden_repuesto_aeropuerto; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.orden_repuesto
    ADD CONSTRAINT fk_orden_repuesto_aeropuerto FOREIGN KEY (id_aeropuerto) REFERENCES aa_mantenimiento.aeropuerto(id_aeropuerto);


--
-- Name: orden_repuesto fk_orden_repuesto_inventario; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.orden_repuesto
    ADD CONSTRAINT fk_orden_repuesto_inventario FOREIGN KEY (id_repuesto, id_aeropuerto) REFERENCES aa_mantenimiento.inventario_repuesto(id_repuesto, id_aeropuerto);


--
-- Name: orden_repuesto fk_orden_repuesto_orden; Type: FK CONSTRAINT; Schema: aa_mantenimiento; Owner: postgres
--

ALTER TABLE ONLY aa_mantenimiento.orden_repuesto
    ADD CONSTRAINT fk_orden_repuesto_orden FOREIGN KEY (id_orden, id_aeropuerto) REFERENCES aa_mantenimiento.orden_trabajo(id_orden, id_aeropuerto);


--
-- PostgreSQL database dump complete
--

