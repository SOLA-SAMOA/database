-- 9 Oct 2013 Changeset #112

-- Remove all data created for plan 7286
UPDATE cadastre.cadastre_object 
SET change_user = 'andrew'
WHERE name_lastpart = '7286'
AND   geom_polygon IS NOT NULL;
DELETE FROM cadastre.cadastre_object 
WHERE name_lastpart = '7286'
AND   geom_polygon IS NOT NULL;
DELETE FROM transaction.transaction WHERE from_service_id IN
 ( SELECT id FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '7286'));
DELETE FROM application.service WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '7286');
DELETE FROM application.application_property WHERE application_id IN
    ( SELECT id FROM application.application WHERE nr = '7286');
UPDATE application.application 
SET change_user = 'andrew'
WHERE nr = '7286';
DELETE FROM application.application WHERE nr = '7286';

-- Make Lot 3053 Plan 6365 historic 
UPDATE cadastre.cadastre_object 
SET    status_code = 'historic',
       change_user = 'andrew'
WHERE  name_firstpart = '3053'
AND    name_lastpart = '6365';

-- Make PT 318/45 PLAN 3975 historic
UPDATE cadastre.cadastre_object 
SET    status_code = 'historic',
       change_user = 'andrew'
WHERE  name_firstpart = 'PT 318/45'
AND    name_lastpart = '3975';

-- Make PT 318 PLAN 2779L historic
UPDATE cadastre.cadastre_object 
SET    status_code = 'historic',
       change_user = 'andrew'
WHERE  name_firstpart = 'PT 318'
AND    name_lastpart = '2779L';

-- Make Lot 2 PLAN 11127 historic and re-instate the original parcel shape. 
UPDATE cadastre.cadastre_object 
SET    status_code = 'historic',
       change_user = 'andrew',
       geom_polygon = st_setSrid(st_geomFromText('POLYGON((410203.187063622 8471438.78377959,410208.183459981 8471454.56015849,410224.694546608 8471448.30389364,410218.777292354 8471429.31611324,410203.187063622 8471438.78377959))'), 32702)
WHERE  name_firstpart = 'LOT 2'
AND    name_lastpart = '11127';

-- Make Lot 1 PLAN 11127 historic and re-instate the original parcel shape. 
UPDATE cadastre.cadastre_object 
SET    status_code = 'historic',
       change_user = 'andrew',
       geom_polygon = st_setSrid(st_geomFromText('POLYGON((410008.293870855 8471507.17026625,410027.836521836 8471585.16439078,410028.661106266 8471665.59801875,410275.16237565 8471610.24928482,410224.694546608 8471448.30389364,410208.183459981 8471454.56015849,410203.187063622 8471438.78377959,410180.302182869 8471452.68135731,410015.063709022 8471495.00274292,410008.293870855 8471507.17026625))'), 32702)
WHERE  name_firstpart = 'LOT 1'
AND    name_lastpart = '11127';

