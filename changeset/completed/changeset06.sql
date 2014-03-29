
-- Additional Services 
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('cnclMortgagePOS','registrationServices','Cancel Mortgage under Power of Sale::::SAMOAN','c',5,0.00,0.00,0.00,1,
	'Mortgage <reference> cancelled','mortgage','cancel','Discharge of Mortgage under Power of Sale');
	
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('cnclTransmissonAdmin','registrationServices','Cancel Transmission under Transfer by Administrator::::SAMOAN','c',5,0.00,0.00,0.00,1,
	'Transmission <reference> canceled','transmission','cancel','Cancel Transmission');
	
INSERT INTO application.request_type(code, request_category_code, display_value, 
            status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template, rrr_type_code, type_action_code, 
            description)
    VALUES ('planNoCoords','cadastralServices','Record Plan with No Coordinates::::SAMOAN','c',30,23.00,0.00,11.50,0,
	NULL,NULL,NULL,'Record Plan with no coordinates');

-- Documents required for new services
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code)
VALUES('planNoCoords', 'cadastralSurvey');

INSERT INTO system.approle (code, display_value, status)
SELECT req.code, req.display_value, 'c'
FROM   application.request_type req
WHERE  req.code IN ('planNoCoords', 'cnclTransmissonAdmin', 'cnclMortgagePOS');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'planNoCoords', 'super-group-id' 
WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup WHERE approle_code = 'planNoCoords' AND appgroup_id = 'super-group-id')); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'cnclMortgagePOS', 'super-group-id' 
WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup WHERE approle_code = 'cnclMortgagePOS' AND appgroup_id = 'super-group-id'));
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'cnclTransmissonAdmin', 'super-group-id' 
WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup WHERE approle_code = 'cnclTransmissonAdmin' AND appgroup_id = 'super-group-id'));

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'cnclTransmissonAdmin', id FROM system.appgroup WHERE "name" = 'Land Registry');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'cnclMortgagePOS', id FROM system.appgroup WHERE "name" = 'Land Registry'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'planNoCoords', id FROM system.appgroup WHERE "name" = 'Quality Assurance');

-- UPdate Application Nr business rule to allocation survey number for Record Plan with No Coordinates service 
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
	     (SELECT CASE WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} IN (''cadastreChange'', ''planNoCoords'') THEN
	                        trim(to_char(nextval(''application.survey_plan_nr_seq''), ''00000''))
					  WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} = ''redefineCadastre'' THEN
					        trim(to_char(nextval(''application.information_nr_seq''), ''000000''))
		              ELSE (SELECT app_nr || ''/'' || suffix FROM unit_plan_nr)  END)
	WHEN ''registrationServices'' THEN trim(to_char(nextval(''application.dealing_nr_seq''),''00000'')) 
	WHEN ''nonRegServices'' THEN trim(to_char(nextval(''application.non_register_nr_seq''),''00000'')) 
	ELSE trim(to_char(nextval(''application.information_nr_seq''), ''000000'')) END AS vl'
WHERE br_id = 'generate-application-nr';


-- Add system role for exporting the map feature data
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ExportMap', 'Export Map','c', 'Export a selected map feature to KML for display in Google Earth'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ExportMap');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ExportMap', 'super-group-id' 
WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup WHERE approle_code = 'ExportMap' AND appgroup_id = 'super-group-id'));

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ExportMap', id FROM system.appgroup WHERE "name" = 'Quality Assurance');

-- Add Technical Division group into system 
INSERT INTO system.appgroup(id, "name", description)
  (SELECT '80', 'Technical Division', 'The Technical Division can search and view application and document details as well as ' ||
                                ' view, print and export features from the Map'
   WHERE NOT EXISTS (SELECT id FROM system.appgroup WHERE "name" = 'Technical Division' )); 
   
DELETE FROM system.approle_appgroup WHERE appgroup_id = (SELECT id FROM system.appgroup WHERE "name" = 'Technical Division'); 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnView', id FROM system.appgroup WHERE "name" = 'Technical Division');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'SourceSearch', id FROM system.appgroup WHERE "name" = 'Technical Division');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewMap', id FROM system.appgroup WHERE "name" = 'Technical Division');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ManageUserPassword', id FROM system.appgroup WHERE "name" = 'Technical Division');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ViewSource', id FROM system.appgroup WHERE "name" = 'Technical Division');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'PrintMap', id FROM system.appgroup WHERE "name" = 'Technical Division');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ExportMap', id FROM system.appgroup WHERE "name" = 'Technical Division');

DROP FUNCTION application.get_work_summary(DATE, DATE);

-- Lodgement Report Functions
CREATE OR REPLACE FUNCTION application.get_work_summary(from_date DATE, to_date DATE)
  RETURNS TABLE (
      req_type VARCHAR(100), -- The service request type
      req_cat VARCHAR(100), -- The service request category type
      group_idx INT, -- Used for grouping/sorting the services by request category
      in_progress_from INT, -- Count of the services in progress as at the from_date
      on_requisition_from INT, -- Count of the services on requisition as at the from_date
      lodged INT, -- Count of the services lodged during the reporting period
      requisitioned INT, -- Count of the services requisitioned during the reporting period
      registered INT, -- Count of the services registered during the reporting period
      cancelled INT, -- Count of the services cancelled + the services associated to applications that have been rejected or lapsed
      withdrawn INT, -- Count of the serices associated to an application that was withdrawn 
      in_progress_to INT, -- Count of the services in progress as at the to_date
      on_requisition_to INT, -- Count of the services on requisition as at the to_date
      overdue INT, -- Count of the services exceeding their expected_completion_date at end of the reporting period
      overdue_apps TEXT, -- The list of applications that are overdue
      requisition_apps TEXT -- The list of applications on Requisition
) AS
$BODY$
DECLARE 
   tmp_date DATE; 
BEGIN

   IF to_date IS NULL OR from_date IS NULL THEN
      RETURN;
   END IF; 

   -- Swap the dates so the to date is after the from date
   IF to_date < from_date THEN 
      tmp_date := from_date; 
      from_date := to_date; 
      to_date := tmp_date; 
   END IF; 
   
   -- Go through to the start of the next day. 
   to_date := to_date + 1; 

   RETURN query 
      -- service_changed table contains all services that changed status during the 
      -- reporting period as a result of the service changing status direclty or the 
      -- application changing status. The UNION will ensure duplicates are filtered out.
      WITH service_changed AS 
         -- Get all services that changed status during the reporting period
        (SELECT ser.id, ser.application_id, ser.request_type_code, 
	        ser.status_code, false AS app_change
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
         -- Verify that the service actually changed status during the reporting period
	 -- rather than just being updated. 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )
      UNION  
         -- Get all services that changed status during the reporting period but have
         -- been subsequently updated by checking the service_historic table. 
         SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
		ser_hist.status_code, false AS app_change
         FROM  application.service_historic ser_hist
         WHERE ser_hist.change_time BETWEEN from_date AND to_date
         -- Verify that the service actually changed status during the reporting period
	 -- rather than just being updated.
         AND  NOT EXISTS (SELECT ser_hist2.status_code 
                          FROM application.service_historic ser_hist2
                          WHERE ser_hist.id = ser_hist2.id
                          AND  (ser_hist.rowversion - 1) = ser_hist2.rowversion
                          AND  ser_hist.status_code = ser_hist2.status_code )
      UNION
         -- Get the services for all applications that changed status during the reporting period
	 -- but did not actually get updated themselves. 
	 SELECT ser.id, ser.application_id, ser.request_type_code, 
		-- app_change indicates the service has changed as a result of an update to 
		-- the application rather than the service changing status itself
		ser.status_code, true AS app_change 
	 FROM   application.application app, application.service ser
	 WHERE  app.change_time BETWEEN from_date AND to_date
	 AND    ser.application_id = app.id
	 -- no need to collect services that changed during
	 -- the reporting period as these will be captured in the first select
	 AND    ser.change_time < from_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist.status_code 
			  FROM application.application_historic app_hist
			  WHERE app_hist.id = app.id
			  AND  (app.rowversion - 1) = app_hist.rowversion
			  AND  app.status_code = app_hist.status_code )
      UNION
	 -- Get the services for all applications that changed status during the reporting
	 -- period. This query checks the service_historic table to ensure the correct
	 -- service status is retrieved. 
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
		ser_hist.status_code, true AS app_change 
	 FROM   application.application app, application.service ser,
	        application.service_historic ser_hist
	 WHERE  app.change_time BETWEEN from_date AND to_date
	 AND    ser.application_id = app.id
	 -- Only capture services that changed since the reporting period as the previous
	 -- queries should have dealt with the other cases. 
	 AND    ser.change_time > to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist.status_code 
			  FROM application.application_historic app_hist
			  WHERE app_hist.id = app.id
			  AND  (app.rowversion - 1) = app_hist.rowversion
			  AND  app.status_code = app_hist.status_code )
	 -- Make sure this service didn't change during the reporting period by getting the
	 -- max row version up to the end of the reporting period
	 AND    ser_hist.id = ser.id
	 AND    ser_hist.change_time < from_date
	 AND ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				    FROM  application.service_historic ser_hist2
				    WHERE ser_hist.id = ser_hist2.id
				    AND   ser_hist2.change_time < to_date)
      UNION
	 -- Get the services for all applications (using the application history table)
	 -- that changed status during the reporting period but did not actually get 
	 -- updated themselves. Rely on duplicates being removed by the UNION
	 SELECT ser.id, ser.application_id, ser.request_type_code, 
		ser.status_code, true AS app_change 
	 FROM   application.application_historic app_hist, application.service ser
	 WHERE  app_hist.change_time BETWEEN from_date AND to_date
	 AND    ser.application_id = app_hist.id
	 -- no need to collect services that changed during
	 -- the reporting period as these will be captured in the first select
	 AND    ser.change_time < from_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist2.status_code 
			  FROM application.application_historic app_hist2
			  WHERE app_hist2.id = app_hist.id
			  AND  (app_hist.rowversion - 1) = app_hist2.rowversion
			  AND  app_hist.status_code = app_hist2.status_code )
      UNION
	 -- Get the services for all applications that changed status during the reporting
	 -- period. This query checks the service_historic table to ensure the correct
	 -- service status is retrieved. 
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
		ser_hist.status_code, true AS app_change 
	 FROM   application.application_historic app_hist, application.service ser,
	        application.service_historic ser_hist
	 WHERE  app_hist.change_time BETWEEN from_date AND to_date
	 AND    ser.application_id = app_hist.id
	 -- Only capture services that changed since the reporting period as the previous
	 -- queries should have dealt with the other cases. 
	 AND    ser.change_time > to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist2.status_code 
			  FROM application.application_historic app_hist2
			  WHERE app_hist2.id = app_hist.id
			  AND  (app_hist.rowversion - 1) = app_hist2.rowversion
			  AND  app_hist.status_code = app_hist2.status_code )
	 -- Make sure this service didn't change during the reporting period by getting the
	 -- max row version up to the end of the reporting period
	 AND    ser_hist.id = ser.id
	 AND    ser_hist.change_time < from_date
	 AND ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				    FROM  application.service_historic ser_hist2
				    WHERE ser_hist.id = ser_hist2.id
				    AND   ser_hist2.change_time < to_date)),
		                       
      service_in_progress AS (  -- All services in progress at the end of the reporting period
         SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= to_date
	 AND ser.status_code IN ('pending', 'lodged')
      UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist
	 WHERE ser_hist.change_time <= to_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= to_date )),
					  
	service_in_progress_from AS (  -- All services in progress at the start of the reporting period
         SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= from_date
	 AND ser.status_code IN ('pending', 'lodged')
      UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist
	 WHERE ser_hist.change_time <= from_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= from_date )),
				      
      app_changed AS ( -- All applications that changed status during the reporting period
         SELECT app.id, 
	 -- Treat the completed status the same as the approved status
	 CASE app.status_code WHEN 'completed' THEN 'approved' ELSE app.status_code END,
	 app.action_code
	 FROM   application.application app
	 WHERE  app.change_time BETWEEN from_date AND to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist.status_code 
			  FROM application.application_historic app_hist
			  WHERE app_hist.id = app.id
			  AND  (app.rowversion - 1) = app_hist.rowversion
			  AND  app.status_code = app_hist.status_code )
      UNION  
	 SELECT app_hist.id, 
	 -- Treat the completed status the same as the approved status
	 CASE app_hist.status_code WHEN 'completed' THEN 'approved' ELSE app_hist.status_code END,
	 app_hist.action_code
	 FROM  application.application_historic app_hist
	 WHERE app_hist.change_time BETWEEN from_date AND to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist2.status_code 
			  FROM application.application_historic app_hist2
			  WHERE app_hist.id = app_hist2.id
			  AND  (app_hist.rowversion - 1) = app_hist2.rowversion
			  AND  app_hist.status_code = app_hist2.status_code )), 
                          
      app_in_progress AS ( -- All applications in progress at the end of the reporting period
	 SELECT app.id, app.status_code, app.expected_completion_date, app.nr
	 FROM application.application app
	 WHERE app.change_time <= to_date
	 AND app.status_code IN ('lodged', 'requisitioned')
	 UNION
	 SELECT app_hist.id, app_hist.status_code, app_hist.expected_completion_date, app_hist.nr
	 FROM  application.application_historic app_hist
	 WHERE app_hist.change_time <= to_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= to_date)),
					  
	app_in_progress_from AS ( -- All applications in progress at the start of the reporting period
	 SELECT app.id, app.status_code, app.expected_completion_date, app.nr
	 FROM application.application app
	 WHERE app.change_time <= from_date
	 AND app.status_code IN ('lodged', 'requisitioned')
	 UNION
	 SELECT app_hist.id, app_hist.status_code, app_hist.expected_completion_date, app_hist.nr
	 FROM  application.application_historic app_hist
	 WHERE app_hist.change_time <= from_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= from_date))
   -- MAIN QUERY                         
   SELECT get_translation(req.display_value, null) AS req_type,
	  CASE req.request_category_code 
	     WHEN 'registrationServices' THEN get_translation(cat.display_value, null)
	     WHEN 'cadastralServices' THEN get_translation(cat.display_value, null)
	     ELSE 'Other Services'  END AS req_cat,
	     
	  CASE req.request_category_code 
	     WHEN 'registrationServices' THEN 1
             WHEN 'cadastralServices' THEN 2
	     ELSE 3 END AS group_idx,
		 
	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the start of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code)::INT AS in_progress_from,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code)::INT AS on_requisition_from,
	     
	  -- Count the services lodged during the reporting period. Note that
	  -- new services can be added to an existing application, so
	  -- count the services lodged rather than the applications lodged. 
	 (SELECT COUNT(s.id) FROM service_changed s
	  WHERE s.status_code = 'lodged'
	  AND   s.app_change = false
	  AND s.request_type_code = req.code)::INT AS lodged,
	  
          -- Count the applications that were requisitioned during the
	  -- reporting period. All of the services on the application
 	  -- are requisitioned unless they are cancelled
	 (SELECT COUNT(s.id) FROM app_changed a, service_changed s
          WHERE s.application_id = a.id
	  AND   a.status_code = 'requisitioned'
	  AND   s.status_code != 'cancelled'
          AND   s.request_type_code = req.code)::INT AS requisitioned, 
          
	  -- Count the services on applications approved/completed 
	  -- during the reporting period
         (SELECT COUNT(s.id) FROM app_changed a, service_changed s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'approved'
	  AND   s.status_code = 'completed'
	  AND   s.request_type_code = req.code)::INT AS registered,
	  
	  -- Count of the services associated with applications 
	  -- that have been lapsed or rejected + the count of 
	  -- services cancelled during the reporting period 		   
        ((SELECT COUNT(s.id) FROM app_changed a, service_changed s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'annulled'
	  AND   a.action_code != 'withdrawn'
	  AND   s.request_type_code = req.code) + 
	 (SELECT COUNT(s.id) FROM app_changed a, service_changed s
	  WHERE s.application_id = a.id
	  AND   a.status_code != 'annulled'
	  AND   s.status_code = 'cancelled'
	  AND   s.request_type_code = req.code))::INT AS cancelled, 
	  
	  -- Count of the services associated with applications
	  -- that have been withdrawn during the reporting period
         (SELECT COUNT(s.id) FROM app_changed a, service_changed s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'annulled'
	  AND   a.action_code = 'withdrawn'
	  AND   s.request_type_code = req.code)::INT AS withdrawn,

	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code)::INT AS in_progress_to,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code)::INT AS on_requisition_to,

	  -- Count of the services that have exceeded thier expected
	  -- completion date and are overdue. Only counts the service 
	  -- as overdue if both the application and the service are overdue. 
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'              
	  AND   a.expected_completion_date < to_date
	  AND   s.expected_completion_date < to_date
	  AND   s.request_type_code = req.code)::INT AS overdue,  

	  -- The list of overdue applications 
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'lodged' 
          AND   a.expected_completion_date < to_date
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.expected_completion_date < to_date
                        AND   s.request_type_code = req.code)) AS overdue_apps,   

	  -- The list of applications on Requisition
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'requisitioned' 
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.request_type_code = req.code)) AS requisition_apps 						
   FROM  application.request_type req, 
	 application.request_category_type cat
   WHERE req.status = 'c'
   AND   cat.code = req.request_category_code
   UNION 
   -- Summarise overall totals for the reporting period
   SELECT 'TOTAL' AS req_type,
          'Totals' AS req_cat, 
           10 AS group_idx,
	  (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
   WHERE s.application_id = a.id
   AND   a.status_code = 'lodged')::INT AS in_progress_from,
  (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
   WHERE s.application_id = a.id
   AND   a.status_code = 'requisitioned')::INT AS on_requisition_from, 
	  (SELECT COUNT(s.id) FROM service_changed s
	   WHERE s.status_code = 'lodged'
	   AND s.app_change = false)::INT AS lodged,
	  (SELECT COUNT(s.id) FROM app_changed a, service_changed s
	   WHERE s.application_id = a.id
	   AND   a.status_code = 'requisitioned'
	   AND   s.status_code != 'cancelled')::INT AS requisitioned,  
          (SELECT COUNT(s.id) FROM app_changed a, service_changed s
	   WHERE s.application_id = a.id
	   AND   a.status_code = 'approved'
	   AND   s.status_code = 'completed')::INT AS registered, 
	 ((SELECT COUNT(s.id) FROM app_changed a, service_changed s
	   WHERE s.application_id = a.id
	   AND   a.status_code = 'annulled'
	   AND   a.action_code != 'withdrawn') + 
	  (SELECT COUNT(s.id) FROM app_changed a, service_changed s
	   WHERE s.application_id = a.id
	   AND   a.status_code != 'annulled'
	   AND   s.status_code = 'cancelled'))::INT AS cancelled, 
	  (SELECT COUNT(*) FROM app_changed a, service_changed s
	   WHERE s.application_id = a.id
	   AND   a.status_code = 'annulled'
	   AND   a.action_code = 'withdrawn')::INT AS withdrawn,
	  (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
           WHERE s.application_id = a.id
           AND   a.status_code = 'lodged')::INT AS in_progress_to,
          (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
           WHERE s.application_id = a.id
           AND   a.status_code = 'requisitioned')::INT AS on_requisition_to, 
          (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
           WHERE s.application_id = a.id
           AND   a.status_code = 'lodged' 
           AND   a.expected_completion_date < to_date
	   AND   s.expected_completion_date < to_date)::INT AS overdue,
	  (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
           WHERE a.status_code = 'lodged' 
           AND   a.expected_completion_date < to_date
           AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                         WHERE s.application_id = a.id
                         AND   s.expected_completion_date < to_date)) AS overdue_apps,
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'requisitioned' 
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id)) AS requisition_apps 						 
   ORDER BY group_idx, req_type;
	
   END; $BODY$
   LANGUAGE plpgsql VOLATILE;


COMMENT ON FUNCTION application.get_work_summary(DATE,DATE)
IS 'Returns a summary of the services processed for a specified reporting period';







INSERT INTO cadastre.spatial_unit (id, dimension_code, label, surface_relation_code, level_id, change_user, rowversion, geom) VALUES ('8569dc74-33c6-11e2-bc4f-a383c647fd71', '2D', 'XV', 'onSurface', (SELECT id FROM cadastre.level WHERE name = 'Flur'), 'dcdb-migration', 1, ST_GeomFromText('POLYGON((401487.508388524 8470067.68326966,401761.336385905 8468445.88338233,402041.818779632 8466820.87414824,402036.483718373 8466820.86415028,402111.116855096 8466229.0546114,402297.357494364 8466176.35533818,402259.319414627 8465769.90806934,402231.811278056 8465566.76941763,402193.52582299 8465134.89732394,402099.242839309 8463569.57594057,402115.132581268 8463530.99379385,402110.06963287 8463270.856744,402078.718932857 8462017.92177528,402042.931968612 8460260.38951587,402013.205699925 8458871.64219137,401976.635380473 8457105.47169025,401976.01694215 8457070.89872748,401996.606815358 8457070.748758,401969.486233468 8455768.3838506,401939.215739058 8455699.92778464,401894.15219998 8455619.07424214,401891.8103802 8455580.37211985,401910.3140548 8455480.43246228,401863.716788684 8455365.81579217,401845.848044094 8455287.13180806,401819.106771042 8455154.48880716,401793.792029054 8455085.24290196,401793.173590732 8455028.02454859,401782.668385099 8454966.24712321,401754.146009679 8454870.63658446,401738.899443576 8454752.0407243,401746.370178508 8454738.90339837,401873.19126378 8454555.45073962,401832.811364262 8454315.32961558,401678.572846706 8453398.0863178,401563.089797341 8452710.66624016,401554.209023034 8452657.94697101,401607.180326792 8452603.01815162,401730.867991231 8452371.80521434,401751.070309756 8452257.05857069,401806.004124456 8452114.04768014,401817.927615308 8452006.67953461,401865.275253256 8451909.73926652,401884.380874489 8451870.30729279,401886.285664522 8451799.52170099,401851.966460562 8451710.88974177,401846.384023973 8451657.36063746,401843.283586518 8451602.19186691,401833.462785962 8451579.10656585,401770.736648402 8451595.30326906,401495.308957228 8451596.6329984,401161.945964031 8451657.40062932,401026.664642511 8451667.53856578,400912.773041095 8451695.46288186,400825.136207918 8451759.30988599,400715.77157502 8451805.60046368,400715.845787619 8451802.01119426,400715.903508529 8451782.35519518,400703.666675594 8451789.27378692,400691.190713174 8451795.20258014,400678.722996598 8451794.65269206,400671.235769978 8451798.11198793,400664.23504817 8451804.05077911,400653.259829412 8451806.00038227,400642.27636481 8451812.92897198,400634.286141687 8451816.37826988,400615.320699807 8451821.28727067,400597.353005086 8451827.68596824,400589.841040932 8451837.61394742,400576.367331352 8451843.53274267,400564.377873746 8451849.95143616,400552.371924451 8451863.84860744,400537.908713556 8451864.28851789,400531.913984753 8451868.24771201,400518.407291796 8451882.6247856,400507.926823696 8451886.0740835,400492.449373952 8451893.72252668,400483.428420293 8451906.13999915,400481.383450907 8451922.05675934,400481.29274662 8451949.9310856,400475.248542751 8451970.8068364,400471.208079046 8451985.72380009,400455.095699292 8452034.69383238,400450.560484929 8452050.10069636,400447.006526037 8452068.00705158,400446.932313439 8452090.9023913,400446.379841871 8452108.81874447,400442.817637135 8452130.21438945,400424.24799578 8452167.21685771,400408.218074469 8452193.04160116,400395.676145295 8452215.3870528,400393.622930065 8452233.80330423,400382.581744553 8452257.14855237,400368.547317561 8452280.49380051,400344.502435594 8452314.98677957,400328.480760127 8452336.83233297,400312.970327006 8452352.19920509,400305.466608697 8452361.12738778,400293.452413558 8452375.01456109,400275.45173546 8452391.37123173,400260.963787032 8452400.2794185,400250.961577901 8452411.18719825,400212.972973229 8452441.65099743,400194.485790318 8452455.01827656,400181.960352832 8452473.38453816,400166.458165556 8452487.76161175,400139.486008863 8452503.58839026,400112.010855669 8452518.90527255,400081.534215151 8452540.44088904,400052.50884323 8452573.18422423,400028.505190484 8452596.97938079,400007.503025062 8452616.80534527,399985.989617294 8452639.62070127,399971.460439644 8452660.96635643,399944.974787766 8452679.52257936,399937.479315301 8452686.471165,399922.504862059 8452690.8902655,399914.011642434 8452695.82926019,399900.521441166 8452705.73724344,399890.016235533 8452717.14492144,399880.014026402 8452727.55280295,399862.541082339 8452733.96149848,399839.601143508 8452736.36101007,399829.112429563 8452742.28980328,399812.653724348 8452745.20920904,399787.207048851 8452751.08801243,399774.731086431 8452753.02761763,399767.730364624 8452760.96600179,399754.701930636 8452780.32206192,399750.661466931 8452797.47856976,399737.633032944 8452817.3445261,399734.095565741 8452833.25128833,399726.047621708 8452854.62693738,399705.985482536 8452889.88975973,399692.940556859 8452915.2246029,399683.416606698 8452932.86101306,399663.931676626 8452944.72859745,399624.458819981 8452972.44295627,399601.469406084 8452989.27952923,399587.484454158 8452997.1879195,399571.512253757 8453003.09671678,399562.021286972 8453008.04570943,399547.566321922 8453007.98572164,399527.627870414 8453007.90573792,399509.181916724 8453007.33585392,399499.699195783 8453009.78535533,399498.668465246 8453019.24343017,399500.639222033 8453026.47195882,399504.60547314 8453034.95023309,399509.066474904 8453042.92860912,399510.014746998 8453056.86577225,399498.990053174 8453075.24203181,399482.951886018 8453100.56687702,399475.415184332 8453118.20328718,399462.906238535 8453131.59056224,399447.412297103 8453145.46773758,399446.373320721 8453156.91540744,399452.813325117 8453169.38286972,399460.737581485 8453184.84972149,399473.675311185 8453192.85809141,399463.640118677 8453212.73404571,399460.15212654 8453212.71404978,399446.183666303 8453214.65365498,399433.691212194 8453225.06153649,399424.159016188 8453243.68774518,399413.645564711 8453257.0850182,399401.623123727 8453273.46168478,399385.634431637 8453284.3494686,399361.70499149 8453285.74918369,399342.73954961 8453290.65818448,399330.247095501 8453298.56657475,399322.232134846 8453312.47374399,399315.660196942 8453339.82817607,399297.684256376 8453348.71636691,399287.698538934 8453351.66576657,399276.236815363 8453352.11567499,399266.737602734 8453360.04406119,399240.268442544 8453374.62109407,399231.247488884 8453389.01816359,399229.705516 8453401.95553023,399236.104291174 8453426.37056062,399249.982047124 8453453.80497642,399254.921307858 8453465.77254046,399263.802082164 8453496.16635389,399248.200944756 8453540.89724904,399244.646985865 8453558.80360426,399234.636530889 8453571.21107875,399233.614046197 8453580.16925534,399228.089330518 8453591.59692927,399222.523385619 8453617.45166662,399199.55046341 8453630.30904953,399196.524238553 8453639.25722816,399189.515270902 8453648.6853091,399178.028809798 8453655.60390084,399178.012318109 8453660.08298913,399172.034080994 8453658.57329643,399146.702847317 8453631.09888876,399140.221613701 8453630.56899662,399128.273385316 8453624.06032144,399113.834911953 8453619.52124536,399102.348450849 8453626.4398371,399094.358227726 8453629.39923472,399088.355253079 8453635.34802386,399083.844776249 8453643.79630424,399081.849281929 8453643.78630628,399075.887536503 8453637.28762906,399075.912274036 8453629.32924897,399086.442217202 8453611.45288765,399093.467676542 8453598.0356187,399094.490161235 8453589.07744211,399082.566670383 8453576.09008565,399074.106434136 8453573.07070023,399071.129684345 8453567.0919172,399066.734649335 8453537.95784735,399065.802868929 8453518.54179943,399054.448341334 8453483.64890178,399043.580318552 8453454.24488688,399029.1995661 8453430.78966113,399015.255843395 8453424.77088623,399002.821110197 8453416.75251834,398990.897619345 8453403.76516188,398988.935108402 8453393.30729055,398985.991341989 8453379.85002974,398976.558096114 8453366.87267124,398966.597116205 8453364.84308436,398950.171394367 8453356.81471851,398929.268179077 8453347.27665995,398906.344731934 8453342.21768969,398891.386770381 8453343.64739868,398880.411551623 8453346.59679834,398866.954333732 8453346.04691027,398845.539876096 8453336.74880287,398824.603677428 8453336.1689209,398815.640444678 8453333.64943374,398803.675724605 8453334.09934216,398787.736507581 8453329.06036783,398767.278567882 8453335.44906743,398748.849105881 8453329.90019688,398721.439919441 8453326.81082572,398688.003020821 8453336.13892701,398677.019556219 8453341.06792372,398660.066100346 8453343.49742921,398649.577386402 8453347.93652564,398628.072224478 8453370.25198339,398613.592521894 8453375.67088039,398597.133816679 8453378.59028616,398591.642084378 8453379.56008876,398579.652626772 8453386.97857874,398563.688672215 8453392.39747574,398549.703720289 8453398.81616924,398532.717281039 8453410.44380247,398516.695605572 8453431.28955937,398512.6798794 8453439.72784179,398499.173186443 8453453.11511684,398484.69348386 8453460.03370859,398468.201795268 8453472.91108743,398455.725832848 8453475.35059088,398445.253610592 8453476.30039755,398431.27690451 8453483.21898929,398409.293483617 8453498.06596723,398396.792783665 8453509.96354551,398391.276313831 8453519.40162442,398384.762096837 8453527.82990886,398368.789896435 8453535.73829914,398360.791427468 8453540.67729382,398351.267477306 8453557.81380573,398325.268330241 8453581.10906405,398312.264633787 8453592.00684584,398306.261659139 8453599.94523,398303.713693252 8453615.37208991,398300.184471893 8453628.29945858,398285.663540088 8453646.65572221,398275.174826143 8453654.08421017,398273.154594291 8453662.04259026,398265.147879479 8453670.97077296,398249.126204012 8453692.05648102,398248.087227631 8453703.50415088,398239.08276566 8453713.42213211,398232.568548666 8453724.34990779,398226.029594139 8453742.24626504,398217.998141795 8453759.63272607,398209.50492217 8453765.071619,398201.498207359 8453773.01000317,398192.51848292 8453776.45930107,398189.013999095 8453779.42869666,398183.505775105 8453788.36687732,398175.474322761 8453804.76353983,398171.466842433 8453809.22263219,398162.981868652 8453814.17162484,398159.477384827 8453817.14102043,398145.962446025 8453833.26773788,398141.476706728 8453833.7476402,398129.990245624 8453839.17653516,398120.02101987 8453840.63623804,398111.552537778 8453837.60685467,398105.079550006 8453835.09736547,398099.596063549 8453835.57726778,398096.091579723 8453839.04656162,398097.559340008 8453848.50463645,398097.526356631 8453857.96271129,398092.504637455 8453869.39038522,398078.997944498 8453883.27755853,398069.028718744 8453883.73746491,398059.043001302 8453887.18676282,398053.551269001 8453890.64605869,398044.043810527 8453899.56424342,398040.036330199 8453907.02272527,398038.024344191 8453912.98151237,398037.480118468 8453926.9186755,398035.459886615 8453934.8770556,398032.895429039 8453955.02295496,398030.866951342 8453965.96072861,398024.360980193 8453974.39901102,398018.36625139 8453976.86850836,398011.365529582 8453983.30719778,398009.34529773 8453992.75527465,398007.811570691 8454004.70284276,398005.783092994 8454014.15091963,398002.278609168 8454019.10991024,397998.287620529 8454018.60001403,397998.312358062 8454012.63122896,397995.838604773 8454006.64244796,397988.351378152 8454010.10174383,397987.32889346 8454016.57042715,397986.289917078 8454029.00789554,397983.783180412 8454034.96668264,397979.783945929 8454037.44617795,397976.798950294 8454034.44678847,397973.327449845 8454029.447806,397967.34921273 8454029.42781007,397963.333486558 8454036.87629395,397962.797506679 8454048.82386206,397957.784033347 8454055.77244769,397949.78556438 8454064.20073214,397947.740594995 8454078.62779555,397939.725634339 8454089.79552239,397929.236920394 8454097.22401035,397922.227952743 8454106.15219304,397912.728740114 8454113.58068099,397895.750546709 8454123.46866832,397884.280577293 8454124.42847296,397864.820384754 8454129.32747578,397847.339194847 8454139.71536135,397822.543941049 8454143.48459414,397812.739632181 8454145.24423597,397798.919597141 8454157.4417532,397791.943612867 8454156.42196077,397785.948884063 8454159.3813584,397782.460891926 8454159.37136043,397772.994662674 8454157.34177355,397769.506670537 8454158.32157411,397767.494684529 8454163.29056269,397770.966184978 8454168.77944545,397770.941447445 8454175.24812876,397765.936219957 8454181.20691587,397751.951268031 8454188.61540789,397735.995559318 8454190.54501513,397719.058595134 8454186.49583932,397706.120865434 8454179.97716618,397698.171871533 8454169.48930096,397688.72213397 8454163.48052402,397681.243153193 8454163.95042838,397673.739434884 8454170.88901605,397677.210935332 8454176.3778988,397690.156910877 8454181.90677341,397704.578892551 8454192.91453282,397711.02714279 8454203.39240008,397704.018175139 8454212.07063365,397688.540725395 8454220.4689242,397669.575283514 8454226.86762176,397649.595602785 8454236.24571288,397640.624124191 8454236.71561723,397629.632413745 8454243.63420897,397618.62421161 8454256.54158172,397603.583791614 8454280.86663042,397594.07633314 8454293.77400316,397579.588384712 8454301.68239344,397571.565178212 8454315.08966442,397555.535256901 8454339.41471313,397544.024058264 8454353.80178468,397527.532369672 8454365.689365,397510.034688076 8454380.54634091,397499.521236599 8454394.19356305,397461.046127114 8454422.16786897,397444.034950331 8454439.52433611,397430.025260872 8454455.90100268,397423.486306345 8454472.79756344,397422.397854898 8454500.66189173,397419.858134855 8454515.58885339,397405.262990451 8454556.59050763,397396.20080757 8454583.4350435,397385.176113746 8454600.81150657,397362.607237908 8454643.03291253,397344.021104865 8454686.26411294,397337.943917619 8454714.3683924,397328.824013828 8454759.62917969,397325.195842337 8454801.42067316,397312.150916661 8454827.25541457,397288.130772227 8454854.78981002,397274.599341737 8454878.1250602,397252.038711744 8454914.86758137,397231.003562945 8454944.65151893,397229.956340719 8454961.32812446,397235.373860421 8454981.75396684,397249.738121185 8455009.68828089,397259.63313434 8455032.12371422,397274.962158886 8455072.49549666,397287.817430144 8455103.65915339,397291.72596034 8455129.05398435,397295.634490536 8455153.95891502,397293.490571019 8455199.73959649,397295.304656765 8455254.74839961,397279.720011045 8455295.51010269,397275.671301496 8455311.91676316,397267.573882397 8455350.70886714,397260.51543968 8455374.82395858,397257.431493913 8455402.18838863,397247.363318028 8455432.01231806,397230.294420335 8455469.2747334,397212.227775483 8455506.28719962,397191.176134995 8455539.56042695,397170.157477885 8455565.3551765,397165.11926702 8455581.76183697,397151.596082374 8455600.3780477,397135.129131315 8455604.78715024,397119.123947537 8455621.6537171,397096.101550263 8455649.05813901,397090.3377051 8455656.25667377,397075.602381343 8455665.15486257,397055.350587752 8455684.99082501,397045.331886932 8455698.88799628,397031.083067989 8455710.52562748,397003.360539466 8455728.21202746,396979.389870097 8455740.81946126,396968.159030166 8455745.9984071,396957.678562066 8455746.95821173,396948.443216455 8455752.88700494,396935.926024813 8455769.26367152,396920.91034235 8455787.13003487,396903.140547893 8455807.83582027,396891.612857567 8455826.46202896,396878.081427077 8455848.80748061,396858.274909078 8455884.19027854,396826.478933473 8455927.50146268,396801.188929017 8455960.25479583,396776.921409254 8455987.77919332,396767.166575452 8455999.68676957,396748.926767869 8456011.43437837,396720.98160155 8456019.79267707,396687.041706428 8456032.35012104,396675.794374808 8456042.50805342,396669.511041455 8456058.16486652,396663.986325777 8456068.3527928,396653.481120143 8456079.51052167,396636.742056223 8456093.12774993,396616.259378991 8456105.12530786,396596.032322933 8456116.99289224,396584.034619483 8456126.15102813,396573.298530209 8456131.5799231,396554.563971969 8456142.9576072,396542.285909812 8456162.69359,396540.282169648 8456166.42283092,396537.98157909 8456183.58933673,396527.468127612 8456197.72645916,396521.176548415 8456215.12291816,396517.647327056 8456228.68015863,396519.576854621 8456247.09641005,396523.782235212 8456258.31412672,396524.672786396 8456289.05786892,396524.120314828 8456306.72427297,396523.592580793 8456314.93260219,396519.073858119 8456325.87037584,396507.026679603 8456351.07524546,396477.960078459 8456396.75594729,396443.888249828 8456449.38523475,396419.835122017 8456487.36750357,396403.821692394 8456506.22366545,396388.278275896 8456532.54830715,396381.252816556 8456546.95537463,396379.702597829 8456563.37203307,396376.156884781 8456579.77869354,396369.60968441 8456601.90418996,396365.569220705 8456616.3212554,396352.054281904 8456634.18761876,396333.022873269 8456660.99216277,396321.973441913 8456684.34740888,396317.43822755 8456699.26437257,396316.391005324 8456714.19133423,396325.230550409 8456755.7828684,396343.066311622 8456791.19566023,396345.004085031 8456809.12201137,396344.797938924 8456871.83924546,396364.505506791 8456943.59463986,396367.91928633 8456965.50018105,396363.35108859 8456991.36491635,396353.181738467 8457053.50309498,395700.07186511 8457052.15254321,395693.673089937 8458434.19123324,395693.367993698 8458421.36384422,395692.980439016 8458378.52256444,395666.857604286 8458401.57787159,395657.55629192 8458414.46524841,395650.720486999 8458423.7933497,395640.033872792 8458433.40139401,395627.434222707 8458444.92904759,395614.562459761 8458456.04678461,395601.410338109 8458467.58443615,395580.589581262 8458483.23125129,395562.226086015 8458497.50834523,395544.134703629 8458506.58649739,395526.587546968 8458516.47448472,395506.871733256 8458537.20026605,395497.009703478 8458545.97847927,395486.32308927 8458553.66691431,395477.285643922 8458561.35534935,395465.485840734 8458565.76445189,395452.036868688 8458566.3343359,395440.2370655 8458569.64366229,395422.681662994 8458576.93217873,395414.749160781 8458585.71039195,395407.360884292 8458596.40821444,395401.88564368 8458601.8970972,395393.112065349 8458606.02625672,395384.321995329 8458606.58614276,395373.891002295 8458605.50636254,395367.038705685 8458610.45535519,395357.72090163 8458618.14379023,395344.84089284 8458625.97219678,395330.031356485 8458634.76040797,395313.597388803 8458648.21766878,395296.883062415 8458661.94487465,395286.748919775 8458671.00303089,395256.593867185 8458688.44947971,395233.843582772 8458702.46662656,395213.303184631 8458722.50254831,395209.765717428 8458734.56009403,395198.856465424 8458761.15468078,395186.042423388 8458796.38750924,395181.408258894 8458808.17510991,395176.229868676 8458823.80192911,395160.364864251 8458844.03781016,395138.447410112 8458864.62361998,395128.057646299 8458878.61077293,395121.230087222 8458895.06742323,395112.217379407 8458912.34390665,395098.265410858 8458932.08988741,395079.638048593 8458946.78689588,395055.518954027 8458963.2635421,395022.601543598 8458976.20090874,395000.37899322 8458981.84975893,394983.648175144 8458989.27824689,394972.672956386 8458989.84813089,394957.57481548 8458991.51779103,394937.265300979 8458995.93689154,394910.903336765 8458995.15705027,394880.698809109 8458994.65715203,394867.785816941 8458990.29803931,394856.249880771 8458991.13786837,394831.809198278 8458988.63837713,394821.369959399 8458987.83853994,394806.543931355 8458986.48881467,394787.594981163 8458985.42903038,394765.059088702 8458978.21049969,394741.42649895 8458970.8519975,394719.706945074 8458959.37433374,394702.398917897 8458957.21477331,394674.371293135 8458950.68610221,394652.396118086 8458944.69732121,394604.553729481 8458922.44185124,394583.378401329 8458908.77463317,394551.450492215 8458880.20044936,394540.986515803 8458870.08250883,394527.248939206 8458864.89356503,394516.537587466 8458863.81378482,394496.500185826 8458868.23288532,394480.033234767 8458870.18248848,394462.453094728 8458868.84276118,394444.04837026 8458863.11392727,394432.759809419 8458853.82581784,394422.295833007 8458842.32815815,394409.894083186 8458823.58197388,394407.123479502 8458814.82375659,394401.046292256 8458801.95637571,394394.713483837 8458796.20754587,394388.652788279 8458789.36893785,394386.71501487 8458781.15061066,394371.856003449 8458769.39300389,394353.39355807 8458747.50745863,394352.832840658 8458740.9287977,394348.973785527 8458737.37952014,394337.132753118 8458723.69230613,394338.212958721 8458716.5737551,394332.152263163 8458710.5549802,394320.838964789 8458689.05935557,394326.256484492 8458662.20482174,394332.803684863 8458644.65839326,394334.955850224 8458629.86140514,394329.431134546 8458616.16419317,394324.425907058 8458593.15887584,394326.033846696 8458577.81199965,394345.098238708 8458521.88338376,394345.856856383 8458496.12862606,394345.180697151 8458449.95802396,394342.929581658 8458428.59237287,394337.858387416 8458381.20201904,394333.595285915 8458328.19280891,394338.155237811 8458287.90101019,394341.68445917 8458272.28418895,394352.849332346 8458238.01116512,394358.786340239 8458200.04889224,394362.043448736 8458186.35168026,394361.425010414 8458161.41675569,394353.962521326 8458140.8809357,394344.826125846 8458114.04639779,394342.847123215 8458092.81072025,394344.727175715 8458078.28367719,394347.407075111 8458051.97903143,394350.359087369 8458027.86393998,394358.530719066 8458003.32893401,394365.910749711 8457989.06183804,394377.133343798 8457976.99429435,394422.370045606 8457952.38930263,394453.085815608 8457937.54232469,394483.801585611 8457924.61495601,394548.259350472 8457900.25991341,394568.552373285 8457890.91181619,394581.976607798 8457877.73449839,394585.250207984 8457871.15583746,394586.025317348 8457852.78957586,394580.211997119 8457835.26314332,394566.977417024 8457816.65693056,394545.793843028 8457799.70038201,394537.012018853 8457800.40023956,394521.633519241 8457800.43023345,394500.763287327 8457799.92033724,394473.271642445 8457787.91278134,394450.752241672 8457784.65344477,394409.564249414 8457784.18354042,394365.622145161 8457780.41430764,394326.611055797 8457773.90563246,394284.87059197 8457771.23617582,394240.359524461 8457761.71811319,394213.453334523 8457760.66832688,394156.293141863 8457744.87154227,394118.345766413 8457723.56587897,394087.522800435 8457696.77133292,394053.929230773 8457661.20857162,394020.566544752 8457608.92921293,393999.069628672 8457579.91511867,393973.4415446 8457546.81185674,393953.066063345 8457525.7461446,393931.066150763 8457510.43926028,393906.881089443 8457503.49067464,393865.140625617 8457500.00138487,393843.181942257 8457504.97037345,393806.94970242 8457507.21991557,393789.905542261 8457500.67124853,393768.985835282 8457482.07503373,393756.303726754 8457462.9189329,393749.063875463 8457424.57673734,393743.522668096 8457405.95052866,393719.296377554 8457381.87542907,393701.155520103 8457375.05681698,393686.304754526 8457367.4083738,393672.534194552 8457352.09149151,393646.114509427 8457329.66605614,393628.484894323 8457306.68073473,393614.714334348 8457293.55340676,393600.407794495 8457282.61563312,393577.344167999 8457282.65562497,393561.99040592 8457290.35405798,393559.285768991 8457306.25082224,393558.238546765 8457323.78725275,393557.752041952 8457347.9023442,393554.503179299 8457364.34899653,393544.096923798 8457376.96642828,393523.259675262 8457386.86441358,393479.35880023 8457397.62222386,393444.783975097 8457405.35065076,393424.474460596 8457410.86952741,393410.753375688 8457414.1788538,393395.960331021 8457425.16661728,393379.542855027 8457445.47248407,393365.294036084 8457457.00013766,393351.58119702 8457463.04890645,393336.746923131 8457459.2396818,393322.432137433 8457446.6622419,393309.783012283 8457441.20335304,393294.924000862 8457429.16580325,393275.661708587 8457412.21925267,393255.871682276 8457404.58080746,393239.388239529 8457400.77158281,393222.393554435 8457412.29923639,393220.241389073 8457428.74588872,393210.412342673 8457450.68142381,393203.329162422 8457469.32762843,393202.834411765 8457490.70327748,393197.944626097 8457510.43926028,393193.623803686 8457537.56373917,393178.336008361 8457570.47703976,393155.899066032 8457600.10100989,393130.691520019 8457619.87698454,393121.934433377 8457630.29486402,393108.213348468 8457633.0643003,393084.654971315 8457653.93005314,393078.660242512 8457670.37670547,393070.999853161 8457679.15491869,393058.952674644 8457692.33223649,393044.728593234 8457713.44793845,393030.529249356 8457741.97213243,393007.572818836 8457781.46409396,392989.011423326 8457822.59572173,392967.720653354 8457869.48617732,392948.054314708 8457906.77858656,392930.020653232 8457941.3315534,392920.191606832 8457960.52764609,392913.100180737 8457978.62396264,392910.939769532 8457993.42095075,392912.621921768 8458006.02838455,392923.118881557 8458029.84353704,392947.38640132 8458066.51607245,392963.37509341 8458090.06127989,392980.99646267 8458109.75727083,393007.473868705 8458152.72852416,393020.733186332 8458181.20272832,393030.174678051 8458220.64470002,393025.862101485 8458251.88834047,393016.676230939 8458306.9771273,393012.421375282 8458360.13630691,393012.495587881 8458386.44095267,393019.669472418 8458400.12816668,393028.525509192 8458425.32303834,393043.442241524 8458458.99618426,393049.527674614 8458474.33306249,393056.701559151 8458486.37061228,393061.129577538 8458501.7074905,393064.469144478 8458517.04436872,393066.167788403 8458537.8701297,393064.073343952 8458574.58265697,393063.017875882 8458590.47942123,393053.188829481 8458611.86506825,393033.47301577 8458630.81121181,393010.994844219 8458644.54841565,392986.859257965 8458656.09606515,392959.986051404 8458668.74349081,392945.176515048 8458674.7922596,392919.408251624 8458690.17912765,392898.01853152 8458700.62700101,392883.225486853 8458713.80431881,392872.827477196 8458726.97163864,392853.672380896 8458750.57683387,392835.053264476 8458768.68314838,392824.647008974 8458778.57113571,392808.213041292 8458793.93800783,392775.864594119 8458813.44403743,392756.643531065 8458814.0239194,392736.317524876 8458810.22469272,392715.430801274 8458804.78579979,392698.947358527 8458800.97657515,392676.427957754 8458797.72723654,392657.215140545 8458802.13633908,392643.494055636 8458805.44566548,392631.455122964 8458818.62298327,392622.162056442 8458836.71929982,392617.808250654 8458850.97639783,392620.595346026 8458865.22349787,392620.644821092 8458884.94948271,392622.359956706 8458910.15435233,392620.752017068 8458924.95134044,392612.011422114 8458942.49776892,392600.52496101 8458956.76486489,392595.082703774 8458975.68101456,392597.886290835 8458997.04666565,392604.532441338 8459018.9622048,392621.617830719 8459041.94752621,392631.001601528 8459058.37418261,392640.946089749 8459081.36950198,392647.592240251 8459101.63537692,392649.826864055 8459115.872479,392648.787887674 8459138.89779226,392642.257178992 8459159.18366313,392634.646264707 8459189.87741551,392616.084869196 8459229.63932209,392597.498736153 8459261.45284654,392569.017589955 8459287.80748213,392543.257572374 8459307.03356871,392523.51702113 8459317.47144411,392488.397970273 8459329.58897762,392454.928088276 8459338.41718067,392433.521876484 8459343.92605935,392413.228853671 8459353.28415454,392397.875091592 8459360.98258755,392365.493661042 8459367.06135023,392312.802715991 8459378.37904655,392296.879990655 8459379.50881659,392272.150703611 8459373.52003559,392220.523472474 8459370.3206868,392189.774719095 8459371.46045481,392185.915663964 8459365.99156798,392162.819054091 8459352.33434787,392147.399325258 8459338.10724376,392142.938323494 8459313.45226221,392123.115313806 8459293.76626923,392111.571131792 8459287.20760423,392096.184386335 8459283.94826766,392079.709189432 8459283.14843046,392048.952190208 8459283.19842029,392030.811332757 8459274.46019893,392009.932855 8459271.21086032,391973.123406062 8459264.69218718,391953.902343008 8459265.82195722,391934.664788266 8459258.73340007,391908.269840675 8459243.98640178,391880.753458259 8459224.30040881,391866.45516425 8459217.2018537,391847.786572764 8459216.68195952,391828.598493087 8459228.21961107,391816.559560415 8459244.68625933,391803.415684607 8459258.9533553,391789.73582892 8459276.50978174,391778.777101851 8459285.29799293,391749.702254863 8459295.4859192,391698.701707892 8459321.33065858,391686.08556612 8459328.46920555,391675.704048151 8459345.47574392,391653.811331545 8459372.91015972,391638.46581531 8459384.44781127,391621.454638528 8459390.50657802,391611.048383026 8459399.28479124,391600.658619213 8459417.94099383,391600.699848435 8459432.73798194,391602.950963928 8459453.00385688,391612.326488892 8459468.33073714,391616.2185274 8459484.21750344,391620.646545787 8459497.08488432,391633.336900158 8459518.99042551,391655.378041961 8459547.99452181,391668.068396333 8459571.53972925,391674.145583579 8459583.57727904,391678.037622087 8459600.56382148,391710.039743799 8459657.22228881,391717.782591593 8459677.48816375,391726.086156799 8459702.68303541,391725.047180418 8459725.14846264,391721.245846198 8459740.50533679,391722.38377271 8459754.75243684,391708.184428833 8459783.81652093,391697.811156709 8459807.94161033,391689.631279167 8459827.13770302,391679.225023665 8459839.21524468,391651.288103191 8459864.47010412,391623.887162595 8459884.51602383,391580.538759131 8459899.3829977,391539.416733627 8459920.81863454,391486.767017797 8459947.76315006,391462.66441492 8459969.17879097,391434.166777033 8459992.7839862,391383.693964098 8460010.9502885,391344.171632387 8460017.31899217,391317.248950761 8460011.89009721,391256.815157916 8459999.38264307,391207.900809552 8459985.76541481,391177.143810328 8459983.07596224,391153.502974732 8459973.80784874,391124.378652678 8459967.54912269,391101.315026182 8459967.58911455,391078.812117099 8459972.00821505,391056.309208015 8459976.43731352,391039.306277077 8459983.58585845,391003.107020617 8460000.63238868,390983.349977684 8460005.05148919,390956.460279435 8460011.67014198,390933.965616196 8460018.83868285,390916.418459534 8460030.36633642,390908.222090304 8460042.98376818,390898.937269626 8460062.17986087,390889.652448949 8460081.37595356,390869.408901202 8460110.18009057,390819.562772433 8460157.9403691,390802.040353304 8460176.05668158,390797.125830104 8460185.92467298,390798.280248305 8460207.30032202,390796.128082944 8460224.83675254,390797.826726869 8460243.46296122,390800.663297307 8460276.0663249,390810.591293839 8460293.03287141,390831.49450913 8460306.15020142,390833.72088709 8460316.01819282,390833.753870467 8460329.16551672,390837.093437407 8460345.05228301,390847.557413818 8460355.99005666,390859.662313245 8460365.83805213,390882.750677273 8460374.01638745,390893.214653685 8460385.51404714,390908.057173418 8460390.96293803,390928.391425452 8460397.78155012,390943.266928561 8460415.28798674,390957.548730882 8460416.90765706,390974.007436097 8460409.20922405,390988.280992573 8460408.63934005,391007.518547316 8460415.17800912,391023.482501873 8460430.49489142,391065.214719855 8460427.14557316,391088.245362973 8460416.68770183,391120.651531056 8460417.73748815,391139.87259411 8460417.69749629,391162.383749038 8460417.6675024,391186.008092946 8460420.90684304,391219.519204165 8460425.78584993,391243.704265485 8460435.0639614,391260.773163178 8460449.83095562,391268.516010972 8460471.73649681,391272.424541168 8460494.74181414,391265.885586641 8460514.48779491,391258.233443135 8460526.00545052,391251.669751075 8460536.97321806,391249.501094025 8460547.66104259,391244.042345101 8460560.27847435,391245.732743182 8460573.97568632,391243.605315354 8460600.28033208,391242.533355595 8460611.24809963,391242.582830661 8460629.32442024,391242.624059882 8460645.2211845,391236.629331079 8460661.66783683,391222.965967081 8460686.90270035,391210.951771942 8460711.30773278,391206.589720309 8460722.82538839,391198.97056018 8460748.59014405,391197.395603919 8460774.89478982,391200.174453447 8460788.59200179,391211.223884803 8460810.48754501,391218.389523497 8460820.34553845,391227.204331049 8460833.48286438,391248.107546339 8460844.13069705,391283.267826417 8460851.19925826,391309.629790631 8460851.69915651,391317.883880772 8460856.61815526,391345.375525654 8460870.27537537,391373.930884451 8460871.31516373,391401.942017525 8460873.46472619,391432.732000126 8460886.56206027,391480.030163008 8460911.14705606,391503.126772881 8460925.90405232,391522.916799191 8460933.54249754,391539.408487783 8460937.35172218,391550.416689918 8460948.28949583,391557.079332109 8460974.30420061,391554.514874533 8461040.62070208,391537.586156194 8461078.46299939,391534.881519264 8461091.62032125,391537.091405536 8461097.08920808,391546.969927002 8461095.97943397,391551.373207856 8461097.61910022,391540.406234943 8461105.57748031,391529.472245406 8461123.13390675,391510.894358207 8461158.78664974,391481.868986286 8461188.4306158,391481.885477974 8461194.99927877,391470.967980126 8461218.58447807,391454.501029067 8461221.35391436,391439.65026349 8461210.96602878,391418.227560009 8461209.35635642,391379.265945711 8461220.65405681,391349.069663899 8461223.17354397,391332.330599978 8461225.94298027,391312.301444183 8461231.1819139,391274.15616847 8461238.23047918,391245.889414224 8461245.94890812,391219.007961819 8461254.48717018,391198.987051868 8461264.93504354,391177.061351885 8461279.4920805,391145.537489142 8461297.4884174,391139.245909944 8461305.99668556,391141.744400765 8461317.2244002,391133.515048158 8461320.25378357,391127.454352601 8461312.59534243,391115.646303569 8461310.96567414,391103.302274658 8461317.01444293,391090.150153006 8461325.26276401,391079.174934248 8461328.02220234,391067.927602628 8461333.52108305,391053.703521217 8461352.16728767,391040.304024236 8461373.97284921,391007.69995589 8461400.60742782,390977.289282127 8461425.59234222,390963.592934751 8461438.21977194,390952.634207682 8461445.36831687,390934.254220746 8461453.33669493,390920.277514664 8461462.54482065,390892.299364968 8461472.18285885,390876.121018459 8461481.52095811,390854.459185494 8461492.51871955,390837.167650005 8461495.01821078,390810.550064618 8461498.89742118,390782.547177389 8461500.17716069,390755.649233295 8461504.05637109,390735.892190362 8461508.4754716,390689.814412436 8461529.37121833,390686.664499915 8461556.40571553,390678.624801727 8461557.79543266,390664.771783309 8461560.37490761,390646.622680014 8461560.56486895,390629.68571583 8461554.31614086,390617.523095493 8461547.83745958,390602.260037702 8461539.91907134,390588.901769942 8461535.82990368,390578.157434825 8461534.13024964,390567.413099707 8461533.50037785,390552.611809196 8461534.1702415,390542.337487203 8461537.23961674,390531.593152085 8461539.82908966,390524.897526517 8461541.95865619,390521.071454764 8461545.75788287,390509.370601708 8461549.0572113,390501.726704045 8461550.94682667,390496.704984869 8461554.50610219,390488.574582393 8461560.92479569,390478.531144041 8461565.42387991,390469.452469471 8461570.1629153,390462.756843902 8461575.63180212,390456.061218334 8461579.90093315,390452.466030221 8461586.56957577,390444.319136057 8461600.73669209,390442.158724851 8461608.59509254,390438.794420378 8461615.74363747,390436.386633844 8461625.27169806,390434.704481608 8461633.61000082,390431.818436104 8461642.4282059,390429.658024898 8461648.6169462,390425.59282366 8461650.51655954,390420.340220844 8461652.64612608,390417.940680154 8461655.9754484,390416.258527917 8461662.17418667,390411.475938226 8461666.2133645,390403.353781594 8461669.76264206,390395.231624963 8461670.6924528,390391.405553209 8461671.87221266,390384.470798156 8461676.39129282,390374.913864617 8461680.41047472,390361.778234654 8461683.34987642,390352.699560084 8461685.46944498,390343.876506687 8461683.05993543,390336.47173851 8461683.98974617,390320.9448137 8461685.84936765,390310.439608067 8461685.81937376,390299.456143465 8461688.16889552,390287.037901955 8461690.51841728,390277.480968416 8461691.20827686,390270.554459208 8461693.80774775,390262.201418936 8461694.85753407,390250.492320036 8461696.96710467,390232.34321674 8461698.82672615,390208.455005815 8461704.7155275,390202.493260389 8461703.9756781,390194.610233242 8461704.19563332,390188.161983002 8461707.75490884,390181.227227949 8461711.06423524,390165.4694195 8461711.97405005,390157.833767682 8461710.04444282,390148.524209472 8461710.01444892,390139.445534902 8461713.4437509,390122.492079029 8461712.92385672,390111.277730787 8461710.02444689,390098.628605637 8461706.64513473,390080.735123514 8461700.39640665,390068.333373693 8461694.63757884,390061.423356173 8461688.16889552,390048.790722712 8461678.12094075,390036.388972891 8461673.19194403,390028.027686775 8461674.60165709,390016.31034203 8461682.6700148,389998.8621355 8461693.34784136,389987.862179209 8461701.90609935,389979.979152062 8461704.50557024,389963.973968283 8461706.83509607,389945.123968223 8461703.92568827,389925.548333864 8461701.47618686,389910.755289197 8461698.80673022,389887.36182893 8461696.59717997,389872.799667903 8461694.40762564,389857.520118423 8461694.23766024,389852.27576145 8461690.88834198,389837.952729908 8461690.12849665,389830.077948606 8461687.47903594,389822.681426272 8461687.45904001,389807.880135761 8461686.69919467,389792.361456796 8461684.73959354,389778.516684223 8461682.55003922,389770.163643951 8461682.05014098,389754.892340315 8461678.67082882,389744.164496886 8461671.24234087,389738.672764585 8461670.27253827,389727.920183623 8461674.41169576,389715.254566784 8461681.29029564,389707.602423277 8461687.22908681,389702.094199288 8461693.88773147,389691.572501966 8461702.44598946,389673.885165951 8461711.69410703,389661.219549113 8461717.61290228,389655.233066154 8461726.66106055,389655.925717075 8461737.38887694,389661.285515867 8461745.63719801,389677.620533417 8461754.86531966,389691.209684817 8461761.46397652,389695.142952546 8461764.81329477,389696.09122464 8461769.1124197,389692.858853676 8461772.67169522,389685.454085498 8461775.40113965,389675.30345117 8461778.5804925,389656.313271757 8461782.27973953,389647.473726671 8461784.3993081,389630.990283924 8461788.6484432,389616.172501724 8461795.51704511,389609.245992515 8461798.59641832,389564.355616168 8461799.17630028,389551.459115689 8461801.28587089,389539.527378993 8461800.89595025,389525.674360576 8461801.08591159,389498.941333368 8461800.29607236,389486.762221343 8461800.01612934,389478.648310556 8461799.75618225,389471.004412893 8461802.35565314,389465.496188904 8461809.25424895,389455.205375222 8461821.26180484,389443.949797758 8461837.20855893,389428.159005931 8461851.7056081,389415.254259608 8461860.49381928,389402.81952641 8461869.04207931,389387.754368881 8461879.96985499,389355.001875338 8461900.49567702,389348.067120285 8461906.19451704,389338.262811417 8461913.32306604,389328.705877878 8461917.34224795,389317.475037947 8461920.8915255,389304.570291623 8461928.4799809,389289.744263579 8461938.45794991,389268.93999842 8461953.1749543,389233.078821577 8461979.8995146,389212.991944872 8461992.71690566,389179.522062875 8462015.50226776,389169.725999851 8462020.24130314,389161.117338406 8462024.99033649,389146.777815176 8462030.90913174,389127.894831738 8462041.93688707,389120.25917992 8462042.39679346,389093.02315621 8462049.70530583,389085.379258548 8462050.39516541,389073.925780821 8462048.21560906,389063.181445703 8462048.42556632,389040.505373889 8462046.92587158,389024.26930647 8462048.18561516,389024.261060626 8462052.95464444,388984.615041251 8462057.60369814,388959.300299263 8462060.39313035,388958.838531982 8462052.28478079,388953.82505865 8462052.26478486,388942.363335079 8462056.04401561,388927.06729391 8462062.44271317,388917.032101401 8462065.03218609,388906.526895768 8462066.9118035,388886.456510752 8462071.86079615,388873.329126633 8462073.72041762,388856.6065544 8462077.00974809,388839.405723199 8462082.32866544,388822.435775638 8462089.66717171,388809.052770346 8462097.2556271,388793.756729177 8462106.27379148,388782.756772886 8462115.06200266,388766.504213778 8462121.69065342,388748.107735154 8462129.50906201,388732.325189172 8462138.637204,388711.290040373 8462150.50478839,388684.524029788 8462164.01203903,388666.358434804 8462173.02020544,388652.744545871 8462178.70904749,388638.644152125 8462184.62784274,388629.087218586 8462185.78760667,388615.242446013 8462187.53725054,388602.824204503 8462188.44706535,388591.840739901 8462186.74741131,388581.104650628 8462184.56785495,388573.221623481 8462185.25771453,388566.765127397 8462191.20650367,388561.982537705 8462194.52582803,388561.496032892 8462201.20446862,388560.292139625 8462206.20345109,388560.044764296 8462208.83291587,388556.466067871 8462208.8229179,388551.939099353 8462204.99369733,388545.499094958 8462198.29506082,388536.939908579 8462184.67783256,388528.347738822 8462180.11876055,388526.690324119 8462173.68007113,388528.149838559 8462162.95225474,388531.275013547 8462150.43480263,388520.547170118 8462142.77636149,388491.439339753 8462135.05793255,388473.776741271 8462134.28808925,388447.027222375 8462135.63781452,388435.095485679 8462135.59782266,388430.560271316 8462135.58782469,388409.31897641 8462129.08914748,388395.490695526 8462120.22095258,388380.722388391 8462107.30358187,388370.959308745 8462094.86611348,388370.497541464 8462086.99771507,388372.179693701 8462079.84917014,388377.193167033 8462081.05892389,388394.839273826 8462089.93711676,388404.857974646 8462095.44599545,388432.770157588 8462103.6443267,388443.514492705 8462104.62412727,388448.288836553 8462104.64412319,388474.312721151 8462105.07403569,388487.20922163 8462102.25460957,388497.005284653 8462097.75552535,388510.874794759 8462088.49740981,388522.583893659 8462081.84876312,388539.067336407 8462078.08952831,388553.159484309 8462074.19032198,388561.28164094 8462072.31070457,388564.868583209 8462069.46128456,388576.585927954 8462062.82263584,388589.729803761 8462056.18398711,388602.156291115 8462049.30538723,388619.365368161 8462040.28722285,388640.6314006 8462032.00890788,388659.506138194 8462025.75018183,388673.60653194 8462020.06133978,388692.481269534 8462013.44268698,388700.850801494 8462005.36433131,388712.089887269 8461998.47573346,388721.646820808 8461993.49674692,388736.703732493 8461986.15824065,388751.521514693 8461980.23944541,388765.613662594 8461978.48980154,388797.846667947 8461975.73036322,388812.169699489 8461976.72016175,388827.68013261 8461980.10947186,388846.530132671 8461986.83810227,388866.089275341 8461993.8166818,388893.770574642 8462002.36494182,388915.960141643 8462008.873617,388936.475802251 8462013.94258523,388953.668387608 8462015.0623573,388952.266594078 8461998.36575585,389020.550430693 8461998.0958108,389022.191353708 8462013.36270326,389027.683086009 8462012.1829434,389058.003055485 8462013.23272972,389075.434770327 8462013.04276839,389083.30955163 8462013.66264221,389100.502136987 8462012.52287421,389107.66777568 8462012.07296579,389115.789932311 8462009.71344606,389128.917316431 8462009.03358444,389138.713379454 8462006.91401587,389148.748571962 8462003.37473628,389160.226787222 8461996.24618728,389170.261979731 8461990.31739407,389180.544547568 8461983.90869854,389194.644941314 8461975.37043648,389220.22355032 8461961.7332123,389237.432627366 8461953.2049482,389246.511301935 8461946.78625471,389260.380812041 8461937.05823482,389272.576415755 8461928.27002363,389285.002903109 8461921.8613281,389297.676765792 8461913.08311488,389323.255374798 8461897.05637708,389335.211849027 8461888.74806821,389348.11659535 8461881.62951717,389361.268717002 8461873.80111062,389370.833896386 8461865.72275495,389385.420794945 8461854.56502607,389396.420751236 8461846.4866704,389403.594635774 8461839.11817023,389417.950650693 8461825.68090535,389427.754959561 8461818.32240315,389437.320138944 8461809.76414516,389448.328341079 8461800.2560805,389451.915283348 8461795.9769515,389443.323113592 8461795.2371021,389427.095292017 8461791.36788966,389413.976153742 8461785.3691107,389402.530921859 8461776.8708405,389391.333065306 8461767.53274124,389380.357846548 8461761.7839114,389364.847413427 8461757.68474577,389351.728275152 8461755.49519145,389337.40524361 8461754.25544379,389327.378296946 8461751.84593424,389316.172194548 8461746.32705759,389305.436105274 8461740.09832544,389290.420422811 8461730.63025263,389271.81779808 8461720.56230194,389259.894307228 8461713.60371833,389248.68820483 8461707.61493733,389235.808196039 8461699.70654706,389216.727312338 8461690.57840507,389203.138160939 8461683.14991712,389177.139013873 8461668.88282114,389162.354215051 8461661.92423754,389143.990719804 8461653.04604467,389126.814626135 8461646.31741427,389113.217228891 8461639.83873298,389095.084617284 8461632.87015142,389057.871121977 8461621.19252837,389041.882429887 8461617.56326709,389017.062438556 8461611.52449626,389003.456795467 8461608.38513527,388999.399840074 8461607.65528383,388987.344415713 8461609.64487886,388971.941178568 8461611.03459598,388930.629498645 8461613.95400175,388917.732998167 8461615.34371887,388904.242796898 8461616.61346042,388895.526939477 8461617.18334442,388884.180657726 8461619.17293945,388874.145465218 8461622.66222921,388867.103514189 8461625.14172452,388855.03159814 8461629.280882,388842.489668966 8461632.94013717,388828.760338213 8461636.94932112,388813.587984708 8461641.61837074,388803.5527922 8461644.80772156,388793.641287356 8461646.68733897,388784.678054607 8461650.47656768,388770.816790345 8461657.58512076,388760.295093024 8461664.35374302,388748.825123608 8461671.89220859,388742.36038168 8461678.31090209,388734.469108689 8461685.31947551,388723.230022913 8461694.82754017,388714.382231984 8461702.66594469,388697.882297547 8461713.76368577,388687.962546859 8461719.81245456,388681.027791806 8461724.92141465,388671.940871392 8461731.57006134,388649.223570357 8461748.37664041,388638.94100252 8461755.73514261,388625.434309563 8461765.47316046,388617.543036572 8461771.0520249,388610.492839699 8461775.80105825,388601.636802925 8461784.89920635,388593.984659418 8461792.14773093,388583.462962097 8461799.38625755,388574.615171167 8461806.15487981,388563.738902541 8461813.4034044,388549.391133466 8461821.88167867,388539.471382778 8461827.22059195,388535.051610235 8461830.41994073,388525.73380618 8461833.84924271,388517.009702915 8461838.3583249,388506.372563773 8461842.49748238,388496.700188414 8461846.04675994,388482.599794668 8461852.62542087,388471.368954737 8461857.83436061,388466.71005271 8461860.08390272,388461.325516385 8461863.05329831,388455.11639563 8461867.20245376,388450.564689578 8461871.48158275,388441.848832158 8461875.45077484,388434.551259956 8461879.13002593,388427.261933598 8461883.99903486,388416.987611605 8461888.84804786,388409.220026278 8461893.83703237,388401.567882772 8461898.46609014,388393.56116796 8461903.80500341,388386.271841603 8461907.42426672,388378.504256276 8461910.73359312,388372.171447857 8461913.22308639,388365.838639437 8461915.11270177,388358.310183595 8461918.06210142,388351.507362051 8461920.79154585,388344.218035693 8461923.87091906,388338.248044423 8461924.21084986,388327.981968274 8461924.59077253,388323.323066247 8461926.25043471,388315.547235076 8461932.8990814,388310.278140571 8461940.87745743,388303.937086307 8461948.60588432,388297.117773075 8461954.07477115,388291.617794929 8461958.8238045,388287.791723176 8461962.15312682,388281.219785272 8461964.39267097,388269.64261988 8461963.94276255,388262.237851703 8461965.11252445,388249.580480708 8461968.53182846,388241.334636412 8461970.89134818,388226.525100057 8461973.95072546,388219.845966177 8461973.45082721,388213.521403602 8461971.1712912,388207.081399207 8461969.95153948,388200.031202334 8461970.17149471,388191.076215428 8461970.74137871,388185.567991439 8461967.25208895,388110.316416394 8461981.21924597,388051.350383833 8462015.00236951,388000.020003091 8462014.66243871,387985.515562974 8462027.65979313,387981.202986407 8462118.47130871,387958.023918091 8462151.62456046,387885.60066764 8462194.81576902,387778.849967384 8462244.9855571,387731.279691641 8462251.004332,387706.129866538 8462261.65216466,387670.870636329 8462258.68276908,387640.204341392 8462230.60848351,387614.122735884 8462234.52768577,387583.860487317 8462259.80254115,387547.545789038 8462263.91170474,387503.315080234 8462258.32284234,387467.214773907 8462265.36140966,387456.594126454 8462214.28180676,387410.170023067 8462218.54093983,387410.681265414 8462236.20734388,387377.186645883 8462247.56503206,387383.43699586 8462273.87967579,387347.12229758 8462299.30450064,387296.822647375 8462318.14066659,387271.277021746 8462297.21492597,387229.750949871 8462300.07434394,387177.686688987 8462314.11148672,387113.839116603 8462304.84337322,387069.286819872 8462308.69258972,387044.244190745 8462322.34980983,387037.342419069 8462355.48306566,387021.790756727 8462383.22741837,386978.170240401 8462395.8248542,386936.990493987 8462412.36148822,386915.872886745 8462433.03727972,386779.173280007 8462497.54414953,386723.357159967 8462503.86286338,386696.838524711 8462543.52479031,386569.440230339 8462590.22528456,386517.788261669 8462600.93310501,386490.560483804 8462600.89311315,386451.120610536 8462610.58114118,386408.547316436 8462634.11635066,386364.712408158 8462672.49853808,386347.610527089 8462638.71541453,386319.022184914 8462649.98312102,386203.621593992 8462681.79664547,386199.012167031 8462722.68832209,386182.528724283 8462730.16679987,386115.86107315 8462734.65588613,386084.864944442 8462757.27128283,386066.996199852 8462788.78486833,386070.253308349 8462831.02627021,386033.633513831 8462863.33969291,385945.064900248 8462892.83368949,385921.927061153 8462919.48826403,385915.264418962 8462947.732515,385809.610415998 8463043.2430741,385756.845258348 8463047.83214001,385733.748648475 8463104.30064601,385682.311071757 8463138.10376548,385682.212121625 8463148.17171618,385646.713761931 8463167.83771322,385635.730297329 8463167.82771526,385618.982987564 8463161.75895054,385604.50328498 8463161.97890576,385585.603809854 8463175.93606482,385582.206522004 8463195.07216973,385588.11054652 8463212.09870403,385588.80319744 8463219.84712686,385574.142086282 8463251.4906859,385566.778547326 8463295.67169298,385549.594207813 8463305.14976375,385546.213411652 8463312.04835956,385543.624216543 8463338.40299515,385535.048538475 8463361.56827993,385525.392654804 8463371.12633441,385520.634802646 8463384.62358708,385509.131849853 8463417.26694262,385506.930209426 8463420.31632193,385504.382243538 8463423.85560152,385500.729334515 8463429.21451073,385496.911508606 8463434.53342808,385493.258599583 8463439.38244108,385488.888302106 8463445.31123429,385483.643945134 8463452.89968968,385479.512777142 8463458.52854395,385475.942326561 8463462.98763631,385473.171722878 8463466.13699527,385471.407112199 8463469.53630335,385467.259452518 8463476.64485642,385461.751228528 8463485.8629801,385460.473122662 8463487.71260361,385456.57283831 8463493.65139479,385451.94691966 8463501.03989088,385450.116342227 8463504.20924577,385445.449194355 8463511.68772355,385441.243813764 8463517.36656764,385437.871263447 8463521.28576989,385434.473975597 8463524.77505966,385432.082680751 8463528.53429448,385429.9882363 8463530.64386508,385427.613433143 8463533.53327695,385423.317348265 8463537.36249752,385419.56548911 8463540.94176897,385415.854859177 8463544.39106688,385408.43359931 8463551.10969932,385405.844404201 8463552.77935947,385402.727475058 8463555.60878354,385398.670519664 8463558.54818524,385396.815204697 8463560.57777212,385391.142063822 8463564.75692147,385384.298013056 8463569.86588155,385374.930733936 8463576.86445701,385366.272597425 8463582.76325633,385360.145935113 8463586.72245045,385351.98254926 8463590.8716059,385346.103262277 8463593.97097503,385338.418135393 8463597.70021595,385679.961006132 8463822.134533,386053.967765865 8464068.69434647,386178.892306949 8464150.83762644,388174.320659819 8465459.13132705,388672.938618552 8465788.75423326,388874.59074081 8465922.5270042,388862.353907875 8466025.67600852,388493.987305641 8469274.96462524,388303.434089805 8470710.90234428,388156.064360548 8470769.62039239,388156.377702631 8470802.37372555,388279.199553419 8470887.29643977,388320.684396073 8470933.18709886,388405.270266861 8470974.34872054,388482.319435962 8471016.66010818,388488.685227759 8471104.8921488,388592.846732905 8471160.9307423,388763.123417617 8471246.46333239,388785.370705528 8471307.62088395,388865.182232468 8471306.83104472,388971.190806737 8471334.84534249,389072.655920799 8471341.38401157,389106.455636568 8471374.4272857,389132.504258699 8471389.24426975,389198.066966697 8471368.12856779,389247.640982604 8471364.40932483,389342.831009157 8471340.31422932,389440.453559777 8471340.96409704,389697.550739081 8471376.09694585,389715.394746137 8471429.76602166,389784.008416524 8471440.38386043,389814.971561855 8471510.06967609,389827.851570646 8471504.0209073,389798.034597671 8471441.32366914,389827.496999341 8471422.72745434,389864.726986337 8471424.5070921,389869.443609274 8471412.07962168,389905.997437039 8471401.4917768,389947.886326062 8471384.92514889,389953.699646291 8471374.09735286,389976.829239541 8471368.47849656,389996.108023505 8471356.44094677,390015.032236164 8471360.56010833,390045.360451485 8471421.10778402,390055.552315035 8471416.69868148,390027.936982487 8471357.21079007,390055.593544256 8471321.93796975,390063.575521534 8471312.69985014,390094.299537381 8471310.78024087,390102.388710636 8471310.70025715,390128.255924192 8471357.8306639,390140.047481535 8471351.78189511,390113.083570688 8471302.52192183,390119.432870795 8471291.15423569,390120.801680949 8471269.05873317,390129.286654729 8471256.06137874,390239.508855433 8471225.34763044,390258.391838871 8471275.2374755,390270.735867782 8471269.18870671,390251.325150309 8471220.92852993,390281.859511737 8471202.32231717,390288.134599247 8471184.48594771,390314.908855676 8471166.99950703,390334.872044716 8471167.86932998,390349.895973023 8471209.72081123,390363.303715849 8471203.12215437,390348.832259109 8471162.35045333,390392.86506765 8471144.68404927,390522.745361156 8471136.39573633,390561.410125059 8471099.79318668,390576.079482062 8471033.75662823,390592.406253768 8470997.33404194,390656.146630176 8470960.15161032,390758.11474074 8470895.01486871,390815.472833663 8470874.37906907,391079.125459182 8470884.11708692,391116.545100597 8470926.28850305,392652.259388123 8470959.21180161,392658.443771345 8470998.9137204,392690.718005919 8471007.12204962,392761.426120757 8470978.52786988,392979.635898361 8470962.23118702,393294.684871377 8470985.21650843,393608.818555677 8471059.28143273,393749.624592875 8471094.0843487,393856.705126902 8471100.19310527,393905.248412272 8471092.74462139,393967.628224372 8471067.89967851,394020.253202668 8471063.56056172,394087.99281356 8471074.56832113,394163.277371982 8471097.133728,394199.20451558 8471096.67382162,394344.298391811 8471113.95030504,394455.881156824 8471101.0129384,394490.546686245 8471092.12474757,394613.277832746 8471096.15392744,394759.641568999 8471105.77196971,394812.489185092 8471109.84114145,394859.18540134 8471100.6130198,395034.508542761 8471127.25759638,395149.521579001 8471138.09539038,395305.104169178 8471171.92850374,395441.144108373 8471219.88874158,395621.018955845 8471279.62658211,395652.056313775 8471348.01266232,395885.990916452 8471506.14047587,396091.823681768 8471730.14488042,396859.066510131 8472267.85543099,396980.64323843 8472439.56048093,397042.734445979 8472449.87838075,397141.618610776 8472418.97467111,397423.263668549 8472465.74515112,397431.113712319 8472522.5035981,397530.896674145 8472530.6019497,397549.507544721 8472486.04101995,398170.493832806 8472850.4168523,398207.097135636 8473040.26820861,398357.187993511 8473122.45148045,398484.437862686 8473059.52428909,398705.212097867 8473123.2913095,399042.838192565 8473112.22356231,399175.670498329 8473217.38215758,399446.868071379 8473311.47300566,399502.296636737 8473410.34288098,399651.65361447 8473483.04808205,399924.533339756 8473495.5255423,400249.403113329 8473676.75865283,400337.75733496 8473749.47385186,400527.700358318 8473731.10759026,400644.741872255 8473688.59624332,400645.986994743 8473314.41240736,400688.708714041 8473314.72234427,400692.510048261 8473297.01594835,400662.981679837 8473278.10979665,400707.822581119 8473217.02223084,400695.890844423 8473136.24867207,400739.428902305 8473030.20025791,400763.73765129 8472986.35918164,400786.702327654 8472921.6023627,400802.196269086 8472860.77474399,400798.559851752 8472820.45295137,400812.190232373 8472764.50433955,400813.303421353 8472682.26107993,400856.602349751 8472684.24067698,400890.187673569 8472656.57630799,400890.830849424 8472577.58238697,400911.989685887 8472483.08162233,400987.50512795 8472448.90857815,401001.547800786 8472416.30521447,401049.184043283 8472352.43821441,401064.372888477 8472326.22355033,401127.296926299 8472194.21042122,401138.766895715 8472165.77620892,401162.25106027 8472070.93551347,401138.131965704 8472030.56373103,401124.551060149 8471957.79854218,401147.31783625 8471873.64567125,401164.386733942 8471840.47242357,401158.919739174 8471785.39363469,401133.448326144 8471723.04632531,401172.319236155 8471622.09687328,401142.089970966 8471601.1011469,401148.191895745 8471579.50554262,401141.273632381 8471549.75159895,401153.947495064 8471505.18067123,401176.367945704 8471471.55751513,401192.274179351 8471437.67441193,401211.841567866 8471432.62543964,401231.977919636 8471383.65540734,401294.88546577 8471361.52991093,401319.235443976 8471301.89205004,401312.836668803 8471244.95363969,401317.586275117 8471205.47167613,401415.917968347 8471170.20885377,401439.682491608 8471160.98073213,401453.725164444 8471129.30717919,401477.300033286 8471101.03293433,401494.995615145 8471100.38306661,401516.781135775 8471040.27530137,401532.662631889 8471018.00983344,401538.146118346 8470957.97205396,401551.075602202 8470901.55353778,401543.679079868 8470879.22808207,401526.956507636 8470861.28173499,401518.619959053 8470837.09665779,401512.691197004 8470782.01786892,401516.566743823 8470710.82236056,401518.018012419 8470685.96741971,401533.421249564 8470671.25041532,401550.391197125 8470578.36932099,401557.903161279 8470550.5049927,401566.940606627 8470461.5530986,401493.668034213 8470321.70156497,401489.149311539 8470261.51381601,401465.104429572 8470183.61967114,401476.821774317 8470149.2666636,401473.894499592 8470103.6059577,401487.508388524 8470067.68326966),(396353.181738467 8457053.50309498,396364.883805278 8457053.52729343,396353.126241663 8457053.84219928,396353.181738467 8457053.50309498),(396364.883805278 8457053.52729343,396380.749820054 8457053.10234988,396391.461171795 8457053.5822522,396364.883805278 8457053.52729343),(401487.508388524 8470067.68326966,401332.618449269 8470067.0733938,401323.927329381 8470066.86343654,401326.170199029 8470066.49351183,401335.669411658 8470066.51350776,401487.508388524 8470067.68326966))', 32702));