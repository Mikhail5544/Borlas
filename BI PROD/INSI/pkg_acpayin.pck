CREATE OR REPLACE PACKAGE pkg_AcPayIn IS
  FUNCTION PrepareData_process(p_gate_obj_type_id gate_obj_type.gate_obj_type_id%TYPE) RETURN NUMBER;
  PROCEDURE DeletePP(p_gate_package_id NUMBER);
  PROCEDURE OT_AcPayIn
  (
    p_gate_package_id  NUMBER
   ,p_gate_obj_type_id NUMBER
  );
END pkg_AcPayIn;
/
CREATE OR REPLACE PACKAGE BODY pkg_AcPayIn AS

  PROCEDURE DeletePP(p_gate_package_id NUMBER) IS
    res          NUMBER;
    var_bnr_date DATE;
  BEGIN
    -- узнаем дату БВ
    BEGIN
    
      SELECT p.bnr_date
        INTO var_bnr_date
        FROM xx_gate_ac_payment p
       WHERE p.gate_package_id = p_gate_package_id
         AND rownum <= 1;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- нет данных в пакете - выйдем
        RETURN;
    END;
    --Удаляем ППисх
    FOR i IN (SELECT ap.*
                FROM ins.ac_payment ap
                    ,ins.document   d
                    ,ins.DOC_TEMPL  dt
               WHERE d.EXT_ID LIKE 'NAV#%'
                 AND d.document_id = ap.payment_id
                 AND dt.DOC_TEMPL_ID = d.DOC_TEMPL_ID
                 AND dt.BRIEF = 'ППИ'
                 AND ap.due_date = var_bnr_date
                 AND NOT EXISTS
               (SELECT 1 FROM insi.xx_gate_ac_payment gap WHERE 'NAV#' || gap.code = d.ext_id))
    LOOP
      --Доработка ППисх до статуса Новый
      IF ins.doc.get_doc_status_brief(i.payment_id) <> 'NEW'
      THEN
        ins.doc.SET_DOC_STATUS(i.payment_id, 'NEW');
      END IF;
    
      --Получаем DSO по ППисх
      FOR ii IN (SELECT dso.DOC_SET_OFF_ID
                       ,dso.PARENT_DOC_ID
                   FROM ins.doc_set_off dso
                  WHERE dso.CHILD_DOC_ID = i.payment_id)
      LOOP
      
        --Если есть ДСО, то
      
        --РНВ до статуса TO_PAY
        IF ins.doc.get_doc_status_brief(ii.parent_doc_id) <> 'TO_PAY'
        THEN
          ins.doc.SET_DOC_STATUS(ii.parent_doc_id, 'TO_PAY');
        END IF;
      
        --Удаление DSO
        ins.pkg_payment.DSO_BEFORE_DELETE(ii.doc_set_off_id);
        DELETE FROM ins.doc_set_off dso WHERE dso.DOC_SET_OFF_ID = ii.doc_set_off_id;
      END LOOP;
    
      --Удаляем ППисх
      res := ins.pkg_payment.delete_payment(i.payment_id, 'ППИ');
    END LOOP;
  
    --Удаляем ППвх
    FOR i IN (SELECT ap.*
                FROM ins.ac_payment ap
                    ,ins.document   d
                    ,ins.DOC_TEMPL  dt
               WHERE d.EXT_ID LIKE 'NAV#%'
                 AND d.document_id = ap.payment_id
                 AND dt.DOC_TEMPL_ID = d.DOC_TEMPL_ID
                 AND dt.BRIEF = 'ПП'
                 AND ap.due_date = var_bnr_date
                 AND NOT EXISTS
               (SELECT 1 FROM insi.xx_gate_ac_payment gap WHERE 'NAV#' || gap.code = d.ext_id))
    LOOP
      --Доработка ППвх до статуса Новый
      IF ins.doc.get_doc_status_brief(i.payment_id) <> 'NEW'
      THEN
        ins.doc.SET_DOC_STATUS(i.payment_id, 'NEW');
      END IF;
    
      --Получаем DSO по ППвх
      FOR ii IN (SELECT dso.DOC_SET_OFF_ID
                   FROM ins.doc_set_off dso
                  WHERE dso.CHILD_DOC_ID = i.payment_id)
      LOOP
        --Если есть ДСО, то
        --Удаление DSO
        ins.pkg_payment.DSO_BEFORE_DELETE(ii.DOC_SET_OFF_ID);
        DELETE FROM ins.doc_set_off dso WHERE dso.DOC_SET_OFF_ID = ii.DOC_SET_OFF_ID;
      END LOOP;
      --Удаляем ППвх
      res := ins.pkg_payment.delete_payment(i.payment_id, 'ПП');
    END LOOP;
  END;

  /****************************************************************************/

  FUNCTION PrepareData_process(p_gate_obj_type_id gate_obj_type.gate_obj_type_id%TYPE) RETURN NUMBER IS
    var_temp VARCHAR2(255);
  BEGIN
  
    FOR i IN (SELECT gp.gate_package_id
                FROM gate_package gp
               WHERE gp.gate_obj_type_id = p_gate_obj_type_id
               GROUP BY gp.gate_package_id)
    LOOP
      -- вызовем процедуру импорта ПП
    
      OT_AcPayIn(i.gate_package_id, 1000);
    
    -- удалим пакет
    -- delete from gate_package gp where gp.gate_package_id = i.gate_package_id;
    END LOOP;
  
    RETURN Utils_tmp.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
    
      var_temp := pkg_gate.InserEvent('Ошибка при импорте ПП: ' || SQLERRM(SQLCODE)
                                     ,1
                                     ,p_gate_obj_type_id);
    
      RETURN Utils_tmp.c_exept;
    
  END PrepareData_process;

  /****************************************************************************/

  PROCEDURE OT_AcPayIn
  (
    p_gate_package_id  NUMBER
   ,p_gate_obj_type_id NUMBER
  ) IS
    var_document       ins.document%ROWTYPE;
    var_ac_payment     ins.ac_payment%ROWTYPE;
    var_doc_id         NUMBER;
    var_doc_set_off_id NUMBER;
    error_load_PP EXCEPTION;
    PRAGMA EXCEPTION_INIT(error_load_PP, -20100);
  BEGIN
  
    -- построим цикл по Пакету.
    -- обработаем по порядку Пакет, Номер ППисх
    FOR i IN (SELECT *
                FROM insi.vgo_xx_gate_ac_payment p
               WHERE p.gate_package_id = p_gate_package_id
                 AND nvl(p.change_flag, 1) = 1
               ORDER BY p.num)
    LOOP
    
      --вид ПП - исх/вх
      CASE i.payment_status
        WHEN 'ИСХ' THEN
          DECLARE
            cnt    NUMBER;
            doc_id NUMBER;
          BEGIN
            INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('ID Пакета ' || i.gate_package_id ||
                                                               '. Начало обработки ППисх с номером: ' ||
                                                               NVL(i.num, '<null>') || ' от ' ||
                                                               to_char(i.doc_date, 'DD.MM.YYYY') ||
                                                               ' по ID распоряжению на выплату: ' ||
                                                               i.payment_id
                                                              ,0
                                                              ,p_gate_obj_type_id
                                                              ,p_gate_package_id);
          
            -- узнаем информацию по Распоряжению на выплату
            BEGIN
              SELECT * INTO var_ac_payment FROM ins.ac_payment p WHERE p.payment_id = i.payment_id;
            EXCEPTION
              WHEN no_data_found THEN
                INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Не найден документ-основание по ППисх с номером: ' ||
                                                                   NVL(i.num, '<null>') || ' от ' ||
                                                                   to_char(i.doc_date, 'DD.MM.YYYY') ||
                                                                   '. ID распоряжению на выплату: ' ||
                                                                   i.payment_id
                                                                  ,1
                                                                  ,p_gate_obj_type_id
                                                                  ,p_gate_package_id);
                raise_application_error(-20100
                                       ,'Ошибка обработки Платёжных поручений');
            END;
          
            -- проверим сумму
            IF i.doc_sum <> var_ac_payment.amount
            THEN
              INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Сумма по ППисх с номером: ' ||
                                                                 NVL(i.num, '<null>') || ' от ' ||
                                                                 to_char(i.doc_date, 'DD.MM.YYYY') ||
                                                                 ' и распоряжению на выплату отличается'
                                                                ,1
                                                                ,p_gate_obj_type_id
                                                                ,p_gate_package_id);
              raise_application_error(-20100
                                     ,'Ошибка обработки Платёжных поручений');
            ELSE
              /*-- Если идет отмена, то отменим документ
              if i.change_flag = 0 then
                 ins.doc.set_doc_status(i.payment_id,'CANCEL',sysdate,'AUTO','Отмена документа в Navision');
              else*/
            
              --проверям наличие данного ПП в BI
              SELECT COUNT(*)
                INTO cnt
                FROM ins.document d
               WHERE d.DOC_TEMPL_ID = i.payment_templ_id
                 AND d.EXT_ID = 'NAV#' || i.code;
            
              IF cnt = 0
              THEN
                IF ins.doc.get_doc_status_brief(i.payment_id) = 'TO_PAY'
                THEN
                
                  -- обработаем вставку ППисх и сделаем DSO
                
                  -- проверим ID Валюты
                  IF i.fund_id IS NULL
                  THEN
                    INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Передаваемый ID Валюты документа равен NULL для ППисх с номером: ' ||
                                                                       NVL(i.num, '<null>') || ' от ' ||
                                                                       to_char(i.doc_date
                                                                              ,'DD.MM.YYYY')
                                                                      ,1
                                                                      ,p_gate_obj_type_id
                                                                      ,p_gate_package_id);
                    raise_application_error(-20100
                                           ,'Ошибка обработки Платёжных поручений');
                  END IF;
                
                  var_doc_id := ins.pkg_payment.create_paymnt_by_templ(p_payment_templ_id    => i.payment_templ_id
                                                                      ,p_payment_terms_id    => i.payment_terms_id
                                                                      ,p_number              => i.num
                                                                      ,p_date                => i.bnr_date
                                                                      , -- Дата  БВ
                                                                       p_grace_date          => i.doc_date
                                                                      ,p_amount              => i.doc_sum
                                                                      , -- сумма в валюте платежа
                                                                       p_fund_id             => i.fund_id
                                                                      ,p_rev_amount          => i.rev_amount
                                                                      , -- приведенная сумма
                                                                       p_rev_fund_id         => i.rur_fund_id
                                                                      ,p_rev_rate_type_id    => i.rev_rate_type_id
                                                                      ,p_rev_rate            => i.rev_rate
                                                                      ,p_contact_id          => i.contact_id
                                                                      ,p_contact_bank_acc_id => i.pay_bank_id
                                                                      ,p_company_bank_acc_id => i.pay_company_bank_acc_id
                                                                      ,p_note                => i.PAYMENT_NOTE
                                                                      ,p_primary_doc_id      => i.PAYMENT_ID);
                
                  -- Ужос!!! в процедуре нет параметра ext_id
                  UPDATE ins.document d
                     SET d.ext_id = 'NAV#' || i.code
                   WHERE d.document_id = var_doc_id;
                  INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('!!!Успешно создана запись по ППисх'
                                                                    ,0
                                                                    ,p_gate_obj_type_id
                                                                    ,p_gate_package_id);
                
                  --DSO
                  --ins.pkg_payment.set_off(i.payment_id,var_doc_id);
                  -- insert into ins.ven_doc_set_off (DOC_SET_OFF_ID,PARENT_DOC_ID,CHILD_DOC_ID,SET_OFF_AMOUNT,SET_OFF_FUND_ID,SET_OFF_RATE,SET_OFF_DATE,SET_OFF_CHILD_AMOUNT,SET_OFF_CHILD_FUND_ID)
                  --        values (ins.sq_doc_set_off.nextval,var_ac_payment.payment_id,var_doc_id,var_ac_payment.amount,var_ac_payment.fund_id,var_ac_payment.rev_rate,i.doc_date,i.doc_sum,i.fund_id);
                
                  BEGIN
                    SELECT ins.sq_doc_set_off.nextval INTO var_doc_set_off_id FROM dual;
                  EXCEPTION
                    WHEN OTHERS THEN
                      INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Невозможно сгенерировать ID для DSO (сиквенс: ins.sq_doc_set_off). См. код ошибки Oracle: ' ||
                                                                         SQLERRM(SQLCODE)
                                                                        ,1
                                                                        ,p_gate_obj_type_id
                                                                        ,p_gate_package_id);
                      raise_application_error(-20100
                                             ,'Ошибка обработки Платёжных поручений');
                    
                  END;
                
                  BEGIN
                    INSERT INTO ins.ven_doc_set_off
                      (DOC_TEMPL_ID
                      ,NUM
                      ,REG_DATE
                      ,PARENT_DOC_ID
                      ,CHILD_DOC_ID
                      ,SET_OFF_AMOUNT
                      ,SET_OFF_FUND_ID
                      ,SET_OFF_RATE
                      ,SET_OFF_DATE
                      ,SET_OFF_CHILD_AMOUNT
                      ,SET_OFF_CHILD_FUND_ID)
                    VALUES
                      ((SELECT dt1.doc_templ_id FROM ins.doc_templ dt1 WHERE dt1.brief = 'ЗАЧПЛ')
                      ,var_doc_set_off_id
                      ,i.bnr_date
                      ,var_ac_payment.payment_id
                      ,var_doc_id
                      ,var_ac_payment.amount
                      ,var_ac_payment.fund_id
                      ,i.rev_rate
                      ,i.doc_date
                      ,i.doc_sum
                      ,i.fund_id);
                  EXCEPTION
                    WHEN OTHERS THEN
                      INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Невозможно сформировать DSO по Распоряжению на выплату:' ||
                                                                         ins.fn_obj_name(522
                                                                                        ,var_ac_payment.payment_id
                                                                                        ,SYSDATE) ||
                                                                         ' . См. код ошибки Oracle: ' ||
                                                                         SQLERRM(SQLCODE)
                                                                        ,1
                                                                        ,p_gate_obj_type_id
                                                                        ,p_gate_package_id);
                      raise_application_error(-20100
                                             ,'Ошибка обработки Платёжных поручений');
                    
                  END;
                  INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('!!!Успешно создана DSO'
                                                                    ,0
                                                                    ,p_gate_obj_type_id
                                                                    ,p_gate_package_id);
                
                  --Исполнение РНВ до Проведён
                  IF ins.doc.get_doc_status_brief(i.payment_id) NOT IN ('PAID')
                  THEN
                    ins.doc.SET_DOC_STATUS(i.payment_id, 'PAID', i.bnr_date);
                  END IF;
                
                  INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('!!!Успешно исполнение РНВ до Проведён'
                                                                    ,0
                                                                    ,p_gate_obj_type_id
                                                                    ,p_gate_package_id);
                
                  --Исполнение ППисх до Проведён
                  IF ins.doc.get_doc_status_brief(var_doc_id) NOT IN ('TRANS')
                  THEN
                    ins.doc.SET_DOC_STATUS(var_doc_id, 'TRANS', i.bnr_date);
                  END IF;
                
                  INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('!!!Успешно исполнение ППисх до Проведён'
                                                                    ,0
                                                                    ,p_gate_obj_type_id
                                                                    ,p_gate_package_id);
                
                ELSE
                
                  -- Уже загружались, т.е. ничего делать не будем.
                  INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Платеж с номером: ' || i.num ||
                                                                     ' от ' || i.doc_date ||
                                                                     ' для Распоряжения на выплату: ' ||
                                                                     ins.fn_obj_name(522
                                                                                    ,var_ac_payment.payment_id
                                                                                    ,SYSDATE) ||
                                                                     ' не обработан, т.к. Распоряжение на выплату имеет статус отличный от К оплате'
                                                                    ,2
                                                                    ,p_gate_obj_type_id
                                                                    ,p_gate_package_id);
                
                END IF;
                --update
              ELSIF cnt = 1
              THEN
                NULL;
              ELSE
                INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Для ППисх с номером ' ||
                                                                   NVL(i.num, '<null>') || ' за дату ' ||
                                                                   i.doc_date || ' для ID Пакета=' ||
                                                                   i.gate_package_id ||
                                                                   ' в BI найдено более одной записи'
                                                                  ,1
                                                                  ,p_gate_obj_type_id
                                                                  ,p_gate_package_id);
                raise_application_error(-20100
                                       ,'Ошибка обработки Платёжных поручений');
              END IF;
            END IF;
            INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('ID Пакета ' || i.gate_package_id ||
                                                               '. Успешно обработан ППисх с номером: ' ||
                                                               NVL(i.num, '<null>') || ' от ' ||
                                                               to_char(i.doc_date, 'DD.MM.YYYY') ||
                                                               ' по ID распоряжению на выплату: ' ||
                                                               i.payment_id
                                                              ,0
                                                              ,p_gate_obj_type_id
                                                              ,p_gate_package_id);
          END;
          --  end if;
        WHEN 'ВХ' THEN
          DECLARE
            cnt    NUMBER;
            doc_id NUMBER;
          BEGIN
          
            INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('ID Пакета ' || i.gate_package_id ||
                                                               '. Начало обработки ППвх с номером: ' ||
                                                               NVL(i.num, '<null>') || ' от ' ||
                                                               to_char(i.doc_date, 'DD.MM.YYYY')
                                                              ,0
                                                              ,p_gate_obj_type_id
                                                              ,p_gate_package_id);
          
            --проверям наличие данного ПП в BI
            SELECT COUNT(*)
              INTO cnt
              FROM ins.document d
             WHERE d.DOC_TEMPL_ID = i.payment_templ_id
               AND d.EXT_ID = 'NAV#' || i.code;
          
            CASE cnt
            --insert
              WHEN 0 THEN
                -- обработаем вставку ППисх и сделаем DSO
                -- проверим ID Валюты
                IF i.fund_id IS NULL
                THEN
                  INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Передаваемый ID Валюты документа равен NULL для ППисх с номером: ' ||
                                                                     NVL(i.num, '<null>') || ' от ' ||
                                                                     to_char(i.doc_date, 'DD.MM.YYYY')
                                                                    ,1
                                                                    ,p_gate_obj_type_id
                                                                    ,p_gate_package_id);
                  raise_application_error(-20100
                                         ,'Ошибка обработки Платёжных поручений');
                END IF;
              
                var_doc_id := ins.pkg_payment.create_paymnt_by_templ(p_payment_templ_id    => i.payment_templ_id
                                                                    ,p_payment_terms_id    => i.payment_terms_id
                                                                    ,p_number              => i.num
                                                                    ,p_date                => i.bnr_date
                                                                    , -- Дата  БВ
                                                                     p_grace_date          => i.doc_date
                                                                    ,p_amount              => i.doc_sum
                                                                    ,p_fund_id             => i.fund_id
                                                                    ,p_rev_amount          => i.rev_amount
                                                                    , -- приведенная сумма
                                                                     p_rev_fund_id         => i.rur_fund_id
                                                                    ,p_rev_rate_type_id    => i.rev_rate_type_id
                                                                    ,p_rev_rate            => i.rev_rate
                                                                    ,p_contact_id          => i.contact_id
                                                                    ,p_contact_bank_acc_id => i.rec_bank_id
                                                                    ,p_company_bank_acc_id => i.rec_company_bank_acc_id
                                                                    ,p_note                => i.PAYMENT_NOTE
                                                                    ,p_primary_doc_id      => NULL);
              
                -- Ужос!!! в процедуре нет параметра ext_id
                UPDATE ins.document d
                   SET d.ext_id = 'NAV#' || i.code
                 WHERE d.document_id = var_doc_id;
                -- в АПИ для ПП которые созданы не по Родительскому документу, статус не проставляется.
                -- исправим это нелепое недоразумение
                ins.doc.SET_DOC_STATUS(var_doc_id, 'NEW', i.bnr_date);
                INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('!!!Успешно создана запись по ППвх'
                                                                  ,0
                                                                  ,p_gate_obj_type_id
                                                                  ,p_gate_package_id);
              
            --update
              WHEN 1 THEN
                SELECT d.*
                  INTO var_document
                  FROM ins.document d
                 WHERE d.DOC_TEMPL_ID = i.payment_templ_id
                   AND d.EXT_ID = 'NAV#' || i.code;
              
                SELECT ap.*
                  INTO var_ac_payment
                  FROM ins.ac_payment ap
                 WHERE ap.PAYMENT_ID = var_document.DOCUMENT_ID;
              
                --проверяем Сумму и Дату
                IF (var_ac_payment.AMOUNT <> i.doc_sum)
                   OR (var_ac_payment.grace_date <> i.doc_date)
                THEN
                
                  --проверяем наличие разноски
                  SELECT COUNT(*)
                    INTO cnt
                    FROM ins.doc_set_off dso
                   WHERE dso.PARENT_DOC_ID = i.payment_id
                     AND dso.CHILD_DOC_ID = var_document.document_id;
                
                  --если ППвх проведён или существует разноска, то ругаемся
                  IF (ins.doc.get_doc_status_brief(var_document.document_id) = 'TRANS')
                     OR (cnt <> 0)
                  THEN
                    INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Для ППвх с номером ' ||
                                                                       NVL(i.num, '<null>') ||
                                                                       ' за дату ' || i.doc_date ||
                                                                       ' найдена запись в DOCUMENT с отличыми Сумма/Дата и либо статусом Проведён, либо существующей разноской (DSO)'
                                                                      ,1
                                                                      ,p_gate_obj_type_id
                                                                      ,p_gate_package_id);
                    raise_application_error(-20100
                                           ,'Ошибка обработки Платёжных поручений');
                  ELSE
                    UPDATE ins.ac_payment ap
                       SET ap.AMOUNT     = i.doc_sum
                          ,ap.GRACE_DATE = i.DOC_DATE
                     WHERE ap.PAYMENT_ID = var_ac_payment.PAYMENT_ID;
                    INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('!!!Успешно обновлены данные по ППвх'
                                                                      ,0
                                                                      ,p_gate_obj_type_id
                                                                      ,p_gate_package_id);
                  END IF;
                END IF;
              
            --найдено более одного документа - ругаемся
              ELSE
                INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('Для ППвх с номером ' ||
                                                                   NVL(i.num, '<null>') || ' за дату ' ||
                                                                   i.doc_date || ' для ID Пакета=' ||
                                                                   i.gate_package_id ||
                                                                   ' в BI найдено более одной записи'
                                                                  ,1
                                                                  ,p_gate_obj_type_id
                                                                  ,p_gate_package_id);
                raise_application_error(-20100
                                       ,'Ошибка обработки Платёжных поручений');
            END CASE;
            INSI.pkg_gate.EventRet := INSI.pkg_gate.InserEvent('ID Пакета ' || i.gate_package_id ||
                                                               '. Успешно обработан ППвх с номером: ' ||
                                                               NVL(i.num, '<null>') || ' от ' ||
                                                               to_char(i.doc_date, 'DD.MM.YYYY')
                                                              ,0
                                                              ,p_gate_obj_type_id
                                                              ,p_gate_package_id);
          END;
      END CASE;
    END LOOP;
    --удаляем в BI непривязанные к NAVISION ПП
    DeletePP(p_gate_package_id);
    --delete from insi.xx_gate_ac_payment where gate_package_id = p_gate_package_id;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END;
END pkg_AcPayIn;
/
