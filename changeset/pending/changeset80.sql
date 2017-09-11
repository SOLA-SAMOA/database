-- 17 Aug 2017
-- Change the reference number from all characters to include a digit to avoid
-- a sort issue in the application. 
update administrative.notation set reference_nr = 'convey0' 
where reference_nr = 'convey' and rrr_id in 
(select id from administrative.rrr where ba_unit_id in (
select id from administrative.ba_unit where name = '1517/5505'))
