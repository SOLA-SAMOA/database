-- 24 August 2015
-- #177 Add new Conveyance document type
INSERT INTO source.administrative_source_type(
            code, display_value, status, description, is_for_registration)
    SELECT 'conveyance', 'Conveyance', 'c', 'Deed of conveyance', FALSE
    WHERE NOT EXISTS (SELECT code FROM source.administrative_source_type
                      WHERE  code = 'conveyance');

