CREATE OR REPLACE PACKAGE pkg_mail IS

  -- Author  : RKUDRYAVCEV
  -- Created : 23.03.2006 16:22:40
  -- Purpose : Управляющая процедура

  -- сообщение по е-маил ... будет массивом
  TYPE T_vc2000 IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  --------------------------------------------------------------------------------------
  --
  -- Получить подстроку из строки par_line с номером подстроки par_param
  -- и разделителем подстрок par_separator
  --
  --------------------------------------------------------------------------------------
  FUNCTION get_substring
  (
    par_line      VARCHAR2
   , -- строка
    par_param     NUMBER
   , -- номер возвращаемой подстроки
    par_separator VARCHAR2 DEFAULT '#' -- разделитель подстрок
  ) RETURN VARCHAR2;
  ---------------------------------------------------------------------------
  --
  -- Процесс рассылки сообщений по е-маил
  -- 1. формирует рассылку по группам
  -- 2. отправляет результаты работы шлюза по e-mail
  --
  -- Параметры:
  -- стандартные параметры для запускаемых процедур из процессов

  --
  ---------------------------------------------------------------------------

  FUNCTION generation_mail(par_gate_obj_type_id NUMBER) RETURN NUMBER;

  --------------------------------------------------------------------------
  --
  -- Процесс рассылки сообщений по е-маил
  -- отправляет результаты работы шлюза по e-mail
  --
  ---------------------------------------------------------------------------

  PROCEDURE send_mail
  (
    par_recipient VARCHAR2
   ,par_sender    VARCHAR2
   ,par_message   t_vc2000
   ,par_subject   VARCHAR2 DEFAULT NULL
  );
  --
END pkg_mail;
/
CREATE OR REPLACE PACKAGE BODY pkg_mail IS
  --------------------------------------------------------------------------------------
  --
  -- Получить подстроку из строки par_line с номером подстроки par_param
  -- и разделителем подстрок par_separator
  --
  --------------------------------------------------------------------------------------
  FUNCTION get_substring
  (
    par_line      VARCHAR2
   , -- строка
    par_param     NUMBER
   , -- номер возвращаемой подстроки
    par_separator VARCHAR2 DEFAULT '#' -- разделитель подстрок
  ) RETURN VARCHAR2 IS
    i NUMBER := 0;
    s VARCHAR2(255);
  BEGIN
    FOR c1 IN 1 .. par_param - 1
    LOOP
      i := instr(par_line, par_separator, i + 1);
      IF i = 0
      THEN
        s := NULL;
        RETURN s;
      END IF;
    END LOOP;
    SELECT substr(par_line
                 ,i + 1
                 ,decode(instr(par_line, par_separator, i + 1)
                        ,0
                        ,length(par_line)
                        ,instr(par_line, par_separator, i + 1) - i - 1))
      INTO s
      FROM dual;
    RETURN s;
  END get_substring;
  ---------------------------------------------------------------------------
  --
  -- Процесс формирования сообщений для рассылки сообщений по е-маил
  --
  -- Параметры:
  -- стандартные параметры для запускаемых процедур из процессов

  --
  ---------------------------------------------------------------------------

  FUNCTION generation_mail(par_gate_obj_type_id NUMBER) RETURN NUMBER IS
  
    var_recipient VARCHAR2(255); -- информация о получателе
    var_sender    VARCHAR2(255); -- информация о отправителе
    var_message   T_vc2000; -- текст ошибки
    var_count     NUMBER := 0;
    --var_temp      XX_GATE.message_operation.group_mail%type;
    var_temp      VARCHAR2(255);
    var_count_err NUMBER := 0;
    var_note      VARCHAR2(255);
  BEGIN
    -- данный процесс будет отправлять сообщения пользователям
    -- сообщения будут анализироваться за текущий сеанс.
    -- в случае ошибки в данном процессе - ни чего отсылаться не будет
    -- и ни кто не узнает об этом, разьве что Админ :-)
    -- можно сделать дополнительные процессы проверки.
  
    -- сообщим о себе
    var_temp := pkg_gate.InserEvent('Начат процесс формирования сообщений отправляемых по электронной почте'
                                   ,0
                                   ,2000);
  
    UPDATE gate_event SET back_send = 1 WHERE back_send IS NULL;
  
    -- var_message := '[результат работы процессов с номером сеанса: '||pvar_gate_seance_id||'  и датой запуска: '||to_char(pvar_seance_date,'dd.mm.yyyy hh24:mi:ss')||' ]';
    -- мы должны сгрупировать сообщения по
    --1. группам процессов
    --2. пакетам
    -- отравляются только сообщения с более высоким приоритетом
    -- отправляются по указанным пользователям.
    FOR r IN (SELECT MAX(mo.priority_group) priority_group
                    ,mo.gate_obj_type_id
                    ,NVL(ge.gate_package_id, 0) gate_package_id
                FROM gate_event        ge
                    ,message_operation mo
               WHERE ge.gate_event_type_id = mo.gate_event_type_id
                 AND ge.gate_obj_type_id = mo.gate_obj_type_id
                 AND ge.back_send = 1
               GROUP BY mo.gate_obj_type_id
                       ,NVL(ge.gate_package_id, 0))
    LOOP
      -- заполним вспомогательную таблицу
      -- поместим в нее только те сообщения которые надо рассылать
      INSERT INTO INSI.generation_mail
        (group_mail
        ,GATE_OBJ_TYPE_ID
        ,GATE_PACKAGE_ID
        ,GATE_EVENT_TYPE_ID
        ,MESSAGE_EVENT
        ,GATE_EVENT_ID
        ,ACTION
        ,MESSAGE_DATE)
        SELECT mo.group_mail
              ,ge.gate_obj_type_id
              ,ge.gate_package_id
              ,ge.gate_event_type_id
              ,ge.message_event
              ,ge.gate_event_id
              ,mo.action
              ,ge.message_date
          FROM gate_event        ge
              ,message_operation mo
         WHERE ge.gate_event_type_id = mo.gate_event_type_id
           AND ge.gate_obj_type_id = mo.gate_obj_type_id
           AND ge.back_send = 1
           AND ge.gate_obj_type_id = r.gate_obj_type_id
           AND NVL(ge.gate_package_id, 0) = r.gate_package_id
           AND mo.priority_group = r.priority_group
           AND mo.group_mail IS NOT NULL;
    
    END LOOP;
    -- почта может быть указана через #, тогда ее необходимо разделять
    --
    FOR t IN (SELECT ROWID rwd
                    ,g.*
                FROM INSI.generation_mail g)
    LOOP
      -- если в группе рассылки встретиться символ # то необходимо
      -- такие строки разделять.
      var_temp := t.group_mail;
    
      WHILE 1 = 1
      LOOP
        IF instr(var_temp, '#') <> 0
        THEN
        
          INSERT INTO INSI.generation_mail
            (group_mail
            ,GATE_OBJ_TYPE_ID
            ,GATE_PACKAGE_ID
            ,GATE_EVENT_TYPE_ID
            ,MESSAGE_EVENT
            ,GATE_EVENT_ID
            ,ACTION
            ,MESSAGE_DATE)
          VALUES
            (get_substring(var_temp, 1, '#')
            ,t.GATE_OBJ_TYPE_ID
            ,t.GATE_PACKAGE_ID
            ,t.GATE_EVENT_TYPE_ID
            ,t.MESSAGE_EVENT
            ,t.GATE_EVENT_ID
            ,t.ACTION
            ,t.MESSAGE_DATE);
          var_temp := substr(var_temp
                            ,instr(var_temp, '#') + 1
                            ,length(var_temp) - instr(var_temp, '#'));
        
        ELSE
          -- прекратим цикл
        
          INSERT INTO INSI.generation_mail
            (group_mail
            ,GATE_OBJ_TYPE_ID
            ,GATE_PACKAGE_ID
            ,GATE_EVENT_TYPE_ID
            ,MESSAGE_EVENT
            ,GATE_EVENT_ID
            ,ACTION
            ,MESSAGE_DATE)
          VALUES
            (get_substring(var_temp, 1, '#')
            ,t.GATE_OBJ_TYPE_ID
            ,t.GATE_PACKAGE_ID
            ,t.GATE_EVENT_TYPE_ID
            ,t.MESSAGE_EVENT
            ,t.GATE_EVENT_ID
            ,t.ACTION
            ,t.MESSAGE_DATE);
        
          EXIT;
        
        END IF;
      
      END LOOP;
    
      DELETE FROM INSI.generation_mail WHERE ROWID = t.rwd;
    
    END LOOP;
  
    -- теперь мы можем манипулировать данными
    --
    -- пройдемся по получателям почты
    FOR i IN (SELECT gm.group_mail FROM generation_mail gm GROUP BY gm.group_mail)
    LOOP
      -- пройдемся по процессам и пакетам
      var_message.delete;
      var_count_err := 0;
      var_note      := NULL;
      var_count     := 1;
    
      var_message(var_count) := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE> New Document </TITLE>
<META NAME="Generator" CONTENT="">
<META NAME="Author" CONTENT="">
<META NAME="Keywords" CONTENT="">
<META NAME="Description" CONTENT="">
</HEAD>

<BODY>' || ' <H5> ' ||
                                '[результат работы процесса ОТПРАВКА_СООБЩЕНИЙ от: ' ||
                                to_char(SYSDATE, 'DD.MM.YYYY HH24:MI:SS') || ' ]' || '</H5> <BR> ';
    
      -----------------------------
      -- резервируем 2-ую строку для подсчета
      -----------------------------
      var_count := var_count + 2;
      var_message(var_count) := '<TABLE border="1" cellspacing="0" cellpadding="0" bgcolor="#F7F7F7">
<TR bgcolor="#C0C0C0">
	<TD width="20%" class="nrw">Процесс</TD>
	<TD width="10%" class="nrw">Тип сообщения</TD>
	<TD width="60%" class="nrw">Текст сообщения</TD>
  <TD width="5%" class="nrw">Время сообщения</TD>
</TR>';
      FOR r IN (SELECT gm.group_mail
                      ,ot.descr p_descr
                      ,gm.gate_package_id
                      ,gm.message_event
                      ,et.descr e_descr
                      ,decode(gm.action, 'О', 'bgcolor = "#FF8080"', NULL) color
                      ,gm.message_date
                      ,gm.action
                  FROM INSI.generation_mail gm
                      ,INSI.Gate_Event_Type et
                      ,gate_obj_type        ot
                 WHERE gm.group_mail = i.group_mail
                   AND ot.gate_obj_type_id = gm.gate_obj_type_id
                   AND et.gate_event_type_id = gm.gate_event_type_id
                 ORDER BY gm.gate_obj_type_id
                         ,gm.gate_package_id
                         ,gm.message_date
                         ,gm.gate_event_id)
      LOOP
        var_count := var_count + 1;
        IF r.action = 'О'
        THEN
          var_count_err := var_count_err + 1;
        END IF;
        var_message(var_count) := ' <TR ' || r.color || '>
	<TD class="nrw" >' || r.p_descr || '</TD>
	<TD class="nrw" >' || r.e_descr || '</TD>
	<TD class="nrw" >' || r.message_event || '</TD>
  <TD class="nrw" >' ||
                                  to_char(r.message_date, 'DD.MM.YYYY HH24:MI:SS') || '</TD>
</TR>';
      
      END LOOP;
      var_count := var_count + 1;
      var_message(var_count) := ' </TABLE> </BODY> </HTML>';
      -- произведем отправку по е-маил
      var_note := '[Результат работы подсистемы интеграции';
      IF var_count_err > 0
      THEN
        var_note := var_note || '. Произошло остановок процессов: ' || var_count_err || ']';
        var_message(2) := ' <H5> <FONT COLOR="#FF0000">' ||
                          ' Произошли остановки процессов (см. далее)' || '</FONT> </H5> <BR> ';
      ELSE
      
        var_note := var_note || ']';
        var_message(2) := '<BR>';
      END IF;
    
      BEGIN
        send_mail(i.group_mail
                 ,ins.pkg_app_param.get_app_param_c('GATE: E-MAIL ADMIN')
                 ,var_message
                 ,var_note);
      EXCEPTION
        WHEN OTHERS THEN
          -- выйдем из цикла
          var_temp := pkg_gate.InserEvent('Во время отправки сообщений по е-маил произошла ошибка. Формирование прервано'
                                         ,2
                                         ,2000);
        
        --  exit;
      
      END;
    END LOOP;
    -- удалим данные из вспомогательной таблицы
    DELETE FROM generation_mail;
    UPDATE gate_event ge SET ge.back_send = 2 WHERE ge.back_send = 1;
  
    var_temp := pkg_gate.InserEvent('Успешно завершен процесс формирования сообщений отправляемых по электронной почте'
                                   ,0
                                   ,2000);
    RETURN Utils_tmp.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      -- процудура отработала криво, а это значит что не отправилось письмо.
      -- в этом случае оповестить мы ни как не можем.
      -- Пользователь должен сам понять что что -то не так, так как не пришло письмо
      var_temp := pkg_gate.InserEvent('Ошибка при формировании отправляемого текста по электронной почте: ' ||
                                      SQLERRM(SQLCODE)
                                     ,1
                                     ,2000);
    
      RETURN Utils_tmp.c_false;
  END generation_mail;

  ---------------------------------------------------------------------------
  --
  -- Процесс рассылки сообщений по е-маил
  -- отправляет результаты работы шлюза по e-mail
  --
  ---------------------------------------------------------------------------

  PROCEDURE send_mail
  (
    par_recipient VARCHAR2
   ,par_sender    VARCHAR2
   ,par_message   T_vc2000
   ,par_subject   VARCHAR2 DEFAULT NULL
  ) IS
    var_MAIL_CONN utl_smtp.connection; -- коннект
    var_mail_host VARCHAR2(32); -- Хост почтового сервера
    var_mail_port NUMBER; -- порт почтового сервера
    var_temp      VARCHAR2(255);
  BEGIN
  
    -- получим данные из переменных окружения
    -- IP адрес почтового сервера (или его имя, но сейчас mail.borlas.ru не работает, приходится по IP)
    var_mail_host := ins.pkg_app_param.get_app_param_c('GATE: E-MAIL HOST');
    -- получим порт
    var_mail_port := ins.pkg_app_param.get_app_param_c('GATE: E-MAIL PORT');
    -- получим коннект
    var_mail_conn := utl_smtp.open_connection(var_mail_host, var_mail_port);
    UTL_SMTP.HELO(var_mail_conn, var_mail_host); -- connection to mail host
  
    UTL_SMTP.MAIL(var_mail_conn, par_sender); -- who sends the email
    --
    UTL_SMTP.RCPT(var_mail_conn, par_recipient); -- who recieves the email
    --
    UTL_SMTP.OPEN_DATA(var_mail_conn);
  
    utl_smtp.write_data(var_mail_conn, 'From' || ': ' || par_sender || utl_tcp.CRLF);
    utl_smtp.write_data(var_mail_conn, 'To' || ': ' || par_Recipient || utl_tcp.CRLF);
    /*  utl_smtp.write_data(var_mail_conn,
    'Date' || ': ' ||
    to_char(sysdate,
            'DD MON YY HH24:MI:SS') || ' +0300' ||
    utl_tcp.CRLF);*/
  
    -- сформируем тему письма
    utl_smtp.write_raw_data(var_mail_conn
                           ,utl_raw.cast_to_raw('Subject: ' || CONVERT(par_subject, 'CL8KOI8R') ||
                                                utl_tcp.CRLF));
  
    -- здесь идут настройки , чтобы письма приходили на Нормальном русском языке
    utl_smtp.write_data(var_mail_conn, 'MIME-Version: 1.0' || CHR(13) || CHR(10));
    utl_smtp.write_data(var_mail_conn
                       ,'Content-Type' || ': ' || 'text/html;charset=KOI8-R' || utl_tcp.CRLF);
    utl_smtp.write_data(var_mail_conn, 'Content-Transfer-Encoding: 8bit' || CHR(13) || CHR(10));
  
    -- сформируем заголовок письма ,где укажем время запуска, номер сеанса и т.д.
    -- и текст письма
    utl_smtp.write_raw_data(var_mail_conn, utl_raw.cast_to_raw(utl_tcp.CRLF));
    FOR C_MESS IN 1 .. par_message.count
    LOOP
    
      utl_smtp.write_raw_data(var_mail_conn
                             ,utl_raw.cast_to_raw(CONVERT(par_message(C_MESS), 'CL8KOI8R')));
    END LOOP;
  
    UTL_SMTP.CLOSE_DATA(var_mail_conn);
    --
    UTL_SMTP.QUIT(var_mail_conn);
  
    var_temp := pkg_gate.InserEvent('Успешно завершен процесс отправки сообщений по электронной почте для:' ||
                                    par_recipient
                                   ,0
                                   ,2000);
  
  EXCEPTION
    WHEN OTHERS THEN
      -- процудура отработала криво, а это значит что не отправилось письмо.
      -- в этом случае оповестить мы ни как не можем.
      -- Пользователь должен сам понять что что -то не так, так как не пришло письмо
      var_temp := pkg_gate.InserEvent('Оправка сообщений по электронной почте вызвала ошибку: ' ||
                                      SQLERRM(SQLCODE)
                                     ,1
                                     ,2000);
    
  END send_mail;

--
END pkg_mail;
/
