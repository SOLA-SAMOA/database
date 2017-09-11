-- 12 Sep 2017
-- Make historic folio V42/151 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V42/151');
