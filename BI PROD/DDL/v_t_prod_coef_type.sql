create or replace force view v_t_prod_coef_type as
select t."T_PROD_COEF_TYPE_ID",t."ENT_ID",t."FILIAL_ID",t."EXT_ID",t."BRIEF",t."COMPARATOR_1",t."COMPARATOR_10",t."COMPARATOR_2",t."COMPARATOR_3",t."COMPARATOR_4",t."COMPARATOR_5",t."COMPARATOR_6",t."COMPARATOR_7",t."COMPARATOR_8",t."COMPARATOR_9",t."FACTOR_1",t."FACTOR_10",t."FACTOR_2",t."FACTOR_3",t."FACTOR_4",t."FACTOR_5",t."FACTOR_6",t."FACTOR_7",t."FACTOR_8",t."FACTOR_9",t."FUNC_DEFINE_TYPE_ID",t."NAME",t."NOTE",t."R_SQL",t."SUB_T_PROD_COEF_TYPE_ID",t."T_PROD_COEF_TARIFF_ID",
       tar.name type_name,
       tar.brief type_brief
from ven_t_prod_coef_type t, ven_t_prod_coef_tariff tar
where tar.t_prod_coef_tariff_id (+)=t.t_prod_coef_tariff_id;

