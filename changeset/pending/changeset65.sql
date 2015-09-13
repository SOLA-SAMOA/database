-- 14 September 2015
-- #179 - Change the name of parcel LOT 45801 PLAN 5894 to 4580

-- A Non spatial parcel was created for title 4580/5894 which 
-- is preventing the Change Parcel Attributes tool from working
-- successfully.
 
-- Set the change user on the cadastre_objects to be deleted. N
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart IN ('5894')
AND   name_firstpart IN ('4580');

-- Set the change user on the ba unit links to be deleted
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE spatial_unit_id IN 
  (SELECT id FROM cadastre.cadastre_object 
   WHERE name_lastpart IN ('5894')
   AND   name_firstpart IN ('4580'));
   
-- Remove the ba_unit links  
DELETE FROM administrative.ba_unit_contains_spatial_unit
WHERE spatial_unit_id IN 
  (SELECT id FROM cadastre.cadastre_object 
   WHERE name_lastpart IN ('5894')
   AND   name_firstpart IN ('4580'));
   
-- Remove the spatial units - cadastre objects deleted via trigger. 
DELETE FROM cadastre.spatial_unit 
WHERE id IN ( SELECT id FROM cadastre.cadastre_object 
              WHERE name_lastpart IN ('5894')
              AND   name_firstpart IN ('4580')
			  AND   source_reference = '5894');

			  
-- Reinstate the original DCDB parcel and link it to the title			  
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew',
    name_firstpart = '4580'
WHERE name_lastpart IN ('5894')
AND   name_firstpart IN ('45801');	

INSERT INTO administrative.ba_unit_contains_spatial_unit 
 (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM adminisrative.ba_unit ba,
     cadastre.cadastre_object co
WHERE ba.name_firstpart = '4580'
AND   ba.name_lastpart = '5894'
AND   co.name_firstpart = ba.name_firstpart
AND   co.name_lastpart = ba.name_lastpart; 
	  

