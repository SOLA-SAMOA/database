-- 4 Mar 2012

-- Update Training, test the deployment, then update Production. 
-- Update Glassfish Keystore certificates by copying cacerts.jks and keystore.jks
-- From Dropbox\Keystores folder to the config directory of the Glassfish SOLA 
-- Domain. Run the asadmin change-master-password subcommand and set the 
-- new Glassfish Master Password to match the storepass in 
-- Dropbox\Keystores\settings.xml file. 
-- <Glassfish Install Dir>\bin\asadmin change-master-password --savemasterpassword=true --domaindir <SOLA Glassfish Domain Dir>

-- #89 Updated Map Find by Parcel Number to match functionality of Parcel Search
UPDATE system.query SET sql = 
'SELECT id, cadastre.formatParcelNr(name_firstpart, name_lastpart) as label, st_asewkb(geom_polygon) as the_geom  
 FROM cadastre.cadastre_object  
 WHERE status_code= ''current'' 
 AND geom_polygon IS NOT NULL 
 AND compare_strings(#{search_string}, name_firstpart || '' PLAN '' || name_lastpart) 
 ORDER BY lpad(regexp_replace(name_firstpart, ''\\D*'', '''', ''g''), 5, ''0'') || name_firstpart || name_lastpart
 LIMIT 30'
 WHERE "name" = 'map_search.cadastre_object_by_number';


