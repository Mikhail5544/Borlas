CREATE OR REPLACE VIEW INS.V_GATE_POLICY AS
SELECT ph.policy_header_id,
       pp.policy_id,
       pp.Notice_Num,
       tat.DESCRIPTION addendum_type,
       pp.pol_num,
       ph.product_id,
       pp.Notice_Date,
       ph.start_date,
       ppa.ag_contract_header_id pol_agent_ch,
       ins.doc.get_doc_status_name(ppa.p_policy_agent_doc_id) pol_agent_status,
       ppa.date_begin pol_agent_date_start,
       ppa.date_end pol_agent_date_end,
       (SELECT SUM(pc.fee)
         FROM as_asset ass,
              p_cover pc
        WHERE ass.p_policy_id = pp.policy_id
          AND pc.as_asset_id = ass.as_asset_id
          AND pc.status_hist_id <> 3) fee,
       pt.description as payment_term_name
      ,(SELECT SUM(pc.fee*decode(tplo.description, 'Административные издержки',1, pt.number_of_payments))
         FROM as_asset ass,
              p_cover pc,
              t_prod_line_option tplo
        WHERE ass.p_policy_id = pp.policy_id
          AND pc.as_asset_id = ass.as_asset_id
          AND pc.status_hist_id <> 3
          AND tplo.ID = pc.t_prod_line_option_id) ape,
       f.brief,
       cn.contact_id,
       cn.obj_name_orig asset_fio,
       cnp.date_of_birth asset_dob,
       decode(cnp.gender,1,'Male','Female') asset_gender,
       (SELECT wmsys.wm_concat(ca.address_type_name||' : '||ca.address_name)
         FROM v_cn_contact_address ca
        WHERE ca.contact_id = cn.contact_id) asset_address,
       cn2.obj_name_orig assured_fio,
       cnp2.date_of_birth assured_dob,
       decode(cnp2.gender,1,'Male','Female') assured_gender,
       (SELECT wmsys.wm_concat(ca.address_type_name||' : '||ca.address_name)
         FROM v_cn_contact_address ca
        WHERE ca.contact_id = cn2.contact_id) assured_address,
       (SELECT wmsys.wm_concat(cp.telephone_prefix||' '||cp.telephone_number)
         FROM cn_contact_telephone cp
        WHERE cp.contact_id = cn2.contact_id) assured_phone
  FROM ins.p_policy pp,
       ins.p_pol_addendum_type pat,
       ins.t_addendum_type tat,
       ins.p_pol_header ph,
       ins.p_policy_agent_doc ppa,
       ins.t_payment_terms pt,
       ins.contact cn,
       ins.cn_person cnp,
       ins.contact cn2,
       ins.cn_person cnp2,
       INs.ven_as_assured ass1,
       ins.fund f
 WHERE pp.pol_header_id = ph.policy_header_id
   AND pp.payment_term_id = pt.ID
   AND pat.p_policy_id (+) = pp.policy_id
   AND pat.t_addendum_type_id = tat.t_addendum_type_id (+)
   AND ppa.policy_header_id = ph.policy_header_id
   AND pp.policy_id = ass1.p_policy_id
   AND ass1.assured_contact_id = cn.contact_id
   AND cnp.contact_id (+)  = cn.contact_id
   AND cnp2.contact_id (+) = cn2.contact_id
   AND pkg_policy.get_policy_contact(pp.policy_id,'Страхователь') = cn2.contact_id
   AND f.fund_id = ph.fund_id;
