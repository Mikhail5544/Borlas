CREATE OR REPLACE PACKAGE PKG_ROO IS

  -- Author  : Байтин А.
  -- Created : 14.06.2011 17:43:54
  -- Purpose : Пакет для работы со справочником РОО

  /*
    Байтин А.
    Генерация нового номера
  */
  FUNCTION get_next_number RETURN NUMBER;
  /*
    Байтин А.
    Возвращает установленную по умолчанию дату окончания
  */
  FUNCTION get_default_end_date RETURN DATE;
  /*
    Байтин А.
    Проверка значений РОО
  */
  PROCEDURE check_roo
  (
    par_roo_name      VARCHAR2
   ,par_open_date     DATE
   ,par_start_date    DATE
   ,par_roo_number    NUMBER
   ,par_department_id VARCHAR2
   ,par_roo_header_id NUMBER
  );
  /*
    Байтин А.
    Добавляет сотрудника в РОО
  */
  PROCEDURE insert_employee
  (
    par_roo_id          NUMBER
   ,par_sys_user_id     NUMBER
   ,par_begin_date      DATE
   ,par_end_date        DATE
   ,par_roo_employee_id OUT NUMBER
  );
  /*
    Байтин А.
    Исправляет запись сотрудника РОО
  */
  PROCEDURE update_employee
  (
    par_roo_employee_id NUMBER
   ,par_sys_user_id     NUMBER
   ,par_begin_date      DATE
   ,par_end_date        DATE
  );
  /*
    Байтин А.
    Удаляет запись сотрудника из РОО
  */
  PROCEDURE delete_employee(par_roo_employee_id NUMBER);
  /*
    Байтин А.
    Восстановление сотрудников
  */
  PROCEDURE restore_employees
  (
    par_roo_header_id NUMBER
   ,par_roo_to_id     NUMBER
  );
  /*
    Байтин А.
    Создание новой версии
  */
  PROCEDURE create_new_version
  (
    par_roo_header_id   IN OUT NUMBER
   ,par_roo_number      NUMBER
   ,par_roo_name        VARCHAR2
   ,par_department_id   NUMBER
   ,par_open_date       DATE
   ,par_close_date      DATE
   ,par_corp_mail       VARCHAR2
   ,par_t_tap_header_id NUMBER
   ,par_roo_id          OUT NUMBER
  );
END PKG_ROO;
/
CREATE OR REPLACE PACKAGE BODY PKG_ROO IS
  -- Дата окончания по умолчанию
  gc_default_end_date CONSTANT DATE := to_date('31.12.3000', 'dd.mm.yyyy');
  -- Краткое название шаблона документа РОО (версия)
  gc_t_roo_brief CONSTANT VARCHAR2(30) := 'T_ROO';
  -- ИД сущности T_ROO;
  gv_roo_ent_id NUMBER;
  -- Список сотрудников
  TYPE t_roo_employees IS TABLE OF t_roo_employee%ROWTYPE;
  gvr_employees t_roo_employees;

  /*
    Байтин А.
    Генерация нового номера
  */
  FUNCTION get_next_number RETURN NUMBER IS
    v_roo_number NUMBER;
  BEGIN
    SELECT nvl(MAX(roo_number) + 1, 1) INTO v_roo_number FROM ven_t_roo_header;
    RETURN v_roo_number;
  END get_next_number;

  /*
    Байтин А.
    Проверка значений РОО
  */
  PROCEDURE check_roo
  (
    par_roo_name      VARCHAR2
   ,par_open_date     DATE
   ,par_start_date    DATE
   ,par_roo_number    NUMBER
   ,par_department_id VARCHAR2
   ,par_roo_header_id NUMBER
  ) IS
    v_cnt NUMBER;
  BEGIN
    -- *Проверки на заполненность полей*
  
    -- Номер РОО не пустой
    IF par_roo_number IS NULL
    THEN
      raise_application_error(-20001, 'Номер РОО должен быть указан');
    END IF;
    -- Название РОО не пустое
    IF par_roo_name IS NULL
    THEN
      raise_application_error(-20001, 'Название РОО должно быть указано');
    END IF;
    -- Дата открытия не пустая
    IF par_open_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'Дата открытия должна быть указана');
    END IF;
    -- Дата начала версии
    IF par_start_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'Дата начала версии должна быть указана');
    END IF;
  
    -- *Проверки на корректность значений*
  
    -- Номер
    IF par_roo_number NOT BETWEEN 1 AND 999
    THEN
      raise_application_error(-20001
                             ,'Номер РОО должен быть в диапазоне с 1 до 999');
    END IF;
    -- Дата открытия не ранее 01.01.2000
    IF par_open_date < to_date('01.01.2000', 'dd.mm.yyyy')
    THEN
      raise_application_error(-20001
                             ,'Дата открытия не должна быть менее 01.01.2000');
    END IF;
    -- Подразделение не закрыто
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_sales_dept_header sh
                  ,ven_sales_dept        sd
             WHERE sh.organisation_tree_id = par_department_id
               AND sh.last_sales_dept_id = sd.sales_dept_id
               AND sd.close_date != pkg_roo.get_default_end_date);
    IF v_cnt = 1
    THEN
      raise_application_error(-20001, 'Выбрано закрытое подразделение');
    END IF;
  
    -- *Проверки на уникальность значений*
  
    -- Уникальность названия
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS
     (SELECT NULL
              FROM ven_t_roo tt
             WHERE upper(tt.roo_name) = upper(par_roo_name)
               AND (par_roo_header_id IS NULL OR tt.t_roo_header_id != par_roo_header_id));
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'РОО с таким названием уже существует');
    END IF;
  END check_roo;

  /*
    Байтин А.
    Проверка значений сотрудников
  */
  PROCEDURE check_employee
  (
    par_roo_id            NUMBER
   ,par_sys_user_id       NUMBER
   ,par_begin_date        DATE
   ,par_end_date          DATE
   ,par_t_roo_employee_id NUMBER
  ) IS
    v_cnt           NUMBER;
    v_roo_header_id NUMBER;
    v_contact       contact.obj_name_orig%TYPE;
    v_number        ven_t_roo_header.roo_number%TYPE;
  BEGIN
    -- *Проверка заполнения*
    -- 
    IF par_roo_id IS NULL
    THEN
      raise_application_error(-20001, 'ИД РОО должен быть указан');
    END IF;
    IF par_sys_user_id IS NULL
    THEN
      raise_application_error(-20001
                             ,'ИД пользователя должен быть указан');
    END IF;
    IF par_begin_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'Дата начала действия должна быть указана');
    END IF;
    -- *Проверка корректности*
    IF par_begin_date > nvl(par_end_date, gc_default_end_date)
    THEN
      raise_application_error(-20001
                             ,'Дата начала не может привышать дату окончания');
    END IF;
    -- *Проверка уникальности*
    BEGIN
      SELECT co.obj_name_orig
            ,rh.roo_number
        INTO v_contact
            ,v_number
        FROM contact            co
            ,ven_employee       ee
            ,ven_sys_user       su
            ,ven_t_roo_employee re
            ,ven_t_roo          ro
            ,ven_t_roo_header   rh
       WHERE ee.contact_id = co.contact_id
         AND re.sys_user_id = su.employee_id
         AND re.sys_user_id = par_sys_user_id
         AND re.t_roo_id = ro.t_roo_id
         AND ro.t_roo_header_id = rh.t_roo_header_id
         AND ro.t_roo_id = rh.last_roo_id
         AND rh.t_roo_header_id != v_roo_header_id
         AND re.begin_date <= nvl(par_end_date, gc_default_end_date)
         AND re.end_date >= par_begin_date
         AND rownum = 1;
    
      raise_application_error(-20001
                             ,'Внимание! Указанный сотрудник (' || v_contact ||
                              ') уже числится в РОО (' || v_number || ')');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_t_roo_employee re
             WHERE re.t_roo_id = par_roo_id
               AND re.begin_date <= nvl(par_end_date, gc_default_end_date)
               AND re.end_date >= par_begin_date
               AND re.sys_user_id = par_sys_user_id
               AND re.t_roo_employee_id != par_t_roo_employee_id);
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'Внимание! Сотрудник уже действует!');
    END IF;
  END check_employee;

  /*
    Байтин А.
    Установка последней версии в заголовок
  */
  PROCEDURE set_last_version
  (
    par_roo_header_id NUMBER
   ,par_roo_id        NUMBER
  ) IS
  BEGIN
    UPDATE ven_t_roo_header th
       SET th.last_roo_id = par_roo_id
     WHERE th.t_roo_header_id = par_roo_header_id;
  END set_last_version;

  /*
    Байтин А.
    Создание заголовка
  */
  PROCEDURE create_header
  (
    par_roo_number    NUMBER
   ,par_roo_header_id OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_t_roo_header.nextval INTO par_roo_header_id FROM dual;
    INSERT INTO ven_t_roo_header
      (t_roo_header_id, roo_number)
    VALUES
      (par_roo_header_id, par_roo_number);
  END create_header;
  /*
    Байтин А.
    Получение следующего номера версии
  */
  FUNCTION get_new_ver_num(par_roo_header_id NUMBER) RETURN NUMBER IS
    v_ver_num ven_t_roo.ver_num%TYPE;
  BEGIN
    SELECT nvl(MAX(tt.ver_num), 0) + 1
      INTO v_ver_num
      FROM ven_t_roo tt
     WHERE tt.t_roo_header_id = par_roo_header_id;
    RETURN v_ver_num;
  END get_new_ver_num;

  /*
    Байтин А.
    Базовое создание версии
  */
  -- Илюшкин С. 01/06/2012 Добавил поле КПЯ (RT 168362)  
  PROCEDURE create_version_base
  (
    par_roo_header_id   NUMBER
   ,par_roo_name        VARCHAR2
   ,par_department_id   NUMBER
   ,par_open_date       DATE
   ,par_start_date      DATE
   ,par_close_date      DATE
   ,par_corp_mail       VARCHAR2
   ,par_t_tap_header_id NUMBER
   ,par_ver_num         NUMBER
   ,par_sys_user_id     NUMBER
   ,par_roo_id          OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_t_roo.nextval INTO par_roo_id FROM dual;
  
    INSERT INTO ven_t_roo
      (t_roo_id
      ,t_roo_header_id
      ,roo_name
      ,organisation_tree_id
      ,t_tap_header_id
      ,open_date
      ,start_date
      ,close_date
      ,ver_num
      ,sys_user_id
      ,corp_mail)
    VALUES
      (par_roo_id
      ,par_roo_header_id
      ,par_roo_name
      ,par_department_id
      ,par_t_tap_header_id
      ,par_open_date
      ,par_start_date
      ,par_close_date
      ,par_ver_num
      ,par_sys_user_id
      ,par_corp_mail);
  
    set_last_version(par_roo_header_id, par_roo_id);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      raise_application_error(-20001
                             ,'В справочнике шаблонов документов отсутствует шаблон с кратким названием "' ||
                              gc_t_roo_brief || '"');
  END create_version_base;
  /*
    Байтин А.
    Возвращает установленную по умолчанию дату окончания
  */
  FUNCTION get_default_end_date RETURN DATE IS
  BEGIN
    RETURN gc_default_end_date;
  END get_default_end_date;
  /*
    Байтин А.
    Сохранение сотрудников в коллекцию
  */
  PROCEDURE store_employees(par_roo_header_id NUMBER) IS
  BEGIN
    SELECT * BULK COLLECT
      INTO gvr_employees
      FROM t_roo_employee tt
     WHERE tt.t_roo_id =
           (SELECT th.last_roo_id FROM t_roo_header th WHERE th.t_roo_header_id = par_roo_header_id);
  END store_employees;
  /*
    Байтин А.
    Восстановление сотрудников
  */
  PROCEDURE restore_employees
  (
    par_roo_header_id NUMBER
   ,par_roo_to_id     NUMBER
  ) IS
    v_prev_roo_id NUMBER;
  BEGIN
    IF gvr_employees IS NOT NULL
    THEN
      -- Получение предыдущей версии
      SELECT tc.t_roo_id
        INTO v_prev_roo_id
        FROM ven_t_roo tc
       WHERE tc.t_roo_header_id = par_roo_header_id
         AND tc.ver_num = (SELECT tt.ver_num - 1 FROM ven_t_roo tt WHERE tt.t_roo_id = par_roo_to_id);
      -- Перенос обновленных FORMS ТАПов из предыдущей версии на новую
      UPDATE t_roo_employee tt
         SET tt.t_roo_employee_id = sq_t_roo_employee.nextval
            ,tt.t_roo_id          = par_roo_to_id
       WHERE tt.t_roo_id = v_prev_roo_id;
      -- Вставка сохраненных при создании версии ТАПов 
      FORALL i IN gvr_employees.first .. gvr_employees.last
        INSERT INTO t_roo_employee VALUES gvr_employees (i);
      gvr_employees.delete;
    END IF;
  END restore_employees;

  /*
    Байтин А.
    Создание новой версии
  */
  -- Илюшкин С. 01/06/2012 Добавил поле КПЯ (RT 168362)  
  PROCEDURE create_new_version
  (
    par_roo_header_id   IN OUT NUMBER
   ,par_roo_number      NUMBER
   ,par_roo_name        VARCHAR2
   ,par_department_id   NUMBER
   ,par_open_date       DATE
   ,par_close_date      DATE
   ,par_corp_mail       VARCHAR2
   ,par_t_tap_header_id NUMBER
   ,par_roo_id          OUT NUMBER
  ) IS
    v_start_date  DATE := SYSDATE;
    v_sys_user_id sys_user.sys_user_id%TYPE;
  BEGIN
    IF par_roo_header_id IS NULL
    THEN
      -- Создание заголовка
      create_header(par_roo_number, par_roo_header_id);
    ELSE
      -- Сохранение сотрудников, для того чтобы FORMS не затерли при POST'е
      store_employees(par_roo_header_id);
    END IF;
    -- Получение пользователя
    BEGIN
      SELECT su.sys_user_id INTO v_sys_user_id FROM sys_user su WHERE su.sys_user_name = USER;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Пользователь ' || USER || ' не является пользователем системы');
    END;
    -- Создание новой версии
    create_version_base(par_roo_header_id   => par_roo_header_id
                       ,par_roo_name        => par_roo_name
                       ,par_open_date       => par_open_date
                       ,par_start_date      => v_start_date
                       ,par_close_date      => nvl(par_close_date, gc_default_end_date)
                       ,par_corp_mail       => par_corp_mail
                       ,par_t_tap_header_id => par_t_tap_header_id
                       ,par_ver_num         => get_new_ver_num(par_roo_header_id)
                       ,par_department_id   => par_department_id
                       ,par_sys_user_id     => v_sys_user_id
                       ,par_roo_id          => par_roo_id);
  END create_new_version;

  /*
    Байтин А.
    Добавляет сотрудника в РОО
  */
  PROCEDURE insert_employee
  (
    par_roo_id          NUMBER
   ,par_sys_user_id     NUMBER
   ,par_begin_date      DATE
   ,par_end_date        DATE
   ,par_roo_employee_id OUT NUMBER
  ) IS
  BEGIN
    SELECT sq_t_roo_employee.nextval INTO par_roo_employee_id FROM dual;
  
    check_employee(par_roo_id            => par_roo_id
                  ,par_sys_user_id       => par_sys_user_id
                  ,par_begin_date        => par_begin_date
                  ,par_end_date          => par_end_date
                  ,par_t_roo_employee_id => par_roo_employee_id);
  
    INSERT INTO ven_t_roo_employee
      (t_roo_employee_id, t_roo_id, sys_user_id, begin_date, end_date)
    VALUES
      (par_roo_employee_id
      ,par_roo_id
      ,par_sys_user_id
      ,par_begin_date
      ,nvl(par_end_date, gc_default_end_date));
  END insert_employee;
  /*
    Байтин А.
    Исправляет запись сотрудника в РОО
  */
  PROCEDURE update_employee
  (
    par_roo_employee_id NUMBER
   ,par_sys_user_id     NUMBER
   ,par_begin_date      DATE
   ,par_end_date        DATE
  ) IS
    v_roo_id ven_t_roo.t_roo_id%TYPE;
  BEGIN
    SELECT re.t_roo_id
      INTO v_roo_id
      FROM ven_t_roo_employee re
     WHERE re.t_roo_employee_id = par_roo_employee_id;
  
    check_employee(par_roo_id            => v_roo_id
                  ,par_sys_user_id       => par_sys_user_id
                  ,par_begin_date        => par_begin_date
                  ,par_end_date          => par_end_date
                  ,par_t_roo_employee_id => par_roo_employee_id);
  
    UPDATE ven_t_roo_employee ta
       SET sys_user_id = par_sys_user_id
          ,begin_date  = par_begin_date
          ,end_date    = nvl(par_end_date, gc_default_end_date)
     WHERE ta.t_roo_employee_id = par_roo_employee_id;
  END update_employee;
  /*
    Байтин А.
    Удаляет запись сотрудника в РОО
  */
  PROCEDURE delete_employee(par_roo_employee_id NUMBER) IS
  BEGIN
    DELETE FROM ven_t_roo_employee ta WHERE ta.t_roo_employee_id = par_roo_employee_id;
  END delete_employee;
BEGIN
  SELECT en.ent_id INTO gv_roo_ent_id FROM entity en WHERE en.brief = gc_t_roo_brief;
END PKG_ROO;
/
