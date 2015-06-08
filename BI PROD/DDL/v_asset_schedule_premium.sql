create or replace force view v_asset_schedule_premium as
select "AS_ASSET_HEADER_ID",
       "YEAR",
       "PLO_ASSET_ID",
       "PLO_ASSET_PERSON_ID",
       "PLO_PERSON_ID",
       "ASSET_PREMIUM",
       "ASSET_PERSON_PREMIUM",
       "PERSON_PREMIUM",
       "ASSET_TARIFF",
       "ASSET_PERSON_TARIFF",
       "PERSON_TARIFF",
       "ASSET_UNDER_COEF",
       "ASSET_PERSON_UNDER_COEF",
       "PERSON_UNDER_COEF",
       "ASSET_OTHER_COEF",
       "ASSET_PERSON_OTHER_COEF",
       "PERSON_OTHER_COEF"
  from table(INS.PKG_XX_SCHEDULE_PREMIUM.get_schedule_premium(PKG_XX_SCHEDULE_PREMIUM.get_as_asset_header_id));

