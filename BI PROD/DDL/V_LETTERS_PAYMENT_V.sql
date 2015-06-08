CREATE OR REPLACE VIEW V_LETTERS_PAYMENT_V AS
(
SELECT a."DAYS_REMAINING",a."PAYMENT_PERIOD",a."MB",case a.mb when 0 then fee/*-pay_amount_dog*/ else sum_fee/*-pay_amount_dog*/ end oplata,
       a."POL_START_DATE",a."POL_END_DATE",a."POL_HEADER_ID",a."POLICY_ID",a."POLICY_NUMBER",a."POL_SER",a."POL_NUM",a."DOCUMENT_ID",
       a."NUM",a."DUE_DATE",a.prev_due_date,a."GRACE_DATE",
       case a.payment_period
             WHEN 'единовременный' THEN to_date(a.grace_period,'dd.mm.yyyy')
             WHEN 'ежеквартальный' THEN add_months(to_date(a.grace_period,'dd.mm.yyyy'),-3)
             WHEN 'ежемесячный' THEN add_months(to_date(a.grace_period,'dd.mm.yyyy'),-1)
             WHEN 'полугодовой' THEN add_months(to_date(a.grace_period,'dd.mm.yyyy'),-6)
             WHEN 'годовой' THEN add_months(to_date(a.grace_period,'dd.mm.yyyy'),-12)
             ELSE to_date(a.grace_period,'dd.mm.yyyy')
       END AS prev_grace_date, a.ids_check,
       a."GRACE_PERIOD",a."AMOUNT",a."FUND",a."SUM_FEE",nvl(a.pay_amount,0) "PAY_AMOUNT",a."ACC_RATE",
       a."CONTACT_ID",a."CONTACT_NAME",a."INIT_NAME",a."CODE", a."ADDRESS_NAME" ,a."ID",a."DOC_STATUS_REF_ID",a."DOC_STATUS_REF_NAME",
       a."PRODUCT_ID",NVL2(a.pay_amount, a.amount*a.acc_rate, a.amount) rev_amount, nvl2(a.pay_amount,a.fund,'') rev_fund, a.type_contact,
       a.gender, a.pay_amount_dog,a.lday, a.plan_date, nvl(a.cnt_9,0) cnt_9, nvl(a.cnt_10,0) cnt_10,
       row_number() over (partition by a.pol_header_id order by a.due_date asc) nm,--a.nm,
       a.dop_prem_ns, a.prod_flg,
       a.stat_flg, a.agent_current, a.leader_agent, a.leader_manag,a.fadr, a.city_name, a.distr_name, a.province_name, a.region_name, a.country_name,
       a.zip, a.payment_period_check, a.min_data_no_pay, a.colm_flag FROM (
SELECT distinct trunc(SYSDATE) - trunc(a.grace_date) days_remaining,
       CASE pt.DESCRIPTION
             WHEN 'Единовременно' THEN 'единовременный'
             WHEN 'Ежеквартально' THEN 'ежеквартальный'
             WHEN 'Ежемесячно' THEN 'ежемесячный'
             WHEN 'Раз в полгода' THEN 'полугодовой'
             WHEN 'Ежегодно' THEN 'годовой'
             ELSE pt.DESCRIPTION
       END AS payment_period,
       CASE pt.DESCRIPTION
             WHEN 'Ежемесячно' THEN 1
             ELSE 0
       END AS payment_period_check,
              case
         when substr(to_char(ph.ids),1,3) in ('114','115','123')
              or prod.product_id in (select lva.number_val
                                       from t_n_ltrs_params lpr
                                           ,t_n_ltrs_params_vals lva
                                           ,t_notification_type  ntp
                                      where ntp.brief = 'REMIND_GRACE_PDFN_WITH'
                                        and lpr.brief = 'PRODUCT'
                                        and lpr.t_n_ltrs_params_id     = lva.t_notif_param_id
                                        and ntp.t_notification_type_id = lva.t_notification_type_id
                                    )
         then 0
         else 1
       end ids_check,
       case pt.DESCRIPTION
             WHEN 'Единовременно' THEN a.due_date
             WHEN 'Ежеквартально' THEN add_months(a.due_date,-3)
             WHEN 'Ежемесячно' THEN add_months(a.due_date,-1)
             WHEN 'Раз в полгода' THEN add_months(a.due_date,-6)
             WHEN 'Ежегодно' THEN add_months(a.due_date,-12)
             ELSE a.due_date
       END AS prev_due_date,
       case when mod(MONTHS_BETWEEN(a.plan_date, ph.start_date),12) = 0 then 0 else 1 end mb,
       --1 nm,
       --row_number() over (partition by p.pol_header_id order by a.payment_id asc) nm,
       p.START_DATE POL_START_DATE,
       p.END_DATE POL_END_DATE,
       p.pol_header_id,
       p.policy_id,
       p.pol_ser||nvl2(p.pol_ser, ' ','')|| p.pol_num AS POLICY_NUMBER,
       nvl(p.pol_ser, '-') pol_ser,
       nvl(p.pol_num, '-') pol_num,
       a.payment_id document_id,
       a.num,
       a.due_date,
       a.grace_date,
       a.plan_date,
       to_date(last_day(to_char(extract(day from to_date('01','dd')))||'.'||to_char(case when extract(month from a.due_date)+1 > 12 then extract(month from a.due_date)+1 - 12 else extract(month from a.due_date)+1 end)||'.'||to_char(case when extract(month from a.due_date)+1 > 12 then extract(year from a.due_date)+1 else extract(year from a.due_date) end)) ) lday,
       to_char(a.due_date + tper.period_value, 'dd.mm.yyyy') grace_period,
       --decode(ph.product_id, 2267, to_char(a.due_date + 45, 'dd.mm.yyyy'), 7680, to_char(a.due_date + 45, 'dd.mm.yyyy'), 7678, to_char(a.due_date + 45, 'dd.mm.yyyy'), 7679, to_char(a.due_date + 45, 'dd.mm.yyyy'), 20525, to_char(a.due_date + 30, 'dd.mm.yyyy'), 20544, to_char(a.due_date + 30, 'dd.mm.yyyy'), 28290, to_char(a.due_date + 30, 'dd.mm.yyyy'), to_char(a.grace_date, 'dd.mm.yyyy')) AS grace_period,
       a.amount -
       (SELECT NVL(SUM(ir.invest_reserve_amount),0)
          FROM ins.ac_payment_ir ir
         WHERE ir.ac_payment_id = a.payment_id
       ) amount,
       Pkg_Payment.get_set_off_amount(a.payment_id, NULL, NULL) -
       NVL(Pkg_Payment.get_set_off_amount_ir(a.payment_id, NULL, NULL),0) pay_amount_dog,
       f.brief fund,
       doc.get_last_doc_status_name(p.policy_id) last_policy_status,
       (select min(acm.plan_date)
       from p_pol_header phm,
            p_policy ppm,
            doc_doc ddm,
            ac_payment acm,
            document dm,
            doc_templ dtm
       where phm.policy_header_id = ph.policy_header_id
             and phm.policy_header_id = ppm.pol_header_id
             and ddm.parent_id = ppm.policy_id
             and ddm.child_id = acm.payment_id
             and acm.payment_id = dm.document_id
             and dm.doc_templ_id = dtm.doc_templ_id
             and dtm.brief = 'PAYMENT'
             and doc.get_doc_status_brief(acm.payment_id) in ('NEW','TO_PAY')
             ) min_data_no_pay,

       (select sum(pc.fee)
        from
                p_policy pp,
                as_asset ass,
                p_cover pc,
                t_prod_line_option plo,
                t_product_line pl,
                t_product_line_type plt
        where pp.policy_id = p.policy_id
         and ass.p_policy_id = pp.policy_id
         and pc.as_asset_id = ass.as_asset_id
         and plo.id = pc.t_prod_line_option_id
         and plo.product_line_id = pl.id
         and pl.product_line_type_id = plt.product_line_type_id
         and plt.brief in ('OPTIONAL','MANDATORY')
         and upper(trim(plo.description)) not in ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ','АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ НА ВОССТАНОВЛЕНИЕ','ИНВЕСТ','ИНВЕСТ2','ИНВЕСТ2_1')
         AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                                      FROM ins.t_lob_line ll
                                      WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                                      )
         ) dop_prem_ns,

       (SELECT SUM(pc.fee)
          FROM as_asset aa,
               p_cover pc,
               t_prod_line_option tplo,
               t_product_line pl
         WHERE aa.p_policy_id = p.policy_id
           AND pc.as_asset_id = aa.as_asset_id
           AND pc.decline_reason_id IS NULL
           AND pc.t_prod_line_option_id = tplo.id
           AND tplo.description NOT IN ('Административные издержки','Административные издержки на восстановление')
           AND pl.id = tplo.product_line_id
           AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                                        FROM ins.t_lob_line ll
                                        WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                                        )
           ) sum_fee,
        (SELECT SUM(pc.fee)
          FROM as_asset aa,
               p_cover pc,
               t_prod_line_option tplo,
               t_product_line pl
         WHERE aa.p_policy_id = p.policy_id
           AND pc.as_asset_id = aa.as_asset_id
           AND pc.decline_reason_id IS NULL
           AND pc.t_prod_line_option_id = tplo.id
           AND tplo.description NOT IN ('Административные издержки на восстановление')
           AND pl.id = tplo.product_line_id
           AND pl.t_lob_line_id NOT IN (SELECT ll.t_lob_line_id
                                        FROM ins.t_lob_line ll
                                        WHERE ll.brief = 'PEPR_INVEST_RESERVE'
                                        )
           ) fee,
       (SELECT sum(t.trans_amount)
          FROM oper o,
               trans t,
               trans_templ tt
         WHERE o.document_id = dso.doc_set_off_id
           AND o.oper_id = t.oper_id
           AND t.trans_templ_id = tt.trans_templ_id
           AND tt.brief IN ('СтраховаяПремияОплачена', 'ЗачтВыплВозвр')) -
       (SELECT sum(t.trans_amount)
          FROM oper o,
               trans t,
               trans_templ tt
         WHERE o.document_id = dso.doc_set_off_id
           AND o.oper_id = t.oper_id
           AND t.trans_templ_id = tt.trans_templ_id
           AND tt.brief IN ('СтраховаяПремияОплачена', 'ЗачтВыплВозвр')
           AND ((t.a4_dt_ure_id = 310 AND
                 t.a4_dt_uro_id IN (SELECT opt.id
                                        FROM ins.t_lob_line         lb
                                            ,ins.t_product_line     pl
                                            ,ins.t_prod_line_option opt
                                       WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                                         AND lb.t_lob_line_id = pl.t_lob_line_id
                                         AND pl.id = opt.product_line_id)) OR
                 (t.a4_ct_ure_id = 310 AND
                 t.a4_ct_uro_id IN (SELECT opt.id
                                        FROM ins.t_lob_line         lb
                                            ,ins.t_product_line     pl
                                            ,ins.t_prod_line_option opt
                                       WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                                         AND lb.t_lob_line_id = pl.t_lob_line_id
                                         AND pl.id = opt.product_line_id)) OR
                 (t.a3_dt_ure_id = 310 AND
                 t.a3_dt_uro_id IN (SELECT opt.id
                                        FROM ins.t_lob_line         lb
                                            ,ins.t_product_line     pl
                                            ,ins.t_prod_line_option opt
                                       WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                                         AND lb.t_lob_line_id = pl.t_lob_line_id
                                         AND pl.id = opt.product_line_id)) OR
                 (t.a3_ct_ure_id = 310 AND
                 t.a3_ct_uro_id IN (SELECT opt.id
                                        FROM ins.t_lob_line         lb
                                            ,ins.t_product_line     pl
                                            ,ins.t_prod_line_option opt
                                       WHERE lb.brief = 'PEPR_INVEST_RESERVE'
                                         AND lb.t_lob_line_id = pl.t_lob_line_id
                                         AND pl.id = opt.product_line_id))
                )
        ) pay_amount,
       (SELECT max(t.acc_rate)
          FROM oper o,
               trans t,
               trans_templ tt
         WHERE o.document_id = dso.doc_set_off_id
           AND o.oper_id = t.oper_id
           AND t.trans_templ_id = tt.trans_templ_id
           AND tt.brief IN ('СтраховаяПремияОплачена', 'ЗачтВыплВозвр')) acc_rate,
       cpol.contact_id,
       case tc.id when 101 then 0 else 1 end type_contact,
       per.gender,
       cpol.obj_name_orig contact_name,
       nvl(cpol.NAME, '')||' '||nvl(substr(cpol.first_name, 1, 1)||'.','')||nvl(substr(cpol.middle_name, 1, 1)||'.','') init_name,
       nvl(dep.NAME, '00') code,
       NVL(ca.name, pkg_contact.get_address_name(ca.id)) address_name,
       (case when ca.street_name is not null then NVL(ca.street_type,'ул')||'.'||ca.street_name else '' end ||
       case when ca.house_nr is not null then ',д.'||ca.house_nr else '' end ||
       case when ca.block_number is not null then ','||ca.block_number else '' end ||
       case when ca.appartment_nr is not null then ',кв.'||ca.appartment_nr else '' end) fadr,
       (case when ca.city_name is not null then 'г.'||ca.city_name else '' end) city_name,
       case when ca.region_name is not null then ca.region_name||' '||ca.region_type else '' end region_name,
       case when ca.province_name is not null then ca.province_name||' '||ca.province_type else '' end province_name,
       case when ca.district_name is not null then ca.district_type||' '||ca.district_name else '' end distr_name,
       --nvl(ca.province_name,ca.region_name) province_name,
       --nvl(ca.region_name,ca.province_name) region_name,
       (select distinct tc.description from t_country tc where tc.id = ca.country_id) country_name,
       ca.zip,
       ca.ID,
       dsr.doc_status_ref_id,
       dsr.NAME doc_status_ref_name,
       ph.product_id,

       (select  count(*)
                from p_policy pp
                     join as_asset a on (pp.policy_id = a.p_policy_id)
                     join p_cover pc on (a.as_asset_id = pc.as_asset_id)
                     join status_hist h on (pc.status_hist_id = h.status_hist_id and h.brief != 'DELETED')
                     join t_prod_line_option opt on (pc.t_prod_line_option_id = opt.id)
                     join t_product_line ll on (opt.product_line_id = ll.id)
                     join t_lob_line tl on (ll.t_lob_line_id = tl.t_lob_line_id)
                     join t_prod_line_opt_peril opr on (opr.product_line_option_id = opt.id)
                     join t_peril prl on (prl.id = opr.peril_id)

                     join ven_c_claim_header ch on (ch.p_policy_id = pp.policy_id and ch.p_cover_id = pc.p_cover_id and prl.id = ch.peril_id)

                where (prl.description  like ('Смерть Застрахованного%') or prl.description  like ('Смерть застрахованного%'))
                      and pp.policy_id in (select phg.policy_id
                                           from p_policy phg
                                           where phg.pol_header_id = ph.policy_header_id)) cnt_10,

   case when  (select  count(*)
                from p_policy pp
                     join as_asset a on (pp.policy_id = a.p_policy_id)
                     join p_cover pc on (a.as_asset_id = pc.as_asset_id)
                     join status_hist h on (pc.status_hist_id = h.status_hist_id and h.brief != 'DELETED')
                     join t_prod_line_option opt on (pc.t_prod_line_option_id = opt.id)
                     join t_product_line ll on (opt.product_line_id = ll.id)
                     join t_lob_line tl on (ll.t_lob_line_id = tl.t_lob_line_id)
                     join t_prod_line_opt_peril opr on (opr.product_line_option_id = opt.id)
                     join t_peril prl on (prl.id = opr.peril_id)

                     join ven_c_claim_header ch on (ch.p_policy_id = pp.policy_id and ch.p_cover_id = pc.p_cover_id and prl.id = ch.peril_id)

                where (prl.description like ('Смерть Страхователя%') or prl.description like ('Смерть страхователя%'))
                      and pp.policy_id in (select phc.policy_id
                                           from p_policy phc
                                           where phc.pol_header_id = ph.policy_header_id)) = 0 then 1 else
                (select  count(*)
                from p_policy pp
                     join as_asset a on (pp.policy_id = a.p_policy_id)
                     join p_cover pc on (a.as_asset_id = pc.as_asset_id)
                     join status_hist h on (pc.status_hist_id = h.status_hist_id and h.brief != 'DELETED')
                     join t_prod_line_option opt on (pc.t_prod_line_option_id = opt.id)
                     join t_product_line ll on (opt.product_line_id = ll.id)
                     join t_lob_line tl on (ll.t_lob_line_id = tl.t_lob_line_id)
                     join t_prod_line_opt_peril opr on (opr.product_line_option_id = opt.id)
                     join t_peril prl on (prl.id = opr.peril_id)

                     join ven_c_claim_header ch on (ch.p_policy_id = pp.policy_id and ch.p_cover_id = pc.p_cover_id and prl.id = ch.peril_id)

                where (prl.description like ('Смерть Страхователя%') or prl.description like ('Смерть страхователя%'))
                      and pp.policy_id in (select phc.policy_id
                                           from p_policy phc
                                           where phc.pol_header_id = ph.policy_header_id)
                      and (select to_char(max(ds.start_date),'dd.mm.yyyy')
                                 from ven_c_claim clm2,
                                      doc_status ds
                                 where clm2.c_claim_header_id = ch.c_claim_header_id
                                       and ds.document_id = clm2.c_claim_id
                                       and ds.doc_status_ref_id = 128) is not null) end cnt_9,
       case when prod.product_id in (2267,7679,7680,7678) then 1 else 0 end prod_flg, 
       CASE
         WHEN doc.get_doc_status_brief(pkg_policy.get_last_version(p.pol_header_id)) IN
              ('STOPED', 'READY_TO_CANCEL', 'INDEXATING', 'BREAK')
              OR
              (doc.get_doc_status_brief(pkg_policy.get_last_version(p.pol_header_id)) = 'CANCEL' AND
               doc.get_doc_status_brief(pkg_policy.get_curr_policy(p.pol_header_id)) != 'CURRENT') THEN
          2
         WHEN doc.get_doc_status_brief(pkg_policy.get_last_version(p.pol_header_id)) IN ('STOP') THEN
          1
         ELSE
          0
       END stat_flg /*изменено по заявке 337566/Чирков*/,
      ag_cur.agent_current,
      ag_cur.leader_agent,
      ag_cur.leader_manag,
      CASE WHEN colm.description = 'Прямое списание с карты'
            THEN 1
           ELSE 0
      END colm_flag
      /*doc.get_doc_status_brief(p.policy_id) st1,
      doc.get_doc_status_brief(pkg_policy.get_last_version(p.pol_header_id)) st2,
      pkg_policy.get_last_version_status(p.pol_header_id) st3*/
  FROM p_pol_header ph,
       t_product prod,
       p_policy_agent_doc  pag,
       document padd,
       ag_contract_header hed,
       department         dep,
       p_policy   p,
       t_period tper,
       T_PAYMENT_TERMS pt,
       doc_doc    dd,
       ven_ac_payment a,
       fund f,
       ac_payment_templ apt,
       doc_status_ref dsr,
       contact c,
       t_contact_type tc,
       cn_person per,
       cn_address ca,

       doc_set_off dso,
       t_contact_pol_role polr,
       p_policy_contact pcnt,
       contact cpol,
       t_collection_method colm,

       (select pa.policy_header_id,
               ach.agent_id,
               ach.agency_id,
               ach.t_sales_channel_id,
               cagc.obj_name_orig agent_current,
               cl.obj_name_orig leader_agent,
               cd.obj_name_orig leader_manag
          from p_policy_agent_doc   pa,
               document pad,
               ven_ag_contract_header ach,
               contact cagc,

               ag_contract ag,
               ag_contract agl,
               ag_contract_header hl,
               contact cl,
               ag_contract aglv,
               ag_contract agd,
               ag_contract_header hd,
               contact cd

         where pa.ag_contract_header_id = ach.ag_contract_header_id
           and cagc.contact_id = ach.agent_id
           and pad.document_id = pa.p_policy_agent_doc_id
           and doc.get_doc_status_brief(pa.p_policy_agent_doc_id) not in ('CANCEL','ERROR')
          --and pa.policy_header_id = 25690806
          and ag.ag_contract_id = ach.last_ver_id
          and ag.contract_leader_id = agl.ag_contract_id(+)
          and agl.contract_id = hl.ag_contract_header_id(+)
          and cl.contact_id(+) = hl.agent_id
          and hl.last_ver_id = aglv.ag_contract_id(+)
          and aglv.contract_leader_id = agd.ag_contract_id(+)
          and agd.contract_id = hd.ag_contract_header_id(+)
          and hd.agent_id = cd.contact_id(+)
       ) ag_cur

 WHERE a.payment_templ_id = apt.payment_templ_id
   AND apt.brief = 'PAYMENT'
   AND doc.get_doc_status_id(a.payment_id) = dsr.doc_status_ref_id
   AND dsr.brief <> 'PAID'
   and dsr.name <> 'Аннулирован'
   --Чирков /192022 Доработка АС BI в части обеспечения регистрации    
   AND not exists(select 1       
              from ins.ven_journal_tech_work jtw
                  ,ins.doc_status_ref dsr 
              where jtw.doc_status_ref_id = dsr.doc_status_ref_id
                and jtw.policy_header_id  = ph.policy_header_id
                and dsr.brief             = 'CURRENT'
                and jtw.work_type         = 0) --'Технические работы'
   --Чирков /192022//

   -- Байтин А.
   -- Заявка 131971
   -- Считать что ЭПГ <Оплачен>, если к нему привязана А7 или ПД4 (да же если <документ не оплачен>).
   and not exists (select null
                     from doc_set_off      dso
                         ,ven_ac_payment   apd
                    where dso.parent_doc_id = a.payment_id
                      and dso.child_doc_id  = apd.payment_id
                      and apd.doc_templ_id in (5234/*А7*/,6531/*ПД4*/)
                  )
   --
   AND a.payment_id = dd.child_id
   AND a.payment_id = dso.parent_doc_id (+)
   AND dd.parent_id = p.policy_id
   and p.pol_privilege_period_id = tper.id(+)
   AND ph.product_id = prod.product_id
   AND p.pol_header_id = ph.policy_header_id
   and nvl(p.is_group_flag,0) <> 1
   AND pt.ID = p.PAYMENT_TERM_ID
   AND pt.DESCRIPTION not in ('Единовременно')

   AND pag.policy_header_id = p.pol_header_id
   AND hed.ag_contract_header_id = pag.ag_contract_header_id
   and padd.document_id = pag.p_policy_agent_doc_id
   and doc.get_doc_status_brief(pag.p_policy_agent_doc_id) not in ('CANCEL','ERROR')
   AND dep.department_id = hed.agency_id

   AND a.contact_id = c.contact_id
   and p.collection_method_id = colm.id
   --and colm.description <> 'Прямое списание с карты'
   and ag_cur.policy_header_id(+) = ph.policy_header_id

   and polr.brief = 'Страхователь'
   and pcnt.policy_id = p.policy_id
   and pcnt.contact_policy_role_id = polr.id
   and cpol.contact_id = pcnt.contact_id

   AND pkg_contact.get_primary_address(cpol.contact_id) = ca.ID

   AND f.fund_id = a.fund_id
   /*AND NOT EXISTS (SELECT pr.policy_id
               FROM p_policy pr
               WHERE doc.get_doc_status_brief(pr.policy_id) IN ('READY_TO_CANCEL', 'STOPED', 'CANCEL', 'STOP','INDEXATING')
                     AND pr.pol_header_id = p.pol_header_id)*/
   -- Капля 204271 Добавил в исключения статус RECOVER_DENY
   AND doc.get_doc_status_brief(pkg_policy.get_last_version(p.pol_header_id)) NOT IN ('RECOVER','READY_TO_CANCEL','QUIT_DECL','TO_QUIT','TO_QUIT_CHECK_READY','TO_QUIT_CHECKED','QUIT_REQ_QUERY','QUIT_REQ_GET','QUIT_TO_PAY','QUIT','RECOVER_DENY')
   and tc.id = cpol.contact_type_id
   and cpol.contact_id = per.contact_id
   and (prod.description not like 'КС CR%')--заявка №78308

   and not exists (   select  pp.policy_id
                      from p_policy pp
                           join as_asset a on (pp.policy_id = a.p_policy_id)
                           join p_cover pc on (a.as_asset_id = pc.as_asset_id)
                           join status_hist h on (pc.status_hist_id = h.status_hist_id and h.brief != 'DELETED')
                           join t_prod_line_option opt on (pc.t_prod_line_option_id = opt.id)
                           join t_product_line ll on (opt.product_line_id = ll.id)
                           join t_lob_line tl on (ll.t_lob_line_id = tl.t_lob_line_id)
                           join t_prod_line_opt_peril opr on (opr.product_line_option_id = opt.id)
                           join t_peril prl on (prl.id = opr.peril_id)

                           join ven_c_claim_header ch on (ch.p_policy_id = pp.policy_id and ch.p_cover_id = pc.p_cover_id and prl.id = ch.peril_id)
                           join fund f on (ch.fund_id = f.fund_id)
                           left join c_damage dmg on (dmg.p_cover_id = pc.p_cover_id
                                                      and ch.active_claim_id = dmg.c_claim_id
                                                      and dmg.status_hist_id <> 3)
                           join fund dmgf on (dmgf.fund_id = dmg.damage_fund_id)

                      where tl.brief in ('WOP_Life','PWOP_Life','WOP','PWOP')
                            and pp.policy_id in (select phg.policy_id
                                                 from p_policy phg
                                                 where phg.pol_header_id = ph.policy_header_id)
                            and (select to_char(max(ds.start_date),'dd.mm.yyyy')
                                       from ven_c_claim clm2,
                                            doc_status ds
                                       where clm2.c_claim_header_id = ch.c_claim_header_id
                                             and ds.document_id = clm2.c_claim_id
                                             and ds.doc_status_ref_id = 128) is not null
                            and nvl(nvl(pc.ins_amount,0) * (case when nvl(pc.ins_amount,0) > 0 then round((nvl(dmg.declare_sum,0) - nvl(dmg.decline_sum,0)) * nvl(acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,ch.declare_date),1) / nvl(pc.ins_amount,0),3) else 0 end),0) > 0

   )
   and a.due_date >= to_date('01.01.2008','dd.mm.yyyy')
   --and ph.policy_header_id = 25690806
   --and ph.ids = 1140475581
   --and p.pol_num = '1560104526'
   --and p.policy_id = 20434002
   /*AND mod(MONTHS_BETWEEN(a.DUE_DATE, p.START_DATE),12)<>0*/

   ) a
)
;
