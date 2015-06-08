create materialized view INS_DWH.MV_CR_POL_JOURNAL_POLICY_YEAR
build deferred
refresh force on demand
as
select pp.policy_id police_id, -- id полиса
       pr.description product_name, -- продукт
       pp.pol_ser, -- серия
       pp.pol_num, -- номер
       pp.num contract_num, -- номер договора
       pp.notice_num,-- номер заявления
       ins.ent.obj_name('CONTACT',assur.assured_contact_id) as fio_assur_obj,-- застрахованный
       ph.start_date, -- дата начала действия договора
       pp.end_date, -- дата окончания действия договора
       ins.ent.obj_name('CONTACT',agch.agent_id) as agent_id,-- фио агента
       ins.ent.obj_name('CONTACT',agchLead.agent_id) as agent_liader,-- фио руководителя агента
       d.name agensy,-- агенство
       tpt.description period,-- периодичность
       ap.payment_number,-- id планового платежа
       sch.part_amount premium,-- размер премии
       sch.due_date, -- дата платежа
       f1.brief fund, -- валюта ответственноси
       f2.brief fund_pay-- валюта расчетов
from ins.ven_p_pol_header ph
   join ins.ven_p_policy pp on pp.policy_id = ph.policy_id
   --/* агенты
   left join ins.ven_p_policy_agent ppag on ppag.policy_header_id = ph.policy_header_id
   left join ins.ven_ag_contract_header agch on agch.ag_contract_header_id = ppag.ag_contract_header_id
   left join ins.ven_department d on d.department_id = agch.agency_id
   left join ins.ven_ag_contract agc on agch.last_ver_id = agc.ag_contract_id
   left join ins.ven_ag_contract agLead on agLead.ag_contract_id = agc.contract_leader_id
left join ins.ven_ag_contract_header agchLead on agchLead.ag_contract_header_id = agLead.contract_id
 left join ins.ven_policy_agent_status pAgSt on pAgSt.policy_agent_status_id = ppag.status_id
   --*/
   join ins.ven_t_product pr on pr.product_id = ph.product_id
   join ins.ven_fund f1 on f1.fund_id = ph.fund_id
   join ins.ven_fund f2 on f2.fund_id = ph.fund_pay_id
   join ins.ven_as_asset ass on ass.p_policy_id = pp.policy_id
   join ins.ven_t_payment_terms tpt on tpt.id = pp.payment_term_id
   join ins.v_policy_payment_schedule sch on sch.policy_id = pp.policy_id
   join ins.ven_ac_payment ap on ap.payment_id = sch.document_id
   join ins.ven_as_assured assur on assur.as_assured_id = ass.as_asset_id
   where  nvl(pAgSt.brief,'CURRENT') = 'CURRENT';

