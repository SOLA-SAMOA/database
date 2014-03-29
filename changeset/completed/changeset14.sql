-- ?? Mar 2012
-- #94 Total Share BR check gives false failures
UPDATE system.br_definition SET "body" = '
SELECT (SUM(nominator::DECIMAL/denominator::DECIMAL)*10000)::INT = 10000  AS vl
FROM   administrative.rrr_share 
WHERE  rrr_id = #{id}
AND    denominator != 0'
WHERE br_id = 'rrr-shares-total-check';


