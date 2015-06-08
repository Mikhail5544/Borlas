create or replace force view v_cr_pol_journal_asset
(product_name, policy_header_id, pol_ser, pol_num, start_date, end_date, fund, fund_pay, asset_name, ins_amount, premium, deductible_type, deductible_value, confirm_date)
as
select pr.description, -- продукт
       ph.policy_header_id, -- id полиса
       pp.pol_ser, -- серия
       pp.pol_num, -- номер
      
       ph.start_date, -- дата начала
       pp.end_date, -- дата окончания
       f1.brief, -- валюта отв
       f2.brief, -- валюта расчетов,
       ent.obj_name(ass.ent_id,ass.as_asset_id), -- объект страхования
       ass.ins_amount, -- страховая сумма
       ass.ins_premium, -- страховая премия
       decode(dt.description,'Нет',dt.description,dt.description||','||dvt.description),-- тип франшизы
       ass.deductible_value, -- значение франшизы
       pp.confirm_date    -- дата вступления в силу
from ven_p_pol_header ph 
 join ven_p_policy pp on pp.policy_id = ph.policy_id
 join ven_t_product pr on pr.product_id = ph.product_id
 join ven_fund f1 on f1.fund_id = ph.fund_id
 join ven_fund f2 on f2.fund_id = ph.fund_pay_id
 join ven_as_asset ass on ass.p_policy_id = pp.policy_id
 left join ven_t_deductible_type dt on dt.id = ass.t_deductible_type_id
 left join ven_t_deduct_val_type dvt on dvt.id = ass.t_deduct_val_type_id
;

