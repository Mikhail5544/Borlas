CREATE OR REPLACE PACKAGE pkg_reins IS

  g_debug BOOLEAN := TRUE;
  /**
  * Ппакет для работы с документами перестрахования
  * @author Syrovetskiy D.
  *
  */
  ------------------------------------------------------
  ------------------------------------------------------
  /**
  * Функционал для работы с договором перестрахования
  *
  */

  /**
  * Процедура смены ссылки договора перестрахования на активную версию договора
  * @author Сыровецкий Д.
  * @param doc_id - ИД версии договора
  */
  PROCEDURE change_akt_link_on_doc(doc_id IN NUMBER);

  /**
  * Функция создания новой версии договора перестрахования
  * @author Сыровецкий Д.
  * @param p_re_main_contract - ИД договора перестрахования
  * @return ИД версии договора перестрахования
  */
  FUNCTION create_version(p_re_main_contract IN NUMBER) RETURN NUMBER;

  /**
  * Процедура копированиея содержимого активной версии
  * договора во вновь создаваемую
  * @author Сыровецкий Д.
  * @param new_ver_id ИД новой версии договора перестрахования
  */
  PROCEDURE copy_version(new_ver_id IN NUMBER);

  /**
  * Функция возвращает сгенерированный номер для версии договора перестрахования
  * @author Сыровецкий Д.
  * @param p_ver_id ИД версии договора перестрахования
  * @return Номер версиии
  */
  FUNCTION get_num_ver(p_ver_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Функция удаляет договор перестрахования
  * @author Сыровецкий Д.
  * @param p_contract_id ИД договора перестрахования
  * @return 0 - в случае успеха, 1 - в случае неудачи
  */
  FUNCTION delete_contract(p_contract_id IN NUMBER) RETURN NUMBER;

  /**
  * Функция создает список пакетов бордеро
  * @author Сыровецкий Д.
  * @param p_contract_id ИД договора перестрахования
  * @return 0 - в случае успеха, 1 - в случае неудачи
  */
  FUNCTION create_bordero_pack_list(p_contract_id IN NUMBER) RETURN NUMBER;

  /**
  * Функция удаляет версию договора перестрахования
  * @author Сыровецкий Д.
  * @param p_ver_id ИД версии договора перестрахования
  * @return 0 - в случае успеха, 1 - в случае неудачи
  */
  FUNCTION delete_version(p_ver_id IN NUMBER) RETURN NUMBER;

  /**
  * Процедура смены ствтуса всех входящих в пакет бордеро на указанный
  * @author Сыровецкий Д.
  * @param p_pack_id ИД пакета бордеро
  * @param p_st_brief сокращение для статуса
  */
  PROCEDURE change_st_bordero_from_pack
  (
    p_pack_id  IN NUMBER
   ,p_st_brief VARCHAR2 DEFAULT 'ACCEPTED'
  );

  /**
  * Наполнение содержимого бордеро в пакете
  * @author Сыровецкий Д.
  * @param p_pack_id ИД пакета бордеро
  * @param p_bordero_id ИД конкретного бордеро, необязательный
  */
  PROCEDURE fill_bordero
  (
    p_pack_id    IN NUMBER
   ,p_bordero_id NUMBER DEFAULT NULL
  );

  /*
    Байтин А.
    Копирование пакета бордеро
    par_bordero_package_id - ID источника
    par_is_inclusion_package - True - создание пакета заключения
                             - False - обычное копирование
    
  */
  PROCEDURE copy_bordero_pack
  (
    par_bordero_pack_id     NUMBER
   ,par_is_inclusion_pack   NUMBER DEFAULT 0
   ,par_new_bordero_pack_id OUT NUMBER
  );

  /**
  * Создание бордеро первых платежей
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  * @param p_retr признак ретроцессии
  * @param p_opt 0 - формирование бордеро первых платежей, 1 - неподтверденные, 2 - изменений
  */
  PROCEDURE create_bordero_first
  (
    p_bordero_id IN NUMBER
   ,p_retr       IN NUMBER DEFAULT 0
   ,p_opt        IN NUMBER DEFAULT 0
  );

  /**
  * Создание бордеро изменений
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  * @param p_retr признак ретроцессии
  * @param p_opt 0 - формирование бордеро первых платежей, 1 - неподтверденные, 2 - изменений
  */
  PROCEDURE create_bordero_bi
  (
    p_bordero_id IN NUMBER
   ,p_retr       IN NUMBER DEFAULT 0
   ,p_opt        IN NUMBER DEFAULT 0
  );

  /**
  * Создание бордеро доплат
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  */
  PROCEDURE create_bordero_second(p_bordero_id IN NUMBER);

  /**
  * Создание бордеро расторжений
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  */
  PROCEDURE create_bordero_rast(p_bordero_id IN NUMBER);

  /**
  * Создание бордеро убытков
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  * @param p_type_id - тип бордеро, 0 - заявленных убытков, 1 - оплаченных
  */
  PROCEDURE create_bordero_loss
  (
    p_bordero_id IN NUMBER
   ,p_type_id    IN NUMBER DEFAULT 0
  );

  /**
  * Пересчет бордеро и родительского пакета
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  * @param p_calc установить признак перерасчета бордеро, 1-перечитан, 0 - нет
  */
  PROCEDURE recalc_bordero
  (
    p_bordero_id IN NUMBER
   ,p_calc       IN NUMBER DEFAULT 1
  );

  /**
  * Очищает содержимое бордеро
  * @author Сыровецкий Д.
  * @param p_bordero_id ИД бордеро
  * @param p_recalc признак пересчета бордеро, 1-пересчитывать, 0 -нет
  */
  PROCEDURE clear_bordero
  (
    p_pack_id    IN NUMBER DEFAULT NULL
   ,p_bordero_id IN NUMBER DEFAULT NULL
   ,p_recalc     NUMBER DEFAULT 1
  );

  /**
  * Функция создания новой версии слипа
  * @author Сыровецкий Д.
  * @param p_re_main_contract - ИД договора перестрахования
  * @return ИД версии договора перестрахования
  */
  FUNCTION create_version_slip(p_re_slip_header_id IN NUMBER) RETURN NUMBER;

  /**
  * Процедура копированиея содержимого активной слипа в новый
  * @author Сыровецкий Д.
  * @param p_ver_id ИД новой версии слипа
  * @param flg_null Флаг обнуление линий (необязательный) 0 - не обнулять, 1 - обнулять
  */
  PROCEDURE copy_version_slip
  (
    p_ver_id IN NUMBER
   ,flg_null IN NUMBER DEFAULT 0
  );

  /**
  * Процедура расчета покрытия по слипу
  * @author Сыровецкий Д.
  * @param p_slip_id ИД новой версии слипа
  * @param p_pcover_id ИД покрытия
  * @param p_flg_null Флаг удаленной версии
  */
  PROCEDURE create_slip_cover
  (
    p_slip_id   IN NUMBER
   ,p_pcover_id IN NUMBER
   ,p_flg_null  IN NUMBER DEFAULT 1
  );

  /**
  * Процедура смены статуса слипа
  * @author Сыровецкий Д.
  * @param p_slip_id ИД слипа
  */
  PROCEDURE change_slip_st(p_slip_id IN NUMBER);

  /**
  * Процедура обновляет суммы слипа
  * @author Сыровецкий Д.
  * @param p_slip_id ИД слипа
  */
  PROCEDURE update_slip_sum(p_slip_id IN NUMBER);

  /**
  * Процедура расторжения слипа
  * @author Сыровецкий Д.
  * @param p_slip_head_id ИД заголовка слипа
  */
  PROCEDURE slip_abort(p_slip_head_id IN NUMBER);

  /**
  * Процедура удаления слипа
  * @author Сыровецкий Д.
  * @param p_slip_id ИД заголовка слипа
  */
  PROCEDURE slip_delete(p_slip_id IN NUMBER);

  /**
  * Процедура обновления текущей версии RE_COVER
  * @author Сыровецкий Д.
  * @param p_recover_id ИД RE_COVER
  */
  PROCEDURE update_cur_recover(p_recover_id IN NUMBER);

  /**
  * Процедура добавления исключения в облигаторный договор
  * @author Сыровецкий Д.
  * @param p_ver_id ИД версии договора
  * @param p_pcover_id ИД покрытия
  * @param p_exc_brief Сокращение типа исключения
  * @param p_bordero_id ИД бордеро, сгенерировшего исключение
  */
  PROCEDURE create_oblig_exc
  (
    p_ver_id     IN NUMBER
   ,p_pcover_id  IN NUMBER
   ,p_exc_brief  IN VARCHAR2 DEFAULT 'USER'
   ,p_bordero_id IN NUMBER DEFAULT NULL
  );

  /**
  * Функция проверки исключения покрытия
  * @author Сыровецкий Д.
  * @param p_p_cover_id ИД покрытия
  * @param p_re_ver_id ИД версии облигаторного договора (может быть пустым)
  * @param p_re_slip_id ИД версии слипа (может быть пустым)
  * @return 1 - есть в исключениях, 0 - нет
  */
  FUNCTION check_exc
  (
    p_p_cover_id IN NUMBER
   ,p_re_ver_id  IN NUMBER DEFAULT NULL
   ,p_re_slip_id IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  /**
  * Процедура расчета убытка по линиям слипа
  * @author Сыровецкий Д.
  * @param par_slip_id ИД версии слипа
  * @param par_damage_id ИД ущерба
  */
  PROCEDURE slip_damage_calc
  (
    par_slip_id   IN NUMBER
   ,par_damage_id IN NUMBER
  );

  /**
  * Процедура расчета эксцедента убытка
  * @author Сыровецкий Д.
  * @param p_ver_id ИД версии договора эксцедента убытка
  */
  PROCEDURE calc_exced(p_ver_id IN NUMBER);

  /**
  * Функция восстановление убытка
  * @author Сыровецкий Д.
  * @param p_ver_id ИД версии договора эксцедента убытка
  * @param p_re_damage_id ИД убытка в перестраховании
  * @param p_type Направление расчета восстановления
  * @return Сумма восстановления
  */
  FUNCTION exced_recover
  (
    p_ver_id       IN NUMBER
   ,p_re_damage_id IN NUMBER
   ,p_type         IN NUMBER DEFAULT 0
  ) RETURN NUMBER;

  /**
  * Процедура возвращает сумму перестрахованной части
  * @author Сыровецкий Д.
  * @param p_pcover_id ИД покрытия
  */
  FUNCTION get_pcover_reins_sum(p_pcover_id IN NUMBER) RETURN NUMBER;

  /**
  * Функция определяет перестраховано ли покрытие (1 - перестраховано, 0 - нет)
  * @author Чикашова
  * @param p_pcover_id ИД покрытия
  */
  FUNCTION cover_reins(p_pcover_id NUMBER) RETURN NUMBER;
  -------------------------------------------------------
  -------------------------------------------------------

  FUNCTION TEST(p_in VARCHAR2 DEFAULT NULL) RETURN NUMBER;

  PROCEDURE re_commision_calculate(p_re_bordero_id NUMBER);
END; -- Package spec
/
CREATE OR REPLACE PACKAGE BODY pkg_reins IS

  -- Тип для получения данных из курсора
  TYPE R_COVER IS RECORD(
     insurance_group_id T_PRODUCT_LINE.insurance_group_id%TYPE --вид страхования
    ,product_id         P_POL_HEADER.product_id%TYPE -- продукт
    ,prod_line_id       T_PRODUCT_LINE.ID%TYPE --страховая программа
    ,contact_id         P_POLICY_CONTACT.contact_id%TYPE -- страхователь
    ,policy_header_id   P_POL_HEADER.policy_header_id%TYPE -- заголовок договора страхования
    ,policy_id          P_POLICY.POLICY_ID%TYPE --полис
    ,pol_num            P_POLICY.pol_num%TYPE
    ,fund_id            P_POL_HEADER.FUND_ID%TYPE --валюта ответственности
    ,fund_pay_id        P_POL_HEADER.fund_pay_id%TYPE --валюта оплаты
    ,p_cover_id         P_COVER.p_cover_id%TYPE
    ,p_asset_header_id  AS_ASSET.p_asset_header_id%TYPE --заголовок объекта страхования
    ,start_date         P_COVER.start_date%TYPE
    ,end_date           P_COVER.end_date%TYPE
    ,premium            P_COVER.premium%TYPE
    ,ins_amount         P_COVER.ins_amount%TYPE
    ,tariff             P_COVER.tariff%TYPE
    ,ent_id             P_COVER.ent_id%TYPE
    ,sh_brief           STATUS_HIST.brief%TYPE);

  TYPE T_COVER IS TABLE OF R_COVER INDEX BY BINARY_INTEGER;
  recordset T_COVER;

  --

  PROCEDURE LOG
  (
    p_object_id IN NUMBER
   ,p_message   IN VARCHAR2
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF g_debug
    THEN
      INSERT INTO RE_BORDERO_DEBUG
        (object_id, execution_date, operation_type, debug_message)
      VALUES
        (p_object_id, SYSDATE, 'INS.PKG_REINS', SUBSTR(p_message, 1, 4000));
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
  FUNCTION get_pcover_fund_date(p_pcover_id NUMBER) RETURN DATE IS
    v_date DATE := SYSDATE;
  BEGIN
    SELECT pph.start_date
      INTO v_date
      FROM P_COVER      pc
          ,AS_ASSET     aa
          ,P_POLICY     pp
          ,P_POL_HEADER pph
     WHERE pc.p_cover_id = p_pcover_id
       AND aa.as_asset_id = pc.as_asset_id
       AND pp.policy_id = aa.P_POLICY_ID
       AND pph.POLICY_HEADER_ID = pp.POL_HEADER_ID;
    RETURN v_date;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN SYSDATE;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION calc_bordero_in_fund
  (
    p_re_bordero_id NUMBER
   ,p_brief         VARCHAR2
   ,p_type          NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_result NUMBER := 0;
  BEGIN
  
    CASE
      WHEN p_brief IN ('БОРДЕРО_ПРЕМИЙ'
                      ,'БОРДЕРО_ПРЕМИЙ_НЕ'
                      ,'БОРДЕРО_ИЗМЕН'
                      ,'БОРДЕРО_ДОПЛАТ')
           AND p_type = 0 THEN
      
        SELECT SUM(NVL(rrb.NETTO_PREMIUM *
                       pkg_reins_payment.GET_BORDERO_RATE(p_re_bordero_id, rrb.FUND_DATE)
                      ,0))
          INTO v_result
          FROM REL_RECOVER_BORDERO rrb
         WHERE rrb.RE_BORDERO_ID = p_re_bordero_id;
      
      WHEN p_brief = 'БОРДЕРО_РАСТОРЖЕНИЙ'
           OR p_brief = 'БОРДЕРО_ИЗМЕН'
           AND p_type = 1 THEN
      
        SELECT SUM(NVL(rrb.RETURNED_PREMIUM *
                       pkg_reins_payment.GET_BORDERO_RATE(p_re_bordero_id, rrb.FUND_DATE)
                      ,0))
          INTO v_result
          FROM REL_RECOVER_BORDERO rrb
         WHERE rrb.RE_BORDERO_ID = p_re_bordero_id;
      
      WHEN p_brief = 'БОРДЕРО_ОПЛ_УБЫТКОВ' THEN
      
        SELECT SUM(NVL(rrb.RE_PAYMENT_SUM *
                       pkg_reins_payment.GET_BORDERO_RATE(p_re_bordero_id, rrb.FUND_DATE)
                      ,0))
          INTO v_result
          FROM REL_REDAMAGE_BORDERO rrb
         WHERE rrb.RE_BORDERO_ID = p_re_bordero_id;
      ELSE
        v_result := 0;
    END CASE;
  
    RETURN NVL(v_result, 0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  /*
     Получение ИД Бордеро Изменений
  */

  FUNCTION Get_ID_Bordero_BPP
  (
    p_bordero_pack_id IN NUMBER
   ,p_fund_id         IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
  
    LOG(p_bordero_pack_id, 'GET_ID_BORDERO_BPP p_fund_id ' || p_fund_id);
    SELECT b.re_bordero_id
      INTO RESULT
      FROM RE_BORDERO      b
          ,RE_BORDERO_TYPE bt
     WHERE bt.brief = 'БОРДЕРО_ПРЕМИЙ'
       AND b.RE_BORDERO_TYPE_ID = bt.re_bordero_type_id
       AND b.re_bordero_package_id = p_bordero_pack_id
       AND b.FUND_ID = p_fund_id;
  
    LOG(p_bordero_pack_id, 'GET_ID_BORDERO_BPP ' || RESULT);
  
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000, 'У Вас нет БПП');
  END;

  FUNCTION Get_ID_Bordero_BI
  (
    p_bordero_pack_id IN NUMBER
   ,p_fund_id         IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    LOG(p_bordero_pack_id, 'GET_ID_BORDERO_BI');
    SELECT b.re_bordero_id
      INTO RESULT
      FROM RE_BORDERO      b
          ,RE_BORDERO_TYPE bt
     WHERE bt.brief = 'БОРДЕРО_ИЗМЕН'
       AND b.RE_BORDERO_TYPE_ID = bt.re_bordero_type_id
       AND b.re_bordero_package_id = p_bordero_pack_id
       AND b.FUND_ID = p_fund_id;
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000, 'У Вас нет БИ');
  END;

  /*
     Получение ИД Бордеро Первых Премий Неподтвержденное
  */

  FUNCTION Get_ID_Bordero_BPPN
  (
    p_bordero_pack_id IN NUMBER
   ,p_fund_id         IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
  BEGIN
    LOG(p_bordero_pack_id, 'GET_ID_BORDERO_BPPN');
  
    SELECT b.re_bordero_id
      INTO RESULT
      FROM RE_BORDERO      b
          ,RE_BORDERO_TYPE bt
     WHERE bt.brief = 'БОРДЕРО_ПРЕМИЙ_НЕ'
       AND b.RE_BORDERO_TYPE_ID = bt.re_bordero_type_id
       AND b.re_bordero_package_id = p_bordero_pack_id
       AND b.FUND_ID = p_fund_id;
  
    RETURN RESULT;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000, 'У Вас нет БППН');
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE change_akt_link_on_doc(doc_id IN NUMBER) IS
    v_temp_id   NUMBER;
    v_new_st_id NUMBER;
  BEGIN
    --doc.set_doc_status(doc_id,2);
    --узнаем основной договор по версии
  
    SELECT CV.re_main_contract_id
      INTO v_temp_id
      FROM ven_re_contract_version CV
     WHERE CV.re_contract_version_id = doc_id;
  
    UPDATE ven_re_main_contract mc
       SET mc.last_version_id = doc_id
     WHERE mc.re_main_contract_id = v_temp_id;
    --COMMIT;
    --теперь необходимо изменить статусы других действующих договоров
    -- на "завершен"
    SELECT doc_status_ref_id INTO v_new_st_id FROM DOC_STATUS_REF WHERE UPPER(brief) = 'STOPED';
    FOR cver IN (SELECT CV.re_contract_version_id
                   FROM ven_re_contract_version CV
                       ,ven_doc_status          ds
                       ,ven_doc_status_ref      sr
                  WHERE CV.re_contract_version_id <> doc_id
                    AND ds.document_id = CV.re_contract_version_id
                    AND sr.doc_status_ref_id = ds.doc_status_ref_id
                    AND Doc.get_doc_status_brief(CV.re_contract_version_id) = 'NEW')
    LOOP
      Doc.set_doc_status(cver.re_contract_version_id, v_new_st_id);
      --save_message(cver.re_contract_version_id);
    --save_message(v_new_st_id);
    --save_message(doc.get_doc_status_brief(cver.re_contract_version_id));
    END LOOP;
    --COMMIT;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  --создает ре_ковер и линии по нему
  FUNCTION create_re_cover
  (
    p_pcover_id      IN NUMBER
   ,p_type           IN NUMBER -- 0 - bordero, 1 - slip
   ,p_id             IN NUMBER
   ,p_line_source_id IN NUMBER DEFAULT NULL
   ,p_flg_null       IN NUMBER DEFAULT 1
  ) RETURN NUMBER IS
    v_re_cover      ven_re_cover%ROWTYPE;
    p_pcover_ent_id NUMBER;
  
    real_ins_amount NUMBER; -- неперестрахованная часть
  
    v_re_line_cover         ven_re_line_cover%ROWTYPE;
    v_re_line_tarif_func_id NUMBER;
    v_func_calc_id          NUMBER;
  
    v_brief         VARCHAR2(255);
    v_re_ins_amount NUMBER;
  
    CURSOR line_bordero
    (
      p_filter_id IN NUMBER
     ,p_fund_id   NUMBER
    ) IS
      SELECT lc.re_line_contract_id
            ,NVL(lc.line_number, 0)
            ,NVL(lc.LIMIT, 0)
            ,NVL(lc.retention_perc, 0)
            ,NVL(lc.retention_val, 0)
            ,NVL(lc.part_perc, 0)
            ,NVL(lc.part_sum, 0)
            ,NVL(lc.commission_perc, 0)
            ,NVL(lc.re_tariff, 0)
            ,lc.t_prod_coef_type_id
        FROM RE_LINE_CONTRACT lc
       WHERE lc.re_cond_filter_obl_id = p_filter_id
         AND lc.fund_id = p_fund_id
       ORDER BY lc.line_number;
  
    CURSOR line_slip(p_filter_id IN NUMBER) IS
      SELECT ls.re_line_slip_id
            ,NVL(ls.line_number, 0)
            ,NVL(ls.LIMIT, 0)
            ,NVL(ls.retention_perc, 0)
            ,NVL(ls.retention_val, 0)
            ,NVL(ls.part_perc, 0)
            ,NVL(ls.part_sum, 0)
            ,NVL(ls.commission_perc, 0)
            ,NVL(ls.re_tariff, 0)
            ,NULL
        FROM RE_LINE_SLIP ls
       WHERE ls.re_slip_id = p_filter_id
       ORDER BY ls.line_number;
  
    v_prev_val          NUMBER;
    v_cur_sum           NUMBER;
    v_max_retention_val NUMBER;
  
    v_bordero_brief VARCHAR2(100);
  
    v_tarif_perc NUMBER; --определяет вид тарифа (либо в процентах, либо в долях)
    l_is_found   NUMBER DEFAULT 1;
  
  BEGIN
    LOG(p_pcover_id, 'CREATE_RE_COVER p_type ' || p_type);
    -- 1. нужно создать заготовку для re_cover
  
    -- данные по текущему договору перестрахования
    IF p_type = 0
    THEN
    
      -- Получаем ИД ДСП
      SELECT sq_re_cover.NEXTVAL INTO v_re_cover.re_cover_id FROM dual;
    
      SELECT CV.start_date
            ,CV.end_date
            ,NULL
            ,b.re_bordero_id
            ,CV.re_contract_version_id
            ,CV.re_main_contract_id
            ,b.fund_id
            ,bp.fund_pay_id
            ,CV.func_calc_id
            ,bt.BRIEF
        INTO v_re_cover.start_date
            ,v_re_cover.end_date
            ,v_re_cover.re_slip_id
            ,v_re_cover.re_bordero_id
            ,v_re_cover.re_contract_ver_id
            ,v_re_cover.re_m_contract_id
            ,v_re_cover.fund_id
            ,v_re_cover.fund_pay_id
            ,v_func_calc_id
            ,v_bordero_brief
        FROM RE_BORDERO          b
            ,RE_BORDERO_TYPE     bt
            ,RE_BORDERO_PACKAGE  bp
            ,RE_CONTRACT_VERSION CV
       WHERE b.re_bordero_id = p_id
         AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
         AND bp.re_bordero_package_id = b.re_bordero_package_id
         AND CV.re_contract_version_id = bp.re_contract_id;
    
      v_tarif_perc := 1; --абсолютная величина
    ELSE
    
      --получаем ИД ДСП
      BEGIN
        SELECT *
          INTO v_re_cover
          FROM ven_re_cover
         WHERE p_cover_id = p_pcover_id
           AND re_slip_id = p_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SELECT sq_re_cover.NEXTVAL INTO v_re_cover.re_cover_id FROM dual;
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000
                                 ,'Ошибка создания ДСП для слипа ' || SQLERRM);
      END;
    
      BEGIN
        SELECT s.start_date
              ,s.end_date
              ,s.re_slip_id
              ,NULL
              ,NULL
              ,sh.re_main_contract_id
              ,sh.fund_id
              ,sh.fund_pay_id
              ,NULL
              ,'null'
          INTO v_re_cover.start_date
              ,v_re_cover.end_date
              ,v_re_cover.re_slip_id
              ,v_re_cover.re_bordero_id --заглушка
              ,v_re_cover.re_contract_ver_id --заглушка
              ,v_re_cover.re_m_contract_id
              ,v_re_cover.fund_id
              ,v_re_cover.fund_pay_id
              ,v_func_calc_id --заглушка
              ,v_bordero_brief --заглушка
          FROM RE_SLIP        s
              ,RE_SLIP_HEADER sh
         WHERE s.re_slip_id = p_id
           AND sh.re_slip_header_id = s.re_slip_header_id;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20100, 'Ошибка получения данных слипа');
      END;
    
      v_tarif_perc := 100; -- %
    END IF;
  
    -- данные по покрытиию и по полису
    BEGIN
      -- Пробуем найти данные в временном хранилище
      SELECT pc.p_cover_id
            ,NVL(pc.ins_amount, 0)
            ,NVL(pc.premium, 0)
            ,NVL(pc.tariff, 0)
            ,pc.p_asset_header_id
            ,pc.policy_id
            ,pc.as_asset_id
            ,pc.prod_line_id
            ,pc.insurance_group_id
            ,pc.contact_id
            ,pc.ent_id
            ,pc.START_DATE
            ,pc.END_DATE
            ,pc.LL_BRIEF
        INTO v_re_cover.p_cover_id
            ,v_re_cover.ins_amount
            ,v_re_cover.ins_premium
            ,v_re_cover.ins_tariff
            ,v_re_cover.p_asset_header_id
            ,v_re_cover.ins_policy
            ,v_re_cover.ins_asset
            ,v_re_cover.t_product_line_id
            ,v_re_cover.t_insurance_group_id
            ,v_re_cover.customer_id
            ,p_pcover_ent_id
            ,v_re_cover.start_date
            ,v_re_cover.end_date
            ,v_brief
        FROM XX_RE_COVER pc
       WHERE pc.p_cover_id = p_pcover_id;
    
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_is_found := 0;
        LOG(p_pcover_id, 'CREATE_RE_COVER Данные в хранилище не найдены');
    END;
  
    IF l_is_found = 0
    THEN
    
      BEGIN
      
        SELECT pc.p_cover_id
              ,NVL(pc.ins_amount, 0)
              ,NVL(pc.premium, 0)
              ,NVL(pc.tariff, 0)
              ,aa.p_asset_header_id
              ,aa.p_policy_id
              ,aa.as_asset_id
              ,pl.ID
              ,pl.insurance_group_id
              ,ppc.contact_id
              ,pc.ent_id
              ,pc.START_DATE
              ,pc.END_DATE
              ,ll.BRIEF
          INTO v_re_cover.p_cover_id
              ,v_re_cover.ins_amount
              ,v_re_cover.ins_premium
              ,v_re_cover.ins_tariff
              ,v_re_cover.p_asset_header_id
              ,v_re_cover.ins_policy
              ,v_re_cover.ins_asset
              ,v_re_cover.t_product_line_id
              ,v_re_cover.t_insurance_group_id
              ,v_re_cover.customer_id
              ,p_pcover_ent_id
              ,v_re_cover.start_date
              ,v_re_cover.end_date
              ,v_brief
          FROM P_COVER            pc
              ,AS_ASSET           aa
              ,T_PROD_LINE_OPTION plo
              ,T_PRODUCT_LINE     pl
              ,T_LOB_LINE         ll
              ,P_POLICY_CONTACT   ppc
              ,T_CONTACT_POL_ROLE cpr
         WHERE pc.p_cover_id = p_pcover_id
           AND aa.as_asset_id = pc.as_asset_id
           AND plo.ID = pc.t_prod_line_option_id
           AND pl.ID = plo.product_line_id
           AND ll.t_lob_line_id = pl.t_lob_line_id
           AND ppc.policy_id = aa.p_policy_id
           AND cpr.brief = 'Страхователь'
           AND ppc.contact_policy_role_id = cpr.ID;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20100
                                 ,'Ошибка получения данных по договору' || p_pcover_id);
      END;
    END IF;
  
    /*if p_type = 1 and nvl(v_re_cover.flg_manual,0) = 0 then
      --для слипов нужно проверить наличие версии, которая была
      --исправлена в ручную, если текущая не правилась
      begin
      select rc.FLG_MANUAL
           , rc.PART_SUM
           , rc.RE_TARIF
           , rc.brutto_premium
           , rc.netto_premium
           , rc.commission
      into v_re_cover.flg_manual
         , v_re_cover.part_sum
         , v_re_cover.re_tarif
         , v_re_cover.BRUTTO_PREMIUM
         , v_re_cover.netto_premium
         , v_re_cover.commission
      from re_slip s_cur
         , re_slip_header rsh
         , re_slip s
         , re_cover rc
      where s_cur.RE_SLIP_ID = p_id
        and rsh.RE_SLIP_HEADER_ID = s_cur.RE_SLIP_HEADER_ID
        and s.RE_SLIP_ID = rsh.LAST_SLIP_ID
        and rc.RE_SLIP_ID = s.RE_SLIP_ID
        and rc.T_PRODUCT_LINE_ID = v_re_cover.t_product_line_id
        and rc.P_ASSET_HEADER_ID = v_re_cover.p_asset_header_id;
      exception
        when others then
          null;
      end;
    end if;*/
  
    --если было ручное изменение доли перестраховщика, то
    --это нужно сохранить
    v_re_cover.flg_manual := NVL(v_re_cover.flg_manual, 0);
  
    IF v_re_cover.flg_manual = 1
    THEN
      v_re_cover.part_sum       := NVL(ABS(v_re_cover.part_sum), 0);
      v_re_cover.re_tarif       := NVL(ABS(v_re_cover.re_tarif), 0);
      v_re_cover.BRUTTO_PREMIUM := NVL(ABS(v_re_cover.BRUTTO_PREMIUM), 0);
      v_re_cover.NETTO_PREMIUM  := NVL(ABS(v_re_cover.NETTO_PREMIUM), 0);
      v_re_cover.COMMISSION     := NVL(ABS(v_re_cover.COMMISSION), 0);
    ELSE
      v_re_cover.part_sum       := 0;
      v_re_cover.re_tarif       := 0;
      v_re_cover.BRUTTO_PREMIUM := 0;
      v_re_cover.NETTO_PREMIUM  := 0;
      v_re_cover.COMMISSION     := 0;
    END IF;
  
    IF UPPER(v_bordero_brief) = 'БОРДЕРО_ЕКСЦЕДЕНТ'
    THEN
      SELECT cve.PREMIUM_PERC / 100
        INTO v_re_cover.re_tarif
        FROM RE_CONTRACT_VER_EL cve
       WHERE cve.re_contract_ver_el_id = v_re_cover.re_contract_ver_id;
    END IF;
  
    IF p_flg_null = 0
    THEN
      v_re_cover.flg_deleted := 1;
      --else
      --v_re_cover.flg_deleted := 0;
    ELSIF p_flg_null = 2
    THEN
      v_re_cover.flg_deleted := 0;
    ELSIF p_flg_null IS NULL
          OR v_re_cover.flg_deleted IS NULL
    THEN
      v_re_cover.flg_deleted := 0;
    END IF;
  
    LOG(v_re_cover.re_cover_id, 'INSERT RE_COVER ' || v_re_cover.p_cover_id);
    INSERT INTO ven_RE_COVER VALUES v_re_cover;
  
    /*    BEGIN
      INSERT INTO ven_RE_COVER VALUES v_re_cover;
    EXCEPTION
      WHEN OTHERS THEN --А если ошибка не в том что такая запись уже есть????
        UPDATE ven_re_cover rc
          SET ROW = v_re_cover
          WHERE rc.re_cover_id = v_re_cover.re_cover_id;
    END;*/
  
    -- определяем сколько страховой суммы мы передали
    -- по другим договорам перестрахования по нашему п_каверу
    IF p_type = 0
    THEN
      SELECT NVL(SUM(rc.part_sum), 0)
        INTO real_ins_amount
        FROM RE_COVER rc
       WHERE rc.P_ASSET_HEADER_ID = v_re_cover.P_ASSET_HEADER_ID
         AND rc.T_PRODUCT_LINE_ID = v_re_cover.T_PRODUCT_LINE_ID
         AND NVL(rc.RE_CONTRACT_VER_ID, 0) <> NVL(v_re_cover.re_contract_ver_id, 0)
         AND flg_cur_version = 1; --берем действующие версии договоров
    ELSE
      SELECT NVL(SUM(rc.part_sum), 0)
        INTO real_ins_amount
        FROM RE_COVER rc
       WHERE rc.P_ASSET_HEADER_ID = v_re_cover.P_ASSET_HEADER_ID
         AND rc.T_PRODUCT_LINE_ID = v_re_cover.T_PRODUCT_LINE_ID
         AND NVL(rc.RE_SLIP_ID, 0) <> NVL(v_re_cover.re_slip_id, 0)
         AND flg_cur_version = 1; --берем действующие версии договоров
    END IF;
  
    --вычисление страховой суммы
    --для некоторых программ это актуально
    IF p_type = 0
       AND v_bordero_brief <> 'БОРДЕРО_ЕКСЦЕДЕНТ'
    THEN
      IF v_brief IN ('WOP', 'PWOP', 'WOP_ACC', 'PWOP_ACC', 'PWOP_LIFE', 'WOP_LIFE')
      THEN
        v_re_cover.ins_amount := pkg_reins_calc.GET_SUM_FIRST(v_re_cover.p_cover_id
                                                             ,v_re_cover.fund_id);
      END IF;
    END IF;
  
    real_ins_amount := v_re_cover.ins_amount - real_ins_amount;
    IF real_ins_amount < 0
    THEN
      real_ins_amount := 0;
    END IF;
  
    --определяем максимальное собственное удержание по договору
    BEGIN
      SELECT val
        INTO v_max_retention_val
        FROM RE_CONTRACT_VER_FUND
       WHERE fund_id = v_re_cover.fund_id
         AND re_contract_version_id = v_re_cover.re_contract_ver_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_max_retention_val := v_re_cover.ins_amount;
    END;
  
    IF v_re_cover.flg_manual > 0
    THEN
      --Доля перестраховщика была указана вручную и больше реально доступной
      IF real_ins_amount < v_re_cover.part_sum
      THEN
        v_re_cover.flg_is_overflow := 1;
      ELSE
        v_re_cover.flg_is_overflow := 0;
      END IF;
      real_ins_amount := v_re_cover.part_sum;
    END IF;
  
    --идем по линиям
    IF p_type = 0
    THEN
      OPEN line_bordero(p_line_source_id, v_re_cover.fund_id);
    ELSE
      OPEN line_slip(p_id);
    END IF;
  
    v_prev_val := 0;
    DELETE RE_LINE_COVER WHERE re_cover_id = v_re_cover.re_cover_id;
  
    LOOP
    
      --если заданы ручные премии, то нам фактически
      --линии не нужны
      IF v_re_cover.flg_manual > 0
         AND
         (v_re_cover.brutto_premium > 0 OR v_re_cover.commission > 0 OR v_re_cover.netto_premium > 0)
         OR v_re_cover.flg_is_overflow > 0
      THEN
      
        v_re_line_cover.line_number := 0;
      
        EXIT;
      END IF;
    
      IF p_type = 0
      THEN
        FETCH line_bordero
          INTO v_re_line_cover.RE_LINE_CONTRACT_ID
              ,v_re_line_cover.LINE_NUMBER
              ,v_re_line_cover.LIMIT
              ,v_re_line_cover.RETENTION_PERC
              ,v_re_line_cover.RETENTION_VAL
              ,v_re_line_cover.PART_PERC
              ,v_re_line_cover.PART_SUM
              ,v_re_line_cover.COMMISSION_PERC
              ,v_re_line_cover.RE_TARIFF
              ,v_re_line_tarif_func_id;
        IF UPPER(v_bordero_brief) = 'БОРДЕРО_ЕКСЦЕДЕНТ'
        THEN
          v_re_line_tarif_func_id := NULL;
        END IF;
        EXIT WHEN line_bordero%NOTFOUND;
      ELSE
        FETCH line_slip
          INTO v_re_line_cover.RE_LINE_CONTRACT_ID
              ,v_re_line_cover.LINE_NUMBER
              ,v_re_line_cover.LIMIT
              ,v_re_line_cover.RETENTION_PERC
              ,v_re_line_cover.RETENTION_VAL
              ,v_re_line_cover.PART_PERC
              ,v_re_line_cover.PART_SUM
              ,v_re_line_cover.COMMISSION_PERC
              ,v_re_line_cover.RE_TARIFF
              ,v_re_line_tarif_func_id;
        EXIT WHEN line_slip%NOTFOUND;
        IF NVL(v_re_cover.flg_manual, 0) = 1
        THEN
          v_re_cover.re_tarif := NVL(v_re_cover.re_tarif, v_re_line_cover.RE_TARIFF);
        END IF;
      END IF;
    
      -- расчет тарифа
      IF v_re_line_tarif_func_id IS NOT NULL
      THEN
        v_re_line_cover.re_tariff := pkg_tariff_calc.calc_fun(v_re_line_tarif_func_id
                                                             ,p_pcover_ent_id
                                                             ,p_pcover_id);
        v_re_line_cover.re_tariff := NVL(v_re_line_cover.re_tariff, 1);
      ELSE
      
        IF NVL(v_re_cover.re_tarif, 0) > 0
        THEN
          v_re_line_cover.re_tariff := NVL(v_re_cover.re_tarif, 0);
        END IF;
      
        IF NVL(v_re_line_cover.re_tariff, 0) = 0
        THEN
          BEGIN
            IF v_re_cover.ins_tariff <> 0
            THEN
              v_re_line_cover.re_tariff := v_re_cover.ins_tariff / 100;
            ELSE
              v_re_line_cover.re_tariff := v_re_cover.ins_premium / v_re_cover.ins_amount;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              v_re_line_cover.re_tariff := 0;
          END;
        END IF;
      END IF;
      v_re_line_cover.re_tariff := v_re_line_cover.re_tariff / v_tarif_perc;
    
      --узнаем текущую сумма расчета
    
      IF v_re_line_cover.LIMIT > v_re_cover.ins_amount
      THEN
        v_cur_sum := v_re_cover.ins_amount - v_prev_val;
      ELSE
        v_cur_sum := v_re_line_cover.LIMIT - v_prev_val;
      END IF;
    
      --израсходовали все сумму, то выход
      IF real_ins_amount <= 0
         OR v_cur_sum <= 0
      THEN
        EXIT;
      END IF;
    
      IF v_max_retention_val = 0
      THEN
        v_re_line_cover.part_sum := v_cur_sum;
      END IF;
    
      --нужно определить собственные доли и доли перестраховщика
      IF v_re_line_cover.retention_val > 0
      THEN
        -- указано абсолютное значение
        IF v_cur_sum <= v_re_line_cover.retention_val
        THEN
          v_re_line_cover.retention_val := v_cur_sum;
        END IF;
        v_re_line_cover.part_sum       := v_cur_sum - v_re_line_cover.retention_val;
        v_re_line_cover.retention_perc := v_re_line_cover.retention_val / v_cur_sum * 100;
        v_re_line_cover.part_perc      := 100 - v_re_line_cover.retention_perc;
      ELSIF v_re_line_cover.part_sum > 0
      THEN
        -- указано абсолютное значение для перестраховщика
        IF v_cur_sum <= v_re_line_cover.part_sum
        THEN
          v_re_line_cover.part_sum := v_cur_sum;
        END IF;
        v_re_line_cover.retention_val  := v_cur_sum - v_re_line_cover.part_sum;
        v_re_line_cover.retention_perc := v_re_line_cover.retention_val / v_cur_sum * 100;
        v_re_line_cover.part_perc      := 100 - v_re_line_cover.retention_perc;
      ELSE
        --проценты заданы и для собственной доли и для доли перестраховщика
        --поэтому тут расчет сразу для двух
      
        IF p_type = 0
           AND v_bordero_brief <> 'БОРДЕРО_ЕКСЦЕДЕНТ'
        THEN
        
          --определяем первоначальное страховое обеспечение
          IF v_brief IN ('WOP', 'PWOP', 'WOP_ACC', 'PWOP_ACC', 'PWOP_LIFE', 'WOP_LIFE')
          THEN
            v_re_ins_amount := v_re_cover.ins_amount;
          ELSE
            v_re_ins_amount := v_re_cover.ins_amount *
                               (1 - pkg_reins_calc.GET_RESERVE(v_re_line_cover.re_cover_id));
          END IF;
        
          v_re_line_cover.retention_val := LEAST(v_cur_sum
                                                ,v_re_ins_amount * v_re_line_cover.retention_perc / 100);
        
          --проверка на превышения максимального собственного удержания
          IF v_re_line_cover.retention_val > v_max_retention_val
          THEN
            v_re_line_cover.retention_val := v_max_retention_val;
          END IF;
        
          v_re_line_cover.retention_perc := ROUND(v_re_line_cover.retention_val / v_cur_sum * 100, 2);
          v_re_line_cover.part_perc      := 100 - v_re_line_cover.retention_perc;
        ELSE
          v_re_line_cover.retention_val := v_cur_sum * v_re_line_cover.retention_perc / 100;
        END IF;
        v_re_line_cover.part_sum := v_cur_sum - v_re_line_cover.retention_val;
      END IF;
    
      -- проверка на превышение лимита
      IF v_re_line_cover.part_sum > real_ins_amount
      THEN
        v_re_line_cover.part_sum := real_ins_amount;
        IF v_re_cover.flg_manual = 1
           AND v_re_cover.PART_SUM > 0
        THEN
          NULL;
        ELSE
          v_re_line_cover.flg_is_reduc := 1; --ставим флаг, что линия была ограничена
        END IF;
        v_re_line_cover.retention_val  := v_cur_sum - v_re_line_cover.part_sum;
        v_re_line_cover.retention_perc := v_re_line_cover.retention_val / v_cur_sum * 100;
        v_re_line_cover.part_perc      := 100 - v_re_line_cover.retention_perc;
      END IF;
    
      v_re_line_cover.part_perc      := ROUND(v_re_line_cover.part_perc, 4);
      v_re_line_cover.part_sum       := ROUND(v_re_line_cover.part_sum, 4);
      v_re_line_cover.retention_val  := ROUND(v_re_line_cover.retention_val, 4);
      v_re_line_cover.retention_perc := ROUND(v_re_line_cover.retention_perc, 4);
    
      v_max_retention_val := v_max_retention_val - v_re_line_cover.retention_val;
      --обнуляем нулевое значение:
      v_max_retention_val := (ABS(v_max_retention_val) + v_max_retention_val) / 2;
    
      v_re_line_cover.BRUTTO_PREMIUM := 0;
      v_re_line_cover.COMMISSION     := 0;
      v_re_line_cover.NETTO_PREMIUM  := 0;
    
      --добавляем расчитанную линию
      SELECT sq_re_line_cover.NEXTVAL INTO v_re_line_cover.re_line_cover_id FROM dual;
      v_re_line_cover.re_cover_id := v_re_cover.RE_COVER_ID;
    
      INSERT INTO ven_re_line_cover VALUES v_re_line_cover;
    
      -- вычисление премий перестраховщика
      IF v_re_line_cover.part_perc > 0
      THEN
        IF UPPER(v_bordero_brief) = 'БОРДЕРО_ЕКСЦЕДЕНТ'
        THEN
          v_re_line_cover.BRUTTO_PREMIUM := v_re_line_cover.re_tariff * v_re_cover.ins_premium;
        ELSE
          v_re_line_cover.BRUTTO_PREMIUM := v_re_line_cover.re_tariff * v_re_line_cover.part_sum;
        END IF;
        v_re_line_cover.COMMISSION := v_re_line_cover.BRUTTO_PREMIUM * v_re_line_cover.COMMISSION_PERC / 100;
      END IF;
    
      v_re_line_cover.BRUTTO_PREMIUM := v_re_line_cover.BRUTTO_PREMIUM;
      v_re_line_cover.COMMISSION     := v_re_line_cover.COMMISSION;
      v_re_line_cover.NETTO_PREMIUM  := v_re_line_cover.BRUTTO_PREMIUM - v_re_line_cover.COMMISSION;
    
      UPDATE RE_LINE_COVER
         SET brutto_premium = v_re_line_cover.BRUTTO_PREMIUM
            ,commission     = v_re_line_cover.COMMISSION
            ,netto_premium  = v_re_line_cover.NETTO_PREMIUM
       WHERE re_line_cover_id = v_re_line_cover.re_line_cover_id;
    
      --текущий остаток от премии
      real_ins_amount := real_ins_amount - v_re_line_cover.part_sum;
      --последнее значение линии
      v_prev_val := v_re_line_cover.LIMIT;
    
    END LOOP;
  
    --расчет последней линии
    --нужен тогда, когда:
  
    IF (v_re_cover.ins_amount > v_prev_val --есть остатки
       AND v_re_cover.ins_amount > 0)
       OR (v_re_cover.flg_manual > 0 -- правка вручную премий, без автоматического расчета
       AND
       (v_re_cover.brutto_premium > 0 OR v_re_cover.commission > 0 OR v_re_cover.netto_premium > 0) AND
       v_re_line_cover.line_number = 0)
       OR v_re_cover.flg_is_overflow > 0 --переполнение допустимой суммы
    THEN
    
      IF v_re_cover.flg_manual > 0
         AND
         (v_re_cover.brutto_premium > 0 OR v_re_cover.commission > 0 OR v_re_cover.netto_premium > 0)
         OR v_re_cover.flg_is_overflow > 0
      THEN
      
        v_re_line_cover.netto_premium  := v_re_cover.netto_premium;
        v_re_line_cover.commission     := v_re_cover.commission;
        v_re_line_cover.brutto_premium := v_re_cover.brutto_premium;
      
        IF v_re_cover.brutto_premium > 0
        THEN
          v_re_line_cover.commission_perc := v_re_cover.netto_premium / v_re_cover.brutto_premium;
        ELSE
          v_re_line_cover.commission_perc := 0;
        END IF;
      
        v_re_line_cover.part_sum  := v_re_cover.part_sum;
        v_re_line_cover.re_tariff := v_re_cover.re_tarif / v_tarif_perc;
        v_re_line_cover.part_perc := ROUND(v_re_cover.part_sum / v_re_cover.ins_amount * 100, 2);
        IF v_re_line_cover.part_perc > 100
        THEN
          v_re_line_cover.part_perc := 100;
        END IF;
        v_re_line_cover.RETENTION_PERC := 100 - v_re_line_cover.part_perc;
        v_re_line_cover.retention_val  := v_re_cover.ins_amount - v_re_cover.part_sum;
        IF v_re_line_cover.retention_val < 0
        THEN
          v_re_line_cover.retention_val := 0;
        END IF;
      
        v_re_line_cover.LINE_NUMBER := 0;
      
      ELSE
        --нужно вставить проверку на параметр
        IF p_type = 0
           AND v_bordero_brief <> 'БОРДЕРО_ЕКСЦЕДЕНТ'
           AND NVL(pkg_app_param.get_app_param_n('O_OUT_REMAINS'), 1) = 0
        THEN
          --параметр указывает на сливание остатков перестраховщику
          v_re_line_cover.part_perc      := 100;
          v_re_line_cover.part_sum       := v_re_cover.ins_amount - v_prev_val;
          v_re_line_cover.RETENTION_PERC := 0;
          v_re_line_cover.RETENTION_VAL  := 0;
          v_re_line_cover.re_tariff      := ROUND(v_re_cover.ins_premium / v_re_cover.ins_amount, 2);
        ELSE
          --все сливается в собственное удержание
          v_re_line_cover.part_perc      := 0;
          v_re_line_cover.part_sum       := 0;
          v_re_line_cover.RETENTION_PERC := 100;
          v_re_line_cover.RETENTION_VAL  := v_re_cover.ins_amount - v_prev_val;
          v_re_line_cover.re_tariff      := 0;
        END IF;
      
        v_re_line_cover.commission_perc := 0;
        v_re_line_cover.netto_premium   := 0;
        v_re_line_cover.commission      := 0;
        v_re_line_cover.brutto_premium  := 0;
      END IF;
    
      v_re_line_cover.re_cover_id := v_re_cover.re_cover_id;
    
      BEGIN
        INSERT INTO INS.ven_RE_LINE_COVER
          (RE_LINE_COVER_ID
          ,RE_COVER_ID
          ,LINE_NUMBER
          ,LIMIT
          ,PART_PERC
          ,RE_TARIFF
          ,PART_SUM
          ,BRUTTO_PREMIUM
          ,COMMISSION
          ,NETTO_PREMIUM
          ,COMMISSION_PERC
          ,RETENTION_PERC
          ,RETENTION_VAL)
        VALUES
          (sq_re_line_cover.NEXTVAL
          ,v_re_line_cover.RE_COVER_ID
          ,NVL(v_re_line_cover.LINE_NUMBER, 0) + 1
          ,v_re_cover.ins_amount --v_re_line_cover.LIMIT
          ,v_re_line_cover.part_perc
          ,v_re_line_cover.re_tariff
          ,v_re_line_cover.part_sum
          ,v_re_line_cover.brutto_premium
          ,v_re_line_cover.commission
          ,v_re_line_cover.netto_premium
          ,v_re_line_cover.commission_perc
          ,v_re_line_cover.retention_perc
          ,v_re_line_cover.retention_val);
        --    EXCEPTION 
        --       WHEN OTHERS THEN 
        --Raise_application_error(-20000, 'Не удается создать re_line_cover '||v_re_line_cover.RE_COVER_ID);
      END;
    END IF;
  
    SELECT NVL(SUM(BRUTTO_PREMIUM), 0)
          ,NVL(SUM(COMMISSION), 0)
          ,NVL(SUM(NETTO_PREMIUM), 0)
          ,NVL(SUM(part_sum), 0)
          ,NVL(SUM(flg_is_reduc), 0)
      INTO v_re_cover.brutto_premium
          ,v_re_cover.commission
          ,v_re_cover.netto_premium
          ,v_re_cover.part_sum
          ,v_re_cover.flg_is_reduc
      FROM RE_LINE_COVER
     WHERE re_cover_id = v_re_cover.re_cover_id;
  
    UPDATE RE_COVER
       SET brutto_premium  = ROUND(v_re_cover.brutto_premium, 2)
          ,commission      = ROUND(v_re_cover.commission, 2)
          ,netto_premium   = ROUND(v_re_cover.brutto_premium, 2) - ROUND(v_re_cover.commission, 2)
          ,part_sum        = v_re_cover.part_sum
          ,flg_calc        = 1
          ,flg_cur_version = 1
          ,re_tarif        = v_re_cover.brutto_premium /
                             DECODE(NVL(v_re_cover.part_sum, 0), 0, 1, NVL(v_re_cover.part_sum, 0)) *
                             v_tarif_perc
          ,flg_manual      = v_re_cover.flg_manual
          ,flg_is_reduc    = DECODE(v_re_cover.flg_is_reduc, 0, 0, 1)
          ,flg_is_overflow = v_re_cover.flg_is_overflow
     WHERE re_cover_id = v_re_cover.re_cover_id;
  
    UPDATE RE_LINE_COVER rlc
       SET rlc.BRUTTO_PREMIUM = ROUND(rlc.BRUTTO_PREMIUM, 2)
          ,rlc.COMMISSION     = ROUND(rlc.COMMISSION, 2)
          ,rlc.NETTO_PREMIUM  = ROUND(rlc.NETTO_PREMIUM, 2)
     WHERE rlc.re_cover_id = v_re_cover.re_cover_id;
  
    IF p_type = 0
    THEN
      CLOSE line_bordero;
    ELSE
      CLOSE line_slip;
    END IF;
  
    RETURN v_re_cover.re_cover_id;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION create_rel_recover
  (
    p_re_cover_id   NUMBER
   ,p_re_bordero_id NUMBER
   ,p_nach_sum      NUMBER DEFAULT 0
  ) RETURN NUMBER IS
    v_db DATE;
    --v_db_save date;
    v_de             DATE;
    v_policy_id      NUMBER;
    v_first_pay_date DATE;
    v_decline_date   DATE;
  
    v_p_cover_id         NUMBER;
    v_ent_id             NUMBER;
    v_p_cover_start      DATE;
    v_p_cover_end        DATE;
    v_bordero_type_brief VARCHAR2(100);
    v_pt_brief           VARCHAR2(200);
  
    v_cur_opl_premium NUMBER;
  
    v_id         NUMBER;
    v_re_calc_id NUMBER;
  
    v_brutto NUMBER;
    v_commis NUMBER;
  
    v_counter NUMBER;
    v_count   NUMBER;
  
    v_paym_term_id NUMBER;
    v_exit         NUMBER;
    v_coef         NUMBER;
  
    v_return_sum NUMBER;
    v_brutto_sum NUMBER;
    v_netto_sum  NUMBER;
    v_commis_sum NUMBER;
  
    -- вытаскивает все платежи, которые существуют в системе,
    -- оплата которых произошла в период пакетра бордеро и
    -- которые еще не были учтены
    CURSOR cur_period IS
      SELECT ap.payment_id
            ,ap.amount
            ,ap.plan_date
        FROM ven_ac_payment ap
            ,DOC_DOC        dd
            ,P_POLICY       pp
            ,P_POLICY       ppn
            ,DOC_TEMPL      dt
       WHERE pp.POLICY_ID = v_policy_id
         AND ppn.POL_HEADER_ID = pp.POL_HEADER_ID
         AND dd.parent_id = ppn.policy_id
         AND dd.child_id = ap.payment_id
         AND ap.plan_date BETWEEN v_db AND v_de
         AND ap.doc_templ_id = dt.DOC_TEMPL_ID
         AND dt.BRIEF = 'PAYMENT'
         AND NOT EXISTS
       (SELECT 1
                FROM REL_RECOVER_BORDERO rrb
               WHERE (rrb.re_cover_id = p_re_cover_id AND rrb.ac_payment_id = ap.payment_id AND
                     NVL(pkg_app_param.get_app_param_n('O_OUT_CHECK_PAY_DATE'), 0) = 1)
                  OR (rrb.re_cover_id = p_re_cover_id AND TRUNC(rrb.plan_date) = TRUNC(ap.plan_date) AND
                     NVL(pkg_app_param.get_app_param_n('O_OUT_CHECK_PAY_DATE'), 0) = 0));
  
    --выборка всех платежей по полису
    CURSOR cur_opl_period IS
      SELECT ap.payment_id
            ,ap.amount
            ,ap.plan_date
        FROM ven_ac_payment ap
            ,DOC_DOC        dd
            ,DOC_TEMPL      dt
       WHERE dd.parent_id = v_policy_id
         AND dd.child_id = ap.payment_id
         AND ap.doc_templ_id = dt.DOC_TEMPL_ID
         AND dt.BRIEF = 'PAYMENT';
  
    -- этот курсор нужен только для бордеро доплат
    -- для единовременного платежа по прямому страхованию, чтобы была возможность
    -- делать расчеты ежегодно.
    CURSOR cur_non_period IS
      SELECT ap.payment_id
            ,ap.amount
            ,ap.plan_date
        FROM ven_ac_payment ap
            ,DOC_DOC        dd
            ,DOC_TEMPL      dt
       WHERE dd.parent_id = v_policy_id
         AND dd.child_id = ap.payment_id
         AND ap.doc_templ_id = dt.DOC_TEMPL_ID
         AND dt.BRIEF = 'PAYMENT'
         AND EXISTS
       (SELECT 1
                FROM REL_RECOVER_BORDERO rrb
               WHERE (rrb.re_cover_id = p_re_cover_id AND rrb.ac_payment_id = ap.payment_id AND
                     NVL(pkg_app_param.get_app_param_n('O_OUT_CHECK_PAY_DATE'), 0) = 1)
                  OR (rrb.re_cover_id = p_re_cover_id AND rrb.plan_date = ap.plan_date AND
                     NVL(pkg_app_param.get_app_param_n('O_OUT_CHECK_PAY_DATE'), 0) = 0));
  
    v_cur_payment_id    NUMBER;
    v_cur_amount        NUMBER;
    v_cur_plan_date     DATE;
    v_old_cur_plan_date DATE;
    v_type_payment      NUMBER;
    v_fund_date         DATE;
  
    v_temp_count NUMBER;
  BEGIN
    LOG(p_re_bordero_id, 'CREATE_REL_RECOVER p_re_cover_id ' || p_re_cover_id);
    SELECT bp.start_date
          ,bp.end_date
          ,bt.brief
      INTO v_db
          ,v_de
          ,v_bordero_type_brief
      FROM RE_BORDERO_PACKAGE bp
          ,RE_BORDERO         b
          ,RE_BORDERO_TYPE    bt
     WHERE bp.re_bordero_package_id = b.re_bordero_package_id
       AND b.re_bordero_id = p_re_bordero_id
       AND bt.re_bordero_type_id = b.re_bordero_type_id;
  
    SELECT rc.ins_policy
          ,rc.p_cover_id
          ,NVL(pt.brief, '-1')
          ,pc.start_date
          ,pc.end_date
          ,NVL(mc.FLG_TYPE_PAYMENT, 0)
          ,pc.ent_id
          ,pp.FIRST_PAY_DATE
          ,pp.DECLINE_DATE
          ,pp.PAYMENT_TERM_ID
      INTO v_policy_id
          ,v_p_cover_id
          ,v_pt_brief
          ,v_p_cover_start
          ,v_p_cover_end
          ,v_type_payment
          ,v_ent_id
          ,v_first_pay_date
          ,v_decline_date
          ,v_paym_term_id
      FROM RE_COVER         rc
          ,RE_MAIN_CONTRACT mc
          ,P_COVER          pc
          ,P_POLICY         pp
          ,T_PAYMENT_TERMS  pt
     WHERE rc.re_cover_id = p_re_cover_id
       AND mc.RE_MAIN_CONTRACT_ID = rc.RE_M_CONTRACT_ID
       AND pc.p_cover_id = rc.p_cover_id
       AND pp.policy_id = rc.ins_policy
       AND pt.ID = pp.payment_term_id;
  
    LOG(p_re_bordero_id, 'CREATE_REL_RECOVER p_cover_id ' || v_p_cover_id);
    v_counter := 0;
  
    v_fund_date := get_pcover_fund_date(v_p_cover_id);
  
    IF v_pt_brief = 'Единовременно'
       AND v_bordero_type_brief = 'БОРДЕРО_ДОПЛАТ'
       AND v_type_payment = 0
    THEN
      OPEN cur_non_period;
    ELSIF v_bordero_type_brief = 'БОРДЕРО_РАСТОРЖЕНИЙ'
    THEN
      NULL;
    ELSIF v_type_payment = 1
    THEN
      OPEN cur_opl_period;
    ELSE
      OPEN cur_period;
    END IF;
  
    LOOP
      IF v_pt_brief = 'Единовременно'
         AND v_bordero_type_brief = 'БОРДЕРО_ДОПЛАТ'
         AND v_type_payment = 0
      THEN
      
        FETCH cur_non_period
          INTO v_cur_payment_id
              ,v_cur_amount
              ,v_cur_plan_date;
      
        EXIT WHEN cur_non_period%NOTFOUND;
      
        --нужно проверить, что единовременный единственный платеж уже не
        -- был использован в этом пакете
        SELECT COUNT(1)
          INTO v_count
          FROM RE_BORDERO          rb
              ,RE_BORDERO_PACKAGE  rrp
              ,RE_BORDERO          rb1
              ,REL_RECOVER_BORDERO rrb
         WHERE rb.re_bordero_id = p_re_bordero_id
           AND rrp.re_bordero_package_id = rb.re_bordero_package_id
           AND rb1.re_bordero_package_id = rrp.re_bordero_package_id
           AND rb1.re_bordero_id <> rb.re_bordero_id
              
           AND rrb.re_bordero_id = rb1.re_bordero_id
           AND rrb.ac_payment_id = v_cur_payment_id
           AND rrb.re_cover_id = p_re_cover_id;
        EXIT WHEN v_count > 0;
        LOOP
          --увеличиаем дату "псевдоплатежа" на год
          v_cur_plan_date := ADD_MONTHS(v_cur_plan_date, 12);
          --если перешли за границы договора страхования
          EXIT WHEN v_cur_plan_date > v_p_cover_end;
          --вышли за пределы пакета
          EXIT WHEN v_cur_plan_date > v_de;
        
          IF v_cur_plan_date >= v_db
             AND v_cur_plan_date < v_de
          THEN
            --в этом случае мы нашли нужный период
            EXIT;
          END IF;
        END LOOP;
      
        --двойные проверки, чтобы ничего не делать лишнего
        -- поэтому выход из внешнего цикла
        EXIT WHEN v_cur_plan_date > v_p_cover_end;
        EXIT WHEN v_cur_plan_date > v_de;
      
      ELSIF v_bordero_type_brief = 'БОРДЕРО_РАСТОРЖЕНИЙ'
      THEN
      
        LOG(p_re_bordero_id, 'CREATE_REL_RECOVER v_bordero_type_brief ' || v_bordero_type_brief);
        v_exit := 0;
        IF v_decline_date < v_first_pay_date
        THEN
          v_exit := 2;
        END IF;
        v_cur_plan_date := v_first_pay_date;
        --вычисление платежа для расторжений
        LOOP
          --если дата меньше первоначальной
          EXIT WHEN v_exit = 2;
        
          v_exit := 1; --нужно, если вложенный кусор ничего не найдет
          FOR cur IN (SELECT td.months_in_period
                        FROM T_PAY_TERM_DETAILS td
                       WHERE td.payment_term_id = v_paym_term_id
                       ORDER BY td.payment_nr)
          LOOP
            v_exit := 0; --вложенный курсор что-то нашел
            --Добавлено Веселуха Е.В. 03-06-2009 по заявке №23894
            --v_old_cur_plan_date := v_cur_plan_date;
            -----------------------------------------------------
            v_cur_plan_date := ADD_MONTHS(v_first_pay_date, cur.months_in_period);
            IF v_decline_date BETWEEN v_first_pay_date AND v_cur_plan_date
            THEN
              v_exit := 1; --выход из внешнего цикла
              EXIT;
              --Добавлено Веселуха Е.В. 03-06-2009 по заявке №23894
              --if v_cur_plan_date > v_de then
              --  v_cur_plan_date := v_old_cur_plan_date;
              --  v_exit := 1;
              --  EXIT;
              -----------------------------------------------------  
            ELSE
              v_first_pay_date := v_cur_plan_date; -- увеличиваем начальную дату
            END IF;
          END LOOP;
        
          EXIT WHEN v_cur_plan_date > v_de;
          EXIT WHEN v_exit = 1;
        END LOOP;
      
        --if v_cur_plan_date > v_de then
        --raise_application_error(-20000, 'error in bordero_rast. cur_plan_date >');
        --end if;
        --IF v_decline_date NOT BETWEEN v_first_pay_date AND v_cur_plan_date THEN
        --RAISE_APPLICATION_ERROR(-20000, 'error in bordero_rast. re_cover_id = '||p_re_cover_id||'re_bordero_id='||p_re_bordero_id);
        --END IF;
        v_cur_amount := 0;
      
        -- Расчет коэффциента, отвечающего за сумму возврата
      
        /*
        = (1-((период от начала срока страхования)/мин(5лет; срок страхования по договору))) * Сумму всей уплаченной комиссии
        Для рисков нс с автопролонгацией:
        =(1-период от начала очередного страхового года (автопролонгации))*Сумму всей уплаченной комиссии от начала очередного страхового года (автопролонгации)
        
        */
      
        IF v_decline_date < v_first_pay_date
        THEN
          v_coef := 0;
        ELSIF v_decline_date BETWEEN v_first_pay_date AND v_cur_plan_date
        THEN
          v_coef := (v_cur_plan_date - v_decline_date) / (v_cur_plan_date - v_first_pay_date);
          v_coef := ROUND(v_coef, 4);
        ELSE
          v_coef := 0;
        END IF;
      
        LOG(p_re_cover_id, 'CREATE_REL_RECOVER v_coef ' || v_coef);
      ELSIF v_type_payment = 1
      THEN
        FETCH cur_opl_period
          INTO v_cur_payment_id
              ,v_cur_amount
              ,v_cur_plan_date;
        EXIT WHEN cur_opl_period%NOTFOUND;
      ELSE
        --проблема в том, что происходит динамимческое обновление rel_recover_bordero
        --а курсор оперирует старыми данными, поэтому нужно закрыть курсор и открыть его
        --по новой для БД
        IF v_bordero_type_brief = 'БОРДЕРО_ДОПЛАТ'
        THEN
          CLOSE cur_period;
          OPEN cur_period;
        END IF;
        FETCH cur_period
          INTO v_cur_payment_id
              ,v_cur_amount
              ,v_cur_plan_date;
        EXIT WHEN cur_period%NOTFOUND;
      END IF;
    
      v_counter := v_counter + 1;
      IF v_counter > 1
         AND v_bordero_type_brief IN ('БОРДЕРО_ПРЕМИЙ'
                                     ,'БОРДЕРО_ПРЕМИЙ_НЕ'
                                     ,'БОРДЕРО_ИЗМЕН')
      THEN
        EXIT;
      END IF;
    
      IF v_bordero_type_brief IN ('БОРДЕРО_ПРЕМИЙ'
                                 ,'БОРДЕРО_ПРЕМИЙ_НЕ'
                                 ,'БОРДЕРО_ИЗМЕН')
      THEN
        --v_db_save := v_db;
        v_db := TO_DATE('01011900', 'ddmmyyyy');
      END IF;
      SELECT NVL(SUM(t.trans_amount), 0)
        INTO v_cur_opl_premium
        FROM TRANS       t
            ,OPER        o
            ,DOC_SET_OFF dso
            ,ACCOUNT     a
       WHERE a.num = '77.01.02'
         AND t.ct_account_id = a.account_id
         AND t.trans_date BETWEEN v_db AND v_de --!!!!!!!!!
         AND o.oper_id = t.oper_id
         AND dso.doc_set_off_id = o.document_id
         AND t.obj_uro_id = v_p_cover_id --!!!!!!!!!!!!!!!!!
         AND t.OBJ_URE_ID = v_ent_id --!!!!!!!!!!!!
         AND dso.parent_doc_id = v_cur_payment_id;
    
      LOG(p_re_bordero_id
         ,'CREATE_REL_RECOVER Расчет суммы по проводкам счет 77.01.02 ' || v_cur_opl_premium);
      IF v_cur_opl_premium = 0
         AND v_type_payment = 1
         AND v_bordero_type_brief = 'БОРДЕРО_ДОПЛАТ'
      THEN
        -- если платеж не поступил, то его не нужно добавлять
        NULL;
      ELSE
        SELECT sq_rel_recover_bordero.NEXTVAL INTO v_id FROM dual;
      
        INSERT INTO REL_RECOVER_BORDERO
          (rel_recover_bordero_id
          ,re_cover_id
          ,re_bordero_id
          ,ins_premium
          ,ins_premium_nach
          ,is_accept
          ,ac_payment_id
          ,brutto_premium
          ,commission
          ,netto_premium
          ,returned_premium
          ,plan_date
          ,fund_date)
        VALUES
          (v_id
          ,p_re_cover_id
          ,p_re_bordero_id
          ,v_cur_opl_premium
          ,p_nach_sum
          ,0
          ,v_cur_payment_id
          ,0
          ,0
          ,0
          ,0
          ,v_cur_plan_date
          ,v_fund_date);
      
        v_re_calc_id := pkg_reins_calc.calc_rel_recover(v_id, v_cur_payment_id, v_cur_opl_premium);
      
        SELECT NVL(rc.re_premium, 0)
              ,NVL(rc.commission_val, 0)
          INTO v_brutto
              ,v_commis
          FROM RE_CALCULATION rc
         WHERE rc.re_calculation_id = v_re_calc_id;
      
        LOG(v_re_calc_id, 'CREATE_REL_RECOVER v_re_calc_id ' || v_re_calc_id);
        IF v_bordero_type_brief = 'БОРДЕРО_РАСТОРЖЕНИЙ'
        THEN
        
          --для расторжений считаются премии, но они являются "отрицательными"
          UPDATE REL_RECOVER_BORDERO
             SET returned_premium = v_brutto * v_coef
                ,brutto_premium   = 0
                ,commission       = 0
                ,netto_premium    = 0
           WHERE rel_recover_bordero_id = v_id;
        
        ELSIF v_bordero_type_brief = 'БОРДЕРО_ИЗМЕН'
        THEN
        
          --для БИ нужно учесть изменение суммы
          --если оно произошло в рамках одного пакета
          DECLARE
            v_old_premium NUMBER;
            v_old_commis  NUMBER;
            v_old_return  NUMBER;
          
            v_return NUMBER;
          BEGIN
            --нужно найти версии коверов по другим бордеро
            --в этом же пакете
            SELECT SUM(NVL(rrb.BRUTTO_PREMIUM, 0))
                  ,SUM(NVL(rrb.COMMISSION, 0))
                  ,SUM(NVL(rrb.RETURNED_PREMIUM, 0))
              INTO v_old_premium
                  ,v_old_commis
                  ,v_old_return
              FROM RE_BORDERO          rb1
                  ,RE_BORDERO          rb
                  ,REL_RECOVER_BORDERO rrb
                  ,RE_COVER            rc
                  ,RE_COVER            rc1
             WHERE rb1.RE_BORDERO_ID = p_re_bordero_id
               AND rc1.re_cover_id = p_re_cover_id
               AND rb.re_bordero_package_id = rb1.re_bordero_package_id
               AND rrb.RE_BORDERO_ID = rb.re_bordero_id
               AND rc.re_cover_id = rrb.re_cover_id
               AND rc.T_PRODUCT_LINE_ID = rc1.T_PRODUCT_LINE_ID
               AND rc.P_ASSET_HEADER_ID = rc1.P_ASSET_HEADER_ID
               AND rc.p_cover_id <> rc1.p_cover_id;
          
            v_brutto := NVL(v_brutto, 0) - (NVL(v_old_premium, 0) - NVL(v_old_return, 0));
            v_commis := NVL(v_commis, 0) - NVL(v_old_commis, 0);
            v_return := 0;
          
            IF v_brutto - v_commis < 0
            THEN
              v_return := ABS(v_brutto - v_commis);
              v_brutto := 0;
              v_commis := 0;
            ELSE
              v_return := 0;
            END IF;
          
            IF v_commis < 0
            THEN
              v_brutto := v_brutto + ABS(v_commis);
              v_commis := 0;
              v_return := 0;
            END IF;
          
            UPDATE REL_RECOVER_BORDERO
               SET returned_premium = NVL(v_return, 0)
                  ,brutto_premium   = NVL(v_brutto, 0)
                  ,commission       = NVL(v_commis, 0)
                  ,netto_premium    = NVL(v_brutto, 0) - NVL(v_commis, 0)
             WHERE rel_recover_bordero_id = v_id;
          
          EXCEPTION
            --если запрос ничего не нашел, то будем здесь
            --следовательно, обычное обновление
            WHEN OTHERS THEN
              UPDATE REL_RECOVER_BORDERO
                 SET brutto_premium   = NVL(v_brutto, 0)
                    ,commission       = NVL(v_commis, 0)
                    ,netto_premium    = NVL(v_brutto, 0) - NVL(v_commis, 0)
                    ,returned_premium = 0
               WHERE rel_recover_bordero_id = v_id;
          END;
        
        ELSE
          --для остальных все правильно
          UPDATE REL_RECOVER_BORDERO
             SET brutto_premium   = NVL(v_brutto, 0)
                ,commission       = NVL(v_commis, 0)
                ,netto_premium    = NVL(v_brutto, 0) - NVL(v_commis, 0)
                ,returned_premium = 0
           WHERE rel_recover_bordero_id = v_id;
        END IF;
      
        SELECT NVL(SUM(rrb.RETURNED_PREMIUM), 0)
              ,NVL(SUM(rrb.NETTO_PREMIUM), 0)
              ,NVL(SUM(rrb.BRUTTO_PREMIUM), 0)
              ,NVL(SUM(rrb.COMMISSION), 0)
          INTO v_return_sum
              ,v_netto_sum
              ,v_brutto_sum
              ,v_commis_sum
          FROM REL_RECOVER_BORDERO rrb
         WHERE rrb.RE_COVER_ID = p_re_cover_id;
      
        --т.к. ре_ковер один на всех, то каждый раз нужно уточнять его сумму
        UPDATE RE_COVER rc
           SET rc.RETURN_PREMIUM = v_return_sum
              ,rc.NETTO_PREMIUM  = v_netto_sum
              ,rc.BRUTTO_PREMIUM = v_brutto_sum
              ,rc.COMMISSION     = v_commis_sum
         WHERE rc.RE_COVER_ID = p_re_cover_id;
      
      END IF;
    
      IF v_bordero_type_brief = 'БОРДЕРО_РАСТОРЖЕНИЙ'
      THEN
        -- это нужно для выхода из внешнего цикла
        -- т.к. для этих бордеро нужен только один запуск
        EXIT;
      END IF;
    
    END LOOP;
  
    IF v_pt_brief = 'Единовременно'
       AND v_bordero_type_brief = 'БОРДЕРО_ДОПЛАТ'
       AND v_type_payment = 0
    THEN
      CLOSE cur_non_period;
    ELSIF v_bordero_type_brief = 'БОРДЕРО_РАСТОРЖЕНИЙ'
    THEN
      NULL;
    ELSIF v_type_payment = 1
    THEN
      CLOSE cur_opl_period;
    ELSE
      CLOSE cur_period;
    END IF;
    RETURN v_id;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION create_re_damage
  (
    p_id        NUMBER
   ,p_damage_id NUMBER
   ,p_type      NUMBER
  ) RETURN NUMBER IS
  
    v_re_line_damage  ven_re_line_damage%ROWTYPE;
    v_re_damage       ven_re_damage%ROWTYPE;
    v_re_claim        ven_re_claim%ROWTYPE;
    v_re_claim_header ven_re_claim_header%ROWTYPE;
  
    v_p_cover_id     NUMBER;
    v_c_claim_id     NUMBER;
    v_claim_st_brief VARCHAR2(255);
    v_temp           NUMBER;
  
    real_declare_sum NUMBER;
    real_payment_sum NUMBER;
  
    v_prev_sum NUMBER;
  
    v_cur_dec_sum NUMBER;
    v_cur_pay_sum NUMBER;
  
    v_start_date DATE;
    v_end_date   DATE;
  
  BEGIN
    /*
    1. нужно создать цепочку re_damage-re_claim-re_claim_header
    связанную с конкретным убытком и re_coverom
    */
    BEGIN
      IF p_type = 0
      THEN
        SELECT cd.c_damage_id
              ,NVL(cd.declare_sum, 0) d_sum
              ,NVL(cd.payment_sum, 0) p_sum
              ,cd.t_damage_code_id
              ,cd.c_damage_type_id
              ,cc.seqno seqno
              ,cc.claim_status_id
              ,cc.num || '/re' claim_num
              ,cch.c_claim_header_id
              ,cch.num || '/re' c_header_num
              ,ce.event_date
              ,rc.re_cover_id
              ,rc.re_m_contract_id
              ,rc.re_slip_id
              ,cd.p_cover_id
              ,cc.c_claim_id
          INTO v_re_damage.damage_id
              ,v_re_damage.ins_declared_sum
              ,v_re_damage.ins_payment_sum
              ,v_re_damage.t_damage_code_id
              ,v_re_damage.c_damage_type_id
              ,v_re_claim.seqno
              ,v_re_claim.status_id
              ,v_re_claim.num
              ,v_re_claim_header.c_claim_header_id
              ,v_re_claim_header.num
              ,v_re_claim_header.event_date
              ,v_re_claim_header.re_cover_id
              ,v_re_claim_header.re_m_contract_id
              ,v_re_claim_header.re_slip_id
              ,v_p_cover_id
              ,v_c_claim_id
          FROM ven_c_damage       cd
              ,ven_c_claim        cc
              ,ven_c_claim_header cch
              ,ven_c_event        ce
              ,RE_COVER           rc
              ,P_COVER            pc
              ,AS_ASSET           aa
              ,T_PROD_LINE_OPTION plo
         WHERE cd.c_damage_id = p_damage_id
           AND cc.c_claim_id = cd.c_claim_id
           AND cch.c_claim_header_id = cc.c_claim_header_id
           AND cch.c_event_id = ce.c_event_id
           AND pc.p_cover_id = cd.p_cover_id
           AND pc.AS_ASSET_ID = aa.as_asset_id
           AND pc.T_PROD_LINE_OPTION_ID = plo.ID
           AND rc.P_ASSET_HEADER_ID = aa.P_ASSET_HEADER_ID
           AND rc.T_PRODUCT_LINE_ID = plo.PRODUCT_LINE_ID
           AND rc.FLG_CUR_VERSION = 1
           AND rc.re_bordero_id = p_id;
      ELSE
        SELECT *
          INTO v_re_damage.damage_id
              ,v_re_damage.ins_declared_sum
              ,v_re_damage.ins_payment_sum
              ,v_re_damage.t_damage_code_id
              ,v_re_damage.c_damage_type_id
              ,v_re_claim.seqno
              ,v_re_claim.status_id
              ,v_re_claim.num
              ,v_re_claim_header.c_claim_header_id
              ,v_re_claim_header.num
              ,v_re_claim_header.event_date
              ,v_re_claim_header.re_cover_id
              ,v_re_claim_header.re_m_contract_id
              ,v_re_claim_header.re_slip_id
              ,v_p_cover_id
              ,v_c_claim_id
          FROM (SELECT cd.c_damage_id
                      ,NVL(cd.declare_sum, 0) d_sum
                      ,NVL(cd.payment_sum, 0) p_sum
                      ,cd.t_damage_code_id
                      ,cd.c_damage_type_id
                      ,cc.seqno seqno
                      ,cc.claim_status_id
                      ,cc.num || '/re' claim_num
                      ,cch.c_claim_header_id
                      ,cch.num || '/re' c_header_num
                      ,ce.event_date
                      ,rc.re_cover_id
                      ,rc.re_m_contract_id
                      ,rc.re_slip_id
                      ,cd.p_cover_id
                      ,cc.c_claim_id
                  FROM ven_c_damage       cd
                      ,ven_c_claim        cc
                      ,ven_c_claim_header cch
                      ,ven_c_event        ce
                      ,RE_COVER           rc
                      ,P_COVER            pc
                      ,AS_ASSET           aa
                      ,T_PROD_LINE_OPTION plo
                      ,RE_SLIP            rs
                      ,RE_SLIP            rsa
                 WHERE cd.c_damage_id = p_damage_id --!!!!!!!!
                   AND cc.c_claim_id = cd.c_claim_id
                   AND cch.c_claim_header_id = cc.c_claim_header_id
                   AND cch.c_event_id = ce.c_event_id
                   AND pc.p_cover_id = cd.p_cover_id
                   AND pc.AS_ASSET_ID = aa.as_asset_id
                   AND pc.T_PROD_LINE_OPTION_ID = plo.ID
                      
                   AND rs.re_slip_id = p_id --!!!!!!!!
                   AND rsa.RE_SLIP_HEADER_ID = rs.RE_SLIP_HEADER_ID
                      
                   AND rc.FLG_CUR_VERSION = 1
                   AND rc.re_slip_id = rsa.RE_SLIP_ID
                   AND rc.P_ASSET_HEADER_ID = aa.P_ASSET_HEADER_ID
                   AND rc.T_PRODUCT_LINE_ID = plo.PRODUCT_LINE_ID
                 ORDER BY rc.re_cover_id DESC)
         WHERE ROWNUM = 1;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'get_c_damage:' || p_damage_id || ',' || p_id);
    END;
  
    SELECT pc.t_prod_line_option_id
      INTO v_re_claim_header.t_prod_line_option_id
      FROM P_COVER pc
     WHERE pc.p_cover_id = v_p_cover_id;
    SELECT dc.doc_templ_id
      INTO v_re_claim_header.doc_templ_id
      FROM DOC_TEMPL dc
     WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM_HEADER');
  
    -- Нужно проверить наличие re_claim_header
    SELECT COUNT(1)
      INTO v_temp
      FROM RE_CLAIM_HEADER
     WHERE c_claim_header_id = v_re_claim_header.c_claim_header_id
       AND re_m_contract_id = v_re_claim_header.re_m_contract_id;
  
    BEGIN
      IF v_temp = 0
      THEN
        SELECT sq_re_claim_header.NEXTVAL INTO v_re_claim_header.re_claim_header_id FROM dual;
      
        INSERT INTO ven_re_claim_header VALUES v_re_claim_header;
      ELSE
        SELECT re_claim_header_id
          INTO v_re_claim_header.re_claim_header_id
          FROM RE_CLAIM_HEADER
         WHERE c_claim_header_id = v_re_claim_header.C_CLAIM_HEADER_ID
           AND re_m_contract_id = v_re_claim_header.re_m_contract_id;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Не возможно получить re_claim_header. ' || SQLERRM);
    END;
  
    /*
    теперь нужно создать re_claim
    при этом нужно проверить:
    1. сумма re_payment_sum не превышала 100%
    */
  
    v_re_claim.re_claim_header_id   := v_re_claim_header.re_claim_header_id;
    v_re_claim.re_declare_sum       := 0;
    v_re_claim.re_payment_sum       := 0;
    v_re_claim.re_claim_status_date := SYSDATE;
    SELECT dc.doc_templ_id
      INTO v_re_claim.doc_templ_id
      FROM DOC_TEMPL dc
     WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM');
  
    SELECT COUNT(1)
      INTO v_temp
      FROM RE_CLAIM
     WHERE re_claim_header_id = v_re_claim.re_CLAIM_HEADER_ID
       AND seqno = v_re_claim.seqno;
    BEGIN
      IF v_temp = 0
      THEN
        SELECT sq_re_claim.NEXTVAL INTO v_re_claim.re_claim_id FROM dual;
        INSERT INTO ven_re_claim VALUES v_re_claim;
        BEGIN
          SELECT doc_status_ref_id
            INTO v_temp
            FROM C_CLAIM_STATUS
           WHERE c_claim_status_id = v_re_claim.status_id;
          doc.set_doc_status(v_re_claim.re_claim_id, v_temp);
        EXCEPTION
          WHEN OTHERS THEN
            BEGIN
              doc.set_doc_status(v_re_claim.re_claim_id, doc.GET_LAST_DOC_STATUS_REF_ID(v_c_claim_id));
            EXCEPTION
              WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20000
                                       ,'Не возможно установить статус re_claim.' || SQLERRM);
            END;
        END;
      
      ELSE
        SELECT re_claim_id
              ,re_declare_sum
              ,re_payment_sum
          INTO v_re_claim.re_claim_id
              ,v_re_claim.re_declare_sum --узнаем существующие суммы
              ,v_re_claim.re_payment_sum
          FROM ven_re_claim
         WHERE re_claim_header_id = v_re_claim.re_claim_header_id
           AND seqno = v_re_claim.seqno;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000
                               ,'Не возможно получить re_claim. ' || SQLERRM);
    END;
  
    /*
    нужно пересоздать re_damage, если он не принадлежит заявлению в статусе 
    "акцептован"
    */
  
    IF doc.GET_DOC_STATUS_BRIEF(v_re_claim.re_claim_id) = 'ACCEPTED'
    THEN
      SELECT rd.re_damage_id
        INTO v_re_damage.re_damage_id
        FROM RE_DAMAGE rd
       WHERE rd.DAMAGE_ID = v_re_damage.damage_id
         AND rd.RE_CLAIM_ID = v_re_damage.re_claim_id;
      RETURN v_re_damage.re_damage_id;
    ELSE
      v_re_damage.re_cover_id     := v_re_claim_header.re_cover_id;
      v_re_damage.re_claim_id     := v_re_claim.re_claim_id;
      v_re_damage.re_declared_sum := 0;
      v_re_damage.re_payment_sum  := 0;
      SELECT sq_re_damage.NEXTVAL INTO v_re_damage.re_damage_id FROM dual;
      DELETE RE_DAMAGE
       WHERE re_cover_id = v_re_damage.re_cover_id
         AND re_claim_id = v_re_damage.re_claim_id
         AND damage_id = v_re_damage.damage_id;
      INSERT INTO ven_re_damage VALUES v_re_damage;
    END IF;
  
    --теперь нужно узнать сколько уже убытка перестраховано
    SELECT NVL(SUM(rd.re_declared_sum), 0)
          ,NVL(SUM(rd.re_payment_sum), 0)
      INTO real_declare_sum
          ,real_payment_sum
      FROM RE_DAMAGE rd
     WHERE rd.damage_id = p_damage_id
       AND rd.re_damage_id <> v_re_damage.re_damage_id;
    real_declare_sum := v_re_damage.ins_declared_sum - real_declare_sum;
    real_payment_sum := v_re_damage.ins_payment_sum - real_payment_sum;
  
    --теперь нужно рассписать заявленные и выплаченные суммы
    --по расчитанным линиям, с учетом реальных
  
    v_prev_sum := 0;
  
    FOR line IN ( --цикл по линиям рекавера и договора 1
                 SELECT cov.line_number
                        ,cov.LIMIT
                        ,cov.part_perc
                        ,cov.part_sum
                        ,cov.retention_val
                        ,cov.retention_perc
                        ,cov.re_line_contract_id
                        ,0                       part_sum_con
                        ,0                       ret_val_con
                   FROM RE_LINE_COVER cov
                  WHERE cov.re_cover_id = v_re_damage.re_cover_id
                    AND cov.re_line_contract_id IS NOT NULL
                  ORDER BY cov.line_number)
    LOOP
      --цикл по линиям рекавера и договора 2
    
      IF p_type = 0
      THEN
        SELECT lc.part_sum
              ,lc.retention_val
          INTO line.part_sum_con
              ,line.ret_val_con
          FROM RE_LINE_CONTRACT lc
         WHERE lc.re_line_contract_id = line.re_line_contract_id;
      ELSE
        SELECT ls.part_sum
              ,ls.retention_val
          INTO line.part_sum_con
              ,line.ret_val_con
          FROM RE_LINE_SLIP ls
         WHERE ls.re_line_slip_id = line.re_line_contract_id;
      END IF;
    
      v_re_line_damage.re_damage_id := v_re_damage.re_damage_id;
      v_re_line_damage.line_number  := line.line_number;
      v_re_line_damage.LIMIT        := line.LIMIT;
      v_re_line_damage.part_sum     := line.part_sum;
      v_re_line_damage.part_perc    := line.part_perc;
    
      --расчитываем заявленную сумму
      IF v_re_damage.ins_declared_sum >= line.LIMIT
      THEN
        -- тут все просто. Нужно взять уже расчитанную линию
        v_re_line_damage.part_decl := line.part_sum;
      
      ELSE
        v_cur_dec_sum := v_re_damage.ins_declared_sum - v_prev_sum;
        --эта проверка нужна для того, чтобы в минус не уйти
        IF v_cur_dec_sum < 0
        THEN
          v_re_line_damage.part_decl := 0;
        ELSE
        
          -- возможно на линии договора были указаны конкретные значения, поэтому их нужно учесть
          --указано собственное значение
          IF NVL(line.ret_val_con, 0) > 0
          THEN
            IF line.ret_val_con > v_cur_dec_sum
            THEN
              v_re_line_damage.part_decl := 0; --все забрали себе
            ELSE
              v_re_line_damage.part_decl := line.ret_val_con - v_cur_dec_sum; --часть отдали
            END IF;
          END IF;
        
          --указано значение для перестраховщика
          IF NVL(line.part_sum_con, 0) > 0
             AND NVL(line.ret_val_con, 0) = 0
          THEN
            IF line.part_sum_con > v_cur_dec_sum
            THEN
              v_re_line_damage.part_decl := v_cur_dec_sum; --все отдали перестраховщику
            ELSE
              v_re_line_damage.part_decl := line.part_sum_con; --отдали указанное
            END IF;
          END IF;
        
          --указаны проценты
          IF NVL(line.ret_val_con, 0) = 0
             AND NVL(line.part_sum_con, 0) = 0
          THEN
            v_re_line_damage.part_decl := ROUND(v_cur_dec_sum * line.part_perc / 100, 4);
          END IF;
        
        END IF;
      END IF;
    
      --расчитываем оплаченную сумму
      IF v_re_damage.ins_payment_sum >= line.LIMIT
      THEN
        -- тут все просто. Нужно взять уже расчитанную линию
        v_re_line_damage.part_pay := line.part_sum;
      
      ELSE
        v_cur_pay_sum := v_re_damage.ins_payment_sum - v_prev_sum;
        --эта проверка нужна для того, чтобы в минус не уйти
        IF v_cur_pay_sum < 0
        THEN
          v_re_line_damage.part_pay := 0;
        ELSE
        
          -- возможно на линии договора были указаны конкретные значения, поэтому их нужно учесть
          --указано собственное значение
          IF NVL(line.ret_val_con, 0) > 0
          THEN
            IF line.ret_val_con > v_cur_pay_sum
            THEN
              v_re_line_damage.part_pay := 0; --все забрали себе
            ELSE
              v_re_line_damage.part_pay := line.ret_val_con - v_cur_pay_sum; --часть отдали
            END IF;
          END IF;
        
          --указано значение для перестраховщика
          IF NVL(line.part_sum_con, 0) > 0
             AND NVL(line.ret_val_con, 0) = 0
          THEN
            IF line.part_sum_con > v_cur_pay_sum
            THEN
              v_re_line_damage.part_pay := v_cur_pay_sum; --все отдали перестраховщику
            ELSE
              v_re_line_damage.part_pay := line.part_sum_con; --отдали указанное
            END IF;
          END IF;
        
          --указаны проценты
          IF NVL(line.ret_val_con, 0) = 0
             AND NVL(line.part_sum_con, 0) = 0
          THEN
            v_re_line_damage.part_pay := ROUND(v_cur_pay_sum * line.part_perc / 100, 4);
          END IF;
        
        END IF;
      END IF;
    
      --проверяем на превышение уже перестрахованных
      IF v_re_line_damage.part_decl > real_declare_sum
      THEN
        v_re_line_damage.part_decl := real_declare_sum;
      END IF;
      IF v_re_line_damage.part_pay > real_payment_sum
      THEN
        v_re_line_damage.part_pay := real_payment_sum;
      END IF;
    
      --сохраняем значение текущего лимита
      v_prev_sum := line.LIMIT;
    
      --уменьшаем доступную сумму
      real_declare_sum := real_declare_sum - v_re_line_damage.part_decl;
      real_payment_sum := real_payment_sum - v_re_line_damage.part_pay;
    
      IF v_re_line_damage.part_decl <= 0
         AND v_re_line_damage.part_pay <= 0
      THEN
        EXIT;
      END IF;
    
      SELECT sq_re_line_damage.NEXTVAL INTO v_re_line_damage.re_line_damage_id FROM dual;
      --cохраняем заполненную линию
    
      v_re_line_damage.part_pay  := NVL(v_re_line_damage.part_pay, 0);
      v_re_line_damage.part_decl := NVL(v_re_line_damage.part_decl, 0);
    
      INSERT INTO ven_re_line_damage VALUES v_re_line_damage;
    
    END LOOP; --цикл по линиям рекавера и договора 3
  
    --обновляем суммы на re_damage
    SELECT NVL(SUM(part_decl), 0)
          ,NVL(SUM(part_pay), 0)
      INTO v_re_damage.re_declared_sum
          ,v_re_damage.re_payment_sum
      FROM RE_LINE_DAMAGE
     WHERE re_damage_id = v_re_damage.re_damage_id;
  
    --для слипов нужно заполнять сумму оплаты, только для статуса
    -- версии претензии "закрыто"
    IF p_type = 1
    THEN
      v_claim_st_brief := doc.get_doc_status_brief(v_re_claim.re_claim_id);
      IF v_claim_st_brief <> 'CLOSE'
      THEN
        v_re_damage.re_payment_sum := 0;
      END IF;
    END IF;
  
    UPDATE ven_re_damage
       SET re_declared_sum = v_re_damage.re_declared_sum
          ,re_payment_sum  = v_re_damage.re_payment_sum
     WHERE re_damage_id = v_re_damage.re_damage_id;
  
    -- обновляем суммы на re_claim
    SELECT NVL(SUM(re_declared_sum), 0)
          ,NVL(SUM(re_payment_sum), 0)
      INTO v_re_claim.re_declare_sum
          ,v_re_claim.re_payment_sum
      FROM RE_DAMAGE
     WHERE re_claim_id = v_re_claim.re_claim_id;
  
    UPDATE ven_re_claim
       SET re_declare_sum = v_re_claim.re_declare_sum
          ,re_payment_sum = v_re_claim.re_payment_sum
     WHERE re_claim_id = v_re_claim.re_claim_id;
  
    RETURN v_re_damage.re_damage_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'!!!p_id=' || p_id || ';dam_id=' || p_damage_id || '; ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION create_version(p_re_main_contract IN NUMBER) RETURN NUMBER IS
    v_ver         ven_re_contract_version%ROWTYPE;
    v_ver_el      RE_CONTRACT_VER_EL%ROWTYPE;
    v_temp_max_id NUMBER;
    v_error_txt   VARCHAR2(4000) := NULL;
    v_error_code  NUMBER;
  BEGIN
    --получаем предыдушую версию
    SELECT last_version_id
      INTO v_temp_max_id
      FROM RE_MAIN_CONTRACT
     WHERE re_main_contract_id = p_re_main_contract;
    --полностью копируем содержимое предыдущей версии
    SELECT * INTO v_ver FROM ven_re_contract_version WHERE re_contract_version_id = v_temp_max_id;
  
    --персонализация текущей версии
    SELECT sq_re_contract_version.NEXTVAL INTO v_ver.re_contract_version_id FROM dual;
    SELECT COUNT(1)
      INTO v_ver.seq_num
      FROM RE_CONTRACT_VERSION
     WHERE re_main_contract_id = p_re_main_contract;
  
    v_ver.reg_date   := SYSDATE;
    v_ver.sign_date  := SYSDATE;
    v_ver.start_date := SYSDATE;
    v_ver.num        := get_num_ver(p_re_main_contract);
  
    --создаем новую версию
    BEGIN
      INSERT INTO ven_re_contract_version VALUES v_ver;
    EXCEPTION
      WHEN OTHERS THEN
        v_error_txt  := 'Ошибка созания новой записи.';
        v_error_code := -20001;
        RAISE;
    END;
  
    --копирование данных эксцедента убытка (эсли есть)
    BEGIN
      SELECT * INTO v_ver_el FROM RE_CONTRACT_VER_EL WHERE re_contract_ver_el_id = v_temp_max_id;
      v_ver_el.re_contract_ver_el_id := v_ver.re_contract_version_id;
      INSERT INTO RE_CONTRACT_VER_EL VALUES v_ver_el;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Ошибка ЭУ.' || SQLERRM);
    END;
  
    --начальный статус
    BEGIN
      doc.set_doc_status(v_ver.re_contract_version_id, 'PROJECT');
    EXCEPTION
      WHEN OTHERS THEN
        v_error_txt  := 'Ошибка назначения статуса.';
        v_error_code := -20002;
        RAISE;
        RAISE_APPLICATION_ERROR(-20002, 'Ошибка назначения статуса.');
    END;
    --копирование связанных данных
    BEGIN
      pkg_reins.copy_version(v_ver.re_contract_version_id);
    EXCEPTION
      WHEN OTHERS THEN
        v_error_txt  := 'Ошибка копирования.';
        v_error_code := -20003;
        RAISE;
    END;
  
    RETURN v_ver.re_contract_version_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF v_error_txt IS NOT NULL
      THEN
        RAISE_APPLICATION_ERROR(v_error_code, v_error_txt);
      ELSE
        RAISE_APPLICATION_ERROR(-20000
                               ,'Ошибка создания новой версии (неизвестная ошибка).' || SQLERRM);
      END IF;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE copy_version(new_ver_id IN NUMBER) IS
    v_test_last_ver    NUMBER;
    v_main_contract_id NUMBER;
    v_new_filter_id    NUMBER;
  
    v_doc_templ_brief VARCHAR2(50);
    v_ent_id          NUMBER;
  
    v_start_date DATE;
    v_end_date   DATE;
    v_reg_date   DATE;
    v_num        VARCHAR2(255);
  BEGIN
    --нужно узнать ИД основного договора
    SELECT re_main_contract_id
      INTO v_main_contract_id
      FROM RE_CONTRACT_VERSION
     WHERE re_contract_version_id = new_ver_id;
  
    -- теперь нужно узнать, есть ли действующие версии
    SELECT COUNT(1)
      INTO v_test_last_ver
      FROM RE_MAIN_CONTRACT
     WHERE re_main_contract_id = v_main_contract_id
       AND last_version_id IS NOT NULL;
  
    -- если создается ексцедент убытка, то нужно добавить данные в
    -- таблицу re_contract_ver_el
    SELECT dt.brief
      INTO v_doc_templ_brief
      FROM ven_re_contract_version CV
          ,ven_doc_templ           dt
     WHERE dt.doc_templ_id = CV.doc_templ_id
       AND CV.RE_CONTRACT_VERSION_ID = new_ver_id;
  
    CASE UPPER(v_doc_templ_brief)
      WHEN 'REOBLEL' THEN
        SELECT ent_id INTO v_ent_id FROM ENTITY WHERE UPPER(brief) = 'RE_CONTRACT_VER_EL';
      
        UPDATE DOCUMENT SET ent_id = v_ent_id WHERE document_id = new_ver_id;
      
        INSERT INTO RE_CONTRACT_VER_EL cve
          (cve.re_contract_ver_el_id, cve.filial_id, cve.cur_sum_premium, cve.cur_premium)
          SELECT re_contract_version_id
                ,filial_id
                ,0
                ,0
            FROM ven_re_contract_version
           WHERE re_contract_version_id = new_ver_id;
      ELSE
        NULL;
    END CASE;
  
    IF v_test_last_ver = 0
    THEN
      --это самая первая версия договора, поэтому ее нужно сделать на нее ссылку
      UPDATE RE_MAIN_CONTRACT
         SET last_version_id = new_ver_id
       WHERE re_main_contract_id = v_main_contract_id;
      --больше делать ничего не надо, поэтому выход
      RETURN;
    ELSE
      -- У договора есть какие-то версии, поэтому нужно найти основную текущую версию
      SELECT last_version_id
        INTO v_test_last_ver
        FROM RE_MAIN_CONTRACT
       WHERE re_main_contract_id = v_main_contract_id;
      --теперь нужно скопировать
    
      --1. все условия отборов рисков
      --  1.1. все линие по выбранным рискам
      --2. все лимиты
      --3 исключения
      --4. все пакеты бордеро (уточнить, пока это делать не буду)
    
      /*select start_date, end_date, reg_date, num
        into v_start_date, v_end_date, v_reg_date, v_num
        from ven_re_contract_version
        where re_contract_version_id = v_test_last_ver;
      
      update ven_re_contract_version
        set start_date = v_start_date
          , end_date = v_end_date
          , reg_date = v_reg_date
          , num = v_num
        where re_contract_version_id = new_ver_id;*/
    
      -- 1. вставка фильтров риска
      FOR FILTER IN (SELECT RE_COND_FILTER_OBL_ID
                           ,PRODUCT_ID
                           ,INSURANCE_GROUP_ID
                           ,ASSET_TYPE_ID
                           ,PRODUCT_LINE_ID
                           ,AGENT_ID
                           ,ISSUER_ID
                           ,RE_MAIN_CONTRACT_ID
                           ,RE_CONTRACT_VER_ID
                       FROM RE_COND_FILTER_OBL
                      WHERE re_contract_ver_id = v_test_last_ver)
      LOOP
      
        --копируем условия
        SELECT sq_re_cond_filter_obl.NEXTVAL INTO v_new_filter_id FROM dual;
      
        INSERT INTO ven_RE_COND_FILTER_OBL
          (RE_COND_FILTER_OBL_ID
          ,PRODUCT_ID
          ,INSURANCE_GROUP_ID
          ,ASSET_TYPE_ID
          ,PRODUCT_LINE_ID
          ,RE_CONTRACT_VER_ID
          ,AGENT_ID
          ,ISSUER_ID
          ,RE_MAIN_CONTRACT_ID)
        VALUES
          (v_new_filter_id
          ,FILTER.PRODUCT_ID
          ,FILTER.INSURANCE_GROUP_ID
          ,FILTER.ASSET_TYPE_ID
          ,FILTER.PRODUCT_LINE_ID
          ,new_ver_id --новая версия договора
          ,FILTER.AGENT_ID
          ,FILTER.ISSUER_ID
          ,FILTER.RE_MAIN_CONTRACT_ID);
      
        -- 1.1. теперь нужно для каждого фильтра сделать копию линии
        FOR line IN (SELECT *
                       FROM RE_LINE_CONTRACT lc
                      WHERE lc.re_cond_filter_obl_id = FILTER.RE_COND_FILTER_OBL_ID)
        LOOP
        
          INSERT INTO ven_RE_LINE_CONTRACT
            (re_line_contract_id
            ,line_number
            ,LIMIT
            ,retention_perc
            ,retention_val
            ,part_perc
            ,part_sum
            ,commission_perc
            ,fund_id
            ,tariff_ins
            ,re_cond_filter_obl_id
            ,re_tariff
            ,t_prod_coef_type_id)
          VALUES
            (sq_re_line_contract.NEXTVAL
            ,line.line_number
            ,line.LIMIT
            ,line.retention_perc
            ,line.retention_val
            ,line.part_perc
            ,line.part_sum
            ,line.commission_perc
            ,line.fund_id
            ,line.tariff_ins
            ,v_new_filter_id --новый ИД фильта
            ,line.re_tariff
            ,line.t_prod_coef_type_id);
        END LOOP;
      END LOOP;
    
      --2. копирование лимитов
      FOR limits IN (SELECT LIMIT
                           ,FUND_ID
                           ,t_product_line_id
                       FROM RE_LIMIT_CONTRACT
                      WHERE re_contract_version_id = v_test_last_ver)
      LOOP
        INSERT INTO ven_RE_LIMIT_CONTRACT
          (re_limit_contract_id, LIMIT, fund_id, t_product_line_id, RE_CONTRACT_VERSION_ID)
        VALUES
          (sq_re_limit_contract.NEXTVAL
          ,limits.LIMIT
          ,limits.fund_id
          ,limits.t_product_line_id
          ,new_ver_id --новая версия договора
           );
      END LOOP;
    
      --3. копирование исключений
      FOR exc IN (SELECT ce.re_contract_id
                        ,ce.re_contract_version_id
                        ,ce.p_pol_header_id
                        ,ce.t_product_line_id
                        ,ce.p_asset_header_id
                    FROM RE_CONTRACT_EXC ce
                   WHERE ce.re_contract_version_id = v_test_last_ver)
      LOOP
        INSERT INTO ven_re_contract_exc ce
          (ce.re_contract_id
          ,ce.re_contract_version_id
          ,ce.re_slip_id
          ,ce.p_pol_header_id
          ,ce.t_product_line_id
          ,ce.p_asset_header_id)
        VALUES
          (exc.re_contract_id
          ,new_ver_id --новая версия договора
          ,NULL
          ,exc.p_pol_header_id
          ,exc.t_product_line_id
          ,exc.p_asset_header_id);
      END LOOP;
    
    END IF;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_num_ver(p_ver_id IN NUMBER) RETURN VARCHAR2 IS
    v_num VARCHAR2(100);
    v_seq NUMBER;
  BEGIN
  
    SELECT COUNT(1) INTO v_seq FROM RE_CONTRACT_VERSION WHERE re_main_contract_id = p_ver_id;
    SELECT mc.num || '/' || TO_CHAR(v_seq)
      INTO v_num
      FROM ven_re_main_contract mc
     WHERE mc.RE_MAIN_CONTRACT_ID = p_ver_id;
    RETURN v_num;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN TO_CHAR(p_ver_id);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION create_bordero_pack_list(p_contract_id IN NUMBER) RETURN NUMBER IS
    v_last_version_id NUMBER;
  
    v_count_mounth NUMBER;
    v_calendar_flg NUMBER;
  
    v_bd          DATE;
    v_ed          DATE;
    v_start_date  DATE;
    v_contract_bd DATE;
    v_contract_ed DATE;
    v_num         VARCHAR2(255);
  
    v_select     NUMBER;
    v_temp_count NUMBER;
  
    v_bp ven_re_bordero_package%ROWTYPE;
    v_b  ven_re_bordero%ROWTYPE;
  BEGIN
    LOG(p_contract_id, 'CREATE_BORDERO_PACK_LIST');
  
    SELECT mc.LAST_VERSION_ID
      INTO v_last_version_id
      FROM RE_MAIN_CONTRACT mc
     WHERE mc.RE_MAIN_CONTRACT_ID = p_contract_id;
  
    --1. получаем периодичность
    BEGIN
      SELECT bp.count_mounth
            ,bp.calendar_flg
        INTO v_count_mounth
            ,v_calendar_flg
        FROM ven_re_contract_version CV
            ,ven_re_bordero_period   bp
       WHERE CV.re_contract_version_id = v_last_version_id
         AND bp.re_bordero_period_id = CV.re_bordero_period_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_count_mounth := 12;
        v_calendar_flg := 1;
    END;
  
    SELECT CV.re_contract_version_id
          ,CV.re_main_contract_id
          ,CV.num
          ,mc.fund_id
          ,mc.assignor_id
          ,mc.reinsurer_id
          ,TRUNC(CV.start_date, 'dd')
          ,NVL(CV.end_date, ADD_MONTHS(TRUNC(SYSDATE, 'yyyy'), 12) - 1)
      INTO v_bp.re_contract_id
          ,v_bp.re_m_contract_id
          ,v_num
          ,v_bp.fund_pay_id
          ,v_bp.assignor_id
          ,v_bp.reinsurer_id
          ,v_contract_bd
          ,v_contract_ed
      FROM ven_re_contract_version CV
          ,ven_re_main_contract    mc
     WHERE CV.re_contract_version_id = v_last_version_id
       AND mc.re_main_contract_id = CV.re_main_contract_id;
  
    BEGIN
      -- если уже есть какие-то пакеты бордеро
      -- то начальная дата текущего пакета будет конечной датой последнего пакета
      SELECT TRUNC(MAX(end_date), 'dd')
        INTO v_start_date
        FROM ven_re_bordero_package
       WHERE re_m_contract_id = p_contract_id;
    
      IF v_start_date IS NOT NULL
      THEN
        v_contract_bd := v_start_date;
        IF v_contract_bd <> v_contract_ed
        THEN
          v_contract_bd := v_contract_bd + 1;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    IF v_calendar_flg = 1
    THEN
      --используем календарные значения
      --встаем на начало года
      v_start_date := TRUNC(v_contract_bd, 'yyyy');
    ELSE
      --встаем на начало контракта
      v_start_date := v_contract_bd;
    END IF;
  
    -- выбираем нужный период
    v_bd := v_contract_bd; --встаем на начало договора
    v_ed := v_start_date; --начало отчетного периода
  
    --теперь нужно, чтобы конечная дата была позже начальной
    WHILE v_ed <= v_bd
    LOOP
      v_start_date := v_ed; --всегда указывает на кратное начало действия
      v_ed         := ADD_MONTHS(v_ed, v_count_mounth);
    END LOOP;
  
    --все. определили первый период
    --теперь нужно нагерить пакеты бордеро
  
    WHILE v_bd <= v_contract_ed
    LOOP
      IF v_ed > v_contract_ed
      THEN
        v_ed := v_contract_ed + 1;
      END IF;
    
      --проверка на ограничение по текущей дате
      IF v_bd > SYSDATE
      THEN
        EXIT;
      END IF;
    
      v_bp.start_date := TO_DATE(TO_CHAR(v_bd, 'ddmmyyyy') || '00.00.00', 'ddmmyyyy.HH24.mi.ss');
      v_bp.end_date   := TO_DATE(TO_CHAR(v_ed - 1, 'ddmmyyyy') || '23.59.59', 'ddmmyyyy.HH24.mi.ss');
    
      SELECT COUNT(1)
        INTO v_temp_count
        FROM ven_re_bordero_package bp
       WHERE bp.re_m_contract_id = p_contract_id --!!!
         AND bp.start_date = v_bp.start_date --!!
         AND bp.end_date = v_bp.end_date; --!!!
    
      IF v_temp_count = 0
      THEN
        --нужно создать пакет бордеро
      
        SELECT sq_re_bordero_package.NEXTVAL INTO v_bp.re_bordero_package_id FROM dual;
      
        BEGIN
          SELECT dt.doc_templ_id
            INTO v_bp.doc_templ_id
            FROM DOC_TEMPL dt
           WHERE dt.brief = 'RE_BORDERO_PACKAGE';
        EXCEPTION
          WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Не найден шаблон документа.');
        END;
      
        SELECT v_num || '\' || TO_CHAR(COUNT(1) + 1)
          INTO v_bp.num
          FROM ven_re_bordero_package
         WHERE re_m_contract_id = p_contract_id;
      
        v_bp.summ     := 0;
        v_bp.summ_in  := 0;
        v_bp.summ_out := 0;
      
        BEGIN
          INSERT INTO ven_re_bordero_package VALUES v_bp;
          LOG(p_contract_id
             ,'CREATE_BORDERO_PACK_LIST v_bp.re_bordero_package_id ' || v_bp.re_bordero_package_id ||
              ' PROJECT');
          doc.set_doc_status(v_bp.re_bordero_package_id, 'PROJECT');
        EXCEPTION
          WHEN OTHERS THEN
            LOG(p_contract_id
               ,'CREATE_BORDERO_PACK_LIST Создание пакета бордеро EXCEPTION ' || SQLERRM);
            RAISE_APPLICATION_ERROR(-20000
                                   ,'Невозможно создать пакет бордеро.');
        END;
      
        /*
                FOR cur IN (
                  SELECT re_bordero_type_id
                    FROM ven_re_bordero_type
                    WHERE short_name IS NOT NULL
                  ) LOOP
        
                  SELECT sq_re_bordero.NEXTVAL INTO v_b.re_bordero_id FROM dual;
        
                  SELECT dt.doc_templ_id INTO v_b.doc_templ_id
                    FROM ven_doc_templ dt
                    WHERE dt.brief = 'RE_BORDERO';
        
                  v_b.re_bordero_package_id := v_bp.re_bordero_package_id;
                  v_b.re_bordero_type_id := cur.re_bordero_type_id;
                  v_b.num := TO_CHAR(v_b.re_bordero_id);
                  v_b.fund_id := v_bp.fund_pay_id;
                  v_b.flg_date_rate := NVL(pkg_app_param.GET_APP_PARAM_N('O_OUT_FUND_DATE'),0);
        
                  SELECT rate_type_id, 1
                    INTO v_b.rate_type_id, v_b.rate_val
                    FROM ven_rate_type WHERE brief = 'ЦБ';
        
                  BEGIN
                    INSERT INTO ven_re_bordero VALUES v_b;
                    LOG (p_contract_id, 'CREATE_BORDERO_PACK_LIST v_b.re_bordero_id '||v_b.re_bordero_id||' doc.get_doc_status_brief(v_bp.re_bordero_package_id) '||doc.get_doc_status_brief(v_bp.re_bordero_package_id));
                    
                    doc.set_doc_status(v_b.re_bordero_id, doc.get_doc_status_brief(v_bp.re_bordero_package_id));
                  EXCEPTION
                    WHEN OTHERS THEN
                      LOG (p_contract_id, 'CREATE_BORDERO_PACK_LIST EXCEPTION '||sqlerrm);
                      RAISE_APPLICATION_ERROR(-20000, 'Невозможно создать бордеро.');
                  END;
        
                END LOOP;
        */
      
      END IF;
    
      v_bd         := ADD_MONTHS(v_start_date, v_count_mounth);
      v_ed         := ADD_MONTHS(v_bd, v_count_mounth);
      v_start_date := ADD_MONTHS(v_start_date, v_count_mounth);
    
    END LOOP;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION delete_contract(p_contract_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    UPDATE RE_MAIN_CONTRACT rmc
       SET last_version_id = NULL
     WHERE rmc.re_main_contract_id = p_contract_id;
    FOR cur IN (SELECT re_contract_version_id ID
                  FROM RE_CONTRACT_VERSION
                 WHERE re_main_contract_id = p_contract_id)
    LOOP
      v_result := delete_version(cur.ID);
    
    END LOOP;
    DELETE RE_MAIN_CONTRACT WHERE re_main_contract_id = p_contract_id;
  
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'Ошибка удаления договора' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION delete_version(p_ver_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    DELETE RE_LIMIT_CONTRACT WHERE re_contract_version_id = p_ver_id;
    FOR cur IN (SELECT re_cond_filter_obl_id ID
                  FROM RE_COND_FILTER_OBL
                 WHERE re_contract_ver_id = p_ver_id)
    LOOP
      DELETE RE_LINE_CONTRACT WHERE re_cond_filter_obl_id = cur.ID;
    END LOOP;
    DELETE RE_COND_FILTER_OBL WHERE re_contract_ver_id = p_ver_id;
    UPDATE RE_MAIN_CONTRACT SET last_version_id = NULL WHERE last_version_id = p_ver_id;
    DELETE RE_CONTRACT_VER_EL WHERE re_contract_ver_el_id = p_ver_id;
    DELETE RE_CONTRACT_VERSION WHERE re_contract_version_id = p_ver_id;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'Невозможно удалить версию договора ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE change_st_bordero_from_pack
  (
    p_pack_id  IN NUMBER
   ,p_st_brief VARCHAR2 DEFAULT 'ACCEPTED'
  ) IS
  BEGIN
    FOR cur IN (SELECT re_bordero_id FROM RE_BORDERO WHERE re_bordero_package_id = p_pack_id)
    LOOP
      BEGIN
        --update re_bordero b
        --set b.accept_date = doc.get_status_date(p_pack_id, 'ACCEPTED')
        --where b.re_bordero_id = cur.re_bordero_id;
        Doc.set_doc_status(cur.re_bordero_id, p_st_brief);
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000, SQLERRM);
      END;
    END LOOP;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE re_commision_calculate(p_re_bordero_id NUMBER) AS
    ydatea_new        DATE;
    v_bordero_type_id VARCHAR2(50);
  
    v_RE_COMM_RATE  NUMBER;
    v_re_commission NUMBER;
  
    v_RETURN_RE_COMMISSION NUMBER;
    v_period               NUMBER;
    v_mn1_year             NUMBER;
    PROCEDURE CALCURATE_BORDERO IS
    BEGIN
      LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE CALCURATE_BORDERO');
      FOR v_re_cover IN (SELECT rrb.REL_RECOVER_BORDERO_ID
                               ,R.RE_COVER_ID
                               ,R.START_DATE
                               ,R.P_COVER_ID
                               ,RP.START_DATE AS PACK_START_DATE
                               ,PC.IS_AVTOPROLONGATION
                               ,R.INS_POLICY
                               ,R.BRUTTO_PREMIUM
                           FROM REL_RECOVER_BORDERO rrb
                               ,RE_COVER            r
                               ,RE_BORDERO          RB
                               ,RE_BORDERO_PACKAGE  rp
                               ,P_COVER             pc
                          WHERE rb.re_bordero_id = p_re_bordero_id
                            AND rrb.RE_BORDERO_ID = rb.RE_BORDERO_ID
                            AND rp.RE_BORDERO_PACKAGE_ID = rb.RE_BORDERO_PACKAGE_ID
                            AND r.re_cover_id = rrb.re_cover_id
                            AND pc.p_cover_id = r.p_cover_id
                         -- and R.INS_POLICY = 12378535
                         )
      LOOP
        LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE P_COVER_ID ' || v_re_cover.p_cover_id);
      
        ydatea_new := ADD_MONTHS(v_re_cover.START_DATE, 12);
        --to_date( to_char(v_re_cover.START_DATE,'DD.MM')||'.'|| ( to_char(v_re_cover.START_DATE,'YYYY') +1) , 'DD.MM.YYYY');
      
        IF (nvl(v_re_cover.IS_AVTOPROLONGATION, 0) = 1)
        THEN
        
          v_RE_COMM_RATE := 10;
          LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE AVTOPROLONGATION');
        
        ELSIF (ydatea_new > v_re_cover.PACK_START_DATE)
        THEN
        
          v_RE_COMM_RATE := Pkg_Tariff_Calc.calc_fun(p_brief  => 'Re.StavkaReCom'
                                                    ,p_ent_id => 305
                                                    ,p_obj_id => v_re_cover.p_cover_id);
          LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE Re.StavkaReCom ' || v_RE_COMM_RATE);
        
        ELSE
          LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE Re.StavkaReCom');
          v_RE_COMM_RATE := 0;
        END IF;
      
        v_re_commission := v_re_cover.BRUTTO_PREMIUM * v_RE_COMM_RATE / 100;
      
        UPDATE REL_RECOVER_BORDERO r
           SET r.RE_COMM_RATE  = v_RE_COMM_RATE
              ,R.RE_COMMISSION = v_re_commission
         WHERE r.REL_RECOVER_BORDERO_ID = v_re_cover.REL_RECOVER_BORDERO_ID
           AND r.RE_COVER_ID = v_re_cover.RE_COVER_ID
           AND r.re_bordero_id = p_re_bordero_id;
      END LOOP;
    END;
  
    PROCEDURE CALCURATE_BORDERO_BR IS
      l_period    NUMBER;
      l_re_period NUMBER;
    BEGIN
      LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BR');
      FOR v_re_cover IN (SELECT rrb.REL_RECOVER_BORDERO_ID
                               ,RC.P_ASSET_HEADER_ID
                               ,RRB.RETURNED_PREMIUM
                               ,RC.T_PRODUCT_LINE_ID
                               ,(SELECT MIN(rp2.start_date)
                                   FROM RE_COVER            rc2
                                       ,REL_RECOVER_BORDERO rrb2
                                       ,RE_BORDERO          rb2
                                       ,RE_BORDERO_PACKAGE  rp2
                                  WHERE rc2.P_ASSET_HEADER_ID = RC.P_ASSET_HEADER_ID
                                    AND RC2.T_PRODUCT_LINE_ID = RC.T_PRODUCT_LINE_ID
                                    AND RRB2.RE_COVER_ID = RC2.RE_COVER_ID
                                    AND RRB2.RE_BORDERO_ID = RC2.RE_BORDERO_ID
                                    AND RB2.RE_BORDERO_ID = RRB2.RE_BORDERO_ID
                                    AND RP2.RE_BORDERO_PACKAGE_ID = RB2.RE_BORDERO_PACKAGE_ID
                                    AND RP2.RE_M_CONTRACT_ID = RP.RE_M_CONTRACT_ID) re_start_date
                               ,RP.end_date re_end_date
                               ,(SELECT nvl(SUM(decode(rc2.re_bordero_id
                                                      ,rrb.re_bordero_id
                                                      ,0
                                                      , -- Это то же бордеро. Его не учитываем
                                                       nvl(RRB2.RE_COMMISSION, 0) -
                                                       nvl(RRB2.return_re_commission, 0)))
                                           ,0)
                                   FROM RE_COVER            rc2
                                       ,REL_RECOVER_BORDERO rrb2
                                       ,RE_BORDERO          rb2
                                       ,RE_BORDERO_PACKAGE  rp2
                                  WHERE rc2.P_ASSET_HEADER_ID = RC.P_ASSET_HEADER_ID
                                    AND RC2.T_PRODUCT_LINE_ID = RC.T_PRODUCT_LINE_ID
                                    AND RRB2.RE_COVER_ID = RC2.RE_COVER_ID
                                    AND RRB2.RE_BORDERO_ID = RC2.RE_BORDERO_ID
                                    AND RB2.RE_BORDERO_ID = RRB2.RE_BORDERO_ID
                                    AND RP2.RE_BORDERO_PACKAGE_ID = RB2.RE_BORDERO_PACKAGE_ID
                                    AND RP2.RE_M_CONTRACT_ID = RP.RE_M_CONTRACT_ID) AS RE_COMMISSION
                               ,PC.IS_AVTOPROLONGATION
                               ,RC.RE_COVER_ID
                               ,RC.START_DATE
                               ,RP.START_DATE AS PACK_START_DATE
                               ,PP.END_DATE AS POLICY_END_DATE
                               ,PC.START_DATE AS PC_START_DATE
                               ,PC.END_DATE AS PC_END_DATE
                           FROM RE_COVER            rc
                               ,REL_RECOVER_BORDERO rrb
                               ,P_COVER             pc
                               ,RE_BORDERO          RB
                               ,RE_BORDERO_PACKAGE  rp
                               ,P_POLICY            pp
                               ,AS_ASSET            aa
                          WHERE 1 = 1
                            AND RRB.RE_BORDERO_ID = p_re_bordero_id
                            AND rc.RE_COVER_ID = rrb.RE_COVER_ID
                            AND pc.P_COVER_ID = rc.P_COVER_ID
                            AND RB.RE_BORDERO_ID = RRB.RE_BORDERO_ID
                            AND RP.RE_BORDERO_PACKAGE_ID = RB.RE_BORDERO_PACKAGE_ID
                            AND aa.as_asset_id = pc.as_asset_id
                            AND pp.policy_id = aa.p_policy_id
                         --  and RC.RE_BORDERO_ID = 13032257
                         --and rc.INS_POLICY = 5375380
                         )
      LOOP
      
        IF (nvl(v_re_cover.IS_AVTOPROLONGATION, 0) = 0)
        THEN
          LOG(p_re_bordero_id, 'автопролонгация 0');
          LOG(p_re_bordero_id
             ,'RE_COMMISION_CALCULATE v_re_cover.POLICY_END_DATE ' ||
              to_char(v_re_cover.POLICY_END_DATE, 'dd.mm.yyyy') || ' v_re_cover.PC_START_DATE ' ||
              to_char(v_re_cover.PC_START_DATE, 'dd.mm.yyyy'));
          -- Рассчитываем действие покрытия в днях                 
          l_period := trunc(v_re_cover.POLICY_END_DATE) - trunc(v_re_cover.PC_START_DATE);
          --l_re_period := v_re_cover.RE_END_DATE - v_re_cover.RE_START_DATE;                          
          l_re_period := v_re_cover.PC_END_DATE - v_re_cover.PC_START_DATE;
        
          LOG(p_re_bordero_id
             ,'RE_COMMISION_CALCULATE l_period ' || l_period || ' l_re_period ' || l_re_period);
        
          v_mn1_year := 1 - (l_period) / LEAST(5 * 365.242199, l_re_period);
        
        ELSE
          LOG(p_re_bordero_id, 'автопролонгация 1');
        
          l_period := v_re_cover.POLICY_END_DATE - v_re_cover.PC_START_DATE;
        
          LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE l_period ' || l_period);
        
          --l_re_period := v_re_cover.RE_END_DATE - v_re_cover.RE_START_DATE;                
          v_mn1_year := 1 - (l_period / 365.242199);
        
        END IF;
        LOG(p_re_bordero_id
           ,'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BR v_mn1_year ' || v_mn1_year ||
            ' RE_COMMISSION ' || v_re_cover.RE_COMMISSION);
      
        LOG(p_re_bordero_id
           ,'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BR POLICY_END_DATE ' ||
            v_re_cover.POLICY_END_DATE || ' PC_START_DATE ' || v_re_cover.PC_START_DATE);
      
        UPDATE REL_RECOVER_BORDERO r
           SET R.RETURN_RE_COMMISSION = v_mn1_year * v_re_cover.RE_COMMISSION
         WHERE r.REL_RECOVER_BORDERO_ID = v_re_cover.REL_RECOVER_BORDERO_ID
           AND r.RE_COVER_ID = v_re_cover.RE_COVER_ID
           AND r.re_bordero_id = p_re_bordero_id;
      
      END LOOP;
      LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BR EXIT');
    END;
    --       
    PROCEDURE CALCURATE_BORDERO_BI IS
    BEGIN
      LOG(p_re_bordero_id
         ,'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BI p_re_bordero_id ' || p_re_bordero_id);
      FOR v_re_cover IN (
                         
                         SELECT rrb.REL_RECOVER_BORDERO_ID
                                ,RC.P_ASSET_HEADER_ID
                                ,RRB.RETURNED_PREMIUM
                                ,RC.T_PRODUCT_LINE_ID
                                ,PC.P_COVER_ID
                                ,(SELECT nvl(SUM(decode(rc2.re_bordero_id
                                                       ,rc.re_bordero_id
                                                       ,0
                                                       , -- Это то же бордеро. Его не учитываем
                                                        nvl(RRB2.RE_COMMISSION, 0) -
                                                        nvl(RRB2.return_re_commission, 0)))
                                            ,0)
                                    FROM RE_COVER            rc2
                                        ,REL_RECOVER_BORDERO rrb2
                                        ,RE_BORDERO          rb2
                                        ,RE_BORDERO_PACKAGE  rp2
                                   WHERE rc2.P_ASSET_HEADER_ID = RC.P_ASSET_HEADER_ID
                                     AND RC2.T_PRODUCT_LINE_ID = RC.T_PRODUCT_LINE_ID
                                     AND RRB2.RE_COVER_ID = RC2.RE_COVER_ID
                                     AND RRB2.RE_BORDERO_ID = RC2.RE_BORDERO_ID
                                     AND RB2.RE_BORDERO_ID = RRB2.RE_BORDERO_ID
                                     AND RP2.RE_BORDERO_PACKAGE_ID = RB2.RE_BORDERO_PACKAGE_ID
                                     AND RP2.RE_M_CONTRACT_ID = RP.RE_M_CONTRACT_ID) AS RE_COMMISSION
                                ,PC.IS_AVTOPROLONGATION
                                ,RC.RE_COVER_ID
                                ,RC.START_DATE
                                ,RP.START_DATE AS PACK_START_DATE
                                ,PP.END_DATE AS POLICY_END_DATE
                                ,PC.START_DATE AS PC_START_DATE
                                ,PC.END_DATE AS PC_END_DATE
                           FROM RE_COVER            rc
                                ,REL_RECOVER_BORDERO rrb
                                ,P_COVER             pc
                                ,RE_BORDERO          RB
                                ,RE_BORDERO_PACKAGE  rp
                                ,P_POLICY            pp
                                ,AS_ASSET            aa
                          WHERE 1 = 1
                            AND RRB.RE_BORDERO_ID = p_re_bordero_id
                            AND rc.RE_COVER_ID = rrb.RE_COVER_ID
                            AND pc.P_COVER_ID = rc.P_COVER_ID
                            AND RB.RE_BORDERO_ID = RRB.RE_BORDERO_ID
                            AND RP.RE_BORDERO_PACKAGE_ID = RB.RE_BORDERO_PACKAGE_ID
                            AND aa.as_asset_id = pc.as_asset_id
                            AND pp.policy_id = aa.p_policy_id
                         --                        and RC.RE_BORDERO_ID = 8770373
                         --    and rc.INS_POLICY = 12378535
                         
                         )
      LOOP
        LOG(p_re_bordero_id
           ,'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BI v_re_cover.p_cover_id ' ||
            v_re_cover.p_cover_id);
      
        IF (v_re_cover.RETURNED_PREMIUM > 0)
        THEN
          IF (nvl(v_re_cover.IS_AVTOPROLONGATION, 0) = 0)
          THEN
          
            v_period := ROUND(MONTHS_BETWEEN(v_re_cover.PC_END_DATE, v_re_cover.PC_START_DATE) / 12);
            LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BI v_period ' || v_period);
          
            v_mn1_year := 1 - (v_re_cover.PACK_START_DATE - v_re_cover.START_DATE) / 365.242199 /
                          LEASt(5, v_period);
          
          ELSE
          
            v_mn1_year := 1 - (v_re_cover.PACK_START_DATE - v_re_cover.START_DATE) / 365.242199;
          
          END IF;
        
          UPDATE REL_RECOVER_BORDERO r
             SET R.RETURN_RE_COMMISSION = re_comm_rate / 100 * returned_premium
                ,RE_COMMISSION          = BRUTTO_PREMIUM * re_comm_rate / 100
           WHERE r.REL_RECOVER_BORDERO_ID = v_re_cover.REL_RECOVER_BORDERO_ID
             AND r.RE_COVER_ID = v_re_cover.RE_COVER_ID
             AND r.re_bordero_id = p_re_bordero_id;
        
        END IF;
      END LOOP;
    END;
  BEGIN
    LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE');
  
    SELECT T.SHORT_NAME
      INTO v_bordero_type_id
      FROM RE_BORDERO      r
          ,RE_BORDERO_TYPE t
     WHERE T.RE_BORDERO_TYPE_ID = R.RE_BORDERO_TYPE_ID
       AND R.RE_BORDERO_ID = p_re_bordero_id;
  
    -- для перестраховочной коммисии
  
    --В бордеро первых платежей (БПП), 
    -- в бордеро первых платежей (неподтвержденное) (БППН), 
    --в бордеро последующих платежей (БД) 
    -- и бордеро изменений (БИ).
    IF (v_bordero_type_id IN ('БПП', 'БППН', 'БД', 'БИ'))
    THEN
      LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE CALCURATE_BORDERO');
      calcurate_bordero;
    END IF;
  
    IF (v_bordero_type_id IN ('БР'))
    THEN
      LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BR');
      calcurate_bordero_br;
    END IF;
  
    IF (v_bordero_type_id IN ('БИ'))
    THEN
      LOG(p_re_bordero_id, 'RE_COMMISION_CALCULATE CALCURATE_BORDERO_BI');
      calcurate_bordero_bi;
    END IF;
  
  END;
  --------------------------------------------------------------------------------

  PROCEDURE fill_bordero
  (
    p_pack_id    IN NUMBER
   ,p_bordero_id NUMBER DEFAULT NULL
  ) IS
    v_bord_id         NUMBER;
    v_bord_type       VARCHAR2(50);
    l_bordero_bi_id   NUMBER;
    l_bordero_bpp_id  NUMBER;
    l_bordero_bppn_id NUMBER;
    l_fund_id         NUMBER;
  BEGIN
  
    LOG(p_pack_id, 'FILL_BORDERO P_BORDERO_ID ' || p_bordero_id);
  
    clear_bordero(p_pack_id, p_bordero_id);
  
    FOR cur IN (SELECT b.RE_BORDERO_ID
                      ,bt.BRIEF
                      ,fund_id
                  FROM RE_BORDERO      b
                      ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = NVL(p_bordero_id, b.re_bordero_id)
                   AND b.RE_BORDERO_PACKAGE_ID = p_pack_id
                   AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
                   AND bt.brief = 'БОРДЕРО_ПРЕМИЙ')
    LOOP
    
      LOG(p_pack_id, 'FILL_BORDERO БОРДЕРО_ПРЕМИЙ ');
    
      l_fund_id := cur.fund_id;
      create_bordero_first(cur.re_bordero_id, NULL, 0);
      re_commision_calculate(cur.re_bordero_id);
    
      l_bordero_bi_id := Get_ID_Bordero_BI(p_pack_id, l_fund_id);
      re_commision_calculate(l_bordero_bi_id);
    
    END LOOP;
  
    FOR cur IN (SELECT b.RE_BORDERO_ID
                      ,bt.BRIEF
                      ,fund_id
                  FROM RE_BORDERO      b
                      ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = NVL(p_bordero_id, b.re_bordero_id)
                   AND b.RE_BORDERO_PACKAGE_ID = p_pack_id
                   AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
                   AND bt.brief = 'БОРДЕРО_ПРЕМИЙ_НЕ')
    LOOP
    
      LOG(p_pack_id, 'FILL_BORDERO БОРДЕРО_ПРЕМИЙ_НЕ ');
      create_bordero_first(cur.re_bordero_id, NULL, 1);
      re_commision_calculate(cur.re_bordero_id);
    
    END LOOP;
  
    FOR cur IN (SELECT b.RE_BORDERO_ID
                      ,bt.BRIEF
                      ,fund_id
                  FROM RE_BORDERO      b
                      ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = NVL(p_bordero_id, b.re_bordero_id)
                   AND b.RE_BORDERO_PACKAGE_ID = p_pack_id
                   AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
                   AND bt.brief = 'БОРДЕРО_ИЗМЕН')
    LOOP
      LOG(p_pack_id, 'FILL_BORDERO БОРДЕРО_ИЗМЕН ');
      l_fund_id := cur.fund_id;
    
      create_bordero_bi(cur.re_bordero_id, NULL, 0);
      l_bordero_bpp_id  := Get_ID_Bordero_BPP(p_pack_id, l_fund_id);
      l_bordero_bppn_id := Get_ID_Bordero_BPPN(p_pack_id, l_fund_id);
    
      re_commision_calculate(l_bordero_bpp_id);
      re_commision_calculate(l_bordero_bppn_id);
      re_commision_calculate(cur.re_bordero_id);
    
    END LOOP;
  
    FOR cur IN (SELECT b.RE_BORDERO_ID
                      ,bt.BRIEF
                  FROM RE_BORDERO      b
                      ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = NVL(p_bordero_id, b.re_bordero_id)
                   AND b.RE_BORDERO_PACKAGE_ID = p_pack_id
                   AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
                   AND bt.brief = 'БОРДЕРО_РАСТОРЖЕНИЙ')
    LOOP
      LOG(p_pack_id, 'FILL_BORDERO БОРДЕРО_РАСТОРЖЕНИЙ ');
    
      LOG(p_pack_id, 'FILL_BORDERO БОРДЕРО_РАСТОРЖЕНИЙ');
      create_bordero_rast(cur.re_bordero_id);
      re_commision_calculate(cur.re_bordero_id);
    END LOOP;
  
    FOR cur IN (SELECT b.RE_BORDERO_ID
                      ,bt.BRIEF
                  FROM RE_BORDERO      b
                      ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = NVL(p_bordero_id, b.re_bordero_id)
                   AND b.RE_BORDERO_PACKAGE_ID = p_pack_id
                   AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
                   AND bt.brief = 'БОРДЕРО_ДОПЛАТ')
    LOOP
    
      LOG(p_pack_id, 'FILL_BORDERO БОРДЕРО_ДОПЛАТ ');
      create_bordero_second(cur.re_bordero_id);
    
    --      l_bordero_bpp_id := Get_ID_Bordero_BPP (p_pack_id, l_fund_id);
    --      l_bordero_bppn_id := Get_ID_Bordero_BPPN(p_pack_id, l_fund_id);
    --                                  
    --      re_commision_calculate(l_bordero_bpp_id);
    --      re_commision_calculate(l_bordero_bppn_id);
    --      re_commision_calculate(cur.re_bordero_id);
    
    END LOOP;
  
    FOR cur IN (SELECT b.RE_BORDERO_ID
                      ,bt.BRIEF
                  FROM RE_BORDERO      b
                      ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = NVL(p_bordero_id, b.re_bordero_id)
                   AND b.RE_BORDERO_PACKAGE_ID = p_pack_id
                   AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
                   AND bt.brief = 'БОРДЕРО_ЗАЯВ_УБЫТКОВ')
    LOOP
      LOG(p_pack_id, 'FILL_BORDERO БОРДЕРО_ЗАЯВ_УБЫТКОВ ');
      create_bordero_loss(cur.re_bordero_id, 0);
    END LOOP;
  
    FOR cur IN (SELECT b.RE_BORDERO_ID
                      ,bt.BRIEF
                  FROM RE_BORDERO      b
                      ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = NVL(p_bordero_id, b.re_bordero_id)
                   AND b.RE_BORDERO_PACKAGE_ID = p_pack_id
                   AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
                   AND bt.brief = 'БОРДЕРО_ОПЛ_УБЫТКОВ')
    LOOP
      LOG(p_pack_id, 'FILL_BORDERO БОРДЕРО_ОПЛ_УБЫТКОВ ');
      create_bordero_loss(cur.re_bordero_id, 1);
    END LOOP;
  
    LOG(p_pack_id, 'FILL_BORDERO RETURN');
  
  END fill_bordero;
  --------------------------------------------------------------------------------
  PROCEDURE create_bordero_second(p_bordero_id IN NUMBER) IS
    recalc_flg   NUMBER;
    v_last_id    NUMBER;
    v_cur_nach   NUMBER;
    v_temp_count NUMBER;
  BEGIN
    --очищает предыдущие результаты
    DELETE REL_RECOVER_BORDERO WHERE re_bordero_id = p_bordero_id;
    recalc_flg := 0;
  
    --ищем все рековеры, которые подходят нам по договору.
    --БД может существовать в том же пакете бордеро, что и БПП (и т.п.)
    --т.к. все зависит от наличия платежей
    --проверка на это происходит в процедуре
    --create_rel_recover
    FOR cur IN ( --цикл по recover
                SELECT rc.re_cover_id
                       ,rc.p_cover_id
                       ,rc.T_PRODUCT_LINE_ID
                       ,rc.P_ASSET_HEADER_ID
                  FROM RE_BORDERO         b1
                       ,RE_BORDERO_PACKAGE bp1
                       ,RE_BORDERO_PACKAGE bp2
                       ,RE_BORDERO         b2
                        --, RE_BORDERO_TYPE bt
                       ,RE_COVER rc
                       ,P_POLICY pp
                
                --
                /*          , p_pol_header pph
                , t_payment_terms trm
                , t_product prod*/
                --
                 WHERE b1.re_bordero_id = p_bordero_id ----!!!!!!!
                   AND bp1.re_bordero_package_id = b1.re_bordero_package_id
                   AND bp2.re_contract_id = bp1.re_contract_id
                   AND b2.re_bordero_package_id = bp2.re_bordero_package_id
                   AND b2.fund_id = b1.fund_id
                      --and pp.pol_num = '011972'--
                      --AND bt.re_bordero_type_id = b2.re_bordero_type_id
                   AND rc.re_bordero_id = b2.re_bordero_id
                   AND check_exc(rc.p_cover_id, bp1.re_contract_id) = 0
                   AND pp.POLICY_ID = rc.INS_POLICY
                   AND pp.END_DATE > bp2.START_DATE
                --
                /*          and pph.policy_header_id = pp.pol_header_id
                AND (pph.start_date between to_date('01-01-2006','dd-mm-yyyy') and to_date('31-03-2006','dd-mm-yyyy') 
                     or pph.start_date between to_date('01-01-2007','dd-mm-yyyy') and to_date('31-03-2007','dd-mm-yyyy')
                     or pph.start_date between to_date('01-01-2008','dd-mm-yyyy') and to_date('31-03-2008','dd-mm-yyyy')
                     or pph.start_date between to_date('01-01-2009','dd-mm-yyyy') and to_date('31-03-2009','dd-mm-yyyy'))
                and prod.product_id = pph.product_id
                and prod.description like 'КС CR%'
                and pp.pol_header_id not in (select pst.pol_header_id
                                      from p_policy pst
                                      where ins.doc.get_doc_status_brief(pst.policy_id, to_date('01.01.2010 23:59:59','DD.MM.YYYY hh24:mi:ss')) in ('READY_TO_CANCEL')
                                            and pst.pol_header_id = pp.pol_header_id
                                      )
                and trm.id = pp.payment_term_id
                and trm.description = 'Единовременно'*/
                --
                --AND rc.P_ASSET_HEADER_ID in (292586,293613,316465)
                --  AND pp.POLICY_ID = 6060425
                )
    LOOP
      --цикл по recover
    
      v_temp_count := 1;
    
      --1. проверить на завершение покрытия
      SELECT COUNT(1)
        INTO v_temp_count
        FROM P_COVER     pc
            ,STATUS_HIST sh
       WHERE pc.P_COVER_ID = cur.p_cover_id
         AND sh.STATUS_HIST_ID = pc.STATUS_HIST_ID
         AND sh.BRIEF <> 'DELETED';
    
      recalc_flg := 1;
      BEGIN
        v_cur_nach := pkg_payment.get_charge_cover_amount(cur.p_cover_id).fund_amount;
      EXCEPTION
        WHEN OTHERS THEN
          v_cur_nach := 0;
      END;
      IF v_temp_count > 0
      THEN
        v_last_id := create_rel_recover(cur.re_cover_id, p_bordero_id, v_cur_nach);
      END IF;
    END LOOP; --цикл по recover
  
    --нужно все пересчитать
    IF recalc_flg = 1
    THEN
      recalc_bordero(p_bordero_id);
    END IF;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE create_bordero_rast(p_bordero_id IN NUMBER) IS
    v_re_cover    ven_re_cover%ROWTYPE;
    v_db          DATE;
    v_de          DATE;
    v_fund_id     NUMBER;
    v_contract_id NUMBER;
    v_ver_id      NUMBER; -- версия договора перестрахования
    v_rrb_id      NUMBER;
  
    v_sum_bordero NUMBER;
  
    v_recalc_flg NUMBER;
  
    PROCEDURE CREATE_COVER_LIST IS
    
      l_qty NUMBER;
    
    BEGIN
      DELETE FROM XX_RE_RECALC_COVER;
    
      INSERT INTO XX_RE_RECALC_COVER
        SELECT rc.re_cover_id
              ,pc.P_COVER_ID
              ,pp.decline_date
              ,0
          FROM P_POLICY    pp
              ,AS_ASSET    aa
              ,P_COVER     pc
              ,RE_COVER    rc
              ,RE_BORDERO  b
              ,STATUS_HIST sh
        --, re_bordero_type bt
         WHERE rc.RE_CONTRACT_VER_ID = v_ver_id --отбираем все ДСП по договору
           AND check_exc(pc.p_cover_id, v_ver_id) = 0 --0--нет в исключениях
           AND b.re_bordero_id = rc.re_bordero_id
           AND b.fund_id = v_fund_id --валюта совпадает
           AND pc.P_COVER_ID = rc.P_COVER_ID -- покрытия
           AND aa.AS_ASSET_ID = pc.AS_ASSET_ID
           AND pp.POLICY_ID = aa.P_POLICY_ID -- полисы
              --   AND pp.POLICY_ID = 6060425
              --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Добавлено временно на тест бордеро Marchuk A             
              --AND aa.P_ASSET_HEADER_ID in (292586,293613,316465)
           AND sh.BRIEF = 'DELETED'
              --and pp.pol_header_id = 5049003--
           AND (
               --или договор был расторгнут
                (pp.DECLINE_DATE BETWEEN v_db AND v_de --!!!!!!!!!!!!!!!!!!!!!!!!!
                AND doc.get_doc_status_brief(pp.POLICY_ID) = 'BREAK')
               --или есть покрытия, которые были удалены из полиса
                OR (pc.STATUS_HIST_ID = sh.STATUS_HIST_ID));
    
      SELECT COUNT(1) INTO l_qty FROM XX_RE_RECALC_COVER;
    
      LOG(p_bordero_id
         ,'CREATE_BORDERO_RAST Список покрытий составлен. Число покрытий ' || l_qty);
      UPDATE XX_RE_RECALC_COVER SET is_calc = 1 WHERE check_exc(p_cover_id, v_ver_id) = 1;
    
      SELECT COUNT(1) INTO l_qty FROM XX_RE_RECALC_COVER WHERE is_calc = 0;
      LOG(p_bordero_id
         ,'CREATE_BORDERO_RAST Из списка покрытий удалены исключения. Число покрытий ' || l_qty);
    
    END;
  BEGIN
    LOG(p_bordero_id, 'CREATE_BORDERO_RAST');
  
    v_recalc_flg := 0;
  
    DELETE FROM REL_RECOVER_BORDERO r WHERE r.re_bordero_id = p_bordero_id;
  
    LOG(p_bordero_id, 'CREATE_BORDERO_RAST DELETE SUCCESSFUL');
  
    -- определяем период,за который ищутся расторжения и версию договора облигаторного перестрахования
    SELECT bp.start_date
          ,bp.end_date
          ,b.fund_id
          ,CV.re_main_contract_id
          ,CV.re_contract_version_id
      INTO v_db
          ,v_de
          ,v_fund_id
          ,v_contract_id
          ,v_ver_id
      FROM RE_BORDERO          b
          ,RE_BORDERO_PACKAGE  bp
          ,RE_CONTRACT_VERSION CV
     WHERE b.re_bordero_id = p_bordero_id --!!!!!!!!!!!!!!!!!
       AND bp.re_bordero_package_id = b.re_bordero_package_id
       AND CV.re_contract_version_id = bp.re_contract_id;
  
    LOG(p_bordero_id
       ,'CREATE_BORDERO_RAST v_db ' || v_db || ' v_de ' || v_de || ' v_fund_id ' || v_fund_id ||
        ' v_contract_id ' || v_contract_id || ' ' || v_ver_id);
  
    --нужно отобрать все покрытию, по которым были расторжения, но
    LOG(p_bordero_id, 'CREATE_BORDERO_RAST v_ver_id ' || v_ver_id);
  
    CREATE_COVER_LIST;
    FOR cover IN (SELECT * FROM XX_RE_RECALC_COVER WHERE IS_CALC = 0)
    LOOP
      /*    
          FOR cover IN (--цикл по коверам 1
            SELECT
              rc.re_cover_id
            , pc.P_COVER_ID
            , pp.decline_date
            FROM P_POLICY pp
               , AS_ASSET aa
               , P_COVER pc
               , RE_COVER rc
               , RE_BORDERO b
               , STATUS_HIST sh
               --, re_bordero_type bt
            WHERE rc.RE_CONTRACT_VER_ID = v_ver_id  --отбираем все ДСП по договору
              AND check_exc(pc.p_cover_id,v_ver_id) = 0 --0--нет в исключениях
              AND b.re_bordero_id = rc.re_bordero_id
              AND b.fund_id = v_fund_id --валюта совпадает
              AND pc.P_COVER_ID = rc.P_COVER_ID -- покрытия
              AND aa.AS_ASSET_ID = pc.AS_ASSET_ID
              AND pp.POLICY_ID = aa.P_POLICY_ID -- полисы
              AND sh.BRIEF = 'DELETED'
              --and pp.pol_header_id = 5049003--
              AND (
                --или договор был расторгнут
               (pp.DECLINE_DATE BETWEEN v_db AND v_de --!!!!!!!!!!!!!!!!!!!!!!!!!
                AND doc.get_doc_status_brief(pp.POLICY_ID) = 'BREAK')
                --или есть покрытия, которые были удалены из полиса
              OR (pc.STATUS_HIST_ID = sh.STATUS_HIST_ID)
              )
      
            ) LOOP --цикл по коверам 2
      */
      v_rrb_id := create_rel_recover(cover.re_cover_id, p_bordero_id);
    
      --добавляем исключение
      create_oblig_exc(v_ver_id, cover.p_cover_id, 'CANCEL', p_bordero_id);
    
      v_recalc_flg := 1;
    
    END LOOP; --цикл по коверам 3
  
    IF v_recalc_flg > 0
    THEN
      recalc_bordero(p_bordero_id);
    END IF;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE Build_Cover_List
  (
    p_bordero_id IN NUMBER
   ,p_fund_id    IN NUMBER
   ,p_prior      IN NUMBER
   ,p_date_begin IN DATE
   ,p_date_end   IN DATE
  ) IS
    l_count NUMBER;
  BEGIN
    LOG(p_bordero_id
       ,'BUILD_COVER_LIST p_fund_id ' || p_fund_id || ' p_date_begin ' ||
        to_char(p_date_begin, 'dd.mm.yyyy') || ' p_date_end ' || to_char(p_date_end, 'dd.mm.yyyy'));
    DELETE FROM xx_re_cover;
  
    INSERT INTO XX_RE_COVER
    
      SELECT pl.insurance_group_id --вид страхования
            ,pph.product_id -- продукт
            ,pl.ID                 prod_line_id --страховая программа
            ,ppc.contact_id -- страхователь
            ,pph.policy_header_id -- заголовок договора страхования
            ,pp.policy_id --полис
            ,pp.pol_num
            ,pph.fund_id --валюта ответственности
            ,pph.fund_pay_id --валюта оплаты
            ,pc.p_cover_id
            ,aa.p_asset_header_id --заголовок объекта страхования
            ,pc.start_date
            ,pc.end_date
            ,pc.premium
            ,pc.ins_amount
            ,pc.tariff
            ,pc.ent_id
            ,sh.brief              sh_brief
            ,ll.brief              ll_brief
            ,aa.as_asset_id
        FROM T_PRODUCT_LINE     pl
            ,T_PROD_LINE_OPTION plo
            ,AS_ASSET           aa
            ,P_POLICY           pp
            ,P_POL_HEADER       pph
             --
             /*          , t_payment_terms trm
             , t_product prod*/
             --
            ,T_CONTACT_POL_ROLE cpr
            ,P_POLICY_CONTACT ppc
            ,P_COVER pc
            ,STATUS_HIST sh
            ,T_LOB_LINE ll
            ,(SELECT policy_id
                FROM (SELECT p.version_num m
                            ,p.policy_id
                            ,p.version_num
                        FROM ins.p_policy p
                       WHERE ins.doc.get_doc_status_brief(p.policy_id, p_date_end) NOT IN
                             ('INDEXATING')
                          OR (ins.doc.get_doc_status_brief(p.policy_id, p_date_end) IN ('INDEXATING') AND
                              nvl(ins.pkg_renlife_utils.policy_amount_from_trans(p.policy_id
                                                                                ,21
                                                                                ,p.start_date
                                                                                ,p_date_end)
                                 ,0) > 0))
               WHERE m = version_num) active_policy_on_date
      /*, (select policy_id
      from (select p.version_num m,
                   p.policy_id,
                   p.version_num
            from ins.p_policy p
            where ins.doc.get_doc_status_brief(p.policy_id, to_date('01-01-2010','dd-mm-yyyy')) not in ('STOPED', 'BREAK', 'CANCEL','INDEXATING')
                  or (ins.doc.get_doc_status_brief(p.policy_id,to_date('01-01-2010','dd-mm-yyyy')) in ('INDEXATING')
                      and nvl(ins.pkg_renlife_utils.policy_amount_from_trans(p.policy_id, 21,p.start_date, to_date('01-01-2010','dd-mm-yyyy')),0) > 0)
                      )
      where m = version_num) active_policy_on_date*/
      
       WHERE 1 = 1 --pl.ID = NVL(p_product_line_id, pl.ID)
            --AND pl.insurance_group_id = p_ig_id
         AND plo.product_line_id = pl.ID
            --  and pp.policy_id = 6060425
            --and pp.pol_header_id = 7825547
         AND cpr.brief = 'Страхователь'
         AND ppc.contact_policy_role_id = cpr.ID
            --AND ppc.contact_id = NVL(p_is_id, ppc.contact_id)
         AND pp.policy_id = ppc.policy_id
            --          
         AND pp.policy_id = active_policy_on_date.policy_id
            --        
            --          AND (pp.start_date between p_date_begin and p_date_end 
            --
            /*          AND (pph.start_date between to_date('01-01-2006','dd-mm-yyyy') and to_date('31-03-2006','dd-mm-yyyy') 
                 or pph.start_date between to_date('01-01-2007','dd-mm-yyyy') and to_date('31-03-2007','dd-mm-yyyy')
                 or pph.start_date between to_date('01-01-2008','dd-mm-yyyy') and to_date('31-03-2008','dd-mm-yyyy')
                 or pph.start_date between to_date('01-01-2009','dd-mm-yyyy') and to_date('31-03-2009','dd-mm-yyyy'))
            and prod.product_id = pph.product_id
            and prod.description like 'КС CR%'
            and pp.pol_header_id not in (select pst.pol_header_id
                                  from p_policy pst
                                  where ins.doc.get_doc_status_brief(pst.policy_id, to_date('01.01.2010 23:59:59','DD.MM.YYYY hh24:mi:ss')) in ('READY_TO_CANCEL')
                                        and pst.pol_header_id = pp.pol_header_id
                                  )
            and trm.id = pp.payment_term_id
            and trm.description = 'Единовременно'*/
            --
         AND pph.policy_header_id = pp.pol_header_id
         AND pph.fund_id = p_fund_id
            --AND pph.product_id = NVL(p_product_id, pph.product_id)
         AND aa.p_policy_id = pp.policy_id
         AND pc.as_asset_id = aa.as_asset_id
         AND pc.t_prod_line_option_id = plo.ID
         AND ll.t_lob_line_id = pl.t_lob_line_id
         AND sh.STATUS_HIST_ID = pc.STATUS_HIST_ID;
    --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Добавлено временно на тест бордеро Marchuk A
    --AND aa.P_ASSET_HEADER_ID in (292586,293613,316465);          
    --AND aa.P_ASSET_HEADER_ID = 192086;
    --and sh.BRIEF <> 'DELETED'
    --AND NVL(pc.INS_AMOUNT, 0) >= :p_prior;
  
    --BUILD_COVER_LIST p_fund_id 122 p_date_begin 01.01.2008 p_date_end 31.03.2008
  
    SELECT COUNT(1) INTO l_count FROM xx_re_cover;
    LOG(p_bordero_id, 'BUILD_COVER_LIST ' || l_count);
  
  END;

  FUNCTION Fill_Cover_List
  (
    p_ver_id      IN NUMBER
   ,p_contract_id IN NUMBER
  ) RETURN T_COVER IS
  
    --
    resultset T_COVER;
    --  
    CURSOR C_COVER IS
    
      SELECT insurance_group_id --вид страхования
            ,product_id -- продукт
            ,prod_line_id --страховая программа
            ,contact_id -- страхователь
            ,policy_header_id -- заголовок договора страхования
            ,policy_id --полис
            ,pol_num
            ,fund_id --валюта ответственности
            ,fund_pay_id --валюта оплаты
            ,p_cover_id
            ,p_asset_header_id --заголовок объекта страхования
            ,start_date
            ,end_date
            ,premium
            ,ins_amount
            ,tariff
            ,ent_id
            ,sh_brief
        FROM xx_re_cover rc
       WHERE NOT EXISTS (SELECT 1
                FROM RE_COVER rc2
               WHERE rc2.p_cover_id = rc.p_cover_id
                 AND rc2.re_contract_ver_id = p_ver_id)
            --учитываем исключения
         AND NOT EXISTS (SELECT 1
                FROM RE_CONTRACT_EXC ce
               WHERE ce.re_contract_id = p_contract_id
                 AND ce.p_pol_header_id = rc.policy_header_id
                 AND ce.re_contract_version_id = p_ver_id
                 AND ce.t_product_line_id = rc.PROD_LINE_ID
                 AND ce.p_asset_header_id = rc.p_asset_header_id)
      
      -- Add Marchuk A 2009.10.26                            
      --AND ce.p_cover_id = rc.p_cover_id --Потенциально ошибочно (Каткевич 30/12/10)
      
       ORDER BY p_cover_id;
  
    --  
  BEGIN
    LOG(p_ver_id
       ,'FILL_COVER_LIST Отбор покрытий p_ver_id ' || p_ver_id || ' p_contract_id ' || p_contract_id);
  
    SELECT insurance_group_id --вид страхования
          ,product_id -- продукт
          ,prod_line_id --страховая программа
          ,contact_id -- страхователь
          ,policy_header_id -- заголовок договора страхования
          ,policy_id --полис
          ,pol_num
          ,fund_id --валюта ответственности
          ,fund_pay_id --валюта оплаты
          ,p_cover_id
          ,p_asset_header_id --заголовок объекта страхования
          ,start_date
          ,end_date
          ,premium
          ,ins_amount
          ,tariff
          ,ent_id
          ,sh_brief BULK COLLECT
      INTO resultset
      FROM xx_re_cover rc
     WHERE NOT EXISTS (SELECT 1
              FROM RE_COVER rc2
             WHERE rc2.p_cover_id = rc.p_cover_id
               AND rc2.re_contract_ver_id = p_ver_id)
          --учитываем исключения
       AND NOT EXISTS (SELECT 1
              FROM RE_CONTRACT_EXC ce
             WHERE ce.re_contract_id = p_contract_id
               AND ce.p_pol_header_id = rc.policy_header_id
               AND ce.re_contract_version_id = p_ver_id
               AND ce.t_product_line_id = rc.PROD_LINE_ID
               AND ce.p_asset_header_id = rc.p_asset_header_id);
  
    /*  OPEN C_COVER;
    FETCH C_COVER BULK COLLECT INTO resultset;
    CLOSE C_COVER; */
  
    LOG(p_ver_id, 'FILL_COVER_LIST Отобрано покрытий ' || resultset.count);
  
    RETURN resultset;
  END;

  FUNCTION Filter_Cover_List
  (
    p_product_line_id IN NUMBER
   ,p_product_id      IN NUMBER
   ,p_ig_id           IN NUMBER
   ,p_is_id           IN NUMBER
  ) RETURN T_COVER IS
  
    --
    RESULT         T_COVER;
    l_index        NUMBER DEFAULT 1;
    l_index_del_id NUMBER;
  
  BEGIN
  
    LOG(p_product_line_id
       ,'FILTER_Cover_List p_product_line_id ' || p_product_line_id || ' p_product_id ' ||
        p_product_id || ' p_ig_id ' || p_ig_id || ' p_is_id ' || p_is_id);
  
    FOR i IN 1 .. recordset.count
    LOOP
      IF recordset(i)
       .prod_line_id = nvl(p_product_line_id, recordset(i).prod_line_id)
          AND recordset(i).insurance_group_id = nvl(p_ig_id, recordset(i).insurance_group_id)
          AND recordset(i).contact_id = nvl(p_is_id, recordset(i).contact_id)
          AND recordset(i).product_id = nvl(p_product_id, recordset(i).product_id)
      THEN
      
        RESULT(l_index).insurance_group_id := recordset(i).insurance_group_id;
        RESULT(l_index).product_id := recordset(i).product_id;
        RESULT(l_index).prod_line_id := recordset(i).prod_line_id;
        RESULT(l_index).contact_id := recordset(i).contact_id;
        RESULT(l_index).policy_header_id := recordset(i).policy_header_id;
        RESULT(l_index).policy_id := recordset(i).policy_id;
        RESULT(l_index).pol_num := recordset(i).pol_num;
        RESULT(l_index).fund_id := recordset(i).fund_id;
        RESULT(l_index).fund_pay_id := recordset(i).fund_pay_id;
        RESULT(l_index).p_cover_id := recordset(i).p_cover_id;
        RESULT(l_index).p_asset_header_id := recordset(i).p_asset_header_id;
        RESULT(l_index).start_date := recordset(i).start_date;
        RESULT(l_index).end_date := recordset(i).end_date;
        RESULT(l_index).premium := recordset(i).premium;
        RESULT(l_index).ins_amount := recordset(i).ins_amount;
        RESULT(l_index).tariff := recordset(i).tariff;
        RESULT(l_index).ent_id := recordset(i).ent_id;
        RESULT(l_index).sh_brief := recordset(i).sh_brief;
      
        l_index := l_index + 1;
        --recordset.delete (i);
      END IF;
    
    END LOOP;
  
    LOG(p_product_line_id, 'FILTER_Cover_List Найдено покрытий ' || result.count);
  
    RETURN RESULT;
  END;
  --------------------------------------------------------------------------------

  /*
    Байтин А.
    Копирование пакета бордеро
    par_bordero_package_id - ID источника
    par_is_inclusion_package - True - создание пакета заключения
                             - False - обычное копирование
    
  */
  PROCEDURE copy_bordero_pack
  (
    par_bordero_pack_id     NUMBER
   ,par_is_inclusion_pack   NUMBER DEFAULT 0
   ,par_new_bordero_pack_id OUT NUMBER
  ) IS
    v_source_pack_id re_bordero_package.re_bordero_package_id%TYPE;
  BEGIN
    SELECT sq_re_bordero_package.nextval INTO par_new_bordero_pack_id FROM dual;
    IF par_is_inclusion_pack = 1
    THEN
      /*
         Пакет включения должен иметь те же атрибуты, что и самый первый пакет бордеро
         для перестраховочного договора, так как все скорректированные интервалы должны попадать
         в самый первый пакет бордеро
      */
      BEGIN
        SELECT re_bordero_package_id
          INTO v_source_pack_id
          FROM (SELECT bp_f.re_bordero_package_id
                  FROM re_bordero_package bp
                      ,re_bordero_package bp_f
                 WHERE bp.re_bordero_package_id = par_bordero_pack_id
                   AND bp.re_m_contract_id = bp_f.re_m_contract_id
                 ORDER BY bp_f.start_date)
         WHERE rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          raise_application_error(-20001
                                 ,'Не найден пакет бордеро, на основании которого должно производиться копирование');
      END;
    ELSE
      v_source_pack_id := par_bordero_pack_id;
    END IF;
  
    INSERT INTO ven_re_bordero_package
      (re_bordero_package_id
      ,note
      ,num
      ,reg_date
      ,accept_date
      ,assignor_id
      ,end_date
      ,first_pay_day
      ,first_ret_pay_day
      ,fund_pay_id
      ,is_inclusion_package
      ,is_nach
      ,nach_date
      ,payment_ret_term_id
      ,payment_term_id
      ,reinsurer_id
      ,re_contract_id
      ,re_m_contract_id
      ,start_date
      ,summ
      ,summ_in
      ,summ_out)
      SELECT par_new_bordero_pack_id
            ,note
            ,num
            ,reg_date
            ,accept_date
            ,assignor_id
            ,end_date
            ,first_pay_day
            ,first_ret_pay_day
            ,fund_pay_id
            ,CASE par_is_inclusion_pack
               WHEN 0 THEN
                is_inclusion_package
               ELSE
                par_is_inclusion_pack
             END
            ,is_nach
            ,nach_date
            ,payment_ret_term_id
            ,payment_term_id
            ,reinsurer_id
            ,re_contract_id
            ,re_m_contract_id
            ,start_date
            ,summ
            ,summ_in
            ,summ_out
        FROM ven_re_bordero_package bp
       WHERE bp.re_bordero_package_id = v_source_pack_id;
  
    doc.set_doc_status(p_doc_id => par_new_bordero_pack_id, p_status_brief => 'PROJECT');
  
  END copy_bordero_pack;

  PROCEDURE create_bordero_first
  (
    p_bordero_id IN NUMBER
   ,p_retr       IN NUMBER DEFAULT 0
   ,p_opt        IN NUMBER DEFAULT 0
  ) IS
    resultset T_COVER;
    --    
    v_re_cover      RE_COVER%ROWTYPE;
    v_re_line_cover RE_LINE_COVER%ROWTYPE;
    v_db            DATE; --дата начала
    v_de            DATE; --дата окончания
    v_fund_id       NUMBER; -- валюта бордеро
    v_contract_id   NUMBER; --договор перестрахования
    v_ver_id        NUMBER; -- версия договора перестрахования
  
    other_partsum NUMBER := 0; -- колическто денег переданное по другим договорам перестрахования
    our_partsum   NUMBER; -- оставшаяся сумма
    v_prev_val    NUMBER;
    v_total_val   NUMBER;
    v_cur_sum     NUMBER;
  
    v_temp_count NUMBER;
    v_skip_flg   NUMBER; -- 0 указывает, что данный риск то, что ищем
    -- 1 не прошел фильтр по агентам или нет денег
    -- 2 не прошел ограничение на лимиты
    -- 3 не прошел ограничение на коэффициенты
    -- 4 p_cover попадает в бордеро изменений
    -- 5 уже все отдано по другим договорам страхования
    -- 6 попал в бордеро изменений для бордеро неподтвержденных
    -- 7 расторгнутый договор
    -- 8 риск удален из договора еще не перестрахованного или расторгнут
    v_recalc_flg NUMBER; -- 1 - нужно пересчитать бордеро
    -- 0 - не нужно
    v_bordero_id      NUMBER;
    v_bordero1_id     NUMBER;
    v_bordero2_id     NUMBER;
    v_bordero3_id     NUMBER;
    v_bordero_pack_id NUMBER;
  
    v_rel_recover_bordero_id NUMBER;
    v_cur_nach_premium       NUMBER;
  
    v_prior NUMBER; -- значение приоритета для эксцедента
  
    PROCEDURE Bordero_First_Payment
    (
      p_bordero_pack_id IN NUMBER
     ,p_fund_id         IN NUMBER
    ) IS
    BEGIN
      v_bordero1_id := p_bordero_id;
    
      v_bordero2_id := Get_ID_Bordero_BPPN(p_bordero_pack_id, p_fund_id);
    
      DELETE RE_COVER WHERE re_bordero_id = v_bordero2_id;
    
      UPDATE RE_BORDERO r
         SET r.netto_premium  = 0
            ,r.commission     = 0
            ,r.brutto_premium = 0
            ,r.return_sum     = 0
            ,r.payment_sum    = 0
            ,r.declared_sum   = 0
            ,r.is_calc        = 1
       WHERE r.re_bordero_id = v_bordero2_id;
    
      -- Получение ИД Бордеро БИ      
      v_bordero3_id := Get_ID_Bordero_BI(p_bordero_pack_id, p_fund_id);
    
      DELETE RE_COVER WHERE re_bordero_id = v_bordero3_id;
    
      UPDATE RE_BORDERO r
         SET r.netto_premium  = 0
            ,r.commission     = 0
            ,r.brutto_premium = 0
            ,r.return_sum     = 0
            ,r.payment_sum    = 0
            ,r.declared_sum   = 0
            ,r.is_calc        = 1
       WHERE r.re_bordero_id = v_bordero3_id;
    
    END;
  
    -- START CREATE_BORDERO_FIRST
  BEGIN
    LOG(p_bordero_id, 'CREATE_BORDERO_FIRST');
  
    -- ШАГ 1
    -- определяем период,за который ищутся начисления и версию договора облигаторного перестрахования
    SELECT bp.start_date
          ,bp.end_date
          ,b.fund_id
          ,CV.re_main_contract_id
          ,CV.re_contract_version_id
          ,bp.RE_BORDERO_PACKAGE_ID
      INTO v_db
          ,v_de
          ,v_fund_id
          ,v_contract_id
          , -- заголовок обл договора перестрахования
           v_ver_id
          , -- версия обл договора перестрахования, по которому сформирован пакет бордеро
           v_bordero_pack_id
      FROM RE_BORDERO          b
          ,RE_BORDERO_PACKAGE  bp
          ,RE_CONTRACT_VERSION CV
     WHERE b.re_bordero_id = p_bordero_id
       AND bp.re_bordero_package_id = b.re_bordero_package_id
       AND CV.re_contract_version_id = bp.re_contract_id;
  
    LOG(p_bordero_id, 'CREATE_BORDERO_FIRST p_opt ' || p_opt || ' p_retr ' || p_retr);
  
    IF p_opt IN (0, 1, 2)
    THEN
      -- очищаем содержимое бордеро ( если оно конечно уже есть)
      DELETE FROM RE_COVER r
       WHERE r.re_bordero_id = p_bordero_id
            --2009.11.08 Add by Service
            -- При удалении и пересчете БП необходимо оставлять строки, которые используются для хранения данных по БР               
         AND EXISTS (SELECT 1
                FROM REL_RECOVER_BORDERO rr
               WHERE rr.re_cover_id = r.re_cover_id
                 AND rr.re_bordero_id = r.re_bordero_id);
      --для эксцедента мы этого не делаем
    END IF;
  
    IF p_opt = 0
    THEN
      --это бордеро ПП поэтому нужно заполнять сразу 3 бордеро
      Bordero_First_Payment(v_bordero_pack_id, v_fund_id);
    END IF;
  
    UPDATE RE_BORDERO r
       SET r.netto_premium  = 0
          ,r.commission     = 0
          ,r.brutto_premium = 0
          ,r.return_sum     = 0
          ,r.payment_sum    = 0
          ,r.declared_sum   = 0
          ,r.is_calc        = 1
     WHERE r.re_bordero_id = p_bordero_id;
  
    Build_Cover_List(p_bordero_id, v_fund_id, v_prior, v_db, v_de);
  
    recordset := Fill_Cover_List(v_ver_id, v_contract_id);
  
    -- ШАГ 2
    -- получаем список фильтров
    FOR FILTER IN (SELECT v.re_cond_filter_obl_id f_id
                         ,v.insurance_group_id    ig_id
                         ,v.product_id            pr_id
                         ,v.product_line_id       pl_id
                         ,v.agent_id              ag_id
                         ,v.issuer_id             is_id
                     FROM RE_COND_FILTER_OBL v
                    WHERE v.re_contract_ver_id = v_ver_id
                   
                   )
    LOOP
      --цикл по filter
    
      --для эксцедента фильтром также является приоритет
      IF p_opt = 3
      THEN
        SELECT lc.LIMIT
          INTO v_prior
          FROM RE_LINE_CONTRACT lc
         WHERE lc.LINE_NUMBER = 1
           AND lc.RE_COND_FILTER_OBL_ID = FILTER.f_id
           AND lc.fund_id = v_fund_id;
      ELSE
        v_prior := 0;
      END IF;
    
      LOG(p_bordero_id
         ,'CREATE_BORDERO_FIRST Поиск покрытий ... v_de ' || to_char(v_de, 'dd.mm.yyyy') ||
          ' FILTER.pl_id ' || FILTER.pl_id || ' FILTER.ig_id ' || FILTER.ig_id || ' FILTER.is_id ' ||
          FILTER.is_id || ' v_prior ' || v_prior || ' v_contract_id ' || v_contract_id ||
          ' v_ver_id ' || v_ver_id || ' FILTER.pr_id ' || FILTER.pr_id || ' v_db ' ||
          to_char(v_db, 'dd.mm.yyyy'));
    
      -- ШАГ 3 отбираем риски прямого страхования, удовлетворяющие фильтру
    
      resultset := Filter_Cover_List(FILTER.pl_id, FILTER.pr_id, FILTER.ig_id, FILTER.is_id);
    
      LOG(p_bordero_id
         ,'CREATE_BORDERO_FIRST Найдено ' || RESULTSET.count || ' покрытий');
    
      FOR i IN 1 .. RESULTSET.count
      LOOP
        LOG(p_bordero_id, 'CREATE_BORDERO_FIRST Покрытие ' || RESULTSET(i).p_cover_id);
      
        /*
              (
                SELECT * FROM (
                
                SELECT
                    pl.insurance_group_id --вид страхования
                  , pph.product_id -- продукт
                  , pl.ID prod_line_id--страховая программа
                  , ppc.contact_id -- страхователь
                  , pph.policy_header_id -- заголовок договора страхования
                  , pp.policy_id --полис
                  , pp.pol_num
                  , pph.fund_id --валюта ответственности
                  , pph.fund_pay_id --валюта оплаты
                  , pc.p_cover_id
                  , aa.p_asset_header_id --заголовок объекта страхования
                  , pc.start_date
                  , pc.end_date
                  , pc.premium
                  , pc.ins_amount
                  , pc.tariff
                  , pc.ent_id
                  , sh.brief sh_brief
                  FROM
                    T_PRODUCT_LINE pl
                  , T_PROD_LINE_OPTION plo
                  , AS_ASSET aa
                  , P_POLICY pp
                  , P_POL_HEADER pph
                  , T_CONTACT_POL_ROLE cpr
                  , P_POLICY_CONTACT ppc
                  , P_COVER pc
                  , STATUS_HIST sh
                  ,  (select policy_id
                         from (select p.version_num m,
                                      p.policy_id,
                                      p.version_num
                               from ins.p_policy p
                               where ins.doc.get_doc_status_brief(p.policy_id, v_de) not in ('INDEXATING')
                                     or (ins.doc.get_doc_status_brief(p.policy_id, v_de) in ('INDEXATING')
                                         and nvl(ins.pkg_renlife_utils.policy_amount_from_trans(p.policy_id,21,p.start_date,v_de),0) > 0)
                                         )
                         where m = version_num) active_policy_on_date
                  WHERE pl.ID = NVL(FILTER.pl_id, pl.ID)
                  AND pl.insurance_group_id = FILTER.ig_id
                  AND plo.product_line_id = pl.ID
                  --and pp.policy_id = 8712956--
                  --and pp.pol_header_id = 7825547
                  --and pc.p_cover_id in (811479,590218,681448,590218)
                  AND cpr.brief = 'Страхователь'
                  AND ppc.contact_policy_role_id = cpr.ID
                  AND ppc.contact_id = NVL(FILTER.is_id, ppc.contact_id)
                  AND pp.policy_id = ppc.policy_id
                  
                  and pp.policy_id = active_policy_on_date.policy_id
                  
                  AND v_db <= pp.start_date
                  AND v_de >= pp.start_date
                  AND pph.policy_header_id = pp.pol_header_id
                  AND pph.fund_id = v_fund_id
                  AND pph.product_id = NVL(FILTER.pr_id, pph.product_id)
                  AND aa.p_policy_id = pp.policy_id
                  AND pc.as_asset_id = aa.as_asset_id
                  AND pc.t_prod_line_option_id = plo.ID
                  AND sh.STATUS_HIST_ID = pc.STATUS_HIST_ID
        --!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Добавлено временно на тест бордеро Marchuk A          
                  AND pc.p_cover_id in (811479, 811479, 681448, 590218)
                  --and sh.BRIEF <> 'DELETED'
                  AND NVL(pc.INS_AMOUNT,0) >= v_prior
                  AND NOT EXISTS (SELECT 1
                                  FROM RE_COVER rc
                                  WHERE rc.p_cover_id = pc.p_cover_id
                                    AND rc.re_contract_ver_id = v_ver_id
                                  )
                  --учитываем исключения
                  AND NOT EXISTS (SELECT 1
                                  FROM RE_CONTRACT_EXC ce
                                  WHERE ce.re_contract_id = v_contract_id
                                    AND ce.p_pol_header_id = pph.policy_header_id
                                    AND ce.re_contract_version_id = v_ver_id
                                    AND ce.t_product_line_id = pl.ID
                                    AND ce.p_asset_header_id = aa.p_asset_header_id
                                  )
                                  
                ) ORDER BY p_cover_id
                ) LOOP --цикл по p_cover
        */
      
        BEGIN
          v_cur_nach_premium := pkg_payment.get_charge_cover_amount(resultset(i).p_cover_id)
                                .fund_amount;
          --v_cur_nach_premium := 105;
        EXCEPTION
          WHEN OTHERS THEN
            v_cur_nach_premium := 0;
        END;
      
        LOG(p_bordero_id, 'CREATE_BORDERO_FIRST v_cur_nach_premium ' || v_cur_nach_premium);
      
        IF v_cur_nach_premium > 0
        THEN
          v_skip_flg := 0;
        ELSE
          v_skip_flg := 1;
        END IF;
      
        LOG(p_bordero_id, 'CREATE_BORDERO_FIRST v_skip_flg ' || v_skip_flg);
      
        --v_skip_flg:=0;
      
        -- в том случае, если в фильтре есть агенты, то это нужно учесть
        IF FILTER.ag_id IS NOT NULL
           AND v_skip_flg = 0
        THEN
          SELECT DECODE(COUNT(1), 0, 1, 0)
            INTO v_skip_flg
            FROM P_POLICY_AGENT      ppa
                ,AG_CONTRACT_HEADER  ch
                ,POLICY_AGENT_STATUS pas
           WHERE ppa.policy_header_id = resultset(i).policy_header_id --заголовок полиса из фильтра
             AND ch.ag_contract_header_id = ppa.ag_contract_header_id
             AND pas.policy_agent_status_id = ppa.status_id
             AND pas.brief NOT IN ('NEW')
             AND ch.agent_id = FILTER.ag_id
             AND (ppa.date_start <= v_de AND ppa.date_end > v_de OR
                 ppa.date_end > v_db AND ppa.date_start <= v_db);
        END IF;
      
        LOG(p_bordero_id
           ,'CREATE_BORDERO_FIRST Фильтр по агентам v_skip_flg ' || v_skip_flg);
      
        IF v_skip_flg = 0
        THEN
          -- ШАГ 4 проверка на превышение
        
          FOR lim IN ( --курсор по лимитам
                      SELECT *
                        FROM RE_LIMIT_CONTRACT
                       WHERE re_contract_version_id = v_ver_id
                         AND t_product_line_id = resultset(i).prod_line_id
                         AND fund_id = resultset(i).fund_id
                         AND LIMIT < resultset(i).ins_amount --сразу проверка на лимиты
                      )
          LOOP
            --курсор по лимитам
            --если оказались здесь значит нашли риск сверх лимита
            v_skip_flg := 2;
            EXIT;
          END LOOP; --курсор по лимитам
        END IF;
      
        LOG(p_bordero_id
           ,'CREATE_BORDERO_FIRST Фильтр по превышениям v_skip_flg ' || v_skip_flg);
      
        IF v_skip_flg = 0
        THEN
          --проверяем на возможное изменение p_cover (изменение условий договора)
          FOR cur_old IN (SELECT rc.p_cover_id
                          --into v_temp_count
                            FROM RE_COVER rc
                           WHERE rc.p_asset_header_id = resultset(i).p_asset_header_id
                             AND rc.t_product_line_id = resultset(i).prod_line_id
                             AND rc.re_contract_ver_id = v_ver_id
                             AND rc.p_cover_id < resultset(i).p_cover_id --новая версия более поздняя
                          )
          LOOP
            v_skip_flg := 4;
          
            --проверить на расторжение
            IF doc.GET_LAST_DOC_STATUS_BRIEF(resultset(i).policy_id) = 'BREAK'
            THEN
              v_skip_flg := 7;
            ELSIF resultset(i).sh_brief = 'DELETED'
            THEN
              v_skip_flg := 7;
            END IF;
          
            EXIT;
          END LOOP;
        
          LOG(p_bordero_id
             ,'CREATE_BORDERO_FIRST Проверяем на возможное изменение p_cover  v_skip_flg ' ||
              v_skip_flg);
        
          --если это не изменения, то удаленные риски учитывать не надо
          IF v_skip_flg NOT IN (4, 7)
             AND (resultset(i).sh_brief = 'DELETED' OR
              doc.GET_LAST_DOC_STATUS_BRIEF(resultset(i).policy_id) = 'BREAK')
          THEN
            v_skip_flg := 8;
          END IF;
        
          LOG(p_bordero_id
             ,'CREATE_BORDERO_FIRST Если это не изменения, то удаленные риски учитывать не надо v_skip_flg ' ||
              v_skip_flg);
        
        END IF; --v_skip_flg = 0
      
        IF v_skip_flg IN (0, 2, 4)
        THEN
          -- определяем сколько страховой суммы мы передали
          -- по другим договорам перестрахования по нашему п_каверу
          SELECT NVL(SUM(rc.part_sum), 0)
            INTO other_partsum
            FROM RE_COVER rc
           WHERE rc.p_cover_id = resultset(i).p_cover_id
             AND rc.fund_id = resultset(i).fund_id;
          our_partsum := NVL(resultset(i).ins_amount, 0) - other_partsum; --текущий остаток от ответственности
          LOG(p_bordero_id
             ,'CREATE_BORDERO_FIRST Определяем сколько страховой суммы мы передали по другим договорам перестрахования по нашему п_каверу our_partsum ' ||
              our_partsum);
        
          IF our_partsum <= 0
          THEN
            -- все отдали
            v_skip_flg := 5;
          END IF;
        END IF;
      
        LOG(p_bordero_id
           ,'CREATE_BORDERO_FIRST Проверка сколько стр. суммы было передано v_skip_flg ' ||
            v_skip_flg || ' p_opt ' || p_opt);
      
        /* было
        IF (v_skip_flg = 0 AND p_opt = 0)  -- бордеро первых платежей
        OR (v_skip_flg = 2 AND p_opt = 1)  -- бордеро неподтвержденных рисков
        OR (v_skip_flg = 4 and p_opt = 2)  -- бордеро изменений
        OR (v_skip_flg = 0 and p_opt = 3)  -- бордеро эксцедента
        OR (v_skip_flg = 4 and p_opt = 3)  -- бордеро эксцедента (изменение)
        THEN*/
        IF (v_skip_flg IN (0, 2, 4, 7) AND p_opt = 0)
           OR (v_skip_flg IN (0, 4) AND p_opt = 3)
        THEN
        
          IF p_opt = 0
          THEN
            CASE v_skip_flg
              WHEN 0 THEN
                v_bordero_id := v_bordero1_id;
              WHEN 2 THEN
                v_bordero_id := v_bordero2_id;
              WHEN 4 THEN
                v_bordero_id := v_bordero3_id;
              WHEN 7 THEN
                --этот рековер нужно создать для расторжения
                v_bordero_id := p_bordero_id;
            END CASE;
          ELSE
            v_bordero_id := p_bordero_id;
          END IF;
        
          LOG(p_bordero_id
             ,'CREATE_BORDERO_FIRST v_skip_flg ' || v_skip_flg || ' v_bordero_id ' || v_bordero_id);
        
          IF p_opt <> 3
          THEN
            --нужно проверить
            --есть ли другие p_cover`ы из этого полиса в бордеро БППН
            SELECT COUNT(1)
              INTO v_temp_count
              FROM RE_COVER rc
             WHERE rc.ins_policy = resultset(i).policy_id
               AND rc.re_bordero_id = v_bordero2_id
               AND rc.p_cover_id <> resultset(i).p_cover_id;
          
            LOG(p_bordero_id, 'CREATE_BORDERO_FIRST v_temp_count ' || v_temp_count);
          
            IF v_temp_count > 0
            THEN
              --такие покрытия есть
              --значит и это покрытие должно попасть туда же
              v_bordero_id := v_bordero2_id;
            END IF;
          END IF;
        
          v_recalc_flg := 1; -- нужно будет пересчитать пакет
        
          LOG(p_bordero_id
             , 'CREATE_BORDERO_FIRST Создание новой записи create_re_cover p_cover_id ' || resultset(i)
              .p_cover_id);
        
          v_re_cover.re_cover_id := create_re_cover(resultset(i).p_cover_id
                                                   ,0
                                                   ,v_bordero_id
                                                   ,FILTER.f_id);
        
          LOG(p_bordero_id, 'CREATE_BORDERO_FIRST v_re_cover.re_cover_id ' || v_re_cover.re_cover_id);
        
          --если это БППН, то тогда нужно все другие покрытия из этого полиса, 
          --находящиеся в БПП запихнуть в БППН
          IF v_skip_flg = 2
             AND p_opt = 0
          THEN
          
            UPDATE RE_COVER
               SET re_bordero_id = v_bordero2_id
             WHERE ins_policy = resultset(i).policy_id
               AND re_bordero_id = v_bordero1_id
               AND p_cover_id <> resultset(i).p_cover_id;
          
            UPDATE REL_RECOVER_BORDERO
               SET re_bordero_id = v_bordero2_id
             WHERE re_bordero_id = v_bordero1_id
               AND re_cover_id IN (SELECT re_cover_id
                                     FROM RE_COVER
                                    WHERE ins_policy = resultset(i).policy_id
                                      AND re_bordero_id = v_bordero2_id);
          
          END IF;
        
          IF p_opt = 0
             AND v_skip_flg = 7
          THEN
            -- эти риски должны будут попасть в бордеро расторжений
            -- но при этом не должно влиять на суммы перестрахования
            UPDATE RE_COVER
               SET brutto_premium = 0
                  ,commission     = 0
                  ,netto_premium  = 0
             WHERE re_cover_id = v_re_cover.re_cover_id;
          END IF;
        
          IF p_opt = 0
             AND v_skip_flg IN (0, 2)
          THEN
            --БПП и БППН
          
            v_rel_recover_bordero_id := create_rel_recover(v_re_cover.re_cover_id
                                                          ,v_bordero_id
                                                          ,v_cur_nach_premium);
          ELSIF p_opt = 0
                AND v_skip_flg = 4
          THEN
            LOG(p_bordero_id, 'CREATE_BORDERO_FIRST p_opt = 0 AND v_skip_flg = 4 ');
          
            --БИ
            --в том случае, если версия полиса - автопролонгация
            --и по всем покрытиям НЕ было изменений, то нужно 
            --создать только re_cover
            BEGIN
            
              SELECT SUM(flg_change)
                INTO v_temp_count
                FROM (SELECT NVL(pcla.IS_INS_AMOUNT_CHANGE, 0) + NVL(pcla.IS_FEE_CHANGE, 0) +
                             NVL(pcla.IS_ASSURED_CHANGE, 0) + NVL(pcla.IS_PERIOD_CHANGE, 0) flg_change
                            ,ppat.P_POLICY_ID p_policy_id
                        FROM P_POL_ADDENDUM_TYPE ppat
                            ,T_ADDENDUM_TYPE     tat
                            ,AS_ASSET            aa
                            ,P_COVER             pc
                            ,V_P_COVER_LIFE_ADD  pcla
                       WHERE ppat.P_POLICY_ID = resultset(i).policy_id
                         AND ppat.T_ADDENDUM_TYPE_ID = tat.T_ADDENDUM_TYPE_ID
                         AND tat.brief = 'Автопролонгация'
                         AND aa.P_POLICY_ID = ppat.P_POLICY_ID
                         AND pc.AS_ASSET_ID = aa.AS_ASSET_ID
                         AND pcla.P_COVER_ID_CURR = pc.P_COVER_ID)
               GROUP BY p_policy_id;
            
              LOG(p_bordero_id, 'CREATE_BORDERO_FIRST v_temp_count ' || v_temp_count);
            
              IF v_temp_count > 0
              THEN
                v_temp_count := 2;
              END IF;
              IF v_temp_count IS NULL
              THEN
                v_temp_count := 1;
              END IF;
              --if v_temp_count > 0 значит есть изменения
              --иначе - это просто автопролонгация, т.е. создавать 
              --rel_recover_bordero не надо.
            EXCEPTION
              WHEN OTHERS THEN
                -- не нашли ничего => это не автопролонгация
                v_temp_count := 1;
            END;
          
            LOG(p_bordero_id, 'CREATE_BORDERO_FIRST v_temp_count ' || v_temp_count);
          
            --в итоге возможны варианты
            --v_temp_count = 0 - это автопролонгация без изменений
            --v_temp_count = 1 - не нашли автопролонгацию
            --v_temp_count = 2 - это автопролонгация с изменениями
            --если 1 и 2 то были изменения => формируем привязку БИ
          
            -- в том случае, есил v_temp_count = 1, то это означает, что
            -- у нас есть новый п_ковер, возможно измененный. В этом случае 
            -- нужно реализовать следующий алгоритм
            -- Если в страховую годовщину было сделано дополнительное соглашение на добавление в
            -- договор нового риска (рисков), то этот риск (риски) должен попадать в БПП, 
            -- а все остальные риски в БД.
            IF v_temp_count = 1
            THEN
              BEGIN
                SELECT SUM(flg_change)
                  INTO v_temp_count
                  FROM (SELECT NVL(pcla.IS_INS_AMOUNT_CHANGE, 0) + NVL(pcla.IS_FEE_CHANGE, 0) +
                               NVL(pcla.IS_ASSURED_CHANGE, 0) + NVL(pcla.IS_PERIOD_CHANGE, 0) flg_change
                              ,aa.P_POLICY_ID p_policy_id
                          FROM AS_ASSET           aa
                              ,P_COVER            pc
                              ,V_P_COVER_LIFE_ADD pcla
                         WHERE aa.P_POLICY_ID = resultset(i).policy_id
                           AND pc.AS_ASSET_ID = aa.AS_ASSET_ID
                           AND pcla.P_COVER_ID_CURR = pc.P_COVER_ID)
                 GROUP BY p_policy_id;
                --если v_temp_count = 0, то это означает, что изменений не было
                --в противном случае - создание привязки
              EXCEPTION
                WHEN OTHERS THEN
                  --ничего не нашли, тогда все без изменений
                  v_temp_count := 1;
              END;
            END IF;
          
            IF v_temp_count > 0
            THEN
              --нужно создать запись для БИ
            
              LOG(p_bordero_id
                 ,'CREATE_BORDERO_FIRST Нужно создать запись для БИ ');
              v_rel_recover_bordero_id := create_rel_recover(v_re_cover.re_cover_id
                                                            ,v_bordero_id
                                                            ,v_cur_nach_premium);
            END IF;
          
            --нужно запихнуть исключения по старым покрытиям
            --в любом случае, чтобы этот п-ковер больше не учитывать
            FOR cur_old IN (SELECT rc.p_cover_id
                                  ,rc.re_cover_id
                              FROM RE_COVER rc
                             WHERE rc.p_asset_header_id = resultset(i).p_asset_header_id
                               AND rc.t_product_line_id = resultset(i).prod_line_id
                               AND rc.re_contract_ver_id = v_ver_id
                               AND rc.p_cover_id < resultset(i).p_cover_id --новая версия более поздняя
                             ORDER BY rc.p_cover_id DESC)
            LOOP
              create_oblig_exc(v_ver_id, cur_old.p_cover_id, 'OLD', v_bordero_id);
              UPDATE RE_COVER SET flg_cur_version = 0 WHERE re_cover_id = cur_old.re_cover_id;
            END LOOP;
          
          END IF;
        
          IF p_opt = 3
          THEN
            v_recalc_flg := 0;
          END IF;
        
        END IF;
      
      END LOOP; --курсор по p_cover
    END LOOP; --курсор по filter
  
    LOG(p_bordero_id
       ,'CREATE_BORDERO_FIRST v_bordero1_id ' || v_bordero1_id || ' v_bordero2_id ' || v_bordero2_id ||
        ' v_bordero3_id ' || v_bordero3_id);
  
    IF v_recalc_flg = 1
    THEN
      IF p_opt = 0
      THEN
        recalc_bordero(v_bordero1_id);
        recalc_bordero(v_bordero2_id);
        recalc_bordero(v_bordero3_id);
      ELSE
        recalc_bordero(p_bordero_id);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'create_re_cover ' || SQLERRM);
  END;

  PROCEDURE create_bordero_bi
  (
    p_bordero_id IN NUMBER
   ,p_retr       IN NUMBER DEFAULT 0
   ,p_opt        IN NUMBER DEFAULT 0
  ) IS
    l_borbero_bpp_id NUMBER;
    l_fund_id        NUMBER;
  BEGIN
    LOG(p_bordero_id, 'CREATE_BORDERO_BI');
  
    FOR cur IN (
                
                SELECT b.RE_BORDERO_ID
                       ,bt.BRIEF
                       ,fund_id
                       ,RE_BORDERO_PACKAGE_ID
                  FROM RE_BORDERO      b
                       ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = p_bordero_id
                   AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
                   AND bt.brief = 'БОРДЕРО_ИЗМЕН'
                
                )
    LOOP
      l_fund_id        := cur.fund_id;
      l_borbero_bpp_id := Get_ID_Bordero_BPP(cur.RE_BORDERO_PACKAGE_ID, l_fund_id);
      LOG(p_bordero_id, 'CREATE_BORDERO_BI l_borbero_bpp_id ' || l_borbero_bpp_id);
      create_bordero_first(l_borbero_bpp_id, p_retr, p_opt);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'create_re_cover ' || SQLERRM);
  END;
  --------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------

  PROCEDURE create_bordero_loss
  (
    p_bordero_id IN NUMBER
   ,p_type_id    IN NUMBER DEFAULT 0
  ) IS
    v_db           DATE; --дата начала
    v_de           DATE; --дата окончания
    v_fund_id      NUMBER; -- валюта бордеро
    v_contract_id  NUMBER; --договор перестрахования
    v_doc_templ_id NUMBER;
    v_ver_id       NUMBER; -- версия договора перестрахования
  
    v_temp_count NUMBER;
  
    v_re_claim_header NUMBER;
    v_re_claim        NUMBER;
    v_re_damage       NUMBER;
  
    v_skip_flg NUMBER;
  
    v_cur_decl_sum  NUMBER;
    v_prev_decl_sum NUMBER;
    v_cur_pay_sum   NUMBER;
    v_prev_pay_sum  NUMBER;
  
    v_sum_decl  NUMBER;
    v_sum_pay   NUMBER;
    v_fund_date DATE;
  
    v_re_line_damage RE_LINE_DAMAGE%ROWTYPE;
  
    type_id NUMBER;
  BEGIN
  
    IF p_type_id IN (0, 2)
    THEN
      type_id := 0;
    ELSE
      type_id := 1;
    END IF;
  
    -- удаляем расчитанные ранее убытки по данному бордеро
    DELETE FROM REL_REDAMAGE_BORDERO r WHERE r.re_bordero_id = p_bordero_id;
  
    -- определяем период,за который ищутся начисления и версию договора облигаторного перестрахования
    SELECT bp.start_date
          ,bp.end_date
          ,b.fund_id
          ,CV.re_main_contract_id
          ,CV.re_contract_version_id
          ,CV.DOC_TEMPL_ID
      INTO v_db
          ,v_de
          ,v_fund_id
          ,v_contract_id -- заголовок обл договора перестрахования
          ,v_ver_id -- версия обл договора перестрахования, по которому сформирован пакет бордеро
          ,v_doc_templ_id
      FROM RE_BORDERO              b
          ,RE_BORDERO_PACKAGE      bp
          ,ven_RE_CONTRACT_VERSION CV
     WHERE b.re_bordero_id = p_bordero_id
       AND bp.re_bordero_package_id = b.re_bordero_package_id
       AND CV.re_contract_version_id = bp.re_contract_id;
  
    --raise_application_error(-20000, 'before cicle');
  
    FOR cl IN ( --цикл по претензиям 1
               SELECT *
                 FROM (SELECT cch.C_CLAIM_HEADER_ID
                              ,cch.num num_header
                              ,cc.c_claim_id
                              ,MAX(cc.seqno) OVER(PARTITION BY cc.C_CLAIM_HEADER_ID) seqno_max
                              ,cc.seqno
                              ,cc.num num_claim
                              ,cc.claim_status_date
                              ,cc.claim_status_id
                              ,cc.DECLARE_SUM
                              ,rc.re_cover_id
                              ,rc.p_cover_id
                              ,pc.t_prod_line_option_id
                              ,Pkg_Claim_Payment.get_claim_pay_sum_per(cc.c_claim_id, v_db, v_de) payment_sum
                          FROM ven_C_CLAIM        cc
                              ,ven_C_CLAIM_HEADER cch
                              ,RE_COVER           rc
                              ,P_COVER            pc
                              ,RE_BORDERO         b
                        --             , re_bordero_type bt
                         WHERE rc.p_cover_id = cch.p_cover_id
                           AND check_exc(pc.p_cover_id, v_ver_id) = 0
                           AND b.re_bordero_id = rc.re_bordero_id
                           AND b.FUND_ID = v_fund_id
                           AND pc.p_cover_id = rc.p_cover_id
                           AND rc.re_m_contract_id = v_contract_id --!!!!!!!!!!!!!!!!!!!
                           AND cc.C_CLAIM_HEADER_ID = cch.C_CLAIM_HEADER_ID
                           AND cc.CLAIM_STATUS_DATE BETWEEN v_db AND v_de --!!!!!!!!!!!!!!!!!!!
                           AND Doc.get_last_doc_status_brief(cc.c_claim_id) <> 'PROJECT'
                              --  AND rc.P_ASSET_HEADER_ID in (292586,293613,316465)
                           AND cch.fund_id = v_fund_id --!!!!!!!!!!!!!!!!!
                              --для бордеро заявленных убытков
                           AND ((Pkg_Claim_Payment.get_claim_pay_sum(cc.c_claim_id) = 0 AND type_id = 0) OR
                               -- для бордеро оплаченных убытков
                               (Pkg_Claim_Payment.get_claim_pay_sum_per(cc.c_claim_id, v_db, v_de) > 0 AND
                               type_id = 1)))
                WHERE seqno_max = seqno)
    LOOP
      --цикл по претензиям 2
    
      v_skip_flg := 0;
      --raise_application_error(-20000, 'claim find');
    
      -- создаем re_claim_header (если его нет)
      SELECT COUNT(1)
        INTO v_temp_count
        FROM RE_CLAIM_HEADER
       WHERE c_claim_header_id = cl.C_CLAIM_HEADER_ID
         AND re_m_contract_id = v_contract_id;
    
      BEGIN
        IF v_temp_count = 0
        THEN
          SELECT sq_re_claim_header.NEXTVAL INTO v_re_claim_header FROM dual;
          INSERT INTO ven_re_claim_header
            (re_claim_header_id
            ,c_claim_header_id
            ,num
            ,doc_templ_id
            ,t_prod_line_option_id
            ,re_cover_id
            ,re_m_contract_id
            ,event_date)
            SELECT v_re_claim_header
                  , -- ид
                   cl.c_claim_header_id
                  ,cl.num_header
                  ,(SELECT dc.doc_templ_id
                     FROM DOC_TEMPL dc
                    WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM_HEADER'))
                  ,cl.t_prod_line_option_id
                  ,cl.re_cover_id
                  ,v_contract_id
                  ,(SELECT ce.EVENT_DATE
                     FROM C_CLAIM_HEADER cch
                         ,C_EVENT        ce
                    WHERE ce.C_EVENT_ID = cch.C_EVENT_ID
                      AND cch.c_claim_header_id = cl.C_CLAIM_HEADER_ID)
              FROM dual;
        ELSE
          SELECT re_claim_header_id
            INTO v_re_claim_header
            FROM RE_CLAIM_HEADER
           WHERE c_claim_header_id = cl.C_CLAIM_HEADER_ID
             AND re_m_contract_id = v_contract_id;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_skip_flg := 1;
      END;
    
      -- создаем re_claim (если его нет)
      SELECT COUNT(1)
        INTO v_temp_count
        FROM RE_CLAIM
       WHERE re_claim_header_id = v_re_claim_header
         AND seqno = cl.seqno;
      BEGIN
        IF v_temp_count = 0
        THEN
          SELECT sq_re_claim.NEXTVAL INTO v_re_claim FROM dual;
          INSERT INTO ven_re_claim
            (re_claim_id
            ,re_claim_header_id
            ,seqno
            ,num
            ,re_claim_status_date
            ,status_id
            ,doc_templ_id)
            SELECT v_re_claim
                  ,v_re_claim_header
                  ,cl.seqno
                  ,cl.num_claim
                  ,cl.claim_status_date
                  ,cl.claim_status_id
                  ,(SELECT dc.doc_templ_id
                     FROM DOC_TEMPL dc
                    WHERE dc.doc_ent_id = Ent.id_by_brief('RE_CLAIM'))
              FROM dual;
        ELSE
          SELECT re_claim_id
            INTO v_re_claim
            FROM ven_re_claim
           WHERE re_claim_header_id = v_re_claim_header
             AND seqno = cl.seqno;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_APPLICATION_ERROR(-20000, SQLERRM);
          v_skip_flg := 2;
      END;
    
      IF v_skip_flg = 0
      THEN
        FOR dam IN ( --цикл по c_damage 1
                    SELECT cd.c_damage_id
                           ,cd.t_damage_code_id
                           ,cd.c_damage_type_id
                           ,cd.declare_sum
                           ,cd.payment_sum
                      FROM C_CLAIM            cc
                           ,C_DAMAGE           cd
                           ,C_DAMAGE_COST_TYPE dct
                     WHERE cd.p_cover_id = cl.p_cover_id
                       AND cc.c_claim_id = cl.c_claim_id
                       AND cd.c_claim_id = cc.c_claim_id
                       AND dct.c_damage_cost_type_id(+) = cd.c_damage_cost_type_id
                       AND NVL(dct.brief, 'ВОЗМЕЩАЕМЫЕ') = 'ВОЗМЕЩАЕМЫЕ')
        LOOP
          --цикл по c_damage 2
        
          --вставляем линк на c_damage into re_damage if it is null
          SELECT COUNT(1)
            INTO v_temp_count
            FROM RE_DAMAGE
           WHERE damage_id = dam.c_damage_id
             AND re_cover_id = cl.re_cover_id
             AND re_claim_id = v_re_claim;
          BEGIN
            IF v_temp_count = 0
            THEN
              SELECT sq_re_damage.NEXTVAL INTO v_re_damage FROM dual;
              INSERT INTO RE_DAMAGE
                (re_damage_id, damage_id, re_cover_id, re_claim_id, t_damage_code_id)
              VALUES
                (v_re_damage, dam.c_damage_id, cl.re_cover_id, v_re_claim, dam.t_damage_code_id);
            ELSE
              SELECT re_damage_id
                INTO v_re_damage
                FROM RE_DAMAGE
               WHERE damage_id = dam.c_damage_id
                 AND re_cover_id = cl.re_cover_id
                 AND re_claim_id = v_re_claim
                 AND t_damage_code_id = dam.t_damage_code_id;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              RAISE_APPLICATION_ERROR(-20000, SQLERRM || 'error insert re_damage');
              v_skip_flg := 3;
          END;
        
          --теперь нужно рассписать заявленные и выплаченные суммы
          --по расчитанным линиям, с учетом реальных
        
          v_prev_decl_sum := 0;
          v_prev_pay_sum  := 0;
        
          DELETE RE_LINE_DAMAGE WHERE re_damage_id = v_re_damage;
        
          IF v_skip_flg = 0
          THEN
          
            --нужно узнать дату начала договора и сохранить ее
            v_fund_date := get_pcover_fund_date(cl.p_cover_id);
          
            FOR line IN ( --цикл по линиям рекавера и договора 1
                         SELECT cov.line_number
                                ,cov.LIMIT
                                ,cov.part_perc
                                ,cov.part_sum
                                ,cov.retention_val
                                ,cov.retention_perc
                                ,con.part_sum       part_sum_con
                                ,con.retention_val  ret_val_con
                           FROM RE_LINE_COVER    cov
                                ,RE_LINE_CONTRACT con --необходимо, если были указаны конкретные суммы
                          WHERE cov.re_cover_id = cl.re_cover_id
                            AND cov.re_line_contract_id = con.re_line_contract_id
                          ORDER BY cov.line_number)
            LOOP
              --цикл по линиям рекавера и договора 2
            
              v_re_line_damage.re_damage_id := v_re_damage;
              v_re_line_damage.line_number  := line.line_number;
              v_re_line_damage.LIMIT        := line.LIMIT;
              v_re_line_damage.part_sum     := line.part_sum;
              v_re_line_damage.part_perc    := line.part_perc;
            
              --расчитываем заявленную сумму
              IF dam.declare_sum >= line.LIMIT
              THEN
                v_cur_decl_sum             := line.LIMIT - v_prev_decl_sum;
                v_re_line_damage.part_decl := line.part_sum;
              ELSE
                v_cur_decl_sum := dam.declare_sum - v_prev_decl_sum;
                IF v_cur_decl_sum <= 0
                THEN
                  v_re_line_damage.part_decl := 0;
                ELSE
                
                  IF NVL(line.part_sum_con, 0) > 0
                  THEN
                    --указано значение для перестраховщика
                    IF line.part_sum_con > v_cur_decl_sum
                    THEN
                      v_re_line_damage.part_decl := v_cur_decl_sum; --все отдали перестраховщику
                    ELSE
                      v_re_line_damage.part_decl := line.part_sum_con; --отдали указанное
                    END IF;
                  END IF;
                
                  IF NVL(line.ret_val_con, 0) > 0
                     AND NVL(line.part_sum_con, 0) = 0
                  THEN
                    --указано собственное значение
                    IF line.ret_val_con > v_cur_decl_sum
                    THEN
                      v_re_line_damage.part_decl := 0; --все забрали себе
                    ELSE
                      v_re_line_damage.part_decl := line.ret_val_con - v_cur_decl_sum; --часть отдали
                    END IF;
                  END IF;
                
                  IF NVL(line.ret_val_con, 0) = 0
                     AND NVL(line.part_sum_con, 0) = 0
                  THEN
                    --указаны проценты
                    v_re_line_damage.part_decl := ROUND(v_cur_decl_sum * line.part_perc / 100, 4);
                  END IF;
                
                END IF;
              END IF;
            
              --расчитываем оплаченную сумму
              IF dam.payment_sum >= line.LIMIT
              THEN
                v_cur_pay_sum             := line.LIMIT - v_prev_pay_sum;
                v_re_line_damage.part_pay := line.part_sum;
              ELSE
                v_cur_pay_sum := dam.payment_sum - v_prev_pay_sum;
                IF v_cur_pay_sum <= 0
                THEN
                  v_re_line_damage.part_pay := 0;
                ELSE
                
                  IF NVL(line.part_sum_con, 0) > 0
                  THEN
                    --указано значение для перестраховщика
                    IF line.part_sum_con > v_cur_pay_sum
                    THEN
                      v_re_line_damage.part_pay := v_cur_pay_sum; --все отдали перестраховщику
                    ELSE
                      v_re_line_damage.part_pay := line.part_sum_con; --отдали указанное
                    END IF;
                  END IF;
                
                  IF NVL(line.ret_val_con, 0) > 0
                     AND NVL(line.part_sum_con, 0) = 0
                  THEN
                    --указано собственное значение
                    IF line.ret_val_con > v_cur_pay_sum
                    THEN
                      v_re_line_damage.part_pay := 0; --все забрали себе
                    ELSE
                      v_re_line_damage.part_pay := line.ret_val_con - v_cur_pay_sum; --часть отдали
                    END IF;
                  END IF;
                
                  IF NVL(line.ret_val_con, 0) = 0
                     AND NVL(line.part_sum_con, 0) = 0
                  THEN
                    --указаны проценты
                    v_re_line_damage.part_pay := ROUND(v_cur_pay_sum * line.part_perc / 100, 4);
                  END IF;
                
                END IF;
              END IF;
            
              v_prev_decl_sum := line.LIMIT;
              v_prev_pay_sum  := line.LIMIT;
            
              --cохраняем заполненную линию
              INSERT INTO RE_LINE_DAMAGE
                (re_line_damage_id
                ,re_damage_id
                ,line_number
                ,LIMIT
                ,part_sum
                ,part_perc
                ,part_decl
                ,part_pay)
              VALUES
                (sq_re_line_damage.NEXTVAL
                ,v_re_line_damage.re_damage_id
                ,v_re_line_damage.line_number
                ,v_re_line_damage.LIMIT
                ,v_re_line_damage.part_sum
                ,v_re_line_damage.part_perc
                ,NVL(v_re_line_damage.part_decl, 0)
                ,NVL(v_re_line_damage.part_pay, 0));
            
            END LOOP; --цикл по линиям рекавера и договора 3
          END IF; --проверка v_skip_flg
        
          SELECT NVL(SUM(part_decl), 0)
            INTO v_sum_decl
            FROM RE_LINE_DAMAGE
           WHERE re_damage_id = v_re_damage;
          SELECT NVL(SUM(part_pay), 0)
            INTO v_sum_pay
            FROM RE_LINE_DAMAGE
           WHERE re_damage_id = v_re_damage;
        
          --теперь нужно обновить re_damage
          UPDATE RE_DAMAGE
             SET re_declared_sum  = v_sum_decl
                ,re_payment_sum   = v_sum_pay
                ,t_damage_code_id = dam.t_damage_code_id
                ,c_damage_type_id = dam.c_damage_type_id
                ,ins_declared_sum = dam.declare_sum --суммы из прямого страхования
                ,ins_payment_sum  = dam.payment_sum --суммы из прямого страхования
           WHERE re_damage_id = v_re_damage;
        
          --связь бордеро с re_damagem
          INSERT INTO REL_REDAMAGE_BORDERO
            (rel_redamage_bordero_id, re_damage_id, re_bordero_id, re_payment_sum, fund_date)
          VALUES
            (sq_rel_redamage_bordero.NEXTVAL
            ,v_re_damage
            ,p_bordero_id
            ,DECODE(type_id, 0, v_sum_decl, v_sum_pay)
            ,v_fund_date);
        
        END LOOP; --цикл по c_damage 3
      END IF; --проверка v_skip_flg
    
    END LOOP; --цикл по претензиям 3
  
    IF p_type_id < 2
    THEN
      recalc_bordero(p_bordero_id);
    END IF;
  
  END;

  -------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------

  PROCEDURE recalc_bordero
  (
    p_bordero_id IN NUMBER
   ,p_calc       IN NUMBER DEFAULT 1
  ) IS
    v_pack_id      NUMBER;
    v_brief        VARCHAR2(50);
    v_bd           DATE;
    v_ed           DATE;
    v_sum_in       NUMBER;
    v_sum_out      NUMBER;
    v_cur_rate_val NUMBER;
    v_cur_rate_id  NUMBER;
    v_temp_count   NUMBER;
  BEGIN
    LOG(p_bordero_id, 'RECALC_BORDERO p_calc ' || p_calc);
    SELECT b.re_bordero_package_id
          ,bt.brief
      INTO v_pack_id
          ,v_brief
      FROM RE_BORDERO      b
          ,RE_BORDERO_TYPE bt
     WHERE b.re_bordero_id = p_bordero_id
       AND bt.re_bordero_type_id = b.re_bordero_type_id;
  
    IF v_brief IN ('БОРДЕРО_ПРЕМИЙ'
                  ,'БОРДЕРО_ПРЕМИЙ_НЕ'
                  ,'БОРДЕРО_ДОПЛАТ')
    THEN
      UPDATE RE_BORDERO r
         SET (r.netto_premium
            ,r.commission
            ,brutto_premium
            ,r.DECLARED_SUM
            ,r.PAYMENT_SUM
            ,r.return_sum
            ,r.is_calc) =
             (SELECT NVL(SUM(rrb.netto_premium), 0)
                    ,NVL(SUM(rrb.commission), 0)
                    ,NVL(SUM(rrb.brutto_premium), 0)
                    ,0
                    ,0
                    ,0
                    ,p_calc
                FROM REL_RECOVER_BORDERO rrb
               WHERE rrb.re_bordero_id = p_bordero_id)
       WHERE r.re_bordero_id = p_bordero_id;
    END IF;
  
    IF v_brief IN ('БОРДЕРО_РАСТОРЖЕНИЙ')
    THEN
      UPDATE RE_BORDERO r
         SET (r.netto_premium
            ,r.commission
            ,brutto_premium
            ,r.DECLARED_SUM
            ,r.PAYMENT_SUM
            ,r.return_sum
            ,r.is_calc) =
             (SELECT 0
                    ,0
                    ,0
                    ,0
                    ,0
                    ,NVL(SUM(rrb.returned_premium), 0)
                    ,p_calc
                FROM REL_RECOVER_BORDERO rrb
               WHERE rrb.re_bordero_id = p_bordero_id)
       WHERE r.re_bordero_id = p_bordero_id;
    END IF;
  
    IF v_brief IN ('БОРДЕРО_ИЗМЕН')
    THEN
      UPDATE RE_BORDERO r
         SET (r.netto_premium
            ,r.commission
            ,brutto_premium
            ,r.DECLARED_SUM
            ,r.PAYMENT_SUM
            ,r.return_sum
            ,r.is_calc) =
             (SELECT NVL(SUM(rrb.netto_premium), 0)
                    ,NVL(SUM(rrb.commission), 0)
                    ,NVL(SUM(rrb.brutto_premium), 0)
                    ,0
                    ,0
                    ,NVL(SUM(rrb.returned_premium), 0)
                    ,p_calc
                FROM REL_RECOVER_BORDERO rrb
               WHERE rrb.re_bordero_id = p_bordero_id)
       WHERE r.re_bordero_id = p_bordero_id;
    END IF;
  
    IF v_brief IN ('БОРДЕРО_ЗАЯВ_УБЫТКОВ')
    THEN
      UPDATE RE_BORDERO r
         SET (r.netto_premium
            ,r.commission
            ,brutto_premium
            ,r.DECLARED_SUM
            ,r.PAYMENT_SUM
            ,r.return_sum
            ,r.is_calc) =
             (SELECT 0
                    ,0
                    ,0
                    ,NVL(SUM(rl.RE_PAYMENT_SUM), 0)
                    ,0
                    ,0
                    ,p_calc
                FROM REL_REDAMAGE_BORDERO rl
               WHERE rl.re_bordero_id = p_bordero_id)
       WHERE r.re_bordero_id = p_bordero_id;
    END IF;
  
    IF v_brief IN ('БОРДЕРО_ОПЛ_УБЫТКОВ')
    THEN
      UPDATE RE_BORDERO r
         SET (r.netto_premium
            ,r.commission
            ,brutto_premium
            ,r.DECLARED_SUM
            ,r.PAYMENT_SUM
            ,r.return_sum
            ,r.is_calc) =
             (SELECT 0
                    ,0
                    ,0
                    ,0
                    ,NVL(SUM(rl.RE_PAYMENT_SUM), 0)
                    ,0
                    ,p_calc
                FROM REL_REDAMAGE_BORDERO rl
               WHERE rl.re_bordero_id = p_bordero_id)
       WHERE r.re_bordero_id = p_bordero_id;
    END IF;
  
    v_sum_in  := 0;
    v_sum_out := 0;
  
    FOR cur IN (SELECT bt.brief
                      ,b.brutto_premium
                      ,b.commission
                      ,b.netto_premium
                      ,b.payment_sum
                      ,b.return_sum
                      ,b.regress_sum
                      ,b.declared_sum
                      ,b.re_bordero_id
                      ,b.FLG_DATE_RATE
                  FROM RE_BORDERO         b
                      ,RE_BORDERO_TYPE    bt
                      ,RE_BORDERO_PACKAGE bp
                 WHERE b.re_bordero_package_id = v_pack_id
                   AND bp.re_bordero_package_id = b.re_bordero_package_id
                   AND bt.re_bordero_type_id = b.re_bordero_type_id)
    LOOP
    
      v_cur_rate_val := pkg_reins_payment.get_bordero_rate(cur.re_bordero_id);
    
      IF NVL(cur.flg_date_rate, 0) = 1
      THEN
        CASE cur.brief
          WHEN 'БОРДЕРО_ПРЕМИЙ' THEN
            v_sum_out := v_sum_out + calc_bordero_in_fund(cur.re_bordero_id, cur.brief);
          WHEN 'БОРДЕРО_ПРЕМИЙ_НЕ' THEN
            v_sum_out := v_sum_out + calc_bordero_in_fund(cur.re_bordero_id, cur.brief);
          WHEN 'БОРДЕРО_ИЗМЕН' THEN
            v_sum_out := v_sum_out + calc_bordero_in_fund(cur.re_bordero_id, cur.brief);
            v_sum_in  := v_sum_in + calc_bordero_in_fund(cur.re_bordero_id, cur.brief, 1);
          WHEN 'БОРДЕРО_ДОПЛАТ' THEN
            v_sum_out := v_sum_out + calc_bordero_in_fund(cur.re_bordero_id, cur.brief);
          WHEN 'БОРДЕРО_РАСТОРЖЕНИЙ' THEN
            v_sum_in := v_sum_in + calc_bordero_in_fund(cur.re_bordero_id, cur.brief);
          WHEN 'БОРДЕРО_ЗАЯВ_УБЫТКОВ' THEN
            NULL;
          WHEN 'БОРДЕРО_ОПЛ_УБЫТКОВ' THEN
            v_sum_in := v_sum_in + calc_bordero_in_fund(cur.re_bordero_id, cur.brief);
          ELSE
            NULL;
        END CASE;
      ELSE
        CASE cur.brief
          WHEN 'БОРДЕРО_ПРЕМИЙ' THEN
            v_sum_out := v_sum_out + NVL(cur.netto_premium, 0) * v_cur_rate_val;
          WHEN 'БОРДЕРО_ПРЕМИЙ_НЕ' THEN
            v_sum_out := v_sum_out + NVL(cur.netto_premium, 0) * v_cur_rate_val;
          WHEN 'БОРДЕРО_ИЗМЕН' THEN
            v_sum_out := v_sum_out + NVL(cur.netto_premium, 0) * v_cur_rate_val;
            v_sum_in  := v_sum_in + NVL(cur.return_sum, 0) * v_cur_rate_val;
          WHEN 'БОРДЕРО_ДОПЛАТ' THEN
            v_sum_out := v_sum_out + NVL(cur.netto_premium, 0) * v_cur_rate_val;
          WHEN 'БОРДЕРО_РАСТОРЖЕНИЙ' THEN
            v_sum_in := v_sum_in + NVL(cur.return_sum, 0) * v_cur_rate_val;
          WHEN 'БОРДЕРО_ЗАЯВ_УБЫТКОВ' THEN
            NULL;
          WHEN 'БОРДЕРО_ОПЛ_УБЫТКОВ' THEN
            v_sum_in := v_sum_in + NVL(cur.payment_sum, 0) * v_cur_rate_val;
          ELSE
            NULL;
        END CASE;
      END IF;
    END LOOP;
    UPDATE RE_BORDERO_PACKAGE
       SET summ_in  = v_sum_in
          ,summ_out = v_sum_out
          ,summ     = v_sum_out - v_sum_in
     WHERE re_bordero_package_id = v_pack_id;
  
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE clear_bordero
  (
    p_pack_id    IN NUMBER DEFAULT NULL
   ,p_bordero_id IN NUMBER DEFAULT NULL
   ,p_recalc     NUMBER DEFAULT 1
  ) IS
    v_pack_id NUMBER;
    v_brief   VARCHAR2(50);
    v_bd      DATE;
    v_ed      DATE;
  
    v_contract_id NUMBER;
    v_p_cover_id  NUMBER;
    v_exc_id      NUMBER;
    v_bordero_id  NUMBER;
  BEGIN
    FOR cur IN (SELECT b.re_bordero_package_id
                      ,b.re_bordero_id
                      ,bt.brief
                      ,b.fund_id
                  FROM RE_BORDERO      b
                      ,RE_BORDERO_TYPE bt
                 WHERE b.re_bordero_id = NVL(p_bordero_id, b.re_bordero_id)
                   AND b.re_bordero_package_id = NVL(p_pack_id, b.re_bordero_package_id)
                   AND bt.re_bordero_type_id = b.re_bordero_type_id)
    LOOP
    
      IF cur.brief IN ('БОРДЕРО_ПРЕМИЙ')
      THEN
        DELETE FROM RE_COVER r
         WHERE re_bordero_id = cur.re_bordero_id
              --2009.11.08 Add by Service
              -- При удалении и пересчете БП необходимо оставлять строки, которые используются для хранения данных по БР       
           AND EXISTS (SELECT 1
                  FROM REL_RECOVER_BORDERO rr
                 WHERE rr.re_cover_id = r.re_cover_id
                   AND rr.re_bordero_id = r.re_bordero_id);
      
        --нужно также почистить БППН
        SELECT re_bordero_id
          INTO v_bordero_id
          FROM RE_BORDERO      b
              ,RE_BORDERO_TYPE bt
         WHERE b.re_bordero_type_id = bt.re_bordero_type_id
           AND b.re_bordero_package_id = cur.re_bordero_package_id
           AND b.fund_id = cur.fund_id
           AND bt.brief = 'БОРДЕРО_ПРЕМИЙ_НЕ';
        clear_bordero(cur.re_bordero_package_id, v_bordero_id);
      
      ELSIF cur.brief IN ('БОРДЕРО_ПРЕМИЙ_НЕ')
      THEN
        DELETE RE_COVER WHERE re_bordero_id = cur.re_bordero_id;
      
        --Нужно также почистить БИ
        SELECT re_bordero_id
          INTO v_bordero_id
          FROM RE_BORDERO      b
              ,RE_BORDERO_TYPE bt
         WHERE b.re_bordero_type_id = bt.re_bordero_type_id
           AND b.re_bordero_package_id = cur.re_bordero_package_id
           AND b.fund_id = cur.fund_id
           AND bt.brief = 'БОРДЕРО_ИЗМЕН';
        clear_bordero(cur.re_bordero_package_id, v_bordero_id);
      
      ELSIF cur.brief IN ('БОРДЕРО_ИЗМЕН')
      THEN
      
        --прежде нужно удалить исключения по этому бордеро
        SELECT re_exc_type_id INTO v_exc_id FROM RE_EXC_TYPE WHERE brief = 'OLD';
        DELETE RE_CONTRACT_EXC rce
         WHERE rce.re_bordero_id = cur.re_bordero_id
           AND rce.re_exc_type_id = v_exc_id;
      
        DELETE RE_COVER WHERE re_bordero_id = cur.re_bordero_id;
      
      ELSIF cur.brief IN ('БОРДЕРО_ДОПЛАТ')
      THEN
        DELETE REL_RECOVER_BORDERO WHERE re_bordero_id = cur.re_bordero_id;
      ELSIF cur.brief IN ('БОРДЕРО_РАСТОРЖЕНИЙ')
      THEN
      
        --прежде нужно удалить исключения по этому бордеро
        SELECT re_exc_type_id INTO v_exc_id FROM RE_EXC_TYPE WHERE brief = 'CANCEL';
        DELETE RE_CONTRACT_EXC rce
         WHERE rce.re_bordero_id = cur.re_bordero_id
           AND rce.re_exc_type_id = v_exc_id;
      
        DELETE REL_RECOVER_BORDERO WHERE re_bordero_id = cur.re_bordero_id;
      
      ELSIF cur.brief IN
            ('БОРДЕРО_ЗАЯВ_УБЫТКОВ', 'БОРДЕРО_ОПЛ_УБЫТКОВ')
      THEN
        FOR dam IN (SELECT * FROM REL_REDAMAGE_BORDERO WHERE re_bordero_id = cur.re_bordero_id)
        LOOP
          IF cur.brief = 'БОРДЕРО_ЗАЯВ_УБЫТКОВ'
          THEN
            UPDATE RE_DAMAGE SET re_declared_sum = 0 WHERE re_damage_id = dam.re_damage_id;
          END IF;
          IF cur.brief = 'БОРДЕРО_ОПЛ_УБЫТКОВ'
          THEN
            UPDATE RE_DAMAGE SET re_payment_sum = 0 WHERE re_damage_id = dam.re_damage_id;
          END IF;
        
          DELETE REL_REDAMAGE_BORDERO WHERE rel_redamage_bordero_id = dam.rel_redamage_bordero_id;
        END LOOP;
      
        DELETE RE_DAMAGE rd -- нужно удалить все дамаджи, если на них нет ссылки из rel_redamage_bordero
         WHERE NOT EXISTS
         (SELECT 1 FROM REL_REDAMAGE_BORDERO rrb WHERE rrb.re_damage_id = rd.re_damage_id);
        DELETE RE_CLAIM rc --удаляем все претензии, если на них нет ссылок
         WHERE NOT EXISTS (SELECT 1 FROM RE_DAMAGE rd WHERE rd.re_claim_id = rc.re_claim_id);
        DELETE RE_CLAIM_HEADER rch --аналогично заголовки претензий
         WHERE NOT EXISTS
         (SELECT 1 FROM RE_CLAIM rc WHERE rc.re_claim_header_id = rch.re_claim_header_id);
      END IF;
    
      IF p_recalc = 1
      THEN
        recalc_bordero(cur.re_bordero_id, 0);
      END IF;
    
    END LOOP;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION create_version_slip(p_re_slip_header_id IN NUMBER) RETURN NUMBER IS
    v_slip ven_re_slip%ROWTYPE;
  
    v_date DATE;
  BEGIN
  
    --заполняем данные из предыдущей версии
    SELECT s.*
      INTO v_slip
      FROM ven_re_slip    s
          ,RE_SLIP_HEADER sh
     WHERE sh.LAST_SLIP_ID = s.RE_SLIP_ID
       AND sh.re_slip_header_id = p_re_slip_header_id;
  
    SELECT abort_date INTO v_date FROM RE_SLIP_HEADER WHERE re_slip_header_id = p_re_slip_header_id;
  
    IF v_date IS NOT NULL
    THEN
      v_slip.start_date := v_date;
    ELSE
      v_slip.start_date := SYSDATE;
    END IF;
  
    SELECT sq_re_slip.NEXTVAL INTO v_slip.re_slip_id FROM dual;
  
    SELECT COUNT(1) INTO v_slip.ver_num FROM RE_SLIP WHERE re_slip_header_id = p_re_slip_header_id;
  
    v_slip.reg_date  := SYSDATE;
    v_slip.sign_date := SYSDATE;
  
    SELECT num || '/' || TO_CHAR(v_slip.ver_num)
      INTO v_slip.num
      FROM RE_SLIP_HEADER
     WHERE re_slip_header_id = p_re_slip_header_id;
  
    v_slip.re_amount      := 0;
    v_slip.brutto_premium := 0;
    v_slip.commission     := 0;
    v_slip.netto_premium  := 0;
  
    INSERT INTO ven_re_slip VALUES v_slip;
  
    doc.set_doc_status(v_slip.re_slip_id, 'PROJECT', SYSDATE - 1 / (24 * 60 * 60));
  
    RETURN v_slip.re_slip_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'Ошибка создания версии. ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE copy_version_slip
  (
    p_ver_id IN NUMBER
   ,flg_null IN NUMBER DEFAULT 0
  ) IS
    v_slip_header_id  NUMBER;
    v_cur_ver_id      NUMBER;
    v_new_re_cover_id NUMBER;
  
    v_re_line_slip ven_re_line_slip%ROWTYPE;
  BEGIN
    --нужно узнать ИД заголовка слипа
    SELECT re_slip_header_id INTO v_slip_header_id FROM RE_SLIP WHERE re_slip_id = p_ver_id;
  
    --внесено 26.11.2007, чтобы формы не курочить
    --просто обновление фактической даты окончания
    -- датой предпологаемого окончания
    UPDATE RE_SLIP SET fact_end_date = end_date WHERE re_slip_id = p_ver_id;
  
    -- теперь нужно узнать действующую версию
    BEGIN
      SELECT sh.LAST_SLIP_ID
        INTO v_cur_ver_id
        FROM RE_SLIP_HEADER sh
       WHERE sh.re_slip_header_id = v_slip_header_id
         AND sh.last_slip_id IS NOT NULL;
    EXCEPTION
      WHEN OTHERS THEN
        --это самая первая версия слипа, поэтому нужно сделать на нее ссылку
        UPDATE RE_SLIP_HEADER SET last_slip_id = p_ver_id WHERE re_slip_header_id = v_slip_header_id;
        --больше делать ничего не надо, поэтому выход
        RETURN;
    END;
  
    --копируем линии слипа
    FOR cur IN (SELECT re_line_slip_id
                  FROM RE_LINE_SLIP
                 WHERE re_slip_id = v_cur_ver_id
                 ORDER BY line_number)
    LOOP
      SELECT * INTO v_re_line_slip FROM ven_re_line_slip WHERE re_line_slip_id = cur.re_line_slip_id;
    
      SELECT sq_re_line_slip.NEXTVAL INTO v_re_line_slip.re_line_slip_id FROM dual;
      v_re_line_slip.re_slip_id := p_ver_id;
    
      IF flg_null = 1
      THEN
        v_re_line_slip.retention_perc := 100;
        v_re_line_slip.retention_val  := 0;
        v_re_line_slip.part_perc      := 0;
        v_re_line_slip.part_sum       := 0;
      END IF;
    
      INSERT INTO ven_re_line_slip VALUES v_re_line_slip;
    END LOOP;
  
    --копируем ДСП
    --1. нужно указать, что re_cover по предыдущим версиям не действительны
    UPDATE RE_COVER SET flg_cur_version = 0 WHERE re_slip_id = v_cur_ver_id;
  
    --Теперь нужно по-новой расчитать ДСП
    FOR cur IN
    --мега селект нужен для того, чтобы получить актуальный p_cover
    --а также данные по текущей версии
     (SELECT pc_e.p_cover_id
        FROM RE_COVER           rc
            ,P_COVER            pc_s
            ,T_PROD_LINE_OPTION plo_s
            ,AS_ASSET           aa_s
            ,P_POLICY           pp_s
            ,P_POL_HEADER       pph
            ,P_COVER            pc_e
            ,T_PROD_LINE_OPTION plo_e
            ,AS_ASSET           aa_e
       WHERE rc.re_slip_id = v_cur_ver_id
         AND pc_s.p_cover_id = rc.P_cover_id
         AND plo_s.ID = pc_s.T_PROD_LINE_OPTION_ID
         AND aa_s.AS_ASSET_ID = pc_s.AS_ASSET_ID
         AND pp_s.POLICY_ID = aa_s.P_POLICY_ID
         AND pph.POLICY_HEADER_ID = pp_s.POL_HEADER_ID
         AND aa_e.P_POLICY_ID = pph.POLICY_ID
         AND aa_e.P_ASSET_HEADER_ID = aa_s.P_ASSET_HEADER_ID
         AND pc_e.AS_ASSET_ID = aa_e.AS_ASSET_ID
         AND plo_e.PRODUCT_LINE_ID = plo_s.PRODUCT_LINE_ID
         AND pc_e.T_PROD_LINE_OPTION_ID = plo_e.ID
         AND NVL(rc.FLG_DELETED, 0) <> 1)
    LOOP
      pkg_reins.create_slip_cover(p_ver_id, cur.p_cover_id, 1);
    END LOOP;
  
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE create_slip_cover
  (
    p_slip_id   IN NUMBER
   ,p_pcover_id IN NUMBER
   ,p_flg_null  IN NUMBER DEFAULT 1
  ) IS
    /*
    p_flg_null
    0 - удаленное покрытие
    1 - нормальное добавление
    2 - восстановить удаленное
    */
  
    v_re_cover ven_re_cover%ROWTYPE;
  
    v_delta_premium NUMBER;
    v_delta_commis  NUMBER;
  
    v_part_1 NUMBER;
    v_part_2 NUMBER;
  
    v_sum_1 NUMBER;
    v_sum_2 NUMBER;
  
  BEGIN
  
    -- добавляем запись в  re_cover, если такой нет
    BEGIN
      v_re_cover.re_cover_id := create_re_cover(p_pcover_id, 1, p_slip_id, NULL, p_flg_null);
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'crc ' || SQLERRM);
    END;
  
    IF v_re_cover.re_cover_id IS NULL
    THEN
      RETURN;
    END IF;
  
    -- теперь нужно выяснить, является ли это ДСП
    -- новой версией уже существовавщего
  
    BEGIN
      FOR cur IN (SELECT rc.re_cover_id
                        ,rc_cur.start_date v_ssd_new
                        ,rc_cur.end_date v_sed_new
                        ,SYSDATE v_rsd_new
                        ,rc_cur.end_date v_red_new
                        ,rc.start_date v_ssd_old
                        ,LEAST(rc.END_DATE, rc_cur.start_date) v_sed_old
                        ,SYSDATE v_rsd_old
                        ,rc.end_date v_red_old
                        ,rc_cur.start_date
                        ,NVL(rc.BRUTTO_PREMIUM, 0) brutto_old
                        ,NVL(rc.COMMISSION, 0) commis_old
                        ,rc_cur.BRUTTO_PREMIUM brutto_new
                        ,rc_cur.COMMISSION commis_new
                        ,NVL(rc.DELTA_BRUTTO, 0) delta_brutto
                        ,NVL(rc.DELTA_COMMISSION, 0) delta_commis
                        ,rc_cur.flg_deleted
                    FROM (SELECT rc_cur.flg_deleted
                                ,rc_cur.brutto_premium
                                ,rc_cur.commission
                                ,rc_cur.p_asset_header_id
                                ,rc_cur.t_product_line_id
                                ,s_cur.ver_num - 1 ver_num
                                ,s_cur.re_slip_header_id
                                ,s_cur.start_date
                                ,s_cur.end_date
                            FROM RE_COVER rc_cur
                                ,RE_SLIP  s_cur
                           WHERE rc_cur.RE_COVER_ID = v_re_cover.re_cover_id
                             AND s_cur.re_slip_id = rc_cur.re_slip_id) rc_cur
                        ,(SELECT rc.re_cover_id
                                ,rc.brutto_premium
                                ,rc.COMMISSION
                                ,rc.DELTA_BRUTTO
                                ,rc.DELTA_COMMISSION
                                ,rc.p_asset_header_id
                                ,rc.t_product_line_id
                                ,s.ver_num
                                ,s.re_slip_header_id
                                ,s.start_date
                                ,s.end_date
                            FROM RE_SLIP  s
                                ,RE_COVER rc
                           WHERE rc.re_slip_id = s.re_slip_id) rc
                   WHERE rc.VER_NUM(+) = rc_cur.VER_NUM
                     AND rc.re_slip_header_id(+) = rc_cur.re_slip_header_id
                     AND rc.T_PRODUCT_LINE_ID(+) = rc_cur.T_PRODUCT_LINE_ID
                     AND rc.P_ASSET_HEADER_ID(+) = rc_cur.P_ASSET_HEADER_ID)
      LOOP
      
        SELECT MIN(ss.start_date)
          INTO cur.v_rsd_old
          FROM RE_SLIP s
              ,RE_SLIP ss
         WHERE s.re_slip_id = p_slip_id
           AND ss.RE_SLIP_HEADER_ID = s.RE_SLIP_HEADER_ID;
      
        cur.v_rsd_new := cur.v_rsd_old;
      
        --вычисляем долю по предыдущему p_cover
        BEGIN
          v_part_1 := (cur.v_sed_old - cur.v_ssd_old) / (cur.v_red_old - cur.v_rsd_old);
        EXCEPTION
          WHEN OTHERS THEN
            v_part_1 := 0;
        END;
      
        IF v_part_1 < 0
        THEN
          v_part_1 := 0;
        ELSIF v_part_1 > 1
        THEN
          v_part_1 := 1;
        END IF;
      
        IF cur.re_cover_id IS NULL
        THEN
          v_part_1 := 0;
        END IF;
      
        --вычисляем долю по текущему p_cover
        BEGIN
          v_part_2 := (cur.v_sed_new - cur.v_ssd_new) / (cur.v_red_new - cur.v_rsd_new);
        EXCEPTION
          WHEN OTHERS THEN
            v_part_2 := 0;
        END;
      
        IF cur.flg_deleted = 1
        THEN
          v_part_2 := 0;
        END IF;
      
        IF v_part_2 < 0
        THEN
          v_part_2 := 0;
        ELSIF v_part_2 > 1
        THEN
          v_part_2 := 1;
        END IF;
      
        --raise_application_error(-20000, 'v_part_1='||v_part_1||',v_part_2='||v_part_2);
      
        --Вычисление брутто-премии
        v_sum_1                   := ROUND((cur.brutto_old - cur.delta_brutto) * v_part_1, 2) +
                                     cur.delta_brutto;
        v_re_cover.delta_brutto   := v_sum_1;
        v_sum_2                   := ROUND(cur.brutto_new * v_part_2, 2);
        v_re_cover.brutto_premium := v_sum_1 + v_sum_2;
      
        --Вычисление коммиссии
        v_sum_1                     := ROUND(cur.commis_old * v_part_1, 2) + cur.delta_commis;
        v_re_cover.delta_commission := v_sum_1 + cur.delta_commis;
        v_sum_2                     := ROUND(cur.commis_new * v_part_2, 2);
        v_re_cover.commission       := v_sum_1 + v_sum_2;
      
        --Вычисление Нетто-премии
        v_re_cover.netto_premium := v_re_cover.brutto_premium - v_re_cover.commission;
      
        UPDATE RE_COVER
           SET brutto_premium   = v_re_cover.brutto_premium
              ,commission       = v_re_cover.commission
              ,netto_premium    = v_re_cover.netto_premium
              ,delta_brutto     = v_re_cover.delta_brutto
              ,delta_commission = v_re_cover.delta_commission
         WHERE re_cover_id = v_re_cover.re_cover_id;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'CSC in loop' || SQLERRM);
    END;
  
    pkg_reins.update_slip_sum(p_slip_id);
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'create_slip_cover ' || SQLERRM);
    
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE change_slip_st(p_slip_id IN NUMBER) IS
    v_doc_st_brief   VARCHAR2(255);
    v_slip_header_id NUMBER;
    v_num            NUMBER;
    v_date           DATE;
  BEGIN
    v_doc_st_brief := doc.get_doc_status_brief(p_slip_id);
    CASE
      WHEN v_doc_st_brief IN ('ACCEPTED', 'BREAK') THEN
        -- 1. смена активной версии
        SELECT re_slip_header_id
              ,ver_num - 1
              ,start_date
          INTO v_slip_header_id
              ,v_num
              ,v_date
          FROM RE_SLIP
         WHERE re_slip_id = p_slip_id;
      
        UPDATE RE_SLIP_HEADER sh
           SET sh.LAST_SLIP_ID = p_slip_id
         WHERE sh.RE_SLIP_HEADER_ID = v_slip_header_id;
      
        -- 2. перевод предыдущих в статус завершен
        FOR cur IN (SELECT re_slip_id
                      FROM RE_SLIP
                     WHERE doc.get_doc_status_brief(re_slip_id) = 'ACCEPTED'
                       AND re_slip_id <> p_slip_id
                       AND re_slip_header_id = v_slip_header_id)
        LOOP
          doc.SET_DOC_STATUS(cur.re_slip_id, 'STOPED');
        END LOOP;
      
        -- 3.Обрезать фактическую дату предыдущей версии до даты начала текущей версии
        IF v_num >= 0
        THEN
          UPDATE RE_SLIP
             SET fact_end_date = v_date
           WHERE re_slip_header_id = v_slip_header_id
             AND ver_num = v_num;
        END IF;
      
      ELSE
        NULL;
    END CASE;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  PROCEDURE update_slip_sum(p_slip_id IN NUMBER) IS
    v_brutto  NUMBER;
    v_commis  NUMBER;
    v_netto   NUMBER;
    v_part    NUMBER;
    v_payment NUMBER;
  
  BEGIN
  
    v_brutto  := 0;
    v_commis  := 0;
    v_netto   := 0;
    v_part    := 0;
    v_payment := 0;
  
    SELECT SUM(rr.brutto_premium)
          ,SUM(rr.commission)
          ,SUM(rr.netto_premium)
          ,SUM(rr.part_sum)
      INTO v_brutto
          ,v_commis
          ,v_netto
          ,v_part
      FROM RE_COVER rr
     WHERE rr.re_slip_id = p_slip_id;
  
    SELECT SUM(rc.re_payment_sum)
      INTO v_payment
      FROM RE_CLAIM        rc
          ,RE_CLAIM_HEADER rch
     WHERE rch.RE_SLIP_ID = p_slip_id
       AND rc.RE_CLAIM_HEADER_ID = rch.RE_CLAIM_HEADER_ID;
  
    BEGIN
      UPDATE RE_SLIP r
         SET r.brutto_premium = NVL(v_brutto, 0)
            ,r.commission     = NVL(v_commis, 0)
            ,r.netto_premium  = NVL(v_netto, 0)
            ,r.re_amount      = NVL(v_part, 0)
            ,r.payment_sum    = NVL(v_payment, 0)
       WHERE r.re_slip_id = p_slip_id;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'update_slip_sum ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE slip_abort(p_slip_head_id IN NUMBER) IS
    v_last_id NUMBER;
    v_num     NUMBER;
  
    v_temp_id NUMBER;
  
    v_date DATE;
  BEGIN
    SELECT sh.last_slip_id
          ,s.VER_NUM
      INTO v_last_id
          ,v_num
      FROM RE_SLIP_HEADER sh
          ,RE_SLIP        s
     WHERE sh.re_slip_header_id = p_slip_head_id
       AND s.RE_SLIP_ID = sh.LAST_SLIP_ID;
  
    --последняя версия по слипу должна быть в статусе "акцептована"
    --все последующие - удалять
  
    IF doc.get_doc_status_brief(v_last_id) <> 'ACCEPTED'
    THEN
      RAISE_APPLICATION_ERROR(-20001, 'Договор не актептован.');
    END IF;
  
    DELETE RE_SLIP
     WHERE re_slip_header_id = p_slip_head_id
       AND ver_num > v_num;
  
    --теперь нужно сформировать новую версию слипа
    --и перевести ее в нужный статус
  
    BEGIN
      v_temp_id := Pkg_Reins.create_version_slip(p_slip_head_id);
      IF v_temp_id IS NOT NULL
      THEN
        pkg_reins.copy_version_slip(v_temp_id, 1);
      
        v_date := doc.GET_STATUS_DATE(v_temp_id, 'PROJECT');
        v_date := v_date + 1 / (24 * 60 * 60);
      
        doc.set_doc_status(v_temp_id, 'READY_TO_CANCEL', v_date);
      ELSE
        RAISE_APPLICATION_ERROR(-20002
                               ,'Невозможно создать новую версию.');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002
                               ,'Невозможно создать версию для расторжения.' || SQLERRM);
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000
                             ,'Невозможно расторгнуть договор. ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE slip_delete(p_slip_id IN NUMBER) IS
    v_slip ven_re_slip%ROWTYPE;
  BEGIN
    SELECT * INTO v_slip FROM ven_re_slip WHERE re_slip_id = p_slip_id;
    IF v_slip.ver_num > 0
    THEN
      FOR cur IN (SELECT re_cover_id FROM RE_COVER WHERE re_slip_id = p_slip_id)
      LOOP
        update_cur_recover(cur.re_cover_id);
      END LOOP;
    END IF;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE update_cur_recover(p_recover_id IN NUMBER) IS
    v_doc_id NUMBER;
    v_brief  VARCHAR2(50);
  
    v_asset_header_id NUMBER;
    v_product_line_id NUMBER;
  
  BEGIN
  
    SELECT re_slip_id
          ,p_asset_header_id
          ,t_product_line_id
      INTO v_doc_id
          ,v_asset_header_id
          ,v_product_line_id
      FROM RE_COVER
     WHERE re_cover_id = p_recover_id;
  
    FOR cur IN (SELECT rc.re_cover_id
                  FROM RE_SLIP  rs_cur
                      ,RE_SLIP  rs
                      ,RE_COVER rc
                 WHERE rs_cur.re_slip_id = v_doc_id
                   AND rs.re_slip_header_id = rs_cur.re_slip_header_id
                   AND rc.re_slip_id = rs.re_slip_id
                   AND rc.P_ASSET_HEADER_ID = v_asset_header_id
                   AND rc.T_PRODUCT_LINE_ID = v_product_line_id
                   AND rs.ver_num = (SELECT MAX(rs1.ver_num)
                                       FROM RE_SLIP rs1
                                      WHERE rs1.re_slip_header_id = rs_cur.re_slip_header_id
                                        AND rs1.ver_num < rs_cur.ver_num))
    LOOP
      UPDATE RE_COVER rc SET rc.FLG_CUR_VERSION = 1 WHERE rc.re_cover_id = cur.re_cover_id;
    END LOOP;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE create_oblig_exc
  (
    p_ver_id     IN NUMBER
   ,p_pcover_id  IN NUMBER
   ,p_exc_brief  IN VARCHAR2 DEFAULT 'USER'
   ,p_bordero_id IN NUMBER DEFAULT NULL
  ) IS
    v_contract_id     NUMBER;
    v_pol_header_id   NUMBER;
    v_asset_header_id NUMBER;
    v_prod_line_id    NUMBER;
    v_temp            NUMBER;
    v_id_exc_type_id  NUMBER;
  BEGIN
    SELECT CV.re_main_contract_id
      INTO v_contract_id
      FROM RE_CONTRACT_VERSION CV
     WHERE CV.re_contract_version_id = p_ver_id;
  
    SELECT re_exc_type_id INTO v_id_exc_type_id FROM ven_re_exc_type WHERE brief = p_exc_brief;
  
    SELECT ah.p_asset_header_id
          ,pl.ID
          ,pp.pol_header_id
      INTO v_asset_header_id
          ,v_prod_line_id
          ,v_pol_header_id
      FROM P_COVER            pc
          ,AS_ASSET           aa
          ,P_POLICY           pp
          ,P_ASSET_HEADER     ah
          ,T_PROD_LINE_OPTION plo
          ,T_PRODUCT_LINE     pl
     WHERE pc.as_asset_id = aa.as_asset_id
       AND ah.p_asset_header_id = aa.p_asset_header_id
       AND pp.policy_id = aa.p_policy_id
       AND plo.ID = pc.t_prod_line_option_id
       AND pl.ID = plo.product_line_id
       AND pc.p_cover_id = p_pcover_id;
  
    SELECT COUNT(1)
      INTO v_temp
      FROM RE_CONTRACT_EXC
     WHERE re_contract_version_id = p_ver_id
       AND p_pol_header_id = v_pol_header_id
       AND t_product_line_id = v_prod_line_id
       AND p_asset_header_id = v_asset_header_id
       AND re_exc_type_id = v_id_exc_type_id
       AND p_cover_id = p_pcover_id;
  
    IF v_temp = 0
    THEN
      INSERT INTO ven_re_contract_exc
        (re_contract_id
        ,RE_CONTRACT_VERSION_ID
        ,P_POL_HEADER_ID
        ,t_product_line_id
        ,p_asset_header_id
        ,p_cover_id
        ,re_exc_type_id
        ,re_bordero_id)
      VALUES
        (v_contract_id
        ,p_ver_id
        ,v_pol_header_id
        ,v_prod_line_id
        ,v_asset_header_id
        ,p_pcover_id
        ,v_id_exc_type_id
        ,p_bordero_id);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'create_exception' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION check_exc
  (
    p_p_cover_id IN NUMBER
   ,p_re_ver_id  IN NUMBER DEFAULT NULL
   ,p_re_slip_id IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
    v_asset_header_id NUMBER;
    v_prod_line_id    NUMBER;
    v_pol_header_id   NUMBER;
  
    v_contract_id NUMBER;
  
    v_temp NUMBER;
  BEGIN
    --узнаем параметры p_cover
    SELECT ah.p_asset_header_id
          ,pl.ID
          ,pp.pol_header_id
      INTO v_asset_header_id
          ,v_prod_line_id
          ,v_pol_header_id
      FROM P_COVER            pc
          ,AS_ASSET           aa
          ,P_POLICY           pp
          ,P_ASSET_HEADER     ah
          ,T_PROD_LINE_OPTION plo
          ,T_PRODUCT_LINE     pl
     WHERE pc.as_asset_id = aa.as_asset_id
       AND ah.p_asset_header_id = aa.p_asset_header_id
       AND pp.policy_id = aa.p_policy_id
       AND plo.ID = pc.t_prod_line_option_id
       AND pl.ID = plo.product_line_id
       AND pc.p_cover_id = p_p_cover_id;
  
    --узнаем параметры договора перестрахования
    v_contract_id := NULL;
  
    IF p_re_ver_id IS NOT NULL
    THEN
      SELECT CV.re_main_contract_id
        INTO v_contract_id
        FROM RE_CONTRACT_VERSION CV
       WHERE CV.re_contract_version_id = p_re_ver_id;
    END IF;
  
    IF p_re_slip_id IS NOT NULL
    THEN
      SELECT sh.re_main_contract_id
        INTO v_contract_id
        FROM RE_SLIP        s
            ,RE_SLIP_HEADER sh
       WHERE s.re_slip_header_id = sh.re_slip_header_id
         AND s.re_slip_id = p_re_slip_id;
    END IF;
  
    --1. нужно проверить на устаревшую версию
    -- это нужно для того, чтобы хоть одна версия п-ковера попала в расчеты
    -- если это не делать, то все версии п-ковера будут считаться исключенными.
    SELECT COUNT(1)
      INTO v_temp
      FROM RE_CONTRACT_EXC ce
          ,RE_EXC_TYPE     et
     WHERE ce.re_contract_id = NVL(v_contract_id, ce.re_contract_id)
       AND ce.p_cover_id = p_p_cover_id --!!!!!!!
       AND ce.re_exc_type_id = et.re_exc_type_id
       AND et.BRIEF = 'OLD'
       AND NVL(ce.re_contract_version_id, -1) = NVL(p_re_ver_id, NVL(ce.re_contract_version_id, -1))
       AND NVL(ce.re_slip_id, -1) = NVL(p_re_slip_id, NVL(ce.re_slip_id, -1));
    IF v_temp > 0
    THEN
      RETURN 1;
    END IF;
  
    --2 проверяем на другие исключения (за исключением устаревшей)
    SELECT COUNT(1)
      INTO v_temp
      FROM RE_CONTRACT_EXC ce
          ,RE_EXC_TYPE     et
     WHERE ce.re_contract_id = NVL(v_contract_id, re_contract_id) -- ИД договора
       AND ce.p_pol_header_id = v_pol_header_id --|
       AND ce.t_product_line_id = v_prod_line_id --| покрытие
       AND ce.p_asset_header_id = v_asset_header_id --|
       AND et.brief = 'OLD'
       AND ce.RE_EXC_TYPE_ID <> et.RE_EXC_TYPE_ID
       AND NVL(ce.re_contract_version_id, -1) = NVL(p_re_ver_id, NVL(ce.re_contract_version_id, -1))
       AND NVL(ce.re_slip_id, -1) = NVL(p_re_slip_id, NVL(ce.re_slip_id, -1));
  
    IF v_temp = 0
    THEN
      RETURN 0;
    ELSE
      RETURN 1;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE slip_damage_calc
  (
    par_slip_id   IN NUMBER
   ,par_damage_id IN NUMBER
  ) IS
    v_re_damage_id NUMBER;
  BEGIN
    v_re_damage_id := create_re_damage(par_slip_id, par_damage_id, 1);
    update_slip_sum(par_slip_id);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  PROCEDURE calc_exced(p_ver_id IN NUMBER) IS
  
    v_count NUMBER;
  
    v_bp_id NUMBER;
    v_b_id  NUMBER;
  
    v_cur_premium     NUMBER;
    v_cur_sum_premium NUMBER;
  
    --тип бордеро для убытков
    v_brief CONSTANT VARCHAR2(50) := 'БОРДЕРО_ЗАЯВ_УБЫТКОВ';
    v_type  CONSTANT NUMBER := 0;
    --v_brief constant  varchar2(50) := 'БОРДЕРО_ОПЛ_УБЫТКОВ';
    --v_type constant number := 0;
  
  BEGIN
    --расчет эксцедента
    --1. нужно создать (или проверить наличие) псевдо-бордеро и пакет бордеро
  
    --проверка наличия пакета бордеро
    SELECT COUNT(1) INTO v_count FROM RE_BORDERO_PACKAGE WHERE re_contract_id = p_ver_id;
  
    IF v_count = 0
    THEN
      -- пакета бордеро нет, поэтому нужно его создать
      INSERT INTO ven_re_bordero_package
        (re_m_contract_id
        ,start_date
        ,end_date
        ,num
        ,reg_date
        ,fund_pay_id
        ,doc_templ_id
        ,assignor_id
        ,reinsurer_id
        ,summ
        ,re_contract_id)
        SELECT CV.RE_MAIN_CONTRACT_ID
              ,CV.START_DATE
              ,CV.END_DATE
              ,CV.NUM
              ,CV.REG_DATE
              ,mc.FUND_ID
              ,dt.DOC_TEMPL_ID
              ,mc.ASSIGNOR_ID
              ,mc.REINSURER_ID
              ,0
              ,p_ver_id
          FROM ven_re_contract_version CV
              ,RE_MAIN_CONTRACT        mc
              ,DOC_TEMPL               dt
         WHERE CV.re_contract_version_id = p_ver_id
           AND mc.RE_MAIN_CONTRACT_ID = CV.RE_MAIN_CONTRACT_ID
           AND UPPER(dt.BRIEF) = 'RE_BORDERO_PACKAGE';
    
    END IF;
  
    SELECT re_bordero_package_id INTO v_bp_id FROM RE_BORDERO_PACKAGE WHERE re_contract_id = p_ver_id;
  
    UPDATE ven_re_bordero_package
       SET (start_date, end_date, fund_pay_id) =
           (SELECT CV.start_date
                  ,CV.end_date
                  ,mc.fund_id
              FROM ven_re_contract_version CV
                  ,RE_MAIN_CONTRACT        mc
             WHERE CV.re_contract_version_id = p_ver_id
               AND mc.RE_MAIN_CONTRACT_ID = CV.RE_MAIN_CONTRACT_ID)
     WHERE re_bordero_package_id = v_bp_id;
  
    --проверка наличия псевдо-бордеро эксцедента
    SELECT COUNT(1)
      INTO v_count
      FROM RE_BORDERO      b
          ,RE_BORDERO_TYPE bt
     WHERE b.re_bordero_package_id = v_bp_id
       AND UPPER(bt.BRIEF) = 'БОРДЕРО_ЕКСЦЕДЕНТ'
       AND b.RE_BORDERO_TYPE_ID = bt.RE_BORDERO_TYPE_ID;
  
    IF v_count = 0
    THEN
      --нужно создать его
    
      INSERT INTO ven_re_bordero
        (doc_templ_id
        ,num
        ,reg_date
        ,fund_id
        ,fund_pay_id
        ,re_bordero_package_id
        ,re_bordero_type_id
        ,rate_type_id
        ,rate_val
        ,brutto_premium
        ,commission
        ,netto_premium)
        SELECT dt.DOC_TEMPL_ID
              ,bp.NUM
              ,bp.REG_DATE
              ,bp.FUND_PAY_ID
              ,bp.FUND_PAY_ID
              ,bp.RE_BORDERO_PACKAGE_ID
              ,bt.RE_BORDERO_TYPE_ID
              ,rt.RATE_TYPE_ID
              ,1
              ,0
              ,0
              ,0
          FROM ven_re_bordero_package bp
              ,DOC_TEMPL              dt
              ,RE_BORDERO_TYPE        bt
              ,RATE_TYPE              rt
         WHERE bp.RE_BORDERO_PACKAGE_ID = v_bp_id
           AND UPPER(dt.BRIEF) = 'RE_BORDERO'
           AND UPPER(bt.BRIEF) = 'БОРДЕРО_ЕКСЦЕДЕНТ'
           AND UPPER(rt.BRIEF) = 'ФИКС';
    END IF;
  
    SELECT b.re_bordero_id
      INTO v_b_id
      FROM RE_BORDERO      b
          ,RE_BORDERO_TYPE bt
     WHERE b.re_bordero_package_id = v_bp_id
       AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
       AND bt.BRIEF = 'БОРДЕРО_ЕКСЦЕДЕНТ';
  
    --обновляем на всякий случай валюту
    UPDATE RE_BORDERO
       SET (fund_id, fund_pay_id) =
           (SELECT bp.FUND_PAY_ID
                  ,bp.FUND_PAY_ID
              FROM ven_re_bordero_package bp
             WHERE bp.RE_BORDERO_PACKAGE_ID = v_bp_id)
     WHERE re_bordero_id = v_b_id;
  
    create_bordero_first(v_b_id, 0, 3);
  
    --теперь нужно обновить суммы в договре
    SELECT NVL(SUM(rc.BRUTTO_PREMIUM), 0)
          ,NVL(SUM(pc.PREMIUM), 0)
      INTO v_cur_premium
          ,v_cur_sum_premium
      FROM RE_COVER rc
          ,P_COVER  pc
     WHERE pc.p_cover_id = rc.p_cover_id
       AND rc.RE_CONTRACT_VER_ID = p_ver_id;
  
    UPDATE RE_CONTRACT_VER_EL
       SET cur_premium     = v_cur_premium
          ,cur_sum_premium = v_cur_sum_premium
     WHERE re_contract_ver_el_id = p_ver_id;
  
    --проверка наличия псевдо-бордеро убытков
    SELECT COUNT(1)
      INTO v_count
      FROM RE_BORDERO      b
          ,RE_BORDERO_TYPE bt
     WHERE b.re_bordero_package_id = v_bp_id
       AND UPPER(bt.BRIEF) = v_brief
       AND b.RE_BORDERO_TYPE_ID = bt.RE_BORDERO_TYPE_ID;
  
    IF v_count = 0
    THEN
      --нужно создать его
    
      INSERT INTO ven_re_bordero
        (doc_templ_id
        ,num
        ,reg_date
        ,fund_id
        ,fund_pay_id
        ,re_bordero_package_id
        ,re_bordero_type_id
        ,rate_type_id
        ,rate_val
        ,brutto_premium
        ,commission
        ,netto_premium)
        SELECT dt.DOC_TEMPL_ID
              ,bp.NUM
              ,bp.REG_DATE
              ,bp.FUND_PAY_ID
              ,bp.FUND_PAY_ID
              ,bp.RE_BORDERO_PACKAGE_ID
              ,bt.RE_BORDERO_TYPE_ID
              ,rt.RATE_TYPE_ID
              ,1
              ,0
              ,0
              ,0
          FROM ven_re_bordero_package bp
              ,DOC_TEMPL              dt
              ,RE_BORDERO_TYPE        bt
              ,RATE_TYPE              rt
         WHERE bp.RE_BORDERO_PACKAGE_ID = v_bp_id
           AND UPPER(dt.BRIEF) = 'RE_BORDERO'
           AND UPPER(bt.BRIEF) = v_brief
           AND UPPER(rt.BRIEF) = 'ФИКС';
    
    END IF;
  
    SELECT b.re_bordero_id
      INTO v_b_id
      FROM RE_BORDERO      b
          ,RE_BORDERO_TYPE bt
     WHERE b.re_bordero_package_id = v_bp_id
       AND bt.RE_BORDERO_TYPE_ID = b.RE_BORDERO_TYPE_ID
       AND bt.BRIEF = v_brief;
  
    --обновляем на всякий случай валюту
    UPDATE RE_BORDERO
       SET (fund_id, fund_pay_id) =
           (SELECT bp.FUND_PAY_ID
                  ,bp.FUND_PAY_ID
              FROM ven_re_bordero_package bp
             WHERE bp.RE_BORDERO_PACKAGE_ID = v_bp_id)
     WHERE re_bordero_id = v_b_id;
  
    create_bordero_loss(v_b_id, v_type);
  
    DELETE RE_DAMAGE rd
     WHERE rd.re_damage_id IN
           (SELECT rrb.re_damage_id FROM REL_REDAMAGE_BORDERO rrb WHERE rrb.RE_PAYMENT_SUM = 0);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20000, 'Calc_exced ' || SQLERRM);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION exced_recover
  (
    p_ver_id       IN NUMBER
   ,p_re_damage_id IN NUMBER
   ,p_type         IN NUMBER DEFAULT 0
  ) RETURN NUMBER IS
  
    v_excedent NUMBER; -- сумма восстановления
    v_cur_sum  NUMBER; -- возможная сумма восстановления
    --    v_cur_num number; -- текущий номер восстановления
  
    v_sum_rec  NUMBER; --сумма восстановленых
    v_cost_rec NUMBER; --стоимость восстановления
  
    v_result NUMBER;
  
  BEGIN
  
    v_result := 0;
  
    -- 1. Нужно определить сумму восстановления
    BEGIN
      SELECT NVL(rlc2.LIMIT, 0) - NVL(rlc1.LIMIT, 0)
        INTO v_excedent
        FROM REL_REDAMAGE_BORDERO rrb
            ,RE_BORDERO_PACKAGE   bp
            ,RE_BORDERO           b
            ,RE_DAMAGE            rd
            ,RE_LINE_COVER        rlc1
            ,RE_LINE_COVER        rlc2
       WHERE b.re_bordero_package_id = bp.re_bordero_package_id
         AND rrb.re_bordero_id = b.re_bordero_id
         AND rd.re_damage_id = rrb.re_damage_id
         AND rlc1.RE_COVER_ID = rd.RE_COVER_ID
         AND rlc2.re_cover_id = rd.re_cover_id
         AND rlc1.LINE_NUMBER = 1
         AND rlc2.line_number = 2
         AND bp.RE_CONTRACT_ID = p_ver_id
         AND rd.RE_DAMAGE_ID = p_re_damage_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_excedent := 0;
    END;
  
    --нужно определить сумму риска
    SELECT NVL(rd.RE_DECLARED_SUM, 0)
      INTO v_cur_sum
      FROM RE_DAMAGE rd
     WHERE rd.RE_DAMAGE_ID = p_re_damage_id;
  
    v_result := v_cur_sum;
  
    IF p_type = 1
    THEN
      --восстанавливаем
    
      --получаем стоимость восстановления
      FOR cur IN (SELECT order_num
                        ,COST
                    FROM RE_COND_EXC_RECOVERY
                   ORDER BY order_num)
      LOOP
      
        LOOP
        
          SELECT NVL(SUM(rer.REC_VAL), 0)
            INTO v_sum_rec
            FROM RE_EXC_RECOVERY rer
           WHERE rer.RE_CONTRACT_VERSION_ID = p_ver_id
             AND rer.ORDER_NUM = cur.order_num;
        
          IF v_sum_rec < v_excedent
          THEN
            --есть еще возможность восстановить
          
            --сколько можно восстановить
            v_sum_rec := v_excedent - v_sum_rec;
          
            IF v_cur_sum < v_sum_rec
            THEN
              --сумма убытка меньше, чем возможность восстановления
              --значит полное восстановление
              v_sum_rec := v_cur_sum;
              v_cur_sum := 0;
            
              --сумма восстановления еще осталась поэтому берем долю от суммы
              v_cost_rec := ROUND(cur.COST * v_sum_rec / v_excedent, 2);
            
            ELSE
              --не хватило суммы восстановления на весь убыток;
              v_cur_sum := v_cur_sum - v_sum_rec;
            
              --нужно получить остатки от премии, т.к. это восстановление закончилось
              SELECT cur.COST - NVL(SUM(rec_cost), 0)
                INTO v_cost_rec
                FROM RE_EXC_RECOVERY
               WHERE order_num = cur.order_num
                 AND RE_CONTRACT_VERSION_ID = p_ver_id;
            END IF;
          
            INSERT INTO ven_re_exc_recovery
              (re_damage_id, order_num, re_contract_version_id, rec_date, rec_val, rec_cost)
            VALUES
              (p_re_damage_id, cur.order_num, p_ver_id, SYSDATE, v_sum_rec, v_cost_rec);
          
          ELSE
            EXIT;
          END IF;
        
          EXIT WHEN v_cur_sum = 0;
          EXIT WHEN v_sum_rec = 0;
        END LOOP;
      
        --риск полностью восстановлен
        EXIT WHEN v_cur_sum = 0;
      
      END LOOP;
    
      RETURN v_result - v_cur_sum;
    ELSE
    
      DELETE RE_EXC_RECOVERY
       WHERE re_contract_version_id = p_ver_id
         AND re_damage_id = p_re_damage_id;
    
      RETURN 0;
    
    END IF;
  
    RETURN v_result;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------

  FUNCTION get_pcover_reins_sum(p_pcover_id IN NUMBER) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
  
    SELECT SUM(rc.part_sum)
      INTO v_result
      FROM RE_COVER           rc
          ,P_COVER            pc
          ,AS_ASSET           aa
          ,T_PROD_LINE_OPTION plo
     WHERE pc.p_cover_id = p_pcover_id
       AND aa.as_asset_id = pc.AS_ASSET_ID
       AND plo.ID = pc.T_PROD_LINE_OPTION_ID
       AND rc.P_ASSET_HEADER_ID = aa.P_ASSET_HEADER_ID
       AND rc.T_PRODUCT_LINE_ID = plo.PRODUCT_LINE_ID
       AND rc.FLG_CUR_VERSION = 1;
  
    RETURN NVL(v_result, 0);
  END;

  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION cover_reins(p_pcover_id NUMBER) RETURN NUMBER IS
    v_res NUMBER;
  BEGIN
    BEGIN
      SELECT COUNT(rc.re_cover_id)
        INTO v_res
        FROM RE_COVER           rc
            ,P_COVER            pc
            ,AS_ASSET           aa
            ,T_PROD_LINE_OPTION plo
       WHERE pc.p_cover_id = p_pcover_id
         AND aa.as_asset_id = pc.AS_ASSET_ID
         AND plo.ID = pc.T_PROD_LINE_OPTION_ID
         AND rc.P_ASSET_HEADER_ID = aa.P_ASSET_HEADER_ID
         AND rc.T_PRODUCT_LINE_ID = plo.PRODUCT_LINE_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_res := 0;
    END;
    IF v_res > 0
    THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION TEST(p_in VARCHAR2 DEFAULT NULL) RETURN NUMBER IS
  
    TYPE t_cursor IS REF CURSOR;
    cur    t_cursor;
    v_temp NUMBER;
  BEGIN
  
    doc.set_doc_status(275294, 'ACCEPTED');
  
    --insert into ven_test(description) values (p_in);
    RETURN 1;
  
    OPEN cur FOR
      SELECT 1 FROM dual;
    FETCH cur
      INTO v_temp;
    CLOSE cur;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 1;
  END;

END;
/
