-- 13 Jul 2016

-- #186 Add Le Mafa  Village in the Atua district
INSERT INTO administrative.ba_unit (id, type_code, name, name_firstpart, name_lastpart, status_code, change_user)
VALUES ('LOC503', 'administrativeUnit', 'Le Mafa/Village', 'Le Mafa', 'Village', 'current', 'andrew');

INSERT INTO administrative.required_relationship_baunit(
            from_ba_unit_id, to_ba_unit_id, relation_code, change_user)
    VALUES ('LD715954','LOC503', 'district_Village', 'andrew');