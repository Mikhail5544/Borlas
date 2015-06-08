CREATE OR REPLACE VIEW V_C_CLAIM AS
SELECT ch.c_claim_header_id, ch.p_policy_id, ch.c_event_id,
          cd.declarant_role_id, --Чирков 160064 добавил
          cd.declarant_id, --Чирков 160064 добавил
          --ch.declarant_id, 
          --ch.declarant_role_id,             
          ch.depart_id, ch.curator_id,
          ch.as_asset_id, ch.fund_id, ch.notice_date, ch.notice_type_id,
          ch.declare_date, ch.is_regress, ch.is_criminal, ch.p_cover_id,
          ch.payment_term_id, ch.first_payment_date, ch.rate_on_date_id,
          ch.fund_pay_id, ch.deductible_value, ch.num, cc.doc_folder_id,
          cc.doc_templ_id, cc.note, cc.reg_date, cc.seqno, cc.declare_sum,
          cc.claim_status_id, cc.asset_of_victim, cc.compensate_damage_sum,
          cc.account_payment, cc.beneficiary_sum, cc.damage_payment_sum,
          cc.payment_sum, cc.interpayment_sum, cc.additional_expenses_sum,
          cc.additional_expenses_own_sum, cc.additional_expenses_noown_sum,
          cc.claim_status_date, cc.c_claim_id, ch.active_claim_id,
          ent.obj_name ('C_CLAIM_STATUS',
                        cc.claim_status_id
                       ) claim_status_name,
          ent.obj_name ('CN_PERSON', cec.cn_person_id) declarant_name,
          ent.obj_name ('C_DECLARANT_ROLE',
                        --ch.declarant_role_id --Чирков 160064 комментарий
                        cd.declarant_role_id   --Чирков 160064 добавил 
                       ) declarant_role_name,
          ent.obj_name ('DEPARTMENT', ch.depart_id) dep_name,
          ent.obj_name (per.ent_id, per.contact_id) curator_name,
          pl.description product_line_name,
          pkg_claim_payment.get_claim_payment_sum
                                               (cc.c_claim_id)
                                                              all_payment_sum,
          f.brief fund_brief
     FROM ven_c_claim cc,
          ven_c_event_contact cec,
          c_declarants cd,--Чирков 160064 добавил
          ven_c_claim_header ch,
          ven_cn_person per,
          p_cover p,
          t_prod_line_option plo,
          t_product_line pl,
          fund f
    WHERE ch.c_claim_header_id = cc.c_claim_header_id
      and ch.c_claim_header_id = cd.c_claim_header_id
      and cec.c_event_contact_id(+) = cd.declarant_id  
      and cd.c_declarants_id = (select max(cd_1.c_declarants_id) --Чирков 160064 добавил
                               from c_declarants cd_1
                               where cd_1.c_claim_header_id = cd.c_claim_header_id) 
      --AND ch.declarant_id = cec.c_event_contact_id(+) --Чирков 160064 комментарий
      AND ch.curator_id = per.contact_id(+) --Чирков 207619 изменил на left join 
      AND p.p_cover_id(+) = ch.p_cover_id
      AND p.t_prod_line_option_id = plo.ID(+)
      AND plo.product_line_id = pl.ID(+)
      AND f.fund_id(+) = ch.fund_id;
