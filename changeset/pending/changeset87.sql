-- 5 Nov 2018
-- Change priorTitle relationship to Village where it is incorrectly recorded. 

    UPDATE administrative.required_relationship_baunit
    SET    relation_code = 'title_Village',
	       change_user = 'andrew'
    WHERE  relation_code = 'priorTitle'
    AND    EXISTS (SELECT vill.id
            FROM   administrative.ba_unit vill
            WHERE  vill.id = from_ba_unit_id
            AND    name_lastpart = 'Village')
    AND  NOT EXISTS (SELECT rel.to_ba_unit_id
                     FROM administrative.required_relationship_baunit rel
                     WHERE rel.to_ba_unit_id = administrative.required_relationship_baunit.to_ba_unit_id
                     AND   rel.relation_code = 'title_Village'
                     AND   rel.rowidentifier != administrative.required_relationship_baunit.rowidentifier); 
            