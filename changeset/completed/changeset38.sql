-- 5 May 2014 Ticket #148

DROP FUNCTION IF EXISTS cadastre.change_parcel_name(IN parcel_id CHARACTER VARYING, IN part1 CHARACTER VARYING, 
                                                    IN part2 CHARACTER VARYING, IN user_name CHARACTER VARYING);

CREATE OR REPLACE FUNCTION cadastre.change_parcel_name(IN parcel_id CHARACTER VARYING, IN part1 CHARACTER VARYING, 
                                                       IN part2 CHARACTER VARYING, IN user_name CHARACTER VARYING)
  RETURNS VOID AS
$BODY$  
BEGIN

    IF parcel_id IS NULL THEN
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
LANGUAGE plpgsql VOLATILE;
COMMENT ON FUNCTION cadastre.change_parcel_name(CHARACTER VARYING, CHARACTER VARYING, CHARACTER VARYING, CHARACTER VARYING) IS 'Procedure to correct the name of a cadastre object that was incorrectly recorded in DCDB. During the LRS migration, non spatial LRS parcels were created. The procedure will remove any LRS parcel matching the new name as well as link the parcel to the BA Unit matching the new name.';


SELECT cadastre.change_parcel_name(
   (SELECT co.id FROM cadastre.cadastre_object co
    WHERE co.name_firstpart = '552'
    AND   co.name_lastpart = '1772'), '552', '5537', 'andrew');

SELECT cadastre.change_parcel_name(
   (SELECT co.id FROM cadastre.cadastre_object co
    WHERE co.name_firstpart = '553'
    AND   co.name_lastpart = '4862'), '553', '5537', 'andrew');

SELECT cadastre.change_parcel_name(
   (SELECT co.id FROM cadastre.cadastre_object co
    WHERE co.name_firstpart = '497'
    AND   co.name_lastpart = '2420'), '497', '4980', 'andrew');
	
SELECT cadastre.change_parcel_name(
   (SELECT co.id FROM cadastre.cadastre_object co
    WHERE co.name_firstpart = '516'
    AND   co.name_lastpart = '2420'), '516', '4980', 'andrew');
