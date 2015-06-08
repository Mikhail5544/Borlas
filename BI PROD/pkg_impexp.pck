CREATE OR REPLACE PACKAGE pkg_impexp IS

  -- Загрузка договоров страхования из представления LDR_POLICY
  PROCEDURE load_from_ldr_policy;

  -- Загрузка застрахованных по договору ДМС из представления LDR_PERSON_MED
  --procedure load_from_ldr_person_med(p_policy_id number, p_asset_type_id number);

  PROCEDURE update_contact(par_contact_id IN NUMBER);

  --procedure contact_to_xml;

  PROCEDURE export_to_xml;

  PROCEDURE update_pol_header(par_pol_header IN NUMBER);

END pkg_impexp;
/
CREATE OR REPLACE PACKAGE BODY pkg_impexp IS

  PROCEDURE clob2file
  (
    par_clob IN CLOB
   ,par_file IN utl_file.file_type
  ) IS
    v_len NUMBER := length(par_clob);
    i     NUMBER := 0;
  BEGIN
    dbms_output.put_line(v_len);
    WHILE i * 32000 < v_len
    LOOP
      utl_file.put(par_file, dbms_lob.substr(par_clob, 32000, i * 32000 + 1));
      --dbms_output.put_line(dbms_lob.substr(par_clob, 100, i * 100 + 1));
      utl_file.fflush(par_file);
    
      i := i + 1;
    END LOOP;
  END;

  PROCEDURE clob2file
  (
    par_clob IN CLOB
   ,par_file IN VARCHAR2
   ,par_path IN VARCHAR2
  ) IS
    --v_len  number := length(par_clob);
    --i      number := 0;
    v_file utl_file.file_type;
  BEGIN
    v_file := utl_file.fopen(par_path, par_file, 'w');
    /*while i * 32000 < v_len loop
      utl_file.put(v_file, substr(par_clob, i * 32000 + 1, 32000));
      i := i + 1;
    end loop;*/
    clob2file(par_clob, v_file);
    utl_file.fclose(v_file);
  EXCEPTION
    WHEN OTHERS THEN
      utl_file.fclose(v_file);
      RAISE;
  END;
  /*
    procedure contact_to_xml is
      v_clob clob;
      v_ctx  dbms_xmlquery.ctxType;
      v_path varchar2(2000) := pkg_app_param.get_app_param_c('ЭКСПОРТКОНТАКТ');
    begin
      v_ctx := dbms_xmlquery.newContext('select * from exp_contact where contact_id = :p_id');
      dbms_xmlquery.setEncodingTag(v_ctx, 'windows-1251');
      for rec in (select contact_id from exp_contact where is_uploaded = 0) loop
        begin
          dbms_xmlquery.setBindValue(v_ctx, 'p_id', rec.contact_id);
          v_clob := dbms_xmlquery.getXML(v_ctx);
          clob2file(v_clob,
                    'exp-contact-' || rec.contact_id || '.xml',
                    v_path);
          update exp_contact
             set is_uploaded = 1
           where contact_id = rec.contact_id;
        exception
          when others then
            null;
        end;
      end loop;
      dbms_xmlquery.closeContext(v_ctx);
    exception
      when others then
        dbms_output.put_line(sqlerrm);
        dbms_xmlquery.closeContext(v_ctx);
    end;
  */
  FUNCTION contact_to_xml RETURN CLOB IS
    v_clob CLOB;
    v_ctx  dbms_xmlquery.ctxType;
  BEGIN
    v_ctx := dbms_xmlquery.newContext('select * from exp_contact where is_uploaded = 0 order by recno for update nowait');
    dbms_xmlquery.setEncodingTag(v_ctx, 'windows-1251');
    dbms_xmlquery.setRowsetTag(v_ctx, 'CONTACTS');
    dbms_xmlquery.setRowTag(v_ctx, 'CONTACT');
    dbms_xmlquery.setDateFormat(v_ctx, 'yyyyMMddhhmmss');
    v_clob := dbms_xmlquery.getXML(v_ctx);
    dbms_xmlquery.closeContext(v_ctx);
    UPDATE exp_contact
       SET is_uploaded    = 1
          ,uploading_date = SYSDATE
     WHERE is_uploaded = 0;
    RETURN v_clob;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_xmlquery.closeContext(v_ctx);
      RETURN NULL;
  END;

  FUNCTION agent_to_xml RETURN CLOB IS
    v_clob CLOB;
    v_ctx  dbms_xmlquery.ctxType;
  BEGIN
    v_ctx := dbms_xmlquery.newContext('select * from exp_agent where is_uploaded = 0 order by recno for update nowait');
    dbms_xmlquery.setEncodingTag(v_ctx, 'windows-1251');
    dbms_xmlquery.setRowsetTag(v_ctx, 'AGENTS');
    dbms_xmlquery.setRowTag(v_ctx, 'AGENT');
    dbms_xmlquery.setDateFormat(v_ctx, 'yyyyMMddhhmmss');
    v_clob := dbms_xmlquery.getXML(v_ctx);
    dbms_xmlquery.closeContext(v_ctx);
    UPDATE exp_agent
       SET is_uploaded    = 1
          ,uploading_date = SYSDATE
     WHERE is_uploaded = 0;
    RETURN v_clob;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_xmlquery.closeContext(v_ctx);
      RETURN NULL;
  END;

  FUNCTION pol_header_to_xml RETURN CLOB IS
    v_clob CLOB;
    v_ctx  dbms_xmlquery.ctxType;
  BEGIN
    v_ctx := dbms_xmlquery.newContext('select * from exp_pol_header where is_uploaded = 0 order by recno for update nowait');
    dbms_xmlquery.setEncodingTag(v_ctx, 'windows-1251');
    dbms_xmlquery.setRowsetTag(v_ctx, 'AGREEMENTS');
    dbms_xmlquery.setRowTag(v_ctx, 'AGREEMENT');
    dbms_xmlquery.setDateFormat(v_ctx, 'yyyyMMddhhmmss');
    v_clob := dbms_xmlquery.getXML(v_ctx);
    dbms_xmlquery.closeContext(v_ctx);
    UPDATE exp_pol_header
       SET is_uploaded    = 1
          ,uploading_date = SYSDATE
     WHERE is_uploaded = 0;
    RETURN v_clob;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_xmlquery.closeContext(v_ctx);
      RETURN NULL;
  END;

  PROCEDURE export_to_xml IS
    v_file utl_file.file_type;
  BEGIN
    -- открыли файл
    v_file := utl_file.fopen(pkg_app_param.get_app_param_c('ЭКСПОРТПУТЬ')
                            ,'export-contact-' || to_char(SYSDATE, 'YYYYMMDDHH24MISS') || '.xml'
                            ,'w');
    -- выгружаем контакты
    clob2file(contact_to_xml, v_file);
    -- закрыли файл
    utl_file.fclose(v_file);
    -- открыли файл
    v_file := utl_file.fopen(pkg_app_param.get_app_param_c('ЭКСПОРТПУТЬ')
                            ,'export-agent-' || to_char(SYSDATE, 'YYYYMMDDHH24MISS') || '.xml'
                            ,'w');
    -- выгружаем агентов
    clob2file(agent_to_xml, v_file);
    -- закрыли файл
    utl_file.fclose(v_file);
    -- открыли файл
    v_file := utl_file.fopen(pkg_app_param.get_app_param_c('ЭКСПОРТПУТЬ')
                            ,'export-policy-' || to_char(SYSDATE, 'YYYYMMDDHH24MISS') || '.xml'
                            ,'w');
    -- выгружаем агентов
    clob2file(pol_header_to_xml, v_file);
    -- закрыли файл
    utl_file.fclose(v_file);
  
  EXCEPTION
    WHEN OTHERS THEN
      utl_file.fclose(v_file);
      RAISE;
  END;

  PROCEDURE update_pol_header(par_pol_header IN NUMBER) IS
  BEGIN
    INSERT INTO exp_pol_header
      SELECT sys_sq_export.nextval
            ,e.*
        FROM v_exp_pol_header e
       WHERE e.pol_header_id = par_pol_header;
  END;

  PROCEDURE update_contact(par_contact_id IN NUMBER) IS
    --v_old_rec exp_contact%rowtype;
    --v_new_rec exp_contact%rowtype;
    --v_ins_fl  boolean;
  BEGIN
    INSERT INTO exp_contact
      SELECT sys_sq_export.nextval
            ,e.*
        FROM v_exp_contact e
       WHERE e.contact_id = par_contact_id;
  
    INSERT INTO exp_agent
      SELECT sys_sq_export.nextval
            ,e.*
        FROM v_exp_agent e
       WHERE e.agent_id = par_contact_id;
  
    /*  select e.*
        into v_new_rec
        from v_exp_contact e
       where e.contact_id = par_contact_id;
    
      begin
        select e.*
          into v_old_rec
          from exp_contact e
         where e.contact_id = par_contact_id;
      exception
        when no_data_found then
          v_ins_fl := true;
      end;
    
      if v_ins_fl then
        insert into exp_contact values v_new_rec;
      elsif nvl(v_old_rec.contact_type, 'nodatafound') <>
            nvl(v_new_rec.contact_type, 'nodatafound') or
            nvl(v_old_rec.full_name, 'nodatafound') <>
            nvl(v_new_rec.full_name, 'nodatafound') or
            nvl(v_old_rec.legal_adr, 'nodatafound') <>
            nvl(v_new_rec.legal_adr, 'nodatafound') or
            nvl(v_old_rec.postal_adr, 'nodatafound') <>
            nvl(v_new_rec.postal_adr, 'nodatafound') or
            nvl(v_old_rec.phones, 'nodatafound') <>
            nvl(v_new_rec.phones, 'nodatafound') or
            nvl(v_old_rec.inn, 'nodatafound') <>
            nvl(v_new_rec.inn, 'nodatafound') or
            nvl(v_old_rec.doc_series, 'nodatafound') <>
            nvl(v_new_rec.doc_series, 'nodatafound') or
            nvl(v_old_rec.doc_number, 'nodatafound') <>
            nvl(v_new_rec.doc_number, 'nodatafound') or
            nvl(v_old_rec.doc_organ, 'nodatafound') <>
            nvl(v_new_rec.doc_organ, 'nodatafound') or
            nvl(v_old_rec.doc_date, to_date('01011980', 'DDMMYYYY')) <>
            nvl(v_new_rec.doc_date, to_date('01011980', 'DDMMYYYY')) or
            nvl(v_old_rec.birth_date, to_date('01011980', 'DDMMYYYY')) <>
            nvl(v_new_rec.birth_date, to_date('01011980', 'DDMMYYYY')) or
            nvl(v_old_rec.doc_type, 'nodatafound') <>
            nvl(v_new_rec.doc_type, 'nodatafound') or
            nvl(v_old_rec.adr_index, 'nodatafound') <>
            nvl(v_new_rec.adr_index, 'nodatafound') or
            nvl(v_old_rec.adr_kladr, 'nodatafound') <>
            nvl(v_new_rec.adr_kladr, 'nodatafound') or
            nvl(v_old_rec.gender, 'nodatafound') <>
            nvl(v_new_rec.gender, 'nodatafound') or
            nvl(v_old_rec.okato, 'nodatafound') <>
            nvl(v_new_rec.okato, 'nodatafound') then
    
        v_new_rec.is_uploaded := 0;
    
        update exp_contact e
           set (e.contact_id, e.ext_id, e.is_uploaded, e.contact_type, e.full_name, e.legal_adr, e.postal_adr, e.phones, e.inn, e.doc_series, e.doc_number, e.doc_organ, e.doc_date, e.birth_date, e.doc_type, e.adr_index, e.adr_kladr, e.gender, e.okato) = (select v_new_rec.contact_id,
                                                                                                                                                                                                                                                                      v_new_rec.ext_id,
                                                                                                                                                                                                                                                                      v_new_rec.is_uploaded,
                                                                                                                                                                                                                                                                      v_new_rec.contact_type,
                                                                                                                                                                                                                                                                      v_new_rec.full_name,
                                                                                                                                                                                                                                                                      v_new_rec.legal_adr,
                                                                                                                                                                                                                                                                      v_new_rec.postal_adr,
                                                                                                                                                                                                                                                                      v_new_rec.phones,
                                                                                                                                                                                                                                                                      v_new_rec.inn,
                                                                                                                                                                                                                                                                      v_new_rec.doc_series,
                                                                                                                                                                                                                                                                      v_new_rec.doc_number,
                                                                                                                                                                                                                                                                      v_new_rec.doc_organ,
                                                                                                                                                                                                                                                                      v_new_rec.doc_date,
                                                                                                                                                                                                                                                                      v_new_rec.birth_date,
                                                                                                                                                                                                                                                                      v_new_rec.doc_type,
                                                                                                                                                                                                                                                                      v_new_rec.adr_index,
                                                                                                                                                                                                                                                                      v_new_rec.adr_kladr,
                                                                                                                                                                                                                                                                      v_new_rec.gender,
                                                                                                                                                                                                                                                                      v_new_rec.okato
                                                                                                                                                                                                                                                                 from dual)
         where e.contact_id = par_contact_id;
      else
        return;
      end if;
    */
    --contact_to_xml;
  END;

  -- Загрузка договоров страхования из представления LDR_POLICY
  PROCEDURE load_from_ldr_policy IS
    v_LDR ldr_policy%ROWTYPE;
    CURSOR c_LDR IS
      SELECT *
        FROM ldr_policy t
       WHERE NOT EXISTS (SELECT *
                FROM Document     d
                    ,p_pol_header ph
               WHERE d.document_id = ph.policy_header_id
                 AND d.num = t.ser || '-' || t.num);
    v_Pol_Header_ID        NUMBER;
    v_Policy_ID            NUMBER;
    v_Date_Char            VARCHAR2(8);
    v_End_Date             DATE;
    v_product_id           NUMBER;
    v_Sales_Channel_ID     NUMBER;
    v_Company_Tree_ID      NUMBER;
    v_Fund_ID              NUMBER;
    v_Fund_Pay_ID          NUMBER;
    v_Confirm_Condition_ID NUMBER;
    v_Collection_Method_ID NUMBER;
    v_Payment_Term_ID      NUMBER;
    v_Period_ID            NUMBER;
    v_Curator_ID           NUMBER;
    v_Asset_Header_ID      NUMBER;
    v_Asset_Type_ID        NUMBER;
    v_Asset_ID             NUMBER;
    v_Status_Hist_ID       NUMBER;
    v_Birth_Date           DATE;
    v_Cover_ID             NUMBER;
    v_Product_Line_ID      NUMBER;
    v_Is_Loaded            NUMBER;
    v_Message              VARCHAR2(4000);
  BEGIN
    OPEN c_LDR;
    LOOP
      FETCH c_LDR
        INTO v_LDR;
      EXIT WHEN c_LDR%NOTFOUND;
    
      BEGIN
      
        --Создать договор страхования
        SELECT sq_document.nextval INTO v_Policy_ID FROM dual;
        v_Date_Char := to_char(v_LDR.d_Start, 'yyyymmdd');
        CASE
          WHEN v_LDR.d_Term = 'ПОЖИЗН' THEN
            v_End_Date := to_date(to_char(to_number(substr(v_Date_Char, 1, 4)) + 30) ||
                                  substr(v_Date_Char, 5, 4)
                                 ,'yyyymmdd');
          ELSE
            v_End_Date := to_date(to_char(to_number(substr(v_Date_Char, 1, 4)) +
                                          to_number(v_LDR.d_Term)) || substr(v_Date_Char, 5, 4)
                                 ,'yyyymmdd') - 1;
        END CASE;
        SELECT p.product_id INTO v_product_id FROM t_product p WHERE p.brief = 'LIFE';
        SELECT sc.id
          INTO v_Sales_Channel_ID
          FROM t_sales_channel sc
         WHERE sc.description = v_LDR.Sale_Channel;
        SELECT ct.id
          INTO v_Company_Tree_ID
          FROM t_Company_Tree ct
         WHERE ct.description LIKE v_LDR.Dept_Num || ' %';
        SELECT f.fund_id INTO v_Fund_ID FROM fund f WHERE f.brief = v_LDR.Fund;
        SELECT f.fund_id INTO v_Fund_Pay_ID FROM fund f WHERE f.brief = v_LDR.Fund_Pay;
        SELECT cc.id
          INTO v_Confirm_Condition_ID
          FROM t_Confirm_Condition cc
         WHERE cc.description = 'Фикс. дата';
        CASE
          WHEN v_LDR.Pay_Way = 'Нал' THEN
            SELECT cm.id
              INTO v_Collection_Method_ID
              FROM t_Collection_Method cm
             WHERE cm.description = 'Наличный расчет';
          ELSE
            SELECT cm.id
              INTO v_Collection_Method_ID
              FROM t_Collection_Method cm
             WHERE cm.description = 'Безналичный расчет';
        END CASE;
        CASE
          WHEN to_number(v_LDR.Pay_Periodicity) = 1 THEN
            SELECT pt.id
              INTO v_Payment_Term_ID
              FROM t_Payment_Terms pt
             WHERE pt.collection_method_id = v_Collection_Method_ID
               AND pt.description = 'Единовременно';
          WHEN to_number(v_LDR.Pay_Periodicity) = 2 THEN
            SELECT pt.id
              INTO v_Payment_Term_ID
              FROM t_Payment_Terms pt
             WHERE pt.collection_method_id = v_Collection_Method_ID
               AND pt.description = 'Каждые 6 месяцев';
          ELSE
            SELECT pt.id
              INTO v_Payment_Term_ID
              FROM t_Payment_Terms pt
             WHERE pt.collection_method_id = v_Collection_Method_ID
               AND pt.number_of_payments = to_number(v_LDR.Pay_Periodicity);
        END CASE;
        CASE
          WHEN v_LDR.d_Term = 'ПОЖИЗН' THEN
            SELECT p.id INTO v_Period_ID FROM t_period p WHERE p.description = 'Пожизненно';
          ELSE
            SELECT p.id
              INTO v_Period_ID
              FROM t_period p
             WHERE p.description = v_LDR.d_Term || ' лет';
        END CASE;
        SELECT MIN(c.contact_id) INTO v_Curator_ID FROM Contact c WHERE c.name = v_LDR.Cur_Fio;
        v_Pol_Header_ID := pkg_policy.policy_insert(v_Policy_ID
                                                   ,v_product_id
                                                   ,v_sales_channel_id
                                                   ,v_Company_Tree_ID
                                                   ,v_Fund_ID
                                                   ,v_Fund_Pay_ID
                                                   ,v_Confirm_Condition_ID
                                                   ,v_LDR.Ser
                                                   ,v_LDR.Num
                                                   ,v_LDR.d_Start
                                                   ,v_LDR.d_Start
                                                   ,v_LDR.d_Start
                                                   ,v_LDR.d_Start
                                                   ,v_End_Date
                                                   ,v_LDR.d_Start
                                                   ,v_Payment_Term_ID
                                                   ,v_Period_ID
                                                   ,NULL
                                                   ,NULL
                                                   ,v_Curator_ID
                                                   ,v_LDR.Cont_Id
                                                   ,NULL
                                                   ,NULL
                                                   ,0
                                                   ,to_number(v_LDR.Pay_Term)
                                                   ,NULL
                                                   ,NULL
                                                   ,NULL
                                                   ,NULL
                                                   ,NULL);
        dbms_output.put_line('Договор страхования ИД=' || v_Pol_Header_ID);
        --Создать заголовок объекта
        SELECT sq_p_asset_header.nextval INTO v_Asset_Header_ID FROM dual;
        SELECT att.t_asset_type_id
          INTO v_Asset_Type_ID
          FROM t_asset_type att
         WHERE att.brief = 'AS_ASSURED';
        INSERT INTO p_asset_header ah
          (p_asset_header_id, t_asset_type_id)
        VALUES
          (v_Asset_Header_ID, v_Asset_Type_ID);
        dbms_output.put_line('--Заголовок объекта страхования ИД=' || v_Asset_Header_ID);
        --Создать объект страхования
        SELECT sq_as_asset.nextval INTO v_Asset_ID FROM dual;
        SELECT sh.status_hist_id INTO v_Status_Hist_ID FROM Status_Hist sh WHERE sh.brief = 'NEW';
        SELECT cp.date_of_birth
          INTO v_Birth_Date
          FROM Cn_Person cp
         WHERE cp.contact_id = v_LDR.Cont_Id;
        INSERT INTO as_asset a
          (ent_id
          ,as_asset_id
          ,p_asset_header_id
          ,status_hist_id
          ,p_policy_id
          ,ins_amount
          ,ins_premium
          ,contact_id
          ,start_date
          ,end_date)
        VALUES
          (ent.id_by_brief('AS_ASSET_ASSURED')
          ,v_Asset_ID
          ,v_Asset_Header_ID
          ,v_Status_Hist_ID
          ,v_Policy_ID
          ,v_LDR.Ins_Sum
          ,0
          ,v_LDR.Cont_Id
          ,v_LDR.d_Start
          ,v_End_Date);
        INSERT INTO as_asset_assured aa
          (as_asset_assured_id, insured_age)
        VALUES
          (v_Asset_ID, trunc(MONTHS_BETWEEN(v_LDR.d_Start, v_Birth_Date) / 12));
        dbms_output.put_line('--Объект страхования ИД=' || v_Asset_ID);
        --Создать страховое покрытие
        SELECT pl.id
          INTO v_Product_Line_ID
          FROM t_product_line pl
         WHERE pl.description = v_LDR.Ins_Name;
        v_Cover_ID := pkg_cover.cre_new_cover(v_Asset_ID, v_Product_Line_ID);
        dbms_output.put_line('----Страховое покрытие ИД=' || v_Cover_ID);
        --Проапдейтить суммы в покрытии
        UPDATE p_Cover c
           SET c.ins_amount            = v_LDR.Ins_Sum
              ,c.fee                   = v_LDR.Brutto
              ,c.premium               = ROUND(v_LDR.Brutto * to_number(v_LDR.Pay_Periodicity) *
                                               to_number(v_LDR.Pay_Term) * 100) / 100
              ,c.is_handchange_amount  = 1
              ,c.is_handchange_premium = 1
              ,c.is_handchange_deduct  = 1
              ,c.is_handchange_tariff  = 1
         WHERE c.p_cover_id = v_Cover_ID;
        dbms_output.put_line('----Сумма покрытия задана');
        --Апдейт сумм полиса и объектов, установка статуса "Действующий"
        pkg_policy.update_policy_sum(v_Policy_ID);
        --pkg_policy.set_current_status(v_Policy_ID);
        doc.set_doc_status(v_policy_id, 'CURRENT', SYSDATE + 1 / 3600 / 24);
        dbms_output.put_line('----Сумма полиса пересчитана');
      
        v_Is_Loaded := 1;
        v_Message   := NULL;
      
      EXCEPTION
        WHEN OTHERS THEN
        
          v_Is_Loaded := 1;
          v_Message   := SQLERRM;
        
      END;
    
      --Запись квитанции о загрузке/ошибке в исходную таблицу
      UPDATE ldr_policy lp
         SET lp.is_loaded = v_Is_Loaded
            ,lp.err_text  = v_Message
       WHERE lp.ser = v_LDR.Ser
         AND lp.num = v_LDR.Num;
    
    END LOOP;
    CLOSE c_LDR;
    COMMIT;
  END;
  /*
  procedure load_from_ldr_person_med(p_policy_id number, p_asset_type_id number) is
    v_LDR ldr_person_med%rowtype;
    cursor c_LDR is
      select
        *
      from
        ldr_person_med t
      where
        t.is_loaded = 1 and
        not exists(
          select
            *
          from
            p_asset_header ah, as_asset a, as_person_med pm, p_cover c
          where
            a.p_asset_header_id = ah.p_asset_header_id and
            a.as_asset_id = pm.as_person_med_id and
            upper(trim(pm.last_name) || ' ' || trim(pm.first_name) || ' ' || trim(pm.middle_name)) = upper(trim(t.fio)) and
            pm.birth_date = t.birth_date and
            a.start_date = t.start_date and
            a.end_date = t.end_date and
            a.p_policy_id = p_policy_id and
            ah.t_asset_type_id = p_asset_type_id and
            c.as_asset_id = a.as_asset_id
        );
    cursor c_Prod_Line(pc_Prod_Line_1_Name varchar2, pc_Prod_Line_2_Name varchar2) is
      select
        pl.id
      from
        t_product_line pl
      where
        pl.description = pc_Prod_Line_1_Name or pl.description = pc_Prod_Line_2_Name;
    v_Pol_Header_ID number;
    v_Policy_ID number;
    v_As_Asset_ID number;
    v_P_Asset_Header_ID number;
    v_P_Cover_ID number;
    v_Asset_Ent_ID number;
    v_Status_Hist_ID number;
    v_Contact_ID number;
    v_Gender_ID number;
    v_Last_Name   varchar2(255);
    v_First_Name  varchar2(255);
    v_Middle_Name varchar2(255);
    v_Product_Line_ID number;
  begin
    select e.ent_id into v_Asset_Ent_ID from Entity e where e.brief = 'AS_PERSON_MED';
    select sh.status_hist_id into v_Status_Hist_ID from Status_Hist sh where sh.brief = 'NEW';
    select pc.contact_id
    into   v_Contact_ID
    from   p_policy p, p_pol_header ph, p_policy_contact pc, t_contact_pol_role cpr
    where  p.policy_id = p_policy_id and
           p.pol_header_id = ph.policy_header_id and
           pc.policy_id = p.policy_id and
           pc.contact_policy_role_id = cpr.id and
           cpr.description = 'Страхователь';
    open c_LDR;
    loop
      fetch c_LDR into v_LDR;
      exit when c_LDR%notfound;
      select sq_p_asset_header.nextval into v_P_Asset_Header_ID from dual;
      insert into p_asset_header ah
        (
         ah.p_asset_header_id,
         ah.t_asset_type_id
        )
      values
        (
         v_P_Asset_Header_ID,
         p_asset_type_id
        );
      select sq_as_asset.nextval into v_As_Asset_ID from dual;
      insert into As_Asset a
        (
         a.as_asset_id,
         a.ent_id,
         a.p_asset_header_id,
         a.status_hist_id,
         a.p_policy_id,
         a.ins_amount,
         a.ins_premium,
         a.contact_id,
         a.start_date,
         a.end_date,
         a.fee
        )
      values
        (
         v_As_Asset_ID,
         v_Asset_Ent_ID,
         v_P_Asset_Header_ID,
         v_Status_Hist_ID,
         p_policy_id,
         0,
         0,
         v_Contact_ID,
         v_LDR.Start_Date,
         v_LDR.End_Date,
         0
        );
  
      pk_utils.fio2full_name(v_LDR.Fio, v_Last_Name, v_First_Name, v_Middle_Name);
      select g.id into v_Gender_ID from t_gender g where substr(g.description,1,1) = v_LDR.Gender;
  
      insert into As_Person_Med pm
        (
         pm.as_person_med_id,
         pm.card_num,
         pm.card_date,
         pm.last_name,
         pm.first_name,
         pm.middle_name,
         pm.birth_date,
         pm.t_gender_id,
         pm.address,
         pm.doc_ser,
         pm.doc_num,
         pm.doc_date,
         pm.doc_org,
         pm.phone,
         pm.is_resident,
         pm.inn
        )
      values
        (
         v_As_Asset_ID,
         pkg_asset.get_card_nr,
         v_LDR.Start_Date,
         v_Last_Name,
         v_First_Name,
         v_Middle_Name,
         v_LDR.Birth_Date,
         v_Gender_ID,
         v_LDR.Address,
         null,
         null,
         null,
         null,
         v_LDR.Phone,
         1,
         null
        );
  
      open c_Prod_Line(v_LDR.Code_1, v_LDR.Code_2);
      loop
        fetch c_Prod_Line into v_Product_Line_ID;
        exit when c_Prod_Line%notfound;
  
        v_P_Cover_ID := pkg_cover.cre_new_cover(v_As_Asset_ID, v_Product_Line_ID);
        /*
        insert into p_Cover_Lpu_Serv cls
          (
           cls.p_cover_lpu_serv_id,
           cls.p_cover_id,
           cls.contract_lpu_cont_id
          )
        values
          (
           sq_p_cover_lpu_serv.nextval,
           v_P_Cover_ID,
           null
          );
        */
/*      end loop;
      close c_Prod_Line;

    end loop;
    close c_LDR;
    commit;
  end;
*/

END pkg_impexp;
/
