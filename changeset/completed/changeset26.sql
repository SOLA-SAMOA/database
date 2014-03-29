-- 13 Dec 2013 Ticket #119
-- Update plan number for lots 1111 to 1121 from 6476 to 6378. Need to remove LRS parcel first. 	
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE ba_unit_id IN (SELECT id FROM administrative.ba_unit WHERE name_lastpart = '6378')
AND   spatial_unit_id IN (SELECT id FROM cadastre.cadastre_object 
                          WHERE name_lastpart = '6378'
                          AND source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit
WHERE ba_unit_id IN (SELECT id FROM administrative.ba_unit WHERE name_lastpart = '6378')
AND   spatial_unit_id IN (SELECT id FROM cadastre.cadastre_object 
                          WHERE name_lastpart = '6378'
                          AND source_reference = 'LRS');

UPDATE cadastre.cadastre_object
SET change_user = 'andrew'
WHERE name_lastpart = '6378'
AND source_reference = 'LRS';

DELETE FROM cadastre.cadastre_object
WHERE name_lastpart = '6378'
AND source_reference = 'LRS';

UPDATE cadastre.cadastre_object 
SET name_lastpart = '6378',
    change_user = 'andrew'
WHERE name_firstpart IN ('1111', '1112', '1113', '1114', '1115', '1116',
  '1117', '1118', '1119', '1120', '1121')
AND name_lastpart = '6476'
AND source_reference = 'DCDB';

INSERT INTO administrative.ba_unit_contains_spatial_unit
(ba_unit_id, spatial_unit_id, change_user) 
SELECT b.id, co.id, 'andrew'
FROM administrative.ba_unit b,
     cadastre.cadastre_object co
WHERE b.name_lastpart = '6378'
AND   co.name_lastpart = b.name_lastpart
AND   co.name_firstpart = b.name_firstpart
AND   co.source_reference = 'DCDB';


-- Update plan number for lots 1122 and 1123 from 6476 to 6379. Need to remove LRS parcels first. 	
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE ba_unit_id IN (SELECT id FROM administrative.ba_unit 
                     WHERE name_lastpart = '6379'
					 AND name_firstpart IN ('1122', '1123'))
AND   spatial_unit_id IN (SELECT id FROM cadastre.cadastre_object 
                          WHERE name_lastpart = '6379'
						  AND name_firstpart IN ('1122', '1123')
                          AND source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit
WHERE ba_unit_id IN (SELECT id FROM administrative.ba_unit 
                     WHERE name_lastpart = '6379'
					 AND name_firstpart IN ('1122', '1123'))
AND   spatial_unit_id IN (SELECT id FROM cadastre.cadastre_object 
                          WHERE name_lastpart = '6379'
						  AND name_firstpart IN ('1122', '1123')
                          AND source_reference = 'LRS');

UPDATE cadastre.cadastre_object
SET change_user = 'andrew'
WHERE name_lastpart = '6379'
AND name_firstpart IN ('1122', '1123') 
AND source_reference = 'LRS';

DELETE FROM cadastre.cadastre_object
WHERE name_lastpart = '6379'
AND name_firstpart IN ('1122', '1123')
AND source_reference = 'LRS';

UPDATE cadastre.cadastre_object 
SET name_lastpart = '6379',
    change_user = 'andrew'
WHERE name_firstpart IN ('1122', '1123')
AND name_lastpart = '6476'
AND source_reference = 'DCDB';

INSERT INTO administrative.ba_unit_contains_spatial_unit
(ba_unit_id, spatial_unit_id, change_user) 
SELECT b.id, co.id, 'andrew'
FROM administrative.ba_unit b,
     cadastre.cadastre_object co
WHERE b.name_lastpart = '6379'
AND   b.name_firstpart IN ('1122', '1123')
AND   co.name_lastpart = b.name_lastpart
AND   co.name_firstpart = b.name_firstpart
AND   co.source_reference = 'DCDB';

-- Update plan number for lots 1129 to 1138 from 6476 to 6380. Need to remove LRS parcel first. 	
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE ba_unit_id IN (SELECT id FROM administrative.ba_unit WHERE name_lastpart = '6380')
AND   spatial_unit_id IN (SELECT id FROM cadastre.cadastre_object 
                          WHERE name_lastpart = '6380'
                          AND source_reference = 'LRS');

DELETE FROM administrative.ba_unit_contains_spatial_unit
WHERE ba_unit_id IN (SELECT id FROM administrative.ba_unit WHERE name_lastpart = '6380')
AND   spatial_unit_id IN (SELECT id FROM cadastre.cadastre_object 
                          WHERE name_lastpart = '6380'
                          AND source_reference = 'LRS');

UPDATE cadastre.cadastre_object
SET change_user = 'andrew'
WHERE name_lastpart = '6380'
AND source_reference = 'LRS';

DELETE FROM cadastre.cadastre_object
WHERE name_lastpart = '6380'
AND source_reference = 'LRS';

UPDATE cadastre.cadastre_object 
SET name_lastpart = '6380',
    change_user = 'andrew'
WHERE name_firstpart IN ('1129', '1130', '1131', '1132', '1133', '1134',
  '1135', '1136', '1137', '1138')
AND name_lastpart = '6476'
AND source_reference = 'DCDB';

INSERT INTO administrative.ba_unit_contains_spatial_unit
(ba_unit_id, spatial_unit_id, change_user) 
SELECT b.id, co.id, 'andrew'
FROM administrative.ba_unit b,
     cadastre.cadastre_object co
WHERE b.name_lastpart = '6380'
AND   co.name_lastpart = b.name_lastpart
AND   co.name_firstpart = b.name_firstpart
AND   co.source_reference = 'DCDB';
