-- 24 Sep 2014, Ticket #159 Add new document types.
-- Discharge of Mortgage 
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'dischargeMortgage', 'Discharge of Mortgage', 'c', 'Discharge of Mortgage application form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'dischargeMortgage');
					  
-- Reset the type_code for documents related to discharge of mortgage					  
UPDATE source.source 
 SET type_code = 'dischargeMortgage', 
     change_user = 'andrew'
WHERE id IN (
   SELECT s.id  
   FROM   application.application a, 
          application.application_uses_source aus,
          source.source s
   WHERE s.type_code = 'application'
   AND   aus.source_id = s.id
   AND   a.id = aus.application_id
   AND   EXISTS (SELECT ser.application_id FROM application.service ser
              WHERE ser.application_id = a.id
              AND   ser.request_type_code = 'removeRestriction'
			  AND   ser.status_code = 'completed')); 


-- Registry Dealing			  
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'registryDealing', 'Registry Dealing', 'c', 'Registry Dealing application form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'registryDealing');

-- Reset the type_code for documents related to regisry dealings					  
UPDATE source.source 
 SET type_code = 'registryDealing', 
     change_user = 'andrew'
WHERE id IN (
   SELECT s.id  
   FROM   application.application a, 
          application.application_uses_source aus,
          source.source s
   WHERE s.type_code = 'application'
   AND   aus.source_id = s.id
   AND   a.id = aus.application_id
   AND   EXISTS (SELECT ser.application_id FROM application.service ser
              WHERE ser.application_id = a.id
              AND   ser.request_type_code IN ('registrarCorrection', 'registrarCancel')
			  AND   ser.status_code = 'completed')); 
			  
-- Transmission		  
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'transmission', 'Transmission', 'c', 'Transmission application form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'transmission');

-- Reset the type_code for documents related to Transmission					  
UPDATE source.source 
 SET type_code = 'transmission', 
     change_user = 'andrew'
WHERE id IN (
   SELECT s.id  
   FROM   application.application a, 
          application.application_uses_source aus,
          source.source s
   WHERE s.type_code = 'application'
   AND   aus.source_id = s.id
   AND   a.id = aus.application_id
   AND   EXISTS (SELECT ser.application_id FROM application.service ser
              WHERE ser.application_id = a.id
              AND   ser.request_type_code IN ('transmission')
			  AND   ser.status_code = 'completed')); 
			  
-- Cancel Lease		  
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'cancelLease', 'Cancel Lease or Sublease', 'c', 'Cancel Lease application form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'cancelLease');

-- Reset the type_code for documents related to Transmission					  
UPDATE source.source 
 SET type_code = 'cancelLease', 
     change_user = 'andrew'
WHERE id IN (
   SELECT s.id  
   FROM   application.application a, 
          application.application_uses_source aus,
          source.source s
   WHERE s.type_code = 'application'
   AND   aus.source_id = s.id
   AND   a.id = aus.application_id
   AND   EXISTS (SELECT ser.application_id FROM application.service ser
              WHERE ser.application_id = a.id
              AND   ser.request_type_code IN ('removeRight')
			  AND   ser.status_code = 'completed')); 
			  

-- Update the sources so they link to the scanned images correctly. 			  
WITH tmp AS (
SELECT s1.id AS s_id, 
       s2.ext_archive_id AS doc_id 
FROM  source.source s1,
      source.source s2
WHERE s1.ext_archive_id IS NULL
AND   s1.la_nr = s2.la_nr || '-01'
AND   s2.ext_archive_id IS NOT NULL)
UPDATE source.source
SET ext_archive_id = tmp.doc_id,
    change_user = 'doc_update'
FROM tmp
WHERE ext_archive_id IS NULL
AND   tmp.s_id = id;

-- Remove any sources that have been created as duplicates
WITH tmp AS (
SELECT s2.id AS s_id
FROM  source.source s1,
      source.source s2
WHERE s1.la_nr = s2.la_nr || '-01'
AND   s1.change_user = 'doc_update')
UPDATE source.source
SET change_user = 'doc_update_del'
FROM tmp
WHERE tmp.s_id = id;

DELETE FROM source.source
WHERE change_user = 'doc_update_del'; 

	
-- Ticket #160 Remove all data created for plans 11282, 11290 & 11342.
-- Reinstate the original underlying parcels 6/1104L
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew',
    status_code = 'current'
WHERE name_lastpart = '1104L'
AND   name_firstpart = '6'
AND   geom_polygon IS NOT NULL;

-- Set the change user on the cadastre_objects to be deleted
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart IN ( '11282', '11290', '11342');

-- Remove the spatial units - cadastre objects deleted via trigger. 
UPDATE cadastre.spatial_unit 
SET change_user = 'andrew'
WHERE id IN ( SELECT id FROM cadastre.cadastre_object WHERE name_lastpart IN ('11282', '11290', '11342'));

DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr IN ('11282', '11290', '11342')));
      
DELETE FROM application.service WHERE application_id IN
   ( SELECT id FROM application.application WHERE nr IN ('11282', '11290', '11342'));
      
DELETE FROM application.application_property WHERE application_id IN
      ( SELECT id FROM application.application WHERE nr IN ('11282', '11290', '11342'));
      
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr IN ('11282', '11290', '11342');

DELETE FROM application.application 
WHERE nr IN ('11282', '11290', '11342');