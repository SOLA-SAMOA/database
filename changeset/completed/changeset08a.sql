-- Run 2 Feb 2012

-- Updates the source records to create linkages where the scanning has failed to link correctly. 
UPDATE source.source
SET ext_archive_id = s2.ext_archive_id, 
version = 'linked'
FROM source.source s2
WHERE source.source.submission > '20 NOV 2012' 
AND source.source.archive_id IS NULL
AND source.source.ext_archive_id IS NULL
AND s2.submission > '20 NOV 2012' 
AND s2.archive_id  IS NULL
AND s2.ext_archive_id IS NOT  NULL
AND s2.la_nr || '-01' = source.source.la_nr; 

CREATE UNIQUE INDEX ba_unit_name_unique_ind
   ON administrative.ba_unit (name_firstpart ASC NULLS LAST, name_lastpart ASC NULLS LAST);
   
