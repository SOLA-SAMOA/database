-- 28 May 2014 Ticket #153
-- Make historic folios live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V5/79','V5/100','V5/71','V2/175','V2/75','V10/27','V1/97');
