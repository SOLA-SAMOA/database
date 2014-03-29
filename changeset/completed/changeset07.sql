
-- Fix up the plan number for 6252 and link it to the appropriate
-- property records. 
UPDATE cadastre.spatial_unit 
SET level_id = ((SELECT id FROM cadastre.level WHERE name = 'Parcels'))
WHERE label IN ( '125/6252', '126/6252', '127/6252');

UPDATE cadastre.spatial_unit 
SET level_id = NULL
WHERE label IN ( '125/6522', '126/6522', '127/6522');

UPDATE cadastre.cadastre_object
SET geom_polygon = ((SELECT co.geom_polygon 
                    FROM cadastre.cadastre_object co 
                    WHERE co.name_firstpart = cadastre.cadastre_object.name_firstpart 
                    AND co.name_lastpart = '6522'))
WHERE name_lastpart = '6252';

UPDATE cadastre.cadastre_object
SET geom_polygon = NULL,
    status_code = 'historic',
	source_reference = 'DCDB > Invalid plan number - geom merged to ' || name_firstpart || '\6252'  
WHERE name_lastpart = '6522';


CREATE OR REPLACE FUNCTION cadastre.formatareaimperial(area numeric)
  RETURNS character varying AS
$BODY$
   DECLARE perches NUMERIC(29,12); 
   DECLARE roods   NUMERIC(29,12); 
   DECLARE acres   NUMERIC(29,12);
   DECLARE remainder NUMERIC(29,12);
   DECLARE result  CHARACTER VARYING(40) := ''; 
   BEGIN
	IF area IS NULL THEN RETURN NULL; END IF; 
	acres := (area/4046.8564); -- 1a = 4046.8564m2     
	remainder := acres - trunc(acres,0);  
	roods := (remainder * 4); -- 4 roods to an acre
	remainder := roods - trunc(roods,0);
	perches := (remainder * 40); -- 40 perches to a rood
	IF acres >= 1 THEN
	  result := trim(to_char(trunc(acres,0), '9,999,999a')); 
	END IF; 
	-- Allow for the rounding introduced by to_char by manually incrementing
	-- the roods if perches are >= 39.95
	IF perches >= 39.95 THEN
	   roods := roods + 1;
	   perches = 0; 
	END IF; 
	IF acres >= 1 OR roods >= 1 THEN
	  result := result || ' ' || trim(to_char(trunc(roods,0), '99r'));
	END IF; 
	  result := result || ' ' || trim(to_char(perches, '00.0p'));
	RETURN '('  || trim(result) || ')';  
    END; 
    $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION cadastre.formatareaimperial(numeric)
  OWNER TO postgres;
COMMENT ON FUNCTION cadastre.formatareaimperial(numeric) IS 'Formats a metric area to an imperial area measurement consisting of arces, roods and perches';
