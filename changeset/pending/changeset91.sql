-- 2 Mar 2019
-- Make historic folio V5/200 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V5/200');