CREATE OR REPLACE VIEW V_COMMISSION_CHECK_OAV AS
SELECT ar.num vedom,
       art.NAME prem_type,
       dep.NAME agency,
       ts.DESCRIPTION sales_ch,
       ach.num ad,
       aca.category_name,
       cn.obj_name_orig agent_fio,
       tct.DESCRIPTION leg_entity,
       avt.DESCRIPTION volume_TYPE,
       apw.ag_level,
       apw.volumes.get_volume(1) rl_vol,
       apw.volumes.get_volume(41) bank_vol,
       apw.volumes.get_volume(6) inv_vol,
       apw.volumes.get_volume(2) ops_vol,
       apw.volumes.get_volume(8) ops2_vol,
       apw.volumes.get_volume(3) sofi_vol,
       apw.volumes.get_volume(5) sofi_pay_vol,
       apw.volumes.get_volume(101) fdep_vol,
       apw.ag_ksp ksp,
       apw.sgp1 act_volume_amt,
       apw.SUM act_commission,
       ph.Ids IDS,
       pp.pol_num policy_num,
       tp.DESCRIPTION product,
       cn_ins.obj_name_orig Insuer,
       NULL gender,
       NULL date_of_birth,
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
       apv.vol_amount detail_vol_amt,
       apv.vol_rate detail_vol_rate,
       apv.vol_amount*apv.vol_rate detail_commis
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume agv,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.department dep,
       ins.t_contact_type tct,
       ins.contact cn,
       ins.contact cn_ins,
       ins.p_pol_header ph,
       ins.p_policy pp,
       ins.t_product tp,
       ins.t_payment_terms pt,
       ins.fund f,
       ins.ac_payment_templ acpt,
       ins.document epg,
       ins.document pd,
       ins.trans t,
       ins.t_collection_method cm,
       ins.t_prod_line_option tplo
 WHERE 1=1
   AND arh.ag_roll_header_id = (SELECT arhi.ag_roll_header_id
                                FROM ins.Ven_Ag_Roll_Header arhi
                                WHERE arhi.num = LPAD((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                  WHERE r.rep_name = 'com_chk_oav'
                                                    AND r.param_name = 'num_ved'),6,'0'))
   AND ar.num = nvl( (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'com_chk_oav'
                      AND r.param_name = 'ver_ved') ,
                      ar.num)
   AND ar.ag_roll_id = apw.ag_roll_id
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND art.ag_rate_type_id = apd.ag_rate_type_id
   AND apv.ag_volume_id = agv.ag_volume_id
   AND tct.ID = ac.leg_pos
   AND ac.contract_id = ach.ag_contract_header_id
   AND ts.ID (+) = ac.ag_sales_chn_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.category_id = aca.ag_category_agent_id
   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
   AND avt.brief IN ('RL','INV','FDep')
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND dep.department_id(+) = ac.agency_id
   AND ach.agent_id = cn.contact_id
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
UNION ALL
SELECT ar.num vedom,
       art.NAME prem_type,
       dep.NAME agency,
       ts.DESCRIPTION sales_ch,
       ach.num ad,
       aca.category_name,
       cn.obj_name_orig agent_fio,
       tct.DESCRIPTION leg_entity,
       avt.DESCRIPTION volume_TYPE,
       apw.ag_level,
       apw.volumes.get_volume(1) rl_vol,
       apw.volumes.get_volume(41) bank_vol,
       apw.volumes.get_volume(6) inv_vol,
       apw.volumes.get_volume(2) ops_vol,
       apw.volumes.get_volume(8) ops2_vol,
       apw.volumes.get_volume(3) sofi_vol,
       apw.volumes.get_volume(5) sofi_pay_vol,
       apw.volumes.get_volume(101) fdep_vol,
       apw.ag_ksp ksp,
       apw.sgp1 act_volume_amt,
       apw.SUM act_commission,
       NULL,
       anv.snils,
       null,--tp.DESCRIPTION product,
       anv.fio,--cn_ins.obj_name_orig Insuer,
       anv.gender,
       anv.assured_birf_date, --agv.date_begin policy_begin,
       anv.sign_date,
       null, --agv.ins_period insurance_term,
       null,--ent.obj_name('DOC_STATUS_REF',agv.last_status) last_status,
       null, --ent.obj_name('DOC_STATUS_REF',agv.active_status) active_status,
       NULL, --pt.DESCRIPTION payment_term,
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
       CASE WHEN art.brief = 'EXTRA_SAV_OPS'
         THEN apv.vol_rate
         ELSE apv.vol_amount
       END detail_vol_amt,
       /*apv.vol_amount detail_vol_amt,*/
       CASE WHEN art.brief = 'EXTRA_SAV_OPS'
         THEN apv.vol_amount
         ELSE apv.vol_rate
       END detail_vol_rate,
       /*apv.vol_rate detail_vol_rate,*/
       apv.vol_rate* apv.vol_amount
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume agv,
       ins.ag_volume_type avt,
       ins.ag_npf_volume_det anv,
       ins.ven_ag_contract_header ach,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.department dep,
       ins.contact cn,
       ins.t_contact_type tct
 WHERE 1=1
   AND arh.ag_roll_header_id = (SELECT arhi.ag_roll_header_id
                                FROM ins.Ven_Ag_Roll_Header arhi
                                WHERE arhi.num = LPAD((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                  WHERE r.rep_name = 'com_chk_oav'
                                                    AND r.param_name = 'num_ved'),6,'0'))
   AND ar.num = nvl( (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'com_chk_oav'
                      AND r.param_name = 'ver_ved') ,
                      ar.num)
   AND ar.ag_roll_id = apw.ag_roll_id
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND art.ag_rate_type_id = apd.ag_rate_type_id
   AND apv.ag_volume_id = agv.ag_volume_id
   AND agv.ag_volume_id (+)  = anv.ag_volume_id
   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
   AND avt.brief IN ('NPF','NPF02','AVCP','SOFI','NPF(MARK9)')
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND ac.contract_id = ach.ag_contract_header_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.category_id = aca.ag_category_agent_id
   AND dep.department_id = ac.agency_id
   AND ach.agent_id = cn.contact_id
   AND tct.ID = ac.leg_pos
   AND ac.ag_sales_chn_id = ts.ID (+)
UNION ALL
SELECT ar.num vedom,
       art.NAME prem_type,
       dep.NAME agency,
       ts.DESCRIPTION sales_ch,
       ach.num ad,
       aca.category_name,
       cn.obj_name_orig agent_fio,
       tct.DESCRIPTION leg_entity,
       avt.DESCRIPTION volume_TYPE,
       apw.ag_level,
       apw.volumes.get_volume(1) rl_vol,
       apw.volumes.get_volume(41) bank_vol,
       apw.volumes.get_volume(6) inv_vol,
       apw.volumes.get_volume(2) ops_vol,
       apw.volumes.get_volume(8) ops2_vol,
       apw.volumes.get_volume(3) sofi_vol,
       apw.volumes.get_volume(5) sofi_pay_vol,
       apw.volumes.get_volume(101) fdep_vol,
       apw.ag_ksp ksp,
       apw.sgp1 act_volume_amt,
       apw.SUM act_commission,
       NULL,
       anv.policy_num,
       null,--tp.DESCRIPTION product,
       anv.fio,--cn_ins.obj_name_orig Insuer,
       anv.gender,
       anv.assured_birf_date, --agv.date_begin policy_begin,
       anv.sign_date,
       null, --agv.ins_period insurance_term,
       null,--ent.obj_name('DOC_STATUS_REF',agv.last_status) last_status,
       null, --ent.obj_name('DOC_STATUS_REF',agv.active_status) active_status,
       NULL, --pt.DESCRIPTION payment_term,
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
       apv.vol_amount detail_vol_amt,
       apv.vol_rate detail_vol_rate,
       apv.vol_rate* apv.vol_amount
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_perfomed_work_act apw,
       ins.ag_perfom_work_det apd,
       ins.ag_rate_type art,
       ins.ag_perf_work_vol apv,
       ins.ag_volume agv,
       ins.ag_volume_type avt,
       ins.ag_trast_volume_det anv,
       ins.ven_ag_contract_header ach,
       ins.t_sales_channel ts,
       ins.ag_contract ac,
       ins.ag_category_agent aca,
       ins.department dep,
       ins.contact cn,
       ins.t_contact_type tct
 WHERE 1=1
   AND arh.ag_roll_header_id = (SELECT arhi.ag_roll_header_id
                                FROM ins.Ven_Ag_Roll_Header arhi
                                WHERE arhi.num = LPAD((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                  WHERE r.rep_name = 'com_chk_oav'
                                                    AND r.param_name = 'num_ved'),6,'0'))
   AND ar.num = nvl( (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'com_chk_oav'
                      AND r.param_name = 'ver_ved') ,
                      ar.num)
   AND ar.ag_roll_id = apw.ag_roll_id
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND apw.ag_perfomed_work_act_id = apd.ag_perfomed_work_act_id
   AND apd.ag_perfom_work_det_id = apv.ag_perfom_work_det_id
   AND art.ag_rate_type_id = apd.ag_rate_type_id
   AND apv.ag_volume_id = agv.ag_volume_id
   AND agv.ag_volume_id = anv.ag_volume_id
   AND agv.ag_volume_type_id  = avt.ag_volume_type_id
   AND avt.brief IN ('BANK')
   AND apw.ag_contract_header_id = ach.ag_contract_header_id
   AND ac.contract_id = ach.ag_contract_header_id
   AND arh.date_end BETWEEN ac.date_begin AND ac.date_end
   AND ac.category_id = aca.ag_category_agent_id
   AND dep.department_id = ac.agency_id
   AND ach.agent_id = cn.contact_id
   AND tct.ID = ac.leg_pos
   AND ac.ag_sales_chn_id = ts.ID (+);
