-- 7 Apr 2015, Ticket #169 Fix folio reference
UPDATE administrative.ba_unit
SET    name_firstpart = '473',
       name = '473/4863',
       change_user = 'andrew'
WHERE  name_firstpart = '47371'
AND    name_lastpart = '4863';
