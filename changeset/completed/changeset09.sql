-- 11 Feb 2012
-- Cancels the mortgages on V3/15. See Ticket #73. 
UPDATE administrative.rrr
SET status_code = 'historic'
WHERE ba_unit_id in (
SELECT id from administrative.ba_unit 
WHERE name_firstpart = 'V3'
and name_lastpart = '15')
AND type_code IN ( 'mortgage', 'lease', 'miscellaneous', 'caveat')
and status_code = 'current';

UPDATE application.request_type
SET display_value = 'Change Right or Restriction::::SAMOAN'
WHERE code =  'regnOnTitle'; 