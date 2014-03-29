-- 9 Oct 2013 Ticket #112

-- Remove all data created for plan 7286(2)
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart = '7286(2)'
AND   geom_polygon IS NOT NULL;
DELETE FROM cadastre.cadastre_object 
WHERE name_lastpart = '7286(2)'
AND   geom_polygon IS NOT NULL;
DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '7286(2)'));
DELETE FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '7286(2)');
DELETE FROM application.application_property WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '7286(2)');
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr = '7286(2)';
DELETE FROM application.application WHERE nr = '7286(2)';
