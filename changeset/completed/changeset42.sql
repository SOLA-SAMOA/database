-- 11 June 2014 Ticket #154
UPDATE cadastre.spatial_value_area
SET size = 2629, change_user = 'andrew'
WHERE spatial_unit_id  IN (SELECT id FROM cadastre.cadastre_object 
                           WHERE name_firstpart = '3083'
                           AND   name_lastpart = '6652')
AND type_code = 'officialArea'; 


