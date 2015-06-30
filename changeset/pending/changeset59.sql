-- 1 July 2015
-- #174 Reinstate property 1/10011
UPDATE administrative.ba_unit
SET    status_code = 'current',
       change_user = 'andrew'
WHERE  name_firstpart = '1'
AND    name_lastpart = '10011';

