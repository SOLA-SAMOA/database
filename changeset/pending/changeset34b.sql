-- 1 Apr 2014 Ticket #141
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'lapseCaveat', 'Lapse Caveat','c', 'Used for processing Lapse Caveat services.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'lapseCaveat');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'lapseCaveat', id FROM system.appgroup WHERE "name" = 'Land Registry');