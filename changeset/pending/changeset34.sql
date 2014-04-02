-- 1 Apr 2014 Ticket #141
-- Remove an unnecessary Survey Plan point
DELETE FROM cadastre.spatial_unit WHERE label LIKE '6378 %';

-- Update Plan Numbers
UPDATE cadastre.cadastre_object
SET name_lastpart = '2628',
    change_user = 'andrew'
WHERE name_lastpart = '1863'
AND   name_firstpart = '12';

-- Change plan number of 1011/272 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_firstpart = '1011'
AND   name_lastpart = '6670'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1011'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1011'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object co
WHERE  co.name_firstpart = '1011'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS';

UPDATE cadastre.cadastre_object co
SET name_lastpart = '6670',
    change_user = 'andrew'
WHERE  co.name_firstpart = '1011'
AND    co.name_lastpart = '272';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '1011'
AND    ba.name_lastpart = '6670'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;

-- Change plan number of 1012/2721 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_firstpart = '1012'
AND   name_lastpart = '6670'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1012'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1012'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object co
WHERE  co.name_firstpart = '1012'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS';

UPDATE cadastre.cadastre_object co
SET name_lastpart = '6670',
    change_user = 'andrew'
WHERE  co.name_firstpart = '1012'
AND    co.name_lastpart = '2721';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '1012'
AND    ba.name_lastpart = '6670'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;

-- Change plan number of 1013/2721 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_firstpart = '1013'
AND   name_lastpart = '6670'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1013'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1013'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object co
WHERE  co.name_firstpart = '1013'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS';

UPDATE cadastre.cadastre_object co
SET name_lastpart = '6670',
    change_user = 'andrew'
WHERE  co.name_firstpart = '1013'
AND    co.name_lastpart = '2721';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '1013'
AND    ba.name_lastpart = '6670'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;

-- Change plan number of 1014/2721 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_firstpart = '1014'
AND   name_lastpart = '6670'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1014'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1014'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object co
WHERE  co.name_firstpart = '1014'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS';

UPDATE cadastre.cadastre_object co
SET name_lastpart = '6670',
    change_user = 'andrew'
WHERE  co.name_firstpart = '1014'
AND    co.name_lastpart = '2721';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '1014'
AND    ba.name_lastpart = '6670'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;

-- Change plan number of 1015/CIRCUIT 11 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_firstpart = '1015'
AND   name_lastpart = '6670'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1015'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1015'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object co
WHERE  co.name_firstpart = '1015'
AND    co.name_lastpart = '6670'
AND    co.source_reference = 'LRS';

UPDATE cadastre.cadastre_object co
SET name_lastpart = '6670',
    change_user = 'andrew'
WHERE  co.name_firstpart = '1015'
AND    co.name_lastpart LIKE 'CIRCUIT 11%';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '1015'
AND    ba.name_lastpart = '6670'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;

-- Change plan number of 994/6360 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_firstpart = '994'
AND   name_lastpart = '6300'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '994'
AND    co.name_lastpart = '6300'
AND    co.source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '994'
AND    co.name_lastpart = '6300'
AND    co.source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object co
WHERE  co.name_firstpart = '994'
AND    co.name_lastpart = '6300'
AND    co.source_reference = 'LRS';

UPDATE cadastre.cadastre_object co
SET name_lastpart = '6300',
    change_user = 'andrew'
WHERE  co.name_firstpart = '994'
AND    co.name_lastpart = '6360';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '994'
AND    ba.name_lastpart = '6300'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;

-- Reset the parcel area for 994/6300
UPDATE cadastre.spatial_value_area
SET size = 2354	
WHERE spatial_unit_id IN (SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '994'
AND    co.name_lastpart = '6300');