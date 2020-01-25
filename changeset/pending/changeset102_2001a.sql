-- Aug 2019
-- Adds new spatial features into SOLA Samoa


-- Layer for Aerial Photography
DELETE FROM system.config_map_layer WHERE name = 'samoa_aerial';
DELETE FROM system.config_map_layer WHERE name = 'samoa_parcels_contrast';

/*INSERT INTO system.config_map_layer(
	name, title, type_code, active, visible_in_start, item_order, url, wms_layers, wms_version, wms_format)
	VALUES ('samoa_aerial', 'Samoa Aerial::::Samoa Aerial', 'wms', true, false, 2, 'http://localhost:8085/geoserver/sola/wms', 'sola:Samoa', '1.1.1', 'image/jpeg');*/
	
INSERT INTO system.config_map_layer(
	name, title, type_code, active, visible_in_start, item_order, url, wms_layers, wms_version, wms_format)
	VALUES ('samoa_aerial', 'Samoa Aerial::::Samoa Aerial', 'wms', true, false, 2, 'http://10.20.1.10:8085/geoserver/Samoa_2015_aerial_photos/wms', 'Samoa_2015_aerial_photos:Samoa_2015_aerial_photography_0.2m_per_pixel', '1.1.1', 'image/jpeg');
	
INSERT INTO system.config_map_layer(
	name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name, pojo_query_name_for_select)
	VALUES ('samoa_parcels_contrast', 'Parcels Contrast::::Poloka', 'pojo', true, false, 31, 'samoa_parcel_contrast.xml', 'theGeom:Polygon,label:""', 'SpatialResult.getParcels', null);
	
	
INSERT INTO system.appgroup (id, name, description)
SELECT uuid_generate_v1(), 'View Aerial Photos', 'Allows users to view the Samoa 2015 Aerial Photos as a map layer in SOLA'
WHERE NOT EXISTS (SELECT 1 FROM system.appgroup WHERE name = 'View Aerial Photos');

INSERT INTO system.approle (code, display_value, description, status)
SELECT 'ViewAerialPhotos', 'View Aerial Photos', 'Allows users to view the Samoa 2015 Aerial Photos as a map layer in SOLA', 'c'
WHERE  NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ViewAerialPhotos');  

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r 
 WHERE g."name" = 'View Aerial Photos'
 AND   r.code IN ('ViewAerialPhotos' )
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
				   WHERE r.code = approle_code AND appgroup_id = g.id));	



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
VALUES ('dynamic.informationtool.get_geodetic_marks', 'select su.id, su.label, ROUND(st_y(su.reference_point)::NUMERIC, 3) AS northing, ROUND(st_x(su.reference_point)::NUMERIC, 3) AS easting, su.extension_val AS spheroidal, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Geodetic Marks''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);

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
VALUES ('dynamic.informationtool.get_traverse_marks', 'select su.id, su.label, ROUND(st_y(su.reference_point)::NUMERIC, 3) AS northing, ROUND(st_x(su.reference_point)::NUMERIC, 3) AS easting, st_asewkb(su.reference_point) as the_geom from cadastre.spatial_unit su, cadastre.level l where su.level_id = l.id and l."name" = ''Traverse Marks''  and ST_Intersects(su.reference_point, ST_SetSRID(ST_GeomFromWKB(#{wkb_geom}), #{srid}))', NULL);

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



-- ****  Public Counter DB Changes **** --

UPDATE system.appgroup SET name = 'Staff Public Counter'
WHERE name = 'Public Counter'
AND NOT EXISTS (SELECT 1 FROM system.appgroup WHERE name = 'Staff Public Counter');

INSERT INTO system.appgroup (id, name, description)
SELECT uuid_generate_v1(), 'Public Users', 'Allows public users to view the map, search for survey documents and print the map and documents'
WHERE NOT EXISTS (SELECT 1 FROM system.appgroup WHERE name = 'Public Users');

INSERT INTO system.approle (code, display_value, description, status)
SELECT 'PublicOnly', 'Public Only', 'Only allow the user to access public documentation and information such as public documents (e.g. survey plans) and map information', 'c'
WHERE  NOT EXISTS (SELECT code FROM system.approle WHERE code = 'PublicOnly');  

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r 
 WHERE g."name" = 'Public Users'
 AND   r.code IN ('ViewMap', 'PrintMap', 'SourceSearch', 'SourcePrint', 'ChangePassword', 'ManageUserPassword', 'ViewSource', 
   'MeasureTool', 'PublicOnly' )
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
				   WHERE r.code = approle_code AND appgroup_id = g.id));
				   
/*
INSERT INTO system.appuser(
	id, username, first_name, last_name, passwd, active, change_user)
	VALUES (uuid_generate_v1(), 'public1', 'Public', 'One', 'fc093c6f48bcdad5ddd7964faff3a41c51b337a4824301b96c4d3b293b590c30', true, 'andrew');
	
UPDATE system.appuser set passwd = 'fc093c6f48bcdad5ddd7964faff3a41c51b337a4824301b96c4d3b293b590c30' where username = 'public1'; 

INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id) 
(SELECT u.id, g.id FROM system.appgroup g, system.appuser u 
 WHERE g."name" = 'Public Counter'
 AND   u.username = 'public1'
 AND   NOT EXISTS (SELECT appgroup_id FROM system.appuser_appgroup ag
				   WHERE ag.appuser_id = u.id AND ag.appgroup_id = g.id));	
	
*/

ALTER TABLE source.administrative_source_type ADD COLUMN IF NOT EXISTS public_access CHARACTER VARYING(50); 

UPDATE source.administrative_source_type SET public_access = 'DENY'; 	
UPDATE source.administrative_source_type SET public_access = 'ALLOW' 
WHERE code in ('cadastralSurvey', 'circuitPlan', 'coastalPlan', 'flurPlan', 'recordMaps', 'schemePlan', 'titlePlan', 'unitEntitlements', 'unitPlan', 'traverse', 'surveyDataFile');	
	

CREATE OR REPLACE FUNCTION source.getpublicaccess(
	source_id character varying)
    RETURNS character varying
	LANGUAGE 'plpgsql'
AS $BODY$
  BEGIN
    RETURN (SELECT t.public_access
	         FROM source.administrative_source_type t,
			      source.source s
		     WHERE s.id = source_id
			 AND   t.code = s.type_code);   
  END; $BODY$;

COMMENT ON FUNCTION source.getpublicaccess(character varying)
    IS 'Returns the public access status for a given source record'; 
	

	
DROP TABLE IF EXISTS system.public_user_activity;
DROP TABLE IF EXISTS system.public_user_activity_type;  

CREATE TABLE system.public_user_activity_type
(
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL,
    CONSTRAINT public_user_activity_type_pkey PRIMARY KEY (code),
    CONSTRAINT public_user_activity_type_display_value_unique UNIQUE (display_value)

);

COMMENT ON TABLE system.public_user_activity_type
    IS 'The types of activity a public user may undertake when logged into SOLA.';
	
INSERT INTO system.public_user_activity_type (code, display_value, status) VALUES ('login', 'Login', 'c');
INSERT INTO system.public_user_activity_type (code, display_value, status) VALUES ('docPrint', 'Print Document', 'c');
INSERT INTO system.public_user_activity_type (code, display_value, status) VALUES ('docView', 'View Document', 'c');
INSERT INTO system.public_user_activity_type (code, display_value, status) VALUES ('mapPrint', 'Map Print', 'c');
	
CREATE TABLE system.public_user_activity
(
    id character varying(40) NOT NULL,
    activity_time timestamp with time zone NOT NULL DEFAULT now(),  
    activity_type character varying(20) NOT NULL,	
	receipt_number character varying(100),
    comment character varying(500),
	public_user character varying(40) NOT NULL,
    CONSTRAINT public_access_pkey PRIMARY KEY (id),
	CONSTRAINT public_user_activity_activity_type FOREIGN KEY (activity_type)
        REFERENCES system.public_user_activity_type (code) MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


COMMENT ON TABLE system.public_user_activity
    IS 'Tracks specific activities performed by a public user. ';

COMMENT ON COLUMN system.public_user_activity.id
    IS 'Identifier for the public_user_activity table ';

COMMENT ON COLUMN system.public_user_activity.activity_time
    IS 'The time the activity occurred. ';
	
COMMENT ON COLUMN system.public_user_activity.activity_type
    IS 'The type of activity performed by the public user. e.g. Login, Map Print, Document Print. ';

COMMENT ON COLUMN system.public_user_activity.receipt_number
    IS 'The receipt_number the user has for this session';

COMMENT ON COLUMN system.public_user_activity.comment
    IS 'Comment from user. Not used in initial version of functionality. ';

COMMENT ON COLUMN system.public_user_activity.public_user
    IS 'The public user that triggered the activity. ';
	
CREATE INDEX public_user_activity_activity_type_ind
    ON system.public_user_activity USING btree
    (activity_type);
	
CREATE INDEX public_user_activity_public_user_ind
    ON system.public_user_activity USING btree
    (public_user);
	
CREATE INDEX public_user_activity_activity_time_ind
    ON system.public_user_activity USING btree
    (activity_time);
	

-- Public User Activity Daily Summary Report --

INSERT INTO system.approle (code, display_value, description, status)
SELECT 'PublicActivityRpt', 'Pubilc Activity Report', 'Allows user to run the Public User Activity Daily Summary Report', 'c'
WHERE  NOT EXISTS (SELECT code FROM system.approle WHERE code = 'PublicActivityRpt');  

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r 
 WHERE g."name" IN ( 'Staff Public Counter', 'Team Leader') 
 AND   r.code IN ('PublicActivityRpt')
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
				   WHERE r.code = approle_code AND appgroup_id = g.id));


CREATE OR REPLACE FUNCTION system.public_user_activity_daily_summary(
	from_date date,
	to_date date,
	the_user VARCHAR (40))
    RETURNS TABLE(public_user VARCHAR (40), pub_user_name VARCHAR(255), activity_day DATE, receipt_num VARCHAR(100), login_num INTEGER, map_print_num INTEGER, map_print_comments VARCHAR(255), doc_view_num INTEGER, doc_view_comments VARCHAR(255), doc_print_num INTEGER, doc_print_comments VARCHAR(255),
	max_activity_time TIMESTAMP WITH TIME ZONE, min_activity_time TIMESTAMP WITH TIME ZONE) 
	LANGUAGE 'plpgsql'
	
AS $BODY$
DECLARE 
   tmp_date DATE; 
BEGIN

   -- If no from date provided, set it to 5 days before the to_date, 
   -- or 5 days before today if to_date is null
   IF from_date IS NULL THEN
      IF to_date IS NOT NULL THEN
        from_date := to_date - 5; 
	  ELSE
		from_date := current_date - 5;
	  END IF; 
   END IF; 
   
   -- If to_date is null, set it to today. 
   IF to_date IS NULL THEN
      to_date := current_date; 
   END IF; 

   -- Swap the dates so the to date is after the from date
   IF to_date < from_date THEN 
      tmp_date := from_date; 
      from_date := to_date; 
      to_date := tmp_date; 
   END IF; 

   RETURN query 
   
    -- Create a temporary subset of records for subsequent processing based on the function parameters.
	-- Truncate the activity time so that data is summarised per 24hr period for each user and receipt_num combination
    WITH activity_subset AS 
         (SELECT pua.public_user, date_trunc('day', pua.activity_time at time zone 'Pacific/Apia') AS activity_day, pua.activity_type, pua.receipt_number AS receipt_num, pua.comment, COALESCE(usr.first_name || ' ', '') || COALESCE(usr.last_name, '') AS pub_user_name, pua.activity_time
          FROM system.public_user_activity pua, 
		       system.appuser usr
          WHERE pua.activity_time BETWEEN from_date AND to_date 
		  AND COALESCE(the_user, pua.public_user) = pua.public_user
		  AND usr.username = pua.public_user)
   -- MAIN QUERY                         
   SELECT sub.public_user::VARCHAR(40),
          sub.pub_user_name::VARCHAR(255),   
          sub.activity_day::DATE, 
		  sub.receipt_num::VARCHAR(100), 
		  SUM(CASE sub.activity_type WHEN 'login' THEN 1 ELSE 0 END)::INTEGER AS login_num,
		  SUM(CASE sub.activity_type WHEN 'mapPrint' THEN 1 ELSE 0 END)::INTEGER AS map_print_num,
		  string_agg((CASE sub.activity_type WHEN 'mapPrint' THEN sub.comment ELSE NULL END)::VARCHAR(100), ', ')::VARCHAR(255) AS map_print_comments,
		  SUM(CASE sub.activity_type WHEN 'docView' THEN 1 ELSE 0 END)::INTEGER AS doc_view_num,
		  string_agg((CASE sub.activity_type WHEN 'docView' THEN sub.comment ELSE NULL END)::VARCHAR(100), ', ')::VARCHAR(255) AS doc_view_comments,
		  SUM(CASE sub.activity_type WHEN 'docPrint' THEN 1 ELSE 0 END)::INTEGER AS doc_print_num,
		  string_agg((CASE sub.activity_type WHEN 'docPrint' THEN sub.comment ELSE NULL END)::VARCHAR(100), ', ')::VARCHAR(255) AS doc_print_comments,
		  MAX(sub.activity_time)::TIMESTAMP WITH TIME ZONE AS max_activity_time,
		  MIN(sub.activity_time)::TIMESTAMP WITH TIME ZONE AS min_activity_time
    FROM  activity_subset sub
	GROUP BY sub.public_user, sub.pub_user_name, sub.activity_day, sub.receipt_num
	ORDER BY min_activity_time ASC, sub.public_user, sub.receipt_num; 
 
	
   END; $BODY$;

COMMENT ON FUNCTION system.public_user_activity_daily_summary(DATE, DATE, VARCHAR(40))
    IS 'Returns a daily summary of public user activities. The default settings will report all user activity over the last 5 days. Used by the Public User Activity Report.';




-- ****  CoT Report **** --

CREATE OR REPLACE FUNCTION administrative.show_cot_report(
	p_ba_unit_id character varying,
	p_is_production boolean,
	p_user_name character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'

AS $BODY$

DECLARE 
   v_cot_date DATE := '02-MAR-2021';
   v_bypass boolean := TRUE; -- The bypass will force the CFC to be produced until such time as the cutover date to CoT's is agreeded. 
BEGIN

  -- This is the training system, so allow certain users to view the CoT report
  IF p_user_name = 'andrew' AND NOT p_is_production THEN RETURN TRUE; END IF;
  
  -- Allow a date independent bypass to avoid the CoT from being displayed
  IF v_bypass THEN RETURN FALSE; END IF;
  
  -- Check if there has been dealing registered on the title after the CoT cutover date. 
  IF EXISTS (SELECT r.id
             FROM  administrative.rrr r,
			       transaction.transaction t, 
				   application.service s
		     WHERE r.ba_unit_id = p_ba_unit_id
			 AND   r.registration_date >= v_cot_date
			 AND   t.id = r.transaction_id
			 AND   s.id = t.from_service_id
			 AND   s.request_type_code NOT IN ('registrarCancel', 'registrarCorrection')) THEN RETURN TRUE; END IF; 

  RETURN FALSE;
END
$BODY$;

COMMENT ON FUNCTION administrative.show_cot_report(character varying, boolean, character varying)
    IS 'Checks the ba_unit to determine if the Certificate of Title report should be displayed or not';
	
	
  


-- Make Deed Current

INSERT INTO system.approle (code, display_value, description, status)
SELECT 'MakePropCurrent', 'Make Property Current', 'Allows a team leader to update the status of a deed or property from Historic to Current', 'c'
WHERE  NOT EXISTS (SELECT code FROM system.approle WHERE code = 'MakePropCurrent');  

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
(SELECT r.code, g.id FROM system.appgroup g, system.approle  r 
 WHERE g."name" IN ('Team Leader') 
 AND   r.code IN ('MakePropCurrent')
 AND   NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
				   WHERE r.code = approle_code AND appgroup_id = g.id));  
