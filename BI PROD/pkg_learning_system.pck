CREATE OR REPLACE PACKAGE pkg_learning_system IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 22.05.2013 12:19:08
  -- Purpose : Интеграция с системой обучения

  PROCEDURE get_first_agn_sales;

END pkg_learning_system;
/
CREATE OR REPLACE PACKAGE BODY pkg_learning_system IS

  gc_pkg_name CONSTANT VARCHAR2(30) := 'PKG_LEARNING_SYSTEM';

  PROCEDURE get_first_agn_sales IS
    c_proc_name CONSTANT VARCHAR2(30) := 'GET_FIRST_AGN_SALES';
    v_pass_series      cn_contact_ident.serial_nr%TYPE;
    v_pass_number      cn_contact_ident.id_value%TYPE;
    v_pass_date        VARCHAR2(10);
    v_ids              VARCHAR2(10);
    v_min_payment_date VARCHAR2(10);
  
    v_obj       JSON;
    v_obj_array JSON_LIST := JSON_LIST();
    v_log_info  pkg_communication.typ_log_info;
  BEGIN
    -- Цикл по агентам
    FOR vr_agents IN (SELECT dcch.num AS ag_num -- 6. Номер Агентского договора (из Агентского договора);
                             -- 4. Код подразделения (из карточки Подразделений);
                            ,to_char(dh.universal_code, 'FM0009') AS universal_code
                            ,to_char(cp.date_of_birth, 'dd.mm.yyyy') AS ag_date_of_birth
                            ,ch.ag_contract_header_id
                             -- 5. Наименование продающего подразделения (из Агентского договора или из Карточки подразделений)
                            ,dp.name AS department_name
                             -- 7. ФИО Агента (из Агентского договора);
                            ,co.name        AS agent_lname
                            ,co.middle_name AS agent_mname
                            ,co.first_name  AS agent_fname
                            ,co.contact_id
                        FROM ag_contract_header ch
                            ,document           dcch
                            ,doc_status_ref     dsrch
                            ,ag_contract        cn
                            ,t_sales_channel    sc
                            ,contact            co
                            ,cn_person          cp
                            ,department         dp
                            ,sales_dept_header  dh
                       WHERE ch.last_ver_id = cn.ag_contract_id
                         AND cn.ag_sales_chn_id = sc.id
                            -- 1.а. Канал продаж действующего Агента not in (Банковский, Брокерский, Брокерский без скидки, Корпоративный);
                         AND sc.brief NOT IN ('BANK', 'BR', 'BR_WDISC', 'CORPORATE')
                            -- 1.b. Дата заключения Агентского договора больше 1 января 2013 г.
                         AND ch.date_begin >= to_date('01.01.2013', 'dd.mm.yyyy')
                         AND ch.ag_contract_header_id = dcch.document_id
                         AND dcch.doc_status_ref_id = dsrch.doc_status_ref_id
                         AND dsrch.brief = 'CURRENT'
                         AND cn.agency_id = dp.department_id
                         AND dp.org_tree_id = dh.organisation_tree_id
                         AND ch.agent_id = co.contact_id
                         AND co.contact_id = cp.contact_id
                            -- Есть договоры, где они действующие
                         AND EXISTS (SELECT NULL
                                FROM p_policy_agent_doc pad
                                    ,document           dcpad
                                    ,doc_status_ref     dsrpad
                                    ,p_pol_header       ph
                                    ,t_product          pr
                               WHERE pad.ag_contract_header_id = ch.ag_contract_header_id
                                 AND pad.p_policy_agent_doc_id = dcpad.document_id
                                 AND dcpad.doc_status_ref_id = dsrpad.doc_status_ref_id
                                 AND dsrpad.brief = 'CURRENT'
                                 AND pad.policy_header_id = ph.policy_header_id
                                 AND ph.product_id = pr.product_id
                                    -- исключить из выборки ИДС is null;
                                 AND ph.ids IS NOT NULL
                                    -- 1.c. Продукт not in (СОФИ, ОПС+);
                                 AND pr.brief NOT IN ('SF_Plus'
                                                     ,'SF_AVCR'
                                                     ,'OPS_Plus'
                                                     ,'OPS_Plus_New'
                                                     ,'OPS_Plus_New_2014'
                                                     ,'OPS_Plus_2'))
                      
                      )
    LOOP
      -- 1. Минимальный по дате заключения договор
      SELECT to_char(ids) AS ids -- 3. ИДС договора
             -- 2. Минимальная дата ЭПГ в статусе <Оплачен>;
            ,(SELECT to_char(MIN(ac.plan_date), 'dd.mm.yyyy')
                FROM p_policy       pp
                    ,doc_doc        dd
                    ,ac_payment     ac
                    ,document       dcac
                    ,doc_status_ref dsrac
                    ,doc_templ      dt
               WHERE pp.pol_header_id = ph.policy_header_id
                 AND pp.policy_id = dd.parent_id
                 AND dd.child_id = dcac.document_id
                 AND dcac.document_id = ac.payment_id
                 AND dcac.doc_status_ref_id = dsrac.doc_status_ref_id
                 AND dsrac.brief = 'PAID'
                 AND dcac.doc_templ_id = dt.doc_templ_id
                 AND dt.brief = 'PAYMENT') AS min_payment
        INTO v_ids
            ,v_min_payment_date
        FROM (SELECT ids
                    ,policy_header_id
                FROM (SELECT ph.ids
                            ,ph.policy_header_id
                        FROM p_policy_agent_doc pad
                            ,document           dcpad
                            ,doc_status_ref     dsrpad
                            ,p_pol_header       ph
                            ,t_product          pr
                       WHERE pad.ag_contract_header_id = vr_agents.ag_contract_header_id
                         AND pad.p_policy_agent_doc_id = dcpad.document_id
                         AND dcpad.doc_status_ref_id = dsrpad.doc_status_ref_id
                         AND dsrpad.brief = 'CURRENT'
                         AND pad.policy_header_id = ph.policy_header_id
                         AND ph.product_id = pr.product_id
                            -- исключить из выборки ИДС is null;
                         AND ph.ids IS NOT NULL
                            -- 1.c. Продукт not in (СОФИ, ОПС+);
                         AND pr.brief NOT IN ('SF_Plus'
                                             ,'SF_AVCR'
                                             ,'OPS_Plus'
                                             ,'OPS_Plus_New'
                                             ,'OPS_Plus_New_2014'
                                             ,'OPS_Plus_2')
                       ORDER BY ph.start_date)
               WHERE rownum = 1) ph;
      /*
        Первый документ из контакта с типом Паспорт РФ либо Загран. Паспорт.
        Сортировка по <галочке по-умолчанию>, дате выдачи документа по убыванию)
        a. Серия документа
        b. Номер документа
        c. Дата выдачи документа
      */
      BEGIN
        SELECT serial_nr
              ,id_value
              ,to_char(issue_date, 'dd.mm.yyyy') AS issue_date
          INTO v_pass_series
              ,v_pass_number
              ,v_pass_date
          FROM (SELECT ci.serial_nr
                      ,ci.id_value
                      ,ci.issue_date
                  FROM cn_contact_ident ci
                 WHERE ci.contact_id = vr_agents.contact_id
                   AND ci.id_type IN (SELECT t.id
                                        FROM t_id_type t
                                       WHERE t.description IN ('Загранпаспорт гражданина РФ'
                                                              ,'Паспорт гражданина РФ'))
                 ORDER BY ci.is_default DESC NULLS LAST
                         ,ci.issue_date DESC)
         WHERE rownum = 1;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;
      v_obj := JSON();
      v_obj.put('epg_date', v_min_payment_date);
      v_obj.put('ids', v_ids);
      v_obj.put('dep_code', vr_agents.universal_code);
      v_obj.put('dep_name', vr_agents.department_name);
      v_obj.put('ag_num', vr_agents.ag_num);
      v_obj.put('ag_fname', vr_agents.agent_fname);
      v_obj.put('ag_mname', vr_agents.agent_mname);
      v_obj.put('ag_lname', vr_agents.agent_lname);
      v_obj.put('ag_birth', vr_agents.ag_date_of_birth);
      v_obj.put('doc_ser', v_pass_series);
      v_obj.put('doc_num', v_pass_number);
      v_obj.put('doc_date', v_pass_date);
    
      v_obj_array.append(v_obj.to_json_value);
    
    END LOOP;
    v_obj := JSON();
    v_obj.put('data', v_obj_array.to_json_value);
  
    v_log_info.source_pkg_name       := gc_pkg_name;
    v_log_info.source_procedure_name := c_proc_name;
    v_log_info.operation_name        := c_proc_name;
  
    pkg_communication.htp_lob_response(par_json => v_obj, par_log_info => v_log_info);
  
  END get_first_agn_sales;

END pkg_learning_system;
/
