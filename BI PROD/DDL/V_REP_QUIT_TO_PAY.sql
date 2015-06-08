CREATE OR REPLACE VIEW V_REP_QUIT_TO_PAY AS
SELECT /*+ index(ap PK_AC_PAYMENT) index(ccba PK_CN_CONTACT_BANK_ACC)*/
 ph.policy_header_id
 ,ph.ids AS "Договор IDS"
 ,p.pol_num AS "Номер договора"
 ,p.confirm_date AS "Дата вст дог в силу"
 ,vi.contact_name AS /*fio_ass*/ "Страхователь ФИО/наименование"
 ,vi.contact_id AS /*id_as*/ "Страхователь ID контакта"
 ,ct.description AS /*tip_ass*/ "Тип страх(физ.лицо/юр.лицо)"
 ,cp.obj_name_orig AS /*fio_p*/ "Получатель ФИО/наим"
 ,cp.contact_id AS "Получатель ID контакта"
 ,ctp.description AS /*tip_p*/ "Тип получ(физ.лицо/юр.лицо)"
 ,pc.description AS /*country_p*/ "Гражданство получателя"
-- ,decode(cp.resident_flag, 1, 'Да', 'Нет') AS /*resident_p*/ "Получатель Резидент?"
      ,decode((SELECT COUNT(*)
                FROM dual
               WHERE EXISTS (SELECT 1
                        FROM cn_contact_ident cci
                            ,t_id_type        it
                       WHERE cci.contact_id = cp.contact_id
                         AND cci.id_type = it.id
                         AND it.brief = 'PASS_RF'
                         AND cci.termination_date IS NULL))
             ,0
             ,NULL
             ,'Резидент') AS "Получатель Резидент?"
 ,vcp.date_of_birth AS /*birth_p*/ "Пасп.данные(дата рождения)"
 ,s.sum_redemption_sum AS "Выкупная сумма"
 ,s.sum_add_invest_income AS "Инвест. доход"
 ,s.sum_return_bonus_part AS "Возврат стр. премии"
 ,p.return_summ AS "Итого по договору"
 ,f.brief AS /*val*/ "Валюта договора"
 ,'Доверенность на получателя (при наличии)' AS /*proxy_p*/ "Доверенность на получателя"
 ,s.other_sum AS /*other*/ "Прочее"
 ,ins.pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_letters_address_id(cp.contact_id)
                                              ,'<#ADDRESS_FULL>') AS /*address_const_p*/ "Пасп.данные(адрес регистрации)"
 ,pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(cp.contact_id)
                                               ,'<#DOC_SERNUM>' || ' ' || '<#DOC_PLACE>' || ' ' ||
                                                '<#DOC_DATE>') AS "Паспортные данные"
 ,decode(pfp.profit_type, 0, 'ДИД', 1, 'ДСС') AS "ДИД/ДСС"
  FROM doc_status_ref dsr
      ,document v
      ,p_policy p
      ,p_pol_header ph
      ,v_pol_issuer vi
      ,contact c
      ,t_contact_type ct
      ,doc_doc dd
      ,ven_ac_payment ap
      ,doc_templ dt
      ,cn_contact_bank_acc ccba
      ,contact cp
      ,t_contact_type ctp
      ,cn_person t
      ,t_country pc
      ,cn_person vcp
      ,fund f
      ,(SELECT pd.p_policy_id AS policy_id
              ,nvl(pd.debt_fee_fact, 0) + nvl(pd.medo_cost, 0) + nvl(pd.overpayment, 0) AS other_sum
              ,SUM(pcd.redemption_sum) AS sum_redemption_sum
              ,SUM(pcd.add_invest_income) AS sum_add_invest_income
              ,SUM(pcd.return_bonus_part) AS sum_return_bonus_part
          FROM p_pol_decline   pd
              ,p_cover_decline pcd
         WHERE pcd.p_pol_decline_id = pd.p_pol_decline_id
         GROUP BY pd.p_policy_id
                 ,pd.debt_fee_fact
                 ,pd.medo_cost
                 ,pd.overpayment) s
      ,t_policyform_product pfp
 WHERE dsr.brief = 'QUIT_TO_PAY'
   AND v.doc_status_ref_id = dsr.doc_status_ref_id
   AND p.policy_id = v.document_id
   AND p.policy_id = ph.policy_id
   AND p.policy_id = vi.policy_id
   AND c.contact_id = vi.contact_id
   AND ct.id = c.contact_type_id
   AND dd.parent_id = p.policy_id
   AND ap.payment_id = dd.child_id
   AND ap.doc_templ_id = dt.doc_templ_id
   AND dt.brief = 'PAYREQ'
   AND ap.reg_date = (SELECT MAX(ap1.reg_date)
                        FROM doc_doc        dd1
                            ,ven_ac_payment ap1
                            ,doc_templ      dt1
                       WHERE dd1.parent_id = p.policy_id
                         AND ap1.payment_id = dd1.child_id
                         AND ap1.doc_templ_id = dt1.doc_templ_id
                         AND dt1.brief = 'PAYREQ')
   AND ccba.id = ap.contact_bank_acc_id
   AND cp.contact_id(+) = ccba.owner_contact_id
   AND ctp.id(+) = cp.contact_type_id
   AND t.contact_id(+) = cp.contact_id
   AND t.country_birth = pc.id(+)
   AND vcp.contact_id(+) = cp.contact_id
   AND ph.fund_id = f.fund_id
   AND s.policy_id = p.policy_id
   AND pfp.t_policyform_product_id = p.t_product_conds_id
;
