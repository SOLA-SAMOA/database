-- 16 Feb 2017
-- Make sure the rowversion of this rrr is 1. 
UPDATE administrative.rrr 
SET rowversion = 1
WHERE id = '2c829f05-300d-4116-8453-3d120c3dfbbe';