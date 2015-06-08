CREATE OR REPLACE PACKAGE PKG_TAP IS

  -- Author  : Байтин А.
  -- Created : 09.06.2011 13:11:18
  -- Purpose : Пакет для работы со справочником ТАП, включая справочник подписантов

  -- Дата окончания по умолчанию
  gc_default_end_date CONSTANT DATE := to_date('31.12.3000', 'dd.mm.yyyy');

  /*
    Байтин А.
    Создание новой версии (копии предыдущей)
  */
  PROCEDURE create_new_version
  (
    par_tap_header_id IN OUT NUMBER
   ,par_tap_number    NUMBER
   ,par_open_date     DATE
   ,par_close_date    DATE DEFAULT gc_default_end_date
   ,par_tap_id        OUT NUMBER
  );
  /*
    Байтин А.
    Возвращает установленную по умолчанию дату окончания
  */
  FUNCTION get_default_end_date RETURN DATE;
END PKG_TAP;
/
CREATE OR REPLACE PACKAGE BODY PKG_TAP IS
  -- Статус отправки во внешние БД по умолчанию
  gc_default_send_status CONSTANT NUMBER(1) := 0;
  -- Краткое название шаблона документа ТАП (версия)
  gc_t_tap_brief CONSTANT VARCHAR2(30) := 'T_TAP';
  -- ИД сущности T_TAP;
  gv_tap_ent_id NUMBER;

  /*
    Байтин А.
    Проверка корректности заполнения данных в версии
  */
  PROCEDURE check_tap
  (
    par_tap_header_id NUMBER
   ,par_ver_num       NUMBER
   ,par_tap_number    NUMBER
   ,par_open_date     DATE
   ,par_start_date    DATE
  ) IS
    v_cnt NUMBER;
  BEGIN
  
    -- Проверка на заполнение параметров
    IF par_start_date IS NULL
    THEN
      raise_application_error(-20001
                             ,'Дата начала версии не должена быть пустой');
    END IF;
  
    -- Проверка значений
    -- Проверка номера на уникальность - номер не должен использоваться в другом ТАПе
    SELECT COUNT(1)
      INTO v_cnt
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM ven_t_tap        tt
                  ,ven_t_tap_header th
             WHERE th.t_tap_header_id != par_tap_header_id
               AND tt.tap_number = par_tap_number
               AND tt.t_tap_id = th.last_tap_id);
    IF v_cnt = 1
    THEN
      raise_application_error(-20001
                             ,'Такой номер ТАП уже используется в другом ТАПе');
    END IF;
    -- Проверка даты открытия - не должна быть ранее 01.01.2009
    IF par_open_date < to_date('01.01.2009', 'dd.mm.yyyy')
    THEN
      raise_application_error(-20001
                             ,'Дата открытия ТАП не должна быть меньше 01.01.2009');
    END IF;
    -- Проверка даты открытия - не должна быть позднее текущей даты
    IF par_open_date > SYSDATE
    THEN
      raise_application_error(-20001
                             ,'Дата открытия ТАП не должна быть позже текущей даты');
    END IF;
    -- Проверка даты начала версии - не должна быть больше текущей даты
    IF par_start_date > SYSDATE
    THEN
      raise_application_error(-20001
                             ,'Дата начала версии ТАП не должна быть позже текущей даты');
    END IF;
    -- Проверка даты начала первой версии - не должна быть больше даты открытия
    IF par_ver_num = 1
    THEN
      IF par_start_date > par_open_date
      THEN
        raise_application_error(-20001
                               ,'Дата начала версии ТАП не должна быть позже даты открытия');
      END IF;
    END IF;
    IF par_ver_num >= 2
    THEN
      -- Проверка даты начала второй и более версии - не должна быть меньше или равной дате начала предыдущей версии
      SELECT COUNT(1)
        INTO v_cnt
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM ven_t_tap tt
               WHERE tt.t_tap_header_id = par_tap_header_id
                 AND tt.ver_num = par_ver_num - 1
                 AND tt.start_date > par_start_date);
      IF v_cnt = 1
      THEN
        raise_application_error(-20001
                               ,'Дата начала версии ТАП не должна быть меньше или равной дате начала действия предыдущей версии');
      END IF;
    END IF;
  END check_tap;

  /*
    Байтин А.
    Внесение изменений в структуру организации
    При переходе Проект - Действующий
  */
  PROCEDURE modify_agn_tac(par_t_tap_id NUMBER) IS
    vr_tap     ven_t_tap%ROWTYPE;
    vr_agn_tac ven_agn_tac%ROWTYPE;
  BEGIN
  
    SELECT * INTO vr_tap FROM ven_t_tap tp WHERE tp.t_tap_id = par_t_tap_id;
  
    SELECT th.agn_tac_id
      INTO vr_agn_tac.agn_tac_id
      FROM ven_t_tap_header th
     WHERE th.t_tap_header_id = vr_tap.t_tap_header_id;
  
    -- Если ID нет, создаем запись
    IF vr_agn_tac.agn_tac_id IS NULL
    THEN
      -- Номер
      vr_agn_tac.tac_num := to_char(vr_tap.tap_number);
      -- Наименование
      --vr_agn_tac.tac_name := vr_tap.tap_name;
      -- ОПФ ТАП
      vr_agn_tac.tac_ent := 'некоммерческая организация';
      -- Добавление записи
      SELECT sq_agn_tac.nextval INTO vr_agn_tac.agn_tac_id FROM dual;
      INSERT INTO ven_agn_tac VALUES vr_agn_tac;
    
      -- Запись ID ТАП в заголовок ТАП
      UPDATE ven_t_tap_header th
         SET th.agn_tac_id = vr_agn_tac.agn_tac_id
       WHERE th.t_tap_header_id = vr_tap.t_tap_header_id;
      -- Если есть, обновляем инфой из ТАП
    ELSE
      -- Номер
      vr_agn_tac.tac_num := to_char(vr_tap.tap_number);
      -- Наименование
      --vr_agn_tac.tac_name := vr_tap.tap_name;
      -- Обновляем
      UPDATE ven_agn_tac at
         SET at.tac_num  = vr_agn_tac.tac_num
            ,at.tac_name = vr_agn_tac.tac_name
       WHERE at.agn_tac_id = vr_agn_tac.agn_tac_id;
    END IF;
  END modify_agn_tac;
  /*
    Байтин А.
    Удаление из справочника трансфер-агентских пунктов
  */
  PROCEDURE delete_from_agn_tac(par_tap_id NUMBER) IS
    v_agn_tac_id    NUMBER;
    v_tap_header_id NUMBER;
  BEGIN
    SELECT th.agn_tac_id
          ,th.t_tap_header_id
      INTO v_agn_tac_id
          ,v_tap_header_id
      FROM ven_t_tap_header th
          ,ven_t_tap        tt
     WHERE tt.t_tap_id = par_tap_id
       AND tt.t_tap_header_id = th.t_tap_header_id;
  
    UPDATE ven_t_tap_header th SET th.agn_tac_id = NULL WHERE th.t_tap_header_id = v_tap_header_id;
  
    DELETE FROM ven_agn_tac at WHERE at.agn_tac_id = v_agn_tac_id;
  END delete_from_agn_tac;

  /*
    Байтин А.
    Установка активной версии в заголовок
    Работает при смене статуса из "Действующий" в "Проект" и наоборот
  */
  /*
    Отключено
    procedure set_active_version
    (
      par_tap_id number
    )
    is
      v_tap_id        number;
      v_tap_header_id number;
      v_cnt           number;
    begin
      if doc.get_doc_status_brief(par_tap_id, to_date('31.12.3000','dd.mm.yyyy')) = 'PROJECT' then
        select nullif(t.t_tap_id,par_tap_id)
              ,t.t_tap_header_id
          into v_tap_id
              ,v_tap_header_id
          from ven_t_tap tt
              ,ven_t_tap t
         where tt.t_tap_id = par_tap_id
           and tt.t_tap_header_id = t.t_tap_header_id
           and t.ver_num          = case
                                      when tt.ver_num > 1 then tt.ver_num-1
                                      else tt.ver_num
                                    end;
        -- Если нет активных версии, проверка на использование ТАП в ТАЦ
        if v_tap_id is null then
          select count(1)
            into v_cnt
            from dual
           where exists (select null
                           from ven_t_tac tc
                          where tc.t_tap_header_id = v_tap_header_id);
          if v_cnt = 1 then
            raise_application_error(-20001, 'ТАП указан в одном из ТАЦ, снятие активности запрещено');
          end if;
        end if;
      elsif doc.get_doc_status_brief(par_tap_id, to_date('31.12.3000','dd.mm.yyyy')) = 'CURRENT' then
        v_tap_id := par_tap_id;
        select tt.t_tap_header_id
          into v_tap_header_id
          from ven_t_tap tt
         where tt.t_tap_id = par_tap_id;
      else
        raise_application_error(-20001, 'Установка активной версии не предусмотрена для данной смены статуса');
      end if;
      update ven_t_tap_header th
         set th.active_tap_id = v_tap_id
       where th.t_tap_header_id = v_tap_header_id;
      -- Изменения в структуре организации
      if v_tap_id is not null then
        modify_agn_tac(v_tap_id);
      else
        delete_from_agn_tac(par_tap_id);
      end if;
    end set_active_version;
  */
  /*
    Байтин А.
    Установка последней версии в заголовок
  */
  PROCEDURE set_last_version
  (
    par_tap_header_id NUMBER
   ,par_tap_id        NUMBER
  ) IS
  BEGIN
    UPDATE ven_t_tap_header th
       SET th.last_tap_id = par_tap_id
     WHERE th.t_tap_header_id = par_tap_header_id;
  END set_last_version;
  /*
    Байтин А.
    Создание заголовка ТАП
  */
  PROCEDURE create_header(par_tap_header_id OUT NUMBER) IS
  BEGIN
    SELECT sq_t_tap_header.nextval INTO par_tap_header_id FROM dual;
    INSERT INTO ven_t_tap_header (t_tap_header_id) VALUES (par_tap_header_id);
  END create_header;

  /*
    Байтин А.
    Получение следующего номера версии
  */
  FUNCTION get_new_ver_num(par_tap_header_id NUMBER) RETURN NUMBER IS
    v_ver_num ven_t_tap.ver_num%TYPE;
  BEGIN
    SELECT nvl(MAX(tt.ver_num), 0) + 1
      INTO v_ver_num
      FROM ven_t_tap tt
     WHERE tt.t_tap_header_id = par_tap_header_id;
    RETURN v_ver_num;
  END get_new_ver_num;
  /*
    Байтин А.
    Базовое создание версии
  */
  PROCEDURE create_version_base
  (
    par_tap_header_id NUMBER
   ,par_tap_number    NUMBER
   ,par_open_date     DATE
   ,par_start_date    DATE
   ,par_close_date    DATE
   ,par_ver_num       NUMBER
   ,par_sys_user_id   NUMBER
   ,par_tap_id        OUT NUMBER
  ) IS
  BEGIN
  
    SELECT sq_t_tap.nextval INTO par_tap_id FROM dual;
  
    INSERT INTO ven_t_tap
      (t_tap_id
      ,t_tap_header_id
      ,tap_number
      ,open_date
      ,start_date
      ,close_date
      ,send_status
      ,ver_num
      ,sys_user_id)
    VALUES
      (par_tap_id
      ,par_tap_header_id
      ,par_tap_number
      ,par_open_date
      ,par_start_date
      ,par_close_date
      ,gc_default_send_status
      ,par_ver_num
      ,par_sys_user_id);
  
    set_last_version(par_tap_header_id, par_tap_id);
  END create_version_base;

  /*
    Байтин А.
    Создание новой версии (копии предыдущей)
  */
  PROCEDURE create_new_version
  (
    par_tap_header_id IN OUT NUMBER
   ,par_tap_number    NUMBER
   ,par_open_date     DATE
   ,par_close_date    DATE DEFAULT gc_default_end_date
   ,par_tap_id        OUT NUMBER
  ) IS
    v_sys_user_id sys_user.sys_user_id%TYPE;
    v_start_date  DATE := SYSDATE;
  BEGIN
    -- Получение пользователя
    BEGIN
      SELECT su.sys_user_id INTO v_sys_user_id FROM sys_user su WHERE su.sys_user_name = USER;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        raise_application_error(-20001
                               ,'Пользователь ' || USER || ' не является пользователем системы');
    END;
    -- Проверки
    /*
        check_tap(par_tap_header_id => par_tap_header_id
                 ,par_ver_num       => v_ver_num
                 ,par_tap_number    => par_tap_number
                 ,par_open_date     => par_open_date
                 ,par_start_date    => v_start_date);
    */
    IF par_tap_header_id IS NULL
    THEN
      -- Создание заголовка
      create_header(par_tap_header_id);
    END IF;
    -- Создание новой версии
    create_version_base(par_tap_header_id => par_tap_header_id
                       ,par_tap_number    => par_tap_number
                       ,par_open_date     => par_open_date
                       ,par_start_date    => v_start_date
                       ,par_close_date    => nvl(par_close_date, gc_default_end_date)
                       ,par_ver_num       => get_new_ver_num(par_tap_header_id)
                       ,par_sys_user_id   => v_sys_user_id
                       ,par_tap_id        => par_tap_id);
    IF par_close_date != gc_default_end_date
    THEN
      UPDATE ven_t_tac_to_tap tt
         SET tt.end_date = par_close_date
       WHERE tt.t_tap_header_id = par_tap_header_id
         AND tt.end_date = gc_default_end_date
         AND EXISTS (SELECT NULL FROM ven_t_tac_header th WHERE th.last_tac_id = tt.t_tac_id);
    END IF;
    modify_agn_tac(par_tap_id);
  END create_new_version;
  /*
    Байтин А.
    Возвращает установленную по умолчанию дату окончания
  */
  FUNCTION get_default_end_date RETURN DATE IS
  BEGIN
    RETURN gc_default_end_date;
  END get_default_end_date;

BEGIN
  SELECT en.ent_id INTO gv_tap_ent_id FROM entity en WHERE en.brief = gc_t_tap_brief;
END PKG_TAP;
/
