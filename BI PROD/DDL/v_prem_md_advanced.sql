CREATE OR REPLACE FORCE VIEW V_PREM_MD_ADVANCED AS
select a."Номер ведомости",
       a."Отчетный период",
       a."Агенство",
       a."АКТ",
       a."Дата/время расчета акта",
       a."Id договора",
       a."Номер договора",
       a."ФИО агента",
       a."Статус АД на ОП",
       a."Статус Агента на ОП",
       a."Статус агента на ПД4/Выращ.",
       a."Id вырастившего",
       a."ФИО вырастившего",
       a."Количествл месяцев работы",
       a."Количество выращ агентов",
       a."Премия",
       a."Полис",
       a."Id ДС",
       a."Заявление",
       a."Дата С",
       a."Срок страхования",
       a."Рассрочка платежа",
       a."Продукт",
       a."АД по ДС",
       a."ФИО агента по ДС",
       a."Страхователь",
       a."Статус МР А Версии МР",
       a."Статус сейчас А версии МР",
       a."Статус сейчас А версии сейчас",
       a."Валюта",
       a."Номер ЭПГ",
       a."Дата ЭПГ",
       a."Статус ЭПГ МР",
       a."Сумма ЭПГ",
       a."Номер платежного док",
       a."Дата ПД",
       a."Коэфф. СГП",
       a."СГП/Поступившие деньги по ДС",
       a."Поступившие деньги по ПД",
       a."СГП по акту (выполнение плана)",
       a."Поступившие деньги по акту",
       a.check_1,
       a.check_2,
       a."Коммися по акту",
       a."Комиссия по премии",
       a."План".sgp_amount    "План.sgp_amount",
       a."План".policy_count  "План.policy_count",
       a."Индивидуальный план".sgp_amount   "Индив план.sgp_amount",
       a."Индивидуальный план".policy_count "Индив план.policy_count"
from(
SELECT arh.num "Номер ведомости",
       to_CHAR(arh.date_end, 'MONTH', 'NLS_DATE_LANGUAGE=RUSSIAN') "Отчетный период",
       ent.obj_name('DEPARTMENT',ach.agency_id) "Агенство",
       apw.ag_perfomed_work_act_id "АКТ",
       apw.date_calc "Дата/время расчета акта",
       ach.ag_contract_header_id "Id договора",
       ach.num "Номер договора",
       ent.obj_name('CONTACT',ach.agent_id) "ФИО агента",
       doc.get_doc_status_name(ac.ag_contract_id, arh.date_end) "Статус АД на ОП",
       (SELECT asa1.name FROM ag_stat_agent asa1 WHERE asa1.ag_stat_agent_id = apw.status_id) "Статус Агента на ОП",
        asa.NAME "Статус агента на ПД4/Выращ.",
       (SELECT achr.ag_contract_header_id
          FROM ag_contract acr,
               ag_contract_header achr
         WHERE acr.ag_contract_id = ac.contract_f_lead_id
           AND acr.contract_id = achr.ag_contract_header_id) "Id вырастившего",
       (SELECT ent.obj_name('CONTACT',achr.agent_id)
          FROM ag_contract acr,
               ag_contract_header achr
         WHERE acr.ag_contract_id = ac.contract_f_lead_id
           AND acr.contract_id = achr.ag_contract_header_id) "ФИО вырастившего",
       apd.mounth_num "Количествл месяцев работы",
       apd.count_recruit_agent "Количество выращ агентов",
       art.NAME "Премия",
       pp.pol_ser||NVL2(pp.pol_ser,'-','')||pp.pol_num "Полис",
       pp.pol_header_id "Id ДС",
       pp.Notice_Ser||NVL2(pp.notice_ser,'-','')||pp.notice_num "Заявление",
       ph.start_date "Дата С",
       apdp.insurance_period "Срок страхования",
       tpt.description "Рассрочка платежа",
       tp.DESCRIPTION "Продукт",
       achp.num "АД по ДС",
       ent.obj_name('CONTACT',achp.agent_id) "ФИО агента по ДС",
       ent.obj_name('CONTACT',pkg_policy.get_policy_contact(pp.policy_id,'Страхователь')) "Страхователь",
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= apdp.policy_status_id) "Статус МР А Версии МР",
       doc.get_doc_status_name(apdp.policy_id) "Статус сейчас А версии МР",
       doc.get_doc_status_name(ph.policy_id) "Статус сейчас А версии сейчас",
       f.NAME "Валюта",
       epg.num "Номер ЭПГ",
       epg.reg_date "Дата ЭПГ",
       (SELECT dsr.name FROM doc_status_ref dsr WHERE dsr.doc_status_ref_id= appad.epg_status_id) "Статус ЭПГ МР",
       epg.amount "Сумма ЭПГ",
       pay.num "Номер платежного док",
       pay.due_date "Дата ПД",
       apdp.policy_agent_part "Коэфф. СГП",
       apdp.summ "СГП/Поступившие деньги по ДС",
       (select dso.set_off_amount
          from doc_set_off dso
         where dso.child_doc_id  = appad.pay_payment_id
           AND dso.parent_doc_id = appad.epg_payment_id
       ) "Поступившие деньги по ПД",
       apw.sgp1 "СГП по акту (выполнение плана)",
       apw.sgp2 "Поступившие деньги по акту",
       check_1,
       check_2,
       apw.SUM "Коммися по акту",
       apd.summ "Комиссия по премии",
       pkg_ag_calc_admin.get_plan(apd.mounth_num,apw.status_id,arh.date_end) "План",
       pkg_ag_calc_admin.get_individual_plan(apw.ag_contract_header_id,arh.date_end) "Индивидуальный план"
  FROM ven_ag_roll_header arh,
       ven_ag_roll ar,
       ag_perfomed_work_act apw,
       ag_perfom_work_det apd,
       ag_rate_type art,
       ag_perfom_work_dpol apdp,
       ag_perf_work_pay_doc appad,
       p_policy pp,
       p_pol_header ph,
       ven_ag_contract_header ach,
       ven_ag_contract_header achp,
       ag_contract ac,
       ven_ac_payment epg,
       ven_ac_payment pay,
       t_product tp,
       ag_stat_agent asa,
       t_payment_terms tpt,
       fund f
 WHERE 1=1
   and (select CLIENT_IDENTIFIER from v$session where audsid = userenv('SESSIONID')) in ('YPLATOVA','TKIM','JKOVRIGINA','IGOVOROV','AKATKEVICH','INS','EGORNOVA')
   and arh.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'prem_md' and param_name = 'rep_num')
   AND ar.num = (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'prem_md' and param_name = 'version_num')
   --AND apdp.policy_id = 10770210
   AND ar.ag_roll_header_id = arh.ag_roll_header_id
   AND apw.ag_roll_id = ar.ag_roll_id
   AND apd.ag_perfomed_work_act_id = apw.ag_perfomed_work_act_id
   AND apdp.ag_perfom_work_det_id = apd.ag_perfom_work_det_id
   AND apd.ag_rate_type_id = art.ag_rate_type_id
   AND appad.ag_preformed_work_dpol_id = apdp.ag_perfom_work_dpol_id
   AND pp.policy_id = apdp.policy_id
   AND pp.pol_header_id = ph.policy_header_id
   AND ach.ag_contract_header_id = apw.ag_contract_header_id
   AND Pkg_Agent_1.get_status_by_date(ach.ag_contract_header_id, arh.date_end) = ac.ag_contract_id
   AND appad.epg_payment_id = epg.payment_id (+)
   AND appad.pay_payment_id = pay.payment_id (+)
   AND asa.ag_stat_agent_id (+) = apdp.ag_status_id
   AND ph.fund_id = f.fund_id
   AND tpt.id = pp.payment_term_id
   AND ph.product_id = tp.product_id
   AND achp.ag_contract_header_id = apdp.ag_contract_header_ch_id
  ORDER BY 3,4,"Премия"
)a
;

