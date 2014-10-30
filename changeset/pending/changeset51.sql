-- 30 Oct 2014
-- #165 Reinstate property V6/48
UPDATE administrative.ba_unit
SET    status_code = 'current',
       change_user = 'andrew'
WHERE  name_firstpart = 'V6'
AND    name_lastpart = '48';

