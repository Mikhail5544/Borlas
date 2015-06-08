CREATE OR REPLACE PACKAGE pkg_products_riders_rep IS

  -- Author  : VESELEK
  -- Created : 15.11.2013 17:26:52
  -- Purpose : Вспомогательный пакет для работы с отчетом DWH_Payments.Products_Riders

  FUNCTION fill_table
  (
    p_date_from DATE
   ,p_date_to   DATE
  ) RETURN NUMBER;

  PROCEDURE set_pol_header_table;
  PROCEDURE set_p_policy_table;
  PROCEDURE set_p_cover_table;
  PROCEDURE set_ac_payment_table
  (
    p_date_from DATE
   ,p_date_to   DATE
  );
  PROCEDURE set_oper_trans_table;
  /*Веселуха Е.В.
    05.11.2013
    Определение наличия дополнительной программы "Инвест-Резерв" и/или
    "Помощь при женских онкологических заболеваниях" и/или
    "Подари жизнь" и/или
    "Первичное диагностирование смертельно опасного заболевания"
    Параметр: ИД договора страхования
  */
  FUNCTION is_products_riders(par_p_pol_header_id NUMBER) RETURN NUMBER;

END pkg_products_riders_rep;
/
CREATE OR REPLACE PACKAGE BODY pkg_products_riders_rep IS

  PROCEDURE truncate_table_products_riders IS
  BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.TBL_PR_POL_HEADER';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.TBL_PR_P_POLICY';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.TBL_PR_P_COVER';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.TBL_PR_AC_PAYMENT';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE INS.TBL_PR_OPER_TRANS';
  END truncate_table_products_riders;

  FUNCTION fill_table
  (
    p_date_from DATE
   ,p_date_to   DATE
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    truncate_table_products_riders;
    dbms_application_info.set_client_info('Очистили таблицы');
    set_pol_header_table;
    dbms_application_info.set_client_info('Таблица tbl_pr_pol_header заполнилась');
    set_p_policy_table;
    dbms_application_info.set_client_info('Таблица tbl_pr_p_policy заполнилась');
    set_p_cover_table;
    dbms_application_info.set_client_info('Таблица tbl_pr_p_cover заполнилась');
    set_ac_payment_table(p_date_from, p_date_to);
    dbms_application_info.set_client_info('Таблица tbl_pr_ac_payment заполнилась');
    set_oper_trans_table;
    dbms_application_info.set_client_info('Таблица set_oper_trans_table заполнилась');
    RETURN 1;
  END fill_table;

  PROCEDURE set_pol_header_table IS
  BEGIN
  
    INSERT INTO ins.tbl_pr_pol_header
      SELECT ph.policy_header_id
            ,dep.name
            ,prod.description
            ,rfph.name
            ,ph.start_date
            ,f.brief
        FROM ins.p_pol_header   ph
            ,ins.document       dph
            ,ins.doc_status_ref rfph
            ,ins.fund           f
            ,ins.department     dep
            ,ins.t_product      prod
       WHERE ph.policy_id = dph.document_id
         AND dph.doc_status_ref_id = rfph.doc_status_ref_id
         AND ph.fund_id = f.fund_id
         AND ph.agency_id = dep.department_id
         AND ph.product_id = prod.product_id
         AND prod.brief IN ('END'
                           ,'END_2'
                           ,'CHI'
                           ,'CHI_2'
                           ,'TERM'
                           ,'TERM_2'
                           ,'PEPR'
                           ,'PEPR_2'
                           ,'APG'
                           ,'ACC163'
                           ,'ACC164'
                           ,'ACC172'
                           ,'ACC173');
    COMMIT;
  
  END set_pol_header_table;

  PROCEDURE set_p_policy_table IS
  BEGIN
    INSERT INTO ins.tbl_pr_p_policy
      SELECT pol.policy_id
            ,pol.pol_header_id
            ,cpol.obj_name_orig       holder_name
            ,pol.pol_num
            ,pol.end_date             po_end_date
            ,pol.payment_term_id
            ,pol.collection_method_id
        FROM ins.tbl_pr_pol_header ph
            ,ins.p_policy          pol
            ,ins.p_policy_contact  ppc
            ,ins.contact           cpol
       WHERE /*is_products_riders(pol.pol_header_id) = 1*/
       ph.policy_header_id = pol.pol_header_id
       AND pol.is_group_flag = 0
       AND pol.policy_id = ppc.policy_id
       AND ppc.contact_id = cpol.contact_id
       AND ppc.contact_policy_role_id = 6;
    COMMIT;
  
  END set_p_policy_table;

  PROCEDURE set_p_cover_table IS
  BEGIN
    INSERT INTO ins.tbl_pr_p_cover
      SELECT a.p_policy_id
            ,opt.id         opt_id
            ,pl.description pl_desc
            ,pca.fee
            ,pca.ins_amount
        FROM ins.tbl_pr_p_policy    pp
            ,ins.as_asset           a
            ,ins.p_cover            pca
            ,ins.t_prod_line_option opt
            ,ins.t_product_line     pl
            ,ins.t_lob_line         lb
       WHERE a.p_policy_id = pp.policy_id
         AND a.as_asset_id = pca.as_asset_id
         AND pca.t_prod_line_option_id = opt.id
         AND opt.product_line_id = pl.id
         AND pl.t_lob_line_id = lb.t_lob_line_id
         AND (lb.brief IN ('PEPR_INVEST_RESERVE', 'FEMALE_ONCOLOGY', 'DD') OR
             pl.description = 'Подари жизнь');
    COMMIT;
  
  END set_p_cover_table;

  PROCEDURE set_oper_trans_table IS
  BEGIN
    INSERT INTO ins.tbl_pr_oper_trans
      SELECT o.document_id
            ,tra.a4_dt_uro_id
            ,tra.a4_ct_uro_id
            ,tra.trans_date
            ,tra.trans_amount
        FROM ins.tbl_pr_ac_payment ac
            ,ins.oper              o
            ,ins.trans             tra
       WHERE ac.doc_set_off_id = o.document_id
         AND o.oper_id = tra.oper_id
         AND o.oper_templ_id = 3201 /*1825*/
      /*'Страховая премия аванс оплачен'*/
      /*'Страховая премия оплачена'*/
      ;
    COMMIT;
  END set_oper_trans_table;

  PROCEDURE set_ac_payment_table
  (
    p_date_from DATE
   ,p_date_to   DATE
  ) IS
  BEGIN
    INSERT INTO ins.tbl_pr_ac_payment
      WITH tmp AS
       (SELECT /*+ NO_MERGE*/
         dd.parent_id
        ,aca.payment_id
        ,trunc(ds.start_date) ds_start_date
        ,dsf.doc_set_off_id
        ,aca.plan_date
          FROM ins.tbl_pr_p_policy pp
              ,ins.doc_doc         dd
              ,ins.ac_payment      aca
              ,ins.document        dc
              ,ins.doc_status      ds
              ,ins.doc_set_off     dsf
         WHERE dd.parent_id = pp.policy_id
           AND dd.child_id = dc.document_id
           AND dc.document_id = aca.payment_id
           AND dc.doc_templ_id = 4 /*'PAYMENT'*/
           AND dc.doc_status_ref_id = 6 /*'PAID'*/
           AND dc.doc_status_id = ds.doc_status_id
           AND dc.document_id = dsf.parent_doc_id
           AND dsf.cancel_date IS NULL)
      SELECT * FROM tmp WHERE tmp.ds_start_date BETWEEN p_date_from AND p_date_to;
  
    /*SELECT dd.parent_id
         ,aca.payment_id
         ,trunc(dsa.start_date) ds_start_date
         ,dsf.doc_set_off_id
         ,aca.plan_date
     FROM (SELECT d.parent_id
                 ,d.child_id
             FROM ins.doc_doc d
            WHERE EXISTS (SELECT NULL FROM ins.tbl_pr_p_policy pp WHERE pp.policy_id = d.parent_id)) dd
         ,ins.ven_ac_payment aca
         ,(SELECT ds.doc_status_id
                 ,ds.start_date
             FROM ins.doc_status ds
            WHERE trunc(ds.start_date) BETWEEN p_date_from AND p_date_to) dsa
         ,ins.doc_set_off dsf
    WHERE dd.child_id = aca.payment_id
      AND aca.doc_templ_id = 4
      AND aca.doc_status_ref_id = 6
      AND dsa.doc_status_id = aca.doc_status_id
      AND dsf.parent_doc_id = aca.payment_id
      AND dsf.cancel_date IS NULL;*/
    COMMIT;
  
  END set_ac_payment_table;

  /*Веселуха Е.В.
    05.11.2013
    Определение наличия дополнительной программы "Инвест-Резерв" и/или
    "Помощь при женских онкологических заболеваниях" и/или
    "Подари жизнь" и/или
    "Первичное диагностирование смертельно опасного заболевания"
    Параметр: ИД договора страхования
  */
  FUNCTION is_products_riders(par_p_pol_header_id NUMBER) RETURN NUMBER IS
    v_proc_name VARCHAR2(20) := 'is_products_riders';
  
    v_is_exists NUMBER;
  BEGIN
  
    SELECT COUNT(1)
      INTO v_is_exists
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ins.p_pol_header       ph
                  ,ins.as_asset           a
                  ,ins.p_cover            pc
                  ,ins.t_prod_line_option opt
                  ,ins.t_product_line     pl
                  ,ins.t_lob_line         lb
             WHERE ph.policy_header_id = par_p_pol_header_id
               AND ph.policy_id = a.p_policy_id
               AND a.as_asset_id = pc.as_asset_id
               AND pc.t_prod_line_option_id = opt.id
               AND opt.product_line_id = pl.id
               AND pl.t_lob_line_id = lb.t_lob_line_id
               AND (lb.brief IN ('PEPR_INVEST_RESERVE', 'FEMALE_ONCOLOGY', 'DD') OR
                   pl.description = 'Подари жизнь'));
  
    RETURN v_is_exists;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка выполнения процедуры: ' || v_proc_name || ' - ' || SQLERRM);
  END is_products_riders;

END pkg_products_riders_rep;
/
