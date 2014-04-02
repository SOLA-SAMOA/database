-- 2 Apr 2014
-- Changeset containing updates for version 1404a of SOLA.

-- Ticket #138 Config for Measure Tool
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'MeasureTool', 'Measure Tool','c', 'Allows user to measure a distance on the map.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'MeasureTool');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'MeasureTool', id FROM system.appgroup WHERE "name" = 'Technical Division');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'MeasureTool', id FROM system.appgroup WHERE "name" = 'Quality Assurance'); 