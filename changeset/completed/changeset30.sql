-- 05 Mar 2014 Ticket #123

-- Remove all data created for plan 11142. 
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart = '11142'
AND   geom_polygon IS NOT NULL;

DELETE FROM cadastre.cadastre_object 
WHERE name_lastpart = '11142'
AND   geom_polygon IS NOT NULL;

DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '11142'));
      
DELETE FROM application.service WHERE application_id IN
   ( SELECT id FROM application.application WHERE nr = '11142');
      
DELETE FROM application.application_property WHERE application_id IN
      ( SELECT id FROM application.application WHERE nr = '11142');
      
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr = '11142';

DELETE FROM application.application 
WHERE nr = '11142';


-- Remove all data created for plan 11145. 
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart = '11145'
AND   geom_polygon IS NOT NULL;

DELETE FROM cadastre.cadastre_object 
WHERE name_lastpart = '11145'
AND   geom_polygon IS NOT NULL;

DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '11145'));
      
DELETE FROM application.service WHERE application_id IN
   ( SELECT id FROM application.application WHERE nr = '11145');
      
DELETE FROM application.application_property WHERE application_id IN
      ( SELECT id FROM application.application WHERE nr = '11145');
      
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr = '11145';

DELETE FROM application.application 
WHERE nr = '11145';

-- Remove all data created for plan 11145(2). 
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart = '11145(2)'
AND   geom_polygon IS NOT NULL;

DELETE FROM cadastre.cadastre_object 
WHERE name_lastpart = '11145(2)'
AND   geom_polygon IS NOT NULL;

DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '11145(2)'));
      
DELETE FROM application.service WHERE application_id IN
   ( SELECT id FROM application.application WHERE nr = '11145(2)');
      
DELETE FROM application.application_property WHERE application_id IN
      ( SELECT id FROM application.application WHERE nr = '11145(2)');
      
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr = '11145(2)';

DELETE FROM application.application 
WHERE nr = '11145(2)';

