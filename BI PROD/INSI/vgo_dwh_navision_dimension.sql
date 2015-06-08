create or replace force view vgo_dwh_navision_dimension as
select
'BI.PRODUCT'          DIM_CODE,
p.product_id          DIM_VALUE_CODE,
p.description         DIM_NAME,
p.brief               DIM_NAME_2

from ins.t_product p

union all

--Департамент BI.DEPARTMENT
select
'BI.DEPARTMENT'       DIM_CODE,
dp.department_id      DIM_VALUE_CODE,
dp.name               DIM_NAME,
''                    DIM_NAME_2
from ins.department dp

 union all

-- Канал продаж BI.SALES_CHANEL
select
'BI.SALES.CHANEL'     DIM_CODE,
sc.id                 DIM_VALUE_CODE,
sc.description        DIM_NAME,
sc.brief              DIM_NAME_2
from ins.t_sales_channel sc

union all

--Агент BI.AGENT
select
'BI.AGENT'            DIM_CODE,
c.contact_id          DIM_VALUE_CODE,
c.obj_name            DIM_NAME,
c.obj_name_orig       DIM_NAME_2

from ins.ven_ag_contract_header ACH,ins.contact C
where ACH.agent_id = c.contact_id

union all

--Страхователь BI.HOLDER
select
'BI.HOLDER'           DIM_CODE,
c.contact_id          DIM_VALUE_CODE,
c.obj_name            DIM_NAME,
c.obj_name_orig       DIM_NAME_2
from ins.contact c

--ins.p_policy_contact  ppc,
--where ppc.contact_id = c.contact_id and ppc.contact_policy_role_id = 6
where exists ( select ppc.contact_id
               from ins.p_policy_contact  ppc
               where ppc.contact_id = c.contact_id and ppc.contact_policy_role_id = 6 )

union all

--Риски
select
'BI.PRODUCT.LINE' DIM_CODE,
tpl.id            DIM_VALUE_CODE,
tpl.description   DIM_NAME,
''                DIM_NAME_2

from ins.t_product_line tpl

union all
--Страховые группы
select
'BI.INSURANCE.GROUP'     DIM_CODE,
tig.t_insurance_group_id DIM_VALUE_CODE,
tig.description          DIM_NAME,
tig.brief                DIM_NAME_2
from ins.t_insurance_group tig

union all
--регион страхователя BI.HOLDER.REGION
select
'BI.HOLDER.REGION'    DIM_CODE,
pr.province_id        DIM_VALUE_CODE,
pr.province_name      DIM_NAME,
''                    DIM_NAME_2
from ins.t_province pr

union all
--Тип фино
select
'BI.TRANS.TEMPL'    DIM_CODE,
tt.trans_templ_id   DIM_VALUE_CODE,
tt.name             DIM_NAME,
''                  DIM_NAME_2
from ins.trans_templ tt
;

