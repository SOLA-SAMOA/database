INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ApplnViewUnassignAll', 'View all unassigned applications', 'c', 'Allows the user to view all of the unassigned applications
instead of just a filtered view based on the services they can perform' 
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnViewUnassignAll');

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ApplnViewAssignAll', 'View all assigned applications', 'c', 'Allows the user to view all assigned applications
instead of just a filtered view based on the services they can perform' 
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ApplnViewAssignAll');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnViewAssignAll', 'super-group-id' 
WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup WHERE approle_code = 'ApplnViewAssignAll' AND appgroup_id = 'super-group-id'));  

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnViewUnassignAll', 'super-group-id' 
WHERE NOT EXISTS (SELECT approle_code FROM system.approle_appgroup WHERE approle_code = 'ApplnViewUnassignAll' AND appgroup_id = 'super-group-id'));  

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnViewUnassignAll', id FROM system.appgroup WHERE "name" = 'Accounts');