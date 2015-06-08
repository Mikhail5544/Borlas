CREATE OR REPLACE PACKAGE pkg_doc_templ_fmb IS

  -- Author  :  Чирков В.Ю.
  -- Created : 03.08.2012 13:46:29
  -- Purpose : Пакет для работы с формой DOC_TEMPL.FMB

  FUNCTION get_doc_status_allowed_id
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
  ) RETURN NUMBER;

  /* Получение данных из строки таблицы doc_status_action_cur
  * @param par_templ_brief       - шаблон документа
  * @param par_src_status_brief  - переход статуса от
  * @param par_dest_status_brief - переход статуса к
  * @param par_proc_name         - процедура
  * @autor Чирков В.Ю.
  */
  CURSOR doc_status_action_cur
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
   ,par_proc_name         VARCHAR2
  ) RETURN doc_status_action%ROWTYPE;

  /* Получение Признака выполнять/не выполнять действие
  * и Признака обязательного/необязательного действия
  * для процедуры у документа при переходе статуса 
  * @autor Чирков В.Ю.
  * @param par_templ_brief       - шаблон документа
  * @param par_src_status_brief  - переход статуса от
  * @param par_dest_status_brief - переход статуса к
  * @param par_proc_name         - процедура
  * @param par_is_execute        - Признака выполнять/не выполнять действие
  * @param par_is_required       - Признака выполнять/не выполнять действие
  */
  PROCEDURE get_doc_status_proc
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
   ,par_proc_name         VARCHAR2
   ,par_is_execute        OUT NUMBER
   ,par_is_required       OUT NUMBER
  );

  /* Измененние  Признака выполнять/не выполнять действие
  * и Признака обязательного/необязательного действия
  * для процедуры у документа при переходе статуса 
  * @autor Чирков В.Ю.
  * @param par_templ_brief       - шаблон документа
  * @param par_src_status_brief  - переход статуса от
  * @param par_dest_status_brief - переход статуса к
  * @param par_proc_name         - процедура
  * @param par_is_execute        - Признака выполнять/не выполнять действие
  * @param par_is_required       - Признака выполнять/не выполнять действие
  */

  PROCEDURE set_doc_status_proc
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
   ,par_proc_name         VARCHAR2
   ,par_is_execute        NUMBER
   ,par_is_required       NUMBER
  );

  /* Добавление процедуры в шаблон документа  
  * @autor Чирков В.Ю.
  * @param par_templ_brief       - шаблон документа
  * @param par_src_status_brief  - переход статуса от
  * @param par_dest_status_brief - переход статуса к
  * @param par_proc_name         - процедура
  * @param par_is_execute        - Признака выполнять/не выполнять действие
  * @param par_is_required       - Признака выполнять/не выполнять действие
  * @param par_doc_action_type_brief - Тип действия
  * @param par_sort_order        - порядок сортировки 
  */
  PROCEDURE add_proc_to_templ
  (
    par_templ_brief           VARCHAR2
   ,par_src_status_brief      VARCHAR2
   ,par_dest_status_brief     VARCHAR2
   ,par_proc_name             VARCHAR2
   ,par_is_execute            NUMBER := 1
   ,par_is_required           NUMBER := 1
   ,par_doc_action_type_brief VARCHAR2 := 'PROCEDURE'
   ,par_sort_order            NUMBER := NULL
  );

  /* Удаление процедуры с перехода статусов для шаблона документа  
  * @autor Капля П.С.
  * @param par_templ_brief       - шаблон документа
  * @param par_src_status_brief  - переход статуса от
  * @param par_dest_status_brief - переход статуса к
  * @param par_proc_name         - процедура/операция
  */
  PROCEDURE del_proc_from_templ
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
   ,par_proc_name         VARCHAR2
  );

  /* Удаление всех процедур с перехода статусов для шаблона документа    
  * @autor Капля П.С.
  * @param par_templ_brief       - шаблон документа
  * @param par_src_status_brief  - переход статуса от
  * @param par_dest_status_brief - переход статуса к
  */
  PROCEDURE del_all_proc_from_templ
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
  );

  /* Копирование процедур в шаблон документа  
  * @autor Капля П.С.
  * @param par_templ_brief       - шаблон документа
  * @param par_copy_src_status_brief  - переход статуса от откуда копируем
  * @param par_copy_dest_status_brief - переход статуса к отукда копируем
  * @param par_paste_src_status_brief  - переход статуса от куда копируем
  * @param par_paste_dest_status_brief - переход статуса к куда копируем
  */
  PROCEDURE copy_proc_from_templ
  (
    par_templ_brief             VARCHAR2
   ,par_copy_src_status_brief   VARCHAR2
   ,par_copy_dest_status_brief  VARCHAR2
   ,par_paste_src_status_brief  VARCHAR2
   ,par_paste_dest_status_brief VARCHAR2
  );

  /** Добавление перехода для шаблона документа
  * @author Kaplya P.
  * @param p_doc_templ_brief        - Бриф шаблона документа
  * @param p_src_status_ref_brief   - Бриф исходного статуса
  * @param p_dest_status_ref_brief  - Бриф целевого статуса
  * @param p_is_del_trans           - Удаление проводок при преходе
  * @param p_is_auto_only           - Исключить переход из интерфейса
  * @param p_is_storno_trans        - Сторнировать проводки
  */
  PROCEDURE create_allowed_status_transfer
  (
    par_doc_templ_brief       VARCHAR2
   ,par_src_status_ref_brief  VARCHAR2
   ,par_dest_status_ref_brief VARCHAR2
   ,par_is_del_trans          NUMBER DEFAULT 0
   ,par_is_auto_only          NUMBER DEFAULT 0
   ,par_is_storno_trans       NUMBER DEFAULT 0
  );

  /** Добавление перехода для шаблона документа
  * @author Kaplya P.
  * @param p_doc_templ_brief        - Бриф шаблона документа
  * @param p_doc_status_ref_brief   - Бриф статуса
  * @param p_sort                   - Сортировка (по умолчанию максимальный +1)
  */
  PROCEDURE create_templ_status
  (
    par_doc_templ_brief      doc_templ.brief%TYPE
   ,par_doc_status_ref_brief doc_status_ref.brief%TYPE
   ,par_sort                 doc_templ_status.order_num%TYPE DEFAULT NULL
   ,par_update_allowed       doc_templ_status.update_allowed%TYPE DEFAULT 0
   ,par_delete_allowed       doc_templ_status.delete_allowed%TYPE DEFAULT 0
   ,par_is_annul_status      doc_templ_status.is_annul_status%TYPE DEFAULT 0
   ,par_is_active_status     doc_templ_status.is_active_status%TYPE DEFAULT 0
  );

  PROCEDURE create_template
  (
    par_entity_brief entity.brief%TYPE
   ,par_templ_brief  doc_templ.brief%TYPE
   ,par_templ_name   doc_templ.name%TYPE
   ,par_doc_templ_id OUT doc_templ.doc_templ_id%TYPE
  );

  PROCEDURE create_template
  (
    par_entity_brief entity.brief%TYPE
   ,par_templ_brief  doc_templ.brief%TYPE
   ,par_templ_name   doc_templ.name%TYPE
  );
END pkg_doc_templ_fmb;
/
CREATE OR REPLACE PACKAGE BODY pkg_doc_templ_fmb IS

  CURSOR doc_status_action_cur
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
   ,par_proc_name         VARCHAR2
  ) RETURN doc_status_action%ROWTYPE IS
    SELECT dsan.*
      FROM doc_templ          dt
          ,entity             e
          ,doc_templ_status   dts_src
          ,doc_status_ref     dsr_src
          ,doc_status_allowed dsa
          ,doc_templ_status   dts_dest
          ,doc_status_ref     dsr_dest
          ,doc_status_action  dsan
          ,doc_action_type    dat
          ,doc_procedure      dp
     WHERE e.ent_id = dt.ent_id
       AND dts_src.doc_templ_id = dt.doc_templ_id
       AND dsr_src.doc_status_ref_id = dts_src.doc_status_ref_id
       AND dsa.src_doc_templ_status_id = dts_src.doc_templ_status_id
       AND dts_dest.doc_templ_status_id = dsa.dest_doc_templ_status_id
       AND dsr_dest.doc_status_ref_id = dts_dest.doc_status_ref_id
       AND dsan.doc_status_allowed_id = dsa.doc_status_allowed_id
       AND dat.doc_action_type_id = dsan.doc_action_type_id
       AND dp.doc_procedure_id = dsan.obj_uro_id
       AND dt.brief = par_templ_brief
       AND dsr_src.brief = par_src_status_brief
       AND dsr_dest.brief = par_dest_status_brief
       AND dp.name = par_proc_name;

  FUNCTION get_doc_status_allowed_id
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
  ) RETURN NUMBER IS
    v_id NUMBER;
  BEGIN
    SELECT dsa.doc_status_allowed_id
      INTO v_id
      FROM doc_templ          dt
          ,entity             e
          ,doc_templ_status   dts_src
          ,doc_status_ref     dsr_src
          ,doc_status_allowed dsa
          ,doc_templ_status   dts_dest
          ,doc_status_ref     dsr_dest
     WHERE e.ent_id = dt.ent_id
       AND dts_src.doc_templ_id = dt.doc_templ_id
       AND dsr_src.doc_status_ref_id = dts_src.doc_status_ref_id
       AND dsa.src_doc_templ_status_id = dts_src.doc_templ_status_id
       AND dts_dest.doc_templ_status_id = dsa.dest_doc_templ_status_id
       AND dsr_dest.doc_status_ref_id = dts_dest.doc_status_ref_id
       AND dt.brief = par_templ_brief
       AND dsr_src.brief = par_src_status_brief
       AND dsr_dest.brief = par_dest_status_brief;
  
    RETURN v_id;
  EXCEPTION
    WHEN no_data_found THEN
      raise_application_error(-20000, 'Не удалось определить переход');
  END get_doc_status_allowed_id;

  PROCEDURE get_doc_status_proc
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
   ,par_proc_name         VARCHAR2
   ,par_is_execute        OUT NUMBER
   ,par_is_required       OUT NUMBER
  )
  
   IS
    v_doc_status_action pkg_doc_templ_fmb.doc_status_action_cur%ROWTYPE;
  BEGIN
    OPEN pkg_doc_templ_fmb.doc_status_action_cur(par_templ_brief
                                                ,par_src_status_brief
                                                ,par_dest_status_brief
                                                ,par_proc_name);
    LOOP
      EXIT WHEN pkg_doc_templ_fmb.doc_status_action_cur%NOTFOUND;
      FETCH pkg_doc_templ_fmb.doc_status_action_cur
        INTO v_doc_status_action;
    END LOOP;
    IF pkg_doc_templ_fmb.doc_status_action_cur%ROWCOUNT > 1
    THEN
      raise_application_error(-20000
                             ,'В шаблоне документа ' || par_templ_brief ||
                              ' при переходе из статуса ' || par_src_status_brief || ' в статус ' ||
                              par_dest_status_brief || ' найдено несколько процедур ' ||
                              par_proc_name);
    END IF;
    CLOSE pkg_doc_templ_fmb.doc_status_action_cur;
  
    par_is_execute  := v_doc_status_action.is_execute;
    par_is_required := v_doc_status_action.is_required;
  EXCEPTION
    WHEN OTHERS THEN
      IF pkg_doc_templ_fmb.doc_status_action_cur%ISOPEN
      THEN
        CLOSE pkg_doc_templ_fmb.doc_status_action_cur;
      END IF;
      RAISE;
  END get_doc_status_proc;

  PROCEDURE set_doc_status_proc
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
   ,par_proc_name         VARCHAR2
   ,par_is_execute        NUMBER
   ,par_is_required       NUMBER
  ) AS
    v_doc_status_action pkg_doc_templ_fmb.doc_status_action_cur%ROWTYPE;
  BEGIN
    OPEN pkg_doc_templ_fmb.doc_status_action_cur(par_templ_brief
                                                ,par_src_status_brief
                                                ,par_dest_status_brief
                                                ,par_proc_name);
    LOOP
      EXIT WHEN pkg_doc_templ_fmb.doc_status_action_cur%NOTFOUND;
      FETCH pkg_doc_templ_fmb.doc_status_action_cur
        INTO v_doc_status_action;
    END LOOP;
    IF pkg_doc_templ_fmb.doc_status_action_cur%ROWCOUNT > 1
    THEN
      raise_application_error(-20000
                             ,'В шаблоне документа ' || par_templ_brief ||
                              ' при переходе из статуса ' || par_src_status_brief || ' в статус ' ||
                              par_dest_status_brief || ' найдено несколько процедур ' ||
                              par_proc_name);
    END IF;
    CLOSE pkg_doc_templ_fmb.doc_status_action_cur;
  
    UPDATE doc_status_action dsan
       SET dsan.is_execute  = par_is_execute
          ,dsan.is_required = par_is_required
     WHERE dsan.doc_status_action_id = v_doc_status_action.doc_status_action_id;
  EXCEPTION
    WHEN OTHERS THEN
      IF pkg_doc_templ_fmb.doc_status_action_cur %ISOPEN
      THEN
        CLOSE pkg_doc_templ_fmb.doc_status_action_cur;
      END IF;
      RAISE;
  END set_doc_status_proc;

  PROCEDURE add_proc_to_templ
  (
    par_templ_brief           VARCHAR2
   ,par_src_status_brief      VARCHAR2
   ,par_dest_status_brief     VARCHAR2
   ,par_proc_name             VARCHAR2
   ,par_is_execute            NUMBER := 1
   ,par_is_required           NUMBER := 1
   ,par_doc_action_type_brief VARCHAR2 := 'PROCEDURE'
   ,par_sort_order            NUMBER := NULL
  ) IS
    v_doc_status_allowed_id NUMBER;
    v_doc_action_type_id    NUMBER;
    v_ent_id                NUMBER;
    v_doc_procedure_id      NUMBER;
    v_sort_order            INT;
  BEGIN
    IF nvl(par_doc_action_type_brief, 'PROCEDURE') NOT IN ('PROCEDURE', 'OPER')
    THEN
      raise_application_error(-20000, 'Не верный тип процедуры/функции');
    END IF;
  
    BEGIN
      SELECT dat.doc_action_type_id
        INTO v_doc_action_type_id
        FROM doc_action_type dat
       WHERE dat.brief = nvl(par_doc_action_type_brief, 'PROCEDURE');
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20000, 'Не верно указан par_doc_action_type_brief');
    END;
  
    IF nvl(par_doc_action_type_brief, 'PROCEDURE') = 'PROCEDURE'
    THEN
      BEGIN
        SELECT v.doc_procedure_id
          INTO v_doc_procedure_id
          FROM doc_procedure v
         WHERE v.name = par_proc_name;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000, 'Не найдена процедура ' || par_proc_name);
      END;
      BEGIN
        SELECT e.ent_id INTO v_ent_id FROM entity e WHERE e.brief = 'DOC_PROCEDURE';
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000, 'Не найдена сущность DOC_PROCEDURE');
      END;
    ELSE
      BEGIN
        SELECT o.oper_templ_id INTO v_doc_procedure_id FROM oper_templ o WHERE o.name = par_proc_name;
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000
                                 ,'Не найден шаблон операции ' || par_proc_name);
      END;
      BEGIN
        SELECT e.ent_id INTO v_ent_id FROM entity e WHERE e.brief = 'OPER_TEMPL';
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20000, 'Не найдена сущность OPER_TEMPL');
      END;
    END IF;
  
    BEGIN
      v_doc_status_allowed_id := get_doc_status_allowed_id(par_templ_brief       => par_templ_brief
                                                          ,par_src_status_brief  => par_src_status_brief
                                                          ,par_dest_status_brief => par_dest_status_brief);
    
      IF par_sort_order IS NOT NULL
      THEN
        v_sort_order := par_sort_order;
      ELSE
        SELECT nvl(MAX(dsan.sort_order), 0) + 10
          INTO v_sort_order
          FROM doc_status_action dsan
         WHERE dsan.doc_status_allowed_id = v_doc_status_allowed_id;
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20000
                               ,'В шаблоне документа ' || par_templ_brief || ' нет перехода статуса ' ||
                                par_src_status_brief || ' в статус ' || par_dest_status_brief);
    END;
  
    INSERT INTO ven_doc_status_action
      (doc_action_type_id --1
      ,doc_status_allowed_id --2
      ,is_execute --3
      ,is_required --4
      ,obj_ure_id --5
      ,obj_uro_id --6
      ,sort_order) --7
    VALUES
      (v_doc_action_type_id --1
      ,v_doc_status_allowed_id --2
      ,par_is_execute --3
      ,par_is_required --4
      ,v_ent_id --5
      ,v_doc_procedure_id --6
      ,v_sort_order); --7    
  END add_proc_to_templ;

  /* Удаление процедуры с перехода статусов для шаблона документа  
  * @autor Капля П.С.
  * @param par_templ_brief       - шаблон документа
  * @param par_src_status_brief  - переход статуса от
  * @param par_dest_status_brief - переход статуса к
  * @param par_proc_name         - процедура/операция
  */
  PROCEDURE del_proc_from_templ
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
   ,par_proc_name         VARCHAR2
  ) IS
    v_doc_stat_allowed_id NUMBER;
    v_doc_stat_action_id  NUMBER;
  BEGIN
    v_doc_stat_allowed_id := get_doc_status_allowed_id(par_templ_brief       => par_templ_brief
                                                      ,par_src_status_brief  => par_src_status_brief
                                                      ,par_dest_status_brief => par_dest_status_brief);
  
    --384909  Григорьев Ю. Добавил вычищение логов и в EXISTS добавил связь объектов сущностей  
    SELECT doc_status_action_id
      INTO v_doc_stat_action_id
      FROM doc_status_action t
     WHERE t.doc_status_allowed_id = v_doc_stat_allowed_id
       AND (EXISTS (SELECT NULL
                      FROM oper_templ ot
                     WHERE ot.name = par_proc_name
                       AND t.obj_ure_id = 40
                       AND ot.oper_templ_id = t.obj_uro_id
                    UNION
                    SELECT NULL
                      FROM doc_procedure d
                     WHERE d.name = par_proc_name
                       AND t.obj_ure_id = 2762
                       AND d.doc_procedure_id = t.obj_uro_id));
  
    DELETE FROM status_action_log s WHERE s.doc_status_action_id = v_doc_stat_action_id;
  
    DELETE FROM doc_status_action t WHERE t.doc_status_action_id = v_doc_stat_action_id;
  
    IF SQL%ROWCOUNT = 0
    THEN
      raise_application_error(-20000, 'Ничего не удалилось');
    END IF;
  
  END del_proc_from_templ;

  /* Удаление всех процедур с перехода статусов для шаблона документа    
  * @autor Капля П.С.
  * @param par_templ_brief       - шаблон документа
  * @param par_src_status_brief  - переход статуса от
  * @param par_dest_status_brief - переход статуса к
  */
  PROCEDURE del_all_proc_from_templ
  (
    par_templ_brief       VARCHAR2
   ,par_src_status_brief  VARCHAR2
   ,par_dest_status_brief VARCHAR2
  ) IS
    v_doc_stat_allowed_id NUMBER;
  BEGIN
    v_doc_stat_allowed_id := get_doc_status_allowed_id(par_templ_brief       => par_templ_brief
                                                      ,par_src_status_brief  => par_src_status_brief
                                                      ,par_dest_status_brief => par_dest_status_brief);
  
    DELETE FROM doc_status_action t WHERE t.doc_status_allowed_id = v_doc_stat_allowed_id;
  
  END del_all_proc_from_templ;

  PROCEDURE copy_proc_from_templ
  (
    par_templ_brief             VARCHAR2
   ,par_copy_src_status_brief   VARCHAR2
   ,par_copy_dest_status_brief  VARCHAR2
   ,par_paste_src_status_brief  VARCHAR2
   ,par_paste_dest_status_brief VARCHAR2
  ) IS
    v_copy_doc_stat_allowed_id  NUMBER;
    v_paste_doc_stat_allowed_id NUMBER;
  BEGIN
    v_copy_doc_stat_allowed_id := get_doc_status_allowed_id(par_templ_brief       => par_templ_brief
                                                           ,par_src_status_brief  => par_copy_src_status_brief
                                                           ,par_dest_status_brief => par_copy_dest_status_brief);
  
    v_paste_doc_stat_allowed_id := get_doc_status_allowed_id(par_templ_brief       => par_templ_brief
                                                            ,par_src_status_brief  => par_paste_src_status_brief
                                                            ,par_dest_status_brief => par_paste_dest_status_brief);
  
    INSERT INTO ven_doc_status_action
      (doc_action_type_id
      ,doc_status_allowed_id
      ,is_execute
      ,is_required
      ,obj_ure_id
      ,obj_uro_id
      ,sort_order)
      SELECT t.doc_action_type_id
            ,v_paste_doc_stat_allowed_id
            ,t.is_execute
            ,t.is_required
            ,t.obj_ure_id
            ,t.obj_uro_id
            ,t.sort_order
        FROM ven_doc_status_action t
       WHERE t.doc_status_allowed_id = v_copy_doc_stat_allowed_id
       ORDER BY t.sort_order;
  END copy_proc_from_templ;

  /** Добавление перехода для шаблона документа
  * @author Kaplya P.
  * @param p_doc_templ_brief        - Бриф шаблона документа
  * @param p_src_status_ref_brief   - Бриф исходного статуса
  * @param p_dest_status_ref_brief  - Бриф целевого статуса
  * @param p_is_del_trans           - Удаление проводок при преходе
  * @param p_is_auto_only           - Исключить переход из интерфейса
  * @param p_is_storno_trans        - Сторнировать проводки
  */
  PROCEDURE create_allowed_status_transfer
  (
    par_doc_templ_brief       VARCHAR2
   ,par_src_status_ref_brief  VARCHAR2
   ,par_dest_status_ref_brief VARCHAR2
   ,par_is_del_trans          NUMBER DEFAULT 0
   ,par_is_auto_only          NUMBER DEFAULT 0
   ,par_is_storno_trans       NUMBER DEFAULT 0
  ) IS
    v_already_exist        NUMBER;
    v_src_templ_status_id  NUMBER;
    v_dest_templ_status_id NUMBER;
  BEGIN
  
    SELECT COUNT(1)
      INTO v_already_exist
      FROM doc_status_allowed dsa
          ,doc_templ_status   dts1
          ,doc_templ_status   dts2
          ,doc_templ          dt
          ,doc_status_ref     dsr1
          ,doc_status_ref     dsr2
     WHERE dsa.src_doc_templ_status_id = dts1.doc_templ_status_id
       AND dts1.doc_templ_id = dt.doc_templ_id
       AND dt.brief = par_doc_templ_brief
       AND dts1.doc_status_ref_id = dsr1.doc_status_ref_id
       AND dsr1.brief = par_src_status_ref_brief
       AND dsa.dest_doc_templ_status_id = dts2.doc_templ_status_id
       AND dts2.doc_templ_id = dt.doc_templ_id
       AND dts2.doc_status_ref_id = dsr2.doc_status_ref_id
       AND dsr2.brief = par_dest_status_ref_brief;
  
    IF v_already_exist = 0
    THEN
      BEGIN
        SELECT dts.doc_templ_status_id
          INTO v_src_templ_status_id
          FROM doc_templ_status dts
              ,doc_templ        dt
              ,doc_status_ref   dsr
         WHERE dts.doc_templ_id = dt.doc_templ_id
           AND dt.brief = par_doc_templ_brief
           AND dts.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = par_src_status_ref_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найден статус ' || par_src_status_ref_brief ||
                                  ' для документа типа ' || par_doc_templ_brief);
      END;
      BEGIN
      
        SELECT dts.doc_templ_status_id
          INTO v_dest_templ_status_id
          FROM doc_templ_status dts
              ,doc_templ        dt
              ,doc_status_ref   dsr
         WHERE dts.doc_templ_id = dt.doc_templ_id
           AND dt.brief = par_doc_templ_brief
           AND dts.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = par_dest_status_ref_brief;
      EXCEPTION
        WHEN no_data_found THEN
          raise_application_error(-20001
                                 ,'Не найден статус ' || par_dest_status_ref_brief ||
                                  ' для документа типа ' || par_doc_templ_brief);
      END;
    
      INSERT INTO ven_doc_status_allowed
        (src_doc_templ_status_id
        ,dest_doc_templ_status_id
        ,is_del_trans
        ,is_auto_only
        ,is_storno_trans)
      VALUES
        (v_src_templ_status_id
        ,v_dest_templ_status_id
        ,par_is_del_trans
        ,par_is_auto_only
        ,par_is_storno_trans);
    END IF;
  END;

  PROCEDURE create_templ_status
  (
    par_doc_templ_brief      doc_templ.brief%TYPE
   ,par_doc_status_ref_brief doc_status_ref.brief%TYPE
   ,par_sort                 doc_templ_status.order_num%TYPE DEFAULT NULL
   ,par_update_allowed       doc_templ_status.update_allowed%TYPE DEFAULT 0
   ,par_delete_allowed       doc_templ_status.delete_allowed%TYPE DEFAULT 0
   ,par_is_annul_status      doc_templ_status.is_annul_status%TYPE DEFAULT 0
   ,par_is_active_status     doc_templ_status.is_active_status%TYPE DEFAULT 0
  ) IS
    v_doc_templ_id  NUMBER;
    v_status_ref_id NUMBER;
  BEGIN
  
    BEGIN
      SELECT doc_status_ref_id
        INTO v_status_ref_id
        FROM doc_status_ref dsr
       WHERE dsr.brief = par_doc_status_ref_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001, 'Не удалось найти статус по брифу');
    END;
  
    BEGIN
      SELECT doc_templ_id INTO v_doc_templ_id FROM doc_templ dt WHERE brief = par_doc_templ_brief;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Не удалось найти шаблон документа по брифу');
    END;
  
    INSERT INTO ven_doc_templ_status
      (doc_status_ref_id
      ,doc_templ_id
      ,order_num
      ,is_annul_status
      ,is_active_status
      ,delete_allowed
      ,update_allowed)
    VALUES
      (v_status_ref_id
      ,v_doc_templ_id
      ,nvl(par_sort
          ,(SELECT nvl(MAX(order_num), 0) + 1
             FROM doc_templ_status dts1
            WHERE dts1.doc_templ_id = v_doc_templ_id))
      ,par_is_annul_status
      ,par_is_active_status
      ,par_delete_allowed
      ,par_update_allowed);
  
  END;

  PROCEDURE create_template
  (
    par_entity_brief entity.brief%TYPE
   ,par_templ_brief  doc_templ.brief%TYPE
   ,par_templ_name   doc_templ.name%TYPE
   ,par_doc_templ_id OUT doc_templ.doc_templ_id%TYPE
  ) IS
    v_entity_id entity.ent_id%TYPE;
  BEGIN
    assert_deprecated(par_entity_brief IS NULL, 'Должна быть указана сущность');
    assert_deprecated(par_templ_brief IS NULL
          ,'Должно быть указано сокращенное название шаблона');
    assert_deprecated(par_templ_name IS NULL
          ,'Должно быть указано название шаблона');
  
    v_entity_id := ent.id_by_brief(p_brief => par_entity_brief);
    IF v_entity_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'Сущность с сокращенным названием "' || par_templ_brief ||
                              '" не найдена');
    END IF;
  
    SELECT sq_doc_templ.nextval INTO par_doc_templ_id FROM dual;
    INSERT INTO ven_doc_templ
      (doc_templ_id, brief, doc_ent_id, NAME)
    VALUES
      (par_doc_templ_id, par_templ_brief, v_entity_id, par_templ_name);
  END create_template;

  PROCEDURE create_template
  (
    par_entity_brief entity.brief%TYPE
   ,par_templ_brief  doc_templ.brief%TYPE
   ,par_templ_name   doc_templ.name%TYPE
  ) IS
    v_doc_templ_id doc_templ.doc_templ_id%TYPE;
  BEGIN
    create_template(par_entity_brief => par_entity_brief
                   ,par_templ_brief  => par_templ_brief
                   ,par_templ_name   => par_templ_name
                   ,par_doc_templ_id => v_doc_templ_id);
  END;
END pkg_doc_templ_fmb; 
/
