-- 7 Aug 2013
-- Email request from Tufi to tidy up some parcel records. 
UPDATE cadastre.cadastre_object 
SET name_firstpart = 'LOT 7342',
    change_user = 'andrew'
WHERE name_firstpart = 'LOT 7324'
AND name_lastpart = '10555';

-- Remove cadastre objects that have been created in error.
-- Update the change user first so the person deleting the 
-- record is recorded. 
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_firstpart = '6565'
AND  name_lastpart = '7498';

DELETE from cadastre.cadastre_object 
WHERE name_firstpart = '6565'
AND  name_lastpart = '7498';


