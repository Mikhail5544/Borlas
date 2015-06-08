create or replace force view vgo_dwh_fino as
select
    trans.trans_id,
    trans.trans_date,
    trans.trans_templ_id,
    /*
    case
    when (nvl(trans.reg_date,to_date('01.01.1753','DD.MM.YYYY')) < to_date('01.01.2005','DD.MM.YYYY'))
         or (nvl(trans.reg_date,to_date('01.01.1753','DD.MM.YYYY')) > to_date('01.01.2020','DD.MM.YYYY')) then to_date('01.01.1753','DD.MM.YYYY')
    else nvl(trans.reg_date,to_date('01.01.1753','DD.MM.YYYY'))
    end reg_date,
    */
    to_date('01.01.1753','DD.MM.YYYY') reg_date,
    to_date('01.01.1753','DD.MM.YYYY') doc_date,
--    nvl(trans.doc_date,to_date('01.01.1753','DD.MM.YYYY')) doc_date,
    trans.acc_fund_id CURRENCY,
    trans.trans_amount*100 AMOUNT_RUR100,
    trans.acc_amount*100 AMOUNT_CUR100,
    trans.acc_rate*10000 acc_rate10000,
    pp.policy_id POLICY_ID,
    pp.pol_header_id POL_HEADER_ID,
    pp.version_num POL_VERSION_NO,
 --   trans.a4_ct_uro_id PROD_LINE_
 --   pc.p_cover_id,
    tpl.id PROD_LINE_ID,
    tig.life_property,
    tplo.description,
    0 AG_CON_HEADER_ID,
    0 AG_AV_ID,
    0 AG_CATEGORY
--    trans.obj_ure_id,
--    trans.a4_dt_ure_id
--    trans.a2_ct_ure_id,
--    trans.a4_ct_ure_id

from
    ins.trans trans,
    ins.p_policy pp,
--    ins.p_cover pc,
    ins.t_prod_line_option TPLO,
    ins.t_product_line TPL,
    ins.t_insurance_group TIG--,
--    ins.as_asset aa
where
   -- премия начислена, Страховая премия оплачена, Страховая премия аванс оплачен
   ((trans.trans_templ_id = 21)  or (trans.trans_templ_id in (44,741) and trans.dt_account_id = 122))

--     trans.trans_templ_id = 741
    and trans.a2_ct_uro_id = pp.policy_id (+)
    and trans.a4_ct_uro_id = tplo.id (+)
--    and trans.obj_uro_id = pc.p_cover_id (+)
--   and pc.as_asset_id = aa.as_asset_id (+)
--   and aa.p_policy_id = pp.policy_id (+)
--    and PC.T_PROD_LINE_OPTION_ID = TPLO.ID (+)
    and TPLO.PRODUCT_LINE_ID = TPL.ID (+)
    and TPL.INSURANCE_GROUP_ID = TIG.T_INSURANCE_GROUP_ID (+)
  and trans.trans_date between to_date('01.01.2009', 'DD.MM.YYYY') and to_date('31.03.2009', 'DD.MM.YYYY')
/*
and pp.pol_header_id in (
6179663,6200792,6201222,6201846,6202615,6202948,6203227,6204806,6205175,6205925,6206219,6207636,6208122,6208423,6211115,6212098,6212644,6213159,6214392,
6215180,6216468,6216840,6217007,6217113,6217195,6217924,6218252,6218880,6219304,6219540,6219790,6220077,6220273,6220373,6220485,6220573,6220823,6236688,
6264735,6264796,6292833,6292952,6447865,6506627,6511265,6532454,6539565,6540345,6540912,6541118,6541674
)
*/
--and trans.trans_id > 2038813
--and trans.a2_ct_uro_id = 845378
--select * from ins.t_product_line TPL



UNION ALL

select
    trans.trans_id,
    trans.trans_date,
    trans.trans_templ_id,
--    trans.reg_date,

--    case
--    when (nvl(trans.reg_date,to_date('01.01.1753','DD.MM.YYYY')) < to_date('01.01.2005','DD.MM.YYYY'))
--         or (nvl(trans.reg_date,to_date('01.01.1753','DD.MM.YYYY')) > to_date('01.01.2020','DD.MM.YYYY')) then to_date('01.01.1753','DD.MM.YYYY')
--    else nvl(trans.reg_date,to_date('01.01.1753','DD.MM.YYYY'))
--    end reg_date,

    to_date('01.01.1753','DD.MM.YYYY') reg_date,
    to_date('01.01.1753','DD.MM.YYYY') doc_date,
--    nvl(trans.doc_date,to_date('01.01.1753','DD.MM.YYYY')) doc_date,
    trans.acc_fund_id CURRENCY,
    trans.trans_amount*100 AMOUNT_RUR100,
    trans.acc_amount*100 AMOUNT_CUR100,
    trans.acc_rate*10000 acc_rate10000,
    pp.policy_id POLICY_ID,
    pp.pol_header_id POL_HEADER_ID,
    pp.version_num POL_VERSION_NO,
 --   trans.a4_ct_uro_id PROD_LINE_
 --   pc.p_cover_id,
    tpl.id PROD_LINE_ID,
    tig.life_property,
    tplo.description,
    0 AG_CON_HEADER_ID,
    0 AG_AV_ID,
    0 AG_CATEGORY
--    trans.obj_ure_id,
--    trans.a4_dt_ure_id
--    trans.a2_ct_ure_id,
--    trans.a4_ct_ure_id

from
    ins.trans trans,
    ins.p_policy pp,
    ins.p_cover pc,
    ins.t_prod_line_option TPLO,
    ins.t_product_line TPL,
    ins.t_insurance_group TIG,
    ins.as_asset aa
where
   -- Премия оплачена посредником
 --  ((trans.trans_templ_id = 661 and trans.dt_account_id = 122) or (trans.trans_templ_id = 51))
     trans.trans_templ_id = 661
     and trans.dt_account_id = 122
--     trans.trans_templ_id = 741
--    and trans.a2_ct_uro_id = pp.policy_id (+)
--    and trans.a4_ct_uro_id = tplo.id (+)
    and trans.obj_uro_id = pc.p_cover_id (+)
   and pc.as_asset_id = aa.as_asset_id (+)
   and aa.p_policy_id = pp.policy_id (+)
    and PC.T_PROD_LINE_OPTION_ID = TPLO.ID (+)
    and TPLO.PRODUCT_LINE_ID = TPL.ID (+)
    and TPL.INSURANCE_GROUP_ID = TIG.T_INSURANCE_GROUP_ID (+)
and trans.trans_date between to_date('01.01.2009', 'DD.MM.YYYY') and to_date('31.03.2009', 'DD.MM.YYYY')

--and trans.trans_id > 2038813
--and trans.a2_ct_uro_id = 845378
--select * from ins.t_product_line TPL

UNION ALL
--КОМИССИОННОЕ ВОЗНАГРАЖДЕНИЕ
select
0                 as TRANS_ID,
t_av.date_trance  as TRANS_DATE,
42                as TRANS_TEMPL_ID,
t_av.date_trance                    as REG_DATE,
t_av.date_trance                    as DOC_DATE,
122                                 as CURRENCY,
round(t_av.trans_amount,2)*100      as AMMOUNT_RUR100,
round(t_av.trans_amount,2)*100      as AMMOUNT_CUR100,
1                                   as ACC_RATE10000,
pp.policy_id                        as POLICY_ID,
pp.pol_header_id                    as POL_HEADER_ID,
pp.version_num                      as POL_VERSION_NO,
TPL.ID                              as PROD_LINE_ID,
TIG.Life_Property                   as LIFE_PROPERTY,
TPL.DESCRIPTION                     as DESCRIPTION,
nvl(t_av.ag_contract_header_id,0)          as AG_CON_HEADER_ID,
t_av.t_ag_av_id                     as AG_AV_ID, -- Вид агентского вознаграждения
--case when t_av.ext_id = 'DAV' then 42
--else 41 end                        as AG_AV_ID, -- Вид агентского вознаграждения
nvl(t_av.ag_category_agent_id,0)           as AG_CATEGORY

from
    ins.trans_av_dwh t_av,
    ins.as_asset AA,
    ins.p_policy pp,
    ins.p_cover pc,
    ins.t_prod_line_option TPLO,
    ins.t_product_line TPL,
    ins.t_insurance_group TIG

where
      t_av.p_cover_id = pc.p_cover_id (+)
      and PC.T_PROD_LINE_OPTION_ID = TPLO.ID (+)
      and TPLO.PRODUCT_LINE_ID = TPL.ID (+)
      and TPL.INSURANCE_GROUP_ID = TIG.T_INSURANCE_GROUP_ID (+)
      and pc.as_asset_id = AA.As_Asset_Id (+)
      and AA.P_POLICY_ID = pp.policy_id (+)

      and t_av.date_trance between to_date('01.10.2009','DD.MM.YYYY') and  to_date('31.12.2009','DD.MM.YYYY')
;

