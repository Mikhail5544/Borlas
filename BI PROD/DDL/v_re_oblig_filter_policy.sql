CREATE OR REPLACE FORCE VIEW V_RE_OBLIG_FILTER_POLICY AS
SELECT
            pph.policy_header_id -- заголовок договора страхования
          , pp.policy_id --полис
          , pp.start_date
          , pp.end_date
          , pph.fund_id --валюта ответственности
          , pc.p_cover_id
          , aa.p_asset_header_id --заголовок объекта страхования
          , FILTER.re_contract_ver_id
          FROM
            T_PRODUCT_LINE pl
          , T_PROD_LINE_OPTION plo
          , AS_ASSET aa
          , P_POLICY pp
          , P_POL_HEADER pph
          , T_CONTACT_POL_ROLE cpr
          , P_POLICY_CONTACT ppc
          , P_COVER pc
          , RE_COND_FILTER_OBL FILTER
          WHERE pl.ID = NVL(FILTER.product_line_id, pl.ID)
          AND pl.insurance_group_id = NVL(FILTER.insurance_group_id,pl.insurance_group_id)
          AND plo.product_line_id = pl.ID
          AND cpr.brief = 'Страхователь'
          AND ppc.contact_policy_role_id = cpr.ID
          AND ppc.contact_id = NVL(FILTER.issuer_id, ppc.contact_id)
          AND pp.policy_id = ppc.policy_id
          AND pph.policy_header_id = pp.pol_header_id
          AND pph.product_id = NVL(FILTER.product_id, pph.product_id)
          AND aa.p_policy_id = pp.policy_id
          AND pc.as_asset_id = aa.as_asset_id
          AND pc.t_prod_line_option_id = plo.ID
          AND NOT EXISTS (SELECT 1
                          FROM P_POLICY_AGENT ppa
                              , AG_CONTRACT_HEADER ch
                              , POLICY_AGENT_STATUS pas
                          WHERE ppa.policy_header_id = pph.policy_header_id 
                          AND ch.ag_contract_header_id = ppa.ag_contract_header_id
                          AND pas.policy_agent_status_id = ppa.status_id
                          AND pas.brief NOT IN ('NEW') AND ch.agent_id<>FILTER.agent_id)
          AND NOT EXISTS (SELECT 1
                          FROM RE_COVER rc
                          WHERE rc.p_cover_id = pc.p_cover_id
                            AND rc.re_contract_ver_id = FILTER.re_contract_ver_id
                          )
          --учитываем исключения
          AND NOT EXISTS (SELECT 1
                          FROM RE_CONTRACT_EXC ce
                          WHERE ce.re_contract_id = FILTER.re_main_contract_id
                            AND ce.p_pol_header_id = pph.policy_header_id
                            AND ce.re_contract_version_id = FILTER.re_contract_ver_id
                            AND ce.t_product_line_id = pl.ID
                            AND ce.p_asset_header_id = aa.p_asset_header_id
                          )
;

