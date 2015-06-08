CREATE OR REPLACE VIEW INS.V_AV_RLP_CHECK AS
SELECT ar.num vedom,
       art.NAME prem_type,
       dep.NAME agency,
       ts.DESCRIPTION sales_ch,
       ach.num ad,
       aca.category_name,
       cn.obj_name_orig agent_fio,
       tct.DESCRIPTION leg_entity,
       avt.DESCRIPTION volume_TYPE,
       apw.SUM act_commission,
       ph.Ids IDS,
       pp.pol_num policy_num,
       tp.DESCRIPTION product,
       cn_ins.obj_name_orig Insuer,
       NULL gender,
       NULL date_of_birth,
       agv.date_begin policy_begin,
       agv.ins_period insurance_term,
       rf_ph.name last_status,
       rf_pp.name active_status,
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
       agv.nbv_coef,
       NVL(apv.vol_amount,0) detail_vol_amt,
       NVL(apv.vol_rate,0) detail_vol_rate,
       NVL(apv.vol_av,0) detail_commis,
       NVL(apv.vol_sav,0) vol_sav,
       NVL(apv.av_need,0) av_need,
       NVL(apv.rate_need,0) rate_need,
       NVL(apv.vol_av,0) - NVL(apv.vol_sav,0) vol_av,
       NVL(apv.last_vol_av,0) commiss_last,
       CASE WHEN apv.av_need IS NULL THEN NULL ELSE NVL(apv.vol_av,0) - NVL(apv.vol_sav,0) - NVL(apv.last_vol_av,0) END AVcommon,
       CASE WHEN apv.av_need IS NULL THEN NULL ELSE apv.cross_rate END cross_rate
  FROM ins.ven_ag_roll_header arh,
       ins.ven_ag_roll ar,
       ins.ag_act_rlp apw,
       ins.ag_work_det_rlp apd,
       ins.ag_rate_type art,
       ins.ag_vol_rlp apv,
       ins.ag_volume_rlp agv,
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
       ins.document d_ph,
       ins.doc_status_ref rf_ph,
       ins.p_policy pp,
       ins.document d_pp,
       ins.doc_status_ref rf_pp,
       ins.t_product tp,
       ins.t_payment_terms pt,
       ins.fund f,
       ins.ac_payment_templ acpt,
       ins.document epg,
       ins.document pd,
       ins.t_collection_method cm
 WHERE 1=1
   AND arh.ag_roll_header_id = (SELECT arhi.ag_roll_header_id
                                FROM ins.Ven_Ag_Roll_Header arhi
                                WHERE arhi.num = LPAD((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                  WHERE r.rep_name = 'av_rlp_chk'
                                                    AND r.param_name = 'num_ved'),6,'0')
                               )
   AND ar.num = nvl( (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'av_rlp_chk'
                      AND r.param_name = 'ver_ved') ,
                      ar.num)
   AND ar.ag_roll_id = apw.ag_roll_id
   AND arh.ag_roll_header_id = ar.ag_roll_header_id
   AND apw.ag_act_rlp_id = apd.ag_act_rlp_id
   AND apd.ag_work_det_rlp_id = apv.ag_work_det_rlp_id
   AND art.ag_rate_type_id = apd.ag_rate_type_id
   AND apv.ag_volume_rlp_id = agv.ag_volume_rlp_id
   AND tct.ID = ac.leg_pos
   AND ac.contract_id = ach.ag_contract_header_id
   AND ts.ID(+) = ac.ag_sales_chn_id
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
   AND tp.product_id = ph.product_id
   AND ph.last_ver_id = d_ph.document_id
   AND d_ph.doc_status_ref_id = rf_ph.doc_status_ref_id
   AND pp.policy_id = d_pp.document_id
   AND d_pp.doc_status_ref_id = rf_pp.doc_status_ref_id
   AND NVL(agv.is_future,0) = 0;
