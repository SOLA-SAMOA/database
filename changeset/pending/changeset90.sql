-- 16 Jan 2019
-- Make historic folio V7/164 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V7/164');


