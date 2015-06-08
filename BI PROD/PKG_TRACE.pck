CREATE OR REPLACE PACKAGE pkg_trace IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 30.09.2013 15:05:53
  -- Purpose : Трассировка функционала

  SUBTYPE t_method IS VARCHAR2(6);
  SUBTYPE t_object_name IS VARCHAR(30);

  FUNCTION trace_to_table RETURN t_method;

  FUNCTION trace_to_output RETURN t_method;

  FUNCTION trace_to_pipe RETURN t_method;

  -- Байтин А.
  -- Включение трассировки
  PROCEDURE enable_trace
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_method            t_method
  );

  -- Байтин А.
  -- Отключение трассировки
  PROCEDURE disable_trace
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  );

  -- Байтин А.
  -- Добавление переменной для логирования (NUMBER)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_value NUMBER
  );

  -- Байтин А.
  -- Добавление переменной для логирования (DATE)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_value DATE
  );

  -- Байтин А.
  -- Добавление переменной для логирования (BOOLEAN)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_value BOOLEAN
  );

  -- Байтин А.
  -- Добавление переменной для логирования (VARCHAR2)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_value VARCHAR2
  );

  -- Байтин А.
  -- Добавление переменной для логирования (VARCHAR2)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_type  trace_log_vars.trace_var_type%TYPE
   ,par_trace_var_value trace_log_vars.trace_var_value%TYPE
  );

  -- Байтин А.
  -- Очистка трассировочной таблицы
  PROCEDURE clear_trace_table
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  );

  -- Байтин А.
  -- Выполнение трассировки
  PROCEDURE trace
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_message           trace_log.message%TYPE
  );

  -- Капля П.
  -- Процедура для выполнения в начале вызова процедуры
  PROCEDURE trace_procedure_start
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  );

  -- Капля П.
  -- Процедура для выполнения в начале вызова функции
  PROCEDURE trace_function_start
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  );

  -- Капля П.
  -- Процедура для выполнения в конце вызова процедуры
  PROCEDURE trace_procedure_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  );

  -- Капля П.
  -- Процедура для выполнения в конце вызова функции
  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  );
  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_result_value      NUMBER
  );
  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_result_value      VARCHAR2
  );
  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_result_value      DATE
  );
  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_result_value      BOOLEAN
  );
END pkg_trace;
/
CREATE OR REPLACE PACKAGE BODY pkg_trace IS
  gv_sid NUMBER;

  TYPE t_trace_subobjects IS TABLE OF BOOLEAN INDEX BY trace_log.trace_subobj_name%TYPE;
  TYPE t_trace_objects IS TABLE OF t_trace_subobjects INDEX BY trace_log.trace_obj_name%TYPE;

  TYPE t_variable IS RECORD(
     var_type  trace_log_vars.trace_var_type%TYPE
    ,var_value trace_log_vars.trace_var_value%TYPE);

  TYPE t_variables IS TABLE OF t_variable INDEX BY trace_log_vars.trace_var_name%TYPE;

  gv_traces    t_trace_objects;
  gv_method    t_method;
  gv_variables t_variables;

  gc_table  CONSTANT t_method := 'TABLE';
  gc_output CONSTANT t_method := 'OUTPUT';
  gc_pipe   CONSTANT t_method := 'PIPE';

  gc_procedure_start_msg_text CONSTANT trace_log.message%TYPE := 'Начало выполнения процедуры ';
  gc_function_start_msg_text  CONSTANT trace_log.message%TYPE := 'Начало выполнения функции ';
  gc_procedure_end_msg_text   CONSTANT trace_log.message%TYPE := 'Конец выполнения процедуры ';
  gc_function_end_msg_text    CONSTANT trace_log.message%TYPE := 'Конец выполнения функции ';
  gc_fucntion_result_var_name CONSTANT trace_log_vars.trace_var_name%TYPE := 'RESULT';

  FUNCTION trace_to_table RETURN t_method IS
  BEGIN
    RETURN gc_table;
  END trace_to_table;

  FUNCTION trace_to_output RETURN t_method IS
  BEGIN
    RETURN gc_output;
  END trace_to_output;

  FUNCTION trace_to_pipe RETURN t_method IS
  BEGIN
    RETURN gc_pipe;
  END trace_to_pipe;

  -- Байтин А.
  -- Получение состояния трассировки для переданного названия: true - включена, false - выключена
  FUNCTION is_enabled
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  ) RETURN BOOLEAN IS
    v_is_enabled BOOLEAN;
  BEGIN
    BEGIN
      -- Если есть подчиненный объект, смотрим значение элемента с его названием
      IF gv_traces(par_trace_obj_name).exists(nvl(par_trace_subobj_name, ''))
      THEN
        v_is_enabled := gv_traces(par_trace_obj_name) (nvl(par_trace_subobj_name, ''));
        -- Если есть объект с не указанным названием подчиненного объекта, тогда смотрим его
      ELSIF gv_traces(par_trace_obj_name).exists('')
      THEN
        v_is_enabled := TRUE;
      ELSE
        v_is_enabled := FALSE;
      END IF;
      -- В случае, когда элементов нет, считаем, что трассировка не включена
    EXCEPTION
      WHEN no_data_found THEN
        v_is_enabled := FALSE;
    END;
  
    RETURN v_is_enabled;
  END is_enabled;

  -- Байтин А.
  -- Установка метода вывода трассировочных данных
  PROCEDURE set_output_method(par_method t_method) IS
  BEGIN
    -- Проверка входного параметра
    assert_deprecated(par_method NOT IN (gc_table, gc_output, gc_pipe)
          ,'Метод трассировки "' || par_method || '" не поддерживается');
  
    gv_method := par_method;
  END set_output_method;

  -- Байтин А.
  -- Получение метода вывода трассировочных данных
  FUNCTION get_output_method RETURN t_method IS
  BEGIN
    IF gv_method IS NOT NULL
    THEN
      RETURN gv_method;
    ELSE
      raise_application_error(-20001
                             ,'Метод вывода трассировоных данных не установлен');
    END IF;
  END get_output_method;

  -- Байтин А.
  -- Включение трассировки
  PROCEDURE enable_trace
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_method            t_method
  ) IS
  BEGIN
    -- Проверки входных параметров
    assert_deprecated(par_trace_obj_name IS NULL
          ,'Название объекта должно быть заполнено!');
  
    gv_traces(par_trace_obj_name)(nvl(par_trace_subobj_name, '')) := TRUE;
    set_output_method(par_method => par_method);
  END enable_trace;

  -- Байтин А.
  -- Отключение трассировки
  PROCEDURE disable_trace
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  ) IS
  BEGIN
    -- Проверки входных параметров
    assert_deprecated(par_trace_obj_name IS NULL
          ,'Название объекта должно быть заполнено!');
  
    BEGIN
      IF par_trace_subobj_name IS NOT NULL
      THEN
        gv_traces(par_trace_obj_name).delete(par_trace_subobj_name);
      ELSE
        gv_traces.delete(par_trace_obj_name);
      END IF;
    EXCEPTION
      WHEN no_data_found THEN
        raise_application_error(-20001
                               ,'Невозможно выполнить отключение трассировки, трассировка не была включена');
    END;
  END disable_trace;

  -- Байтин А.
  -- Добавление переменной для логирования (NUMBER)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_value NUMBER
  ) IS
  BEGIN
    add_variable(par_trace_var_name  => par_trace_var_name
                ,par_trace_var_type  => 'NUMBER'
                ,par_trace_var_value => to_char(par_trace_var_value));
  END add_variable;

  -- Байтин А.
  -- Добавление переменной для логирования (DATE)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_value DATE
  ) IS
  BEGIN
    add_variable(par_trace_var_name  => par_trace_var_name
                ,par_trace_var_type  => 'DATE'
                ,par_trace_var_value => to_char(par_trace_var_value, 'dd.mm.yyyy'));
  END;

  -- Байтин А.
  -- Добавление переменной для логирования (BOOLEAN)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_value BOOLEAN
  ) IS
  BEGIN
    add_variable(par_trace_var_name  => par_trace_var_name
                ,par_trace_var_type  => 'BOOLEAN'
                ,par_trace_var_value => CASE
                                          WHEN par_trace_var_value THEN
                                           'TRUE'
                                          WHEN NOT par_trace_var_value THEN
                                           'FALSE'
                                        END);
  END;

  -- Байтин А.
  -- Добавление переменной для логирования (VARCHAR2)
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_value VARCHAR2
  ) IS
  BEGIN
    add_variable(par_trace_var_name  => par_trace_var_name
                ,par_trace_var_type  => 'VARCHAR2'
                ,par_trace_var_value => par_trace_var_value);
  END;

  -- Байтин А.
  -- Добавление переменной для логирования
  PROCEDURE add_variable
  (
    par_trace_var_name  trace_log_vars.trace_var_name%TYPE
   ,par_trace_var_type  trace_log_vars.trace_var_type%TYPE
   ,par_trace_var_value trace_log_vars.trace_var_value%TYPE
  ) IS
  BEGIN
    -- Проверки входных параметров
    assert_deprecated(par_trace_var_name IS NULL
          ,'Название переменной должно быть заполнено!');
  
    -- Если нет типа, предполагаем, что именно эта процедура вызвана,
    -- следовательно, тип VARCHAR2
    IF par_trace_var_type IS NULL
    THEN
      gv_variables(par_trace_var_name).var_type := 'VARCHAR2';
    ELSE
      gv_variables(par_trace_var_name).var_type := par_trace_var_type;
    END IF;
    gv_variables(par_trace_var_name).var_value := nvl(par_trace_var_value, 'NULL');
  END add_variable;

  -- Байтин А.
  -- Очистка коллекции с переменными
  PROCEDURE clear_variables IS
  BEGIN
    gv_variables.delete;
  END;

  -- Байтин А.
  -- Вставка отдельной записи в таблицу трассировки
  PROCEDURE insert_trace_log
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE
   ,par_message           trace_log.message%TYPE
   ,par_user              trace_log.user_name%TYPE
   ,par_action_time       trace_log.action_time%TYPE
   ,par_trace_log_id      OUT trace_log.trace_log_id%TYPE
  ) IS
  BEGIN
    -- Проверки входных параметров
    assert_deprecated(par_trace_obj_name IS NULL
          ,'Название объекта должно быть заполнено!');
  
    SELECT sq_trace_log.nextval INTO par_trace_log_id FROM dual;
  
    INSERT INTO trace_log
      (trace_log_id, trace_obj_name, trace_subobj_name, message, user_name, action_time, sid)
    VALUES
      (par_trace_log_id
      ,par_trace_obj_name
      ,par_trace_subobj_name
      ,par_message
      ,par_user
      ,par_action_time
      ,gv_sid);
  END insert_trace_log;

  -- Байтин А.
  -- Вставка отдельной записи в таблицу переменных трассировки
  PROCEDURE insert_trace_log_var
  (
    par_trace_log_id   trace_log.trace_log_id%TYPE
   ,par_variable_name  trace_log_vars.trace_var_name%TYPE
   ,par_variable_type  trace_log_vars.trace_var_type%TYPE
   ,par_variable_value trace_log_vars.trace_var_value%TYPE
  ) IS
  BEGIN
    INSERT INTO trace_log_vars
      (trace_log_id, trace_var_name, trace_var_type, trace_var_value)
    VALUES
      (par_trace_log_id, par_variable_name, par_variable_type, par_variable_value);
  END insert_trace_log_var;

  -- Байтин А.
  -- Вставка коллекции записей в таблицу переменных трассировки
  PROCEDURE insert_trace_log_vars
  (
    par_trace_log_id trace_log.trace_log_id%TYPE
   ,par_variables    t_variables
  ) IS
    v_key trace_log_vars.trace_var_name%TYPE;
  BEGIN
    IF par_variables.count > 0
    THEN
      v_key := par_variables.first;
      WHILE v_key IS NOT NULL
      LOOP
        insert_trace_log_var(par_trace_log_id   => par_trace_log_id
                            ,par_variable_name  => v_key
                            ,par_variable_type  => par_variables(v_key).var_type
                            ,par_variable_value => par_variables(v_key).var_value);
        v_key := par_variables.next(v_key);
      END LOOP;
    END IF;
  END insert_trace_log_vars;

  -- Байтин А.
  -- Очистка трассировочной таблицы
  PROCEDURE clear_trace_table
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  ) IS
  BEGIN
    -- Проверка входных параметров
    assert_deprecated(par_trace_obj_name IS NULL
          ,'Название объекта должно быть заполнено!');
  
    IF par_trace_subobj_name IS NULL
    THEN
      DELETE FROM trace_log tl WHERE tl.trace_obj_name = par_trace_obj_name;
    ELSE
      DELETE FROM trace_log tl
       WHERE tl.trace_obj_name = par_trace_obj_name
         AND tl.trace_subobj_name = par_trace_subobj_name;
    END IF;
  END clear_trace_table;

  -- Байтин А.
  -- Вывод трассировочных данных в таблицу
  PROCEDURE trace_to_table
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_message           trace_log.message%TYPE
   ,par_variables         t_variables
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_trace_log_id trace_log.trace_log_id%TYPE;
  BEGIN
    insert_trace_log(par_trace_obj_name    => par_trace_obj_name
                    ,par_trace_subobj_name => par_trace_subobj_name
                    ,par_message           => par_message
                    ,par_user              => USER
                    ,par_action_time       => systimestamp
                    ,par_trace_log_id      => v_trace_log_id);
    insert_trace_log_vars(v_trace_log_id, par_variables);
    COMMIT;
  END trace_to_table;

  -- Байтин А.
  -- Вывод трассировочных данных в DBMS_OUTPUT
  PROCEDURE trace_to_output
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_message           trace_log.message%TYPE
   ,par_variables         t_variables
  ) IS
    v_key      trace_log_vars.trace_var_name%TYPE;
    v_message  trace_log.message%TYPE;
    v_variable trace_log_vars.trace_var_value%TYPE;
  BEGIN
    -- Формирование и вывод названия объекта, где происходит трассировка
    IF par_trace_subobj_name IS NULL
    THEN
      v_message := '<' || par_trace_obj_name || '>';
    ELSE
      v_message := '<' || par_trace_obj_name || '.' || par_trace_subobj_name || '>';
    END IF;
    v_message := v_message || ': "' || nvl(par_message, 'NULL') || '"';
    dbms_output.put_line(v_message);
  
    -- Если указаны переменные, формируем и выводим их список
    IF par_variables.count > 0
    THEN
      dbms_output.put_line('  <Переменные:начало>');
      v_key := par_variables.first;
      WHILE v_key IS NOT NULL
      LOOP
        v_variable := v_key || '= "' || par_variables(v_key).var_value || '"; (' || par_variables(v_key)
                     .var_type || ')';
        v_variable := lpad(v_variable, length(v_variable) + 4, ' ');
        dbms_output.put_line(v_variable);
        v_key := par_variables.next(v_key);
      END LOOP;
      dbms_output.put_line('  <Переменные:окончание>' || chr(10));
    END IF;
  END trace_to_output;

  -- Байтин А.
  -- Вывод трассировочных данных в PIPE, еще не реализован
  PROCEDURE trace_to_pipe
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE
   ,par_message           trace_log.message%TYPE
   ,par_variables         t_variables
  ) IS
  BEGIN
    raise_application_error(-20001, 'trace_to_pipe не поддерживается');
  END trace_to_pipe;

  -- Байтин А.
  -- Выполнение трассировки
  PROCEDURE trace
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_message           trace_log.message%TYPE
  ) IS
    v_output_method pkg_trace.t_method;
  BEGIN
    -- Если трассировка включена, смотрим куда выводить результат
    IF is_enabled(par_trace_obj_name    => par_trace_obj_name
                 ,par_trace_subobj_name => par_trace_subobj_name)
    THEN
      v_output_method := get_output_method;
      CASE v_output_method
        WHEN pkg_trace.gc_table THEN
          -- В таблицу
          trace_to_table(par_trace_obj_name    => par_trace_obj_name
                        ,par_trace_subobj_name => par_trace_subobj_name
                        ,par_message           => par_message
                        ,par_variables         => gv_variables);
        WHEN pkg_trace.gc_output THEN
          -- В DBMS_OUTPUT
          trace_to_output(par_trace_obj_name    => par_trace_obj_name
                         ,par_trace_subobj_name => par_trace_subobj_name
                         ,par_message           => par_message
                         ,par_variables         => gv_variables);
        WHEN pkg_trace.gc_pipe THEN
          -- В pipe
          trace_to_pipe(par_trace_obj_name    => par_trace_obj_name
                       ,par_trace_subobj_name => par_trace_subobj_name
                       ,par_message           => par_message
                       ,par_variables         => gv_variables);
          NULL;
        ELSE
          raise_application_error(-20001
                                 ,'Метод вывода трассировочных данных "' ||
                                  nvl(v_output_method, 'NULL') || '" не поддерживается');
      END CASE;
    
    END IF;
    clear_variables;
  EXCEPTION
    WHEN OTHERS THEN
      clear_variables;
      RAISE;
  END trace;

  PROCEDURE trace_fnc_prc_start_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_general_msg       trace_log.message%TYPE
  ) IS
    v_msg trace_log.message%TYPE;
  BEGIN
  
    IF par_trace_subobj_name IS NULL
    THEN
      v_msg := par_general_msg || par_trace_subobj_name;
    ELSE
      v_msg := par_general_msg || par_trace_obj_name;
    END IF;
  
    trace(par_trace_obj_name    => par_trace_obj_name
         ,par_trace_subobj_name => par_trace_subobj_name
         ,par_message           => v_msg);
  END;

  PROCEDURE trace_procedure_start
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  ) IS
  BEGIN
    trace_fnc_prc_start_end(par_trace_obj_name    => par_trace_obj_name
                           ,par_trace_subobj_name => par_trace_subobj_name
                           ,par_general_msg       => gc_procedure_start_msg_text);
  END trace_procedure_start;

  PROCEDURE trace_function_start
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  ) IS
  BEGIN
    trace_fnc_prc_start_end(par_trace_obj_name    => par_trace_obj_name
                           ,par_trace_subobj_name => par_trace_subobj_name
                           ,par_general_msg       => gc_function_start_msg_text);
  END trace_function_start;

  PROCEDURE trace_procedure_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  ) IS
  BEGIN
    trace_fnc_prc_start_end(par_trace_obj_name    => par_trace_obj_name
                           ,par_trace_subobj_name => par_trace_subobj_name
                           ,par_general_msg       => gc_procedure_end_msg_text);
  END trace_procedure_end;

  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
  ) IS
  BEGIN
    trace_fnc_prc_start_end(par_trace_obj_name    => par_trace_obj_name
                           ,par_trace_subobj_name => par_trace_subobj_name
                           ,par_general_msg       => gc_function_end_msg_text);
  END trace_function_end;

  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_result_value      NUMBER
  ) IS
  BEGIN
    add_variable(par_trace_var_name  => gc_fucntion_result_var_name
                ,par_trace_var_value => par_result_value);
  
    trace_function_end(par_trace_obj_name    => par_trace_obj_name
                      ,par_trace_subobj_name => par_trace_subobj_name);
  END trace_function_end;

  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_result_value      VARCHAR2
  ) IS
  BEGIN
    add_variable(par_trace_var_name  => gc_fucntion_result_var_name
                ,par_trace_var_value => par_result_value);
  
    trace_function_end(par_trace_obj_name    => par_trace_obj_name
                      ,par_trace_subobj_name => par_trace_subobj_name);
  END trace_function_end;

  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_result_value      DATE
  ) IS
  BEGIN
    add_variable(par_trace_var_name  => gc_fucntion_result_var_name
                ,par_trace_var_value => par_result_value);
  
    trace_function_end(par_trace_obj_name    => par_trace_obj_name
                      ,par_trace_subobj_name => par_trace_subobj_name);
  END trace_function_end;
	
  PROCEDURE trace_function_end
  (
    par_trace_obj_name    trace_log.trace_obj_name%TYPE
   ,par_trace_subobj_name trace_log.trace_subobj_name%TYPE DEFAULT NULL
   ,par_result_value      BOOLEAN
  ) IS
  BEGIN
    add_variable(par_trace_var_name  => gc_fucntion_result_var_name
                ,par_trace_var_value => par_result_value);
  
    trace_function_end(par_trace_obj_name    => par_trace_obj_name
                      ,par_trace_subobj_name => par_trace_subobj_name);
  END trace_function_end;	

BEGIN
  gv_sid := userenv('sessionid');
END pkg_trace; 
/
