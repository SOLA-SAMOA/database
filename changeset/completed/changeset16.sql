-- 21 Apr 2012
-- #96 Unable to change property shares
-- Create a transaction
INSERT INTO transaction.transaction (id, from_service_id, status_code, change_user)
VALUES ('a9f5062f-ac35-461f-b005-bb6a5b9a6f15', '69918c13-c0be-42dc-beff-53086bcf66f2', 'pending', 'andrew'); 

-- Add the rrr
INSERT INTO administrative.rrr (id, ba_unit_id, nr, type_code, status_code, is_primary, transaction_id, change_user)
VALUES ('d4689268-5014-4b63-8912-70f4d422fb96', '3EA1A855-400A-4FD8-9F14-0DC5F2AC46C6', '035775', 'ownership', 'pending', true, 'a9f5062f-ac35-461f-b005-bb6a5b9a6f15', 'andrew'); 

-- Add the notation
INSERT INTO administrative.notation (id, rrr_id, transaction_id, reference_nr, notation_text, status_code, change_user)
VALUES ('5bd78ed6-8611-4c14-a8cf-696c3866da48', 'd4689268-5014-4b63-8912-70f4d422fb96', 'a9f5062f-ac35-461f-b005-bb6a5b9a6f15', '40167', 'Correction by Registrar to fix shares for Simon & Lisa Kalapu and Alaisi Iosefa', 'pending', 'andrew'); 

-- Add the source
INSERT INTO administrative.source_describes_rrr (rrr_id, source_id, change_user)
VALUES ('d4689268-5014-4b63-8912-70f4d422fb96', '8a937bcd-cd86-4602-abf9-c7f7e4954f52', 'andrew'); 

-- Add the 1/12 shares
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('715c5b2c-c0ea-4cf6-a5fb-390e575d91e5',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('c8c7a501-16ff-44de-8260-f08645302550',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('36444613-a86c-4ae8-bd10-9181e9db662f',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('17cd445b-db01-4698-8d5a-0bf3dc063e17',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('9514632d-293f-43b6-9e13-d017b104ab38',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('3f444174-1641-432b-81f8-e6f221a2d268',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('72ac5447-f0d9-4b4d-b947-424e4692c2b3',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('25f9c06e-0fe1-4c4a-8256-e08a045ceb24',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('28729221-646f-491e-a5e9-6c82f3f107ab',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('78567372-f328-44dc-b7b8-73c114944222',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('ec149d4d-f4fb-4b4c-89ef-2d12c340094c',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 
INSERT INTO administrative.rrr_share (id, rrr_id, nominator, denominator, change_user) 
VALUES ('8bde6e74-a988-4e3c-bdcb-bcbcb29497a3',  'd4689268-5014-4b63-8912-70f4d422fb96', 1, 12, 'andrew'); 


-- Add New Parties
INSERT INTO party.party (id, name, last_name, type_code, change_user) 
VALUES ('0c46d341-b083-417c-993e-1e3d4b3e98e2',  'Lisa Michelle', 'Kalapu', 'naturalPerson', 'andrew'); 
INSERT INTO party.party (id, name, last_name, type_code, change_user) 
VALUES ('20fc31cc-bf60-4492-b6fd-64bd3a22410a',  'Alaisi', 'Iosefa', 'naturalPerson', 'andrew'); 
INSERT INTO party.party (id, name, last_name, type_code, change_user) 
VALUES ('8e393e84-e334-4007-85ef-b10027d23233',  'Simon Andrew', 'Kalapu', 'naturalPerson', 'andrew'); 


-- Create new party mappings for the shares
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('715c5b2c-c0ea-4cf6-a5fb-390e575d91e5',  'd4689268-5014-4b63-8912-70f4d422fb96', '0c46d341-b083-417c-993e-1e3d4b3e98e2', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('715c5b2c-c0ea-4cf6-a5fb-390e575d91e5',  'd4689268-5014-4b63-8912-70f4d422fb96', '8e393e84-e334-4007-85ef-b10027d23233', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('c8c7a501-16ff-44de-8260-f08645302550',  'd4689268-5014-4b63-8912-70f4d422fb96', '20fc31cc-bf60-4492-b6fd-64bd3a22410a', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('36444613-a86c-4ae8-bd10-9181e9db662f',  'd4689268-5014-4b63-8912-70f4d422fb96', '20D3D135-ACB6-4EA2-BE18-6EC40F124905', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('17cd445b-db01-4698-8d5a-0bf3dc063e17',  'd4689268-5014-4b63-8912-70f4d422fb96', '3B643639-B767-4CD0-BEB1-E2B8203E069B', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('9514632d-293f-43b6-9e13-d017b104ab38',  'd4689268-5014-4b63-8912-70f4d422fb96', '319E0EF1-F7EB-46C4-8033-107E7722C350', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('3f444174-1641-432b-81f8-e6f221a2d268',  'd4689268-5014-4b63-8912-70f4d422fb96', 'E56E649A-C928-417F-B1E8-43AF33D94A53', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('72ac5447-f0d9-4b4d-b947-424e4692c2b3',  'd4689268-5014-4b63-8912-70f4d422fb96', 'FC48F72C-EB3A-495D-BD9F-9003EE1628B3', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('25f9c06e-0fe1-4c4a-8256-e08a045ceb24',  'd4689268-5014-4b63-8912-70f4d422fb96', '7D3119AF-F1C9-4C5E-AB7E-550AEE091F52', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('28729221-646f-491e-a5e9-6c82f3f107ab',  'd4689268-5014-4b63-8912-70f4d422fb96', '08955312-E605-431D-B710-EABC0AC46FEB', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('78567372-f328-44dc-b7b8-73c114944222',  'd4689268-5014-4b63-8912-70f4d422fb96', 'A276A1D5-3829-4DAC-B855-D57DD551DC41', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('ec149d4d-f4fb-4b4c-89ef-2d12c340094c',  'd4689268-5014-4b63-8912-70f4d422fb96', 'F04F1D64-1F02-4684-894B-99A288905333', 'andrew'); 
INSERT INTO administrative.party_for_rrr (share_id, rrr_id, party_id, change_user) 
VALUES ('8bde6e74-a988-4e3c-bdcb-bcbcb29497a3',  'd4689268-5014-4b63-8912-70f4d422fb96', '93F4939E-25D8-4AA5-AC91-4135C16C3117', 'andrew'); 






