create or replace procedure Update_BSO(ser_bso varchar2,
                                       num_bso varchar2)
is
bsoid number;
num_s number;
max_hist number;
begin

  select bs.bso_id
  into bsoid
  from bso bs
       left join bso_series sr on (sr.bso_series_id = bs.bso_series_id)
  where sr.series_name like ser_bso
        and bs.num like num_bso;
  select max(hs.num),
         hs.bso_id
  into num_s, bsoid
  from bso_hist hs
  where hs.bso_id = bsoid
  group by hs.bso_id;
  insert into bso_hist (bso_hist_id,bso_id,hist_date,hist_type_id,num)
         values (sq_bso_hist.nextval,bsoid,sysdate(),12,num_s + 1);
  select max(bh.bso_hist_id),
         bh.bso_id
  into max_hist, bsoid
  from bso_hist bh
  where bh.bso_id = bsoid
  group by bh.bso_id;
  update bso set bso_hist_id = max_hist where bso_id = bsoid;

end Update_BSO;
/

