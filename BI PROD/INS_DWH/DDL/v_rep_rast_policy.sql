CREATE OR REPLACE FORCE VIEW INS_DWH.V_REP_RAST_POLICY AS
SELECT
/*ROWNUM*/ null "пп",
DECODE(a.min_back_stat, 'PAID', 'Зачет', 'Возврат') "Тип операции",
DECODE(ig.life_property, 1, 'Ж', 0, 'НС') "Вид страхования",
a."ИДС",
a."№ полиса",
a."Серия заявления",
a."№ заявления",
a."Название программы",
plo.description "Риски по договору",
pc.p_cover_id "ID покрытия",
plo.id "ID наименования риска",
a."Регион" "Регион из Borlas",
a."Код региона",
a."Страхователь",
a."ИД Страхователя" "ИД Контакта (Страхователь)",
(select decode(tpc.description,'Физическое лицо',tpc.description,'Юридическое лицо')
 from ins.ven_contact c,
      ins.t_contact_type tpc
 where c.contact_id = a."ИД Страхователя"
   and c.contact_type_id = tpc.id) "Тип Страхователя",
(select decode(nvl(c.resident_flag,0),0,'Нерезидент',1,'Резидент','') from ins.ven_contact c where c.contact_id = a."ИД Страхователя") "Резиден/Нерезидент",
(select cca.COUNTRY_NAME from ins.v_cn_contact_address cca where cca.contact_id = a."ИД Страхователя" and ins.pkg_contact.get_primary_address(a."ИД Страхователя") = cca.id(+)) "Страна проживания Страхователя",
null "Contractor № из Navision",
case when nvl(a.beneficiary_pay,'X') = 'X' and a.return_summ <= 0
          then a."Страхователь"
     when nvl(a.beneficiary_pay,'X') = 'X' and a.return_summ > 0
          then ''
     when nvl(a.beneficiary_pay,'X') <> 'X'
          then a.beneficiary_pay
     else
          nvl(a.beneficiary_pay,a."Страхователь")
end "Получатель страх.возмещения",
case when nvl(a.beneficiary_id,0) = 0 and a.return_summ <= 0
          then a."ИД Страхователя"
     when nvl(a.beneficiary_id,0) = 0 and a.return_summ > 0
          then 0
     when nvl(a.beneficiary_id,0) <> 0
          then a.beneficiary_id
     else
          nvl(a.beneficiary_id,a."ИД Страхователя")
end "ИД Контакта(Пол.страх.возм.)",

(select decode(tpc.description,'Физическое лицо',tpc.description,'Юридическое лицо')
 from ins.ven_contact c,
      ins.t_contact_type tpc
 where c.contact_id = (case when nvl(a.beneficiary_id,0) = 0 and a.return_summ <= 0
                                 then a."ИД Страхователя"
                            when nvl(a.beneficiary_id,0) = 0 and a.return_summ > 0
                                 then 0
                            when nvl(a.beneficiary_id,0) <> 0
                                 then a.beneficiary_id
                            else
                                 nvl(a.beneficiary_id,a."ИД Страхователя")
                       end)
   and c.contact_type_id = tpc.id) "Тип пол.страх.возм.",
(select decode(nvl(c.resident_flag,0),0,'Нерезидент',1,'Резидент','')
 from ins.ven_contact c
 where c.contact_id = (case when nvl(a.beneficiary_id,0) = 0 and a.return_summ <= 0
                                 then a."ИД Страхователя"
                            when nvl(a.beneficiary_id,0) = 0 and a.return_summ > 0
                                 then 0
                            when nvl(a.beneficiary_id,0) <> 0
                                 then a.beneficiary_id
                            else
                                 nvl(a.beneficiary_id,a."ИД Страхователя")
                       end)
                       ) "Тип пол.страх.возм. Рез/Нерез",
(select cca.COUNTRY_NAME
 from ins.v_cn_contact_address cca
 where cca.contact_id = a."ИД Страхователя"
   and ins.pkg_contact.get_primary_address(case when nvl(a.beneficiary_id,0) = 0 and a.return_summ <= 0
                                                  then a."ИД Страхователя"
                                             when nvl(a.beneficiary_id,0) = 0 and a.return_summ > 0
                                                  then 0
                                             when nvl(a.beneficiary_id,0) <> 0
                                                  then a.beneficiary_id
                                             else
                                                  nvl(a.beneficiary_id,a."ИД Страхователя")
                                        end) = cca.id(+)) "Страна прож пол.стах.возм.",
a."Агент",
a."Валюта договора",
pc.ins_amount "Страховая сумма",
a."Дата начала ответственности",
a."Дата окончания ответственности",
pc.start_date    "Дата начала по риску",
pc.end_date      "Дата окончания по риску",
NULL "Курс на отчетную дату",
pc.fee     "Сумма премии/взноса",
pc.premium "Годовая премия",
a."Периодичность уплаты взносов",
a.db,
ADD_MONTHS(a.db,12/a.number_of_payments) dg,
a.ppo,
a.po,
 (  SELECT max(ap.amount)
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = a.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID'
           and ap.plan_date = a.db
           ) epg_amount_db,

(select sum(t.acc_amount) from ins.oper o, ins.trans t, ins.account a
where 1=1
and o.oper_id = t.oper_id
and t.ct_account_id = a.account_id
and a.num = '92.01'
and t.trans_amount > 0
and t.a4_ct_uro_id = plo.id
and t.a3_ct_uro_id = aa.p_asset_header_id) charge_amount_rur,

(select sum(t.acc_amount) from ins.oper o, ins.trans t, ins.account a
where 1=1
and o.oper_id = t.oper_id
and t.ct_account_id = a.account_id
and a.num = '92.01'
and t.trans_amount < 0
and t.a4_ct_uro_id = plo.id
and t.a3_ct_uro_id = aa.p_asset_header_id) storno_charge_amount_rur,

(select sum(t.acc_amount)
  FROM INS.TRANS T,
       ins.oper o,
       ins.DOC_SET_OFF  DSO,
       ins.DOCUMENT     D,
       ins.doc_templ    dt,
       ins.trans_templ  tt,
       ins.p_cover pc1,
       ins.as_asset a1
 WHERE

       tt.trans_templ_id = T.TRANS_TEMPL_ID
   AND o.oper_id = t.oper_id
   AND o.document_id    = DSO.DOC_SET_OFF_ID
   and t.obj_ure_id = 305
   and t.obj_uro_id = pc1.p_cover_id
   and pc1.as_asset_id = a1.as_asset_id
   and pc1.t_prod_line_option_id = plo.id
   and a1.p_asset_header_id = aa.p_asset_header_id
   AND DSO.CHILD_DOC_ID = D.DOCUMENT_ID
   AND dt.doc_templ_id  = D.DOC_TEMPL_ID
   AND t.acc_amount >0
   AND ((tt.brief in ('СтраховаяПремияОплачена',
                      'ЗачВзнСтрАг',
                      'ПремияОплаченаПоср',
                      'СтраховаяПремияАвансОпл')
        and dt.brief in ('ПП','ПП_ОБ','ПП_ПС')
        )
        or (tt.brief in ('СтраховаяПремияАвансОпл','УдержКВ') --Убыток и выплата КВ
            and dt.brief in ('PAYORDER_SETOFF','ЗачетУ_КВ')
           )
       )
) payd_amount_rur,

(select sum(t.acc_amount)
  FROM INS.TRANS T,
       ins.oper o,
       ins.DOC_SET_OFF  DSO,
       ins.DOCUMENT     D,
       ins.doc_templ    dt,
       ins.trans_templ  tt,
       ins.p_cover pc1,
       ins.as_asset a1
 WHERE

       tt.trans_templ_id = T.TRANS_TEMPL_ID
   AND o.oper_id = t.oper_id
   AND o.document_id    = DSO.DOC_SET_OFF_ID
   and t.obj_ure_id = 305
   and t.obj_uro_id = pc1.p_cover_id
   and pc1.as_asset_id = a1.as_asset_id
   and pc1.t_prod_line_option_id = plo.id
   and a1.p_asset_header_id = aa.p_asset_header_id
   AND DSO.CHILD_DOC_ID = D.DOCUMENT_ID
   AND dt.doc_templ_id  = D.DOC_TEMPL_ID
   AND t.acc_amount <0
   AND ((tt.brief in ('СтраховаяПремияОплачена',
                      'ЗачВзнСтрАг',
                      'ПремияОплаченаПоср',
                      'СтраховаяПремияАвансОпл')
        and dt.brief in ('ПП','ПП_ОБ','ПП_ПС')
        )
        or (tt.brief in ('СтраховаяПремияАвансОпл','УдержКВ') --Убыток и выплата КВ
            and dt.brief in ('PAYORDER_SETOFF','ЗачетУ_КВ')
           )
       )
) storno_payd_amount_rur,

pc.fee/(SELECT MIN(ap.plan_date) - ADD_MONTHS(MIN(ap.plan_date),-12/a.number_of_payments)+1
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = a.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           AND ap.plan_date > a."Дата расторжения"
       ) "БВ на один день",
a."Кол-во оставшихся опл дней",
a."Статус ДС",
decode(a."Признак статуса К прекращению",1,
(select sum(nvl(pcd.redemption_sum,0))
from ins.as_asset ast,
     ins.P_COVER_DECLINE pcd,
     ins.t_product_line tpl
where ast.p_policy_id = a.past_policy_id
      and pcd.as_asset_id = ast.as_asset_id
      and tpl.id = pl.id
      and pcd.t_product_line_id = tpl.id),
(SELECT nvl(pcsd.value,0)
   FROM ins.POLICY_CASH_SURR   pcs,
        ins.POLICY_CASH_SURR_D pcsd
  WHERE pcs.policy_id = a.policy_id
    AND pcs.t_lob_line_id = ll.t_lob_line_id
    AND pcsd.policy_cash_surr_id = pcs.policy_cash_surr_id
    AND pcsd.start_cash_surr_date < a."Дата расторжения"
    AND pcsd.end_cash_surr_date   > a."Дата расторжения"
    AND ROWNUM = 1
)
) "Выкупная сумма",

case when a.is_group_flag = 1 then

   decode(a."Признак статуса К прекращению",1,
      (select sum(nvl(pcd.return_bonus_part,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),
      (CASE WHEN DECODE(ig.life_property,1,'Ж',0,'НС') = 'НС'
           THEN pc.fee/(SELECT MIN(ap.plan_date) - ADD_MONTHS(MIN(ap.plan_date),-12/a.number_of_payments)+1
                          FROM ins.p_policy   p2,
                               ins.doc_doc    dd,
                               ins.document   d,
                               ins.doc_templ  dt,
                               ins.ac_payment ap
                         WHERE p2.pol_header_id = a.policy_header_id
                           AND dd.parent_id = p2.policy_id
                           AND d.document_id = dd.child_id
                           AND dt.doc_templ_id = d.doc_templ_id
                           AND dt.brief = 'PAYMENT'
                           AND ap.payment_id = d.document_id
                           AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
                           AND ap.plan_date > a."Дата расторжения"
                       ) * a."Кол-во оставшихся опл дней"
           ELSE NULL
       END) )

else

   decode(a."Признак статуса К прекращению",1,
      (select sum(nvl(pcd.return_bonus_part,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),
      (CASE WHEN DECODE(ig.life_property,1,'Ж',0,'НС') = 'НС'
           THEN pc.fee/(SELECT MIN(ap.plan_date) - ADD_MONTHS(MIN(ap.plan_date),-12/a.number_of_payments)+1
                          FROM ins.p_policy   p2,
                               ins.doc_doc    dd,
                               ins.document   d,
                               ins.doc_templ  dt,
                               ins.ac_payment ap
                         WHERE p2.pol_header_id = a.policy_header_id
                           AND dd.parent_id = p2.policy_id
                           AND d.document_id = dd.child_id
                           AND dt.doc_templ_id = d.doc_templ_id
                           AND dt.brief = 'PAYMENT'
                           AND ap.payment_id = d.document_id
                           AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
                           AND ap.plan_date > a."Дата расторжения"
                       ) * a."Кол-во оставшихся опл дней"
           ELSE NULL
       END) )

end "Возврат части премии",

case when a.is_group_flag = 1 then

     case when (select sum(pcd.add_invest_income)
          from ins.as_asset ast,
               ins.P_COVER_DECLINE pcd
          where ast.p_policy_id = a.past_policy_id
                and pcd.as_asset_id = ast.as_asset_id
                --
                and ast.as_asset_id = aa.as_asset_id
                --
                and pcd.t_product_line_id = pl.id) >= 0
     then (select sum(nvl(pcd.add_invest_income,0))
          from ins.as_asset ast,
               ins.P_COVER_DECLINE pcd
          where ast.p_policy_id = a.past_policy_id
                and pcd.as_asset_id = ast.as_asset_id
                --
                and ast.as_asset_id = aa.as_asset_id
                --
                and pcd.t_product_line_id = pl.id)
     else (select sum(adi.add_income_cur)
           from ins.v_add_invest_income adi
           where adi.pol_header_id = a.policy_header_id
                 and adi.t_product_line_id = pl.id
                 and UPPER(adi.as_asset_name) = UPPER(cas.obj_name_orig)
                 and adi.income_date =
                    ( SELECT  MAX( aii2.income_date )
                        FROM  ins.ven_p_add_invest_income aii2
                        WHERE aii2.income_date <= a."Дата расторжения"
                          AND aii2.pol_header_id = policy_header_id
                          AND aii2.t_product_line_id = pl.id )
           )

     end

else

     case when (select sum(pcd.add_invest_income)
          from ins.as_asset ast,
               ins.P_COVER_DECLINE pcd
          where ast.p_policy_id = a.past_policy_id
                and pcd.as_asset_id = ast.as_asset_id
                and pcd.t_product_line_id = pl.id ) >= 0
     then (select sum(nvl(pcd.add_invest_income,0))
          from ins.as_asset ast,
               ins.P_COVER_DECLINE pcd
          where ast.p_policy_id = a.past_policy_id
                and pcd.as_asset_id = ast.as_asset_id
                and pcd.t_product_line_id = pl.id
                )
     else (select sum(adi.add_income_cur)
           from ins.v_add_invest_income adi
           where adi.pol_header_id = a.policy_header_id
                 and adi.t_product_line_id = pl.id
                 and adi.income_date =
                    ( SELECT  MAX( aii2.income_date )
                        FROM  ins.ven_p_add_invest_income aii2
                        WHERE aii2.income_date <= a."Дата расторжения"
                          AND aii2.pol_header_id = policy_header_id
                          AND aii2.t_product_line_id = pl.id )
          )

     end

end "Доп. инвест доход",
NULL "Сумма к возврату в рублях",

case when a.is_group_flag = 1 then

decode(a."Признак статуса К прекращению",1,
      (select case when sum(nvl(pcd.underpayment_actual,0)) > 0 then -sum(nvl(pcd.underpayment_actual,0)) else 0 end
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),NULL)

else

decode(a."Признак статуса К прекращению",1,
      (select case when sum(nvl(pcd.underpayment_actual,0)) > 0 then -sum(nvl(pcd.underpayment_actual,0)) else 0 end
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),NULL)

end "Недоплата (ППУ)",
case when a.is_group_flag = 1 then

decode(a."Признак статуса К прекращению",1,
      (select case when sum(nvl(pcd.admin_expenses,0)) > 0 then -sum(nvl(pcd.admin_expenses,0)) else 0 end
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),NULL)

else

decode(a."Признак статуса К прекращению",1,
      (select case when sum(nvl(pcd.admin_expenses,0)) > 0 then -sum(nvl(pcd.admin_expenses,0)) else 0 end
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),NULL)

end "Адм изд",
case when plt.brief = 'RECOMMENDED' then
        decode(a."Признак статуса К прекращению",1,
        (select nvl(pod.overpayment,0)
         from ins.ven_p_pol_decline pod
         where pod.p_policy_id = a.policy_id),null)
     else 0 end "Переплата",
case when plt.brief = 'RECOMMENDED' then
        decode(a."Признак статуса К прекращению",1,
        (select nvl(pod.medo_cost ,0)
         from ins.ven_p_pol_decline pod
         where pod.p_policy_id = a.policy_id),null)
     else 0 end "Стоимость МО",

case when a.is_group_flag = 1 then

decode(a."Признак статуса К прекращению",1,
      (select sum(nvl(pcd.bonus_off_current,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),NULL)

else

decode(a."Признак статуса К прекращению",1,
      (select sum(nvl(pcd.bonus_off_current,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),NULL)

end "Сторно 92 счета",

case when a.is_group_flag = 1 then

decode(a."Признак статуса К прекращению",1,
      (select sum(nvl(pcd.bonus_off_prev,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),NULL)
else

decode(a."Признак статуса К прекращению",1,
      (select sum(nvl(pcd.bonus_off_prev,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),NULL)

end "91 счет",

(select pd.income_tax_sum
from ins.ven_p_pol_decline pd
where pd.p_policy_id = a.policy_id) "Сумма НДФЛ (для нулевых актов)",
(select pd.act_date
from ins.ven_p_pol_decline pd
where pd.p_policy_id = a.policy_id) "Дата акта",

decode(a."Показывать дату выплаты",1,
        (select pod.issuer_return_date
         from ins.ven_p_pol_decline pod
         where pod.p_policy_id = a.policy_id),null) "Дата выплаты",
null "Судебные расходы",
a."Дата расторжения",
a."Причина расторжения",
a."Инициатор",
a."Вид прекращения",
a."Год расторжения",

(select pd.other_pol_num
 from ins.ven_p_pol_decline pd
 where pd.p_policy_id = a.past_policy_id) "Перенос денег на другой ДС",
(SELECT ppt.pol_header_id
FROM
  ins.DOCUMENT d,
  ins.AC_PAYMENT a,
  ins.DOC_TEMPL dt,
  ins.DOC_DOC dd,
  ins.P_POLICY p,
  ins.doc_set_off f1,
  ins.doc_set_off f2,
  ins.doc_doc ddt,
  ins.p_policy ppt
WHERE d.document_id = a.payment_id
  AND d.doc_templ_id = dt.doc_templ_id
  AND dt.brief IN ('PAYORDBACK','PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
  AND dd.child_id = d.document_id
  AND dd.parent_id = p.policy_id
  and d.document_id = f1.parent_doc_id(+)
  and d.document_id = f2.child_doc_id(+)
  and ddt.child_id = nvl(f1.parent_doc_id,f2.parent_doc_id)
  and ppt.policy_id = ddt.parent_id
  and p.pol_header_id = a.policy_header_id
  and ppt.pol_num = (select pd.other_pol_num
                     from ins.ven_p_pol_decline pd
                     where pd.p_policy_id = a.past_policy_id)
  and rownum = 1) "POL_ID_Head (перенос оплаты)",
null "Перенос денег на тот же ДС",
null "Сумма 92 и 91 счета",
null "Комментарии",
case when plt.brief = 'RECOMMENDED' then
    decode(a."Признак статуса К прекращению",1,
            (select pod.total_fee_payment_sum
             from ins.ven_p_pol_decline pod
             where pod.p_policy_id = a.policy_id),null)
     else 0 end  "Общая сумма уплаченных взносов",
(select c.obj_name_orig from ins.contact c where c.contact_id = ass.assured_contact_id) "Застрахованный",
(select c.contact_id from ins.contact c where c.contact_id = ass.assured_contact_id) "ИД Контакта (Застрахованный)",
a."Наим банковского продукта",
ll.description "Наим группы рисков",
policy_header_id "ИД шапки ДС",
policy_id        "ИД ДС"
FROM (
SELECT
       to_char(ph.ids) "ИДС",
       ph.policy_header_id,
       p.policy_id,
       (SELECT MIN(ins.doc.get_doc_status_brief(ab.payment_id))
          FROM ins.DOCUMENT   db,
               ins.AC_PAYMENT ab,
               ins.DOC_TEMPL  dtb,
               ins.DOC_DOC    ddb
         WHERE db.document_id = ab.payment_id
           AND db.doc_templ_id = dtb.doc_templ_id
           AND dtb.brief IN ('PAYORDBACK','PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
           AND ddb.child_id = db.document_id
           AND ddb.parent_id = p.policy_id
           and ins.doc.get_doc_status_brief(ab.payment_id) <> 'ANNULATED'
       ) min_back_stat,
       p.pol_num "№ полиса",
       p.notice_ser "Серия заявления",
       p.notice_num "№ заявления",
       tp.description "Название программы",
       nvl(depph.name,(select depa.name
                       from ins.p_pol_header pha,
                            ins.p_policy_agent_doc pad,
                            ins.ag_contract_header ach,
                            ins.ag_contract ag,
                            ins.department depa
                       where pha.policy_header_id = ph.policy_header_id
                             and pha.policy_header_id = pad.policy_header_id
                             and pad.ag_contract_header_id = ach.ag_contract_header_id
                             and ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                             and ag.contract_id = ach.ag_contract_header_id
                             and sysdate between ag.date_begin and ag.date_end
                             and nvl(ach.is_new,0) = 1
                             and ag.agency_id = depa.department_id)) "Регион",
       case when nvl(depph.name,'X') = 'X' then
       (select to_char(depa.department_code)
                       from ins.p_pol_header pha,
                            ins.p_policy_agent_doc pad,
                            ins.ag_contract_header ach,
                            ins.ag_contract ag,
                            ins.department depa
                       where pha.policy_header_id = ph.policy_header_id
                             and pha.policy_header_id = pad.policy_header_id
                             and pad.ag_contract_header_id = ach.ag_contract_header_id
                             and ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                             and ag.contract_id = ach.ag_contract_header_id
                             and sysdate between ag.date_begin and ag.date_end
                             and nvl(ach.is_new,0) = 1
                             and ag.agency_id = depa.department_id)
       else SUBSTR(tpr.ocatd,1,2) end "Код региона",
       ins.pkg_policy.get_policy_contact(p.policy_id, 'Страхователь') "ИД Страхователя",
       ins.ent.obj_name('CONTACT',ins.pkg_policy.get_policy_contact(p.policy_id, 'Страхователь')) "Страхователь",
       (select cag.obj_name_orig
        from ins.p_pol_header pha,
             ins.p_policy_agent_doc pad,
             ins.ag_contract_header ach,
             ins.contact cag
        where pha.policy_header_id = ph.policy_header_id
              and pha.policy_header_id = pad.policy_header_id
              and pad.ag_contract_header_id = ach.ag_contract_header_id
              and ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
              and nvl(ach.is_new,0) = 1
              and ach.agent_id = cag.contact_id) "Агент",
       f.brief "Валюта договора",
       ph.start_date "Дата начала ответственности",
       p.end_date    "Дата окончания ответственности",
       tpt.description  "Периодичность уплаты взносов",
       tpt.number_of_payments,
       (SELECT MIN(ap.plan_date) - pgkr.decline_date
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           and ap.plan_date > pgkr.decline_date
       ) "Кол-во оставшихся опл дней",

       (SELECT MAX(ap.plan_date)
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID') db,

         (SELECT sum(ap.amount)
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           and ap.plan_date <= pgkr.decline_date) ppo,

       (SELECT SUM(ins.Pkg_Payment.get_set_off_amount(ap.payment_id, ph.policy_header_id,NULL))
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           and dd.parent_id = p2.policy_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID'
           and ap.plan_date <= pgkr.decline_date) po,

       (SELECT SUM(dd.parent_amount - ins.Pkg_Payment.get_set_off_amount(ap.payment_id, ph.policy_header_id,NULL))
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           and dd.parent_id = p2.policy_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ap.plan_date <= pgkr.decline_date
       )"Размер переплаты/недоплаты",
       to_char(pgkr.decline_date,'dd.mm.yyyy') "Дата расторжения",
       tdr.name "Причина расторжения",
       case tdr.name when 'Неоплата очередного взноса' then 'Страховщик'
                     when 'Окончание выжидательного периода' then 'Страховщик'
                     when 'Увеличение степени страхового риска' then 'Страховщик'
                     when 'Неоплата первого взноса' then 'Страховщик'
                     when 'Отказ Страховщика' then 'Страховщик'
                     when 'Заявление клиента' then 'Страхователь'
                     when 'Отказ страхователя от НУ' then 'Страхователь'
                     when 'Решение суда (аннулирование)' then 'Иное'
                     when 'Решение суда (расторжение)' then 'Иное'
                     when 'Смерть Страхователя' then 'Иное'
                     when 'Смерть Застрахованного' then 'Иное'
                     when 'Отказ Страхователя от договора' then 'Страхователь'
                     else ''
       end "Инициатор",
       to_char(pgkr.decline_date,'yyyy') "Год расторжения",
       case tdr.name when 'Неоплата очередного взноса' then 'Расторжение'
                     when 'Окончание выжидательного периода' then 'Расторжение'
                     when 'Увеличение степени страхового риска' then 'Расторжение'
                     when 'Неоплата первого взноса' then 'Аннулирование'
                     when 'Отказ Страховщика' then 'Аннулирование'
                     when 'Заявление клиента' then 'Расторжение'
                     when 'Отказ страхователя от НУ' then 'Аннулирование'
                     when 'Решение суда (аннулирование)' then 'Аннулирование'
                     when 'Решение суда (расторжение)' then 'Расторжение'
                     when 'Смерть Страхователя' then 'Расторжение'
                     when 'Смерть Застрахованного' then 'Расторжение'
                     when 'Отказ Страхователя от договора' then 'Аннулирование'
                     else tdt.name
       end "Вид прекращения",
       ins.doc.get_doc_status_name(pgkr.policy_id) "Статус ДС",
       decode(ins.doc.get_doc_status_name(pgkr.policy_id),'К прекращению',1,
                                                          'К прекращению. Готов для проверки',1,
                                                          'К прекращению. Проверен',1,
                                                          'Прекращен',1,
                                                          0) "Признак статуса К прекращению",
       decode(ins.doc.get_doc_status_name(pgkr.policy_id),'К прекращению',1,
                                                          'К прекращению. Готов для проверки',1,
                                                          'К прекращению. Проверен',1,
                                                          'Прекращен',1,
                                                          'Прекращен.К выплате',1,
                                                          'Прекращен. Запрос реквизитов',1,
                                                          'Прекращен. Реквизиты получены',1,
                                                          0) "Показывать дату выплаты",                                                          
                                                          
                                                          
       p.version_num,
       (select pas.policy_id
       from ins.p_policy pas
       where pas.pol_header_id = ph.policy_header_id
             and pas.version_num = pgkr.version_num - 1) past_policy_id,
       p.is_group_flag,

(select c.obj_name_orig
from ins.ven_ac_payment ap,
     ins.doc_doc dd,
     ins.ac_payment_templ apt,
     ins.doc_templ dt,
     ins.contact c,
     ins.cn_contact_bank_acc ccba --Чирков добавил 209752	доработка получателя
where dd.parent_id = pgkr.policy_id
  AND ap.payment_id = dd.child_id
  AND ap.payment_templ_id = apt.payment_templ_id
  AND apt.brief = 'PAYREQ'
  AND ap.doc_templ_id = dt.doc_templ_id
  AND dt.brief = 'PAYREQ'
  --Чирков комментарий 209752	доработка получателя
  --and c.contact_id        = ap.contact_id                            
  --Чирков добавил 209752	доработка получателя
  and ap.contact_bank_acc_id  = ccba.id
  and ccba.owner_contact_id   = c.contact_id
  --  
  and rownum = 1) beneficiary_pay,

(select c.contact_id
from ins.ven_ac_payment ap,
     ins.doc_doc dd,
     ins.ac_payment_templ apt,
     ins.doc_templ dt,
     ins.contact c,
     ins.cn_contact_bank_acc ccba --Чирков добавил 209752	доработка получателя
where dd.parent_id = pgkr.policy_id
  AND ap.payment_id = dd.child_id
  AND ap.payment_templ_id = apt.payment_templ_id
  AND apt.brief = 'PAYREQ'
  AND ap.doc_templ_id = dt.doc_templ_id
  AND dt.brief = 'PAYREQ'
  --Чирков комментарий 209752	доработка получателя
  --and c.contact_id        = ap.contact_id                            
  --Чирков добавил 209752	доработка получателя
  and ap.contact_bank_acc_id  = ccba.id
  and ccba.owner_contact_id   = c.contact_id
  --      
  and rownum = 1) beneficiary_id,
 pgkr.return_summ,
 cr_prod.description "Наим банковского продукта"

  FROM ins.p_policy     p,
       ins.p_pol_header ph,
       ins.t_product    tp,
       (select prod1.description, prod1.product_id from ins.t_product prod1 where prod1.brief like '%CR%') cr_prod,
       ins.department depph,
       ins.t_province   tpr,
       ins.fund                f,
       ins.t_payment_terms     tpt,
       ins.p_policy         pgkr,
       ins.t_decline_reason tdr,
       ins.t_decline_type   tdt
 WHERE 1=1
   AND p.policy_id = ph.policy_id
   AND tp.product_id = ph.product_id
   AND tp.product_id = cr_prod.product_id (+)
   AND tpr.province_id(+) = p.region_id
   AND ph.agency_id = depph.department_id(+)
   AND f.fund_id = ph.fund_id
   AND tpt.id = p.payment_term_id
   AND pgkr.pol_header_id = ph.policy_header_id
   AND ins.doc.get_doc_status_brief(pgkr.policy_id) in ('READY_TO_CANCEL','QUIT_DECL','TO_QUIT','TO_QUIT_CHECK_READY','TO_QUIT_CHECKED','QUIT_REQ_QUERY','QUIT_REQ_GET','QUIT_TO_PAY','QUIT')
   AND pgkr.policy_id  = (select max(ppl.policy_id) from ins.p_policy ppl where ppl.pol_header_id = ph.policy_header_id)
   AND tdr.t_decline_reason_id = pgkr.decline_reason_id
   AND tdt.t_decline_type_id(+) = pgkr.decline_type_id
   --and ph.policy_header_id in (25295935)
) a,
      ins.as_asset            aa,
      ins.as_assured          ass,
      ins.contact             cas,
      ins.status_hist         sha,
      ins.p_cover             pc,
      ins.status_hist         shp,
      ins.t_prod_line_option  plo,
      ins.t_product_line      pl,
      ins.t_product_line_type plt,
      ins.t_lob_line          ll,
      ins.t_insurance_group   ig
WHERE aa.p_policy_id = a.past_policy_id
  AND sha.status_hist_id = aa.status_hist_id
  AND sha.brief <> 'DELETED'
  AND pc.as_asset_id = aa.as_asset_id
  AND aa.as_asset_id = ass.as_assured_id(+)
  AND ass.assured_contact_id = cas.contact_id(+)
  AND shp.status_hist_id = pc.status_hist_id
  AND plo.id = pc.t_prod_line_option_id
  AND plo.product_line_id = pl.id
  AND pl.t_lob_line_id = ll.t_lob_line_id
  AND pl.product_line_type_id = plt.product_line_type_id
  AND ll.insurance_group_id = ig.t_insurance_group_id
  --and policy_header_id in (25295935);
;

