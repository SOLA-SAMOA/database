-- Changeset to reapply all Spatial Views so they are correct registered in PostGIS and can be
-- served from Geoserver as WFS layers. You must explicitly cast to the appropirate geometry
-- type for it to be registred correctly. 
-- Note that you must indicate the identifier in Geoserver when creating the corresponding layer. 

DROP VIEW IF EXISTS cadastre.court_grants;
CREATE VIEW cadastre.court_grants AS
 SELECT su.id,
    su.label,
    su.reference_point::geometry(Point, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Court Grants'::text));

DROP VIEW IF EXISTS cadastre.current_parcels; 
CREATE VIEW cadastre.current_parcels AS
 SELECT co.id,
    cadastre.formatParcelNrLabel(co.name_firstpart, co.name_lastpart) AS label,
    co.geom_polygon::geometry(Polygon, 32702) AS "theGeom"
   FROM cadastre.cadastre_object co
  WHERE (((co.type_code)::text = 'parcel'::text) AND ((co.status_code)::text = 'current'::text));
 
DROP VIEW IF EXISTS cadastre.pending_parcels; 
CREATE VIEW cadastre.pending_parcels AS
 SELECT co.id,
    cadastre.formatParcelNrLabel(co.name_firstpart, co.name_lastpart) AS label,
    co.geom_polygon::geometry(Polygon, 32702) AS "theGeom"
   FROM cadastre.cadastre_object co
  WHERE (((co.type_code)::text = 'parcel'::text) AND ((co.status_code)::text = 'pending'::text)); 
 
 
DROP VIEW IF EXISTS cadastre.geodetic_marks; 
CREATE VIEW cadastre.geodetic_marks AS
 SELECT su.id,
    su.label,
    su.reference_point::geometry(Point, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Geodetic Marks'::text));
   
  
DROP VIEW IF EXISTS cadastre.district_boundary; 
CREATE VIEW cadastre.district_boundary AS
 SELECT su.id,
    su.label,
    su.geom::geometry(Linestring, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'District Boundary'::text));
 
DROP VIEW IF EXISTS cadastre.districts; 
CREATE VIEW cadastre.districts AS
 SELECT su.id,
    su.label,
    su.reference_point::geometry(Point, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Districts'::text));
 
DROP VIEW IF EXISTS cadastre.flur; 
CREATE VIEW cadastre.flur AS
 SELECT su.id,
    su.label,
    su.geom::geometry(Polygon, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Flur'::text));
  
DROP VIEW IF EXISTS cadastre.hydro_features; 
CREATE VIEW cadastre.hydro_features AS
 SELECT su.id,
    su.label,
    su.geom::geometry(Polygon, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Hydro Features'::text));
  
DROP VIEW IF EXISTS cadastre.islands; 
CREATE VIEW cadastre.islands AS
 SELECT su.id,
    su.label,
    su.reference_point::geometry(Point, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Islands'::text));
  
DROP VIEW IF EXISTS cadastre.record_sheets; 
CREATE VIEW cadastre.record_sheets AS
 SELECT su.id,
    su.label,
    su.geom::geometry(Polygon, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Record Sheets'::text));

DROP VIEW IF EXISTS cadastre.road_centerlines; 
CREATE VIEW cadastre.road_centerlines AS
 SELECT su.id,
    su.label,
    su.geom::geometry(Linestring, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Road Centerlines'::text));  

DROP VIEW IF EXISTS cadastre.roads; 
CREATE VIEW cadastre.roads AS
 SELECT su.id,
    su.label,
    su.geom::geometry(Polygon, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Roads'::text));

  DROP VIEW IF EXISTS cadastre.survey_plans; 
  CREATE VIEW cadastre.survey_plans AS
 SELECT su.id,
    su.label,
    su.reference_point::geometry(Point, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Survey Plans'::text));
  
  DROP VIEW IF EXISTS cadastre.unit_parcels; 
  CREATE VIEW cadastre.unit_parcels AS 
 SELECT co.id, cadastre.formatParcelNrLabel(co.name_firstpart, co.name_lastpart) AS label, 
 co.geom_polygon::geometry(Polygon, 32702) AS "theGeom"
   FROM cadastre.cadastre_object co, cadastre.spatial_unit_in_group sug
  WHERE sug.spatial_unit_id = co.id AND co.type_code = 'parcel' AND co.status_code = 'current' 
  AND co.geom_polygon IS NOT NULL AND sug.unit_parcel_status_code = 'current';
  
    DROP VIEW IF EXISTS cadastre.villages; 
	CREATE VIEW cadastre.villages AS
 SELECT su.id,
    su.label,
    su.reference_point::geometry(Point, 32702) AS "theGeom"
   FROM cadastre.spatial_unit su,
    cadastre.level l
  WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Villages'::text));
  
  
 DROP VIEW IF EXISTS cadastre.traverse_marks; 
 
 CREATE VIEW cadastre.traverse_marks AS
 SELECT su.id,
    su.label,
    su.reference_point::geometry(Point, 32702) AS "theGeom"
 FROM cadastre.spatial_unit su,
    cadastre.level l
 WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Traverse Marks'::text));
  
 GRANT SELECT ON cadastre.traverse_marks TO mnre_geoserver;
  
  -- Setup a user with access to the geospatial views
 DROP USER IF EXISTS mnre_geoserver; 
 CREATE USER mnre_geoserver WITH PASSWORD 'xxx'; 
 GRANT CONNECT ON DATABASE sola_prod TO mnre_geoserver;
 GRANT USAGE ON SCHEMA cadastre TO mnre_geoserver;
 GRANT SELECT ON public.geometry_columns TO mnre_geoserver;
 GRANT SELECT ON cadastre.court_grants TO mnre_geoserver;
 GRANT SELECT ON cadastre.current_parcels TO mnre_geoserver;
 GRANT SELECT ON cadastre.pending_parcels TO mnre_geoserver;
 GRANT SELECT ON cadastre.district_boundary TO mnre_geoserver;
 GRANT SELECT ON cadastre.districts TO mnre_geoserver;
 GRANT SELECT ON cadastre.flur TO mnre_geoserver;
 GRANT SELECT ON cadastre.geodetic_marks TO mnre_geoserver;
 GRANT SELECT ON cadastre.hydro_features TO mnre_geoserver;
 GRANT SELECT ON cadastre.islands TO mnre_geoserver;
 GRANT SELECT ON cadastre.record_sheets TO mnre_geoserver;
 GRANT SELECT ON cadastre.road_centerlines TO mnre_geoserver;
 GRANT SELECT ON cadastre.roads TO mnre_geoserver;
 GRANT SELECT ON cadastre.survey_plans TO mnre_geoserver;
 GRANT SELECT ON cadastre.traverse_marks TO mnre_geoserver;
 GRANT SELECT ON cadastre.unit_parcels TO mnre_geoserver;
 GRANT SELECT ON cadastre.villages TO mnre_geoserver;
 
 
 