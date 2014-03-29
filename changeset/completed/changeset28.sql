-- 11 Feb 2014 Ticket #121
-- Set the fee for proclamation to 0 
UPDATE application.request_type
SET base_fee = 0
WHERE code in ('proclamation', 'removeProclamation'); 


