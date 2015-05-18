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
-- Data for Name: config_map_layer_type; Type: TABLE DATA; Schema: system; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE config_map_layer_type DISABLE TRIGGER ALL;

INSERT INTO config_map_layer_type (code, display_value, status, description) VALUES ('wms', 'WMS server with layers::::VMS Teuina ma Loia', 'c', NULL);
INSERT INTO config_map_layer_type (code, display_value, status, description) VALUES ('shape', 'Shapefile::::Faila o Meafaitino', 'c', NULL);
INSERT INTO config_map_layer_type (code, display_value, status, description) VALUES ('pojo', 'Pojo layer::::Itulau o le Pojo', 'c', NULL);


ALTER TABLE config_map_layer_type ENABLE TRIGGER ALL;

--
-- Data for Name: query; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE query DISABLE TRIGGER ALL;

INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_parcel', 'SELECT co.id, 
			cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as parcel_nr,
		   (SELECT string_agg(ba.name_firstpart || ''/'' || ba.name_lastpart, '','') 
			FROM 	administrative.ba_unit_contains_spatial_unit bas, 
					administrative.ba_unit ba
			WHERE	spatial_unit_id = co.id and bas.ba_unit_id = ba.id) AS ba_units,
			cadastre.formatAreaMetric(sva.size) || '' '' || cadastre.formatAreaImperial(sva.size) AS official_area,
			CASE WHEN sva.size IS NOT NULL THEN NULL
			     ELSE cadastre.formatAreaMetric(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) || '' '' ||
			cadastre.formatAreaImperial(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) END AS calculated_area,
			st_asewkb(co.geom_polygon) as the_geom
	FROM 	cadastre.cadastre_object co LEFT OUTER JOIN cadastre.spatial_value_area sva 
			ON sva.spatial_unit_id = co.id AND sva.type_code = ''officialArea''
	WHERE 	co.type_code= ''parcel'' 
	AND 	co.status_code= ''current''      
	AND 	ST_Intersects(co.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 'SELECT co.id, 
			cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as parcel_nr,
		   (SELECT string_agg(ba.name_firstpart || ''/'' || ba.name_lastpart, '','') 
			FROM 	administrative.ba_unit_contains_spatial_unit bas, 
					administrative.ba_unit ba
			WHERE	spatial_unit_id = co.id and bas.ba_unit_id = ba.id) AS ba_units,
			cadastre.formatAreaMetric(sva.size) || '' '' || cadastre.formatAreaImperial(sva.size) AS official_area,
			CASE WHEN sva.size IS NOT NULL THEN NULL
			     ELSE cadastre.formatAreaMetric(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) || '' '' ||
			cadastre.formatAreaImperial(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) END AS calculated_area,
			st_asewkb(co.geom_polygon) as the_geom
	FROM 	cadastre.cadastre_object co LEFT OUTER JOIN cadastre.spatial_value_area sva 
			ON sva.spatial_unit_id = co.id AND sva.type_code = ''officialArea'', 
			administrative.ba_unit_contains_spatial_unit ba_co, 
			administrative.ba_unit ba
	WHERE 	co.type_code= ''parcel'' 
	AND 	co.status_code= ''historic''      
	AND 	ST_Intersects(co.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))
	AND     ba_co.spatial_unit_id = co.id
	AND		ba.id = ba_co.ba_unit_id
	AND		ba.status_code = ''current''', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcels', 'select co.id, cadastre.formatParcelNrLabel(co.name_firstpart, co.name_lastpart) as label,  st_asewkb(co.geom_polygon) as the_geom from cadastre.cadastre_object co where type_code= ''parcel'' and status_code= ''current'' 
 and ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getRoadCL', 'select su.id, su.label,  st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Road Centerlines'' and ST_Intersects(su.geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_roadCL', 'select su.id, su.label, st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Road Centerlines''  and ST_Intersects(su.geom, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcelAreas', 'select co.id, trim(cadastre.formatAreaMetric(sva.size)) || chr(10) || cadastre.formatAreaImperial(sva.size) AS label,  st_asewkb(co.geom_polygon) as the_geom from cadastre.cadastre_object co, cadastre.spatial_value_area sva 
 WHERE co.type_code= ''parcel'' and co.status_code= ''current'' AND sva.spatial_unit_id = co.id AND sva.type_code = ''officialArea'' 
 AND ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getRoad', 'select su.id, su.label,  st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Roads'' and ST_Intersects(su.geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_road', 'select su.id, su.label, st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Roads''  and ST_Intersects(su.geom, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getFlur', 'select su.id, su.label,  st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Flur'' and ST_Intersects(su.geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcelsHistoricWithCurrentBA', 'select co.id, cadastre.formatParcelNrLabel(co.name_firstpart, co.name_lastpart) as label,  st_asewkb(co.geom_polygon) as the_geom from cadastre.cadastre_object co inner join administrative.ba_unit_contains_spatial_unit ba_co on co.id = ba_co.spatial_unit_id   inner join administrative.ba_unit ba_unit on ba_unit.id= ba_co.ba_unit_id where co.type_code=''parcel'' and co.status_code= ''historic'' and ba_unit.status_code = ''current'' and ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getApplications', 'select id, nr as label, st_asewkb(location) as the_geom from application.application 
where location IS NOT NULL AND status_code != ''annulled''
AND ST_Intersects(location, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_application', 'select id, nr, st_asewkb(location) as the_geom FROM application.application 
where location IS NOT NULL AND status_code != ''annulled''
AND  ST_Intersects(location, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.cadastre_object_by_number', 'SELECT id, cadastre.formatParcelNr(name_firstpart, name_lastpart) as label, st_asewkb(geom_polygon) as the_geom  
 FROM cadastre.cadastre_object  
 WHERE status_code= ''current'' 
 AND geom_polygon IS NOT NULL 
 AND compare_strings(#{search_string}, name_firstpart || '' PLAN '' || name_lastpart) 
 ORDER BY lpad(regexp_replace(name_firstpart, ''\\D*'', '''', ''g''), 5, ''0'') || name_firstpart || name_lastpart
 LIMIT 30', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcelNodes', 'select distinct st_astext(geom) as id, '''' as label, st_asewkb(geom) as the_geom from (select (ST_DumpPoints(geom_polygon)).* from cadastre.cadastre_object co  where type_code= ''parcel'' and status_code= ''current''  and ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))) tmp_table ', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_parcel_pending', 'SELECT co.id, 
			cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as parcel_nr,
			cadastre.formatAreaMetric(sva.size) || '' '' || cadastre.formatAreaImperial(sva.size) AS official_area,
			CASE WHEN sva.size IS NOT NULL THEN NULL
			     ELSE cadastre.formatAreaMetric(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) || '' '' ||
			cadastre.formatAreaImperial(CAST(st_area(co.geom_polygon) AS NUMERIC(29,2))) END AS calculated_area,
			st_asewkb(co.geom_polygon) as the_geom
	FROM 	cadastre.cadastre_object co LEFT OUTER JOIN cadastre.spatial_value_area sva 
			ON sva.spatial_unit_id = co.id AND sva.type_code = ''officialArea''
	WHERE   co.type_code= ''parcel'' 
	AND   ((co.status_code = ''pending''    
	AND 	ST_Intersects(co.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid})))   
	   OR  (co.id in (SELECT 	cadastre_object_id           
					  FROM 		cadastre.cadastre_object_target co_t,
								transaction.transaction t
					  WHERE 	ST_Intersects(co_t.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid})) 
					  AND 		co_t.transaction_id = t.id
					  AND		t.status_code not in (''approved''))))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getVillages', 'select su.id, su.label,  st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Villages'' and ST_Intersects(su.reference_point, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_villages', 'select su.id, su.label, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Villages''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getDistricts', 'select su.id, su.label,  st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Districts'' and ST_Intersects(su.reference_point, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_districts', 'select su.id, su.label, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Districts''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getCourtGrant', 'select su.id, su.label,  st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Court Grants'' and ST_Intersects(su.reference_point, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_courtGrant', 'select su.id, su.label, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Court Grants''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getHydro', 'select su.id, su.label,  st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Hydro Features'' and ST_Intersects(su.geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_hydro', 'select su.id, su.label, st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Hydro Features''  and ST_Intersects(su.geom, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getIslands', 'select su.id, su.label,  st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Islands'' and ST_Intersects(su.reference_point, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_islands', 'select su.id, su.label, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Islands''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getRecordSheets', 'select su.id, su.label,  st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Record Sheets'' and ST_Intersects(su.geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_recordSheets', 'select su.id, su.label, st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Record Sheets''  and ST_Intersects(su.geom, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getSurveyPlan', 'select su.id, su.label,  st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Survey Plans'' and ST_Intersects(su.reference_point, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_surveyPlan', 'select su.id, su.label, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Survey Plans''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('system_search.cadastre_object_by_baunit_id', 'SELECT id,  cadastre.formatParcelNr(name_firstpart, name_lastpart) as label, st_asewkb(geom_polygon) as the_geom  FROM cadastre.cadastre_object WHERE transaction_id IN (  SELECT cot.transaction_id FROM (administrative.ba_unit_contains_spatial_unit ba_su     INNER JOIN cadastre.cadastre_object co ON ba_su.spatial_unit_id = co.id)     INNER JOIN cadastre.cadastre_object_target cot ON co.id = cot.cadastre_object_id     WHERE ba_su.ba_unit_id = #{search_string})  AND (SELECT COUNT(1) FROM administrative.ba_unit_contains_spatial_unit WHERE spatial_unit_id = cadastre_object.id) = 0 AND geom_polygon IS NOT NULL AND status_code = ''current''', 'Query used by BaUnitBean.loadNewParcels');
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_flur', 'select su.id, su.label, st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Flur''  and ST_Intersects(su.geom, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.road', 'SELECT su.id, su.label, st_asewkb(su.geom) as the_geom 
  FROM cadastre.spatial_unit su, cadastre.level l 
  WHERE su.level_id = l.id and l."name" = ''Road Centerlines''  
  AND compare_strings(#{search_string}, su.label)
  AND su.label IS NOT NULL
  AND su.geom IS NOT NULL', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.flur', 'SELECT su.id, su.label, st_asewkb(su.geom) as the_geom 
  FROM cadastre.spatial_unit su, cadastre.level l 
  WHERE su.level_id = l.id and l."name" = ''Flur''  
  AND compare_strings(#{search_string}, su.label)
  AND su.label IS NOT NULL
  AND su.geom IS NOT NULL', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.village', 'SELECT su.id, su.label, st_asewkb(su.reference_point) as the_geom 
  FROM cadastre.spatial_unit su, cadastre.level l 
  WHERE su.level_id = l.id and l."name" = ''Villages''  
  AND compare_strings(#{search_string}, su.label)
  AND su.reference_point IS NOT NULL', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.court_grant', 'SELECT MIN(su.id) as id, su.label, st_asewkb(ST_Union(su.reference_point)) as the_geom 
  FROM cadastre.spatial_unit su, cadastre.level l 
  WHERE su.level_id = l.id and l."name" = ''Court Grants''  
  AND compare_strings(#{search_string}, su.label)
  AND su.reference_point IS NOT NULL
  GROUP BY su.label', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.cadastre_object_by_baunit_owner', 'SELECT DISTINCT co.id,  
       coalesce(p.name, '''') || '' '' || coalesce(p.last_name, '''') || '' > '' || cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as label,  
       st_asewkb(co.geom_polygon) as the_geom 
FROM   party.party p,
       administrative.party_for_rrr pfr,
       administrative.rrr rrr,
       administrative.ba_unit bau,
       administrative.ba_unit_contains_spatial_unit bas,
       cadastre.cadastre_object  co
WHERE  compare_strings(#{search_string}, coalesce(p.name, '''') || '' '' || coalesce(p.last_name, '''') || '' '' || coalesce(p.alias, ''''))
AND    pfr.party_id = p.id
AND    rrr.id = pfr.rrr_id
AND    rrr.status_code = ''current''
AND    rrr.type_code = ''ownership''
AND    bau.id = rrr.ba_unit_id
AND    bas.ba_unit_id = bau.id
AND    co.id = bas.spatial_unit_id
AND    co.geom_polygon IS NOT NULL
AND   (co.status_code = ''current'' OR bau.status_code = ''current'')
LIMIT 30', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.cadastre_object_by_baunit', 'select distinct co.id,  ba_unit.name_firstpart || ''/'' || ba_unit.name_lastpart || '' > '' || cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as label,  st_asewkb(geom_polygon) as the_geom from cadastre.cadastre_object  co    inner join administrative.ba_unit_contains_spatial_unit bas on co.id = bas.spatial_unit_id     inner join administrative.ba_unit on ba_unit.id = bas.ba_unit_id  where (co.status_code= ''current'' or ba_unit.status_code= ''current'') and co.geom_polygon IS NOT NULL  and compare_strings(#{search_string}, ba_unit.name_firstpart || '' / '' || ba_unit.name_lastpart) limit 30', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getParcelsPending', 'select co.id, cadastre.formatParcelNrLabel(co.name_firstpart, co.name_lastpart) as label,  st_asewkb(co.geom_polygon) as the_geom  from cadastre.cadastre_object co  where type_code= ''parcel'' and status_code= ''pending''   and ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid})) union select co.id, cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as label,  st_asewkb(co_t.geom_polygon) as the_geom  from cadastre.cadastre_object co inner join cadastre.cadastre_object_target co_t on co.id = co_t.cadastre_object_id and co_t.geom_polygon is not null where ST_Intersects(co_t.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))       and co_t.transaction_id in (select id from transaction.transaction where status_code not in (''approved'')) ', NULL);
INSERT INTO query (name, sql, description) VALUES ('map_search.survey_plan', 'SELECT MIN(su.id) as id, su.label, st_asewkb(ST_Union(su.reference_point)) as the_geom 
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
  AND compare_strings(#{search_string}, app.nr)', NULL);
INSERT INTO query (name, sql, description) VALUES ('SpatialResult.getUnitParcel', 'SELECT co.id, cadastre.formatParcelNrLabel(co.name_firstpart, co.name_lastpart) as label,  st_asewkb(co.geom_polygon) as the_geom 
  FROM cadastre.cadastre_object co, cadastre.spatial_unit_in_group sug
  WHERE sug.spatial_unit_id = co.id AND co.type_code = ''parcel'' AND co.status_code = ''current'' 
  AND co.geom_polygon IS NOT NULL AND sug.unit_parcel_status_code = ''current''
  AND ST_Intersects(co.geom_polygon, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL);
INSERT INTO query (name, sql, description) VALUES ('dynamic.informationtool.get_unit_parcel', 'WITH unit_plan_parcels AS 
	  (SELECT co_unit.id AS unit_id,
	          sug2.spatial_unit_group_id AS group_id,
			  CASE co_unit.type_code 
				WHEN ''commonProperty'' THEN 1 
				WHEN ''principalUnit'' THEN 2
				WHEN ''accessoryUnit'' THEN 3 END  AS unit_type, 
			  co_unit.name_firstpart AS unit_name, 
			  co_unit.name_lastpart AS plan_num
	   FROM   cadastre.cadastre_object co_unit, 
	          cadastre.spatial_unit_in_group sug2
	   WHERE  co_unit.status_code = ''current''
	   AND    co_unit.type_code != ''parcel''
	   AND    sug2.spatial_unit_id = co_unit.id
	   AND    sug2.unit_parcel_status_code = ''current''
	   ORDER BY unit_type, plan_num, unit_name)
	SELECT co.id, 
			cadastre.formatParcelNr(co.name_firstpart, co.name_lastpart) as parcel_nr,
		   (SELECT  string_agg(unit_name, '', '') 
			FROM 	unit_plan_parcels
			WHERE   group_id = sg.id) || '' PLAN '' || sg.name AS unit_parcels,
		   (SELECT string_agg(ba.name_firstpart || ''/'' || ba.name_lastpart, '', '') 
			FROM 	unit_plan_parcels, 
					administrative.ba_unit_contains_spatial_unit bas, 
					administrative.ba_unit ba
			WHERE	group_id = sg.id 
			AND     bas.spatial_unit_id = unit_id 
			AND     bas.ba_unit_id = ba.id
			AND     ba.status_code = ''current'') AS unit_properties,
			st_asewkb(co.geom_polygon) as the_geom
	FROM 	cadastre.cadastre_object co, 
	        cadastre.spatial_unit_in_group sug,
			cadastre.spatial_unit_group sg
	WHERE 	co.type_code= ''parcel'' 
	AND 	co.status_code= ''current''  
	AND     sug.unit_parcel_status_code = ''current''
    AND     sug.spatial_unit_id = co.id
	AND     sg.id = sug.spatial_unit_group_id
	AND		co.geom_polygon IS NOT NULL
	AND 	ST_Intersects(co.geom_polygon, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);


ALTER TABLE query ENABLE TRIGGER ALL;

--
-- Data for Name: config_map_layer; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE config_map_layer DISABLE TRIGGER ALL;

INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('applications', 'Applications::::Talosaga', 'pojo', true, true, 140, 'samoa_application.xml', NULL, NULL, NULL, NULL, 'theGeom:MultiPoint,label:""', 'SpatialResult.getApplications', 'dynamic.informationtool.get_application', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('parcels', 'Parcels::::Poloka', 'pojo', true, true, 30, 'samoa_parcel.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getParcels', 'dynamic.informationtool.get_parcel', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('pending-parcels', 'Pending Parcels::::Poloka Faamalumalu', 'pojo', true, false, 130, 'pending_parcels.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getParcelsPending', 'dynamic.informationtool.get_parcel_pending', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('orthophoto', 'Orthophoto::::SAMOAN', 'wms', false, false, 10, NULL, 'http://localhost:8085/geoserver/sola/wms', 'sola:nz_orthophoto', '1.1.1', 'image/jpeg', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('parcels-historic-current-ba', 'Historic Parcels with Current Titles::::Talaaga o le Fanua', 'pojo', true, false, 50, 'parcel_historic_current_ba.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getParcelsHistoricWithCurrentBA', 'dynamic.informationtool.get_parcel_historic_current_ba', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('parcel-nodes', 'Parcel Nodes::::Nota o le poloka', 'pojo', true, false, 40, 'parcel_node.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getParcelNodes', NULL, NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('villages', 'Villages::::Nuu', 'pojo', true, true, 120, 'samoa_village.xml', NULL, NULL, NULL, NULL, 'theGeom:Point,label:""', 'SpatialResult.getVillages', 'dynamic.informationtool.get_villages', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('districts', 'Districts::::Itumalo', 'pojo', true, false, 80, 'samoa_district.xml', NULL, NULL, NULL, NULL, 'theGeom:Point,label:""', 'SpatialResult.getDistricts', 'dynamic.informationtool.get_districts', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('courtGrant', 'Court Grant::::Iuga o le Faamasinoga', 'pojo', true, false, 100, 'samoa_court_grant.xml', NULL, NULL, NULL, NULL, 'theGeom:Point,label:""', 'SpatialResult.getCourtGrant', 'dynamic.informationtool.get_courtGrant', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('hydro', 'Hydro::::eleele susu', 'pojo', true, true, 20, 'samoa_hydro.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getHydro', 'dynamic.informationtool.get_hydro', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('islands', 'Islands::::Motu', 'pojo', true, true, 70, 'samoa_island.xml', NULL, NULL, NULL, NULL, 'theGeom:Point,label:""', 'SpatialResult.getIslands', 'dynamic.informationtool.get_islands', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('recordSheet', 'Record Sheets::::Faamaumauga o fuataga', 'pojo', true, false, 60, 'samoa_record_sheet.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getRecordSheets', 'dynamic.informationtool.get_recordSheets', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('survey_plan', 'Survey Plan::::Fuataga o Fanua', 'pojo', true, false, 90, 'samoa_survey_plan.xml', NULL, NULL, NULL, NULL, 'theGeom:Point,label:""', 'SpatialResult.getSurveyPlan', 'dynamic.informationtool.get_surveyPlan', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('road_cl', 'Road Centrelines::::Ogatotonu o le auala', 'pojo', true, true, 110, 'samoa_road_cl.xml', NULL, NULL, NULL, NULL, 'theGeom:LineString,label:""', 'SpatialResult.getRoadCL', 'dynamic.informationtool.get_roadCL', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('parcel_area', 'Parcel Area::::Tele o le poloka', 'pojo', true, false, 25, 'samoa_parcel_area.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getParcelAreas', NULL, NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('road', 'Roads::::Auala', 'pojo', true, false, 105, 'samoa_road.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getRoad', 'dynamic.informationtool.get_road', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('flur', 'Flur::::SAMOAN', 'pojo', true, false, 102, 'samoa_flur.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getFlur', 'dynamic.informationtool.get_flur', NULL, NULL, NULL);
INSERT INTO config_map_layer (name, title, type_code, active, visible_in_start, item_order, style, url, wms_layers, wms_version, wms_format, pojo_structure, pojo_query_name, pojo_query_name_for_select, shape_location, security_user, security_password) VALUES ('unit_parcel', 'Unit Parcels::::SAMOAN', 'pojo', true, false, 35, 'samoa_unit_parcel.xml', NULL, NULL, NULL, NULL, 'theGeom:Polygon,label:""', 'SpatialResult.getUnitParcel', 'dynamic.informationtool.get_unit_parcel', NULL, NULL, NULL);


ALTER TABLE config_map_layer ENABLE TRIGGER ALL;

--
-- Data for Name: map_search_option; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE map_search_option DISABLE TRIGGER ALL;


INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('BAUNIT', 'Property Number::::Meatotino Numera', 'map_search.cadastre_object_by_baunit', true, 3, 50.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('NUMBER', 'Parcel Number::::Poloka Numera', 'map_search.cadastre_object_by_number', true, 3, 50.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('OWNER_OF_BAUNIT', 'Property Owner::::Meatotino O e Pule', 'map_search.cadastre_object_by_baunit_owner', true, 3, 50.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('ROAD', 'Road Name::::Auala', 'map_search.road', true, 3, 100.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('FLUR', 'Flur Number::::SAMOAN', 'map_search.flur', true, 1, 300.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('VILLAGE', 'Village::::Nuu', 'map_search.village', true, 2, 300.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('COURT_GRANT', 'Court Grant::::Iuga o le Faamasinoga', 'map_search.court_grant', true, 1, 200.00, NULL);
INSERT INTO map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description) VALUES ('SURVEY_PLAN', 'Survey Plan::::Fuataga o Fanua', 'map_search.survey_plan', true, 2, 100.00, NULL);


ALTER TABLE map_search_option ENABLE TRIGGER ALL;

--
-- Data for Name: query_field; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE query_field DISABLE TRIGGER ALL;

INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_application', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_application', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_application', 1, 'nr', 'Number::::Numera');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 1, 'parcel_nr', 'Parcel number::::Poloka numera');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 2, 'ba_units', 'Properties::::Meatotino');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 3, 'official_area', 'Official area::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 4, 'calculated_area', 'Calculated area::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel', 5, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 1, 'parcel_nr', 'Parcel number::::Poloka numera');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 2, 'official_area', 'Official area::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 3, 'calculated_area', 'Calculated area::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_pending', 4, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 1, 'parcel_nr', 'Parcel number::::Poloka numera');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 2, 'ba_units', 'Properties::::Meatotino');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 3, 'official_area', 'Official area::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 4, 'calculated_area', 'Calculated area::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_parcel_historic_current_ba', 5, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_villages', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_villages', 1, 'label', 'Village::::Nuu');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_villages', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_districts', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_districts', 1, 'label', 'District::::Itumalo');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_districts', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_courtGrant', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_courtGrant', 1, 'label', 'Court Grant::::Iuga o le Faamasinoga');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_courtGrant', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_hydro', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_hydro', 1, 'label', 'Name::::Igoa');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_hydro', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_islands', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_islands', 1, 'label', 'Island::::Motu');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_islands', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_recordSheets', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_recordSheets', 1, 'label', 'Record Sheet::::Faamaumauga o fuataga');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_recordSheets', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_surveyPlan', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_surveyPlan', 1, 'label', 'Survey Plan::::Fuataga o Fanua');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_surveyPlan', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_roadCL', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_roadCL', 1, 'label', 'Road Name::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_roadCL', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_road', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_road', 1, 'label', 'Road Name::::Auala');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_road', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_flur', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_flur', 1, 'label', 'Flur Number::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_flur', 2, 'the_geom', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_unit_parcel', 0, 'id', NULL);
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_unit_parcel', 1, 'parcel_nr', 'Parcel number::::Poloka numera');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_unit_parcel', 2, 'unit_parcels', 'Unit Parcels::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_unit_parcel', 3, 'unit_properties', 'Strata Properties::::SAMOAN');
INSERT INTO query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_unit_parcel', 4, 'the_geom', NULL);


ALTER TABLE query_field ENABLE TRIGGER ALL;

--
-- Data for Name: setting; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE setting DISABLE TRIGGER ALL;

INSERT INTO setting (name, vl, active, description) VALUES ('map-tolerance', '0.01', true, 'The tolerance that is used while snapping geometries to each other. If two points are within this distance are considered being in the same location.');
INSERT INTO setting (name, vl, active, description) VALUES ('map-shift-tolerance-rural', '20', true, 'The shift tolerance of boundary points used in cadastre change in rural areas.');
INSERT INTO setting (name, vl, active, description) VALUES ('map-shift-tolerance-urban', '5', true, 'The shift tolerance of boundary points used in cadastre change in urban areas.');
INSERT INTO setting (name, vl, active, description) VALUES ('map-srid', '32702', true, 'The srid of the geographic data that are administered in the system.');
INSERT INTO setting (name, vl, active, description) VALUES ('map-west', '300500', true, 'The most west coordinate. It is used in the map control.');
INSERT INTO setting (name, vl, active, description) VALUES ('map-south', '8439000', true, 'The most south coordinate. It is used in the map control.');
INSERT INTO setting (name, vl, active, description) VALUES ('map-east', '461900', true, 'The most east coordinate. It is used in the map control.');
INSERT INTO setting (name, vl, active, description) VALUES ('map-north', '8518000', true, 'The most north coordinate. It is used in the map control.');
INSERT INTO setting (name, vl, active, description) VALUES ('pword-expiry-days', '90', true, 'The number of days a users password remains valid');


ALTER TABLE setting ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

