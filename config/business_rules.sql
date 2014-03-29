--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = system, pg_catalog;

--
-- Data for Name: br; Type: TABLE DATA; Schema: system; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE br DISABLE TRIGGER ALL;

INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-application-nr', 'generate-application-nr', 'sql', NULL, NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-notation-reference-nr', 'generate-notation-reference-nr', 'sql', NULL, NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-rrr-nr', 'generate-rrr-nr', 'sql', NULL, NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-source-nr', 'generate-source-nr', 'sql', NULL, NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-baunit-nr', 'generate-baunit-nr', 'sql', NULL, NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('rrr-must-have-parties', 'rrr-must-have-parties', 'sql', 'These rights (and restrictions) must have a recorded party (or parties)::::RRR per cui sono previste parti, le devono avere', NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('rrr-shares-total-check', 'rrr-shares-total-check', 'sql', 'The sum of the shares (in ownership rights) must total to 1::::Le quote non raggiungono 1', NULL, '#{id}(administrative.rrr.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-several-mortgages-with-same-rank', 'ba_unit-has-several-mortgages-with-same-rank', 'sql', 'The rank of a new mortgage must not be the same as an existing mortgage registered on the same title::::Il titolo ha una ipoteca corrente con lo stesso grado di priorita', NULL, '#{id}(administrative.rrr.id) is requested.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-caveat', 'ba_unit-has-caveat', 'sql', 'Caveat should not prevent registration proceeding.::::Il titolo ha un diritto di prelazione attivo', NULL, '#{id}(administrative.rrr.id) is requested.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('rrr-has-pending', 'rrr-has-pending', 'sql', 'There are no other pending actions on the rights and restrictions being changed or removed on this application::::Non vi sono modifiche pendenti sul diritto, responsabilita o restrizione che si sta per cambiare o rimuovere', NULL, '#{id}(administrative.rrr.id) is requested. It checks if for the target rrr there is already a pending edit or record.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br8-check-has-services', 'application-br8-check-has-services', 'sql', 'An application must have at least one service::::La Pratica ha almeno un documento allegato', NULL, 'Checks that an application has at least one service. When this rule fails you should add a service to the application or cancel the application.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br7-check-sources-have-documents', 'application-br7-check-sources-have-documents', 'sql', 'Documents lodged with an application should have a scanned image file (or other source file) attached::::Alcuni dei documenti per questa pratica non hanno una immagine scannerizzata allegata', NULL, 'Checks that each document lodged with the application has a scanned image file (or other digital source file) stored in the SOLA database. To remedy the failure of the business rule add the scanned image to the document record through the Document Tab in the Application form or use the Document Toolbar item in the Main form.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br1-check-required-sources-are-present', 'application-br1-check-required-sources-are-present', 'sql', 'All documents required for the services in this application are present.::::Sono presenti tutti i documenti richiesti per il servizio', NULL, 'Checks that all required documents for any of the services in an application are recorded. Null value is returned if there are no required documents');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br2-check-title-documents-not-old', 'application-br2-check-title-documents-not-old', 'sql', 'The scanned image of the title should be less than one week old.::::Tutte le immagini scannerizzate del titolo hanno al massimo una settimana', NULL, 'Checks recorded date (recordation) against date at time of validation. Current allowable date difference is one week.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br3-check-properties-are-not-historic', 'application-br3-check-properties-are-not-historic', 'sql', 'All the titles identified for the application must be current.::::Tutte le proprieta identificate per la pratica non sono storiche', NULL, 'Checks the title reference recorded at lodgement against titles in the database and if there is a ba_unit record it checks if it is current (PASS)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br4-check-sources-date-not-in-the-future', 'application-br4-check-sources-date-not-in-the-future', 'sql', 'Documents should have dates formalised by source agency that are not in the future.::::Nessun documento ha le date di inoltro per il futuro', NULL, 'Checks the date of the document as recorded at lodgement (source.recordation) and checks it is not a date in the future');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br5-check-there-are-front-desk-services', 'application-br5-check-there-are-front-desk-services', 'sql', 'There are services in this application that should  be dealt in the front office. These services are of type: serviceEnquiry, documentCopy, cadastrePrint, surveyPlanCopy, titleSearch.::::Ci sono servizi che dovrebbero essere svolti dal front office. Questi servizi sono di tipo:Richiesta Servizio, Copia Documento, Stampa Catastale, Copia Piano Perizia, Ricerca Titolo', NULL, 'Checks the services in the applications to see if they are amongst services considered as front office services');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-br6-check-new-title-service-is-needed', 'application-br6-check-new-title-service-is-needed', 'sql', 'An application can be associated with a property which should have a digital title record.::::Non esiste un formato digitale per questa proprieta. Aggiungere un Nuovo Titolo Digitale alla vostra pratica', NULL, 'Rule checks to see if there is a ba_unit record for the property identified for the application at lodgement');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('applicant-name-to-owner-name-check', 'applicant-name-to-owner-name-check', 'sql', 'The applicants name should be the same as (one of) the current owner(s)::::Il nome del richiedente differisce da quello dei proprietari registrati', NULL, '#{id}(application.application.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-current-caveat-and-no-remove-or-vary', 'app-current-caveat-and-no-remove-or-vary', 'sql', 'The identified property has a current or pending caveat registered on the title. The application must include a cancel or waiver/vary caveat service for registration to proceed.::::Per questo titolo siste un diritto di prelazione pendente o corrente e la pratica non include un servizio di cancellazione o di variazione prelazione ', NULL, '#{id}(application.application.id) is requested. It checks if there is a caveat (pending or current) registered
 on the title and if the application does not have any service of type remove or vary caveat');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-other-app-with-caveat', 'app-other-app-with-caveat', 'sql', 'The identified property is affected by another live application that includes a service to register a caveat. An application with a cancel or waiver/vary caveat service must be registered before this application can proceed.::::La proprieta é gravata da una pratica attiva che include un servizio per registrare un diritto di prelazione. Perche questa pratia possa procedere deve essere registrata una pratica per richiedere la cancellazione o la variazione della prelazione', NULL, '#{id}(application.application.id) is requested.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-title-has-primary-right', 'app-title-has-primary-right', 'sql', 'A single primary right (such as ownership) must be identified whenever a new title record is created::::Il titolo originario del nuovo titolo deve avere un diritto primario', NULL, '#{id}(application.application.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-allowable-primary-right-for-new-title', 'app-allowable-primary-right-for-new-title', 'sql', 'An allowable primary right (ownership, apartment, State ownership, lease) must be identified for a new title::::Un diritto primario disponibile (proprieta, appartamento o proprieta statale) deve essere identificato per un nuovo titolo', NULL, '#{id}(application.application.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-on-approve-check-services-status', 'application-on-approve-check-services-status', 'sql', 'All services in the application must have the status ''cancelled'' or ''completed''.::::Tutti i servizi devono avere lo stato di cancellato o completato', NULL, 'Checks the service.status_code for all instances of service related to the application');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('app-check-title-ref', 'app-check-title-ref', 'sql', 'Invalid identifier for title::::ITALIANO', '#{id}(application.application_property.application_id) is requested', NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-on-approve-check-services-without-transaction', 'application-on-approve-check-services-without-transaction', 'sql', 'Within an application,all services making changes to core records must be completed and have utilised an instance of transaction before application can be approved.::::Tutti i servizi con stato completato devono aver prodotto modifiche nel sistema', NULL, 'Checks that all services have the status of completed and that there is a transaction record referring to each service record through the field from_service_id');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-verifies-identification', 'application-verifies-identification', 'sql', 'Personal identification verification should be attached to the application.::::Non esistono dettagli identificativi registrati per la pratica', NULL, '#{id}(application.application.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('newtitle-br24-check-rrr-accounted', 'newtitle-br24-check-rrr-accounted', 'sql', 'All rights and restrictions from existing title(s) must be accounted for in the new titles created in this application.::::non tutti i diritti e le restrizioni sono stati trasferiti al nuovo titolo', NULL, '#{id}(application_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-for-new-title-has-cancel-property-service', 'application-for-new-title-has-cancel-property-service', 'sql', 'When a new title is created there must be a cancel title service in the application for the parent title.::::Non esiste nella pratica un servizio di cancellazione titolo. Aggiungere questo servizio alla pratica', NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-cancel-property-service-before-new-title', 'application-cancel-property-service-before-new-title', 'sql', 'New Freehold title service must come before Cancel Title service in the application.::::Il servizio di cancellazione titolo deve venire prima di quello di creazione nuovo titolo. Cambiare ordine servizi nella pratica', NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-approve-cancel-old-titles', 'application-approve-cancel-old-titles', 'sql', 'An application including a new freehold service must also terminate the parent title(s) with a cancel title service.::::Identificati titoli esistenti. Prego terminare i titoli esistenti usando il servizio di Cancellazione Titolo', NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cancel-title-check-rrr-cancelled', 'cancel-title-check-rrr-cancelled', 'sql', 'All rights and restrictions on the title to be cancelled must be transfered or cancelled in this application.::::Tutti i diritti e le restrizioni sul titolo da cancellare devono essere trasferiti o cancellati in questa pratica', NULL, '#{id}(application_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-baunit-has-parcels', 'application-baunit-has-parcels', 'sql', 'Title must have Parcels::::Titolo deve avere particelle', NULL, '#{id}(application.service.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('service-on-complete-without-transaction', 'service-on-complete-without-transaction', 'sql', 'Service ''req_type'' must have been started and some changes made in the system::::Service must have been started and some changes made in the system', NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('service-check-no-previous-digital-title-service', 'service-check-no-previous-digital-title-service', 'sql', 'For the Convert Title service there must be no existing digital title record (including the recording of a primary (ownership) right) for the identified title::::Un titolo digitale non dovrebbe esistere per la proprieta richiesta (non avere diritti primari significa anche che non esiste)', NULL, '#{id}(application.service.id) is requested where service is for newDigitalTitle or newDigitalProperty');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('baunit-has-multiple-mortgages', 'baunit-has-multiple-mortgages', 'sql', 'For the Register Mortgage service the identified title has no existing mortgages::::Il titolo ha una ipoteca corrente', NULL, '#{id}(administrative.ba_unit.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('mortgage-value-check', 'mortgage-value-check', 'sql', 'For the Register Mortgage service, the new mortgage is for less than the reported value of property (at time application was received)::::Ipoteca superiore al valore riportato', NULL, '#{id}(application.service.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('current-rrr-for-variation-or-cancellation-check', 'current-rrr-for-variation-or-cancellation-check', 'sql', 'For cancellation or variation of rights (or restrictions), there must be existing rights or restriction (in addition to the primary (ownership) right)::::Il titolo non include diritti o restrizioni correnti (oltre al diritto primario). Confermare la richiesta di variazione o cancellazione e verificare il titolo identificativo', NULL, '#{id}(application.service.id)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('power-of-attorney-service-has-document', 'power-of-attorney-service-has-document', 'sql', 'Service ''req_type'' must have must have one associated Power of Attorney document::::''req_type'' del Servizio deve avere un documento di procura legale allegato', NULL, '#{id}(application.service.id)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('document-supporting-rrr-is-current', 'document-supporting-rrr-is-current', 'sql', 'Documents supporting rights (or restrictions) must have current status::::I documenti che supportano diritti (o restrizioni) devono avere stato corrente', NULL, '#{id}(application.service.id)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('documents-present', 'documents-present', 'sql', 'Documents associated with a service must have a scanned image file (or other source file) attached::::Vi sono documenti allegati', NULL, '#{id}(service_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('power-of-attorney-owner-check', 'power-of-attorney-owner-check', 'sql', 'Name of person identified in Power of Attorney should match a (one of the) current owner(s)::::Il nome della persona identificato nella procura legale deve corrispondere ad uno dei proprietari correnti', NULL, '#{id}(application.service.id)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('required-sources-are-present', 'required-sources-are-present', 'sql', 'All documents required for the service ''req_type'' are present.::::Sono presenti tutti i documenti richiesti per il servizio', NULL, 'Checks that all required documents for any of the services in an application are recorded. Null value is returned if there are no required documents');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('service-has-person-verification', 'service-has-person-verification', 'sql', 'Within the application personal identification verification should be attached.::::Non esistono dettagli identificativi registrati per la pratica', NULL, '#{id}(application.service.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('service-title-terminated', 'service-title-terminated', 'sql', 'For the service ''req_type'' the title must be terminated (after all rights recorded on the title are transferred or cancelled).::::Per il servizio ''req_type'' il titolo deve essere terminato (dopo che tutti i diritti registrati per il titolo sono stati trasferiti o cancellati)', NULL, '#{id}(application.service.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-baunit-check-area', 'application-baunit-check-area', 'sql', 'Title has the same area as the combined area of its associated parcels::::La Area della BA Unit (Unita Amministrativa di Base) non ha la stessa estensione di quella delle sue particelle', NULL, '#{id}(ba_unit_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('newtitle-br22-check-different-owners', 'newtitle-br22-check-different-owners', 'sql', 'Owners of new titles should be the same as owners of underlying titles::::Gli aventi diritto delle nuove titoli non sono gli stessi delle proprieta/titoli sottostanti', NULL, '#{id}(baunit_id) is requested.
Check that new title owners are the same as underlying titles owners (Give WARNING if > 0)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-spatial_unit-area-comparison', 'ba_unit-spatial_unit-area-comparison', 'sql', 'Title area should only differ from parcel area(s) by less than 1%::::Area indicata nel titolo differisce da quella delle particelle per piu del 1%', NULL, '#{id}(administrative.ba_unit.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-cadastre-object', 'ba_unit-has-cadastre-object', 'sql', 'Title must have an associated parcel (or cadastre object)::::Il titolo deve avere particelle (oggetti catastali) associati', NULL, '#{id}(administrative.ba_unit.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-compatible-cadastre-object', 'ba_unit-has-compatible-cadastre-object', 'sql', 'Title should have compatible parcel (or cadastre object) description (appellation)::::Il titolo ha particelle (oggetti catastali) incompatibili', NULL, '#{id}(administrative.ba_unit.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('ba_unit-has-a-valid-primary-right', 'ba_unit-has-a-valid-primary-right', 'sql', 'A title must have a valid primary right::::Un titolo deve avere un diritto primario', NULL, '#{id}(baunit_id) is requested.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cadastre-object-check-name', 'cadastre-object-check-name', 'sql', 'The parcel (cadastre object) should have a valid form of description (appellation)::::Identificativo per la particella (oggetto catastale) invalido', NULL, '#{id}(cadastre.cadastre_object.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('area-check-percentage-newareas-oldareas', 'area-check-percentage-newareas-oldareas', 'sql', 'The difference between the total of the new parcels official areas and the total of the old parcels official areas should not be greater than 0.1%::::Il valore delle nuove aree ufficiali -  quello delle vecchie / 
il valore delle vecchie aree ufficiali in percentuale non dovrebbe essere superiore allo 0.1%', NULL, NULL);
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-ba_unit-check-if-pending', 'target-ba_unit-check-if-pending', 'sql', 'Pending registration actions (from other applications) affecting the title to be cancelled should be cancelled::::Non esistono modifiche pendenti per il titolo origine', NULL, '#{id}(baunit_id) is requested. It checks if there is no pending transaction for target ba_unit (a ba_unit flagged for cancellation).
 It checks if the administrative.ba_unit_target table has a record of this ba_unit which is different
 from the transaction that has flagged the ba_unit for cancellation, that this transaction record is not yet approved,
 that this ba_unit has an associated rrr record which is pending and that there are no other applications with intended or pending changes to this ba_unit.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-parcels-present', 'target-parcels-present', 'sql', 'Target parcel(s) must be selected::::Esistono particelle originarie selezionate', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-parcels-check-nopending', 'target-parcels-check-nopending', 'sql', 'There should be no pending changes for any of target parcels::::Vi sono modifiche pendenti che bloccano la unione delle Particelle', NULL, '#{id}(cadastre.cadastre_object.id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cadastre-redefinition-union-old-new-the-same', 'cadastre-redefinition-union-old-new-the-same', 'sql', 'The union of the new polygons must be the same as the union of the old polygons::::La unione dei nuovi poligoni deve esser la stessa di quella dei vecchi poligoni', NULL, '#{id} is the parameter asked. It is the transaction id.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('cadastre-redefinition-target-geometries-dont-overlap', 'cadastre-redefinition-target-geometries-dont-overlap', 'sql', 'New polygons do not overlap with each other.::::I nuovi poligoni non devono sovrapporsi', NULL, '#{id} is the parameter asked. It is the transaction id.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('survey-points-present', 'survey-points-present', 'sql', 'There are at least 3 survey points present::::Devono esservi almeno 3 punti di controllo', NULL, '#{id}(transaction_id) is requested. Check there are survey points attached with the cadastre change.
 At least 3 points has to be attached to complete a polygon.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-parcels-check-isapolygon', 'target-parcels-check-isapolygon', 'sql', 'The union of the target parcels must be a polygon::::La unione di Particelle deve essere un poligono unico', NULL, '#{id}(cadastre.cadastre_object.transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('new-cadastre-objects-present', 'new-cadastre-objects-present', 'sql', 'New cadastral objects must be defined::::Vi sono nuovi oggetti catastali definiti', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('target-and-new-union-the-same', 'target-and-new-union-the-same', 'sql', 'The union of new parcel polygons is the same with the union of the target parcel polygons::::La unione dei nuovi oggetti catastali deve corrispondere alla unione di quelli originari', NULL, '#{id}(transaction_id) is requested');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('new-cadastre-objects-do-not-overlap', 'new-cadastre-objects-do-not-overlap', 'sql', 'The new parcel polygons must not overlap::::I nuovi oggetti catastali non devono sovrapporsi', NULL, '#{id}(transaction_id) is requested. Check the union of new co has the same area as the sum of all areas of new co-s, which means the new co-s don''t overlap');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('area-check-percentage-newofficialarea-calculatednewarea', 'area-check-percentage-newofficialarea-calculatednewarea', 'sql', 'The difference between the new official parcel area and the new calculated area should be less than 1%::::Il valore della nuova area ufficiale -  quello CALCOLATO della nuova area / 
il valore della nuova area ufficiale in percentuale non dovrebbe essere superiore all 1%', NULL, '#{id}(cadastre.cadastre_object.id) is requested. 
 Check new official area - calculated new area / new official area in percentage (Give in WARNING description, percentage & parcel if percentage > 1%)');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('source-attach-in-transaction-no-pendings', 'source-attach-in-transaction-no-pendings', 'sql', 'Document (source file) must not be duplicated::::Documento non deve avere stato pendente', NULL, '#{id}(source.source.id) is requested. It checks if the source has already a record with the status pending.');
INSERT INTO br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('source-attach-in-transaction-allowed-type', 'source-attach-in-transaction-allowed-type', 'sql', 'Document to be registered must have an allowable and current source type::::Documento deve essere di tipo consentito per la transazione', NULL, '#{id}(source.source.id) is requested. It checks if the source has a type which has the is_for_registration attribute true.');


ALTER TABLE br ENABLE TRIGGER ALL;

--
-- Data for Name: br_definition; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_definition DISABLE TRIGGER ALL;

INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br8-check-has-services', '2012-11-22', 'infinity', 'SELECT (COUNT(*) > 0) AS vl
FROM application.service sv 
WHERE sv.application_id = #{id}
AND sv.status_code != ''cancelled''');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br7-check-sources-have-documents', '2012-11-22', 'infinity', 'SELECT ext_archive_id IS NOT NULL AS vl
FROM source.source 
WHERE id IN (SELECT source_id FROM application.application_uses_source WHERE application_id= #{id})');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br1-check-required-sources-are-present', '2012-11-22', 'infinity', 'WITH reqForAp AS 	(SELECT DISTINCT ON(r_s.source_type_code) r_s.source_type_code AS typeCode
			FROM application.request_type_requires_source_type r_s 
				INNER JOIN application.service sv ON((r_s.request_type_code = sv.request_type_code) AND (sv.status_code != ''cancelled''))
			WHERE sv.application_id = #{id}),
     inclInAp AS	(SELECT DISTINCT ON (sc.id) sc.id FROM reqForAp req
				INNER JOIN source.source sc ON (req.typeCode = sc.type_code)
				INNER JOIN application.application_uses_source a_s ON ((sc.id = a_s.source_id) AND (a_s.application_id = #{id})))
SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM reqForAp) THEN NULL
		WHEN ((SELECT COUNT(*) FROM inclInAp) - (SELECT COUNT(*) FROM reqForAp) >= 0) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br2-check-title-documents-not-old', '2012-11-22', 'infinity', 'SELECT s.recordation + 1 * interval ''1 week'' > NOW() AS vl
FROM application.application_uses_source a_s 
	INNER JOIN source.source s ON (a_s.source_id= s.id)
WHERE a_s.application_id = #{id}
AND s.type_code = ''title''');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br3-check-properties-are-not-historic', '2012-11-22', 'infinity', 'WITH baUnitRecs AS	(SELECT ba.status_code AS status FROM application.application_property ap
				INNER JOIN administrative.ba_unit ba ON ((ap.name_lastpart = ba.name_lastpart) AND (ap.name_firstpart = ba.name_firstpart))
			WHERE application_id= #{id})

SELECT	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM baUnitRecs) THEN NULL
		WHEN (COUNT(*) = 0) THEN TRUE
		ELSE  FALSE
	END AS vl FROM baUnitRecs
WHERE status = ''historic''
ORDER BY 1
LIMIT 1 ');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br4-check-sources-date-not-in-the-future', '2012-11-22', 'infinity', 'SELECT ss.recordation < NOW() as vl FROM application.application_uses_source a_s
	INNER JOIN source.source ss ON (a_s.source_id = ss.id)
	WHERE a_s.application_id = #{id}
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br5-check-there-are-front-desk-services', '2012-11-22', 'infinity', 'SELECT CASE WHEN (COUNT(*)= 0) THEN NULL
	ELSE FALSE 
	end AS vl
FROM application.service
WHERE application_id = #{id} 
AND action_code != ''cancel''
AND request_type_code IN (''serviceEnquiry'', ''documentCopy'', ''cadastrePrint'', ''surveyPlanCopy'', ''titleSearch'')');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-br6-check-new-title-service-is-needed', '2012-11-22', 'infinity', 'SELECT	CASE	WHEN (name_firstpart, name_lastpart) NOT IN (SELECT name_firstpart, name_lastpart FROM administrative.ba_unit)
			THEN (SELECT (COUNT(*) > 0) FROM application.service WHERE request_type_code = ''newFreehold'')
		ELSE TRUE
	END AS vl
FROM application.application_property  
WHERE application_id=#{id}
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('applicant-name-to-owner-name-check', '2012-11-22', 'infinity', 'WITH apStr AS (SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS searchStr FROM party.party pty
		INNER JOIN application.application ap ON (ap.contact_person_id = pty.id)
		WHERE ap.id = #{id}),
     apStr2 AS (SELECT  COALESCE(last_name, '''') AS searchStr FROM party.party pty
		INNER JOIN application.application ap ON (ap.contact_person_id = pty.id)
		WHERE ap.id = #{id}),
    poaQuery AS (SELECT pty.name AS firstName, pty.last_name AS lastName FROM application.application_property ap
			INNER JOIN administrative.ba_unit ba ON ((ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart))
			INNER JOIN administrative.rrr rr ON ((ba.id = rr.ba_unit_id) AND (rr.status_code = ''current'') AND rr.is_primary)
			INNER JOIN administrative.rrr_share rs ON (rr.id = rs.rrr_id)
			INNER JOIN administrative.party_for_rrr pr ON (rs.rrr_id = pr.rrr_id)
			INNER JOIN party.party pty ON (pr.party_id = pty.id)
		WHERE ap.application_id = #{id})

SELECT CASE WHEN (COUNT(*) > 0) THEN TRUE
		ELSE NULL
	END AS vl FROM poaQuery
WHERE (compare_strings((SELECT searchStr FROM apStr), COALESCE(firstName, '''') || '' '' || COALESCE(lastName, '''')) OR compare_strings((SELECT searchStr FROM apStr2), COALESCE(firstName, '''') || '' '' || COALESCE(lastName, '''')))
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-current-caveat-and-no-remove-or-vary', '2012-11-22', 'infinity', 'SELECT (SELECT (COUNT(*) > 0) FROM application.service sv 
  WHERE ((sv.application_id = ap.application_id) AND (sv.request_type_code IN (''varyCaveat'', ''removeCaveat'')))) AS vl
FROM application.application_property ap 
  INNER JOIN administrative.ba_unit ba ON ((ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart))
  LEFT JOIN administrative.rrr ON (rrr.ba_unit_id = ba.id)
WHERE ((ap.application_id = #{id}) AND (rrr.type_code = ''caveat'') AND (rrr.status_code IN (''pending'', ''current'')))
ORDER BY 1 desc
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-other-app-with-caveat', '2012-11-22', 'infinity', 'SELECT (SELECT COUNT(*) > 0 FROM application.service sv WHERE sv.application_id = ap.application_id AND sv.request_type_code IN (''varyCaveat'', ''removeCaveat'')) AS vl
FROM application.application_property ap
	INNER JOIN application.application_property ap2 ON (((ap.name_firstpart, ap.name_lastpart) = (ap2.name_firstpart, ap2.name_lastpart)) AND (ap.id != ap2.id))
	INNER JOIN application.application app2 ON (ap2.application_id = app2.id)
	INNER JOIN application.service sv2 ON ((app2.id = sv2.application_id) AND (sv2.request_type_code = ''caveat'') AND (sv2.status_code != ''cancelled'') AND (app2.status_code NOT IN (''completed'', ''annulled'')))
WHERE ap.application_id = #{id} 
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-title-has-primary-right', '2012-11-22', 'infinity', 'WITH 	newTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code IN (''newFreehold'', ''newApartment'', ''newState'')),
	start_titles	AS	(SELECT DISTINCT ON (pt.from_ba_unit_id) pt.from_ba_unit_id, s.application_id FROM administrative.rrr rr 
				INNER JOIN administrative.required_relationship_baunit pt ON (rr.ba_unit_id = pt.to_ba_unit_id)
				INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}),
	start_primary_rrr AS 	(SELECT DISTINCT ON(pp.nr) pp.nr FROM administrative.rrr pp 
				WHERE pp.status_code != ''cancelled''
				AND pp.is_primary
				AND pp.ba_unit_id IN (SELECT from_ba_unit_id  FROM start_titles))

SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT sum(1) FROM start_primary_rrr) = 1
		ELSE NULL
	END AS vl FROM newTitleApp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('survey-points-present', '2012-11-22', 'infinity', 'select count (*) > 2  as vl from cadastre.survey_point where transaction_id= #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-baunit-has-parcels', '2012-11-22', 'infinity', 'select (select count(*)>0 from administrative.ba_unit_contains_spatial_unit ba_su 
		inner join cadastre.cadastre_object co on ba_su.spatial_unit_id= co.id
	where co.status_code in (''current'') and co.geom_polygon is not null and ba_su.ba_unit_id= ba.id) as vl
from application.service s 
	inner join application.application_property ap on (s.application_id= ap.application_id)
	INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
where s.id = #{id}
order by 1
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-rrr-nr', '2012-11-22', 'infinity', 'SELECT trim(to_char(nextval(''administrative.rrr_nr_seq''), ''000000'')) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-allowable-primary-right-for-new-title', '2012-11-22', 'infinity', 'WITH 	newTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code IN (''newFreehold'', ''newApartment'', ''newState'')),
	existTitleApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.application_property prp1
					INNER JOIN application.service sv ON (prp1.application_id = sv.application_id)
				WHERE prp1.application_id = #{id}
				AND sv.request_type_code = ''newDigitalTitle'')
				
 SELECT CASE WHEN (SELECT ((SELECT * FROM newTitleApp) OR (SELECT * FROM existTitleApp)) IS NULL) THEN NULL 
	WHEN ((SELECT COUNT(*) FROM existTitleApp) = 0) THEN	(SELECT (COUNT(*) = 0) FROM application.application_property prp2
									INNER JOIN administrative.rrr rr2 
										ON ((prp2.ba_unit_id = rr2.ba_unit_id) AND NOT(rr2.is_primary OR (rr2.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease''))))
								 WHERE prp2.application_id = #{id} )
	ELSE	(SELECT (COUNT(*) = 0) FROM application.service sv2 
			 INNER JOIN transaction.transaction tn2 ON (sv2.id = tn2.from_service_id) 
			 INNER JOIN administrative.ba_unit ba2 ON (tn2.id = ba2.transaction_id) 
			 INNER JOIN administrative.rrr rr3 
				ON ((ba2.id = rr3.ba_unit_id) AND NOT(rr3.is_primary OR (rr3.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease''))))
			 WHERE sv2.application_id = #{id} )
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-on-approve-check-services-status', '2012-11-22', 'infinity', 'SELECT (COUNT(*) = 0)  AS vl FROM application.service sv 
WHERE sv.application_id = #{id} 
AND sv.status_code NOT IN (''completed'', ''cancelled'')');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-on-approve-check-services-without-transaction', '2012-11-22', 'infinity', 'SELECT (COUNT(*) = 0) AS vl FROM application.service sv 
	INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
WHERE sv.application_id = #{id} 
AND sv.status_code NOT IN (''completed'', ''cancelled'')');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('newtitle-br24-check-rrr-accounted', '2012-11-22', 'infinity', '
WITH 	pending_property_rrr AS (SELECT DISTINCT ON(rp.nr) rp.nr FROM administrative.rrr rp 
				INNER JOIN transaction.transaction tn ON (rp.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}
				AND rp.status_code = ''pending''),
								
	parent_titles	AS	(SELECT DISTINCT ON (ba.id) ba.id AS liveTitle, from_ba_unit_id FROM administrative.ba_unit ba
				INNER JOIN transaction.transaction tn ON (ba.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN administrative.required_relationship_baunit pt ON (ba.id = pt.to_ba_unit_id)
				WHERE s.application_id = #{id}),
				
	new_titles	AS	(SELECT DISTINCT ON (rr.ba_unit_id) rr.ba_unit_id FROM administrative.rrr rr 
				INNER JOIN administrative.ba_unit nt ON (rr.ba_unit_id = nt.id)
				INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN application.application ap ON (s.application_id = ap.id)
				WHERE ap.id = #{id}),
	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
					
	prior_property_rrr AS 	(SELECT DISTINCT ON(pp.nr) pp.nr FROM administrative.rrr pp 
				WHERE pp.status_code = ''current''
				AND pp.ba_unit_id IN (SELECT from_ba_unit_id  FROM parent_titles)),

	rem_property_rrr AS	(SELECT nr FROM prior_property_rrr WHERE nr NOT IN (SELECT nr FROM pending_property_rrr))
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(nr) FROM rem_property_rrr) = 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-for-new-title-has-cancel-property-service', '2012-11-22', 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold'')
					
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(id) FROM application.service sv 
					WHERE sv.application_id = #{id}
					AND sv.request_type_code = ''cancelProperty'') > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-cancel-property-service-before-new-title', '2012-11-22', 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
 	orderCancel	AS	(SELECT service_order + 1 AS cancelSequence FROM application.service sv 
				WHERE sv.application_id = #{id}
				AND sv.request_type_code = ''cancelProperty'' LIMIT 1),	
 	orderNew	AS	(SELECT service_order + 1 AS newSequence FROM application.service sv 
				WHERE sv.application_id = #{id}
				AND sv.request_type_code = ''newFreehold'' LIMIT 1)
				
SELECT CASE WHEN fhCheck IS TRUE THEN ((SELECT cancelSequence FROM orderCancel) - (SELECT newSequence FROM orderNew)) > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-approve-cancel-old-titles', '2012-11-22', 'infinity', '
WITH 	newFreeholdApp	AS	(SELECT (SUM(1) > 0) AS fhCheck FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newFreehold''),
	parent_titles	AS	(SELECT DISTINCT ON (ba.id) ba.id AS liveTitle, ba.status_code FROM administrative.ba_unit ba
				INNER JOIN transaction.transaction tn ON (ba.transaction_id = tn.id)
				INNER JOIN application.service s ON (tn.from_service_id = s.id) 
				INNER JOIN administrative.required_relationship_baunit pt ON (ba.id = pt.to_ba_unit_id)
				WHERE s.application_id = #{id}
				AND ba.status_code = ''pending'')
				
SELECT CASE WHEN fhCheck IS TRUE THEN (SELECT COUNT(liveTitle) FROM parent_titles) > 0
		ELSE NULL
	END AS vl FROM newFreeholdApp
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cancel-title-check-rrr-cancelled', '2012-11-22', 'infinity', 'WITH 	pending_property_rrr AS (SELECT DISTINCT ON(rr1.nr) rr1.nr FROM administrative.rrr rr1 
				INNER JOIN transaction.transaction tn ON (rr1.transaction_id = tn.id)
				INNER JOIN application.service sv1 ON (tn.from_service_id = sv1.id) 
				WHERE sv1.application_id = #{id}
				AND rr1.status_code = ''pending''),
								
	target_title	AS	(SELECT prp.ba_unit_id AS liveTitle FROM application.application_property prp
				WHERE prp.application_id = #{id}),
				
	cancelPropApp	AS	(SELECT sv3.id AS fhCheck, sv3.request_type_code FROM application.service sv3
				WHERE sv3.application_id = #{id}
				AND sv3.request_type_code = ''cancelProperty''),
					
	current_rrr AS 		(SELECT DISTINCT ON(rr2.nr) rr2.nr FROM administrative.rrr rr2 
				WHERE rr2.status_code = ''current''
				AND rr2.ba_unit_id IN (SELECT liveTitle FROM target_title)),

	rem_property_rrr AS	(SELECT nr FROM current_rrr WHERE nr NOT IN (SELECT nr FROM pending_property_rrr))
				
SELECT CASE 	WHEN (SELECT (COUNT(*) = 0) FROM cancelPropApp) THEN NULL
		WHEN (SELECT (COUNT(*) = 0) FROM pending_property_rrr) THEN FALSE
		WHEN (SELECT (COUNT(*) = 0) FROM rem_property_rrr) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('app-check-title-ref', '2012-11-22', 'infinity', 'WITH 	convertTitleApp	AS	(SELECT se.id FROM application.service se
				WHERE se.application_id = #{id}
				AND se.request_type_code = ''newDigitalTitle''),
	titleRefChk	AS	(SELECT aprp.application_id FROM application.application_property aprp
				WHERE aprp.application_id= #{id} 
				AND SUBSTR(aprp.name_firstpart, 1) != ''N''
				AND NOT(aprp.name_lastpart ~ ''^[0-9]+$''))--isnumeric test
	
SELECT CASE 	WHEN (SELECT (COUNT(*) = 0) FROM convertTitleApp) THEN NULL
		WHEN (SELECT (COUNT(*) = 0) FROM titleRefChk) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('service-on-complete-without-transaction', '2012-11-22', 'infinity', 'select id in (select from_service_id from transaction.transaction where from_service_id is not null) as vl, 
  get_translation(r.display_value, #{lng}) as req_type
from application.service s inner join application.request_type r on s.request_type_code = r.code and request_category_code=''registrationServices''
and s.id= #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('service-check-no-previous-digital-title-service', '2012-11-22', 'infinity', 'SELECT coalesce(not rrr.is_primary, true) as vl
FROM application.service s inner join application.application_property ap on s.application_id = ap.application_id
  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
  LEFT JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} 
order by 1 desc
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('baunit-has-multiple-mortgages', '2012-11-22', 'infinity', 'SELECT	(SELECT (COUNT(*) = 0) FROM application.service sv2
		 INNER JOIN transaction.transaction tn ON (sv2.id = tn.from_service_id)
		 INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id)
		 INNER JOIN administrative.rrr rr2 ON ((rr.ba_unit_id = rr2.ba_unit_id) AND (rr2.type_code = ''mortgage'') AND (rr2.status_code =''current'') ) 
	WHERE sv.id = #{id}) AS vl FROM application.service sv
WHERE sv.id = #{id}
AND sv.request_type_code = ''mortgage''
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('mortgage-value-check', '2012-11-22', 'infinity', 'SELECT (ap.total_value < rrr.mortgage_amount) AS vl 
  from application.service s inner join application.application_property ap on s.application_id = ap.application_id 
 INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
 INNER JOIN administrative.rrr ON rrr.ba_unit_id = ba.id
WHERE s.id = #{id} and rrr.type_code= ''mortgage'' and rrr.status_code in (''pending'')
order by 1
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('current-rrr-for-variation-or-cancellation-check', '2012-11-22', 'infinity', 'SELECT (SUM(1) > 0) AS vl FROM application.service sv 
			INNER JOIN application.application_property ap ON (sv.application_id = ap.application_id )
			  INNER JOIN administrative.ba_unit ba ON (ap.name_firstpart, ap.name_lastpart) = (ba.name_firstpart, ba.name_lastpart)
			  INNER JOIN administrative.rrr rr ON rr.ba_unit_id = ba.id
			  WHERE sv.id = #{id}
			  AND sv.request_type_code IN (SELECT code FROM application.request_type WHERE ((status = ''c'') AND (type_action_code IN (''vary'', ''cancel''))))
			  AND NOT(rr.is_primary)
			  AND rr.status_code = ''current''
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('power-of-attorney-service-has-document', '2012-11-22', 'infinity', 'SELECT (SUM(1) = 1) AS vl, get_translation(rt.display_value, #{lng}) as req_type FROM application.service sv
	 INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
	 INNER JOIN source.source sc ON (tn.id = sc.transaction_id)
	 INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code AND request_category_code = ''registrationServices'')
WHERE sv.id =#{id}
AND sc.type_code = ''powerOfAttorney''
GROUP BY rt.code
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('document-supporting-rrr-is-current', '2012-11-22', 'infinity', 'WITH serviceDocs AS	(SELECT DISTINCT ON (sc.id) sv.id AS sv_id, sc.id AS sc_id, sc.status_code, sc.type_code FROM application.service sv
				INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
				INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id)
				INNER JOIN administrative.source_describes_rrr sr ON (rr.id = sr.rrr_id)
				INNER JOIN source.source sc ON (sr.source_id = sc.id)
				WHERE sv.id = #{id}),
    nullDocs AS		(SELECT sc_id, type_code FROM serviceDocs WHERE status_code IS NULL),
    transDocs AS	(SELECT sc_id, type_code FROM serviceDocs WHERE status_code = ''current'' AND ((type_code = ''powerOfAttorney'') OR (type_code = ''standardDocument'')))
SELECT ((SELECT COUNT(*) FROM serviceDocs) - (SELECT COUNT(*) FROM nullDocs) - (SELECT COUNT(*) FROM transDocs) = 0) AS vl
ORDER BY 1
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('documents-present', '2012-11-22', 'infinity', 'WITH cadastreDocs AS 	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN transaction.transaction_source ts ON (ss.id = ts.source_id)
				INNER JOIN transaction.transaction tn ON(ts.transaction_id = tn.id)
				WHERE tn.from_service_id = #{id}
				ORDER BY 1),
	rrrDocs AS	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN administrative.source_describes_rrr sr ON (ss.id = sr.source_id)
				INNER JOIN administrative.rrr rr ON (sr.rrr_id = rr.id)
				INNER JOIN transaction.transaction tn ON(rr.transaction_id = tn.id)
				WHERE tn.from_service_id = #{id}
				ORDER BY 1),
     titleDocs AS	(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN administrative.source_describes_ba_unit su ON (ss.id = su.source_id)
				WHERE su.ba_unit_id IN (SELECT  ba_unit_id FROM rrrDocs)
				ORDER BY 1),
     regDocs AS		(SELECT DISTINCT ON (id) ss.id, ext_archive_id FROM source.source ss
				INNER JOIN transaction.transaction tn ON (ss.transaction_id = tn.id)
				INNER JOIN application.service sv ON (tn.from_service_id = sv.id)
				WHERE sv.id = #{id}
				AND sv.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'', ''cnclPowerOfAttorney'', ''cnclStandardDocument'')
				ORDER BY 1),
     serviceDocs AS	((SELECT * FROM rrrDocs) UNION (SELECT * FROM cadastreDocs) UNION (SELECT * FROM titleDocs) UNION (SELECT * FROM regDocs))
     
     
 SELECT (((SELECT COUNT(*) FROM serviceDocs) - (SELECT COUNT(*) FROM serviceDocs WHERE ext_archive_id IS NOT NULL)) = 0) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('power-of-attorney-owner-check', '2012-11-22', 'infinity', 'WITH poaQuery AS (SELECT person_name, py.name AS firstName, py.last_name AS lastName FROM transaction.transaction tn
			INNER JOIN administrative.rrr rr ON (tn.id = rr.transaction_id) 
			INNER JOIN administrative.ba_unit ba ON (rr.ba_unit_id = ba.id)
			INNER JOIN administrative.rrr r2 ON ((ba.id = r2.ba_unit_id) AND (r2.status_code = ''current'') AND r2.is_primary)
			INNER JOIN administrative.rrr_share rs ON (r2.id = rs.rrr_id)
			INNER JOIN administrative.party_for_rrr pr ON (rs.rrr_id = pr.rrr_id)
			INNER JOIN party.party py ON (pr.party_id = py.id)
			INNER JOIN administrative.source_describes_rrr sr ON (rr.id = sr.rrr_id)
			INNER JOIN source.power_of_attorney pa ON (sr.source_id = pa.id)
		WHERE tn.from_service_id = #{id})
SELECT CASE WHEN (COUNT(*) > 0) THEN TRUE
		ELSE NULL
	END AS vl FROM poaQuery
WHERE compare_strings(person_name, COALESCE(firstName, '''') || '' '' || COALESCE(lastName, ''''))
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-parcels-check-isapolygon', '2012-11-22', 'infinity', 'select St_GeometryType(ST_Union(co.geom_polygon)) = ''ST_Polygon'' as vl
 from cadastre.cadastre_object co 
  inner join cadastre.cadastre_object_target co_target
   on co.id = co_target.cadastre_object_id
    where co_target.transaction_id = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('new-cadastre-objects-present', '2012-11-22', 'infinity', 'select count (*) > 0 as vl from cadastre.cadastre_object where transaction_id= #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('area-check-percentage-newofficialarea-calculatednewarea', '2012-11-22', 'infinity', 'select count(*) = 0 as vl
from cadastre.cadastre_object co 
  left join cadastre.spatial_value_area sa_calc on (co.id= sa_calc.spatial_unit_id and sa_calc.type_code =''calculatedArea'')
  left join cadastre.spatial_value_area sa_official on (co.id= sa_official.spatial_unit_id and sa_official.type_code =''officialArea'')
where co.transaction_id = #{id} and
(abs(coalesce(sa_official.size, 0) - coalesce(sa_calc.size, 0)) 
/ 
(case when sa_official.size is null or sa_official.size = 0 then 1 else sa_official.size end)) > 0.01');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cadastre-object-check-name', '2012-11-22', 'infinity', 'Select cadastre.cadastre_object_name_is_valid(name_firstpart, name_lastpart) as vl 
FROM cadastre.cadastre_object
WHERE transaction_id = #{id} and type_code = ''parcel''
order by 1
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('required-sources-are-present', '2012-11-22', 'infinity', 'WITH reqForSv AS 	(SELECT r_s.source_type_code AS typeCode
			FROM application.request_type_requires_source_type r_s 
				INNER JOIN application.service sv ON((r_s.request_type_code = sv.request_type_code) AND (sv.status_code != ''cancelled''))
			WHERE sv.id = #{id}),
     inclInSv AS	(SELECT DISTINCT ON (sc.id) get_translation(rt.display_value, #{lng}) AS req_type FROM reqForSv req
				INNER JOIN source.source sc ON (req.typeCode = sc.type_code)
				INNER JOIN application.application_uses_source a_s ON (sc.id = a_s.source_id)
				INNER JOIN application.service sv ON ((a_s.application_id = sv.application_id) AND (sv.id = #{id}))
				INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code))

SELECT 	CASE 	WHEN (SELECT (SUM(1) IS NULL) FROM reqForSv) THEN NULL
		WHEN ((SELECT COUNT(*) FROM inclInSv) - (SELECT COUNT(*) FROM reqForSv) >= 0) THEN TRUE
		ELSE FALSE
	END AS vl, req_type FROM inclInSv
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('service-title-terminated', '2012-11-22', 'infinity', 'WITH reqForSv AS 	(SELECT sv.id, get_translation(rt.display_value, #{lng}) AS req_type FROM application.service sv 
				INNER JOIN application.request_type rt ON (sv.request_type_code = rt.code)
			WHERE sv.id = #{id} 
			AND sv.request_type_code = ''cancelProperty''),
     checkTitle AS	(SELECT tg.ba_unit_id FROM application.service sv
				INNER JOIN transaction.transaction tn ON (sv.id = tn.from_service_id)
				INNER JOIN administrative.ba_unit_target tg ON (tn.id = tg.transaction_id)
			WHERE sv.id = #{id})
SELECT 	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM reqForSv) THEN NULL
		WHEN (SELECT (COUNT(*) > 0) FROM checkTitle) THEN TRUE
		ELSE FALSE
	END AS vl, req_type FROM reqForSv
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-baunit-check-area', '2012-11-22', 'infinity', 'select
       ( 
         select coalesce(cast(sum(a.size)as float),0)
	 from administrative.ba_unit_area a
         inner join administrative.ba_unit ba
         on a.ba_unit_id = ba.id
         where ba.transaction_id = #{id}
         and a.type_code =  ''officialArea''
       ) 
   = 

       (
         select coalesce(cast(sum(a.size)as float),0)
	 from cadastre.spatial_value_area a
	 where  a.type_code = ''officialArea''
	 and a.spatial_unit_id in
           (  select b.spatial_unit_id
              from administrative.ba_unit_contains_spatial_unit b
              inner join administrative.ba_unit ba
	      on b.ba_unit_id = ba.id
	      where ba.transaction_id = #{id}
           )

        ) as vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('newtitle-br22-check-different-owners', '2012-11-22', 'infinity', 'WITH new_property_owner AS (
	SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS newOwnerStr FROM party.party po
		INNER JOIN administrative.party_for_rrr pfr1 ON (po.id = pfr1.party_id)
		INNER JOIN administrative.rrr rr1 ON (pfr1.rrr_id = rr1.id)
	WHERE rr1.ba_unit_id = #{id}),
	
  prior_property_owner AS (
	SELECT  COALESCE(name, '''') || '' '' || COALESCE(last_name, '''') AS priorOwnerStr FROM party.party pn
		INNER JOIN administrative.party_for_rrr pfr2 ON (pn.id = pfr2.party_id)
		INNER JOIN administrative.rrr rr2 ON (pfr2.rrr_id = rr2.id)
		INNER JOIN administrative.required_relationship_baunit rfb ON (rr2.ba_unit_id = rfb.from_ba_unit_id)
	WHERE	rfb.to_ba_unit_id = #{id}
	LIMIT 1	)

SELECT 	CASE 	WHEN (SELECT (COUNT(*) = 0) FROM prior_property_owner) THEN NULL
		WHEN (SELECT (COUNT(*) != 0) FROM new_property_owner npo WHERE compare_strings((SELECT priorOwnerStr FROM prior_property_owner), npo.newOwnerStr)) THEN TRUE
		ELSE FALSE
	END AS vl
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-spatial_unit-area-comparison', '2012-11-22', 'infinity', 'SELECT (abs(coalesce(ba_a.size,0.001) - 
 (select coalesce(sum(sv_a.size), 0.001) 
  from cadastre.spatial_value_area sv_a inner join administrative.ba_unit_contains_spatial_unit ba_s 
    on sv_a.spatial_unit_id= ba_s.spatial_unit_id
  where sv_a.type_code = ''officialArea'' and ba_s.ba_unit_id= ba.id))/coalesce(ba_a.size,0.001)) < 0.001 as vl
FROM administrative.ba_unit ba left join administrative.ba_unit_area ba_a 
  on ba.id= ba_a.ba_unit_id and ba_a.type_code = ''officialArea''
WHERE ba.id = #{id}
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-cadastre-object', '2012-11-22', 'infinity', 'SELECT count(*)>0 vl
from administrative.ba_unit_contains_spatial_unit ba_s 
WHERE ba_s.ba_unit_id = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-compatible-cadastre-object', '2012-11-22', 'infinity', 'SELECT  co.type_code = ''parcel'' as vl
from administrative.ba_unit ba 
  inner join administrative.ba_unit_contains_spatial_unit ba_s on ba.id= ba_s.ba_unit_id
  inner join cadastre.cadastre_object co on ba_s.spatial_unit_id= co.id
WHERE ba.id = #{id} and ba.type_code= ''basicPropertyUnit''
order by case when co.type_code = ''parcel'' then 0 
		else 1 
	end
limit 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-ba_unit-check-if-pending', '2012-11-22', 'infinity', 'WITH	otherCancel AS	(SELECT (SELECT (COUNT(*) = 0)FROM administrative.ba_unit_target ba_t2 
				INNER JOIN transaction.transaction tn ON (ba_t2.transaction_id = tn.id)
				WHERE ba_t2.ba_unit_id = ba_t.ba_unit_id
				AND ba_t2.transaction_id != ba_t.transaction_id
				AND tn.status_code != ''approved'') AS chkOther
			FROM administrative.ba_unit_target ba_t
			WHERE ba_t.ba_unit_id = #{id}), 
	cancelAp AS	(SELECT ap.id FROM administrative.ba_unit_target ba_t 
			INNER JOIN application.application_property pr ON (ba_t.ba_unit_id = pr.ba_unit_id)
			INNER JOIN application.service sv ON (pr.application_id = sv.application_id)
			INNER JOIN application.application ap ON (pr.application_id = ap.id)
			WHERE ba_t.ba_unit_id = #{id}
			AND sv.request_type_code = ''cancelProperty''
			AND sv.status_code != ''cancelled''
			AND ap.status_code NOT IN (''annulled'', ''approved'')),
	otherAps AS	(SELECT (SELECT (count(*) = 0) FROM administrative.ba_unit ba
			INNER JOIN administrative.rrr rr ON (ba.id = rr.ba_unit_id)
			INNER JOIN transaction.transaction tn ON (rr.transaction_id = tn.id)
			INNER JOIN application.service sv ON (tn.from_service_id = sv.id)
			INNER JOIN application.application ap ON (sv.application_id = ap.id)
			WHERE ba.id = #{id} 
			AND ap.status_code = ''lodged''
			AND ap.id NOT IN (SELECT id FROM cancelAp)) AS chkNoOtherAps),

	pendingRRR AS	(SELECT (SELECT (count(*) = 0) FROM administrative.rrr rr
				INNER JOIN administrative.ba_unit_target ba_t2 ON (rr.ba_unit_id = ba_t2.ba_unit_id)
				INNER JOIN transaction.transaction t2 ON (ba_t2.transaction_id = t2.id)
				INNER JOIN application.service s2 ON (t2.from_service_id = s2.id) 
				WHERE ba_t2.ba_unit_id = ba_t.ba_unit_id
				AND s2.application_id != s1.application_id
				AND ba_t2.transaction_id != ba_t.transaction_id
				AND rr.status_code = ''pending'') AS chkPend 
			FROM administrative.ba_unit_target ba_t
			INNER JOIN transaction.transaction t1 ON (ba_t.transaction_id = t1.id)
			INNER JOIN application.service s1 ON (t1.from_service_id = s1.id) 
			WHERE ba_t.ba_unit_id = #{id})
SELECT ((SELECT chkPend  FROM pendingRRR) AND (SELECT chkOther FROM otherCancel)  AND (SELECT chkNoOtherAps FROM otherAps)) AS vl 
FROM administrative.ba_unit_target tg
WHERE tg.ba_unit_id  = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-a-valid-primary-right', '2012-11-22', 'infinity', 'SELECT (COUNT(*) = 1) AS vl FROM administrative.rrr rr1 
	 INNER JOIN administrative.ba_unit ba ON (rr1.ba_unit_id = ba.id)
	 INNER JOIN transaction.transaction tn ON (rr1.transaction_id = tn.id)
	 INNER JOIN application.service sv ON ((tn.from_service_id = sv.id) AND (sv.request_type_code != ''cancelProperty''))
 WHERE ba.id = #{id}
 AND rr1.status_code != ''cancelled''
 AND rr1.is_primary
 AND rr1.type_code IN (''ownership'', ''apartment'', ''stateOwnership'', ''lease'')');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-parcels-present', '2012-11-22', 'infinity', 'select count (*) > 0 as vl from cadastre.cadastre_object_target where transaction_id= #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-parcels-check-nopending', '2012-11-22', 'infinity', 'select (select count(*)=0 
  from cadastre.cadastre_object_target target_also inner join transaction.transaction t 
    on target_also.transaction_id = t.id and t.status_code not in (''approved'')
  where co_target.transaction_id != target_also.transaction_id
    and co_target.cadastre_object_id= target_also.cadastre_object_id) as vl
from cadastre.cadastre_object_target co_target
where co_target.transaction_id = #{id}
 ');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cadastre-redefinition-union-old-new-the-same', '2012-11-22', 'infinity', 'select st_equals(geom_to_snap,target_geom) as vl from cadastre.snap_geometry_to_geometry((select st_union(co.geom_polygon) from cadastre.cadastre_object co 
 where id in (select cadastre_object_id from cadastre.cadastre_object_target co_t where transaction_id = #{id})), 
(select st_union(co_t.geom_polygon) from cadastre.cadastre_object_target co_t where transaction_id = #{id}), 
 system.get_setting(''map-tolerance'')::double precision, true)');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('cadastre-redefinition-target-geometries-dont-overlap', '2012-11-22', 'infinity', 'select coalesce(st_area(st_union(co.geom_polygon)) = sum(st_area(co.geom_polygon)), true) as vl
from cadastre.cadastre_object_target co where transaction_id = #{id}');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('new-cadastre-objects-do-not-overlap', '2012-11-22', 'infinity', 'WITH tolerance AS (SELECT CAST(ABS(LOG((CAST (vl AS NUMERIC)^2))) AS INT) AS area FROM system.setting where name = ''map-tolerance'' LIMIT 1)

SELECT COALESCE(ROUND(CAST (ST_AREA(ST_UNION(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)) = 
		ROUND(CAST(SUM(ST_AREA(co.geom_polygon))AS NUMERIC), (SELECT area FROM tolerance)), 
		TRUE) AS vl
FROM cadastre.cadastre_object co 
WHERE transaction_id = #{id} ');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('area-check-percentage-newareas-oldareas', '2012-11-22', 'infinity', 'select abs((select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
        and a.spatial_unit_id in (
	   select co_new.id
		from cadastre.cadastre_object co_new 
		where co_new.transaction_id = #{id}))
 -
   (select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
	and a.spatial_unit_id in ( 
	      select co_target.cadastre_object_id
		from cadastre.cadastre_object_target co_target
		    where co_target.transaction_id = #{id})) 
 ) /(select cast(sum(a.size)as float)
	from cadastre.spatial_value_area a
	where a.type_code = ''officialArea''
	and a.spatial_unit_id in ( 
	      select co_target.cadastre_object_id
		from cadastre.cadastre_object_target co_target
		    where co_target.transaction_id = #{id})) 
 < 0.001 as vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('rrr-must-have-parties', '2012-11-22', 'infinity', 'select count(*) = 0 as vl
from administrative.rrr r
where r.id= #{id} and type_code in (select code from administrative.rrr_type where party_required)
and (select count(*) from administrative.party_for_rrr where rrr_id= r.id) = 0');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-several-mortgages-with-same-rank', '2012-11-22', 'infinity', 'WITH	simple	AS	(SELECT rr1.id, rr1.nr FROM administrative.rrr rr1
				INNER JOIN administrative.ba_unit ba1 ON (rr1.ba_unit_id = ba1.id)
				INNER JOIN administrative.rrr rr2 ON ((ba1.id = rr2.ba_unit_id) AND (rr1.mortgage_ranking = rr2.mortgage_ranking))
			WHERE rr2.id = #{id}
			AND rr1.type_code = ''mortgage''
			AND rr1.status_code = ''current''
			AND (rr1.mortgage_ranking = rr2.mortgage_ranking)),
	complex	AS	(SELECT rr3.id, rr3.nr FROM administrative.rrr rr3
				INNER JOIN administrative.ba_unit ba2 ON (rr3.ba_unit_id = ba2.id)
				INNER JOIN administrative.rrr rr4 ON (ba2.id = rr4.ba_unit_id)
			WHERE rr4.id = #{id}
			AND rr3.type_code = ''mortgage''
			AND rr3.status_code != ''current''
			AND rr3.mortgage_ranking = rr4.mortgage_ranking
			AND rr3.nr IN (SELECT nr FROM simple))

SELECT CASE 	WHEN	((SELECT rr5.id FROM administrative.rrr rr5 WHERE rr5.id = #{id} AND rr5.type_code = ''mortgage'') IS NULL) THEN NULL
		WHEN 	(SELECT (COUNT(*) = 0) FROM simple) THEN TRUE
		WHEN 	(((SELECT COUNT(*) FROM simple) - (SELECT COUNT(*) FROM complex) = 0)) THEN TRUE
		ELSE	FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('ba_unit-has-caveat', '2012-11-22', 'infinity', 'WITH caveatCheck AS	(SELECT COUNT(*) AS present FROM administrative.rrr rr2 
				 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id)
				 INNER JOIN administrative.rrr rr1 ON ((ba.id = rr1.ba_unit_id) AND (rr1.type_code = ''caveat'') AND (rr1.status_code IN (''pending'', ''current'')))
			 WHERE rr2.id = #{id}
			 ORDER BY 1
			 LIMIT 1),
    changeCheck AS	(SELECT (COUNT(*) > 0) AS caveatChange FROM administrative.rrr rr2 
				 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id)
				 INNER JOIN administrative.rrr rr3 ON ((ba.id = rr3.ba_unit_id) AND (rr3.type_code = ''caveat'') AND (rr3.status_code = ''current''))
				 INNER JOIN transaction.transaction tn ON (rr3.transaction_id = tn.id)
				 INNER JOIN application.service sv1 ON ((tn.from_service_id = sv1.id) AND sv1.request_type_code IN (''varyCaveat'', ''removeCaveat'') AND sv1.status_code IN (''lodged'', ''pending''))
			 WHERE rr2.id = #{id}),
	varyCheck AS 	(SELECT ((SELECT present FROM caveatCheck) - (SELECT SUM(1) FROM (SELECT DISTINCT ON (rr4.nr) rr4.nr FROM administrative.rrr rr2 
									 INNER JOIN administrative.ba_unit ba ON (rr2.ba_unit_id = ba.id) 
									 INNER JOIN administrative.rrr rr3 ON ((ba.id = rr3.ba_unit_id) AND (rr3.type_code = ''caveat'') AND (rr3.status_code = ''current''))
									 INNER JOIN transaction.transaction tn ON (rr3.transaction_id = tn.id) 
									 INNER JOIN application.service sv1 ON ((tn.from_service_id = sv1.id) AND (sv1.request_type_code = ''varyCaveat''))
									 INNER JOIN administrative.rrr rr4 ON ((ba.id = rr4.ba_unit_id) AND (rr3.nr = rr4.nr))
								WHERE rr2.id = #{id}) AS vary) = 0) AS withoutVary), 
     caveatRegn AS	(SELECT (COUNT(*) > 0) AS caveat FROM administrative.rrr rr4
				 INNER JOIN transaction.transaction tn ON ((rr4.transaction_id = tn.id)	AND (rr4.status_code IN (''pending'', ''current'')) AND (rr4.type_code = ''caveat''))
				 INNER JOIN application.service sv2 ON (tn.from_service_id = sv2.id)
			WHERE rr4.id = #{id}
			AND (SELECT (COUNT(*) = 0) FROM application.service sv3 WHERE ((sv3.application_id = sv2.application_id) AND (sv3.status_code != ''cancelled'') AND (sv3.request_type_code NOT IN (''caveat'', ''varyCaveat'', ''removeCaveat''))))
			ORDER BY 1
			LIMIT 1)
			
SELECT (SELECT	CASE 	WHEN (SELECT caveat FROM caveatRegn) THEN TRUE
			WHEN (SELECT caveatChange FROM changeCheck) THEN TRUE
			WHEN (SELECT withoutVary FROM varyCheck) THEN TRUE
			WHEN (SELECT (present = 0) FROM caveatCheck)THEN NULL
			WHEN (SELECT (present > 0) FROM caveatCheck) THEN FALSE
			ELSE TRUE
		END) AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('rrr-has-pending', '2012-11-22', 'infinity', 'select count(*) = 0 as vl
from administrative.rrr rrr1 inner join administrative.rrr rrr2 on (rrr1.ba_unit_id, rrr1.nr) = (rrr2.ba_unit_id, rrr2.nr)
where rrr1.id = #{id} and rrr2.id!=rrr1.id and rrr2.status_code = ''pending''
');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('source-attach-in-transaction-no-pendings', '2012-11-22', 'infinity', 'WITH checkServiceType	AS	(SELECT COUNT(*) AS cnt FROM application.service sv1
					INNER JOIN transaction.transaction tn ON (sv1.id = tn.from_service_id)
					INNER JOIN source.source sc1 ON (tn.id = sc1.transaction_id)
				 WHERE sc1.id = #{id}
				 AND sv1.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'')),
	checkSource	AS	(SELECT COUNT(*) AS cnt FROM source.source sc2
				 WHERE sc2.id = #{id}
				 AND sc2.status_code = ''pending'')

SELECT	CASE 	WHEN (SELECT (cnt = 0) FROM checkServiceType) THEN NULL
		WHEN (SELECT (cnt = 0) FROM checkSource) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('source-attach-in-transaction-allowed-type', '2012-11-22', 'infinity', 'WITH checkServiceType	AS	(SELECT COUNT(*) AS cnt FROM application.service sv1
					INNER JOIN transaction.transaction tn ON (sv1.id = tn.from_service_id)
					INNER JOIN source.source sc1 ON (tn.id = sc1.transaction_id)
				 WHERE tn.id = #{id}
				 AND sv1.request_type_code IN (''regnPowerOfAttorney'', ''regnStandardDocument'')),
	allSource	AS	(SELECT sc2.id AS sid FROM source.source sc2
				 WHERE sc2.transaction_id = #{id}),
	checkSource	AS	(SELECT sid FROM allSource
				 WHERE sid IN (SELECT sc3.id FROM source.source sc3
							INNER JOIN source.administrative_source_type st ON (sc3.type_code = st.code)
						WHERE sc3.id = #{id}
						AND st.is_for_registration
						AND st.status = ''c''))

SELECT	CASE 	WHEN (SELECT (cnt = 0) FROM checkServiceType) THEN NULL
		WHEN (SELECT ((SELECT COUNT(*) FROM allSource) - (SELECT COUNT(*) FROM checkSource)) = 0) THEN TRUE
		ELSE FALSE
	END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('rrr-shares-total-check', '2012-11-22', 'infinity', '
SELECT (SUM(nominator::DECIMAL/denominator::DECIMAL)*10000)::INT = 10000  AS vl
FROM   administrative.rrr_share 
WHERE  rrr_id = #{id}
AND    denominator != 0');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('target-and-new-union-the-same', '2012-11-22', 'infinity', 'WITH target AS 
(SELECT st_union(co.geom_polygon) AS target_geom
 FROM   cadastre.cadastre_object co 
 WHERE  id in (SELECT cadastre_object_id 
               FROM cadastre.cadastre_object_target  
               WHERE transaction_id = #{id})),
pending AS 
(SELECT st_union(co.geom_polygon) AS pend_geom
 FROM   cadastre.cadastre_object co 
 WHERE   transaction_id = #{id})
SELECT st_contains(st_buffer(target.target_geom, system.get_setting(''map-tolerance'')::double precision), pending.pend_geom)
       AND st_contains(st_buffer(pending.pend_geom, system.get_setting(''map-tolerance'')::double precision), target.target_geom) AS vl
FROM target, pending');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-source-nr', '2012-11-22', 'infinity', '
WITH app AS  (
    SELECT a.id AS app_id
    FROM application.application a 
    WHERE CAST(#{refId} AS VARCHAR(40)) IS NOT NULL 
    AND a.id =  #{refId}
    UNION 
    SELECT ser.application_id AS app_id
    FROM   application.service ser,
           transaction.transaction t 
    WHERE  CAST(#{transactionId} AS VARCHAR(40)) IS NOT NULL
    AND    t.id = #{transactionId}
    AND    ser.id = t.from_service_id),
sources AS (
    SELECT aus.source_id AS source_id
    FROM   application.application_uses_source aus,
           app 
    WHERE  aus.application_id = app.app_id
    UNION
    SELECT rs.source_id as source_id
    FROM   app,
           application.service ser, 
           transaction.transaction t,
           administrative.rrr r,
           administrative.source_describes_rrr rs
    WHERE  ser.application_id = app.app_id
    AND    t.from_service_id = ser.id
    AND    r.transaction_id = t.id
    AND    rs.rrr_id = r.id)
SELECT CASE WHEN (SELECT COUNT(app_id) FROM app) > 0 THEN 
   (SELECT split_part(a.nr, ''/'', 1) || ''-'' || trim(to_char((SELECT COUNT(*) + 1 FROM sources), ''00''))
    FROM app, application.application a WHERE a.id = app.app_id)
	WHEN EXISTS (SELECT ba.id FROM administrative.ba_unit ba WHERE ba.id = #{refId} AND (SELECT COUNT(app_id) FROM app) = 0) THEN 
	 (SELECT ba.name_firstpart || ''/'' || ba.name_lastpart FROM administrative.ba_unit ba WHERE ba.id = #{refId})
	WHEN EXISTS (SELECT r.id FROM administrative.rrr r WHERE r.id = #{refId} AND (SELECT COUNT(app_id) FROM app) = 0) THEN 
	 (SELECT r.nr FROM administrative.rrr r WHERE r.id = #{refId})  || ''-''  || 
		trim(to_char((SELECT COUNT(*) + 1 FROM administrative.source_describes_rrr s WHERE s.rrr_id = #{refId}), ''00''))
	ELSE trim(to_char(nextval(''source.source_la_nr_seq''), ''000000'')) END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-notation-reference-nr', '2012-11-22', 'infinity', '
SELECT CASE WHEN CAST(#{transactionId} AS VARCHAR(40)) IS NOT NULL THEN (
                 SELECT 	split_part(app.nr, ''/'', 1)
				 FROM 	application.application app
				 WHERE	app.id IN  (	SELECT 	ser.application_id
						FROM 	application.service ser,
							transaction.transaction t
						WHERE 	t.id = #{transactionId}	
						AND   	ser.id = t.from_service_id))
            ELSE (SELECT trim(to_char(nextval(''administrative.notation_reference_nr_seq''), ''000000''))) END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-application-nr', '2012-11-22', 'infinity', '
WITH unit_plan_nr AS 
  (SELECT split_part(app.nr, ''/'', 1) AS app_nr, (COUNT(ser.id) + 1) AS suffix
   FROM administrative.ba_unit_contains_spatial_unit bas,
        cadastre.spatial_unit_in_group sug,
        transaction.transaction trans, 
        application.service ser,
        application.application app
   WHERE bas.ba_unit_id = #{baUnitId}
   AND   sug.spatial_unit_id = bas.spatial_unit_id
   AND   trans.spatial_unit_group_id = sug.spatial_unit_group_id
   AND   ser.id = trans.from_service_id
   AND   ser.request_type_code = ''unitPlan''
   AND   #{requestTypeCode} = ser.request_type_code
   AND   app.id = ser.application_id
   GROUP BY app_nr)
SELECT CASE (SELECT cat.code FROM application.request_category_type cat, application.request_type req WHERE req.code = #{requestTypeCode} AND cat.code = req.request_category_code) 
	WHEN ''cadastralServices'' THEN
	     (SELECT CASE WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} IN (''cadastreChange'', ''planNoCoords'') THEN
	                        trim(to_char(nextval(''application.survey_plan_nr_seq''), ''00000''))
					  WHEN (SELECT COUNT(app_nr) FROM unit_plan_nr) = 0 AND #{requestTypeCode} = ''redefineCadastre'' THEN
					        trim(to_char(nextval(''application.information_nr_seq''), ''000000''))
		              ELSE (SELECT app_nr || ''/'' || suffix FROM unit_plan_nr)  END)
	WHEN ''registrationServices'' THEN trim(to_char(nextval(''application.dealing_nr_seq''),''00000'')) 
	WHEN ''nonRegServices'' THEN trim(to_char(nextval(''application.non_register_nr_seq''),''00000'')) 
	ELSE trim(to_char(nextval(''application.information_nr_seq''), ''000000'')) END AS vl');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('application-verifies-identification', '2012-11-22', '2013-01-31', 'SELECT (COUNT(*) > 0) AS vl FROM source.source sc
	INNER JOIN application.application_uses_source aus ON (sc.id = aus.source_id)
WHERE aus.application_id= #{id}
AND sc.type_code = ''idVerification''');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('service-has-person-verification', '2012-11-22', '2013-01-31', 'SELECT (COUNT(*) > 0) AS vl FROM source.source sc
	INNER JOIN application.application_uses_source aus ON ((sc.id = aus.source_id) AND (sc.type_code = ''idVerification''))
	INNER JOIN application.service sv ON (aus.application_id = sv.application_id)
WHERE sv.id= #{id}
ORDER BY vl
LIMIT 1');
INSERT INTO br_definition (br_id, active_from, active_until, body) VALUES ('generate-baunit-nr', '2012-11-22', 'infinity', 'SELECT CASE WHEN CAST(#{cadastreObjectId} AS VARCHAR(40)) IS NOT NULL
	THEN (SELECT (CASE WHEN co.type_code = ''parcel'' THEN regexp_replace(co.name_firstpart, ''\D*|/.*'',  '''', ''g'') ELSE co.name_firstpart END) 
	        || ''/'' || regexp_replace(co.name_lastpart, ''[\s|L|l]$'',  '''') FROM cadastre.cadastre_object co WHERE id = #{cadastreObjectId})
	ELSE (SELECT to_char(now(), ''yymm'') || trim(to_char(nextval(''administrative.ba_unit_first_name_part_seq''), ''0000''))
			|| ''/200000'') END AS vl');


ALTER TABLE br_definition ENABLE TRIGGER ALL;

--
-- Data for Name: br_validation; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE br_validation DISABLE TRIGGER ALL;

INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b5b378-3445-11e2-9233-8b473e124d59', 'application-br7-check-sources-have-documents', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 570);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b5b378-3445-11e2-b2fb-ef6e0906c27c', 'application-br2-check-title-documents-not-old', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 510);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b814d8-3445-11e2-ac33-f7d53cf9ef18', 'application-br4-check-sources-date-not-in-the-future', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 710);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b814d8-3445-11e2-bfb8-3f5fd079d638', 'application-br5-check-there-are-front-desk-services', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 740);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b814d8-3445-11e2-8bc2-2b12b9c0edb8', 'application-br6-check-new-title-service-is-needed', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 730);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b814d8-3445-11e2-8419-13bd6d21ef32', 'applicant-name-to-owner-name-check', 'application', 'validate', NULL, NULL, NULL, NULL, 'warning', 410);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b814d8-3445-11e2-9c88-7f6d7f95e2ce', 'app-current-caveat-and-no-remove-or-vary', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 550);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4ba7638-3445-11e2-bd39-8b1a53f1fd6a', 'app-other-app-with-caveat', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 590);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4bf38f8-3445-11e2-8614-d7e64989c289', 'app-check-title-ref', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 750);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cb1fd8-3445-11e2-a107-4fd51f0b6a78', 'current-rrr-for-variation-or-cancellation-check', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 11);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cb1fd8-3445-11e2-8aa0-d34efe1f2ea7', 'current-rrr-for-variation-or-cancellation-check', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 650);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cb1fd8-3445-11e2-ab58-8fb70922d22c', 'power-of-attorney-owner-check', 'service', NULL, 'complete', NULL, NULL, NULL, 'warning', 580);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4d706b8-3445-11e2-abda-4b8f94e6e842', 'newtitle-br22-check-different-owners', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'warning', 680);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4d706b8-3445-11e2-8cc0-e754bc78ed53', 'ba_unit-spatial_unit-area-comparison', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'medium', 490);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4d706b8-3445-11e2-ad79-47adb7668c07', 'ba_unit-has-cadastre-object', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'medium', 500);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4d706b8-3445-11e2-b9af-ffe4b90e41eb', 'ba_unit-has-compatible-cadastre-object', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'medium', 540);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e08c38-3445-11e2-b185-2f3dba4393f9', 'target-parcels-present', 'cadastre_object', NULL, NULL, 'pending', NULL, NULL, 'warning', 450);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e08c38-3445-11e2-8d0c-5b90e91cdb35', 'target-parcels-present', 'cadastre_object', NULL, NULL, 'current', NULL, NULL, 'warning', 440);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e2ed98-3445-11e2-9c0f-639242f50893', 'target-parcels-check-nopending', 'cadastre_object', NULL, NULL, 'pending', NULL, NULL, 'critical', 310);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e2ed98-3445-11e2-a0b7-5b76b2b69f13', 'target-parcels-check-nopending', 'cadastre_object', NULL, NULL, 'current', NULL, NULL, 'critical', 300);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4d96818-3445-11e2-8439-eb228654b18b', 'ba_unit-has-a-valid-primary-right', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'medium', 20);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4d96818-3445-11e2-a333-43bbadf81652', 'target-ba_unit-check-if-pending', 'ba_unit', NULL, NULL, 'current', NULL, NULL, 'medium', 280);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cd8138-3445-11e2-a86d-434a1f62a2a1', 'service-title-terminated', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 190);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cd8138-3445-11e2-84b5-2f370623940e', 'required-sources-are-present', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 230);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cb1fd8-3445-11e2-8350-1f8b1fd9d179', 'documents-present', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 200);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cb1fd8-3445-11e2-b5b0-3bdf37a25c8c', 'document-supporting-rrr-is-current', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 240);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4c8be78-3445-11e2-8818-fb9c4afd79a6', 'service-on-complete-without-transaction', 'service', NULL, 'complete', NULL, NULL, NULL, 'medium', 360);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4bf38f8-3445-11e2-adc2-2f468ee4af3b', 'cancel-title-check-rrr-cancelled', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 150);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4bcd798-3445-11e2-b21b-d7c2c010e60c', 'application-approve-cancel-old-titles', 'application', 'approve', NULL, NULL, NULL, NULL, 'medium', 250);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4bcd798-3445-11e2-93e7-c78fa96b8f05', 'application-cancel-property-service-before-new-title', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 390);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4bcd798-3445-11e2-8d26-4b0816b66f3f', 'application-for-new-title-has-cancel-property-service', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 1);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4bcd798-3445-11e2-acc7-1fa326aa4049', 'newtitle-br24-check-rrr-accounted', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 160);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4ba7638-3445-11e2-8c32-8bb4d0bb9dd3', 'application-on-approve-check-services-without-transaction', 'application', 'approve', NULL, NULL, NULL, NULL, 'medium', 330);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e54ef8-3445-11e2-bd09-c31bf56c5f5a', 'target-parcels-check-isapolygon', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'medium', 80);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e54ef8-3445-11e2-9834-57c563c1e2af', 'target-parcels-check-isapolygon', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'medium', 90);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4c8be78-3445-11e2-a362-032a4c988ffe', 'mortgage-value-check', 'service', NULL, 'complete', NULL, 'variationMortgage', NULL, 'warning', 690);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4ea11b8-3445-11e2-83cf-5f34c9b14813', 'area-check-percentage-newareas-oldareas', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'warning', 630);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e7b058-3445-11e2-95a6-7b00da01b2be', 'area-check-percentage-newareas-oldareas', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 640);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e7b058-3445-11e2-b67a-5b305cdf0d46', 'cadastre-object-check-name', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'medium', 660);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e7b058-3445-11e2-9591-27b27feb918e', 'cadastre-object-check-name', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'medium', 600);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e7b058-3445-11e2-8c13-1bd0df678646', 'area-check-percentage-newofficialarea-calculatednewarea', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 620);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e7b058-3445-11e2-8bc4-2f1deb0a109c', 'area-check-percentage-newofficialarea-calculatednewarea', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'warning', 610);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e7b058-3445-11e2-a23c-4f9f64a4776c', 'new-cadastre-objects-do-not-overlap', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'medium', 480);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e7b058-3445-11e2-83d3-97a5e8c61076', 'new-cadastre-objects-do-not-overlap', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 60);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e54ef8-3445-11e2-84e3-fbf851b2bcaa', 'new-cadastre-objects-present', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'critical', 50);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e54ef8-3445-11e2-99ff-c70cafe0a68e', 'new-cadastre-objects-present', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 370);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e54ef8-3445-11e2-aebd-d30811b8d5d6', 'survey-points-present', 'cadastre_object', NULL, NULL, 'current', 'cadastreChange', NULL, 'critical', 70);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4fabb58-3445-11e2-803f-3f5ec6631b7d', 'source-attach-in-transaction-allowed-type', 'source', NULL, NULL, 'pending', NULL, NULL, 'medium', 560);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4fabb58-3445-11e2-b200-ff97cdc72372', 'source-attach-in-transaction-no-pendings', 'source', NULL, NULL, 'pending', NULL, NULL, 'medium', 220);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4f39738-3445-11e2-991f-0f61a84a6b00', 'rrr-has-pending', 'rrr', NULL, NULL, 'current', NULL, NULL, 'medium', 290);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4f39738-3445-11e2-a954-43328eedc7bd', 'ba_unit-has-caveat', 'rrr', NULL, NULL, 'current', NULL, NULL, 'medium', 30);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4f135d8-3445-11e2-a89b-9f9c094b19da', 'ba_unit-has-several-mortgages-with-same-rank', 'rrr', NULL, NULL, 'current', NULL, NULL, 'medium', 170);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4f135d8-3445-11e2-879d-03af09a78b49', 'rrr-shares-total-check', 'rrr', NULL, NULL, 'current', NULL, NULL, 'medium', 40);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4f135d8-3445-11e2-a78b-fbea3fac216b', 'rrr-must-have-parties', 'rrr', NULL, NULL, 'current', NULL, NULL, 'medium', 110);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e54ef8-3445-11e2-9a64-8b092ba85ae8', 'survey-points-present', 'cadastre_object', NULL, NULL, 'pending', 'cadastreChange', NULL, 'warning', 380);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cd8138-3445-11e2-bb2a-5b1d177499a2', 'application-baunit-check-area', 'service', NULL, NULL, NULL, 'cadastreChange', NULL, 'warning', 520);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e2ed98-3445-11e2-9dec-07e527d6a722', 'cadastre-redefinition-target-geometries-dont-overlap', 'cadastre_object', NULL, NULL, 'current', 'redefineCadastre', NULL, 'medium', 120);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e2ed98-3445-11e2-aeac-1bf78fbcf2ef', 'cadastre-redefinition-target-geometries-dont-overlap', 'cadastre_object', NULL, NULL, 'pending', 'redefineCadastre', NULL, 'warning', 430);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e2ed98-3445-11e2-b286-ab9d25542b5e', 'cadastre-redefinition-union-old-new-the-same', 'cadastre_object', NULL, NULL, 'pending', 'redefineCadastre', NULL, 'warning', 420);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4e2ed98-3445-11e2-bd2f-b3d674d33e0c', 'cadastre-redefinition-union-old-new-the-same', 'cadastre_object', NULL, NULL, 'current', 'redefineCadastre', NULL, 'warning', 400);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4c8be78-3445-11e2-bd2f-9faf85eac6dc', 'mortgage-value-check', 'service', NULL, 'complete', NULL, 'mortgage', NULL, 'warning', 700);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4c8be78-3445-11e2-9f6e-87bb7e53b0cc', 'baunit-has-multiple-mortgages', 'service', NULL, 'complete', NULL, 'mortgage', NULL, 'warning', 670);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4c8be78-3445-11e2-8b5d-2b6a39f1e956', 'service-check-no-previous-digital-title-service', 'service', NULL, 'complete', NULL, 'newDigitalTitle', NULL, 'warning', 720);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4cb1fd8-3445-11e2-9cea-db04ce7e338c', 'power-of-attorney-service-has-document', 'service', NULL, 'complete', NULL, 'regnPowerOfAttorney', NULL, 'medium', 340);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4c65d18-3445-11e2-9b3f-734e33be6e46', 'application-baunit-has-parcels', 'service', NULL, 'complete', NULL, 'redefineCadastre', NULL, 'medium', 140);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4c65d18-3445-11e2-95f6-03a7a55bb195', 'application-baunit-has-parcels', 'service', NULL, 'complete', NULL, 'cadastreChange', NULL, 'medium', 130);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4ba7638-3445-11e2-a3ec-6b230d144a34', 'application-on-approve-check-services-status', 'application', 'approve', NULL, NULL, NULL, NULL, 'medium', 270);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4ba7638-3445-11e2-b49a-b3929d20b7e2', 'app-allowable-primary-right-for-new-title', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 10);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4ba7638-3445-11e2-beed-634bc732c3b1', 'app-title-has-primary-right', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 100);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b5b378-3445-11e2-aa70-cb542fdedec5', 'application-br3-check-properties-are-not-historic', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 180);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b5b378-3445-11e2-b1ae-6f50b3d171fc', 'application-br1-check-required-sources-are-present', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 210);
INSERT INTO br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('d4b0f0b8-3445-11e2-9e3f-bb89f8a4b767', 'application-br8-check-has-services', 'application', 'validate', NULL, NULL, NULL, NULL, 'medium', 260);


ALTER TABLE br_validation ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

