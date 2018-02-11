-- 10 Feb 2018
-- Delete 394/3615 from the database
UPDATE administrative.ba_unit 
SET    change_user = 'andrew', 
       change_action = 'd'
WHERE  name IN ('394/3615')
AND    status_code = 'pending'; 

DELETE FROM administrative.ba_unit 
WHERE  name IN ('394/3615')
AND    status_code = 'pending'; 

-- Add the missing database constraint. Need to add a new transaction record for the
-- migrated data first. 
INSERT INTO transaction.transaction (id, status_code, approval_datetime, change_user)
      VALUES ('adm-transaction', 'completed', now(), 'andrew');
      
ALTER TABLE administrative.ba_unit DROP CONSTRAINT IF EXISTS ba_unit_transaction_id_fk40; 
ALTER TABLE administrative.ba_unit ADD CONSTRAINT ba_unit_transaction_id_fk40 FOREIGN KEY (transaction_id)
      REFERENCES transaction.transaction (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
