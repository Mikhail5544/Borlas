CREATE OR REPLACE PROCEDURE DAV_tmp_table_make IS
BEGIN
--DELETE FROM tcal_ppol_header;
EXECUTE immediate 'TRUNCATE TABLE tcal_ppol_header';
INSERT INTO tcal_ppol_header
  (POLICY_HEADER_ID,
   POLICY_ID,
   AGENT,
   POLICY_START_DATE,
   POLICY_END_DATE,
   PHEAD_FUND_ID,
   IS_GROUP_FLAG,
   POLICY_PAYMENT_TERM_ID,
   RATE_BY_DATE,
   PART_AGENT,
   AG_TYPE_RATE_VALUE_ID,
   PD,
   PH,
   PAYMENT_TERM_BRIEF,
   MANAGER,
   AGENT_CONT_SALES_ID,
   CAT_MANAGER)
  (SELECT * FROM ven_tcal_ppol_header);
  COMMIT;

  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'INS'
     ,TabName        => 'TCAL_PPOL_HEADER'
    ,Estimate_Percent  => SYS.DBMS_STATS.AUTO_SAMPLE_SIZE
    ,DEGREE            => 4
    ,CASCADE           => TRUE
    ,No_Invalidate     => FALSE);  

--DELETE FROM ag_all_agent_sgp;
EXECUTE immediate 'TRUNCATE TABLE ag_all_agent_sgp';
INSERT INTO ag_all_agent_sgp
  (AG_CONTRACT_HEADER_ID,
  POL_HEADER_ID,
  POLICY_ID,
  SGP_AMOUNT,
  DATE_POLICY,
  DATE_MONTH)
  (SELECT * FROM v_ag_all_agent_sgp);
  COMMIT;

  SYS.DBMS_STATS.GATHER_TABLE_STATS (
      OwnName        => 'INS'
     ,TabName        => 'ag_all_agent_sgp'
    ,Estimate_Percent  => SYS.DBMS_STATS.AUTO_SAMPLE_SIZE
    ,DEGREE            => 4
    ,CASCADE           => TRUE
    ,No_Invalidate     => FALSE);  
END DAV_tmp_table_make;
/

