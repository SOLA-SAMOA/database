-- 18 Nov 2015
-- #180 - Merge Lots 3026/6311 and 3026/6772

-- 3026/6772 appears to have been created in error
-- within the DCDB. Make that lot historic and merge
-- the shape with 3026/6311 to create the correct lot.
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew',
    status_code = 'historic'
WHERE name_lastpart IN ('6772')
AND   name_firstpart IN ('3026');

UPDATE cadastre.cadastre_object 
SET change_user = 'andrew',
    geom_polygon = (SELECT st_union(geom_polygon) 
	                FROM cadastre.cadastre_object  
					WHERE id IN ( '7900a59e-33c6-11e2-b1d6-e36bc3c02b54' , '78f819f6-33c6-11e2-8ef0-cfd289905079'))
WHERE name_lastpart IN ('6311')
AND   name_firstpart IN ('3026');
