-- 14 July 2019
-- Fix the parcels linked to 53/10537. First remove 'Plan' from the name_lastpart
UPDATE administrative.ba_unit
SET name_lastpart = '10537',
    change_user = 'andrew'
WHERE name = '53/10537';

-- Get the current parcel link record(s) ready for deletion 
UPDATE administrative.ba_unit_contains_spatial_unit
SET  change_user = 'andrew'
FROM administrative.ba_unit ba
WHERE ba.name = '53/10537'
AND   administrative.ba_unit_contains_spatial_unit.ba_unit_id = ba.id;

-- Delete any linking records
DELETE FROM administrative.ba_unit_contains_spatial_unit
USING administrative.ba_unit ba
WHERE ba.name = '53/10537'
AND   administrative.ba_unit_contains_spatial_unit.ba_unit_id = ba.id;

-- Link 53/10537 to the appropriate parcel
INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
SELECT ba.id, co.id, 'andrew'
FROM administrative.ba_unit ba, 
     cadastre.cadastre_object co
WHERE ba.name = '53/10537'
AND   co.name_firstpart = 'LOT 53'
AND   co.name_lastpart = '10537(2)'
AND   co.type_code = 'parcel';

-- Fix other ba_units that have Plan in the name_lastpart
UPDATE administrative.ba_unit
SET name_lastpart = '1781',
    name = '188/1781', 
    change_user = 'andrew'
WHERE name = '188/Plan 1781';

UPDATE administrative.ba_unit
SET name_lastpart = '11214',
    name = '2/11214', 
    change_user = 'andrew'
WHERE name = '2/Plan 11214';

UPDATE administrative.ba_unit
SET name_lastpart = '11214', 
    change_user = 'andrew'
WHERE name = '4/11214';

UPDATE administrative.ba_unit
SET name_lastpart = '11213', 
    change_user = 'andrew'
WHERE name = '2/11213';
