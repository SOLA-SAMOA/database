-- 2 Apr 2019
-- change the district linked to Fagaloa
UPDATE administrative.required_relationship_baunit 
SET from_ba_unit_id = 'LD715954', -- Atua
    change_user = 'andrew'
WHERE to_ba_unit_id = 'LOC131' -- Fagaloa
AND relation_code = 'district_Village'
AND from_ba_unit_id = 'LD724709'; -- Palauli


