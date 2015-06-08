CREATE OR REPLACE PACKAGE pkg_q_quest_form IS

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 08.11.2010 21:12:51
  -- Purpose : Получает значение веса застрахованного
  FUNCTION q_height_default_value(par_q_question_id PLS_INTEGER) RETURN NUMBER;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 08.11.2010 21:12:51
  -- Purpose : Получает значение веса застрахованного
  FUNCTION q_weight_default_value(par_q_question_id PLS_INTEGER) RETURN NUMBER;

  -- ishch 17.11.2010 (
  -- Purpose : Получает значение возраста застрахованного
  FUNCTION q_age_default_value(par_q_question_id PLS_INTEGER) RETURN NUMBER;
  -- ishch )

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.10.2010
  -- Purpose : Контроль соотношения роста и веса
  FUNCTION q_weight_height_control(par_q_question_id PLS_INTEGER) RETURN NUMBER;

  -- Author  : Веселуха Е.В.
  -- Created : 18.06.2013
  -- Purpose : Контроль указания дохода при больших СС
  FUNCTION q_large_amount_control(par_q_question_id PLS_INTEGER) RETURN NUMBER;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.10.2010 13:18:14
  -- Purpose : Выдает ошибку (0), если ответ на вопрос ДА -- ishch 08.11.2010
  FUNCTION q_yes_control(par_q_question_id PLS_INTEGER) RETURN INTEGER;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.10.2010 13:18:14
  -- Purpose : Выдает ошибку (0), если ответ на вопрос НЕТ -- ishch 08.11.2010
  FUNCTION q_no_control(par_q_question_id PLS_INTEGER) RETURN INTEGER;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.10.2010 13:30:09
  -- Purpose : Проверка дохода застрахованного
  FUNCTION q_income_control(par_q_question_id PLS_INTEGER) RETURN INTEGER;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.02.2010 11:34:02
  -- Purpose : Пакет для обслуживания анкет
  PROCEDURE fill_questionnaire(par_q_quest_form_id PLS_INTEGER);

  -- Author  : ishch
  -- Created : 31.01.2010
  -- Purpose : Предварительная проверка анкет
  PROCEDURE pre_quest_form_check(par_policy_id PLS_INTEGER);

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 17.02.2010 16:03:55
  -- Purpose : Основная проверка анкет
  PROCEDURE main_quest_form_check(par_policy_id PLS_INTEGER);

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.02.2010 15:18:46
  -- Purpose : Открывает анкеты на редактирование
  PROCEDURE open_quest_form(par_policy_id PLS_INTEGER);

END pkg_q_quest_form;
/
CREATE OR REPLACE PACKAGE BODY pkg_q_quest_form IS

  g_quest_ent PLS_INTEGER := ent.id_by_brief('Q_QUESTIONS');
  q_message   VARCHAR2(60) := '';

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 08.11.2010 21:12:51
  -- Purpose : Получает значение веса застрахованного
  FUNCTION q_height_default_value(par_q_question_id PLS_INTEGER) RETURN NUMBER IS
    v_height  NUMBER;
    proc_name VARCHAR2(25) := 'q_height_default_value';
  BEGIN
  
    SELECT aa.height
      INTO v_height
      FROM q_questions    qq
          ,q_quest_form   qf
          ,p_policy       pp
          ,ven_as_assured aa
     WHERE qq.q_questions_id = par_q_question_id
       AND qq.q_quest_form_id = qf.q_quest_form_id
       AND qf.policy_id = pp.policy_id
       AND qf.contact_id = aa.assured_contact_id
       AND pp.policy_id = aa.p_policy_id;
  
    RETURN(v_height);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_height_default_value;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 08.11.2010 21:12:51
  -- Purpose : Получает значение веса застрахованного
  FUNCTION q_weight_default_value(par_q_question_id PLS_INTEGER) RETURN NUMBER IS
    v_weight  NUMBER;
    proc_name VARCHAR2(25) := 'q_weight_default_value';
  BEGIN
  
    SELECT aa.weight
      INTO v_weight
      FROM q_questions    qq
          ,q_quest_form   qf
          ,p_policy       pp
          ,ven_as_assured aa
     WHERE qq.q_questions_id = par_q_question_id
       AND qq.q_quest_form_id = qf.q_quest_form_id
       AND qf.policy_id = pp.policy_id
       AND qf.contact_id = aa.assured_contact_id
       AND pp.policy_id = aa.p_policy_id;
  
    RETURN(v_weight);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_weight_default_value;

  -- ishch 17.11.2010 (
  -- Purpose : Получает значение возраста застрахованного
  FUNCTION q_age_default_value(par_q_question_id PLS_INTEGER) RETURN NUMBER IS
    v_age     NUMBER;
    proc_name VARCHAR2(25) := 'q_age_default_value';
  BEGIN
  
    SELECT trunc(MONTHS_BETWEEN(SYSDATE, cp.date_of_birth) / 12) age
      INTO v_age
      FROM q_questions    qq
          ,q_quest_form   qf
          ,p_policy       pp
          ,ven_as_assured aa
          ,ven_cn_person  cp
     WHERE qq.q_questions_id = par_q_question_id
       AND qq.q_quest_form_id = qf.q_quest_form_id
       AND qf.policy_id = pp.policy_id
       AND qf.contact_id = aa.assured_contact_id
       AND qf.contact_id = cp.contact_id
       AND pp.policy_id = aa.p_policy_id;
  
    RETURN(v_age);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_age_default_value;
  -- ishch )

  -- Author  : Katkevich Alexey
  -- Created : 11.10.2010
  -- Purpose : Контроль соотношения роста и веса
  FUNCTION q_weight_height_control(par_q_question_id PLS_INTEGER) RETURN NUMBER IS
    proc_name VARCHAR2(50) := 'q_height_weight_control';
    v_height  NUMBER;
    v_weight  NUMBER;
    p_res     NUMBER := 1;
  BEGIN
  
    SELECT nvl(q_w.answer_value, 0)
          ,nvl(q_h.answer_value, 0)
      INTO v_weight
          ,v_height
      FROM q_questions      q
          ,q_questions      q_h
          ,q_questions      q_w
          ,t_q_pl_questions qpl_h
          ,t_q_pl_questions qpl_w
          ,t_q_questions    tq_h
          ,t_q_questions    tq_w
     WHERE 1 = 1
       AND q.q_questions_id = par_q_question_id
       AND q.q_quest_form_id = q_h.q_quest_form_id
       AND q.q_quest_form_id = q_w.q_quest_form_id
       AND q_h.t_q_pl_questions_id = qpl_h.t_q_pl_questions_id
       AND qpl_h.t_q_question_id = tq_h.t_q_questions_id
       AND tq_h.brief = 'height'
       AND q_w.t_q_pl_questions_id = qpl_w.t_q_pl_questions_id
       AND qpl_w.t_q_question_id = tq_w.t_q_questions_id
       AND tq_w.brief = 'weight';
  
    IF v_height - v_weight < 85
       OR v_height - v_weight > 115
    THEN
      p_res := 0;
    END IF;
  
    RETURN p_res;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
      --RAISE_APPLICATION_ERROR(-20001, 'Соотношение между ростом и весом у застрахованного (страхователя) не удовлетворяет стандартным требованиям компании". Договор может быть переведен в статус "Нестандарт" или "Проект".');
  END q_weight_height_control;

  -- Author  : Веселуха Е.В.
  -- Created : 18.06.2013
  -- Purpose : Контроль указания дохода при больших СС
  FUNCTION q_large_amount_control(par_q_question_id PLS_INTEGER) RETURN NUMBER IS
    proc_name    VARCHAR2(50) := 'q_large_amount_control';
    p_res        NUMBER := 1;
    v_answ       VARCHAR2(20);
    v_type_quest VARCHAR2(20);
    v_ins_sum    NUMBER;
  
    CURSOR plo_grp_curs(pcurs_q_question_id PLS_INTEGER) IS
      SELECT DISTINCT tpc.val
        FROM ins.q_questions      q
            ,ins.q_quest_form     qf
            ,ins.ven_as_assured   ass
            ,ins.p_cover          pc
            ,ins.t_prod_coef      tpc
            ,ins.t_prod_coef_type tpt
       WHERE q.q_questions_id = pcurs_q_question_id
         AND q.q_quest_form_id = qf.q_quest_form_id
         AND qf.policy_id = ass.p_policy_id -- только для данного ДС
         AND ass.as_assured_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = tpc.criteria_1
         AND tpc.t_prod_coef_type_id = tpt.t_prod_coef_type_id
         AND tpt.brief = 'Same_option_grouping';
  
  BEGIN
  
    BEGIN
      SELECT nvl(q_h.answer_value, 0)
            ,upper(qqt.brief)
        INTO v_answ
            ,v_type_quest
        FROM ins.q_questions         q
            ,ins.q_questions         q_h
            ,ins.t_q_pl_questions    qpl_h
            ,ins.t_q_questions       tq_h
            ,ins.q_quest_form        qf
            ,ins.t_q_quest_form_type qqt
       WHERE 1 = 1
         AND q.q_questions_id = par_q_question_id
         AND q.q_quest_form_id = q_h.q_quest_form_id
         AND q_h.t_q_pl_questions_id = qpl_h.t_q_pl_questions_id
         AND qpl_h.t_q_question_id = tq_h.t_q_questions_id
         AND q.q_quest_form_id = qf.q_quest_form_id
         AND qf.t_q_quest_form_type_id = qqt.t_q_quest_form_type_id
         AND tq_h.brief = 'income1';
    EXCEPTION
      WHEN no_data_found THEN
        RETURN p_res;
    END;
  
    IF v_answ = '0'
    THEN
      /**/
      IF v_type_quest = 'A_ZASTR'
      THEN
        FOR curs_rec IN plo_grp_curs(par_q_question_id)
        LOOP
          SELECT SUM(pc.ins_amount * acc.get_cross_rate_by_id(1, ph.fund_id, 122, pol.notice_date))
            INTO v_ins_sum
            FROM ins.q_questions    q
                ,ins.q_quest_form   qf
                ,ins.ven_as_assured ass
                ,ins.p_pol_header   ph
                ,ins.document       d
                ,ins.doc_status_ref rf
                ,ins.p_cover        pc
                ,ins.status_hist    sh
                ,ins.p_policy       pol
           WHERE q.q_questions_id = par_q_question_id
             AND q.q_quest_form_id = qf.q_quest_form_id
             AND qf.contact_id = ass.assured_contact_id
             AND ass.p_policy_id = ph.policy_id
             AND ph.policy_id = pol.policy_id
             AND ph.last_ver_id = d.document_id
             AND d.doc_status_ref_id = rf.doc_status_ref_id
             AND rf.brief NOT IN ('CANCEL', 'STOPED', 'BREAK')
             AND ass.as_assured_id = pc.as_asset_id
             AND pc.t_prod_line_option_id IN
                 (SELECT tpc.criteria_1
                    FROM t_prod_coef_type tpt
                        ,t_prod_coef      tpc
                   WHERE tpt.t_prod_coef_type_id = tpc.t_prod_coef_type_id
                     AND tpt.brief = 'Same_option_grouping'
                     AND tpc.val = curs_rec.val)
             AND pc.status_hist_id = sh.status_hist_id
             AND sh.brief IN ('NEW', 'CURRENT');
        
          IF v_ins_sum > 500000
          THEN
            RETURN(0);
          END IF;
          q_message := '(Застрахованный)';
        END LOOP;
      ELSIF v_type_quest = 'A_STRAH'
      THEN
        FOR cur_ins IN (SELECT ppc.contact_id
                          FROM q_questions            q
                              ,q_quest_form           qf
                              ,ins.p_policy           pol
                              ,ins.p_policy_contact   ppc
                              ,ins.t_contact_pol_role plr
                         WHERE q.q_questions_id = par_q_question_id
                           AND q.q_quest_form_id = qf.q_quest_form_id
                           AND qf.policy_id = pol.policy_id
                           AND pol.policy_id = ppc.policy_id
                           AND ppc.contact_policy_role_id = plr.id
                           AND plr.brief = 'Страхователь')
        LOOP
          SELECT SUM(pc.ins_amount * acc.get_cross_rate_by_id(1, ph.fund_id, 122, p.notice_date))
            INTO v_ins_sum
            FROM ins.p_cover            pc
                ,ins.status_hist        sh
                ,ins.p_pol_header       ph
                ,ins.document           d
                ,ins.doc_status_ref     rf
                ,ins.p_policy           p
                ,ins.p_policy_contact   ppc
                ,ins.t_contact_pol_role plr
                ,ins.as_asset           a
           WHERE ph.policy_id = p.policy_id
             AND p.policy_id = a.p_policy_id
             AND p.policy_id = ppc.policy_id
             AND ppc.contact_policy_role_id = plr.id
             AND plr.brief = 'Страхователь'
             AND ppc.contact_id = cur_ins.contact_id
             AND ph.last_ver_id = d.document_id
             AND d.doc_status_ref_id = rf.doc_status_ref_id
             AND rf.brief NOT IN ('CANCEL', 'STOPED', 'BREAK')
             AND a.as_asset_id = pc.as_asset_id
             AND pc.status_hist_id = sh.status_hist_id
             AND sh.brief IN ('NEW', 'CURRENT')
             AND pc.t_prod_line_option_id IN
                 (SELECT opt.id
                    FROM ins.t_prod_line_option opt
                   WHERE opt.description IN
                         ('Защита страховых взносов'
                         ,'Защита страховых взносов рассчитанная по основной программе'));
        END LOOP;
      
        IF v_ins_sum > 500000
        THEN
          RETURN(0);
        END IF;
        q_message := '(Страхователь)';
      
      ELSE
        RETURN(1);
      END IF;
      /**/
    END IF;
  
    RETURN p_res;
  
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_large_amount_control;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.10.2010 13:18:14
  -- Purpose : Выдает ошибку (0), если ответ на вопрос НЕТ -- ishch 08.11.2010
  FUNCTION q_no_control(par_q_question_id PLS_INTEGER) RETURN INTEGER IS
    v_result  INTEGER;
    proc_name VARCHAR2(25) := 'q_no_control';
  BEGIN
    SELECT nvl(q.answer_value, 0) -- ошибка если NULL - ishch 09.11.2010
      INTO v_result
      FROM q_questions    q
          ,t_q_value_type tqv
     WHERE q.q_questions_id = par_q_question_id
       AND q.t_q_value_type_id = tqv.t_q_value_type_id
       AND tqv.brief = 'BOOLEAN';
  
    RETURN(v_result);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_no_control;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.10.2010 13:18:14
  -- Purpose : Выдает ошибку (0), если ответ на вопрос ДА -- ishch 08.11.2010
  FUNCTION q_yes_control(par_q_question_id PLS_INTEGER) RETURN INTEGER IS
    v_result  INTEGER;
    proc_name VARCHAR2(25) := 'q_yes_control';
  BEGIN
    SELECT nvl(decode(q.answer_value, 1, 0, 1), 0) -- ошибка если NULL - 
    -- ishch 09.11.2010
      INTO v_result
      FROM q_questions    q
          ,t_q_value_type tqv
     WHERE q.q_questions_id = par_q_question_id
       AND q.t_q_value_type_id = tqv.t_q_value_type_id
       AND tqv.brief = 'BOOLEAN';
  
    RETURN(v_result);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_yes_control;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.10.2010 13:30:09
  -- Purpose : Проверка дохода застрахованного
  FUNCTION q_income_control(par_q_question_id PLS_INTEGER) RETURN INTEGER IS
    v_income     NUMBER;
    v_ins_sum    NUMBER;
    v_type_quest VARCHAR2(20);
    proc_name    VARCHAR2(25) := 'q_income_control';
    -- ishch 08.11.2010 (
    -- группы рисков по ДС (смерть НС - отдельно, смешка и смерть ЛП - отдельно)
    -- разделение по группам - в функции "Группировка одинаковых рисков по 
    -- программам"
    --на застрахованного
    CURSOR plo_grp_curs(pcurs_q_question_id PLS_INTEGER) IS
      SELECT DISTINCT tpc.val
        FROM q_questions      q
            ,q_quest_form     qf
            ,ven_as_assured   ass
            ,p_cover          pc
            ,t_prod_coef      tpc
            ,t_prod_coef_type tpt
       WHERE q.q_questions_id = pcurs_q_question_id
         AND q.q_quest_form_id = qf.q_quest_form_id
         AND qf.policy_id = ass.p_policy_id -- только для данного ДС
         AND ass.as_assured_id = pc.as_asset_id
         AND pc.t_prod_line_option_id = tpc.criteria_1
         AND tpc.t_prod_coef_type_id = tpt.t_prod_coef_type_id
         AND tpt.brief = 'Same_option_grouping';
    -- ishch )    
  BEGIN
    SELECT nvl(q.answer_value, 0)
          ,upper(qqt.brief)
      INTO v_income
          ,v_type_quest
      FROM ins.q_questions         q
          ,ins.t_q_pl_questions    tqpl
          ,ins.t_q_questions       tq
          ,ins.q_quest_form        qf
          ,ins.t_q_quest_form_type qqt
     WHERE q.q_questions_id = par_q_question_id
       AND q.t_q_pl_questions_id = tqpl.t_q_pl_questions_id
       AND tqpl.t_q_question_id = tq.t_q_questions_id
       AND tq.brief = 'income'
       AND qf.q_quest_form_id = q.q_quest_form_id
       AND qf.t_q_quest_form_type_id = qqt.t_q_quest_form_type_id;
  
    IF v_type_quest = 'A_ZASTR'
    THEN
      FOR curs_rec IN plo_grp_curs(par_q_question_id)
      LOOP
        -- ishch 08.11.2010
        SELECT SUM(pc.ins_amount)
          INTO v_ins_sum
          FROM q_questions    q
              ,q_quest_form   qf
              ,ven_as_assured ass
              ,p_pol_header   ph
              ,p_cover        pc
              ,status_hist    sh
         WHERE q.q_questions_id = par_q_question_id
           AND q.q_quest_form_id = qf.q_quest_form_id
           AND qf.contact_id = ass.assured_contact_id
           AND ass.p_policy_id = ph.policy_id
           AND doc.get_doc_status_brief(pkg_policy.get_last_version(ph.policy_header_id)) NOT IN
               ('CANCEL', 'STOPED', 'BREAK')
           AND ass.as_assured_id = pc.as_asset_id
           AND pc.t_prod_line_option_id IN (SELECT tpc.criteria_1
                                              FROM t_prod_coef_type tpt
                                                  ,t_prod_coef      tpc
                                             WHERE tpt.t_prod_coef_type_id = tpc.t_prod_coef_type_id
                                               AND tpt.brief = 'Same_option_grouping'
                                               AND tpc.val = curs_rec.val) -- ishch 08.11.2010
           AND pc.status_hist_id = sh.status_hist_id
           AND sh.brief IN ('NEW', 'CURRENT');
      
        IF v_income * 60 >= v_ins_sum
        THEN
          RETURN(1);
        END IF;
        q_message := 'Застрахованный';
      END LOOP; -- ishch 08.11.2010 
    ELSIF v_type_quest = 'A_STRAH'
    THEN
      FOR cur_ins IN (SELECT ppc.contact_id
                        FROM q_questions            q
                            ,q_quest_form           qf
                            ,ins.p_policy           pol
                            ,ins.p_policy_contact   ppc
                            ,ins.t_contact_pol_role plr
                       WHERE q.q_questions_id = par_q_question_id
                         AND q.q_quest_form_id = qf.q_quest_form_id
                         AND qf.policy_id = pol.policy_id
                         AND pol.policy_id = ppc.policy_id
                         AND ppc.contact_policy_role_id = plr.id
                         AND plr.brief = 'Страхователь')
      LOOP
        SELECT SUM(pc.ins_amount)
          INTO v_ins_sum
          FROM ins.p_cover     pc
              ,ins.status_hist sh
         WHERE EXISTS (SELECT NULL
                  FROM ins.p_pol_header       ph
                      ,ins.p_policy           p
                      ,ins.p_policy_contact   ppc
                      ,ins.t_contact_pol_role plr
                      ,ins.as_asset           a
                 WHERE ph.policy_id = p.policy_id
                   AND p.policy_id = a.p_policy_id
                   AND p.policy_id = ppc.policy_id
                   AND ppc.contact_policy_role_id = plr.id
                   AND plr.brief = 'Страхователь'
                   AND ppc.contact_id = cur_ins.contact_id
                   AND doc.get_doc_status_brief(pkg_policy.get_last_version(ph.policy_header_id)) NOT IN
                       ('CANCEL', 'STOPED', 'BREAK')
                   AND a.as_asset_id = pc.as_asset_id)
           AND pc.status_hist_id = sh.status_hist_id
           AND sh.brief IN ('NEW', 'CURRENT')
           AND pc.t_prod_line_option_id IN
               (SELECT opt.id
                  FROM ins.t_prod_line_option opt
                 WHERE opt.description IN
                       ('Защита страховых взносов'
                       ,'Защита страховых взносов рассчитанная по основной программе'));
      END LOOP;
    
      IF v_income * 60 >= v_ins_sum
      THEN
        RETURN(1);
      END IF;
      q_message := 'Страхователь';
    
    ELSE
      RETURN(0);
    END IF;
  
    RETURN(0);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN(0);
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END q_income_control;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.02.2010 11:33:27
  -- Purpose : Создает на договоре анкету заданного типа 
  PROCEDURE create_questionnaire
  (
    par_policy_id       PLS_INTEGER
   ,par_quest_form_type PLS_INTEGER
  ) IS
    proc_name        VARCHAR2(25) := 'Create_questionnaire';
    v_qf_common_type PLS_INTEGER; --1 - застрахованный 2- страхователь
    v_insurer_cn     PLS_INTEGER;
    v_quest_form_id  PLS_INTEGER;
    v_qf_date_b      DATE;
    v_qf_date_e      DATE;
    v_ph_date        DATE;
  BEGIN
    SELECT qft.common_type
          ,qft.date_begin
          ,qft.date_end
      INTO v_qf_common_type
          ,v_qf_date_b
          ,v_qf_date_e
      FROM t_q_quest_form_type qft
     WHERE qft.t_q_quest_form_type_id = par_quest_form_type;
  
    SELECT ph.start_date
      INTO v_ph_date
      FROM p_pol_header ph
          ,p_policy     pp
     WHERE pp.policy_id = par_policy_id
       AND pp.pol_header_id = ph.policy_header_id;
  
    IF v_ph_date NOT BETWEEN v_qf_date_b AND v_qf_date_e
    THEN
      RETURN;
    END IF;
  
    CASE v_qf_common_type
      WHEN 1 THEN
        FOR assured IN (SELECT asu.assured_contact_id cn_id
                          FROM ven_as_assured asu
                         WHERE asu.p_policy_id = par_policy_id)
        LOOP
          SELECT sq_q_quest_form.nextval INTO v_quest_form_id FROM dual;
          INSERT INTO q_quest_form
            (q_quest_form_id
            ,t_q_quest_form_type_id
            ,contact_id
            ,who_create
            ,policy_id
            ,date_of_fill
            ,note
            ,is_closed)
          VALUES
            (v_quest_form_id
            ,par_quest_form_type
            ,assured.cn_id
            ,USER
            ,par_policy_id
            ,SYSDATE
            ,'Автоматически созданная анкета'
            ,0);
          fill_questionnaire(v_quest_form_id);
        END LOOP;
      WHEN 2 THEN
        SELECT sq_q_quest_form.nextval INTO v_quest_form_id FROM dual;
        v_insurer_cn := pkg_policy.get_policy_contact(par_policy_id, 'Страхователь');
        IF v_insurer_cn IS NOT NULL
        THEN
          INSERT INTO q_quest_form
            (q_quest_form_id
            ,t_q_quest_form_type_id
            ,contact_id
            ,who_create
            ,policy_id
            ,date_of_fill
            ,note
            ,is_closed)
          VALUES
            (v_quest_form_id
            ,par_quest_form_type
            ,v_insurer_cn
            ,USER
            ,par_policy_id
            ,SYSDATE
            ,'Автоматически созданная анкета'
            ,0);
          fill_questionnaire(v_quest_form_id);
        END IF;
    END CASE;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END create_questionnaire;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 11.02.2010 11:35:50
  -- Purpose : Процедура заполнения анкеты
  PROCEDURE fill_questionnaire(par_q_quest_form_id PLS_INTEGER) IS
    proc_name VARCHAR2(25) := 'Fill_questionnaire';
    --v_quest_ent    PLS_INTEGER:=ent.id_by_brief('Q_QUESTIONS');
    v_answer_val VARCHAR2(50);
    v_closed     PLS_INTEGER;
  BEGIN
  
    SELECT qf.is_closed
      INTO v_closed
      FROM q_quest_form qf
     WHERE qf.q_quest_form_id = par_q_quest_form_id;
  
    --Проверка на то что анкета уже закрыта
    IF v_closed = 1
    THEN
      RETURN;
    END IF;
  
    --Заполним вопросы анкеты
    INSERT INTO q_questions
      (q_questions_id, q_quest_form_id, t_q_pl_questions_id, t_q_value_type_id)
      SELECT sq_q_questions.nextval sq
            ,a.qf
            ,a.qpl
            ,a.vt
        FROM ( --Все УНИКАЛЬНЫЕ вопросы по рискам в продукте
              SELECT DISTINCT qf.q_quest_form_id qf
                              ,first_value(qpl.t_q_pl_questions_id) over(PARTITION BY qpl.t_q_question_id) qpl
                              ,
                               --qpl.t_q_pl_questions_id qpl,
                               qvt.t_q_value_type_id vt
                FROM q_quest_form       qf
                     ,t_q_pl_questions   qpl
                     ,t_q_questions      qq
                     ,t_q_value_type     qvt
                     ,ven_as_assured     vas
                     ,p_cover            pc
                     ,t_prod_line_option tplo
               WHERE 1 = 1
                 AND qf.q_quest_form_id = par_q_quest_form_id
                 AND qpl.enabled = 1
                 AND vas.p_policy_id = qf.policy_id
                 AND vas.as_assured_id = pc.as_asset_id
                 AND pc.t_prod_line_option_id = tplo.id
                 AND tplo.product_line_id = qpl.t_prod_line_id
                 AND qf.t_q_quest_form_type_id = qpl.t_quest_form_type_id
                 AND qpl.t_q_question_id = qq.t_q_questions_id
                 AND qq.t_q_value_type_id = qvt.t_q_value_type_id
                 AND qpl.t_q_question_id NOT IN
                     (SELECT qpl2.t_q_question_id
                        FROM p_policy         pp
                            ,p_policy         pp2
                            ,q_quest_form     qf2
                            ,q_questions      qq2
                            ,t_q_pl_questions qpl2
                       WHERE pp.policy_id = qf.policy_id
                         AND pp2.pol_header_id = pp.pol_header_id
                         AND pp2.policy_id = qf2.policy_id
                         AND qq2.q_quest_form_id = qf2.q_quest_form_id
                            -- Чирков/205621 Анкеты в ДС - не формируется список вопросов/не формировался страхователь, если есть застрахованный
                         AND qf.t_q_quest_form_type_id = qf2.t_q_quest_form_type_id
                            --
                         AND qq2.t_q_pl_questions_id = qpl2.t_q_pl_questions_id)
              MINUS --Вычитаем конкурирующие вопросы (Настройка на продукте)
              SELECT qf.q_quest_form_id            qf
                     ,tqpl_comp.t_q_pl_questions_id qplm
                     ,tq.t_q_value_type_id
                FROM q_quest_form       qf
                     ,ven_as_asset       ass
                     ,p_cover            pc
                     ,t_prod_line_option tplo
                     ,t_q_pl_questions   tqpl
                     ,t_q_comp_questions tqplc
                     ,p_cover            pc_comp
                     ,t_prod_line_option tplo_comp
                     ,t_q_pl_questions   tqpl_comp
                     ,t_q_questions      tq
               WHERE qf.q_quest_form_id = par_q_quest_form_id
                 AND qf.policy_id = ass.p_policy_id
                 AND pc.as_asset_id = ass.as_asset_id
                 AND pc_comp.as_asset_id = ass.as_asset_id
                 AND tplo.id = pc.t_prod_line_option_id
                 AND tplo.product_line_id = tqpl.t_prod_line_id
                 AND tqpl.enabled = 1
                 AND tqplc.t_q_pl_questions_id = tqpl.t_q_pl_questions_id
                 AND tqplc.t_q_pl_comp_questions_id = tqpl_comp.t_q_pl_questions_id
                 AND pc_comp.t_prod_line_option_id = tplo_comp.id
                 AND tplo_comp.product_line_id = tqpl_comp.t_prod_line_id
                 AND tqpl_comp.enabled = 1
                 AND tq.t_q_questions_id = tqpl_comp.t_q_question_id
              MINUS --Вычитаем вопросы которые уже заполнены
              SELECT qqs.q_quest_form_id
                     ,qqs.t_q_pl_questions_id
                     ,qq.t_q_value_type_id
                FROM ven_q_questions  qqs
                     ,t_q_pl_questions qpl
                     ,t_q_questions    qq
               WHERE qqs.q_quest_form_id = par_q_quest_form_id
                 AND qqs.t_q_pl_questions_id = qpl.t_q_pl_questions_id
                 AND qq.t_q_questions_id = qpl.t_q_question_id) a;
  
    --Заполним занчения ответов по умолчанию.
    --с помощью цикла приходится обходить "мутацию"
    --может есть смысл подумать над тем чтобы функции
    --вычислять от другого аргумента или в другом месте
    FOR question IN (SELECT qs.q_questions_id
                           ,qs.t_q_pl_questions_id
                       FROM q_questions qs
                      WHERE qs.q_quest_form_id = par_q_quest_form_id
                        AND (qs.answer_value IS NULL OR EXISTS
                            --Вопрос как оформить логику
                            --Перезаполнять ответ всегда, когда есть функция его определяющая,
                            --или только если пользователь не может его изменить?
                             (SELECT NULL
                                FROM t_q_pl_questions qpl_d
                               WHERE qpl_d.t_q_pl_questions_id = qs.t_q_pl_questions_id
                                    --AND nvl(qpl_d.default_can_change,1) = 0
                                 AND qpl_d.default_value_func IS NOT NULL))
                        AND EXISTS (SELECT NULL
                               FROM t_q_pl_questions qpl_d
                              WHERE qpl_d.t_q_pl_questions_id = qs.t_q_pl_questions_id
                                AND (qpl_d.default_value IS NOT NULL OR
                                    qpl_d.default_value_func IS NOT NULL)))
    LOOP
      SELECT decode(tqpl.default_value_func
                   ,NULL
                   ,tqpl.default_value
                   ,pkg_tariff_calc.calc_fun(tqpl.default_value_func
                                            ,g_quest_ent
                                            ,question.q_questions_id))
        INTO v_answer_val
        FROM t_q_pl_questions tqpl
       WHERE tqpl.t_q_pl_questions_id = question.t_q_pl_questions_id;
    
      UPDATE q_questions qq
         SET answer_value = v_answer_val
       WHERE qq.q_questions_id = question.q_questions_id;
    END LOOP;
  
    /*     UPDATE q_questions qq
      SET qq.answer_value = 
             (SELECT decode(tqpl.default_value_func, 
                            NULL, 
                            tqpl.default_value, 
                            pkg_tariff_calc.calc_fun(tqpl.default_value_func, v_quest_ent, qq.q_questions_id))
                FROM t_q_pl_questions tqpl
               WHERE tqpl.t_q_pl_questions_id =
                     qq.t_q_pl_questions_id)
    WHERE qq.q_quest_form_id = par_q_quest_form_id
      AND EXISTS
          (SELECT NULL
             FROM t_q_pl_questions qpl_d
            WHERE qpl_d.t_q_pl_questions_id = qq.t_q_pl_questions_id
              AND (qpl_d.default_value IS NOT NULL OR
                  qpl_d.default_value_func IS NOT NULL));*/
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END fill_questionnaire;

  -- Author  : ishch
  -- Created : 31.01.2010
  -- Purpose : Предварительная проверка анкет
  PROCEDURE pre_quest_form_check(par_policy_id PLS_INTEGER) IS
    proc_name   VARCHAR2(25) := 'Pre_quest_form_check';
    v_err_quest VARCHAR2(200);
    p_ver_num   NUMBER;
  BEGIN
  
    BEGIN
      SELECT p.version_num
        INTO p_ver_num
        FROM p_policy     p
            ,p_pol_header ph
            ,t_product    prod
            ,bso          b
            ,bso_series   bs
       WHERE p.policy_id = par_policy_id
         AND p.pol_header_id = ph.policy_header_id
         AND prod.product_id = ph.product_id
         AND b.pol_header_id = ph.policy_header_id
         AND b.policy_id = p.policy_id
         AND bs.bso_series_id = b.bso_series_id
         AND (prod.brief IN ('PEPR'
                            ,'PEPR_Old'
                            ,'PEPR_2'
                            ,'END'
                            ,'END_Old'
                            ,'END_2'
                            ,'CHI'
                            ,'CHI_Old'
                            ,'CHI_2'
                            ,'ACC'
                            ,'ACC_Old'
                            ,'ACC163'
                            ,'ACC164'
                            ,'ACC172'
                            ,'ACC173'
                            ,'APG'
                            ,'TERM'
                            ,'TERM_old'
                            ,'TERM_2'
                            ,'Family_Dep_2014'));
    EXCEPTION
      WHEN no_data_found THEN
        p_ver_num := 0;
    END;
  
    IF p_ver_num = 1
    THEN
    
      --1) Проверка на то что по договору есть анкеты и они полностью заполнены
      --   если нет то создаем и заполняем
      FOR r IN (SELECT qft.t_q_quest_form_type_id qf_t
                      ,qf.q_quest_form_id         qf_f
                  FROM p_policy            pp
                      ,p_pol_header        ph
                      ,t_q_quest_form_type qft
                      ,q_quest_form        qf
                 WHERE 1 = 1
                   AND pp.policy_id = par_policy_id
                   AND pp.pol_header_id = ph.policy_header_id
                   AND ph.product_id = qft.product_id
                   AND qf.policy_id(+) = par_policy_id
                   AND qf.t_q_quest_form_type_id(+) = qft.t_q_quest_form_type_id
                   AND SYSDATE BETWEEN qft.date_begin AND qft.date_end)
      LOOP
        IF r.qf_f IS NULL
        THEN
          create_questionnaire(par_policy_id, r.qf_t);
        ELSE
          fill_questionnaire(r.qf_f);
        END IF;
      END LOOP;
    
      --2) Проверка на то что есть ответы на все вопросы кроме тех у которых
      --   на родительский вопрос отрицательный ответ
      FOR r1 IN (SELECT qpl.t_q_question_id
                   FROM q_quest_form     qf
                       ,q_questions      qq
                       ,t_q_value_type   qvt
                       ,t_q_pl_questions qpl
                  WHERE qf.policy_id = par_policy_id
                    AND qf.q_quest_form_id = qq.q_quest_form_id
                    AND qq.t_q_value_type_id = qvt.t_q_value_type_id
                    AND qpl.enabled = 1
                    AND qpl.t_q_pl_questions_id = qq.t_q_pl_questions_id
                    AND ((qq.answer_value IS NULL AND qvt.brief <> 'LOV') OR
                        (qvt.brief = 'LOV' AND NOT EXISTS
                         (SELECT NULL FROM q_answers qa WHERE qa.q_questions_id = qq.q_questions_id)))
                       -- ishch 19.11.2010 (
                    AND (qpl.parent_pl_question_id IS NULL OR EXISTS
                         (SELECT NULL
                            FROM q_questions qq1
                           WHERE qq1.t_q_pl_questions_id = qpl.parent_pl_question_id
                             AND qq1.q_quest_form_id = qq.q_quest_form_id
                             AND nvl(qq1.answer_value, 0) = 1))
                 -- ishch ) 
                 )
      LOOP
        SELECT tq.text
          INTO v_err_quest
          FROM t_q_questions tq
         WHERE tq.t_q_questions_id = r1.t_q_question_id;
        raise_application_error(-20006
                               ,'Проверьте анкеты, нет ответа на вопрос: ' || v_err_quest);
      END LOOP;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE > -20001
      THEN
        raise_application_error(-20001
                               ,'Ошибка при выполнении ' || proc_name || SQLERRM);
      ELSE
        raise_application_error(-20006, SQLERRM);
      END IF;
  END pre_quest_form_check;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 17.02.2010 16:03:55
  -- Purpose : Основная проверка анкет
  PROCEDURE main_quest_form_check(par_policy_id PLS_INTEGER) IS
    proc_name   VARCHAR2(25) := 'Main_quest_form_check';
    v_err_quest VARCHAR2(200);
    --v_quest_ent    PLS_INTEGER:=ent.id_by_brief('Q_QUESTIONS');
    v_dummy       CHAR(1);
    v_is_product  NUMBER;
    v_err_message VARCHAR2(25) := '';
  BEGIN
    -- ishch 26.01.2011 (
    -- Убрал проверку принадлежности агенства списку
    -- ishch 19.11.2010 (
    -- Если ДС не принадлежит агенству из заданного списка - 
    -- проверки анкет не производятся 
    /*BEGIN   
      SELECT  '1'
        INTO v_dummy
        FROM  organisation_tree o,
              department d,
              p_policy pp,
              p_pol_header ph
        WHERE o.organisation_tree_id = d.org_tree_id
          AND d.department_id = ph.agency_id
          AND ph.policy_header_id = pp.pol_header_id
          AND pp.policy_id = par_policy_id
          AND o.name IN (
                'Иркутск',
                'Иркутск 2',
                'Подразделение ГРС Отдел розничных продаж в г. Иркутске Филиала ООО "СК" Ренессанс Жизнь" в городе Иркутске',
                'Подразделение 1 Филиала ООО "СК"Ренессанс Жизнь" в городе Иркутске',
                'Ф_Иркутск',
                'Пермь',
                'Пермь Подразделение 1',
                'Пермь Подразделение 5',
                'Пермь 1',
                'Пермь 1 Подразделение 1',
                'Пермь 1 Подразделение 2',
                'Пермь 1 Подразделение 3',
                'Пермь 1 Подразделение 4',
                'Пермь 2',
                'Пермь 2 Подразделение 1',
                'Пермь 2 Подразделение 2',
                'Пермь 3',
                'Пермь 4',
                'Ф_Пермь',
                'Рязань',
                'Рязань Подразделение 1',
                'Ф_Рязань',
                'Омск',
                'Ф_Омск',
                'Ульяновск',
                'Ульяновск Подразделение 1',
                'Ф_Ульяновск' );
    EXCEPTION
      WHEN no_data_found THEN            
        RETURN; -- проверки анкет не производятся
    END;
    */
    -- ishch )
    -- ishch 26.01.2011 )
    -- добавлена проверка по продукту, заявка №114804, 20-06-2011
    BEGIN
      SELECT nvl(prod.product_id, 0)
        INTO v_is_product
        FROM p_policy     p
            ,p_pol_header ph
            ,t_product    prod
            ,bso          b
            ,bso_series   bs
       WHERE p.policy_id = par_policy_id
         AND p.pol_header_id = ph.policy_header_id
         AND prod.product_id = ph.product_id
         AND b.pol_header_id = ph.policy_header_id
         AND b.policy_id = p.policy_id
         AND bs.bso_series_id = b.bso_series_id
         AND (prod.description IN ('Будущее'
                                  ,'Будущее (Старая версия)'
                                  ,'Гармония жизни'
                                  ,'Гармония жизни (Старая версия)'
                                  ,'Дети'
                                  ,'Дети (Старая версия)'
                                  ,'Защита'
                                  ,'Защита (Старая версия)'
                                  ,'Защита APG'
                                  ,'Защита 164'
                                  ,'Защита 163'
                                  ,'Семья'
                                  ,'Семья (Старая версия)'
                                  ,'Будущее_2'
                                  ,'Гармония жизни_2'
                                  ,'Дети_2'
                                  ,'Семья_2'
                                  ,'Семейный депозит 2014'));
    EXCEPTION
      WHEN no_data_found THEN
        v_is_product := 0;
    END;
  
    IF v_is_product > 0
    THEN
    
      --1) Проверка на то что по договору есть анкеты и они полностью заполнены
      --   если нет то создаем и заполняем
      FOR r IN (SELECT qft.t_q_quest_form_type_id qf_t
                      ,qf.q_quest_form_id         qf_f
                  FROM p_policy            pp
                      ,p_pol_header        ph
                      ,t_q_quest_form_type qft
                      ,q_quest_form        qf
                 WHERE 1 = 1
                   AND pp.policy_id = par_policy_id
                   AND pp.pol_header_id = ph.policy_header_id
                   AND ph.product_id = qft.product_id
                   AND qf.policy_id(+) = par_policy_id
                   AND qf.t_q_quest_form_type_id(+) = qft.t_q_quest_form_type_id
                   AND SYSDATE BETWEEN qft.date_begin AND qft.date_end)
      LOOP
        IF r.qf_f IS NULL
        THEN
          create_questionnaire(par_policy_id, r.qf_t);
        ELSE
          fill_questionnaire(r.qf_f);
        END IF;
      END LOOP;
    
      --2) Проверка на то что есть ответы на все вопросы кроме тех у которых
      --   на родительский вопрос отрицательный ответ
      FOR r1 IN (SELECT qpl.t_q_question_id
                   FROM q_quest_form     qf
                       ,q_questions      qq
                       ,t_q_value_type   qvt
                       ,t_q_pl_questions qpl
                  WHERE qf.policy_id = par_policy_id
                    AND qf.q_quest_form_id = qq.q_quest_form_id
                    AND qq.t_q_value_type_id = qvt.t_q_value_type_id
                    AND qpl.enabled = 1
                    AND qpl.t_q_pl_questions_id = qq.t_q_pl_questions_id
                    AND ((qq.answer_value IS NULL AND qvt.brief <> 'LOV') OR
                        (qvt.brief = 'LOV' AND NOT EXISTS
                         (SELECT NULL FROM q_answers qa WHERE qa.q_questions_id = qq.q_questions_id)))
                       -- ishch 19.11.2010 (
                    AND (qpl.parent_pl_question_id IS NULL OR EXISTS
                         (SELECT NULL
                            FROM q_questions qq1
                           WHERE qq1.t_q_pl_questions_id = qpl.parent_pl_question_id
                             AND qq1.q_quest_form_id = qq.q_quest_form_id
                             AND nvl(qq1.answer_value, 0) = 1))
                 -- ishch ) 
                 )
      LOOP
        SELECT tq.text
          INTO v_err_quest
          FROM t_q_questions tq
         WHERE tq.t_q_questions_id = r1.t_q_question_id;
        raise_application_error(-20006
                               ,'Проверьте анкеты нет ответа на вопрос: ' || v_err_quest);
      END LOOP;
    
      --3) Проверки на самих вопросах
      FOR q IN (SELECT qq.q_questions_id
                      ,qq.answer_value
                      ,qvt.brief value_type
                      ,nvl(decode(qpl.max_value_func
                                 ,NULL
                                 ,NULL
                                 ,pkg_tariff_calc.calc_fun(qpl.max_value_func
                                                          ,g_quest_ent
                                                          ,qq.q_questions_id))
                          ,qpl.max_value) max_value
                      ,
                       
                       nvl(decode(qpl.min_value_func
                                 ,NULL
                                 ,NULL
                                 ,pkg_tariff_calc.calc_fun(qpl.min_value_func
                                                          ,g_quest_ent
                                                          ,qq.q_questions_id))
                          ,qpl.min_value) min_value
                      ,qpl.check_value_func
                      ,qpl.check_falirue_msg
                      ,tqq.text quest_text
                      ,tqq.brief quest_brief
                      ,tpl.description programm_name /*Наименование страховой программы*/
                  FROM q_quest_form     qf
                      ,q_questions      qq
                      ,t_q_value_type   qvt
                      ,t_q_pl_questions qpl
                      ,t_q_questions    tqq
                      ,t_product_line   tpl
                 WHERE qf.policy_id = par_policy_id
                   AND qf.q_quest_form_id = qq.q_quest_form_id
                   AND qq.t_q_value_type_id = qvt.t_q_value_type_id
                   AND qpl.t_q_pl_questions_id = qq.t_q_pl_questions_id
                   AND qpl.t_q_question_id = tqq.t_q_questions_id
                   AND qpl.is_main_check = 1
                   AND (qpl.parent_pl_question_id IS NULL OR EXISTS
                        (SELECT NULL
                           FROM q_questions qq1
                          WHERE qq1.t_q_pl_questions_id = qpl.parent_pl_question_id
                            AND qq1.q_quest_form_id = qq.q_quest_form_id
                            AND nvl(qq1.answer_value, 0) = 1))
                   AND qpl.t_prod_line_id = tpl.id /*24.04.2014 Черных М.Г. 324932*/
                )
      LOOP
      
        --3a) Проверка на максимальные и минимальные значения для вопросов с
        --   типом число
        IF q.value_type = 'NUM'
        THEN
          IF to_number(q.answer_value) > q.max_value
          THEN
            raise_application_error(-20006
                                   ,'Договор должен быть переведен в статус "Нестандарт" ' || chr(10) ||
                                    'Введеное значение (' || q.answer_value ||
                                    ') больше максимального (' || q.max_value || ') по программе ' ||
                                    q.programm_name || '. ' || q.quest_text);
          END IF;
        
          IF to_number(q.answer_value) < q.min_value
          THEN
            raise_application_error(-20006
                                   ,'Договор должен быть переведен в "Нестандарт" ' || chr(10) ||
                                    'Введеное значение (' || q.answer_value ||
                                    ') меньше минимального (' || q.min_value || ') по программе ' ||
                                    q.programm_name || '. ' || q.quest_text);
          END IF;
        END IF;
      
        --3b) Проверка результатов выполнения дополнительных проверочных функций
        --   Основано на том принципе что проверочная функция возвращает 1 если все нормально
        --   функции считаются от сущьности Q_QUESTIONS
        IF q.check_value_func IS NOT NULL
        THEN
          IF pkg_tariff_calc.calc_fun(q.check_value_func, g_quest_ent, q.q_questions_id) <> 1
          THEN
            v_err_message := q_message;
            q_message     := '';
            raise_application_error(-20006
                                   ,'Договор должен быть переведен в "Нестандарт" ' || chr(10) ||
                                    q.check_falirue_msg || ' ' || v_err_message);
          
          END IF;
        END IF;
      END LOOP;
    
      --Закрываем анкеты на редактирование
      UPDATE q_quest_form qf SET is_closed = 1 WHERE qf.policy_id = par_policy_id;
    
      --Удаляем пустые анкеты
      DELETE FROM q_quest_form qf
       WHERE qf.policy_id = par_policy_id
         AND NOT EXISTS
       (SELECT NULL FROM q_questions qq WHERE qq.q_quest_form_id = qf.q_quest_form_id);
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE > -20001
      THEN
        raise_application_error(-20001
                               ,'Ошибка при выполнении ' || proc_name || SQLERRM);
      ELSE
        raise_application_error(-20006, SQLERRM);
      END IF;
  END main_quest_form_check;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 18.02.2010 15:18:46
  -- Purpose : Открывает анкеты на редактирование
  PROCEDURE open_quest_form(par_policy_id PLS_INTEGER) IS
    proc_name VARCHAR2(25) := 'Open_quest_form';
  BEGIN
  
    UPDATE q_quest_form qf SET is_closed = 0 WHERE qf.policy_id = par_policy_id;
  
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END open_quest_form;
BEGIN
  -- Initialization
  NULL; --<STATEMENT>;
END pkg_q_quest_form;
/
