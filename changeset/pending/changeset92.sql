-- 16 Mar 2019
-- Make historic folio V43/228 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V43/228');


