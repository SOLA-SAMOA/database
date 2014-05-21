-- 22 May 2014 Ticket #152 
UPDATE cadastre.spatial_value_area
SET size = 20235, change_user = 'andrew'
WHERE spatial_unit_id  IN (SELECT id FROM cadastre.cadastre_object 
                           WHERE name_firstpart = 'LOT 3240'
                           AND   name_lastpart = '6535')
AND type_code = 'officialArea'; 


