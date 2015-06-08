CREATE OR REPLACE VIEW INS.V_FIND_PAYMENT_VOLUME AS
select arh.num vedom,
       ar.num vedom_ver,
       arh.date_begin,
       arh.date_end,
       dep.NAME agency,
       ts.DESCRIPTION sales_ch,
       ach_new.num ad,
       cn.obj_name_orig agent_fio,
       ph.Ids IDS,
       tp.DESCRIPTION product,
       cn_ins.obj_name_orig Insuer,
       pt.DESCRIPTION payment_term,
       f.NAME fund,
       epg.num epg_num,
       agv.epg_date,
       agv.epg_ammount,
       acpt.title pd_type,
       cm.DESCRIPTION collect_method,
       agv.payment_date,
       SUM(agv.trans_sum) trans_sum,
       avt.DESCRIPTION volume_type
  from ins.ven_ag_roll ar,
       ins.ven_ag_roll_header arh,
       ins.ag_volume agv,
       ins.ag_volume_type avt,
      (SELECT prev.a2 ag_contract_header_id, NVL(ag.agency_id,ach.agency_id) agency_id, ach.agent_id, ach.num, NVL(chac.id,ach.t_sales_channel_id) t_sales_channel_id
         FROM ins.ven_ag_contract_header ach,
              ins.ag_contract ag,
              ins.t_sales_channel chac,
              (SELECT *
                 FROM (SELECT ach.ag_contract_header_id a1,
                              ach.ag_contract_header_id a2
                         FROM ins.ag_contract_header ach
                        WHERE ach.is_new = 1
                        )
              ) prev
        WHERE ach.ag_contract_header_id = prev.a1
          AND ach.is_new = 1
          AND ach.ag_contract_header_id = ag.contract_id
          AND SYSDATE BETWEEN ag.date_begin AND ag.date_end
          AND ag.ag_sales_chn_id = chac.id(+) ) ach_new,
       ins.department dep,
       ins.contact cn,
       ins.t_sales_channel ts,
       ins.p_pol_header ph,
       ins.p_policy pp,
       ins.contact cn_ins,
       ins.t_payment_terms pt,
       ins.document epg,
       ins.fund f,
       ins.document pd,
       ins.ac_payment_templ acpt,
       ins.t_collection_method cm,
       ins.t_prod_line_option tplo,
       ins.trans t,
       ins.t_product tp
 WHERE 1=1
   AND ph.ids = (SELECT r.param_value
                 FROM ins_dwh.rep_param r
                 WHERE r.rep_name = 'paym_vol'
                 AND r.param_name = 'ids'
                 )
   /*AND arh.date_begin = TO_DATE(
                        (SELECT r.param_value
                         FROM ins_dwh.rep_param r
                         WHERE r.rep_name = 'paym_vol'
                         AND r.param_name = 'date_from'
                         ),'DD.MM.YYYY')
   AND arh.date_end = TO_DATE(
                        (SELECT r.param_value
                         FROM ins_dwh.rep_param r
                         WHERE r.rep_name = 'paym_vol'
                         AND r.param_name = 'date_to'
                         ),'DD.MM.YYYY')*/
   /*AND ph.ids = 1560399735*/
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND agv.ag_contract_header_id = ach_new.ag_contract_header_id (+)
   AND agv.ag_roll_id = ar.ag_roll_id
   AND avt.ag_volume_type_id = agv.ag_volume_type_id
   AND avt.ag_volume_type_id IN (1,4,6)
   AND ach_new.agent_id = cn.contact_id (+)
   AND ach_new.agency_id = dep.department_id (+)
   AND ach_new.t_sales_channel_id = ts.ID (+)
   AND agv.policy_header_id = ph.policy_header_id
   AND ph.policy_id = pp.policy_id
   AND ins.pkg_policy.get_policy_contact(ph.policy_id,'Страхователь') = cn_ins.contact_id
   AND agv.payment_term_id = pt.ID
   AND epg.document_id = agv.epg_payment
   AND f.fund_id = agv.fund
   AND agv.pd_payment = pd.document_id
   AND acpt.payment_templ_id = agv.epg_pd_type
   AND cm.id = agv.pd_collection_method
   AND tplo.ID = agv.t_prod_line_option_id
   AND agv.trans_id = t.trans_id (+)
   AND tp.product_id = ph.product_id
GROUP BY arh.num,
       ar.num,
       arh.date_begin,
       arh.date_end,
       dep.NAME,
       ts.DESCRIPTION,
       ach_new.num,
       cn.obj_name_orig,
       ph.Ids,
       tp.DESCRIPTION,
       cn_ins.obj_name_orig,
       pt.DESCRIPTION,
       f.NAME,
       epg.num,
       agv.epg_date,
       agv.epg_ammount,
       acpt.title,
       cm.DESCRIPTION,
       agv.payment_date,
       avt.DESCRIPTION;
   
GRANT SELECT ON INS.V_FIND_PAYMENT_VOLUME TO INS_EUL;
GRANT SELECT ON INS.V_FIND_PAYMENT_VOLUME TO INS_READ;
