create or replace force view v_cover as
select plo.description cover_name,
       dt.description ||
       case
         when dt.description <> 'Нет' then
          pc.deductible_value || decode(dvt.description,
                                        'Процент',
                                        '%',
                                        'Количество дней',
                                        ' дн.')
         else
          null
       end deduct_name,
       pv.product_id,
       pc."P_COVER_ID",pc."AS_ASSET_ID",pc."T_PROD_LINE_OPTION_ID",pc."START_DATE",pc."END_DATE",pc."INS_AMOUNT",pc."PREMIUM",pc."TARIFF",pc."T_DEDUCTIBLE_TYPE_ID",pc."T_DEDUCT_VAL_TYPE_ID",pc."DEDUCTIBLE_VALUE",pc."STATUS_HIST_ID",pc."ENT_ID",pc."FILIAL_ID",pc."OLD_PREMIUM",pc."COMPENSATION_TYPE",pc."FEE",pc."IS_HANDCHANGE_AMOUNT",pc."IS_HANDCHANGE_PREMIUM",pc."IS_HANDCHANGE_TARIFF",pc."IS_HANDCHANGE_DEDUCT",pc."DECLINE_DATE",pc."DECLINE_SUMM",pc."IS_DECLINE_CHARGE",pc."IS_DECLINE_COMISSION",pc."IS_HANDCHANGE_DECLINE",pc."IS_AGGREGATE",pc."INS_PRICE",pc."EXT_ID",pc."IS_PROPORTIONAL",pc."RVB_VALUE",pc."K_COEF",pc."S_COEF",pc."NORMRATE_VALUE",pc."COMMENTS",pc."INSURED_AGE",pc."PREMIUM_ALL_SROK",pc."PREMIA_BASE_TYPE",pc."ADDED_SUMM",pc."PAYED_SUMM",pc."DEBT_SUMM",pc."RETURN_SUMM",pc."ACCUM_PERIOD_END_AGE",pc."IS_AVTOPROLONGATION",pc."NETTO_TARIFF",pc."K_COEF_M",pc."K_COEF_NM",pc."S_COEF_M",pc."S_COEF_NM"
  from p_cover            pc,
       t_prod_line_option plo,
       t_product_line     pl,
       t_product_ver_lob  pvl,
       t_product_version  pv,
       t_deductible_type  dt,
       t_deduct_val_type  dvt
 where pc.t_prod_line_option_id(+) = plo.id
   and pl.id = plo.product_line_id
   and pvl.t_product_ver_lob_id = pl.product_ver_lob_id
   and pv.t_product_version_id = pvl.product_version_id
   and pl.visible_flag = 1
   and dt.id(+) = pc.t_deductible_type_id
   and dvt.id(+) = pc.t_deduct_val_type_id;

