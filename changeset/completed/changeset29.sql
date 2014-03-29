-- 26 Feb 2014 Ticket #122

-- Make 2\CT GT 731 historic as it is no
-- longer required
UPDATE cadastre.cadastre_object
SET   change_user = 'andrew',
      status_code = 'historic'
WHERE name_lastpart = 'CT GT 731'
AND   name_firstpart = '2'; 

-- Remove all data created for plan 10135. Note that 
-- there are 6 applications with the number 10135
-- with one created by LRS migration. Leave the
-- LRS migration application in place. 
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart = '10135'
AND   geom_polygon IS NOT NULL;

DELETE FROM cadastre.cadastre_object 
WHERE name_lastpart = '10135'
AND   geom_polygon IS NOT NULL;

DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '10135'
      AND id != '3F6E31CD-4ADB-4A6E-841A-1CE6C5190A94'));
      
DELETE FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '10135'
      AND id != '3F6E31CD-4ADB-4A6E-841A-1CE6C5190A94');
      
DELETE FROM application.application_property WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '10135'
      AND id != '3F6E31CD-4ADB-4A6E-841A-1CE6C5190A94');
      
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr = '10135'
AND id != '3F6E31CD-4ADB-4A6E-841A-1CE6C5190A94';

DELETE FROM application.application 
WHERE nr = '10135'
AND id != '3F6E31CD-4ADB-4A6E-841A-1CE6C5190A94';


