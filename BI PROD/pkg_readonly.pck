CREATE OR REPLACE PACKAGE "PKG_READONLY" IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 07.10.2011 11:06:09
  -- Purpose : Обертка для функций других пакетов

  FUNCTION get_doc_status_name
  (
    par_doc_id      IN NUMBER
   ,par_status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  FUNCTION get_last_doc_status_name(par_document_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_doc_status_brief
  (
    par_doc_id      IN NUMBER
   ,par_status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  FUNCTION get_set_off_amount
  (
    par_bill_doc_id     IN NUMBER
   ,par_p_pol_header_id IN NUMBER
   ,par_set_off_doc_id  NUMBER
  ) RETURN NUMBER;

  FUNCTION get_p_agent_current
  (
    par_pol_header_id NUMBER
   ,par_date          DATE DEFAULT NULL
   ,par_return        PLS_INTEGER DEFAULT 1
  ) RETURN NUMBER;

  FUNCTION get_policy_contact
  (
    par_policy_id  NUMBER
   ,par_role_brief VARCHAR2
  ) RETURN NUMBER;

  FUNCTION get_last_version(par_pol_header_id NUMBER) RETURN NUMBER;

  FUNCTION get_previous_version(par_pol_id NUMBER) RETURN NUMBER;

  FUNCTION get_rate_by_id
  (
    par_rate_type_id NUMBER
   ,par_fund_id      NUMBER
   ,par_date         DATE
  ) RETURN NUMBER;

  FUNCTION obj_name
  (
    par_ent_brief IN VARCHAR2
   ,par_obj_id    IN NUMBER
   ,par_obj_date  IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  FUNCTION obj_name
  (
    par_ent_id   IN NUMBER
   ,par_obj_id   IN NUMBER
   ,par_obj_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2;

  FUNCTION get_address_name
  (
    par_zip                VARCHAR2
   ,par_country_name       VARCHAR2
   ,par_region_name        VARCHAR2
   ,par_region_type_name   VARCHAR2
   ,par_province_name      VARCHAR2
   ,par_province_type_name VARCHAR2
   ,par_district_type_name VARCHAR2
   ,par_district_name      VARCHAR2
   ,par_city_type_name     VARCHAR2
   ,par_city_name          VARCHAR2
   ,par_street_name        VARCHAR2
   ,par_street_type_name   VARCHAR2
   ,par_building_name      VARCHAR2
   ,par_house_nr           VARCHAR2
   ,par_house_type         VARCHAR2
   ,par_block_number       VARCHAR2
   ,par_box_number         VARCHAR2
   ,par_appartment_nr      VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_address_name(par_adr v_cn_address%ROWTYPE) RETURN VARCHAR2;

  FUNCTION get_address_name(par_id NUMBER) RETURN VARCHAR2;

  FUNCTION name_by_id(par_ent_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_calc_amount(par_pol_header_id NUMBER) RETURN NUMBER;

  FUNCTION get_to_pay_amount(par_pol_header_id NUMBER) RETURN NUMBER;

  FUNCTION get_pay_pol_header_amount_pfa
  (
    par_start_date      DATE
   ,par_end_date        DATE
   ,par_p_pol_header_id NUMBER
  ) RETURN NUMBER;

  FUNCTION get_last_premium_amount(par_pol_header_id NUMBER) RETURN NUMBER;

  FUNCTION Get_Cross_Rate_By_Brief
  (
    par_Rate_Type_Id   NUMBER
   ,par_Fund_Brief_In  VARCHAR2
   ,par_Fund_Brief_Out VARCHAR2
   ,par_Date           DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER;

  FUNCTION f_d2
  (
    par_damage_id NUMBER
   ,par_value     NUMBER
  ) RETURN NUMBER;

  FUNCTION get_aggregated_string
  (
    par_table     tt_one_col
   ,par_separator VARCHAR2
  ) RETURN VARCHAR2;

  FUNCTION get_splitted_string
  (
    par_string    VARCHAR2
   ,par_separator VARCHAR2
  ) RETURN tt_one_col;

END pkg_readonly;
/
CREATE OR REPLACE PACKAGE BODY "PKG_READONLY" IS

  FUNCTION get_doc_status_name
  (
    par_doc_id      IN NUMBER
   ,par_status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN doc.get_doc_status_name(doc_id => par_doc_id, status_date => par_status_date);
  END;

  FUNCTION get_last_doc_status_name(par_document_id NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN doc.get_last_doc_status_name(p_document_id => par_document_id);
  END get_last_doc_status_name;

  FUNCTION get_doc_status_brief
  (
    par_doc_id      IN NUMBER
   ,par_status_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN doc.get_doc_status_brief(doc_id => par_doc_id, status_date => par_status_date);
  END;

  FUNCTION get_set_off_amount
  (
    par_bill_doc_id     IN NUMBER
   ,par_p_pol_header_id IN NUMBER
   ,par_set_off_doc_id  NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_payment.get_set_off_amount(bill_doc_id     => par_bill_doc_id
                                         ,p_pol_header_id => par_p_pol_header_id
                                         ,set_off_doc_id  => par_set_off_doc_id);
  END;

  FUNCTION get_p_agent_current
  (
    par_pol_header_id NUMBER
   ,par_date          DATE DEFAULT NULL
   ,par_return        PLS_INTEGER DEFAULT 1
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_renlife_utils.get_p_agent_current(par_pol_header_id => par_pol_header_id
                                                ,par_date          => par_date
                                                ,par_return        => par_return);
  END get_p_agent_current;

  FUNCTION get_policy_contact
  (
    par_policy_id  NUMBER
   ,par_role_brief VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_policy.get_policy_contact(p_policy_id => par_policy_id, p_role_brief => par_role_brief);
  END;

  FUNCTION get_last_version(par_pol_header_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN pkg_policy.get_last_version(p_pol_header_id => par_pol_header_id);
  END;

  FUNCTION get_previous_version(par_pol_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN pkg_policy.get_previous_version(p_pol_id => par_pol_id);
  END;

  FUNCTION get_rate_by_id
  (
    par_rate_type_id NUMBER
   ,par_fund_id      NUMBER
   ,par_date         DATE
  ) RETURN NUMBER IS
  BEGIN
    RETURN acc_new.get_rate_by_id(p_rate_type_id => par_rate_type_id
                                 ,p_fund_id      => par_fund_id
                                 ,p_date         => par_date);
  END;

  FUNCTION obj_name
  (
    par_ent_brief IN VARCHAR2
   ,par_obj_id    IN NUMBER
   ,par_obj_date  IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN ent.obj_name(p_ent_brief => par_ent_brief
                       ,p_obj_id    => par_obj_id
                       ,p_obj_date  => par_obj_date);
  END;

  FUNCTION obj_name
  (
    par_ent_id   IN NUMBER
   ,par_obj_id   IN NUMBER
   ,par_obj_date IN DATE DEFAULT SYSDATE
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN ent.obj_name(p_ent_id => par_ent_id, p_obj_id => par_obj_id, p_obj_date => par_obj_date);
  END;

  FUNCTION get_address_name
  (
    par_zip                VARCHAR2
   ,par_country_name       VARCHAR2
   ,par_region_name        VARCHAR2
   ,par_region_type_name   VARCHAR2
   ,par_province_name      VARCHAR2
   ,par_province_type_name VARCHAR2
   ,par_district_type_name VARCHAR2
   ,par_district_name      VARCHAR2
   ,par_city_type_name     VARCHAR2
   ,par_city_name          VARCHAR2
   ,par_street_name        VARCHAR2
   ,par_street_type_name   VARCHAR2
   ,par_building_name      VARCHAR2
   ,par_house_nr           VARCHAR2
   ,par_house_type         VARCHAR2
   ,par_block_number       VARCHAR2
   ,par_box_number         VARCHAR2
   ,par_appartment_nr      VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_contact.get_address_name(zip                => par_zip
                                       ,country_name       => par_country_name
                                       ,region_name        => par_region_name
                                       ,region_type_name   => par_region_type_name
                                       ,province_name      => par_province_name
                                       ,province_type_name => par_province_type_name
                                       ,district_type_name => par_district_type_name
                                       ,district_name      => par_district_name
                                       ,city_type_name     => par_city_type_name
                                       ,city_name          => par_city_name
                                       ,street_name        => par_street_name
                                       ,street_type_name   => par_street_type_name
                                       ,building_name      => par_building_name
                                       ,house_nr           => par_house_nr
                                       ,house_type         => par_house_type
                                       ,block_number       => par_block_number
                                       ,box_number         => par_box_number
                                       ,appartment_nr      => par_appartment_nr);
  END get_address_name;

  FUNCTION get_address_name(par_adr v_cn_address%ROWTYPE) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_contact.get_address_name(v_adr => par_adr);
  END get_address_name;

  FUNCTION get_address_name(par_id NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_contact.get_address_name(p_id => par_id);
  END get_address_name;

  FUNCTION name_by_id(par_ent_id NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN ent.name_by_id(p_ent_id => par_ent_id);
  END name_by_id;

  FUNCTION get_calc_amount(par_pol_header_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN Pkg_Payment.get_calc_amount(p_pol_header_id => par_pol_header_id);
  END get_calc_amount;

  FUNCTION get_to_pay_amount(par_pol_header_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN pkg_payment.get_to_pay_amount(p_pol_header_id => par_pol_header_id);
  END get_to_pay_amount;

  FUNCTION get_pay_pol_header_amount_pfa
  (
    par_start_date      DATE
   ,par_end_date        DATE
   ,par_p_pol_header_id NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_payment.get_pay_pol_header_amount_pfa(p_start_date      => par_start_date
                                                    ,p_end_date        => par_end_date
                                                    ,p_p_pol_header_id => par_p_pol_header_id);
  END get_pay_pol_header_amount_pfa;

  FUNCTION get_last_premium_amount(par_pol_header_id NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN pkg_payment.get_last_premium_amount(p_pol_header_id => par_pol_header_id);
  END get_last_premium_amount;

  FUNCTION get_cross_rate_by_brief
  (
    par_Rate_Type_Id   NUMBER
   ,par_Fund_Brief_In  VARCHAR2
   ,par_Fund_Brief_Out VARCHAR2
   ,par_Date           DATE DEFAULT trunc(SYSDATE, 'dd')
  ) RETURN NUMBER IS
  BEGIN
    RETURN acc.Get_Cross_Rate_By_Brief(p_Rate_Type_Id   => par_Rate_Type_Id
                                      ,p_Fund_Brief_In  => par_Fund_Brief_In
                                      ,p_Fund_Brief_Out => par_Fund_Brief_Out
                                      ,p_Date           => par_Date);
  END get_cross_rate_by_brief;

  FUNCTION f_d2
  (
    par_damage_id NUMBER
   ,par_value     NUMBER
  ) RETURN NUMBER IS
  BEGIN
    RETURN pkg_claim.f_d2(p_damage_id => par_damage_id, VALUE => par_value);
  END f_d2;

  FUNCTION get_aggregated_string
  (
    par_table     tt_one_col
   ,par_separator VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_utils.get_aggregated_string(par_table => par_table, par_separator => par_separator);
  END;

  FUNCTION get_splitted_string
  (
    par_string    VARCHAR2
   ,par_separator VARCHAR2
  ) RETURN tt_one_col IS
  BEGIN
    RETURN pkg_utils.get_splitted_string(par_string => par_string, par_separator => par_separator);
  END;

END pkg_readonly;
/
