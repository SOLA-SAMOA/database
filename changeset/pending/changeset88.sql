-- 18 Dec 2018
-- Remove 821/526 because it is a duplicate of 821/5256
UPDATE administrative.ba_unit 
SET change_user = 'andrew'
WHERE name = '821/526';

UPDATE administrative.ba_unit_area
SET change_user = 'andrew'
WHERE ba_unit_id IN (SELECT id 
                     FROM administrative.ba_unit 
					 WHERE name = '821/526');
					 
UPDATE administrative.rrr
SET change_user = 'andrew'
WHERE ba_unit_id IN (SELECT id 
                     FROM administrative.ba_unit 
					 WHERE name = '821/526');					 
					 
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE ba_unit_id IN (SELECT id 
                     FROM administrative.ba_unit 
					 WHERE name = '821/526');
					 

UPDATE administrative.required_relationship_baunit
SET change_user = 'andrew'
WHERE to_ba_unit_id IN (SELECT id 
                     FROM administrative.ba_unit 
					 WHERE name = '821/526');

UPDATE application.application_property
SET change_user = 'andrew'
WHERE ba_unit_id IN (SELECT id 
                     FROM administrative.ba_unit 
					 WHERE name = '821/526'); 					 
	
DELETE FROM application.application_property 
WHERE ba_unit_id IN (SELECT id 
                     FROM administrative.ba_unit 
					 WHERE name = '821/526');
					 
DELETE FROM administrative.ba_unit WHERE name = '821/526';					 