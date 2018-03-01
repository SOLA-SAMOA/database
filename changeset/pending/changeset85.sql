-- 1 Mar 2018
-- Make historic folio V9/186 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V9/186');
