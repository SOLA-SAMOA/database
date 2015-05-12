-- 12 May 2015
-- #171 Give Tuaoloa Team Leader role
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id, change_user)
SELECT id, '40', 'andrew' FROM system.appuser where username = 'tuaoloa';