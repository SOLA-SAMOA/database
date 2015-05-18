-- 18 May 2015
-- #172 Remove plan 11409 from the database

-- Reinstate any parcels that were made historic by the transaction
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew',
    status_code = 'current'
WHERE id IN (SELECT cot.cadastre_object_id 
             FROM   cadastre.cadastre_object_target cot,
                    cadastre.cadastre_object co
             WHERE  co.transaction_id = cot.transaction_id
             AND    co.name_lastpart = '11409')
AND   status_code = 'historic'           
AND   geom_polygon IS NOT NULL;

-- Set the change user on the cadastre_objects to be deleted
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart IN ('11409');

-- Remove the spatial units - cadastre objects deleted via trigger. 
DELETE FROM cadastre.spatial_unit 
WHERE id IN ( SELECT id FROM cadastre.cadastre_object WHERE name_lastpart IN ('11409'));

DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr IN ('11409')));
      
DELETE FROM application.service WHERE application_id IN
   ( SELECT id FROM application.application WHERE nr IN ('11409'));
      
DELETE FROM application.application_property WHERE application_id IN
      ( SELECT id FROM application.application WHERE nr IN ('11409'));
      
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr IN ('11409');

DELETE FROM application.application 
WHERE nr IN ('11409'); 

