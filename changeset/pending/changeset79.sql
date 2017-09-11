-- 18 July 2017
-- Update required relationship type for 47/11047 and V3/15 to priorTitle
UPDATE administrative.required_relationship_baunit 
SET    relation_code = 'priorTitle', 
       change_user = 'andrew'
WHERE  to_ba_unit_id IN (select id from administrative.ba_unit where name = '47/11047')
AND    from_ba_unit_id IN (select id from administrative.ba_unit where name = 'V3/15');