SET search_path TO aa_mantenimiento, public;

-- 1. Índices B-tree en tablas distribuidas
CREATE INDEX IF NOT EXISTS idx_orden_trabajo_estado ON orden_trabajo (estado);
CREATE INDEX IF NOT EXISTS idx_orden_trabajo_fecha ON orden_trabajo (fecha_apertura);
CREATE INDEX IF NOT EXISTS idx_orden_trabajo_aeronave ON orden_trabajo (matricula_aeronave);

CREATE INDEX IF NOT EXISTS idx_inspeccion_fecha ON inspeccion (fecha_inspeccion);
CREATE INDEX IF NOT EXISTS idx_inspeccion_aeronave ON inspeccion (matricula_aeronave);

CREATE INDEX IF NOT EXISTS idx_discrepancia_severidad ON discrepancia_tecnica (severidad);
CREATE INDEX IF NOT EXISTS idx_discrepancia_estado ON discrepancia_tecnica (estado);

-- 2. Búsqueda Full Text en PostgreSQL (GIN con tsvector)
CREATE INDEX IF NOT EXISTS ft_repuesto_descripcion ON inventario_repuesto USING gin(to_tsvector('spanish', descripcion));
CREATE INDEX IF NOT EXISTS ft_componente_nombre ON componente USING gin(to_tsvector('spanish', nombre_componente));

-- 3. Actualización de estadísticas para el optimizador distribuido
ANALYZE orden_trabajo;
ANALYZE inspeccion;
ANALYZE discrepancia_tecnica;
ANALYZE inventario_repuesto;
ANALYZE componente;
