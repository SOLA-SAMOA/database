--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = application, pg_catalog;

--
-- Data for Name: request_type_requires_source_type; Type: TABLE DATA; Schema: application; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE request_type_requires_source_type DISABLE TRIGGER ALL;

INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('application', 'mortgage');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('application', 'variationMortgage');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('application', 'transmission');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('application', 'newOwnership');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('application', 'registerLease');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('application', 'subLease');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('note', 'registrarCorrection');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('note', 'registrarCancel');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('cadastralSurvey', 'newFreehold');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('application', 'removeCaveat');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('note', 'regnOnTitle');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('cadastralSurvey', 'cadastreChange');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('note', 'redefineCadastre');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('powerOfAttorney', 'regnPowerOfAttorney');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('standardDocument', 'regnStandardDocument');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('cadastralSurvey', 'planNoCoords');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('unitPlan', 'unitPlan');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('unitPlan', 'newUnitTitle');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('bodyCorpRules', 'newUnitTitle');
INSERT INTO request_type_requires_source_type (source_type_code, request_type_code) VALUES ('unitEntitlements', 'newUnitTitle');


ALTER TABLE request_type_requires_source_type ENABLE TRIGGER ALL;

SET search_path = cadastre, pg_catalog;

--
-- Data for Name: level; Type: TABLE DATA; Schema: cadastre; Owner: postgres
--

ALTER TABLE level DISABLE TRIGGER ALL;

INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('1430659a-3430-11e2-9f26-7387b308b32d', 'Parcels', 'all', 'polygon', 'primaryRight', 'd54224a2-3445-11e2-ac17-932274662d54', 1, 'i', 'test-id', '2012-11-22 12:42:10.98');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('1434363e-3430-11e2-a0e5-3f974f0fbad5', 'Road Centerlines', 'all', 'unStructuredLine', 'network', 'd5448602-3445-11e2-ac3f-8f47c8c8039c', 1, 'i', 'db:postgres', '2012-11-22 12:42:10.996');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('1434ab6e-3430-11e2-9e5c-0b939eb6212b', 'Survey Plans', 'all', 'point', 'primaryRight', 'd5448602-3445-11e2-9a35-bfe19bdfa03b', 1, 'i', 'db:postgres', '2012-11-22 12:42:10.996');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('143372ee-3430-11e2-b474-a3d921ae91f3', 'Court Grants', 'all', 'point', 'primaryRight', 'd5448602-3445-11e2-905f-5b8910444f5a', 1, 'i', 'db:postgres', '2012-11-22 12:42:10.996');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('143547ae-3430-11e2-a546-e3993b166ab2', 'Hydro Features', 'all', 'polygon', 'geographicLocator', 'd5448602-3445-11e2-ba04-d3048dceb5e7', 1, 'i', 'db:postgres', '2012-11-22 12:42:10.996');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('1435bcde-3430-11e2-9ddd-7350de71f251', 'Record Sheets', 'all', 'polygon', 'geographicLocator', 'd5448602-3445-11e2-8d9e-5be5e3798a69', 1, 'i', 'db:postgres', '2012-11-22 12:42:10.996');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('14365928-3430-11e2-b7ce-1792426a0d79', 'Islands', 'all', 'point', 'geographicLocator', 'd546e762-3445-11e2-9f07-f33805b8e932', 1, 'i', 'db:postgres', '2012-11-22 12:42:11.011');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('1436ce58-3430-11e2-99be-93be76f72a4f', 'Districts', 'all', 'point', 'geographicLocator', 'd546e762-3445-11e2-bce8-db5089302e5f', 1, 'i', 'db:postgres', '2012-11-22 12:42:11.011');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('14376a98-3430-11e2-a35c-f7d989458bde', 'Villages', 'all', 'point', 'geographicLocator', 'd546e762-3445-11e2-8008-ffbdb9d9c427', 1, 'i', 'db:postgres', '2012-11-22 12:42:11.011');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('1437dfc8-3430-11e2-931c-eb87eabd2d16', 'Roads', 'all', 'polygon', 'geographicLocator', 'd546e762-3445-11e2-aec6-d34d9ccb69ba', 1, 'i', 'db:postgres', '2012-11-22 12:42:11.011');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('14387c08-3430-11e2-b710-4b5e5b20d6c9', 'Flur', 'all', 'polygon', 'geographicLocator', 'd546e762-3445-11e2-98c0-c399ae974a0f', 1, 'i', 'db:postgres', '2012-11-22 12:42:11.011');
INSERT INTO level (id, name, register_type_code, structure_code, type_code, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ab915cc2-d188-11e3-897f-33dae765a184', 'Unit Parcels', 'all', NULL, 'primaryRight', 'ab9183dc-d188-11e3-8a2d-5740258755a8', 1, 'i', 'db:postgres', '2014-05-02 11:31:07.504');


ALTER TABLE level ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

