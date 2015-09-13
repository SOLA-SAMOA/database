--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = administrative, pg_catalog;

--
-- Data for Name: ba_unit_rel_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE ba_unit_rel_type DISABLE TRIGGER ALL;

INSERT INTO ba_unit_rel_type (code, display_value, description, status) VALUES ('priorTitle', 'Prior Title', 'Prior Title', 'c');
INSERT INTO ba_unit_rel_type (code, display_value, description, status) VALUES ('rootTitle', 'Root of Title', 'Root of Title', 'c');
INSERT INTO ba_unit_rel_type (code, display_value, description, status) VALUES ('island_District', 'Island::::Motu', 'Island - Districts', 'x');
INSERT INTO ba_unit_rel_type (code, display_value, description, status) VALUES ('district_Village', 'District::::Itumalo', 'District - Villages', 'x');
INSERT INTO ba_unit_rel_type (code, display_value, description, status) VALUES ('title_Village', 'Village::::Nuu', 'Title - Village', 'c');
INSERT INTO ba_unit_rel_type (code, display_value, description, status) VALUES ('commonProperty', 'Common Property::::SAMOAN', NULL, 'c');


ALTER TABLE ba_unit_rel_type ENABLE TRIGGER ALL;

--
-- Data for Name: ba_unit_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE ba_unit_type DISABLE TRIGGER ALL;

INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('leasedUnit', 'Leased Unit::::Unita Affitto', NULL, 'x');
INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('propertyRightUnit', 'Property Right Unit::::Unita Diritto Proprieta', NULL, 'x');
INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('basicPropertyUnit', 'Basic Property Unit::::Vaega mo Meatotino Amata', 'This is the basic property unit that is used by default', 'c');
INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('administrativeUnit', 'Administrative Unit::::Vaega o Pulega', NULL, 'x');
INSERT INTO ba_unit_type (code, display_value, description, status) VALUES ('strataUnit', 'Strata Property Unit::::SAMOAN', NULL, 'c');


ALTER TABLE ba_unit_type ENABLE TRIGGER ALL;

--
-- Data for Name: mortgage_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE mortgage_type DISABLE TRIGGER ALL;

INSERT INTO mortgage_type (code, display_value, description, status) VALUES ('levelPayment', 'Level Payment::::Totogi tutusa', NULL, 'c');
INSERT INTO mortgage_type (code, display_value, description, status) VALUES ('linear', 'Linear::::Laina', NULL, 'c');
INSERT INTO mortgage_type (code, display_value, description, status) VALUES ('microCredit', 'microCredit::::Aitalafu la''ititi', NULL, 'c');


ALTER TABLE mortgage_type ENABLE TRIGGER ALL;

--
-- Data for Name: rrr_group_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE rrr_group_type DISABLE TRIGGER ALL;

INSERT INTO rrr_group_type (code, display_value, description, status) VALUES ('rights', 'Rights::::Aiatatau', NULL, 'c');
INSERT INTO rrr_group_type (code, display_value, description, status) VALUES ('restrictions', 'Restrictions::::Aiaiga', NULL, 'c');
INSERT INTO rrr_group_type (code, display_value, description, status) VALUES ('system', 'System', 'Groups RRRs that exist solely to support SOLA system functionality', 'x');
INSERT INTO rrr_group_type (code, display_value, description, status) VALUES ('responsibilities', 'Responsibilities::::SAMOAN', NULL, 'c');


ALTER TABLE rrr_group_type ENABLE TRIGGER ALL;

--
-- Data for Name: rrr_type; Type: TABLE DATA; Schema: administrative; Owner: postgres
--

ALTER TABLE rrr_type DISABLE TRIGGER ALL;

INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('primary', 'system', 'Primary', false, false, false, 'System RRR type used by SOLA to represent the group of primary rights.', 'x');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('easement', 'system', 'Easement Group', false, false, false, 'System RRR type used by SOLA to represent the group of rights associated with easements (i.e. servitude and dominant.', 'x');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('customaryType', 'rights', 'Customary::::SAMOAN', true, true, true, 'Primary right indicating the property is owned under customary title.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('leaseHold', 'rights', 'Leasehold::::SAMOAN', true, true, true, 'Primary right indicating the property is subject to a long term leasehold agreement.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('ownership', 'rights', 'Freehold::::SAMOAN', true, true, true, 'Primary right indicating the property is owned under a freehold (Fee Simple Estate) title.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('stateOwnership', 'rights', 'Government::::SAMOAN', true, true, true, 'Primary right indicating the property is state land owned by the Government of Samoa.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('mortgage', 'restrictions', 'Mortgage::::Nono le Fanua', false, false, false, 'Indicates the property is under mortgage.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('lease', 'rights', 'Lease::::Lisi', false, false, true, 'Indicates the property is subject to a short or medium term lease agreement.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('caveat', 'restrictions', 'Caveat::::Tusi Taofi', false, false, true, 'Indicates the property is subject to restrictions imposed by a caveat.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('order', 'restrictions', 'Court Order::::SAMOAN', false, false, false, 'Indicates the property is subject to restrictions imposed by a court order.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('proclamation', 'restrictions', 'Proclamation::::SAMOAN', false, false, false, 'Indicates the property is subject to restrictions imposed by a proclamation that has completed the necessary statutory process.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('lifeEstate', 'restrictions', 'Life Estate::::SAMOAN', false, false, true, 'Indicates the property is subject to a life estate.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('servitude', 'restrictions', 'Easement::::SAMOAN', false, false, false, 'Indicates the property is subject to an easement as the servient estate.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('dominant', 'rights', 'Dominant Estate::::SAMOAN', false, false, false, 'Indicates the property has been granted rights to an easement over another property as the dominant estate.', 'x');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('miscellaneous', 'rights', 'Miscellaneous::::SAMOAN', false, false, false, 'Miscellaneous', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('unitEntitlement', 'rights', 'Unit Entitlement::::SAMOAN', false, false, false, 'Indicates the unit entitlement the unit has in relation to the unit development.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('bodyCorpRules', 'responsibilities', 'Body Corporate Rules::::SAMOAN', false, false, false, 'The body corporate rules for a unit development.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('addressForService', 'responsibilities', 'Address for Service::::SAMOAN', false, false, false, 'The body corporate address for service.', 'c');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('commonProperty', 'system', 'Common Property', false, false, false, 'System RRR type used by SOLA to represent the unit development body corporate responsibilities', 'x');
INSERT INTO rrr_type (code, rrr_group_type_code, display_value, is_primary, share_check, party_required, description, status) VALUES ('transmission', 'rights', 'Transmission::::SAMOAN', false, false, true, 'Transmission.', 'x');


ALTER TABLE rrr_type ENABLE TRIGGER ALL;

SET search_path = application, pg_catalog;

--
-- Data for Name: application_status_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE application_status_type DISABLE TRIGGER ALL;

INSERT INTO application_status_type (code, display_value, status, description) VALUES ('annulled', 'Annulled::::Anullato', 'c', NULL);
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('lodged', 'Lodged::::Ua Faaulu', 'c', 'Application has been lodged and officially received by land office::::La pratica registrata e formalmente ricevuta da ufficio territoriale');
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('approved', 'Approved::::Ua Pasia', 'c', NULL);
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('completed', 'Completed::::Ua Maea', 'c', NULL);
INSERT INTO application_status_type (code, display_value, status, description) VALUES ('requisitioned', 'Requisitioned::::Ua Tusifaasao', 'c', NULL);


ALTER TABLE application_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: application_action_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE application_action_type DISABLE TRIGGER ALL;

INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('dispatch', 'Dispatch::::Inviata', NULL, 'c', 'Application documents and new land office products are sent or collected by applicant (action is manually logged)::::I documenti della pratica e i nuovi prodotti da Ufficio Territoriale sono stati spediti o ritirati dal richiedente');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('lodge', 'Lodgement Notice Prepared::::Ua saunia faamatalaga mo le Tuuina mai', 'lodged', 'c', 'Lodgement notice is prepared (action is automatically logged when application details are saved for the first time::::La ricevuta della registrazione pronta');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('addDocument', 'Add document::::Faaopopo Faamatalaga', NULL, 'c', 'Scanned Documents linked to Application (action is automatically logged when a new document is saved)::::Documenti scannerizzati allegati alla pratica');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('withdraw', 'Withdraw application::::Toe faafoi le Talosaga', 'annulled', 'c', 'Application withdrawn by Applicant (action is manually logged)::::Pratica Ritirata dal Richiedente');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('cancel', 'Cancel application::::Soloia Talosaga', 'annulled', 'c', 'Application cancelled by Land Office (action is automatically logged when application is cancelled)::::Pratica cancellata da Ufficio Territoriale');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('requisition', 'Requisition::::Tusifaasao', 'requisitioned', 'c', 'Further information requested from applicant (action is manually logged)::::Ulteriori Informazioni domandate dal richiedente');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('validateFailed', 'Quality Check Fails::::Ua le pasia siaki mo le Faamautuina', NULL, 'c', 'Quality check fails (automatically logged when a critical business rule failure occurs)::::Controllo Qualita Fallito');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('validatePassed', 'Quality Check Passes::::Ua pasia siaki mo le Faamautuina', NULL, 'c', 'Quality check passes (automatically logged when business rules are run without any critical failures)::::Controllo Qualita Superato');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('approve', 'Approve::::Pasia', 'approved', 'c', 'Application is approved (automatically logged when application is approved successively)::::Pratica approvata');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('archive', 'Archive::::Teu maluina ', 'completed', 'c', 'Paper application records are archived (action is manually logged)::::I fogli della pratica sono stati archiviati');
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('lapse', 'Lapse::::Ua lape/Ua faaleaogaina', 'annulled', 'c', NULL);
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('assign', 'Assign::::Tofia ', NULL, 'c', NULL);
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('unAssign', 'Unassign::::Le Tofia', NULL, 'c', NULL);
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('resubmit', 'Resubmit::::Toe Aumaia', 'lodged', 'c', NULL);
INSERT INTO application_action_type (code, display_value, status_to_set, status, description) VALUES ('validate', 'Validate::::Aso Aoga', NULL, 'c', 'The action validate does not leave a mark, because validateFailed and validateSucceded will be used instead when the validate is completed.');


ALTER TABLE application_action_type ENABLE TRIGGER ALL;

--
-- Data for Name: request_category_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE request_category_type DISABLE TRIGGER ALL;

INSERT INTO request_category_type (code, display_value, description, status) VALUES ('registrationServices', 'Registration Services::::Auaunaga o Resitaraina', NULL, 'c');
INSERT INTO request_category_type (code, display_value, description, status) VALUES ('informationServices', 'Information Services::::Auaunaga o Faamatalaga', NULL, 'c');
INSERT INTO request_category_type (code, display_value, description, status) VALUES ('cadastralServices', 'Cadastral Services', NULL, 'c');
INSERT INTO request_category_type (code, display_value, description, status) VALUES ('nonRegServices', 'Non Registration Services', NULL, 'c');


ALTER TABLE request_category_type ENABLE TRIGGER ALL;

--
-- Data for Name: type_action; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE type_action DISABLE TRIGGER ALL;

INSERT INTO type_action (code, display_value, description, status) VALUES ('new', 'New::::Fou ', NULL, 'c');
INSERT INTO type_action (code, display_value, description, status) VALUES ('vary', 'Vary::::Fetuunai', NULL, 'c');
INSERT INTO type_action (code, display_value, description, status) VALUES ('cancel', 'Cancel::::Soloia', NULL, 'c');


ALTER TABLE type_action ENABLE TRIGGER ALL;

--
-- Data for Name: request_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE request_type DISABLE TRIGGER ALL;

INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('removeLifeEstate', 'registrationServices', 'Cancel Life Estate::::SAMOAN', 'Cancel Life Estate', 'c', 5, 100.00, 0.00, 0.00, 1, 'Life Estate <reference> cancelled', 'lifeEstate', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('newFreehold', 'registrationServices', 'Create New Title::::SAMOAN', 'Create New Title', 'c', 5, 0.00, 0.00, 0.00, 1, 'New <estate type> title', NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('varyTitle', 'registrationServices', 'Change Estate Type::::SAMOAN', 'Change Estate Type', 'c', 5, 100.00, 0.00, 0.00, 1, 'Title changed from <original estate type> to <new estate type>', 'primary', NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('registerLease', 'registrationServices', 'Record Lease::::SAMOAN', 'Lease or Sub Lease', 'c', 5, 100.00, 0.00, 0.00, 1, 'Lease of <nn> years to <name> until <date>', 'lease', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('newOwnership', 'registrationServices', 'Transfer::::SAMOAN', 'Transfer', 'c', 5, 100.00, 0.00, 0.00, 1, 'Transfer to <name>', 'primary', 'vary');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('mortgage', 'registrationServices', 'Record Mortgage::::SAMOAN', 'Mortgage', 'c', 5, 100.00, 0.00, 0.00, 1, 'Mortgage to <lender>', 'mortgage', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('caveat', 'registrationServices', 'Record Caveat::::SAMOAN', 'Caveat', 'c', 5, 100.00, 0.00, 0.00, 1, 'Caveat in the name of <name>', 'caveat', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('newDigitalTitle', 'registrationServices', 'Convert to Title::::SAMOAN', 'Conversion', 'c', 5, 0.00, 0.00, 0.00, 1, 'Title converted from paper', NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('order', 'registrationServices', 'Record Court Order::::SAMOAN', 'Order', 'c', 5, 100.00, 0.00, 0.00, 1, 'Court Order <order>', 'order', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('subLease', 'registrationServices', 'Record Sub Lease::::SAMOAN', 'Sub Lease', 'c', 5, 100.00, 0.00, 0.00, 1, 'Sub Lease of nn years to <name> until <date>', 'lease', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('registrarCorrection', 'registrationServices', 'Correct Registry::::SAMOAN', 'Registry Dealing', 'c', 5, 0.00, 0.00, 0.00, 1, 'Correction by Registrar to <reference>', NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('registrarCancel', 'registrationServices', 'Correct Registry (Cancel Right)::::SAMOAN', 'Registry Dealing', 'c', 5, 0.00, 0.00, 0.00, 1, 'Correction by Registrar to <reference>', NULL, 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cancelProperty', 'registrationServices', 'Cancel Title::::SAMOAN', 'Cancel Title', 'c', 5, 0.00, 0.00, 0.00, 1, NULL, NULL, 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('varyCaveat', 'registrationServices', 'Change Caveat::::SAMOAN', 'Variation of Caveat', 'c', 5, 100.00, 0.00, 0.00, 1, 'Variation of caveat <reference>', 'caveat', 'vary');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cadastreChange', 'cadastralServices', 'Record Plan::::SAMOAN', 'Plan', 'c', 30, 23.00, 0.00, 11.50, 1, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('redefineCadastre', 'cadastralServices', 'Change Map::::SAMOAN', NULL, 'c', 30, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('regnStandardDocument', 'nonRegServices', 'Record Standard Memorandum::::SAMOAN', 'Standard Memoranda', 'c', 3, 100.00, 0.00, 0.00, 0, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('regnPowerOfAttorney', 'nonRegServices', 'Record Power of Attorney::::SAMOAN', 'Power of Attorney', 'c', 3, 100.00, 0.00, 0.00, 0, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cnclStandardDocument', 'nonRegServices', 'Cancel Standard Memorandum::::SAMOAN', 'Revocation of Standard Memoranda', 'c', 3, 100.00, 0.00, 0.00, 0, NULL, NULL, 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('certifiedCopy', 'informationServices', 'Produce/Print a Certified Copy::::SAMOAN', 'Application for a Certified True Copy', 'c', 2, 100.00, 0.00, 0.00, 0, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cadastrePrint', 'informationServices', 'Map Print::::SAMOAN', '', 'x', 1, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cadastreExport', 'informationServices', 'Map Export::::SAMOAN', '', 'x', 1, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cadastreBulk', 'informationServices', 'Bulk Map Export::::SAMOAN', '', 'x', 1, 0.00, 0.00, 0.00, 0, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cnclMortgagePOS', 'registrationServices', 'Cancel Mortgage under Power of Sale::::SAMOAN', 'Discharge of Mortgage under Power of Sale', 'c', 5, 0.00, 0.00, 0.00, 1, 'Mortgage <reference> cancelled', 'mortgage', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('planNoCoords', 'cadastralServices', 'Record Plan with No Coordinates::::SAMOAN', 'Record Plan with no coordinates', 'c', 30, 23.00, 0.00, 11.50, 0, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('regnOnTitle', 'registrationServices', 'Change Right or Restriction::::SAMOAN', 'Miscellaneous', 'c', 5, 100.00, 0.00, 0.00, 1, '<memorial>', NULL, 'vary');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cnclPowerOfAttorney', 'nonRegServices', 'Revoke Power of Attorney::::SAMOAN', 'Revocation of Power of Attorney', 'c', 3, 100.00, 0.00, 0.00, 0, NULL, NULL, 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('proclamation', 'registrationServices', 'Record Proclamation::::SAMOAN', 'Proclamation::::...', 'c', 5, 0.00, 0.00, 0.00, 1, 'Proclamation <proclamation>', 'primary', NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('removeCaveat', 'registrationServices', 'Removal of Caveat::::SAMOAN', 'Withdrawal of Caveat', 'c', 5, 100.00, 0.00, 0.00, 1, 'Caveat <reference> cancelled', 'caveat', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('removeRestriction', 'registrationServices', 'Discharge of Mortgage::::SAMOAN', 'Discharge of Mortgage::::...', 'c', 5, 100.00, 0.00, 0.00, 1, 'Mortgage <reference> cancelled', 'mortgage', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cancelMisc', 'registrationServices', 'Cancel Memorial::::SAMOAN', 'Cancel Miscellaneous', 'c', 5, 0.00, 0.00, 0.00, 1, 'Miscellaneous <reference> canceled', 'miscellaneous', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('varyLease', 'registrationServices', 'Variation of Lease or Sublease::::SAMOAN', 'Transfer or Renew Lease::::...', 'c', 5, 100.00, 0.00, 0.00, 1, 'Variation of lease <reference> for <nn> years to <name> until <date>', 'lease', 'vary');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('removeProclamation', 'registrationServices', 'Cancel Proclamation::::SAMOAN', 'Revocation of Proclamation', 'x', 5, 0.00, 0.00, 0.00, 1, 'Proclamation <reference> cancelled', 'proclamation', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('variationMortgage', 'registrationServices', 'Variation of Mortgage::::SAMOAN', 'Variation of Mortgage', 'c', 5, 100.00, 0.00, 0.00, 1, 'Variation of mortgage <reference>', 'mortgage', 'vary');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('removeOrder', 'registrationServices', 'Remove Court Order::::SAMOAN', 'Revocation of Order', 'c', 5, 100.00, 0.00, 0.00, 1, 'Court Order <reference> cancelled', 'order', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('miscellaneous', 'registrationServices', 'Record Memorial::::SAMOAN', 'Miscellaneous', 'c', 5, 0.00, 0.00, 0.00, 1, '<memorial>', 'miscellaneous', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('lapseCaveat', 'registrationServices', 'Lapse of Caveat::::SAMOAN', 'Withdrawal of Caveat', 'c', 5, 0.00, 0.00, 0.00, 1, 'Caveat <reference> cancelled', 'caveat', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('removeRight', 'registrationServices', 'Termination of Lease or Sublease::::SAMOAN', 'Terminate Lease::::...', 'c', 5, 100.00, 0.00, 0.00, 1, 'Lease <reference> cancelled', 'lease', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('unitPlan', 'cadastralServices', 'Record Unit Plan::::SAMOAN', 'Unit Plan', 'x', 30, 23.00, 0.00, 11.50, 1, NULL, NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('transmission', 'registrationServices', 'Record Transmission::::SAMOAN', 'Transmission', 'c', 5, 100.00, 0.00, 0.00, 1, 'Transmission to <name>', 'primary', 'vary');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('removeEasement', 'registrationServices', 'Cancel Easement::::SAMOAN', 'Cancel Easement', 'c', 5, 0.00, 0.00, 0.00, 1, 'Easement <reference> cancelled', 'servitude', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('easement', 'registrationServices', 'Record Easement::::SAMOAN', 'Easement::::...', 'c', 5, 0.00, 0.00, 0.00, 1, 'Subject to Memorandum of Easements endorsed thereon', 'servitude', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('newUnitTitle', 'registrationServices', 'Create Unit Titles::::SAMOAN', 'Create Unit Titles', 'x', 5, 0.00, 0.00, 0.00, 1, 'New <estate type> unit title', NULL, NULL);
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cancelUnitPlan', 'registrationServices', 'Cancel Unit Titles::::SAMOAN', 'Unit Title Cancellation', 'x', 5, 100.00, 0.00, 0.00, 1, NULL, NULL, 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('changeBodyCorp', 'registrationServices', 'Change Body Corporate::::SAMOAN', 'Variation to Body Corporate', 'x', 5, 100.00, 0.00, 0.00, 1, 'Change Body Corporate Rules / Change Address for Service to <address>', 'commonProperty', 'vary');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('recordMiscFee', 'registrationServices', 'Record Miscellaneous', 'Creates a Miscellaneous RRR on the property with a fee', 'c', 5, 100.00, 0.00, 0.00, 1, '<memorial>', 'miscellaneous', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cancelMiscFee', 'registrationServices', 'Cancel Miscellaneous', 'Cancels a Miscellaneous RRR on the property with a fee', 'c', 5, 100.00, 0.00, 0.00, 1, 'Miscellaneous <reference> cancelled', 'miscellaneous', 'cancel');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('lifeEstate', 'registrationServices', 'Record Life Estate::::SAMOAN', 'Life Estate', 'c', 5, 0.00, 0.00, 0.00, 1, 'Life Estate for <name1> with Remainder Estate in <name2, name3>', 'lifeEstate', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('lifeEstateFee', 'registrationServices', 'Record Life Estate with Fee', 'Creates a Life Estate RRR with a fee', 'c', 5, 100.00, 0.00, 0.00, 1, 'Life Estate for <name1> with Remainder Estate in <name2, name3>', 'lifeEstate', 'new');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('removeTransmission', 'registrationServices', 'Cancel Transmission::::SAMOAN', 'Cancel Transmission', 'c', 5, 100.00, 0.00, 0.00, 1, 'Transmission <reference> canceled', 'primary', 'vary');
INSERT INTO request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code) VALUES ('cnclTransmissonAdmin', 'registrationServices', 'Cancel Transmission under Transfer by Administrator::::SAMOAN', 'Cancel Transmission', 'c', 5, 0.00, 0.00, 0.00, 1, 'Transmission <reference> canceled', 'primary', 'vary');


ALTER TABLE request_type ENABLE TRIGGER ALL;

--
-- Data for Name: service_status_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE service_status_type DISABLE TRIGGER ALL;

INSERT INTO service_status_type (code, display_value, status, description) VALUES ('lodged', 'Lodged::::Ua Faaulu', 'c', 'Application for a service has been lodged and officially received by land office::::La pratica per un servizio, registrata e formalmente ricevuta da ufficio territoriale');
INSERT INTO service_status_type (code, display_value, status, description) VALUES ('completed', 'Completed::::Ua Maea', 'c', NULL);
INSERT INTO service_status_type (code, display_value, status, description) VALUES ('pending', 'Pending::::Faamalumalu', 'c', NULL);
INSERT INTO service_status_type (code, display_value, status, description) VALUES ('cancelled', 'Cancelled::::Ua Soloia', 'c', NULL);


ALTER TABLE service_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: service_action_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

ALTER TABLE service_action_type DISABLE TRIGGER ALL;

INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('lodge', 'Lodge::::Faaulu', 'lodged', 'c', 'Application for service(s) is officially received by land office (action is automatically logged when application is saved for the first time)::::La pratica per i servizi formalmente ricevuta da ufficio territoriale');
INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('start', 'Start::::Amata', 'pending', 'c', 'Provisional RRR Changes Made to Database as a result of application (action is automatically logged when a change is made to a rrr object)::::Apportate Modifiche Provvisorie di tipo RRR al Database come risultato della pratica');
INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('cancel', 'Cancel::::Soloia', 'cancelled', 'c', 'Service is cancelled by Land Office (action is automatically logged when a service is cancelled)::::Pratica cancellata da Ufficio Territoriale');
INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('complete', 'Complete::::Maea', 'completed', 'c', 'Application is ready for approval (action is automatically logged when service is marked as complete::::Pratica pronta per approvazione');
INSERT INTO service_action_type (code, display_value, status_to_set, status, description) VALUES ('revert', 'Revert::::Se''ei i ai', 'pending', 'c', 'The status of the service has been reverted to pending from being completed (action is automatically logged when a service is reverted back for further work)::::Lo stato del servizio riportato da completato a pendente (azione automaticamente registrata quando un servizio viene reinviato per ulteriori adempimenti)');


ALTER TABLE service_action_type ENABLE TRIGGER ALL;

SET search_path = cadastre, pg_catalog;

--
-- Data for Name: area_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE area_type DISABLE TRIGGER ALL;

INSERT INTO area_type (code, display_value, description, status) VALUES ('calculatedArea', 'Calculated Area::::Tele ua Vevaeina', NULL, 'c');
INSERT INTO area_type (code, display_value, description, status) VALUES ('nonOfficialArea', 'Non-official Area::::Tele e lei faailoaina', NULL, 'c');
INSERT INTO area_type (code, display_value, description, status) VALUES ('officialArea', 'Official Area::::Tele ua faailoaina', NULL, 'c');
INSERT INTO area_type (code, display_value, description, status) VALUES ('surveyedArea', 'Surveyed Area::::Tele ua Fuaina', NULL, 'c');


ALTER TABLE area_type ENABLE TRIGGER ALL;

--
-- Data for Name: building_unit_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE building_unit_type DISABLE TRIGGER ALL;

INSERT INTO building_unit_type (code, display_value, description, status) VALUES ('individual', 'Individual::::Taitoatasi', NULL, 'c');
INSERT INTO building_unit_type (code, display_value, description, status) VALUES ('shared', 'Shared::::fefa''asoaa''i', NULL, 'c');


ALTER TABLE building_unit_type ENABLE TRIGGER ALL;

--
-- Data for Name: cadastre_object_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE cadastre_object_type DISABLE TRIGGER ALL;

INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('parcel', 'Parcel::::Poloka', NULL, 'c', true);
INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('buildingUnit', 'Building Unit::::Iunite o le Fale', NULL, 'c', false);
INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('utilityNetwork', 'Utility Network::::feso''ota''iga i auala mana''omia', NULL, 'c', false);
INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('principalUnit', 'Principal Unit::::SAMOAN', NULL, 'c', false);
INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('accessoryUnit', 'Accessory Unit::::SAMOAN', NULL, 'c', false);
INSERT INTO cadastre_object_type (code, display_value, description, status, in_topology) VALUES ('commonProperty', 'Common Property::::SAMOAN', NULL, 'c', false);


ALTER TABLE cadastre_object_type ENABLE TRIGGER ALL;

--
-- Data for Name: dimension_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE dimension_type DISABLE TRIGGER ALL;

INSERT INTO dimension_type (code, display_value, description, status) VALUES ('liminal', 'Liminal', NULL, 'x');
INSERT INTO dimension_type (code, display_value, description, status) VALUES ('0D', '0D::::OD', NULL, 'c');
INSERT INTO dimension_type (code, display_value, description, status) VALUES ('1D', '1D::::1D', NULL, 'c');
INSERT INTO dimension_type (code, display_value, description, status) VALUES ('2D', '2D::::2D', NULL, 'c');
INSERT INTO dimension_type (code, display_value, description, status) VALUES ('3D', '3D::::3D', NULL, 'c');


ALTER TABLE dimension_type ENABLE TRIGGER ALL;

--
-- Data for Name: level_content_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE level_content_type DISABLE TRIGGER ALL;

INSERT INTO level_content_type (code, display_value, description, status) VALUES ('building', 'Building::::Costruzione', NULL, 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('customary', 'Customary::::Consueto', NULL, 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('informal', 'Informal::::Informale', NULL, 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('mixed', 'Mixed::::Misto', NULL, 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('network', 'Network::::Rete', NULL, 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('responsibility', 'Responsibility::::Responsabilita', NULL, 'x');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('primaryRight', 'Primary Right::::Saolotoga Muamua', NULL, 'c');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('restriction', 'Restriction::::Faamalosia', NULL, 'c');
INSERT INTO level_content_type (code, display_value, description, status) VALUES ('geographicLocator', 'Geographic Locators::::Faaailoga e iloa ai', 'Extension to LADM', 'c');


ALTER TABLE level_content_type ENABLE TRIGGER ALL;

--
-- Data for Name: register_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE register_type DISABLE TRIGGER ALL;

INSERT INTO register_type (code, display_value, description, status) VALUES ('all', 'All::::Mea uma', NULL, 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('forest', 'Forest::::Vaomatua', NULL, 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('mining', 'Mining::::Eliga', NULL, 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('publicSpace', 'Public Space::::Avanoa Faitele', NULL, 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('rural', 'Rural::::Nuu I Tua', NULL, 'c');
INSERT INTO register_type (code, display_value, description, status) VALUES ('urban', 'Urban::::Nuu I le Taulaga', NULL, 'c');


ALTER TABLE register_type ENABLE TRIGGER ALL;

--
-- Data for Name: structure_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE structure_type DISABLE TRIGGER ALL;

INSERT INTO structure_type (code, display_value, description, status) VALUES ('unStructuredLine', 'UnstructuredLine::::LineanonDefinita', NULL, 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('point', 'Point::::Faailoga', NULL, 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('polygon', 'Polygon::::Tafatele', NULL, 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('sketch', 'Sketch::::Ata Faataitai', NULL, 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('text', 'Text::::Mataitusi', NULL, 'c');
INSERT INTO structure_type (code, display_value, description, status) VALUES ('topological', 'Topological::::Ta''atiaga o le fanua', NULL, 'c');


ALTER TABLE structure_type ENABLE TRIGGER ALL;

--
-- Data for Name: surface_relation_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE surface_relation_type DISABLE TRIGGER ALL;

INSERT INTO surface_relation_type (code, display_value, description, status) VALUES ('above', 'Above::::Sopra', NULL, 'x');
INSERT INTO surface_relation_type (code, display_value, description, status) VALUES ('below', 'Below::::Sotto', NULL, 'x');
INSERT INTO surface_relation_type (code, display_value, description, status) VALUES ('mixed', 'Mixed::::Misto', NULL, 'x');
INSERT INTO surface_relation_type (code, display_value, description, status) VALUES ('onSurface', 'On Surface::::Foligavaaia', NULL, 'c');


ALTER TABLE surface_relation_type ENABLE TRIGGER ALL;

--
-- Data for Name: utility_network_status_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE utility_network_status_type DISABLE TRIGGER ALL;

INSERT INTO utility_network_status_type (code, display_value, description, status) VALUES ('inUse', 'In Use::::O loo Faaaoga', NULL, 'c');
INSERT INTO utility_network_status_type (code, display_value, description, status) VALUES ('outOfUse', 'Out of Use::::Ua leo Faaogaina', NULL, 'c');
INSERT INTO utility_network_status_type (code, display_value, description, status) VALUES ('planned', 'Planned::::Fuafua', NULL, 'c');


ALTER TABLE utility_network_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: utility_network_type; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE utility_network_type DISABLE TRIGGER ALL;

INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('chemical', 'Chemicals::::Vailaau', NULL, 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('electricity', 'Electricity::::Eletise', NULL, 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('gas', 'Gas::::Kesi', NULL, 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('heating', 'Heating::::Faavevela', NULL, 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('oil', 'Oil::::Suauu', NULL, 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('telecommunication', 'Telecommunication::::Faafesootaiga', NULL, 'c');
INSERT INTO utility_network_type (code, display_value, description, status) VALUES ('water', 'Water::::Suavai', NULL, 'c');


ALTER TABLE utility_network_type ENABLE TRIGGER ALL;

SET search_path = party, pg_catalog;

--
-- Data for Name: communication_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE communication_type DISABLE TRIGGER ALL;

INSERT INTO communication_type (code, display_value, status, description) VALUES ('eMail', 'e-Mail::::Fetusiaiga Faakomipiuta', 'c', NULL);
INSERT INTO communication_type (code, display_value, status, description) VALUES ('fax', 'Fax::::Masini lafo meli', 'c', NULL);
INSERT INTO communication_type (code, display_value, status, description) VALUES ('post', 'Post::::Lafo', 'c', NULL);
INSERT INTO communication_type (code, display_value, status, description) VALUES ('phone', 'Phone::::Telefoni', 'c', NULL);
INSERT INTO communication_type (code, display_value, status, description) VALUES ('courier', 'Courier::::Avefeau', 'c', NULL);


ALTER TABLE communication_type ENABLE TRIGGER ALL;

--
-- Data for Name: gender_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE gender_type DISABLE TRIGGER ALL;

INSERT INTO gender_type (code, display_value, status, description) VALUES ('male', 'Male::::Alii', 'c', NULL);
INSERT INTO gender_type (code, display_value, status, description) VALUES ('female', 'Female::::Tamaitai', 'c', NULL);


ALTER TABLE gender_type ENABLE TRIGGER ALL;

--
-- Data for Name: group_party_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE group_party_type DISABLE TRIGGER ALL;

INSERT INTO group_party_type (code, display_value, status, description) VALUES ('tribe', 'Tribe::::Tribu', 'x', NULL);
INSERT INTO group_party_type (code, display_value, status, description) VALUES ('baunitGroup', 'Basic Administrative Unit Group::::Unita Gruppo Amministrativo di Base', 'x', NULL);
INSERT INTO group_party_type (code, display_value, status, description) VALUES ('association', 'Association::::Auaufaatasi', 'c', NULL);
INSERT INTO group_party_type (code, display_value, status, description) VALUES ('family', 'Family::::Aiga', 'c', NULL);


ALTER TABLE group_party_type ENABLE TRIGGER ALL;

--
-- Data for Name: id_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE id_type DISABLE TRIGGER ALL;

INSERT INTO id_type (code, display_value, status, description) VALUES ('nationalID', 'National ID::::Pepa faamaonia Tagatanuu', 'c', 'The main person ID that exists in the country::::Il principale documento identificativo nel paese');
INSERT INTO id_type (code, display_value, status, description) VALUES ('nationalPassport', 'National Passport::::Tusifolau Tagatanuu', 'c', 'A passport issued by the country::::Passaporto fornito dal paese');
INSERT INTO id_type (code, display_value, status, description) VALUES ('otherPassport', 'Other Passport::::Isi Tusifolau', 'c', 'A passport issued by another country::::Passaporto Fornito da un altro paese');


ALTER TABLE id_type ENABLE TRIGGER ALL;

--
-- Data for Name: party_role_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE party_role_type DISABLE TRIGGER ALL;

INSERT INTO party_role_type (code, display_value, status, description) VALUES ('conveyor', 'Conveyor::::Trasportatore', 'x', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('writer', 'Writer::::Autore', 'x', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('employee', 'Employee::::Impiegato', 'x', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('farmer', 'Farmer::::Contadino', 'x', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('notary', 'Notary::::Faaailogaina', 'c', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('certifiedSurveyor', 'Licenced Surveyor::::Fuafanua Laiseneina', 'c', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('bank', 'Bank::::Fale Tupe', 'c', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('moneyProvider', 'Money Provider::::Aumaia Tupe', 'c', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('citizen', 'Citizen::::Tagatanuu', 'c', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('stateAdministrator', 'Registrar / Approving Surveyor::::Resitala / Fuafanua Pasiaina', 'c', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('landOfficer', 'Land Officer::::Tagata Ofisa o Eleele', 'c', 'Extension to LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('lodgingAgent', 'Lodging Agent::::Vaega mo le Tuuina mai', 'c', 'Extension to LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('powerOfAttorney', 'Power of Attorney::::Malosiaga o le Loia Sili', 'c', 'Extension to LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('transferee', 'Transferee (to)::::Tagata e Ave I ai', 'c', 'Extension to LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('transferor', 'Transferor (from)::::Tagata e Aumai ai', 'c', 'Extension to LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('applicant', 'Applicant::::Tagata Talosaga', 'c', 'Extension to LADM');
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('surveyor', 'Surveyor::::Fuafanua', 'c', NULL);
INSERT INTO party_role_type (code, display_value, status, description) VALUES ('lawyer', 'Lawyer::::SAMOAN', 'c', NULL);


ALTER TABLE party_role_type ENABLE TRIGGER ALL;

--
-- Data for Name: party_type; Type: TABLE DATA; Schema: party; Owner: postgres
--

ALTER TABLE party_type DISABLE TRIGGER ALL;

INSERT INTO party_type (code, display_value, status, description) VALUES ('group', 'Group::::Gruppo', 't', NULL);
INSERT INTO party_type (code, display_value, status, description) VALUES ('naturalPerson', 'Natural Person::::Tagata na umia muamua', 'c', NULL);
INSERT INTO party_type (code, display_value, status, description) VALUES ('nonNaturalPerson', 'Non-natural Person::::E le o ia na umiaina muamua', 'c', NULL);
INSERT INTO party_type (code, display_value, status, description) VALUES ('baunit', 'Basic Administrative Unit::::Vaega o Pulega Amata', 'c', NULL);


ALTER TABLE party_type ENABLE TRIGGER ALL;

SET search_path = source, pg_catalog;

--
-- Data for Name: administrative_source_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

ALTER TABLE administrative_source_type DISABLE TRIGGER ALL;


INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('agreement', 'Agreement::::Autasiga', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('application', 'Request Form::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('caveat', 'Caveat::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('circuitPlan', 'Circuit Plan::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('coastalPlan', 'Coastal Plan::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('courtOrder', 'Court Order::::Faatonuga a le Faamasinoga', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('deed', 'Deed::::Pepa o le Fanua', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('landClaimPlan', 'Land Claim (LC) Plan::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('landClaims', 'Land Claim::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('lease', 'Lease::::Lisi', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('memorandum', 'Memorandum::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('other', 'Miscellaneous::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('mortgage', 'Mortgage::::Mokesi', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('cadastralSurvey', 'Plan::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('powerOfAttorney', 'Power of Attorney::::Paoa o le Loia Sili', 'c', NULL, true);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('proclamation', 'Proclamation::::Faasalalauga Faaletulafono', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('note', 'Office Note::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('idVerification', 'Proof of Identity::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('recordMaps', 'Record Map::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('registered', 'Migrated::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('requisitionNotice', 'Requisition Notice::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('schemePlan', 'Scheme Plan::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('standardForm', 'Standard Form::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('standardDocument', 'Standard Memorandum::::SAMOAN', 'c', NULL, true);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('surveyDataFile', 'Survey Data File::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('newFormFolio', 'New Form Folio::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('titlePlan', 'Title Plan::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('waiver', 'Waiver::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('will', 'Probated Will::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('qaChecklist', 'QA Checklist::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('consent', 'Consent Form::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('traverse', 'Traverse Sheet::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('flurPlan', 'Flur Plan::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('courtJudgement', 'Lands and Titles Court Judgement::::...', 'c', 'Judgement issued by the Lands and Titles Court::::...', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('unitPlan', 'Unit Plan::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('bodyCorpRules', 'Body Corporate Rules::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('unitEntitlements', 'Schedule of Unit Entitlements::::SAMOAN', 'c', NULL, false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('transfer', 'Transfer', 'c', 'Application transfer form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('dischargeMortgage', 'Discharge of Mortgage', 'c', 'Discharge of Mortgage application form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('registryDealing', 'Registry Dealing', 'c', 'Registry Dealing application form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('transmission', 'Transmission', 'c', 'Transmission application form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('cancelLease', 'Cancel Lease or Sublease', 'c', 'Cancel Lease application form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('assignLease', 'Assignment of Lease', 'c', 'Assignment of Lease application form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('varyMortgage', 'Variation of Mortgage', 'c', 'Variation of Mortgage application form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('varyLease', 'Variation of Lease', 'c', 'Variation of Lease application form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('removeCaveat', 'Removal of Caveat', 'c', 'Removal of Caveat application form', false);
INSERT INTO administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('conveyance', 'Conveyance', 'c', 'Deed of conveyance', false);




ALTER TABLE administrative_source_type ENABLE TRIGGER ALL;

--
-- Data for Name: availability_status_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

ALTER TABLE availability_status_type DISABLE TRIGGER ALL;

INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('archiveDestroyed', 'Destroyed::::Distrutto', 'x', NULL);
INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('archiveConverted', 'Converted::::Faaliliuina', 'c', NULL);
INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('incomplete', 'Incomplete::::Lei maea', 'c', NULL);
INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('archiveUnknown', 'Unknown::::Le maua', 'c', NULL);
INSERT INTO availability_status_type (code, display_value, status, description) VALUES ('available', 'Available::::Avanoa', 'c', 'Extension to LADM');


ALTER TABLE availability_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: presentation_form_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

ALTER TABLE presentation_form_type DISABLE TRIGGER ALL;

INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('documentDigital', 'Digital Document::::Faamaumauga o faamatalaga i Komepiuta', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('documentHardcopy', 'Hardcopy Document::::Kopi malo/pepa o faamatalaga', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('imageDigital', 'Digital Image::::Ata o lo''o faamaumau i komepiuta', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('imageHardcopy', 'Hardcopy Image::::Kopi Malo o Ata', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('mapDigital', 'Digital Map::::Faafanua o lo''o faamaumau i komepiuta', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('mapHardcopy', 'Hardcopy Map::::Kopi malo/pepa o Faafanua', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('modelDigital', 'Digital Model::::Faamaumauga o le Ituaiga i komepiuta', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('modelHarcopy', 'Hardcopy Model::::Kopi malo/pepa o le Ituaiga', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('profileDigital', 'Digital Profile::::Faamaumauga o le Talatalaga i komepiuta', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('profileHardcopy', 'Hardcopy Profile::::kopi malo/pepa o le Talatalaga', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('tableDigital', 'Digital Table::::Faamaumauga o Laulau o Faamatalaga i komepiuta', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('tableHardcopy', 'Hardcopy Table::::Kopi malo/pepa o laulau o faamatalaga', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('videoDigital', 'Digital Video::::Faamaumauga o Ata Video i komepiuta', 'c', NULL);
INSERT INTO presentation_form_type (code, display_value, status, description) VALUES ('videoHardcopy', 'Hardcopy Video::::Kopi Malo o le Ata Tifaga/Video', 'c', NULL);


ALTER TABLE presentation_form_type ENABLE TRIGGER ALL;

--
-- Data for Name: spatial_source_type; Type: TABLE DATA; Schema: source; Owner: postgres
--

ALTER TABLE spatial_source_type DISABLE TRIGGER ALL;

INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('surveyData', 'Survey Data (Coordinates)::::Rilevamento Data', 'c', 'Extension to LADM');
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('fieldSketch', 'Field Sketch::::Ata Faatusa Laufanua', 'c', NULL);
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('gnssSurvey', 'GNSS (GPS) Survey::::GNSS (GPS) Fuataga.', 'c', NULL);
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('orthoPhoto', 'Orthophoto::::Ata o le Faafanua', 'c', NULL);
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('relativeMeasurement', 'Relative Measurements::::Fua Fesootai', 'c', NULL);
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('topoMap', 'Topographical Map::::Faafanua o le Laufanua', 'c', NULL);
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('video', 'Video::::Ata Vito', 'c', NULL);
INSERT INTO spatial_source_type (code, display_value, status, description) VALUES ('cadastralSurvey', 'Cadastral Survey::::Fuataga o Tuaoi', 'c', 'Extension to LADM');


ALTER TABLE spatial_source_type ENABLE TRIGGER ALL;

SET search_path = system, pg_catalog;

--
-- Data for Name: approle; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE approle DISABLE TRIGGER ALL;

INSERT INTO approle (code, display_value, status, description) VALUES ('DashbrdViewAssign', 'View Assigned Applications', 'c', 'View Assigned Applications in Dashboard');
INSERT INTO approle (code, display_value, status, description) VALUES ('DashbrdViewUnassign', 'View Unassigned Applications', 'c', 'View Unassigned Applications in Dashboard');
INSERT INTO approle (code, display_value, status, description) VALUES ('DashbrdViewOwn', 'View Own Applications', 'c', 'View Applications assigned to user  in Dashboard');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnView', 'Search and View Applications', 'c', 'Search and view applications');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnCreate', 'Lodge new Applications', 'c', 'Lodge new Applications');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnStatus', 'Generate and View Status Report', 'c', 'Generate and View Status Report');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnAssignSelf', 'Assign Applications to Self', 'c', 'Able to assign (unassigned) applications to yourself');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnUnassignSelf', 'Unassign Applications to Self', 'c', 'Able to unassign (assigned) applications from yourself');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnAssignOthers', 'Assign Applications to Other Users', 'c', 'Able to assign (unassigned) applications to other users');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnUnassignOthers', 'Unassign Applications to Others', 'c', 'Able to unassign (assigned) applications to other users');
INSERT INTO approle (code, display_value, status, description) VALUES ('StartService', 'Start Service', 'c', 'Start Service');
INSERT INTO approle (code, display_value, status, description) VALUES ('CompleteService', 'Complete Service', 'c', 'Complete Service (prior to approval)');
INSERT INTO approle (code, display_value, status, description) VALUES ('CancelService', 'Cancel Service', 'c', 'Cancel Service');
INSERT INTO approle (code, display_value, status, description) VALUES ('RevertService', 'Revert Service', 'c', 'Revert previously Complete Service');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnRequisition', 'Requisition application and request', 'c', 'Request further information from applicant');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnResubmit', 'Resubmit Application', 'c', 'Resubmit (requisitioned) application');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnApprove', 'Approve Application', 'c', 'Approve Application');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnWithdraw', 'Withdraw Application', 'c', 'Applicant withdraws their application');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnReject', 'Reject Application', 'c', 'Land Office rejects an application');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnValidate', 'Validate Application', 'c', 'User manually runs validation rules for application');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnDispatch', 'Dispatch Application', 'c', 'Dispatch any documents to be returned to applicant and any certificates/reports/map prints requested by applicant');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnArchive', 'Archive Application', 'c', 'Paper Application File is stored in Land Office Archive');
INSERT INTO approle (code, display_value, status, description) VALUES ('BaunitSave', 'Create or Modify BA Unit', 'c', 'Create or Modify BA Unit (Property)');
INSERT INTO approle (code, display_value, status, description) VALUES ('BauunitrrrSave', 'Create or Modify Rights or Restrictions', 'c', 'Create or Modify Rights or Restrictions');
INSERT INTO approle (code, display_value, status, description) VALUES ('BaunitParcelSave', 'Create or Modify (BA Unit) Parcels', 'c', 'Create or Modify (BA Unit) Parcels');
INSERT INTO approle (code, display_value, status, description) VALUES ('BaunitNotatSave', 'Create or Modify (BA Unit) Notations', 'c', 'Create or Modify (BA Unit) Notations');
INSERT INTO approle (code, display_value, status, description) VALUES ('BaunitCertificate', 'Generate and Print (BA Unit) Certificate', 'c', 'Generate and Print (BA Unit) Certificate');
INSERT INTO approle (code, display_value, status, description) VALUES ('BaunitSearch', 'Search BA Unit', 'c', 'Search BA Unit');
INSERT INTO approle (code, display_value, status, description) VALUES ('TransactionCommit', 'Approve (and Cancel) Transaction', 'c', 'Approve (and Cancel) Transaction');
INSERT INTO approle (code, display_value, status, description) VALUES ('ViewMap', 'View Cadastral Map', 'c', 'View Cadastral Map');
INSERT INTO approle (code, display_value, status, description) VALUES ('PrintMap', 'Print Map', 'c', 'Print Map');
INSERT INTO approle (code, display_value, status, description) VALUES ('ParcelSave', 'Create or modify (Cadastre) Parcel', 'c', 'Create or modify (Cadastre) Parcel');
INSERT INTO approle (code, display_value, status, description) VALUES ('PartySave', 'Create or modify Party', 'c', 'Create or modify Party');
INSERT INTO approle (code, display_value, status, description) VALUES ('SourceSave', 'Create or modify Source', 'c', 'Create or modify Source');
INSERT INTO approle (code, display_value, status, description) VALUES ('SourceSearch', 'Search Sources', 'c', 'Search sources');
INSERT INTO approle (code, display_value, status, description) VALUES ('SourcePrint', 'Print Sources', 'c', 'Print Source');
INSERT INTO approle (code, display_value, status, description) VALUES ('ReportGenerate', 'Generate and View Reports', 'c', 'Generate and View reports');
INSERT INTO approle (code, display_value, status, description) VALUES ('ArchiveApps', 'Archive applications', 'c', 'Archive applications');
INSERT INTO approle (code, display_value, status, description) VALUES ('ManageSecurity', 'Manage users, groups and roles', 'c', 'Manage users, groups and roles');
INSERT INTO approle (code, display_value, status, description) VALUES ('ManageRefdata', 'Manage reference data', 'c', 'Manage reference data');
INSERT INTO approle (code, display_value, status, description) VALUES ('ManageSettings', 'Manage system settings', 'c', 'Manage system settings');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnEdit', 'Application Edit', 'c', 'Allows editing of Applications');
INSERT INTO approle (code, display_value, status, description) VALUES ('ManageBR', 'Manage business rules', 'c', 'Allows to manage business rules');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnViewUnassignAll', 'View all unassigned applications', 'c', 'Allows the user to view all of the unassigned applications
instead of just a filtered view based on the services they can perform');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnViewAssignAll', 'View all assigned applications', 'c', 'Allows the user to view all assigned applications
instead of just a filtered view based on the services they can perform');
INSERT INTO approle (code, display_value, status, description) VALUES ('cnclMortgagePOS', 'Cancel Mortgage under Power of Sale::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('cnclTransmissonAdmin', 'Cancel Transmission under Transfer by Administrator::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('planNoCoords', 'Record Plan with No Coordinates::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('ExportMap', 'Export Map', 'c', 'Export a selected map feature to KML for display in Google Earth');
INSERT INTO approle (code, display_value, status, description) VALUES ('ChangePassword', 'Admin - Change Password', 'c', 'Allows a user to change their password and edit thier user name. This role should be included in every security group.');
INSERT INTO approle (code, display_value, status, description) VALUES ('NoPasswordExpiry', 'Admin - No Password Expiry', 'c', 'Users with this role will not be subject to a password expiry if one is in place. This role can be assigned to user accounts used by other systems to integrate with the SOLA web services.');
INSERT INTO approle (code, display_value, status, description) VALUES ('cadastreChange', 'Record Plan::::SAMOAN', 'c', 'Allows to make changes to the cadastre');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnNr', 'Set Application Number', 'c', 'Set application number to match number allocated by LRS');
INSERT INTO approle (code, display_value, status, description) VALUES ('FeePayment', 'Record Fee Payment', 'c', 'Allows the user to set the Fee Paid flag on the Application Details screen');
INSERT INTO approle (code, display_value, status, description) VALUES ('ApplnCompleteDate', 'Edit Application Completion Date', 'c', 'Allows the user to update the completion date for the application on the Application Details screen');
INSERT INTO approle (code, display_value, status, description) VALUES ('ManageUserPassword', 'Manager User Details and Password', 'c', 'Allows the user to update their user details and/or password');
INSERT INTO approle (code, display_value, status, description) VALUES ('ViewSource', 'View Source Details', 'c', 'Allows the user to view source and document details.');
INSERT INTO approle (code, display_value, status, description) VALUES ('PartySearch', 'Search Party', 'c', 'Allows the user access to the Party Search so they can edit existing parties (i.e. Lodging Agent and Bank details).');
INSERT INTO approle (code, display_value, status, description) VALUES ('cadastrePrint', 'Map Print::::SAMOAN', 'c', 'Allows to make prints of cadastre map');
INSERT INTO approle (code, display_value, status, description) VALUES ('cancelProperty', 'Cancel Title::::SAMOAN', 'c', 'Allows to make changes to cancel title');
INSERT INTO approle (code, display_value, status, description) VALUES ('caveat', 'Record Caveat::::SAMOAN', 'c', 'Allows to make changes for registration of caveat');
INSERT INTO approle (code, display_value, status, description) VALUES ('cnclPowerOfAttorney', 'Cancel Power of Attorney::::SAMOAN', 'c', 'Allows to make changes to cancel power of attorney');
INSERT INTO approle (code, display_value, status, description) VALUES ('cnclStandardDocument', 'Cancel Standard Memorandum::::SAMOAN', 'c', 'Allows to make changes to withdraw standard document');
INSERT INTO approle (code, display_value, status, description) VALUES ('mortgage', 'Record Mortgage::::SAMOAN', 'c', 'Allows to make changes for registration of mortgage');
INSERT INTO approle (code, display_value, status, description) VALUES ('newDigitalTitle', 'Convert to Title::::SAMOAN', 'c', 'Allows to make changes for digital conversion of an existing title');
INSERT INTO approle (code, display_value, status, description) VALUES ('newFreehold', 'Create New Title::::SAMOAN', 'c', 'Allows to make changes for registration of a new freehold title');
INSERT INTO approle (code, display_value, status, description) VALUES ('newOwnership', 'Transfer::::SAMOAN', 'c', 'Allows to make changes for registration of ownership change');
INSERT INTO approle (code, display_value, status, description) VALUES ('redefineCadastre', 'Change Map::::SAMOAN', 'c', 'Allows to make changes to existing cadastre objects');
INSERT INTO approle (code, display_value, status, description) VALUES ('registerLease', 'Record Lease::::SAMOAN', 'c', 'Allows to make changes for registration of a lease');
INSERT INTO approle (code, display_value, status, description) VALUES ('regnOnTitle', 'Record Memorial::::SAMOAN', 'c', 'Allows to make changes for general (not specific) registration on a title');
INSERT INTO approle (code, display_value, status, description) VALUES ('regnPowerOfAttorney', 'Record Power of Attorney::::SAMOAN', 'c', 'Allows to make changes for registration of power of attorney');
INSERT INTO approle (code, display_value, status, description) VALUES ('regnStandardDocument', 'Record Standard Memorandum::::SAMOAN', 'c', 'Allows to make changes for registration of a standard document');
INSERT INTO approle (code, display_value, status, description) VALUES ('removeCaveat', 'Cancel Caveat::::SAMOAN', 'c', 'Allows to make changes for the removal of a caveat');
INSERT INTO approle (code, display_value, status, description) VALUES ('removeRestriction', 'Cancel Mortgage::::SAMOAN', 'c', 'Allows to make changes for the removal of a restriction');
INSERT INTO approle (code, display_value, status, description) VALUES ('removeRight', 'Cancel Lease or Sublease::::SAMOAN', 'c', 'Allows to make changes for the removal of a right');
INSERT INTO approle (code, display_value, status, description) VALUES ('varyCaveat', 'Change Caveat::::SAMOAN', 'c', 'Allows to make changes for registration of a variation to a caveat');
INSERT INTO approle (code, display_value, status, description) VALUES ('varyLease', 'Change Lease or Sublease::::SAMOAN', 'c', 'Allows to make changes for registration of a variation to a lease');
INSERT INTO approle (code, display_value, status, description) VALUES ('lifeEstate', 'Record Life Estate::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('removeLifeEstate', 'Cancel Life Estate::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('varyTitle', 'Change Estate Type::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('easement', 'Record Easement::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('removeEasement', 'Cancel Easement::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('variationMortgage', 'Change Mortgage::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('proclamation', 'Record Proclamation::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('order', 'Record Court Order::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('subLease', 'Record Sub Lease::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('registrarCorrection', 'Correct Registry::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('registrarCancel', 'Correct Registry (Cancel Right)::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('removeOrder', 'Cancel Court Order::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('removeProclamation', 'Cancel Proclamation::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('transmission', 'Record Transmission::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('removeTransmission', 'Cancel Transmission::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('miscellaneous', 'Record Miscellaneous::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('cancelMisc', 'Cancel Miscellaneous::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('certifiedCopy', 'Produce/Print a Certified Copy::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('cadastreExport', 'Map Export::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('cadastreBulk', 'Bulk Map Export::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('buildingRestriction', 'Register Building Restriction', 'c', 'Allows to make changes for registration of building restriction');
INSERT INTO approle (code, display_value, status, description) VALUES ('documentCopy', 'Print Archived Document', 'c', 'Allows to print an archived document');
INSERT INTO approle (code, display_value, status, description) VALUES ('historicOrder', 'Register Historic Order', 'c', 'Allows to make changes for registration of historic order');
INSERT INTO approle (code, display_value, status, description) VALUES ('limtedRoadAccess', 'Register Limited Road Access', 'c', 'Allows to make changes for registration of limited road access');
INSERT INTO approle (code, display_value, status, description) VALUES ('newApartment', 'Register Apartment', 'c', 'Allows to make changes for registration of an apartment');
INSERT INTO approle (code, display_value, status, description) VALUES ('serviceEnquiry', 'Service Enquiry', 'c', 'Allows to make a service enquiry');
INSERT INTO approle (code, display_value, status, description) VALUES ('servitude', 'Servitude', 'c', 'Allows to make changes for the registration of a servitude');
INSERT INTO approle (code, display_value, status, description) VALUES ('surveyPlanCopy', 'Survey Plan Print', 'c', 'Allows to make a print of a Survey Plan');
INSERT INTO approle (code, display_value, status, description) VALUES ('titleSearch', 'Title Search', 'c', 'Allows to make title search');
INSERT INTO approle (code, display_value, status, description) VALUES ('varyMortgage', 'Vary Mortgage', 'c', 'Allows to make changes for registration of a variation to a mortgage');
INSERT INTO approle (code, display_value, status, description) VALUES ('varyRight', 'Vary Right or Restriction', 'c', 'Allows to make changes for registration of a variation to a right or restriction');
INSERT INTO approle (code, display_value, status, description) VALUES ('MeasureTool', 'Measure Tool', 'c', 'Allows user to measure a distance on the map.');
INSERT INTO approle (code, display_value, status, description) VALUES ('lapseCaveat', 'Lapse Caveat', 'c', 'Used for processing Lapse Caveat services.');
INSERT INTO approle (code, display_value, status, description) VALUES ('unitPlan', 'Record Unit Plan::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('newUnitTitle', 'Create Unit Titles::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('varyCommonProperty', 'Change Common Property::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('cancelUnitPlan', 'Cancel Unit Plan::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('changeBodyCorp', 'Change Body Corporate::::SAMOAN', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('StrataUnitCreate', 'Create Strata Property', 'c', NULL);
INSERT INTO approle (code, display_value, status, description) VALUES ('ChangeParcelAttrTool', 'Change Parcel Attribute Tool', 'c', 'Allows user to change the name or status of a parcel.');
INSERT INTO approle (code, display_value, status, description) VALUES ('recordMiscFee', 'Service - Record Miscellaneous', 'c', 'Allows the Record Miscellaneous service to be started.');
INSERT INTO approle (code, display_value, status, description) VALUES ('cancelMiscFee', 'Service - Cancel Miscellaneous', 'c', 'Allows the Cancel Miscellaneous service to be started.');
INSERT INTO approle (code, display_value, status, description) VALUES ('lifeEstateFee', 'Service - Record Life Estate with Fee', 'c', 'Allows the Record Life Estate with Fee service to be started.');


ALTER TABLE approle ENABLE TRIGGER ALL;

--
-- Data for Name: br_severity_type; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_severity_type DISABLE TRIGGER ALL;

INSERT INTO br_severity_type (code, display_value, status, description) VALUES ('critical', 'Critical::::Tulaga Matautia', 'c', NULL);
INSERT INTO br_severity_type (code, display_value, status, description) VALUES ('medium', 'Medium::::Ogatotonu', 'c', NULL);
INSERT INTO br_severity_type (code, display_value, status, description) VALUES ('warning', 'Warning::::Lapataiga', 'c', NULL);


ALTER TABLE br_severity_type ENABLE TRIGGER ALL;

--
-- Data for Name: br_technical_type; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_technical_type DISABLE TRIGGER ALL;

INSERT INTO br_technical_type (code, display_value, status, description) VALUES ('sql', 'SQL::::SQL', 'c', 'The rule definition is based in sql and it is executed by the database engine.');
INSERT INTO br_technical_type (code, display_value, status, description) VALUES ('drools', 'Drools::::Drools', 'c', 'The rule definition is based on Drools engine.');


ALTER TABLE br_technical_type ENABLE TRIGGER ALL;

--
-- Data for Name: br_validation_target_type; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_validation_target_type DISABLE TRIGGER ALL;

INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('application', 'Application::::Talosaga', 'c', 'The target of the validation is the application. It accepts one parameter {id} which is the application id.');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('service', 'Service::::Auaunaga', 'c', 'The target of the validation is the service. It accepts one parameter {id} which is the service id.');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('rrr', 'Right or Restriction::::Aia Faatonutonu', 'c', 'The target of the validation is the rrr. It accepts one parameter {id} which is the rrr id. ');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('ba_unit', 'Administrative Unit::::Iunite Pulega', 'c', 'The target of the validation is the ba_unit. It accepts one parameter {id} which is the ba_unit id.');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('source', 'Source::::Tupuaga', 'c', 'The target of the validation is the source. It accepts one parameter {id} which is the source id.');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('cadastre_object', 'Cadastre Object::::Faamaumauga i totonu o le faafanua', 'c', 'The target of the validation is the transaction related with the cadastre change. It accepts one parameter {id} which is the transaction id.');
INSERT INTO br_validation_target_type (code, display_value, status, description) VALUES ('unit_plan', 'Unit Plan', 'c', 'The target of the validation is the transaction related with the unit plan. It accepts one parameter {id} which is the transaction id.');


ALTER TABLE br_validation_target_type ENABLE TRIGGER ALL;

--
-- Data for Name: language; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE language DISABLE TRIGGER ALL;

INSERT INTO language (code, display_value, active, is_default, item_order) VALUES ('en', 'English::::Faapalagi', true, true, 1);
INSERT INTO language (code, display_value, active, is_default, item_order) VALUES ('sm', 'Samoan::::Faasamoa', true, false, 2);


ALTER TABLE language ENABLE TRIGGER ALL;

SET search_path = transaction, pg_catalog;

--
-- Data for Name: reg_status_type; Type: TABLE DATA; Schema: transaction; Owner: postgres
--

ALTER TABLE reg_status_type DISABLE TRIGGER ALL;

INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('current', 'Current::::Taimi nei', NULL, 'c');
INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('pending', 'Pending::::Faamalumalu', NULL, 'c');
INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('historic', 'Historic/Cancelled::::Faasolopito', NULL, 'c');
INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('previous', 'Previous::::Tuanai', NULL, 'c');
INSERT INTO reg_status_type (code, display_value, description, status) VALUES ('dormant', 'Dormant::::SAMOAN', NULL, 'c');


ALTER TABLE reg_status_type ENABLE TRIGGER ALL;

--
-- Data for Name: transaction_status_type; Type: TABLE DATA; Schema: transaction; Owner: postgres
--

ALTER TABLE transaction_status_type DISABLE TRIGGER ALL;

INSERT INTO transaction_status_type (code, display_value, description, status) VALUES ('approved', 'Approved::::Ua Pasia', NULL, 'c');
INSERT INTO transaction_status_type (code, display_value, description, status) VALUES ('cancelled', 'Cancelled::::Ua Soloia', NULL, 'c');
INSERT INTO transaction_status_type (code, display_value, description, status) VALUES ('pending', 'Pending::::Faamalumalu', NULL, 'c');
INSERT INTO transaction_status_type (code, display_value, description, status) VALUES ('completed', 'Completed::::Ua Maea', NULL, 'c');


ALTER TABLE transaction_status_type ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

