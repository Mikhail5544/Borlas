create or replace force view v_cr_end_dogovors as
select ent.obj_name('DOCUMENT',ph.policy_header_id) dog_num, --номер договора
       null code,                                         --код продающего подразделения
       null dog,                                         --ссылка на договор
       pp.policy_id,                                  --ИД версии договора
       ph.start_date,                                --дата начала договора
       pp.end_date,                                  --дата окончания версии
       pkg_payment.get_calc_amount_policy(pp.policy_id)||' '||f.brief amount,    --начисленная премия
       null pay_amount,                                                --поступившая премия по договору
       null cont,                                                --контактное лицо
       null empl,                                                --должность контактного лица
       null tel,                                                --телефон контактного лица
       ph.description                                       --примечание
from ven_p_pol_header ph,
     ven_p_policy pp,
     ven_fund f
where pp.policy_id=ph.policy_id
      and f.fund_id=ph.fund_id
;

