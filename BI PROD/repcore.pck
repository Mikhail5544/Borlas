CREATE OR REPLACE PACKAGE REPCORE IS

  /**
  * ���� ����������: ���������� �� ���������, ������
  * @author V.Ustinov
  * @version 1
  * @headcom
  */

  /**
  * ��� - ������.
  * @author V.Ustinov
  */
  TYPE num_table_type IS TABLE OF VARCHAR2(18);

  /**
  * ������� ���������� ������� �� �������, ��������������� �� ���������.
  * @author V.Ustinov
  * @return ������ �� �������
  */
  FUNCTION report_ids_by_context RETURN num_table_type
    PIPELINED;

  /**
  * ��������� ������������� �������� ������ Oracle Forms.<br>
  * ���������� �� repcore.pll
  * @author V.Ustinov
  * @param p_form ������� �����
  * @param p_block ������� ����
  * @param p_item ����� ��� ��������
  */
  PROCEDURE set_interface_context
  (
    p_form  VARCHAR2
   ,p_block VARCHAR2
   ,p_item  VARCHAR2
  );

  /**
  * ��������� ������������� ���������������� ��������, ���������.
  * @author V.Ustinov
  * @param p_key ����, ���
  * @param p_value ��������
  */
  PROCEDURE set_context
  (
    p_key   VARCHAR2
   ,p_value VARCHAR2
  );

  /**
  * ������� ���������� �������� ��������� �� �����.<br>
  * ���������� �������� �������� ����������.
  * @author V.Ustinov
  * @param p_key ����, ��� ���������
  * @return �������� �� ���������
  */
  FUNCTION get_context(p_key VARCHAR2) RETURN VARCHAR2;

  /**
  * ��������� ������� ���������.
  * @author V.Ustinov
  */
  PROCEDURE clear_context;

  /**
  * <strong>���������</strong> ������� ���������� URL.<br>
  * ��������� ��������, ��������� ���������.<br>
  * ������������ repcore.pll
  * @author V.Ustinov
  * @param p_text ������ ���������� URL
  * @return ���������� ������ ���������� URL
  */
  FUNCTION prepare_paremeters(p_text VARCHAR2 /*, p_like_diskoverer boolean := false*/) RETURN VARCHAR2;

  /**
  * <strong>���������</strong> �������.<br>
  * ������������ ��� �������, ���������� ���� �������� ����� �������.
  * @author V.Ustinov
  * @return ���� �������� ����� �������
  */
  FUNCTION context_as_string RETURN VARCHAR2;

  /**
  * <strong>���������</strong> ������� URL �����������
  * @author V.Ustinov
  */
  FUNCTION encode(val VARCHAR2) RETURN VARCHAR2;

  /**
  * <strong>���������</strong> ������� URL �������������
  * @author V.Ustinov
  */
  FUNCTION decode(val VARCHAR2) RETURN VARCHAR2;

  /**
  * <strong>���������</strong> ��������� URL �������������
  * @author V.Ustinov
  */
  PROCEDURE decode(val IN OUT VARCHAR2);

  /**
  * <strong>���������</strong> ��������� ��������� ���������� ���������� ������ �������
  * @author V.Ustinov
  */

  PROCEDURE set_modal_result(mr NUMBER);
  /**
  * <strong>���������</strong> ������� ��������� ���������� ���������� ������ �������
  * @author V.Ustinov
  */
  FUNCTION get_modal_result RETURN NUMBER;

END REPCORE;
/
CREATE OR REPLACE PACKAGE BODY REPCORE IS

  TYPE hash_table_type IS TABLE OF VARCHAR2(128) INDEX BY VARCHAR2(64);
  TYPE refcursor_type IS REF CURSOR;

  -- ��������, ��������� �������
  context_ht hash_table_type;

  -- Modal result
  form_modal_result NUMBER;

  -- ���������� ��������� � �������, ��������
  FUNCTION apply_context
  (
    p_text   VARCHAR2
   ,p_is_url BOOLEAN
  ) RETURN VARCHAR2 IS
    key      VARCHAR2(64);
    res      VARCHAR2(4000) := p_text;
    rpctext  VARCHAR2(1024);
    posb     INTEGER;
    pose     INTEGER;
    bad_key  VARCHAR2(64);
    err_text VARCHAR2(1024);
  BEGIN
    key := context_ht.first;
    WHILE key IS NOT NULL
    LOOP
      IF substr(key, 1, 1) <> '#'
      THEN
        -- ����� � �������� �� ����������
        IF p_is_url
        THEN
          rpctext :=  /*encode*/
           (get_context(key));
        ELSE
          rpctext := '''' || get_context(key) || '''';
        END IF;
        res := REPLACE(res, '<#' || key || '>', rpctext);
      END IF;
      key := context_ht.next(key);
    END LOOP;
    -- ���������, ��� �� ����������
    posb := instr(res, '<#');
    IF posb > 0
    THEN
      pose := instr(res, '>', posb);
      IF pose > 0
      THEN
        -- ����� ����� ������� ����� � �������
        bad_key := substr(res, posb, pose - posb + 1);
      END IF;
      err_text := 'REPCORE: �������� ���������� �� ���������, ���� �������� ������. ���������� � ��������������.';
      IF bad_key IS NOT NULL
      THEN
        err_text := err_text || ' ������� ������: ' || bad_key;
      END IF;
      raise_application_error(-20000, err_text);
    END IF;
    RETURN res;
  END;

  FUNCTION report_ids_by_context RETURN num_table_type
    PIPELINED IS
    cur         refcursor_type;
    report_id   NUMBER;
    l_condition rep_context.rep_context%TYPE;
    l_form      rep_context.form%TYPE;
    res         INTEGER;
  BEGIN
    OPEN cur FOR
      SELECT rep_report_id
            ,rep_context
            ,form
        FROM rep_context
       WHERE (form = get_context('#FORM'))
         AND (datablock IS NULL OR datablock = get_context('#BLOCK'));
    LOOP
      -- ���� �� ������� ��������� ��� ������ �����/�����
      FETCH cur
        INTO report_id
            ,l_condition
            ,l_form;
      EXIT WHEN cur%NOTFOUND;
      IF l_condition IS NOT NULL
         AND l_form = get_context('#FORM')
      THEN
        -- ���� �������������� �������� � ��������� ��������
        -- ���������� ������ � �������
        l_condition := apply_context(l_condition, FALSE);
        BEGIN
          EXECUTE IMMEDIATE 'begin select 1 into :res from dual where (' || l_condition || '); end;'
            USING OUT res;
          PIPE ROW(report_id); -- ������ ��� ��������
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL; -- �������� �� ������
          WHEN OTHERS THEN
            raise_application_error(-20000
                                   ,'REPCORE: ������ ��� �������� ���������! ���������� � ��������������. �������: ( "' ||
                                    l_condition || '")');
        END;
      ELSE
        PIPE ROW(report_id); -- ���. ��������� �� ���������, ������ �����
      END IF;
    END LOOP;
    CLOSE cur;
    RETURN;
  END;

  FUNCTION get_context(p_key VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF context_ht.exists(upper(p_key))
    THEN
      RETURN context_ht(upper(p_key));
    ELSE
      raise_application_error(-20000
                             ,'REPCORE: �������� ����������� ���������� "' || upper(p_key) ||
                              '" �� �������. ���������� � ��������������.');
    END IF;
  END;

  PROCEDURE set_interface_context
  (
    p_form  VARCHAR2
   ,p_block VARCHAR2
   ,p_item  VARCHAR2
  ) IS
  BEGIN
    context_ht('#FORM') := p_form;
    context_ht('#BLOCK') := p_block;
    context_ht('#ITEM') := p_item;
  END;

  PROCEDURE clear_context IS
  BEGIN
    context_ht.delete;
  END;

  PROCEDURE set_context
  (
    p_key   VARCHAR2
   ,p_value VARCHAR2
  ) IS
  BEGIN
    IF instr(p_key, '#') > 0
       OR instr(p_key, '<') > 0
       OR instr(p_key, '>') > 0
    THEN
      raise_application_error(-20000
                             ,'REPCORE: ��� ����������� ���������� ������ ������������ �����, ���������� ����� "#", "<", ">". ������� ���� ��� "' ||
                              upper(p_key) || '". ���������� � ��������������.');
    END IF;
    IF length(p_value) > 128
    THEN
      raise_application_error(-20000
                             ,'REPCORE: �������� ����������� ���������� "' || upper(p_key) ||
                              '" ��������� ������������ �����. ���������� � ��������������.');
    END IF;
    context_ht(upper(p_key)) := p_value;
  END;

  FUNCTION context_as_string RETURN VARCHAR2 IS
    l_str VARCHAR2(2048);
    key   VARCHAR2(64);
  BEGIN
    key := context_ht.first;
    WHILE key IS NOT NULL
    LOOP
      l_str := l_str || key || ' = "' || context_ht(key) || '"   ';
      key   := context_ht.next(key);
    END LOOP;
    RETURN l_str;
  END;

  FUNCTION prepare_paremeters(p_text VARCHAR2 /*, p_like_diskoverer boolean := false*/) RETURN VARCHAR2 IS
    res VARCHAR2(6000);
  BEGIN
    res := apply_context(p_text, TRUE); -- ��������� ��������
    IF substr(res, 1, 1) <> '&'
    THEN
      res := '&' || res;
    END IF;
    RETURN res;
  END;

  FUNCTION encode(val VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN utl_url.escape(val, TRUE, 'UTF8');
  END;

  FUNCTION decode(val VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    RETURN utl_url.unescape(val, 'UTF8');
  END;

  PROCEDURE decode(val IN OUT VARCHAR2) AS
  BEGIN
    val := decode(val);
  END;

  PROCEDURE set_modal_result(mr NUMBER) AS
  BEGIN
    IF mr NOT IN (utils.c_true, utils.c_false)
    THEN
      raise_application_error(-20000, 'REPCORE: SET_MODAL_RESULT failed. Bad parameter.');
    END IF;
    form_modal_result := mr;
  END;

  FUNCTION get_modal_result RETURN NUMBER AS
  BEGIN
    RETURN form_modal_result;
  END;

BEGIN
  context_ht('#FORM') := '#';
  context_ht('#BLOCK') := '#';
END REPCORE;
/
