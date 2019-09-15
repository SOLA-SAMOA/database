-- Aug 2019
-- Adds new spatial features into SOLA Samoa


-- Layer for Aerial Photography
DELETE FROM system.config_map_layer WHERE name = 'samoa_aerial';
DELETE FROM system.config_map_layer WHERE name = 'samoa_parcels_contrast';
INSERT INTO system.config_map_layer(
	name, title, type_code, active, visible_in_start, item_order, url, wms_layers, wms_version, wms_format)
	VALUES ('samoa_aerial', 'Samoa Aerial::::Samoa Aerial', 'wms', true, false, 2, 'http://localhost:8085/geoserver/sola/wms', 'sola:Samoa', '1.1.1', 'image/jpeg');
	
INSERT INTO system.config_map_layer(
	name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name, pojo_query_name_for_select)
	VALUES ('samoa_parcels_contrast', 'Parcels Contrast::::Poloka', 'pojo', true, false, 31, 'samoa_parcel_contrast.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getParcels', null);



-- * Insert Geodetic Marks and configuration *

/* SELECT 'INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), ''andrew'', ''' ||  marknumber || ''', (SELECT l.id FROM cadastre.level l WHERE l.name = ''Geodetic Marks''), ''' || m.spheroidal || ''', ' || 'ST_SetSRID(ST_GeomFromText(''POINT(' || m.easting || ' ' || m.northing || ')''),32702));'
FROM cadastre."Geodetic Mark_point" m; */ 
	
ALTER TABLE cadastre.spatial_unit ADD COLUMN IF NOT EXISTS extension_val CHARACTER VARYING(50); 
ALTER TABLE cadastre.spatial_unit_historic ADD COLUMN IF NOT EXISTS extension_val CHARACTER VARYING(50); 

DELETE FROM cadastre.spatial_unit WHERE level_id = (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks');
DELETE FROM system.config_map_layer WHERE name = 'geodetic_marks';
DELETE FROM system.query_field WHERE query_name = 'dynamic.informationtool.get_geodetic_marks'; 
DELETE FROM system.map_search_option WHERE query_name = 'map_search.geodetic_mark'; 
DELETE FROM system.query WHERE name = 'SpatialResult.getGeodeticMarks'; 
DELETE FROM system.query WHERE name = 'dynamic.informationtool.get_geodetic_marks'; 
DELETE FROM system.query WHERE name = 'map_search.geodetic_mark'; 
DELETE FROM cadastre.level WHERE name = 'Geodetic Marks'; 

INSERT INTO cadastre.level(id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'Geodetic Marks', 'all', 'point', 'geographicLocator', 'andrew'); 

INSERT INTO system.query (name, sql, description) 
VALUES ('SpatialResult.getGeodeticMarks', 'select su.id, su.label,  st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Geodetic Marks'' and ST_Intersects(su.reference_point, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL); 

INSERT INTO system.query (name, sql, description) 
VALUES ('dynamic.informationtool.get_geodetic_marks', 'select su.id, su.label, st_y(su.reference_point) AS northing, st_x(su.reference_point) AS easting, su.extension_val AS spheroidal, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Geodetic Marks''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);

INSERT INTO system.query (name, sql, description) 
VALUES ('map_search.geodetic_mark', 'SELECT su.id, su.label, st_asewkb(su.reference_point) as the_geom FROM cadastre.spatial_unit su, cadastre.level l WHERE su.level_id = l.id and l."name" = ''Geodetic Marks'' AND compare_strings(#{search_string}, su.label) AND su.reference_point IS NOT NULL', NULL);

INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_geodetic_marks', 0, 'id', null); 
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_geodetic_marks', 1, 'label', 'Mark Number::::Mark Number'); 
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_geodetic_marks', 2, 'northing', 'Northing::::Northing');
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_geodetic_marks', 3, 'easting', 'Easting::::Easting');
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_geodetic_marks', 4, 'spheroidal', 'Spheroidal::::Spheroidal');
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_geodetic_marks', 5, 'the_geom', null);

INSERT INTO system.map_search_option (code, title, query_name, active, min_search_str_len, zoom_in_buffer, description)
VALUES ('GEODETIC_MARK', 'Geodetic Mark::::Geodetic Mark', 'map_search.geodetic_mark', true, 1, 300, null); 

INSERT INTO system.config_map_layer(
	name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name, pojo_query_name_for_select)
	VALUES ('geodetic_marks', 'Geodetic Marks::::Geodetic Marks', 'pojo', true, false, 125, 'samoa_geodetic_mark.xml', 'theGeom:Point,label:""', 'SpatialResult.getGeodeticMarks', 'dynamic.informationtool.get_geodetic_marks');

INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '102', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '47.600', ST_SetSRID(ST_GeomFromText('POINT(391976.820 8470604.922)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '103', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.567', ST_SetSRID(ST_GeomFromText('POINT(404078.796 8473966.186)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '104', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '76.875', ST_SetSRID(ST_GeomFromText('POINT(420202.883 8468827.340)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '105', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.125', ST_SetSRID(ST_GeomFromText('POINT(430894.165 8466221.762)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '106', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '61.526', ST_SetSRID(ST_GeomFromText('POINT(441344.934 8447425.951)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '107', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '578.115', ST_SetSRID(ST_GeomFromText('POINT(416153.615 8463579.009)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '108', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '41.033', ST_SetSRID(ST_GeomFromText('POINT(390516.934 8461623.172)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '109', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '67.667', ST_SetSRID(ST_GeomFromText('POINT(363645.422 8480421.292)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '110', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '45.266', ST_SetSRID(ST_GeomFromText('POINT(352344.558 8476970.680)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '111', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.381', ST_SetSRID(ST_GeomFromText('POINT(323065.752 8505813.451)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '112', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '257.669', ST_SetSRID(ST_GeomFromText('POINT(335557.520 8502669.924)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '113', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.480', ST_SetSRID(ST_GeomFromText('POINT(368910.133 8497476.262)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '114', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.514', ST_SetSRID(ST_GeomFromText('POINT(304803.003 8505203.036)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '115', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '41.113', ST_SetSRID(ST_GeomFromText('POINT(408503.795 8474220.900)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '116', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '134.063', ST_SetSRID(ST_GeomFromText('POINT(408981.785 8469862.951)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '117', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '116.607', ST_SetSRID(ST_GeomFromText('POINT(411473.266 8470870.976)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '118', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '82.482', ST_SetSRID(ST_GeomFromText('POINT(414505.160 8467441.402)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '119', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '245.385', ST_SetSRID(ST_GeomFromText('POINT(417749.738 8466504.504)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '120', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '61.371', ST_SetSRID(ST_GeomFromText('POINT(421625.600 8468299.127)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '121', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.965', ST_SetSRID(ST_GeomFromText('POINT(418460.664 8471116.612)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '122', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '77.411', ST_SetSRID(ST_GeomFromText('POINT(420413.445 8468699.455)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '123', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '68.048', ST_SetSRID(ST_GeomFromText('POINT(419762.486 8468941.361)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '124', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '75.139', ST_SetSRID(ST_GeomFromText('POINT(420179.069 8468827.106)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '125', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '38.485', ST_SetSRID(ST_GeomFromText('POINT(419192.983 8470705.453)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '126', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '38.639', ST_SetSRID(ST_GeomFromText('POINT(418994.476 8470891.854)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '127', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.110', ST_SetSRID(ST_GeomFromText('POINT(418824.568 8471024.236)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '128', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.429', ST_SetSRID(ST_GeomFromText('POINT(417768.695 8471235.662)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '129', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.310', ST_SetSRID(ST_GeomFromText('POINT(417643.466 8471364.525)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '130', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.278', ST_SetSRID(ST_GeomFromText('POINT(417724.834 8471312.754)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '131', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '41.510', ST_SetSRID(ST_GeomFromText('POINT(417863.826 8470794.165)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '132', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '41.544', ST_SetSRID(ST_GeomFromText('POINT(417822.472 8470738.505)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '133', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.248', ST_SetSRID(ST_GeomFromText('POINT(416942.235 8470888.195)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '134', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.077', ST_SetSRID(ST_GeomFromText('POINT(416165.735 8471830.377)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '135', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.211', ST_SetSRID(ST_GeomFromText('POINT(416132.787 8471879.440)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '136', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.607', ST_SetSRID(ST_GeomFromText('POINT(416517.592 8470844.351)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '137', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.767', ST_SetSRID(ST_GeomFromText('POINT(416430.889 8470367.844)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '138', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.428', ST_SetSRID(ST_GeomFromText('POINT(416367.905 8470245.689)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '139', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.264', ST_SetSRID(ST_GeomFromText('POINT(416792.879 8470231.142)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '140', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '44.447', ST_SetSRID(ST_GeomFromText('POINT(368353.383 8480178.874)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '39', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '38.799', ST_SetSRID(ST_GeomFromText('POINT(415611.357 8472633.508)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '4', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.168', ST_SetSRID(ST_GeomFromText('POINT(384019.203 8466834.504)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '42', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '48.245', ST_SetSRID(ST_GeomFromText('POINT(419516.927 8447143.483)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '51', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '39.300', ST_SetSRID(ST_GeomFromText('POINT(400906.363 8451624.794)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '55', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '38.885', ST_SetSRID(ST_GeomFromText('POINT(429407.623 8447329.444)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '6', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '50.270', ST_SetSRID(ST_GeomFromText('POINT(453110.241 8446830.462)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '60', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '48.520', ST_SetSRID(ST_GeomFromText('POINT(441855.047 8461785.250)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '72', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '42.361', ST_SetSRID(ST_GeomFromText('POINT(313868.608 8495746.783)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '74', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '43.313', ST_SetSRID(ST_GeomFromText('POINT(323339.385 8486588.719)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '89', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '38.342', ST_SetSRID(ST_GeomFromText('POINT(346948.755 8512663.819)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '90', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '40.248', ST_SetSRID(ST_GeomFromText('POINT(370649.928 8482714.032)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '93', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '47.092', ST_SetSRID(ST_GeomFromText('POINT(363111.461 8506231.521)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', '98', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Geodetic Marks'), '42.931', ST_SetSRID(ST_GeomFromText('POINT(335976.833 8473675.585)'),32702));



-- * Traverse Marks and configuration *

DELETE FROM cadastre.spatial_unit WHERE level_id = (SELECT l.id FROM cadastre.level l WHERE l.name = 'Traverse Marks');
DELETE FROM system.config_map_layer WHERE name = 'traverse_marks';
DELETE FROM system.query_field WHERE query_name = 'dynamic.informationtool.get_traverse_marks';  
DELETE FROM system.query WHERE name = 'SpatialResult.getTraverseMarks'; 
DELETE FROM system.query WHERE name = 'dynamic.informationtool.get_traverse_marks'; 
DELETE FROM cadastre.level WHERE name = 'Traverse Marks'; 

INSERT INTO cadastre.level(id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'Traverse Marks', 'all', 'point', 'geographicLocator', 'andrew'); 

INSERT INTO system.query (name, sql, description) 
VALUES ('SpatialResult.getTraverseMarks', 'select su.id, su.label,  st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Traverse Marks'' and ST_Intersects(su.reference_point, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL); 

INSERT INTO system.query (name, sql, description) 
VALUES ('dynamic.informationtool.get_traverse_marks', 'select su.id, su.label, st_y(su.reference_point) AS northing, st_x(su.reference_point) AS easting, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Traverse Marks''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);

INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_traverse_marks', 0, 'id', null); 
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_traverse_marks', 1, 'label', 'Mark Number::::Mark Number'); 
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_traverse_marks', 2, 'northing', 'Northing::::Northing');
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_traverse_marks', 3, 'easting', 'Easting::::Easting');
INSERT INTO system.query_field (query_name, index_in_query, name, display_value) VALUES ('dynamic.informationtool.get_traverse_marks', 4, 'the_geom', null);


INSERT INTO system.config_map_layer(
	name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name, pojo_query_name_for_select)
	VALUES ('traverse_marks', 'Traverse Marks::::Traverse Marks', 'pojo', true, false, 124, 'samoa_traverse_mark.xml', 'theGeom:Point,label:""', 'SpatialResult.getTraverseMarks', 'dynamic.informationtool.get_traverse_marks');
	
/*	
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', 'VII DP 10200', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Traverse Marks'), '47.092', ST_SetSRID(ST_GeomFromText('POINT(335946.833 8473695.585)'),32702));
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, reference_point) VALUES (uuid_generate_v1(), 'andrew', 'IX DP 10200', (SELECT l.id FROM cadastre.level l WHERE l.name = 'Traverse Marks'), '42.931', ST_SetSRID(ST_GeomFromText('POINT(335966.833 8473665.585)'),32702));
*/


-- * District Boundries and configuration *

DELETE FROM cadastre.spatial_unit WHERE level_id = (SELECT l.id FROM cadastre.level l WHERE l.name = 'District Boundary');
DELETE FROM system.config_map_layer WHERE name = 'district_boundary';  
DELETE FROM system.query WHERE name = 'SpatialResult.getDistrictBoundary'; 
DELETE FROM cadastre.level WHERE name = 'District Boundary'; 

INSERT INTO cadastre.level(id, name, register_type_code, structure_code, type_code, change_user)
	VALUES (uuid_generate_v1(), 'District Boundary', 'all', 'unStructuredLine', 'geographicLocator', 'andrew'); 

INSERT INTO system.query (name, sql, description) 
VALUES ('SpatialResult.getDistrictBoundary', 'select su.id, su.label,  st_asewkb(su.geom) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''District Boundary'' and ST_Intersects(su.geom, ST_SetSRID(ST_MakeBox3D(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))', NULL); 

INSERT INTO system.config_map_layer(
	name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name, pojo_query_name_for_select)
	VALUES ('district_boundary', 'District Boundary::::District Boundary', 'pojo', true, false, 85, 'samoa_district_boundary.xml', 'theGeom:LineString,label:""', 'SpatialResult.getDistrictBoundary', null);

/*
INSERT INTO cadastre.spatial_unit (id, change_user, label, level_id, extension_val, geom) SELECT uuid_generate_v1(), 'andrew', 'Example', (SELECT l.id FROM cadastre.level l WHERE l.name = 'District Boundary'), null, su.geom FROM cadastre.spatial_unit su WHERE su.label = 'VUI ROAD'; 
*/
