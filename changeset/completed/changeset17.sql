-- 24 May 2012
-- Fix naming for lots on plan 11083. Add LOT to the first part of the name
UPDATE cadastre.cadastre_object
SET name_firstpart = ' ' || name_firstpart
WHERE name_lastpart = '11083'
AND status_code = 'historic';

UPDATE cadastre.cadastre_object
SET name_firstpart = 'LOT ' || TRIM(name_firstpart)
WHERE name_lastpart = '11083'
AND status_code = 'current';

-- Fix the area for the parcel 190/3776
UPDATE cadastre.spatial_value_area
SET size = 20235
WHERE spatial_unit_id IN 
 (SELECT id from cadastre.cadastre_object
  WHERE name_lastpart = '3776'
  AND name_firstpart = '190');

-- Fix the area for the ba unit 190/3776
UPDATE administrative.ba_unit_area
SET size = 20235
WHERE ba_unit_id IN 
 (SELECT id from administrative.ba_unit
  WHERE name_lastpart = '3776'
  AND name_firstpart = '190');
  
  -- Fix the area for the parcel 187/3732L
UPDATE cadastre.spatial_value_area
SET size = 202343
WHERE spatial_unit_id IN 
 (SELECT id from cadastre.cadastre_object
  WHERE name_lastpart = '3732L'
  AND name_firstpart = '187');
  
-- #101 Remove the fee for charges for the Cancel Miscellaneous Service. 
UPDATE application.request_type SET base_fee = 0 WHERE code = 'cancelMisc';