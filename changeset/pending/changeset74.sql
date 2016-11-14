-- 14 November 2015
-- #188 Add service to terminate lease with no fee
INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code)
SELECT 'removeGovLease', 'registrationServices', 'Terminate Government Lease or Customary Lease', 'Terminates a government lease or a customary lease with no fee', 'c' ,5, 0, 1, 'Lease <reference> cancelled', 'lease', 'cancel' WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'removeGovLease');
