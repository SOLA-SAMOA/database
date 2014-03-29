-- Applied 23-Nov-2012

-- Only search applications that are not annulled
UPDATE system.query
SET sql  = 
 'SELECT MIN(su.id) as id, su.label, st_asewkb(ST_Union(su.reference_point)) as the_geom 
  FROM cadastre.spatial_unit su, cadastre.level l 
  WHERE su.level_id = l.id and l."name" = ''Survey Plans''  
  AND compare_strings(#{search_string}, su.label)
  AND su.reference_point IS NOT NULL
  GROUP BY su.label
  UNION
  SELECT app.id as id, app.nr as label, st_asewkb(app.location) as the_geom
  FROM application.application app
  WHERE app.location IS NOT NULL
  AND   app.status_code != ''annulled''
  AND compare_strings(#{search_string}, app.nr)'
WHERE "name" = 'map_search.survey_plan'; 

UPDATE system.query
SET sql = 
'select id, nr as label, st_asewkb(location) as the_geom from application.application 
where location IS NOT NULL AND status_code != ''annulled''
AND ST_Intersects(location, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))'
WHERE "name" = 'SpatialResult.getApplications'; 


UPDATE system.query
SET sql = 
'select id, nr, st_asewkb(location) as the_geom FROM application.application 
where location IS NOT NULL AND status_code != ''annulled''
AND  ST_Intersects(location, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))'
WHERE "name" = 'dynamic.informationtool.get_application';


INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('traverse','Traverse Sheet::::SAMOAN','c','FALSE');

INSERT INTO source.administrative_source_type (code,display_value,status,is_for_registration)
VALUES ('flurPlan','Flur Plan::::SAMOAN','c','FALSE');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) (SELECT 'ApplnApprove', id FROM system.appgroup WHERE "name" = 'Land Registry');