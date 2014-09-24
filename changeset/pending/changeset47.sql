-- 24 Sep 2014, Ticket #158 Add security roles for the new request types

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'recordMiscFee', 'Service - Record Miscellaneous','c', 'Allows the Record Miscellaneous service to be started.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'recordMiscFee');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'recordMiscFee', ag.id FROM system.appgroup ag WHERE ag."name" = 'Land Registry'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'recordMiscFee'
					 AND    appgroup_id = ag.id));
					 
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'cancelMiscFee', 'Service - Cancel Miscellaneous','c', 'Allows the Cancel Miscellaneous service to be started.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'cancelMiscFee');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'cancelMiscFee', ag.id FROM system.appgroup ag WHERE ag."name" = 'Land Registry'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'cancelMiscFee'
					 AND    appgroup_id = ag.id));
					 
					