-- 2 Aug 2016

-- #187 Property fixes
-- Reinstate 3380/8266 and link it to its parcel
UPDATE administrative.ba_unit
SET status_code = 'current',
    change_user = 'andrew'
WHERE name = '3380/8266';

-- Link 3380/8266 to its parcel
INSERT INTO administrative.ba_unit_contains_spatial_unit 
 (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM administrative.ba_unit ba,
     cadastre.cadastre_object co
WHERE ba.name_firstpart = '3380'
AND   ba.name_lastpart = '8266'
AND   co.name_firstpart = ba.name_firstpart
AND   co.name_lastpart = ba.name_lastpart
AND NOT EXISTS (SELECT ba_unit_id FROM administrative.ba_unit_contains_spatial_unit bas
                WHERE  ba_unit_id = ba.id
                AND     spatial_unit_id = co.id);	




-- Change property reference 1024/6071 o 1024/6070
-- Set the change user on the LRS cadastre_objects to be deleted.
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_firstpart IN ('1024')
AND   name_lastpart IN ('6071')  
AND   source_reference = 'LRS';

-- Set the change user on the ba unit links to be deleted
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE spatial_unit_id IN 
  (SELECT id FROM cadastre.cadastre_object 
   WHERE name_firstpart IN ('1024')
   AND   name_lastpart IN ('6071')  
   AND   source_reference = 'LRS');
   
-- Remove the ba_unit links  
DELETE FROM administrative.ba_unit_contains_spatial_unit
WHERE spatial_unit_id IN 
  (SELECT id FROM cadastre.cadastre_object 
   WHERE name_firstpart IN ('1024')
   AND   name_lastpart IN ('6071')  
   AND   source_reference = 'LRS');
   
-- Remove the spatial units - cadastre objects deleted via trigger. 
DELETE FROM cadastre.spatial_unit 
WHERE id IN ( SELECT id FROM cadastre.cadastre_object 
		        WHERE name_firstpart IN ('1024')
		        AND   name_lastpart IN ('6071')  
		        AND   source_reference = 'LRS');

-- Change the property reference for 1024/6071 to 1024/6070
UPDATE administrative.ba_unit
SET name_lastpart = '6070', 
    name = '1024/6070',
    change_user = 'andrew'
WHERE name = '1024/6071';

-- Link 1024/6070 to its parcel
INSERT INTO administrative.ba_unit_contains_spatial_unit 
 (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM administrative.ba_unit ba,
     cadastre.cadastre_object co
WHERE ba.name_firstpart = '1024'
AND   ba.name_lastpart = '6070'
AND   co.name_firstpart = ba.name_firstpart
AND   co.name_lastpart = ba.name_lastpart
AND NOT EXISTS (SELECT ba_unit_id FROM administrative.ba_unit_contains_spatial_unit bas
                WHERE ba_unit_id = ba.id
                AND   spatial_unit_id = co.id);	
