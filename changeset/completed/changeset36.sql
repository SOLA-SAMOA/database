-- 9 Apr 2014 Ticket #143
-- Update Plan numbers
UPDATE cadastre.cadastre_object co
SET name_lastpart = '3866',
    change_user = 'andrew'
WHERE  co.name_firstpart = 'PT 197'
AND    co.name_lastpart = '3886';

UPDATE cadastre.cadastre_object co
SET  name_firstpart = 'PT 98',
     name_lastpart = '2448L',
    change_user = 'andrew'
WHERE  co.name_firstpart = '465'
AND    co.name_lastpart = '5560';