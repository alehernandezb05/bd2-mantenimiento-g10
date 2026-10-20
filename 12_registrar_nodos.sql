-- Registrar los workers en el coordinador (ejecutar en citus_coordinator)
SELECT extname, extversion FROM pg_extension WHERE extname = 'citus';
SELECT citus_set_coordinator_host('citus_coordinator', 5432);
SELECT master_add_node('citus_worker_1', 5432);   -- Region ESTE
SELECT master_add_node('citus_worker_2', 5432);   -- Region CENTRAL
SELECT master_add_node('citus_worker_3', 5432);   -- Region OESTE
SELECT nodeid, nodename, nodeport, groupid, noderole, isactive, shouldhaveshards
FROM pg_dist_node ORDER BY nodeid;
SELECT * FROM citus_get_active_worker_nodes();
