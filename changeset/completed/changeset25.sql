-- 2 Dec 2013 Ticket #118
-- Update plan numbers for lots on plan 6322
	UPDATE cadastre.cadastre_object 
	SET name_lastpart = '6457',
		change_user = 'andrew'
	WHERE name_firstpart IN ('157', '158', '159')
	AND name_lastpart = '6322';
	

-- Update plan number for lot 148/6322. Need to remove LRS parcel first. 	
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE ba_unit_id = 'F4FCF3CD-8C9F-4F5A-8A76-90B07BB192A3';

DELETE FROM administrative.ba_unit_contains_spatial_unit
WHERE ba_unit_id = 'F4FCF3CD-8C9F-4F5A-8A76-90B07BB192A3';

UPDATE cadastre.cadastre_object
SET change_user = 'andrew'
WHERE id = 'F4FCF3CD-8C9F-4F5A-8A76-90B07BB192A3';

DELETE FROM cadastre.cadastre_object
WHERE id = 'E01EE8A7-B543-4C5B-BAB3-AB5768505A42' -- LRS parcel for 148/6279
AND source_reference = 'LRS';

UPDATE cadastre.cadastre_object 
SET name_lastpart = '6279',
    change_user = 'andrew'
WHERE name_firstpart IN ('148')
AND name_lastpart = '6322'
AND source_reference = 'DCDB';

INSERT INTO administrative.ba_unit_contains_spatial_unit
(ba_unit_id, spatial_unit_id, change_user) VALUES
('F4FCF3CD-8C9F-4F5A-8A76-90B07BB192A3', '7d82e33e-33c6-11e2-984c-03bf5ca2db6a', 'andrew');