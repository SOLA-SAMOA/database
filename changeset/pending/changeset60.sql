-- 17 July 2015
-- #175 Reinstate 55 PLAN 2212 and remove LOT 2 2212
UPDATE cadastre.cadastre_object 
SET geom_polygon = (SELECT geom_polygon FROM cadastre.cadastre_object
                    WHERE name_firstpart = 'LOT 2'
                    AND   name_lastpart = '2212'),
    status_code = 'current',
    change_user = 'andrew'
WHERE name_firstpart = '55'
AND   name_lastpart = '2212'
AND   status_code = 'historic'; 

UPDATE cadastre.cadastre_object 
SET    change_user = 'andrew',
       change_action = 'd'
WHERE name_firstpart = 'LOT 2'
AND   name_lastpart = '2212'
AND   status_code = 'current'; 

DELETE FROM cadastre.cadastre_object 
WHERE name_firstpart = 'LOT 2'
AND   name_lastpart = '2212'
AND   status_code = 'current'; 

