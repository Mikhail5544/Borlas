CREATE OR REPLACE PACKAGE pkg_policyform_product IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 05.05.2014 15:30:08
  -- Purpose : 

  /*
    Получение PDF полисных условий
  */
  PROCEDURE get_policyform_product_pdf
  (
    par_policyform_product_id t_policyform_product.t_policyform_product_id%TYPE
   ,par_report                OUT pkg_rep_utils.t_report
  );

END pkg_policyform_product; 
/
CREATE OR REPLACE PACKAGE BODY pkg_policyform_product IS

  /*
    Получение PDF полисных условий
  */
  PROCEDURE get_policyform_product_pdf
  (
    par_policyform_product_id t_policyform_product.t_policyform_product_id%TYPE
   ,par_report                OUT pkg_rep_utils.t_report
  ) IS
    vc_policyform_product_ent CONSTANT entity.brief%TYPE := 'T_POLICYFORM_PRODUCT';
  BEGIN
    par_report.content_type := 'application/pdf';
    par_report.file_name    := 'Полисные условия.pdf';
  
    SELECT tpp.file_body
      INTO par_report.report_body
      FROM t_policyform_product tpp
     WHERE tpp.t_policyform_product_id = par_policyform_product_id;
  
    IF par_report.report_body IS NULL
    THEN
    SELECT sfb.stored_fb
      INTO par_report.report_body
      FROM t_policyform_product tpp
          ,stored_files         sf
          ,stored_files_body    sfb
     WHERE tpp.t_policyform_product_id = par_policyform_product_id
       AND sf.parent_uro_id = tpp.t_policyform_product_id
       AND sf.parent_ure_id = ent.id_by_brief(vc_policyform_product_ent)
       AND sfb.stored_files_body_id = sf.stored_files_id;
    END IF;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001
                             ,'Не удалось найти файл для данных ПУ.');
    WHEN too_many_rows THEN
      raise_application_error(-20001
                             ,'Не удалось однозначно идентифицировать файл для данных ПУ.');
  END;
END pkg_policyform_product; 
/
