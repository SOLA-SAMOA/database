-- 24 July 2015
-- #176 Remove plan 11439 from the database
-- Reinstate the links to the titles
INSERT INTO administrative.ba_unit_contains_spatial_unit
 ( ba_unit_id, spatial_unit_id, change_user)
 SELECT ba.id, co.id, 'andrew'
 FROM   administrative.ba_unit ba,
        cadastre.cadastre_object co
 WHERE  ba.name_lastpart = '11439'
 AND    co.name_lastpart = ba.name_lastpart
 AND    co.name_firstpart = 'LOT ' || ba.name_firstpart; 

