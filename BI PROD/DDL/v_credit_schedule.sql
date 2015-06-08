CREATE OR REPLACE FORCE VIEW V_CREDIT_SCHEDULE AS
SELECT cs.CREDIT_SCHEDULE_ID,
       cs.ENT_ID,
       cs.FILIAL_ID,
       cs.EXT_ID,
       cs.YEAR,
       cs.PAYOFF_DATE,
       cs.REST_AMOUNT,
       cs.CREDIT_CONDITION_ID,
       cc.policy_id
  FROM CREDIT_SCHEDULE cs, CREDIT_CONDITION cc
 WHERE cs.credit_condition_id = cc.credit_condition_id;

