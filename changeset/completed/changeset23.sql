-- 30 Oct 2013 Ticket #114

-- 1) Fix Lot number on parcel LOT 5 PLAN 11119
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew', 
    name_firstpart = 'LOT 8'
WHERE name_lastpart = '11119'
AND   name_firstpart = 'LOT 5';

-- 2) Remove "SHEET 2" text from parcels on PLAN 10465
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew', 
    name_lastpart = '10465'
WHERE name_lastpart = '10465 SHEET 2';

-- 3) Remove all parcels for PLAN 10465 SHEET 1 from the map by making them historic
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew', 
    status_code = 'historic'
WHERE name_lastpart = '10465 SHEET 1';

-- 4) Correct areas for LOT 1 and LOT 2 on PLAN 11101 
UPDATE cadastre.spatial_value_area
SET change_user = 'andrew',
    size = 204598
WHERE type_code = 'officialArea'
AND   spatial_unit_id IN 
 (SELECT id from cadastre.cadastre_object
  WHERE name_lastpart = '11101'
  AND name_firstpart = 'LOT 1');
  
UPDATE cadastre.spatial_value_area
SET change_user = 'andrew',
    size = 204598
WHERE type_code = 'officialArea'
AND   spatial_unit_id IN 
 (SELECT id from cadastre.cadastre_object
  WHERE name_lastpart = '11101'
  AND name_firstpart = 'LOT 2');
  
-- 5) Change the plan number for LOT 1828 PLAN 1452 to PLAN 5338 by updating the existing
--    LRS parcel with the geom from LOT 1828 PLAN 1452 and making the DCDB parcel historic
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew', 
    geom_polygon = (SELECT geom_polygon FROM cadastre.cadastre_object
	                WHERE name_firstpart = '1828' AND name_lastpart = '1452')
WHERE name_lastpart = '5338'
AND   name_firstpart = '1828';

UPDATE cadastre.cadastre_object 
SET change_user = 'andrew', 
    status_code = 'historic'
WHERE name_lastpart = '1452'
AND   name_firstpart = '1828';

-- 6) Change the plan number for LOT 1826 PLAN 1330L to PLAN 5338 by updating the existing
--    LRS parcel with the geom from LOT 1826 PLAN 1330L and making the DCDB parcel historic
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew', 
    geom_polygon = (SELECT geom_polygon FROM cadastre.cadastre_object
	                WHERE name_firstpart = '1826' AND name_lastpart = '1330L')
WHERE name_lastpart = '5338'
AND   name_firstpart = '1826';

UPDATE cadastre.cadastre_object 
SET change_user = 'andrew', 
    status_code = 'historic'
WHERE name_lastpart = '1330L'
AND   name_firstpart = '1826';

-- 7) Remove plan number from 85 PLAN 5835 and TUVAO PLAN 5835. Both of these parcels are 
--    from Customary Land and should be named 85 and TUVAO with no plan number
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew', 
    name_lastpart = ''
WHERE name_lastpart = '5835'
AND name_firstpart IN ('85', 'TUVAO');