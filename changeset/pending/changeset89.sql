-- 21 Dec 2018
-- Make historic folio V2/66 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V2/66');


