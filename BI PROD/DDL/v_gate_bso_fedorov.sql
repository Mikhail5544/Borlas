create or replace view v_gate_bso_fedorov as
select b.num num_bso
      ,bt.name type_bso
      ,bs.series_num
      ,bht.name as hist_status
      ,bh.hist_date
      ,pr.description as product_desc
      ,pr.brief       as product_brief
      ,pr.product_id
 from ins.bso                 b
      ,ins.bso_series          bs
      ,ins.bso_type            bt
      ,ins.bso_hist            bh
      ,ins.bso_hist_type       bht
      ,ins.t_product_bso_types pbt
      ,ins.t_product           pr
 where bh.contact_id in (767818,381891)
   and bs.bso_series_id   = b.bso_series_id
   and bs.bso_type_id     = bt.bso_type_id
   and b.bso_hist_id      = bh.bso_hist_id
   and bh.hist_type_id    = bht.bso_hist_type_id
   and bt.bso_type_id     = pbt.bso_type_id (+)
   and pbt.t_product_id   = pr.product_id (+);
