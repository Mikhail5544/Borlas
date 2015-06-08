create or replace view INS_DWH.V_RESERVES_VS_PROFIT_LSTPOL
as
select /*+ INDEX(ds PK_DOC_STATUS)*/
         pp.policy_id
        ,pp.pol_header_id
        ,pp.decline_date
        ,pp.decline_reason_id
        ,tdr.name as decline_reason_name
        ,dsr.name as status_name
        ,ds.start_date as status_start_date
    from ins.p_policy         pp
        ,ins.t_decline_reason tdr
        ,ins.document         dc
        ,ins.doc_status       ds
        ,ins.doc_status_ref   dsr
        ,ins.p_pol_header ph
        ,ins.t_product pr
   where pp.decline_reason_id = tdr.t_decline_reason_id (+)
     and pp.policy_id         = dc.document_id
     and dc.doc_status_id     = ds.doc_status_id
     and ds.doc_status_ref_id = dsr.doc_status_ref_id
     AND ph.last_ver_id       = pp.policy_id
     AND ph.product_id        = pr.product_id
     AND ((ins_dwh.pkg_reserves_vs_profit.get_mode = 0
           and pr.brief not in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
           and pp.is_group_flag = 0
          )or
          (ins_dwh.pkg_reserves_vs_profit.get_mode = 1
           and pr.brief in ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
          )or
          (ins_dwh.pkg_reserves_vs_profit.get_mode = 2
           and pp.is_group_flag = 1
          )
         );
