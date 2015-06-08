create materialized view INS_DWH.MV_CR_END_DOGOVORS
build deferred
refresh force on demand
as
select ins.ent.obj_name('DOCUMENT',ph.policy_header_id) dog_num, --номер договора
       cast(null as varchar2(2000))  code,                                         --код продающего подразделения
       cast(null as varchar2(2000))  dog,                                         --ссылка на договор
       pp.policy_id,                                  --ИД версии договора
       ph.start_date,                                --дата начала договора
       pp.end_date,                                  --дата окончания версии
       ins.pkg_payment.get_calc_amount_policy(pp.policy_id)||' '||f.brief amount,    --начисленная премия
       cast(null as varchar2(2000)) pay_amount,                                                --поступившая премия по договору
       cast(null as varchar2(2000)) cont,                                                --контактное лицо
       cast(null as varchar2(2000)) empl,                                                --должность контактного лица
       cast(null as varchar2(2000)) tel,                                                --телефон контактного лица
       ph.description                                       --примечание
from ins.ven_p_pol_header ph,
     ins.ven_p_policy pp,
     ins.ven_fund f
where pp.policy_id=ph.policy_id
      and f.fund_id=ph.fund_id;

