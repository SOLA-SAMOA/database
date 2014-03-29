-- 26 Mar 2014 Ticket #135

-- Create areas for lots 1111 to 1121 on plan 6378
INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1013, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1111';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1012, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1112';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1013, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1113';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1134, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1114';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1137, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1115';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1137, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1116';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1127, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1117';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1113, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1118';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1076, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1119';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1087, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1120';

INSERT INTO cadastre.spatial_value_area (spatial_unit_id, type_code, size, change_user)
SELECT id, 'officialArea', 1012, 'andrew'
FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND name_firstpart = '1121';

-- Update Plan Numbers
UPDATE cadastre.cadastre_object
SET name_lastpart = '2628',
    change_user = 'andrew'
WHERE name_lastpart = '1863'
AND   name_firstpart = '12';

-- Change plan number of 1245/3438 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_lastpart = '4546'
AND   name_firstpart = '1245'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1245'
AND    co.name_lastpart = '4546'
AND    source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '1245'
AND    co.name_lastpart = '4546'
AND    source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object
WHERE name_lastpart = '4546'
AND   name_firstpart = '1245'
AND   source_reference = 'LRS';

UPDATE cadastre.cadastre_object
SET name_lastpart = '4546',
    change_user = 'andrew'
WHERE name_lastpart = '3438'
AND   name_firstpart = '1245';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '1245'
AND    ba.name_lastpart = '4546'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;

-- Change plan number of 5637/6568 by
-- removing existing LRS parcel first
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew'
WHERE name_lastpart = '6619'
AND   name_firstpart = '5637'
AND   source_reference = 'LRS';

UPDATE administrative.ba_unit_contains_spatial_unit 
SET change_user = 'andrew'
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '5637'
AND    co.name_lastpart = '6619'
AND    source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit 
WHERE spatial_unit_id IN (
SELECT co.id
FROM   cadastre.cadastre_object co
WHERE  co.name_firstpart = '5637'
AND    co.name_lastpart = '6619'
AND    source_reference = 'LRS');

DELETE FROM cadastre.cadastre_object
WHERE name_lastpart = '6619'
AND   name_firstpart = '5637'
AND   source_reference = 'LRS';

UPDATE cadastre.cadastre_object
SET name_lastpart = '6619',
    change_user = 'andrew'
WHERE name_lastpart = '6568'
AND   name_firstpart = '5637';

INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM   administrative.ba_unit ba,
       cadastre.cadastre_object co
WHERE  ba.name_firstpart = '5637'
AND    ba.name_lastpart = '6619'
AND    co.name_firstpart = ba.name_firstpart
AND    co.name_lastpart = ba.name_lastpart;

-- Remove unnecessary Survey Plan Number from map
DELETE FROM cadastre.spatial_unit
WHERE id = '758ca796-33c6-11e2-8063-4719499d4c94'
AND label LIKE '2260L%';



