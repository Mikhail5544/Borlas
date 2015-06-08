CREATE OR REPLACE PACKAGE pkg_policy_checks AS
  /******************************************************************************
     NAME:       PKG_POLICY_CHECKS
     PURPOSE:    Набор процедур проверки создания новой версии договора страхования
  
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        30.07.2012      sergey.ilyushkin       1. Created this package.
  ******************************************************************************/

  /* sergey.ilyushkin 30/07/2012
  Проверяет наличее указанного типа изменения у версии
  @param par_policy_id - ИД версии
  @param par_addendum_type_brief - Краткое наименование типа изменения
  @return: 1 - версия имеет данный тип изменения; 0 - не имеет
  */
  FUNCTION check_addendum_type
  (
    par_policy_id           NUMBER
   ,par_addendum_type_brief VARCHAR2
  ) RETURN NUMBER;

  /* sergey.ilyushkin 30/07/2012
  Контроль застрахованного
  */
  PROCEDURE check_insured(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 30/07/2012
  Контроль андеррайтинга
  */
  PROCEDURE check_underwriting(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль страхователя
  */
  PROCEDURE check_policy_holder(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль брутто-взноса
  */
  PROCEDURE check_brutto(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль кол-ва изменений срока страхования
  */
  PROCEDURE check_count_period_change(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль максимального срока действия договора
  */
  PROCEDURE check_max_end_date(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль срока страхования по FLA\BLA
  */
  PROCEDURE check_year_count_fla(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль срока страхования по PLA
  */
  PROCEDURE check_year_count_bla(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль периодичности
  */
  PROCEDURE check_periodic(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль прошедшего периода действия договора
  */
  PROCEDURE check_prev_period(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 31/07/2012
  Контроль даты окончания действия договора
  */
  PROCEDURE check_end_date(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 01/08/2012
  Контроль риска дожитие в основной программе
  */
  PROCEDURE check_cover(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 01/08/2012
  Контроль кол-ва изменений страховой суммы
  */
  PROCEDURE check_count_amount_change(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 01/08/2012
  Контроль осн. программ для FLA
  */
  PROCEDURE check_rec_prog_fla(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 01/08/2012
  Контроль доп. программ для FLA
  */
  PROCEDURE check_opt_prog_fla(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 01/08/2012
  Контроль периодичности (уменьшение взноса)
  */
  PROCEDURE check_periodic_premium(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 01/08/2012
  Контроль кол-ва уменьшений страхового взноса
  */
  PROCEDURE check_count_premium_change(par_policy_id IN NUMBER);

  /* sergey.ilyushkin 01/08/2012
  Контроль размера страхового взноса
  */
  PROCEDURE check_premium_change(par_policy_id IN NUMBER);

  /* roman.zyong 07/11/2014
  Контроль наличия права "Ручной перевод автоматических статусов"
  */
  PROCEDURE check_manual_status_change(par_policy_id IN NUMBER);

  /*
  * Контроль даты расторжения при аннулировании
  * Дата расторжения по причине с типом Анунлирование не может быть больше
  * даты начала действия договора
  * @param par_policy_id - ИД версии договора страхования
  */
  PROCEDURE check_decline_date_annulate(par_policy_id NUMBER);

  /**
   * Процедура проверки типа изменений ДС до 3-й годовщины на переходе Проект-Новый
   * @author Черных М. 26.05.2015
   * @param par_policy_id  ИД версии ДС
  */
  PROCEDURE check_change_addendum_type(par_policy_id p_policy.policy_id%TYPE);
END pkg_policy_checks;
/
CREATE OR REPLACE PACKAGE BODY pkg_policy_checks AS
  /******************************************************************************
     NAME:       PKG_POLICY_CHECKS
     PURPOSE:    Набор процедур проверки создания новой версии договора страхования
  
     REVISIONS:
     Ver        Date        Author           Description
     ---------  ----------  ---------------  ------------------------------------
     1.0        30.07.2012      sergey.ilyushkin       1. Created this package body.
  ******************************************************************************/

  /* sergey.ilyushkin 30/07/2012
  Проверяет наличее указанного типа изменения у версии
  @param par_policy_id - ИД версии
  @param par_addendum_type_brief - Краткое наименование типа изменения
  @return: 1 - версия имеет данный тип изменения; 0 - не имеет
  */
  FUNCTION check_addendum_type
  (
    par_policy_id           NUMBER
   ,par_addendum_type_brief VARCHAR2
  ) RETURN NUMBER IS
    v_ret_val NUMBER := 0;
  BEGIN
    SELECT 1
      INTO v_ret_val
      FROM p_pol_addendum_type pat
          ,t_addendum_type     tat
     WHERE pat.p_policy_id = par_policy_id
       AND tat.t_addendum_type_id = pat.t_addendum_type_id
       AND upper(tat.brief) = par_addendum_type_brief;
  
    RETURN v_ret_val;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 0;
    WHEN OTHERS THEN
      RETURN NULL;
  END check_addendum_type;

  /* sergey.ilyushkin 30/07/2012
  Возвращает краткое наименование продукта по договору
  @param par_policy_id - ИД версии договора
  @return - краткое наименование продукта
  */
  FUNCTION get_policy_product_brief(par_policy_id NUMBER) RETURN VARCHAR2 IS
    v_product_brief VARCHAR2(100) := NULL;
  BEGIN
    SELECT pr.brief
      INTO v_product_brief
      FROM p_policy     pp
          ,p_pol_header pph
          ,t_product    pr
     WHERE pp.policy_id = par_policy_id
       AND pph.policy_header_id = pp.pol_header_id
       AND pr.product_id = pph.product_id;
  
    RETURN v_product_brief;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_policy_product_brief;

  /* sergey.ilyushkin 31/07/2012
  Возвращает наименование продукта по договору
  @param par_policy_id - ИД версии договора
  @return - наименование продукта
  */
  FUNCTION get_policy_product_name(par_policy_id NUMBER) RETURN VARCHAR2 IS
    v_product_name VARCHAR2(2000) := NULL;
  BEGIN
    SELECT pr.description
      INTO v_product_name
      FROM p_policy     pp
          ,p_pol_header pph
          ,t_product    pr
     WHERE pp.policy_id = par_policy_id
       AND pph.policy_header_id = pp.pol_header_id
       AND pr.product_id = pph.product_id;
  
    RETURN v_product_name;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_policy_product_name;

  /* sergey.ilyushkin 30/07/2012
  Контроль застрахованного
  */
  PROCEDURE check_insured(par_policy_id IN NUMBER) IS
    v_prev_ver_id      NUMBER := NULL;
    v_old_assured_id   NUMBER := NULL;
    v_new_assured_id   NUMBER := NULL;
    v_is_contact       NUMBER := 0;
    l_contact_ins_id   NUMBER := NULL;
    l_contact_insur_id NUMBER := NULL;
    cnt_prev_ver       NUMBER := 0;
    cnt_cur_ver        NUMBER := 0;
    v_is_err           NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'POLICY_HOLDER_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'Family La'
       ,'Family_La2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Внимание! Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Внимание! Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    BEGIN
      SELECT ppc.contact_id
        INTO l_contact_ins_id
        FROM ins.p_policy           pol
            ,ins.p_policy_contact   ppc
            ,ins.t_contact_pol_role cpr
       WHERE pol.policy_id = v_prev_ver_id
         AND pol.policy_id = ppc.policy_id
         AND ppc.contact_policy_role_id = cpr.id
         AND cpr.brief = 'Страхователь';
      FOR cur IN (SELECT a.as_asset_id
                    FROM ins.as_asset   a
                        ,ins.as_assured ass
                   WHERE a.as_asset_id = ass.as_assured_id
                     AND ass.assured_contact_id = l_contact_ins_id
                     AND a.p_policy_id = v_prev_ver_id)
      LOOP
        v_is_contact := v_is_contact + 1;
      END LOOP;
    
      IF v_is_contact > 0
      THEN
        SELECT COUNT(*) INTO cnt_prev_ver FROM ins.as_asset a WHERE a.p_policy_id = v_prev_ver_id;
        SELECT COUNT(*) INTO cnt_cur_ver FROM ins.as_asset a WHERE a.p_policy_id = par_policy_id;
        IF cnt_prev_ver = cnt_cur_ver
        THEN
          FOR insur IN (SELECT ass.assured_contact_id
                          FROM ins.as_asset   a
                              ,ins.as_assured ass
                         WHERE a.as_asset_id = ass.as_assured_id
                           AND a.p_policy_id = v_prev_ver_id)
          LOOP
          
            BEGIN
              SELECT ass.assured_contact_id
                INTO l_contact_insur_id
                FROM ins.as_asset   a
                    ,ins.as_assured ass
               WHERE a.as_asset_id = ass.as_assured_id
                 AND ass.assured_contact_id = insur.assured_contact_id
                 AND a.p_policy_id = par_policy_id;
            EXCEPTION
              WHEN no_data_found THEN
                v_is_err           := 1;
                l_contact_insur_id := NULL;
            END;
          
          END LOOP;
        
        END IF;
      END IF;
    
      /*select aa1.contact_id,
            AA2.CONTACT_ID
       into v_old_assured_id,
            v_new_assured_id
       from p_policy_contact ppc,
            t_contact_pol_role cpr,
            ven_as_assured aa1,
            ven_as_assured aa2
      where ppc.policy_id = v_prev_ver_id
        and CPR.id = PPC.CONTACT_POLICY_ROLE_ID
        and CPR.BRIEF = 'Страхователь'
        and AA1.CONTACT_ID = PPC.CONTACT_ID
        and AA1.P_POLICY_ID = PPC.POLICY_ID
        and AA2.CONTACT_ID(+) = PPC.CONTACT_ID
        and AA2.P_POLICY_ID = par_policy_id;*/
    
      IF (cnt_prev_ver <> cnt_cur_ver)
         OR v_is_err = 1
      THEN
        pkg_forms_message.put_message('Внимание! Страхователь и Застрахованный по предыдущей версии – одно лицо, изменение Застрахованного запрещено.');
        raise_application_error(-20000
                               ,'Внимание! Страхователь и Застрахованный по предыдущей версии – одно лицо, изменение Застрахованного запрещено.');
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN;
      WHEN OTHERS THEN
        raise_application_error(SQLCODE, SQLERRM);
    END;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_insured;

  /* sergey.ilyushkin 30/07/2012
  Контроль андеррайтинга
  */
  PROCEDURE check_underwriting(par_policy_id IN NUMBER) IS
    v_addendum_type_name VARCHAR2(500) := NULL;
    is_exists            NUMBER := 0;
  BEGIN
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'Family La'
       ,'Family_La2'
       ,'Investor')
    THEN
      RETURN;
    END IF;
  
    SELECT COUNT(*)
      INTO is_exists
      FROM ins.p_policy pol
     WHERE pol.policy_id = par_policy_id
       AND EXISTS (SELECT NULL
              FROM ins.p_pol_addendum_type pat
                  ,ins.t_addendum_type     tat
             WHERE pat.p_policy_id = pol.policy_id
               AND pat.t_addendum_type_id = tat.t_addendum_type_id
               AND upper(tat.brief) IN ('PERIOD_CHANGE'
                                       ,'POLICY_HOLDER_CHANGE'
                                       ,'FEE_INCREASE'
                                       ,'FEE_CHANGE'
                                       ,'ASSET_KINDER_CHANGE'
                                       ,'INCREASE_SIZE_OF_THE_TOTAL_PREMIUM'
                                       ,'COVER_ADDING'));
  
    IF is_exists > 0
    THEN
      SELECT tat.description
        INTO v_addendum_type_name
        FROM ins.p_policy            pol
            ,ins.p_pol_addendum_type pat
            ,ins.t_addendum_type     tat
       WHERE pol.policy_id = par_policy_id
         AND pat.p_policy_id = pol.policy_id
         AND pat.t_addendum_type_id = tat.t_addendum_type_id
         AND upper(tat.brief) IN ('PERIOD_CHANGE'
                                 ,'POLICY_HOLDER_CHANGE'
                                 ,'FEE_INCREASE'
                                 ,'FEE_CHANGE'
                                 ,'ASSET_KINDER_CHANGE'
                                 ,'INCREASE_SIZE_OF_THE_TOTAL_PREMIUM'
                                 ,'COVER_ADDING')
         AND rownum = 1;
      pkg_forms_message.put_message('Внимание! Для версии с типом "' || v_addendum_type_name ||
                                    '" обязательно прохождение процедуры андеррайтинга. Возможен переход в статус "Нестандартный".');
      raise_application_error(-20000
                             ,'Внимание! Для версии с типом "' || v_addendum_type_name ||
                              '" обязательно прохождение процедуры андеррайтинга. Возможен переход в статус "Нестандартный".');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_underwriting;

  /* sergey.ilyushkin 31/07/2012
  Контроль страхователя
  */
  PROCEDURE check_policy_holder(par_policy_id IN NUMBER) IS
    v_policy_holder_id NUMBER := NULL;
    v_assured_id       NUMBER := NULL;
    l_contact_ins_id   NUMBER := NULL;
    v_is_err           NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'POLICY_HOLDER_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN ('Family La', 'Family_La2')
    THEN
      RETURN;
    END IF;
  
    SELECT ppc.contact_id
      INTO l_contact_ins_id
      FROM ins.p_policy           pol
          ,ins.p_policy_contact   ppc
          ,ins.t_contact_pol_role cpr
     WHERE pol.policy_id = par_policy_id
       AND pol.policy_id = ppc.policy_id
       AND ppc.contact_policy_role_id = cpr.id
       AND cpr.brief = 'Страхователь';
  
    FOR cur IN (SELECT a.as_asset_id
                  FROM ins.as_asset   a
                      ,ins.as_assured ass
                 WHERE a.as_asset_id = ass.as_assured_id
                   AND ass.assured_contact_id = l_contact_ins_id
                   AND a.p_policy_id = par_policy_id)
    LOOP
      v_is_err := 1;
    END LOOP;
  
    IF v_is_err = 0
    THEN
      pkg_forms_message.put_message('Внимание! Для продукта "' ||
                                    get_policy_product_name(par_policy_id) ||
                                    '" страхователем должен быть один из застрахованных.');
      raise_application_error(-20000
                             ,'Внимание! Для продукта "' || get_policy_product_name(par_policy_id) ||
                              '" страхователем должен быть один из застрахованных.');
    END IF;
  
    /*  begin
      select ppc.contact_id,
             AA1.CONTACT_ID
        into v_policy_holder_id,
             v_assured_id
        from p_policy_contact ppc,
             t_contact_pol_role cpr,
             ven_as_assured aa1
       where ppc.policy_id = par_policy_id
         and CPR.id = PPC.CONTACT_POLICY_ROLE_ID
         and CPR.BRIEF = 'Страхователь'
         and AA1.CONTACT_ID = PPC.CONTACT_ID
         and AA1.P_POLICY_ID = PPC.POLICY_ID;
    exception
      when no_data_found then
        PKG_FORMS_MESSAGE.PUT_MESSAGE('Внимание! Для продукта "'||Get_Policy_Product_Name(par_policy_id)||'" страхователем должен быть один из застрахованных.');
        RAISE_APPLICATION_ERROR(-20000, 'Внимание! Для продукта "'||Get_Policy_Product_Name(par_policy_id)||'" страхователем должен быть один из застрахованных.');
      when others then
        RAISE_APPLICATION_ERROR(sqlcode, sqlerrm);
    end;*/
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_policy_holder;

  /* sergey.ilyushkin 31/07/2012
  Контроль брутто-взноса
  */
  PROCEDURE check_brutto(par_policy_id IN NUMBER) IS
    v_prev_ver_id    NUMBER := NULL;
    v_old_brutto_sum NUMBER := NULL;
    v_new_brutto_sum NUMBER := NULL;
  BEGIN
    IF check_addendum_type(par_policy_id, 'PERIOD_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'Family La'
       ,'Family_La2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Внимание! Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Внимание! Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    SELECT ROUND(SUM(a.fee), 2) AS old_brutto_sum
      INTO v_old_brutto_sum
      FROM as_asset        a
          ,ins.status_hist st
     WHERE a.p_policy_id = v_prev_ver_id
       AND a.status_hist_id = st.status_hist_id
       AND st.brief != 'DELETED';
  
    SELECT ROUND(SUM(a.fee), 2) AS new_brutto_sum
      INTO v_new_brutto_sum
      FROM as_asset        a
          ,ins.status_hist st
     WHERE a.p_policy_id = par_policy_id
       AND a.status_hist_id = st.status_hist_id
       AND st.brief != 'DELETED';
  
    IF v_old_brutto_sum <> v_new_brutto_sum
    THEN
      pkg_forms_message.put_message('Внимание! Для типа изменений "Изменение срока страхования" изменение брутто-взноса запрещено. Брутто-взнос не соответствует предыдущей версии');
      raise_application_error(-20000
                             ,'Внимание! Для типа изменений "Изменение срока страхования" изменение брутто-взноса запрещено. Брутто-взнос не соответствует предыдущей версии');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_brutto;

  /* sergey.ilyushkin 31/07/2012
  Контроль кол-ва изменений срока страхования
  */
  PROCEDURE check_count_period_change(par_policy_id IN NUMBER) IS
    v_count NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'PERIOD_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'Family La'
       ,'Family_La2')
    THEN
      RETURN;
    END IF;
  
    SELECT COUNT(pol.policy_id)
      INTO v_count
      FROM ven_p_policy     pp
          ,ins.ven_p_policy pol
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = pol.pol_header_id
       AND pol.doc_status_ref_id NOT IN
           (SELECT doc_status_ref_id FROM doc_status_ref WHERE brief = 'CANCEL')
       AND ins.pkg_policy_checks.check_addendum_type(pol.policy_id, 'PERIOD_CHANGE') = 1
       AND pol.policy_id != pp.policy_id;
  
    IF v_count > 0
    THEN
      pkg_forms_message.put_message('Внимание! Создание версии с типом "Изменение срока страхования" возможно не более 1-го раза в течении действия договора.');
      raise_application_error(-20000
                             ,'Внимание! Создание версии с типом "Изменение срока страхования" возможно не более 1-го раза в течении действия договора.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_count_period_change;

  /* sergey.ilyushkin 31/07/2012
  Контроль максимального срока действия договора
  */
  PROCEDURE check_max_end_date(par_policy_id IN NUMBER) IS
    v_prev_ver_id NUMBER := NULL;
    v_new_period  NUMBER := NULL;
    v_old_period  NUMBER := NULL;
  BEGIN
    IF check_addendum_type(par_policy_id, 'PERIOD_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'Family La'
       ,'Family_La2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    SELECT ROUND((pp2.end_date - pp2.start_date) / 2)
          ,pp1.end_date - pp2.end_date
      INTO v_old_period
          ,v_new_period
      FROM p_policy pp1
          ,p_policy pp2
     WHERE pp1.policy_id = par_policy_id
       AND pp2.policy_id = v_prev_ver_id;
  
    IF v_new_period > v_old_period
    THEN
      pkg_forms_message.put_message('Внимание! Увеличение срока действия возможно в пределах 1/2 от срока страхования, установленного в договоре до внесения изменений.');
      raise_application_error(-20000
                             ,'Внимание! Увеличение срока действия возможно в пределах 1/2 от срока страхования, установленного в договоре до внесения изменений.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_max_end_date;

  /* sergey.ilyushkin 31/07/2012
  Контроль срока страхования по FLA\BLA
  */
  PROCEDURE check_year_count_fla(par_policy_id IN NUMBER) IS
    v_year_count NUMBER := NULL;
  BEGIN
    IF check_addendum_type(par_policy_id, 'PERIOD_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('Baby_LA', 'Baby_LA2', 'Family La', 'Family_La2')
    THEN
      RETURN;
    END IF;
  
    SELECT MONTHS_BETWEEN((pp.end_date + 1), pp.start_date) / 12
      INTO v_year_count
      FROM p_policy pp
     WHERE pp.policy_id = par_policy_id;
  
    IF v_year_count NOT IN (10, 12, 14, 16, 18, 20)
    THEN
      pkg_forms_message.put_message('Внимание! Для продукта "' ||
                                    get_policy_product_name(par_policy_id) ||
                                    '" возможно изменить срок действия только на 10, 12, 14, 16, 18 или 20 лет');
      raise_application_error(-20000
                             ,'Внимание! Для продукта "' || get_policy_product_name(par_policy_id) ||
                              '" возможно изменить срок действия только на 10, 12, 14, 16, 18 или 20 лет');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_year_count_fla;

  /* sergey.ilyushkin 31/07/2012
  Контроль срока страхования по PLA
  */
  PROCEDURE check_year_count_bla(par_policy_id IN NUMBER) IS
    v_year_count NUMBER := NULL;
  BEGIN
    IF check_addendum_type(par_policy_id, 'PERIOD_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN ('Platinum_LA', 'Platinum_LA2')
    THEN
      RETURN;
    END IF;
  
    SELECT MONTHS_BETWEEN((pp.end_date + 1), pp.start_date) / 12
      INTO v_year_count
      FROM p_policy pp
     WHERE pp.policy_id = par_policy_id;
  
    IF v_year_count NOT IN (10, 15, 20)
    THEN
      pkg_forms_message.put_message('Внимание! Для продукта "' ||
                                    get_policy_product_name(par_policy_id) ||
                                    '" возможно изменить срок действия только на 10, 15 или 20 лет');
      raise_application_error(-20000
                             ,'Внимание! Для продукта "' || get_policy_product_name(par_policy_id) ||
                              '" возможно изменить срок действия только на 10, 15 или 20 лет');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_year_count_bla;

  /* sergey.ilyushkin 31/07/2012
  Контроль периодичности
  */
  PROCEDURE check_periodic(par_policy_id IN NUMBER) IS
    v_prev_ver_id NUMBER := NULL;
    v_new_period  VARCHAR2(100) := NULL;
    v_old_period  VARCHAR2(100) := NULL;
    v_prev_period NUMBER := 0;
    v_cur_period  NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'COL_METHOD_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END', 'CHI', 'PEPR', 'TERM', 'END_2', 'CHI_2', 'PEPR_2', 'TERM_2', 'Life_GF')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
    SELECT COUNT(*)
      INTO v_prev_period
      FROM ins.p_policy        po
          ,ins.t_payment_terms trm
     WHERE po.policy_id = v_prev_ver_id
       AND po.payment_term_id = trm.id
       AND trm.brief = 'Единовременно';
  
    SELECT COUNT(*)
      INTO v_cur_period
      FROM ins.p_policy        po
          ,ins.t_payment_terms trm
     WHERE po.policy_id = par_policy_id
       AND po.payment_term_id = trm.id
       AND trm.brief = 'Единовременно';
  
    SELECT trm.description
      INTO v_old_period
      FROM ins.p_policy        po
          ,ins.t_payment_terms trm
     WHERE po.policy_id = v_prev_ver_id
       AND po.payment_term_id = trm.id;
  
    IF v_prev_period > 0
    THEN
      pkg_forms_message.put_message('Внимание! По договорам с периодичностью "Единовременно" невозможно создание версии с типом "Изменение формы оплаты договора".');
      raise_application_error(-20000
                             ,'Внимание! По договорам с периодичностью "Единовременно" невозможно создание версии с типом "Изменение формы оплаты договора".');
    END IF;
  
    IF v_cur_period > 0
       AND v_prev_period = 0
    THEN
      pkg_forms_message.put_message('Внимание! По договорам с периодичностью "' || v_old_period ||
                                    '" невозможно изменение периодичности на "Единовременно".');
      raise_application_error(-20000
                             ,'Внимание! По договорам с периодичностью "' || v_old_period ||
                              '" невозможно изменение периодичности на "Единовременно".');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_periodic;

  /* sergey.ilyushkin 31/07/2012
  Контроль прошедшего периода действия договора
  */
  PROCEDURE check_prev_period(par_policy_id IN NUMBER) IS
    v_prev_ver_id NUMBER := NULL;
    v_count       NUMBER := 0;
    v_half_priod  NUMBER := NULL;
    v_prev_period NUMBER := NULL;
  BEGIN
    IF check_addendum_type(par_policy_id, 'COVER_ADDING') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'Family La'
       ,'Family_La2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    SELECT COUNT(*)
      INTO v_count
      FROM p_cover  pc
          ,as_asset aa
     WHERE pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = par_policy_id
       AND pc.t_prod_line_option_id IN
           (SELECT plo.id
              FROM t_prod_line_option plo
                  ,t_product_line     pl
             WHERE plo.product_line_id = pl.id
               AND ((pl.description = 'Первичное диагностирование смертельно опасного заболевания') OR
                   (pl.description =
                   'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе') OR
                   (pl.description =
                   'Освобождение от уплаты взносов рассчитанное по основной программе') OR
                   (pl.description = 'Защита страховых взносов') OR
                   (pl.description = 'Защита страховых взносов расчитанная по основной программе') OR
                   (pl.description = 'Защита страховых взносов рассчитанная по основной программе') OR
                   (pl.description = 'Инвалидность по любой причине') OR
                   (pl.description LIKE 'Госпитализация по любой причине%')))
       AND NOT EXISTS (SELECT 1
              FROM p_cover  pc1
                  ,as_asset aa1
             WHERE aa1.p_policy_id = v_prev_ver_id
               AND pc1.as_asset_id = aa1.as_asset_id
               AND pc1.t_prod_line_option_id = pc.t_prod_line_option_id);
  
    IF v_count > 0
    THEN
      SELECT ROUND((pp.end_date - pph.start_date) / 2)
            ,pp.start_date - pph.start_date
        INTO v_half_priod
            ,v_prev_period
        FROM ven_p_pol_header pph
            ,ven_p_policy     pp
       WHERE pp.policy_id = par_policy_id
         AND pph.policy_header_id = pp.pol_header_id;
    ELSE
      RETURN;
    END IF;
  
    IF v_prev_period > v_half_priod
    THEN
      pkg_forms_message.put_message('Внимание! Для добавления программ договор должен действовать не более половины от общего срока действия.');
      raise_application_error(-20000
                             ,'Внимание! Для добавления программ договор должен действовать не более половины от общего срока действия.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_prev_period;

  /* sergey.ilyushkin 31/07/2012
  Контроль даты окончания действия договора
  */
  PROCEDURE check_end_date(par_policy_id IN NUMBER) IS
    v_prev_ver_id NUMBER := NULL;
    v_count       NUMBER := 0;
    v_count_day   NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'COVER_ADDING') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'Family La'
       ,'Family_La2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    SELECT COUNT(*)
      INTO v_count
      FROM p_cover  pc
          ,as_asset aa
     WHERE pc.as_asset_id = aa.as_asset_id
       AND aa.p_policy_id = par_policy_id
       AND pc.t_prod_line_option_id IN
           (SELECT plo.id
              FROM t_prod_line_option plo
                  ,t_product_line     pl
             WHERE plo.product_line_id = pl.id
               AND ((pl.description = 'Первичное диагностирование смертельно опасного заболевания') OR
                   (pl.description =
                   'Освобождение от уплаты дальнейших взносов рассчитанное по основной программе') OR
                   (pl.description =
                   'Освобождение от уплаты взносов рассчитанное по основной программе') OR
                   (pl.description = 'Защита страховых взносов') OR
                   (pl.description = 'Защита страховых взносов расчитанная по основной программе') OR
                   (pl.description = 'Защита страховых взносов рассчитанная по основной программе') OR
                   (pl.description = 'Инвалидность по любой причине') OR
                   (pl.description LIKE 'Госпитализация по любой причине%') OR
                   (pl.description = 'ИНВЕСТ') OR (pl.description = 'ИНВЕСТ2')))
       AND NOT EXISTS (SELECT 1
              FROM p_cover  pc1
                  ,as_asset aa1
             WHERE aa1.p_policy_id = v_prev_ver_id
               AND pc1.as_asset_id = aa1.as_asset_id
               AND pc1.t_prod_line_option_id = pc.t_prod_line_option_id);
  
    IF v_count > 0
    THEN
      SELECT MONTHS_BETWEEN(pp.end_date + 1 / 24 / 3600, pp.start_date) / 12
        INTO v_count_day
        FROM ven_p_policy pp
       WHERE pp.policy_id = par_policy_id;
    ELSE
      RETURN;
    END IF;
  
    IF v_count_day < 5
    THEN
      pkg_forms_message.put_message('Внимание! До окончания действия договора менее 5-ти лет.');
      raise_application_error(-20000
                             ,'Внимание! До окончания действия договора менее 5-ти лет.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_end_date;

  /* sergey.ilyushkin 01/08/2012
  Контроль риска дожитие в основной программе
  */
  PROCEDURE check_cover(par_policy_id IN NUMBER) IS
    v_prev_ver_id NUMBER := NULL;
    v_count       NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'FEE_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END', 'CHI', 'PEPR', 'TERM', 'END_2', 'CHI_2', 'PEPR_2', 'TERM_2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    SELECT COUNT(*)
      INTO v_count
      FROM p_cover             pc1
          ,p_cover             pc2
          ,as_asset            aa1
          ,as_asset            aa2
          ,t_prod_line_option  plo
          ,t_product_line      pl
          ,t_product_line_type plt
     WHERE aa1.p_policy_id = par_policy_id
       AND pc1.as_asset_id = aa1.as_asset_id
       AND aa2.p_policy_id = v_prev_ver_id
       AND pc2.as_asset_id = aa2.as_asset_id
       AND pc2.t_prod_line_option_id = pc1.t_prod_line_option_id
       AND pc1.ins_amount <> pc2.ins_amount
       AND plo.id = pc1.t_prod_line_option_id
       AND pl.id = plo.product_line_id
       AND plt.product_line_type_id = pl.product_line_type_id
       AND plt.brief = 'RECOMMENDED'
       AND NOT EXISTS
     (SELECT 1
              FROM t_prod_line_opt_peril plop
                  ,t_peril               tp
             WHERE plop.product_line_option_id = plo.id
               AND tp.id = plop.peril_id
               AND tp.description =
                   'Дожитие Застрахованного лица до установленной даты или даты окончания срока страхования');
  
    IF v_count > 0
    THEN
      pkg_forms_message.put_message('Внимание! Изменение страховой суммы возможно только для основных программ, включающих риск “Дожитие застрахованного до конца срока страхования”');
      raise_application_error(-20000
                             ,'Внимание! Изменение страховой суммы возможно только для основных программ, включающих риск “Дожитие застрахованного до конца срока страхования”');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_cover;

  /* sergey.ilyushkin 01/08/2012
  Контроль кол-ва изменений страховой суммы
  */
  PROCEDURE check_count_amount_change(par_policy_id IN NUMBER) IS
    v_count NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'FEE_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'Family La'
       ,'Family_La2')
    THEN
      RETURN;
    END IF;
  
    SELECT COUNT(pol.policy_id)
      INTO v_count
      FROM ven_p_policy     pp
          ,ins.ven_p_policy pol
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = pol.pol_header_id
       AND pol.doc_status_ref_id NOT IN
           (SELECT doc_status_ref_id FROM doc_status_ref WHERE brief = 'CANCEL')
       AND ins.pkg_policy_checks.check_addendum_type(pol.policy_id, 'FEE_CHANGE') = 1
       AND pol.policy_id != pp.policy_id;
  
    IF v_count > 0
    THEN
      pkg_forms_message.put_message('Внимание! Создание версии с типом "Изменение страховой суммы по программе" возможно не более 1-го раза в течении действия договора.');
      raise_application_error(-20000
                             ,'Внимание! Создание версии с типом "Изменение страховой суммы по программе" возможно не более 1-го раза в течении действия договора.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_count_amount_change;

  /* sergey.ilyushkin 01/08/2012
  Контроль доп. программ для FLA
  */
  PROCEDURE check_opt_prog_fla(par_policy_id IN NUMBER) IS
    v_prev_ver_id        NUMBER := NULL;
    v_change_adult_count NUMBER := 0;
    v_change_child_count NUMBER := 0;
    v_all_adult_count    NUMBER := 0;
    v_all_child_count    NUMBER := 0;
    v_asset_adult        NUMBER := NULL;
    v_asset_child        NUMBER := NULL;
  BEGIN
    IF check_addendum_type(par_policy_id, 'FEE_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN ('Family La', 'Family_La2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    BEGIN
      SELECT t_asset_type_id INTO v_asset_adult FROM t_asset_type WHERE brief = 'ASSET_PERSON_ADULT';
    
      SELECT t_asset_type_id INTO v_asset_child FROM t_asset_type WHERE brief = 'ASSET_PERSON_CHILD';
    EXCEPTION
      WHEN OTHERS THEN
        RETURN;
    END;
  
    SELECT SUM(decode(asset_type, v_asset_adult, asset_count, 0))
          ,SUM(decode(asset_type, v_asset_child, asset_count, 0))
      INTO v_change_adult_count
          ,v_change_child_count
      FROM (SELECT COUNT(as_asset_id) AS asset_count
                  ,t_asset_type_id AS asset_type
              FROM (SELECT DISTINCT aa1.as_asset_id
                                   ,pah.t_asset_type_id
                      FROM p_cover             pc1
                          ,p_cover             pc2
                          ,as_asset            aa1
                          ,as_asset            aa2
                          ,t_prod_line_option  plo
                          ,t_product_line      pl
                          ,t_product_line_type plt
                          ,p_asset_header      pah
                          ,t_asset_type        tat
                     WHERE aa1.p_policy_id = par_policy_id
                       AND pc1.as_asset_id = aa1.as_asset_id
                       AND aa2.p_policy_id = v_prev_ver_id
                       AND pc2.as_asset_id = aa2.as_asset_id
                       AND pc2.t_prod_line_option_id = pc1.t_prod_line_option_id
                       AND pc1.ins_amount <> pc2.ins_amount
                       AND plo.id = pc1.t_prod_line_option_id
                       AND pl.id = plo.product_line_id
                       AND plt.product_line_type_id = pl.product_line_type_id
                       AND plt.brief IN ('OPTIONAL', 'MANDATORY')
                       AND pah.p_asset_header_id = aa1.p_asset_header_id)
             GROUP BY t_asset_type_id);
  
    SELECT SUM(decode(asset_type, v_asset_adult, asset_count, 0))
          ,SUM(decode(asset_type, v_asset_child, asset_count, 0))
      INTO v_all_adult_count
          ,v_all_child_count
      FROM (SELECT COUNT(as_asset_id) AS asset_count
                  ,t_asset_type_id AS asset_type
              FROM as_asset       aa
                  ,p_asset_header pah
             WHERE p_policy_id = par_policy_id
               AND pah.p_asset_header_id = aa.p_asset_header_id
             GROUP BY t_asset_type_id);
  
    IF (v_change_adult_count <> v_all_adult_count)
       OR (v_change_child_count <> v_all_child_count)
    THEN
      pkg_forms_message.put_message('Внимание! Невозможно изменение страховой суммы по дополнительным программам отдельно для каждого родителя, либо отдельно для каждого ребенка');
      raise_application_error(-20000
                             ,'Внимание! Невозможно изменение страховой суммы по дополнительным программам отдельно для каждого родителя, либо отдельно для каждого ребенка');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_opt_prog_fla;

  /* sergey.ilyushkin 01/08/2012
  Контроль осн. программ для FLA
  */
  PROCEDURE check_rec_prog_fla(par_policy_id IN NUMBER) IS
    v_prev_ver_id  NUMBER := NULL;
    v_change_count NUMBER := 0;
    v_all_count    NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'FEE_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN ('Family La', 'Family_La2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    SELECT COUNT(as_asset_id)
      INTO v_change_count
      FROM (SELECT DISTINCT aa1.as_asset_id
              FROM p_cover             pc1
                  ,p_cover             pc2
                  ,as_asset            aa1
                  ,as_asset            aa2
                  ,t_prod_line_option  plo
                  ,t_product_line      pl
                  ,t_product_line_type plt
             WHERE aa1.p_policy_id = par_policy_id
               AND pc1.as_asset_id = aa1.as_asset_id
               AND aa2.p_policy_id = v_prev_ver_id
               AND pc2.as_asset_id = aa2.as_asset_id
               AND pc2.t_prod_line_option_id = pc1.t_prod_line_option_id
               AND pc1.ins_amount <> pc2.ins_amount
               AND plo.id = pc1.t_prod_line_option_id
               AND pl.id = plo.product_line_id
               AND plt.product_line_type_id = pl.product_line_type_id
               AND plt.brief = 'RECOMMENDED');
  
    SELECT COUNT(as_asset_id) INTO v_all_count FROM as_asset WHERE p_policy_id = par_policy_id;
  
    IF v_change_count <> v_all_count
    THEN
      pkg_forms_message.put_message('Внимание! Невозможно изменение страховой суммы по основным программам отдельно для каждого родителя');
      raise_application_error(-20000
                             ,'Внимание! Невозможно изменение страховой суммы по основным программам отдельно для каждого родителя');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_rec_prog_fla;

  /* sergey.ilyushkin 01/08/2012
  Контроль периодичности (уменьшение взноса)
  */
  PROCEDURE check_periodic_premium(par_policy_id IN NUMBER) IS
    v_period VARCHAR2(100) := NULL;
  BEGIN
    IF check_addendum_type(par_policy_id, 'PREMIUM_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'PRIN'
       ,'PRIN_DP_NEW'
       ,'Life_GF'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2')
    THEN
      RETURN;
    END IF;
  
    SELECT pt.description
      INTO v_period
      FROM p_policy        pp
          ,t_payment_terms pt
     WHERE pp.policy_id = par_policy_id
       AND pt.id = pp.payment_term_id;
  
    IF v_period = 'Единовременно'
    THEN
      pkg_forms_message.put_message('Внимание! По договорам с периодичностью "Единовременно" невозможно создание версии с типом "Уменьшение размера страхового взноса".');
      raise_application_error(-20000
                             ,'Внимание! По договорам с периодичностью "Единовременно" невозможно создание версии с типом "Уменьшение размера страхового взноса".');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_periodic_premium;

  /* sergey.ilyushkin 01/08/2012
  Контроль кол-ва уменьшений страхового взноса
  */
  PROCEDURE check_count_premium_change(par_policy_id IN NUMBER) IS
    v_count NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'PREMIUM_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN
       ('END'
       ,'CHI'
       ,'PEPR'
       ,'TERM'
       ,'PRIN'
       ,'PRIN_DP_NEW'
       ,'Life_GF'
       ,'Platinum_LA'
       ,'Platinum_LA2'
       ,'Baby_LA'
       ,'Baby_LA2'
       ,'END_2'
       ,'CHI_2'
       ,'PEPR_2'
       ,'TERM_2')
    THEN
      RETURN;
    END IF;
  
    SELECT COUNT(pol.policy_id)
      INTO v_count
      FROM ven_p_policy     pp
          ,ins.ven_p_policy pol
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = pol.pol_header_id
       AND pol.doc_status_ref_id NOT IN
           (SELECT doc_status_ref_id FROM doc_status_ref WHERE brief = 'CANCEL')
       AND ins.pkg_policy_checks.check_addendum_type(pol.policy_id, 'PREMIUM_CHANGE') = 1
       AND pol.policy_id != pp.policy_id;
  
    IF v_count > 0
    THEN
      pkg_forms_message.put_message('Внимание! Создание версии с типом "Уменьшение размера страхового взноса" возможно не более 1-го раза в течении действия договора.');
      raise_application_error(-20000
                             ,'Внимание! Создание версии с типом "Уменьшение размера страхового взноса" возможно не более 1-го раза в течении действия договора.');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_count_premium_change;

  /* sergey.ilyushkin 01/08/2012
  Контроль размера страхового взноса
  */
  PROCEDURE check_premium_change(par_policy_id IN NUMBER) IS
    v_prev_ver_id  NUMBER := NULL;
    v_change_count NUMBER := 0;
    v_all_count    NUMBER := 0;
  BEGIN
    IF check_addendum_type(par_policy_id, 'PREMIUM_CHANGE') <> 1
    THEN
      RETURN;
    END IF;
  
    IF get_policy_product_brief(par_policy_id) NOT IN ('Family La', 'Family_La2')
    THEN
      RETURN;
    END IF;
  
    BEGIN
      SELECT prev_ver_id INTO v_prev_ver_id FROM p_policy WHERE policy_id = par_policy_id;
    EXCEPTION
      WHEN no_data_found THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.');
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка.');
      WHEN OTHERS THEN
        pkg_forms_message.put_message('Не удалось установить версию-предка.' || SQLERRM);
        raise_application_error(-20000
                               ,'Не удалось установить версию-предка. ' || SQLERRM);
    END;
  
    SELECT COUNT(as_asset_id)
      INTO v_change_count
      FROM (SELECT DISTINCT aa1.as_asset_id
              FROM p_cover            pc1
                  ,p_cover            pc2
                  ,as_asset           aa1
                  ,as_asset           aa2
                  ,t_prod_line_option plo
                  ,t_product_line
             WHERE aa1.p_policy_id = par_policy_id
               AND pc1.as_asset_id = aa1.as_asset_id
               AND aa2.p_policy_id = v_prev_ver_id
               AND pc2.as_asset_id = aa2.as_asset_id
               AND pc2.t_prod_line_option_id = pc1.t_prod_line_option_id
               AND pc1.ins_amount <> pc2.ins_amount
               AND plo.id = pc1.t_prod_line_option_id);
  
    SELECT COUNT(as_asset_id) INTO v_all_count FROM as_asset WHERE p_policy_id = par_policy_id;
  
    IF v_change_count <> v_all_count
    THEN
      pkg_forms_message.put_message('Внимание! Невозможно уменьшение страхового взноса по отдельным застрахованным, возможно только в целом по договору');
      raise_application_error(-20000
                             ,'Внимание! Невозможно уменьшение страхового взноса по отдельным застрахованным, возможно только в целом по договору');
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END check_premium_change;

  /* roman.zyong 07/11/2014
  Контроль наличия права "Ручной перевод автоматических статусов"
  */
  PROCEDURE check_manual_status_change(par_policy_id IN NUMBER) IS
    v_status_change_type status_change_type.brief%TYPE;
    v_is_right_exists    NUMBER;
    v_src_status         doc_status_ref.brief%TYPE;
    v_cur_status         doc_status_ref.brief%TYPE;
  BEGIN
    SELECT sct.brief
      INTO v_status_change_type
      FROM document           d
          ,doc_status         ds
          ,status_change_type sct
     WHERE d.doc_status_id = ds.doc_status_id
       AND ds.status_change_type_id = sct.status_change_type_id
       AND d.document_id = par_policy_id;
  
    SELECT COUNT(srr.safety_right_id)
      INTO v_is_right_exists
      FROM document          d
          ,doc_status        ds
          ,sys_user          su
          ,rel_role_user     rru
          ,safety_right_role srr
     WHERE d.doc_status_id = ds.doc_status_id
       AND ds.user_name = su.sys_user_name
       AND su.sys_user_id = rru.sys_user_id
       AND rru.sys_role_id = srr.role_id
       AND d.document_id = par_policy_id
       AND safety.get_right_brief(srr.safety_right_id) = 'AUTOMATIC_STATUS_MANUAL_CHANGE';
  
    IF v_status_change_type = 'MANUAL'
    THEN
      IF v_is_right_exists = 0
      THEN
        SELECT dsr_src.name src_brief
              ,dsr_cur.name cur_brief
          INTO v_src_status
              ,v_cur_status
          FROM document       d
              ,doc_status     ds
              ,doc_status_ref dsr_src
              ,doc_status_ref dsr_cur
         WHERE d.doc_status_id = ds.doc_status_id
           AND ds.src_doc_status_ref_id = dsr_src.doc_status_ref_id
           AND ds.doc_status_ref_id = dsr_cur.doc_status_ref_id
           AND d.document_id = par_policy_id;
      
        pkg_forms_message.put_message('Внимание! Переход статусов "' || v_src_status || ' -> ' ||
                                      v_cur_status ||
                                      '" доступен только для пользователей с правом "Ручной перевод автоматических статусов", обратитесь к своему руководителю.');
        raise_application_error(-20000
                               ,'Внимание! Переход статусов "' || v_src_status || ' -> ' ||
                                v_cur_status ||
                                '" доступен только для пользователей с правом "Ручной перевод автоматических статусов", обратитесь к своему руководителю.');
      ELSE
        NULL;
      END IF;
    ELSE
      NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(SQLCODE, SQLERRM);
  END;

  /*
  * Контроль даты расторжения при аннулировании
  * Дата расторжения по причине с типом Анунлирование не может быть больше
  * даты начала действия договора
  * @param par_policy_id - ИД версии договора страхования
  */
  PROCEDURE check_decline_date_annulate(par_policy_id NUMBER) IS
    v_policy                dml_p_policy.tt_p_policy;
    v_decline_type          dml_t_decline_type.tt_t_decline_type;
    v_decline_type_brief    t_decline_type.brief%TYPE;
    v_pol_header_start_date p_pol_header.start_date%TYPE;
    v_decline_date          p_policy.decline_date%TYPE;
  BEGIN
  
    SELECT ph.start_date
          ,dt.brief
          ,pp.decline_date
      INTO v_pol_header_start_date
          ,v_decline_type_brief
          ,v_decline_date
      FROM p_policy         pp
          ,p_pol_header     ph
          ,t_decline_reason dr
          ,t_decline_type   dt
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND pp.decline_reason_id = dr.t_decline_reason_id(+)
       AND dr.t_decline_type_id = dt.t_decline_type_id(+);
  
    IF v_decline_type_brief = 'Аннулирование'
       AND v_decline_date != v_pol_header_start_date
    THEN
      ex.raise_custom('Дата расторжения должна быть равна дате начала действия договора при аннулировании');
    END IF;
  
  END check_decline_date_annulate;
  /**
   * Процедура проверки типа изменений ДС до 3-й годовщины на переходе Проект-Новый
   * @author Черных М. 26.05.2015
   * @param par_policy_id  ИД версии ДС
  */
  PROCEDURE check_change_addendum_type(par_policy_id p_policy.policy_id%TYPE) IS
  
    /*Страховая сумма по любому из рисков новой версии меньше страховой суммы этого же риска предыдущей версии и Дата начала версии < 3й годовщины*/
    FUNCTION is_ins_amount_violation(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
        INTO v_count
        FROM dual
       WHERE EXISTS
       (SELECT NULL
                FROM p_policy            p_cur
                    ,p_pol_header        pph_cur
                    ,p_pol_addendum_type pat
                    ,t_addendum_type     tat
                    ,p_policy            p_prev
                    ,as_asset            as_cur
                    ,p_cover             cov_cur
                     
                    ,as_asset as_prev
                    ,p_cover  cov_prev
               WHERE p_cur.policy_id = par_policy_id
                 AND p_cur.pol_header_id = pph_cur.policy_header_id
                 AND p_cur.policy_id = pat.p_policy_id
                 AND tat.t_addendum_type_id = pat.t_addendum_type_id
                 AND tat.brief IN ('FEE_CHANGE') /*Изменение страховой суммы по программе*/
                 AND p_cur.prev_ver_id = p_prev.policy_id
                 AND as_cur.p_policy_id = p_cur.policy_id
                 AND cov_cur.as_asset_id = as_cur.as_asset_id
                    
                 AND as_prev.p_policy_id = p_prev.policy_id
                 AND cov_prev.as_asset_id = as_prev.as_asset_id
                 AND cov_cur.t_prod_line_option_id = cov_prev.t_prod_line_option_id /*Одни и теже риски*/
                 AND cov_cur.ins_amount < cov_prev.ins_amount /*Страховая сумма уменьшилась*/
                 AND p_cur.start_date < pkg_anniversary.get_anniversary(pph_cur.start_date, 3));
      RETURN v_count = 1;
    END is_ins_amount_violation;
  
  BEGIN
    /*
    381636 - Ограничение на создание новых версий ДС
    Условия наложить на типы «Измененеи страховой суммы по программе»
    - запретить их создание < 3-й годовщины
    Черных М. 13.5.2015, модифицировано 26.5.2015
    */
    IF is_ins_amount_violation(par_policy_id)
    THEN
      ex.raise_custom(par_message => 'Раньше третьей годовщины ДС запрещен данный тип изменений');
    END IF;

  END check_change_addendum_type;
END pkg_policy_checks;
/
