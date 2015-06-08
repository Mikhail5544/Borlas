CREATE OR REPLACE FORCE VIEW V_POLICY_SCHEDULE_PREMIUM AS
SELECT "POL_HEADER_ID",
       "P_POLICY_ID",
       "YEAR",
       "PLO_ASSET_ID",
       "PLO_ASSET_PERSON_ID",
       "PLO_PERSON_ID",
       "ASSET_PREMIUM",
       "ASSET_PERSON_PREMIUM",
       "PERSON_PREMIUM"
  FROM TABLE(ins.pkg_xx_schedule_premium.get_policy_schedule_premium(pkg_xx_schedule_premium.get_policy_id));

