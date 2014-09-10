-- 10 Sep 2014, Ticket #157 Add 2 new request types. 

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete,
 base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code)
 SELECT 'recordMiscFee', 'registrationServices', 'Record Miscellaneous', 'Creates a Miscellaneous RRR on the property with a fee', 'c' ,5, 
 100, 1, '<memorial>', 'miscellaneous', 'new'
 WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'recordMiscFee'); 

INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete,
 base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code)
 SELECT 'cancelMiscFee', 'registrationServices', 'Cancel Miscellaneous', 'Cancels a Miscellaneous RRR on the property with a fee', 'c' ,5, 
 100, 1, 'Miscellaneous <reference> cancelled', 'miscellaneous', 'cancel'
 WHERE NOT EXISTS (SELECT code FROM application.request_type WHERE code = 'cancelMiscFee'); 