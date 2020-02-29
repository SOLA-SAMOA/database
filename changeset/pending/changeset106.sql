
-- 1 Mar 2020.
-- Update business rules to allow district boundary surveys to be approved. 

	  
	  UPDATE system.br_definition SET body = 
	  'WITH cadastre_objs AS
         (SELECT co.id FROM cadastre.cadastre_object co
		  WHERE co.transaction_id = #{id}
          UNION 
		  SELECT suc.id FROM cadastre.spatial_unit_change  suc,
		  cadastre.level l
		  WHERE suc.transaction_id = #{id}
		  AND   l.id = suc.level_id
		  AND   l.name = ''District Boundary'')
      SELECT COUNT (*) > 0 AS vl FROM cadastre_objs'
	  WHERE br_id = 'new-cadastre-objects-present'
	  
	  
	   UPDATE system.br_definition SET body = 
	  'WITH cadastre_objs AS
         (SELECT 1 AS obj_cnt FROM cadastre.survey_point sp
		  WHERE sp.transaction_id = #{id}
          UNION ALL
		  SELECT 3 AS obj_cnt FROM cadastre.spatial_unit_change  suc,
		  cadastre.level l
		  WHERE suc.transaction_id = #{id}
		  AND   l.id = suc.level_id
		  AND   l.name = ''District Boundary'')
      SELECT SUM(obj_cnt) > 2 AS vl FROM cadastre_objs'
	  WHERE br_id = 'survey-points-present'