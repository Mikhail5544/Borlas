CREATE OR REPLACE VIEW INS.V_AG_ROLL AS
SELECT v.AG_ROLL_ID AS AG_ROLL_ID,
       v.ENT_ID AS ENT_ID,
       v.DOC_FOLDER_ID AS DOC_FOLDER_ID,
       v.DOC_TEMPL_ID AS DOC_TEMPL_ID,
       v.NOTE AS NOTE,
       v.NUM AS NUM,
       v.REG_DATE AS REG_DATE,
       v.AG_ROLL_HEADER_ID AS AG_ROLL_HEADER_ID,
       v.USER_NAME AS USER_NAME,
       ds.DOC_STATUS_ID as DOC_STATUS_ID,
       dsr.NAME as AG_ROLL_STATUS_NAME,
       ds.USER_NAME AS STATUS_USER_NAME,
       ds.START_DATE AS STATUS_START_DATE,
       v.date_begin,
       v.date_end,v.conclude_date,
       v.ops_sign_date,v.payment_date,v.sofi_begin_date,v.trans_reg_date, v.sofi_end_date,
       v.is_only_nb,
       v.is_calc_sofi,
       v.is_calc_sofi_pay,
       v.is_ops_retention,
       v.rlp_av_need,
       v.rlp_av_smear
  FROM VEN_AG_ROLL v
  LEFT JOIN DOC_STATUS ds ON DS.DOC_STATUS_ID = DOC.GET_LAST_DOC_STATUS_ID(V.AG_ROLL_ID)
  LEFT JOIN VEN_DOC_STATUS_REF dsr on dsr.DOC_STATUS_REF_ID = ds.DOC_STATUS_REF_ID;
grant select on INS.V_AG_ROLL to INS_READ;
