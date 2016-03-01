-- 2 Mar 2016 Ticket #185
-- Disable access for Tufi. 
UPDATE system.appuser
SET active = FALSE
WHERE username = 'tufi';
