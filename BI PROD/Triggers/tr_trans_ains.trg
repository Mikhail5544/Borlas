CREATE OR REPLACE TRIGGER ins.tr_trans_ains
  AFTER INSERT /*or update*/
ON ins.trans
  FOR EACH ROW
  WHEN (new.trans_templ_id = 21)
DECLARE
  v_count       NUMBER(1);
  v_cover_id    p_cover.p_cover_id%TYPE;
  v_fee         p_cover.fee%TYPE;
  v_insured_age p_cover.insured_age%TYPE;
  v_ins_amount  p_cover.ins_amount%TYPE;
  v_gender      as_assured.gender%TYPE;
  v_sum_fee     as_asset.fee%TYPE;
BEGIN
  SELECT COUNT(*)
    INTO v_count
    FROM dual
   WHERE EXISTS (SELECT NULL
            FROM p_policy        pp
                ,p_pol_header    ph
                ,t_sales_channel sc
           WHERE pp.policy_id = :new.a2_dt_uro_id
             AND pp.pol_header_id = ph.policy_header_id
             AND ph.sales_channel_id = sc.id
             AND sc.brief IN ('BANK', 'BR', 'BR_WDISC', 'MBG'));
  IF v_count = 1
  THEN
    BEGIN
      SELECT pc.p_cover_id
            ,pc.fee
            ,pc.insured_age
            ,pc.ins_amount
            ,su.gender
            ,se.fee
        INTO v_cover_id
            ,v_fee
            ,v_insured_age
            ,v_ins_amount
            ,v_gender
            ,v_sum_fee
        FROM p_cover    pc
            ,as_assured su
            ,as_asset   se
       WHERE pc.p_cover_id = :new.a5_dt_uro_id
         AND pc.as_asset_id = su.as_assured_id
         AND pc.as_asset_id = se.as_asset_id;
    
      INSERT INTO estimated_liabilities
        (estimated_liabilities_id
        ,trans_id
        ,trans_sum
        ,trans_date
        ,ag_contract_header_id
        ,policy_header_id
        ,policy_id
        ,p_cover_id
        ,p_cover_fee
        ,product_line_id
        ,prod_line_option_id
        ,insurance_period
        ,payment_period
        ,sav_payment_term
        ,assured_gender
        ,sav)
        SELECT sq_estimated_liabilities.nextval
              ,:new.trans_id
              ,:new.trans_amount
              ,trunc(:new.trans_date, 'dd')
              ,ag_contract_header_id
              ,policy_header_id
              ,:new.a2_dt_uro_id AS policy_id
              ,v_cover_id AS p_cover_id
              ,nvl(v_fee * :new.acc_rate, 0) AS p_cover_fee
              ,prod_line_id
              ,:new.a4_dt_uro_id AS prod_line_option_id
              ,insurance_period
              ,payment_period
              ,sav_payment_term
              ,v_gender
              ,pkg_ag_agent_calc.get_sav_bank(ag_contract_header_id
                                             ,prod_line_id
                                             ,v_ins_amount
                                             ,insurance_period
                                             ,payment_period
                                             ,v_gender
                                             ,nvl(v_insured_age, 0)
                                             ,opt.pol_start_date
                                             ,sav_payment_term
                                             ,nvl(v_sum_fee * :new.acc_rate, 0))
          FROM (SELECT (SELECT plo.product_line_id
                          FROM t_prod_line_option plo
                         WHERE plo.id = :new.a4_dt_uro_id) AS prod_line_id
                      ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date) / 12) AS insurance_period
                      ,FLOOR(MONTHS_BETWEEN(:new.trans_date, ph.start_date) / 12) + 1 AS payment_period
                      ,CASE
                         WHEN pt.is_periodical = 1 THEN
                          2
                         ELSE
                          1
                       END AS sav_payment_term
                      ,ph.policy_header_id
                      ,ph.start_date AS pol_start_date
                      ,pp.end_date AS pol_end_date
                      ,ad.ag_contract_header_id
                  FROM p_policy           pp
                      ,p_pol_header       ph
                      ,p_policy_agent_doc ad
                      ,document           dc
                      ,doc_status_ref     dsr
                      ,t_payment_terms    pt
                 WHERE pp.policy_id = :new.a2_dt_uro_id
                   AND pp.pol_header_id = ph.policy_header_id
                   AND ph.policy_header_id = ad.policy_header_id
                   AND ad.p_policy_agent_doc_id = dc.document_id
                   AND dc.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief = 'CURRENT'
                   AND pp.payment_term_id = pt.id) opt;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  END IF;
END tr_trans_ains;
/
