CREATE OR REPLACE PACKAGE pkg_email IS
  TYPE t_file IS RECORD(
     v_file_name VARCHAR2(255)
    ,v_file_type VARCHAR2(100) -- MIME
    ,v_file      BLOB);

  TYPE t_files IS TABLE OF t_file;

  TYPE t_recipients IS TABLE OF VARCHAR2(50);

  TYPE rec_email_message IS RECORD(
     recipients t_recipients
    ,text       VARCHAR2(2000)
    ,subject    VARCHAR2(255)
    ,attachment t_files);
  TYPE t_email_message IS TABLE OF rec_email_message;
  -- Author  : VLADIMIR.CHIRKOV
  -- Created : 18.08.2011 11:01:39
  -- Purpose : �������� ����������� �����

  PROCEDURE add_email
  (
    p_send_to       VARCHAR2
   ,p_email_subject VARCHAR2
   ,p_email_data    VARCHAR2
   ,p_send_from     VARCHAR2 := 'oracle@renlife.com'
   ,p_date_to_send  DATE := SYSDATE
  );

  PROCEDURE add_email_by_role
  (
    p_role          VARCHAR2
   ,p_email_subject VARCHAR2
   ,p_email_data    VARCHAR2
   ,p_send_from     VARCHAR2 := 'oracle@renlife.com'
   ,p_type_address  VARCHAR2 := '����� ��������'
  );

  FUNCTION sp_send_email
  (
    p_to      IN VARCHAR2
   ,p_subject IN VARCHAR2
   ,p_data    IN VARCHAR2
   ,p_from    IN VARCHAR2 := 'oracle@renlife.com'
   ,p_host    IN VARCHAR2 := 'mail.renlife.com'
  ) RETURN INT;
  /*
    ������ �.
    �������� ����� � ����������
  */
  PROCEDURE send_mail_with_attachment
  (
    par_to            t_recipients
   ,par_cc            t_recipients DEFAULT NULL
   ,par_subject       VARCHAR2
   ,par_text          VARCHAR2
   ,par_attachment    t_files DEFAULT NULL
   ,par_from          VARCHAR2 DEFAULT 'oracle@renlife.com'
   ,par_login         VARCHAR2 DEFAULT 'oracle'
   ,par_host          VARCHAR2 DEFAULT 'mail.renlife.com'
   ,par_ignore_errors BOOLEAN DEFAULT FALSE
  );

END pkg_email;
/
CREATE OR REPLACE PACKAGE BODY pkg_email IS

  gc_key_string CONSTANT VARCHAR2(15) := 'MagicKey555';
  --���������� ������ �� �������� ��������� ������������
  PROCEDURE add_email
  (
    p_send_to       VARCHAR2
   ,p_email_subject VARCHAR2
   ,p_email_data    VARCHAR2
   ,p_send_from     VARCHAR2 := 'oracle@renlife.com'
   ,p_date_to_send  DATE := SYSDATE
  ) IS
    v_obj_id NUMBER;
  
  BEGIN
    SELECT sq_send_email.nextval INTO v_obj_id FROM dual;
  
    INSERT INTO send_email
      (send_email_id, send_to, send_from, email_subject, email_data, date_to_send)
    VALUES
      (v_obj_id, p_send_to, p_send_from, p_email_subject, p_email_data, p_date_to_send);
    COMMIT;
  END;

  --���������� ��������� ������������� ����
  PROCEDURE add_email_by_role
  (
    p_role          VARCHAR2
   ,p_email_subject VARCHAR2
   ,p_email_data    VARCHAR2
   ,p_send_from     VARCHAR2 := 'oracle@renlife.com'
   ,p_type_address  VARCHAR2 := '����� ��������'
  ) IS
    CURSOR c_email_address
    (
      c_role         VARCHAR2
     ,c_type_address VARCHAR2
    ) IS
      SELECT c.name
            ,v_mail.email
        FROM ven_sys_user    u
            ,v_rel_role_user vru
             --,employee emp --/������/ 293957: ����� ����������� contact ������ ����� sys_user
             --, � �� ����� employee
            ,contact c
            ,ven_cn_contact_email v_mail
            ,(SELECT * FROM ven_t_email_type WHERE description = c_type_address) v_mail_t
       WHERE vru.userid = u.sys_user_id
            --and emp.employee_id = u.employee_id --293957
            --and c.contact_id = emp.contact_id   --293957
         AND c.contact_id = u.contact_id --293957
         AND v_mail.contact_id = c.contact_id
         AND v_mail.email_type = v_mail_t.id(+)
         AND vru.rolename = c_role
         AND vru.assigned = 1;
  BEGIN
    FOR rec IN c_email_address(p_role, p_type_address)
    LOOP
      add_email(rec.email, p_email_subject, p_email_data, p_send_from);
    END LOOP;
  END;

  --��������� �������� ���������
  FUNCTION sp_send_email
  (
    p_to      IN VARCHAR2
   ,p_subject IN VARCHAR2
   ,p_data    IN VARCHAR2
   ,p_from    IN VARCHAR2 := 'oracle@renlife.com'
   ,p_host    IN VARCHAR2 := 'mail.renlife.com'
  ) RETURN INT IS
    v_connection utl_smtp.connection;
    v_from       VARCHAR2(64);
    v_orahost    VARCHAR2(64);
  
  BEGIN
  
    SELECT host_name INTO v_orahost FROM v$instance;
    v_from := 'From: "' || sys_context('USERENV', 'DB_NAME') || '.' ||
              sys_context('USERENV', 'DB_DOMAIN') || ' (ORACLE on ' || v_orahost || ')"';
  
    v_connection := utl_smtp.open_connection(p_host);
    utl_smtp.helo(v_connection, p_host);
    utl_smtp.mail(v_connection, p_from);
    utl_smtp.rcpt(v_connection, p_to);
    utl_smtp.open_data(v_connection);
  
    utl_smtp.write_data(v_connection, v_from || utl_tcp.crlf);
    utl_smtp.write_data(v_connection, 'To: ' || p_to || utl_tcp.crlf);
    utl_smtp.write_data(v_connection, 'MIME-Version: 1.0' || utl_tcp.crlf);
    utl_smtp.write_data(v_connection
                       ,'Content-Type: text/plain; charset=windows-1251' || utl_tcp.crlf);
  
    utl_smtp.write_data(v_connection, 'Subject: ');
    utl_smtp.write_raw_data(v_connection, utl_raw.cast_to_raw(p_subject));
    utl_smtp.write_data(v_connection, utl_tcp.crlf);
    utl_smtp.write_data(v_connection, utl_tcp.crlf);
    utl_smtp.write_raw_data(v_connection, utl_raw.cast_to_raw(p_data));
  
    --utl_smtp.write_data(v_connection, utl_tcp.CRLF || p_data);
    utl_smtp.close_data(v_connection);
    utl_smtp.quit(v_connection);
  
    RETURN 1;
  EXCEPTION
    WHEN utl_smtp.transient_error
         OR utl_smtp.permanent_error THEN
      BEGIN
        utl_smtp.quit(v_connection);
      EXCEPTION
        WHEN utl_smtp.transient_error
             OR utl_smtp.permanent_error THEN
          NULL; -- When the SMTP server is down or unavailable, we don't
        -- have a connection to the server. The quit call will
        -- raise an exception that we can ignore.
      END;
      RETURN 0;
  END;

  /*
    ������ �.
    ������ � ������ �������� �����
  */
  PROCEDURE log_mail
  (
    par_to_list     VARCHAR2
   ,par_cc_list     VARCHAR2
   ,par_subject     VARCHAR2
   ,par_body_text   VARCHAR2
   ,par_attach_list VARCHAR2
   ,par_mail_date   DATE DEFAULT SYSDATE
   ,par_err_message VARCHAR2 DEFAULT NULL
  ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    BEGIN
      INSERT INTO sys_emails_log
        (to_list, cc_list, subject, body_text, mail_date, attach_list, sender, err_message)
      VALUES
        (par_to_list
        ,par_cc_list
        ,par_subject
        ,par_body_text
        ,par_mail_date
        ,par_attach_list
        ,USER
        ,par_err_message);
    EXCEPTION
      WHEN OTHERS THEN
        INSERT INTO sys_emails_log
          (to_list, cc_list, subject, body_text, mail_date, sender, err_message)
        VALUES
          (substr(par_to_list, 1, 4000)
          ,substr(par_cc_list, 1, 4000)
          ,substr(par_subject, 1, 4000)
          ,substr(par_body_text, 1, 4000)
          ,nvl(par_mail_date, SYSDATE)
          ,USER
          ,substr(par_err_message, 1, 4000));
    END;
    COMMIT;
  
  END log_mail;

  /*
    ������ �.
    ���������� ������ ����������� �� ID ����
  */
  FUNCTION get_recipients_by_role
  (
    par_role_id      NUMBER
   ,par_address_type VARCHAR2
  ) RETURN t_recipients IS
  BEGIN
    FOR vr_role IN (SELECT em.email
                      FROM ven_sys_user     u
                          ,v_rel_role_user  vru
                          ,employee         emp
                          ,contact          c
                          ,cn_contact_email em
                          ,t_email_type     et
                     WHERE vru.userid = u.sys_user_id
                       AND emp.employee_id = u.employee_id
                       AND c.contact_id = emp.contact_id
                       AND em.contact_id = c.contact_id
                       AND em.email_type = et.id
                       AND et.description = par_address_type
                       AND vru.roleid = par_role_id
                       AND vru.assigned = 1)
    LOOP
      NULL;
    END LOOP;
    RETURN NULL;
  END get_recipients_by_role;
  /*
    ������ �.
    ���������� ������ ����������� �� �������� ����
  */
  FUNCTION get_recipients_by_role
  (
    par_role_name    VARCHAR2
   ,par_address_type VARCHAR2
  ) RETURN t_recipients IS
    v_role_id NUMBER;
  BEGIN
    SELECT sr.sys_role_id INTO v_role_id FROM ven_sys_role sr WHERE upper(sr.name) = par_role_name;
  
    RETURN get_recipients_by_role(v_role_id, par_address_type);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_recipients_by_role;

  /** ����������� ������ � win-1251
  * @author ��������� �.
  * @date   16.04.2015
  */

  FUNCTION encode_string_to_win1251(s_string VARCHAR2) RETURN VARCHAR2 IS
    v_part          NUMBER := 1;
    v_result_string VARCHAR2(4000);
  BEGIN
  
    --���������: ��������� ������� ������ �� ��������� ������ 47 �������� � ������ ��������� �������� ������������ � win-1251
    WHILE v_part < length(s_string)
    LOOP
      v_result_string := v_result_string || '=?windows-1251?B?' ||
                         utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(convert(substr(s_string
                                                                                                             ,v_part
                                                                                                             ,47)
                                                                                                      ,'CL8MSWIN1251')))) || '?=';
      v_part          := v_part + 47;
    END LOOP;
  
    dbms_output.put_line(v_result_string);
  
    RETURN v_result_string;
  END encode_string_to_win1251;

  /** ���������� ������ �� ����� �� ������� ins.app_param
  * @author ��������� �.
  * @date   16.03.2015
  */

  PROCEDURE decrypt_password
  (
    par_brief        ins.app_param.brief%TYPE
   ,par_password_out OUT VARCHAR2
  ) IS
    v_raw_key          RAW(16);
    v_encrypted_string VARCHAR2(4000);
    v_decrypted_raw    RAW(4000);
  BEGIN
    v_encrypted_string := pkg_app_param.get_app_param_c(par_brief);
    v_raw_key          := utl_raw.cast_to_raw(convert(gc_key_string, 'AL32UTF8'));
    v_decrypted_raw    := dbms_crypto.decrypt(typ => dbms_crypto.des_cbc_pkcs5 --���������������
                                             ,src => utl_encode.base64_decode(v_encrypted_string)
                                             ,key => v_raw_key);
    par_password_out   := utl_raw.cast_to_varchar2(utl_encode.base64_encode(v_decrypted_raw));
  END;

  /*
    ������ �.
    �������� ����� � ����������
  */
  PROCEDURE send_mail_with_attachment
  (
    par_to            t_recipients
   ,par_cc            t_recipients DEFAULT NULL
   ,par_subject       VARCHAR2
   ,par_text          VARCHAR2
   ,par_attachment    t_files DEFAULT NULL
   ,par_from          VARCHAR2 DEFAULT 'oracle@renlife.com'
   ,par_login         VARCHAR2 DEFAULT 'oracle'
   ,par_host          VARCHAR2 DEFAULT 'mail.renlife.com'
   ,par_ignore_errors BOOLEAN DEFAULT FALSE
  ) IS
    v_conn         utl_smtp.connection;
    v_reply        utl_smtp.reply;
    v_replies      utl_smtp.replies;
    v_to_list      VARCHAR2(255);
    v_cc_list      VARCHAR2(255);
    v_file_list    VARCHAR2(255);
    v_mail_date    DATE := SYSDATE;
    v_login_b64    VARCHAR2(4000);
    v_password_b64 VARCHAR2(4000);
  
    v_amount NUMBER;
    v_offset NUMBER;
    v_buff   RAW(3000);
  
    v_subject VARCHAR2(4000);
  BEGIN
  
    IF is_test_server = 1
    THEN
      v_subject := '���� (' || REPLACE(upper(ora_database_name), '.RENLIFE.COM', '') || ') ' ||
                   par_subject;
    ELSE
      v_subject := par_subject;
    END IF;
  
    --����������
    v_conn := utl_smtp.open_connection(host => par_host);
    --������� ������ �� �����.
    -- 1. ���� ������ � app_param IS NOT NULL, ��������� � ���������� ������, ����������� �� SMTP-�������; 
    -- 2. ���� ������ � app_param IS NULL, �� ���� ������ ��� ����������� �� SMTP-�������
    IF pkg_app_param.get_app_param_c('ORA_SMTP_PASSWORD') IS NOT NULL
    THEN
      decrypt_password('ORA_SMTP_PASSWORD', v_password_b64);
      v_login_b64 := utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(par_login)));
      utl_smtp.ehlo(v_conn, par_host);
      -- ����������� �� SMTP-�������
      utl_smtp.command(v_conn, 'AUTH', 'LOGIN');
      utl_smtp.command(v_conn, v_login_b64);
      utl_smtp.command(v_conn, v_password_b64);
    END IF;
    -- �����������
    v_reply := utl_smtp.helo(c => v_conn, domain => par_host);
    -- ������������� ����������
    v_reply := utl_smtp.mail(c => v_conn, sender => par_from);
    -- ����������
    FOR v_i IN par_to.first .. par_to.last
    LOOP
      v_reply := utl_smtp.rcpt(c => v_conn, recipient => par_to(v_i));
      -- ������ "����"
      IF v_to_list IS NULL
      THEN
        v_to_list := par_to(v_i);
      ELSE
        v_to_list := v_to_list || ', ' || par_to(v_i);
      END IF;
    END LOOP;
    -- ������ "�����"
    IF par_cc IS NOT NULL
    THEN
      FOR v_i IN par_cc.first .. par_cc.last
      LOOP
        v_reply := utl_smtp.rcpt(c => v_conn, recipient => par_cc(v_i));
        -- ������ "����"
        IF v_cc_list IS NULL
        THEN
          v_cc_list := par_cc(v_i);
        ELSE
          v_cc_list := v_cc_list || ', ' || par_cc(v_i);
        END IF;
      END LOOP;
    END IF;
    -- ���� ������
    v_reply := utl_smtp.open_data(c => v_conn);
  
    utl_smtp.write_data(c    => v_conn
                       ,data => 'From: ' || par_from || utl_tcp.crlf || 'To: ' || v_to_list ||
                                utl_tcp.crlf || 'Date: ' ||
                                to_char(v_mail_date, 'dd.mm.yyyy HH24:MI:SS') || '+0400 (UTC)' ||
                                utl_tcp.crlf || 'Subject: ' || encode_string_to_win1251(v_subject));
  
    -- �����
    IF v_cc_list IS NOT NULL
    THEN
      utl_smtp.write_data(c => v_conn, data => utl_tcp.crlf || 'Cc: ' || v_cc_list);
    END IF;
    -- �������, ��� ������ ������� �� ���������� ������
    utl_smtp.write_data(c    => v_conn
                       ,data => utl_tcp.crlf || 'MIME-Version: 1.0' || utl_tcp.crlf ||
                                'Content-Type: multipart/mixed;' || utl_tcp.crlf ||
                                ' boundary="5645684A5531394A5531395455454653564545684953453D"' ||
                                utl_tcp.crlf || utl_tcp.crlf);
    -- ����� ������
    utl_smtp.write_data(c    => v_conn
                       ,data => '--5645684A5531394A5531395455454653564545684953453D' || utl_tcp.crlf ||
                                'Content-Type: text/plain; charset=windows-1251' || utl_tcp.crlf ||
                                'Content-Transfer_Encoding: 7bit' || utl_tcp.crlf || utl_tcp.crlf);
  
    utl_smtp.write_raw_data(c => v_conn, data => utl_raw.cast_to_raw(par_text));
  
    -- ��������
    IF par_attachment IS NOT NULL
    THEN
      FOR v_i IN par_attachment.first .. par_attachment.last
      LOOP
        v_amount := 3000;
        v_offset := 1;
        -- ��������� ��������
        utl_smtp.write_data(c    => v_conn
                           ,data => utl_tcp.crlf || utl_tcp.crlf ||
                                    '--5645684A5531394A5531395455454653564545684953453D' ||
                                    utl_tcp.crlf || 'Content-Type: ' || par_attachment(v_i)
                                   .v_file_type || ';' || utl_tcp.crlf || ' name="'); -- ����������� �������� �����
        utl_smtp.write_raw_data(c    => v_conn
                               ,data => utl_raw.cast_to_raw(par_attachment(v_i).v_file_name));
      
        utl_smtp.write_data(c    => v_conn
                           ,data => '"' || utl_tcp.crlf || 'Content-Transfer-Encoding: base64' ||
                                    utl_tcp.crlf || 'Content-Disposition: attachment;' || utl_tcp.crlf ||
                                    ' filename="');
      
        utl_smtp.write_data(c    => v_conn
                           ,data => encode_string_to_win1251(par_attachment(v_i).v_file_name));
      
        utl_smtp.write_data(c => v_conn, data => '"' || utl_tcp.crlf || utl_tcp.crlf);
      
        -- ���� �����
        LOOP
          EXIT WHEN v_amount < 3000;
          dbms_lob.read(lob_loc => par_attachment(v_i).v_file
                       ,amount  => v_amount
                       ,offset  => v_offset
                       ,buffer  => v_buff);
        
          IF v_amount > 0
          THEN
            utl_smtp.write_raw_data(c => v_conn, data => utl_encode.base64_encode(v_buff));
            v_offset := v_offset + v_amount;
          END IF;
        END LOOP;
        -- ������ ������ ��� ����
        IF v_file_list IS NULL
        THEN
          v_file_list := par_attachment(v_i).v_file_name;
        ELSE
          v_file_list := v_file_list || ', ' || par_attachment(v_i).v_file_name;
        END IF;
      END LOOP;
    END IF;
    utl_smtp.write_data(c    => v_conn
                       ,data => utl_tcp.crlf || utl_tcp.crlf ||
                                '--5645684A5531394A5531395455454653564545684953453D--');
    -- ��������� ����������
    v_reply := utl_smtp.close_data(c => v_conn);
    utl_smtp.quit(c => v_conn);
  
    -- ������ � ���
    log_mail(par_to_list     => v_to_list
            ,par_cc_list     => v_cc_list
            ,par_subject     => v_subject
            ,par_body_text   => par_text
            ,par_attach_list => v_file_list
            ,par_mail_date   => v_mail_date);
  EXCEPTION
    WHEN utl_smtp.transient_error
         OR utl_smtp.permanent_error THEN
      BEGIN
        utl_smtp.quit(c => v_conn);
        -- ����� ���������� ������, �� ����� ���������������
      EXCEPTION
        WHEN utl_smtp.transient_error
             OR utl_smtp.permanent_error THEN
          NULL;
      END;
      -- ������ ������ � ���
      log_mail(par_to_list     => v_to_list
              ,par_cc_list     => v_cc_list
              ,par_subject     => v_subject
              ,par_body_text   => par_text
              ,par_attach_list => v_file_list
              ,par_err_message => dbms_utility.format_error_stack
              ,par_mail_date   => v_mail_date);
      IF NOT par_ignore_errors
      THEN
        raise_application_error(-20001, '������ ��� �������� ������', TRUE);
      END IF;
    WHEN OTHERS THEN
      -- ������ ������ � ���
      log_mail(par_to_list     => v_to_list
              ,par_cc_list     => v_cc_list
              ,par_subject     => v_subject
              ,par_body_text   => par_text
              ,par_attach_list => v_file_list
              ,par_err_message => SQLERRM
              ,par_mail_date   => v_mail_date);
      IF NOT par_ignore_errors
      THEN
        RAISE;
      END IF;
  END send_mail_with_attachment;

END pkg_email;
/
