-- 14 May 2014 Ticket #150
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name = '2/10432';

-- Ticket #151
UPDATE application.request_type
SET    base_fee = 100
WHERE  code = 'removeRight'