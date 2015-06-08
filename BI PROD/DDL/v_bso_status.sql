create or replace view ins.v_bso_status as
select bs.series_num||bso.num as bso_ser_num
       ,bs.series_num
       ,bso.num            as bso_num
       ,bt.brief           as bso_status
       ,pp.pol_ser
       ,pp.pol_num
       ,ph.ids
       ,pi.contact_name
       ,pr.brief           as product_brief
   from ins.bso
       ,ins.bso_hist       bh
       ,ins.bso_hist_type  bt
       ,ins.bso_series     bs
       ,ins.p_policy       pp
       ,ins.p_pol_header   ph
       ,ins.v_pol_issuer   pi
       ,ins.t_product      pr
  where bso.bso_series_id    = bs.bso_series_id
    and bso.bso_hist_id      = bh.bso_hist_id
    and bh.hist_type_id      = bt.bso_hist_type_id
    and bso.policy_id        = pp.policy_id        (+)
    and pp.policy_id         = pi.policy_id        (+)
    and pp.pol_header_id     = ph.policy_header_id (+)
    and ph.product_id        = pr.product_id       (+);

grant select on ins.v_bso_status to ins_eul;
grant select on ins.v_bso_status to ins_read;
