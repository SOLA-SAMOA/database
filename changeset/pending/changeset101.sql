-- 25 September 2015
-- Add new supporting document type 
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'lrManualFolio', 'Land Register Manual Folio', 'c', 'Land Register Manual Folio', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'lrManualFolio');

