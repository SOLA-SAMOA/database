-- 2 Dec 2013 Ticket #118
-- Reinstate 1/10363 and 2/10363
UPDATE administrative.ba_unit 
SET status_code = 'current', 
    change_user = 'andrew',
    expiration_date = NULL
WHERE name_lastpart = '10363'
AND name_firstpart IN ('1', '2');
