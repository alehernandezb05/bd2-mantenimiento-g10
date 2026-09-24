USE aa_mantenimiento;

INSERT INTO region (nombre_region) VALUES ('ESTE'), ('CENTRAL'), ('OESTE');

-- ids de region: 1 = ESTE, 2 = CENTRAL, 3 = OESTE (por el orden del INSERT anterior)
INSERT INTO aeropuerto (codigo_iata, id_region) VALUES
('CLT',1),('PHL',1),('JFK',1),('LGA',1),('DCA',1),('MIA',1),('BOS',1),
('EWR',1),('BWI',1),('IAD',1),('PIT',1),('RDU',1),('ATL',1),('MCO',1),
('DFW',2),('ORD',2),('MSP',2),('DTW',2),('CLE',2),('STL',2),('MCI',2),
('MSY',2),('IAH',2),('AUS',2),('SAT',2),('MEM',2),('BNA',2),('MDW',2),
('PHX',3),('LAX',3),('SFO',3),('SAN',3),('LAS',3),('SEA',3),('PDX',3),
('SLC',3),('DEN',3),('ABQ',3),('TUS',3),('SJC',3),('SNA',3),('OAK',3);

INSERT INTO hub (id_aeropuerto)
SELECT id_aeropuerto FROM aeropuerto
WHERE codigo_iata IN ('CLT','PHL','JFK','LGA','DCA','MIA','DFW','ORD','PHX','LAX');