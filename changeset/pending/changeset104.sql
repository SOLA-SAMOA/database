-- Version 2001b - updates to reflect minor changes requested during second mission. 


-- ****  CoT Report **** --

CREATE OR REPLACE FUNCTION administrative.show_cot_report(
	p_ba_unit_id character varying,
	p_is_production boolean,
	p_user_name character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'

AS $BODY$

DECLARE 
   v_cot_date DATE := '02-MAR-2021';
   v_bypass boolean := TRUE; -- The bypass will force the CFC to be produced until such time as the cutover date to CoT's is agreeded. 
BEGIN

  -- This is the training system, so allow certain users to view the CoT report
  -- IF p_user_name = 'andrew' AND NOT p_is_production THEN RETURN TRUE; END IF;
  
  -- Allow a date independent bypass to avoid the CoT from being displayed
  IF v_bypass THEN RETURN FALSE; END IF;
  
  -- Do not produce a CoT for Customary Land
  IF EXISTS (SELECT r.id
             FROM  administrative.rrr r
		     WHERE r.ba_unit_id = p_ba_unit_id
			 AND   r.type_code = 'customaryType'
			 AND   r.status_code = 'current'
			 AND   r.is_primary = true) THEN RETURN FALSE; END IF;
  
  -- Check if there has been dealing registered on the title after the CoT cutover date. 
  IF EXISTS (SELECT r.id
             FROM  administrative.rrr r,
			       transaction.transaction t, 
				   application.service s
		     WHERE r.ba_unit_id = p_ba_unit_id
			 AND   r.registration_date >= v_cot_date
			 AND   t.id = r.transaction_id
			 AND   s.id = t.from_service_id
			 AND   s.request_type_code NOT IN ('registrarCancel', 'registrarCorrection')) THEN RETURN TRUE; END IF; 

  RETURN FALSE;
END
$BODY$;

COMMENT ON FUNCTION administrative.show_cot_report(character varying, boolean, character varying)
    IS 'Checks the ba_unit to determine if the Certificate of Title report should be displayed or not';
	
	
	
-- Allow administrators to see the public user activity report	
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r 
 WHERE g."name" IN ( 'Administrator') 
 AND   r.code IN ('PublicActivityRpt')
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
				   WHERE r.code = approle_code AND appgroup_id = g.id));


-- Allow QA access to Staff Print
INSERT INTO system.approle (code, display_value, description, status)
SELECT 'StaffSearchRpt', 'Staff Search Report', 'Allows members of the QA team to view and print the Staff Search for a property', 'c'
WHERE  NOT EXISTS (SELECT code FROM system.approle WHERE code = 'StaffSearchRpt');  

/* Requires Filisita to confirm QA to have access to Staff Search. 
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r 
 WHERE g."name" IN ('Quality Assurance') 
 AND   r.code IN ('StaffSearchRpt')
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
				   WHERE r.code = approle_code AND appgroup_id = g.id)); */ 


-- Only allow Tua and Sita to make deeds current. 
INSERT INTO system.appgroup (id, name, description)
SELECT uuid_generate_v1(), 'Make Deed Current', 'Allows users make an historic deed current for dealing transactions'
WHERE NOT EXISTS (SELECT 1 FROM system.appgroup WHERE name = 'Make Deed Current');

DELETE FROM system.approle_appgroup WHERE approle_code = 'MakePropCurrent';

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r 
 WHERE g."name" = 'Make Deed Current'
 AND   r.code IN ('MakePropCurrent' )
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
				   WHERE r.code = approle_code AND appgroup_id = g.id));

INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id)
(SELECT u.id, g.id FROM system.appgroup g, system.appuser  u
 WHERE  g."name" = 'Make Deed Current'	
 AND    u.username IN ('tua', 'sita')
 AND NOT EXISTS  (SELECT appuser_id FROM system.appuser_appgroup 
				   WHERE u.id = appuser_id AND appgroup_id = g.id));


-- Give Sita access to the Aerial Photos				   
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id)
(SELECT u.id, g.id FROM system.appgroup g, system.appuser  u
 WHERE  g."name" = 'View Aerial Photos'	
 AND    u.username IN ('sita')
 AND NOT EXISTS  (SELECT appuser_id FROM system.appuser_appgroup 
				   WHERE u.id = appuser_id AND appgroup_id = g.id));
				   
				   
-- Add a public user into SOLA for demonstration purposes. 				   
INSERT INTO system.appuser(
	id, username, first_name, last_name, passwd, active, change_user)
	VALUES (uuid_generate_v1(), 'public', 'Public User', 'Demo', '4176e3038491cf70a8fe8c63099c3e0b7340269661ee2743ae96ec64e4e8b201', true, 'andrew');
	
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id) 
(SELECT u.id, g.id FROM system.appgroup g, system.appuser u 
 WHERE g."name" = 'Public Users'
 AND   u.username = 'public'
 AND   NOT EXISTS (SELECT appgroup_id FROM system.appuser_appgroup ag
				   WHERE ag.appuser_id = u.id AND ag.appgroup_id = g.id));

INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id) 
(SELECT u.id, g.id FROM system.appgroup g, system.appuser u 
 WHERE g."name" = 'View Aerial Photos'
 AND   u.username = 'public'
 AND   NOT EXISTS (SELECT appgroup_id FROM system.appuser_appgroup ag
				   WHERE ag.appuser_id = u.id AND ag.appgroup_id = g.id));
				   
-- Lots created for district boundary that needs to be removed
DELETE FROM cadastre.cadastre_object WHERE name_firstpart = '1' AND name_lastpart = '11846';				   
DELETE FROM cadastre.cadastre_object WHERE name_firstpart = 'LOT 2' AND name_lastpart = '11847';
DELETE FROM cadastre.cadastre_object WHERE name_firstpart = 'LOT 1' AND name_lastpart = '11848';
DELETE FROM cadastre.cadastre_object WHERE name_firstpart = 'LOT 1' AND name_lastpart = '11849';
DELETE FROM cadastre.cadastre_object WHERE name_firstpart = 'LOT 1' AND name_lastpart = '11850';
DELETE FROM cadastre.cadastre_object WHERE name_firstpart = 'LOT 1' AND name_lastpart = '11851';
DELETE FROM cadastre.cadastre_object WHERE name_firstpart = 'LOT 1' AND name_lastpart = '11852';
DELETE FROM cadastre.cadastre_object WHERE name_firstpart = 'LOT 1' AND name_lastpart = '11853';	
	
  