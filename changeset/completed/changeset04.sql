
-- Update the survey plan number allocation to allocate non Record Plan services with a differnet number range to the
-- one used for survey plans
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
	     (SELECT CASE WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} = ''cadastreChange'' THEN
	                        trim(to_char(nextval(''application.survey_plan_nr_seq''), ''00000''))
					  WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} != ''cadastreChange'' THEN
					        trim(to_char(nextval(''application.information_nr_seq''), ''000000''))
		              ELSE (SELECT app_nr || ''/'' || suffix FROM unit_plan_nr)  END)
	WHEN ''registrationServices'' THEN trim(to_char(nextval(''application.dealing_nr_seq''),''00000'')) 
	WHEN ''nonRegServices'' THEN trim(to_char(nextval(''application.non_register_nr_seq''),''00000'')) 
	ELSE trim(to_char(nextval(''application.information_nr_seq''), ''000000'')) END AS vl'
WHERE br_id = 'generate-application-nr';

-- Let Land Reg print the map
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PrintMap', id FROM system.appgroup WHERE "name" = 'Land Registry');

-- Give Pati team leader rights
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id)
VALUES ((SELECT id FROM system.appuser WHERE username = 'pati'), (SELECT id FROM system.appgroup WHERE "name" = 'Team Leader'));
