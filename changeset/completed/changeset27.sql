-- 9 Jan 2014 Ticket #120
-- Fix incorrect plan number. 
UPDATE administrative.ba_unit 
SET name_lastpart = '5871',
change_user = 'andrew'
WHERE name_lastpart = '5817'
AND name_firstpart = '416';

UPDATE cadastre.cadastre_object
SET status_code = 'current',
change_user = 'andrew'
WHERE name_firstpart = '416'
AND name_lastpart = '5871'
AND status_code = 'pending';


