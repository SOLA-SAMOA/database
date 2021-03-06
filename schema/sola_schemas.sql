--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: address; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA address;


ALTER SCHEMA address OWNER TO postgres;

--
-- Name: SCHEMA address; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA address IS 'Extension to the LADM for capturing postal and physical addresses. Allows SOLA to support integration with external address validation services if required.';


--
-- Name: administrative; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA administrative;


ALTER SCHEMA administrative OWNER TO postgres;

--
-- Name: SCHEMA administrative; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA administrative IS 'The SOLA implementation of the LADM Administrative package. Models land use rights and restrictions how those rights and restrictions relate to property and people.';


--
-- Name: application; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA application;


ALTER SCHEMA application OWNER TO postgres;

--
-- Name: SCHEMA application; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA application IS 'Extension to the LADM used by SOLA to implement Case Management functionality.';


--
-- Name: cadastre; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA cadastre;


ALTER SCHEMA cadastre OWNER TO postgres;

--
-- Name: SCHEMA cadastre; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA cadastre IS 'The SOLA implementation of the LADM Spatial Unit Package. Represents parcels of land and water that can be associated to rights (a.k.a. Cadastre Objects) as well as general spatial or geographic features such as roads, hydro and place names, etc. General spatial features are also known as Spatial Units in SOLA.';


--
-- Name: document; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA document;


ALTER SCHEMA document OWNER TO postgres;

--
-- Name: SCHEMA document; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA document IS 'Extension to the LADM used by SOLA to store electronic copies of documentation provided in support of land related dealings. Allows SOLA to support integration with external Document Management Systems (DMS) if required.';


--
-- Name: party; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA party;


ALTER SCHEMA party OWNER TO postgres;

--
-- Name: SCHEMA party; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA party IS 'The SOLA implementation of the LADM Party package. Represents people and organisations that are associated to land rights and/or land transactions.';


--
-- Name: source; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA source;


ALTER SCHEMA source OWNER TO postgres;

--
-- Name: SCHEMA source; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA source IS 'The SOLA implementation of the LADM LA_Source class. Represents metadata about documents provided to support land related dealings.';


--
-- Name: system; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA system;


ALTER SCHEMA system OWNER TO postgres;

--
-- Name: SCHEMA system; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA system IS 'Extension to the LADM that contains SOLA system configuration, business rules and user details.';


--
-- Name: transaction; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA transaction;


ALTER SCHEMA transaction OWNER TO postgres;

--
-- Name: SCHEMA transaction; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA transaction IS 'Extension to the LADM used by SOLA to track all changes made to data as a result of an application service.';


SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit_name_is_valid(character varying, character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION ba_unit_name_is_valid(name_firstpart character varying, name_lastpart character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
  if name_firstpart is null then return false; end if;
  if name_lastpart is null then return false; end if;
  if name_firstpart not like 'N%' then return false; end if;
  if name_lastpart not similar to '[0-9]+' then return false; end if;
  return true;
end;
$$;


ALTER FUNCTION administrative.ba_unit_name_is_valid(name_firstpart character varying, name_lastpart character varying) OWNER TO postgres;

--
-- Name: FUNCTION ba_unit_name_is_valid(name_firstpart character varying, name_lastpart character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION ba_unit_name_is_valid(name_firstpart character varying, name_lastpart character varying) IS 'Checks if the first and last name for a BA Unit match the naming convention used by this SOLA implementation.';


--
-- Name: create_strata_properties(character varying, text[], character varying, character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION create_strata_properties(unit_parcel_group_id character varying, ba_unit_ids text[], trans_id character varying, user_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
   common_prop_id CHARACTER VARYING := NULL; 
   village_id CHARACTER VARYING := NULL;
   app_nr CHARACTER VARYING := NULL;
   estate_type CHARACTER VARYING := NULL;
   pid CHARACTER VARYING := NULL;
   rrr_ids TEXT[];
BEGIN 

    -- Bulk create BA Units for any Principal Units or Common Property that do not already have a BA Unit.  
   INSERT INTO administrative.ba_unit (id, type_code, name, name_firstpart, name_lastpart, transaction_id, change_user)
   SELECT uuid_generate_v1(), 'strataUnit', co.name_firstpart || '/' || co.name_lastpart, 
          co.name_firstpart, co.name_lastpart, trans_id, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code IN ('commonProperty', 'principalUnit')
   AND    NOT EXISTS (SELECT ba.id FROM administrative.ba_unit ba
                      WHERE ba.name_firstpart = co.name_firstpart
                      AND   ba.name_lastpart = co.name_lastpart); 

   -- Bulk create ba_unit_contains_spatial_unit   
   INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
   SELECT ba.id, co.id, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit ba
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code IN ('commonProperty', 'principalUnit')
   AND    ba.name_firstpart = co.name_firstpart
   AND    ba.name_lastpart = co.name_lastpart
   AND    ba.type_code = 'strataUnit'
   AND    NOT EXISTS (SELECT bas.ba_unit_id FROM administrative.ba_unit_contains_spatial_unit bas
                      WHERE bas.ba_unit_id = ba.id
                      AND   bas.spatial_unit_id = co.id); 

   -- Bulk create ba_unit_area
   INSERT INTO administrative.ba_unit_area(id, ba_unit_id, type_code, size, change_user)
   SELECT uuid_generate_v1(), bas.ba_unit_id, 'officialArea', sva.size, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          cadastre.spatial_value_area sva,
          administrative.ba_unit_contains_spatial_unit bas
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code IN ('commonProperty', 'principalUnit')
   AND    sva.spatial_unit_id = co.id
   AND    sva.type_code = 'officialArea'
   AND    bas.spatial_unit_id = co.id
   AND    NOT EXISTS (SELECT bua.id FROM administrative.ba_unit_area bua
                      WHERE bua.ba_unit_id = bas.ba_unit_id
                      AND   bua.type_code = 'officialArea'); 

   -- Find the Common Property Identifier
   SELECT bas.ba_unit_id INTO common_prop_id
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    bas.spatial_unit_id = co.id
   AND    co.type_code = 'commonProperty';

   IF ba_unit_ids IS NOT NULL THEN
      -- Link the Common Property to the underlying property(ies) as the Prior Title
      INSERT INTO administrative.required_relationship_baunit(from_ba_unit_id, to_ba_unit_id, relation_code, change_user)
      SELECT parent.id, common_prop_id, 'priorTitle', user_name
      FROM   administrative.ba_unit parent
      WHERE  parent.id = ANY (ba_unit_ids)
      AND    parent.status_code IN ('current', 'dormant')
      AND    parent.type_code != 'strataUnit'
      AND    NOT EXISTS (SELECT req.from_ba_unit_id FROM administrative.required_relationship_baunit req
                         WHERE req.from_ba_unit_id = parent.id
                         AND   req.to_ba_unit_id = common_prop_id
                         AND   req.relation_code  = 'priorTitle'); 
	END IF;
					  
   -- Determine the village that must be associated with the unit parcels. First check if the
   -- Common Property has a village specified. If so, use that. 
   SELECT village.from_ba_unit_id INTO village_id
   FROM   administrative.required_relationship_baunit village
   WHERE  village.to_ba_unit_id = common_prop_id
   AND    village.relation_code = 'title_Village'
   LIMIT 1;
   
   IF village_id IS NULL THEN
      -- If Common Property does not have a village, try to determine the
	  -- village from the prior titles. 
	  SELECT village.from_ba_unit_id INTO village_id
      FROM   administrative.required_relationship_baunit village,
	         administrative.required_relationship_baunit comm_prop
      WHERE  comm_prop.to_ba_unit_id = common_prop_id
	  AND    comm_prop.relation_code = 'priorTitle'
	  AND    village.to_ba_unit_id = comm_prop.from_ba_unit_id
      AND    village.relation_code = 'title_Village'
      LIMIT 1;
   END IF;
   
   IF village_id IS NOT NULL THEN
      -- Link the unit parcels to the village
      INSERT INTO administrative.required_relationship_baunit(from_ba_unit_id, to_ba_unit_id, relation_code, change_user)
      SELECT village_id, bas.ba_unit_id, 'title_Village', user_name
      FROM   cadastre.spatial_unit_in_group sig,
             cadastre.cadastre_object co,
             administrative.ba_unit_contains_spatial_unit bas
      WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
      AND    co.id = sig.spatial_unit_id
      AND    sig.delete_on_approval = FALSE
      AND    co.type_code IN ('commonProperty', 'principalUnit')
      AND    bas.spatial_unit_id = co.id
      AND    NOT EXISTS (SELECT req.from_ba_unit_id FROM administrative.required_relationship_baunit req
                         WHERE req.from_ba_unit_id = village_id
						 AND   req.to_ba_unit_id = bas.ba_unit_id
                         AND   req.relation_code = 'title_Village'); 
   END IF;

   -- Link the principal units to the common property
   INSERT INTO administrative.required_relationship_baunit(from_ba_unit_id, to_ba_unit_id, relation_code, change_user)
   SELECT common_prop_id, bas.ba_unit_id, 'commonProperty', user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code = 'principalUnit'
   AND    bas.spatial_unit_id = co.id
   AND    NOT EXISTS (SELECT req.from_ba_unit_id  FROM administrative.required_relationship_baunit req
                         WHERE req.from_ba_unit_id = common_prop_id
						 AND   req.to_ba_unit_id = bas.ba_unit_id
                         AND   req.relation_code = 'commonProperty');
						 
   -- Determine application number to use as notation.reference_nr
   SELECT split_part(app.nr, '/', 1) INTO app_nr
   FROM   transaction.transaction t,
		  application.service s,
		  application.application app
   WHERE  t.id = trans_id
   AND    s.id = t.from_service_id
   AND    app.id = s.application_id;
						 
   -- Create the Body Corporate Rules RRR on the Common Property
   INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, transaction_id, change_user)
   SELECT uuid_generate_v1(), common_prop_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          'bodyCorpRules', trans_id, user_name
   WHERE  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = common_prop_id
				      AND   r.type_code = 'bodyCorpRules');
					  
   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 'Body Corporate Rules',
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   administrative.rrr r
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.type_code = 'bodyCorpRules'
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id);

   -- Create Address for Service RRR on the Common Property					  
   INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, transaction_id, change_user)
   SELECT uuid_generate_v1(), common_prop_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          'addressForService', trans_id, user_name
   WHERE  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = common_prop_id
				      AND   r.type_code = 'addressForService');

   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 'Address for Service <address>',
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   administrative.rrr r
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.type_code = 'addressForService'
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id);
					  
   -- Create Unit Entitlement RRRs on the Principal Units. Note that the Unit Entitlement for 
   -- Accessory Units must be added to the Unit Entitlement for the Principal Unit manually    
   INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, transaction_id, change_user)
   SELECT uuid_generate_v1(), bas.ba_unit_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          'unitEntitlement', trans_id, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code = 'principalUnit'
   AND    bas.spatial_unit_id = co.id 
   AND  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = bas.ba_unit_id
				      AND   r.type_code = 'unitEntitlement');

   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 'Unit entitlement <entitlement>',
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas,
		  administrative.rrr r
   WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
   AND    co.id = sig.spatial_unit_id
   AND    sig.delete_on_approval = FALSE
   AND    co.type_code = 'principalUnit'
   AND    bas.spatial_unit_id = co.id 
   AND    r.ba_unit_id = bas.ba_unit_id
   AND    r.type_code = 'unitEntitlement'
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id);
					  
						 
   -- Determine the estate type for the Unit Parcels based on the estate type of the Common Property.
   -- If the estate type for the Common Property is not specified, use the Estate Type from the
   -- underlying properties. 
   SELECT r.type_code INTO estate_type
   FROM   administrative.rrr r
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.is_primary = TRUE
   AND    r.status_code IN ('pending', 'current')
   -- Use Order By to ensure the current RRR is selected in preference to the pending RRR. 
   ORDER BY r.status_code   
   LIMIT 1;	

   IF estate_type IS NULL THEN
	  SELECT r.type_code INTO estate_type
      FROM   administrative.required_relationship_baunit req,
	         administrative.rrr r
      WHERE  req.to_ba_unit_id = common_prop_id
	  AND    req.relation_code = 'priorTitle'
	  AND    r.ba_unit_id = req.from_ba_unit_id
      AND    r.is_primary = TRUE
      AND    r.status_code = 'current'
      LIMIT 1;
   END IF; 

   -- Create the Primary RRR for the Common Property referencing a "Body Corporate" party. 
   INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, is_primary, transaction_id, change_user)
   SELECT uuid_generate_v1(), common_prop_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          estate_type, TRUE, trans_id, user_name
   WHERE  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = common_prop_id
				      AND   r.type_code = estate_type);

   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 'Body Corporate of ' || ba.name_lastpart, 
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   administrative.rrr r,
          administrative.ba_unit ba
   WHERE  ba.id = common_prop_id
   AND    r.ba_unit_id = ba.id
   AND    r.type_code = estate_type
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id); 
					  
   INSERT INTO administrative.rrr_share(id, rrr_id, nominator, denominator, change_user)
   SELECT uuid_generate_v1(), r.id, 1, 1, user_name
   FROM   administrative.rrr r
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.type_code = estate_type
   AND    NOT EXISTS (SELECT s.id FROM administrative.rrr_share s
                      WHERE  s.rrr_id = r.id); 

   SELECT COALESCE((SELECT pfr.party_id 
                    FROM   administrative.rrr r,
					       administrative.party_for_rrr pfr
					WHERE  r.ba_unit_id = common_prop_id
					AND    r.type_code = estate_type
					AND    pfr.rrr_id = r.id), uuid_generate_v1()::VARCHAR(40)) INTO pid;	

   INSERT INTO party.party(id, type_code, name, change_user)
   SELECT pid, 'nonNaturalPerson', 'Body Corporate of ' || 
        (SELECT name_lastpart FROM administrative.ba_unit WHERE id = common_prop_id), user_name
   WHERE  NOT EXISTS (SELECT p.id FROM party.party p
                      WHERE  p.id = pid);
					  
   INSERT INTO administrative.party_for_rrr(rrr_id, party_id, share_id, change_user)
   SELECT r.id, pid, s.id, user_name
   FROM   administrative.rrr r,
          administrative.rrr_share s
   WHERE  r.ba_unit_id = common_prop_id
   AND    r.type_code = estate_type
   AND    s.rrr_id = r.id
   AND    NOT EXISTS (SELECT pfr.rrr_id FROM administrative.party_for_rrr pfr
                      WHERE  pfr.rrr_id = r.id
					  AND    pfr.share_id = s.id
					  AND    pfr.party_id = pid); 
					  
    -- Duplicate the RRRs from the underlying properties onto the new Unit parcels.
    -- Usually this will only be the primary RRR, but may include mortgages and 
    -- caveats if these exist on the underlying properties. 
	
	-- First collect all of the Current RRRs from the underlying property(ies), 
	-- but only pick one primary RRR to use for the primary estate. 
	--
	-- Note that all RRR's on the underlying property(ies) may be historic if the
	-- underlying property is Dormant. In this case, the user will need to manually
	-- create the necessary RRR's on the new Unit Parcel(s). 
	SELECT array_agg(tmp.id) INTO rrr_ids
	FROM (
		SELECT r.id
		FROM   administrative.required_relationship_baunit req,
			   administrative.rrr r
		WHERE  req.to_ba_unit_id = common_prop_id
		AND    req.relation_code = 'priorTitle'
		AND    r.ba_unit_id = req.from_ba_unit_id
		AND    r.is_primary = FALSE
		AND    r.status_code = 'current'
		UNION
		SELECT r.id
		FROM   administrative.required_relationship_baunit req,
			   administrative.rrr r
		WHERE  req.to_ba_unit_id = common_prop_id
		AND    req.relation_code = 'priorTitle'
		AND    r.ba_unit_id = req.from_ba_unit_id
		AND    r.is_primary = TRUE
		AND    r.status_code = 'current'
		AND    r.type_code = estate_type -- Make sure the estate type is consistent with the Common Property
		LIMIT 1) tmp; 
	
	-- Duplicate the RRR's. Requires a new column, source_rrr to ensure RRR's are correctly duplicated. 
    INSERT INTO administrative.rrr(id, ba_unit_id, nr, type_code, is_primary, transaction_id, share,
	            mortgage_amount, mortgage_interest_rate, mortgage_type_code, source_rrr, change_user)
    SELECT uuid_generate_v1(), bas.ba_unit_id, trim(to_char(nextval('administrative.rrr_nr_seq'), '000000')), 
          r_orig.type_code, r_orig.is_primary, trans_id, r_orig.share, r_orig.mortgage_amount, 
		  r_orig.mortgage_interest_rate, r_orig.mortgage_type_code, r_orig.id, user_name
	FROM  cadastre.spatial_unit_in_group sig,
          cadastre.cadastre_object co,
          administrative.ba_unit_contains_spatial_unit bas,
		  administrative.rrr r_orig
    WHERE  sig.spatial_unit_group_id = unit_parcel_group_id
    AND    co.id = sig.spatial_unit_id
    AND    sig.delete_on_approval = FALSE
    AND    co.type_code = 'principalUnit'
    AND    bas.spatial_unit_id = co.id
	AND    r_orig.id = ANY (rrr_ids)
    AND  NOT EXISTS (SELECT r.id FROM administrative.rrr r
                      WHERE r.ba_unit_id = bas.ba_unit_id
				      AND   r.source_rrr = r_orig.id);

   -- Duplicate the notations if they exist, otherwise create an empty notation. 
   INSERT INTO administrative.notation(id, rrr_id, notation_text, reference_nr, transaction_id, change_user)
   SELECT uuid_generate_v1(), r.id, 
          COALESCE((SELECT n_orig.notation_text FROM administrative.notation n_orig WHERE  n_orig.rrr_id = r_orig.id), ''),
          COALESCE(app_nr, trim(to_char(nextval('administrative.notation_reference_nr_seq'), '000000'))), 
          trans_id, user_name
   FROM   administrative.rrr r,
          administrative.rrr r_orig
   WHERE  r_orig.id = ANY (rrr_ids)
   AND    r.source_rrr = r_orig.id
   AND    NOT EXISTS (SELECT n.id FROM administrative.notation n
                      WHERE  n.rrr_id = r.id); 
		
	-- Duplicate the RRR Shares	
   INSERT INTO administrative.rrr_share(id, rrr_id, nominator, denominator, source_rrr_share, change_user)
   SELECT uuid_generate_v1(), r.id, s_orig.nominator, s_orig.denominator, s_orig.id, user_name
   FROM   administrative.rrr r,
          administrative.rrr r_orig,
		  administrative.rrr_share s_orig
   WHERE  r_orig.id = ANY (rrr_ids)
   AND    r.source_rrr = r_orig.id
   AND    s_orig.rrr_id = r_orig.id
   AND    NOT EXISTS (SELECT s.id FROM administrative.rrr_share s
                      WHERE  s.rrr_id = r.id
					  AND    s.source_rrr_share = s_orig.id)
					  
   -- Don't recreate the rrr_share if the user has previously deleted it
   AND    NOT EXISTS (SELECT s.id FROM administrative.rrr_share_historic s
                      WHERE  s.rrr_id = r.id
					  AND    s.source_rrr_share = s_orig.id); 

   -- Link the new RRR's to the original parties. Choose to avoid duplicating the
   -- party record to simplify this query. Also any subsequent change to party
   -- would require a new party record to be created anyway.     
   INSERT INTO administrative.party_for_rrr(rrr_id, party_id, share_id, change_user)
   SELECT DISTINCT r.id, pfr_orig.party_id, s.id, user_name
   FROM   administrative.rrr r,
          administrative.rrr r_orig,
          administrative.rrr_share s,
		  administrative.rrr_share s_orig,
		  administrative.party_for_rrr pfr_orig
   WHERE  r_orig.id = ANY (rrr_ids)
   AND    r.source_rrr = r_orig.id
   AND    s_orig.rrr_id = r_orig.id
   AND    s.source_rrr_share = s_orig.id
   AND    s.rrr_id = r.id
   AND    pfr_orig.rrr_id = r_orig.id
   AND    pfr_orig.share_id = s_orig.id
   AND    NOT EXISTS (SELECT pfr.rrr_id FROM administrative.party_for_rrr pfr
                      WHERE  pfr.rrr_id = r.id
					  AND    pfr.share_id = s.id
					  AND    pfr.party_id = pfr_orig.party_id)
					  
   -- Don't create the pfr if the user has previously deleted it. 				  
   AND    NOT EXISTS (SELECT pfr.rrr_id FROM administrative.party_for_rrr_historic pfr
                      WHERE  pfr.rrr_id = r.id
					  AND    pfr.share_id = s.id
					  AND    pfr.party_id = pfr_orig.party_id); 					  
					  
	-- Update the transaction table to reference this unit parcel group
	UPDATE transaction.transaction
	SET spatial_unit_group_id = unit_parcel_group_id,
	    change_user = user_name
	WHERE id = trans_id;   
	
   END; $$;


ALTER FUNCTION administrative.create_strata_properties(unit_parcel_group_id character varying, ba_unit_ids text[], trans_id character varying, user_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION create_strata_properties(unit_parcel_group_id character varying, ba_unit_ids text[], trans_id character varying, user_name character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION create_strata_properties(unit_parcel_group_id character varying, ba_unit_ids text[], trans_id character varying, user_name character varying) IS 'Creates the Strata Properties based on the Unit Development Parcel Group. Can be used to create new properties if the list of unit parcels is modified.';


--
-- Name: f_for_tbl_rrr_trg_change_from_pending(); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION f_for_tbl_rrr_trg_change_from_pending() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if old.status_code = 'pending' and new.status_code in ( 'current', 'historic') then
    update administrative.rrr set 
      status_code= 'previous', change_user=new.change_user
    where ba_unit_id= new.ba_unit_id and nr= new.nr and status_code = 'current';
  end if;
  return new;
end;
$$;


ALTER FUNCTION administrative.f_for_tbl_rrr_trg_change_from_pending() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_rrr_trg_change_from_pending(); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_rrr_trg_change_from_pending() IS 'Function triggered on an update to the RRR table that sets the status of any Current RRR matching the Nr of the RRR record being updated to Previous. Used to implement versioning of RRR records.';


--
-- Name: get_ba_unit_pending_action(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_ba_unit_pending_action(baunit_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
  return (SELECT rt.type_action_code
  FROM ((administrative.ba_unit_target bt INNER JOIN transaction.transaction t ON bt.transaction_id = t.id)
  INNER JOIN application.service s ON t.from_service_id = s.id)
  INNER JOIN application.request_type rt ON s.request_type_code = rt.code
  WHERE bt.ba_unit_id = baunit_id AND t.status_code = 'pending'
  LIMIT 1);
END;
$$;


ALTER FUNCTION administrative.get_ba_unit_pending_action(baunit_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_ba_unit_pending_action(baunit_id character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION get_ba_unit_pending_action(baunit_id character varying) IS 'Determines the action (New, Vary or Cancel) that applies to the BA Unit based on the service it is associated with.';


--
-- Name: get_calculated_area_size_action(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_calculated_area_size_action(co_list character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN

  return (
          select coalesce(cast(sum(a.size)as float),0)
	  from cadastre.spatial_value_area a
	  where  a.type_code = 'officialArea'
	  and a.spatial_unit_id = ANY(string_to_array(co_list, ' '))
         );
END;
$$;


ALTER FUNCTION administrative.get_calculated_area_size_action(co_list character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_calculated_area_size_action(co_list character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION get_calculated_area_size_action(co_list character varying) IS 'Returns the sum of any official parcel areas (i.e. cadastre.spatial_value_area) associated to the BA Unit.';


--
-- Name: get_concatenated_name(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION get_concatenated_name(baunit_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
           Select pippo.firstpart||'/'||pippo.lastpart || ' ' || pippo.cadtype  as value
   from 
   administrative.ba_unit bu join
	   (select co.name_firstpart firstpart,
	   co.name_lastpart lastpart,
	    get_translation(cot.display_value, null) cadtype,
	   bsu.ba_unit_id unit_id
	   from administrative.ba_unit_contains_spatial_unit  bsu
	   join cadastre.cadastre_object co on (bsu.spatial_unit_id = co.id)
	   join cadastre.cadastre_object_type cot on (co.type_code = cot.code)) pippo
           on (bu.id = pippo.unit_id)
	   where bu.id = baunit_id
	loop
           name = name || ', ' || rec.value;
	end loop;

        if name = '' then
	  name = ' ';
       end if;

	if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;

$$;


ALTER FUNCTION administrative.get_concatenated_name(baunit_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_concatenated_name(baunit_id character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION get_concatenated_name(baunit_id character varying) IS 'Returns a concatenated list of all cadastre objects associated to the BA Unit';


--
-- Name: getdistrict(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getdistrict(baunitid character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  DECLARE
	districtId VARCHAR; 
  BEGIN
  
    IF baUnitId IS NULL THEN
	 RETURN NULL; 
    END IF; 

    districtId := administrative.getDistrictId(baUnitId); 

    IF districtId IS NULL THEN
		RETURN NULL;
    END IF; 
	
    RETURN (SELECT  name_firstpart
			FROM 	administrative.ba_unit
			WHERE	id = districtId);  
			
  END; $$;


ALTER FUNCTION administrative.getdistrict(baunitid character varying) OWNER TO postgres;

--
-- Name: FUNCTION getdistrict(baunitid character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getdistrict(baunitid character varying) IS 'Retrieves the District name for the ba unit';


--
-- Name: getdistrictid(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getdistrictid(baunitid character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  BEGIN
  
    IF baUnitId IS NULL THEN
	 RETURN NULL; 
	END IF; 
	
	RETURN (SELECT  from_ba_unit_id
			FROM 	administrative.required_relationship_baunit
			WHERE	to_ba_unit_id = administrative.getVillageId(baUnitId)
			AND		relation_code = 'district_Village'); 
			
  END; $$;


ALTER FUNCTION administrative.getdistrictid(baunitid character varying) OWNER TO postgres;

--
-- Name: FUNCTION getdistrictid(baunitid character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getdistrictid(baunitid character varying) IS 'Retrieves the District Id for the ba unit';


--
-- Name: getpriortitle(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getpriortitle(baunitid character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  BEGIN
  
	IF baUnitId IS NULL THEN
		RETURN NULL; 
	END IF; 
	
	RETURN (SELECT  name_firstpart ||  '/' || name_lastpart
			FROM 	administrative.ba_unit
			WHERE	id = administrative.getPriorTitleId(baUnitId)); 
			
  END; $$;


ALTER FUNCTION administrative.getpriortitle(baunitid character varying) OWNER TO postgres;

--
-- Name: FUNCTION getpriortitle(baunitid character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getpriortitle(baunitid character varying) IS 'Retrieves the Prior Title reference for the ba unit id';


--
-- Name: getpriortitleid(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getpriortitleid(baunitid character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  BEGIN
  
	IF baUnitId IS NULL THEN
		RETURN NULL; 
	END IF; 
	
	RETURN (SELECT  from_ba_unit_id
			FROM 	administrative.required_relationship_baunit
			WHERE	to_ba_unit_id = baUnitId
			AND		relation_code = 'priorTitle'
			LIMIT 1); 
  END; $$;


ALTER FUNCTION administrative.getpriortitleid(baunitid character varying) OWNER TO postgres;

--
-- Name: FUNCTION getpriortitleid(baunitid character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getpriortitleid(baunitid character varying) IS 'Retrieves the Prior Title Id for the ba unit';


--
-- Name: getvillage(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getvillage(baunitid character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  BEGIN
  
    IF baUnitId IS NULL THEN
	 RETURN NULL; 
	END IF; 
	
	RETURN (SELECT  name_firstpart
			FROM 	administrative.ba_unit
			WHERE	id = administrative.getVillageId(baUnitId)); 
			
  END; $$;


ALTER FUNCTION administrative.getvillage(baunitid character varying) OWNER TO postgres;

--
-- Name: FUNCTION getvillage(baunitid character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getvillage(baunitid character varying) IS 'Retrieves the Village name for the given ba unit';


--
-- Name: getvillageid(character varying); Type: FUNCTION; Schema: administrative; Owner: postgres
--

CREATE FUNCTION getvillageid(baunitid character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  DECLARE
	villageId VARCHAR := NULL; 
  BEGIN
  
    WHILE villageId IS NULL LOOP
		EXIT WHEN baUnitId IS NULL;  
		
		SELECT  from_ba_unit_id
		INTO    villageId
		FROM 	administrative.required_relationship_baunit
		WHERE	to_ba_unit_id = baUnitId
		AND		relation_code = 'title_Village';
		
		IF villageId IS NULL THEN
			baUnitId := administrative.getPriorTitleId(baUnitId);
		END IF;
	END LOOP; 	

	RETURN villageId;
			
  END; $$;


ALTER FUNCTION administrative.getvillageid(baunitid character varying) OWNER TO postgres;

--
-- Name: FUNCTION getvillageid(baunitid character varying); Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON FUNCTION getvillageid(baunitid character varying) IS 'Retrieves the Village Id for the ba unit';


SET search_path = application, pg_catalog;

--
-- Name: get_concatenated_name(character varying); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION get_concatenated_name(service_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  name character varying;
  
BEGIN
  name = '';
   
	for rec in 
	   Select bu.name_firstpart||'/'||bu.name_lastpart||' ( '||pippo.firstpart||'/'||pippo.lastpart || ' ' || pippo.cadtype||' )'  as value,
	        pippo.id
		from application.service s 
		join application.application_property ap on (s.application_id=ap.application_id)
		join administrative.ba_unit bu on (ap.name_firstpart||ap.name_lastpart=bu.name_firstpart||bu.name_lastpart)
		join (select co.name_firstpart firstpart,
			   co.name_lastpart lastpart,
			   get_translation(cot.display_value, null) cadtype,
			   bsu.ba_unit_id unit_id,
			   co.id id
			   from administrative.ba_unit_contains_spatial_unit  bsu
			   join cadastre.cadastre_object co on (bsu.spatial_unit_id = co.id)
			   join cadastre.cadastre_object_type cot on (co.type_code = cot.code)) pippo
			   on (bu.id = pippo.unit_id)
	   where s.id = service_id 
	    and (s.request_type_code = 'cadastreChange' or s.request_type_code = 'redefineCadastre' or s.request_type_code = 'newApartment' 
	   or s.request_type_code = 'newDigitalProperty' or s.request_type_code = 'newDigitalTitle' or s.request_type_code = 'newFreehold' 
	   or s.request_type_code = 'newOwnership' or s.request_type_code = 'newState')
	   and s.status_code != 'lodged'
	loop
	   name = name || ', ' || replace (rec.value,rec.id, '');
	end loop;

        if name = '' then
	  return name;
	end if;

	if substr(name, 1, 1) = ',' then
          name = substr(name,2);
        end if;
return name;
END;

$$;


ALTER FUNCTION application.get_concatenated_name(service_id character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_concatenated_name(service_id character varying); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION get_concatenated_name(service_id character varying) IS 'Returns a concatenated list of all cadastre objects associated to the BA Unit referenced by the application.';


--
-- Name: get_estate_type(character varying, character varying); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION get_estate_type(service_id character varying, request_type character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$ 
DECLARE
  estate_type VARCHAR(20); 
BEGIN
   IF service_id IS NULL OR request_type IS NULL OR request_type NOT IN ('registerLease', 'subLease') THEN
      RETURN '';
   END IF; 

   SELECT p.type_code
   INTO   estate_type
   FROM   transaction.transaction t,
	  administrative.rrr r,
	  administrative.rrr p
   WHERE  t.from_service_id = service_id
   AND    r.transaction_id = t.id
   AND    p.ba_unit_id = r.ba_unit_id
   AND    p.is_primary = true
   AND    p.status_code = 'current';

   IF estate_type IS NULL THEN
      estate_type := '';
   END IF;
   
   RETURN estate_type;
   
END; $$;


ALTER FUNCTION application.get_estate_type(service_id character varying, request_type character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_estate_type(service_id character varying, request_type character varying); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION get_estate_type(service_id character varying, request_type character varying) IS 'Returns the estate type of the property related to the service. Only tested with Record Lease and Record Sublease services. Used by the Lodgement Statistics Report.';


--
-- Name: get_work_summary(date, date); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION get_work_summary(from_date date, to_date date) RETURNS TABLE(req_type character varying, req_cat character varying, group_idx integer, in_progress_from integer, on_requisition_from integer, lodged integer, requisitioned integer, registered integer, cancelled integer, withdrawn integer, in_progress_to integer, on_requisition_to integer, overdue integer, service_fee numeric, overdue_apps text, requisition_apps text)
    LANGUAGE plpgsql
    AS $$
DECLARE 
   tmp_date DATE; 
BEGIN

   IF to_date IS NULL OR from_date IS NULL THEN
      RETURN;
   END IF; 

   -- Swap the dates so the to date is after the from date
   IF to_date < from_date THEN 
      tmp_date := from_date; 
      from_date := to_date; 
      to_date := tmp_date; 
   END IF; 
   
   -- Go through to the start of the next day. 
   to_date := to_date + 1; 

   RETURN query 
   
      -- Identifies all services lodged during the reporting period. Uses the
	  -- change_time instead of lodging_datetime to ensure all datetime comparisons 
	  -- across all subqueries yield consistent results 
      WITH estate_types AS 
	     -- Ticket #137 provide a breakdown by estate type for Record Lease and Record Sublease
         (SELECT req.code as req_code, rt.code as rt_code, 
                 get_translation(rt.display_value, null) as rt_display
          FROM   application.request_type req,
                 administrative.rrr_type rt
          WHERE  rt.is_primary = true
          AND    rt.status = 'c'
          AND    req.code IN ('registerLease', 'subLease')
          AND    req.status = 'c'
          UNION 
		  -- Use to capture any services that do not link to a property with an
		  -- estate type specified
          SELECT req.code AS req_code, '' AS rt_code, 'Unspecified' AS rt_display
          FROM   application.request_type req
          WHERE  req.code IN ('registerLease', 'subLease')
          AND    req.status = 'c'),
      service_lodged AS (
	 SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.rowversion = 1
		 UNION
         SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code
         FROM   application.service_historic ser_hist
         WHERE  ser_hist.change_time BETWEEN from_date AND to_date
		 AND    ser_hist.rowversion = 1),
		 
      -- Identifies all services cancelled during the reporting period. 	  
	  service_cancelled AS 
        (SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.status_code = 'cancelled'
     -- Verify that the service actually changed status 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )
	 -- #106 - Check the history data for cancelled services as applications returned
	 -- from requisition can cause the cancelled service record to be updated. 
		UNION
		SELECT ser.id, ser.application_id, ser.request_type_code
         FROM   application.service_historic ser
         WHERE  ser.change_time BETWEEN from_date AND to_date
		 AND    ser.status_code = 'cancelled'
     -- Verify that the service actually changed status. 
         AND  NOT EXISTS (SELECT ser_hist.status_code 
                          FROM application.service_historic ser_hist
                          WHERE ser_hist.id = ser.id
                          AND  (ser.rowversion - 1) = ser_hist.rowversion
                          AND  ser.status_code = ser_hist.status_code )),
		
      -- All services in progress at the end of the reporting period		
      service_in_progress AS (  
         SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= to_date
	 AND ser.status_code IN ('pending', 'lodged')
      UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist,
	       application.service ser
	 WHERE ser_hist.change_time <= to_date
	 AND   ser.id = ser_hist.id
	 -- Filter out any services that have not been changed since the to_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   ser.change_time > to_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= to_date )),
	
    -- All services in progress at the start of the reporting period	
	service_in_progress_from AS ( 
     SELECT ser.id, ser.application_id, ser.request_type_code, ser.expected_completion_date
	 FROM application.service ser
	 WHERE ser.change_time <= from_date
	 AND ser.status_code IN ('pending', 'lodged')
     UNION
	 SELECT ser_hist.id, ser_hist.application_id, ser_hist.request_type_code, 
	        ser_hist.expected_completion_date
	 FROM  application.service_historic ser_hist,
	       application.service ser
	 WHERE ser_hist.change_time <= from_date
	 AND   ser.id = ser_hist.id
	 -- Filter out any services that have not been changed since the from_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   ser.change_time > from_date
	 AND   ser_hist.status_code IN ('pending', 'lodged')
	 AND   ser_hist.rowversion = (SELECT MAX(ser_hist2.rowversion)
				      FROM  application.service_historic ser_hist2
				      WHERE ser_hist.id = ser_hist2.id
				      AND   ser_hist2.change_time <= from_date )),
				      
    app_changed AS ( -- All applications that changed status during the reporting period
	                 -- If the application changed status more than once, it will be listed
					 -- multiple times
         SELECT app.id, 
	 -- Flag if the application was withdrawn
	 app.status_code,
	 CASE app.action_code WHEN 'withdrawn' THEN TRUE ELSE FALSE END AS withdrawn
	 FROM   application.application app
	 WHERE  app.change_time BETWEEN from_date AND to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist.status_code 
			  FROM application.application_historic app_hist
			  WHERE app_hist.id = app.id
			  AND  (app.rowversion - 1) = app_hist.rowversion
			  AND  app.status_code = app_hist.status_code )
      UNION  
	 SELECT app_hist.id, 
	 app_hist.status_code,
	 CASE app_hist.action_code WHEN 'withdrawn' THEN TRUE ELSE FALSE END AS withdrawn
	 FROM  application.application_historic app_hist
	 WHERE app_hist.change_time BETWEEN from_date AND to_date
	 -- Verify that the application actually changed status during the reporting period
	 -- rather than just being updated
	 AND  NOT EXISTS (SELECT app_hist2.status_code 
			  FROM application.application_historic app_hist2
			  WHERE app_hist.id = app_hist2.id
			  AND  (app_hist.rowversion - 1) = app_hist2.rowversion
			  AND  app_hist.status_code = app_hist2.status_code )), 
                          
     app_in_progress AS ( -- All applications in progress at the end of the reporting period
	 SELECT app.id, app.status_code, app.expected_completion_date, app.nr
	 FROM application.application app
	 WHERE app.change_time <= to_date
	 AND app.status_code IN ('lodged', 'requisitioned')
	 UNION
	 SELECT app_hist.id, app_hist.status_code, app_hist.expected_completion_date, app_hist.nr
	 FROM  application.application_historic app_hist, 
	       application.application app
	 WHERE app_hist.change_time <= to_date
	 AND   app.id = app_hist.id
	 -- Filter out any applications that have not been changed since the to_date as these
	 -- would have been picked up in the first select if they were still active
	 AND   app.change_time > to_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= to_date)),
					  
	app_in_progress_from AS ( -- All applications in progress at the start of the reporting period
	 SELECT app.id, app.status_code, app.expected_completion_date, app.nr
	 FROM application.application app
	 WHERE app.change_time <= from_date
	 AND app.status_code IN ('lodged', 'requisitioned')
	 UNION
	 SELECT app_hist.id, app_hist.status_code, app_hist.expected_completion_date, app_hist.nr
	 FROM  application.application_historic app_hist,
	       application.application app
	 WHERE app_hist.change_time <= from_date
	 AND   app.id = app_hist.id
	-- Filter out any applications that have not been changed since the from_date as these
	-- would have been picked up in the first select if they were still active
	 AND   app.change_time > from_date
	 AND   app_hist.status_code IN ('lodged', 'requisitioned')
	 AND   app_hist.rowversion = (SELECT MAX(app_hist2.rowversion)
				      FROM  application.application_historic app_hist2
				      WHERE app_hist.id = app_hist2.id
				      AND   app_hist2.change_time <= from_date)),
	
    -- Ticket #137	
	-- Attempts to determine the fee paid for each service during the reporting period. This query is capable
	-- of dealing with partial payments and negative payments, but it may also misrepresent the fee paid
	-- per service if a new service is added to the application post lodgement. The logic attempts to 
	-- pro rata any new payment amounts evenly across all services, so when a new service is added, only
	-- part of any new payment may be allocated to the new service. 
	fee_paid AS (
		-- Payment details captured as part of initial lodgement and the application does not have any history
		SELECT s.id, s.request_type_code,
			   TRUNC(((a.total_amount_paid/a.total_fee) * (s.base_fee + s.value_fee)), 2) AS ser_fee, a.rowversion
		FROM  application.application a, 
			  application.service s
		WHERE s.application_id = a.id
		AND   s.status_code != 'cancelled'
		AND   a.total_fee  > 0
		AND   a.total_amount_paid > 0
		AND   a.change_time BETWEEN from_date AND to_date
		AND   s.lodging_datetime <= a.change_time
		AND   a.rowversion = 1
		UNION
		-- Payment made on the most recent save of the application (need to compare ot history of application to determine if 
		-- the total_amount_paid has changed. 
		SELECT s.id, s.request_type_code,
			   TRUNC((((a.total_amount_paid - app_hist.total_amount_paid)/a.total_fee) * (s.base_fee + s.value_fee)), 2) AS ser_fee, a.rowversion
		FROM  application.application a, 
			  application.service s,
			  application.application_historic app_hist
		WHERE s.application_id = a.id
		AND   s.status_code != 'cancelled'
		AND   a.total_fee  > 0
		AND   a.change_time BETWEEN from_date AND to_date
			AND   s.lodging_datetime <= a.change_time
		AND   app_hist.id = a.id
		AND   app_hist.rowversion = (a.rowversion - 1)
		AND   app_hist.total_amount_paid != a.total_amount_paid
		-- Ignore records where the total_fee changed by the same amount as the total paid. 
		AND   a.total_fee - app_hist.total_fee != a.total_amount_paid - app_hist.total_amount_paid
		UNION
		-- Payment made at an earlier time and captured in the application history
		SELECT s.id, s.request_type_code,
			   TRUNC((((a.total_amount_paid - app_hist.total_amount_paid)/a.total_fee) * (s.base_fee + s.value_fee)), 2) AS ser_fee, a.rowversion
		FROM  application.application_historic a, 
			  application.service s,
			  application.application_historic app_hist
		WHERE s.application_id = a.id
		AND   s.status_code != 'cancelled'
		AND   a.total_fee  > 0
		AND   a.change_time BETWEEN from_date AND to_date
		AND   s.lodging_datetime <= a.change_time
		AND   app_hist.id = a.id
		AND   app_hist.rowversion = (a.rowversion - 1)
		AND   app_hist.total_amount_paid != a.total_amount_paid
		-- Ignore records where the total_fee changed by the same amount as the total paid.
		AND   a.total_fee - app_hist.total_fee != a.total_amount_paid - app_hist.total_amount_paid
		UNION
		-- Only one payment made to the original lodgement record which is now in history.
		SELECT s.id, s.request_type_code,
			   TRUNC(((a.total_amount_paid/a.total_fee) * (s.base_fee + s.value_fee)), 2) AS ser_fee, a.rowversion
		FROM  application.application_historic a, 
			  application.service s
		WHERE s.application_id = a.id
		AND   s.status_code != 'cancelled'
		AND   a.total_fee  > 0
		AND   a.total_amount_paid > 0
		AND   a.change_time BETWEEN from_date AND to_date
		-- Allow 1 minute buffer as the services may be saved a few seconds after the application is initially created. 
		AND   s.lodging_datetime <= a.change_time + interval '1 minute'
		AND   a.rowversion = 1
		)
   -- MAIN QUERY                         
   SELECT (CASE WHEN rt_display IS NULL THEN get_translation(req.display_value, null) 
            ELSE  get_translation(req.display_value, null)  || ' - ' || rt_display END)::VARCHAR(200) AS req_type,
             --get_translation(req.display_value, null) AS req_type,
	  CASE req.request_category_code 
	     WHEN 'registrationServices' THEN get_translation(cat.display_value, null)
	     WHEN 'cadastralServices' THEN get_translation(cat.display_value, null)
	     ELSE 'Other Services'  END AS req_cat,
	     
	  CASE req.request_category_code 
	     WHEN 'registrationServices' THEN 1
             WHEN 'cadastralServices' THEN 2
	     ELSE 3 END AS group_idx,
		 
	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the start of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS in_progress_from,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress_from s, app_in_progress_from a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS on_requisition_from,
	     
	  -- Count the services lodged during the reporting period.
	 (SELECT COUNT(s.id) FROM service_lodged s
	  WHERE s.request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS lodged,
	  
      -- Count the applications that were requisitioned during the
	  -- reporting period. All of the services on the application
 	  -- are requisitioned unless they are cancelled. Use the
	  -- current set of services on the application, but ensure
	  -- the services where lodged before the end of the reporting
	  -- period and that they were not cancelled during the 
	  -- reporting period. 
	 (SELECT COUNT(s.id) FROM app_changed a, application.service s
          WHERE s.application_id = a.id
	  AND   a.status_code = 'requisitioned'
	  AND   s.lodging_datetime < to_date
	  AND   NOT EXISTS (SELECT can.id FROM service_cancelled can
                        WHERE s.id = can.id)	  
          AND   s.request_type_code = req.code
          AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS requisitioned, 
          
	  -- Count the services on applications approved/completed 
	  -- during the reporting period. Note that services cannot be
	  -- changed after the application is approved, so checking the
	  -- current state of the services is valid. 
         (SELECT COUNT(s.id) FROM app_changed a, application.service s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'approved'
	  AND   s.status_code = 'completed'
	  AND   s.request_type_code = req.code
	  AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS registered,
	  
	  -- Count of the services associated with applications 
	  -- that have been lapsed or rejected + the count of 
	  -- services cancelled during the reporting period. Note that
      -- once annulled changes to the services are not possible so
      -- checking the current state of the services is valid.
      (SELECT COUNT(tmp.id) FROM  	  
        (SELECT s.id FROM app_changed a, application.service s
		  WHERE s.application_id = a.id
		  AND   a.status_code = 'annulled'
		  AND   a.withdrawn = FALSE
		  AND   s.request_type_code = req.code
		  AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, '')
          UNION		  
		  SELECT s.id FROM app_changed a, service_cancelled s
		  WHERE s.application_id = a.id
		  AND   a.status_code != 'annulled'
		  AND   s.request_type_code = req.code
		  AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, '')) AS tmp)::INT AS cancelled, 
	  
	  -- Count of the services associated with applications
	  -- that have been withdrawn during the reporting period
	  -- Note that once annulled changes to the services are
      -- not possible so checking the current state of the services is valid. 
         (SELECT COUNT(s.id) FROM app_changed a, application.service s
	  WHERE s.application_id = a.id
	  AND   a.status_code = 'annulled'
	  AND   a.withdrawn = TRUE
	  AND   s.status_code != 'cancelled'
	  AND   s.request_type_code = req.code
	  AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS withdrawn,

	  -- Count of the pending and lodged services associated with
	  -- lodged applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'
	  AND request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS in_progress_to,

	  -- Count of the services associated with requisitioned 
	  -- applications at the end of the reporting period
         (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
	  WHERE s.application_id = a.id
          AND   a.status_code = 'requisitioned'
	  AND s.request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS on_requisition_to,

	  -- Count of the services that have exceeded thier expected
	  -- completion date and are overdue. Only counts the service 
	  -- as overdue if both the application and the service are overdue. 
     (SELECT COUNT(s.id) FROM service_in_progress s, app_in_progress a
          WHERE s.application_id = a.id
          AND   a.status_code = 'lodged'              
	  AND   a.expected_completion_date < to_date
	  AND   s.expected_completion_date < to_date
	  AND   s.request_type_code = req.code
	  AND application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))::INT AS overdue,  
	  
	  -- Ticket #137
	  -- Sum the total paid for each fee. Note that for Samoa, only details
	  -- are required for the Record Plan service, (a.k.a. Cadastre Change) 
	  -- so exclude other service types. 
    (SELECT SUM(f.ser_fee) FROM fee_paid f
      WHERE f.request_type_code = req.code
	  AND   application.get_estate_type(f.id, req.code) = COALESCE(rt_code, '')
	  AND   req.code IN ('cadastreChange'))::NUMERIC(20,2) AS service_fee, 

	  -- The list of overdue applications 
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'lodged' 
          AND   a.expected_completion_date < to_date
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.expected_completion_date < to_date
                        AND   s.request_type_code = req.code
                        AND    application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))) AS overdue_apps,   

	  -- The list of applications on Requisition
	 (SELECT string_agg(a.nr, ', ') FROM app_in_progress a
          WHERE a.status_code = 'requisitioned' 
          AND   EXISTS (SELECT s.application_id FROM service_in_progress s
                        WHERE s.application_id = a.id
                        AND   s.request_type_code = req.code
                        AND   application.get_estate_type(s.id, req.code) = COALESCE(rt_code, ''))) AS requisition_apps						
   FROM  application.request_category_type cat, 
         application.request_type req LEFT OUTER JOIN estate_types ON req_code = req.code
   WHERE req.status = 'c'
   AND   cat.code = req.request_category_code					 
   ORDER BY group_idx, req_type;
	
   END; $$;


ALTER FUNCTION application.get_work_summary(from_date date, to_date date) OWNER TO postgres;

--
-- Name: FUNCTION get_work_summary(from_date date, to_date date); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION get_work_summary(from_date date, to_date date) IS 'Returns a summary of the services processed for a specified reporting period. Used by the Lodgement Statistics Report.';


--
-- Name: getlodgement(character varying, character varying); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION getlodgement(fromdate character varying, todate character varying) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE 
    resultType  varchar;
    resultGroup varchar;
    resultTotal integer :=0 ;
    resultTotalPerc decimal:=0 ;
    resultDailyAvg  decimal:=0 ;
    resultTotalReq integer:=0 ;
    resultReqPerc  decimal:=0 ;
    TotalTot integer:=0 ;
    appoDiff integer:=0 ;
    rec     record;
    sqlSt varchar;
    lodgementFound boolean;
    recToReturn record;

    
BEGIN  
    appoDiff := (to_date(''|| toDate || '','yyyy-mm-dd') - to_date(''|| fromDate || '','yyyy-mm-dd'));
     if  appoDiff= 0 then 
            appoDiff:= 1;
     end if; 
    sqlSt:= '';
    
    sqlSt:= 'select   1 as order,
         get_translation(application.request_type.display_value, null) as type,
         application.request_type.request_category_code as group,
         count(application.service_historic.id) as total,
         round((CAST(count(application.service_historic.id) as decimal)
         /
         '||appoDiff||'
         ),2) as dailyaverage
from     application.service_historic,
         application.request_type
where    application.service_historic.request_type_code = application.request_type.code
         and
         application.service_historic.lodging_datetime between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
         and application.service_historic.action_code=''lodge''
         and application.service_historic.application_id in
	      (select distinct(application.application_historic.id)
	       from application.application_historic)
group by application.service_historic.request_type_code, application.request_type.display_value,
         application.request_type.request_category_code
union
select   2 as order,
         ''Total'' as type,
         ''All'' as group,
         count(application.service_historic.id) as total,
         round((CAST(count(application.service_historic.id) as decimal)
         /
         '||appoDiff||'
         ),2) as dailyaverage
from     application.service_historic,
         application.request_type
where    application.service_historic.request_type_code = application.request_type.code
         and
         application.service_historic.lodging_datetime between to_date('''|| fromDate || ''',''yyyy-mm-dd'')  and to_date('''|| toDate || ''',''yyyy-mm-dd'')
         and application.service_historic.application_id in
	      (select distinct(application.application_historic.id)
	       from application.application_historic)
order by 1,3,2;
';




  

    --raise exception '%',sqlSt;
    lodgementFound = false;
    -- Loop through results
         select   
         count(application.service_historic.id)
         into TotalTot
from     application.service_historic,
         application.request_type
where    application.service_historic.request_type_code = application.request_type.code
         and
         application.service_historic.lodging_datetime between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd')
         and application.service_historic.application_id in
	      (select distinct(application.application_historic.id)
	       from application.application_historic);

    
    FOR rec in EXECUTE sqlSt loop
            resultType:= rec.type;
	    resultGroup:= rec.group;
	    resultTotal:= rec.total;
	    if  TotalTot= 0 then 
               TotalTot:= 1;
            end if; 
	    resultTotalPerc:= round((CAST(rec.total as decimal)*100/TotalTot),2);
	    resultDailyAvg:= rec.dailyaverage;
            resultTotalReq:= 0;

           

            if rec.type = 'Total' then
                 select   count(application.service_historic.id) into resultTotalReq
		from application.service_historic
		where application.service_historic.action_code='lodge'
                      and
                      application.service_historic.lodging_datetime between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd')
                      and application.service_historic.application_id in
		      (select application.application_historic.id
		       from application.application_historic
		       where application.application_historic.action_code='requisition');
            else
                  select  count(application.service_historic.id) into resultTotalReq
		from application.service_historic
		where application.service_historic.action_code='lodge'
                      and
                      application.service_historic.lodging_datetime between to_date(''|| fromDate || '','yyyy-mm-dd')  and to_date(''|| toDate || '','yyyy-mm-dd')
                      and application.service_historic.application_id in
		      (select application.application_historic.id
		       from application.application_historic
		       where application.application_historic.action_code='requisition'
		      )   
		and   application.service_historic.request_type_code = rec.type     
		group by application.service_historic.request_type_code;
            end if;

             if  rec.total= 0 then 
               appoDiff:= 1;
             else
               appoDiff:= rec.total;
             end if; 
            resultReqPerc:= round((CAST(resultTotalReq as decimal)*100/appoDiff),2);

            if resultType is null then
              resultType :=0 ;
            end if;
	    if resultTotal is null then
              resultTotal  :=0 ;
            end if;  
	    if resultTotalPerc is null then
	         resultTotalPerc  :=0 ;
            end if;  
	    if resultDailyAvg is null then
	        resultDailyAvg  :=0 ;
            end if;  
	    if resultTotalReq is null then
	        resultTotalReq  :=0 ;
            end if;  
	    if resultReqPerc is null then
	        resultReqPerc  :=0 ;
            end if;  

	    if TotalTot is null then
	       TotalTot  :=0 ;
            end if;  
	  
          select into recToReturn resultType::varchar, resultGroup::varchar, resultTotal::integer, resultTotalPerc::decimal,resultDailyAvg::decimal,resultTotalReq::integer,resultReqPerc::decimal;
          return next recToReturn;
          lodgementFound = true;
    end loop;
   
    if (not lodgementFound) then
        RAISE EXCEPTION 'no_lodgement_found';
    end if;
    return;
END;
$$;


ALTER FUNCTION application.getlodgement(fromdate character varying, todate character varying) OWNER TO postgres;

--
-- Name: FUNCTION getlodgement(fromdate character varying, todate character varying); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION getlodgement(fromdate character varying, todate character varying) IS 'Not used. Replaced by get_work_summary.';


--
-- Name: getlodgetiming(date, date); Type: FUNCTION; Schema: application; Owner: postgres
--

CREATE FUNCTION getlodgetiming(fromdate date, todate date) RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
DECLARE 
    timeDiff integer:=0 ;
BEGIN
timeDiff := toDate-fromDate;
if timeDiff<=0 then 
    timeDiff:= 1;
end if; 

return query
select 'Lodged not completed'::varchar as resultCode, count(1)::integer as resultTotal, (round(count(1)::numeric/timeDiff,1))::float as resultDailyAvg, 1 as ord 
from application.application
where lodging_datetime between fromdate and todate and status_code = 'lodged'
union
select 'Registered' as resultCode, count(1)::integer as resultTotal, (round(count(1)::numeric/timeDiff,1))::float as resultDailyAvg, 2 as ord 
from application.application
where lodging_datetime between fromdate and todate
union
select 'Rejected' as resultCode, count(1)::integer as resultTotal, (round(count(1)::numeric/timeDiff,1))::float as resultDailyAvg, 3 as ord 
from application.application
where lodging_datetime between fromdate and todate and status_code = 'annulled'
union
select 'On Requisition' as resultCode, count(1)::integer as resultTotal, (round(count(1)::numeric/timeDiff,1))::float as resultDailyAvg, 4 as ord 
from application.application
where lodging_datetime between fromdate and todate and status_code = 'requisitioned'
union
select 'Withdrawn' as resultCode, count(distinct id)::integer as resultTotal, (round(count(distinct id)::numeric/timeDiff,1))::float as resultDailyAvg, 5 as ord 
from application.application_historic
where change_time between fromdate and todate and action_code = 'withdraw'
order by ord;

END;
$$;


ALTER FUNCTION application.getlodgetiming(fromdate date, todate date) OWNER TO postgres;

--
-- Name: FUNCTION getlodgetiming(fromdate date, todate date); Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON FUNCTION getlodgetiming(fromdate date, todate date) IS 'Not used. Replaced by get_work_summary.';


SET search_path = cadastre, pg_catalog;

--
-- Name: add_topo_points(public.geometry, public.geometry); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION add_topo_points(source public.geometry, target public.geometry) RETURNS public.geometry
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  point_location float;
  point_to_add geometry;
  rings geometry[];
  nr_elements integer;
  tolerance double precision;
  i integer;
begin
  tolerance = system.get_setting('map-tolerance')::double precision;
  if st_geometrytype(target) = 'ST_LineString' then
    for rec in 
      select geom from St_DumpPoints(source) s
        where st_dwithin(target, s.geom, tolerance)
    loop
      if (select count(1) from st_dumppoints(target) t where st_dwithin(rec.geom, t.geom, tolerance))=0 then
        point_location = ST_Line_Locate_Point(target, rec.geom);
        --point_to_add = ST_Line_Interpolate_Point(target, point_location);
        target = ST_LineMerge(ST_Union(ST_Line_Substring(target, 0, point_location), ST_Line_Substring(target, point_location, 1)));
      end if;
    end loop;
  elsif st_geometrytype(target)= 'ST_Polygon' then
    select  array_agg(ST_ExteriorRing(geom)) into rings from ST_DumpRings(target);
    nr_elements = array_upper(rings, 1);
    for i in 1..nr_elements loop
      rings[i] = cadastre.add_topo_points(source, rings[i]);
    end loop;
    target = ST_MakePolygon(rings[1], rings[2:nr_elements]);
  end if;
  return target;
end;
$$;


ALTER FUNCTION cadastre.add_topo_points(source public.geometry, target public.geometry) OWNER TO postgres;

--
-- Name: FUNCTION add_topo_points(source public.geometry, target public.geometry); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION add_topo_points(source public.geometry, target public.geometry) IS 'Alters the topology of the target geometry by merging selected coordinates from the source geometry into the target geometry. Only those coordinates from the source geometry that are within the map-tolerance distance of the target geometry boundary are merged. Used during spatial editing of parcels to ensure parcels adjacent of the edit remain topologically consistent with any new parcels.';


--
-- Name: cadastre_object_name_is_valid(character varying, character varying); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
  IF name_firstpart is null THEN RETURN false; END IF;
  IF name_lastpart is null THEN RETURN false; END IF;
  IF NOT ((name_firstpart SIMILAR TO 'Lot [0-9]+') OR (name_firstpart SIMILAR TO '[0-9]+')) THEN RETURN false;  END IF;
  IF NOT ((name_lastpart SIMILAR TO '[0-9 ]+') OR (name_lastpart SIMILAR TO 'CUSTOMARY LAND') OR (name_lastpart SIMILAR TO 'CTGT [0-9]+') OR (name_lastpart SIMILAR TO 'LC [0-9]+')) THEN RETURN false;  END IF;
  RETURN true;
end;
$$;


ALTER FUNCTION cadastre.cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying) OWNER TO postgres;

--
-- Name: FUNCTION cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION cadastre_object_name_is_valid(name_firstpart character varying, name_lastpart character varying) IS 'Verifies that the name assigned to a new cadastre object is consistent with the cadastre object naming rules.';


--
-- Name: change_parcel_name(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION change_parcel_name(parcel_id character varying, part1 character varying, part2 character varying, user_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$  
BEGIN

    -- Ticket #156 - Don't let the user set the name to ''
    IF parcel_id IS NULL OR TRIM(part1 || part2) = '' THEN
	   RETURN; 
	END IF;

    -- First remove the LRS parcel of the same name if one exists. 
	UPDATE cadastre.cadastre_object
	SET   change_user = user_name
	WHERE name_firstpart = part1
	AND   name_lastpart =  part2
	AND   source_reference = 'LRS';

	UPDATE administrative.ba_unit_contains_spatial_unit 
	SET change_user = user_name
	WHERE spatial_unit_id IN (
	   SELECT co.id
	   FROM   cadastre.cadastre_object co
	   WHERE name_firstpart = part1
	   AND   name_lastpart =  part2
	   AND   source_reference = 'LRS')
	OR spatial_unit_id = parcel_id;

	-- Disassociation the LRS parcel as well as the parcel that
	-- will get the name change from any BA Units. 
	DELETE FROM administrative.ba_unit_contains_spatial_unit 
	WHERE spatial_unit_id IN (
	   SELECT co.id
	   FROM   cadastre.cadastre_object co
	   WHERE name_firstpart = part1
	   AND   name_lastpart =  part2
	   AND   source_reference = 'LRS')
	OR spatial_unit_id = parcel_id;

	DELETE FROM cadastre.cadastre_object co
	WHERE  co.name_firstpart = part1
	AND    co.name_lastpart = part2
	AND    co.source_reference = 'LRS';

	-- Change the name of the parcel and link it to the ba_unit if a ba_unit
	-- exists with a matching name. 
	UPDATE cadastre.cadastre_object co
	SET    name_firstpart = part1,
	       name_lastpart = part2,
		   change_user = user_name
	WHERE  co.id = parcel_id;

	INSERT INTO administrative.ba_unit_contains_spatial_unit (ba_unit_id, spatial_unit_id, change_user)
	SELECT ba.id, co.id, user_name
	FROM   administrative.ba_unit ba,
		   cadastre.cadastre_object co
	WHERE  ba.name_firstpart = regexp_replace(part1, '\D', '', 'g') -- Remove the LOT part from the name
	AND    ba.name_lastpart = part2
	AND    co.name_firstpart = ba.name_firstpart
	AND    co.name_lastpart = ba.name_lastpart;
   
END; $$;


ALTER FUNCTION cadastre.change_parcel_name(parcel_id character varying, part1 character varying, part2 character varying, user_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION change_parcel_name(parcel_id character varying, part1 character varying, part2 character varying, user_name character varying); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION change_parcel_name(parcel_id character varying, part1 character varying, part2 character varying, user_name character varying) IS 'Procedure to correct the name of a cadastre object that was incorrectly recorded in DCDB. During the LRS migration, non spatial LRS parcels were created. The procedure will remove any LRS parcel matching the new name as well as link the parcel to the BA Unit matching the new name.';


--
-- Name: f_for_tbl_cadastre_object_trg_geommodify(); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION f_for_tbl_cadastre_object_trg_geommodify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
  rec record;
  rec_snap record;
  tolerance float;
  modified_geom geometry;
begin

  if new.status_code != 'current' then
    return new;
  end if;

  if new.type_code not in (select code from cadastre.cadastre_object_type where in_topology) then
    return new;
  end if;

  tolerance = coalesce(system.get_setting('map-tolerance')::double precision, 0.01);
  for rec in select co.id, co.geom_polygon 
                 from cadastre.cadastre_object co 
                 where  co.id != new.id and co.type_code = new.type_code and co.status_code = 'current'
                     and co.geom_polygon is not null 
                     and new.geom_polygon && co.geom_polygon 
                     and st_dwithin(new.geom_polygon, co.geom_polygon, tolerance)
  loop
    modified_geom = cadastre.add_topo_points(new.geom_polygon, rec.geom_polygon);
    if not st_equals(modified_geom, rec.geom_polygon) then
      update cadastre.cadastre_object 
        set geom_polygon= modified_geom, change_user= new.change_user 
      where id= rec.id;
    end if;
  end loop;
  return new;
end;
$$;


ALTER FUNCTION cadastre.f_for_tbl_cadastre_object_trg_geommodify() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_cadastre_object_trg_geommodify(); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_cadastre_object_trg_geommodify() IS 'Function triggered on insert or update to the cadastre_object table.  Uses the add_topo_points function to merge the topology of any parcels adjacent to parcel being updated. Only applied if the parcel being updated has a current status.';


--
-- Name: f_for_tbl_cadastre_object_trg_new(); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION f_for_tbl_cadastre_object_trg_new() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  if (select count(*)=0 from cadastre.spatial_unit where id=new.id) then
    insert into cadastre.spatial_unit(id, rowidentifier, change_user) 
    values(new.id, new.rowidentifier,new.change_user);
  end if;
  return new;
END;

$$;


ALTER FUNCTION cadastre.f_for_tbl_cadastre_object_trg_new() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_cadastre_object_trg_new(); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_cadastre_object_trg_new() IS 'Function triggered on insert to the cadastre_object table.  Inserts a record in the spatial_unit table for the cadastre_object if no spatial_unit record for the new cadastre_object exists.';


--
-- Name: f_for_tbl_cadastre_object_trg_remove(); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION f_for_tbl_cadastre_object_trg_remove() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  delete from cadastre.spatial_unit where id=old.id;
  return old;
END;
$$;


ALTER FUNCTION cadastre.f_for_tbl_cadastre_object_trg_remove() OWNER TO postgres;

--
-- Name: FUNCTION f_for_tbl_cadastre_object_trg_remove(); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION f_for_tbl_cadastre_object_trg_remove() IS 'Function triggered on delete from the cadastre_object table. Cascade deletes the record in the spatial_unit table for the cadastre_object.';


--
-- Name: formatareaimperial(numeric); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION formatareaimperial(area numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
   DECLARE perches NUMERIC(29,12); 
   DECLARE roods   NUMERIC(29,12); 
   DECLARE acres   NUMERIC(29,12);
   DECLARE remainder NUMERIC(29,12);
   DECLARE result  CHARACTER VARYING(40) := ''; 
   BEGIN
	IF area IS NULL THEN RETURN NULL; END IF; 
	acres := (area/4046.8564); -- 1a = 4046.8564m2     
	remainder := acres - trunc(acres,0);  
	roods := (remainder * 4); -- 4 roods to an acre
	remainder := roods - trunc(roods,0);
	perches := (remainder * 40); -- 40 perches to a rood
	IF acres >= 1 THEN
	  result := trim(to_char(trunc(acres,0), '9,999,999a')); 
	END IF; 
	-- Allow for the rounding introduced by to_char by manually incrementing
	-- the roods if perches are >= 39.95
	IF perches >= 39.95 THEN
	   roods := roods + 1;
	   perches = 0; 
	END IF; 
	IF acres >= 1 OR roods >= 1 THEN
	  result := result || ' ' || trim(to_char(trunc(roods,0), '99r'));
	END IF; 
	  result := result || ' ' || trim(to_char(perches, '00.0p'));
	RETURN '('  || trim(result) || ')';  
    END; 
    $$;


ALTER FUNCTION cadastre.formatareaimperial(area numeric) OWNER TO postgres;

--
-- Name: FUNCTION formatareaimperial(area numeric); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION formatareaimperial(area numeric) IS 'Formats a metric area to an imperial area measurement consisting of arces, roods and perches';


--
-- Name: formatareametric(numeric); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION formatareametric(area numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  BEGIN
	CASE WHEN area IS NULL THEN RETURN NULL;
	WHEN area < 1 THEN RETURN '    < 1 m' || chr(178);
	WHEN area < 10000 THEN RETURN to_char(area, '999,999 m') || chr(178);
	ELSE RETURN to_char((area/10000), '999,999.999 ha'); 
	END CASE; 
  END; $$;


ALTER FUNCTION cadastre.formatareametric(area numeric) OWNER TO postgres;

--
-- Name: FUNCTION formatareametric(area numeric); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION formatareametric(area numeric) IS 'Formats a metric area to m2 or hectares if area > 10,000m2';


--
-- Name: formatparcelnr(character varying, character varying); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION formatparcelnr(first_part character varying, last_part character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN first_part || ' PLAN ' || last_part; 
  END; $$;


ALTER FUNCTION cadastre.formatparcelnr(first_part character varying, last_part character varying) OWNER TO postgres;

--
-- Name: FUNCTION formatparcelnr(first_part character varying, last_part character varying); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION formatparcelnr(first_part character varying, last_part character varying) IS 'Formats the number/appellation to use for the parcel';


--
-- Name: formatparcelnrlabel(character varying, character varying); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION formatparcelnrlabel(first_part character varying, last_part character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- Fix for Ticket #156
    IF TRIM (first_part) = '' OR TRIM(last_part) = '' THEN
       RETURN first_part || last_part; 
    END IF;  
    RETURN first_part || chr(10) || last_part; 
  END; $$;


ALTER FUNCTION cadastre.formatparcelnrlabel(first_part character varying, last_part character varying) OWNER TO postgres;

--
-- Name: FUNCTION formatparcelnrlabel(first_part character varying, last_part character varying); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION formatparcelnrlabel(first_part character varying, last_part character varying) IS 'Formats the number/appellation for the parcel over 2 lines';


--
-- Name: snap_geometry_to_geometry(public.geometry, public.geometry, double precision, boolean); Type: FUNCTION; Schema: cadastre; Owner: postgres
--

CREATE FUNCTION snap_geometry_to_geometry(INOUT geom_to_snap public.geometry, INOUT target_geom public.geometry, snap_distance double precision, change_target_if_needed boolean, OUT snapped boolean, OUT target_is_changed boolean) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
  i integer;
  nr_elements integer;
  rec record;
  rec2 record;
  point_location float;
  rings geometry[];
  
BEGIN
  target_is_changed = false;
  snapped = false;
  if st_geometrytype(geom_to_snap) not in ('ST_Point', 'ST_LineString', 'ST_Polygon') then
    raise exception 'geom_to_snap not supported. Only point, linestring and polygon is supported.';
  end if;
  if st_geometrytype(geom_to_snap) = 'ST_Point' then
    -- If the geometry to snap is POINT
    if st_geometrytype(target_geom) = 'ST_Point' then
      if st_dwithin(geom_to_snap, target_geom, snap_distance) then
        geom_to_snap = target_geom;
        snapped = true;
      end if;
    elseif st_geometrytype(target_geom) = 'ST_LineString' then
      -- Check first if there is any point of linestring where the point can be snapped.
      select t.* into rec from ST_DumpPoints(target_geom) t where st_dwithin(geom_to_snap, t.geom, snap_distance);
      if rec is not null then
        geom_to_snap = rec.geom;
        snapped = true;
        return;
      end if;
      --Check second if the point is within distance from linestring and get an interpolation point in the line.
      if st_dwithin(geom_to_snap, target_geom, snap_distance) then
        point_location = ST_Line_Locate_Point(target_geom, geom_to_snap);
        geom_to_snap = ST_Line_Interpolate_Point(target_geom, point_location);
        if change_target_if_needed then
          target_geom = ST_LineMerge(ST_Union(ST_Line_Substring(target_geom, 0, point_location), ST_Line_Substring(target_geom, point_location, 1)));
          target_is_changed = true;
        end if;
        snapped = true;  
      end if;
    elseif st_geometrytype(target_geom) = 'ST_Polygon' then
      select  array_agg(ST_ExteriorRing(geom)) into rings from ST_DumpRings(target_geom);
      nr_elements = array_upper(rings,1);
      i = 1;
      while i <= nr_elements loop
        select t.* into rec from cadastre.snap_geometry_to_geometry(geom_to_snap, rings[i], snap_distance, change_target_if_needed) t;
        if rec.snapped then
          geom_to_snap = rec.geom_to_snap;
          snapped = true;
          if change_target_if_needed then
            rings[i] = rec.target_geom;
            target_geom = ST_MakePolygon(rings[1], rings[2:nr_elements]);
            target_is_changed = rec.target_is_changed;
            return;
          end if;
        end if;
        i = i+1;
      end loop;
    end if;
  elseif st_geometrytype(geom_to_snap) = 'ST_LineString' then
    nr_elements = st_npoints(geom_to_snap);
    i = 1;
    while i <= nr_elements loop
      select t.* into rec
        from cadastre.snap_geometry_to_geometry(st_pointn(geom_to_snap,i), target_geom, snap_distance, change_target_if_needed) t;
      if rec.snapped then
        if rec.target_is_changed then
          target_geom= rec.target_geom;
          target_is_changed = true;
        end if;
        geom_to_snap = st_setpoint(geom_to_snap, i-1, rec.geom_to_snap);
        snapped = true;
      end if;
      i = i+1;
    end loop;
    -- For each point of the target checks if it can snap to the geom_to_snap
    for rec in select * from ST_DumpPoints(target_geom) t 
      where st_dwithin(geom_to_snap, t.geom, snap_distance) loop
      select t.* into rec2
        from cadastre.snap_geometry_to_geometry(rec.geom, geom_to_snap, snap_distance, true) t;
      if rec2.target_is_changed then
        geom_to_snap = rec2.target_geom;
        snapped = true;
      end if;
    end loop;
  elseif st_geometrytype(geom_to_snap) = 'ST_Polygon' then
    select  array_agg(ST_ExteriorRing(geom)) into rings from ST_DumpRings(geom_to_snap);
    nr_elements = array_upper(rings,1);
    i = 1;
    while i <= nr_elements loop
      select t.* into rec
        from cadastre.snap_geometry_to_geometry(rings[i], target_geom, snap_distance, change_target_if_needed) t;
      if rec.snapped then
        rings[i] = rec.geom_to_snap;
        if rec.target_is_changed then
          target_geom = rec.target_geom;
          target_is_changed = true;
        end if;
        snapped = true;
      end if;
      i= i+1;
    end loop;
    if snapped then
      geom_to_snap = ST_MakePolygon(rings[1], rings[2:nr_elements]);
    end if;
  end if;
  return;
END;
$$;


ALTER FUNCTION cadastre.snap_geometry_to_geometry(INOUT geom_to_snap public.geometry, INOUT target_geom public.geometry, snap_distance double precision, change_target_if_needed boolean, OUT snapped boolean, OUT target_is_changed boolean) OWNER TO postgres;

--
-- Name: FUNCTION snap_geometry_to_geometry(INOUT geom_to_snap public.geometry, INOUT target_geom public.geometry, snap_distance double precision, change_target_if_needed boolean, OUT snapped boolean, OUT target_is_changed boolean); Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON FUNCTION snap_geometry_to_geometry(INOUT geom_to_snap public.geometry, INOUT target_geom public.geometry, snap_distance double precision, change_target_if_needed boolean, OUT snapped boolean, OUT target_is_changed boolean) IS 'Snaps one geometry to the other adding points if required. Not used by SOLA.';


SET search_path = party, pg_catalog;

--
-- Name: is_rightholder(character varying); Type: FUNCTION; Schema: party; Owner: postgres
--

CREATE FUNCTION is_rightholder(id character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
  return (SELECT (CASE (SELECT COUNT(1) FROM administrative.party_for_rrr ap WHERE ap.party_id = id) WHEN 0 THEN false ELSE true END));
END;
$$;


ALTER FUNCTION party.is_rightholder(id character varying) OWNER TO postgres;

--
-- Name: FUNCTION is_rightholder(id character varying); Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON FUNCTION is_rightholder(id character varying) IS 'Indicates if the party is associated to one or more land rights as a rightholder.';


SET search_path = source, pg_catalog;

--
-- Name: f_for_tbl_source_trg_change_of_status(); Type: FUNCTION; Schema: source; Owner: postgres
--

CREATE FUNCTION f_for_tbl_source_trg_change_of_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  if old.status_code is not null and old.status_code = 'pending' and new.status_code in ( 'current', 'historic') then
      update source.source set 
      status_code= 'previous', change_user=new.change_user
      where la_nr= new.la_nr and status_code = 'current';
  end if;
  return new;
end;
$$;


ALTER FUNCTION source.f_for_tbl_source_trg_change_of_status() OWNER TO postgres;

SET search_path = system, pg_catalog;

--
-- Name: get_setting(character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION get_setting(setting_name character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
begin
  return (select vl from system.setting where name= setting_name);
end;
$$;


ALTER FUNCTION system.get_setting(setting_name character varying) OWNER TO postgres;

--
-- Name: FUNCTION get_setting(setting_name character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION get_setting(setting_name character varying) IS 'Returns the value for a specified system setting.';


--
-- Name: setpassword(character varying, character varying, character varying); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  result int;
BEGIN
  update system.appuser set passwd = pass,
   change_user = changeuser  where username=usrName;
  GET DIAGNOSTICS result = ROW_COUNT;
  return result;
END;
$$;


ALTER FUNCTION system.setpassword(usrname character varying, pass character varying, changeuser character varying) OWNER TO postgres;

--
-- Name: FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying); Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON FUNCTION setpassword(usrname character varying, pass character varying, changeuser character varying) IS 'Changes the users password.';


SET search_path = address, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: address; Type: TABLE; Schema: address; Owner: postgres; Tablespace: 
--

CREATE TABLE address (
    id character varying(40) NOT NULL,
    description character varying(255),
    ext_address_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE address.address OWNER TO postgres;

--
-- Name: TABLE address; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON TABLE address IS 'Describes a postal or physical address.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN address.id; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.id IS 'Address identifier.';


--
-- Name: COLUMN address.description; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.description IS 'The postal or physical address or if no formal addressing is used, a description or place name for the location.';


--
-- Name: COLUMN address.ext_address_id; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.ext_address_id IS 'Optional identifier for the address that may reference further address details from an external system (e.g. address validation database).';


--
-- Name: COLUMN address.rowidentifier; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.rowidentifier IS 'Identifies the all change records for the row in the address_historic table';


--
-- Name: COLUMN address.rowversion; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN address.change_action; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN address.change_user; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN address.change_time; Type: COMMENT; Schema: address; Owner: postgres
--

COMMENT ON COLUMN address.change_time IS 'The date and time the row was last modified.';


--
-- Name: address_historic; Type: TABLE; Schema: address; Owner: postgres; Tablespace: 
--

CREATE TABLE address_historic (
    id character varying(40),
    description character varying(255),
    ext_address_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE address.address_historic OWNER TO postgres;

SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit (
    id character varying(40) NOT NULL,
    type_code character varying(20) DEFAULT 'basicPropertyUnit'::character varying NOT NULL,
    name character varying(255),
    name_firstpart character varying(20) NOT NULL,
    name_lastpart character varying(50) NOT NULL,
    creation_date timestamp without time zone,
    expiration_date timestamp without time zone,
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    transaction_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit OWNER TO postgres;

--
-- Name: TABLE ba_unit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit IS 'A Basic Administrative Unit a.k.a. BA Unit or Property. Used to link the rights and restrictions over one or more parcels to the parties that hold those rights and restrictions. A right must be homogeneous over the entire BA Unit. Implementation of the LADM LA_BAUnit class.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN ba_unit.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.id IS 'LADM Definition: Identifier for the BA Unit.';


--
-- Name: COLUMN ba_unit.type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.type_code IS 'LADM Definition: The type of BA Unit. E.g. basicPropertyUnit, administrativeUnit, etc.';


--
-- Name: COLUMN ba_unit.name; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.name IS 'LADM Definition: The name of the BA Unit. Usually a concatenation of the name_firstpart and name_lastpart formatted as required.';


--
-- Name: COLUMN ba_unit.name_firstpart; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.name_firstpart IS 'SOLA Extension: The first part of the name or reference assigned by the land administration agency to identify the property.';


--
-- Name: COLUMN ba_unit.name_lastpart; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.name_lastpart IS 'SOLA Extension: The remaining part of the name or reference assigned by the land administration agency to identify the property.';


--
-- Name: COLUMN ba_unit.creation_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.creation_date IS 'SOLA Extension: The datetime the BA Unit is formally recognised by the land administration agency (i.e. registered or issued).';


--
-- Name: COLUMN ba_unit.expiration_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.expiration_date IS 'SOLA Extension: The datetime the BA Unit was superseded and became historic.';


--
-- Name: COLUMN ba_unit.status_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.status_code IS 'LADM Definition: The status of the BA unit.';


--
-- Name: COLUMN ba_unit.transaction_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.transaction_id IS 'SOLA Extension: Reference to the SOLA transaction that created the BA Unit.';


--
-- Name: COLUMN ba_unit.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the ba_unit_historic table';


--
-- Name: COLUMN ba_unit.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN ba_unit.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN ba_unit.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN ba_unit.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: ba_unit_area; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_area (
    id character varying(40) NOT NULL,
    ba_unit_id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    size numeric(19,2) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_area OWNER TO postgres;

--
-- Name: TABLE ba_unit_area; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_area IS 'Identifies the overall area of the BA Unit. This should be the sum of all parcel areas that are part of the BA Unit.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN ba_unit_area.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.id IS 'Identifier for the BA Unit Area.';


--
-- Name: COLUMN ba_unit_area.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.ba_unit_id IS 'Identifier for the BA Unit this area value is associated to.';


--
-- Name: COLUMN ba_unit_area.type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.type_code IS 'The type of area. E.g. officialArea, calculatedArea, etc.';


--
-- Name: COLUMN ba_unit_area.size; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.size IS 'The value of the area. Must be in metres squared and can be converted for display if requried.';


--
-- Name: COLUMN ba_unit_area.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.rowidentifier IS 'Identifies the all change records for the row in the ba_unit_area_historic table';


--
-- Name: COLUMN ba_unit_area.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN ba_unit_area.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN ba_unit_area.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN ba_unit_area.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_area.change_time IS 'The date and time the row was last modified.';


--
-- Name: ba_unit_area_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_area_historic (
    id character varying(40),
    ba_unit_id character varying(40),
    type_code character varying(20),
    size numeric(19,2),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_area_historic OWNER TO postgres;

--
-- Name: ba_unit_as_party; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_as_party (
    ba_unit_id character varying(40) NOT NULL,
    party_id character varying(40) NOT NULL
);


ALTER TABLE administrative.ba_unit_as_party OWNER TO postgres;

--
-- Name: TABLE ba_unit_as_party; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_as_party IS 'Associates BA Unit directly to Party. Implementation of the LADM LA_BAUnit to LA_Party relationship. Not used by SOLA.
Tags: LADM Reference Object, Not Used';


--
-- Name: COLUMN ba_unit_as_party.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_as_party.ba_unit_id IS 'Identifier for the BA Unit.';


--
-- Name: COLUMN ba_unit_as_party.party_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_as_party.party_id IS 'Identifier for the Party.';


--
-- Name: ba_unit_contains_spatial_unit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_contains_spatial_unit (
    ba_unit_id character varying(40) NOT NULL,
    spatial_unit_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_contains_spatial_unit OWNER TO postgres;

--
-- Name: TABLE ba_unit_contains_spatial_unit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_contains_spatial_unit IS 'Associates BA Unit with Spatial Unit. Indicates the parcels that comprise the BA Unit. Implementation of the LA_BAUnit to LA_SpatialUnit relationship.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.ba_unit_id IS 'Identifier for the BA Unit.';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.spatial_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.spatial_unit_id IS 'Identifier for the Spatial Unit associated to the BA Unit.';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.rowidentifier IS 'Identifies the all change records for the row in the ba_unit_contains_spatial_unit_historic table';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN ba_unit_contains_spatial_unit.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_contains_spatial_unit.change_time IS 'The date and time the row was last modified.';


--
-- Name: ba_unit_contains_spatial_unit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_contains_spatial_unit_historic (
    ba_unit_id character varying(40),
    spatial_unit_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_contains_spatial_unit_historic OWNER TO postgres;

--
-- Name: ba_unit_first_name_part_seq; Type: SEQUENCE; Schema: administrative; Owner: postgres
--

CREATE SEQUENCE ba_unit_first_name_part_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 10000
    CACHE 1;


ALTER TABLE administrative.ba_unit_first_name_part_seq OWNER TO postgres;

--
-- Name: SEQUENCE ba_unit_first_name_part_seq; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON SEQUENCE ba_unit_first_name_part_seq IS 'Sequence number used as the basis for the BA Unit first name part. This sequence is used by the generate-baunit-nr business rule.';


--
-- Name: ba_unit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_historic (
    id character varying(40),
    type_code character varying(20),
    name character varying(255),
    name_firstpart character varying(20),
    name_lastpart character varying(50),
    creation_date timestamp without time zone,
    expiration_date timestamp without time zone,
    status_code character varying(20),
    transaction_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_historic OWNER TO postgres;

--
-- Name: ba_unit_rel_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_rel_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL
);


ALTER TABLE administrative.ba_unit_rel_type OWNER TO postgres;

--
-- Name: TABLE ba_unit_rel_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_rel_type IS 'Code list of BA Unit relationship types. Identifies the type of relationship between two BA Units. E.g. priorTitle, rootTitle, etc. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN ba_unit_rel_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_rel_type.code IS 'The code for the relationship type.';


--
-- Name: COLUMN ba_unit_rel_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_rel_type.display_value IS 'Displayed value of the relationship type.';


--
-- Name: COLUMN ba_unit_rel_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_rel_type.description IS 'Description of the relationship type.';


--
-- Name: COLUMN ba_unit_rel_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_rel_type.status IS 'Status of the relationship type.';


--
-- Name: ba_unit_target; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_target (
    ba_unit_id character varying(40) NOT NULL,
    transaction_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_target OWNER TO postgres;

--
-- Name: TABLE ba_unit_target; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_target IS 'Identifies existing BA Units that are included in a transaction. Used by SOLA to mark existing BA Units for cancellation when the transaction is approved. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN ba_unit_target.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.ba_unit_id IS 'Identifier for the BA Unit.';


--
-- Name: COLUMN ba_unit_target.transaction_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.transaction_id IS 'Identifier for the transaction to cancel the BA Unit.';


--
-- Name: COLUMN ba_unit_target.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.rowidentifier IS 'Identifies the all change records for the row in the ba_unit_target_historic table';


--
-- Name: COLUMN ba_unit_target.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN ba_unit_target.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN ba_unit_target.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN ba_unit_target.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_target.change_time IS 'The date and time the row was last modified.';


--
-- Name: ba_unit_target_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_target_historic (
    ba_unit_id character varying(40),
    transaction_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.ba_unit_target_historic OWNER TO postgres;

--
-- Name: ba_unit_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE ba_unit_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE administrative.ba_unit_type OWNER TO postgres;

--
-- Name: TABLE ba_unit_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE ba_unit_type IS 'Code list of BA Unit types. E.g. priorTitle, rootTitle, etc. Implementation of the LADM LA_BAUnitType class.
Tags: LADM Reference Object, Reference Table';


--
-- Name: COLUMN ba_unit_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_type.code IS 'LADM Defintion: The code for the BA Unit type.';


--
-- Name: COLUMN ba_unit_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_type.display_value IS 'LADM Defintion: Displayed value of the BA Unit type.';


--
-- Name: COLUMN ba_unit_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_type.description IS 'LADM Defintion: Description of the BA Unit type.';


--
-- Name: COLUMN ba_unit_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN ba_unit_type.status IS 'SOLA Extension: Status of the BA Unit type.';


--
-- Name: certificate_print; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE certificate_print (
    id character varying(40) NOT NULL,
    ba_unit_id character varying(40),
    certificate_type character varying(40),
    print_time timestamp without time zone,
    print_user character varying(40),
    comment character varying(500)
);


ALTER TABLE administrative.certificate_print OWNER TO postgres;

--
-- Name: TABLE certificate_print; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE certificate_print IS 'Records a complete history of when a Computer Folio Certifcate is printed for a property. 
  SOLA Samoa Extension';


--
-- Name: COLUMN certificate_print.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN certificate_print.id IS 'Identifier for the certificate print table ';


--
-- Name: COLUMN certificate_print.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN certificate_print.ba_unit_id IS 'The identifier of the ba_unit that had a certificate printed. ';


--
-- Name: COLUMN certificate_print.certificate_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN certificate_print.certificate_type IS 'The type of certificate that was printed. One of Folio Certificate, Staff Search or Historical Search';


--
-- Name: COLUMN certificate_print.print_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN certificate_print.print_time IS 'The time the certificate was generated. ';


--
-- Name: COLUMN certificate_print.print_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN certificate_print.print_user IS 'The user that printed the certificate. ';


--
-- Name: COLUMN certificate_print.comment; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN certificate_print.comment IS 'Any comment relating to the print such as the client name';


--
-- Name: mortgage_isbased_in_rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE mortgage_isbased_in_rrr (
    mortgage_id character varying(40) NOT NULL,
    rrr_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.mortgage_isbased_in_rrr OWNER TO postgres;

--
-- Name: TABLE mortgage_isbased_in_rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE mortgage_isbased_in_rrr IS 'Identifies RRR that is subject to mortgage. Implementation of the LA_Mortgage to LA_Right relationship. Not used by SOLA as the primary right will always be the subject of the mortgage.
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN mortgage_isbased_in_rrr.mortgage_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.mortgage_id IS 'Identifier for the mortgage';


--
-- Name: COLUMN mortgage_isbased_in_rrr.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.rrr_id IS 'Identifier for the RRR associated to the mortgage.';


--
-- Name: COLUMN mortgage_isbased_in_rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.rowidentifier IS 'Identifies the all change records for the row in the ba_unit_contains_spatial_unit_historic table';


--
-- Name: COLUMN mortgage_isbased_in_rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN mortgage_isbased_in_rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN mortgage_isbased_in_rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN mortgage_isbased_in_rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_isbased_in_rrr.change_time IS 'The date and time the row was last modified.';


--
-- Name: mortgage_isbased_in_rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE mortgage_isbased_in_rrr_historic (
    mortgage_id character varying(40),
    rrr_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.mortgage_isbased_in_rrr_historic OWNER TO postgres;

--
-- Name: mortgage_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE mortgage_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL
);


ALTER TABLE administrative.mortgage_type OWNER TO postgres;

--
-- Name: TABLE mortgage_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE mortgage_type IS 'Code list of Mortgage types. E.g. levelPayment, linear, etc. Implementation of the LADM LA_MortgageType class.
Tags: LADM Reference Object, Reference Table';


--
-- Name: COLUMN mortgage_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_type.code IS 'LADM Defintion: The code for the mortgage type.';


--
-- Name: COLUMN mortgage_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_type.display_value IS 'LADM Defintion: Displayed value of the mortgage type.';


--
-- Name: COLUMN mortgage_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_type.description IS 'LADM Defintion: Description of the mortgage type.';


--
-- Name: COLUMN mortgage_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN mortgage_type.status IS 'SOLA Extension: Status of the mortgage type.';


--
-- Name: notation; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE notation (
    id character varying(40) NOT NULL,
    ba_unit_id character varying(40),
    rrr_id character varying(40),
    transaction_id character varying(40) NOT NULL,
    reference_nr character varying(15) NOT NULL,
    notation_text character varying(1000),
    notation_date timestamp without time zone,
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.notation OWNER TO postgres;

--
-- Name: TABLE notation; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE notation IS 'Notations (a.k.a memorials) are text that summarise the affect a transaction has to a property/title. SOLA automatically creates template notations for every RRR change.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN notation.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.id IS 'Identifier for the notation.';


--
-- Name: COLUMN notation.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.ba_unit_id IS 'Identifier of the BA Unit the notation is associated with. Only populated if the notation is linked directly to the BA Unit. NULL if the notation is associated with an RRR.';


--
-- Name: COLUMN notation.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.rrr_id IS 'Identifier of the RRR the notation is assocaited with. Must not be populated if ba_unit_id is populated.';


--
-- Name: COLUMN notation.transaction_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.transaction_id IS 'Identifier of the transaction that created the notation.';


--
-- Name: COLUMN notation.reference_nr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.reference_nr IS 'The notation reference number. Value determined using the generate-notation-reference-nr business rule.';


--
-- Name: COLUMN notation.notation_text; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.notation_text IS 'The text of the notation. Note that template notation text can be obtained from the request type (i.e. service) the notation has been created as part of.';


--
-- Name: COLUMN notation.notation_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.notation_date IS 'The date the notation is formalised/registered.';


--
-- Name: COLUMN notation.status_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.status_code IS 'The status of the notation.';


--
-- Name: COLUMN notation.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.rowidentifier IS 'Identifies the all change records for the row in the notation_historic table';


--
-- Name: COLUMN notation.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN notation.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN notation.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN notation.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN notation.change_time IS 'The date and time the row was last modified.';


--
-- Name: notation_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE notation_historic (
    id character varying(40),
    ba_unit_id character varying(40),
    rrr_id character varying(40),
    transaction_id character varying(40),
    reference_nr character varying(15),
    notation_text character varying(1000),
    notation_date timestamp without time zone,
    status_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.notation_historic OWNER TO postgres;

--
-- Name: notation_reference_nr_seq; Type: SEQUENCE; Schema: administrative; Owner: postgres
--

CREATE SEQUENCE notation_reference_nr_seq
    START WITH 200000
    INCREMENT BY 1
    MINVALUE 200000
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE administrative.notation_reference_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE notation_reference_nr_seq; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON SEQUENCE notation_reference_nr_seq IS 'Sequence number used as the basis for the Notation Nr field. This sequence is used by the generate-notation-reference-nr business rule.';


--
-- Name: party_for_rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE party_for_rrr (
    rrr_id character varying(40) NOT NULL,
    party_id character varying(40) NOT NULL,
    share_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.party_for_rrr OWNER TO postgres;

--
-- Name: TABLE party_for_rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE party_for_rrr IS 'Identifies the parties involved in each RRR. Also identifies the share each party has in the RRR if the RRR is subject to shared allocation.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN party_for_rrr.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.rrr_id IS 'Identifier for the RRR.';


--
-- Name: COLUMN party_for_rrr.party_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.party_id IS 'Identifier for the party associated to the RRR.';


--
-- Name: COLUMN party_for_rrr.share_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.share_id IS 'Identifier for the share the party has in the RRR. Not populated unless the RRR is subject to a shared allocation. E.g. Mortgage RRR does not have shares.';


--
-- Name: COLUMN party_for_rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.rowidentifier IS 'Identifies the all change records for the row in the party_for_rrr_historic table';


--
-- Name: COLUMN party_for_rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_for_rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_for_rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN party_for_rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN party_for_rrr.change_time IS 'The date and time the row was last modified.';


--
-- Name: party_for_rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE party_for_rrr_historic (
    rrr_id character varying(40),
    party_id character varying(40),
    share_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.party_for_rrr_historic OWNER TO postgres;

--
-- Name: required_relationship_baunit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE required_relationship_baunit (
    from_ba_unit_id character varying(40) NOT NULL,
    to_ba_unit_id character varying(40) NOT NULL,
    relation_code character varying(20) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.required_relationship_baunit OWNER TO postgres;

--
-- Name: TABLE required_relationship_baunit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE required_relationship_baunit IS 'Identifies relationships between BA Units. Implementation of the LADM LA_RequiredRelationshipBAUnit class. Used by SOLA to represent a range of relationships such as linking a new BA Unit to the BA Unit it supersedes (a.k.a Prior Title) as well as geographic relationships such as all property within a village, or all villages within a region or island, etc. 
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN required_relationship_baunit.from_ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.from_ba_unit_id IS 'The originating BA Unit (a.k.a. parent BA Unit). Usually a parent BA Unit will have multiple child BA Units associted to it. E.g. Island/region is the parent BA Unit for a town';


--
-- Name: COLUMN required_relationship_baunit.to_ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.to_ba_unit_id IS 'The target BA Unit (a.k.a. child BA Unit). For any given relationship type, the child BA Unit will usually only have one logical parent BA Unit. E.g. A new title is the child BA Unit of the original title that is being superseded.';


--
-- Name: COLUMN required_relationship_baunit.relation_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.relation_code IS 'Code that identifies the type of relationship between the two BA Units.';


--
-- Name: COLUMN required_relationship_baunit.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.rowidentifier IS 'Identifies the all change records for the row in the required_relationship_baunit_historic table';


--
-- Name: COLUMN required_relationship_baunit.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN required_relationship_baunit.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN required_relationship_baunit.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN required_relationship_baunit.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN required_relationship_baunit.change_time IS 'The date and time the row was last modified.';


--
-- Name: required_relationship_baunit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE required_relationship_baunit_historic (
    from_ba_unit_id character varying(40),
    to_ba_unit_id character varying(40),
    relation_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.required_relationship_baunit_historic OWNER TO postgres;

--
-- Name: rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr (
    id character varying(40) NOT NULL,
    ba_unit_id character varying(40) NOT NULL,
    nr character varying(20) NOT NULL,
    type_code character varying(20) NOT NULL,
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    transaction_id character varying(40) NOT NULL,
    registration_date timestamp without time zone,
    expiration_date timestamp without time zone,
    share double precision,
    mortgage_amount numeric(29,2),
    mortgage_interest_rate numeric(5,2),
    mortgage_ranking integer,
    mortgage_type_code character varying(20),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    source_rrr character varying(40)
);


ALTER TABLE administrative.rrr OWNER TO postgres;

--
-- Name: TABLE rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE rrr IS 'RRR are the specific rights, restrictions and responsibilities that can be registered on a property e.g. freehold ownership, lease, mortgage, caveat, etc. Implementation of the LADM LA_RRR class.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN rrr.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.id IS 'LADM Definition: Identifier for the RRR';


--
-- Name: COLUMN rrr.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.ba_unit_id IS 'LADM Definition: Identifier for the BA Unit the RRR applies to.';


--
-- Name: COLUMN rrr.nr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.nr IS 'SOLA Extension: Number to identify the RRR. Determined by the generate-rrr-nr business rule. This value is used to track the different versions of the RRR as it is edited over time.';


--
-- Name: COLUMN rrr.type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.type_code IS 'LADM Definition: The type of RRR. E.g. freehold ownership, lease, mortage, caveat, etc.';


--
-- Name: COLUMN rrr.status_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.status_code IS 'SOLA Extension: The status of the RRR.';


--
-- Name: COLUMN rrr.is_primary; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.is_primary IS 'SOLA Extension. Flag it indicate if the RRR is the primary RRR for the BA Unit. One one of the current RRRs on the BA Unit can be flagged as the primary RRR.';


--
-- Name: COLUMN rrr.transaction_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.transaction_id IS 'SOLA Extension: Identifier of the transaction that created the RRR.';


--
-- Name: COLUMN rrr.registration_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.registration_date IS 'SOLA Extension: The date and time the RRR was formally registered by the Land Administration Agency.';


--
-- Name: COLUMN rrr.expiration_date; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.expiration_date IS 'LADM Definition: The date and time defining when the RRR remains in force to. Implementation of the LADM LA_RRR.timespec field.';


--
-- Name: COLUMN rrr.share; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.share IS 'LADM Defintion: Share of the RRR expressed as a fraction with numerator and denominator. Not used by SOLA as shares in rights are represetned in the rrr_share table. This avoids having multiple RRR of the same type on the BA Unit that only differ by share amounts.';


--
-- Name: COLUMN rrr.mortgage_amount; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.mortgage_amount IS 'LADM Definition: The value of the mortgage. SOLA Extension: The amount associated with the RRR. E.g the value of the mortgage, the rental amount for a lease, etc.';


--
-- Name: COLUMN rrr.mortgage_interest_rate; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.mortgage_interest_rate IS 'LADM Definition: The interest rate of the mortgage as a percentage.';


--
-- Name: COLUMN rrr.mortgage_ranking; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.mortgage_ranking IS 'LADM Definition: The ranking order if more than one mortgage applies to the right.';


--
-- Name: COLUMN rrr.mortgage_type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.mortgage_type_code IS 'LADM Definition: The type of mortgage.';


--
-- Name: COLUMN rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the rrr_historic table';


--
-- Name: COLUMN rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: COLUMN rrr.source_rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr.source_rrr IS 'SOLA Extension: Used by the administrative.create_strata_properties prodcedure to determine the source RRR used to create the new rrr for a unit parcel property.';


--
-- Name: rrr_group_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_group_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL
);


ALTER TABLE administrative.rrr_group_type OWNER TO postgres;

--
-- Name: TABLE rrr_group_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE rrr_group_type IS 'Code list of RRR group types. Used to identify if an RRR is a responsibility, right or restriction. SOLA''s representation of the LADM LA_Responsibility, LA_Right and LA_Restriction classes.
Tags: LADM Reference Object, Reference Table';


--
-- Name: COLUMN rrr_group_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_group_type.code IS 'LADM Defintion: The code for the RRR group type.';


--
-- Name: COLUMN rrr_group_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_group_type.display_value IS 'LADM Defintion: Displayed value of the RRR group type.';


--
-- Name: COLUMN rrr_group_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_group_type.description IS 'LADM Defintion: Description of the RRR group type.';


--
-- Name: COLUMN rrr_group_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_group_type.status IS 'SOLA Extension: Status of the RRR group type.';


--
-- Name: rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_historic (
    id character varying(40),
    ba_unit_id character varying(40),
    nr character varying(20),
    type_code character varying(20),
    status_code character varying(20),
    is_primary boolean,
    transaction_id character varying(40),
    registration_date timestamp without time zone,
    expiration_date timestamp without time zone,
    share double precision,
    mortgage_amount numeric(29,2),
    mortgage_interest_rate numeric(5,2),
    mortgage_ranking integer,
    mortgage_type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    source_rrr character varying(40)
);


ALTER TABLE administrative.rrr_historic OWNER TO postgres;

--
-- Name: rrr_nr_seq; Type: SEQUENCE; Schema: administrative; Owner: postgres
--

CREATE SEQUENCE rrr_nr_seq
    START WITH 200000
    INCREMENT BY 1
    MINVALUE 200000
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE administrative.rrr_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE rrr_nr_seq; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON SEQUENCE rrr_nr_seq IS 'Sequence number used as the basis for the RRR Nr field. This sequence is used by the generate-rrr-nr business rule.';


--
-- Name: rrr_share; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_share (
    rrr_id character varying(40) NOT NULL,
    id character varying(40) NOT NULL,
    nominator smallint NOT NULL,
    denominator smallint NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    source_rrr_share character varying(40)
);


ALTER TABLE administrative.rrr_share OWNER TO postgres;

--
-- Name: TABLE rrr_share; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE rrr_share IS 'Identifies the share a party has in an RRR. Implementation of the LADM LA_RRR.share field.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN rrr_share.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.rrr_id IS 'Identifier of the RRR the share is assocaited with.';


--
-- Name: COLUMN rrr_share.id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.id IS 'Identifier for the RRR share.';


--
-- Name: COLUMN rrr_share.nominator; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.nominator IS 'Nominiator part of the share (i.e. top number of fraction)';


--
-- Name: COLUMN rrr_share.denominator; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.denominator IS 'Denominator part of the share (i.e. bottom number of fraction)';


--
-- Name: COLUMN rrr_share.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.rowidentifier IS 'Identifies the all change records for the row in the rrr_share_historic table';


--
-- Name: COLUMN rrr_share.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN rrr_share.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN rrr_share.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN rrr_share.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN rrr_share.source_rrr_share; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_share.source_rrr_share IS 'SOLA Extension: Used by the administrative.create_strata_properties prodcedure to determine the source RRR share used to create the new rrr share for a unit parcel property.';


--
-- Name: rrr_share_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_share_historic (
    rrr_id character varying(40),
    id character varying(40),
    nominator smallint,
    denominator smallint,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    source_rrr_share character varying(40)
);


ALTER TABLE administrative.rrr_share_historic OWNER TO postgres;

--
-- Name: rrr_type; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE rrr_type (
    code character varying(20) NOT NULL,
    rrr_group_type_code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    share_check boolean NOT NULL,
    party_required boolean NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE administrative.rrr_type OWNER TO postgres;

--
-- Name: TABLE rrr_type; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE rrr_type IS 'Code list of RRR types. E.g. freehold owernship, lease, mortgage, caveat, etc. Implementation of the LADM LA_ResponsibilityType, LA_RightType and LA_RestrictionType classes.
Tags: LADM Reference Object, Reference Table';


--
-- Name: COLUMN rrr_type.code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.code IS 'LADM Defintion: The code for the RRR type.';


--
-- Name: COLUMN rrr_type.rrr_group_type_code; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.rrr_group_type_code IS 'LADM Defintion: Identifies if the RRR type is a right, restriction or a responsibility.';


--
-- Name: COLUMN rrr_type.display_value; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.display_value IS 'LADM Defintion: Displayed value of the RRR type.';


--
-- Name: COLUMN rrr_type.is_primary; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.is_primary IS 'SOLA Extension: Flag to indicate if the RRR type is a primary RRR.';


--
-- Name: COLUMN rrr_type.share_check; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.share_check IS 'LADM Defintion: Flag to indicate the that the sum of all shares for the RRR must be checked to ensure it equals 1.';


--
-- Name: COLUMN rrr_type.party_required; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.party_required IS 'LADM Defintion: Flag to indicate at least one party must be associated with this RRR.';


--
-- Name: COLUMN rrr_type.description; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.description IS 'LADM Defintion: Description of the RRR type.';


--
-- Name: COLUMN rrr_type.status; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN rrr_type.status IS 'SOLA Extension: Status of the RRR type.';


--
-- Name: source_describes_ba_unit; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_ba_unit (
    source_id character varying(40) NOT NULL,
    ba_unit_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.source_describes_ba_unit OWNER TO postgres;

--
-- Name: TABLE source_describes_ba_unit; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE source_describes_ba_unit IS 'Associates a BA Unit with one or more source (a.k.a. document) records. Implementation of the LADM LA_BAUnit to LA_AdministrativeSource relationship.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN source_describes_ba_unit.source_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.source_id IS 'Identifier for the source associated with the BA Unit.';


--
-- Name: COLUMN source_describes_ba_unit.ba_unit_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.ba_unit_id IS 'Identifier for the BA Unit.';


--
-- Name: COLUMN source_describes_ba_unit.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.rowidentifier IS 'Identifies the all change records for the row in the source_describes_ba_unit_historic table';


--
-- Name: COLUMN source_describes_ba_unit.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN source_describes_ba_unit.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN source_describes_ba_unit.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN source_describes_ba_unit.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_ba_unit.change_time IS 'The date and time the row was last modified.';


--
-- Name: source_describes_ba_unit_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_ba_unit_historic (
    source_id character varying(40),
    ba_unit_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.source_describes_ba_unit_historic OWNER TO postgres;

--
-- Name: source_describes_rrr; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_rrr (
    rrr_id character varying(40) NOT NULL,
    source_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.source_describes_rrr OWNER TO postgres;

--
-- Name: TABLE source_describes_rrr; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON TABLE source_describes_rrr IS 'Associates a RRR with one or more source (a.k.a. document) records. Implementation of the LADM LA_RRR to LA_AdministrativeSource relationship.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN source_describes_rrr.rrr_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.rrr_id IS 'Identifier for the RRR.';


--
-- Name: COLUMN source_describes_rrr.source_id; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.source_id IS 'Identifier for the source associated with the RRR.';


--
-- Name: COLUMN source_describes_rrr.rowidentifier; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.rowidentifier IS 'Identifies the all change records for the row in the source_describes_ba_unit_historic table';


--
-- Name: COLUMN source_describes_rrr.rowversion; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN source_describes_rrr.change_action; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN source_describes_rrr.change_user; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN source_describes_rrr.change_time; Type: COMMENT; Schema: administrative; Owner: postgres
--

COMMENT ON COLUMN source_describes_rrr.change_time IS 'The date and time the row was last modified.';


--
-- Name: source_describes_rrr_historic; Type: TABLE; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE TABLE source_describes_rrr_historic (
    rrr_id character varying(40),
    source_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE administrative.source_describes_rrr_historic OWNER TO postgres;

SET search_path = application, pg_catalog;

--
-- Name: application; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application (
    id character varying(40) NOT NULL,
    nr character varying(15) NOT NULL,
    agent_id character varying(40) NOT NULL,
    contact_person_id character varying(40),
    lodging_datetime timestamp without time zone DEFAULT now() NOT NULL,
    expected_completion_date date DEFAULT now() NOT NULL,
    assignee_id character varying(40),
    assigned_datetime timestamp without time zone,
    location public.geometry,
    services_fee numeric(20,2) DEFAULT 0 NOT NULL,
    tax numeric(20,2) DEFAULT 0 NOT NULL,
    total_fee numeric(20,2) DEFAULT 0 NOT NULL,
    total_amount_paid numeric(20,2) DEFAULT 0 NOT NULL,
    fee_paid boolean DEFAULT false NOT NULL,
    action_code character varying(20) DEFAULT 'lodge'::character varying NOT NULL,
    action_notes character varying(255),
    status_code character varying(20) DEFAULT 'lodged'::character varying NOT NULL,
    receipt_reference character varying(100),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    new_lots integer DEFAULT 0 NOT NULL,
    CONSTRAINT application_check_assigned CHECK ((((assignee_id IS NULL) AND (assigned_datetime IS NULL)) OR ((assignee_id IS NOT NULL) AND (assigned_datetime IS NOT NULL)))),
    CONSTRAINT enforce_dims_location CHECK ((public.st_ndims(location) = 2)),
    CONSTRAINT enforce_geotype_location CHECK (((public.geometrytype(location) = 'MULTIPOINT'::text) OR (location IS NULL))),
    CONSTRAINT enforce_srid_location CHECK ((public.st_srid(location) = 32702)),
    CONSTRAINT enforce_valid_location CHECK (public.st_isvalid(location))
);


ALTER TABLE application.application OWNER TO postgres;

--
-- Name: TABLE application; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application IS 'Applications capture details and manage requests received by the land administration agency to change, update or report on land registry and/or cadastre information. Applications have a lifecycle and transition into different states as the land administration agency processes the request that instigated the application. The primary role of an application is to implement case management functionality in SOLA.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN application.id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.id IS 'Identifier for the application.';


--
-- Name: COLUMN application.nr; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.nr IS 'The application number displayed to end users. Generated by the generate-application-nr business rule when the application record is initially saved.';


--
-- Name: COLUMN application.agent_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.agent_id IS 'Identifier of the party (individual or organization) that is requesting information or changes to the land registry and/or cadastre information recorded in SOLA. This could be a lawyer or surveyor under instruction from the property owner, the property owner themselves or a third party with a vested interest in a particular property.';


--
-- Name: COLUMN application.contact_person_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.contact_person_id IS 'The person to contact in regard to the application. This person is considered the applicant.';


--
-- Name: COLUMN application.lodging_datetime; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.lodging_datetime IS 'The lodging date and time of the application. This date identifies when the application is officially accepted by the land administration agency.';


--
-- Name: COLUMN application.expected_completion_date; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.expected_completion_date IS 'The date the application should be completed by. This value is determined from the maximum service expected completion date associated with the application.';


--
-- Name: COLUMN application.assignee_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.assignee_id IS 'The identifier of the user assigned to the application. If this value is null, then the application is unassigned.';


--
-- Name: COLUMN application.assigned_datetime; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.assigned_datetime IS 'The date and time the application was last assigned to a user.';


--
-- Name: COLUMN application.location; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.location IS 'The approximate geographic location of the application. The user may indicate more than one point if the application affects a large number of parcels.';


--
-- Name: COLUMN application.services_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.services_fee IS 'The sum of all service fees.';


--
-- Name: COLUMN application.tax; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.tax IS 'The tax applicable based on the services fee.';


--
-- Name: COLUMN application.total_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.total_fee IS 'The sum of the services_fee and tax.';


--
-- Name: COLUMN application.total_amount_paid; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.total_amount_paid IS 'The amount paid by the applicant. Usually will be the full amount (total_fee), but can be a partial payment if the land administration agency accepts partial payments.';


--
-- Name: COLUMN application.fee_paid; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.fee_paid IS 'Flag to indicate a sufficient amount (or all) of the fee has been paid. Once set, the application can be assigned and worked on.';


--
-- Name: COLUMN application.action_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.action_code IS 'The last action that happended to the application. E.g. lodged, assigned, validated, approved, etc.';


--
-- Name: COLUMN application.action_notes; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.action_notes IS 'Optional description of the action.';


--
-- Name: COLUMN application.status_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.status_code IS 'The status of the application.';


--
-- Name: COLUMN application.receipt_reference; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.receipt_reference IS 'The number of the receipt issued as proof of payment. If more than one receipt is issued in the case of part payments, the receipts numbers can be listed in this feild separated by commas.';


--
-- Name: COLUMN application.rowidentifier; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.rowidentifier IS 'Identifies the all change records for the row in the application_historic table';


--
-- Name: COLUMN application.rowversion; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN application.change_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN application.change_user; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN application.change_time; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN application.new_lots; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application.new_lots IS 'SOLA Samoa Extension - Indicates the number of new lots being created by the survey. Required to determine the fee for the survey.';


--
-- Name: application_action_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_action_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status_to_set character varying(20),
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE application.application_action_type OWNER TO postgres;

--
-- Name: TABLE application_action_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_action_type IS 'Code list of action types.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN application_action_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_action_type.code IS 'The code for the application action type.';


--
-- Name: COLUMN application_action_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_action_type.display_value IS 'Displayed value of the application action type.';


--
-- Name: COLUMN application_action_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_action_type.status IS 'Status of the application action type';


--
-- Name: COLUMN application_action_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_action_type.description IS 'Description of the application action type.';


--
-- Name: application_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_historic (
    id character varying(40),
    nr character varying(15),
    agent_id character varying(40),
    contact_person_id character varying(40),
    lodging_datetime timestamp without time zone,
    expected_completion_date date,
    assignee_id character varying(40),
    assigned_datetime timestamp without time zone,
    location public.geometry,
    services_fee numeric(20,2),
    tax numeric(20,2),
    total_fee numeric(20,2),
    total_amount_paid numeric(20,2),
    fee_paid boolean,
    action_code character varying(20),
    action_notes character varying(255),
    status_code character varying(20),
    receipt_reference character varying(100),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    new_lots integer DEFAULT 0 NOT NULL,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_location CHECK ((public.st_ndims(location) = 2)),
    CONSTRAINT enforce_geotype_location CHECK (((public.geometrytype(location) = 'MULTIPOINT'::text) OR (location IS NULL))),
    CONSTRAINT enforce_srid_location CHECK ((public.st_srid(location) = 32702)),
    CONSTRAINT enforce_valid_location CHECK (public.st_isvalid(location))
);


ALTER TABLE application.application_historic OWNER TO postgres;

--
-- Name: application_property; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_property (
    id character varying(40) NOT NULL,
    application_id character varying(40) NOT NULL,
    name_firstpart character varying(20) NOT NULL,
    name_lastpart character varying(20) NOT NULL,
    area numeric(20,2) DEFAULT 0 NOT NULL,
    total_value numeric(20,2) DEFAULT 0 NOT NULL,
    verified_exists boolean DEFAULT false NOT NULL,
    verified_location boolean DEFAULT false NOT NULL,
    ba_unit_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_property OWNER TO postgres;

--
-- Name: TABLE application_property; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_property IS 'Captures details of property associated to an application.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN application_property.id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.id IS 'Identifier for the application property.';


--
-- Name: COLUMN application_property.application_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.application_id IS 'Identifier for the application the record is associated to.';


--
-- Name: COLUMN application_property.name_firstpart; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.name_firstpart IS 'The first part of the name or reference assigned by the land administration agency to identify the property.';


--
-- Name: COLUMN application_property.name_lastpart; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.name_lastpart IS 'The remaining part of the name or reference assigned by the land administration agency to identify the property.';


--
-- Name: COLUMN application_property.area; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.area IS 'The area of the property. This value should be square meters and converted if required for display to the user. e.g. Converted on display into and imperial acres, roods and perches value.';


--
-- Name: COLUMN application_property.total_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.total_value IS 'The land or property value (may vary from jurisdiction to jurisdiction) on which a proportionate service fee can be calculated.';


--
-- Name: COLUMN application_property.verified_exists; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.verified_exists IS 'Flag to indicate if the property details provided for the application match an existing property record in the BA Unit table. ';


--
-- Name: COLUMN application_property.verified_location; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.verified_location IS 'Flag to indicate if the property details provided for the application reference an existing parcel record in the Cadastre Object table.';


--
-- Name: COLUMN application_property.ba_unit_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.ba_unit_id IS 'Reference to a record in the BA Unit table that matches the property details provided for the application.';


--
-- Name: COLUMN application_property.rowidentifier; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.rowidentifier IS 'Identifies the all change records for the row in the application_property_historic table';


--
-- Name: COLUMN application_property.rowversion; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN application_property.change_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN application_property.change_user; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN application_property.change_time; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_property.change_time IS 'The date and time the row was last modified.';


--
-- Name: application_property_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_property_historic (
    id character varying(40),
    application_id character varying(40),
    name_firstpart character varying(20),
    name_lastpart character varying(20),
    area numeric(20,2),
    total_value numeric(20,2),
    verified_exists boolean,
    verified_location boolean,
    ba_unit_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_property_historic OWNER TO postgres;

--
-- Name: application_status_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE application.application_status_type OWNER TO postgres;

--
-- Name: TABLE application_status_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_status_type IS 'Code list of application status types.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN application_status_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_status_type.code IS 'The code for the application status type.';


--
-- Name: COLUMN application_status_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_status_type.display_value IS 'Displayed value of the application status type.';


--
-- Name: COLUMN application_status_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_status_type.status IS 'Status of the application status type';


--
-- Name: COLUMN application_status_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_status_type.description IS 'Description of the application status type.';


--
-- Name: application_uses_source; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_uses_source (
    application_id character varying(40) NOT NULL,
    source_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_uses_source OWNER TO postgres;

--
-- Name: TABLE application_uses_source; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE application_uses_source IS 'Links the application to the sources (a.k.a. documents) submitted with the application. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN application_uses_source.application_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.application_id IS 'Identifier for the application the record is associated to.';


--
-- Name: COLUMN application_uses_source.source_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.source_id IS 'Identifier of the source associated to the application.';


--
-- Name: COLUMN application_uses_source.rowidentifier; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.rowidentifier IS 'Identifies the all change records for the row in the application_spatial_unit_historic table';


--
-- Name: COLUMN application_uses_source.rowversion; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN application_uses_source.change_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN application_uses_source.change_user; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN application_uses_source.change_time; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN application_uses_source.change_time IS 'The date and time the row was last modified.';


--
-- Name: application_uses_source_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE application_uses_source_historic (
    application_id character varying(40),
    source_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.application_uses_source_historic OWNER TO postgres;

--
-- Name: dealing_nr_seq; Type: SEQUENCE; Schema: application; Owner: postgres
--

CREATE SEQUENCE dealing_nr_seq
    START WITH 39500
    INCREMENT BY 1
    MINVALUE 39500
    MAXVALUE 99999
    CACHE 1;


ALTER TABLE application.dealing_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE dealing_nr_seq; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON SEQUENCE dealing_nr_seq IS 'Sequence number used as the basis for the Application nr field when the type of application is a dealing (i.e. Registration Service). This sequence is used by the generate-application-nr business rule.';


--
-- Name: information_nr_seq; Type: SEQUENCE; Schema: application; Owner: postgres
--

CREATE SEQUENCE information_nr_seq
    START WITH 100000
    INCREMENT BY 1
    MINVALUE 100000
    MAXVALUE 119999
    CACHE 1;


ALTER TABLE application.information_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE information_nr_seq; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON SEQUENCE information_nr_seq IS 'Sequence number used as the basis for the Application nr field when the application is for information services. This sequence is used by the generate-application-nr business rule.';


--
-- Name: non_register_nr_seq; Type: SEQUENCE; Schema: application; Owner: postgres
--

CREATE SEQUENCE non_register_nr_seq
    START WITH 21100
    INCREMENT BY 1
    MINVALUE 21100
    MAXVALUE 24999
    CACHE 1;


ALTER TABLE application.non_register_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE non_register_nr_seq; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON SEQUENCE non_register_nr_seq IS 'Sequence number used as the basis for the Application nr field when the application is for non registration services. This sequence is used by the generate-application-nr business rule.';


--
-- Name: request_category_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE request_category_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE application.request_category_type OWNER TO postgres;

--
-- Name: TABLE request_category_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE request_category_type IS 'Code list of request category types. Request category types group the request types into logical groupings such as request types for registration or cadastral changes.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN request_category_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_category_type.code IS 'The code for the request category type.';


--
-- Name: COLUMN request_category_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_category_type.display_value IS 'Displayed value of the request category type.';


--
-- Name: COLUMN request_category_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_category_type.description IS 'Description of the request category type.';


--
-- Name: COLUMN request_category_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_category_type.status IS 'Status of the request category type';


--
-- Name: request_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE request_type (
    code character varying(20) NOT NULL,
    request_category_code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    nr_days_to_complete integer DEFAULT 0 NOT NULL,
    base_fee numeric(20,2) DEFAULT 0 NOT NULL,
    area_base_fee numeric(20,2) DEFAULT 0 NOT NULL,
    value_base_fee numeric(20,2) DEFAULT 0 NOT NULL,
    nr_properties_required integer DEFAULT 0 NOT NULL,
    notation_template character varying(1000),
    rrr_type_code character varying(20),
    type_action_code character varying(20)
);


ALTER TABLE application.request_type OWNER TO postgres;

--
-- Name: TABLE request_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE request_type IS 'Code list of request types. Request types identify the different types of services provided by the land administration agency. SOLA includes a default set of request types that can be reconfigured to match those required by the land administration agency. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN request_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.code IS 'The code for the request type.';


--
-- Name: COLUMN request_type.request_category_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.request_category_code IS 'The code for the request category type.';


--
-- Name: COLUMN request_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.display_value IS 'Displayed value of the request type.';


--
-- Name: COLUMN request_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.description IS 'Description of the request type.';


--
-- Name: COLUMN request_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.status IS 'Status of the request type';


--
-- Name: COLUMN request_type.nr_days_to_complete; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.nr_days_to_complete IS 'The number of days it should take for the service to be completed.  Can be used to manage and monitor transaction throughput targets for the land administration agency.';


--
-- Name: COLUMN request_type.base_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.base_fee IS 'The fixed fee component charged for the service or 0 if there is no fixed fee.';


--
-- Name: COLUMN request_type.area_base_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.area_base_fee IS 'The fee component charged for each square metre of the property or 0 if no area fee applies.';


--
-- Name: COLUMN request_type.value_base_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.value_base_fee IS 'The fee component charged against the value of the property or 0 if no value fee applies.';


--
-- Name: COLUMN request_type.nr_properties_required; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.nr_properties_required IS 'The minimum number of properties that must be referenced by the application before services of this type can be processed.';


--
-- Name: COLUMN request_type.notation_template; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.notation_template IS 'Template text to use when completing the details of RRR records created by the service.';


--
-- Name: COLUMN request_type.rrr_type_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.rrr_type_code IS 'Used by the Property Details screen to identify the type of RRR affected by the service. If null, the Property Details screen will allow the user to process all RRR types.';


--
-- Name: COLUMN request_type.type_action_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type.type_action_code IS 'Used by teh Property Details screen to identify what action applies to the RRR affected by the service. One of new, vary or cancel. If null, the Property Details screen will allow the user to create or vary RRRs matching the rrr_type_code.';


--
-- Name: request_type_requires_source_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE request_type_requires_source_type (
    source_type_code character varying(20) NOT NULL,
    request_type_code character varying(20) NOT NULL
);


ALTER TABLE application.request_type_requires_source_type OWNER TO postgres;

--
-- Name: TABLE request_type_requires_source_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE request_type_requires_source_type IS 'Identifies the types of sources (a.k.a. documents) that must be provided before a service can be processed by the land administration agency.
Tags: FLOSS SOLA Extension';


--
-- Name: COLUMN request_type_requires_source_type.source_type_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type_requires_source_type.source_type_code IS 'The source type required by the request type.';


--
-- Name: COLUMN request_type_requires_source_type.request_type_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN request_type_requires_source_type.request_type_code IS 'The request type that requries the source to be present on the application.';


--
-- Name: service; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE service (
    id character varying(40) NOT NULL,
    application_id character varying(40),
    request_type_code character varying(20) NOT NULL,
    service_order integer DEFAULT 0 NOT NULL,
    lodging_datetime timestamp without time zone DEFAULT now() NOT NULL,
    expected_completion_date date NOT NULL,
    status_code character varying(20) DEFAULT 'lodged'::character varying NOT NULL,
    action_code character varying(20) DEFAULT 'lodge'::character varying NOT NULL,
    action_notes character varying(255),
    base_fee numeric(20,2) DEFAULT 0 NOT NULL,
    area_fee numeric(20,2) DEFAULT 0 NOT NULL,
    value_fee numeric(20,2) DEFAULT 0 NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.service OWNER TO postgres;

--
-- Name: TABLE service; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE service IS 'Used to control the type of change an application can make to the land registry and/or cadastre information recorded in SOLA. Services broadly identify the actions the land administration agency will undertake for the application. Every application lodged in SOLA must include at least one service. SOLA includes a default set of request types that can be reconfigured to match those services required by the land administration agency.  
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN service.id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.id IS 'Identifier for the service.';


--
-- Name: COLUMN service.application_id; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.application_id IS 'Identifier for the application the service is associated with.';


--
-- Name: COLUMN service.request_type_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.request_type_code IS 'The request type identifying the purpose of the service.';


--
-- Name: COLUMN service.service_order; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.service_order IS 'The relative order of the service within the application. Can be used to imply a workflow sequence for application related tasks.';


--
-- Name: COLUMN service.lodging_datetime; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.lodging_datetime IS 'The date the service was lodged on the application. Typically will match the application lodgement_datetime, but may vary if a service is added after the application is lodged.';


--
-- Name: COLUMN service.expected_completion_date; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.expected_completion_date IS 'Date when the service is expected to be completed by. Calculated using the service lodging_datetime and the nr_days_to_complete for the service request type.';


--
-- Name: COLUMN service.status_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.status_code IS 'Service status code.';


--
-- Name: COLUMN service.action_code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.action_code IS 'Service action code. Indicates the last action to occur on the service. E.g. lodge, start, complete, cancel, etc.';


--
-- Name: COLUMN service.action_notes; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.action_notes IS 'Provides extra detail related to the last action to occur on the service. Not Used.';


--
-- Name: COLUMN service.base_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.base_fee IS 'The fixed fee charged for the service. Obtained from the base_fee value in request_type.';


--
-- Name: COLUMN service.area_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.area_fee IS 'The area fee charged for the service. Calculated from the sum of all areas listed for properties on the application multiplied by the request_type.area_base_fee.';


--
-- Name: COLUMN service.value_fee; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.value_fee IS 'The value fee charged for the service. Calculated from the sum of all values listed for properties on the application multiplied by the request_type.value_base_fee.';


--
-- Name: COLUMN service.rowidentifier; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.rowidentifier IS 'Identifies the all change records for the row in the service_historic table';


--
-- Name: COLUMN service.rowversion; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN service.change_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN service.change_user; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN service.change_time; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service.change_time IS 'The date and time the row was last modified.';


--
-- Name: service_action_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE service_action_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status_to_set character varying(20),
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE application.service_action_type OWNER TO postgres;

--
-- Name: TABLE service_action_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE service_action_type IS 'Code list of service action types. Service actions identify the actions user can perform against services. E.g. lodge, start, revert, cancel, complete.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN service_action_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.code IS 'The code for the service action type.';


--
-- Name: COLUMN service_action_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.display_value IS 'Displayed value of the service action type.';


--
-- Name: COLUMN service_action_type.status_to_set; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.status_to_set IS 'The status to set on the service when the service action is applied.';


--
-- Name: COLUMN service_action_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.status IS 'Status of the service action type';


--
-- Name: COLUMN service_action_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_action_type.description IS 'Description of the service action type.';


--
-- Name: service_historic; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE service_historic (
    id character varying(40),
    application_id character varying(40),
    request_type_code character varying(20),
    service_order integer,
    lodging_datetime timestamp without time zone,
    expected_completion_date date,
    status_code character varying(20),
    action_code character varying(20),
    action_notes character varying(255),
    base_fee numeric(20,2),
    area_fee numeric(20,2),
    value_fee numeric(20,2),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE application.service_historic OWNER TO postgres;

--
-- Name: service_status_type; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE service_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE application.service_status_type OWNER TO postgres;

--
-- Name: TABLE service_status_type; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE service_status_type IS 'Code list of service status types.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN service_status_type.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_status_type.code IS 'The code for the service status type.';


--
-- Name: COLUMN service_status_type.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_status_type.display_value IS 'Displayed value of the service status type.';


--
-- Name: COLUMN service_status_type.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_status_type.status IS 'Status of the service status type';


--
-- Name: COLUMN service_status_type.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN service_status_type.description IS 'Description of the service status type.';


--
-- Name: survey_plan_nr_seq; Type: SEQUENCE; Schema: application; Owner: postgres
--

CREATE SEQUENCE survey_plan_nr_seq
    START WITH 11000
    INCREMENT BY 1
    MINVALUE 10700
    MAXVALUE 19999
    CACHE 1;


ALTER TABLE application.survey_plan_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE survey_plan_nr_seq; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON SEQUENCE survey_plan_nr_seq IS 'Sequence number used as the basis for the Application nr field when the application is for Survey (Record Plan) services. This sequence is used by the generate-application-nr business rule.';


--
-- Name: type_action; Type: TABLE; Schema: application; Owner: postgres; Tablespace: 
--

CREATE TABLE type_action (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE application.type_action OWNER TO postgres;

--
-- Name: TABLE type_action; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON TABLE type_action IS 'Code list of request type actions. Identifies what actions the Property Details screen should support for RRRs when processing a service. One of new, vary or cancel. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN type_action.code; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN type_action.code IS 'The code for the request type action.';


--
-- Name: COLUMN type_action.display_value; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN type_action.display_value IS 'Displayed value of the request type action.';


--
-- Name: COLUMN type_action.description; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN type_action.description IS 'Description of the request type action.';


--
-- Name: COLUMN type_action.status; Type: COMMENT; Schema: application; Owner: postgres
--

COMMENT ON COLUMN type_action.status IS 'Status of the request type action.';


SET search_path = cadastre, pg_catalog;

--
-- Name: area_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE area_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 'c'::bpchar NOT NULL
);


ALTER TABLE cadastre.area_type OWNER TO postgres;

--
-- Name: TABLE area_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE area_type IS 'Code list of area types. Identifies the types of area (calculated, official, survey defined, etc) that can be recorded for a parcel (a.k.a. cadastre object). Implementation of the LADM LA_AreaType class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN area_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN area_type.code IS 'LADM Definition: The code for the area type.';


--
-- Name: COLUMN area_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN area_type.display_value IS 'LADM Definition: Displayed value of the area type.';


--
-- Name: COLUMN area_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN area_type.description IS 'LADM Definition: Description of the area type.';


--
-- Name: COLUMN area_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN area_type.status IS 'SOLA Extension: Status of the area type';


--
-- Name: building_unit_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE building_unit_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.building_unit_type OWNER TO postgres;

--
-- Name: TABLE building_unit_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE building_unit_type IS 'Code list of building unit types. Identifies the types of building unit that can exist on a parcel. Implementation of the LADM LA_BuildingUnitType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN building_unit_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN building_unit_type.code IS 'LADM Definition: The code for the building unit type.';


--
-- Name: COLUMN building_unit_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN building_unit_type.display_value IS 'LADM Definition: Displayed value of the building unit type.';


--
-- Name: COLUMN building_unit_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN building_unit_type.description IS 'LADM Definition: Description of the building unit type.';


--
-- Name: COLUMN building_unit_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN building_unit_type.status IS 'SOLA Extension: Status of the building unit type';


--
-- Name: cadastre_object; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object (
    id character varying(40) NOT NULL,
    type_code character varying(20) DEFAULT 'parcel'::character varying NOT NULL,
    building_unit_type_code character varying(20),
    approval_datetime timestamp without time zone,
    historic_datetime timestamp without time zone,
    source_reference character varying(100),
    name_firstpart character varying(20) NOT NULL,
    name_lastpart character varying(50) NOT NULL,
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    geom_polygon public.geometry,
    transaction_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom_polygon CHECK ((public.st_ndims(geom_polygon) = 2)),
    CONSTRAINT enforce_geotype_geom_polygon CHECK (((public.geometrytype(geom_polygon) = 'POLYGON'::text) OR (geom_polygon IS NULL))),
    CONSTRAINT enforce_srid_geom_polygon CHECK ((public.st_srid(geom_polygon) = 32702)),
    CONSTRAINT enforce_valid_geom_polygon CHECK (public.st_isvalid(geom_polygon))
);


ALTER TABLE cadastre.cadastre_object OWNER TO postgres;

--
-- Name: TABLE cadastre_object; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE cadastre_object IS 'Specialization of Spatial Unit that represents primary cadastral features such as parcels. Parcels captured in SOLA should have a spatial definition that illustrates the shape and geographic location of the parcel although this is not a mandatory requirement. Parcels without a spatial definition may be referred to as aspatial or textual parcels.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN cadastre_object.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.id IS 'Identifier for the cadastre object.';


--
-- Name: COLUMN cadastre_object.type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.type_code IS 'The type of cadastre object. E.g. parcel, building unit, etc.';


--
-- Name: COLUMN cadastre_object.building_unit_type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.building_unit_type_code IS 'The building unit subtype if applicable. Not used by SOLA.';


--
-- Name: COLUMN cadastre_object.approval_datetime; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.approval_datetime IS 'The datetime the cadastre object was approved/registered.';


--
-- Name: COLUMN cadastre_object.historic_datetime; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.historic_datetime IS 'The datetime the cadastre object was superseded and became historic.';


--
-- Name: COLUMN cadastre_object.source_reference; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.source_reference IS 'Used to indicate the original source of the cadastre object. Can be a map reference or a reference to the system the geometry was migrated from.';


--
-- Name: COLUMN cadastre_object.name_firstpart; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.name_firstpart IS 'The first part of the name or reference assigned by the land administration agency to identify the cadastre object. E.g. lot number, etc';


--
-- Name: COLUMN cadastre_object.name_lastpart; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.name_lastpart IS 'The remaining part of the name or reference assigned by the land administration agency to identify the cadastre object. E.g. survey plan number, map number, section reference, etc.';


--
-- Name: COLUMN cadastre_object.status_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.status_code IS 'The status of the cadastre object.';


--
-- Name: COLUMN cadastre_object.geom_polygon; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.geom_polygon IS 'The PostGIS geometry for the cadastre object. Must be a ploygon. Multipolygon geometries are not currently supported by SOLA.';


--
-- Name: COLUMN cadastre_object.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.transaction_id IS 'Reference to the SOLA transaction that created the cadastre object.';


--
-- Name: COLUMN cadastre_object.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.rowidentifier IS 'Identifies the all change records for the row in the cadastre_object_historic table';


--
-- Name: COLUMN cadastre_object.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN cadastre_object.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN cadastre_object.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN cadastre_object.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object.change_time IS 'The date and time the row was last modified.';


--
-- Name: cadastre_object_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_historic (
    id character varying(40),
    type_code character varying(20),
    building_unit_type_code character varying(20),
    approval_datetime timestamp without time zone,
    historic_datetime timestamp without time zone,
    source_reference character varying(100),
    name_firstpart character varying(20),
    name_lastpart character varying(50),
    status_code character varying(20),
    geom_polygon public.geometry,
    transaction_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom_polygon CHECK ((public.st_ndims(geom_polygon) = 2)),
    CONSTRAINT enforce_geotype_geom_polygon CHECK (((public.geometrytype(geom_polygon) = 'POLYGON'::text) OR (geom_polygon IS NULL))),
    CONSTRAINT enforce_srid_geom_polygon CHECK ((public.st_srid(geom_polygon) = 32702)),
    CONSTRAINT enforce_valid_geom_polygon CHECK (public.st_isvalid(geom_polygon))
);


ALTER TABLE cadastre.cadastre_object_historic OWNER TO postgres;

--
-- Name: cadastre_object_node_target; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_node_target (
    transaction_id character varying(40) NOT NULL,
    node_id character varying(40) NOT NULL,
    geom public.geometry NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.cadastre_object_node_target OWNER TO postgres;

--
-- Name: TABLE cadastre_object_node_target; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE cadastre_object_node_target IS 'Used to store coordinate details for new or modified nodes during the Redefine Cadastre process.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN cadastre_object_node_target.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.transaction_id IS 'Identifier for the transaction the node is associated with.';


--
-- Name: COLUMN cadastre_object_node_target.node_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.node_id IS 'Identifier for the node.';


--
-- Name: COLUMN cadastre_object_node_target.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.geom IS 'The geometry of the node containing the coordinate details.';


--
-- Name: COLUMN cadastre_object_node_target.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.rowidentifier IS 'Identifies the all change records for the row in the cadastre_object_node_target_historic table';


--
-- Name: COLUMN cadastre_object_node_target.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN cadastre_object_node_target.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN cadastre_object_node_target.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN cadastre_object_node_target.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_node_target.change_time IS 'The date and time the row was last modified.';


--
-- Name: cadastre_object_node_target_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_node_target_historic (
    transaction_id character varying(40),
    node_id character varying(40),
    geom public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.cadastre_object_node_target_historic OWNER TO postgres;

--
-- Name: cadastre_object_target; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_target (
    transaction_id character varying(40) NOT NULL,
    cadastre_object_id character varying(40) NOT NULL,
    geom_polygon public.geometry,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom_polygon CHECK ((public.st_ndims(geom_polygon) = 2)),
    CONSTRAINT enforce_geotype_geom_polygon CHECK (((public.geometrytype(geom_polygon) = 'POLYGON'::text) OR (geom_polygon IS NULL))),
    CONSTRAINT enforce_srid_geom_polygon CHECK ((public.st_srid(geom_polygon) = 32702)),
    CONSTRAINT enforce_valid_geom_polygon CHECK (public.st_isvalid(geom_polygon))
);


ALTER TABLE cadastre.cadastre_object_target OWNER TO postgres;

--
-- Name: TABLE cadastre_object_target; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE cadastre_object_target IS 'Used to identify cadastre objects that are being changed or cancelled by a cadastre related transaction (i.e. Change Cadastre or Redefine Cadastre). These changes are considered pending/unofficial and do not affect the registered state of the cadastre object until the transaction is approved. Note that new cadastre objects are created in the cadastre_object table with a status of pending and they are not recorded in this table. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN cadastre_object_target.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.transaction_id IS 'Identifier for the transaction the cadastre object is being affected by.';


--
-- Name: COLUMN cadastre_object_target.cadastre_object_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.cadastre_object_id IS 'Identifier for the cadastre object.';


--
-- Name: COLUMN cadastre_object_target.geom_polygon; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.geom_polygon IS 'The new geometry of the cadastre object as a result of the cadastre transaction.';


--
-- Name: COLUMN cadastre_object_target.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.rowidentifier IS 'Identifies the all change records for the row in the cadastre_object_target_historic table';


--
-- Name: COLUMN cadastre_object_target.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN cadastre_object_target.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN cadastre_object_target.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN cadastre_object_target.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_target.change_time IS 'The date and time the row was last modified.';


--
-- Name: cadastre_object_target_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_target_historic (
    transaction_id character varying(40),
    cadastre_object_id character varying(40),
    geom_polygon public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom_polygon CHECK ((public.st_ndims(geom_polygon) = 2)),
    CONSTRAINT enforce_geotype_geom_polygon CHECK (((public.geometrytype(geom_polygon) = 'POLYGON'::text) OR (geom_polygon IS NULL))),
    CONSTRAINT enforce_srid_geom_polygon CHECK ((public.st_srid(geom_polygon) = 32702)),
    CONSTRAINT enforce_valid_geom_polygon CHECK (public.st_isvalid(geom_polygon))
);


ALTER TABLE cadastre.cadastre_object_target_historic OWNER TO postgres;

--
-- Name: cadastre_object_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE cadastre_object_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL,
    in_topology boolean DEFAULT false NOT NULL
);


ALTER TABLE cadastre.cadastre_object_type OWNER TO postgres;

--
-- Name: TABLE cadastre_object_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE cadastre_object_type IS 'Code list of cadastre object types. E.g. parcel, building_unit, road, etc. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN cadastre_object_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.code IS 'The code for the cadastre object type.';


--
-- Name: COLUMN cadastre_object_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.display_value IS 'Displayed value of the cadastre object type.';


--
-- Name: COLUMN cadastre_object_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.description IS 'Description of the cadastre object type.';


--
-- Name: COLUMN cadastre_object_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.status IS 'Status of the cadastre object type';


--
-- Name: COLUMN cadastre_object_type.in_topology; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN cadastre_object_type.in_topology IS 'Flag to indicate that all cadastre objects of this type must obey topological conventions such as no gaps or overlaps between objects with the same type.';


--
-- Name: level; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE level (
    id character varying(40) NOT NULL,
    name character varying(50),
    register_type_code character varying(20) NOT NULL,
    structure_code character varying(20),
    type_code character varying(20),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.level OWNER TO postgres;

--
-- Name: TABLE level; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE level IS 'LADM Definition: A set of spatial units, with geometric, and/or topological, and/or thematic coherence. 
EXAMPLE 1 - One level for an urban cadastre and another level for a rural cadastre.
EXAMPLE 2 - One level with rights and another with restrictions.
EXAMPLE 3 - One level with formal rights, a second level with informal rights and a third level with customary rights.
EXAMPLE 4 - One level with point based spaital units, a second level with line based spatial units, and a third level with polygon based spatial features.
Implementation of the LADM LA_Level class. Used by SOLA to identify the set of spatial features for each layer displayed in the Map Viewer. 
Tags: Reference Table, LADM Reference Object, Change History';


--
-- Name: COLUMN level.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.id IS 'LADM Definition: Level identifier.';


--
-- Name: COLUMN level.name; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.name IS 'LADM Definition: The name of the level.';


--
-- Name: COLUMN level.register_type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.register_type_code IS 'LADM Definition: The register type of the content of the level. E.g. all, forest, mining, rural, urban, etc';


--
-- Name: COLUMN level.structure_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.structure_code IS 'LADM Definition: Code for the structure of the level geometry. E.g. point, polygon, sketch, etc.';


--
-- Name: COLUMN level.type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.type_code IS 'LADM Definition: The type of content of the level.';


--
-- Name: COLUMN level.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the level_historic table';


--
-- Name: COLUMN level.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN level.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN level.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN level.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: spatial_unit; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit (
    id character varying(40) NOT NULL,
    dimension_code character varying(20) DEFAULT '2D'::character varying NOT NULL,
    label character varying(255),
    surface_relation_code character varying(20) DEFAULT 'onSurface'::character varying NOT NULL,
    level_id character varying(40),
    reference_point public.geometry,
    geom public.geometry,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_reference_point CHECK ((public.st_ndims(reference_point) = 2)),
    CONSTRAINT enforce_geotype_reference_point CHECK (((public.geometrytype(reference_point) = 'POINT'::text) OR (reference_point IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_srid_reference_point CHECK ((public.st_srid(reference_point) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_reference_point CHECK (public.st_isvalid(reference_point))
);


ALTER TABLE cadastre.spatial_unit OWNER TO postgres;

--
-- Name: TABLE spatial_unit; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit IS 'Single area (or multiple areas) of land, water or a single volume (or multiple volumes) of space. 
Implementation of the LADM LA_SpatialUnit class. Can be used by SOLA to represent geographic features such as place names and roading centrelines that are not considered as cadastre objects.  
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN spatial_unit.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.id IS 'LADM Definition: Spatial unit identifier.';


--
-- Name: COLUMN spatial_unit.dimension_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.dimension_code IS 'LADM Definition: Code for dimension.';


--
-- Name: COLUMN spatial_unit.label; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.label IS 'LADM Definition:  Label for the spatial unit. Used by SOLA as the label to display for the feature in the Map Viewer.';


--
-- Name: COLUMN spatial_unit.surface_relation_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.surface_relation_code IS 'LADM Definition: Code indicating if the spatial unit is above or below the surface.';


--
-- Name: COLUMN spatial_unit.level_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.level_id IS 'LADM Definition: The identifier for the level.';


--
-- Name: COLUMN spatial_unit.reference_point; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.reference_point IS 'LADM Definition: The coordinates of a point inside the spatial unit. Only used by SOLA to define point geometries like place names.';


--
-- Name: COLUMN spatial_unit.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.geom IS 'SOLA Extension: The geometry for the spatial unit. Can be any geometry type.';


--
-- Name: COLUMN spatial_unit.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the spatial_unit_historic table';


--
-- Name: COLUMN spatial_unit.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: court_grants; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW court_grants AS
    SELECT su.id, su.label, su.reference_point AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Court Grants'::text));


ALTER TABLE cadastre.court_grants OWNER TO postgres;

--
-- Name: VIEW court_grants; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW court_grants IS 'View for retrieving court grant features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: current_parcels; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW current_parcels AS
    SELECT co.id, ((btrim((co.name_firstpart)::text) || ' Plan '::text) || btrim((co.name_lastpart)::text)) AS label, co.geom_polygon AS "theGeom" FROM cadastre_object co WHERE (((co.type_code)::text = 'parcel'::text) AND ((co.status_code)::text = 'current'::text));


ALTER TABLE cadastre.current_parcels OWNER TO postgres;

--
-- Name: VIEW current_parcels; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW current_parcels IS 'View for retrieving current parcel features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: dimension_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE dimension_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.dimension_type OWNER TO postgres;

--
-- Name: TABLE dimension_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE dimension_type IS 'Code list of dimension types. Identifies the number of dimensions used to define a spatial unit. E.g. 1D, 2D, etc. Implementation of the LADM LA_DimensionType class. SOLA assumes all spatial units are 2D. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN dimension_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN dimension_type.code IS 'LADM Definition: The code for the dimension type.';


--
-- Name: COLUMN dimension_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN dimension_type.display_value IS 'LADM Definition: Displayed value of the dimension type.';


--
-- Name: COLUMN dimension_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN dimension_type.description IS 'LADM Definition: Description of the dimension type.';


--
-- Name: COLUMN dimension_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN dimension_type.status IS 'SOLA Extension: Status of the dimension type';


--
-- Name: districts; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW districts AS
    SELECT su.id, su.label, su.reference_point AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Districts'::text));


ALTER TABLE cadastre.districts OWNER TO postgres;

--
-- Name: VIEW districts; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW districts IS 'View for retrieving district features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: flur; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW flur AS
    SELECT su.id, su.label, su.geom AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Flur'::text));


ALTER TABLE cadastre.flur OWNER TO postgres;

--
-- Name: VIEW flur; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW flur IS 'View for retrieving flur features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: hydro_features; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW hydro_features AS
    SELECT su.id, su.label, su.geom AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Hydro Features'::text));


ALTER TABLE cadastre.hydro_features OWNER TO postgres;

--
-- Name: VIEW hydro_features; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW hydro_features IS 'View for retrieving hyrdo features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: islands; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW islands AS
    SELECT su.id, su.label, su.reference_point AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Islands'::text));


ALTER TABLE cadastre.islands OWNER TO postgres;

--
-- Name: VIEW islands; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW islands IS 'View for retrieving island features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: legal_space_utility_network; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE legal_space_utility_network (
    id character varying(40) NOT NULL,
    ext_physical_network_id character varying(40),
    status_code character varying(20),
    type_code character varying(20) NOT NULL,
    geom public.geometry,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.legal_space_utility_network OWNER TO postgres;

--
-- Name: TABLE legal_space_utility_network; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE legal_space_utility_network IS 'LADM Defintion: A utility network concerns legal space, which does not necessarily coincide with the physical space of a utility network. Implementation of the LADM LA_LegalSpaceUtilityNetwork class. Not used by SOLA. 
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN legal_space_utility_network.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.id IS 'LADM Definition: Legal space utility network identifier.';


--
-- Name: COLUMN legal_space_utility_network.ext_physical_network_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.ext_physical_network_id IS 'LADM Definition: External identifier for a physical utility network.';


--
-- Name: COLUMN legal_space_utility_network.status_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.status_code IS 'LADM Definition: Status code for the legal space utility network.';


--
-- Name: COLUMN legal_space_utility_network.type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.type_code IS 'LADM Definition: Type code for the legal space utility network.';


--
-- Name: COLUMN legal_space_utility_network.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.geom IS 'LADM Definition: Not provided.';


--
-- Name: COLUMN legal_space_utility_network.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the legal_space_utility_network_historic table';


--
-- Name: COLUMN legal_space_utility_network.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN legal_space_utility_network.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN legal_space_utility_network.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN legal_space_utility_network.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN legal_space_utility_network.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: legal_space_utility_network_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE legal_space_utility_network_historic (
    id character varying(40),
    ext_physical_network_id character varying(40),
    status_code character varying(20),
    type_code character varying(20),
    geom public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 2193)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.legal_space_utility_network_historic OWNER TO postgres;

--
-- Name: level_content_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE level_content_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.level_content_type OWNER TO postgres;

--
-- Name: TABLE level_content_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE level_content_type IS 'Code list of level content types. E.g. geographicLocator, building, customary, primaryRight, etc. Implementation of the LADM LA_LevelContentType class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN level_content_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_content_type.code IS 'LADM Definition: The code for the level content type.';


--
-- Name: COLUMN level_content_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_content_type.display_value IS 'LADM Definition: Displayed value of the level content type.';


--
-- Name: COLUMN level_content_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_content_type.description IS 'LADM Definition: Description of the level content type.';


--
-- Name: COLUMN level_content_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN level_content_type.status IS 'SOLA Extension: Status of the level content type';


--
-- Name: level_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE level_historic (
    id character varying(40),
    name character varying(50),
    register_type_code character varying(20),
    structure_code character varying(20),
    type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.level_historic OWNER TO postgres;

--
-- Name: pending_parcels; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW pending_parcels AS
    SELECT co.id, ((btrim((co.name_firstpart)::text) || ' Plan '::text) || btrim((co.name_lastpart)::text)) AS label, co.geom_polygon AS "theGeom" FROM cadastre_object co WHERE (((co.type_code)::text = 'parcel'::text) AND ((co.status_code)::text = 'pending'::text));


ALTER TABLE cadastre.pending_parcels OWNER TO postgres;

--
-- Name: VIEW pending_parcels; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW pending_parcels IS 'View for retrieving pending parcel features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: record_sheets; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW record_sheets AS
    SELECT su.id, su.label, su.geom AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Record Sheets'::text));


ALTER TABLE cadastre.record_sheets OWNER TO postgres;

--
-- Name: VIEW record_sheets; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW record_sheets IS 'View for retrieving record sheet features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: register_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE register_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL
);


ALTER TABLE cadastre.register_type OWNER TO postgres;

--
-- Name: TABLE register_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE register_type IS 'Code list of register types. E.g. all, forest, mining, rural, urban, etc. Implementation of the LADM LA_RegisterType class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN register_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN register_type.code IS 'LADM Definition: The code for the register type.';


--
-- Name: COLUMN register_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN register_type.display_value IS 'LADM Definition: Displayed value of the register type.';


--
-- Name: COLUMN register_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN register_type.description IS 'LADM Definition: Description of the register type.';


--
-- Name: COLUMN register_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN register_type.status IS 'SOLA Extension: Status of the register type';


--
-- Name: road_centerlines; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW road_centerlines AS
    SELECT su.id, su.label, su.geom AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Road Centerlines'::text));


ALTER TABLE cadastre.road_centerlines OWNER TO postgres;

--
-- Name: VIEW road_centerlines; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW road_centerlines IS 'View for retrieving road_centerlines features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: roads; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW roads AS
    SELECT su.id, su.label, su.geom AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Roads'::text));


ALTER TABLE cadastre.roads OWNER TO postgres;

--
-- Name: VIEW roads; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW roads IS 'View for retrieving road features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: spatial_unit_address; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_address (
    spatial_unit_id character varying(40) NOT NULL,
    address_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_unit_address OWNER TO postgres;

--
-- Name: TABLE spatial_unit_address; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit_address IS 'Associates a spatial unit to one or more address records. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN spatial_unit_address.spatial_unit_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.spatial_unit_id IS 'Spatial unit identifier.';


--
-- Name: COLUMN spatial_unit_address.address_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.address_id IS 'Address identifier';


--
-- Name: COLUMN spatial_unit_address.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.rowidentifier IS 'Identifies the all change records for the row in the spatial_unit_address_historic table';


--
-- Name: COLUMN spatial_unit_address.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit_address.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit_address.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit_address.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_address.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_unit_address_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_address_historic (
    spatial_unit_id character varying(40),
    address_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_unit_address_historic OWNER TO postgres;

--
-- Name: spatial_unit_change; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_change (
    id character varying(40) NOT NULL,
    transaction_id character varying(40) NOT NULL,
    spatial_unit_id character varying(40),
    label character varying(255),
    level_id character varying(40),
    delete_on_approval boolean DEFAULT false NOT NULL,
    geom public.geometry,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.spatial_unit_change OWNER TO postgres;

--
-- Name: TABLE spatial_unit_change; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit_change IS 'Used to capture pending changes to spatial unit records (e.g. Roads, RCL, Hydro and Villages) that are to be applied when the associated transaction is approved. Spatial Unit does not include a status field, so new records are captured with no spatial_unit_id reference. 
Tags: SOLA Samoa Extension, Change History';


--
-- Name: COLUMN spatial_unit_change.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.id IS 'Identifier for the spatial unit change.';


--
-- Name: COLUMN spatial_unit_change.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.transaction_id IS 'Identifier for the transaction that created the spatial unit change.';


--
-- Name: COLUMN spatial_unit_change.spatial_unit_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.spatial_unit_id IS 'Spatial unit identifier.';


--
-- Name: COLUMN spatial_unit_change.label; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.label IS 'The road name, village name, etc to display with the spatial unit.';


--
-- Name: COLUMN spatial_unit_change.level_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.level_id IS 'The level the spatial unit is to be added to.';


--
-- Name: COLUMN spatial_unit_change.delete_on_approval; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.delete_on_approval IS 'Flag to indicate the spatial unit must be deleted when the application is approved';


--
-- Name: COLUMN spatial_unit_change.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.geom IS 'Geometry for the new or changed spatial unit.';


--
-- Name: COLUMN spatial_unit_change.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.rowidentifier IS 'Identifies the all change records for the row in the spatial_unit_address_historic table';


--
-- Name: COLUMN spatial_unit_change.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit_change.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit_change.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit_change.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_change.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_unit_change_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_change_historic (
    id character varying(40),
    transaction_id character varying(40),
    spatial_unit_id character varying(40),
    label character varying(255),
    level_id character varying(40),
    delete_on_approval boolean,
    geom public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom))
);


ALTER TABLE cadastre.spatial_unit_change_historic OWNER TO postgres;

--
-- Name: spatial_unit_group; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_group (
    id character varying(40) NOT NULL,
    hierarchy_level integer NOT NULL,
    label character varying(50),
    name character varying(50),
    reference_point public.geometry,
    geom public.geometry,
    found_in_spatial_unit_group_id character varying(40),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_reference_point CHECK ((public.st_ndims(reference_point) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'MULTIPOLYGON'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_geotype_reference_point CHECK (((public.geometrytype(reference_point) = 'POINT'::text) OR (reference_point IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_srid_reference_point CHECK ((public.st_srid(reference_point) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_reference_point CHECK (public.st_isvalid(reference_point))
);


ALTER TABLE cadastre.spatial_unit_group OWNER TO postgres;

--
-- Name: TABLE spatial_unit_group; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit_group IS 'Any number of spatial units considered as a single entity. 
Implementation of the LADM LA_SpatialUnitGroup class. 
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN spatial_unit_group.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.id IS 'LADM Definition: Spatial unit group identifier.';


--
-- Name: COLUMN spatial_unit_group.hierarchy_level; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.hierarchy_level IS 'LADM Definition: The level in the hierarchy of the administrative or zoning subdivision.';


--
-- Name: COLUMN spatial_unit_group.label; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.label IS 'LADM Definition: Short textual description of the spaital unit group.';


--
-- Name: COLUMN spatial_unit_group.name; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.name IS 'LADM Definition: The name of the spatial unit group.';


--
-- Name: COLUMN spatial_unit_group.reference_point; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.reference_point IS 'LADM Definition: The coordinates of a point inside the spatial unit group.';


--
-- Name: COLUMN spatial_unit_group.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.geom IS 'SOLA Extension: The geometry for the spatial unit group. Can be any geometry type.';


--
-- Name: COLUMN spatial_unit_group.found_in_spatial_unit_group_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.found_in_spatial_unit_group_id IS 'LADM Definition: The identifier of the parent spatial unit group that this group is part of.';


--
-- Name: COLUMN spatial_unit_group.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the spatial_unit_group_historic table';


--
-- Name: COLUMN spatial_unit_group.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit_group.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit_group.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit_group.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_group.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: spatial_unit_group_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_group_historic (
    id character varying(40),
    hierarchy_level integer,
    label character varying(50),
    name character varying(50),
    reference_point public.geometry,
    geom public.geometry,
    found_in_spatial_unit_group_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_reference_point CHECK ((public.st_ndims(reference_point) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'MULTIPOLYGON'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_geotype_reference_point CHECK (((public.geometrytype(reference_point) = 'POINT'::text) OR (reference_point IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_srid_reference_point CHECK ((public.st_srid(reference_point) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_reference_point CHECK (public.st_isvalid(reference_point))
);


ALTER TABLE cadastre.spatial_unit_group_historic OWNER TO postgres;

--
-- Name: spatial_unit_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_historic (
    id character varying(40),
    dimension_code character varying(20),
    label character varying(255),
    surface_relation_code character varying(20),
    level_id character varying(40),
    reference_point public.geometry,
    geom public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_reference_point CHECK ((public.st_ndims(reference_point) = 2)),
    CONSTRAINT enforce_geotype_reference_point CHECK (((public.geometrytype(reference_point) = 'POINT'::text) OR (reference_point IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_srid_reference_point CHECK ((public.st_srid(reference_point) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_reference_point CHECK (public.st_isvalid(reference_point))
);


ALTER TABLE cadastre.spatial_unit_historic OWNER TO postgres;

--
-- Name: spatial_unit_in_group; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_in_group (
    spatial_unit_group_id character varying(40) NOT NULL,
    spatial_unit_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    delete_on_approval boolean DEFAULT false NOT NULL,
    unit_parcel_status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL
);


ALTER TABLE cadastre.spatial_unit_in_group OWNER TO postgres;

--
-- Name: TABLE spatial_unit_in_group; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_unit_in_group IS 'Associates a spatial unit group to one or more spatial units.
Implementation of the LADM LA_SpatialUnitGroup and LA_SpatialUnit relationship.  
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN spatial_unit_in_group.spatial_unit_group_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.spatial_unit_group_id IS 'Spatial unit group identifier';


--
-- Name: COLUMN spatial_unit_in_group.spatial_unit_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.spatial_unit_id IS 'Spatial unit identifier.';


--
-- Name: COLUMN spatial_unit_in_group.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.rowidentifier IS 'Identifies the all change records for the row in the spatial_unit_in_group_historic table';


--
-- Name: COLUMN spatial_unit_in_group.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_unit_in_group.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_unit_in_group.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_unit_in_group.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN spatial_unit_in_group.delete_on_approval; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.delete_on_approval IS 'SOLA Samoa Extension - Flag to indicate the spatial unit will be removed from the unit group at approval. Used to remove Units from a Unit Development.';


--
-- Name: COLUMN spatial_unit_in_group.unit_parcel_status_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_unit_in_group.unit_parcel_status_code IS 'SOLA Samoa Extension - Indicates the status of the new unit within the Unit Development.';


--
-- Name: spatial_unit_in_group_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_unit_in_group_historic (
    spatial_unit_group_id character varying(40),
    spatial_unit_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    delete_on_approval boolean DEFAULT false NOT NULL,
    unit_parcel_status_code character varying(20)
);


ALTER TABLE cadastre.spatial_unit_in_group_historic OWNER TO postgres;

--
-- Name: spatial_value_area; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_value_area (
    spatial_unit_id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    size numeric(29,2) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_value_area OWNER TO postgres;

--
-- Name: TABLE spatial_value_area; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE spatial_value_area IS 'Identifies the area of a 2 dimensional spatial unit.
Implementation of the LADM LA_AreaValue class.  
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN spatial_value_area.spatial_unit_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.spatial_unit_id IS 'Spatial unit identifier.';


--
-- Name: COLUMN spatial_value_area.type_code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.type_code IS 'The type of the spatial value area. E.g. officialArea, calculatedArea, etc.';


--
-- Name: COLUMN spatial_value_area.size; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.size IS 'The value of the area. Must be in metres squared and can be converted for display if requried.';


--
-- Name: COLUMN spatial_value_area.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.rowidentifier IS 'Identifies the all change records for the row in the spatial_value_area_historic table';


--
-- Name: COLUMN spatial_value_area.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_value_area.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_value_area.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_value_area.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN spatial_value_area.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_value_area_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_value_area_historic (
    spatial_unit_id character varying(40),
    type_code character varying(20),
    size numeric(29,2),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE cadastre.spatial_value_area_historic OWNER TO postgres;

--
-- Name: structure_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE structure_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.structure_type OWNER TO postgres;

--
-- Name: TABLE structure_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE structure_type IS 'Code list of structure types. E.g. point, polygon, sketch, text, etc. Implementation of the LADM LA_StructureType class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN structure_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN structure_type.code IS 'LADM Definition: The code for the structure type.';


--
-- Name: COLUMN structure_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN structure_type.display_value IS 'LADM Definition: Displayed value of the structure type.';


--
-- Name: COLUMN structure_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN structure_type.description IS 'LADM Definition: Description of the structure type.';


--
-- Name: COLUMN structure_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN structure_type.status IS 'SOLA Extension: Status of the structure type';


--
-- Name: surface_relation_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE surface_relation_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.surface_relation_type OWNER TO postgres;

--
-- Name: TABLE surface_relation_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE surface_relation_type IS 'Code list of surface relation types. E.g. onSurface, above, below, mixed, etc. Implementation of the LADM LA_SurfaceRelationType class. 
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN surface_relation_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN surface_relation_type.code IS 'LADM Definition: The code for the surface relation type.';


--
-- Name: COLUMN surface_relation_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN surface_relation_type.display_value IS 'LADM Definition: Displayed value of the surface relation type.';


--
-- Name: COLUMN surface_relation_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN surface_relation_type.description IS 'LADM Definition: Description of the surface relation type.';


--
-- Name: COLUMN surface_relation_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN surface_relation_type.status IS 'SOLA Extension: Status of the surface relation type';


--
-- Name: survey_plans; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW survey_plans AS
    SELECT su.id, su.label, su.reference_point AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Survey Plans'::text));


ALTER TABLE cadastre.survey_plans OWNER TO postgres;

--
-- Name: VIEW survey_plans; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW survey_plans IS 'View for retrieving survey plan features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


--
-- Name: survey_point; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE survey_point (
    transaction_id character varying(40) NOT NULL,
    id character varying(40) NOT NULL,
    boundary boolean DEFAULT true NOT NULL,
    linked boolean DEFAULT false NOT NULL,
    geom public.geometry NOT NULL,
    original_geom public.geometry NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_original_geom CHECK ((public.st_ndims(original_geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_geotype_original_geom CHECK (((public.geometrytype(original_geom) = 'POINT'::text) OR (original_geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_srid_original_geom CHECK ((public.st_srid(original_geom) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_original_geom CHECK (public.st_isvalid(original_geom))
);


ALTER TABLE cadastre.survey_point OWNER TO postgres;

--
-- Name: TABLE survey_point; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE survey_point IS 'Used to store new survey point details (i.e. boundary and traverse) when capturing a survey plan into SOLA. Survey points can be used to define new cadastre objects. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN survey_point.transaction_id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.transaction_id IS 'Identifier of the transaction that created the survey point.';


--
-- Name: COLUMN survey_point.id; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.id IS 'Identifier for the survey point.';


--
-- Name: COLUMN survey_point.boundary; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.boundary IS 'Flag to indicate if the survey point is a boundary point (true) or traverse point (false).';


--
-- Name: COLUMN survey_point.linked; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.linked IS 'Flag to indicate if the new survey point has been linked to an existing cadastre object boundary node.';


--
-- Name: COLUMN survey_point.geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.geom IS 'Geometry representing the current position of the survey point.';


--
-- Name: COLUMN survey_point.original_geom; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.original_geom IS 'Geometry representing the original position of the survey point i.e. before it was linked to an existing cadastre object boundary node.';


--
-- Name: COLUMN survey_point.rowidentifier; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.rowidentifier IS 'Identifies the all change records for the row in the survey_point_historic table';


--
-- Name: COLUMN survey_point.rowversion; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN survey_point.change_action; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN survey_point.change_user; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN survey_point.change_time; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN survey_point.change_time IS 'The date and time the row was last modified.';


--
-- Name: survey_point_historic; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE survey_point_historic (
    transaction_id character varying(40),
    id character varying(40),
    boundary boolean,
    linked boolean,
    geom public.geometry,
    original_geom public.geometry,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((public.st_ndims(geom) = 2)),
    CONSTRAINT enforce_dims_original_geom CHECK ((public.st_ndims(original_geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((public.geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_geotype_original_geom CHECK (((public.geometrytype(original_geom) = 'POINT'::text) OR (original_geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((public.st_srid(geom) = 32702)),
    CONSTRAINT enforce_srid_original_geom CHECK ((public.st_srid(original_geom) = 32702)),
    CONSTRAINT enforce_valid_geom CHECK (public.st_isvalid(geom)),
    CONSTRAINT enforce_valid_original_geom CHECK (public.st_isvalid(original_geom))
);


ALTER TABLE cadastre.survey_point_historic OWNER TO postgres;

--
-- Name: unit_parcels; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW unit_parcels AS
    SELECT co.id, ((btrim((co.name_firstpart)::text) || ' PLAN '::text) || btrim((co.name_lastpart)::text)) AS label, co.geom_polygon AS "theGeom" FROM cadastre_object co, spatial_unit_in_group sug WHERE ((((((sug.spatial_unit_id)::text = (co.id)::text) AND ((co.type_code)::text = 'parcel'::text)) AND ((co.status_code)::text = 'current'::text)) AND (co.geom_polygon IS NOT NULL)) AND ((sug.unit_parcel_status_code)::text = 'current'::text));


ALTER TABLE cadastre.unit_parcels OWNER TO postgres;

--
-- Name: utility_network_status_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE utility_network_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) DEFAULT 't'::bpchar NOT NULL
);


ALTER TABLE cadastre.utility_network_status_type OWNER TO postgres;

--
-- Name: TABLE utility_network_status_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE utility_network_status_type IS 'Code list of utility network status types. E.g. inUse, outOfUse, planned, etc. 
Implementation of the LADM LA_UtilityNetworkStatusType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN utility_network_status_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_status_type.code IS 'LADM Definition: The code for the utility network status type.';


--
-- Name: COLUMN utility_network_status_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_status_type.display_value IS 'LADM Definition: Displayed value of the utility network status type.';


--
-- Name: COLUMN utility_network_status_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_status_type.description IS 'LADM Definition: Description of the utility network status type.';


--
-- Name: COLUMN utility_network_status_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_status_type.status IS 'SOLA Extension: Status of the utility network status type';


--
-- Name: utility_network_type; Type: TABLE; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE TABLE utility_network_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL
);


ALTER TABLE cadastre.utility_network_type OWNER TO postgres;

--
-- Name: TABLE utility_network_type; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON TABLE utility_network_type IS 'Code list of utility network types. E.g. gas, oil, water, etc. 
Implementation of the LADM LA_UtilityNetworkType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN utility_network_type.code; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_type.code IS 'LADM Definition: The code for the utility network type.';


--
-- Name: COLUMN utility_network_type.display_value; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_type.display_value IS 'LADM Definition: Displayed value of the utility network type.';


--
-- Name: COLUMN utility_network_type.description; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_type.description IS 'LADM Definition: Description of the utility network type.';


--
-- Name: COLUMN utility_network_type.status; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON COLUMN utility_network_type.status IS 'SOLA Extension: Status of the utility network type';


--
-- Name: villages; Type: VIEW; Schema: cadastre; Owner: postgres
--

CREATE VIEW villages AS
    SELECT su.id, su.label, su.reference_point AS "theGeom" FROM spatial_unit su, level l WHERE (((su.level_id)::text = (l.id)::text) AND ((l.name)::text = 'Villages'::text));


ALTER TABLE cadastre.villages OWNER TO postgres;

--
-- Name: VIEW villages; Type: COMMENT; Schema: cadastre; Owner: postgres
--

COMMENT ON VIEW villages IS 'View for retrieving village features for display in the Map Viewer. Not used by SOLA. Layer queries (defined in system.query) are used instead.';


SET search_path = document, pg_catalog;

--
-- Name: document; Type: TABLE; Schema: document; Owner: postgres; Tablespace: 
--

CREATE TABLE document (
    id character varying(40) NOT NULL,
    nr character varying(15) NOT NULL,
    extension character varying(5) NOT NULL,
    body bytea NOT NULL,
    description character varying(100),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE document.document OWNER TO postgres;

--
-- Name: TABLE document; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON TABLE document IS 'Extension to the LADM used by SOLA to store electronic copies of documentation provided in support of land related dealings.
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN document.id; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.id IS 'Identifier for the document.';


--
-- Name: COLUMN document.nr; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.nr IS 'Unique number to identify the document. Determined by the Digital Archive EJB when saving the document record.';


--
-- Name: COLUMN document.extension; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.extension IS 'The file extension of the electronic file. E.g. pdf, tiff, doc, etc';


--
-- Name: COLUMN document.body; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.body IS 'The content of the electronic file.';


--
-- Name: COLUMN document.description; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.description IS 'A descriptive name to help recognizs the file such as the original file name.';


--
-- Name: COLUMN document.rowidentifier; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';


--
-- Name: COLUMN document.rowversion; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN document.change_action; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN document.change_user; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN document.change_time; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document.change_time IS 'The date and time the row was last modified.';


--
-- Name: document_backup; Type: TABLE; Schema: document; Owner: postgres; Tablespace: 
--

CREATE TABLE document_backup (
    id character varying(40) NOT NULL,
    nr character varying(15),
    extension character varying(5),
    body bytea,
    description character varying(100),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone
);


ALTER TABLE document.document_backup OWNER TO postgres;

--
-- Name: TABLE document_backup; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON TABLE document_backup IS 'Extension to the LADM used by SOLA to perform partial backups of the document.document table.
Tags: FLOSS SOLA Extension';


--
-- Name: COLUMN document_backup.id; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.id IS 'Identifier for the document.';


--
-- Name: COLUMN document_backup.nr; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.nr IS 'Unique number to identify the document. Determined by the Digital Archive EJB when saving the document record.';


--
-- Name: COLUMN document_backup.extension; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.extension IS 'The file extension of the electronic file. E.g. pdf, tiff, doc, etc';


--
-- Name: COLUMN document_backup.body; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.body IS 'The content of the electronic file.';


--
-- Name: COLUMN document_backup.description; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.description IS 'A descriptive name to help recognizs the file such as the original file name.';


--
-- Name: COLUMN document_backup.rowidentifier; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';


--
-- Name: COLUMN document_backup.rowversion; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN document_backup.change_action; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN document_backup.change_user; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN document_backup.change_time; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON COLUMN document_backup.change_time IS 'The date and time the row was last modified.';


--
-- Name: document_historic; Type: TABLE; Schema: document; Owner: postgres; Tablespace: 
--

CREATE TABLE document_historic (
    id character varying(40),
    nr character varying(15),
    extension character varying(5),
    body bytea,
    description character varying(100),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE document.document_historic OWNER TO postgres;

--
-- Name: document_nr_seq; Type: SEQUENCE; Schema: document; Owner: postgres
--

CREATE SEQUENCE document_nr_seq
    START WITH 100000
    INCREMENT BY 1
    MINVALUE 100000
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE document.document_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE document_nr_seq; Type: COMMENT; Schema: document; Owner: postgres
--

COMMENT ON SEQUENCE document_nr_seq IS 'Sequence number used as the basis for the document Nr field. This sequence is used by the Digital Archive EJB.';


SET search_path = party, pg_catalog;

--
-- Name: communication_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE communication_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE party.communication_type OWNER TO postgres;

--
-- Name: TABLE communication_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE communication_type IS 'Code list of communication types. Used to identify the types of communication that can be used between the land administration agency and their clients.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN communication_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN communication_type.code IS 'The code for the communication type.';


--
-- Name: COLUMN communication_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN communication_type.display_value IS 'Displayed value of the communication type.';


--
-- Name: COLUMN communication_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN communication_type.status IS 'Status of the communication type';


--
-- Name: COLUMN communication_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN communication_type.description IS 'Description of the communication type.';


--
-- Name: gender_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE gender_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE party.gender_type OWNER TO postgres;

--
-- Name: TABLE gender_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE gender_type IS 'Code list of gender types. Used to identify the gender of the party where the party represents an individual.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN gender_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN gender_type.code IS 'The code for the gender type.';


--
-- Name: COLUMN gender_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN gender_type.display_value IS 'Displayed value of the gender type.';


--
-- Name: COLUMN gender_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN gender_type.status IS 'Status of the gender type';


--
-- Name: COLUMN gender_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN gender_type.description IS 'Description of the gender type.';


--
-- Name: group_party; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE group_party (
    id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.group_party OWNER TO postgres;

--
-- Name: TABLE group_party; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE group_party IS 'Groups any number of parties into a distinct entity. Implementation of the LADM LA_GroupParty class. Not used by SOLA
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN group_party.id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.id IS 'LADM Definition: Identifier for the group party.';


--
-- Name: COLUMN group_party.type_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.type_code IS 'LADM Definition: The type of the group party. E.g. family, tribe, association, etc.';


--
-- Name: COLUMN group_party.rowidentifier; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the group_party_historic table';


--
-- Name: COLUMN group_party.rowversion; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN group_party.change_action; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN group_party.change_user; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN group_party.change_time; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: group_party_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE group_party_historic (
    id character varying(40),
    type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.group_party_historic OWNER TO postgres;

--
-- Name: group_party_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE group_party_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE party.group_party_type OWNER TO postgres;

--
-- Name: TABLE group_party_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE group_party_type IS 'Code list of group party type types. Implementation of the LADM LA_GroupPartyType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN group_party_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party_type.code IS 'LADM Definition: The code for the group party type.';


--
-- Name: COLUMN group_party_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party_type.display_value IS 'LADM Definition: Displayed value of the group party type.';


--
-- Name: COLUMN group_party_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party_type.status IS 'SOLA Extension: Status of the group party type';


--
-- Name: COLUMN group_party_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN group_party_type.description IS 'LADM Definition: Description of the group party type.';


--
-- Name: id_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE id_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE party.id_type OWNER TO postgres;

--
-- Name: TABLE id_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE id_type IS 'Code list of id types. Used to identify the types of id that can be used to verify the identity of an individual, group or organisation. E.g. nationalId, nationalPassport, driverLicense, etc.
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN id_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN id_type.code IS 'The code for the id type.';


--
-- Name: COLUMN id_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN id_type.display_value IS 'Displayed value of the id type.';


--
-- Name: COLUMN id_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN id_type.status IS 'Status of the id type';


--
-- Name: COLUMN id_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN id_type.description IS 'Description of the id type.';


--
-- Name: party; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party (
    id character varying(40) NOT NULL,
    ext_id character varying(255),
    type_code character varying(20) NOT NULL,
    name character varying(255),
    last_name character varying(50),
    fathers_name character varying(50),
    fathers_last_name character varying(50),
    alias character varying(50),
    gender_code character varying(20),
    address_id character varying(40),
    id_type_code character varying(20),
    id_number character varying(20),
    email character varying(50),
    mobile character varying(15),
    phone character varying(15),
    fax character varying(15),
    preferred_communication_code character varying(20),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT party_id_is_present CHECK ((((id_type_code IS NULL) AND (id_number IS NULL)) OR ((id_type_code IS NOT NULL) AND (id_number IS NOT NULL))))
);


ALTER TABLE party.party OWNER TO postgres;

--
-- Name: TABLE party; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party IS 'An individual, group or organisation that is associated in some way with land office services. Implementation of the LADM LA_Party class.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN party.id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.id IS 'LADM Definition: Identifier for the party.';


--
-- Name: COLUMN party.ext_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.ext_id IS 'SOLA Extension: An identifier for the party from some external system such as a customer relationship management (CRM) system.';


--
-- Name: COLUMN party.type_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.type_code IS 'LADM Definition: The type of the party. E.g. naturalPerson, nonNaturalPerson, etc.';


--
-- Name: COLUMN party.name; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.name IS 'LADM Definition: The first name(s) for the party or the group or organisation name.';


--
-- Name: COLUMN party.last_name; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.last_name IS 'SOLA Extension: The last name for the party or blank for groups and organisations.';


--
-- Name: COLUMN party.fathers_name; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.fathers_name IS 'SOLA Extension: The first name of the father for the party. Relevant where the fathers first name forms part of the name for the party.';


--
-- Name: COLUMN party.fathers_last_name; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.fathers_last_name IS 'SOLA Extension: The last name of the father for the party. Relevant where the fathers last name forms part of the name for the party.';


--
-- Name: COLUMN party.alias; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.alias IS 'SOLA Extension: Any alias for the party. A party can have more than one alias. If so, the aliases should be separated by a comma.';


--
-- Name: COLUMN party.gender_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.gender_code IS 'SOLA Extension: Identifies the gender for the party. If the party is of type naturalPerson then a gender code must be specified.';


--
-- Name: COLUMN party.address_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.address_id IS 'SOLA Extension: Identifier for the contact address of the party.';


--
-- Name: COLUMN party.id_type_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.id_type_code IS 'SOLA Extension: Used to indicate the type of id used to verify the identity of the party.';


--
-- Name: COLUMN party.id_number; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.id_number IS 'SOLA Extension: The number from the id used to verify the identity of the party.';


--
-- Name: COLUMN party.email; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.email IS 'SOLA Extension: The party''s contact email address.';


--
-- Name: COLUMN party.mobile; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.mobile IS 'SOLA Extension: The party''s contact mobile phone number.';


--
-- Name: COLUMN party.phone; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.phone IS 'SOLA Extension: The party''s main contact phone number. I.e. landline.';


--
-- Name: COLUMN party.fax; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.fax IS 'SOLA Extension: The party''s fax number.';


--
-- Name: COLUMN party.preferred_communication_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.preferred_communication_code IS 'SOLA Extension: Used to indicate the party''s preferred means of communication with the land administration agency.';


--
-- Name: COLUMN party.rowidentifier; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the party_historic table';


--
-- Name: COLUMN party.rowversion; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party.change_action; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party.change_user; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN party.change_time; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: party_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_historic (
    id character varying(40),
    ext_id character varying(255),
    type_code character varying(20),
    name character varying(255),
    last_name character varying(50),
    fathers_name character varying(50),
    fathers_last_name character varying(50),
    alias character varying(50),
    gender_code character varying(20),
    address_id character varying(40),
    id_type_code character varying(20),
    id_number character varying(20),
    email character varying(50),
    mobile character varying(15),
    phone character varying(15),
    fax character varying(15),
    preferred_communication_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_historic OWNER TO postgres;

--
-- Name: party_member; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_member (
    party_id character varying(40) NOT NULL,
    group_id character varying(40) NOT NULL,
    share double precision,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_member OWNER TO postgres;

--
-- Name: TABLE party_member; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party_member IS 'Identifies the parties belonging to a group party. Implementation of the LADM LA_PartyMember class. Not used by SOLA.
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN party_member.party_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.party_id IS 'LADM Definition: Identifier for the party.';


--
-- Name: COLUMN party_member.group_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.group_id IS 'LADM Definition: Identifier of the group party';


--
-- Name: COLUMN party_member.share; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.share IS 'LADM Definition: The share of a RRR held by a party member expressed as a fraction with a numerator and a denominator.';


--
-- Name: COLUMN party_member.rowidentifier; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the party_member_historic table';


--
-- Name: COLUMN party_member.rowversion; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_member.change_action; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_member.change_user; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN party_member.change_time; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_member.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: party_member_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_member_historic (
    party_id character varying(40),
    group_id character varying(40),
    share double precision,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_member_historic OWNER TO postgres;

--
-- Name: party_role; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_role (
    party_id character varying(40) NOT NULL,
    type_code character varying(20) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_role OWNER TO postgres;

--
-- Name: TABLE party_role; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party_role IS 'Identifies the roles a party has in relation to the land office transactions and data. Implementation of the LADM LA_Party.role feild.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN party_role.party_id; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.party_id IS 'LADM Definition: Identifier for the party.';


--
-- Name: COLUMN party_role.type_code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.type_code IS 'SOLA Extension: The type of role the party holds';


--
-- Name: COLUMN party_role.rowidentifier; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.rowidentifier IS 'SOLA Extension: Identifies the all change records for the row in the party_role_historic table';


--
-- Name: COLUMN party_role.rowversion; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.rowversion IS 'SOLA Extension: Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN party_role.change_action; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.change_action IS 'SOLA Extension: Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN party_role.change_user; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.change_user IS 'SOLA Extension: The user id of the last person to modify the row.';


--
-- Name: COLUMN party_role.change_time; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role.change_time IS 'SOLA Extension: The date and time the row was last modified.';


--
-- Name: party_role_historic; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_role_historic (
    party_id character varying(40),
    type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE party.party_role_historic OWNER TO postgres;

--
-- Name: party_role_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_role_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE party.party_role_type OWNER TO postgres;

--
-- Name: TABLE party_role_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party_role_type IS 'Code list of party role types. Used to identify the types of role a party can have in relation to land office transactions and data. E.g. applicant, bank, lodgingAgent, etc. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN party_role_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role_type.code IS 'The code for the party role type.';


--
-- Name: COLUMN party_role_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role_type.display_value IS 'Displayed value of the party role type.';


--
-- Name: COLUMN party_role_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role_type.status IS 'Status of the party role type';


--
-- Name: COLUMN party_role_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_role_type.description IS 'Description of the party role type.';


--
-- Name: party_type; Type: TABLE; Schema: party; Owner: postgres; Tablespace: 
--

CREATE TABLE party_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE party.party_type OWNER TO postgres;

--
-- Name: TABLE party_type; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON TABLE party_type IS 'Code list of party type types. Implementation of the LADM LA_PartyType class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN party_type.code; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_type.code IS 'LADM Definition: The code for the party type.';


--
-- Name: COLUMN party_type.display_value; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_type.display_value IS 'LADM Definition: Displayed value of the party type.';


--
-- Name: COLUMN party_type.status; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_type.status IS 'SOLA Extension: Status of the party type';


--
-- Name: COLUMN party_type.description; Type: COMMENT; Schema: party; Owner: postgres
--

COMMENT ON COLUMN party_type.description IS 'LADM Definition: Description of the party type.';


SET search_path = source, pg_catalog;

--
-- Name: administrative_source_type; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE administrative_source_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) NOT NULL,
    description character varying(555),
    is_for_registration boolean DEFAULT false
);


ALTER TABLE source.administrative_source_type OWNER TO postgres;

--
-- Name: TABLE administrative_source_type; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE administrative_source_type IS 'Code list of administrative source types. Used by SOLA to identify document types.
Implementation of the LADM LA_AdministrativeSourceType class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN administrative_source_type.code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.code IS 'LADM Definition: The code for the administrative source type.';


--
-- Name: COLUMN administrative_source_type.display_value; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.display_value IS 'LADM Definition: Displayed value of the administrative source type.';


--
-- Name: COLUMN administrative_source_type.status; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.status IS 'SOLA Extension: Status of the administrative source type';


--
-- Name: COLUMN administrative_source_type.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.description IS 'LADM Definition: Description of the administrative source type.';


--
-- Name: COLUMN administrative_source_type.is_for_registration; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN administrative_source_type.is_for_registration IS 'SOLA Extension: Flag that identifies whether documents of this type must be formally registered in SOLA before they can be used in rights registration. E.g. Power of Attorney documents must be registered in SOLA before they can be associated with transfer transactions, etc.';


--
-- Name: archive; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE archive (
    id character varying(40) NOT NULL,
    name character varying(50) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.archive OWNER TO postgres;

--
-- Name: TABLE archive; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE archive IS 'Represents an archive where collections of physical documents may be kept such as a filing cabinet, library or storage unit. May also refer to digital archives if applicable. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN archive.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.id IS 'Identifier for the archive.';


--
-- Name: COLUMN archive.name; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.name IS 'Description of the archive and/or it''s location. ';


--
-- Name: COLUMN archive.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.rowidentifier IS 'Identifies the all change records for the row in the archive_historic table';


--
-- Name: COLUMN archive.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN archive.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN archive.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN archive.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN archive.change_time IS 'The date and time the row was last modified.';


--
-- Name: archive_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE archive_historic (
    id character varying(40),
    name character varying(50),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.archive_historic OWNER TO postgres;

--
-- Name: availability_status_type; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE availability_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 'c'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE source.availability_status_type OWNER TO postgres;

--
-- Name: TABLE availability_status_type; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE availability_status_type IS 'Code list of availability status types. Indicates if a  document is available, archived, destroyed or incomplete. Implementation of the LADM LA_AvailabilityStatusType class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN availability_status_type.code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN availability_status_type.code IS 'LADM Definition: The code for the availability status type.';


--
-- Name: COLUMN availability_status_type.display_value; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN availability_status_type.display_value IS 'LADM Definition: Displayed value of the availability status type.';


--
-- Name: COLUMN availability_status_type.status; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN availability_status_type.status IS 'SOLA Extension: Status of the availability status type';


--
-- Name: COLUMN availability_status_type.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN availability_status_type.description IS 'LADM Definition: Description of the availability status type.';


--
-- Name: power_of_attorney; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE power_of_attorney (
    id character varying(40) NOT NULL,
    person_name character varying(500) NOT NULL,
    attorney_name character varying(500) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.power_of_attorney OWNER TO postgres;

--
-- Name: TABLE power_of_attorney; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE power_of_attorney IS 'An extension of the soure.source table that captures details for power of attorney documents. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN power_of_attorney.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.id IS 'Identifier for the power of attorney record. Matches the source identifier for the power of attorney record.';


--
-- Name: COLUMN power_of_attorney.person_name; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.person_name IS 'The name of the person that is granting the power of attorney (a.k.a. grantor).';


--
-- Name: COLUMN power_of_attorney.attorney_name; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.attorney_name IS 'The name of the person that will act on behalf of the grantor as their attorney.';


--
-- Name: COLUMN power_of_attorney.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.rowidentifier IS 'Identifies the all change records for the row in the power_of_attorney_historic table';


--
-- Name: COLUMN power_of_attorney.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN power_of_attorney.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN power_of_attorney.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN power_of_attorney.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN power_of_attorney.change_time IS 'The date and time the row was last modified.';


--
-- Name: power_of_attorney_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE power_of_attorney_historic (
    id character varying(40),
    person_name character varying(500),
    attorney_name character varying(500),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.power_of_attorney_historic OWNER TO postgres;

--
-- Name: presentation_form_type; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE presentation_form_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE source.presentation_form_type OWNER TO postgres;

--
-- Name: TABLE presentation_form_type; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE presentation_form_type IS 'Code list of presentation form types. Indicates the original format of the document when presented to the land office (e.g. Hardcopy, digital, image, video, etc). Implementation of the LADM CI_PresentationFormCode class.
Tags: Reference Table, LADM Reference Object';


--
-- Name: COLUMN presentation_form_type.code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN presentation_form_type.code IS 'LADM Definition: The code for the presentation form type.';


--
-- Name: COLUMN presentation_form_type.display_value; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN presentation_form_type.display_value IS 'LADM Definition: Displayed value of the presentation form type.';


--
-- Name: COLUMN presentation_form_type.status; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN presentation_form_type.status IS 'SOLA Extension: Status of the presentation form type';


--
-- Name: COLUMN presentation_form_type.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN presentation_form_type.description IS 'LADM Definition: Description of the presentation form type.';


--
-- Name: source; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE source (
    id character varying(40) NOT NULL,
    maintype character varying(20),
    la_nr character varying(20) NOT NULL,
    reference_nr character varying(20),
    archive_id character varying(40),
    acceptance date,
    recordation date,
    submission date DEFAULT now(),
    expiration_date date,
    ext_archive_id character varying(40),
    availability_status_code character varying(20) DEFAULT 'available'::character varying NOT NULL,
    type_code character varying(20) NOT NULL,
    content character varying(4000),
    status_code character varying(20),
    transaction_id character varying(40),
    owner_name character varying(255),
    version character varying(10),
    description character varying(255),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.source OWNER TO postgres;

--
-- Name: TABLE source; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE source IS 'Represents metadata about documents or recognised facts that provide the basis for the recording of a registration, cadastre change, right, responsibility or administrative action by the land office. Implementation of the LADM LA_Source class.
Tags: LADM Reference Object, Change History';


--
-- Name: COLUMN source.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.id IS 'LADM Definition: Source identifier.';


--
-- Name: COLUMN source.maintype; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.maintype IS 'LADM Definition: The type of the representation of the content of the source.';


--
-- Name: COLUMN source.la_nr; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.la_nr IS 'SOLA Extension: Reference number or identifier assigned to the document by the land office.';


--
-- Name: COLUMN source.reference_nr; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.reference_nr IS 'SOLA Extension: Reference number or identifier assigned to the document by an external agency.';


--
-- Name: COLUMN source.archive_id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.archive_id IS 'SOLA Extension: Archive identifier for the source. ';


--
-- Name: COLUMN source.acceptance; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.acceptance IS 'LADM Definition: The date of force of law of the source by an authority.';


--
-- Name: COLUMN source.recordation; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.recordation IS 'LADM Definition: The date of formalization by the source agency.';


--
-- Name: COLUMN source.submission; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.submission IS 'LADM Definition: The date of submission of the source by a party.';


--
-- Name: COLUMN source.expiration_date; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.expiration_date IS 'SOLA Extension: The date the document expires and is no longer enforceable.';


--
-- Name: COLUMN source.ext_archive_id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.ext_archive_id IS 'SOLA Extension: Identifier of the source in an external document management system. Used by SOLA to reference the digital copy of the document in the document table.';


--
-- Name: COLUMN source.availability_status_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.availability_status_code IS 'LADM Definition: The code describing the availability status of the document.';


--
-- Name: COLUMN source.type_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.type_code IS 'LADM Definition: The type of document.';


--
-- Name: COLUMN source.content; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.content IS 'LADM Definition: The content of the source. Not used by SOLA as digital copies of documents are stored in the document table.';


--
-- Name: COLUMN source.status_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.status_code IS 'SOLA Extension: Status (pending, current, historic) of the source. Only used for transactioned documents such as power of attorney.';


--
-- Name: COLUMN source.transaction_id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.transaction_id IS 'SOLA Extension: Reference to the transaction used to register the document in SOLA. Only used for transactioned documents such as power of attorney.';


--
-- Name: COLUMN source.owner_name; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.owner_name IS 'SOLA Extension: The name of the firm or bank that created the document (a.k.a. Source Agency).';


--
-- Name: COLUMN source.version; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.version IS 'SOLA Extension: The document version.';


--
-- Name: COLUMN source.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.description IS 'SOLA Extension: A description for summarizing the contents of the document.';


--
-- Name: COLUMN source.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.rowidentifier IS 'Identifies the all change records for the row in the source_historic table';


--
-- Name: COLUMN source.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN source.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN source.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN source.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN source.change_time IS 'The date and time the row was last modified.';


--
-- Name: source_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE source_historic (
    id character varying(40),
    maintype character varying(20),
    la_nr character varying(20),
    reference_nr character varying(20),
    archive_id character varying(40),
    acceptance date,
    recordation date,
    submission date,
    expiration_date date,
    ext_archive_id character varying(40),
    availability_status_code character varying(20),
    type_code character varying(20),
    content character varying(4000),
    status_code character varying(20),
    transaction_id character varying(40),
    owner_name character varying(255),
    version character varying(10),
    description character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.source_historic OWNER TO postgres;

--
-- Name: source_la_nr_seq; Type: SEQUENCE; Schema: source; Owner: postgres
--

CREATE SEQUENCE source_la_nr_seq
    START WITH 100000
    INCREMENT BY 1
    MINVALUE 100000
    MAXVALUE 999999
    CACHE 1;


ALTER TABLE source.source_la_nr_seq OWNER TO postgres;

--
-- Name: SEQUENCE source_la_nr_seq; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON SEQUENCE source_la_nr_seq IS 'Sequence number used as the basis for the Source nr field. This sequence is used by the generate-source-nr business rule.';


--
-- Name: spatial_source; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source (
    id character varying(40) NOT NULL,
    procedure character varying(255),
    type_code character varying(20) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.spatial_source OWNER TO postgres;

--
-- Name: TABLE spatial_source; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE spatial_source IS 'A spatial source may be the final (sometimes formal) documents, or all documents related to a survey. Sometimes serveral documents are the result of a single survey. A spatial source may be official or not (i.e. a registered survey plan or an aerial photograph). Implementation of the LADM LA_Source class. Not used by SOLA.
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN spatial_source.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.id IS 'LADM Definition: Spatial source identifier.';


--
-- Name: COLUMN spatial_source.procedure; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.procedure IS 'LADM Definition:  Procedures, steps or method adopted';


--
-- Name: COLUMN spatial_source.type_code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.type_code IS 'LADM Definition: Code type assigned to the source.';


--
-- Name: COLUMN spatial_source.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.rowidentifier IS 'Identifies the all change records for the row in the spatial_source_historic table';


--
-- Name: COLUMN spatial_source.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_source.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_source.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_source.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_source_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source_historic (
    id character varying(40),
    procedure character varying(255),
    type_code character varying(20),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.spatial_source_historic OWNER TO postgres;

--
-- Name: spatial_source_measurement; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source_measurement (
    spatial_source_id character varying(40) NOT NULL,
    id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.spatial_source_measurement OWNER TO postgres;

--
-- Name: TABLE spatial_source_measurement; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE spatial_source_measurement IS 'The observations and measurements as a basis of mapping, and as a basis for historical reconstruction of the location of (parts of) the spatial unit in the field. Implementation of the LADM OM_Observation class. Not used by SOLA.
Tags: LADM Reference Object, Change History, Not Used';


--
-- Name: COLUMN spatial_source_measurement.spatial_source_id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.spatial_source_id IS 'LADM Definition: Spatial source identifier.';


--
-- Name: COLUMN spatial_source_measurement.id; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.id IS 'LADM Definition: Spatial source measurement identifier.';


--
-- Name: COLUMN spatial_source_measurement.rowidentifier; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.rowidentifier IS 'Identifies the all change records for the row in the spatial_source_measurement_historic table';


--
-- Name: COLUMN spatial_source_measurement.rowversion; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN spatial_source_measurement.change_action; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN spatial_source_measurement.change_user; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN spatial_source_measurement.change_time; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_measurement.change_time IS 'The date and time the row was last modified.';


--
-- Name: spatial_source_measurement_historic; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source_measurement_historic (
    spatial_source_id character varying(40),
    id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE source.spatial_source_measurement_historic OWNER TO postgres;

--
-- Name: spatial_source_type; Type: TABLE; Schema: source; Owner: postgres; Tablespace: 
--

CREATE TABLE spatial_source_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) DEFAULT 't'::bpchar NOT NULL,
    description character varying(555)
);


ALTER TABLE source.spatial_source_type OWNER TO postgres;

--
-- Name: TABLE spatial_source_type; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON TABLE spatial_source_type IS 'Code list of spatial source types. Implementation of the LADM LA_SpatialSourceType class. Not used by SOLA.
Tags: Reference Table, LADM Reference Object, Not Used';


--
-- Name: COLUMN spatial_source_type.code; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_type.code IS 'LADM Definition: The code for the spatial source type.';


--
-- Name: COLUMN spatial_source_type.display_value; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_type.display_value IS 'LADM Definition: Displayed value of the spatial source type.';


--
-- Name: COLUMN spatial_source_type.status; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_type.status IS 'SOLA Extension: Status of the spatial source type';


--
-- Name: COLUMN spatial_source_type.description; Type: COMMENT; Schema: source; Owner: postgres
--

COMMENT ON COLUMN spatial_source_type.description IS 'LADM Definition: Description of the spatial source type.';


SET search_path = system, pg_catalog;

--
-- Name: approle_appgroup; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE approle_appgroup (
    approle_code character varying(20) NOT NULL,
    appgroup_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.approle_appgroup OWNER TO postgres;

--
-- Name: TABLE approle_appgroup; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE approle_appgroup IS 'Associates the application security roles to the groups. One role can exist in many groups.
Tags: FLOSS SOLA Extension, User Admin';


--
-- Name: COLUMN approle_appgroup.approle_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.approle_code IS 'Code for the security role.';


--
-- Name: COLUMN approle_appgroup.appgroup_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.appgroup_id IS 'Identifier for the group the role is associated to.';


--
-- Name: COLUMN approle_appgroup.rowidentifier; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.rowidentifier IS 'Identifies the all change records for the row in the system.approle_appgroup_historic table';


--
-- Name: COLUMN approle_appgroup.rowversion; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN approle_appgroup.change_action; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN approle_appgroup.change_user; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN approle_appgroup.change_time; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle_appgroup.change_time IS 'The date and time the row was last modified.';


--
-- Name: appuser; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser (
    id character varying(40) NOT NULL,
    username character varying(40) NOT NULL,
    first_name character varying(30) NOT NULL,
    last_name character varying(30) NOT NULL,
    passwd character varying(100) DEFAULT public.uuid_generate_v1() NOT NULL,
    active boolean DEFAULT true NOT NULL,
    description character varying(255),
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.appuser OWNER TO postgres;

--
-- Name: TABLE appuser; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE appuser IS 'The list of users that can have access to the SOLA application.
Tags: FLOSS SOLA Extension, User Admin';


--
-- Name: COLUMN appuser.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.id IS 'The SOLA user identifier.';


--
-- Name: COLUMN appuser.username; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.username IS 'The user name assigned to the SOLA user.';


--
-- Name: COLUMN appuser.first_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.first_name IS 'The first name of the SOLA user.';


--
-- Name: COLUMN appuser.last_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.last_name IS 'The last name of the SOLA user.';


--
-- Name: COLUMN appuser.passwd; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.passwd IS 'The hash encrypted password for the SOLA user.';


--
-- Name: COLUMN appuser.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.active IS 'Flag to indicate if the SOLA user is active and can log into the application or not.';


--
-- Name: COLUMN appuser.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.description IS 'A description for the SOLA user.';


--
-- Name: COLUMN appuser.rowidentifier; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.rowidentifier IS 'Identifies the all change records for the row in the system.appuser_historic table';


--
-- Name: COLUMN appuser.rowversion; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN appuser.change_action; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN appuser.change_user; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN appuser.change_time; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser.change_time IS 'The date and time the row was last modified.';


--
-- Name: appuser_appgroup; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser_appgroup (
    appuser_id character varying(40) NOT NULL,
    appgroup_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.appuser_appgroup OWNER TO postgres;

--
-- Name: TABLE appuser_appgroup; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE appuser_appgroup IS 'Associates users to groups. Each user can be assigned multiple groups.
Tags: FLOSS SOLA Extension, User Admin';


--
-- Name: COLUMN appuser_appgroup.appuser_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.appuser_id IS 'Identifier for the SOLA user.';


--
-- Name: COLUMN appuser_appgroup.appgroup_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.appgroup_id IS 'Identifier for the group the user is associated to.';


--
-- Name: COLUMN appuser_appgroup.rowidentifier; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.rowidentifier IS 'Identifies the all change records for the row in the system.appuser_appgroup_historic table';


--
-- Name: COLUMN appuser_appgroup.rowversion; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN appuser_appgroup.change_action; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN appuser_appgroup.change_user; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN appuser_appgroup.change_time; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_appgroup.change_time IS 'The date and time the row was last modified.';


--
-- Name: appuser_historic; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser_historic (
    id character varying(40),
    username character varying(40),
    first_name character varying(30),
    last_name character varying(30),
    passwd character varying(100),
    active boolean,
    description character varying(255),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.appuser_historic OWNER TO postgres;

--
-- Name: setting; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE setting (
    name character varying(50) NOT NULL,
    vl character varying(2000) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    description character varying(555) NOT NULL
);


ALTER TABLE system.setting OWNER TO postgres;

--
-- Name: TABLE setting; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE setting IS 'Contains global settings for the SOLA application. Refer to the Administration Guide or the ConfigConstants class in the Common Utilities project for a list of the recognized settings. Note that not all possible settings are listed in the settings table. Settings may be omitted from this table if the default value applies.
Tags: FLOSS SOLA Extension, Reference Table, System Configuration';


--
-- Name: COLUMN setting.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN setting.name IS 'Identifier/name for the setting';


--
-- Name: COLUMN setting.vl; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN setting.vl IS 'The value for the setting.';


--
-- Name: COLUMN setting.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN setting.active IS 'Indicates if the setting is active or not. If not active, the default value for the setting will apply.';


--
-- Name: COLUMN setting.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN setting.description IS 'Description of the setting. ';


--
-- Name: user_roles; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW user_roles AS
    SELECT u.username, rg.approle_code AS rolename FROM ((appuser u JOIN appuser_appgroup ug ON ((((u.id)::text = (ug.appuser_id)::text) AND u.active))) JOIN approle_appgroup rg ON (((ug.appgroup_id)::text = (rg.appgroup_id)::text)));


ALTER TABLE system.user_roles OWNER TO postgres;

--
-- Name: VIEW user_roles; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW user_roles IS 'Determines the application security roles assigned to each user. Referenced by the SolaRealm security configuration in Glassfish.';


--
-- Name: user_pword_expiry; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW user_pword_expiry AS
    WITH pw_change_all AS (SELECT u.username, u.change_time, u.change_user, u.rowversion FROM appuser u WHERE (NOT (EXISTS (SELECT uh2.id FROM appuser_historic uh2 WHERE ((((uh2.username)::text = (u.username)::text) AND (uh2.rowversion = (u.rowversion - 1))) AND ((uh2.passwd)::text = (u.passwd)::text))))) UNION SELECT uh.username, uh.change_time, uh.change_user, uh.rowversion FROM appuser_historic uh WHERE (NOT (EXISTS (SELECT uh2.id FROM appuser_historic uh2 WHERE ((((uh2.username)::text = (uh.username)::text) AND (uh2.rowversion = (uh.rowversion - 1))) AND ((uh2.passwd)::text = (uh.passwd)::text)))))), pw_change AS (SELECT pall.username AS uname, pall.change_time AS last_pword_change, pall.change_user AS pword_change_user FROM pw_change_all pall WHERE (pall.rowversion = (SELECT max(p2.rowversion) AS max FROM pw_change_all p2 WHERE ((p2.username)::text = (pall.username)::text)))) SELECT p.uname, p.last_pword_change, p.pword_change_user, CASE WHEN (EXISTS (SELECT r.username FROM user_roles r WHERE (((r.username)::text = (p.uname)::text) AND ((r.rolename)::text = ANY (ARRAY[('ManageSecurity'::character varying)::text, ('NoPasswordExpiry'::character varying)::text]))))) THEN true ELSE false END AS no_pword_expiry, CASE WHEN (s.vl IS NULL) THEN NULL::integer ELSE (((p.last_pword_change)::date - (now())::date) + (s.vl)::integer) END AS pword_expiry_days FROM (pw_change p LEFT JOIN setting s ON ((((s.name)::text = 'pword-expiry-days'::text) AND s.active)));


ALTER TABLE system.user_pword_expiry OWNER TO postgres;

--
-- Name: VIEW user_pword_expiry; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW user_pword_expiry IS 'Determines the number of days until the users password expires. Once the number of days reaches 0, users will not be able to log into SOLA unless they have the ManageSecurity role (i.e. role to change manage user accounts) or the NoPasswordExpiry role. To configure the number of days before a password expires, set the pword-expiry-days setting in system.setting table. If this setting is not in place, then a password expiry does not apply.';


--
-- Name: active_users; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW active_users AS
    SELECT u.username, u.passwd FROM appuser u, user_pword_expiry ex WHERE (((u.active = true) AND ((ex.uname)::text = (u.username)::text)) AND ((COALESCE(ex.pword_expiry_days, 1) > 0) OR (ex.no_pword_expiry = true)));


ALTER TABLE system.active_users OWNER TO postgres;

--
-- Name: VIEW active_users; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW active_users IS 'Identifies the users currently active in the system. If the users password has expired, then they are treated as inactive users, unless they are System Administrators. This view is intended to replace the system.appuser table in the SolaRealm configuration in Glassfish.';


--
-- Name: appgroup; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appgroup (
    id character varying(40) NOT NULL,
    name character varying(300) NOT NULL,
    description character varying(500)
);


ALTER TABLE system.appgroup OWNER TO postgres;

--
-- Name: TABLE appgroup; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE appgroup IS 'Groups application security roles to simplify assignment of roles to individual system users. 
Tags: FLOSS SOLA Extension, User Admin';


--
-- Name: COLUMN appgroup.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appgroup.id IS 'Identifier for the appgroup.';


--
-- Name: COLUMN appgroup.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appgroup.name IS 'The name assigned to the appgroup.';


--
-- Name: COLUMN appgroup.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appgroup.description IS 'Describes the purpose of the appgroup and should also indicate when it applies.';


--
-- Name: approle; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE approle (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) NOT NULL,
    description character varying(555)
);


ALTER TABLE system.approle OWNER TO postgres;

--
-- Name: TABLE approle; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE approle IS 'Contains the list of application security roles used to restrict access to different parts of the application, both on the server and client side. 
Tags: FLOSS SOLA Extension, Reference Table, User Admin';


--
-- Name: COLUMN approle.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle.code IS 'Code for the security role. Must match exactly the code value used within the SOLA source code to reference the role.';


--
-- Name: COLUMN approle.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN approle.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle.status IS 'The status of the role.';


--
-- Name: COLUMN approle.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN approle.description IS 'Describes the purpose of the role and should also indicate when it applies.';


--
-- Name: approle_appgroup_historic; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE approle_appgroup_historic (
    approle_code character varying(20),
    appgroup_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.approle_appgroup_historic OWNER TO postgres;

--
-- Name: appuser_appgroup_historic; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser_appgroup_historic (
    appuser_id character varying(40),
    appgroup_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE system.appuser_appgroup_historic OWNER TO postgres;

--
-- Name: appuser_setting; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE appuser_setting (
    user_id character varying(40) NOT NULL,
    name character varying(50) NOT NULL,
    vl character varying(2000) NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE system.appuser_setting OWNER TO postgres;

--
-- Name: TABLE appuser_setting; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE appuser_setting IS 'Software settings specific for a user within the SOLA application. Not used by SOLA.
Tags: FLOSS SOLA Extension, User Admin, Not Used';


--
-- Name: COLUMN appuser_setting.user_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_setting.user_id IS 'Identifier of the user the setting applies to.';


--
-- Name: COLUMN appuser_setting.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_setting.name IS 'The name of the setting.';


--
-- Name: COLUMN appuser_setting.vl; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_setting.vl IS 'The value of the setting';


--
-- Name: COLUMN appuser_setting.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN appuser_setting.active IS 'Flag to indicate if the setting is active or not.';


--
-- Name: br; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br (
    id character varying(100) NOT NULL,
    display_name character varying(250) DEFAULT public.uuid_generate_v1() NOT NULL,
    technical_type_code character varying(20) NOT NULL,
    feedback character varying(2000),
    description character varying(1000),
    technical_description character varying(1000)
);


ALTER TABLE system.br OWNER TO postgres;

--
-- Name: TABLE br; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br IS 'Provides a description of the business rules used by SOLA.
Tags: FLOSS SOLA Extension, Business Rules';


--
-- Name: COLUMN br.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.id IS 'The name of the business rule';


--
-- Name: COLUMN br.display_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.display_name IS 'The display name for the business rule.';


--
-- Name: COLUMN br.technical_type_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.technical_type_code IS 'Indicates which engine must be used to run the business rule (sql or drools). Note that SOLA does not currently implement any Drools rules.';


--
-- Name: COLUMN br.feedback; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.feedback IS 'The message that should be displayed to the user if the rule is not complied with.';


--
-- Name: COLUMN br.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.description IS 'A description of the business rule. Intended for system administrators and end users.';


--
-- Name: COLUMN br.technical_description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br.technical_description IS 'A technical description of the business rule including any parameters the rule expects. Intended for developers.';


--
-- Name: br_definition; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_definition (
    br_id character varying(100) NOT NULL,
    active_from date NOT NULL,
    active_until date DEFAULT 'infinity'::date NOT NULL,
    body character varying(4000) NOT NULL
);


ALTER TABLE system.br_definition OWNER TO postgres;

--
-- Name: TABLE br_definition; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_definition IS 'Contains the code definition for business rules used by SOLA. These rules can be assigned an active date range allowing new rules to superseed old rules at specific dates. 
Tags: FLOSS SOLA Extension, Business Rules';


--
-- Name: COLUMN br_definition.br_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_definition.br_id IS 'Identifier for the business rule';


--
-- Name: COLUMN br_definition.active_from; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_definition.active_from IS 'The date this version of the rule is active from.';


--
-- Name: COLUMN br_definition.active_until; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_definition.active_until IS 'The date until this version of the rule is active.';


--
-- Name: COLUMN br_definition.body; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_definition.body IS 'The definition of the rule. Either SQL commands or Drools XML.';


--
-- Name: br_current; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW br_current AS
    SELECT b.id, b.technical_type_code, b.feedback, bd.body FROM (br b JOIN br_definition bd ON (((b.id)::text = (bd.br_id)::text))) WHERE ((now() >= bd.active_from) AND (now() <= bd.active_until));


ALTER TABLE system.br_current OWNER TO postgres;

--
-- Name: VIEW br_current; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW br_current IS 'Determines the currently active business rules based on the active_from, active_to date range';


--
-- Name: br_validation; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_validation (
    id character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    br_id character varying(100) NOT NULL,
    target_code character varying(20) NOT NULL,
    target_application_moment character varying(20),
    target_service_moment character varying(20),
    target_reg_moment character varying(20),
    target_request_type_code character varying(20),
    target_rrr_type_code character varying(20),
    severity_code character varying(20) NOT NULL,
    order_of_execution integer DEFAULT 0 NOT NULL,
    CONSTRAINT br_validation_application_moment_valid CHECK ((((target_code)::text <> 'application'::text) OR ((((target_code)::text = 'application'::text) AND (target_service_moment IS NULL)) AND (target_reg_moment IS NULL)))),
    CONSTRAINT br_validation_reg_moment_valid CHECK ((((target_code)::text = ANY (ARRAY[('application'::character varying)::text, ('service'::character varying)::text])) OR ((((target_code)::text <> ALL (ARRAY[('application'::character varying)::text, ('service'::character varying)::text])) AND (target_service_moment IS NULL)) AND (target_application_moment IS NULL)))),
    CONSTRAINT br_validation_rrr_rrr_type_valid CHECK (((target_rrr_type_code IS NULL) OR ((target_rrr_type_code IS NOT NULL) AND ((target_code)::text = 'rrr'::text)))),
    CONSTRAINT br_validation_service_moment_valid CHECK ((((target_code)::text <> 'service'::text) OR ((((target_code)::text = 'service'::text) AND (target_application_moment IS NULL)) AND (target_reg_moment IS NULL)))),
    CONSTRAINT br_validation_service_request_type_valid CHECK (((target_request_type_code IS NULL) OR ((target_request_type_code IS NOT NULL) AND ((target_code)::text <> 'application'::text))))
);


ALTER TABLE system.br_validation OWNER TO postgres;

--
-- Name: TABLE br_validation; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_validation IS 'Identifies the set of rules to execute based on the user action being peformed. E.g. approval of an application, cancellation of a service, etc. 
Tags: FLOSS SOLA Extension, Business Rules';


--
-- Name: COLUMN br_validation.id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.id IS 'Identifier for the br validation';


--
-- Name: COLUMN br_validation.br_id; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.br_id IS 'The business rule referenced by this br validation record.';


--
-- Name: COLUMN br_validation.target_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_code IS 'The entity that is the target of the validation E.g. application, service, rrr, etc.';


--
-- Name: COLUMN br_validation.target_application_moment; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_application_moment IS 'Identifies the application action the rule applies to. E.g. approve, validate, etc. Only valid if target_code is application.';


--
-- Name: COLUMN br_validation.target_service_moment; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_service_moment IS 'Identifies the service action the rule applies to. E.g. complete, start, cancel, etc. Only valid if the target_code is service.';


--
-- Name: COLUMN br_validation.target_reg_moment; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_reg_moment IS 'Identifies the entity status the rule applies to. E.g. current, pending, etc. Only valid if target_code is one of ba_unit, cadastre_object, source, rrr or bulkOperationSpatial.';


--
-- Name: COLUMN br_validation.target_request_type_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_request_type_code IS 'Used as an additional filter for the set of business rules to run by ensuring the rule is only executed if the service type (a.k.a. request_type) matches the specified value.';


--
-- Name: COLUMN br_validation.target_rrr_type_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.target_rrr_type_code IS 'Used as an additional filter for the set of business rules to run by ensuring the rule is only executed if the rrr type matches the specified value.';


--
-- Name: COLUMN br_validation.severity_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.severity_code IS 'The severity of the business rule failure.';


--
-- Name: COLUMN br_validation.order_of_execution; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation.order_of_execution IS 'Number used to order the execution of business rules in the rule set.';


--
-- Name: br_report; Type: VIEW; Schema: system; Owner: postgres
--

CREATE VIEW br_report AS
    SELECT b.id, b.technical_type_code, b.feedback, b.description, CASE WHEN ((bv.target_code)::text = 'application'::text) THEN bv.target_application_moment WHEN ((bv.target_code)::text = 'service'::text) THEN bv.target_service_moment ELSE bv.target_reg_moment END AS moment_code, bd.body, bv.severity_code, bv.target_code, bv.target_request_type_code, bv.target_rrr_type_code, bv.order_of_execution FROM ((br b LEFT JOIN br_validation bv ON (((b.id)::text = (bv.br_id)::text))) JOIN br_definition bd ON (((b.id)::text = (bd.br_id)::text))) WHERE ((now() >= bd.active_from) AND (now() <= bd.active_until)) ORDER BY b.id;


ALTER TABLE system.br_report OWNER TO postgres;

--
-- Name: VIEW br_report; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON VIEW br_report IS 'Used in the generation of the Admin Business Rules Report that presents summary details for all active business rules in the system.';


--
-- Name: br_severity_type; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_severity_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) NOT NULL,
    description character varying(555)
);


ALTER TABLE system.br_severity_type OWNER TO postgres;

--
-- Name: TABLE br_severity_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_severity_type IS 'The severity types applicable to the SOLA business rules.
Tags: FLOSS SOLA Extension, Reference Table, Business Rules';


--
-- Name: COLUMN br_severity_type.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_severity_type.code IS 'Code for the severity type.';


--
-- Name: COLUMN br_severity_type.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_severity_type.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN br_severity_type.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_severity_type.status IS 'The status of the severity type.';


--
-- Name: COLUMN br_severity_type.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_severity_type.description IS 'A description of the severity type.';


--
-- Name: br_technical_type; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_technical_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) NOT NULL,
    description character varying(555)
);


ALTER TABLE system.br_technical_type OWNER TO postgres;

--
-- Name: TABLE br_technical_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_technical_type IS 'Codes use for each type of rule implementation supported by SOLA. Curently SQL and Drools, however no Drools rules have been developed.
Tags: FLOSS SOLA Extension, Reference Table, Business Rules';


--
-- Name: COLUMN br_technical_type.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_technical_type.code IS 'Code for the technical type.';


--
-- Name: COLUMN br_technical_type.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_technical_type.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN br_technical_type.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_technical_type.status IS 'The status of the technical type.';


--
-- Name: COLUMN br_technical_type.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_technical_type.description IS 'A description of the technical type.';


--
-- Name: br_validation_target_type; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE br_validation_target_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) NOT NULL,
    description character varying(555)
);


ALTER TABLE system.br_validation_target_type OWNER TO postgres;

--
-- Name: TABLE br_validation_target_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE br_validation_target_type IS 'Lists potential targets for the business rules.
Tags: FLOSS SOLA Extension, Reference Table, Business Rules';


--
-- Name: COLUMN br_validation_target_type.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation_target_type.code IS 'Code for the validation target type.';


--
-- Name: COLUMN br_validation_target_type.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation_target_type.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN br_validation_target_type.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation_target_type.status IS 'The status of the validation target type.';


--
-- Name: COLUMN br_validation_target_type.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN br_validation_target_type.description IS 'A description of the validation target type.';


--
-- Name: config_map_layer; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE config_map_layer (
    name character varying(50) NOT NULL,
    title character varying(100) NOT NULL,
    type_code character varying(20) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    visible_in_start boolean DEFAULT true NOT NULL,
    item_order integer DEFAULT 0 NOT NULL,
    style character varying(4000),
    url character varying(500),
    wms_layers character varying(500),
    wms_version character varying(10),
    wms_format character varying(15),
    pojo_structure character varying(500),
    pojo_query_name character varying(100),
    pojo_query_name_for_select character varying(100),
    shape_location character varying(500),
    security_user character varying(30),
    security_password character varying(30),
    CONSTRAINT config_map_layer_fields_required CHECK (CASE WHEN ((type_code)::text = 'wms'::text) THEN ((url IS NOT NULL) AND (wms_layers IS NOT NULL)) WHEN ((type_code)::text = 'pojo'::text) THEN (((pojo_query_name IS NOT NULL) AND (pojo_structure IS NOT NULL)) AND (style IS NOT NULL)) WHEN ((type_code)::text = 'shape'::text) THEN ((shape_location IS NOT NULL) AND (style IS NOT NULL)) ELSE NULL::boolean END)
);


ALTER TABLE system.config_map_layer OWNER TO postgres;

--
-- Name: TABLE config_map_layer; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE config_map_layer IS 'Identifies the layers available for display in the SOLA Map Viewer.
Tags: FLOSS SOLA Extension, Reference Table, Map Configuration';


--
-- Name: COLUMN config_map_layer.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.name IS 'Name assigned to the map layer.';


--
-- Name: COLUMN config_map_layer.title; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.title IS 'The title used for the layer when it is displayed in the map control.';


--
-- Name: COLUMN config_map_layer.type_code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.type_code IS 'Indicates the source of data for the map layer. One of pojo (Plain Old Java Object - SOLA specific), wms (Web Map Service), shape (Shapefile)';


--
-- Name: COLUMN config_map_layer.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.active IS 'Flag to indicate if the layer is active. Inactive layers are not displayed in the map layer control.';


--
-- Name: COLUMN config_map_layer.visible_in_start; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.visible_in_start IS 'Flag to indicate if the layer should be turned on and display when the map initially displays';


--
-- Name: COLUMN config_map_layer.item_order; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.item_order IS 'The order to use for display of layers in the layer control. The layer with the lowest number will be displayed at the bottom of the layer control.';


--
-- Name: COLUMN config_map_layer.style; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.style IS 'An SLD document representing the styles to use for display of the layer features in the map.';


--
-- Name: COLUMN config_map_layer.url; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.url IS 'The URL identifying the data source for a WMS layer.';


--
-- Name: COLUMN config_map_layer.wms_layers; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.wms_layers IS 'The names of the layers to request when obtaining data from a Web Map Service. Layer names must be separated with a comma.';


--
-- Name: COLUMN config_map_layer.wms_version; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.wms_version IS 'The version of the WMS server. Values can be one of 1.0.0, 1.1.0, 1.1.1, 1.3.0.';


--
-- Name: COLUMN config_map_layer.wms_format; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.wms_format IS 'Format of the output for the WMS layer. Allowed values are as defined by the WMS server capabilities. E.g. image/png or image/jpeg.';


--
-- Name: COLUMN config_map_layer.pojo_structure; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.pojo_structure IS 'Plain old java object structure. Must be specified in the same format as requried by the Geotools featuretype definition. E.g. theGeom:Polygon,label:""';


--
-- Name: COLUMN config_map_layer.pojo_query_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.pojo_query_name IS 'The name of the query (i.e. system.query) used to retrieve features for this layer.';


--
-- Name: COLUMN config_map_layer.pojo_query_name_for_select; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.pojo_query_name_for_select IS 'The name of the query to use to select objects corresponding to the layer. Can be used for any layer type';


--
-- Name: COLUMN config_map_layer.shape_location; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.shape_location IS 'The location of the shapefile. Used for layers of type shape. THe client application must have access to the shape file location.';


--
-- Name: COLUMN config_map_layer.security_user; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.security_user IS 'The username to access a secure wms layer. Not currently used.';


--
-- Name: COLUMN config_map_layer.security_password; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer.security_password IS 'The password to access a secure wms layer. Not currently used.';


--
-- Name: config_map_layer_type; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE config_map_layer_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    status character(1) NOT NULL,
    description character varying(555)
);


ALTER TABLE system.config_map_layer_type OWNER TO postgres;

--
-- Name: TABLE config_map_layer_type; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE config_map_layer_type IS 'Lists the map layer types for the config_map_layer table.
Tags: FLOSS SOLA Extension, Reference Table, Map Configuration';


--
-- Name: COLUMN config_map_layer_type.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer_type.code IS 'Code for the map layer type.';


--
-- Name: COLUMN config_map_layer_type.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer_type.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN config_map_layer_type.status; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer_type.status IS 'The status of the map layer type.';


--
-- Name: COLUMN config_map_layer_type.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN config_map_layer_type.description IS 'A description of the map layer type.';


--
-- Name: language; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE language (
    code character varying(7) NOT NULL,
    display_value character varying(250) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    item_order integer DEFAULT 1 NOT NULL
);


ALTER TABLE system.language OWNER TO postgres;

--
-- Name: TABLE language; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE language IS 'Lists the languages configured for the SOLA application
Tags: FLOSS SOLA Extension, Reference Table, System Configuration';


--
-- Name: COLUMN language.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.code IS 'Code for the langauge.';


--
-- Name: COLUMN language.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.display_value IS 'The text value that will be displayed to the user.';


--
-- Name: COLUMN language.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.active IS 'Indicates if the language is current active or not.';


--
-- Name: COLUMN language.is_default; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.is_default IS 'Indicates the default language used by SOLA. Only one record in the table should have is_default = true.';


--
-- Name: COLUMN language.item_order; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN language.item_order IS 'The order the langages should be displayed. The lowest order number will display the langage at the top of the language list. Also identifies the order that all localized string values must store their language translations.';


--
-- Name: map_search_option; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE map_search_option (
    code character varying(20) NOT NULL,
    title character varying(50) NOT NULL,
    query_name character varying(100) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    min_search_str_len smallint DEFAULT 3 NOT NULL,
    zoom_in_buffer numeric(20,2) DEFAULT 50 NOT NULL,
    description character varying(500)
);


ALTER TABLE system.map_search_option OWNER TO postgres;

--
-- Name: TABLE map_search_option; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE map_search_option IS 'Identifies the map search options supported in the Map Viewer along with their configuration details. 
Tags: FLOSS SOLA Extension, Reference Table, Map Configuration';


--
-- Name: COLUMN map_search_option.code; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.code IS 'The code for the map search option.';


--
-- Name: COLUMN map_search_option.title; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.title IS 'The title displayed to the user for the map search option.';


--
-- Name: COLUMN map_search_option.query_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.query_name IS 'The query (i.e. system.query) that will be used for retrieving the search results. The query requires only one parameter : search_string. Map search queries must be defined to use this parameter and return 3 fields; id - unique id for the matched item, label - the value to display to the user, the_geom: the WKB of the matched geometry.';


--
-- Name: COLUMN map_search_option.active; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.active IS 'Indicates the Map Search Option is active or not.';


--
-- Name: COLUMN map_search_option.min_search_str_len; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.min_search_str_len IS 'The minimum number of characters required for the search string.';


--
-- Name: COLUMN map_search_option.zoom_in_buffer; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.zoom_in_buffer IS 'The buffer distance to use when zooming the map to display the selected object. The units of this value are dependent on the coordinate system of the map (usually meters).';


--
-- Name: COLUMN map_search_option.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN map_search_option.description IS 'A description for the search option.';


--
-- Name: query; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE query (
    name character varying(100) NOT NULL,
    sql character varying(4000) NOT NULL,
    description character varying(1000)
);


ALTER TABLE system.query OWNER TO postgres;

--
-- Name: TABLE query; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE query IS 'Defines SQL queries that can be executed dynamically by the Search EJB. Also defines queries to retrieve spatial features for each map layer.
Tags: FLOSS SOLA Extension, Reference Table, System Configuration';


--
-- Name: COLUMN query.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query.name IS 'Identifier/name for the query';


--
-- Name: COLUMN query.sql; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query.sql IS 'The SQL query definition. These SQL queries are executed using MyBatis, so it is possible to identify query parameters using the #{param} syntax.';


--
-- Name: COLUMN query.description; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query.description IS 'Technical description for the query.';


--
-- Name: query_field; Type: TABLE; Schema: system; Owner: postgres; Tablespace: 
--

CREATE TABLE query_field (
    query_name character varying(100) NOT NULL,
    index_in_query integer NOT NULL,
    name character varying(100) NOT NULL,
    display_value character varying(200)
);


ALTER TABLE system.query_field OWNER TO postgres;

--
-- Name: TABLE query_field; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON TABLE query_field IS 'Optionally defines the fields returned by the queries listed in the system.query table. It is not necessary to specify query fields for every dynamic query. Query fields are only required where the results displayed to the user will vary and localization of the field titles is required. For example the Information Tool in the map displays different result fields for each map layer in the same form.
Tags: FLOSS SOLA Extension, Reference Table, System Configuration';


--
-- Name: COLUMN query_field.query_name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query_field.query_name IS 'Identifier/name for the query';


--
-- Name: COLUMN query_field.index_in_query; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query_field.index_in_query IS 'Indicates the position of the result field in the query result set. The index is zero based. The number must not exceed the number of fields in the select part of the query.';


--
-- Name: COLUMN query_field.name; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query_field.name IS 'Identifier/name for the query field';


--
-- Name: COLUMN query_field.display_value; Type: COMMENT; Schema: system; Owner: postgres
--

COMMENT ON COLUMN query_field.display_value IS 'The title to display for the query field when presenting results to the user. This value supports localization.';


SET search_path = transaction, pg_catalog;

--
-- Name: reg_status_type; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE reg_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL
);


ALTER TABLE transaction.reg_status_type OWNER TO postgres;

--
-- Name: TABLE reg_status_type; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON TABLE reg_status_type IS 'Code list of registration status types. E.g. current, historic, pending, previous. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN reg_status_type.code; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN reg_status_type.code IS 'The code for the registration status type.';


--
-- Name: COLUMN reg_status_type.display_value; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN reg_status_type.display_value IS 'Displayed value of the registration status type.';


--
-- Name: COLUMN reg_status_type.description; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN reg_status_type.description IS 'Description of the registration status type.';


--
-- Name: COLUMN reg_status_type.status; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN reg_status_type.status IS 'Status of the registration status type';


--
-- Name: transaction; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction (
    id character varying(40) NOT NULL,
    from_service_id character varying(40),
    status_code character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    approval_datetime timestamp without time zone,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL,
    spatial_unit_group_id character varying(40)
);


ALTER TABLE transaction.transaction OWNER TO postgres;

--
-- Name: TABLE transaction; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON TABLE transaction IS 'Transactions are used to group changes to registered data (i.e. Property, RRR and Parcels). Each service initiates a transaction that is then recorded against any data edits made by the user. When the service is complete and the application approved, the data associated with the transction can be approved/registered as well. If the user chooses to reject their changes prior to approval, the transaction can be used to determine which data edits need to be removed from the system without affecting the currently registered data. 
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN transaction.id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.id IS 'Identifier for the transaction.';


--
-- Name: COLUMN transaction.from_service_id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.from_service_id IS 'The identifier of the service that initiated the transaction. NULL if the transaction has been created using other means. E.g. for migration or bulk data loading purposes.';


--
-- Name: COLUMN transaction.status_code; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.status_code IS 'The status of the transaction';


--
-- Name: COLUMN transaction.approval_datetime; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.approval_datetime IS 'The date and time the transaction is approved.';


--
-- Name: COLUMN transaction.rowidentifier; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.rowidentifier IS 'Identifies the all change records for the row in the transaction_historic table';


--
-- Name: COLUMN transaction.rowversion; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN transaction.change_action; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN transaction.change_user; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN transaction.change_time; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.change_time IS 'The date and time the row was last modified.';


--
-- Name: COLUMN transaction.spatial_unit_group_id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction.spatial_unit_group_id IS 'Indicates this transaction is for a Unit Development plan as specified by the spatial unit group.';


--
-- Name: transaction_historic; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_historic (
    id character varying(40),
    from_service_id character varying(40),
    status_code character varying(20),
    approval_datetime timestamp without time zone,
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL,
    spatial_unit_group_id character varying(40)
);


ALTER TABLE transaction.transaction_historic OWNER TO postgres;

--
-- Name: transaction_source; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_source (
    transaction_id character varying(40) NOT NULL,
    source_id character varying(40) NOT NULL,
    rowidentifier character varying(40) DEFAULT public.uuid_generate_v1() NOT NULL,
    rowversion integer DEFAULT 0 NOT NULL,
    change_action character(1) DEFAULT 'i'::bpchar NOT NULL,
    change_user character varying(50),
    change_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE transaction.transaction_source OWNER TO postgres;

--
-- Name: TABLE transaction_source; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON TABLE transaction_source IS 'Associates transactions to source (a.k.a. documents) that justify the transaction. Used by the Cadastre Change and Cadastre Redefintion services.  
Tags: FLOSS SOLA Extension, Change History';


--
-- Name: COLUMN transaction_source.transaction_id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.transaction_id IS 'Identifier for the transaction.';


--
-- Name: COLUMN transaction_source.source_id; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.source_id IS 'The identifier of the source associated to the transation.';


--
-- Name: COLUMN transaction_source.rowidentifier; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.rowidentifier IS 'Identifies the all change records for the row in the transaction_source_historic table';


--
-- Name: COLUMN transaction_source.rowversion; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';


--
-- Name: COLUMN transaction_source.change_action; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';


--
-- Name: COLUMN transaction_source.change_user; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.change_user IS 'The user id of the last person to modify the row.';


--
-- Name: COLUMN transaction_source.change_time; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_source.change_time IS 'The date and time the row was last modified.';


--
-- Name: transaction_source_historic; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_source_historic (
    transaction_id character varying(40),
    source_id character varying(40),
    rowidentifier character varying(40),
    rowversion integer,
    change_action character(1),
    change_user character varying(50),
    change_time timestamp without time zone,
    change_time_valid_until timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE transaction.transaction_source_historic OWNER TO postgres;

--
-- Name: transaction_status_type; Type: TABLE; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE TABLE transaction_status_type (
    code character varying(20) NOT NULL,
    display_value character varying(250) NOT NULL,
    description character varying(555),
    status character(1) NOT NULL
);


ALTER TABLE transaction.transaction_status_type OWNER TO postgres;

--
-- Name: TABLE transaction_status_type; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON TABLE transaction_status_type IS 'Code list of transaction status types. E.g. pending, approved, cancelled, completed. 
Tags: FLOSS SOLA Extension, Reference Table';


--
-- Name: COLUMN transaction_status_type.code; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_status_type.code IS 'The code for the transaction status type.';


--
-- Name: COLUMN transaction_status_type.display_value; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_status_type.display_value IS 'Displayed value of the transaction status type.';


--
-- Name: COLUMN transaction_status_type.description; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_status_type.description IS 'Description of the transaction status type.';


--
-- Name: COLUMN transaction_status_type.status; Type: COMMENT; Schema: transaction; Owner: postgres
--

COMMENT ON COLUMN transaction_status_type.status IS 'Status of the transaction status type';


SET search_path = address, pg_catalog;

--
-- Name: address_pkey; Type: CONSTRAINT; Schema: address; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id);


SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit_area_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_area
    ADD CONSTRAINT ba_unit_area_pkey PRIMARY KEY (id);


--
-- Name: ba_unit_as_party_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_as_party
    ADD CONSTRAINT ba_unit_as_party_pkey PRIMARY KEY (ba_unit_id, party_id);


--
-- Name: ba_unit_contains_spatial_unit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_contains_spatial_unit
    ADD CONSTRAINT ba_unit_contains_spatial_unit_pkey PRIMARY KEY (ba_unit_id, spatial_unit_id);


--
-- Name: ba_unit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_pkey PRIMARY KEY (id);


--
-- Name: ba_unit_rel_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_rel_type
    ADD CONSTRAINT ba_unit_rel_type_display_value_unique UNIQUE (display_value);


--
-- Name: ba_unit_rel_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_rel_type
    ADD CONSTRAINT ba_unit_rel_type_pkey PRIMARY KEY (code);


--
-- Name: ba_unit_target_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_target
    ADD CONSTRAINT ba_unit_target_pkey PRIMARY KEY (ba_unit_id, transaction_id);


--
-- Name: ba_unit_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_type
    ADD CONSTRAINT ba_unit_type_display_value_unique UNIQUE (display_value);


--
-- Name: ba_unit_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY ba_unit_type
    ADD CONSTRAINT ba_unit_type_pkey PRIMARY KEY (code);


--
-- Name: certificate_print_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY certificate_print
    ADD CONSTRAINT certificate_print_pkey PRIMARY KEY (id);


--
-- Name: mortgage_isbased_in_rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mortgage_isbased_in_rrr
    ADD CONSTRAINT mortgage_isbased_in_rrr_pkey PRIMARY KEY (mortgage_id, rrr_id);


--
-- Name: mortgage_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mortgage_type
    ADD CONSTRAINT mortgage_type_display_value_unique UNIQUE (display_value);


--
-- Name: mortgage_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY mortgage_type
    ADD CONSTRAINT mortgage_type_pkey PRIMARY KEY (code);


--
-- Name: notation_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_pkey PRIMARY KEY (id);


--
-- Name: party_for_rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_for_rrr
    ADD CONSTRAINT party_for_rrr_pkey PRIMARY KEY (rrr_id, party_id);


--
-- Name: required_relationship_baunit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY required_relationship_baunit
    ADD CONSTRAINT required_relationship_baunit_pkey PRIMARY KEY (from_ba_unit_id, to_ba_unit_id);


--
-- Name: rrr_group_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_group_type
    ADD CONSTRAINT rrr_group_type_display_value_unique UNIQUE (display_value);


--
-- Name: rrr_group_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_group_type
    ADD CONSTRAINT rrr_group_type_pkey PRIMARY KEY (code);


--
-- Name: rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_pkey PRIMARY KEY (id);


--
-- Name: rrr_share_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_share
    ADD CONSTRAINT rrr_share_pkey PRIMARY KEY (rrr_id, id);


--
-- Name: rrr_type_display_value_unique; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_type
    ADD CONSTRAINT rrr_type_display_value_unique UNIQUE (display_value);


--
-- Name: rrr_type_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY rrr_type
    ADD CONSTRAINT rrr_type_pkey PRIMARY KEY (code);


--
-- Name: source_describes_ba_unit_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source_describes_ba_unit
    ADD CONSTRAINT source_describes_ba_unit_pkey PRIMARY KEY (source_id, ba_unit_id);


--
-- Name: source_describes_rrr_pkey; Type: CONSTRAINT; Schema: administrative; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source_describes_rrr
    ADD CONSTRAINT source_describes_rrr_pkey PRIMARY KEY (rrr_id, source_id);


SET search_path = application, pg_catalog;

--
-- Name: application_action_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_action_type
    ADD CONSTRAINT application_action_type_display_value_unique UNIQUE (display_value);


--
-- Name: application_action_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_action_type
    ADD CONSTRAINT application_action_type_pkey PRIMARY KEY (code);


--
-- Name: application_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_pkey PRIMARY KEY (id);


--
-- Name: application_property_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_pkey PRIMARY KEY (id);


--
-- Name: application_property_property_once; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_property_once UNIQUE (application_id, name_firstpart, name_lastpart);


--
-- Name: application_status_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_status_type
    ADD CONSTRAINT application_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: application_status_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_status_type
    ADD CONSTRAINT application_status_type_pkey PRIMARY KEY (code);


--
-- Name: application_uses_source_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY application_uses_source
    ADD CONSTRAINT application_uses_source_pkey PRIMARY KEY (application_id, source_id);


--
-- Name: request_category_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_category_type
    ADD CONSTRAINT request_category_type_display_value_unique UNIQUE (display_value);


--
-- Name: request_category_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_category_type
    ADD CONSTRAINT request_category_type_pkey PRIMARY KEY (code);


--
-- Name: request_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_display_value_unique UNIQUE (display_value);


--
-- Name: request_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_pkey PRIMARY KEY (code);


--
-- Name: request_type_requires_source_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY request_type_requires_source_type
    ADD CONSTRAINT request_type_requires_source_type_pkey PRIMARY KEY (source_type_code, request_type_code);


--
-- Name: service_action_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service_action_type
    ADD CONSTRAINT service_action_type_display_value_unique UNIQUE (display_value);


--
-- Name: service_action_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service_action_type
    ADD CONSTRAINT service_action_type_pkey PRIMARY KEY (code);


--
-- Name: service_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_pkey PRIMARY KEY (id);


--
-- Name: service_status_type_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service_status_type
    ADD CONSTRAINT service_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: service_status_type_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY service_status_type
    ADD CONSTRAINT service_status_type_pkey PRIMARY KEY (code);


--
-- Name: type_action_display_value_unique; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY type_action
    ADD CONSTRAINT type_action_display_value_unique UNIQUE (display_value);


--
-- Name: type_action_pkey; Type: CONSTRAINT; Schema: application; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY type_action
    ADD CONSTRAINT type_action_pkey PRIMARY KEY (code);


SET search_path = cadastre, pg_catalog;

--
-- Name: area_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY area_type
    ADD CONSTRAINT area_type_display_value_unique UNIQUE (display_value);


--
-- Name: area_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY area_type
    ADD CONSTRAINT area_type_pkey PRIMARY KEY (code);


--
-- Name: building_unit_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY building_unit_type
    ADD CONSTRAINT building_unit_type_display_value_unique UNIQUE (display_value);


--
-- Name: building_unit_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY building_unit_type
    ADD CONSTRAINT building_unit_type_pkey PRIMARY KEY (code);


--
-- Name: cadastre_object_name; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_name UNIQUE (name_firstpart, name_lastpart);


--
-- Name: cadastre_object_node_target_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object_node_target
    ADD CONSTRAINT cadastre_object_node_target_pkey PRIMARY KEY (transaction_id, node_id);


--
-- Name: cadastre_object_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_pkey PRIMARY KEY (id);


--
-- Name: cadastre_object_target_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object_target
    ADD CONSTRAINT cadastre_object_target_pkey PRIMARY KEY (transaction_id, cadastre_object_id);


--
-- Name: cadastre_object_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object_type
    ADD CONSTRAINT cadastre_object_type_display_value_unique UNIQUE (display_value);


--
-- Name: cadastre_object_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY cadastre_object_type
    ADD CONSTRAINT cadastre_object_type_pkey PRIMARY KEY (code);


--
-- Name: dimension_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dimension_type
    ADD CONSTRAINT dimension_type_display_value_unique UNIQUE (display_value);


--
-- Name: dimension_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dimension_type
    ADD CONSTRAINT dimension_type_pkey PRIMARY KEY (code);


--
-- Name: legal_space_utility_network_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY legal_space_utility_network
    ADD CONSTRAINT legal_space_utility_network_pkey PRIMARY KEY (id);


--
-- Name: level_content_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY level_content_type
    ADD CONSTRAINT level_content_type_display_value_unique UNIQUE (display_value);


--
-- Name: level_content_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY level_content_type
    ADD CONSTRAINT level_content_type_pkey PRIMARY KEY (code);


--
-- Name: level_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY level
    ADD CONSTRAINT level_pkey PRIMARY KEY (id);


--
-- Name: register_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY register_type
    ADD CONSTRAINT register_type_display_value_unique UNIQUE (display_value);


--
-- Name: register_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY register_type
    ADD CONSTRAINT register_type_pkey PRIMARY KEY (code);


--
-- Name: spatial_unit_address_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit_address
    ADD CONSTRAINT spatial_unit_address_pkey PRIMARY KEY (spatial_unit_id, address_id);


--
-- Name: spatial_unit_change_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit_change
    ADD CONSTRAINT spatial_unit_change_pkey PRIMARY KEY (id);


--
-- Name: spatial_unit_group_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit_group
    ADD CONSTRAINT spatial_unit_group_pkey PRIMARY KEY (id);


--
-- Name: spatial_unit_in_group_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit_in_group
    ADD CONSTRAINT spatial_unit_in_group_pkey PRIMARY KEY (spatial_unit_group_id, spatial_unit_id);


--
-- Name: spatial_unit_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_pkey PRIMARY KEY (id);


--
-- Name: spatial_value_area_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_value_area
    ADD CONSTRAINT spatial_value_area_pkey PRIMARY KEY (spatial_unit_id, type_code);


--
-- Name: structure_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY structure_type
    ADD CONSTRAINT structure_type_display_value_unique UNIQUE (display_value);


--
-- Name: structure_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY structure_type
    ADD CONSTRAINT structure_type_pkey PRIMARY KEY (code);


--
-- Name: surface_relation_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY surface_relation_type
    ADD CONSTRAINT surface_relation_type_display_value_unique UNIQUE (display_value);


--
-- Name: surface_relation_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY surface_relation_type
    ADD CONSTRAINT surface_relation_type_pkey PRIMARY KEY (code);


--
-- Name: survey_point_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY survey_point
    ADD CONSTRAINT survey_point_pkey PRIMARY KEY (transaction_id, id);


--
-- Name: utility_network_status_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY utility_network_status_type
    ADD CONSTRAINT utility_network_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: utility_network_status_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY utility_network_status_type
    ADD CONSTRAINT utility_network_status_type_pkey PRIMARY KEY (code);


--
-- Name: utility_network_type_display_value_unique; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY utility_network_type
    ADD CONSTRAINT utility_network_type_display_value_unique UNIQUE (display_value);


--
-- Name: utility_network_type_pkey; Type: CONSTRAINT; Schema: cadastre; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY utility_network_type
    ADD CONSTRAINT utility_network_type_pkey PRIMARY KEY (code);


SET search_path = document, pg_catalog;

--
-- Name: document_backup_pkey; Type: CONSTRAINT; Schema: document; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document_backup
    ADD CONSTRAINT document_backup_pkey PRIMARY KEY (id);


--
-- Name: document_nr_unique; Type: CONSTRAINT; Schema: document; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_nr_unique UNIQUE (nr);


--
-- Name: document_pkey; Type: CONSTRAINT; Schema: document; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY document
    ADD CONSTRAINT document_pkey PRIMARY KEY (id);


SET search_path = party, pg_catalog;

--
-- Name: communication_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY communication_type
    ADD CONSTRAINT communication_type_display_value_unique UNIQUE (display_value);


--
-- Name: communication_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY communication_type
    ADD CONSTRAINT communication_type_pkey PRIMARY KEY (code);


--
-- Name: gender_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY gender_type
    ADD CONSTRAINT gender_type_display_value_unique UNIQUE (display_value);


--
-- Name: gender_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY gender_type
    ADD CONSTRAINT gender_type_pkey PRIMARY KEY (code);


--
-- Name: group_party_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY group_party
    ADD CONSTRAINT group_party_pkey PRIMARY KEY (id);


--
-- Name: group_party_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY group_party_type
    ADD CONSTRAINT group_party_type_display_value_unique UNIQUE (display_value);


--
-- Name: group_party_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY group_party_type
    ADD CONSTRAINT group_party_type_pkey PRIMARY KEY (code);


--
-- Name: id_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY id_type
    ADD CONSTRAINT id_type_display_value_unique UNIQUE (display_value);


--
-- Name: id_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY id_type
    ADD CONSTRAINT id_type_pkey PRIMARY KEY (code);


--
-- Name: party_member_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_member
    ADD CONSTRAINT party_member_pkey PRIMARY KEY (party_id, group_id);


--
-- Name: party_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_pkey PRIMARY KEY (id);


--
-- Name: party_role_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_role
    ADD CONSTRAINT party_role_pkey PRIMARY KEY (party_id, type_code);


--
-- Name: party_role_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_role_type
    ADD CONSTRAINT party_role_type_display_value_unique UNIQUE (display_value);


--
-- Name: party_role_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_role_type
    ADD CONSTRAINT party_role_type_pkey PRIMARY KEY (code);


--
-- Name: party_type_display_value_unique; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_type
    ADD CONSTRAINT party_type_display_value_unique UNIQUE (display_value);


--
-- Name: party_type_pkey; Type: CONSTRAINT; Schema: party; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY party_type
    ADD CONSTRAINT party_type_pkey PRIMARY KEY (code);


SET search_path = source, pg_catalog;

--
-- Name: administrative_source_type_display_value_unique; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY administrative_source_type
    ADD CONSTRAINT administrative_source_type_display_value_unique UNIQUE (display_value);


--
-- Name: administrative_source_type_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY administrative_source_type
    ADD CONSTRAINT administrative_source_type_pkey PRIMARY KEY (code);


--
-- Name: archive_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY archive
    ADD CONSTRAINT archive_pkey PRIMARY KEY (id);


--
-- Name: availability_status_type_display_value_unique; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY availability_status_type
    ADD CONSTRAINT availability_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: availability_status_type_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY availability_status_type
    ADD CONSTRAINT availability_status_type_pkey PRIMARY KEY (code);


--
-- Name: power_of_attorney_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY power_of_attorney
    ADD CONSTRAINT power_of_attorney_pkey PRIMARY KEY (id);


--
-- Name: presentation_form_type_display_value_unique; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY presentation_form_type
    ADD CONSTRAINT presentation_form_type_display_value_unique UNIQUE (display_value);


--
-- Name: presentation_form_type_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY presentation_form_type
    ADD CONSTRAINT presentation_form_type_pkey PRIMARY KEY (code);


--
-- Name: source_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_pkey PRIMARY KEY (id);


--
-- Name: spatial_source_measurement_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_source_measurement
    ADD CONSTRAINT spatial_source_measurement_pkey PRIMARY KEY (spatial_source_id, id);


--
-- Name: spatial_source_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_source
    ADD CONSTRAINT spatial_source_pkey PRIMARY KEY (id);


--
-- Name: spatial_source_type_display_value_unique; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_source_type
    ADD CONSTRAINT spatial_source_type_display_value_unique UNIQUE (display_value);


--
-- Name: spatial_source_type_pkey; Type: CONSTRAINT; Schema: source; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY spatial_source_type
    ADD CONSTRAINT spatial_source_type_pkey PRIMARY KEY (code);


SET search_path = system, pg_catalog;

--
-- Name: appgroup_name_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appgroup
    ADD CONSTRAINT appgroup_name_unique UNIQUE (name);


--
-- Name: appgroup_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appgroup
    ADD CONSTRAINT appgroup_pkey PRIMARY KEY (id);


--
-- Name: approle_appgroup_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY approle_appgroup
    ADD CONSTRAINT approle_appgroup_pkey PRIMARY KEY (approle_code, appgroup_id);


--
-- Name: approle_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY approle
    ADD CONSTRAINT approle_display_value_unique UNIQUE (display_value);


--
-- Name: approle_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY approle
    ADD CONSTRAINT approle_pkey PRIMARY KEY (code);


--
-- Name: appuser_appgroup_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser_appgroup
    ADD CONSTRAINT appuser_appgroup_pkey PRIMARY KEY (appuser_id, appgroup_id);


--
-- Name: appuser_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser
    ADD CONSTRAINT appuser_pkey PRIMARY KEY (id);


--
-- Name: appuser_setting_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser_setting
    ADD CONSTRAINT appuser_setting_pkey PRIMARY KEY (user_id, name);


--
-- Name: appuser_username_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY appuser
    ADD CONSTRAINT appuser_username_unique UNIQUE (username);


--
-- Name: br_definition_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_definition
    ADD CONSTRAINT br_definition_pkey PRIMARY KEY (br_id, active_from);


--
-- Name: br_display_name_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br
    ADD CONSTRAINT br_display_name_unique UNIQUE (display_name);


--
-- Name: br_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br
    ADD CONSTRAINT br_pkey PRIMARY KEY (id);


--
-- Name: br_severity_type_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_severity_type
    ADD CONSTRAINT br_severity_type_display_value_unique UNIQUE (display_value);


--
-- Name: br_severity_type_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_severity_type
    ADD CONSTRAINT br_severity_type_pkey PRIMARY KEY (code);


--
-- Name: br_technical_type_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_technical_type
    ADD CONSTRAINT br_technical_type_display_value_unique UNIQUE (display_value);


--
-- Name: br_technical_type_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_technical_type
    ADD CONSTRAINT br_technical_type_pkey PRIMARY KEY (code);


--
-- Name: br_validation_app_moment_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_app_moment_unique UNIQUE (br_id, target_code, target_application_moment);


--
-- Name: br_validation_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_pkey PRIMARY KEY (id);


--
-- Name: br_validation_reg_moment_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_reg_moment_unique UNIQUE (br_id, target_code, target_reg_moment);


--
-- Name: br_validation_service_moment_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_service_moment_unique UNIQUE (br_id, target_code, target_service_moment, target_request_type_code);


--
-- Name: br_validation_target_type_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation_target_type
    ADD CONSTRAINT br_validation_target_type_display_value_unique UNIQUE (display_value);


--
-- Name: br_validation_target_type_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY br_validation_target_type
    ADD CONSTRAINT br_validation_target_type_pkey PRIMARY KEY (code);


--
-- Name: config_map_layer_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_pkey PRIMARY KEY (name);


--
-- Name: config_map_layer_title_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_title_unique UNIQUE (title);


--
-- Name: config_map_layer_type_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer_type
    ADD CONSTRAINT config_map_layer_type_display_value_unique UNIQUE (display_value);


--
-- Name: config_map_layer_type_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY config_map_layer_type
    ADD CONSTRAINT config_map_layer_type_pkey PRIMARY KEY (code);


--
-- Name: language_display_value_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_display_value_unique UNIQUE (display_value);


--
-- Name: language_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY language
    ADD CONSTRAINT language_pkey PRIMARY KEY (code);


--
-- Name: map_search_option_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY map_search_option
    ADD CONSTRAINT map_search_option_pkey PRIMARY KEY (code);


--
-- Name: map_search_option_title_unique; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY map_search_option
    ADD CONSTRAINT map_search_option_title_unique UNIQUE (title);


--
-- Name: query_field_display_value; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY query_field
    ADD CONSTRAINT query_field_display_value UNIQUE (query_name, display_value);


--
-- Name: query_field_name; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY query_field
    ADD CONSTRAINT query_field_name UNIQUE (query_name, name);


--
-- Name: query_field_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY query_field
    ADD CONSTRAINT query_field_pkey PRIMARY KEY (query_name, index_in_query);


--
-- Name: query_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY query
    ADD CONSTRAINT query_pkey PRIMARY KEY (name);


--
-- Name: setting_pkey; Type: CONSTRAINT; Schema: system; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY setting
    ADD CONSTRAINT setting_pkey PRIMARY KEY (name);


SET search_path = transaction, pg_catalog;

--
-- Name: reg_status_type_display_value_unique; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reg_status_type
    ADD CONSTRAINT reg_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: reg_status_type_pkey; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY reg_status_type
    ADD CONSTRAINT reg_status_type_pkey PRIMARY KEY (code);


--
-- Name: transaction_from_service_id_unique; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_from_service_id_unique UNIQUE (from_service_id);


--
-- Name: transaction_pkey; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (id);


--
-- Name: transaction_source_pkey; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction_source
    ADD CONSTRAINT transaction_source_pkey PRIMARY KEY (transaction_id, source_id);


--
-- Name: transaction_status_type_display_value_unique; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction_status_type
    ADD CONSTRAINT transaction_status_type_display_value_unique UNIQUE (display_value);


--
-- Name: transaction_status_type_pkey; Type: CONSTRAINT; Schema: transaction; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY transaction_status_type
    ADD CONSTRAINT transaction_status_type_pkey PRIMARY KEY (code);


SET search_path = address, pg_catalog;

--
-- Name: address_historic_index_on_rowidentifier; Type: INDEX; Schema: address; Owner: postgres; Tablespace: 
--

CREATE INDEX address_historic_index_on_rowidentifier ON address_historic USING btree (rowidentifier);


--
-- Name: address_index_on_rowidentifier; Type: INDEX; Schema: address; Owner: postgres; Tablespace: 
--

CREATE INDEX address_index_on_rowidentifier ON address USING btree (rowidentifier);


SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit_area_ba_unit_id_fk66_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_area_ba_unit_id_fk66_ind ON ba_unit_area USING btree (ba_unit_id);


--
-- Name: ba_unit_area_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_area_historic_index_on_rowidentifier ON ba_unit_area_historic USING btree (rowidentifier);


--
-- Name: ba_unit_area_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_area_index_on_rowidentifier ON ba_unit_area USING btree (rowidentifier);


--
-- Name: ba_unit_area_type_code_fk67_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_area_type_code_fk67_ind ON ba_unit_area USING btree (type_code);


--
-- Name: ba_unit_as_party_ba_unit_id_fk60_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_as_party_ba_unit_id_fk60_ind ON ba_unit_as_party USING btree (ba_unit_id);


--
-- Name: ba_unit_as_party_party_id_fk61_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_as_party_party_id_fk61_ind ON ba_unit_as_party USING btree (party_id);


--
-- Name: ba_unit_contains_spatial_unit_ba_unit_id_fk57_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_ba_unit_id_fk57_ind ON ba_unit_contains_spatial_unit USING btree (ba_unit_id);


--
-- Name: ba_unit_contains_spatial_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_historic_index_on_rowidentifier ON ba_unit_contains_spatial_unit_historic USING btree (rowidentifier);


--
-- Name: ba_unit_contains_spatial_unit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_index_on_rowidentifier ON ba_unit_contains_spatial_unit USING btree (rowidentifier);


--
-- Name: ba_unit_contains_spatial_unit_spatial_unit_id_fk58_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_spatial_unit_id_fk58_ind ON ba_unit_contains_spatial_unit USING btree (spatial_unit_id);


--
-- Name: ba_unit_contains_spatial_unit_spatial_unit_id_fk59_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_contains_spatial_unit_spatial_unit_id_fk59_ind ON ba_unit_contains_spatial_unit USING btree (spatial_unit_id);


--
-- Name: ba_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_historic_index_on_rowidentifier ON ba_unit_historic USING btree (rowidentifier);


--
-- Name: ba_unit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_index_on_rowidentifier ON ba_unit USING btree (rowidentifier);


--
-- Name: ba_unit_name_unique_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE UNIQUE INDEX ba_unit_name_unique_ind ON ba_unit USING btree (name_firstpart, name_lastpart);


--
-- Name: ba_unit_status_code_fk76_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_status_code_fk76_ind ON ba_unit USING btree (status_code);


--
-- Name: ba_unit_target_ba_unit_id_fk72_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_target_ba_unit_id_fk72_ind ON ba_unit_target USING btree (ba_unit_id);


--
-- Name: ba_unit_target_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_target_historic_index_on_rowidentifier ON ba_unit_target_historic USING btree (rowidentifier);


--
-- Name: ba_unit_target_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_target_index_on_rowidentifier ON ba_unit_target USING btree (rowidentifier);


--
-- Name: ba_unit_target_transaction_id_fk73_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_target_transaction_id_fk73_ind ON ba_unit_target USING btree (transaction_id);


--
-- Name: ba_unit_transaction_id_fk77_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_transaction_id_fk77_ind ON ba_unit USING btree (transaction_id);


--
-- Name: ba_unit_type_code_fk75_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX ba_unit_type_code_fk75_ind ON ba_unit USING btree (type_code);


--
-- Name: mortgage_isbased_in_rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX mortgage_isbased_in_rrr_historic_index_on_rowidentifier ON mortgage_isbased_in_rrr_historic USING btree (rowidentifier);


--
-- Name: mortgage_isbased_in_rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX mortgage_isbased_in_rrr_index_on_rowidentifier ON mortgage_isbased_in_rrr USING btree (rowidentifier);


--
-- Name: mortgage_isbased_in_rrr_mortgage_id_fk38_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX mortgage_isbased_in_rrr_mortgage_id_fk38_ind ON mortgage_isbased_in_rrr USING btree (mortgage_id);


--
-- Name: mortgage_isbased_in_rrr_rrr_id_fk37_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX mortgage_isbased_in_rrr_rrr_id_fk37_ind ON mortgage_isbased_in_rrr USING btree (rrr_id);


--
-- Name: notation_ba_unit_id_fk64_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_ba_unit_id_fk64_ind ON notation USING btree (ba_unit_id);


--
-- Name: notation_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_historic_index_on_rowidentifier ON notation_historic USING btree (rowidentifier);


--
-- Name: notation_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_index_on_rowidentifier ON notation USING btree (rowidentifier);


--
-- Name: notation_rrr_id_fk65_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_rrr_id_fk65_ind ON notation USING btree (rrr_id);


--
-- Name: notation_status_code_fk63_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_status_code_fk63_ind ON notation USING btree (status_code);


--
-- Name: notation_transaction_id_fk62_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX notation_transaction_id_fk62_ind ON notation USING btree (transaction_id);


--
-- Name: party_for_rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_historic_index_on_rowidentifier ON party_for_rrr_historic USING btree (rowidentifier);


--
-- Name: party_for_rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_index_on_rowidentifier ON party_for_rrr USING btree (rowidentifier);


--
-- Name: party_for_rrr_party_id_fk71_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_party_id_fk71_ind ON party_for_rrr USING btree (party_id);


--
-- Name: party_for_rrr_rrr_id_fk69_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_rrr_id_fk69_ind ON party_for_rrr USING btree (rrr_id, share_id);


--
-- Name: party_for_rrr_rrr_id_fk70_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX party_for_rrr_rrr_id_fk70_ind ON party_for_rrr USING btree (rrr_id);


--
-- Name: required_relationship_baunit_from_ba_unit_id_fk43_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_from_ba_unit_id_fk43_ind ON required_relationship_baunit USING btree (from_ba_unit_id);


--
-- Name: required_relationship_baunit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_historic_index_on_rowidentifier ON required_relationship_baunit_historic USING btree (rowidentifier);


--
-- Name: required_relationship_baunit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_index_on_rowidentifier ON required_relationship_baunit USING btree (rowidentifier);


--
-- Name: required_relationship_baunit_relation_code_fk45_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_relation_code_fk45_ind ON required_relationship_baunit USING btree (relation_code);


--
-- Name: required_relationship_baunit_to_ba_unit_id_fk44_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX required_relationship_baunit_to_ba_unit_id_fk44_ind ON required_relationship_baunit USING btree (to_ba_unit_id);


--
-- Name: rrr_ba_unit_id_fk79_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_ba_unit_id_fk79_ind ON rrr USING btree (ba_unit_id);


--
-- Name: rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_historic_index_on_rowidentifier ON rrr_historic USING btree (rowidentifier);


--
-- Name: rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_index_on_rowidentifier ON rrr USING btree (rowidentifier);


--
-- Name: rrr_mortgage_type_code_fk82_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_mortgage_type_code_fk82_ind ON rrr USING btree (mortgage_type_code);


--
-- Name: rrr_share_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_share_historic_index_on_rowidentifier ON rrr_share_historic USING btree (rowidentifier);


--
-- Name: rrr_share_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_share_index_on_rowidentifier ON rrr_share USING btree (rowidentifier);


--
-- Name: rrr_share_rrr_id_fk68_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_share_rrr_id_fk68_ind ON rrr_share USING btree (rrr_id);


--
-- Name: rrr_status_code_fk80_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_status_code_fk80_ind ON rrr USING btree (status_code);


--
-- Name: rrr_transaction_id_fk81_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_transaction_id_fk81_ind ON rrr USING btree (transaction_id);


--
-- Name: rrr_type_code_fk78_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_type_code_fk78_ind ON rrr USING btree (type_code);


--
-- Name: rrr_type_rrr_group_type_code_fk22_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX rrr_type_rrr_group_type_code_fk22_ind ON rrr_type USING btree (rrr_group_type_code);


--
-- Name: source_describes_ba_unit_ba_unit_id_fk41_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_ba_unit_ba_unit_id_fk41_ind ON source_describes_ba_unit USING btree (ba_unit_id);


--
-- Name: source_describes_ba_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_ba_unit_historic_index_on_rowidentifier ON source_describes_ba_unit_historic USING btree (rowidentifier);


--
-- Name: source_describes_ba_unit_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_ba_unit_index_on_rowidentifier ON source_describes_ba_unit USING btree (rowidentifier);


--
-- Name: source_describes_ba_unit_source_id_fk42_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_ba_unit_source_id_fk42_ind ON source_describes_ba_unit USING btree (source_id);


--
-- Name: source_describes_rrr_historic_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_rrr_historic_index_on_rowidentifier ON source_describes_rrr_historic USING btree (rowidentifier);


--
-- Name: source_describes_rrr_index_on_rowidentifier; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_rrr_index_on_rowidentifier ON source_describes_rrr USING btree (rowidentifier);


--
-- Name: source_describes_rrr_rrr_id_fk39_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_rrr_rrr_id_fk39_ind ON source_describes_rrr USING btree (rrr_id);


--
-- Name: source_describes_rrr_source_id_fk40_ind; Type: INDEX; Schema: administrative; Owner: postgres; Tablespace: 
--

CREATE INDEX source_describes_rrr_source_id_fk40_ind ON source_describes_rrr USING btree (source_id);


SET search_path = application, pg_catalog;

--
-- Name: application_action_code_fk16_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_action_code_fk16_ind ON application USING btree (action_code);


--
-- Name: application_action_type_status_to_set_fk17_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_action_type_status_to_set_fk17_ind ON application_action_type USING btree (status_to_set);


--
-- Name: application_agent_id_fk8_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_agent_id_fk8_ind ON application USING btree (agent_id);


--
-- Name: application_assignee_id_fk15_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_assignee_id_fk15_ind ON application USING btree (assignee_id);


--
-- Name: application_contact_person_id_fk14_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_contact_person_id_fk14_ind ON application USING btree (contact_person_id);


--
-- Name: application_historic_id_idx; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_historic_id_idx ON application_historic USING btree (id);


--
-- Name: application_historic_id_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_historic_id_ind ON application_historic USING btree (id);


--
-- Name: application_historic_index_on_location; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_historic_index_on_location ON application_historic USING gist (location);


--
-- Name: application_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_historic_index_on_rowidentifier ON application_historic USING btree (rowidentifier);


--
-- Name: application_index_on_location; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_index_on_location ON application USING gist (location);


--
-- Name: application_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_index_on_rowidentifier ON application USING btree (rowidentifier);


--
-- Name: application_property_application_id_fk99_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_application_id_fk99_ind ON application_property USING btree (application_id);


--
-- Name: application_property_ba_unit_id_fk100_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_ba_unit_id_fk100_ind ON application_property USING btree (ba_unit_id);


--
-- Name: application_property_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_historic_index_on_rowidentifier ON application_property_historic USING btree (rowidentifier);


--
-- Name: application_property_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_property_index_on_rowidentifier ON application_property USING btree (rowidentifier);


--
-- Name: application_status_code_fk18_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_status_code_fk18_ind ON application USING btree (status_code);


--
-- Name: application_uses_source_application_id_fk101_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_uses_source_application_id_fk101_ind ON application_uses_source USING btree (application_id);


--
-- Name: application_uses_source_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_uses_source_historic_index_on_rowidentifier ON application_uses_source_historic USING btree (rowidentifier);


--
-- Name: application_uses_source_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_uses_source_index_on_rowidentifier ON application_uses_source USING btree (rowidentifier);


--
-- Name: application_uses_source_source_id_fk102_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX application_uses_source_source_id_fk102_ind ON application_uses_source USING btree (source_id);


--
-- Name: request_type_request_category_code_fk20_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_request_category_code_fk20_ind ON request_type USING btree (request_category_code);


--
-- Name: request_type_requires_source_type_request_type_code_fk104_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_requires_source_type_request_type_code_fk104_ind ON request_type_requires_source_type USING btree (request_type_code);


--
-- Name: request_type_requires_source_type_source_type_code_fk103_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_requires_source_type_source_type_code_fk103_ind ON request_type_requires_source_type USING btree (source_type_code);


--
-- Name: request_type_rrr_type_code_fk21_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_rrr_type_code_fk21_ind ON request_type USING btree (rrr_type_code);


--
-- Name: request_type_type_action_code_fk23_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX request_type_type_action_code_fk23_ind ON request_type USING btree (type_action_code);


--
-- Name: service_action_code_fk25_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_action_code_fk25_ind ON service USING btree (action_code);


--
-- Name: service_action_type_status_to_set_fk26_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_action_type_status_to_set_fk26_ind ON service_action_type USING btree (status_to_set);


--
-- Name: service_application_historic_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_application_historic_ind ON service_historic USING btree (application_id);


--
-- Name: service_application_id_fk7_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_application_id_fk7_ind ON service USING btree (application_id);


--
-- Name: service_historic_id_idx; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_historic_id_idx ON service_historic USING btree (id);


--
-- Name: service_historic_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_historic_index_on_rowidentifier ON service_historic USING btree (rowidentifier);


--
-- Name: service_index_on_rowidentifier; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_index_on_rowidentifier ON service USING btree (rowidentifier);


--
-- Name: service_request_type_code_fk19_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_request_type_code_fk19_ind ON service USING btree (request_type_code);


--
-- Name: service_status_code_fk24_ind; Type: INDEX; Schema: application; Owner: postgres; Tablespace: 
--

CREATE INDEX service_status_code_fk24_ind ON service USING btree (status_code);


SET search_path = cadastre, pg_catalog;

--
-- Name: cadastre_object_building_unit_type_code_fk55_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_building_unit_type_code_fk55_ind ON cadastre_object USING btree (building_unit_type_code);


--
-- Name: cadastre_object_historic_index_on_geom_polygon; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_historic_index_on_geom_polygon ON cadastre_object_historic USING gist (geom_polygon);


--
-- Name: cadastre_object_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_historic_index_on_rowidentifier ON cadastre_object_historic USING btree (rowidentifier);


--
-- Name: cadastre_object_id_fk52_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_id_fk52_ind ON cadastre_object USING btree (id);


--
-- Name: cadastre_object_index_on_geom_polygon; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_index_on_geom_polygon ON cadastre_object USING gist (geom_polygon);


--
-- Name: cadastre_object_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_index_on_rowidentifier ON cadastre_object USING btree (rowidentifier);


--
-- Name: cadastre_object_node_target_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_historic_index_on_geom ON cadastre_object_node_target_historic USING gist (geom);


--
-- Name: cadastre_object_node_target_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_historic_index_on_rowidentifier ON cadastre_object_node_target_historic USING btree (rowidentifier);


--
-- Name: cadastre_object_node_target_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_index_on_geom ON cadastre_object_node_target USING gist (geom);


--
-- Name: cadastre_object_node_target_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_index_on_rowidentifier ON cadastre_object_node_target USING btree (rowidentifier);


--
-- Name: cadastre_object_node_target_transaction_id_fk98_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_node_target_transaction_id_fk98_ind ON cadastre_object_node_target USING btree (transaction_id);


--
-- Name: cadastre_object_status_code_fk54_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_status_code_fk54_ind ON cadastre_object USING btree (status_code);


--
-- Name: cadastre_object_target_cadastre_object_id_fk93_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_cadastre_object_id_fk93_ind ON cadastre_object_target USING btree (cadastre_object_id);


--
-- Name: cadastre_object_target_historic_index_on_geom_polygon; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_historic_index_on_geom_polygon ON cadastre_object_target_historic USING gist (geom_polygon);


--
-- Name: cadastre_object_target_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_historic_index_on_rowidentifier ON cadastre_object_target_historic USING btree (rowidentifier);


--
-- Name: cadastre_object_target_index_on_geom_polygon; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_index_on_geom_polygon ON cadastre_object_target USING gist (geom_polygon);


--
-- Name: cadastre_object_target_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_index_on_rowidentifier ON cadastre_object_target USING btree (rowidentifier);


--
-- Name: cadastre_object_target_transaction_id_fk94_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_target_transaction_id_fk94_ind ON cadastre_object_target USING btree (transaction_id);


--
-- Name: cadastre_object_transaction_id_fk56_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_transaction_id_fk56_ind ON cadastre_object USING btree (transaction_id);


--
-- Name: cadastre_object_type_code_fk53_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX cadastre_object_type_code_fk53_ind ON cadastre_object USING btree (type_code);


--
-- Name: index_spatial_unit_change_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX index_spatial_unit_change_geom ON spatial_unit_change USING gist (geom);


--
-- Name: index_spatial_unit_change_spatial_unit_id_fk; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX index_spatial_unit_change_spatial_unit_id_fk ON spatial_unit_change USING btree (spatial_unit_id);


--
-- Name: legal_space_utility_network_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_historic_index_on_geom ON legal_space_utility_network_historic USING gist (geom);


--
-- Name: legal_space_utility_network_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_historic_index_on_rowidentifier ON legal_space_utility_network_historic USING btree (rowidentifier);


--
-- Name: legal_space_utility_network_id_fk90_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_id_fk90_ind ON legal_space_utility_network USING btree (id);


--
-- Name: legal_space_utility_network_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_index_on_geom ON legal_space_utility_network USING gist (geom);


--
-- Name: legal_space_utility_network_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_index_on_rowidentifier ON legal_space_utility_network USING btree (rowidentifier);


--
-- Name: legal_space_utility_network_status_code_fk91_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_status_code_fk91_ind ON legal_space_utility_network USING btree (status_code);


--
-- Name: legal_space_utility_network_type_code_fk92_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX legal_space_utility_network_type_code_fk92_ind ON legal_space_utility_network USING btree (type_code);


--
-- Name: level_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_historic_index_on_rowidentifier ON level_historic USING btree (rowidentifier);


--
-- Name: level_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_index_on_rowidentifier ON level USING btree (rowidentifier);


--
-- Name: level_register_type_code_fk49_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_register_type_code_fk49_ind ON level USING btree (register_type_code);


--
-- Name: level_structure_code_fk50_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_structure_code_fk50_ind ON level USING btree (structure_code);


--
-- Name: level_type_code_fk51_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX level_type_code_fk51_ind ON level USING btree (type_code);


--
-- Name: spatial_unit_address_address_id_fk86_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_address_address_id_fk86_ind ON spatial_unit_address USING btree (address_id);


--
-- Name: spatial_unit_address_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_address_historic_index_on_rowidentifier ON spatial_unit_address_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_address_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_address_index_on_rowidentifier ON spatial_unit_address USING btree (rowidentifier);


--
-- Name: spatial_unit_address_spatial_unit_id_fk85_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_address_spatial_unit_id_fk85_ind ON spatial_unit_address USING btree (spatial_unit_id);


--
-- Name: spatial_unit_change_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_change_historic_index_on_geom ON spatial_unit_change_historic USING gist (geom);


--
-- Name: spatial_unit_change_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_change_historic_index_on_rowidentifier ON spatial_unit_change_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_change_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_change_index_on_rowidentifier ON spatial_unit_change USING btree (rowidentifier);


--
-- Name: spatial_unit_change_transaction_id_fk105_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_change_transaction_id_fk105_ind ON spatial_unit_change USING btree (transaction_id);


--
-- Name: spatial_unit_dimension_code_fk46_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_dimension_code_fk46_ind ON spatial_unit USING btree (dimension_code);


--
-- Name: spatial_unit_group_found_in_spatial_unit_group_id_fk87_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_found_in_spatial_unit_group_id_fk87_ind ON spatial_unit_group USING btree (found_in_spatial_unit_group_id);


--
-- Name: spatial_unit_group_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_historic_index_on_geom ON spatial_unit_group_historic USING gist (geom);


--
-- Name: spatial_unit_group_historic_index_on_reference_point; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_historic_index_on_reference_point ON spatial_unit_group_historic USING gist (reference_point);


--
-- Name: spatial_unit_group_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_historic_index_on_rowidentifier ON spatial_unit_group_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_group_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_index_on_geom ON spatial_unit_group USING gist (geom);


--
-- Name: spatial_unit_group_index_on_reference_point; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_index_on_reference_point ON spatial_unit_group USING gist (reference_point);


--
-- Name: spatial_unit_group_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_group_index_on_rowidentifier ON spatial_unit_group USING btree (rowidentifier);


--
-- Name: spatial_unit_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_historic_index_on_geom ON spatial_unit_historic USING gist (geom);


--
-- Name: spatial_unit_historic_index_on_reference_point; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_historic_index_on_reference_point ON spatial_unit_historic USING gist (reference_point);


--
-- Name: spatial_unit_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_historic_index_on_rowidentifier ON spatial_unit_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_in_group_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_in_group_historic_index_on_rowidentifier ON spatial_unit_in_group_historic USING btree (rowidentifier);


--
-- Name: spatial_unit_in_group_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_in_group_index_on_rowidentifier ON spatial_unit_in_group USING btree (rowidentifier);


--
-- Name: spatial_unit_in_group_spatial_unit_group_id_fk88_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_in_group_spatial_unit_group_id_fk88_ind ON spatial_unit_in_group USING btree (spatial_unit_group_id);


--
-- Name: spatial_unit_in_group_spatial_unit_id_fk89_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_in_group_spatial_unit_id_fk89_ind ON spatial_unit_in_group USING btree (spatial_unit_id);


--
-- Name: spatial_unit_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_index_on_geom ON spatial_unit USING gist (geom);


--
-- Name: spatial_unit_index_on_reference_point; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_index_on_reference_point ON spatial_unit USING gist (reference_point);


--
-- Name: spatial_unit_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_index_on_rowidentifier ON spatial_unit USING btree (rowidentifier);


--
-- Name: spatial_unit_level_id_fk48_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_level_id_fk48_ind ON spatial_unit USING btree (level_id);


--
-- Name: spatial_unit_surface_relation_code_fk47_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_unit_surface_relation_code_fk47_ind ON spatial_unit USING btree (surface_relation_code);


--
-- Name: spatial_value_area_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_value_area_historic_index_on_rowidentifier ON spatial_value_area_historic USING btree (rowidentifier);


--
-- Name: spatial_value_area_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_value_area_index_on_rowidentifier ON spatial_value_area USING btree (rowidentifier);


--
-- Name: spatial_value_area_spatial_unit_id_fk83_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_value_area_spatial_unit_id_fk83_ind ON spatial_value_area USING btree (spatial_unit_id);


--
-- Name: spatial_value_area_type_code_fk84_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_value_area_type_code_fk84_ind ON spatial_value_area USING btree (type_code);


--
-- Name: survey_point_historic_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_historic_index_on_geom ON survey_point_historic USING gist (geom);


--
-- Name: survey_point_historic_index_on_original_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_historic_index_on_original_geom ON survey_point_historic USING gist (original_geom);


--
-- Name: survey_point_historic_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_historic_index_on_rowidentifier ON survey_point_historic USING btree (rowidentifier);


--
-- Name: survey_point_index_on_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_index_on_geom ON survey_point USING gist (geom);


--
-- Name: survey_point_index_on_original_geom; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_index_on_original_geom ON survey_point USING gist (original_geom);


--
-- Name: survey_point_index_on_rowidentifier; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_index_on_rowidentifier ON survey_point USING btree (rowidentifier);


--
-- Name: survey_point_transaction_id_fk95_ind; Type: INDEX; Schema: cadastre; Owner: postgres; Tablespace: 
--

CREATE INDEX survey_point_transaction_id_fk95_ind ON survey_point USING btree (transaction_id);


SET search_path = document, pg_catalog;

--
-- Name: document_historic_index_on_rowidentifier; Type: INDEX; Schema: document; Owner: postgres; Tablespace: 
--

CREATE INDEX document_historic_index_on_rowidentifier ON document_historic USING btree (rowidentifier);


--
-- Name: document_index_on_rowidentifier; Type: INDEX; Schema: document; Owner: postgres; Tablespace: 
--

CREATE INDEX document_index_on_rowidentifier ON document USING btree (rowidentifier);


SET search_path = party, pg_catalog;

--
-- Name: group_party_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX group_party_historic_index_on_rowidentifier ON group_party_historic USING btree (rowidentifier);


--
-- Name: group_party_id_fk31_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX group_party_id_fk31_ind ON group_party USING btree (id);


--
-- Name: group_party_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX group_party_index_on_rowidentifier ON group_party USING btree (rowidentifier);


--
-- Name: group_party_type_code_fk32_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX group_party_type_code_fk32_ind ON group_party USING btree (type_code);


--
-- Name: party_address_id_fk10_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_address_id_fk10_ind ON party USING btree (address_id);


--
-- Name: party_gender_code_fk13_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_gender_code_fk13_ind ON party USING btree (gender_code);


--
-- Name: party_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_historic_index_on_rowidentifier ON party_historic USING btree (rowidentifier);


--
-- Name: party_id_type_code_fk12_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_id_type_code_fk12_ind ON party USING btree (id_type_code);


--
-- Name: party_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_index_on_rowidentifier ON party USING btree (rowidentifier);


--
-- Name: party_member_group_id_fk34_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_member_group_id_fk34_ind ON party_member USING btree (group_id);


--
-- Name: party_member_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_member_historic_index_on_rowidentifier ON party_member_historic USING btree (rowidentifier);


--
-- Name: party_member_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_member_index_on_rowidentifier ON party_member USING btree (rowidentifier);


--
-- Name: party_member_party_id_fk33_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_member_party_id_fk33_ind ON party_member USING btree (party_id);


--
-- Name: party_preferred_communication_code_fk11_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_preferred_communication_code_fk11_ind ON party USING btree (preferred_communication_code);


--
-- Name: party_role_historic_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_role_historic_index_on_rowidentifier ON party_role_historic USING btree (rowidentifier);


--
-- Name: party_role_index_on_rowidentifier; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_role_index_on_rowidentifier ON party_role USING btree (rowidentifier);


--
-- Name: party_role_party_id_fk35_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_role_party_id_fk35_ind ON party_role USING btree (party_id);


--
-- Name: party_role_type_code_fk36_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_role_type_code_fk36_ind ON party_role USING btree (type_code);


--
-- Name: party_type_code_fk9_ind; Type: INDEX; Schema: party; Owner: postgres; Tablespace: 
--

CREATE INDEX party_type_code_fk9_ind ON party USING btree (type_code);


SET search_path = source, pg_catalog;

--
-- Name: archive_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX archive_historic_index_on_rowidentifier ON archive_historic USING btree (rowidentifier);


--
-- Name: archive_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX archive_index_on_rowidentifier ON archive USING btree (rowidentifier);


--
-- Name: power_of_attorney_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX power_of_attorney_historic_index_on_rowidentifier ON power_of_attorney_historic USING btree (rowidentifier);


--
-- Name: power_of_attorney_id_fk74_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX power_of_attorney_id_fk74_ind ON power_of_attorney USING btree (id);


--
-- Name: power_of_attorney_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX power_of_attorney_index_on_rowidentifier ON power_of_attorney USING btree (rowidentifier);


--
-- Name: source_archive_id_fk0_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_archive_id_fk0_ind ON source USING btree (archive_id);


--
-- Name: source_availability_status_code_fk2_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_availability_status_code_fk2_ind ON source USING btree (availability_status_code);


--
-- Name: source_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_historic_index_on_rowidentifier ON source_historic USING btree (rowidentifier);


--
-- Name: source_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_index_on_rowidentifier ON source USING btree (rowidentifier);


--
-- Name: source_maintype_fk1_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_maintype_fk1_ind ON source USING btree (maintype);


--
-- Name: source_status_code_fk4_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_status_code_fk4_ind ON source USING btree (status_code);


--
-- Name: source_transaction_id_fk5_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_transaction_id_fk5_ind ON source USING btree (transaction_id);


--
-- Name: source_type_code_fk3_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX source_type_code_fk3_ind ON source USING btree (type_code);


--
-- Name: spatial_source_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_historic_index_on_rowidentifier ON spatial_source_historic USING btree (rowidentifier);


--
-- Name: spatial_source_id_fk28_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_id_fk28_ind ON spatial_source USING btree (id);


--
-- Name: spatial_source_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_index_on_rowidentifier ON spatial_source USING btree (rowidentifier);


--
-- Name: spatial_source_measurement_historic_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_measurement_historic_index_on_rowidentifier ON spatial_source_measurement_historic USING btree (rowidentifier);


--
-- Name: spatial_source_measurement_index_on_rowidentifier; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_measurement_index_on_rowidentifier ON spatial_source_measurement USING btree (rowidentifier);


--
-- Name: spatial_source_measurement_spatial_source_id_fk30_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_measurement_spatial_source_id_fk30_ind ON spatial_source_measurement USING btree (spatial_source_id);


--
-- Name: spatial_source_type_code_fk29_ind; Type: INDEX; Schema: source; Owner: postgres; Tablespace: 
--

CREATE INDEX spatial_source_type_code_fk29_ind ON spatial_source USING btree (type_code);


SET search_path = system, pg_catalog;

--
-- Name: approle_appgroup_appgroup_id_fk120_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX approle_appgroup_appgroup_id_fk120_ind ON approle_appgroup USING btree (appgroup_id);


--
-- Name: approle_appgroup_approle_code_fk119_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX approle_appgroup_approle_code_fk119_ind ON approle_appgroup USING btree (approle_code);


--
-- Name: approle_appgroup_historic_index_on_rowidentifier; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX approle_appgroup_historic_index_on_rowidentifier ON approle_appgroup_historic USING btree (rowidentifier);


--
-- Name: appuser_appgroup_appgroup_id_fk122_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_appgroup_appgroup_id_fk122_ind ON appuser_appgroup USING btree (appgroup_id);


--
-- Name: appuser_appgroup_appuser_id_fk121_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_appgroup_appuser_id_fk121_ind ON appuser_appgroup USING btree (appuser_id);


--
-- Name: appuser_appgroup_historic_index_on_rowidentifier; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_appgroup_historic_index_on_rowidentifier ON appuser_appgroup_historic USING btree (rowidentifier);


--
-- Name: appuser_historic_index_on_rowidentifier; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_historic_index_on_rowidentifier ON appuser_historic USING btree (rowidentifier);


--
-- Name: appuser_index_on_rowidentifier; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_index_on_rowidentifier ON appuser USING btree (rowidentifier);


--
-- Name: appuser_setting_user_id_fk105_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX appuser_setting_user_id_fk105_ind ON appuser_setting USING btree (user_id);


--
-- Name: br_definition_br_id_fk118_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_definition_br_id_fk118_ind ON br_definition USING btree (br_id);


--
-- Name: br_technical_type_code_fk109_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_technical_type_code_fk109_ind ON br USING btree (technical_type_code);


--
-- Name: br_validation_br_id_fk110_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_br_id_fk110_ind ON br_validation USING btree (br_id);


--
-- Name: br_validation_severity_code_fk111_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_severity_code_fk111_ind ON br_validation USING btree (severity_code);


--
-- Name: br_validation_target_application_moment_fk115_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_application_moment_fk115_ind ON br_validation USING btree (target_application_moment);


--
-- Name: br_validation_target_code_fk112_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_code_fk112_ind ON br_validation USING btree (target_code);


--
-- Name: br_validation_target_reg_moment_fk117_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_reg_moment_fk117_ind ON br_validation USING btree (target_reg_moment);


--
-- Name: br_validation_target_request_type_code_fk113_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_request_type_code_fk113_ind ON br_validation USING btree (target_request_type_code);


--
-- Name: br_validation_target_rrr_type_code_fk114_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_rrr_type_code_fk114_ind ON br_validation USING btree (target_rrr_type_code);


--
-- Name: br_validation_target_service_moment_fk116_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX br_validation_target_service_moment_fk116_ind ON br_validation USING btree (target_service_moment);


--
-- Name: config_map_layer_pojo_query_name_fk107_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX config_map_layer_pojo_query_name_fk107_ind ON config_map_layer USING btree (pojo_query_name);


--
-- Name: config_map_layer_pojo_query_name_for_select_fk108_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX config_map_layer_pojo_query_name_for_select_fk108_ind ON config_map_layer USING btree (pojo_query_name_for_select);


--
-- Name: config_map_layer_type_code_fk106_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX config_map_layer_type_code_fk106_ind ON config_map_layer USING btree (type_code);


--
-- Name: map_search_option_query_name_fk124_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX map_search_option_query_name_fk124_ind ON map_search_option USING btree (query_name);


--
-- Name: query_field_query_name_fk123_ind; Type: INDEX; Schema: system; Owner: postgres; Tablespace: 
--

CREATE INDEX query_field_query_name_fk123_ind ON query_field USING btree (query_name);


SET search_path = transaction, pg_catalog;

--
-- Name: transaction_from_service_id_fk6_ind; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_from_service_id_fk6_ind ON transaction USING btree (from_service_id);


--
-- Name: transaction_historic_index_on_rowidentifier; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_historic_index_on_rowidentifier ON transaction_historic USING btree (rowidentifier);


--
-- Name: transaction_index_on_rowidentifier; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_index_on_rowidentifier ON transaction USING btree (rowidentifier);


--
-- Name: transaction_source_historic_index_on_rowidentifier; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_source_historic_index_on_rowidentifier ON transaction_source_historic USING btree (rowidentifier);


--
-- Name: transaction_source_index_on_rowidentifier; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_source_index_on_rowidentifier ON transaction_source USING btree (rowidentifier);


--
-- Name: transaction_source_source_id_fk97_ind; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_source_source_id_fk97_ind ON transaction_source USING btree (source_id);


--
-- Name: transaction_source_transaction_id_fk96_ind; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_source_transaction_id_fk96_ind ON transaction_source USING btree (transaction_id);


--
-- Name: transaction_status_code_fk27_ind; Type: INDEX; Schema: transaction; Owner: postgres; Tablespace: 
--

CREATE INDEX transaction_status_code_fk27_ind ON transaction USING btree (status_code);


SET search_path = address, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: address; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON address FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: address; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON address FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = administrative, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON ba_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON mortgage_isbased_in_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON source_describes_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON source_describes_ba_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON required_relationship_baunit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON ba_unit_contains_spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON notation FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON ba_unit_area FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON rrr_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_for_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON ba_unit_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON ba_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON mortgage_isbased_in_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON source_describes_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON source_describes_ba_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON required_relationship_baunit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON ba_unit_contains_spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON notation FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON ba_unit_area FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON rrr_share FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_for_rrr FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON ba_unit_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: trg_change_from_pending; Type: TRIGGER; Schema: administrative; Owner: postgres
--

CREATE TRIGGER trg_change_from_pending BEFORE UPDATE ON rrr FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_rrr_trg_change_from_pending();


SET search_path = application, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON service FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON application FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON application_property FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON application_uses_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON service FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON application FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON application_property FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: application; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON application_uses_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = cadastre, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON level FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_value_area FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit_address FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit_group FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit_in_group FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON legal_space_utility_network FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON cadastre_object_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON survey_point FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON cadastre_object_node_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_unit_change FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON level FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_value_area FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit_address FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit_group FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit_in_group FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON legal_space_utility_network FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON cadastre_object_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON survey_point FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON cadastre_object_node_target FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_unit_change FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: trg_geommodify; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER trg_geommodify AFTER INSERT OR UPDATE OF geom_polygon ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_cadastre_object_trg_geommodify();


--
-- Name: trg_new; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER trg_new BEFORE INSERT ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_cadastre_object_trg_new();


--
-- Name: trg_remove; Type: TRIGGER; Schema: cadastre; Owner: postgres
--

CREATE TRIGGER trg_remove BEFORE DELETE ON cadastre_object FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_cadastre_object_trg_remove();


SET search_path = document, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: document; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON document FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: document; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON document FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = party, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON group_party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_member FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON party_role FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON group_party FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_member FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: party; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON party_role FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = source, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON archive FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON spatial_source_measurement FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON power_of_attorney FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON archive FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON spatial_source_measurement FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON power_of_attorney FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: trg_change_of_status; Type: TRIGGER; Schema: source; Owner: postgres
--

CREATE TRIGGER trg_change_of_status BEFORE UPDATE ON source FOR EACH ROW EXECUTE PROCEDURE f_for_tbl_source_trg_change_of_status();


SET search_path = system, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON appuser FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON approle_appgroup FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON appuser_appgroup FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON appuser FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: system; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON approle_appgroup FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = transaction, pg_catalog;

--
-- Name: __track_changes; Type: TRIGGER; Schema: transaction; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON transaction FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_changes; Type: TRIGGER; Schema: transaction; Owner: postgres
--

CREATE TRIGGER __track_changes BEFORE INSERT OR UPDATE ON transaction_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_changes();


--
-- Name: __track_history; Type: TRIGGER; Schema: transaction; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON transaction FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


--
-- Name: __track_history; Type: TRIGGER; Schema: transaction; Owner: postgres
--

CREATE TRIGGER __track_history AFTER DELETE OR UPDATE ON transaction_source FOR EACH ROW EXECUTE PROCEDURE public.f_for_trg_track_history();


SET search_path = administrative, pg_catalog;

--
-- Name: ba_unit_area_ba_unit_id_fk66; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_area
    ADD CONSTRAINT ba_unit_area_ba_unit_id_fk66 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_area_type_code_fk67; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_area
    ADD CONSTRAINT ba_unit_area_type_code_fk67 FOREIGN KEY (type_code) REFERENCES cadastre.area_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ba_unit_as_party_ba_unit_id_fk60; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_as_party
    ADD CONSTRAINT ba_unit_as_party_ba_unit_id_fk60 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_as_party_party_id_fk61; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_as_party
    ADD CONSTRAINT ba_unit_as_party_party_id_fk61 FOREIGN KEY (party_id) REFERENCES party.party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_contains_spatial_unit_ba_unit_id_fk57; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_contains_spatial_unit
    ADD CONSTRAINT ba_unit_contains_spatial_unit_ba_unit_id_fk57 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_contains_spatial_unit_spatial_unit_id_fk58; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_contains_spatial_unit
    ADD CONSTRAINT ba_unit_contains_spatial_unit_spatial_unit_id_fk58 FOREIGN KEY (spatial_unit_id) REFERENCES cadastre.spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_contains_spatial_unit_spatial_unit_id_fk59; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_contains_spatial_unit
    ADD CONSTRAINT ba_unit_contains_spatial_unit_spatial_unit_id_fk59 FOREIGN KEY (spatial_unit_id) REFERENCES cadastre.cadastre_object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_status_code_fk76; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_status_code_fk76 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: ba_unit_target_ba_unit_id_fk72; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_target
    ADD CONSTRAINT ba_unit_target_ba_unit_id_fk72 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_target_transaction_id_fk73; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit_target
    ADD CONSTRAINT ba_unit_target_transaction_id_fk73 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_transaction_id_fk77; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_transaction_id_fk77 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: ba_unit_type_code_fk75; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY ba_unit
    ADD CONSTRAINT ba_unit_type_code_fk75 FOREIGN KEY (type_code) REFERENCES ba_unit_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: certificate_print_ba_unit_fkey; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY certificate_print
    ADD CONSTRAINT certificate_print_ba_unit_fkey FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mortgage_isbased_in_rrr_mortgage_id_fk38; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY mortgage_isbased_in_rrr
    ADD CONSTRAINT mortgage_isbased_in_rrr_mortgage_id_fk38 FOREIGN KEY (mortgage_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mortgage_isbased_in_rrr_rrr_id_fk37; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY mortgage_isbased_in_rrr
    ADD CONSTRAINT mortgage_isbased_in_rrr_rrr_id_fk37 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notation_ba_unit_id_fk64; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_ba_unit_id_fk64 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notation_rrr_id_fk65; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_rrr_id_fk65 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notation_status_code_fk63; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_status_code_fk63 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: notation_transaction_id_fk62; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY notation
    ADD CONSTRAINT notation_transaction_id_fk62 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_rrr_party_id_fk71; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY party_for_rrr
    ADD CONSTRAINT party_for_rrr_party_id_fk71 FOREIGN KEY (party_id) REFERENCES party.party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_rrr_rrr_id_fk69; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY party_for_rrr
    ADD CONSTRAINT party_for_rrr_rrr_id_fk69 FOREIGN KEY (rrr_id, share_id) REFERENCES rrr_share(rrr_id, id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_for_rrr_rrr_id_fk70; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY party_for_rrr
    ADD CONSTRAINT party_for_rrr_rrr_id_fk70 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: required_relationship_baunit_from_ba_unit_id_fk43; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY required_relationship_baunit
    ADD CONSTRAINT required_relationship_baunit_from_ba_unit_id_fk43 FOREIGN KEY (from_ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: required_relationship_baunit_relation_code_fk45; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY required_relationship_baunit
    ADD CONSTRAINT required_relationship_baunit_relation_code_fk45 FOREIGN KEY (relation_code) REFERENCES ba_unit_rel_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: required_relationship_baunit_to_ba_unit_id_fk44; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY required_relationship_baunit
    ADD CONSTRAINT required_relationship_baunit_to_ba_unit_id_fk44 FOREIGN KEY (to_ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rrr_ba_unit_id_fk79; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_ba_unit_id_fk79 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rrr_mortgage_type_code_fk82; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_mortgage_type_code_fk82 FOREIGN KEY (mortgage_type_code) REFERENCES mortgage_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rrr_share_rrr_id_fk68; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr_share
    ADD CONSTRAINT rrr_share_rrr_id_fk68 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rrr_status_code_fk80; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_status_code_fk80 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rrr_transaction_id_fk81; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_transaction_id_fk81 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rrr_type_code_fk78; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr
    ADD CONSTRAINT rrr_type_code_fk78 FOREIGN KEY (type_code) REFERENCES rrr_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: rrr_type_rrr_group_type_code_fk22; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY rrr_type
    ADD CONSTRAINT rrr_type_rrr_group_type_code_fk22 FOREIGN KEY (rrr_group_type_code) REFERENCES rrr_group_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_describes_ba_unit_ba_unit_id_fk41; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY source_describes_ba_unit
    ADD CONSTRAINT source_describes_ba_unit_ba_unit_id_fk41 FOREIGN KEY (ba_unit_id) REFERENCES ba_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_describes_ba_unit_source_id_fk42; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY source_describes_ba_unit
    ADD CONSTRAINT source_describes_ba_unit_source_id_fk42 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_describes_rrr_rrr_id_fk39; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY source_describes_rrr
    ADD CONSTRAINT source_describes_rrr_rrr_id_fk39 FOREIGN KEY (rrr_id) REFERENCES rrr(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_describes_rrr_source_id_fk40; Type: FK CONSTRAINT; Schema: administrative; Owner: postgres
--

ALTER TABLE ONLY source_describes_rrr
    ADD CONSTRAINT source_describes_rrr_source_id_fk40 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = application, pg_catalog;

--
-- Name: application_action_code_fk16; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_action_code_fk16 FOREIGN KEY (action_code) REFERENCES application_action_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_action_type_status_to_set_fk17; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_action_type
    ADD CONSTRAINT application_action_type_status_to_set_fk17 FOREIGN KEY (status_to_set) REFERENCES application_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_agent_id_fk8; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_agent_id_fk8 FOREIGN KEY (agent_id) REFERENCES party.party(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_assignee_id_fk15; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_assignee_id_fk15 FOREIGN KEY (assignee_id) REFERENCES system.appuser(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_contact_person_id_fk14; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_contact_person_id_fk14 FOREIGN KEY (contact_person_id) REFERENCES party.party(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_property_application_id_fk99; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_application_id_fk99 FOREIGN KEY (application_id) REFERENCES application(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_property_ba_unit_id_fk100; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_property
    ADD CONSTRAINT application_property_ba_unit_id_fk100 FOREIGN KEY (ba_unit_id) REFERENCES administrative.ba_unit(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_status_code_fk18; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application
    ADD CONSTRAINT application_status_code_fk18 FOREIGN KEY (status_code) REFERENCES application_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: application_uses_source_application_id_fk101; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_uses_source
    ADD CONSTRAINT application_uses_source_application_id_fk101 FOREIGN KEY (application_id) REFERENCES application(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_uses_source_source_id_fk102; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY application_uses_source
    ADD CONSTRAINT application_uses_source_source_id_fk102 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: request_type_request_category_code_fk20; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_request_category_code_fk20 FOREIGN KEY (request_category_code) REFERENCES request_category_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: request_type_requires_source_type_request_type_code_fk104; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type_requires_source_type
    ADD CONSTRAINT request_type_requires_source_type_request_type_code_fk104 FOREIGN KEY (request_type_code) REFERENCES request_type(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: request_type_requires_source_type_source_type_code_fk103; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type_requires_source_type
    ADD CONSTRAINT request_type_requires_source_type_source_type_code_fk103 FOREIGN KEY (source_type_code) REFERENCES source.administrative_source_type(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: request_type_rrr_type_code_fk21; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_rrr_type_code_fk21 FOREIGN KEY (rrr_type_code) REFERENCES administrative.rrr_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: request_type_type_action_code_fk23; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY request_type
    ADD CONSTRAINT request_type_type_action_code_fk23 FOREIGN KEY (type_action_code) REFERENCES type_action(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_action_code_fk25; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_action_code_fk25 FOREIGN KEY (action_code) REFERENCES service_action_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_action_type_status_to_set_fk26; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service_action_type
    ADD CONSTRAINT service_action_type_status_to_set_fk26 FOREIGN KEY (status_to_set) REFERENCES service_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_application_id_fk7; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_application_id_fk7 FOREIGN KEY (application_id) REFERENCES application(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_request_type_code_fk19; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_request_type_code_fk19 FOREIGN KEY (request_type_code) REFERENCES request_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: service_status_code_fk24; Type: FK CONSTRAINT; Schema: application; Owner: postgres
--

ALTER TABLE ONLY service
    ADD CONSTRAINT service_status_code_fk24 FOREIGN KEY (status_code) REFERENCES service_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


SET search_path = cadastre, pg_catalog;

--
-- Name: cadastre_object_building_unit_type_code_fk55; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_building_unit_type_code_fk55 FOREIGN KEY (building_unit_type_code) REFERENCES building_unit_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cadastre_object_id_fk52; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_id_fk52 FOREIGN KEY (id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_node_target_transaction_id_fk98; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object_node_target
    ADD CONSTRAINT cadastre_object_node_target_transaction_id_fk98 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_status_code_fk54; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_status_code_fk54 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: cadastre_object_target_cadastre_object_id_fk93; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object_target
    ADD CONSTRAINT cadastre_object_target_cadastre_object_id_fk93 FOREIGN KEY (cadastre_object_id) REFERENCES cadastre_object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_target_transaction_id_fk94; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object_target
    ADD CONSTRAINT cadastre_object_target_transaction_id_fk94 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_transaction_id_fk56; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_transaction_id_fk56 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cadastre_object_type_code_fk53; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY cadastre_object
    ADD CONSTRAINT cadastre_object_type_code_fk53 FOREIGN KEY (type_code) REFERENCES cadastre_object_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: legal_space_utility_network_id_fk90; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY legal_space_utility_network
    ADD CONSTRAINT legal_space_utility_network_id_fk90 FOREIGN KEY (id) REFERENCES cadastre_object(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: legal_space_utility_network_status_code_fk91; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY legal_space_utility_network
    ADD CONSTRAINT legal_space_utility_network_status_code_fk91 FOREIGN KEY (status_code) REFERENCES utility_network_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: legal_space_utility_network_type_code_fk92; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY legal_space_utility_network
    ADD CONSTRAINT legal_space_utility_network_type_code_fk92 FOREIGN KEY (type_code) REFERENCES utility_network_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: level_register_type_code_fk49; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY level
    ADD CONSTRAINT level_register_type_code_fk49 FOREIGN KEY (register_type_code) REFERENCES register_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: level_structure_code_fk50; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY level
    ADD CONSTRAINT level_structure_code_fk50 FOREIGN KEY (structure_code) REFERENCES structure_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: level_type_code_fk51; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY level
    ADD CONSTRAINT level_type_code_fk51 FOREIGN KEY (type_code) REFERENCES level_content_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_address_address_id_fk86; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_address
    ADD CONSTRAINT spatial_unit_address_address_id_fk86 FOREIGN KEY (address_id) REFERENCES address.address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_address_spatial_unit_id_fk85; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_address
    ADD CONSTRAINT spatial_unit_address_spatial_unit_id_fk85 FOREIGN KEY (spatial_unit_id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_change_spatial_unit_id_fk; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_change
    ADD CONSTRAINT spatial_unit_change_spatial_unit_id_fk FOREIGN KEY (spatial_unit_id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_change_transaction_id_fk; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_change
    ADD CONSTRAINT spatial_unit_change_transaction_id_fk FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_dimension_code_fk46; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_dimension_code_fk46 FOREIGN KEY (dimension_code) REFERENCES dimension_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_group_found_in_spatial_unit_group_id_fk87; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_group
    ADD CONSTRAINT spatial_unit_group_found_in_spatial_unit_group_id_fk87 FOREIGN KEY (found_in_spatial_unit_group_id) REFERENCES spatial_unit_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_in_group_spatial_unit_group_id_fk88; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_in_group
    ADD CONSTRAINT spatial_unit_in_group_spatial_unit_group_id_fk88 FOREIGN KEY (spatial_unit_group_id) REFERENCES spatial_unit_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_in_group_spatial_unit_id_fk89; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_in_group
    ADD CONSTRAINT spatial_unit_in_group_spatial_unit_id_fk89 FOREIGN KEY (spatial_unit_id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_unit_in_group_status_code_fk; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit_in_group
    ADD CONSTRAINT spatial_unit_in_group_status_code_fk FOREIGN KEY (unit_parcel_status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_level_id_fk48; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_level_id_fk48 FOREIGN KEY (level_id) REFERENCES level(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_unit_surface_relation_code_fk47; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_unit
    ADD CONSTRAINT spatial_unit_surface_relation_code_fk47 FOREIGN KEY (surface_relation_code) REFERENCES surface_relation_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_value_area_spatial_unit_id_fk83; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_value_area
    ADD CONSTRAINT spatial_value_area_spatial_unit_id_fk83 FOREIGN KEY (spatial_unit_id) REFERENCES spatial_unit(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_value_area_type_code_fk84; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY spatial_value_area
    ADD CONSTRAINT spatial_value_area_type_code_fk84 FOREIGN KEY (type_code) REFERENCES area_type(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: survey_point_transaction_id_fk95; Type: FK CONSTRAINT; Schema: cadastre; Owner: postgres
--

ALTER TABLE ONLY survey_point
    ADD CONSTRAINT survey_point_transaction_id_fk95 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = party, pg_catalog;

--
-- Name: group_party_id_fk31; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY group_party
    ADD CONSTRAINT group_party_id_fk31 FOREIGN KEY (id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: group_party_type_code_fk32; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY group_party
    ADD CONSTRAINT group_party_type_code_fk32 FOREIGN KEY (type_code) REFERENCES group_party_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_address_id_fk10; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_address_id_fk10 FOREIGN KEY (address_id) REFERENCES address.address(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_gender_code_fk13; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_gender_code_fk13 FOREIGN KEY (gender_code) REFERENCES gender_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_id_type_code_fk12; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_id_type_code_fk12 FOREIGN KEY (id_type_code) REFERENCES id_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_member_group_id_fk34; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party_member
    ADD CONSTRAINT party_member_group_id_fk34 FOREIGN KEY (group_id) REFERENCES group_party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_member_party_id_fk33; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party_member
    ADD CONSTRAINT party_member_party_id_fk33 FOREIGN KEY (party_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_preferred_communication_code_fk11; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_preferred_communication_code_fk11 FOREIGN KEY (preferred_communication_code) REFERENCES communication_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: party_role_party_id_fk35; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party_role
    ADD CONSTRAINT party_role_party_id_fk35 FOREIGN KEY (party_id) REFERENCES party(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_role_type_code_fk36; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party_role
    ADD CONSTRAINT party_role_type_code_fk36 FOREIGN KEY (type_code) REFERENCES party_role_type(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: party_type_code_fk9; Type: FK CONSTRAINT; Schema: party; Owner: postgres
--

ALTER TABLE ONLY party
    ADD CONSTRAINT party_type_code_fk9 FOREIGN KEY (type_code) REFERENCES party_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


SET search_path = source, pg_catalog;

--
-- Name: power_of_attorney_id_fk74; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY power_of_attorney
    ADD CONSTRAINT power_of_attorney_id_fk74 FOREIGN KEY (id) REFERENCES source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_archive_id_fk0; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_archive_id_fk0 FOREIGN KEY (archive_id) REFERENCES archive(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_availability_status_code_fk2; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_availability_status_code_fk2 FOREIGN KEY (availability_status_code) REFERENCES availability_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_maintype_fk1; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_maintype_fk1 FOREIGN KEY (maintype) REFERENCES presentation_form_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_status_code_fk4; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_status_code_fk4 FOREIGN KEY (status_code) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: source_transaction_id_fk5; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_transaction_id_fk5 FOREIGN KEY (transaction_id) REFERENCES transaction.transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: source_type_code_fk3; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY source
    ADD CONSTRAINT source_type_code_fk3 FOREIGN KEY (type_code) REFERENCES administrative_source_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: spatial_source_id_fk28; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY spatial_source
    ADD CONSTRAINT spatial_source_id_fk28 FOREIGN KEY (id) REFERENCES source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_source_measurement_spatial_source_id_fk30; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY spatial_source_measurement
    ADD CONSTRAINT spatial_source_measurement_spatial_source_id_fk30 FOREIGN KEY (spatial_source_id) REFERENCES spatial_source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: spatial_source_type_code_fk29; Type: FK CONSTRAINT; Schema: source; Owner: postgres
--

ALTER TABLE ONLY spatial_source
    ADD CONSTRAINT spatial_source_type_code_fk29 FOREIGN KEY (type_code) REFERENCES spatial_source_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


SET search_path = system, pg_catalog;

--
-- Name: approle_appgroup_appgroup_id_fk120; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY approle_appgroup
    ADD CONSTRAINT approle_appgroup_appgroup_id_fk120 FOREIGN KEY (appgroup_id) REFERENCES appgroup(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: approle_appgroup_approle_code_fk119; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY approle_appgroup
    ADD CONSTRAINT approle_appgroup_approle_code_fk119 FOREIGN KEY (approle_code) REFERENCES approle(code) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: appuser_appgroup_appgroup_id_fk122; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY appuser_appgroup
    ADD CONSTRAINT appuser_appgroup_appgroup_id_fk122 FOREIGN KEY (appgroup_id) REFERENCES appgroup(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: appuser_appgroup_appuser_id_fk121; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY appuser_appgroup
    ADD CONSTRAINT appuser_appgroup_appuser_id_fk121 FOREIGN KEY (appuser_id) REFERENCES appuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: appuser_setting_user_id_fk105; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY appuser_setting
    ADD CONSTRAINT appuser_setting_user_id_fk105 FOREIGN KEY (user_id) REFERENCES appuser(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: br_definition_br_id_fk118; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_definition
    ADD CONSTRAINT br_definition_br_id_fk118 FOREIGN KEY (br_id) REFERENCES br(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: br_technical_type_code_fk109; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br
    ADD CONSTRAINT br_technical_type_code_fk109 FOREIGN KEY (technical_type_code) REFERENCES br_technical_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_br_id_fk110; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_br_id_fk110 FOREIGN KEY (br_id) REFERENCES br(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_severity_code_fk111; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_severity_code_fk111 FOREIGN KEY (severity_code) REFERENCES br_severity_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_application_moment_fk115; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_application_moment_fk115 FOREIGN KEY (target_application_moment) REFERENCES application.application_action_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_code_fk112; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_code_fk112 FOREIGN KEY (target_code) REFERENCES br_validation_target_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_reg_moment_fk117; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_reg_moment_fk117 FOREIGN KEY (target_reg_moment) REFERENCES transaction.reg_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_request_type_code_fk113; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_request_type_code_fk113 FOREIGN KEY (target_request_type_code) REFERENCES application.request_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_rrr_type_code_fk114; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_rrr_type_code_fk114 FOREIGN KEY (target_rrr_type_code) REFERENCES administrative.rrr_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: br_validation_target_service_moment_fk116; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY br_validation
    ADD CONSTRAINT br_validation_target_service_moment_fk116 FOREIGN KEY (target_service_moment) REFERENCES application.service_action_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: config_map_layer_pojo_query_name_fk107; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_pojo_query_name_fk107 FOREIGN KEY (pojo_query_name) REFERENCES query(name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: config_map_layer_pojo_query_name_for_select_fk108; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_pojo_query_name_for_select_fk108 FOREIGN KEY (pojo_query_name_for_select) REFERENCES query(name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: config_map_layer_type_code_fk106; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY config_map_layer
    ADD CONSTRAINT config_map_layer_type_code_fk106 FOREIGN KEY (type_code) REFERENCES config_map_layer_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: map_search_option_query_name_fk124; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY map_search_option
    ADD CONSTRAINT map_search_option_query_name_fk124 FOREIGN KEY (query_name) REFERENCES query(name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: query_field_query_name_fk123; Type: FK CONSTRAINT; Schema: system; Owner: postgres
--

ALTER TABLE ONLY query_field
    ADD CONSTRAINT query_field_query_name_fk123 FOREIGN KEY (query_name) REFERENCES query(name) ON UPDATE CASCADE ON DELETE CASCADE;


SET search_path = transaction, pg_catalog;

--
-- Name: transaction_from_service_id_fk6; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_from_service_id_fk6 FOREIGN KEY (from_service_id) REFERENCES application.service(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transaction_source_source_id_fk97; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction_source
    ADD CONSTRAINT transaction_source_source_id_fk97 FOREIGN KEY (source_id) REFERENCES source.source(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_source_transaction_id_fk96; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction_source
    ADD CONSTRAINT transaction_source_transaction_id_fk96 FOREIGN KEY (transaction_id) REFERENCES transaction(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: transaction_spatial_unit_group_id_fk6; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_spatial_unit_group_id_fk6 FOREIGN KEY (spatial_unit_group_id) REFERENCES cadastre.spatial_unit_group(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transaction_status_code_fk27; Type: FK CONSTRAINT; Schema: transaction; Owner: postgres
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_status_code_fk27 FOREIGN KEY (status_code) REFERENCES transaction_status_type(code) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

