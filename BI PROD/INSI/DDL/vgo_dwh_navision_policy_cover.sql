create or replace force view vgo_dwh_navision_policy_cover as
select
P_POLICY.POL_HEADER_ID,
max(P_POLICY.POLICY_ID) POLICY_ID,
max(PC.AS_ASSET_ID) AS_ASSET_ID,
max(PC.P_COVER_ID) P_COVER_ID,
TPL.ID PRODUCT_LINE_ID,
TPL.DESCRIPTION PROCUCT_LINE_NAME,
nvl(sum(PC.Ins_Amount),0)*100 Ins_amount,
nvl(sum(PC.Premium),0)*100 premium,
case when (min(PC.START_DATE) < to_date('01.01.2004','DD.MM.YYYY') or min(PC.START_DATE) > to_date('01.01.2100','DD.MM.YYYY'))
     then to_date('01.01.1753','DD.MM.YYYY') else min(PC.START_DATE) end START_DATE,
case when (max(PC.End_Date) < to_date('01.01.2004','DD.MM.YYYY') or max(PC.End_Date) > to_date('01.01.2200','DD.MM.YYYY'))
     then to_date('01.01.1753','DD.MM.YYYY') else max(PC.End_Date) end End_Date,
TIG.T_INSURANCE_GROUP_ID,
TIG.LIFE_PROPERTY LIFE_PROPERTY_RSBU,
nvl(round(sum(PC.FEE),2),0)*100 brutto_premium
--TIG.DESCRIPTION,
--TIG.Brief

from
     ins.p_cover PC,
     ins.t_prod_line_option TPLO,
     ins.t_product_line TPL,
     ins.t_insurance_group TIG,
     ins.as_asset aa,
     ins.p_policy P_POLICY,
     (
     select policy_id
     from (
           select
              max(pp.version_num) over(partition by pp.pol_header_id) m,
              pp.policy_id,
              pp.version_num
           from ins.p_policy pp
          )
     where m = version_num
     ) active_policy_on_date --определяем ИД последней версии договора


where
      PC.T_PROD_LINE_OPTION_ID = TPLO.ID
      and TPLO.PRODUCT_LINE_ID = TPL.ID
      and TPL.INSURANCE_GROUP_ID = TIG.T_INSURANCE_GROUP_ID
      and aa.as_asset_id = pc.as_asset_id
      and aa.p_policy_id = P_POLICY.POLICY_ID
      and active_policy_on_date.policy_id = P_POLICY.POLICY_ID

group by
      P_POLICY.POL_HEADER_ID,
      TPL.ID,
      TPL.DESCRIPTION,
      TIG.T_INSURANCE_GROUP_ID,
      TIG.LIFE_PROPERTY
;

