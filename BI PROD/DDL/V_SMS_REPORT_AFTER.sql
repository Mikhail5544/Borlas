CREATE OR REPLACE VIEW V_SMS_REPORT_AFTER AS
SELECT prod_name
      ,contact_name
      ,init_name
      ,pol_ser
      ,pol_num
      ,ids
      ,num
      ,due_date
      ,grace_date
      ,plan_date
      ,fee
      ,s1 zacht
      ,(nvl(child_amount, 0) - nvl(set_off_amount, 0)) to_pay
      ,fee - s1 sum_fee
      ,CASE
         WHEN (nvl(child_amount, 0) - nvl(set_off_amount, 0)) > fee THEN
          (nvl(child_amount, 0) - nvl(set_off_amount, 0)) - (fee - s1)
         ELSE
          0
       END amount
      ,cur_brief
      ,DESCRIPTION
      ,pol_status
      ,NAME
      ,tel
      ,tel_1
      ,tel_2
      ,tel_status
      ,tel_1_status
      ,tel_2_status
      ,coll_method
      ,paym_term_desc
      ,

       CASE
         WHEN coll_method = 'Прямое списание с карты' THEN
          'Уважаемый клиент, сообщаем Вам о том, что оплата очередного взноса по договору страхования №' ||
          TRIM(to_char(ids)) || ' на сумму ' || TRIM(to_char(fee - s1, '99999990D99')) || ' ' ||
          cur_brief ||
          ' путем списания с Вашей банковской карты не прошла авторизацию в банке-эмитенте. Просим Вас обеспечить наличие денежных средств на Вашей карте или оплатить взнос любым иным способом до ' ||
          to_char(grace_date, 'dd.mm.yyyy') || '.' || ' Ренессанс Жизнь, (495) 981-2-981'
         ELSE

          CASE
            WHEN (CASE
                   WHEN (nvl(child_amount, 0) - nvl(set_off_amount, 0)) > fee THEN
                    (nvl(child_amount, 0) - nvl(set_off_amount, 0)) - (fee - s1)
                   ELSE
                    0
                 END) = 0 THEN
             'Уважаемый клиент, если Вы еще не внесли очередной платеж по договору страхования №' ||
             TRIM(to_char(ids)) || ', напоминаем, что Ваш платеж составляет ' ||
             TRIM(to_char(fee - s1, '99999990D99')) || ' ' || cur_brief || ', дата платежа ' ||
             to_char(grace_date, 'dd.mm.yyyy') || (CASE
               WHEN (cur_brief = 'RUR' AND nvl(fee - s1, 0) <= 15000)
                    OR (cur_brief = 'EUR' AND nvl(fee - s1, 0) <= 5000)
                    OR (cur_brief = 'USD' AND nvl(fee - s1, 0) <= 5000) THEN
                ' Оплатить взнос можно через ВТБ 24.'
               ELSE
                ''
             END) || ' Ренессанс Жизнь, (495) 981-2-981'
            ELSE
             'Уважаемый клиент, если Вы еще не внесли очередной платеж по договору страхования №' ||
             TRIM(to_char(ids)) || ', напоминаем, что Ваш платеж составляет ' ||
             TRIM(to_char(fee - s1, '99999990D99')) || ' ' || cur_brief ||
             ', сумма задолженности составляет ' ||
             TRIM(to_char(CASE
                            WHEN (nvl(child_amount, 0) - nvl(set_off_amount, 0)) > fee THEN
                             (nvl(child_amount, 0) - nvl(set_off_amount, 0)) - (fee - s1)
                            ELSE
                             0
                          END
                         ,'99999990D99')) || ' ' || cur_brief || ', дата платежа ' ||
             to_char(grace_date, 'dd.mm.yyyy') || (CASE
               WHEN (cur_brief = 'RUR' AND nvl(fee - s1, 0) <= 15000)
                    OR (cur_brief = 'EUR' AND nvl(fee - s1, 0) <= 5000)
                    OR (cur_brief = 'USD' AND nvl(fee - s1, 0) <= 5000) THEN
                ' Оплатить взнос можно через ВТБ 24.'
               ELSE
                ''
             END) || ' Ренессанс Жизнь, (495) 981-2-981'
          END

       END text_field
      ,contact_id
      ,'Исходящий' "Вид сообщения"
       ,'СМС ПОСЛЕ' "Тип сообщения"
       ,'Телефон' "Тип реквизита"
       ,'Отправлен' "Статус"
       ,'смс после-напоминание об оплате' "Тема сообщения"
       ,NULL "Дата регистрации"
       ,NULL "Номер реестра"
       ,NULL "Инициатор доставки"
       ,NULL "Порядковый номер"
       ,NULL "Комментарий"
       ,'15' || LPAD((SELECT TO_NUMBER(r.param_value)
                       FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'sms_after'
                        AND r.param_name = 'order_num') + ROWNUM - 1
                   ,6
                   ,'0') || '-' || TO_CHAR(SYSDATE, 'MM') || '/' || TO_CHAR(SYSDATE, 'YYYY') "Исходящий номер"
  FROM (SELECT cpol.obj_name_orig contact_name
              ,cpol.contact_id
              ,nvl(cpol.NAME, '') || ' ' || nvl(substr(cpol.first_name, 1, 1) || '.', '') ||
               nvl(substr(cpol.middle_name, 1, 1) || '.', '') init_name
              ,nvl(p.pol_ser, '-') pol_ser
              ,nvl(p.pol_num, '-') pol_num
              ,ph.ids
              ,a.num
              ,a.due_date
              ,a.grace_date
              ,a.plan_date
              ,(dd.parent_amount - (SELECT NVL(SUM(ir.invest_reserve_amount), 0)
                                      FROM ins.ac_payment_ir ir
                                     WHERE ir.ac_payment_id = a.payment_id)) fee
              ,(SELECT NVL(SUM(dd.child_amount -
                               (SELECT NVL(ir.invest_reserve_amount, 0)
                                  FROM ins.ac_payment_ir ir
                                 WHERE ir.ac_payment_id = ac.payment_id))
                          ,0)
                  FROM P_POLICY   p
                      ,ac_payment ac
                      ,DOC_DOC    dd
                      ,document   dac
                 WHERE ac.payment_id = dac.document_id
                   AND dac.doc_status_ref_id IN
                       (SELECT rf.doc_status_ref_id
                          FROM ins.doc_status_ref rf
                         WHERE rf.brief IN ('TO_PAY', 'NEW'))
                   AND ac.PAYMENT_ID = dd.CHILD_ID
                   AND p.POLICY_ID = dd.PARENT_ID
                   AND p.POL_HEADER_ID = ph.policy_header_id
                   AND ac.plan_date <= to_date((SELECT r.param_value
                                                 FROM ins_dwh.rep_param r
                                                WHERE r.rep_name = 'sms_after'
                                                  AND r.param_name = 'date_to')
                                              ,'dd.mm.yyyy') - 15

                   AND dac.DOC_TEMPL_ID IN
                       (SELECT dt.doc_templ_id FROM DOC_TEMPL dt WHERE dt.brief = 'PAYMENT')) child_amount
              ,(SELECT NVL(SUM((SELECT SUM(dsf.set_off_amount -
                                          (SELECT NVL(ir.invest_reserve_amount, 0)
                                             FROM ins.ac_payment_ir ir
                                            WHERE ir.ac_payment_id = ac.payment_id))
                                 FROM doc_set_off dsf
                                WHERE dsf.PARENT_DOC_ID(+) = ac.PAYMENT_ID
                                  AND Doc.get_last_doc_status_brief(dsf.doc_set_off_id) <> 'ANNULATED'))
                          ,0) set_off_amount
                  FROM P_POLICY   p
                      ,ac_payment ac
                      ,DOC_DOC    dd
                      ,document   dac
                 WHERE dac.document_id = ac.payment_id
                   AND dac.doc_status_ref_id IN
                       (SELECT rf.doc_status_ref_id
                          FROM ins.doc_status_ref rf
                         WHERE rf.brief IN ('TO_PAY', 'NEW'))
                   AND ac.PAYMENT_ID = dd.CHILD_ID
                   AND p.POLICY_ID = dd.PARENT_ID
                   AND p.POL_HEADER_ID = ph.policy_header_id
                   AND ac.plan_date <= to_date((SELECT r.param_value
                                                 FROM ins_dwh.rep_param r
                                                WHERE r.rep_name = 'sms_after'
                                                  AND r.param_name = 'date_to')
                                              ,'dd.mm.yyyy') - 15
                   AND dac.DOC_TEMPL_ID IN
                       (SELECT dt.doc_templ_id FROM DOC_TEMPL dt WHERE dt.brief = 'PAYMENT')) set_off_amount
              ,Pkg_Payment.get_set_off_amount(a.payment_id, ph.policy_header_id, NULL) -
               NVL(Pkg_Payment.get_set_off_amount_ir(a.payment_id, ph.policy_header_id, NULL), 0) s1
              ,fh.brief cur_brief
              ,pt.DESCRIPTION
              ,(SELECT rf.name
                  FROM ins.document       da
                      ,ins.doc_status_ref rf
                 WHERE da.document_id = pkg_policy.get_last_version(p.pol_header_id)
                   AND rf.doc_status_ref_id = da.doc_status_ref_id) pol_status
              ,dep.name
              ,PKG_CONTACT.GET_TELEPHONE_NUMBER(cpol.contact_id
                                               ,(SELECT tt.id
                                                  FROM t_telephone_type tt
                                                 WHERE tt.description = 'Мобильный')) tel
              ,PKG_CONTACT.GET_TELEPHONE_STATE(cpol.contact_id
                                              ,(SELECT tt.id
                                                 FROM t_telephone_type tt
                                                WHERE tt.description = 'Мобильный')) tel_status
              ,PKG_CONTACT.GET_TELEPHONE_NUMBER(cpol.contact_id
                                               ,(SELECT tt.id
                                                  FROM t_telephone_type tt
                                                 WHERE tt.description = 'Рабочий телефон')) tel_1
              ,PKG_CONTACT.GET_TELEPHONE_STATE(cpol.contact_id
                                              ,(SELECT tt.id
                                                 FROM t_telephone_type tt
                                                WHERE tt.description = 'Рабочий телефон')) tel_1_status
              ,PKG_CONTACT.GET_TELEPHONE_NUMBER(cpol.contact_id
                                               ,(SELECT tt.id
                                                  FROM t_telephone_type tt
                                                 WHERE tt.description = 'Домашний телефон')) tel_2
              ,PKG_CONTACT.GET_TELEPHONE_STATE(cpol.contact_id
                                              ,(SELECT tt.id
                                                 FROM t_telephone_type tt
                                                WHERE tt.description = 'Домашний телефон')) tel_2_status
              ,colm.description coll_method
              ,prod.description name_product
              ,p.end_date end_date_header
              ,prod.description prod_name
              ,pt.DESCRIPTION paym_term_desc
          FROM p_pol_header        ph
              ,fund                fh
              ,t_product           prod
              ,department          dep
              ,p_policy            p
              ,T_PAYMENT_TERMS     pt
              ,doc_doc             dd
              ,ven_ac_payment      a
              ,document            da
              ,fund                f
              ,ac_payment_templ    apt
              ,t_contact_type      tc
              ,t_contact_pol_role  polr
              ,p_policy_contact    pcnt
              ,contact             cpol
              ,t_collection_method colm
              ,t_sales_channel     ch
              ,ins.ven_p_policy    pp_av -- активная версия
              ,ins.doc_status_ref  dsr_av -- статус активной версии

         WHERE a.payment_templ_id = apt.payment_templ_id
           AND apt.brief = 'PAYMENT'
           AND a.payment_id = da.document_id
           AND da.doc_status_ref_id NOT IN
               (SELECT rf.doc_status_ref_id
                  FROM ins.doc_status_ref rf
                 WHERE rf.brief IN ('PAID', 'ANNULATED'))
           AND a.payment_id = dd.child_id
           AND dd.parent_id = p.policy_id
           AND ph.product_id = prod.product_id
           AND fh.fund_id = ph.fund_id
           AND p.pol_header_id = ph.policy_header_id
           AND ph.refuse_sms_send != 1 --Чирков 158544: Доработка - признак по договору "Отказ от услуг"
              --Чирков /192022 Доработка АС BI в части обеспечения регистрации
           AND NOT EXISTS
         (SELECT 1
                  FROM ins.ven_journal_tech_work jtw
                      ,ins.doc_status_ref        dsr
                 WHERE jtw.doc_status_ref_id = dsr.doc_status_ref_id
                   AND jtw.policy_header_id = ph.policy_header_id
                   AND dsr.brief = 'CURRENT'
                   AND jtw.work_type = 0) --'Технические работы'
              --Чирков /192022//
           AND pt.ID = p.PAYMENT_TERM_ID
           AND pt.DESCRIPTION NOT IN ('Единовременно')
           AND ph.agency_id = dep.department_id(+)
           AND p.collection_method_id = colm.id
           AND ch.id = ph.sales_channel_id
           AND colm.description NOT IN ('Перечисление средств Плательщиком'
                                       ,'Прямое списание с карты')
           AND (CASE
                 WHEN ch.description IN
                      ('Брокерский', 'Брокерский без скидки') THEN
                  (CASE
                    WHEN ph.start_date = a.plan_date THEN
                     0
                    ELSE
                     1
                  END)
                 ELSE
                  1
               END) = 1
           AND ch.description IN ('SAS'
                                 ,'SAS 2'
                                 ,'DSF'
                                 ,'Брокерский'
                                 ,'Брокерский без скидки'
                                 ,'Банковский')
           AND NOT EXISTS
         (SELECT NULL
                  FROM doc_set_off    f
                      ,ven_ac_payment acp
                      ,doc_templ      dtt
                 WHERE f.parent_doc_id = a.payment_id
                   AND acp.doc_templ_id = dtt.doc_templ_id
                   AND dtt.brief IN
                       ('PAYORDBACK', 'PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
                   AND f.child_doc_id = acp.payment_id)
           AND ((tc.description = 'Физическое лицо' AND EXISTS
                (SELECT NULL
                    FROM ins.cn_person per
                   WHERE per.contact_id = cpol.contact_id
                     AND per.date_of_death IS NULL)) OR tc.description != 'Физическое лицо')
           AND polr.brief = 'Страхователь'
           AND pcnt.policy_id = p.policy_id
           AND pcnt.contact_policy_role_id = polr.id
           AND cpol.contact_id = pcnt.contact_id
           AND f.fund_id = a.fund_id
           --Заявка 283064: Изменения в Отчетах смс
           --Гаргонов Д.А.
           --Исключение статусов для последней версии.
           AND ph.policy_id = pp_av.policy_id
           AND pp_av.doc_status_ref_id = dsr_av.doc_status_ref_id
           AND dsr_av.brief NOT IN ('RECOVER_DENY'
                                   ,'RECOVER'
                                   ,'READY_TO_CANCEL'
                                   ,'STOPED'
                                   ,'CANCEL'
                                   ,'STOP'
                                   ,'BREAK'
                                   ,'QUIT_DECL'
                                   ,'TO_QUIT'
                                   ,'TO_QUIT_CHECK_READY'
                                   ,'TO_QUIT_CHECKED'
                                   ,'QUIT_REQ_QUERY'
                                   ,'QUIT_REQ_GET'
                                   ,'QUIT_TO_PAY'
                                   ,'QUIT'
                                   ,'RECOVER'
                                   ,'RECOVER_DENY')
           AND tc.id = cpol.contact_type_id
           --AND prod.brief != 'GN'
              /*and prod.brief in ('Baby_LA','Baby_LA2','Platinum_LA2','ACC_MLN','ACC_5000','RP4','RP-9','ERZ','Zabota','END','ACC','ACC_EXP',
              'ACC_EXP_NEW','ACC_EXP_NEW2','APG','CHI','Family_Dep','Fof_Prot','OPS_Plus','OPS_Plus_2','OPS_Plus_New','PEPR','TERM','LOD','PEPR_2','TERM_2','CHI_2','END_2','Investor','InvestorALFA',
              'INVESTOR_LUMP','INVESTOR_LUMP_OLD','Family_Dep_2011','SF_AVCR')*/
              /*заявка №179163*/
              /*and nvl(dep.name,'X') not in ('Екатеринбург','Екатеринбург Подразделение','Екатеринбург Подразделение 1','Екатеринбург Подразделение 2','Екатеринбург Подразделение 3')*/
              /**/
           AND NOT EXISTS
         (SELECT NULL FROM ven_c_claim_header ch WHERE ch.p_policy_id = p.policy_id)
           AND a.plan_date BETWEEN to_date((SELECT r.param_value
                                             FROM ins_dwh.rep_param r
                                            WHERE r.rep_name = 'sms_after'
                                              AND r.param_name = 'date_from')
                                          ,'dd.mm.yyyy') - 15
           AND to_date((SELECT r.param_value
                         FROM ins_dwh.rep_param r
                        WHERE r.rep_name = 'sms_after'
                          AND r.param_name = 'date_to')
                      ,'dd.mm.yyyy') - 15
           AND EXISTS (SELECT NULL
                  FROM ins.cn_contact_telephone telf
                 WHERE telf.contact_id = cpol.contact_id
                   AND telf.telephone_type IN
                       (SELECT tt.id
                          FROM ins.t_telephone_type tt
                         WHERE tt.description IN ('Мобильный'))
                   AND telf.status = 1
                   AND telf.control = 0)
        --and ph.policy_header_id in (3025262)
        --and ph.ids IN (1140355407,1140280511,1140551761)
        )
 WHERE (fee - s1) > (CASE cur_brief
         WHEN 'RUR' THEN
          300
         WHEN 'EUR' THEN
          10
         WHEN 'USD' THEN
          10
         ELSE
          300
       END)
   AND ((paym_term_desc = 'Ежемесячно' AND (CASE
         WHEN (nvl(child_amount, 0) - nvl(set_off_amount, 0)) > fee THEN
          (nvl(child_amount, 0) - nvl(set_off_amount, 0)) - (fee - s1)
         ELSE
          0
       END) < (fee - s1) * 2) OR paym_term_desc != 'Ежемесячно')
;
