-- 28 August 2015
-- #178 Remove plan 11411 from the database. Receipt Ref for 11411 is 817066

-- Reinstate any parcels that were made historic by the transaction. Should be none
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew',
    status_code = 'current'
WHERE id IN (SELECT cot.cadastre_object_id 
             FROM   cadastre.cadastre_object_target cot,
                    transaction.transaction t,
                    application.service s,
                    application.application a
             WHERE  a.nr = '11411'
             AND    s.application_id = a.id
             AND    t.from_service_id = s.id
             AND    cot.transaction_id = t.id)
AND   status_code = 'historic'           
AND   geom_polygon IS NOT NULL;

-- Set the change user on the cadastre_objects to be deleted
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart IN ('11411');

-- Set the change user on the ba unit links to be deleted
UPDATE administrative.ba_unit_contains_spatial_unit
SET change_user = 'andrew'
WHERE spatial_unit_id IN 
  (SELECT id FROM cadastre.cadastre_object 
   WHERE name_lastpart IN ('11411'));
   
-- Remove the ba_unit links  
DELETE FROM administrative.ba_unit_contains_spatial_unit
WHERE spatial_unit_id IN 
  (SELECT id FROM cadastre.cadastre_object 
   WHERE name_lastpart IN ('11411'));
   
-- Remove the spatial units - cadastre objects deleted via trigger. 
DELETE FROM cadastre.spatial_unit 
WHERE id IN ( SELECT id FROM cadastre.cadastre_object WHERE name_lastpart IN ('11411'));

-- Remove 11411 along with the Redefinition applications
DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr IN ('11411', '101784', '101785', '101786', '101787', '101790')));
      
DELETE FROM application.service WHERE application_id IN
   ( SELECT id FROM application.application WHERE nr IN ('11411', '101784', '101785', '101786', '101787', '101790'));
      
DELETE FROM application.application_property WHERE application_id IN
      ( SELECT id FROM application.application WHERE nr IN ('11411', '101784', '101785', '101786', '101787', '101790'));
      
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr IN ('11411', '101784', '101785', '101786', '101787', '101790');

DELETE FROM application.application 
WHERE nr IN ('11411', '101784', '101785', '101786', '101787', '101790');

