-- 25 Jan 2017
-- Update the reference_nr for a notation to avoid a rrr_sort error. 
update administrative.notation
set reference_nr = 'Transfer0',
change_user = 'andrew'
where id = 'f42aea21-79f2-4322-ae15-a4df7f06ec35'; 