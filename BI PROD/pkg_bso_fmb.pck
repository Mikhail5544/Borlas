CREATE OR REPLACE PACKAGE pkg_bso_fmb IS

  -- Author  : PAVEL.KAPLYA
  -- Created : 03.06.2013 16:03:46
  -- Purpose : Обработка формы BSO

  -- Public type declarations

  -- Public constant declarations

  -- Public variable declarations

  PROCEDURE set_act_date(par_act_date DATE);
  FUNCTION get_act_date RETURN DATE;
  FUNCTION get_warehouse_contact_id RETURN NUMBER;
  FUNCTION get_supplier_contact_id RETURN NUMBER;
  FUNCTION get_dummy_bso_owner_contact_id RETURN NUMBER;
  FUNCTION get_rlp_contact_id RETURN NUMBER;
  FUNCTION get_renlife_partners_id RETURN contact.contact_id%TYPE;

  FUNCTION is_warehouse(par_contact_id NUMBER) RETURN BOOLEAN;
  FUNCTION is_rla(par_contact_id NUMBER) RETURN BOOLEAN;
  FUNCTION is_rlp(par_contact_id NUMBER) RETURN BOOLEAN;
  FUNCTION is_supplier(par_contact_id NUMBER) RETURN BOOLEAN;
  FUNCTION is_dummy_bso_owner_contact_id(par_contact_id NUMBER) RETURN BOOLEAN;
  FUNCTION get_ag_header_by_contact
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION is_agent
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;
  FUNCTION is_rsp
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION is_co_worker(par_contact_id NUMBER) RETURN BOOLEAN;
  FUNCTION is_co_worker_agents(par_contact_id NUMBER) RETURN BOOLEAN;
  FUNCTION is_agent_broker
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;
  FUNCTION is_leader
  (
    par_subject_cn_id NUMBER
   ,par_leader_cn_id  NUMBER
   ,par_act_date      DATE DEFAULT NULL
  ) RETURN BOOLEAN;
  FUNCTION is_manager
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;
  FUNCTION is_director
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;
  FUNCTION agency_director_exists
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION check_transfer_rules
  (
    par_doc_templ_brief      VARCHAR2
   ,par_act_date             DATE
   ,par_contact_from_id      NUMBER
   ,par_department_from_id   NUMBER
   ,par_organisation_from_id NUMBER
   ,par_contact_to_id        NUMBER
   ,par_department_to_id     NUMBER
   ,par_organisation_to_id   NUMBER
  ) RETURN BOOLEAN;
  PROCEDURE validate_doc_cont_record
  (
    par_bso_series_id   NUMBER
   ,par_contact_from_id NUMBER
   ,par_contact_to_id   NUMBER
   ,par_doc_templ_brief VARCHAR2
   ,par_num_start       VARCHAR2
   ,par_num_end         VARCHAR2
  );
  --FUNCTION get_rep_header_contact_fio(par_contact_id NUMBER) RETURN VARCHAR2;
  --FUNCTION get_rep_header_contact_type(par_contact_id NUMBER) RETURN VARCHAR2;
  --FUNCTION get_rep_header_company(par_contact_id NUMBER) RETURN VARCHAR2;

  FUNCTION get_rep_header_type
  (
    par_bso_document_id NUMBER
   ,par_contact_id      NUMBER
  ) RETURN VARCHAR2;
  FUNCTION get_rep_header
  (
    par_bso_document_id NUMBER
   ,par_contact_id      NUMBER
  ) RETURN VARCHAR2;
  FUNCTION get_rep_contact_name
  (
    par_bso_document_id NUMBER
   ,par_contact_id      NUMBER
  ) RETURN VARCHAR2;

  FUNCTION get_agent_category
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN ag_category_agent.brief%TYPE;

  -- Является ли контакт агентом RLA  
  FUNCTION is_rla_subagent
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION is_inside_rlp_transfer(par_bso_document_id NUMBER) RETURN BOOLEAN;
  FUNCTION is_rlp_agent
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION is_rlp_warehouse_transfer(par_bso_document_id NUMBER) RETURN BOOLEAN;

  /* Агент, Менеджер, Директор */
  FUNCTION is_rlp_subagent
  (
    par_contact_id contact.contact_id%TYPE
   ,par_act_date   DATE
  ) RETURN BOOLEAN;
  FUNCTION is_rlp_subagent_sql
  (
    par_contact_id contact.contact_id%TYPE
   ,par_act_date   DATE
  ) RETURN NUMBER;

  FUNCTION is_rsp_agent
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN;

  FUNCTION get_leader_contact_id
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN NUMBER;
  FUNCTION get_leader_fio
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN VARCHAR2;
  FUNCTION get_company_name RETURN VARCHAR2;

  /* 
  Капля П.
  Определение стоимости БСО на дату
   */
  FUNCTION get_bso_cost
  (
    par_bso_series_id bso_series.bso_series_id%TYPE
   ,par_act_date      DATE
  ) RETURN t_bso_cost.bso_cost%TYPE;

-- Public function and procedure declarations

END pkg_bso_fmb;
/
CREATE OR REPLACE PACKAGE BODY pkg_bso_fmb IS

  gv_warehouse_contact_id       contact.contact_id%TYPE;
  gv_supplied_contact_id        contact.contact_id%TYPE;
  gv_rlp_contact_id             contact.contact_id%TYPE;
  gv_dummy_bso_owner_contact_id contact.contact_id%TYPE;
  gv_renlife_contact_id         contact.contact_id%TYPE;
  gv_renlife_partners_id        contact.contact_id%TYPE;
  gv_rla_contact_id             contact.contact_id%TYPE;
  gv_act_date                   DATE := trunc(SYSDATE);

  -- Function and procedure implementations

  FUNCTION get_act_date RETURN DATE IS
  BEGIN
    RETURN gv_act_date;
  END;

  PROCEDURE set_act_date(par_act_date DATE) IS
  BEGIN
    gv_act_date := par_act_date;
  END;

  FUNCTION get_warehouse_contact_id RETURN NUMBER IS
  BEGIN
    RETURN gv_warehouse_contact_id;
  END get_warehouse_contact_id;

  FUNCTION get_supplier_contact_id RETURN NUMBER IS
  BEGIN
    RETURN gv_supplied_contact_id;
  END get_supplier_contact_id;

  FUNCTION get_rlp_contact_id RETURN NUMBER IS
  BEGIN
    RETURN gv_rlp_contact_id;
  END get_rlp_contact_id;

  FUNCTION get_dummy_bso_owner_contact_id RETURN NUMBER IS
  BEGIN
    RETURN gv_dummy_bso_owner_contact_id;
  END get_dummy_bso_owner_contact_id;

  FUNCTION get_renlife_partners_id RETURN contact.contact_id%TYPE IS
  BEGIN
    RETURN gv_renlife_partners_id;
  END get_renlife_partners_id;

  FUNCTION is_dummy_bso_owner_contact_id(par_contact_id NUMBER) RETURN BOOLEAN IS
    RESULT BOOLEAN;
  BEGIN
    RESULT := par_contact_id = gv_dummy_bso_owner_contact_id;
    RETURN RESULT;
  END is_dummy_bso_owner_contact_id;

  FUNCTION is_warehouse(par_contact_id NUMBER) RETURN BOOLEAN IS
    RESULT BOOLEAN;
  BEGIN
    RESULT := par_contact_id = gv_warehouse_contact_id;
    RETURN RESULT;
  END is_warehouse;

  FUNCTION is_supplier(par_contact_id NUMBER) RETURN BOOLEAN IS
    RESULT BOOLEAN;
  BEGIN
    RESULT := par_contact_id = gv_supplied_contact_id;
    RETURN RESULT;
  END is_supplier;

  FUNCTION is_rlp(par_contact_id NUMBER) RETURN BOOLEAN IS
    RESULT BOOLEAN;
  BEGIN
    RESULT := par_contact_id = gv_rlp_contact_id;
    RETURN RESULT;
  END is_rlp;

  FUNCTION is_rla(par_contact_id NUMBER) RETURN BOOLEAN IS
    RESULT BOOLEAN;
  BEGIN
    RESULT := par_contact_id = gv_rla_contact_id;
    RETURN RESULT;
  END is_rla;

  FUNCTION get_ag_header_by_contact
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
  BEGIN
    BEGIN
      SELECT ag_contract_header_id
        INTO v_ag_contract_header_id
        FROM (SELECT ah.ag_contract_header_id
                FROM ag_contract_header ah
               WHERE ah.is_new = 1
                 AND ah.agent_id = par_contact_id
                 AND EXISTS
               (SELECT NULL
                        FROM doc_status     ds
                            ,doc_status_ref dsr
                       WHERE ds.document_id = ah.ag_contract_header_id
                         AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                         AND dsr.brief = 'CURRENT'
                         AND ds.start_date =
                             (SELECT MAX(start_date)
                                FROM doc_status ds2
                               WHERE ds2.document_id = ah.ag_contract_header_id
                                 AND ds2.start_date <= nvl(par_act_date, gv_act_date)))
               ORDER BY ah.date_begin DESC)
      -- ** 4 Необходимо внести логику по максимальной дате начала действия в случае нескольких заголовков
       WHERE rownum < 2;
    
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
    RETURN v_ag_contract_header_id;
  END get_ag_header_by_contact;
  FUNCTION get_agent_category
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN ag_category_agent.brief%TYPE IS
    v_category              ag_category_agent.brief%TYPE;
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
  BEGIN
    v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id => par_contact_id);
    SELECT aca.brief
      INTO v_category
      FROM ag_contract_header ach
          ,ag_contract        ac
          ,ag_category_agent  aca
     WHERE ach.ag_contract_header_id = v_ag_contract_header_id
       AND ac.contract_id = ach.ag_contract_header_id
       AND nvl(par_act_date, gv_act_date) BETWEEN ac.date_begin AND ac.date_end
       AND ac.category_id = aca.ag_category_agent_id;
  
    RETURN v_category;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'NONE';
  END get_agent_category;

  FUNCTION is_agent
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    RESULT BOOLEAN;
  BEGIN
    RESULT := get_ag_header_by_contact(par_contact_id, par_act_date) IS NOT NULL;
    RETURN RESULT;
  END is_agent;

  FUNCTION check_rla_agency
  (
    par_contract_header_id NUMBER
   ,par_act_date           DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_is_agency_rla NUMBER(1) := 0;
  BEGIN
    SELECT COUNT(*)
      INTO v_is_agency_rla
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ag_contract ac
                  ,department  d
             WHERE ac.contract_id = par_contract_header_id
               AND nvl(par_act_date, gv_act_date) BETWEEN ac.date_begin AND ac.date_end
               AND ac.agency_id = d.department_id
               AND d.name = 'Агентство RLA');
    RETURN v_is_agency_rla = 1;
  END check_rla_agency;

  FUNCTION is_agent_in_rlp_sales_channel
  (
    par_ag_contract_header_id NUMBER
   ,par_act_date              DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_sales_channel_brief t_sales_channel.brief%TYPE;
  BEGIN
    v_sales_channel_brief := nvl(pkg_agn_control.agent_sales_chan_brief_by_date(par_ag_contract_header_id => par_ag_contract_header_id
                                                                               ,par_date                  => nvl(par_act_date
                                                                                                                ,gv_act_date)
                                                                               ,par_raise                 => FALSE)
                                ,'?');
    RETURN v_sales_channel_brief IN ('MLM'); --'DSF'
  END is_agent_in_rlp_sales_channel;

  FUNCTION is_rla_subagent
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_is_agency_rla         NUMBER(1);
    v_is_rla_agent          BOOLEAN;
  BEGIN
    v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id => par_contact_id
                                                       ,par_act_date   => par_act_date);
  
    RETURN v_ag_contract_header_id IS NOT NULL AND check_rla_agency(v_ag_contract_header_id
                                                                   ,par_act_date);
  END is_rla_subagent;

  FUNCTION is_rlp_agent
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_found_parent          NUMBER;
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_is_rlp_agent          BOOLEAN;
    v_is_rlp_sales_channel  BOOLEAN;
  BEGIN
    IF is_rla(par_contact_id => par_contact_id)
    THEN
      RETURN FALSE;
    END IF;
  
    v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id => par_contact_id
                                                       ,par_act_date   => par_act_date);
  
    -- ** 3 тут надо добавить условие на категорию агент
  
    IF v_ag_contract_header_id IS NOT NULL
    THEN
      -- Проверка, что руководитель из RLP т.е. категория MN, DR, DR2
      SELECT COUNT(*)
        INTO v_found_parent
        FROM dual
       WHERE NOT EXISTS (SELECT NULL
                FROM ag_agent_tree      agt
                    ,ag_contract_header parent_ah
                    ,ag_contract        parent_ac
                    ,ag_category_agent  cat
               WHERE agt.ag_contract_header_id = v_ag_contract_header_id
                 AND par_act_date BETWEEN agt.date_begin AND agt.date_end
                 AND agt.ag_parent_header_id = parent_ah.ag_contract_header_id
                 AND parent_ah.last_ver_id = parent_ac.ag_contract_id
                 AND parent_ac.category_id = cat.ag_category_agent_id
                 AND cat.brief IN ('RM', 'RD', 'ZD', 'TD'));
    
      v_is_rlp_sales_channel := is_agent_in_rlp_sales_channel(par_ag_contract_header_id => v_ag_contract_header_id
                                                             ,par_act_date              => par_act_date);
    
      v_is_rlp_agent := (v_found_parent > 0) AND
                        get_agent_category(par_contact_id, par_act_date) = 'AG' AND
                        NOT check_rla_agency(v_ag_contract_header_id, par_act_date) AND
                        v_is_rlp_sales_channel;
    ELSE
      v_is_rlp_agent := FALSE;
    END IF;
    RETURN v_is_rlp_agent;
  END is_rlp_agent;

  /* Агент, Менеджер, Директор */
  FUNCTION is_rlp_subagent
  (
    par_contact_id contact.contact_id%TYPE
   ,par_act_date   DATE
  ) RETURN BOOLEAN IS
  BEGIN
    RETURN(is_rlp_agent(par_contact_id => par_contact_id, par_act_date => par_act_date) OR
           is_director(par_contact_id => par_contact_id, par_act_date => par_act_date) OR
           is_manager(par_contact_id => par_contact_id, par_act_date => par_act_date));
  END is_rlp_subagent;

  FUNCTION is_rlp_subagent_sql
  (
    par_contact_id contact.contact_id%TYPE
   ,par_act_date   DATE
  ) RETURN NUMBER IS
    v_result NUMBER(1);
  BEGIN
    IF is_rlp_subagent(par_contact_id => par_contact_id, par_act_date => par_act_date)
    THEN
      v_result := 1;
    ELSE
      v_result := 0;
    END IF;
    RETURN v_result;
  END is_rlp_subagent_sql;

  FUNCTION is_brokeage
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    CURSOR cur_brokeage(par_contact_id NUMBER) IS(
      SELECT 1 dummy_value
        FROM employee      ee
            ,employee_hist eh
       WHERE ee.contact_id = par_contact_id
         AND ee.employee_id = eh.employee_id
         AND eh.employee_hist_id = (SELECT MAX(eh2.employee_hist_id)
                                      FROM employee_hist eh2
                                     WHERE eh2.employee_id = ee.employee_id)
         AND eh.is_brokeage = 1);
    v_dummy_value cur_brokeage%ROWTYPE;
    v_is_brokeage NUMBER;
    v_found       BOOLEAN;
  BEGIN
    IF is_agent(par_contact_id => par_contact_id, par_act_date => par_act_date)
    THEN
      OPEN cur_brokeage(par_contact_id);
    
      FETCH cur_brokeage
        INTO v_dummy_value;
    
      v_found := cur_brokeage%FOUND;
    
      CLOSE cur_brokeage;
    
    ELSE
      v_found := FALSE;
    END IF;
    RETURN v_found;
  EXCEPTION
    WHEN OTHERS THEN
      IF cur_brokeage%ISOPEN
      THEN
        CLOSE cur_brokeage;
      END IF;
      RAISE;
  END is_brokeage;

  /* Капля П.
    Запись соответствующего контакта сотрудника ЦО, именуемого ‘Cотрудник ЦО’, должна удовлетворять следующим условиям:
    1.  У контакта имеется роль ‘МОЛ’
    2.  Имеется запись в справочнике ‘Персонал организации’ для организации с сокращением ‘ЦО’ с установленным признаком ‘М.О.’ (Рис. 3)
    3.  У контакта имеется связь с технической записью ‘Склад ЦО’ с ролью ‘Пользователь БСО’ (данную роль контакта необходимо добавить в систему). 
  */
  FUNCTION is_co_worker(par_contact_id NUMBER) RETURN BOOLEAN IS
    v_found NUMBER(1);
  BEGIN
  
    SELECT COUNT(*)
      INTO v_found
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM employee          ee
                  ,employee_hist     eh
                  ,organisation_tree org
                  ,contact           c
             WHERE ee.organisation_id = org.organisation_tree_id
               AND ee.contact_id = c.contact_id
               AND c.contact_id = par_contact_id
               AND ee.employee_id = eh.employee_id
               AND eh.is_brokeage = 1
               AND eh.employee_hist_id =
                   (SELECT MAX(eh2.employee_hist_id)
                      FROM employee_hist eh2
                     WHERE eh2.employee_id = ee.employee_id)
               AND org.code = 'ЦО'
               AND EXISTS (SELECT NULL
                      FROM cn_contact_role cr
                          ,t_contact_role  r
                     WHERE ee.contact_id = cr.contact_id
                       AND cr.role_id = r.id
                       AND r.brief = 'BSO_USER')
               AND EXISTS (SELECT NULL
                      FROM cn_contact_role cr
                          ,t_contact_role  r
                     WHERE ee.contact_id = cr.contact_id
                       AND cr.role_id = r.id
                       AND r.brief = 'WORKER'));
  
    RETURN v_found > 0;
  
  END is_co_worker;

  FUNCTION is_co_worker_agents(par_contact_id NUMBER) RETURN BOOLEAN IS
  
    v_found NUMBER(1);
  BEGIN
    SELECT COUNT(*)
      INTO v_found
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM employee          ee
                  ,organisation_tree org
                  ,contact           c
             WHERE ee.organisation_id = org.organisation_tree_id
               AND ee.contact_id = c.contact_id
               AND c.contact_id = par_contact_id
               AND org.code = 'ЦО'
               AND EXISTS (SELECT NULL
                      FROM cn_contact_role cr
                          ,t_contact_role  r
                     WHERE ee.contact_id = cr.contact_id
                       AND cr.role_id = r.id
                       AND r.brief = 'BSO_RESPONSE')
               AND EXISTS (SELECT NULL
                      FROM cn_contact_role cr
                          ,t_contact_role  r
                     WHERE ee.contact_id = cr.contact_id
                       AND cr.role_id = r.id
                       AND r.brief = 'WORKER'));
    RETURN v_found > 0;
  END is_co_worker_agents;

  FUNCTION is_agent_broker
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_found                 NUMBER(1) := 0;
    v_is_rla                BOOLEAN := is_rla(par_contact_id);
    v_agency_id             department.department_id%TYPE;
    v_agency_name           department.name%TYPE := '?';
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
  BEGIN
    IF NOT v_is_rla
    THEN
      SELECT COUNT(*)
        INTO v_found
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM cn_contact_role cr
                    ,t_contact_role  r
               WHERE cr.contact_id = par_contact_id
                 AND cr.role_id = r.id
                 AND r.brief = 'BSO_AGENT_BROKER');
      BEGIN
        v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id
                                                           ,nvl(par_act_date, gv_act_date));
      
        v_agency_id := pkg_agn_control.agent_agency_by_date(par_ag_contract_header_id => v_ag_contract_header_id
                                                           ,par_date                  => nvl(par_act_date
                                                                                            ,gv_act_date)
                                                           ,par_raise                 => TRUE);
      
        SELECT d.name INTO v_agency_name FROM department d WHERE d.department_id = v_agency_id;
      EXCEPTION
        WHEN OTHERS THEN
          RETURN FALSE;
      END;
      --select from department d where d.department_id = pkg                
    END IF;
    RETURN v_found > 0 OR v_agency_name IN('Внешние агенты и агентства'
                                          ,'Отдел по работе с брокерами и независимыми агентами');
  END is_agent_broker;

  FUNCTION leader_ag_header
  (
    par_child_ag_header_id ag_contract_header.ag_contract_header_id%TYPE
   ,par_act_date           DATE DEFAULT gv_act_date
  ) RETURN ag_contract_header.ag_contract_header_id%TYPE IS
    v_leader_ag_header_id ag_contract_header.ag_contract_header_id%TYPE;
  BEGIN
    BEGIN
      SELECT aat.ag_parent_header_id
        INTO v_leader_ag_header_id
        FROM ag_agent_tree aat
       WHERE aat.ag_contract_header_id = par_child_ag_header_id
         AND par_act_date BETWEEN aat.date_begin AND aat.date_end;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'На дату акта существует два руководителя агента. Нарушение целостности базы, обратитесь к администратору.');
    END;
  
    RETURN v_leader_ag_header_id;
  END leader_ag_header;

  FUNCTION is_leader
  (
    par_subject_cn_id NUMBER
   ,par_leader_cn_id  NUMBER
   ,par_act_date      DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_child_ag_header_id       ag_contract_header.ag_contract_header_id%TYPE;
    v_leader_ag_header_id      ag_contract_header.ag_contract_header_id%TYPE;
    v_real_leader_ag_header_id ag_contract_header.ag_contract_header_id%TYPE;
  BEGIN
  
    v_child_ag_header_id  := get_ag_header_by_contact(par_subject_cn_id
                                                     ,nvl(par_act_date, gv_act_date));
    v_leader_ag_header_id := get_ag_header_by_contact(par_leader_cn_id, nvl(par_act_date, gv_act_date));
  
    v_real_leader_ag_header_id := leader_ag_header(par_child_ag_header_id => v_child_ag_header_id
                                                  ,par_act_date           => nvl(par_act_date
                                                                                ,gv_act_date));
  
    RETURN v_leader_ag_header_id = v_real_leader_ag_header_id;
  END is_leader;

  FUNCTION is_rsp
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
  BEGIN
  
    RETURN is_brokeage(par_contact_id, par_act_date) AND get_agent_category(par_contact_id
                                                                           ,par_act_date) IN('RM'
                                                                                            ,'RD'
                                                                                            ,'ZD'
                                                                                            ,'TD');
  EXCEPTION
    WHEN no_data_found THEN
      RETURN FALSE;
  END is_rsp;

  FUNCTION is_rsp_agent
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_leader_contact_id NUMBER;
    v_is_rsp_agent      BOOLEAN := FALSE;
  BEGIN
    IF is_agent(par_contact_id, par_act_date)
       AND get_agent_category(par_contact_id, par_act_date) = 'AG'
    THEN
      v_leader_contact_id := get_leader_contact_id(par_contact_id, par_act_date);
      v_is_rsp_agent      := is_rsp(par_contact_id => v_leader_contact_id
                                   ,par_act_date   => par_act_date);
    END IF;
  
    RETURN v_is_rsp_agent;
  END is_rsp_agent;

  FUNCTION is_director
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_is_agent              BOOLEAN;
    v_ag_contract_header_id NUMBER;
    v_is_rlp_sales_channel  BOOLEAN;
    v_agent_category_brief  ag_category_agent.brief%TYPE;
  BEGIN
    v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id, par_act_date);
    v_is_agent              := v_ag_contract_header_id IS NOT NULL;
    v_is_rlp_sales_channel  := is_agent_in_rlp_sales_channel(par_ag_contract_header_id => v_ag_contract_header_id
                                                            ,par_act_date              => par_act_date);
    v_agent_category_brief  := get_agent_category(par_contact_id, par_act_date);
    RETURN  v_is_agent AND v_agent_category_brief IN('DR', 'DR2') AND v_is_rlp_sales_channel;
  END is_director;

  FUNCTION is_manager
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_is_agent              BOOLEAN;
    v_ag_contract_header_id NUMBER;
    v_is_rlp_sales_channel  BOOLEAN;
    v_agent_category_brief  ag_category_agent.brief%TYPE;
  BEGIN
    v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id, par_act_date);
    v_is_agent              := v_ag_contract_header_id IS NOT NULL;
    v_agent_category_brief  := get_agent_category(par_contact_id, par_act_date);
    v_is_rlp_sales_channel  := is_agent_in_rlp_sales_channel(par_ag_contract_header_id => v_ag_contract_header_id
                                                            ,par_act_date              => par_act_date);
    RETURN v_is_agent AND v_agent_category_brief = 'MN' AND v_is_rlp_sales_channel;
  END is_manager;

  FUNCTION agency_director_exists
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_count                 NUMBER(1);
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
  BEGIN
    v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id => par_contact_id);
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ag_contract_header     ach1
                  ,ven_ag_contract_header ach2
                  ,ag_contract            ac
                  ,ag_category_agent      aca
             WHERE ach1.ag_contract_header_id = v_ag_contract_header_id
               AND ach1.agency_id = ach2.agency_id
               AND ach2.is_new = 1
               AND ach2.last_ver_id = ac.ag_contract_id
               AND ac.category_id = aca.ag_category_agent_id
               AND aca.brief IN ('DR', 'DR2')
               AND EXISTS
             (SELECT NULL
                      FROM doc_status     ds
                          ,doc_status_ref dsr
                     WHERE ds.document_id = ach2.ag_contract_header_id
                       AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dsr.brief = 'CURRENT'
                       AND ds.start_date =
                           (SELECT MAX(start_date)
                              FROM doc_status ds2
                             WHERE ds2.document_id = ach2.ag_contract_header_id
                               AND ds2.start_date <= nvl(par_act_date, gv_act_date))));
  
    RETURN v_count > 0;
  
  END agency_director_exists;

  FUNCTION agency_manager_exists
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_count                 NUMBER(1);
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
  BEGIN
    v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id => par_contact_id);
    SELECT COUNT(*)
      INTO v_count
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ag_contract_header     ach1
                  ,ven_ag_contract_header ach2
                  ,ag_contract            ac
                  ,ag_category_agent      aca
             WHERE ach1.ag_contract_header_id = v_ag_contract_header_id
               AND ach1.agency_id = ach2.agency_id
               AND ach2.is_new = 1
               AND ach2.last_ver_id = ac.ag_contract_id
               AND ac.category_id = aca.ag_category_agent_id
               AND aca.brief = 'MN'
               AND EXISTS
             (SELECT NULL
                      FROM doc_status     ds
                          ,doc_status_ref dsr
                     WHERE ds.document_id = ach2.ag_contract_header_id
                       AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                       AND dsr.brief = 'CURRENT'
                       AND ds.start_date =
                           (SELECT MAX(start_date)
                              FROM doc_status ds2
                             WHERE ds2.document_id = ach2.ag_contract_header_id
                               AND ds2.start_date <= nvl(par_act_date, gv_act_date))));
  
    RETURN v_count > 0;
  
  END agency_manager_exists;

  FUNCTION is_bso_type_ac_marked(par_bso_series_id NUMBER) RETURN BOOLEAN IS
    v_check_val bso_type.check_ac%TYPE;
  BEGIN
    SELECT bt.check_ac
      INTO v_check_val
      FROM bso_type   bt
          ,bso_series bs
     WHERE bs.bso_series_id = par_bso_series_id
       AND bs.bso_type_id = bt.bso_type_id;
  
    RETURN nvl(v_check_val, 0) = 1;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20001, 'Не удалось найти серию БСО по ИД');
    
  END is_bso_type_ac_marked;

  FUNCTION check_transfer_rules
  (
    par_doc_templ_brief      VARCHAR2
   ,par_act_date             DATE
   ,par_contact_from_id      NUMBER
   ,par_department_from_id   NUMBER
   ,par_organisation_from_id NUMBER
   ,par_contact_to_id        NUMBER
   ,par_department_to_id     NUMBER
   ,par_organisation_to_id   NUMBER
  ) RETURN BOOLEAN IS
    v_dep_from_name      department.name%TYPE;
    v_dep_to_name        department.name%TYPE;
    v_org_tree_from_name organisation_tree.name%TYPE;
    v_org_tree_to_name   organisation_tree.name%TYPE;
    v_agency_from_id     NUMBER;
    v_agency_to_id       NUMBER;
  BEGIN
  
    v_agency_from_id := nvl(par_department_from_id, -1);
    v_agency_to_id   := nvl(par_department_to_id, -2);
  
    IF par_contact_from_id = par_contact_to_id
       AND par_doc_templ_brief != 'ФормированиеБСО'
    THEN
      raise_application_error(-20001, 'Контакты От кого и Кому совпадают');
    END IF;
  
    CASE
    
    --      WHEN par_doc_templ_brief = 'ПередачаБСО' THEN
    
      WHEN par_doc_templ_brief = 'ПередачаБСО' THEN
        -- Акт приема-передачи БСО, Акт приема-передачи испорченных БСО
        CASE
          WHEN (is_rlp(par_contact_from_id) OR is_co_worker(par_contact_from_id) OR
               is_co_worker_agents(par_contact_from_id) OR is_rsp(par_contact_from_id))
               AND is_warehouse(par_contact_to_id) THEN
            --Передача в ЦО
            RETURN TRUE;
          WHEN is_rsp(par_contact_from_id, par_act_date)
               AND is_rsp(par_contact_to_id, par_act_date) THEN
            -- Передача между структурными руководителями
            RETURN is_leader(par_subject_cn_id => par_contact_from_id
                            ,par_leader_cn_id  => par_contact_to_id
                            ,par_act_date      => par_act_date)
            
            OR is_leader(par_subject_cn_id => par_contact_to_id
                        ,par_leader_cn_id  => par_contact_from_id
                        ,par_act_date      => par_act_date);
          
          WHEN is_director(par_contact_from_id, par_act_date)
               AND is_rsp(par_contact_to_id, par_act_date) THEN
            -- Передача РСП от руководителя  агенства
            RETURN TRUE;
          WHEN is_manager(par_contact_from_id, par_act_date)
               AND is_rsp(par_contact_to_id, par_act_date) THEN
            -- Передача РСП от руководителя агенства (в случае отсутствия директора)
            RETURN NOT agency_director_exists(par_contact_id => par_contact_from_id
                                             ,par_act_date   => par_act_date);
          WHEN is_rlp_agent(par_contact_from_id, par_act_date)
               AND is_rsp(par_contact_to_id, par_act_date) THEN
            -- Передача РСП из агентства RLP в случае отсутствия директора и менеджеров
            RETURN NOT(agency_director_exists(par_contact_from_id, par_act_date) OR
                       agency_manager_exists(par_contact_from_id, par_act_date));
          WHEN is_agent_broker(par_contact_from_id, par_act_date)
               AND is_co_worker_agents(par_contact_to_id) THEN
            -- Передача от  агентов/брокеров
            RETURN TRUE;
          WHEN is_rla(par_contact_from_id)
               AND is_co_worker_agents(par_contact_to_id) THEN
            -- Передача от RLA
            RETURN TRUE;
          WHEN is_rla_subagent(par_contact_from_id, par_act_date)
               AND is_rla(par_contact_to_id) THEN
            -- Передача Агент RLA -> RLA
            RETURN TRUE;
          WHEN is_director(par_contact_from_id, par_act_date)
               AND is_rlp(par_contact_to_id) THEN
            -- Передача от  руководителя агентства
            RETURN TRUE;
          WHEN is_manager(par_contact_from_id, par_act_date)
               AND is_rlp(par_contact_to_id) THEN
            -- Передача от  руководителя агентства (в случае отсутствия директора)
            RETURN NOT agency_director_exists(par_contact_id => par_contact_from_id
                                             ,par_act_date   => par_act_date);
          WHEN is_manager(par_contact_from_id, par_act_date)
               AND is_director(par_contact_from_id, par_act_date) THEN
            -- Передача от менеджера
            RETURN v_agency_from_id = v_agency_to_id OR NOT agency_director_exists(par_contact_from_id
                                                                                  ,par_act_date);
          WHEN is_manager(par_contact_from_id, par_act_date)
               AND is_manager(par_contact_to_id, par_act_date) THEN
            -- Передача от менеджера (в случае отсутствия директора)
            RETURN v_agency_from_id = v_agency_to_id OR(NOT agency_director_exists(par_contact_from_id
                                                                                  ,par_act_date) AND
                                                        NOT agency_director_exists(par_contact_to_id
                                                                                  ,par_act_date));
          WHEN is_rlp_agent(par_contact_from_id, par_act_date)
               AND is_manager(par_contact_to_id, par_act_date) THEN
            --Передача субагенту
            DECLARE
              v_leader_contact_id NUMBER;
              v_leader_category   ag_category_agent.brief%TYPE;
            BEGIN
              v_leader_contact_id := get_leader_contact_id(par_contact_id => par_contact_to_id
                                                          ,par_act_date   => par_act_date);
              v_leader_category   := get_agent_category(par_contact_id => v_leader_contact_id
                                                       ,par_act_date   => par_act_date);
            
              /* Директор и агент должны быть в одном агентстве
              Сделан дополнительный костыль со слов Боровкова, что, если у руководителя агента категория не М/Д, 
              то это кривая запись и ему все равно можно передать*/
              RETURN v_agency_from_id = v_agency_to_id AND(is_leader(par_subject_cn_id => par_contact_from_id
                                                                    ,par_leader_cn_id  => par_contact_to_id
                                                                    ,par_act_date      => par_act_date) OR
                                                           (NOT
                                                             agency_director_exists(par_contact_id => par_contact_to_id
                                                                                   ,par_act_date   => par_act_date) AND
                                                            v_leader_category NOT IN
                                                            ('MN', 'DR', 'DR2')));
            END;
          WHEN is_rlp_agent(par_contact_from_id, par_act_date)
               AND is_director(par_contact_to_id, par_act_date) THEN
            -- Передача от  субагента
            DECLARE
              v_leader_contact_id NUMBER;
              v_leader_category   ag_category_agent.brief%TYPE;
            BEGIN
              v_leader_contact_id := get_leader_contact_id(par_contact_id => par_contact_to_id
                                                          ,par_act_date   => par_act_date);
              v_leader_category   := get_agent_category(par_contact_id => v_leader_contact_id
                                                       ,par_act_date   => par_act_date);
            
              /* Директор и агент должны быть в одном агентстве
              Сделан дополнительный костыль со слов Боровкова, что, если у руководителя агента категория не М/Д, 
              то это кривая запись и ему все равно можно передать*/
              RETURN v_agency_from_id = v_agency_to_id AND(is_leader(par_subject_cn_id => par_contact_from_id
                                                                    ,par_leader_cn_id  => par_contact_to_id
                                                                    ,par_act_date      => par_act_date) OR
                                                           v_leader_category NOT IN
                                                           ('MN', 'DR', 'DR2'));
            END;
          WHEN is_rsp_agent(par_contact_from_id, par_act_date)
               AND is_rsp(par_contact_to_id, par_act_date) THEN
            -- Передача РСП от своих  агентов
            RETURN is_leader(par_subject_cn_id => par_contact_from_id
                            ,par_leader_cn_id  => par_contact_to_id
                            ,par_act_date      => par_act_date);
          WHEN is_warehouse(par_contact_from_id)
               AND (is_rlp(par_contact_to_id) OR is_rsp(par_contact_to_id, par_act_date) OR
                    is_co_worker(par_contact_to_id) OR is_co_worker_agents(par_contact_to_id)) THEN
            -- Передача из ЦО
            RETURN TRUE;
          
          WHEN is_rsp(par_contact_from_id, par_act_date)
               AND is_rsp_agent(par_contact_to_id, par_act_date) THEN
            -- Передача агентам СК
            RETURN is_leader(par_subject_cn_id => par_contact_to_id
                            ,par_leader_cn_id  => par_contact_from_id
                            ,par_act_date      => par_act_date);
          
          WHEN is_rsp(par_contact_from_id, par_act_date)
               AND is_director(par_contact_to_id, par_act_date) THEN
            -- Передача Передача РСП руководителю агенства
            RETURN TRUE;
          WHEN is_rsp(par_contact_from_id, par_act_date)
               AND is_manager(par_contact_to_id, par_act_date) THEN
            -- Передача РСП руководителю агенства (в случае отсутствия директора)
            RETURN NOT agency_director_exists(par_contact_id => par_contact_to_id
                                             ,par_act_date   => par_act_date);
          WHEN is_rsp(par_contact_from_id, par_act_date)
               AND is_rlp_agent(par_contact_to_id, par_act_date) THEN
            -- Передача РСП в агентство RLP в случае отсутствия директора и менеджеров
            RETURN NOT(agency_director_exists(par_contact_id => par_contact_to_id
                                             ,par_act_date   => par_act_date) OR
                       agency_manager_exists(par_contact_to_id, par_act_date));
          
          WHEN is_co_worker_agents(par_contact_from_id)
               AND is_agent_broker(par_contact_to_id, par_act_date) THEN
            -- Передача агентам/брокерам
            RETURN TRUE;
          WHEN is_co_worker_agents(par_contact_from_id)
               AND is_rla(par_contact_to_id) THEN
            -- Передача RLA
            RETURN TRUE;
          WHEN is_rla(par_contact_from_id)
               AND is_rla_subagent(par_contact_to_id, par_act_date) THEN
            -- Передача RLA-> Агент RLA
            RETURN TRUE;
          WHEN is_rlp(par_contact_from_id)
               AND is_director(par_contact_to_id, par_act_date) THEN
            --Передача руководителю агентства
            RETURN TRUE;
          WHEN is_rlp(par_contact_from_id)
               AND is_manager(par_contact_to_id) THEN
            --Передача руководителю агентства (в случае отсутствия директора)
            RETURN NOT agency_director_exists(par_contact_id => par_contact_to_id
                                             ,par_act_date   => par_act_date);
          
          WHEN is_director(par_contact_from_id, par_act_date)
               AND is_manager(par_contact_to_id, par_act_date) THEN
            --Передача менеджеру
            RETURN v_agency_from_id = v_agency_to_id OR NOT agency_director_exists(par_contact_id => par_contact_to_id
                                                                                  ,par_act_date   => par_act_date);
          WHEN is_manager(par_contact_from_id, par_act_date)
               AND is_rlp_agent(par_contact_to_id, par_act_date) THEN
            --Передача субагенту
            DECLARE
              v_leader_contact_id NUMBER;
              v_leader_category   ag_category_agent.brief%TYPE;
            BEGIN
              v_leader_contact_id := get_leader_contact_id(par_contact_id => par_contact_from_id
                                                          ,par_act_date   => par_act_date);
              v_leader_category   := get_agent_category(par_contact_id => v_leader_contact_id
                                                       ,par_act_date   => par_act_date);
            
              /* Директор и агент должны быть в одном агентстве
              Сделан дополнительный костыль со слов Боровкова, что, если у руководителя агента категория не М/Д, 
              то это кривая запись и ему все равно можно передать*/
              RETURN v_agency_from_id = v_agency_to_id AND(is_leader(par_subject_cn_id => par_contact_to_id
                                                                    ,par_leader_cn_id  => par_contact_from_id
                                                                    ,par_act_date      => par_act_date) OR
                                                           (NOT
                                                             agency_director_exists(par_contact_id => par_contact_to_id
                                                                                   ,par_act_date   => par_act_date) AND
                                                            v_leader_category NOT IN
                                                            ('MN', 'DR', 'DR2')));
            END;
          
          WHEN is_director(par_contact_from_id, par_act_date)
               AND is_rlp_agent(par_contact_to_id, par_act_date) THEN
            --Передача субагенту
            DECLARE
              v_leader_contact_id NUMBER;
              v_leader_category   ag_category_agent.brief%TYPE;
            BEGIN
              v_leader_contact_id := get_leader_contact_id(par_contact_id => par_contact_from_id
                                                          ,par_act_date   => par_act_date);
              v_leader_category   := get_agent_category(par_contact_id => v_leader_contact_id
                                                       ,par_act_date   => par_act_date);
            
              /* Директор и агент должны быть в одном агентстве
              Сделан дополнительный костыль со слов Боровкова, что, если у руководителя агента категория не М/Д, 
              то это кривая запись и ему все равно можно передать*/
              RETURN v_agency_from_id = v_agency_to_id AND(is_leader(par_subject_cn_id => par_contact_to_id
                                                                    ,par_leader_cn_id  => par_contact_from_id
                                                                    ,par_act_date      => par_act_date) OR
                                                           v_leader_category NOT IN
                                                           ('MN', 'DR', 'DR2'));
            END;
          WHEN is_director(par_contact_from_id, par_act_date)
               AND is_director(par_contact_to_id, par_act_date) THEN
            -- Передача между подразделениями RLP
            RETURN TRUE;
            /*WHEN (is_director(par_contact_from_id) OR is_manager(par_contact_from_id))
               AND (is_director(par_contact_to_id) OR is_manager(par_contact_from_id)) THEN
            --Передача между подразделениями RLP (в случае отсутствия директора в передающем и/или принимающем подразделении
            DECLARE
              v_result BOOLEAN := TRUE;
            BEGIN
              IF is_manager(par_contact_from_id)
              THEN
                v_result := v_result AND
                            NOT agency_director_exists(par_contact_id => par_contact_from_id
                                                      ,par_act_date   => par_act_date);
              END IF;
              IF is_manager(par_contact_to_id)
              THEN
                v_result := v_result AND
                            NOT agency_director_exists(par_contact_id => par_contact_to_id
                                                      ,par_act_date   => par_act_date);
              END IF;
              RETURN v_result;
            END;*/
          ELSE
            RETURN FALSE;
        END CASE;
      WHEN par_doc_templ_brief = 'СписаниеБСО' THEN
        -- Акт списания БСО
        CASE
          WHEN is_director(par_contact_from_id, par_act_date) THEN
            -- Списание (RLP)
            RETURN TRUE;
          WHEN is_manager(par_contact_from_id, par_act_date) THEN
            -- Списание (RLP, в случае отсутствия директора)
            RETURN NOT agency_director_exists(par_contact_id => par_contact_from_id
                                             ,par_act_date   => par_act_date);
          WHEN is_warehouse(par_contact_from_id) THEN
            -- Списание (ЦО)
            RETURN TRUE;
          WHEN is_rsp(par_contact_from_id, par_act_date) THEN
            -- Передача между структурными руководителями
            RETURN TRUE;
          ELSE
            RETURN FALSE;
        END CASE;
      WHEN par_doc_templ_brief = 'УничтожениеБСО' THEN
        -- Акт уничтожения БСО
        CASE
          WHEN is_director(par_contact_from_id, par_act_date) THEN
            -- Уничтожение (RLP)
            RETURN TRUE;
          WHEN is_manager(par_contact_from_id, par_act_date) THEN
            -- Уничтожение (RLP, в случае отсутствия директора)
            RETURN NOT agency_director_exists(par_contact_id => par_contact_from_id
                                             ,par_act_date   => par_act_date);
          WHEN is_warehouse(par_contact_from_id) THEN
            -- Уничтожение (ЦО)
            RETURN TRUE;
          WHEN is_rsp(par_contact_from_id, par_act_date) THEN
            -- Передача между структурными руководителями
            RETURN TRUE;
          ELSE
            RETURN FALSE;
        END CASE;
      WHEN par_doc_templ_brief IN
           ('УтеряБСО', 'ВосстановлениеБСО', 'ИспорченныеБСО') THEN
        -- Акт утери БСО
        -- Акт восстановления БСО
        RETURN TRUE;
      WHEN par_doc_templ_brief = 'ФормированиеБСО' THEN
        RETURN is_supplier(par_contact_id => par_contact_from_id) AND is_supplier(par_contact_id => par_contact_to_id);
      WHEN par_doc_templ_brief = 'НакладнаяБСО' THEN
        RETURN is_supplier(par_contact_id => par_contact_from_id) AND is_warehouse(par_contact_id => par_contact_to_id);
      ELSE
        RETURN FALSE;
    END CASE;
  
    RETURN FALSE;
  
  END check_transfer_rules;

  PROCEDURE validate_doc_cont_record
  (
    par_bso_series_id   NUMBER
   ,par_contact_from_id NUMBER
   ,par_contact_to_id   NUMBER
   ,par_doc_templ_brief VARCHAR2
   ,par_num_start       VARCHAR2
   ,par_num_end         VARCHAR2
  ) IS
    v_bso_series_num bso_series.series_num%TYPE;
    v_chars_in_num   bso_series.chars_in_num%TYPE;
    v_start_num      bso_doc_cont.num_start%TYPE;
    v_end_num        bso_doc_cont.num_start%TYPE;
    v_bso_type_id    bso_series.bso_type_id%TYPE;
  BEGIN
    SELECT bs.series_num
          ,bs.chars_in_num
          ,bs.bso_type_id
      INTO v_bso_series_num
          ,v_chars_in_num
          ,v_bso_type_id
      FROM bso_series bs
     WHERE bs.bso_series_id = par_bso_series_id;
  
    IF par_doc_templ_brief = 'ФормированиеБСО'
    THEN
      RETURN;
    ELSIF par_doc_templ_brief IN ('УничтожениеБСО', 'СписаниеБСО')
          AND (is_director(par_contact_from_id) OR
          (is_manager(par_contact_from_id) AND
          NOT agency_director_exists(par_contact_id => par_contact_from_id
                                          ,par_act_date   => gv_act_date)) OR
          is_rsp(par_contact_from_id, gv_act_date))
          AND NOT is_bso_type_ac_marked(par_bso_series_id)
    THEN
      raise_application_error(-20001
                             ,'Серия БСО ' || v_bso_series_num || ' должна быть помечена галкой "АС"');
    END IF;
  
    v_start_num := substr(par_num_start, 1, 6);
    v_end_num   := substr(nvl(par_num_end, par_num_start), 1, 6);
  
    FOR i IN to_number(v_start_num) .. to_number(v_end_num)
    LOOP
      DECLARE
        v_count        NUMBER;
        v_bso_number   bso.num%TYPE;
        v_contact_name contact.obj_name_orig%TYPE;
      BEGIN
        -- Для новых БСО определяем контрольную цифру
        IF v_chars_in_num > 6
        THEN
          v_bso_number := substr(pkg_xx_pol_ids.cre_new_ids(p_ser      => v_bso_series_num
                                                           ,p_note_ser => lpad(i, v_chars_in_num))
                                ,4);
        ELSE
          v_bso_number := lpad(i, v_chars_in_num);
        END IF;
      
        IF par_doc_templ_brief IN
           ('УничтожениеБСО', 'ВосстановлениеБСО')
        THEN
        
          SELECT COUNT(*)
            INTO v_count
            FROM dual
           WHERE EXISTS
           (SELECT NULL
                    FROM bso           b
                        ,bso_hist_type ht
                   WHERE b.hist_type_id = ht.bso_hist_type_id
                     AND ((ht.brief IN ('Списан', 'Испорчен') AND
                         par_doc_templ_brief = 'УничтожениеБСО') OR
                         (ht.brief IN
                         ('Списан', 'Испорчен', 'Утерян', 'Уничтожен') AND
                         par_doc_templ_brief = 'ВосстановлениеБСО'))
                     AND b.bso_series_id = par_bso_series_id
                     AND b.num = v_bso_number);
        
          IF v_count = 0
          THEN
            IF par_doc_templ_brief = 'УничтожениеБСО'
            THEN
              raise_application_error(-20001
                                     ,'БСО ' || v_bso_number || ' не в статусе Списан/Испорчен');
            ELSIF par_doc_templ_brief = 'ВосстановлениеБСО'
            THEN
              raise_application_error(-20001
                                     ,'БСО ' || v_bso_number ||
                                      ' не в статусе Списан/Испорчен/Утерян/Уничтожен');
            END IF;
          END IF;
        
        ELSE
          IF par_contact_to_id IS NOT NULL
          --is_dummy_bso_owner_contact_id(par_contact_to_id)
          THEN
            SELECT COUNT(*)
              INTO v_count
              FROM dual
             WHERE EXISTS
             (SELECT NULL
                      FROM bso           b
                          ,bso_hist_type ht
                    --,bso_type      bt
                     WHERE b.hist_type_id = ht.bso_hist_type_id
                       AND ht.brief IN ('Склад ЦО', 'Передан', 'Сформирован')
                       AND b.bso_series_id = par_bso_series_id
                          --AND bt.bso_type_id = v_bso_type_id
                          --AND nvl(bt.check_mo, 0) = 0
                       AND b.contact_id = par_contact_from_id
                       AND b.num = v_bso_number);
          
            IF v_count = 0
            THEN
              SELECT c.obj_name_orig
                INTO v_contact_name
                FROM contact c
               WHERE c.contact_id = par_contact_from_id;
            
              raise_application_error(-20001
                                     ,'БСО ' || v_bso_number || ' нет у ' || v_contact_name);
            END IF;
          END IF;
        END IF;
      END;
    END LOOP;
  
  END validate_doc_cont_record;

  FUNCTION get_od_director_fio(par_act_date DATE DEFAULT NULL) RETURN VARCHAR2 IS
    v_fio contact.obj_name_orig%TYPE;
  BEGIN
    BEGIN
      SELECT obj_name_orig
        INTO v_fio
        FROM (SELECT c.obj_name_orig
                FROM contact       c
                    ,employee_hist eh
                    ,employee      ee
               WHERE upper(TRIM(eh.appointment)) = 'ДИРЕКТОР ОД'
                 AND eh.employee_id = ee.employee_id
                 AND ee.contact_id = c.contact_id
                 AND eh.date_hist <= nvl(par_act_date, gv_act_date)
               ORDER BY eh.date_hist DESC)
       WHERE rownum = 1;
    EXCEPTION
      WHEN no_data_found THEN
        v_fio := 'Не существует контакта с должностью Директор ОД';
    END;
    RETURN v_fio;
  END;

  FUNCTION get_sales_director_fio(par_act_date DATE DEFAULT NULL) RETURN VARCHAR2 IS
    v_fio contact.obj_name_orig%TYPE;
  BEGIN
    BEGIN
      SELECT obj_name_orig
        INTO v_fio
        FROM (SELECT c.obj_name_orig
                FROM contact       c
                    ,employee_hist eh
                    ,employee      ee
                    ,department    d
               WHERE upper(TRIM(eh.appointment)) = 'ДИРЕКТОР'
                 AND d.name = 'Департамент по продажам через банки и брокеров'
                 AND eh.department_id = d.department_id
                 AND eh.employee_id = ee.employee_id
                 AND ee.contact_id = c.contact_id
                 AND eh.date_hist <= nvl(par_act_date, gv_act_date)
               ORDER BY eh.date_hist DESC)
       WHERE rownum = 1;
    
    EXCEPTION
      WHEN no_data_found THEN
        v_fio := 'Не существует контакта с должностью Директор ДПББ';
    END;
    RETURN v_fio;
  END get_sales_director_fio;

  /*
    
    Поле тип Рукводителя/посредника
  */
  FUNCTION get_rep_header_type
  (
    par_bso_document_id NUMBER
   ,par_contact_id      NUMBER
  ) RETURN VARCHAR2 IS
    v_header_type           VARCHAR2(1000);
    v_act_date              DATE;
    v_bso_doc_templ         doc_templ.brief%TYPE;
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
    v_leader_contact_id     NUMBER;
    v_category_brief        ag_category_agent.brief%TYPE;
    v_contact_to_id         bso_document.contact_from_id%TYPE;
    v_contact_from_id       bso_document.contact_from_id%TYPE;
  BEGIN
    SELECT reg_date
          ,dt.brief
          ,d.contact_from_id
          ,d.contact_to_id
      INTO v_act_date
          ,v_bso_doc_templ
          ,v_contact_to_id
          ,v_contact_from_id
      FROM ven_bso_document d
          ,doc_templ        dt
     WHERE d.bso_document_id = par_bso_document_id
       AND d.doc_templ_id = dt.doc_templ_id;
  
    -- Акт приема-передачи БСО
    IF v_bso_doc_templ = 'ПередачаБСО'
    THEN
    
      IF is_warehouse(par_contact_id)
         OR is_rsp(par_contact_id)
         OR is_rla(par_contact_id)
      THEN
        v_header_type := 'Компания';
      ELSIF is_rlp(par_contact_id)
            OR is_rsp_agent(par_contact_id, v_act_date)
            OR is_rla_subagent(par_contact_id, v_act_date)
      THEN
        v_header_type := 'Агент';
      ELSIF is_director(par_contact_id, v_act_date)
            OR is_manager(par_contact_id, v_act_date)
      THEN
        v_header_type := 'Директор/Менеджер';
      ELSIF is_rlp_agent(par_contact_id, v_act_date)
      THEN
        v_header_type := 'Субагент';
      ELSIF is_co_worker(par_contact_id)
      THEN
        v_header_type := 'Сотрудник ЦО';
      ELSIF is_co_worker_agents(par_contact_id)
      THEN
        IF (v_contact_to_id = par_contact_id AND is_agent_broker(v_contact_from_id, v_act_date))
           OR (v_contact_from_id = par_contact_id AND is_agent_broker(v_contact_to_id, v_act_date))
        THEN
          v_header_type := 'Компания';
        ELSE
          v_header_type := 'Директор ДПББ';
        END IF;
      ELSIF is_agent_broker(par_contact_id, v_act_date)
      THEN
        v_header_type := 'Агент/брокер';
      ELSE
        v_header_type := 'НЕ УДАЛОСЬ ОПРЕДЕЛИТЬ!!!';
      END IF;
    
      -- Акт утери БСО
    ELSIF v_bso_doc_templ IN ('УтеряБСО', 'ИспорченныеБСО')
    THEN
    
      IF is_rsp(par_contact_id, v_act_date)
      THEN
        v_header_type := 'Компания';
      ELSIF is_director(par_contact_id, v_act_date)
            OR is_manager(par_contact_id, v_act_date)
      THEN
        v_header_type := 'Директор/Менеджер';
      ELSIF is_rlp_agent(par_contact_id, v_act_date)
      THEN
        v_header_type := 'Субагент';
      ELSIF is_rla_subagent(par_contact_id, v_act_date)
            OR is_rla(par_contact_id)
      THEN
        v_header_type := 'Агент';
      ELSIF is_rsp_agent(par_contact_id, v_act_date)
      THEN
        v_leader_contact_id := get_leader_contact_id(par_contact_id => par_contact_id
                                                    ,par_act_date   => v_act_date);
      
        v_category_brief := get_agent_category(v_leader_contact_id, v_act_date);
      
        SELECT a.category_name
          INTO v_header_type
          FROM ag_category_agent a
         WHERE a.brief = v_category_brief;
      
      ELSIF is_co_worker(par_contact_id => par_contact_id)
      THEN
        v_header_type := 'Директор ОД';
      ELSIF is_co_worker_agents(par_contact_id => par_contact_id)
      THEN
        v_header_type := 'Директор ДПББ';
      ELSIF is_agent_broker(par_contact_id => par_contact_id, par_act_date => v_act_date)
      THEN
        v_header_type := 'Агент/Брокер';
      ELSE
        v_header_type := 'НЕ УДАЛОСЬ ОПРЕДЕЛИТЬ!!!';
      END IF;
    
    END IF;
  
    RETURN v_header_type;
  
  END get_rep_header_type;

  FUNCTION get_rep_header
  (
    par_bso_document_id NUMBER
   ,par_contact_id      NUMBER
  ) RETURN VARCHAR2 IS
    v_header            VARCHAR2(4000);
    v_act_date          ven_bso_document.reg_date%TYPE;
    v_bso_doc_templ     doc_templ.brief%TYPE;
    v_ag_category_brief ag_category_agent.brief%TYPE;
    v_contact_to_id     bso_document.contact_from_id%TYPE;
    v_contact_from_id   bso_document.contact_from_id%TYPE;
  BEGIN
    assert_deprecated(par_condition => par_contact_id IS NULL
          ,par_msg       => 'Ид контакта не может быть пустым');
    SELECT reg_date
          ,dt.brief
          ,d.contact_from_id
          ,d.contact_to_id
      INTO v_act_date
          ,v_bso_doc_templ
          ,v_contact_from_id
          ,v_contact_to_id
      FROM ven_bso_document d
          ,doc_templ        dt
     WHERE d.bso_document_id = par_bso_document_id
       AND d.doc_templ_id = dt.doc_templ_id;
  
    -- Акт приема-передачи БСО
    IF v_bso_doc_templ = 'ПередачаБСО'
    THEN
    
      IF is_rlp(par_contact_id)
      THEN
        SELECT c.obj_name_orig
          INTO v_header
          FROM contact c
         WHERE c.contact_id = gv_renlife_partners_id;
      ELSIF is_warehouse(par_contact_id)
      THEN
        SELECT c.obj_name_orig
          INTO v_header
          FROM contact c
         WHERE c.contact_id = gv_renlife_contact_id;
      ELSIF is_rla(par_contact_id)
      THEN
        SELECT c.obj_name_orig INTO v_header FROM contact c WHERE c.contact_id = gv_rla_contact_id;
      ELSIF is_rlp_subagent(par_contact_id, v_act_date)
      THEN
        v_ag_category_brief := get_agent_category(par_contact_id, v_act_date);
        IF v_ag_category_brief LIKE 'DR%'
        THEN
          v_header := 'Директор';
        ELSE
          SELECT t.category_name
            INTO v_header
            FROM ag_category_agent t
           WHERE t.brief = v_ag_category_brief;
        END IF;
      ELSIF is_co_worker(par_contact_id)
      THEN
        v_header := get_od_director_fio(v_act_date);
      ELSIF is_co_worker_agents(par_contact_id)
      THEN
        IF (v_contact_to_id = par_contact_id AND is_agent_broker(v_contact_from_id, v_act_date))
           OR (v_contact_from_id = par_contact_id AND is_agent_broker(v_contact_to_id, v_act_date))
        THEN
          SELECT c.obj_name_orig
            INTO v_header
            FROM contact c
           WHERE c.contact_id = gv_renlife_contact_id;
        ELSE
          v_header := get_sales_director_fio(v_act_date);
        END IF;
      ELSIF is_rsp(par_contact_id, v_act_date)
            OR is_rsp_agent(par_contact_id, v_act_date)
      THEN
        v_ag_category_brief := get_agent_category(par_contact_id, v_act_date);
        SELECT t.category_name
          INTO v_header
          FROM ag_category_agent t
         WHERE t.brief = v_ag_category_brief;
      ELSIF is_rla_subagent(par_contact_id => par_contact_id, par_act_date => v_act_date)
      THEN
        SELECT obj_name_orig INTO v_header FROM contact c WHERE c.contact_id = gv_rla_contact_id;
      ELSIF is_agent_broker(par_contact_id => par_contact_id, par_act_date => v_act_date)
      THEN
        SELECT obj_name_orig INTO v_header FROM contact c WHERE c.contact_id = par_contact_id;
      END IF;
    ELSIF v_bso_doc_templ IN ('УтеряБСО', 'ИспорченныеБСО')
    THEN
      IF is_rlp_subagent(par_contact_id, v_act_date)
      THEN
        v_ag_category_brief := get_agent_category(par_contact_id, v_act_date);
        IF v_ag_category_brief LIKE 'DR%'
        THEN
          v_header := 'Директор';
        ELSE
          SELECT t.category_name
            INTO v_header
            FROM ag_category_agent t
           WHERE t.brief = v_ag_category_brief;
        END IF;
      ELSIF is_rsp(par_contact_id, v_act_date)
      THEN
        v_ag_category_brief := get_agent_category(par_contact_id, v_act_date);
        SELECT t.category_name
          INTO v_header
          FROM ag_category_agent t
         WHERE t.brief = v_ag_category_brief;
      ELSIF is_rsp_agent(par_contact_id, v_act_date)
      THEN
        v_header := get_leader_fio(par_contact_id, v_act_date);
      ELSIF is_rla_subagent(par_contact_id => par_contact_id, par_act_date => v_act_date)
      THEN
        SELECT obj_name_orig INTO v_header FROM contact c WHERE c.contact_id = gv_rla_contact_id;
      ELSIF is_co_worker(par_contact_id)
      THEN
        v_header := get_od_director_fio(v_act_date);
      ELSIF is_co_worker_agents(par_contact_id)
      THEN
        v_header := get_sales_director_fio(v_act_date);
      ELSIF is_agent_broker(par_contact_id, v_act_date)
            OR is_rla(par_contact_id)
      THEN
        SELECT obj_name_orig INTO v_header FROM contact c WHERE contact_id = par_contact_id;
      ELSE
        v_header := 'НЕ УДАЛОСЬ ОПРЕДЕЛИТЬ!!!';
      END IF;
    END IF;
  
    RETURN v_header;
  
  END get_rep_header;

  FUNCTION get_rep_contact_name
  (
    par_bso_document_id NUMBER
   ,par_contact_id      NUMBER
  ) RETURN VARCHAR2 IS
    v_contact_name      contact.obj_name_orig%TYPE;
    v_act_date          ven_bso_document.reg_date%TYPE;
    v_bso_doc_templ     doc_templ.brief%TYPE;
    v_ag_category_brief ag_category_agent.brief%TYPE;
  BEGIN
  
    SELECT reg_date
          ,dt.brief
      INTO v_act_date
          ,v_bso_doc_templ
      FROM ven_bso_document d
          ,doc_templ        dt
     WHERE d.bso_document_id = par_bso_document_id
       AND d.doc_templ_id = dt.doc_templ_id;
  
    IF is_rlp_subagent(par_contact_id, v_act_date)
       OR is_co_worker(par_contact_id)
       OR is_co_worker_agents(par_contact_id)
       OR is_rsp(par_contact_id)
       OR is_rsp_agent(par_contact_id, v_act_date)
       OR is_rlp(par_contact_id => par_contact_id)
       OR is_warehouse(par_contact_id => par_contact_id)
       OR is_rla_subagent(par_contact_id => par_contact_id, par_act_date => v_act_date)
    THEN
      SELECT c.obj_name_orig INTO v_contact_name FROM contact c WHERE c.contact_id = par_contact_id;
    ELSIF is_agent_broker(par_contact_id => par_contact_id, par_act_date => v_act_date)
          OR is_rla(par_contact_id => par_contact_id)
    THEN
      NULL;
      /*  BEGIN
        SELECT c.obj_name_orig
          INTO RESULT
          FROM contact         c
              ,cn_contact_role cr
              ,t_contact_role  r
         WHERE c.contact_id = cr.contact_id
           AND cr.role_id = r.id
           AND r.brief = 'BSO_USER'
           AND rownum < 2;
      EXCEPTION
        WHEN no_data_found THEN
          NULL;
      END;*/
    ELSE
      v_contact_name := 'НЕ УДАЛОСЬ ОПРЕДЕЛИТЬ!!!';
    END IF;
  
    RETURN v_contact_name;
  
  END get_rep_contact_name;

  FUNCTION is_inside_rlp_transfer(par_bso_document_id NUMBER) RETURN BOOLEAN IS
    v_result          BOOLEAN := FALSE;
    v_contact_from_id NUMBER;
    v_contact_to_id   NUMBER;
    v_act_date        DATE;
  BEGIN
    SELECT bd.contact_from_id
          ,bd.contact_to_id
          ,bd.reg_date
      INTO v_contact_from_id
          ,v_contact_to_id
          ,v_act_date
      FROM ven_bso_document bd
     WHERE bd.bso_document_id = par_bso_document_id;
  
    IF v_contact_to_id IS NULL
    THEN
      v_result := is_manager(v_contact_from_id) OR is_director(v_contact_from_id) OR
                  is_rlp_agent(v_contact_from_id, v_act_date);
    ELSIF is_manager(v_contact_from_id)
          OR is_director(v_contact_from_id)
          OR is_manager(v_contact_to_id)
          OR is_director(v_contact_to_id)
          OR (is_rlp(v_contact_from_id) AND
              (NOT is_warehouse(v_contact_to_id) OR v_contact_to_id IS NULL))
          OR (is_rlp(v_contact_to_id) AND NOT is_warehouse(v_contact_from_id))
    THEN
      v_result := TRUE;
    END IF;
  
    RETURN v_result;
  END is_inside_rlp_transfer;

  FUNCTION is_rlp_warehouse_transfer(par_bso_document_id NUMBER) RETURN BOOLEAN IS
    RESULT            BOOLEAN;
    v_contact_from_id NUMBER;
    v_contact_to_id   NUMBER;
  BEGIN
    SELECT bd.contact_from_id
          ,bd.contact_to_id
      INTO v_contact_from_id
          ,v_contact_to_id
      FROM bso_document bd
     WHERE bd.bso_document_id = par_bso_document_id;
  
    RESULT := (is_rlp(v_contact_from_id) AND is_warehouse(v_contact_to_id)) OR
              (is_rlp(v_contact_to_id) AND is_warehouse(v_contact_from_id));
  
    RETURN RESULT;
  END is_rlp_warehouse_transfer;

  FUNCTION get_leader_contact_id
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_contact_id            contact.contact_id%TYPE;
    v_ag_contract_header_id ag_contract_header.ag_contract_header_id%TYPE;
  BEGIN
    BEGIN
      v_ag_contract_header_id := get_ag_header_by_contact(par_contact_id => par_contact_id
                                                         ,par_act_date   => nvl(par_act_date
                                                                               ,gv_act_date));
    
      SELECT c.contact_id
        INTO v_contact_id
        FROM contact            c
            ,ag_contract_header h2
            ,ag_agent_tree      t
       WHERE t.ag_contract_header_id = v_ag_contract_header_id
         AND t.ag_parent_header_id = h2.ag_contract_header_id
         AND nvl(par_act_date, gv_act_date) BETWEEN t.date_begin AND t.date_end
         AND doc.get_doc_status_brief(h2.ag_contract_header_id, nvl(par_act_date, gv_act_date)) =
             'CURRENT'
         AND c.contact_id = h2.agent_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN too_many_rows THEN
        raise_application_error(-20001
                               ,'Не удалось однозначно определить руководителя для данного контакта');
      
    END;
    RETURN v_contact_id;
  END get_leader_contact_id;

  FUNCTION get_leader_fio
  (
    par_contact_id NUMBER
   ,par_act_date   DATE DEFAULT NULL
  ) RETURN VARCHAR2 IS
    RESULT       contact.obj_name_orig%TYPE;
    v_contact_id contact.contact_id%TYPE;
  BEGIN
    v_contact_id := get_leader_contact_id(par_contact_id, par_act_date);
  
    BEGIN
      SELECT obj_name_orig INTO RESULT FROM contact c WHERE c.contact_id = v_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    RETURN RESULT;
  END get_leader_fio;

  FUNCTION get_company_name RETURN VARCHAR2 IS
    RESULT contact.obj_name_orig%TYPE;
  BEGIN
    SELECT c.obj_name_orig INTO RESULT FROM contact c WHERE c.contact_id = gv_renlife_contact_id;
    RETURN RESULT;
  END;

  /* 
  Капля П.
  Определение стоимости БСО на дату
   */
  FUNCTION get_bso_cost
  (
    par_bso_series_id bso_series.bso_series_id%TYPE
   ,par_act_date      DATE
  ) RETURN t_bso_cost.bso_cost%TYPE IS
    v_bso_cost t_bso_cost.bso_cost%TYPE;
  BEGIN
    BEGIN
      SELECT bc.bso_cost
        INTO v_bso_cost
        FROM t_bso_cost bc
       WHERE bc.bso_series_id = par_bso_series_id
         AND par_act_date BETWEEN bc.cost_date_begin AND nvl(bc.cost_date_end, bc.cost_date_begin);
    EXCEPTION
      WHEN no_data_found
           OR too_many_rows THEN
        v_bso_cost := 0;
    END;
    RETURN v_bso_cost;
  END get_bso_cost;

BEGIN
  -- Initialization
  SELECT contact_id
    INTO gv_warehouse_contact_id
    FROM contact c
   WHERE c.obj_name_orig = 'Склад Ц О';

  SELECT c.contact_id
    INTO gv_supplied_contact_id
    FROM contact c
   WHERE c.obj_name_orig = 'Типография';

  SELECT c.contact_id
    INTO gv_dummy_bso_owner_contact_id
    FROM contact c
   WHERE c.obj_name_orig = 'Владелец Фиктивных Бсо';

  SELECT c.contact_id
    INTO gv_renlife_contact_id
    FROM contact c
   WHERE c.obj_name_orig = '"СК "Ренессанс Жизнь"';

  SELECT contact_id
    INTO gv_renlife_partners_id
    FROM contact c
   WHERE c.obj_name_orig = 'ЗАО "РенЛайф Партнерс"';

  SELECT MAX(c.contact_id)
    INTO gv_rla_contact_id
    FROM contact c
   WHERE c.obj_name_orig = 'ООО "Ренессанс Лайф Актив"';

  BEGIN
    SELECT c.contact_id INTO gv_rlp_contact_id FROM contact c WHERE c.obj_name_orig = 'RLP';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;
END pkg_bso_fmb; 
/
