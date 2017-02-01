-- 11 Jan 2017
-- Update the invalid area of a folio to the correct value
UPDATE administrative.ba_unit_area
SET  size = 3986,
     change_user = 'andrew'
WHERE ba_unit_id = (SELECT ba.id
                    FROM administrative.ba_unit  ba
					WHERE ba.name_firstpart = '2'
					AND   ba.name_lastpart = '10501')
AND  type_code = 'officialArea';