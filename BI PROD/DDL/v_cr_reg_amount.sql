create or replace force view v_cr_reg_amount as
select p.policy_id,
       ent.obj_name('DOCUMENT',p.policy_id) pol_num,
       dsr.num reg_num,
       decode(sm.is_not_med,'1','is not med',decode(sm.is_not_ins,'1','is not ins','is med')) sign,
       decode(f.brief,'RUR',sum(sm.amount_plan),sum(sm.amount_plan)*dsr.rate) summa--заявленная сумма
from ven_dms_serv_reg dsr,
     ven_c_service_med sm,
     ven_as_assured aa,
     ven_fund f,
     ven_p_policy p
where sm.dms_serv_reg_id(+)=dsr.dms_serv_reg_id
      and aa.as_assured_id(+)=sm.as_asset_id
      and f.fund_id=dsr.fund_id
     and p.policy_id(+)=aa.p_policy_id
group by p.policy_id, ent.obj_name('DOCUMENT',p.policy_id), dsr.num, decode(sm.is_not_med,'1','is not med',decode(sm.is_not_ins,'1','is not ins','is med')),f.brief, dsr.rate
;

