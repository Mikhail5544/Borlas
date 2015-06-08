create or replace procedure START_may_2008_vadim
IS

--ÎÀÂ - ìàé 2008


begin

ins.DAV_tmp_table_make;
commit;

av_oav_all_vadim (5955329,to_date('01.05.2008','dd.mm.yyyy'),1,null);
commit;

av_oav_all_vadim (5955342,to_date('01.05.2008','dd.mm.yyyy'),2,null);
commit;

av_oav_all_vadim (5955376,to_date('01.05.2008','dd.mm.yyyy'),3,null);
commit;

av_oav_all_vadim (5955424,to_date('01.05.2008','dd.mm.yyyy'),4,null);
commit;

end START_may_2008_vadim;
/

