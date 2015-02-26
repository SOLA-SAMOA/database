-- 24 Feb 2015, Ticket #167 Record Transmission Services
UPDATE application.request_type 
 SET  rrr_type_code = 'primary',
      type_action_code = 'vary'
WHERE code IN ('transmission', 'cnclTransmissonAdmin', 'removeTransmission');

UPDATE administrative.rrr 
SET change_user = 'andrew'
WHERE type_code = 'transmission'
AND   status_code = 'pending'; 

DELETE FROM administrative.rrr 
WHERE type_code = 'transmission'
AND   status_code = 'pending'; 

UPDATE administrative.rrr_type
SET status = 'x'
WHERE code = 'transmission';