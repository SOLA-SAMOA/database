-- 14 July 2014 Ticket #156

-- Reinstate the parcel that was given a null name
UPDATE cadastre.cadastre_object SET 
   name_firstpart = '58',
   name_lastpart = '1770',
   change_user = 'andrew'
WHERE id = '79880002-33c6-11e2-beef-23337c8200f8';

-- Fix the formatparcellabel function so that is does not prevent the map from drawing if the name-firstpart and
-- name-lastpart have been cleared. 
CREATE OR REPLACE FUNCTION cadastre.formatparcelnrlabel(first_part character varying, last_part character varying)
  RETURNS character varying AS
$BODY$
  BEGIN
    -- Fix for Ticket #156
    IF TRIM (first_part) = '' OR TRIM(last_part) = '' THEN
       RETURN first_part || last_part; 
    END IF;  
    RETURN first_part || chr(10) || last_part; 
  END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.formatparcelnrlabel(character varying, character varying)
  OWNER TO postgres;
COMMENT ON FUNCTION cadastre.formatparcelnrlabel(character varying, character varying) IS 'Formats the number/appellation for the parcel over 2 lines';


CREATE OR REPLACE FUNCTION cadastre.change_parcel_name(parcel_id character varying, part1 character varying, part2 character varying, user_name character varying)
  RETURNS void AS
$BODY$  
BEGIN

    -- Ticket #156 - Don't let the user set the name to ''
    IF parcel_id IS NULL OR TRIM(part1 || part2) = '' THEN
	   RETURN; 
	END IF;

    -- First remove the LRS parcel of the same name if one exists. 
	UPDATE cadastre.cadastre_object
	SET   change_user = user_name
	WHERE name_firstpart = part1
	AND   name_lastpart =  part2
	AND   source_reference = 'LRS';

	UPDATE administrative.ba_unit_contains_spatial_unit 
	SET change_user = user_name
	WHERE spatial_unit_id IN (
	   SELECT co.id
	   FROM   cadastre.cadastre_object co
	   WHERE name_firstpart = part1
	   AND   name_lastpart =  part2
	   AND   source_reference = 'LRS')
	OR spatial_unit_id = parcel_id;

	-- Disassociation the LRS parcel as well as the parcel that
	-- will get the name change from any BA Units. 
	DELETE FROM administrative.ba_unit_contains_spatial_unit 
	WHERE spatial_unit_id IN (
	   SELECT co.id
	   FROM   cadastre.cadastre_object co
	   WHERE name_firstpart = part1
	   AND   name_lastpart =  part2
	   AND   source_reference = 'LRS')
	OR spatial_unit_id = parcel_id;

	DELETE FROM cadastre.cadastre_object co
	WHERE  co.name_firstpart = part1
	AND    co.name_lastpart = part2
	AND    co.source_reference = 'LRS';

	-- Change the name of the parcel and link it to the ba_unit if a ba_unit
	-- exists with a matching name. 
	UPDATE cadastre.cadastre_object co
	SET    name_firstpart = part1,
	       name_lastpart = part2,
		   change_user = user_name
	WHERE  co.id = parcel_id;

	INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
	SELECT ba.id, co.id, user_name
	FROM   administrative.ba_unit ba,
		   cadastre.cadastre_object co
	WHERE  ba.name_firstpart = regexp_replace(part1, '\D', '', 'g') -- Remove the LOT part from the name
	AND    ba.name_lastpart = part2
	AND    co.name_firstpart = ba.name_firstpart
	AND    co.name_lastpart = ba.name_lastpart;
   
END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.change_parcel_name(character varying, character varying, character varying, character varying)
  OWNER TO postgres;
COMMENT ON FUNCTION cadastre.change_parcel_name(character varying, character varying, character varying, character varying) IS 'Procedure to correct the name of a cadastre object that was incorrectly recorded in DCDB. During the LRS migration, non spatial LRS parcels were created. The procedure will remove any LRS parcel matching the new name as well as link the parcel to the BA Unit matching the new name.';



