CREATE OR REPLACE VIEW V_COMMISS_TARIFF AS
SELECT PCT.T_PROD_COEF_TYPE_ID T_PROD_COEF_TYPE_ID,
       PCT.NAME NAME,
       PCT.BRIEF BRIEF,
       pct.t_prod_coef_tariff_id t_prod_coef_tariff_id,
       t.NAME type_name,
       pct.func_define_type_id func_define_type_id,
       fdt.brief func_define_type_brief,
       fdt.NAME func_define_type_name,
       t.brief type_brief,
       PCT.FACTOR_1,
       A1.NAME factor_1_decs,
       PCT.FACTOR_2,
       a2.NAME factor_2_decs,
       PCT.FACTOR_3,
       a3.NAME factor_3_decs,
       PCT.FACTOR_4,
       a4.NAME factor_4_decs,
       PCT.FACTOR_5,
       a5.NAME factor_5_decs,
       PCT.FACTOR_6,
       a6.NAME factor_6_decs,
       PCT.FACTOR_7,
       a7.NAME factor_7_decs,
       PCT.FACTOR_8,
       a8.NAME factor_8_decs,
       PCT.FACTOR_9,
       a9.NAME factor_9_decs,                                          
       PCT.FACTOR_10,
       a10.NAME factor_10_decs,
       PCT.COMPARATOR_1,
       PCT.COMPARATOR_2,
       PCT.COMPARATOR_3,
       PCT.COMPARATOR_4,
       PCT.COMPARATOR_5,
       PCT.COMPARATOR_6,
       PCT.COMPARATOR_7,
       PCT.COMPARATOR_8,
       PCT.COMPARATOR_9,
       PCT.COMPARATOR_10,
       PCT.R_SQL,
       C1.DESCRIPTION C1_DESC,
       C2.DESCRIPTION C2_DESC,
       C3.DESCRIPTION C3_DESC,
       C4.DESCRIPTION C4_DESC,
       C5.DESCRIPTION C5_DESC,
       C6.DESCRIPTION C6_DESC,
       C7.DESCRIPTION C7_DESC,
       C8.DESCRIPTION C8_DESC,                     
       C9.DESCRIPTION C9_DESC,
       C10.DESCRIPTION C10_DESC,
       pct.sub_t_prod_coef_type_id sub_t_prod_coef_type_id,
       pct2.NAME sub_desc, 
    PCT.NOTE NOTE      
FROM 
  T_PROD_COEF_TYPE pct,
  T_PROD_COEF_TYPE pct2,
  T_ATTRIBUT       A1,
  T_ATTRIBUT       a2,
  T_ATTRIBUT       a3,
  T_ATTRIBUT       a4,
  T_ATTRIBUT       a5,
  T_ATTRIBUT       a6,
  T_ATTRIBUT       a7,
  T_ATTRIBUT       a8,
  T_ATTRIBUT       a9,
  T_ATTRIBUT       a10,                  
  t_comporator_type C1, 
  t_comporator_type C2, 
  t_comporator_type C3, 
  t_comporator_type C4, 
  t_comporator_type C5, 
  t_comporator_type C6, 
  t_comporator_type C7, 
  t_comporator_type C8, 
  t_comporator_type C9, 
  t_comporator_type C10,
  T_PROD_COEF_TARIFF t,
  FUNC_DEFINE_TYPE fdt
WHERE PCT.COMPARATOR_1 = C1.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_2 = C2.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_3 = C3.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_4 = C4.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_5 = C5.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_6 = C6.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_7 = C7.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_8 = C8.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_9 = C9.COMPORATOR_ID(+) 
  AND PCT.COMPARATOR_10 = C10.COMPORATOR_ID(+)
  AND pct.factor_1=A1.t_attribut_id(+)
  AND pct.factor_2=a2.t_attribut_id(+)
  AND pct.factor_3=a3.t_attribut_id(+)
  AND pct.factor_4=a4.t_attribut_id(+)
  AND pct.factor_5=a5.t_attribut_id(+)
  AND pct.factor_6=a6.t_attribut_id(+)
  AND pct.factor_7=a7.t_attribut_id(+)
  AND pct.factor_8=a8.t_attribut_id(+)
  AND pct.factor_9=a9.t_attribut_id(+)
  AND pct.factor_10=a10.t_attribut_id(+)
  AND t.t_prod_coef_tariff_id(+)= pct.t_prod_coef_tariff_id
  AND pct.sub_t_prod_coef_type_id=pct2.t_prod_coef_type_id(+)
  AND fdt.func_define_type_id (+)= pct.func_define_type_id;
