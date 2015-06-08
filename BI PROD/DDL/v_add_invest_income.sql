CREATE OR REPLACE FORCE VIEW V_ADD_INVEST_INCOME AS
SELECT  aii.pol_header_id,
        ph.ids,
        ph.start_date policy_header_start_date,
        pl.description product_line_description,
        aii.as_asset_name,
        aii.add_income_cur,
        aii.add_income_rur,
        aii.income_date,
        aii.t_product_line_id,
        aii.p_add_invest_income_id
  FROM  p_add_invest_income aii,
        t_product_line      pl,
        p_pol_header        ph
  WHERE aii.t_product_line_id = pl.id
    AND aii.pol_header_id = ph.policy_header_id;

