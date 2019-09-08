-- 20 Aug 2019
-- Make historic folio V2/227 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V2/227');

-- Make historic folio V47/241 live
UPDATE administrative.ba_unit 
SET status_code = 'current',
    change_user = 'andrew'
WHERE name IN ('V47/241');

-- Update the application number
UPDATE application.application 
SET nr = '12117a', 
    change_user = 'andrew'
WHERE nr IN ('12147a');
