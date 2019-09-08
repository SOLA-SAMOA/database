-- 20 May 2019
-- Make historic folio V30/56 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V30/56');


