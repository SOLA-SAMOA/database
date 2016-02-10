-- 10 Feb 2016 Ticket #183
-- Make historic folio V30/64 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V30/64');
