SELECT table_name, table_rows, avg_row_length, data_length
FROM information_schema.tables
WHERE table_schema = 'aa_mantenimiento' AND table_name = 'orden_trabajo';