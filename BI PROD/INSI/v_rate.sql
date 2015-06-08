create or replace force view v_rate as
select t.rate_id,
       t.ent_id,
       t.filial_id,
       t.ext_id,
       t.base_fund_id,
       t.contra_fund_id,
       t.rate_date,
       t.rate_type_id,
       t.rate_value
from ins.rate t;

