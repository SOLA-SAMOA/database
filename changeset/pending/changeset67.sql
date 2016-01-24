-- 24 Jan 2016
-- #181 Add Namu'a Village
INSERT INTO administrative.ba_unit (id, type_code, name, name_firstpart, name_lastpart, status_code, change_user)
VALUES ('LOC502', 'administrativeUnit', 'Namu''a/Village', 'Namu''a', 'Village', 'current', 'andrew');



-- #181 - Change the lot number for parcel LOT 976 PLAN 7070 to LOT 967

-- A Non spatial parcel was created for title 967/7070 which 
-- is preventing the Change Parcel Attributes tool from working
-- successfully.
 
-- Set the change user on the cadastre_objects to be deleted.
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart IN ('7070')
AND   name_firstpart IN ('967');

-- Set the change user on the ba unit links to be deleted
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE spatial_unit_id IN 
  (SELECT id FROM cadastre.cadastre_object 
   WHERE name_lastpart IN ('7070')
   AND   name_firstpart IN ('967'));
   
-- Remove the ba_unit links  
DELETE FROM administrative.ba_unit_contains_spatial_unit
WHERE spatial_unit_id IN 
  (SELECT id FROM cadastre.cadastre_object 
   WHERE name_lastpart IN ('7070')
   AND   name_firstpart IN ('967'));
   
-- Remove the spatial units - cadastre objects deleted via trigger. 
DELETE FROM cadastre.spatial_unit 
WHERE id IN ( SELECT id FROM cadastre.cadastre_object 
              WHERE name_lastpart IN ('7070')
              AND   name_firstpart IN ('967'));

			  
-- Reinstate the original DCDB parcel and link it to the title			  
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew',
    name_firstpart = '967'
WHERE name_lastpart IN ('7070')
AND   name_firstpart IN ('976');	

INSERT INTO administrative.ba_unit_contains_spatial_unit 
 (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM administrative.ba_unit ba,
     cadastre.cadastre_object co
WHERE ba.name_firstpart = '967'
AND   ba.name_lastpart = '7070'
AND   co.name_firstpart = ba.name_firstpart
AND   co.name_lastpart = ba.name_lastpart;  

