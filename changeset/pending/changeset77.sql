-- 2 Feb 2017
-- Update required relationship type for 2027/5801
UPDATE administrative.required_relationship_baunit 
SET    relation_code = 'title_Village', 
       change_user = 'andrew'
WHERE  to_ba_unit_id IN (select id from administrative.ba_unit where name = '2027/5801')
AND    from_ba_unit_id = 'LOC018';