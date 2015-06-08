CREATE OR REPLACE PACKAGE pkg_gate_jdbc IS

  -- Author  : DENIS.IVANOV
  -- Created : 06.05.2010 18:15:15
  -- Purpose : Пакет содержит процедуры по интеграции с внешними системами 

  PROCEDURE Set_connect(p_conn_name VARCHAR2);
  /**
  * Передача данных по агентскому договору в шлюз системы b2b
  */
  FUNCTION get_last_stmnt RETURN VARCHAR2;

  PROCEDURE agent_into_b2b
  (
    agent_id      VARCHAR2
   ,company_id    NUMBER
   ,tac_id        NUMBER
   ,first_name    VARCHAR2
   ,last_name     VARCHAR2
   ,middle_name   VARCHAR2
   ,city          VARCHAR2
   ,contract_date DATE
   ,birth_date    DATE
   ,operation     NUMBER
  );
END pkg_gate_jdbc;
/
CREATE OR REPLACE PACKAGE BODY pkg_gate_jdbc IS

  g_conn_name  VARCHAR2(255) := 'NPF_MYSQL';
  g_oper_stmnt VARCHAR2(2000);
  -- Author  : ALEXEY.KATKEVICH
  -- Created : 13.07.2010 16:42:44
  -- Purpose : Устанавливает строку коннекта
  PROCEDURE Set_connect(p_conn_name VARCHAR2) IS
    proc_name VARCHAR2(25) := 'Set_connect';
  BEGIN
  
    SELECT jc.data_source_name
      INTO g_conn_name
      FROM orajdbclink_o2a.jdbc_dblink jc
     WHERE jc.data_source_name = p_conn_name;
  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20002
                             ,'Не найдено подключение с именем ' || p_conn_name);
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END Set_connect;

  -- Author  : ALEXEY.KATKEVICH
  -- Created : 20.07.2010 13:21:38
  -- Purpose : Возвращает текст последнего выполненного запроса
  FUNCTION get_last_stmnt RETURN VARCHAR2 IS
    -- Result varchar2;
    proc_name VARCHAR2(25) := 'get_last_stmnt';
  BEGIN
  
    RETURN(g_oper_stmnt);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001
                             ,'Ошибка при выполнении ' || proc_name || SQLERRM);
  END get_last_stmnt;

  /**
  * Передача данных по агентскому договору в шлюз системы b2b
  */
  PROCEDURE agent_into_b2b
  (
    agent_id      VARCHAR2
   ,company_id    NUMBER
   ,tac_id        NUMBER
   ,first_name    VARCHAR2
   ,last_name     VARCHAR2
   ,middle_name   VARCHAR2
   ,city          VARCHAR2
   ,contract_date DATE
   ,birth_date    DATE
   ,operation     NUMBER
  ) IS
    v_stmt          VARCHAR2(400);
    v_select        VARCHAR2(400) := 'select error from n_dir_agents_gateway where agent_id = ''' ||
                                     agent_id || '''';
    v_call          orajdbclink_o2a.jcall;
    v_cursor        orajdbclink_o2a.jcursor;
    v_error         VARCHAR2(400);
    v_orcl_charset  V$NLS_PARAMETERS.VALUE%TYPE;
    v_mysql_charset VARCHAR2(4) := 'utf8'; -- todo: динамически определить можно
    v_conn_name     VARCHAR2(255) := g_conn_name; --'NPF_MYSQL';
  
  BEGIN
    SELECT VALUE INTO v_orcl_charset FROM V$NLS_PARAMETERS WHERE parameter = 'NLS_CHARACTERSET';
  
    IF (operation = 1)
    THEN
      -- вставка
      v_stmt := 'insert into n_dir_agents_gateway (agent_id, company_id, tac_id, ' ||
                'first_name,last_name,middle_name,city,contract_date,birth_date,operation) values (' || '''' ||
                agent_id || ''', ' || company_id || ', ' || tac_id || ', ' || '''' || first_name ||
                ''', ' || '''' || last_name || ''', ' || '''' || middle_name || ''', ' || '''' || city ||
                ''', ''' || to_char(contract_date, 'yyyy-MM-dd') || ''',''' ||
                to_char(birth_date, 'yyyy-MM-dd') || ''', ' || operation || ')';
    ELSIF (operation = 0)
    THEN
      -- отключение
      v_stmt := 'update n_dir_agents_gateway set operation = 0 where agent_id = ' || '''' || agent_id || '''';
    ELSIF (operation = 2)
    THEN
      -- обновление
      v_stmt := 'update n_dir_agents_gateway set company_id = ' || company_id || ', tac_id = ' ||
                tac_id || ', first_name = ' || '''' || first_name || ''', last_name = ' || '''' ||
                last_name || ''', middle_name = ' || '''' || middle_name || ''', city = ' || '''' || city ||
                ''', contract_date = ''' || to_char(contract_date, 'yyyy-MM-dd') ||
                ''', birth_date = ''' || to_char(birth_date, 'yyyy-MM-dd') || ''', operation = ' || 1 ||
                ' where agent_id = ''' || agent_id || '''';
    ELSE
      RAISE_APPLICATION_ERROR(-20001, 'неизвестная операция шлюза');
    END IF;
  
    g_oper_stmnt := v_stmt;
  
    -- выполнение DML запроса
    v_call := orajdbclink_o2a.jcall(v_stmt, v_conn_name);
    v_call.init;
    v_call.executecall;
  
    -- провека успешности действия
    --dbms_output.put_line(v_select);
    v_cursor := orajdbclink_o2a.jcursor(v_select, v_conn_name, 1);
    v_cursor.init;
    v_cursor.open;
  
    WHILE v_cursor.dofetch = 1
    LOOP
      --  dbms_output.put_line(v_cursor.get_string(1));
      v_error := convert(v_cursor.get_string(1), v_orcl_charset, v_mysql_charset);
    END LOOP;
  
    v_cursor.close;
  
    IF (v_error IS NOT NULL)
    THEN
      -- ошибки при передаче данных
      RAISE_APPLICATION_ERROR(-20002, 'Сообщение b2b:' || v_error);
    ELSE
      -- ок, закрываем соединение, коммит.
      v_call.CLOSE;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      v_call.rollback;
      v_call.CLOSE;
      RAISE_APPLICATION_ERROR(-20003
                             ,'Ошибка при передаче данных в b2b. ' || ' agent_id = ' || agent_id || ' ' ||
                              SQLERRM);
    
  END;

BEGIN
  NULL;
END pkg_gate_jdbc;
/
