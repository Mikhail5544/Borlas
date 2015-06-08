CREATE OR REPLACE PACKAGE pkg_rep_procedures IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 11.10.2013 17:19:09
  -- Purpose : Пакет процедур, формирующих отчеты в виде BLOB

  PROCEDURE generate_policy_form
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT BLOB
  );

END pkg_rep_procedures;
/
CREATE OR REPLACE PACKAGE BODY pkg_rep_procedures IS

  gc_pkg_name CONSTANT pkg_trace.t_object_name := 'PKG_REP_PROCEDURES';

  gc_pdf_content_type CONSTANT VARCHAR2(255) := 'application/pdf';

  PROCEDURE generate_policy_form
  (
    par_content_type OUT VARCHAR2
   ,par_file_name    OUT VARCHAR2
   ,par_data         OUT BLOB
  ) IS
    v_policy_id             p_policy.policy_id%TYPE;
    v_policyform_product_id p_policy.t_product_conds_id%TYPE;
    v_report                pkg_rep_utils.t_report;
  
  BEGIN
  
    v_policy_id := to_number(repcore.get_context('POL_ID'));
  
    SELECT pp.t_product_conds_id
      INTO v_policyform_product_id
      FROM p_policy pp
     WHERE pp.policy_id = v_policy_id;
  
    pkg_policyform_product.get_policyform_product_pdf(par_policyform_product_id => v_policyform_product_id
                                                     ,par_report                => v_report);
  
    --dbms_lob.createtemporary(lob_loc => par_data, cache => FALSE);
    par_data := v_report.report_body;
  
    par_file_name := v_report.file_name;
  
    par_content_type := v_report.content_type;
  
  END generate_policy_form;
BEGIN
  NULL;
END pkg_rep_procedures;
/
