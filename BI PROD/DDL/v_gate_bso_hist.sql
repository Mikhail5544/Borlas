CREATE OR REPLACE FORCE VIEW V_GATE_BSO_HIST AS
select b.num num_bso
      ,bt.name type_bso
      ,bs.series_num
      ,bh.num
      ,bht.name as hist_status
      ,bh.hist_date
      ,c.obj_name_orig holder
 from (SELECT DISTINCT bh.bso_id
        FROM ins.bso_hist bh
       WHERE bh.contact_id in (767818,381891)
       )                       bbh
      ,ins.bso                 b
      ,ins.bso_series          bs
      ,ins.bso_type            bt
      ,ins.bso_hist            bh
      ,ins.bso_hist_type       bht
      ,ins.contact             c
 where bbh.bso_id = b.bso_id
   AND bs.bso_series_id   = b.bso_series_id
   and bs.bso_type_id     = bt.bso_type_id
   and b.bso_id      = bh.bso_id
   and bh.hist_type_id    = bht.bso_hist_type_id
   AND bh.contact_id = c.contact_id(+);

