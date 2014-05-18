-- 2 May 2014 Ticket #147

-- Change plan number of 1011/272 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_firstpart = '840'
AND   name_lastpart = '4720'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '840'
AND    co.name_lastpart = '4720'
AND    co.source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '840'
AND    co.name_lastpart = '4720'
AND    co.source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object co
WHERE  co.name_firstpart = '840'
AND    co.name_lastpart = '4720'
AND    co.source_reference = 'LRS';

UPDATE cadastre.cadastre_object co
SET name_firstpart = '840',
    change_user = 'andrew'
WHERE  co.name_firstpart = '240'
AND    co.name_lastpart = '4720';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '840'
AND    ba.name_lastpart = '4720'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;
