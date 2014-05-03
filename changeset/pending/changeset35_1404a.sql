-- 2 Apr 2014
-- Changeset containing updates for version 1404a of SOLA.

-- Ticket #138 Config for Measure Tool
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'MeasureTool', 'Measure Tool','c', 'Allows user to measure a distance on the map.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'MeasureTool');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'MeasureTool', ag.id FROM system.appgroup ag WHERE ag."name" = 'Technical Division'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'MeasureTool'
					 AND    appgroup_id = ag.id));
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'MeasureTool', id FROM system.appgroup ag WHERE "name" = 'Quality Assurance'
     AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'MeasureTool'
					 AND    appgroup_id = ag.id));


-- Ticket 137 - Capture Fees paid by service
-- Fix the fees related to cancelled services
UPDATE application.service s
SET    base_fee = 0,
       area_fee = 0,
       value_fee = 0,
       change_user = 'andrew'
WHERE  s.status_code = 'cancelled'
AND    s.base_fee + s.area_fee + s.value_fee > 0
AND    NOT EXISTS (SELECT a.id FROM application.application a
                   WHERE a.id = s.application_id
                   AND   a.status_code = 'annulled');

WITH service_total AS (
 SELECT a.id AS app_id,
        SUM(s.base_fee + s.area_fee + s.value_fee) AS service_fee
 FROM   application.service s, application.application a
 WHERE  s.application_id = a.id
 AND    a.status_code != 'annulled'
 AND    a.total_amount_paid > 0
 AND    EXISTS (SELECT c.id FROM application.service c
               WHERE c.application_id = s.application_id
               AND   c.status_code = 'cancelled') 
 GROUP BY a.id) 
UPDATE application.application a
SET  services_fee = f.service_fee, 
     tax = f.service_fee - (f.service_fee/1.15), 
     total_fee = f.service_fee, 
     change_user = 'andrew'
FROM     service_total f
WHERE  f.app_id = a.id;                                  


DROP FUNCTION IF EXISTS application.get_work_summary(IN from_date date, IN to_date date);

CREATE OR REPLACE FUNCTION application.get_work_summary(IN from_date date, IN to_date date)
  RETURNS TABLE(req_type character varying, req_cat character varying, group_idx integer, in_progress_from integer, on_requisition_from integer, lodged integer, requisitioned integer, registered integer, cancelled integer, withdrawn integer, in_progress_to integer, on_requisition_to integer, overdue integer, service_fee numeric(20,2), overdue_apps text, requisition_apps text) AS
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
   
      -- Identifies all services lodged during the reporting period. Uses the
	  -- change_time instead of lodging_datetime to ensure all datetime comparisons 
	  -- across all subqueries yield consistent results 
      WITH estate_types AS 
	     -- Ticket #137 provide a breakdown by estate type for Record Lease and Record Sublease
         (SELECT req.code as req_code, rt.code as rt_code, 
                 get_translation(rt.display_value, null) as rt_display
          FROM   application.request_type req,
                 administrative.rrr_type rt
          WHERE  rt.is_primary = true
          AND    rt.status = 'c'
          AND    req.code IN ('registerLease', 'subLease')
          AND    req.status = 'c'
          UNION 
		  -- Use to capture any services that do not link to a property with an
		  -- estate type specified
          SELECT req.code AS req_code, '' AS rt_code, 'Unspecified' AS rt_display
          FROM   application.request_type req
          WHERE  req.code IN ('registerLease', 'subLease')
          AND    req.status = 'c'),
      service_lodged AS (
	 SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.rowversion = 1
		 UNION
         SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code
         FROM   application.service_historic ser_hist
         WHERE  ser_hist.change_time BETWEEN from_date AND to_date
		 AND    ser_hist.rowversion = 1),
		 
      -- Identifies all services cancelled during the reporting period. 	  
	  service_cancelled AS 
        (SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.status_code = 'cancelled'
     -- Verify that the service actually changed status 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )
	 -- #106 - Check the history data for cancelled services as applications returned
	 -- from requisition can cause the cancelled service record to be updated. 
		UNION
		SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service_historic ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.status_code = 'cancelled'
     -- Verify that the service actually changed status. 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )),
		
      -- All services in progress at the end of the reporting period		
      service_in_progress AS (  
         SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= to_date
	 AND ser.status_code IN ('pending', 'lodged')
      UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist,
	       application.service ser
	 WHERE ser_hist.change_time <= to_date
	 AND   ser.id = ser_hist.id
	 -- Filter out any services that have not been changed since the to_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   ser.change_time > to_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= to_date )),
	
    -- All services in progress at the start of the reporting period	
	service_in_progress_from AS ( 
     SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= from_date
	 AND ser.status_code IN ('pending', 'lodged')
     UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist,
	       application.service ser
	 WHERE ser_hist.change_time <= from_date
	 AND   ser.id = ser_hist.id
	 -- Filter out any services that have not been changed since the from_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   ser.change_time > from_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= from_date )),
				      
    app_changed AS ( -- All applications that changed status during the reporting period
	                 -- If the application changed status more than once, it will be listed
					 -- multiple times
         SELECT app.id, 
	 -- Flag if the application was withdrawn
	 app.status_code,
	 CASE app.action_code WHEN 'withdrawn' THEN TRUE ELSE FALSE END AS withdrawn
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
	 app_hist.status_code,
	 CASE app_hist.action_code WHEN 'withdrawn' THEN TRUE ELSE FALSE END AS withdrawn
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
	 FROM  application.application_historic app_hist, 
	       application.application app
	 WHERE app_hist.change_time <= to_date
	 AND   app.id = app_hist.id
	 -- Filter out any applications that have not been changed since the to_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   app.change_time > to_date
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
	 FROM  application.application_historic app_hist,
	       application.application app
	 WHERE app_hist.change_time <= from_date
	 AND   app.id = app_hist.id
	-- Filter out any applications that have not been changed since the from_date as these
	-- would have been picked up in the first select if they were still active
	 AND   app.change_time > from_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= from_date)),
	
    -- Ticket #137	
	-- Attempts to determine the fee paid for each service during the reporting period. This query is capable
	-- of dealing with partial payments and negative payments, but it may also misrepresent the fee paid
	-- per service if a new service is added to the application post lodgement. The logic attempts to 
	-- pro rata any new payment amounts evenly across all services, so when a new service is added, only
	-- part of any new payment may be allocated to the new service. 
	fee_paid AS (
		-- Payment details captured as part of initial lodgement and the application does not have any history
		SELECT s.id, s.request_type_code,
			   TRUNC(((a.total_amount_paid/a.total_fee) * (s.base_fee + s.value_fee)), 2) AS ser_fee, a.rowversion
		FROM  application.application a, 
			  application.service s
		WHERE s.application_id = a.id
		AND   s.status_code != 'cancelled'
		AND   a.total_fee  > 0
		AND   a.total_amount_paid > 0
		AND   a.change_time BETWEEN from_date AND to_date
		AND   s.lodging_datetime <= a.change_time
		AND   a.rowversion = 1
		UNION
		-- Payment made on the most recent save of the application (need to compare ot history of application to determine if 
		-- the total_amount_paid has changed. 
		SELECT s.id, s.request_type_code,
			   TRUNC((((a.total_amount_paid - app_hist.total_amount_paid)/a.total_fee) * (s.base_fee + s.value_fee)), 2) AS ser_fee, a.rowversion
		FROM  application.application a, 
			  application.service s,
			  application.application_historic app_hist
		WHERE s.application_id = a.id
		AND   s.status_code != 'cancelled'
		AND   a.total_fee  > 0
		AND   a.change_time BETWEEN from_date AND to_date
			AND   s.lodging_datetime <= a.change_time
		AND   app_hist.id = a.id
		AND   app_hist.rowversion = (a.rowversion - 1)
		AND   app_hist.total_amount_paid != a.total_amount_paid
		-- Ignore records where the total_fee changed by the same amount as the total paid. 
		AND   a.total_fee - app_hist.total_fee != a.total_amount_paid - app_hist.total_amount_paid
		UNION
		-- Payment made at an earlier time and captured in the application history
		SELECT s.id, s.request_type_code,
			   TRUNC((((a.total_amount_paid - app_hist.total_amount_paid)/a.total_fee) * (s.base_fee + s.value_fee)), 2) AS ser_fee, a.rowversion
		FROM  application.application_historic a, 
			  application.service s,
			  application.application_historic app_hist
		WHERE s.application_id = a.id
		AND   s.status_code != 'cancelled'
		AND   a.total_fee  > 0
		AND   a.change_time BETWEEN from_date AND to_date
		AND   s.lodging_datetime <= a.change_time
		AND   app_hist.id = a.id
		AND   app_hist.rowversion = (a.rowversion - 1)
		AND   app_hist.total_amount_paid != a.total_amount_paid
		-- Ignore records where the total_fee changed by the same amount as the total paid.
		AND   a.total_fee - app_hist.total_fee != a.total_amount_paid - app_hist.total_amount_paid
		UNION
		-- Only one payment made to the original lodgement record which is now in history.
		SELECT s.id, s.request_type_code,
			   TRUNC(((a.total_amount_paid/a.total_fee) * (s.base_fee + s.value_fee)), 2) AS ser_fee, a.rowversion
		FROM  application.application_historic a, 
			  application.service s
		WHERE s.application_id = a.id
		AND   s.status_code != 'cancelled'
		AND   a.total_fee  > 0
		AND   a.total_amount_paid > 0
		AND   a.change_time BETWEEN from_date AND to_date
		-- Allow 1 minute buffer as the services may be saved a few seconds after the application is initially created. 
		AND   s.lodging_datetime <= a.change_time + interval '1 minute'
		AND   a.rowversion = 1
		)
   -- MAIN QUERY                         
   SELECT (CASE WHEN rt_display IS NULL THEN get_translation(req.display_value, null) 
            ELSE  get_translation(req.display_value, null)  || ' - ' || rt_display END)::VARCHAR(200) AS req_type,
             --get_translation(req.display_value, null) AS req_type,
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
	  AND request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS in_progress_from,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS on_requisition_from,
	     
	  -- Count the services lodged during the reporting period.
	 (SELECT COUNT(s.id) FROM service_lodged s
	  WHERE s.request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS lodged,
	  
      -- Count the applications that were requisitioned during the
	  -- reporting period. All of the services on the application
 	  -- are requisitioned unless they are cancelled. Use the
	  -- current set of services on the application, but ensure
	  -- the services where lodged before the end of the reporting
	  -- period and that they were not cancelled during the 
	  -- reporting period. 
	 (SELECT COUNT(s.id) FROM app_changed a, application.service s
          WHERE s.application_id = a.id
	  AND   a.status_code = 'requisitioned'
	  AND   s.lodging_datetime < to_date
	  AND   NOT EXISTS (SELECT can.id FROM service_cancelled can
                        WHERE s.id = can.id)	  
          AND   s.request_type_code = req.code
          AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS requisitioned, 
          
	  -- Count the services on applications approved/completed 
	  -- during the reporting period. Note that services cannot be
	  -- changed after the application is approved, so checking the
	  -- current state of the services is valid. 
         (SELECT COUNT(s.id) FROM app_changed a, application.service s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'approved'
	  AND   s.status_code = 'completed'
	  AND   s.request_type_code = req.code
	  AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS registered,
	  
	  -- Count of the services associated with applications 
	  -- that have been lapsed or rejected + the count of 
	  -- services cancelled during the reporting period. Note that
      -- once annulled changes to the services are not possible so
      -- checking the current state of the services is valid.
      (SELECT COUNT(tmp.id) FROM  	  
        (SELECT s.id FROM app_changed a, application.service s
		  WHERE s.application_id = a.id
		  AND   a.status_code = 'annulled'
		  AND   a.withdrawn = FALSE
		  AND   s.request_type_code = req.code
		  AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, '')
          UNION		  
		  SELECT s.id FROM app_changed a, service_cancelled s
		  WHERE s.application_id = a.id
		  AND   a.status_code != 'annulled'
		  AND   s.request_type_code = req.code
		  AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, '')) AS tmp)::INT AS cancelled, 
	  
	  -- Count of the services associated with applications
	  -- that have been withdrawn during the reporting period
	  -- Note that once annulled changes to the services are
      -- not possible so checking the current state of the services is valid. 
         (SELECT COUNT(s.id) FROM app_changed a, application.service s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'annulled'
	  AND   a.withdrawn = TRUE
	  AND   s.status_code != 'cancelled'
	  AND   s.request_type_code = req.code
	  AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS withdrawn,

	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS in_progress_to,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS on_requisition_to,

	  -- Count of the services that have exceeded thier expected
	  -- completion date and are overdue. Only counts the service 
	  -- as overdue if both the application and the service are overdue. 
     (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'              
	  AND   a.expected_completion_date < to_date
	  AND   s.expected_completion_date < to_date
	  AND   s.request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS overdue,  
	  
	  -- Ticket #137
	  -- Sum the total paid for each fee. Note that for Samoa, only details
	  -- are required for the Record Plan service, (a.k.a. Cadastre Change) 
	  -- so exclude other service types. 
    (SELECT SUM(f.ser_fee) FROM fee_paid f
      WHERE f.request_type_code = req.code
	  AND   application.get_estate_type(f.id, req.code) = COALESCE(rt_code, '')
	  AND   req.code IN ('cadastreChange'))::NUMERIC(20,2) AS service_fee, 

	  -- The list of overdue applications 
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'lodged' 
          AND   a.expected_completion_date < to_date
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.expected_completion_date < to_date
                        AND   s.request_type_code = req.code
                        AND    application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))) AS overdue_apps,   

	  -- The list of applications on Requisition
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'requisitioned' 
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.request_type_code = req.code
                        AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))) AS requisition_apps						
   FROM  application.request_category_type cat, 
         application.request_type req LEFT OUTER JOIN estate_types ON req_code = req.code
   WHERE req.status = 'c'
   AND   cat.code = req.request_category_code					 
   ORDER BY group_idx, req_type;
	
   END; $BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION application.get_work_summary(date, date)
  OWNER TO postgres;
COMMENT ON FUNCTION application.get_work_summary(date, date) IS 'Returns a summary of the services processed for a specified reporting period. Used by the Lodgement Statistics Report.';


DROP FUNCTION IF EXISTS application.get_estate_type(IN service_id VARCHAR(20), IN request_type VARCHAR(20));

CREATE OR REPLACE FUNCTION application.get_estate_type(IN service_id VARCHAR(20), IN request_type VARCHAR(20))
  RETURNS VARCHAR(20) AS
$BODY$ 
DECLARE
  estate_type VARCHAR(20); 
BEGIN
   IF service_id IS NULL OR request_type IS NULL OR request_type NOT IN ('registerLease', 'subLease') THEN
      RETURN '';
   END IF; 

   SELECT p.type_code
   INTO   estate_type
   FROM   transaction.transaction t,
	  administrative.rrr r,
	  administrative.rrr p
   WHERE  t.from_service_id = service_id
   AND    r.transaction_id = t.id
   AND    p.ba_unit_id = r.ba_unit_id
   AND    p.is_primary = true
   AND    p.status_code = 'current';

   IF estate_type IS NULL THEN
      estate_type := '';
   END IF;
   
   RETURN estate_type;
   
END; $BODY$
LANGUAGE plpgsql VOLATILE;
COMMENT ON FUNCTION application.get_estate_type(VARCHAR(20), VARCHAR(20)) IS 'Returns the estate type of the property related to the service. Only tested with Record Lease and Record Sublease services. Used by the Lodgement Statistics Report.';



-- Ticket #69 change_parcel_name procedure.
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ChangeParcelAttrTool', 'Change Parcel Attribute Tool','c', 'Allows user to change the name or status of a parcel.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ChangeParcelAttrTool');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'ChangeParcelAttrTool', id FROM system.appgroup ag WHERE "name" = 'Quality Assurance'
     AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'ChangeParcelAttrTool'
					 AND    appgroup_id = ag.id));

DROP FUNCTION IF EXISTS cadastre.change_parcel_name(IN parcel_id CHARACTER VARYING, IN part1 CHARACTER VARYING, 
                                                    IN part2 CHARACTER VARYING, IN user_name CHARACTER VARYING);

CREATE OR REPLACE FUNCTION cadastre.change_parcel_name(IN parcel_id CHARACTER VARYING, IN part1 CHARACTER VARYING, 
                                                       IN part2 CHARACTER VARYING, IN user_name CHARACTER VARYING)
  RETURNS VOID AS
$BODY$  
BEGIN

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
	WHERE  ba.name_firstpart = part1
	AND    ba.name_lastpart = part2
	AND    co.name_firstpart = ba.name_firstpart
	AND    co.name_lastpart = ba.name_lastpart;
   
END; $BODY$
LANGUAGE plpgsql VOLATILE;
COMMENT ON FUNCTION cadastre.change_parcel_name(CHARACTER VARYING, CHARACTER VARYING, CHARACTER VARYING, CHARACTER VARYING) IS 'Procedure to correct the name of a cadastre object that was incorrectly recorded in DCDB. During the LRS migration, non spatial LRS parcels were created. The procedure will remove any LRS parcel matching the new name as well as link the parcel to the BA Unit matching the new name.';
