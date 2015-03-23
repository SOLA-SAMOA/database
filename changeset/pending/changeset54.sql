-- 23 Mar 2015, Ticket #168 Fix processing of Easements
UPDATE application.request_type 
SET rrr_type_code = 'servitude'
WHERE rrr_type_code = 'easement'; 

UPDATE administrative.rrr
SET type_code = 'servitude'
WHERE type_code = 'easement'; 