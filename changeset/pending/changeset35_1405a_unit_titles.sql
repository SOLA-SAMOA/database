-- Update the Application NR allocation BR
UPDATE system.br_definition SET "body" = '
WITH unit_plan_nr AS 
  (SELECT split_part(app.nr, ''/'', 1) AS app_nr, (COUNT(ser.id) + 1) AS suffix
   FROM administrative.ba_unit_contains_spatial_unit bas,
        cadastre.spatial_unit_in_group sug,
        transaction.transaction trans, 
        application.service ser,
        application.application app
   WHERE bas.ba_unit_id = #{baUnitId}
   AND   sug.spatial_unit_id = bas.spatial_unit_id
   AND   trans.spatial_unit_group_id = sug.spatial_unit_group_id
   AND   ser.id = trans.from_service_id
   AND   ser.request_type_code = ''unitPlan''
   AND   #{requestTypeCode} = ser.request_type_code
   AND   app.id = ser.application_id
   GROUP BY app_nr)
SELECT CASE (SELECT cat.code FROM application.request_category_type cat, application.request_type req WHERE req.code = #{requestTypeCode} AND cat.code = req.request_category_code) 
	WHEN ''cadastralServices'' THEN
	     (SELECT CASE WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} IN (''cadastreChange'', ''planNoCoords'', ''unitPlan'') THEN
	                        trim(to_char(nextval(''application.survey_plan_nr_seq''), ''00000''))
					  WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} = ''redefineCadastre'' THEN
					        trim(to_char(nextval(''application.information_nr_seq''), ''000000''))
		              ELSE (SELECT app_nr || ''/'' || suffix FROM unit_plan_nr)  END)
	WHEN ''registrationServices'' THEN trim(to_char(nextval(''application.dealing_nr_seq''),''00000'')) 
	WHEN ''nonRegServices'' THEN trim(to_char(nextval(''application.non_register_nr_seq''),''00000'')) 
	ELSE trim(to_char(nextval(''application.information_nr_seq''), ''000000'')) END AS vl'
WHERE br_id = 'generate-application-nr'; 

-- RRRR Types
UPDATE administrative.rrr_group_type 
SET status = 'c',
	display_value = 'Responsibilities::::SAMOAN'
WHERE code = 'responsibilities';  

INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
SELECT 'unitEntitlement', 'rights', 'Unit Entitlement::::SAMOAN', FALSE, FALSE, FALSE, 'c', 'Indicates the unit entitlement the unit has in relation to the unit development.'
WHERE NOT EXISTS (SELECT code FROM administrative.rrr_type WHERE code = 'unitEntitlement');

INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
SELECT 'bodyCorpRules', 'responsibilities', 'Body Corporate Rules::::SAMOAN', FALSE, FALSE, FALSE, 'c', 'The body corporate rules for a unit development.'
WHERE NOT EXISTS (SELECT code FROM administrative.rrr_type WHERE code = 'bodyCorpRules');

INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
SELECT 'addressForService', 'responsibilities', 'Address for Service::::SAMOAN', FALSE, FALSE, FALSE, 'c', 'The body corporate address for service.'
WHERE NOT EXISTS (SELECT code FROM administrative.rrr_type WHERE code = 'addressForService');

INSERT INTO administrative.rrr_type(code, rrr_group_type_code, display_value, is_primary, share_check, party_required, status, description)
    VALUES ('commonProperty', 'system', 'Common Property', FALSE, FALSE, FALSE, 'x', 'System RRR type used by SOLA to represent the unit development body corporate responsibilities');

	
-- Document Types
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
SELECT 'unitPlan','Unit Plan::::SAMOAN','c','FALSE'
WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type WHERE code = 'unitPlan');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
SELECT 'bodyCorpRules','Body Corporate Rules::::SAMOAN','c','FALSE'
WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type WHERE code = 'bodyCorpRules');
INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
SELECT 'unitEntitlements','Schedule of Unit Entitlements::::SAMOAN','c','FALSE'
WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type WHERE code = 'unitEntitlements');

-- Services
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
SELECT 'unitPlan','cadastralServices','Record Unit Plan::::SAMOAN','c',30,23.00,0.00,11.50,1,NULL,NULL,NULL,'Unit Plan'
WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'unitPlan');
	
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
SELECT 'newUnitTitle','registrationServices','Create Unit Titles::::SAMOAN','c',5,0.00,0.00,0.00,1, 'New <estate type> unit title',NULL,NULL,'Create Unit Titles'
WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'newUnitTitle');

INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
SELECT 'varyCommonProperty','registrationServices','Change Common Property::::SAMOAN','c',5,100.00,0.00,0.00,1,NULL,NULL,NULL,'Vary Common Property'
WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'varyCommonProperty');
	
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
SELECT 'cancelUnitPlan','registrationServices','Cancel Unit Titles::::SAMOAN','c',5,100.00,0.00,0.00,1, NULL,NULL,'cancel','Unit Title Cancellation'
WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'cancelUnitPlan');

INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
SELECT 'changeBodyCorp','registrationServices','Change Body Corporate::::SAMOAN','c',5,100.00,0.00,0.00,1, 'Change Body Corporate Rules / Change Address for Service to <address>','commonProperty','vary','Variation to Body Corporate'
WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'changeBodyCorp');

-- Link document types to the request types
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
SELECT 'unitPlan','unitPlan'
WHERE NOT EXISTS (SELECT request_type_code FROM application.request_type_requires_source_type 
                  WHERE  request_type_code = 'unitPlan'
				  AND    source_type_code =  'unitPlan');
				  
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
SELECT 'newUnitTitle','unitPlan'
WHERE NOT EXISTS (SELECT request_type_code FROM application.request_type_requires_source_type 
                  WHERE  request_type_code = 'newUnitTitle'
				  AND    source_type_code =  'unitPlan');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
SELECT 'newUnitTitle','bodyCorpRules'
WHERE NOT EXISTS (SELECT request_type_code FROM application.request_type_requires_source_type 
                  WHERE  request_type_code = 'newUnitTitle'
				  AND    source_type_code =  'bodyCorpRules');
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
SELECT 'newUnitTitle','unitEntitlements'
WHERE NOT EXISTS (SELECT request_type_code FROM application.request_type_requires_source_type 
                  WHERE  request_type_code = 'newUnitTitle'
				  AND    source_type_code =  'unitEntitlements');


-- Add User Rights for the new Services
-- Configure roles for services
INSERT INTO system.approle (code, display_value, status)
SELECT req.code, req.display_value, 'c'
FROM   application.request_type req
WHERE  NOT EXISTS (SELECT r.code FROM system.approle r WHERE req.code = r.code)
AND    req.code IN ('unitPlan', 'newUnitTitle', 'varyCommonProperty', 'cancelUnitPlan', 'changeBodyCorp'); 

INSERT INTO system.approle (code, display_value, status)
SELECT 'StrataUnitCreate', 'Create Strata Property', 'c'
WHERE  NOT EXISTS (SELECT code FROM system.approle WHERE code = 'StrataUnitCreate'); 

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r 
 WHERE g."name" = 'Land Registry'
 AND   r.code IN ('newUnitTitle', 'varyCommonProperty', 'cancelUnitPlan', 'changeBodyCorp', 'StrataUnitCreate' )
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
				   WHERE r.code = approle_code AND appgroup_id = g.id));

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r
 WHERE g."name" = 'Quality Assurance'
 AND   r.code IN ('unitPlan')
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup  
				   WHERE r.code = approle_code AND appgroup_id = g.id));
 
 
-- *** Titles Configuration for Unit Titles ***
-- BA Unit Relationship Types
INSERT INTO administrative.ba_unit_rel_type (code, display_value, status)
SELECT 'commonProperty', 'Common Property::::SAMOAN', 'c' 
WHERE NOT EXISTS (SELECT code FROM administrative.ba_unit_rel_type WHERE code = 'commonProperty');

-- BA Unit Type for Common Property and Principal Units is Strata Unit. 
INSERT INTO administrative.ba_unit_type (code, display_value, status)
SELECT 'strataUnit', 'Strata Property Unit::::SAMOAN', 'c' 
WHERE NOT EXISTS (SELECT code FROM administrative.ba_unit_type WHERE code = 'strataUnit');

-- BA Unit Status applied to the underlying parcel of a unit development. 
INSERT INTO transaction.reg_status_type (code, display_value, status)
SELECT 'dormant', 'Dormant::::SAMOAN', 'c' 
WHERE NOT EXISTS (SELECT code FROM transaction.reg_status_type WHERE code = 'dormant');

-- *** Survey Configuration for Unit Titles ***

-- Parcel Types
INSERT INTO cadastre.cadastre_object_type (code,display_value,status)
SELECT 'principalUnit', 'Principal Unit::::SAMOAN', 'c' 
WHERE NOT EXISTS (SELECT code FROM cadastre.cadastre_object_type WHERE code = 'principalUnit');

INSERT INTO cadastre.cadastre_object_type (code,display_value,status)
SELECT 'accessoryUnit', 'Accessory Unit::::SAMOAN', 'c' 
WHERE NOT EXISTS (SELECT code FROM cadastre.cadastre_object_type WHERE code = 'accessoryUnit');

INSERT INTO cadastre.cadastre_object_type (code,display_value,status)
SELECT 'commonProperty', 'Common Property::::SAMOAN', 'c' 
WHERE NOT EXISTS (SELECT code FROM cadastre.cadastre_object_type WHERE code = 'commonProperty');

-- Level for the various unit parcels (Principal Unit, Accessory Unit and Common Property)
INSERT INTO cadastre.level (id, name, register_type_code, type_code)
SELECT uuid_generate_v1(), 'Unit Parcels', 'all', 'primaryRight'
WHERE NOT EXISTS (SELECT name FROM cadastre.level WHERE name = 'Unit Parcels');

CREATE OR REPLACE VIEW cadastre.unit_parcels AS 
 SELECT co.id, (btrim(co.name_firstpart) || ' PLAN ') || btrim(co.name_lastpart) AS label, co.geom_polygon AS "theGeom"
   FROM cadastre.cadastre_object co, cadastre.spatial_unit_in_group sug
  WHERE sug.spatial_unit_id = co.id AND co.type_code = 'parcel' AND co.status_code = 'current' 
  AND co.geom_polygon IS NOT NULL AND sug.unit_parcel_status_code = 'current';
  
DELETE FROM geometry_columns WHERE f_table_name = 'unit_parcels'; 
INSERT INTO geometry_columns (f_table_catalog, f_table_schema, f_table_name, f_geometry_column, coord_dimension, srid, type) VALUES ('', 'cadastre', 'unit_parcels', 'theGeom', 2, 32702, 'POLYGON');

----Unit Parcels Layer----
-- Remove any pre-existing data for the new navigation layer
DELETE FROM system.query_field
 WHERE query_name = 'dynamic.informationtool.get_unit_parcel';

DELETE FROM system.config_map_layer
 WHERE "name" = 'unit_parcel';

DELETE FROM system.query
 WHERE "name" IN ('dynamic.informationtool.get_unit_parcel', 
 'SpatialResult.getUnitParcel');

 -- Add the necessary dynamic queries
INSERT INTO system.query("name", sql)
 VALUES ('SpatialResult.getUnitParcel', 
 'SELECT co.id, cadastre.formatParcelNrLabel(co.name_firstpart, co.name_lastpart) as label,  st_asewkb(co.geom_polygon) as the_geom 
  FROM cadastre.cadastre_object co, cadastre.spatial_unit_in_group sug
  WHERE sug.spatial_unit_id = co.id AND co.type_code = ''parcel'' AND co.status_code = ''current'' 
  AND co.geom_polygon IS NOT NULL AND sug.unit_parcel_status_code = ''current''
  AND ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))'); 
 
INSERT INTO system.query("name", sql)
 VALUES ('dynamic.informationtool.get_unit_parcel', 
	'WITH unit_plan_parcels AS 
	  (SELECT co_unit.id AS unit_id,
	          sug2.spatial_unit_group_id AS group_id,
			  CASE co_unit.type_code 
				WHEN ''commonProperty'' THEN 1 
				WHEN ''principalUnit'' THEN 2
				WHEN ''accessoryUnit'' THEN 3 END  AS unit_type, 
			  co_unit.name_firstpart AS unit_name, 
			  co_unit.name_lastpart AS plan_num
	   FROM   cadastre.cadastre_object co_unit, 
	          cadastre.spatial_unit_in_group sug2
	   WHERE  co_unit.status_code = ''current''
	   AND    co_unit.type_code != ''parcel''
	   AND    sug2.spatial_unit_id = co_unit.id
	   AND    sug2.unit_parcel_status_code = ''current''
	   ORDER BY unit_type, plan_num, unit_name)
	SELECT co.id, 
			cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as parcel_nr,
		   (SELECT  string_agg(unit_name, '', '') 
			FROM 	unit_plan_parcels
			WHERE   group_id = sg.id) || '' PLAN '' || sg.name AS unit_parcels,
		   (SELECT string_agg(ba.name_firstpart || ''/'' || ba.name_lastpart, '', '') 
			FROM 	unit_plan_parcels, 
					administrative.ba_unit_contains_spatial_unit bas, 
					administrative.ba_unit ba
			WHERE	group_id = sg.id 
			AND     bas.spatial_unit_id = unit_id 
			AND     bas.ba_unit_id = ba.id
			AND     ba.status_code = ''current'') AS unit_properties,
			st_asewkb(co.geom_polygon) as the_geom
	FROM 	cadastre.cadastre_object co, 
	        cadastre.spatial_unit_in_group sug,
			cadastre.spatial_unit_group sg
	WHERE 	co.type_code= ''parcel'' 
	AND 	co.status_code= ''current''  
	AND     sug.unit_parcel_status_code = ''current''
    AND     sug.spatial_unit_id = co.id
	AND     sg.id = sug.spatial_unit_group_id
	AND		co.geom_polygon IS NOT NULL
	AND 	ST_Intersects(co.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))'); 

 -- Configure the query fields for the Object Information Tool
INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
 VALUES ('dynamic.informationtool.get_unit_parcel', 0, 'id', null); 

INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
 VALUES ('dynamic.informationtool.get_unit_parcel', 1, 'parcel_nr', 'Parcel number::::Poloka numera');

 INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
 VALUES ('dynamic.informationtool.get_unit_parcel', 2, 'unit_parcels', 'Unit Parcels::::SAMOAN');  

 INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
 VALUES ('dynamic.informationtool.get_unit_parcel', 3, 'unit_properties', 'Strata Properties::::SAMOAN'); 
 
INSERT INTO system.query_field(query_name, index_in_query, "name", display_value) 
 VALUES ('dynamic.informationtool.get_unit_parcel', 4, 'the_geom', null); 

 -- Configure the new Navigation Layer
INSERT INTO system.config_map_layer ("name", title, type_code, pojo_query_name, pojo_structure, pojo_query_name_for_select, style, active, item_order, visible_in_start)
 VALUES ('unit_parcel', 'Unit Parcels::::SAMOAN', 'pojo', 'SpatialResult.getUnitParcel', 'theGeom:Polygon,label:""', 
  'dynamic.informationtool.get_unit_parcel', 'samoa_unit_parcel.xml', TRUE, 35, FALSE); 
  
  
  -- New Unit Development Business Rules
INSERT INTO system.br_validation_target_type(
            code, display_value, status, description)
SELECT 'unit_plan', 'Unit Plan', 'c', 'The target of the validation is the transaction related with the unit plan. It accepts one parameter {id} which is the transaction id.'
WHERE NOT EXISTS (SELECT code FROM system.br_validation_target_type WHERE code = 'unit_plan');
 
 -- unit-plan-underlying-parcel-missing
INSERT INTO system.br(id, display_name, technical_type_code, feedback, technical_description)
SELECT 'unit-plan-underlying-parcel-missing', 'unit-plan-underlying-parcel-missing', 'sql',
         'The underlying parcel(s) for the unit development must be selected on the map', '#{id}(transaction_id) is requested'
WHERE NOT EXISTS (SELECT id FROM system.br WHERE id = 'unit-plan-underlying-parcel-missing');
  
INSERT INTO system.br_definition(
            br_id, active_from, active_until, body)
SELECT 'unit-plan-underlying-parcel-missing', '10 APR 2014', 'infinity',
'SELECT count(*) > 0 as vl 
FROM   transaction.transaction t,
       cadastre.spatial_unit_in_group sig,
       cadastre.cadastre_object co
WHERE  t.id = #{id}
AND    sig.spatial_unit_group_id = t.spatial_unit_group_id
AND    co.id = sig.spatial_unit_id
AND    co.type_code = ''parcel''
AND    co.status_code = ''current'''
WHERE NOT EXISTS (SELECT br_id FROM system.br_definition WHERE br_id = 'unit-plan-underlying-parcel-missing');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, target_request_type_code, severity_code, order_of_execution)
SELECT 'unit-plan-underlying-parcel-missing', 'unit_plan', 'pending', 'unitPlan', 'medium', 700
WHERE NOT EXISTS (SELECT br_id FROM system.br_validation WHERE br_id = 'unit-plan-underlying-parcel-missing' AND target_reg_moment = 'pending');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, target_request_type_code, severity_code, order_of_execution)
SELECT 'unit-plan-underlying-parcel-missing', 'unit_plan', 'current', 'unitPlan', 'critical', 750
WHERE NOT EXISTS (SELECT br_id FROM system.br_validation WHERE br_id = 'unit-plan-underlying-parcel-missing' AND target_reg_moment = 'current');

-- unit-plan-parcel-area-mismatch
INSERT INTO system.br(id, display_name, technical_type_code, feedback, technical_description)
SELECT 'unit-plan-parcel-area-mismatch', 'unit-plan-parcel-area-mismatch', 'sql',
         'The total area for the unit parcels and the common property should match the official area of the underlying parcels', '#{id}(transaction_id) is requested'
WHERE NOT EXISTS (SELECT id FROM system.br WHERE id = 'unit-plan-parcel-area-mismatch');
  
INSERT INTO system.br_definition(
            br_id, active_from, active_until, body)
SELECT 'unit-plan-parcel-area-mismatch', '10 APR 2014', 'infinity',
'WITH unit_par AS (
SELECT SUM(sva.size) AS area
FROM   transaction.transaction t,
       cadastre.spatial_unit_in_group sig,
       cadastre.cadastre_object co,
       cadastre.spatial_value_area sva
WHERE  t.id = #{id}
AND    sig.spatial_unit_group_id = t.spatial_unit_group_id
AND    sig.delete_on_approval = FALSE
AND    co.id = sig.spatial_unit_id
AND    co.type_code != ''parcel''
AND    co.status_code != ''historic''
AND    sva.type_code = ''officialArea''
AND    sva.spatial_unit_id = co.id),
    under_par AS (
SELECT SUM(sva.size) AS area
FROM   transaction.transaction t,
       cadastre.spatial_unit_in_group sig,
       cadastre.cadastre_object co,
       cadastre.spatial_value_area sva
WHERE  t.id = #{id}
AND    sig.spatial_unit_group_id = t.spatial_unit_group_id
AND    co.id = sig.spatial_unit_id
AND    co.type_code = ''parcel''
AND    co.status_code = ''current''
AND    sva.type_code = ''officialArea''
AND    sva.spatial_unit_id = co.id),
    under_prop AS (
SELECT SUM(sva.size) AS area
FROM   transaction.transaction t,
       cadastre.spatial_unit_in_group sig,
       cadastre.cadastre_object co,
       administrative.ba_unit_contains_spatial_unit bas,
       administrative.ba_unit_area sva
WHERE  t.id = #{id}
AND    sig.spatial_unit_group_id = t.spatial_unit_group_id
AND    co.id = sig.spatial_unit_id
AND    co.type_code = ''parcel''
AND    co.status_code = ''current''
AND    bas.spatial_unit_id = co.id
AND    sva.ba_unit_id = bas.ba_unit_id
AND    sva.type_code = ''officialArea'')
SELECT (CASE WHEN COUNT(under_par.area) = 0 THEN SUM(unit_par.area) = SUM(under_prop.area)
            ELSE SUM(unit_par.area) = SUM(under_par.area) END) AS vl
FROM  unit_par, under_par, under_prop'
WHERE NOT EXISTS (SELECT br_id FROM system.br_definition WHERE br_id = 'unit-plan-parcel-area-mismatch');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, target_request_type_code, severity_code, order_of_execution)
SELECT 'unit-plan-parcel-area-mismatch', 'unit_plan', 'pending', 'unitPlan', 'medium', 710
WHERE NOT EXISTS (SELECT br_id FROM system.br_validation WHERE br_id = 'unit-plan-parcel-area-mismatch' AND target_reg_moment = 'pending');

INSERT INTO system.br_validation(br_id, target_code, target_reg_moment, target_request_type_code, severity_code, order_of_execution)
SELECT 'unit-plan-parcel-area-mismatch', 'unit_plan', 'current', 'unitPlan', 'medium', 760
WHERE NOT EXISTS (SELECT br_id FROM system.br_validation WHERE br_id = 'unit-plan-parcel-area-mismatch' AND target_reg_moment = 'current');



-- unit-plan-unlinked-accessory-units
INSERT INTO system.br(id, display_name, technical_type_code, feedback, technical_description)
SELECT 'unit-plan-unlinked-accessory-units', 'unit-plan-unlinked-accessory-units', 'sql',
         'All Accessory Units are associated with a Principal Unit', '#{id}(service_id) is requested'
WHERE NOT EXISTS (SELECT id FROM system.br WHERE id = 'unit-plan-unlinked-accessory-units');
  
INSERT INTO system.br_definition(
            br_id, active_from, active_until, body)
SELECT 'unit-plan-unlinked-accessory-units', '10 APR 2014', 'infinity',
'SELECT count(*) = 0 as vl 
FROM   transaction.transaction t,
       cadastre.spatial_unit_in_group sig,
       cadastre.cadastre_object co
WHERE  t.from_service_id = #{id}
AND    sig.spatial_unit_group_id = t.spatial_unit_group_id
AND    co.id = sig.spatial_unit_id
AND    co.type_code = ''accessoryUnit''
AND    co.status_code = ''current''
AND    NOT EXISTS (SELECT bas.spatial_unit_id 
                   FROM administrative.ba_unit_contains_spatial_unit bas
                   WHERE bas.spatial_unit_id = co.id) '
WHERE NOT EXISTS (SELECT br_id FROM system.br_definition WHERE br_id = 'unit-plan-unlinked-accessory-units');

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, target_request_type_code, severity_code, order_of_execution)
SELECT 'unit-plan-unlinked-accessory-units', 'service', 'complete', 'newUnitTitle', 'medium', 720
WHERE NOT EXISTS (SELECT br_id FROM system.br_validation WHERE br_id = 'unit-plan-unlinked-accessory-units' AND target_service_moment = 'complete');

-- unit-plan-missing-entitlement
INSERT INTO system.br(id, display_name, technical_type_code, feedback, technical_description)
SELECT 'unit-plan-missing-entitlement', 'unit-plan-missing-entitlement', 'sql',
         'All Principal Units have an Unit Entitlement specified', '#{id}(service_id) is requested'
WHERE NOT EXISTS (SELECT id FROM system.br WHERE id = 'unit-plan-missing-entitlement');
  
INSERT INTO system.br_definition(
            br_id, active_from, active_until, body)
SELECT 'unit-plan-missing-entitlement', '10 APR 2014', 'infinity',
'SELECT count(*) = 0 as vl 
FROM   transaction.transaction t,
       cadastre.spatial_unit_in_group sig,
       cadastre.cadastre_object co
WHERE  t.from_service_id = #{id}
AND    sig.spatial_unit_group_id = t.spatial_unit_group_id
AND    co.id = sig.spatial_unit_id
AND    co.type_code = ''principalUnit''
AND    co.status_code = ''current''
AND    EXISTS (SELECT bas.spatial_unit_id 
                   FROM administrative.ba_unit_contains_spatial_unit bas,
				        administrative.rrr r
                   WHERE bas.spatial_unit_id = co.id
				   AND   r.ba_unit_id = bas.ba_unit_id
				   AND   r.type_code = ''unitEntitlement''
				   AND   r.status_code IN (''pending'', ''current'')
				   AND   (r.share IS NULL OR r.share < 1)) '
WHERE NOT EXISTS (SELECT br_id FROM system.br_definition WHERE br_id = 'unit-plan-missing-entitlement');

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, target_request_type_code, severity_code, order_of_execution)
SELECT 'unit-plan-missing-entitlement', 'service', 'complete', 'newUnitTitle', 'critical', 730
WHERE NOT EXISTS (SELECT br_id FROM system.br_validation WHERE br_id = 'unit-plan-missing-entitlement' AND target_service_moment = 'complete');

-- unit-plan-title-area-mismatch
INSERT INTO system.br(id, display_name, technical_type_code, feedback, technical_description)
SELECT 'unit-plan-title-area-mismatch', 'unit-plan-title-area-mismatch', 'sql',
         'The total area for the unit titles and the common property title should match the official area of the underlying property', '#{id}(service_id) is requested'
WHERE NOT EXISTS (SELECT id FROM system.br WHERE id = 'unit-plan-title-area-mismatch');
  
INSERT INTO system.br_definition(
            br_id, active_from, active_until, body)
SELECT 'unit-plan-title-area-mismatch', '10 APR 2014', 'infinity',
'WITH unit_title AS (
SELECT SUM(ba.size) AS area
FROM   transaction.transaction t,
       cadastre.spatial_unit_in_group sig,
       cadastre.cadastre_object co,
       administrative.ba_unit_contains_spatial_unit bas,
	   administrative.ba_unit b,
	   administrative.ba_unit_area ba
WHERE  t.from_service_id = #{id}
AND    sig.spatial_unit_group_id = t.spatial_unit_group_id
AND    co.id = sig.spatial_unit_id
AND    co.type_code IN (''principalUnit'', ''commonProperty'')
AND    co.status_code = ''current''
AND    bas.spatial_unit_id = co.id
AND    b.id = bas.ba_unit_id
AND    b.status_code != ''historic''
AND    ba.ba_unit_id = b.id
AND    ba.type_code = ''officialArea''),
    under_prop AS (
SELECT SUM(sva.size) AS area
FROM   transaction.transaction t,
       cadastre.spatial_unit_in_group sig,
       cadastre.cadastre_object co,
       administrative.ba_unit_contains_spatial_unit bas,
	   administrative.ba_unit b,
       administrative.ba_unit_area ba
WHERE  t.id = #{id}
AND    sig.spatial_unit_group_id = t.spatial_unit_group_id
AND    co.id = sig.spatial_unit_id
AND    co.type_code = ''parcel''
AND    co.status_code = ''current''
AND    bas.spatial_unit_id = co.id
AND    b.id = bas.ba_unit_id
AND    b.status_code != ''historic''
AND    ba.ba_unit_id = b.id
AND    ba.type_code = ''officialArea'')
SELECT SUM(unit_title.area) = SUM(under_prop.area) AS vl
FROM  unit_title, under_prop'
WHERE NOT EXISTS (SELECT br_id FROM system.br_definition WHERE br_id = 'unit-plan-title-area-mismatch');

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, target_request_type_code, severity_code, order_of_execution)
SELECT 'unit-plan-title-area-mismatch', 'service', 'complete', 'newUnitTitle', 'critical', 740
WHERE NOT EXISTS (SELECT br_id FROM system.br_validation WHERE br_id = 'unit-plan-title-area-mismatch' AND target_service_moment = 'complete');


-- ba_unit-spatial_unit-area-comparison
-- Modify query so that strata units are excluded from the validation
UPDATE system.br_definition
SET body = 
'SELECT (abs(coalesce(ba_a.size,0.001) - 
 (select coalesce(sum(sv_a.size), 0.001) 
  from cadastre.spatial_value_area sv_a inner join administrative.ba_unit_contains_spatial_unit ba_s 
    on sv_a.spatial_unit_id= ba_s.spatial_unit_id
  where sv_a.type_code = ''officialArea'' and ba_s.ba_unit_id= ba.id))/coalesce(ba_a.size,0.001)) < 0.001 as vl
FROM administrative.ba_unit ba left join administrative.ba_unit_area ba_a 
  on ba.id= ba_a.ba_unit_id and ba_a.type_code = ''officialArea''
WHERE ba.id = #{id}
AND ba.type_code != ''strataUnit'''
WHERE br_id = 'ba_unit-spatial_unit-area-comparison'; 

-- newtitle-br22-check-different-owners
-- Modify query so that strata units are excluded from the validation
UPDATE system.br_definition
SET body = 
'WITH new_property_owner AS (
	SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS newOwnerStr FROM party.party po
		INNER JOIN administrative.party_for_rrr pfr1 ON (po.id = pfr1.party_id)
		INNER JOIN administrative.rrr rr1 ON (pfr1.rrr_id = rr1.id)
	WHERE rr1.ba_unit_id = #{id}),
	
  prior_property_owner AS (
	SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS priorOwnerStr FROM party.party pn
		INNER JOIN administrative.party_for_rrr pfr2 ON (pn.id = pfr2.party_id)
		INNER JOIN administrative.rrr rr2 ON (pfr2.rrr_id = rr2.id)
		INNER JOIN administrative.required_relationship_baunit rfb ON (rr2.ba_unit_id = rfb.from_ba_unit_id)
	WHERE	rfb.to_ba_unit_id = #{id}
	LIMIT 1	)

SELECT 	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM prior_property_owner) THEN NULL
        WHEN (SELECT type_code FROM administrative.ba_unit WHERE id = #{id}) = ''strataUnit'' THEN NULL
		WHEN (SELECT (COUNT(*) != 0) FROM new_property_owner npo WHERE compare_strings((SELECT priorOwnerStr FROM prior_property_owner), npo.newOwnerStr)) THEN TRUE
		ELSE FALSE
	END AS vl
ORDER BY vl
LIMIT 1'
WHERE br_id = 'newtitle-br22-check-different-owners'; 



ALTER TABLE administrative.rrr
DROP COLUMN IF EXISTS source_rrr;

ALTER TABLE administrative.rrr_historic
DROP COLUMN IF EXISTS source_rrr;

ALTER TABLE administrative.rrr
ADD COLUMN source_rrr VARCHAR(40);

ALTER TABLE administrative.rrr_historic
ADD COLUMN source_rrr VARCHAR(40);

COMMENT ON COLUMN administrative.rrr.source_rrr IS 'SOLA Extension: Used by the administrative.create_strata_properties prodcedure to determine the source RRR used to create the new rrr for a unit parcel property.';

ALTER TABLE administrative.rrr_share
DROP COLUMN IF EXISTS source_rrr_share;

ALTER TABLE administrative.rrr_share_historic
DROP COLUMN IF EXISTS source_rrr_share;

ALTER TABLE administrative.rrr_share
ADD COLUMN source_rrr_share VARCHAR(40);

ALTER TABLE administrative.rrr_share_historic
ADD COLUMN source_rrr_share VARCHAR(40);

COMMENT ON COLUMN administrative.rrr_share.source_rrr_share IS 'SOLA Extension: Used by the administrative.create_strata_properties prodcedure to determine the source RRR share used to create the new rrr share for a unit parcel property.';


-- create_strata_properties procedure.
DROP FUNCTION IF EXISTS administrative.create_strata_properties(IN unit_parcel_group_id CHARACTER VARYING, IN ba_unit_ids TEXT[], 
                                                                IN trans_id CHARACTER VARYING, IN user_name CHARACTER VARYING);

CREATE OR REPLACE FUNCTION administrative.create_strata_properties(IN unit_parcel_group_id CHARACTER VARYING, IN ba_unit_ids TEXT[], 
                                                                   IN trans_id CHARACTER VARYING, IN user_name CHARACTER VARYING)
RETURNS VOID AS
  $BODY$
DECLARE 
   common_prop_id CHARACTER VARYING := NULL; 
   village_id CHARACTER VARYING := NULL;
   app_nr CHARACTER VARYING := NULL;
   estate_type CHARACTER VARYING := NULL;
   pid CHARACTER VARYING := NULL;
   rrr_ids TEXT[];
BEGIN 

    -- Bulk create BA Units for any Principal Units or Common Property that do not already have a BA Unit.  
   INSERT INTO administrative.ba_unit (id, type_code, name, name_firstpart, name_lastpart, transaction_id, change_user)
   SELECT uuid_generate_v1(), 'strataUnit', co.name_firstpart || '/' || co.name_lastpart, 
          co.name_firstpart, co.name_lastpart, trans_id, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code IN ('commonProperty', 'principalUnit')
   AND    NOT EXISTS (SELECT ba.id FROM administrative.ba_unit ba
                      WHERE ba.name_firstpart = co.name_firstpart
                      AND   ba.name_lastpart = co.name_lastpart); 

   -- Bulk create ba_unit_contains_spatial_unit   
   INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
   SELECT ba.id, co.id, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit ba
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code IN ('commonProperty', 'principalUnit')
   AND    ba.name_firstpart = co.name_firstpart
   AND    ba.name_lastpart = co.name_lastpart
   AND    ba.type_code = 'strataUnit'
   AND    NOT EXISTS (SELECT bas.ba_unit_id FROM administrative.ba_unit_contains_spatial_unit bas
                      WHERE bas.ba_unit_id = ba.id
                      AND   bas.spatial_unit_id = co.id); 

   -- Bulk create ba_unit_area
   INSERT INTO administrative.ba_unit_area(id, ba_unit_id, type_code, size, change_user)
   SELECT uuid_generate_v1(), bas.ba_unit_id, 'officialArea', sva.size, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          cadastre.spatial_value_area sva,
          administrative.ba_unit_contains_spatial_unit bas
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code IN ('commonProperty', 'principalUnit')
   AND    sva.spatial_unit_id = co.id
   AND    sva.type_code = 'officialArea'
   AND    bas.spatial_unit_id = co.id
   AND    NOT EXISTS (SELECT bua.id FROM administrative.ba_unit_area bua
                      WHERE bua.ba_unit_id = bas.ba_unit_id
                      AND   bua.type_code = 'officialArea'); 

   -- Find the Common Property Identifier
   SELECT bas.ba_unit_id INTO common_prop_id
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    bas.spatial_unit_id = co.id
   AND    co.type_code = 'commonProperty';

   IF ba_unit_ids IS NOT NULL THEN
      -- Link the Common Property to the underlying property(ies) as the Prior Title
      INSERT INTO administrative.required_relationship_baunit(from_ba_unit_id, to_ba_unit_id, relation_code, change_user)
      SELECT parent.id, common_prop_id, 'priorTitle', user_name
      FROM   administrative.ba_unit parent
      WHERE  parent.id = ANY (ba_unit_ids)
      AND    parent.status_code IN ('current', 'dormant')
      AND    parent.type_code != 'strataUnit'
      AND    NOT EXISTS (SELECT req.from_ba_unit_id FROM administrative.required_relationship_baunit req
                         WHERE req.from_ba_unit_id = parent.id
                         AND   req.to_ba_unit_id = common_prop_id
                         AND   req.relation_code  = 'priorTitle'); 
	END IF;
					  
   -- Determine the village that must be associated with the unit parcels. First check if the
   -- Common Property has a village specified. If so, use that. 
   SELECT village.from_ba_unit_id INTO village_id
   FROM   administrative.required_relationship_baunit village
   WHERE  village.to_ba_unit_id = common_prop_id
   AND    village.relation_code = 'title_Village'
   LIMIT 1;
   
   IF village_id IS NULL THEN
      -- If Common Property does not have a village, try to determine the
	  -- village from the prior titles. 
	  SELECT village.from_ba_unit_id INTO village_id
      FROM   administrative.required_relationship_baunit village,
	         administrative.required_relationship_baunit comm_prop
      WHERE  comm_prop.to_ba_unit_id = common_prop_id
	  AND    comm_prop.relation_code = 'priorTitle'
	  AND    village.to_ba_unit_id = comm_prop.from_ba_unit_id
      AND    village.relation_code = 'title_Village'
      LIMIT 1;
   END IF;
   
   IF village_id IS NOT NULL THEN
      -- Link the unit parcels to the village
      INSERT INTO administrative.required_relationship_baunit(from_ba_unit_id, to_ba_unit_id, relation_code, change_user)
      SELECT village_id, bas.ba_unit_id, 'title_Village', user_name
      FROM   cadastre.spatial_unit_in_group sig,
             cadastre.cadastre_object co,
             administrative.ba_unit_contains_spatial_unit bas
      WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
      AND    co.id = sig.spatial_unit_id
      AND    sig.delete_on_approval = FALSE
      AND    co.type_code IN ('commonProperty', 'principalUnit')
      AND    bas.spatial_unit_id = co.id
      AND    NOT EXISTS (SELECT req.from_ba_unit_id FROM administrative.required_relationship_baunit req
                         WHERE req.from_ba_unit_id = village_id
						 AND   req.to_ba_unit_id = bas.ba_unit_id
                         AND   req.relation_code = 'title_Village'); 
   END IF;

   -- Link the principal units to the common property
   INSERT INTO administrative.required_relationship_baunit(from_ba_unit_id, to_ba_unit_id, relation_code, change_user)
   SELECT common_prop_id, bas.ba_unit_id, 'commonProperty', user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code = 'principalUnit'
   AND    bas.spatial_unit_id = co.id
   AND    NOT EXISTS (SELECT req.from_ba_unit_id  FROM administrative.required_relationship_baunit req
                         WHERE req.from_ba_unit_id = common_prop_id
						 AND   req.to_ba_unit_id = bas.ba_unit_id
                         AND   req.relation_code = 'commonProperty');
						 
   -- Determine application number to use as notation.reference_nr
   SELECT split_part(app.nr, '/', 1) INTO app_nr
   FROM   transaction.transaction t,
		  application.service s,
		  application.application app
   WHERE  t.id = trans_id
   AND    s.id = t.from_service_id
   AND    app.id = s.application_id;
						 
   -- Create the Body Corporate Rules RRR on the Common Property
   INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, transaction_id, change_user)
   SELECT uuid_generate_v1(), common_prop_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          'bodyCorpRules', trans_id, user_name
   WHERE  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = common_prop_id
				      AND   r.type_code = 'bodyCorpRules');
					  
   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 'Body Corporate Rules',
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   administrative.rrr r
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.type_code = 'bodyCorpRules'
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id);

   -- Create Address for Service RRR on the Common Property					  
   INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, transaction_id, change_user)
   SELECT uuid_generate_v1(), common_prop_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          'addressForService', trans_id, user_name
   WHERE  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = common_prop_id
				      AND   r.type_code = 'addressForService');

   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 'Address for Service <address>',
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   administrative.rrr r
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.type_code = 'addressForService'
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id);
					  
   -- Create Unit Entitlement RRRs on the Principal Units. Note that the Unit Entitlement for 
   -- Accessory Units must be added to the Unit Entitlement for the Principal Unit manually    
   INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, transaction_id, change_user)
   SELECT uuid_generate_v1(), bas.ba_unit_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          'unitEntitlement', trans_id, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code = 'principalUnit'
   AND    bas.spatial_unit_id = co.id 
   AND  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = bas.ba_unit_id
				      AND   r.type_code = 'unitEntitlement');

   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 'Unit entitlement <entitlement>',
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas,
		  administrative.rrr r
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code = 'principalUnit'
   AND    bas.spatial_unit_id = co.id 
   AND    r.ba_unit_id = bas.ba_unit_id
   AND    r.type_code = 'unitEntitlement'
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id);
					  
						 
   -- Determine the estate type for the Unit Parcels based on the estate type of the Common Property.
   -- If the estate type for the Common Property is not specified, use the Estate Type from the
   -- underlying properties. 
   SELECT r.type_code INTO estate_type
   FROM   administrative.rrr r
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.is_primary = TRUE
   AND    r.status_code IN ('pending', 'current')
   -- Use Order By to ensure the current RRR is selected in preference to the pending RRR. 
   ORDER BY r.status_code   
   LIMIT 1;	

   IF estate_type IS NULL THEN
	  SELECT r.type_code INTO estate_type
      FROM   administrative.required_relationship_baunit req,
	         administrative.rrr r
      WHERE  req.to_ba_unit_id = common_prop_id
	  AND    req.relation_code = 'priorTitle'
	  AND    r.ba_unit_id = req.from_ba_unit_id
      AND    r.is_primary = TRUE
      AND    r.status_code = 'current'
      LIMIT 1;
   END IF; 

   -- Create the Primary RRR for the Common Property referencing a "Body Corporate" party. 
   INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, is_primary, transaction_id, change_user)
   SELECT uuid_generate_v1(), common_prop_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          estate_type, TRUE, trans_id, user_name
   WHERE  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = common_prop_id
				      AND   r.type_code = estate_type);

   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 'Body Corporate of ' || ba.name_lastpart, 
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   administrative.rrr r,
          administrative.ba_unit ba
   WHERE  ba.id = common_prop_id
   AND    r.ba_unit_id = ba.id
   AND    r.type_code = estate_type
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id); 
					  
   INSERT INTO administrative.rrr_share(id, rrr_id, nominator, denominator, change_user)
   SELECT uuid_generate_v1(), r.id, 1, 1, user_name
   FROM   administrative.rrr r
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.type_code = estate_type
   AND    NOT EXISTS (SELECT s.id FROM administrative.rrr_share s
                      WHERE  s.rrr_id = r.id); 

   SELECT COALESCE((SELECT pfr.party_id 
                    FROM   administrative.rrr r,
					       administrative.party_for_rrr pfr
					WHERE  r.ba_unit_id = common_prop_id
					AND    r.type_code = estate_type
					AND    pfr.rrr_id = r.id), uuid_generate_v1()::VARCHAR(40)) INTO pid;	

   INSERT INTO party.party(id, type_code, name, change_user)
   SELECT pid, 'nonNaturalPerson', 'Body Corporate of ' || 
        (SELECT name_lastpart FROM administrative.ba_unit WHERE id = common_prop_id), user_name
   WHERE  NOT EXISTS (SELECT p.id FROM party.party p
                      WHERE  p.id = pid);
					  
   INSERT INTO administrative.party_for_rrr(rrr_id, party_id, share_id, change_user)
   SELECT r.id, pid, s.id, user_name
   FROM   administrative.rrr r,
          administrative.rrr_share s
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.type_code = estate_type
   AND    s.rrr_id = r.id
   AND    NOT EXISTS (SELECT pfr.rrr_id FROM administrative.party_for_rrr pfr
                      WHERE  pfr.rrr_id = r.id
					  AND    pfr.share_id = s.id
					  AND    pfr.party_id = pid); 
					  
    -- Duplicate the RRRs from the underlying properties onto the new Unit parcels.
    -- Usually this will only be the primary RRR, but may include mortgages and 
    -- caveats if these exist on the underlying properties. 
	
	-- First collect all of the Current RRRs from the underlying property(ies), 
	-- but only pick one primary RRR to use for the primary estate. 
	--
	-- Note that all RRR's on the underlying property(ies) may be historic if the
	-- underlying property is Dormant. In this case, the user will need to manually
	-- create the necessary RRR's on the new Unit Parcel(s). 
	SELECT array_agg(tmp.id) INTO rrr_ids
	FROM (
		SELECT r.id
		FROM   administrative.required_relationship_baunit req,
			   administrative.rrr r
		WHERE  req.to_ba_unit_id = common_prop_id
		AND    req.relation_code = 'priorTitle'
		AND    r.ba_unit_id = req.from_ba_unit_id
		AND    r.is_primary = FALSE
		AND    r.status_code = 'current'
		UNION
		SELECT r.id
		FROM   administrative.required_relationship_baunit req,
			   administrative.rrr r
		WHERE  req.to_ba_unit_id = common_prop_id
		AND    req.relation_code = 'priorTitle'
		AND    r.ba_unit_id = req.from_ba_unit_id
		AND    r.is_primary = TRUE
		AND    r.status_code = 'current'
		AND    r.type_code = estate_type -- Make sure the estate type is consistent with the Common Property
		LIMIT 1) tmp; 
	
	-- Duplicate the RRR's. Requires a new column, source_rrr to ensure RRR's are correctly duplicated. 
    INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, is_primary, transaction_id, share,
	            mortgage_amount, mortgage_interest_rate, mortgage_type_code, source_rrr, change_user)
    SELECT uuid_generate_v1(), bas.ba_unit_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          r_orig.type_code, r_orig.is_primary, trans_id, r_orig.share, r_orig.mortgage_amount, 
		  r_orig.mortgage_interest_rate, r_orig.mortgage_type_code, r_orig.id, user_name
	FROM  cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas,
		  administrative.rrr r_orig
    WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
    AND    co.id = sig.spatial_unit_id
    AND    sig.delete_on_approval = FALSE
    AND    co.type_code = 'principalUnit'
    AND    bas.spatial_unit_id = co.id
	AND    r_orig.id = ANY (rrr_ids)
    AND  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = bas.ba_unit_id
				      AND   r.source_rrr = r_orig.id);

   -- Duplicate the notations if they exist, otherwise create an empty notation. 
   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 
          COALESCE((SELECT n_orig.notation_text FROM administrative.notation n_orig WHERE  n_orig.rrr_id = r_orig.id), ''),
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   administrative.rrr r,
          administrative.rrr r_orig
   WHERE  r_orig.id = ANY (rrr_ids)
   AND    r.source_rrr = r_orig.id
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id); 
		
	-- Duplicate the RRR Shares	
   INSERT INTO administrative.rrr_share(id, rrr_id, nominator, denominator, source_rrr_share, change_user)
   SELECT uuid_generate_v1(), r.id, s_orig.nominator, s_orig.denominator, s_orig.id, user_name
   FROM   administrative.rrr r,
          administrative.rrr r_orig,
		  administrative.rrr_share s_orig
   WHERE  r_orig.id = ANY (rrr_ids)
   AND    r.source_rrr = r_orig.id
   AND    s_orig.rrr_id = r_orig.id
   AND    NOT EXISTS (SELECT s.id FROM administrative.rrr_share s
                      WHERE  s.rrr_id = r.id
					  AND    s.source_rrr_share = s_orig.id)
					  
   -- Don't recreate the rrr_share if the user has previously deleted it
   AND    NOT EXISTS (SELECT s.id FROM administrative.rrr_share_historic s
                      WHERE  s.rrr_id = r.id
					  AND    s.source_rrr_share = s_orig.id); 

   -- Link the new RRR's to the original parties. Choose to avoid duplicating the
   -- party record to simplify this query. Also any subsequent change to party
   -- would require a new party record to be created anyway.     
   INSERT INTO administrative.party_for_rrr(rrr_id, party_id, share_id, change_user)
   SELECT DISTINCT r.id, pfr_orig.party_id, s.id, user_name
   FROM   administrative.rrr r,
          administrative.rrr r_orig,
          administrative.rrr_share s,
		  administrative.rrr_share s_orig,
		  administrative.party_for_rrr pfr_orig
   WHERE  r_orig.id = ANY (rrr_ids)
   AND    r.source_rrr = r_orig.id
   AND    s_orig.rrr_id = r_orig.id
   AND    s.source_rrr_share = s_orig.id
   AND    s.rrr_id = r.id
   AND    pfr_orig.rrr_id = r_orig.id
   AND    pfr_orig.share_id = s_orig.id
   AND    NOT EXISTS (SELECT pfr.rrr_id FROM administrative.party_for_rrr pfr
                      WHERE  pfr.rrr_id = r.id
					  AND    pfr.share_id = s.id
					  AND    pfr.party_id = pfr_orig.party_id)
					  
   -- Don't create the pfr if the user has previously deleted it. 				  
   AND    NOT EXISTS (SELECT pfr.rrr_id FROM administrative.party_for_rrr_historic pfr
                      WHERE  pfr.rrr_id = r.id
					  AND    pfr.share_id = s.id
					  AND    pfr.party_id = pfr_orig.party_id); 					  
					  
	-- Update the transaction table to reference this unit parcel group
	UPDATE transaction.transaction
	SET spatial_unit_group_id = unit_parcel_group_id,
	    change_user = user_name
	WHERE id = trans_id;   
	
   END; $BODY$
  LANGUAGE plpgsql VOLATILE;
  
COMMENT ON FUNCTION administrative.create_strata_properties(IN unit_parcel_group_id CHARACTER VARYING, IN ba_unit_ids TEXT[], 
IN trans_id CHARACTER VARYING, IN user_name CHARACTER VARYING) IS 'Creates the Strata Properties based on the Unit Development Parcel Group. Can be used to create new properties if the list of unit parcels is modified.';