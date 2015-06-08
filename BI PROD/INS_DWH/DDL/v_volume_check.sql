CREATE OR REPLACE FORCE VIEW INS_DWH.V_VOLUME_CHECK AS
select arh.num vedom,
       ar.num vedom_ver,
       dep.NAME agency,
       ts.DESCRIPTION sales_ch,
       ach_new.num ad,
       cn.obj_name_orig agent_fio,
       ph.Ids IDS,
       pp.pol_num policy_num,
       tp.DESCRIPTION product,
       cn_ins.obj_name_orig Insuer,
       NULL gender,
       NULL dob,
       agv.date_begin policy_begin,
       agv.ins_period insurance_term,
       ins.ent.obj_name('DOC_STATUS_REF',agv.last_status) last_status,
       ins.ent.obj_name('DOC_STATUS_REF',agv.active_status) active_status,
       pt.DESCRIPTION payment_term,
       f.NAME fund,
       epg.num epg_num,
       agv.epg_date,
       agv.pay_period pay_year,
       agv.epg_ammount,
       ins.ent.obj_name('DOC_STATUS_REF',agv.epg_status) epg_status,
       ins.ent.obj_name('DOC_STATUS_REF',agv.pd_copy_status) pd_copy_status,
       acpt.title pd_type,
       pd.num pd_num,
       cm.DESCRIPTION collect_method,
       agv.payment_date,
       t.reg_date reg_date,
       tplo.DESCRIPTION cover,
       agv.trans_sum,
       agv.index_delta_sum,
       agv.nbv_coef,
       agv.is_nbv,
       NULL work_book_copy,--agv.ops_is_seh,
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
                       UNION
                       SELECT apd.ag_contract_header_id,
                              apd.ag_prev_header_id
                         FROM ins.ag_prev_dog apd)
              ) prev
        WHERE ach.ag_contract_header_id = prev.a1
          AND ach.is_new = 1
          AND ach.ag_contract_header_id = ag.contract_id
          AND (SELECT ah.date_end
               FROM ins.ven_ag_roll_header ah
               WHERE ah.num = LPAD((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'vol_chk'
                                      AND r.param_name = 'num_ved'),6,'0')) BETWEEN ag.date_begin AND ag.date_end
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
   AND arh.ag_roll_header_id = (SELECT arhi.ag_roll_header_id
                                FROM ins.Ven_Ag_Roll_Header arhi
                                WHERE arhi.num = LPAD((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                  WHERE r.rep_name = 'vol_chk'
                                                    AND r.param_name = 'num_ved'),6,'0')
                               )
   AND ar.num = nvl( (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'vol_chk'
                      AND r.param_name = 'ver_ved') ,
                      ar.num)
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND agv.ag_contract_header_id = ach_new.ag_contract_header_id (+)
   AND agv.ag_roll_id = ar.ag_roll_id--23834829
  --AND ach_new.num = '10378'
  -- AND ph.Ids = 1140475951 --1910083586 --1560183920
   AND avt.ag_volume_type_id = agv.ag_volume_type_id
   AND avt.brief IN ('RL','INFO','INV','FDep')
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
  -- AND ph.Ids = 1160416305
  -- AND agv.ag_contract_header_id = 23106867
 UNION ALL
 SELECT arh.num,
        ar.num,
        dep.NAME agency,
        ts.DESCRIPTION sales_ch,
       ach_new.num ad,
       cn.obj_name_orig agent_fio,
       NULL, --ph.Ids IDS,
       anv.snils,--pp.pol_num policy_num,
       null,--tp.DESCRIPTION product,
       anv.fio,--cn_ins.obj_name_orig Insuer,
       anv.gender,
       anv.assured_birf_date dob,
       anv.sign_date, --agv.date_begin policy_begin,
       null,--agv.ins_period insurance_term,
       null,--ent.obj_name('DOC_STATUS_REF',agv.last_status) last_status,
       null,--ent.obj_name('DOC_STATUS_REF',agv.active_status) active_status,
       null,--pt.DESCRIPTION payment_term,
       null,--f.NAME fund,
       null,--epg.num epg_num,
       null,--agv.epg_date,
       null,--agv.pay_period pay_year,
       null,--agv.epg_ammount,
       null,--ent.obj_name('DOC_STATUS_REF',agv.epg_status) epg_status,
       null,--ent.obj_name('DOC_STATUS_REF',agv.pd_copy_status) pd_copy_status,
       null,--acpt.title pd_type,
       null,--pd.num pd_num,
       null,--cm.DESCRIPTION collect_method,
       null,--agv.payment_date,
       null,--t.reg_date reg_date,
       null,--tplo.DESCRIPTION cover,
       agv.trans_sum,
       null,--agv.index_delta_sum,
       agv.nbv_coef,
       agv.is_nbv,
       anv.ops_is_seh,
       avt.DESCRIPTION volume_type
  FROM ins.ven_ag_roll ar,
       ins.ven_ag_roll_header arh,
       ins.ag_volume agv,
       ins.ag_volume_type avt,
       ins.ag_npf_volume_det anv,
       (SELECT prev.a2 ag_contract_header_id, NVL(ag.agency_id,ach.agency_id) agency_id, ach.agent_id, ach.num, NVL(chac.id,ach.t_sales_channel_id) t_sales_channel_id
         FROM ins.ven_ag_contract_header ach,
              ins.ag_contract ag,
              ins.t_sales_channel chac,
              (SELECT *
                 FROM (SELECT ach.ag_contract_header_id a1,
                              ach.ag_contract_header_id a2
                         FROM ins.ag_contract_header ach
                        WHERE ach.is_new = 1
                       UNION
                       SELECT apd.ag_contract_header_id,
                              apd.ag_prev_header_id
                         FROM ins.ag_prev_dog apd)
              ) prev
        WHERE ach.ag_contract_header_id = prev.a1
          AND ach.is_new = 1
          AND ach.ag_contract_header_id = ag.contract_id
          AND (SELECT ah.date_end
               FROM ins.ven_ag_roll_header ah
               WHERE ah.num = LPAD((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'vol_chk'
                                      AND r.param_name = 'num_ved'),6,'0')) BETWEEN ag.date_begin AND ag.date_end
          AND ag.ag_sales_chn_id = chac.id(+)) ach_new,
       ins.department dep,
       ins.contact cn,
       ins.t_sales_channel ts
 WHERE 1=1
   AND arh.ag_roll_header_id = (SELECT arhi.ag_roll_header_id
                                FROM ins.Ven_Ag_Roll_Header arhi
                                WHERE arhi.num = LPAD((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                  WHERE r.rep_name = 'vol_chk'
                                                    AND r.param_name = 'num_ved'),6,'0')
                               )
   AND ar.num = nvl( (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'vol_chk'
                      AND r.param_name = 'ver_ved') ,
                     ar.num)
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND agv.ag_contract_header_id = ach_new.ag_contract_header_id (+)
   AND agv.ag_roll_id = ar.ag_roll_id -- 23834829
   AND agv.ag_volume_id   = anv.ag_volume_id (+)
   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
   AND avt.brief IN ('NPF','NPF02','SOFI','AVCP')
   AND agv.ag_contract_header_id = ach_new.ag_contract_header_id
   AND dep.department_id (+) = ach_new.agency_id
   AND ach_new.agent_id = cn.contact_id (+)
   AND ach_new.t_sales_channel_id = ts.id  (+)
 UNION ALL
 SELECT arh.num,
        ar.num,
        dep.NAME agency,
        ts.DESCRIPTION sales_ch,
       ach_new.num ad,
       cn.obj_name_orig agent_fio,
       NULL, --ph.Ids IDS,
       anv.policy_num,--pp.pol_num policy_num,
       null,--tp.DESCRIPTION product,
       anv.fio,--cn_ins.obj_name_orig Insuer,
       anv.gender,
       anv.assured_birf_date dob,
       anv.sign_date, --agv.date_begin policy_begin,
       null,--agv.ins_period insurance_term,
       null,--ent.obj_name('DOC_STATUS_REF',agv.last_status) last_status,
       null,--ent.obj_name('DOC_STATUS_REF',agv.active_status) active_status,
       null,--pt.DESCRIPTION payment_term,
       null,--f.NAME fund,
       null,--epg.num epg_num,
       null,--agv.epg_date,
       null,--agv.pay_period pay_year,
       null,--agv.epg_ammount,
       null,--ent.obj_name('DOC_STATUS_REF',agv.epg_status) epg_status,
       null,--ent.obj_name('DOC_STATUS_REF',agv.pd_copy_status) pd_copy_status,
       null,--acpt.title pd_type,
       null,--pd.num pd_num,
       null,--cm.DESCRIPTION collect_method,
       null,--agv.payment_date,
       null,--t.reg_date reg_date,
       null,--tplo.DESCRIPTION cover,
       agv.trans_sum,
       null,--agv.index_delta_sum,
       agv.nbv_coef,
       agv.is_nbv,
       NULL,
       avt.DESCRIPTION volume_type
  FROM ins.ven_ag_roll ar,
       ins.ven_ag_roll_header arh,
       ins.ag_volume agv,
       ins.ag_volume_type avt,
       ins.ag_trast_volume_det anv,
       (SELECT prev.a2 ag_contract_header_id, NVL(ag.agency_id,ach.agency_id) agency_id, ach.agent_id, ach.num, NVL(chac.id,ach.t_sales_channel_id) t_sales_channel_id
         FROM ins.ven_ag_contract_header ach,
              ins.ag_contract ag,
              ins.t_sales_channel chac,
              (SELECT *
                 FROM (SELECT ach.ag_contract_header_id a1,
                              ach.ag_contract_header_id a2
                         FROM ins.ag_contract_header ach
                        WHERE ach.is_new = 1
                       UNION
                       SELECT apd.ag_contract_header_id,
                              apd.ag_prev_header_id
                         FROM ins.ag_prev_dog apd)
              ) prev
        WHERE ach.ag_contract_header_id = prev.a1
          AND ach.is_new = 1
          AND ach.ag_contract_header_id = ag.contract_id
          AND (SELECT ah.date_end
               FROM ins.ven_ag_roll_header ah
               WHERE ah.num = LPAD((SELECT r.param_value
                                    FROM ins_dwh.rep_param r
                                    WHERE r.rep_name = 'vol_chk'
                                      AND r.param_name = 'num_ved'),6,'0')) BETWEEN ag.date_begin AND ag.date_end
          AND ag.ag_sales_chn_id = chac.id(+)) ach_new,
       ins.department dep,
       ins.contact cn,
       ins.t_sales_channel ts
 WHERE 1=1
   AND arh.ag_roll_header_id = (SELECT arhi.ag_roll_header_id
                                FROM ins.Ven_Ag_Roll_Header arhi
                                WHERE arhi.num = LPAD((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                  WHERE r.rep_name = 'vol_chk'
                                                    AND r.param_name = 'num_ved'),6,'0')
                               )
   AND ar.num = nvl( (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'vol_chk'
                      AND r.param_name = 'ver_ved') ,
                     ar.num)
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND agv.ag_contract_header_id = ach_new.ag_contract_header_id (+)
   AND agv.ag_roll_id = ar.ag_roll_id -- 23834829
   AND agv.ag_volume_id   = anv.ag_volume_id
   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
   AND avt.brief IN ('BANK')
   AND agv.ag_contract_header_id = ach_new.ag_contract_header_id
   AND dep.department_id (+) = ach_new.agency_id
   AND ach_new.agent_id = cn.contact_id (+)
   AND ach_new.t_sales_channel_id = ts.id  (+)
;

