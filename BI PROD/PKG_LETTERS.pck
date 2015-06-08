CREATE OR REPLACE PACKAGE PKG_LETTERS IS

  -- Author  : VESELEK
  -- Created : 19.03.2012 15:51:21
  -- Purpose : 

  PROCEDURE LETTERS_IDX_FORM;
  PROCEDURE RLA_ACT_SECOND_FL(par_roll_id NUMBER);
  PROCEDURE RLA_CALCULATION(par_roll_id NUMBER);
  PROCEDURE RLA_REPORT(par_roll_id NUMBER);
  FUNCTION IS_EXISTS_PARAM_IDX
  (
    par_pol_index_head_id NUMBER
   ,par_pol_head_id       NUMBER
  ) RETURN NUMBER;

END PKG_LETTERS;
/
CREATE OR REPLACE PACKAGE BODY PKG_LETTERS IS

  PROCEDURE LETTERS_IDX_FORM IS
  
    p_policy_header_id       NUMBER;
    p_policy_index_header_id NUMBER;
    p_year_idx               VARCHAR2(5);
    p_mon_idx                VARCHAR2(5);
    p_ident                  VARCHAR2(300);
    p_rep_id                 NUMBER;
    rep_name                 VARCHAR2(30) := 'indexating_report.rdf';
    p_order_num              NUMBER;
    p_num_number             NUMBER;
    v_order_numb             NUMBER := 0;
  
    CURSOR c1 IS(
      SELECT ph.policy_header_id
            ,pih.policy_index_header_id
            ,TO_CHAR(pih.date_index, 'YYYY') year_idx
            ,TO_CHAR(pih.date_index, 'MM') mon_idx
            ,REPLACE(cpol.obj_name_orig || '_' || pol.pol_num, '"', '') file_name
            ,to_number(NVL(pih.order_num, '1')) order_num
            ,row_number() over(PARTITION BY pih.policy_index_header_id ORDER BY ph.policy_header_id) num_number
            ,CASE WHEN (SELECT COUNT(*)
                        FROM ins.ven_policy_index_item pi,
                             ins.document d,
                             ins.doc_status_ref rf
                        WHERE pi.policy_header_id = ph.policy_header_id
                          AND pi.policy_index_header_id != pih.policy_index_header_id
                          AND pi.policy_index_item_id = d.document_id
                          AND d.doc_status_ref_id = rf.doc_status_ref_id
                          AND rf.brief = 'INDEXATING_AGREE'
                        ) = 0 AND MONTHS_BETWEEN(pol.start_date,ph.start_date) / 12 <= 5 THEN (SELECT rp.rep_report_id
                                                                                               FROM ins.rep_report rp
                                                                                               WHERE rp.exe_name = 'indexating_report.rdf')
                    ELSE (SELECT rp.rep_report_id
                          FROM ins.rep_report rp
                          WHERE rp.exe_name = 'indexating_report_more.rdf')
              END report_id
            /*CASE 
               WHEN MONTHS_BETWEEN(pol.start_date, ph.start_date) > 12 THEN
                (SELECT rp.rep_report_id
                   FROM ins.rep_report rp
                  WHERE rp.exe_name = 'indexating_report_more.rdf')
               ELSE
                (SELECT rp.rep_report_id
                   FROM ins.rep_report rp
                  WHERE rp.exe_name = 'indexating_report.rdf')
             END report_id*/
        FROM ins.ven_policy_index_header pih
            ,ins.ven_policy_index_item   ii
            ,ins.p_pol_header            ph
            ,ins.p_policy                pol
            ,ins.t_contact_pol_role      polr
            ,ins.p_policy_contact        pcnt
            ,ins.contact                 cpol
       WHERE pih.policy_index_header_id = ii.policy_index_header_id
         AND doc.get_doc_status_brief(ii.policy_index_item_id) IN ('INDEXATING')
         AND ph.policy_header_id = ii.policy_header_id
         AND ph.policy_header_id = pol.pol_header_id
         AND pol.policy_id = ii.policy_id
         AND polr.brief = 'Страхователь'
         AND pcnt.policy_id = pol.policy_id
         AND pcnt.contact_policy_role_id = polr.id
         AND cpol.contact_id = pcnt.contact_id
         AND NVL(pih.is_form_letters, 0) = 1
         AND EXISTS (SELECT NULL
                FROM ins.cn_contact_address cca
               WHERE cca.contact_id = cpol.contact_id
                 AND cca.status = 1)
         AND NOT EXISTS (SELECT NULL
                FROM ins.tmp_stored_reports rep
               WHERE rep.parent_id = pih.policy_index_header_id));
  BEGIN
  
    OPEN c1;
    LOOP
      FETCH c1
        INTO p_policy_header_id
            ,p_policy_index_header_id
            ,p_year_idx
            ,p_mon_idx
            ,p_ident
            ,p_order_num
            ,p_num_number
            ,p_rep_id;
      EXIT WHEN c1%NOTFOUND;
    
      v_order_numb := p_order_num + p_num_number - 1;
      ins.repcore.set_context('POL_HEAD_ID', p_policy_header_id);
      ins.repcore.set_context('POL_INDEX_HEAD_ID', p_policy_index_header_id);
      ins.repcore.set_context('ORDER_NUM'
                             ,lpad(to_char(v_order_numb), 4, '0') || '-' || p_mon_idx || '/' ||
                              substr(p_year_idx, -2));
      pkg_rep_utils.exec_and_store_report(p_rep_id
                                         ,p_ident
                                         ,p_policy_index_header_id
                                         ,p_policy_header_id
                                         ,lpad(to_char(v_order_numb), 4, '0') || '-' || p_mon_idx || '/' ||
                                          substr(p_year_idx, -2));
      ins.repcore.clear_context;
    END LOOP;
    CLOSE c1;
  
    COMMIT;
  
  END LETTERS_IDX_FORM;

  /* Веселуха Е.В.
     Процедура вспомогательная для определения параметров при печати писем по Индексации
     INDEXATING_REPORT
     
     CREATE GLOBAL TEMPORARY TABLE PARAM_IDX
    (p_prod_flg NUMBER,
     p_epg_flg NUMBER,
     p_epg_paid NUMBER,
     p_epg_to_pay NUMBER,
     p_adm_flg NUMBER,
     p_10pol_flg NUMBER,
     p_opt_flg NUMBER,
     p_is_mailing NUMBER,
     p_head_idx_id NUMBER,
     p_head_id NUMBER,
     p_epg_to_pay_gdv NUMBER
    );
     
  */
  FUNCTION IS_EXISTS_PARAM_IDX
  (
    par_pol_index_head_id NUMBER
   ,par_pol_head_id       NUMBER
  ) RETURN NUMBER IS
    proc_name VARCHAR2(20) := 'IS_EXISTS_PARAM_IDX';
  BEGIN
  
    INSERT INTO PARAM_IDX
      SELECT CASE
               WHEN (prod.brief = 'Baby_LA' OR prod.brief = 'Baby_LA2')
                    AND ph.start_date > TO_DATE('04.05.2010', 'DD.MM.YYYY') THEN
                1
               WHEN (prod.brief = 'Family La' OR prod.brief = 'Family_La2')
                    AND ph.start_date > TO_DATE('08.04.2010', 'DD.MM.YYYY') THEN
                1
               WHEN (prod.brief = 'Platinum_LA' OR prod.brief = 'Platinum_LA')
                    AND ph.start_date > TO_DATE('03.06.2010', 'DD.MM.YYYY') THEN
                1
               WHEN (prod.brief = 'END' OR prod.brief = 'CHI' OR prod.brief = 'TERM' OR
                    prod.brief = 'PEPR' OR prod.brief = 'END_2' OR prod.brief = 'CHI_2'
                    OR prod.brief = 'TERM_2' OR prod.brief = 'PEPR_2')
                    AND ph.start_date > TO_DATE('01.04.2009', 'DD.MM.YYYY') THEN
                1
               ELSE
                (CASE
                  WHEN (SELECT COUNT(*)
                          FROM DUAL
                         WHERE EXISTS (SELECT NULL
                                  FROM ins.doc_status     ds
                                      ,ins.doc_status_ref rf
                                 WHERE ds.document_id IN
                                       (SELECT pola.policy_id
                                          FROM ins.p_policy pola
                                         WHERE pola.pol_header_id = ph.policy_header_id
                                           AND pola.policy_id <> pol.policy_id)
                                   AND ds.doc_status_ref_id = rf.doc_status_ref_id
                                   AND rf.brief = 'INDEXATING')) > 0 THEN
                   1
                  ELSE
                   0
                END)
             END flag_1
            ,(SELECT COUNT(*)
                FROM ins.doc_doc    dd
                    ,ins.ac_payment ac
               WHERE dd.child_id = ac.payment_id
                 AND ac.plan_date = pol.start_date
                 AND dd.parent_id IN (SELECT pola.policy_id
                                        FROM ins.p_policy pola
                                       WHERE pola.pol_header_id = ph.policy_header_id)) all_epg_gdv
            ,(SELECT COUNT(*)
                FROM ins.doc_doc    dd
                    ,ins.ac_payment ac
                    ,ins.document   d
               WHERE dd.child_id = ac.payment_id
                 AND ac.plan_date = pol.start_date
                 AND ac.payment_id = d.document_id
                 AND d.doc_status_ref_id =
                     (SELECT rf.doc_status_ref_id FROM ins.doc_status_ref rf WHERE rf.brief = 'PAID')
                 AND d.doc_templ_id =
                     (SELECT dt.doc_templ_id FROM ins.doc_templ dt WHERE dt.brief = 'PAYMENT')
                 AND dd.parent_id IN (SELECT pola.policy_id
                                        FROM ins.p_policy pola
                                       WHERE pola.pol_header_id = ph.policy_header_id)) all_epg_paid
            ,(SELECT COUNT(*)
                FROM ins.doc_doc    dd
                    ,ins.ac_payment ac
                    ,ins.document   d
               WHERE dd.child_id = ac.payment_id
                 AND ac.payment_id = d.document_id
                 AND d.doc_status_ref_id IN
                     (SELECT rf.doc_status_ref_id
                        FROM ins.doc_status_ref rf
                       WHERE rf.brief IN ('TO_PAY', 'NEW'))
                 AND d.doc_templ_id =
                     (SELECT dt.doc_templ_id FROM ins.doc_templ dt WHERE dt.brief = 'PAYMENT')
                 AND dd.parent_id IN (SELECT pola.policy_id
                                        FROM ins.p_policy pola
                                       WHERE pola.pol_header_id = ph.policy_header_id)
                 AND ac.plan_date < pol.start_date) epg_to_pay
            ,(SELECT COUNT(*)
                FROM ins.as_asset           a
                    ,ins.p_cover            pc
                    ,ins.t_prod_line_option pro
                    ,ins.t_product_line     pl
                    ,ins.ven_status_hist    vsh
               WHERE pc.t_prod_line_option_id = pro.ID
                 AND pro.product_line_id = pl.ID
                 AND pc.status_hist_id = vsh.status_hist_id
                 AND vsh.brief NOT IN ('DELETED')
                 AND a.as_asset_id = pc.as_asset_id
                 AND a.p_policy_id = pol.policy_id
                 AND upper(pl.description) IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')) is_adm
            ,CASE
               WHEN LENGTH(pol.pol_num) > 6 THEN
                1
               ELSE
                0
             END is_10pol
            ,(SELECT COUNT(*)
                FROM ins.as_asset            a
                    ,ins.p_cover             pc
                    ,ins.t_prod_line_option  pro
                    ,ins.t_product_line      pl
                    ,ins.t_product_line_type plt
                    ,ins.ven_status_hist     vsh
               WHERE pc.t_prod_line_option_id = pro.ID
                 AND pro.product_line_id = pl.ID
                 AND pc.status_hist_id = vsh.status_hist_id
                 AND vsh.brief NOT IN ('DELETED')
                 AND a.as_asset_id = pc.as_asset_id
                 AND a.p_policy_id = pol.policy_id
                 AND plt.product_line_type_id = pl.product_line_type_id
                 AND plt.brief <> 'RECOMMENDED'
                 AND upper(pl.description) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
                 AND EXISTS
               (SELECT NULL
                        FROM ins.p_policy     pols
                            ,ins.p_pol_header phs
                            ,ins.t_product    prods
                       WHERE pols.policy_id = a.p_policy_id
                         AND pols.pol_header_id = phs.policy_header_id
                         AND phs.product_id = prods.product_id
                         AND ((prods.brief IN ('END', 'CHI', 'PEPR', 'END_2', 'CHI_2', 'PEPR_2') AND
                             SUBSTR(TO_CHAR(phs.ids), 1, 3) IN ('114', '115', '667')) OR
                             prods.brief IN ('Platinum_LA', 'Platinum_LA2')))) is_option
            ,NVL(pol.mailing, 0) is_mailing
            ,par_pol_index_head_id
            ,par_pol_head_id
            ,(SELECT COUNT(*)
                FROM ins.doc_doc    dd
                    ,ins.ac_payment ac
                    ,ins.document   d
               WHERE dd.child_id = ac.payment_id
                 AND ac.payment_id = d.document_id
                 AND d.doc_status_ref_id IN (SELECT rf.doc_status_ref_id
                                               FROM ins.doc_status_ref rf
                                              WHERE rf.brief IN ('TO_PAY'))
                 AND d.doc_templ_id =
                     (SELECT dt.doc_templ_id FROM ins.doc_templ dt WHERE dt.brief = 'PAYMENT')
                 AND dd.parent_id IN (SELECT pola.policy_id
                                        FROM ins.p_policy pola
                                       WHERE pola.pol_header_id = ph.policy_header_id)
                 AND ac.plan_date = pol.start_date) is_epg_to_pay_gdv
        FROM ins.p_pol_header ph
            ,ins.t_product prod
            ,ins.p_policy pol
            ,(SELECT ii.policy_id
                    ,TO_CHAR(pih.date_index, 'YYYY') year_idx
                FROM ins.policy_index_item       ii
                    ,ins.ven_policy_index_header pih
               WHERE pih.policy_index_header_id = ii.policy_index_header_id
                 AND pih.policy_index_header_id = par_pol_index_head_id
                 AND ii.policy_header_id = par_pol_head_id) idpol
       WHERE ph.policy_header_id = pol.pol_header_id
         AND pol.policy_id = idpol.policy_id
         AND ph.product_id = prod.product_id;
  
    RETURN 0;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || ': не найдены данные');
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || CHR(25));
    
  END IS_EXISTS_PARAM_IDX;
  /**/
  PROCEDURE RLA_ACT_SECOND_FL(par_roll_id NUMBER) IS
  
    p_contract_header_id NUMBER;
    p_ident              VARCHAR2(30);
    p_rep_id             NUMBER;
    rep_name             VARCHAR2(30) := 'ins11/RLA_SECOND_FL.jsp';
  
    CURSOR c1 IS(
      SELECT rc.ag_contract_header_id
            ,rc.recruit_num
        FROM ins.RLA_SECOND_RECRUIT rc);
  BEGIN
  
    SELECT rep.rep_report_id INTO p_rep_id FROM ins.rep_report rep WHERE rep.exe_name = rep_name;
  
    DELETE FROM TMP_STORED_REPORTS r WHERE r.file_name LIKE 'RLA1_%';
  
    OPEN c1;
    LOOP
      FETCH c1
        INTO p_contract_header_id
            ,p_ident;
      EXIT WHEN c1%NOTFOUND;
    
      ins.repcore.set_context('P_ROLL_ID', par_roll_id);
      ins.repcore.set_context('P_HEADER_ID', p_contract_header_id);
      pkg_rep_utils.exec_and_store_report(p_rep_id
                                         ,'RLA1_' || p_ident
                                         ,par_roll_id
                                         ,p_contract_header_id
                                         ,lpad(p_ident, 6, '0'));
      ins.repcore.clear_context;
    END LOOP;
    CLOSE c1;
  
    COMMIT;
  
  END RLA_ACT_SECOND_FL;
  /**/
  PROCEDURE RLA_CALCULATION(par_roll_id NUMBER) IS
  
    p_rep_id NUMBER;
    rep_name VARCHAR2(30) := 'ins11/RLA_CALCULATION.jsp';
  
  BEGIN
  
    SELECT rep.rep_report_id INTO p_rep_id FROM ins.rep_report rep WHERE rep.exe_name = rep_name;
  
    DELETE FROM TMP_STORED_REPORTS r WHERE r.file_name LIKE 'RLA2_%';
  
    ins.repcore.set_context('P_ROLL_ID', par_roll_id);
    pkg_rep_utils.exec_and_store_report(p_rep_id, 'RLA2_467696', par_roll_id, 2467696, '467696');
    ins.repcore.clear_context;
  
    COMMIT;
  
  END RLA_CALCULATION;
  /**/
  PROCEDURE RLA_REPORT(par_roll_id NUMBER) IS
  
    p_rep_id NUMBER;
    rep_name VARCHAR2(30) := 'ins11/RLA_REPORT.jsp';
  
  BEGIN
  
    SELECT rep.rep_report_id INTO p_rep_id FROM ins.rep_report rep WHERE rep.exe_name = rep_name;
  
    DELETE FROM TMP_STORED_REPORTS r WHERE r.file_name LIKE 'RLA3_%';
  
    ins.repcore.set_context('P_ROLL_ID', par_roll_id);
    pkg_rep_utils.exec_and_store_report(p_rep_id, 'RLA3_467696', par_roll_id, 3467696, '467696');
    ins.repcore.clear_context;
  
    COMMIT;
  
  END RLA_REPORT;
  /**/
END PKG_LETTERS;
/
