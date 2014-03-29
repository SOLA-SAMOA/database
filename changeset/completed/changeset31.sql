-- 07 Mar 2014 Ticket #124

-- Swap the lot numbers
UPDATE cadastre.cadastre_object
SET name_firstpart = 'X',
    change_user = 'andrew'
WHERE name_lastpart = '10429'
AND   name_firstpart = 'LOT 1';

UPDATE cadastre.cadastre_object
SET name_firstpart = 'LOT 1',
    change_user = 'andrew'
WHERE name_lastpart = '10429'
AND   name_firstpart = 'LOT 2';

UPDATE cadastre.cadastre_object
SET name_firstpart = 'LOT 2',
    change_user = 'andrew'
WHERE name_lastpart = '10429'
AND   name_firstpart = 'X';

