-- 1 Nov 2017
-- #198 Remove fee and add new service type_action_code
-- Update the Change Estate Type service to have no fee
UPDATE application.request_type 
SET  base_fee = 0
WHERE code = 'varyTitle'; 

-- Add new transfer service with no fee charged
INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete,
 base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code)
 SELECT 'glbTransfer', 'registrationServices', 'Government Land Board Transfer', 'Government Land Board Transfer', 'c' ,5, 0, 1, 'Transfer to <name>', 'primary', 'vary'
 WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'glbTransfer'); 
 
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'glbTransfer', 'Service - Government Land Board Transfer','c', 'Allows the Government Land Board Transfer service to be started.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'glbTransfer');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'glbTransfer', ag.id FROM system.appgroup ag WHERE ag."name" = 'Land Registry'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'glbTransfer'
					 AND    appgroup_id = ag.id));
