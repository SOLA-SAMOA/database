-- ***  4341L plan number updates


UPDATE system.br_definition SET "body" = 'SELECT CASE WHEN CAST(#{cadastreObjectId} AS VARCHAR(40)) IS NOT NULL
	THEN (SELECT (CASE WHEN co.type_code = ''parcel'' THEN regexp_replace(co.name_firstpart, ''\D*'',  '''') ELSE co.name_firstpart END) 
	        || ''/'' || regexp_replace(co.name_lastpart, ''[\s|L|l]$'',  '''') FROM cadastre.cadastre_object co WHERE id = #{cadastreObjectId})
	ELSE (SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
			|| ''/200000'') END AS vl'
WHERE br_id = 'generate-baunit-nr'; 


-- Refinements to Business Rules (for use in MNRE) 

UPDATE system.br_definition SET active_until = '2013-01-31' WHERE br_id = 'application-verifies-identification';
UPDATE system.br_definition SET active_until = '2013-01-31' WHERE br_id = 'service-has-person-verification';

-- Function: cadastre.cadastre_object_name_is_valid(character varying, character varying)

DROP FUNCTION cadastre.cadastre_object_name_is_valid(character varying, character varying);

CREATE OR REPLACE FUNCTION cadastre.cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying)
  RETURNS boolean AS
$BODY$
begin
  IF name_firstpart is null THEN RETURN false; END IF;
  IF name_lastpart is null THEN RETURN false; END IF;
  IF NOT ((name_firstpart SIMILAR TO 'Lot [0-9]+') OR (name_firstpart SIMILAR TO '[0-9]+')) THEN RETURN false;  END IF;
  IF NOT ((name_lastpart SIMILAR TO '[0-9 ]+') OR (name_lastpart SIMILAR TO 'CUSTOMARY LAND') OR (name_lastpart SIMILAR TO 'CTGT [0-9]+') OR (name_lastpart SIMILAR TO 'LC [0-9]+')) THEN RETURN false;  END IF;
  RETURN true;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.cadastre_object_name_is_valid(character varying, character varying)
  OWNER TO postgres;