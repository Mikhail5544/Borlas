CREATE OR REPLACE PACKAGE PKG_AI_GATE IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 03.07.2008 19:04:19
  -- Purpose : Для взаимодействия с AI

  -- Public type declarations
  /*TYPE <TypeName> IS <Datatype>;
  
  -- Public constant declarations
  <ConstantName> CONSTANT <Datatype> := <VALUE>;
  
  -- Public variable declarations
  <VariableName> <Datatype>;*/

  -- Public function and procedure declarations
  PROCEDURE File_create;

END PKG_AI_GATE;
/
CREATE OR REPLACE PACKAGE BODY PKG_AI_GATE IS

  /*  -- Private type declarations
  TYPE <TypeName> IS <Datatype>;
  
  -- Private constant declarations
  <ConstantName> CONSTANT <Datatype> := <VALUE>;
  
  -- Private variable declarations
  <VariableName> <Datatype>;*/
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 03.07.2008 19:06:35
  -- Purpose : Выгрузка данных в файл обмена
  PROCEDURE File_create IS
    exp_file  utl_file.file_type;
    exp_sting VARCHAR2(4000);
    dr        VARCHAR2(1) := ';';
    v_pas_ser VARCHAR2(10);
    v_pas_num VARCHAR2(10);
  BEGIN
    exp_file := utl_file.fopen('AIGATE_DIR', 'bor.csv', 'w');
    FOR r IN (SELECT ach.ag_contract_header_id
                    ,cp.contact_id
                    ,cp.NAME agent_surname
                    ,cp.first_name agent_name
                    ,cp.middle_name agent_second_name
                    ,cp.date_of_birth date_of_birth
                    ,ci.serial_nr pass_ser
                    ,ci.id_value pass_num
                    ,ci.issue_date pass_date
                    ,ci.place_of_issue pass_issued_by
                    ,ac.agency_id
                    ,vd.NAME agency_name
                    ,doc.get_doc_status_id(ag_contract_id, SYSDATE) doc_status_ref_id
                    ,doc.get_doc_status_name(ag_contract_id, SYSDATE) doc_status_ref_name
                    ,vca.ag_category_agent_id
                    ,vca.category_name
                    ,vcla.ag_class_agent_id
                    ,vcla.class_name
                    ,ac.leg_pos
                    ,ach.t_sales_channel_id
                    ,(SELECT contract_id
                        FROM ven_ag_contract a1
                       WHERE a1.ag_contract_id = ac.contract_leader_id) contract_leader_id
                    ,(SELECT contract_id
                        FROM ven_ag_contract a1
                       WHERE a1.ag_contract_id = ac.contract_f_lead_id) contract_f_lead_id
                    ,(SELECT contract_id
                        FROM ven_ag_contract a1
                       WHERE a1.ag_contract_id = ac.contract_recrut_id) contract_recrut_id
                    ,ac.date_begin
                    ,ac.date_end
                FROM ven_ag_contract_header ach
                    ,ven_ag_contract ac
                    ,ven_cn_person cp
                    ,(SELECT *
                        FROM (SELECT cci.contact_id
                                    ,cci.serial_nr
                                    ,cci.id_value
                                    ,cci.place_of_issue
                                    ,cci.issue_date
                                    ,ROW_NUMber() over(PARTITION BY cci.contact_id ORDER BY NVL(cci.is_default, 0) DESC, tit.SORT_ORDER, nvl(cci.issue_date, '01.01.1900') DESC) rn
                                FROM ven_cn_contact_ident cci
                                    ,ven_t_id_type        tit
                               WHERE cci.id_type = tit.ID
                                 AND tit.brief = 'PASS_RF')
                       WHERE rn = 1) ci
                    ,ven_department vd
                    ,ven_ag_category_agent vca
                    ,ven_ag_class_agent vcla
               WHERE ach.last_ver_id = ac.ag_contract_id
                 AND ach.agent_id = cp.contact_id
                 AND cp.contact_id = ci.contact_id(+)
                 AND vca.ag_category_agent_id(+) = ac.category_id
                 AND vcla.ag_class_agent_id(+) = ac.class_agent_id
                 AND vd.department_id = ac.agency_id
                 AND ac.date_begin <= SYSDATE)
    
    LOOP
      /*Т.к. выгружаем паспорта по которым потом будем вязать людей
      то пофиксим всякие неточности ввода и приведем все к общему виду
      пока что просто выбрасываем нафик*/
    
      --TODO: Сделать занесениt в лог всяких косякоффф
      BEGIN
        /*Нашлись таки индивиды с белорусским папортом =(((*/
        --v_pas_ser:= to_number(REPLACE(r.pass_ser, ' '));
        v_pas_ser := REPLACE(r.pass_ser, ' ');
      
        --v_pas_num:= to_number(r.pass_num);
        v_pas_num := r.pass_num;
      
        IF length(v_pas_ser) <> 4
        THEN
          NULL; --raise_application_error(-20001,SQLERRM||' Здесь могла быть ваша реклама'); 
        END IF;
      
      EXCEPTION
        WHEN INVALID_NUMBER
             OR VALUE_ERROR THEN
          GOTO next_loop;
        WHEN OTHERS THEN
          raise_application_error(-20001
                                 ,SQLERRM || ' Здесь могла быть ваша реклама');
      END;
    
      exp_sting := r.ag_contract_header_id || dr || r.contact_id || dr || r.agent_surname || dr ||
                   r.agent_name || dr || r.agent_second_name || dr || r.date_of_birth || dr ||
                   v_pas_ser || dr || v_pas_num || dr || r.pass_date || dr || r.pass_issued_by || dr ||
                   r.agency_id || dr || r.agency_name || dr || r.doc_status_ref_id || dr ||
                   r.doc_status_ref_name || dr || r.ag_category_agent_id || dr || r.category_name || dr ||
                   r.ag_class_agent_id || dr || r.class_name || dr || r.leg_pos || dr ||
                   r.t_sales_channel_id || dr || r.contract_leader_id || dr || r.contract_f_lead_id || dr ||
                   r.contract_recrut_id || dr || r.date_begin || dr || r.date_end;
      utl_file.put_line(exp_file, exp_sting);
    
      <<next_loop>>
      NULL;
    END LOOP;
    utl_file.fclose(exp_file);
  END File_create;

BEGIN
  NULL;
  -- Initialization
-- <STATEMENT>;
END PKG_AI_GATE;
/
