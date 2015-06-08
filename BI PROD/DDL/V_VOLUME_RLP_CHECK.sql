CREATE OR REPLACE VIEW INS.V_VOLUME_RLP_CHECK AS
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
       rf_ph.name last_status,
       rf_pp.name active_status,
       pt.DESCRIPTION payment_term,
       f.NAME fund,
       epg.num epg_num,
       agv.epg_date,
       agv.pay_period pay_year,
       agv.epg_ammount,
       rf_epg.name epg_status,
       ins.ent.obj_name('DOC_STATUS_REF',agv.pd_copy_status) pd_copy_status,
       acpt.title pd_type,
       pd.num pd_num,
       cm.DESCRIPTION collect_method,
       agv.payment_date,
       agv.vol_sav,
       agv.nbv_coef,
       agv.is_nbv,
       avt.DESCRIPTION volume_type
  from ins.ven_ag_roll ar,
       ins.ven_ag_roll_header arh,
       ins.ag_volume_rlp agv,
       ins.ag_volume_type avt,
       ins.ven_ag_contract_header ach_new,
       ins.department dep,
       ins.contact cn,
       ins.t_sales_channel ts,
       ins.p_pol_header ph,
       ins.document d_ph,
       ins.doc_status_ref rf_ph,
       ins.p_policy pp,
       ins.document d_pp,
       ins.doc_status_ref rf_pp,
       ins.contact cn_ins,
       ins.t_payment_terms pt,
       ins.document epg,
       ins.doc_status_ref rf_epg,
       ins.fund f,
       ins.document pd,
       ins.ac_payment_templ acpt,
       ins.t_collection_method cm,
       ins.t_product tp
 WHERE 1=1
   AND arh.ag_roll_header_id = (SELECT arhi.ag_roll_header_id
                                FROM ins.Ven_Ag_Roll_Header arhi
                                WHERE arhi.num = LPAD((SELECT r.param_value
                                                  FROM ins_dwh.rep_param r
                                                  WHERE r.rep_name = 'vol_rlp_chk'
                                                    AND r.param_name = 'num_ved'),6,'0')
                               )
   AND ar.num = nvl( (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'vol_rlp_chk'
                      AND r.param_name = 'ver_ved') ,
                      ar.num)
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND agv.ag_contract_header_id = ach_new.ag_contract_header_id
   AND agv.ag_roll_id = ar.ag_roll_id
   AND avt.ag_volume_type_id = agv.ag_volume_type_id
   AND ach_new.agent_id = cn.contact_id
   AND ph.last_ver_id = d_ph.document_id
   AND d_ph.doc_status_ref_id = rf_ph.doc_status_ref_id
   AND pp.policy_id = d_pp.document_id
   AND d_pp.doc_status_ref_id = rf_pp.doc_status_ref_id
   AND ach_new.agency_id = dep.department_id
   AND ach_new.t_sales_channel_id = ts.ID
   AND epg.doc_status_ref_id = rf_epg.doc_status_ref_id
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
   AND NVL(agv.is_future,0) = 0;

grant select on INS.V_VOLUME_RLP_CHECK to INS_READ;
grant select on INS.V_VOLUME_RLP_CHECK to INS_EUL;
