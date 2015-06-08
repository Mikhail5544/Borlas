CREATE OR REPLACE VIEW V_UREG_UBITKI_SHORT AS
SELECT CASE
         WHEN p45 IN ('Передано на оплату'
                     ,'Закрыт'
                     ,'Отказано в выплате') THEN
          (CASE
            WHEN (amount > 0)
                 AND (nvl(paym, 0) - nvl(decl, 0)) * rate / amount > 0 THEN
             1
            ELSE
             0
          END)
         ELSE
          2
       END p51
      , --флаг
       p1
      , --№ претензии, открытой заново (Жизнь  / Не жизнь)
       p2
      , --№ дела
       p3
      , --№ полиса
       ids
      ,p4
      , --Тип полиса (корпоративный или индивидуальный)
       p5
      , --Название продукта
       p7
      , --Застрахованный
       p9
      , --Дата рождения
       p11
      , -- Агент
       p15
      , --Дата вступления договора в силу
       p16
      , --Дата получения уведомления--date_in_company
       nvl(p17, '01.01.1900') p17
      , --Дата получения всех документов--date_all_doc
       nvl(p20, '01.01.1900') p20
      , --Дата наступления страхового события--date_event
       nvl(p21, 0) p21
      , --Количество дней действия полиса до наступления СС
       p22
      , --Диагноз
       p23
      , --Перечень рисков, наступивших вследствие произошедшего события
       p24
      , --Лимит ответственности по  рискам
       p25
      , --Валюта
       CASE
         WHEN rate_ins_amount = 100 THEN
          rate_ins_amount
         WHEN p31 IS NULL THEN
          SUM((CASE
                WHEN amount > 0 THEN
                 ROUND(nvl(paym, 0) * rate / amount * 100, 1)
                ELSE
                 0
              END))
         ELSE
          0
       END p26
      , --% от СС суммы--ubitok_z
       CASE
         WHEN p31 IS NULL THEN
          SUM(ROUND((nvl(amount, 0)) * (CASE
                      WHEN amount > 0 THEN
                       ((nvl(paym, 0) - nvl(decl, 0)) * rate / amount)
                      ELSE
                       0
                    END)
                   ,2))
         ELSE
          0
       END p27
      , --Сумма предполагаемого страхового обеспечения по каждому риску  (без франшизы)
       nvl(p28_1, 0) p28_1
      , --Зарезервированная сумма предполагаемого страхового обеспечения по каждому риску
       --09.12.2011_Чирков Разработка отчетных форм.  изменил график оплаты
       CASE
         WHEN plan_date IS NULL THEN
          to_date('01.01.1900')
         WHEN pl_description IN ('Защита страховых взносов'
                                ,'Защита страховых взносов рассчитанная по основной программе'
                                ,'Освобождение от уплаты взносов рассчитанное по основной программе'
                                ,'Освобождение от уплаты дальнейших взносов'
                                ,'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе'
                                ,'Освобождение от уплаты страховых взносов')

          THEN
          ADD_MONTHS(plan_date
                    ,term_number_of_payments * CASE
                       WHEN interval_num >= 0 THEN
                        interval_num
                       ELSE
                        NULL
                     END)
         WHEN prod_brief IN ('OPS_Plus', 'OPS_Plus_2', 'OPS_Plus_New') THEN
          trunc(ADD_MONTHS(plan_date
                          ,1 * CASE
                             WHEN interval_num >= 0 THEN
                              interval_num
                             ELSE
                              NULL
                           END)
               ,'mm')
       END plan_date
      ,nvl(p30, '01.01.1900') p30
      , --Дата утверждения к выплате (дата составления страхового акта)--date_get_decision1
       nvl(p31, '01.01.1900') p31
      , --Дата отказа в выплате--date_get_decision2
       nvl(d_v, '01.01.1900') p32
      , --Дата выплаты (берется из бухгалтерии после оплаты)--date_ppi
       add_invest
      , --Дополнительный инвестиционный доход
       add_ins_sum
      , -- Дополнительная страховая сумма
       p37
      , --Сумма выплаченного страхового обеспечения по каждому риску (без франшизы)--sum_ppi
       paym_ndfl
      , --09.12.2011_Чирков Разработка отчетных форм  /Удержанный НДФЛ/
       nvl(date_last_st, '01.01.1900') date_last_st
      , --Дата последнего статуса
       p45
      , --Статус
       p46
      , --Комментарий--note
       p50
      , --Причина отказа--otkaz
       claim_date
      , --Претензия
       claim_count
      , --Количество претензий
       policy_holder
       --      ,      rate_ins_amount
      ,TRIM(substr(p2, 1, instr(p2, '/') - 1)) ord1
      , --delo1
       to_number(TRIM(substr(p2, instr(p2, '/') + 1))) ord2
--delo2
      ,agency
  FROM (SELECT /*+ index(clm PK_C_CLAIM) index(p PK_P_POLICY) index(pcnt IX_POL_CONT_POLICY) index(e PK_C_EVENT)*/
         ph.ids
        ,CASE
           WHEN tp.id = 30500025 THEN
            'Ж'
           ELSE
            (nvl(CASE tp.insurance_group_id
                   WHEN 2404 THEN
                    'Н'
                   WHEN 2800 THEN
                    'Н' --Чирков 172102 выгрузка поля № претензии, открытой занов
                   WHEN 2 THEN
                    'П'
                   ELSE
                    'Ж'
                 END
                ,'-'))
         END p1
        ,nvl(d_ch.num, '-') p2
        ,nvl(decode(p.pol_ser, NULL, p.pol_num, p.pol_ser || '-' || p.pol_num), '-') p3
        ,nvl(CASE
               WHEN chl.id = 8 THEN
                'Кредитный'
               ELSE
                (CASE nvl(p.is_group_flag, 0)
                  WHEN 1 THEN
                   'Корпоративный'
                  ELSE
                   'Индивидуальный'
                END)
             END
            ,'-') p4
        ,nvl(prod.description, '-') p5
        ,nvl(ent.obj_name('CONTACT', asu.assured_contact_id), '-') p7
        ,nvl(casu.date_of_birth, '01.01.1900') p9
        ,nvl(pkg_agent_1.get_agent_pol(p.pol_header_id, SYSDATE), '-') p11
        ,nvl(ph.start_date, '01.01.1900') p15
        ,trunc(e.date_company) p16
        ,(SELECT MAX(ds.start_date)
            FROM ven_c_claim clm2
                ,doc_status  ds
           WHERE clm2.c_claim_header_id = ch.c_claim_header_id
             AND ds.document_id = clm2.c_claim_id
             AND ds.doc_status_ref_id = 122) p17
        ,nvl(e.event_date, '01.01.1900') p20
        ,nvl(e.event_date, '01.01.1900') - nvl(ph.start_date, '01.01.1900') p21
        ,nvl(e.diagnose, '-') p22
        ,CASE
           WHEN pl.description LIKE 'Защита страховых%' THEN
            pl.description
           WHEN pl.description LIKE 'Освобождение%' THEN
            pl.description
           WHEN pl.description LIKE '%Дожитие%по независящим%' THEN
            pl.description
           WHEN pl.description LIKE '%"Расширенная Госпитализация"%' THEN
            pl.description
           WHEN pl.description LIKE 'Первичное диагностирование смертельно опасного заболевания' THEN
            pl.description
           ELSE
            tp.description
         END p23
        ,CASE
           WHEN nvl(ch.is_handset_ins_sum, 0) = 1 THEN
            ch.ins_sum
           WHEN nvl(pc.ins_amount, 0) = 0 THEN
            pkg_claim.get_lim_amount(dmg.t_damage_code_id, dmg.p_cover_id, dmg.c_damage_id)
           WHEN dmg.t_damage_code_id IN
                (SELECT dt.id FROM ins.t_damage_code dt WHERE dt.code IN 'DOP_INVEST_DOHOD')
                AND (SELECT COUNT(1)
                       FROM c_damage dmg_s
                      WHERE (dmg_s.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg_s.c_claim_id AND
                            dmg_s.status_hist_id <> 3)) = 1 THEN
            pkg_claim.get_lim_amount(dmg.t_damage_code_id, dmg.p_cover_id, dmg.c_damage_id)
           ELSE
            nvl(pc.ins_amount, 0)
         END p24
        ,nvl(f.brief, '-') p25
        ,CASE
           WHEN nvl(ch.is_handset_ins_sum, 0) = 1 THEN
            ch.ins_sum
           WHEN nvl(pc.ins_amount, 0) = 0 THEN
            pkg_claim.get_lim_amount(dmg.t_damage_code_id, dmg.p_cover_id, dmg.c_damage_id)
           ELSE
            nvl(pc.ins_amount, 0)
         END amount
        ,

         nvl(dmg.decline_sum, 0) decl
        ,nvl(dmg.declare_sum, 0) paym
        ,nvl(acc.get_cross_rate_by_brief(1, dmgf.brief, f.brief, ch.declare_date), 1) rate
        ,(SELECT SUM(ROUND(nvl(dmg.payment_sum, 0) *
                           acc.get_cross_rate_by_brief(1, dmgf.brief, f.brief, chx.declare_date)
                          ,2))
            FROM ven_c_claim_header chx
            JOIN ven_c_claim clm
              ON (chx.c_claim_header_id = clm.c_claim_header_id)
            JOIN c_damage dmg
              ON (clm.c_claim_id = dmg.c_claim_id)
            LEFT JOIN fund dmgf
              ON (dmgf.fund_id = dmg.damage_fund_id)
            LEFT JOIN fund f
              ON (chx.fund_id = f.fund_id)
           WHERE chx.c_claim_header_id = ch.c_claim_header_id
             AND clm.seqno = 1) p28_1
        ,CASE
           WHEN (nvl(dmg.payment_sum, 0)) > 0 THEN

            (SELECT MAX(ds.start_date)
               FROM ven_c_claim clm2
                   ,doc_status  ds
              WHERE clm2.c_claim_header_id = ch.c_claim_header_id
                AND ds.document_id = clm2.c_claim_id
                AND ds.doc_status_ref_id IN (128))
         END p30
        , --  -10 Урегулируется,11 Закрыт
         CASE
           WHEN (nvl(dmg.payment_sum, 0)) = 0 THEN

            (SELECT MAX(ds.start_date)
               FROM ven_c_claim clm2
                   ,doc_status  ds
              WHERE clm2.c_claim_header_id = ch.c_claim_header_id
                AND ds.document_id = clm2.c_claim_id
                AND ds.doc_status_ref_id IN (128))
         END p31
        ,

         nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'В'), 0) +
         nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'З'), 0) p32
        ,nvl(pkg_renlife_utils.ret_sod_claim(ch.c_claim_header_id), '01.01.1900') d_v
        ,CASE
           WHEN ig.brief != 'NonInsuranceClaims' THEN

            nvl(pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'В') +
                pkg_renlife_utils.ret_amount_claim(e.c_event_id, ch.c_claim_header_id, 'З')
               ,0)
           ELSE
            0
         END p37
        ,nvl(doc.get_last_doc_status_name(ch.active_claim_id), '-') p45
        ,nvl(d_clm.note, '-') p46
        ,(SELECT MAX(ds.start_date)
            FROM ven_c_claim clm2
                ,doc_status  ds
           WHERE clm2.c_claim_header_id = ch.c_claim_header_id
             AND ds.document_id = clm2.c_claim_id
             AND ds.doc_status_ref_id = 129) p49
        ,nvl(pkg_renlife_utils.damage_decline_reason(pc.p_cover_id, ch.active_claim_id), '-') p50
        ,nvl(cad.add_invest, 0) add_invest
        ,nvl(cad.add_ins_sum, 0) add_ins_sum
        ,CASE
           WHEN ch.plan_date IS NOT NULL THEN
            ch.plan_date
           ELSE
            nearest_claim.plan_date
         END plan_date
        ,prod.brief prod_brief
        ,CASE
           WHEN term.is_periodical = 0 THEN
            0
           ELSE
            12 / term.number_of_payments
         END term_number_of_payments
        ,pl.description pl_description
        ,CASE
           WHEN ch.plan_date IS NOT NULL THEN
            0
           ELSE
            nvl(to_number(TRIM(substr(d_ch.num, instr(d_ch.num, '/') + 1))), 0) /*текущий номер*/
            -nvl(nearest_claim.ver_num, 0) --ближайший номер
         END interval_num
        ,nvl((SELECT MAX(dso_1.ndfl_tax)
               FROM ins.c_claim cc_1
                   ,doc_doc     dd_1
                   ,doc_set_off dso_1
                   ,document    d_1
                   ,doc_templ   dt_1
              WHERE cc_1.c_claim_header_id = clm.c_claim_header_id
                AND dd_1.parent_id = cc_1.c_claim_id
                AND dd_1.child_id = dso_1.parent_doc_id
                AND d_1.document_id = dso_1.child_doc_id
                AND dt_1.doc_templ_id = d_1.doc_templ_id
                AND dt_1.brief = 'ППИ'
                AND dso_1.set_off_date = (SELECT MAX(dso_2.set_off_date)
                                            FROM ins.c_claim cc_2
                                                ,doc_doc     dd_2
                                                ,doc_set_off dso_2
                                           WHERE cc_2.c_claim_header_id = cc_1.c_claim_header_id
                                             AND dd_2.parent_id = cc_2.c_claim_id
                                             AND dd_2.child_id = dso_2.parent_doc_id
                                             AND nvl(dso_2.ndfl_tax, 0) > 0))
            ,0) paym_ndfl
        ,nvl((SELECT MAX(ccd.c_claim_date)
               FROM c_claim_dates ccd
              WHERE ccd.c_claim_header_id = ch.c_claim_header_id)
            ,'01.01.1900') claim_date

        ,(SELECT COUNT(ccd.c_claim_date)
            FROM c_claim_dates ccd
           WHERE ccd.c_claim_header_id = ch.c_claim_header_id) claim_count
        ,(SELECT MAX(ds.start_date)
            FROM ven_c_claim    clm2
                ,doc_status     ds
                ,doc_status_ref rf
           WHERE clm2.c_claim_header_id = ch.c_claim_header_id
             AND ds.document_id = clm2.c_claim_id
             AND ds.doc_status_ref_id = rf.doc_status_ref_id) date_last_st
        ,cpol.obj_name_orig policy_holder
        ,CASE
           WHEN dmg.t_damage_code_id IN
                (SELECT dt.id FROM ins.t_damage_code dt WHERE dt.code IN 'DOP_INVEST_DOHOD')
                AND (SELECT COUNT(1)
                       FROM c_damage dmg_s
                      WHERE (dmg_s.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg_s.c_claim_id AND
                            dmg_s.status_hist_id <> 3)) = 1 THEN
            100
           ELSE
            1
         END rate_ins_amount
       ,(SELECT MAX(ins.ent.obj_name('DEPARTMENT', ach.agency_id)) keep(dense_rank FIRST ORDER BY pad.date_begin DESC)
                  FROM ins.p_policy_agent_doc pad
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac
                 WHERE pad.ag_contract_header_id = ach.ag_contract_header_id
                   AND ac.ag_contract_id =
                       ins.pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
                   AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND pad.policy_header_id = ph.policy_header_id) agency
          FROM c_claim_header ch
          JOIN document d_ch
            ON d_ch.document_id = ch.c_claim_header_id --and ch.c_claim_header_id=7099131
          JOIN c_claim clm
            ON (ch.active_claim_id = clm.c_claim_id)
          JOIN p_policy p
            ON ch.p_policy_id = p.policy_id
          JOIN p_policy_contact pcnt
            ON pcnt.policy_id = p.policy_id
          JOIN t_contact_pol_role polr
            ON (polr.brief = 'Страхователь' AND pcnt.contact_policy_role_id = polr.id)
          JOIN contact cpol
            ON cpol.contact_id = pcnt.contact_id
          JOIN c_event e
            ON (ch.c_event_id = e.c_event_id)
          LEFT JOIN as_asset a
            ON ch.as_asset_id = a.as_asset_id
          LEFT JOIN as_assured asu
            ON asu.as_assured_id = a.as_asset_id
          LEFT JOIN cn_person casu
            ON casu.contact_id = asu.assured_contact_id
          LEFT JOIN fund f
            ON ch.fund_id = f.fund_id
          LEFT JOIN p_cover pc
            ON ch.p_cover_id = pc.p_cover_id
          LEFT JOIN t_prod_line_option pl
            ON pc.t_prod_line_option_id = pl.id
          LEFT JOIN ins.t_product_line pll
            ON (pll.id = pl.product_line_id)
          LEFT JOIN ins.t_lob_line ll
            ON (pll.t_lob_line_id = ll.t_lob_line_id)
          LEFT JOIN ins.t_insurance_group ig
            ON (ig.t_insurance_group_id = ll.insurance_group_id)
          JOIN p_pol_header ph
            ON ph.policy_header_id = p.pol_header_id
          JOIN t_payment_terms term
            ON (term.id = p.payment_term_id)
          LEFT JOIN t_sales_channel chl
            ON (chl.id = ph.sales_channel_id)
          LEFT JOIN t_product prod
            ON prod.product_id = ph.product_id
          LEFT JOIN t_peril tp
            ON tp.id = ch.peril_id
          LEFT JOIN c_damage dmg
            ON (dmg.p_cover_id = pc.p_cover_id AND ch.active_claim_id = dmg.c_claim_id AND
               dmg.status_hist_id <> 3 AND
               --381316 Григорьев Ю. Выплата по конкретному коду риска (dmg.c_claim_id) поддела должна быть или больше нуля,
               --или, если она равна 0, то сумма по всем кодам риска поддела должна быть положительна.
               --Это нужно, чтобы отсечь случаи, когда выводятся отказы (нулевые выплаты) по некоторым кодам риска поддела, но не поддела в целом.
               (nvl(dmg.payment_sum, 0) > 0 OR
               (nvl(dmg.payment_sum, 0) = 0 AND (SELECT nvl(SUM(dmg_.payment_sum), 0)
                                                     FROM c_damage           dmg_
                                                         ,ven_c_claim_header ch_
                                                    WHERE 1 = 1
                                                      AND ch.c_claim_header_id = ch_.c_claim_header_id
                                                      AND ch_.active_claim_id = dmg_.c_claim_id
                                                   --AND ch_.c_claim_header_id = 114077629
                                                   ) = 0)))
          LEFT JOIN c_claim_add cad
            ON (cad.c_claim_id = clm.c_claim_id)
         INNER JOIN document d_clm
            ON d_clm.document_id = clm.c_claim_id
          LEFT JOIN(WITH claims AS (SELECT /*+use_nl(ch,d)*/
                                    to_number(regexp_substr(TRIM(num), '\d*$')) num
                                   ,plan_date
                                   ,c_event_id
                                   ,c_claim_header_id
                                     FROM c_claim_header ch
                                         ,document       d
                                    WHERE ch.c_claim_header_id = d.document_id)
        SELECT nvl(MAX(c2.num), 0) ver_num
              ,MAX(c2.plan_date) keep(dense_rank FIRST ORDER BY c2.num DESC) plan_date
              ,c1.c_event_id
              ,c1.c_claim_header_id
          FROM claims c1
              ,claims c2
         WHERE c1.c_event_id = c2.c_event_id
           AND c1.num > c2.num
           AND c2.plan_date IS NOT NULL
         GROUP BY c1.c_claim_header_id
                 ,c1.c_event_id) nearest_claim
            ON nearest_claim.c_claim_header_id = ch.c_claim_header_id
           AND nearest_claim.c_event_id = ch.c_event_id
          LEFT JOIN fund dmgf
            ON (dmgf.fund_id = dmg.damage_fund_id)
         WHERE ch.c_claim_header_id NOT IN
               (SELECT d.document_id
                  FROM etl.import_export_claim et
                      ,document                d
                      ,doc_templ               t
                 WHERE t.doc_templ_id = d.doc_templ_id
                   AND t.brief = 'Претензия'
                   AND nvl(et.show_del_pret, 0) = 0
                   AND TRIM((CASE
                              WHEN instr(et.num_event, '-', 1) > 0 THEN
                               lpad(substr(et.num_event
                                          ,1
                                          ,length(et.num_event) -
                                           ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                   ,9
                                   ,'0') || '/' ||
                               substr(et.num_event
                                     ,instr(et.num_event, '-', 1) + 1
                                     ,length(et.num_event) -
                                      ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                              ELSE
                               lpad(et.num_event, 9, '0') || '/' || '1'
                            END)) = d.num))
 GROUP BY CASE
            WHEN p45 IN ('Передано на оплату'
                        ,'Закрыт'
                        ,'Отказано в выплате') THEN
             (CASE
               WHEN (amount > 0)
                    AND (nvl(paym, 0) - nvl(decl, 0)) * rate / amount > 0 THEN
                1
               ELSE
                0
             END)
            ELSE
             2
          END
         ,p1
         ,p2
         ,p3
         ,ids
         ,p4
         ,p5
         ,p7
         ,p9
         ,p11
         ,p15
         ,p16
         ,nvl(p17, '01.01.1900')
         ,nvl(p20, '01.01.1900')
         ,nvl(p21, 0)
         ,p22
         ,p23
         ,p24
         ,p25
         ,nvl(p28_1, 0)
         ,CASE
            WHEN plan_date IS NULL THEN
             to_date('01.01.1900')
            WHEN pl_description IN ('Защита страховых взносов'
                                   ,'Защита страховых взносов рассчитанная по основной программе'
                                   ,'Освобождение от уплаты взносов рассчитанное по основной программе'
                                   ,'Освобождение от уплаты дальнейших взносов'
                                   ,'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе'
                                   ,'Освобождение от уплаты страховых взносов')

             THEN
             ADD_MONTHS(plan_date
                       ,term_number_of_payments * CASE
                          WHEN interval_num >= 0 THEN
                           interval_num
                          ELSE
                           NULL
                        END)
            WHEN prod_brief IN ('OPS_Plus', 'OPS_Plus_2', 'OPS_Plus_New') THEN
             trunc(ADD_MONTHS(plan_date
                             ,1 * CASE
                                WHEN interval_num >= 0 THEN
                                 interval_num
                                ELSE
                                 NULL
                              END)
                  ,'mm')
          END
         ,nvl(p30, '01.01.1900')
         ,p31
         ,nvl(d_v, '01.01.1900')
         ,add_invest
         ,add_ins_sum
         ,p37
         ,paym_ndfl
         ,nvl(date_last_st, '01.01.1900')
         ,p45
         ,p46
         ,p50
         ,claim_date
         ,claim_count
         ,rate_ins_amount
         ,policy_holder
         ,agency
UNION
SELECT CASE
         WHEN (CASE
                WHEN nvl(et.to_agency, 'Закрыт') <> 'Запрос документов' THEN
                 'Закрыт'
                ELSE
                 et.to_agency
              END) IN ('Передано на оплату'
                      ,'Закрыт'
                      ,'Отказано в выплате') THEN
          (CASE
            WHEN nvl(et.sum_real_risk, 0) <> 0 THEN
             1
            WHEN nvl(et.non_insurer, 0) <> 0 THEN
             1
            ELSE
             0
          END)
         ELSE
          2
       END p51
      ,upper(nvl(et.num_pret, 'Н')) num_pret
      , --№ претензии, открытой заново (Жизнь  / Не жизнь)
       (CASE
         WHEN instr(et.num_event, '-', 1) > 0 THEN
          lpad(substr(et.num_event
                     ,1
                     ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
              ,9
              ,'0') || '/' ||
          substr(et.num_event
                ,instr(et.num_event, '-', 1) + 1
                ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
         ELSE
          lpad(et.num_event, 9, '0') || '/' || '1'
       END) num_event
      , --№ дела
       et.pol_num
      , --№ полиса
       et.ids
      ,nvl(et.type_pol, '-') type_pol
      ,et.name_product
      ,et.insurer
      ,nvl(et.date_of_birth, '01.01.1900') date_of_birth
      , --Дата рождения
       et.name_agent
      , --Агент
       nvl(et.date_header, '01.01.1900') date_header
      , --Дата вступления договора в силу
       trunc(et.date_in_company) date_in_company
      , --Дата получения уведомления--date_in_company
       nvl(et.date_all_doc, '01.01.1900') date_all_doc
      , --Дата получения всех документов--date_all_doc
       nvl(et.date_event, '01.01.1900') date_event
      , --Дата наступления страхового события--date_event
       et.days_to_ss
      , --Количество дней действия полиса до наступления СС
       et.diagnos
      , --Диагноз
       et.risks
      , --Перечень рисков, наступивших вследствие произошедшего события
       nvl(et.limit_risks, 0) limit_risks
      , --Лимит ответственности по  рискам
       et.currency
      , --Валюта
       nvl(et.rate_amount, 0) * 100 rate_amount
      , --% от СС суммы--ubitok_z
       nvl(et.summ_future_risk, 0) summ_future_risk
      , --Сумма предполагаемого страхового обеспечения по каждому риску  (без франшизы)
       nvl(et.reserve_sum_future_risk, 0) reserve_sum_future_risk
      , --Зарезервированная сумма предполагаемого страхового обеспечения по каждому риску
       nvl(et.plan_date, '01.01.1900') plan_date
      , --График оплаты страховых взносов (для рисков Защита и Освобождение)
       nvl(et.date_to_vipl, '01.01.1900') date_to_vipl
      , --Дата утверждения к выплате (дата составления страхового акта)--date_get_decision1
       nvl(et.date_abort_vipl, '01.01.1900') date_abort_vipl
      , --Дата отказа в выплате--date_get_decision2
       nvl(et.date_from_account, '01.01.1900') date_from_account
      , --Дата выплаты (берется из бухгалтерии после оплаты)--date_ppi
       nvl(et.add_invest, 0) add_invest
      , --Дополнительный инвестиционный доход
       0 add_ins_sum
      , -- Дополнительная страховая сумма
       nvl(et.sum_real_risk, 0) sum_real_risk
      , --Сумма выплаченного страхового обеспечения по каждому риску (без франшизы)--sum_ppi
       nvl(et.paym_ndfl, 0) paym_ndfl
      , --Удержанный НДФЛ
       CASE (CASE
          WHEN (CASE
                 WHEN nvl(et.to_agency, 'Закрыт') <> 'Запрос документов' THEN
                  'Закрыт'
                 ELSE
                  et.to_agency
               END) IN ('Передано на оплату'
                       ,'Закрыт'
                       ,'Отказано в выплате') THEN
           (CASE
             WHEN nvl(et.sum_real_risk, 0) <> 0 THEN
              1
             ELSE
              0
           END)
          ELSE
           2
        END)
         WHEN 1 THEN
          nvl(et.date_from_account, '01.01.1900')
         WHEN 0 THEN
          nvl(et.date_abort_vipl, '01.01.1900')
         ELSE
          to_date('01.01.1900', 'dd.mm.yyyy')
       END date_last_st
      , --Последний статус
       CASE
         WHEN nvl(et.state, 'Закрыт') <> 'Запрос документов' THEN
          'Закрыт'
         ELSE
          et.state
       END state
      , --Статус
       nvl(et.note, '-') note
      , --Комментарий--note
       nvl(et.otkaz, '-') otkaz
      , --Причина отказа--otkaz
       nvl(et.claim_date, '01.01.1900') claim_date
      , --Претензия
       nvl(et.claim_count, 0) claim_count
      , --Количество претензий
       (SELECT MAX(c.obj_name_orig)
          FROM p_policy           p
              ,p_pol_header       ph
              ,p_policy_contact   ppc
              ,t_contact_pol_role cpr
              ,contact            c
         WHERE p.pol_header_id = ph.policy_header_id
           AND nvl(et.date_event, '01.01.1900') BETWEEN p.start_date AND p.end_date
           AND ppc.policy_id = p.policy_id
           AND ppc.contact_policy_role_id = cpr.id
           AND cpr.description = 'Страхователь'
           AND ppc.contact_id = c.contact_id
           AND ph.policy_header_id = (SELECT ph.policy_header_id
                                        FROM p_pol_header ph
                                       WHERE ph.ids = et.ids
                                         AND rownum = 1)) policy_holder
      ,TRIM(substr((CASE
                     WHEN instr(et.num_event, '-', 1) > 0 THEN
                      lpad(substr(et.num_event
                                 ,1
                                 ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                          ,9
                          ,'0') || '/' ||
                      substr(et.num_event
                            ,instr(et.num_event, '-', 1) + 1
                            ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                     ELSE
                      lpad(et.num_event, 9, '0') || '/' || '1'
                   END)
                  ,1
                  ,instr((CASE
                           WHEN instr(et.num_event, '-', 1) > 0 THEN
                            lpad(substr(et.num_event
                                       ,1
                                       ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                ,9
                                ,'0') || '/' ||
                            substr(et.num_event
                                  ,instr(et.num_event, '-', 1) + 1
                                  ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                           ELSE
                            lpad(et.num_event, 9, '0') || '/' || '1'
                         END)
                        ,'/') - 1)) ord1
      ,

       to_number(TRIM(substr((CASE
                               WHEN instr(et.num_event, '-', 1) > 0 THEN
                                lpad(substr(et.num_event
                                           ,1
                                           ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                    ,9
                                    ,'0') || '/' ||
                                substr(et.num_event
                                      ,instr(et.num_event, '-', 1) + 1
                                      ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                               ELSE
                                lpad(et.num_event, 9, '0') || '/' || '1'
                             END)
                            ,instr((CASE
                                     WHEN instr(et.num_event, '-', 1) > 0 THEN
                                      lpad(substr(et.num_event
                                                 ,1
                                                 ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                          ,9
                                          ,'0') || '/' ||
                                      substr(et.num_event
                                            ,instr(et.num_event, '-', 1) + 1
                                            ,length(et.num_event) - ((length(et.num_event) - instr(et.num_event, '-', 1)) + 1))
                                     ELSE
                                      lpad(et.num_event, 9, '0') || '/' || '1'
                                   END)
                                  ,'/') + 1))) ord2
   ,(SELECT MAX(ins.ent.obj_name('DEPARTMENT', ach.agency_id)) keep(dense_rank FIRST ORDER BY pad.date_begin DESC)
                  FROM ins.p_policy_agent_doc pad
                      ,ins.ag_contract_header ach
                      ,ins.ag_contract        ac
                 WHERE pad.ag_contract_header_id = ach.ag_contract_header_id
                   AND ac.ag_contract_id =
                       ins.pkg_agent_1.get_status_by_date(ach.ag_contract_header_id, SYSDATE)
                   AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                   AND pad.policy_header_id = et.policy_header_id) agency
  FROM etl.import_export_claim et
      ,t_product_group         pg
      ,t_product               pr1
 WHERE nvl(et.show_del_pret, 0) != 2
   AND et.brief_product = pr1.brief(+)
   AND pr1.t_product_group_id = pg.t_product_group_id(+)
;
