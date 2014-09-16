-- 16 Sep 2014, Ticket #158 Add new document type. 
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'transfer', 'Transfer', 'c', 'Application transfer form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'transfer');

-- Reset the type_code for approx 1000 documents to transfer					  
UPDATE source.source 
 SET type_code = 'transfer', 
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
              AND   ser.request_type_code = 'newOwnership'
			  AND   ser.status_code = 'completed')); 
