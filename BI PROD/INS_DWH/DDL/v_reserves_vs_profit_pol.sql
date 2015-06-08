create or replace view ins_dwh.v_reserves_vs_profit_pol as
SELECT pp.policy_id
      ,pp.payment_term_id
      ,pp.region_id
      ,pp.pol_ser
      ,pp.pol_header_id
      ,pp.end_date
      ,pp.notice_num
      ,pp.pol_num
      ,pp.is_group_flag
      ,pp.fee_payment_term
      ,polc.contact_id
      ,cn_pol_holder.obj_name_orig
      ,cn_pol_holder_person.date_of_birth
      ,cn_pol_holder_person.date_of_death
      ,cn_pol_holder.obj_name
      ,tct.brief AS tct_brief
      ,cn_pol_holder_person.gender
      ,nvl(ins.doc.get_doc_status_name(pp.policy_id, ins_dwh.pkg_reserves_vs_profit.get_report_date)
          ,'Нет статуса на отчетную дату') AS pol_status_on_date
      ,pp.version_num
      ,pp.version_order_num
      ,cn_pol_holder.resident_flag AS is_insurer_resident
  FROM ins.p_policy         pp
      ,ins.p_policy_contact polc
      ,ins.contact          cn_pol_holder
      ,ins.cn_person        cn_pol_holder_person
      ,ins.t_contact_type   tct
      ,ins.p_pol_header     ph
      ,ins.t_product        pr
 WHERE pp.policy_id = polc.policy_id
   AND polc.contact_policy_role_id = 6 -- Страхователь
   AND polc.contact_id = cn_pol_holder.contact_id
   AND cn_pol_holder.contact_id = cn_pol_holder_person.contact_id(+)
   AND tct.id = cn_pol_holder.contact_type_id
   AND ph.policy_id = pp.policy_id
   AND ph.product_id = pr.product_id;
