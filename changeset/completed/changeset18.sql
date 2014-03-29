-- 8 July 2013
-- Fix the area for the parcel Lot 1 and 2, PLAN 10547
UPDATE cadastre.spatial_value_area
SET size = 6772
WHERE spatial_unit_id IN 
 (SELECT id from cadastre.cadastre_object
  WHERE name_lastpart = '10547'
  AND name_firstpart = 'LOT 1');
  
UPDATE cadastre.spatial_value_area
SET size = 1037
WHERE spatial_unit_id IN 
 (SELECT id from cadastre.cadastre_object
  WHERE name_lastpart = '10547'
  AND name_firstpart = 'LOT 2');
  
  
-- Remove cadastre objects that have been created in error
DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 3'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 5'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 7'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 8'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 9'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 10'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 11'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 12'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 13'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 14'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 19'
AND name_lastpart = '10135';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 1'
AND name_lastpart = '10463';

UPDATE cadastre.cadastre_object 
SET status_code = 'historic'
WHERE name_firstpart = 'LOT 2'
AND name_lastpart = '10463';

UPDATE cadastre.cadastre_object 
SET status_code = 'historic'
WHERE name_firstpart = 'PT 84'
AND name_lastpart = '2861L';