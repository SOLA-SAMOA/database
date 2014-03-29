-- 11 Nov 2013 Ticket #117
-- Add new villages to the map
INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, level_id, change_user, rowversion, reference_point)
SELECT uuid_generate_v1(), '2D', 'Vaitele-uta', 'onSurface', (SELECT id FROM cadastre.level WHERE name = 'Villages'), 'andrew', 1, 
ST_GeomFromText('POINT(412783.059 8470255.56)', 32702)
WHERE NOT EXISTS (SELECT id FROM cadastre.spatial_unit WHERE label = 'Vaitele-uta');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, level_id, change_user, rowversion, reference_point)
SELECT uuid_generate_v1(), '2D', 'Vaitele-fou', 'onSurface', (SELECT id FROM cadastre.level WHERE name = 'Villages'), 'andrew', 1, 
ST_GeomFromText('POINT(410237.51 8471004.37)', 32702)
WHERE NOT EXISTS (SELECT id FROM cadastre.spatial_unit WHERE label = 'Vaitele-fou');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, level_id, change_user, rowversion, reference_point)
SELECT uuid_generate_v1(), '2D', 'Falelauniu', 'onSurface', (SELECT id FROM cadastre.level WHERE name = 'Villages'), 'andrew', 1, 
ST_GeomFromText('POINT(410862.96 8470026.93)', 32702)
WHERE NOT EXISTS (SELECT id FROM cadastre.spatial_unit WHERE label = 'Falelauniu');

INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, level_id, change_user, rowversion, reference_point)
SELECT uuid_generate_v1(), '2D', 'Mulifanua', 'onSurface', (SELECT id FROM cadastre.level WHERE name = 'Villages'), 'andrew', 1, 
ST_GeomFromText('POINT(388399.20 8470553.63)', 32702)
WHERE NOT EXISTS (SELECT id FROM cadastre.spatial_unit WHERE label = 'Mulifanua');


-- Remove all data created for plan 11172
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart = '11172'
AND status_code = 'current'
AND   geom_polygon IS NOT NULL;
DELETE FROM cadastre.cadastre_object 
WHERE name_lastpart = '11172'
AND   geom_polygon IS NOT NULL
AND status_code = 'current';
DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '11172' AND status_code = 'completed'));
DELETE FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '11172' AND status_code = 'completed');
DELETE FROM application.application_property WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '11172' AND status_code = 'completed');
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr = '11172'
AND status_code = 'completed';
DELETE FROM application.application WHERE nr = '11172' AND status_code = 'completed';