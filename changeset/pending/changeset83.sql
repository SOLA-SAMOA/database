-- 7 Feb 2018
-- Make historic folio V30/69 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V30/69');
