-- 6 Nov 2014, Ticket #166 Add Record Life Estate with no fee
UPDATE application.request_type SET  base_fee = 0 WHERE code = 'lifeEstate'; 

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete,
 base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code)
 SELECT 'lifeEstateFee', 'registrationServices', 'Record Life Estate with Fee', 'Creates a Life Estate RRR with a fee', 'c' ,5, 100, 1, 'Life Estate for <name1> with Remainder Estate in <name2, name3>', 'lifeEstate', 'new'
 WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'lifeEstateFee'); 
 
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'lifeEstateFee', 'Service - Record Life Estate with Fee','c', 'Allows the Record Life Estate with Fee service to be started.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'lifeEstateFee');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'lifeEstateFee', ag.id FROM system.appgroup ag WHERE ag."name" = 'Land Registry'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'lifeEstateFee'
					 AND    appgroup_id = ag.id));