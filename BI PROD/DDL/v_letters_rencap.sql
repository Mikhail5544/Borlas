CREATE OR REPLACE VIEW ins.v_letters_rencap AS
SeleCT ph.policy_header_id pol_header_id,
       pol.policy_id document_id,
       cpol.obj_name_orig contact_name,
       pol.pol_ser,
       pol.pol_num num,
       ph.ids policy_number,
       f.brief currency_brief,
       pol.decline_date,
       ph.start_date pol_start_date,
       t.brief payment_period,
       NULL grace_date,
       pol.start_date due_date,
       NULL amount,
       NULL pay_amount,
       cpol.contact_id,
       NULL doc_status_ref_id,
       NULL doc_status_ref_name,
       pol.return_summ,
       NVL(ca_post.name, pkg_contact.get_address_name(ca_post.id)) address_name,
       (case when ca_post.street_name is not null then NVL(ca_post.street_type,'ул')||'.'||ca_post.street_name else '' end ||
       case when ca_post.house_nr is not null then ',д.'||ca_post.house_nr else '' end ||
       case when ca_post.block_number is not null then ','||ca_post.block_number else '' end ||
       case when ca_post.appartment_nr is not null then ',кв.'||ca_post.appartment_nr else '' end) fadr,
       (case when ca_post.city_name is not null then 'г.'||ca_post.city_name else '' end) city_name,
       (case when ca_post.region_name is not null then ca_post.region_name||' '||ca_post.region_type else '' end) region_name,
       (case when ca_post.province_name is not null then ca_post.province_name||' '||ca_post.province_type else '' end) province_name,
       (case when ca_post.district_name is not null then ca_post.district_type||' '||ca_post.district_name else '' end) distr_name,
       (select distinct tc.description from t_country tc where tc.id = ca_post.country_id) country_name,
       ca_post.zip,
       (select acc.account_nr
        from ins.cn_contact_bank_acc acc
            ,ins.cn_document_bank_acc dac
            ,ins.document d
            ,ins.doc_status_ref rf
        where dac.cn_contact_bank_acc_id = acc.id
          and acc.used_flag = 1
          and dac.cn_document_bank_acc_id = d.document_id
          and d.doc_status_ref_id = rf.doc_status_ref_id
          and rf.brief = 'ACTIVE'
          and rownum = 1
          and acc.contact_id = cpol.contact_id
        ) account_nr
from ins.p_pol_header ph
    ,ins.t_product prod
    ,ins.p_policy pol
    ,ins.t_decline_reason t
    ,ins.p_policy_contact pcnt
    ,ins.contact cpol
    ,ins.fund f
    ,ins.cn_address ca_post
    ,ins.cn_contact_address cca_post
where ph.product_id = prod.product_id
  and prod.brief IN ('RenCap_GP#1','RenCap_GP#2','RenCap_IL#1.1','RenCap_IL#1.2','RenCap_IL#2.1','RenCap_IL#2.2')
  and pol.pol_header_id = ph.policy_header_id
  and pol.decline_reason_id = t.t_decline_reason_id
  AND t.brief = 'Заявление клиента'
  and f.fund_id = ph.fund_id
  and exists (select NULL
              from ins.doc_status ds
                  ,ins.doc_status_ref rf
              where ds.document_id = pol.policy_id
                and ds.doc_status_ref_id = rf.doc_status_ref_id
                and rf.brief = 'QUIT_TO_PAY'
                and ds.start_date between ins.pkg_notification_letters_fmb.get_date_from and ins.pkg_notification_letters_fmb.get_date_to
              )
  and pol.policy_id = pcnt.policy_id
  and pcnt.contact_policy_role_id = 6
  and pcnt.contact_id = cpol.contact_id
  AND NVL(pkg_contact.get_address_by_brief(cpol.contact_id,'POSTAL'),pkg_contact.get_address_by_brief(cpol.contact_id,'CONST')) = ca_post.ID(+)
  and ca_post.id = cca_post.adress_id(+)
  and cca_post.status(+) = 1;

GRANT SELECT ON ins.v_letters_rencap TO INS_READ;
