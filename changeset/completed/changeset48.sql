-- 1 Oct 2014, Ticket #162 Include more new document types.
-- Assignment of Lease 
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'assignLease', 'Assignment of Lease', 'c', 'Assignment of Lease application form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'assignLease');
					  
-- Reset the type_code for documents related to Assignment of Lease					  
UPDATE source.source 
 SET type_code = 'assignLease', 
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
              AND   ser.request_type_code = 'registerLease'
			  AND   ser.status_code = 'completed')); 


-- Variation of Mortgage			  
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'varyMortgage', 'Variation of Mortgage', 'c', 'Variation of Mortgage application form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'varyMortgage');

-- Reset the type_code for documents related to variation of mortgage					  
UPDATE source.source 
 SET type_code = 'varyMortgage', 
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
              AND   ser.request_type_code IN ('variationMortgage')
			  AND   ser.status_code = 'completed')); 
			  
-- Variation of Lease	  
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'varyLease', 'Variation of Lease', 'c', 'Variation of Lease application form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'varyLease');

-- Reset the type_code for documents related to Variation of Lease					  
UPDATE source.source 
 SET type_code = 'varyLease', 
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
              AND   ser.request_type_code IN ('varyLease')
			  AND   ser.status_code = 'completed')); 
			  
-- Removal of Caveat		  
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'removeCaveat', 'Removal of Caveat', 'c', 'Removal of Caveat application form', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'removeCaveat');

-- Reset the type_code for documents related to Cancel Caveat					  
UPDATE source.source 
 SET type_code = 'removeCaveat', 
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
              AND   ser.request_type_code IN ('removeCaveat')
			  AND   ser.status_code = 'completed')); 
			  

