-- 5 Oct 2013
-- Ticket #111 - remove the block number from the name_fristpart to leave the lot number only. 
UPDATE system.br_definition SET "body" = 'SELECT CASE WHEN CAST(#{cadastreObjectId} AS VARCHAR(40)) IS NOT NULL
	THEN (SELECT (CASE WHEN co.type_code = ''parcel'' THEN regexp_replace(co.name_firstpart, ''\D*|/.*'',  '''', ''g'') ELSE co.name_firstpart END) 
	        || ''/'' || regexp_replace(co.name_lastpart, ''[\s|L|l]$'',  '''') FROM cadastre.cadastre_object co WHERE id = #{cadastreObjectId})
	ELSE (SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
			|| ''/200000'') END AS vl'
WHERE br_id = 'generate-baunit-nr';

-- Fix the number on the ba units noted by Tua
UPDATE administrative.ba_unit
SET    name_lastpart = '1843',
       name = '367/1843',
       change_user = 'andrew'
WHERE  name_firstpart = '367'
AND    name_lastpart = '64';

UPDATE administrative.ba_unit
SET    name_lastpart = '1688',
       name = '313/1688',
       change_user = 'andrew'
WHERE  name_firstpart = '313'
AND    name_lastpart = '64';

-- Ticket #112 Area updates requested by Tufi
UPDATE cadastre.spatial_value_area
SET size = 1109, 
    change_user = 'andrew'
WHERE type_code = 'officialArea'
AND   spatial_unit_id IN 
 (SELECT id from cadastre.cadastre_object
  WHERE name_lastpart = '7007'
  AND name_firstpart = '6062');
  
UPDATE administrative.ba_unit_area
SET size = 1109,
    change_user = 'andrew'
WHERE type_code = 'officialArea'
AND   ba_unit_id IN 
 (SELECT id from administrative.ba_unit
  WHERE name_lastpart = '7007'
  AND name_firstpart = '6062');




