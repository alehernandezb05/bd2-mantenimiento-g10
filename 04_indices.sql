USE aa_mantenimiento;

-- indices btree
CREATE INDEX idx_orden_estado_prioridad ON orden_trabajo (estado, prioridad);
CREATE INDEX idx_orden_fecha_apertura ON orden_trabajo (fecha_apertura);
CREATE INDEX idx_inspeccion_matricula_fecha ON inspeccion (matricula_aeronave, fecha_inspeccion);
CREATE INDEX idx_discrepancia_estado_severidad ON discrepancia_tecnica (estado, severidad);

-- indices fulltext
CREATE FULLTEXT INDEX ft_repuesto_descripcion ON inventario_repuesto (descripcion);
CREATE FULLTEXT INDEX ft_componente_nombre ON componente (nombre_componente);

ANALYZE TABLE orden_trabajo, inspeccion, discrepancia_tecnica, inventario_repuesto, componente;

-- 3.2 Show index

-- SHOW INDEX FROM orden_trabajo;
-- SHOW INDEX FROM inspeccion;
-- SHOW INDEX FROM discrepancia_tecnica;
-- SHOW INDEX FROM inventario_repuesto;
-- SHOW INDEX FROM componente;