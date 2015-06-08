CREATE OR REPLACE PACKAGE Utils IS

  /**
    * �����, ���������� ��������� ������� ������ ����������
  * �������� �������, ��������� � ��������� �� �������:
  * PKG_UTILS (int2speech, float2speech, inttospeech, money2speech, date2genitive_case, fio2full_name, return_from_select)
  * PKG_MESSAGE_UTILS(register_message, get_message)
  * PKG_COMMON_UTILS(miss_num, miss_char, miss_date, c_true, c_false, is_empty)
  * @author Filipp Ganichev
  * @version 1.0
   */
  TYPE hashmap_t IS TABLE OF VARCHAR2(4000) INDEX BY VARCHAR2(100);
  /**
  *  ������ �������� ���� number
  */
  miss_num CONSTANT NUMBER := -1;

  /**
  *  ������ �������� ���� varchar
  */
  miss_char CONSTANT VARCHAR2(1) := '~';

  /**
  *  ������ �������� ���� date
  */
  miss_date CONSTANT DATE := TO_DATE('01.01.1000', 'dd.MM.yyyy');

  /**
  *  �������� true
  */
  c_true CONSTANT NUMBER := 1;

  /**
  *  �������� false
  */
  c_false CONSTANT NUMBER := 0;

  /**
  *  �������� ������������, ���� exception, ������� ��� ����, ��� ������� �� ����� 
     ��� ��� ������, ����� �������� � ������������� ������
  */
  c_exept CONSTANT NUMBER := -1;

  /**
  * �������� true
  * @author Patsan O.
  * @return �������� true
  */
  FUNCTION get_true RETURN NUMBER;

  /**
  * �������� false
  * @author Patsan O.
  * @return �������� false
  */
  FUNCTION get_false RETURN NUMBER;

  /**
  * ������ �������� ���� ������
  * @author Patsan O.
  * @return ������ �������� ���� ������
  */
  FUNCTION get_miss_char RETURN VARCHAR2;

  /**
  * ������ �������� ���� �����
  * @author Patsan O.
  * @return ������ �������� ���� �����
  */
  FUNCTION get_miss_num RETURN NUMBER;

  /**
  * ������ �������� ���� ����
  * @author Patsan O.
  * @return ������ �������� ���� ����
  */
  FUNCTION get_miss_date RETURN DATE;

  /**
  *  �������� �� ������ �������� ���������� ���� number
  *  @author Filipp Ganichev
  *  @param p_value �������� ����������
  *  @return c_false/c_true
  */
  FUNCTION is_empty(p_value NUMBER) RETURN NUMBER;

  /**
  *  �������� �� ������ �������� ���������� ���� varchar
  *  @author Filipp Ganichev
  *  @param p_value �������� ����������
  *  @return c_false/c_true
  */
  FUNCTION is_empty(p_value VARCHAR2) RETURN NUMBER;

  /**
  *  �������� �� ������ �������� ���������� ���� date
  *  @author Filipp Ganichev
  *  @param p_value �������� ����������
  *  @return c_false/c_true
  */
  FUNCTION is_empty(p_value DATE) RETURN NUMBER;

  /**
  *  ���������/�������� � ������� ��������� ���������� � ���������
  *  @author Filipp Ganichev
  *  @param p_message_brief ������� ���, ���������������� ���������
  *  @param p_message_name ����� ��������� � �����������. ��������� � ������ ����������� � ���� %���_���������
  *  @param p_lang_id  Id ����� � ������� lang. ���������� ������ ���� p_lang_brief, ���� p_lang_id
  *  @param p_upd_mes_if_exists ���� �������� ����� c_true, �� ����� ��������� ����� �������, ���� ��������� ��� ���� � �������, ����� ����� ������������� �������������� ��������
  */
  PROCEDURE register_message
  (
    p_message_brief     VARCHAR2
   ,p_message_name      VARCHAR2
   ,p_lang_id           NUMBER
   ,p_upd_mes_if_exists NUMBER DEFAULT c_true
  );

  /**
  *  ���������/�������� � ������� ��������� ���������� � ���������
  *  @author Filipp Ganichev
  *  @param p_message_brief ������� ���, ���������������� ���������
  *  @param p_message_name ����� ��������� � �����������. ��������� � ������ ����������� � ���� %���_���������
  *  @param p_lang_brief ������� ������������ ����� � ������� lang
  *  @param p_upd_mes_if_exists ���� �������� ����� c_true, �� ����� ��������� ����� �������, ���� ��������� ��� ���� � �������, ����� ����� ������������� �������������� ��������
  */
  PROCEDURE register_message
  (
    p_message_brief     VARCHAR2
   ,p_message_name      VARCHAR2
   ,p_lang_brief        VARCHAR2
   ,p_upd_mes_if_exists NUMBER DEFAULT c_true
  );
  /**
  *  ���������� ����� ��������� �� �������� ����� � ������������ ����������
  *  @author Filipp Ganichev
  *  @param p_message_brief ������� ���, ���������������� ���������
  *  @param p_lang_id  Id ����� � ������� lang
  *  @param p_token_name1 ������������ ���������
  *  @param p_token1 �������� ���������
  *  @param p_token_name2 ������������ ���������
  *  @param p_token2 �������� ���������
  *  @param p_token_name3 ������������ ���������
  *  @param p_token3 �������� ���������
  *  @param p_token_name4 ������������ ���������
  *  @param p_token4 �������� ���������
  *  @param p_token_name5 ������������ ���������
  *  @param p_token5 �������� ���������
  *  @return ����� ���������
  */
  FUNCTION get_message
  (
    p_message_brief VARCHAR2
   ,p_lang_id       NUMBER DEFAULT Ents.get_lang_id
   ,p_token_name1   VARCHAR2 DEFAULT miss_char
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token_name2   VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token_name3   VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token_name4   VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token_name5   VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2;

  /**
  *  ���������� ����� ��������� �� �������� ����� � ������������ ����������
  *  @author Filipp Ganichev
  *  @param p_message_brief ������� ���, ���������������� ���������
  *  @param p_lang_id  Id ����� � ������� lang
  *  @param p_token1 �������� 1-�� ���������
  *  @param p_token2 �������� 2-�� ���������
  *  @param p_token3 �������� 3-�� ���������
  *  @param p_token4 �������� 4-�� ���������
  *  @param p_token5 �������� 5-�� ���������
  *  @return ����� ���������
  */
  FUNCTION get_mes1
  (
    p_message_brief VARCHAR2
   ,p_lang_id       NUMBER DEFAULT Ents.get_lang_id
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2;

  /**
  *  ���������� ����� ��������� �� �������� ����� � ������������ ����������
  *  @author Filipp Ganichev
  *  @param p_message_brief ������� ���, ���������������� ���������
  *  @param p_token1 �������� 1-�� ���������
  *  @param p_token2 �������� 2-�� ���������
  *  @param p_token3 �������� 3-�� ���������
  *  @param p_token4 �������� 4-�� ���������
  *  @param p_token5 �������� 5-�� ���������
  *  @return ����� ���������
  */
  FUNCTION get_mes
  (
    p_message_brief VARCHAR2
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2;

  /**
  *  ���������� ����� ��������� �� �������� ����� � ������������ ����������
  *  @author Filipp Ganichev
  *  @param p_message_brief ������� ���, ���������������� ���������
  *  @param p_lang_brief Id ����� � ������� lang
  *  @param p_token_name1 ������������ ���������
  *  @param p_token1 �������� ���������
  *  @param p_token_name2 ������������ ���������
  *  @param p_token2 �������� ���������
  *  @param p_token_name3 ������������ ���������
  *  @param p_token3 �������� ���������
  *  @param p_token_name4 ������������ ���������
  *  @param p_token4 �������� ���������
  *  @param p_token_name5 ������������ ���������
  *  @param p_token5 �������� ���������
  *  @return ����� ���������
  */
  FUNCTION get_message
  (
    p_message_brief VARCHAR2
   ,p_lang_brief    VARCHAR2
   ,p_token_name1   VARCHAR2 DEFAULT miss_char
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token_name2   VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token_name3   VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token_name4   VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token_name5   VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2;

  /**
  *  ��������� ���������� � ���������� �� �������� ����� � ������������ ����������
  *  @author Filipp Ganichev
  *  @param p_message_brief ������� ���, ���������������� ���������
  *  @p_error_code ��� ������
  *  @p_text ����� ���������
  *  @param p_token1 �������� 1-�� ���������
  *  @param p_token2 �������� 2-�� ���������
  *  @param p_token3 �������� 3-�� ���������
  *  @param p_token4 �������� 4-�� ���������
  *  @param p_token5 �������� 5-�� ���������
  */
  PROCEDURE raise_err
  (
    p_message_brief VARCHAR2
   ,p_error_code    NUMBER
   ,p_text          VARCHAR2
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  );

  /**
  * ��������� ���������� �������� � ���������� �� �������� ����� � ������������ ����������
  * @author Patsan O.
  * @param p_error_code ��� ������
  * @param p_text ����� ���������
  * @param p_ent_id �� ��������
  */
  PROCEDURE raise_entity_err
  (
    p_error_code NUMBER
   ,p_text       VARCHAR2
   ,p_ent_id     IN NUMBER DEFAULT NULL
  );

  /**
  * ������� ������ ����� � �������
  * @author Patsan O.
  * @param dig �����
  * @param sex ��� (M/F) ������
  * @return ����� ��������
  */
  FUNCTION int2speech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ������� �������� ����� � �������
  * @author Patsan O.
  * @param value �����
  * @param sex ��� (M/F) ������
  * @return ����� ��������
  */
  FUNCTION float2speech
  (
    VALUE IN NUMBER
   ,sex   IN VARCHAR2
   ,POWER IN INTEGER
  ) RETURN VARCHAR2;

  /**
  * ������� ������ ����� � �������
  * @author Patsan O.
  * @param dig �����
  * @param sex ��� (M/F) ������
  * @return ����� ��������
  */
  FUNCTION inttospeech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2;

  /**
  * ������� ����� � �������
  * @author Patsan O.
  * @param quant �����
  * @param p_fund_id �� ������
  * @return ����� ��������
  */
  FUNCTION money2speech
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2;

  /**
  * ���� � ����������� ������
  * @author Patsan O.
  * @param p_date ����
  * @return ���� � ����������� ������
  */
  FUNCTION date2genitive_case(p_date DATE) RETURN VARCHAR2;

  /** 
  * ����� � ����������� ������
  * @author Patsan O.
  * @param p_date ����
  * @param p_caps 0-�������� � ��������� �����, 1-� �������
  * @return ����� � ����������� ������
  */
  FUNCTION month_declension
  (
    p_date DATE
   ,p_caps NUMBER DEFAULT 0
  ) RETURN VARCHAR2;

  /**
  * ������ ��� �� ��������� �����
  * @author Patsan O.
  * @param ���
  * @param �������
  * @param ���
  * @param ��������
  */
  PROCEDURE fio2full_name
  (
    p_fio         IN VARCHAR2
   ,p_last_name   OUT VARCHAR2
   ,p_first_name  OUT VARCHAR2
   ,p_middle_name OUT VARCHAR2
  );

  /**
  * ���������� PLS-SQL � ������� ��������
  * @author Patsan O.
  * @param p_sql ����� ������������ ����
  * @param p_in �������� ��������� ���������
  * @param p_out �������� ���������� ���������
  */
  PROCEDURE return_from_select
  (
    p_sql IN VARCHAR2
   ,p_in  IN NUMBER
   ,p_out OUT VARCHAR2
  );

  /**
  * ���������� PLS-SQL � ������� ��������
  * @author Patsan O.
  * @param p_sql ����� ������������ ����
  * @param res �������� ���������� ���������
  */
  PROCEDURE exec_immediate
  (
    p_sql IN VARCHAR2
   ,res   OUT NUMBER
  );

  /**
  * ������ �������� � ��������� ��������
  * @author Patsan O.
  * @param str �������� ������
  * @param symb ���������� ������
  * @param symbto ���������� ������
  * @param dotrim ������� ������������� ��������� �������� (Y/N)
  * @return ���������� ������
  */
  FUNCTION replaceall
  (
    str    IN VARCHAR2
   ,symb   IN VARCHAR2 DEFAULT ',,'
   ,symbto IN VARCHAR2 DEFAULT ','
   ,dotrim IN CHAR DEFAULT 'Y'
  ) RETURN VARCHAR2;

  /** 
  * ��������/��������� ���������� � ���-������. ������������ � ��������� ��� �������� ���������� � ��������� ���������� ��� ����� ��������
  *  @author �. �������
  * @param key_val ���� ����������
  * @param value �������� ����������
  */
  PROCEDURE put
  (
    key_val VARCHAR2
   ,VALUE   VARCHAR2
  );

  /** 
  * ��������� �������� ���������� �� ���-�������. ������������ � ��������� ��� �������� ���������� � ��������� ���������� ��� ����� ��������
  * @author �. �������
  * @param key_val ���� ����������
  * @return �������� ����������, ���� �������� ���������������� ����� ���, �� no_data_found
  */
  FUNCTION get(key_val VARCHAR2) RETURN VARCHAR2;

  /** 
  * ��������� �������� ���������� �� ���-�������. ������������ � ��������� ��� �������� ���������� � ��������� ���������� ��� ����� ��������
  * @author �. �������
  * @param key_val ���� ����������
  * @return �������� ����������, ���� �������� ���������������� ����� ���, �� null
  */
  FUNCTION get_null
  (
    key_val     VARCHAR2
   ,default_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  FUNCTION get_null
  (
    collection  hashmap_t
   ,key_val     VARCHAR2
   ,default_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;

  /** 
  * ������� ���
  * @author �. �������
  */
  PROCEDURE CLEAR;

  /** 
  * COMMIT
  * @author �. �������
  */
  PROCEDURE cm;

  /** 
    �������� ����� ��� (Surname, Name and Patronymic in Case form)
    @autor valerytin, hexcept@narod.ru, 2003-11-18
    @param p_fio ������,���������� �������,��� � ��������
    @param p_padzh ����� (������ ������e): '�'|'�'-�����������, '�'|'�'-���������,etc., ���� �����: 1-������������, 2-�����������, 3-���������, etc. 
    @param p_fio_fmt ������ ������� ������-��� (�.�.'������� �����'->'��','����� ������� ������-��������'->'���',etc.)
    @param p_sex -- ��� '�'|'�'|'�'|'�'
    @return �������� ����� ��� 
  */
  FUNCTION snp_case
  (
    p_fio     IN VARCHAR2
   ,p_padzh   IN VARCHAR2
   ,p_fio_fmt IN VARCHAR2 DEFAULT '���'
   ,p_sex     IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2;
  /** 
    ���� ��������)
    @autor Alex Khomich
    @param for_convert DATE, �������������� ����
    @param question_suffix NUMBER default 2: '������: ������? - �������� �������� (�������� ��������� 2); �����? - �������� ������ (�������� ��������� 1)
    @return ���������� ������������� ���� VACHAR2(100)
  */
  FUNCTION date2speach
  (
    for_convert     DATE
   ,question_suffix NUMBER DEFAULT 2
  ) RETURN VARCHAR2;

  /**
  *  ���������� ���������� ���� � ��������� �������
  *  @author D.Syrovetskiy
  *  @param p_start_date ��������� ���� � �������
  *  @parem p_end_date �������� ���� � ������� (����� ���� ������)
  *  @return ���������� ���� � �������
  */
  FUNCTION get_count_days
  (
    p_start_date DATE
   ,p_end_date   DATE DEFAULT NULL
  ) RETURN NUMBER;

  PROCEDURE sleep(p_delay NUMBER);

END;
/
CREATE OR REPLACE PACKAGE BODY Utils IS

  hashmap hashmap_t;
  PROCEDURE put
  (
    key_val VARCHAR2
   ,VALUE   VARCHAR2
  ) IS
  BEGIN
    hashmap(key_val) := VALUE;
  END;
  FUNCTION get(key_val VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN hashmap(key_val);
  END;

  FUNCTION get_null
  (
    key_val     VARCHAR2
   ,default_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN hashmap(key_val);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN default_val;
  END;

  FUNCTION get_null
  (
    collection  hashmap_t
   ,key_val     VARCHAR2
   ,default_val VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN collection(key_val);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN default_val;
  END;

  PROCEDURE CLEAR IS
  BEGIN
    hashmap.DELETE;
  END;

  FUNCTION get_true RETURN NUMBER IS
  BEGIN
    RETURN c_true;
  END;

  FUNCTION get_false RETURN NUMBER IS
  BEGIN
    RETURN c_false;
  END;

  FUNCTION get_miss_char RETURN VARCHAR2 IS
  BEGIN
    RETURN miss_char;
  END;

  FUNCTION get_miss_num RETURN NUMBER IS
  BEGIN
    RETURN miss_num;
  END;

  FUNCTION get_miss_date RETURN DATE IS
  BEGIN
    RETURN miss_date;
  END;

  FUNCTION int2speech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2 IS
    ret       VARCHAR2(300);
    REMAINDER NUMBER;
  BEGIN
    REMAINDER := TRUNC(MOD(dig, 1000) / 100);
  
    SELECT DECODE(REMAINDER
                 ,1
                 ,'��� '
                 ,2
                 ,'������ '
                 ,3
                 ,'������ '
                 ,4
                 ,'��������� '
                 ,5
                 ,'������� '
                 ,6
                 ,'�������� '
                 ,7
                 ,'������� '
                 ,8
                 ,'��������� '
                 ,9
                 ,'��������� ')
      INTO ret
      FROM DUAL;
  
    REMAINDER := TRUNC(MOD(dig, 100) / 10);
  
    SELECT ret || DECODE(REMAINDER
                        ,1
                        ,DECODE(MOD(dig, 10)
                               ,0
                               ,'������ '
                               ,1
                               ,'����������� '
                               ,2
                               ,'���������� '
                               ,3
                               ,'���������� '
                               ,4
                               ,'������������ '
                               ,5
                               ,'���������� '
                               ,6
                               ,'����������� '
                               ,7
                               ,'���������� '
                               ,8
                               ,'������������ '
                               ,9
                               ,'������������ ')
                        ,2
                        ,'�������� '
                        ,3
                        ,'�������� '
                        ,4
                        ,'����� '
                        ,5
                        ,'��������� '
                        ,6
                        ,'���������� '
                        ,7
                        ,'��������� '
                        ,8
                        ,'����������� '
                        ,9
                        ,'��������� ')
      INTO ret
      FROM DUAL;
  
    IF REMAINDER = 1
    THEN
      RETURN ret;
    END IF;
  
    REMAINDER := MOD(dig, 10);
  
    SELECT ret || DECODE(REMAINDER
                        ,1
                        ,DECODE(UPPER(sex), 'M', '���� ', 'F', '���� ')
                        ,2
                        ,DECODE(UPPER(sex), 'M', '��� ', 'F', '��� ')
                        ,3
                        ,'��� '
                        ,4
                        ,'������ '
                        ,5
                        ,'���� '
                        ,6
                        ,'����� '
                        ,7
                        ,'���� '
                        ,8
                        ,'������ '
                        ,9
                        ,'������ ')
      INTO ret
      FROM DUAL;
  
    RETURN ret;
  END;

  FUNCTION float2speech
  (
    VALUE IN NUMBER
   ,sex   IN VARCHAR2
   ,POWER IN INTEGER
  ) RETURN VARCHAR2 IS
    ret VARCHAR2(300);
    p   VARCHAR2(1);
    i   INTEGER;
  BEGIN
    IF POWER = 0
    THEN
      ret := '';
      p   := sex;
      i   := -1;
    ELSE
      IF POWER > 1
      THEN
        p := 'M';
      ELSE
        p := 'F';
      END IF;
    
      i := TRUNC(VALUE);
    
      IF TRUNC(MOD(i, 100) / 10) = 1
      THEN
        i := 5;
      ELSE
        i := MOD(i, 10);
      END IF;
    
      IF i = 1
      THEN
        SELECT DECODE(p, 'M', ' ', 'F', '� ') || ret INTO ret FROM DUAL;
      ELSIF (i >= 2)
            AND (i <= 4)
      THEN
        SELECT DECODE(p, 'M', '� ', 'F', '� ') || ret INTO ret FROM DUAL;
      ELSE
        SELECT DECODE(p, 'M', '�� ', 'F', ' ') || ret INTO ret FROM DUAL;
      END IF;
    
      IF (TRUNC(VALUE) MOD 1000) <> 0
      THEN
        SELECT DECODE(POWER
                     ,1
                     ,'�����'
                     ,2
                     ,'�������'
                     ,3
                     ,'��������'
                     ,4
                     ,'��������') || ret
          INTO ret
          FROM DUAL;
      END IF;
    END IF;
  
    ret := int2speech(TRUNC(VALUE) MOD 1000, p) || ret;
  
    IF VALUE >= 1000
    THEN
      ret := float2speech(VALUE / 1000, p, POWER + 1) || ret;
    END IF;
  
    RETURN ret;
  END;

  FUNCTION inttospeech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2 IS
    ret VARCHAR2(300);
  BEGIN
    ret := float2speech(ABS(dig), sex, 0);
  
    IF ret IS NULL
    THEN
      RETURN '����';
    ELSIF dig < 0
    THEN
      RETURN '����� ' || ret;
    ELSE
      RETURN ret;
    END IF;
  
    RETURN ret;
  END;

  FUNCTION money2speech
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2 IS
    ret           VARCHAR2(500);
    v_whole_value NUMBER;
    v_whole_brief VARCHAR2(30);
    v_fract_value NUMBER;
    v_fract_brief VARCHAR2(30);
    v_last_digit  NUMBER;
    v_fund        FUND%ROWTYPE;
  BEGIN
    SELECT * INTO v_fund FROM FUND f WHERE f.fund_id = p_fund_id;
  
    v_whole_value := ROUND(quant, 2);
    v_fract_value := ABS(v_whole_value - TRUNC(v_whole_value)) * 100;
    v_whole_value := TRUNC(v_whole_value);
    v_last_digit  := TO_NUMBER(SUBSTR(TO_CHAR(v_whole_value), LENGTH(TO_CHAR(v_whole_value)), 1));
  
    IF (LENGTH(TO_CHAR(v_whole_value)) > 1)
    THEN
      IF SUBSTR(TO_CHAR(v_whole_value), LENGTH(TO_CHAR(v_whole_value)) - 1, 1) = '1'
      THEN
        v_last_digit := v_last_digit + 10;
      END IF;
    END IF;
  
    v_whole_brief := (CASE v_last_digit
                       WHEN 1 THEN
                        v_fund.spell_1_whole
                       WHEN 2 THEN
                        v_fund.spell_2_whole
                       WHEN 3 THEN
                        v_fund.spell_2_whole
                       WHEN 4 THEN
                        v_fund.spell_2_whole
                       ELSE
                        v_fund.spell_5_whole
                     END);
    v_last_digit  := TO_NUMBER(SUBSTR(TO_CHAR(v_fract_value), LENGTH(TO_CHAR(v_fract_value)), 1));
  
    IF (LENGTH(TO_CHAR(v_fract_value)) > 1)
    THEN
      IF SUBSTR(TO_CHAR(v_fract_value), LENGTH(TO_CHAR(v_fract_value)) - 1, 1) = '1'
      THEN
        v_last_digit := v_last_digit + 10;
      END IF;
    END IF;
  
    v_fract_brief := (CASE v_last_digit
                       WHEN 1 THEN
                        v_fund.spell_1_fract
                       WHEN 2 THEN
                        v_fund.spell_2_fract
                       WHEN 3 THEN
                        v_fund.spell_2_fract
                       WHEN 4 THEN
                        v_fund.spell_2_fract
                       ELSE
                        v_fund.spell_5_fract
                     END);
    ret           := TRIM(inttospeech(v_whole_value, 'm')) || ' ' || TRIM(v_whole_brief) || ' ' ||
                     TRIM(TO_CHAR(v_fract_value, '00')) || ' ' || TRIM(v_fract_brief);
    RETURN NLS_UPPER(SUBSTR(ret, 1, 1)) || SUBSTR(ret, 2);
  END;

  FUNCTION date2genitive_case(p_date DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(p_date, 'dd') || ' ' ||(CASE TO_NUMBER(TO_CHAR(p_date, 'mm')) WHEN 1 THEN '������' WHEN 2 THEN
                                           '�������' WHEN 3 THEN '�����' WHEN 4 THEN '������' WHEN 5 THEN
                                           '���' WHEN 6 THEN '����' WHEN 7 THEN '����' WHEN 8 THEN
                                           '�������' WHEN 9 THEN '��������' WHEN 10 THEN '�������' WHEN 11 THEN
                                           '������' WHEN 12 THEN '�������' ELSE '' END) || ' ' || TO_CHAR(p_date
                                                                                                         ,'yyyy') || ' ����';
  END;

  FUNCTION month_declension
  (
    p_date DATE
   ,p_caps NUMBER DEFAULT 0
  ) RETURN VARCHAR2 IS
    RESULT  VARCHAR2(50);
    p_month NUMBER;
  BEGIN
    p_month := TO_NUMBER(TO_CHAR(p_date, 'mm'));
    CASE p_month
      WHEN 1 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '�����' INTO RESULT FROM dual;
      WHEN 2 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '������' INTO RESULT FROM dual;
      WHEN 3 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '����' INTO RESULT FROM dual;
      WHEN 4 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '�����' INTO RESULT FROM dual;
      WHEN 5 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '��' INTO RESULT FROM dual;
      WHEN 6 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '���' INTO RESULT FROM dual;
      WHEN 7 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '���' INTO RESULT FROM dual;
      WHEN 8 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '������' INTO RESULT FROM dual;
      WHEN 9 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '�������' INTO RESULT FROM dual;
      WHEN 10 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '������' INTO RESULT FROM dual;
      WHEN 11 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '�����' INTO RESULT FROM dual;
      WHEN 12 THEN
        SELECT DECODE(p_caps, 0, '�', '�') || '������' INTO RESULT FROM dual;
      ELSE
        RETURN '';
    END CASE;
    RETURN RESULT;
  END;
  --��������� ��� �� ��������� �����
  PROCEDURE fio2full_name
  (
    p_fio         IN VARCHAR2
   ,p_last_name   OUT VARCHAR2
   ,p_first_name  OUT VARCHAR2
   ,p_middle_name OUT VARCHAR2
  ) IS
    i      NUMBER;
    v_name VARCHAR2(255);
  BEGIN
    v_name := TRIM(p_fio);
    i      := INSTR(v_name, ' ');
  
    IF i > 0
    THEN
      p_last_name := TRIM(SUBSTR(v_name, 1, i - 1));
      v_name      := TRIM(SUBSTR(v_name, i + 1, LENGTH(v_name) - i));
      i           := INSTR(v_name, '.');
    
      IF i = 0
      THEN
        i := INSTR(v_name, ' ');
      END IF;
    
      IF i > 0
      THEN
        p_first_name := TRIM(SUBSTR(v_name, 1, i - 1));
        v_name       := TRIM(SUBSTR(v_name, i + 1, LENGTH(v_name) - i));
        i            := INSTR(v_name, '.');
      
        IF i = 0
        THEN
          i := INSTR(v_name, ' ');
        END IF;
      
        IF i > 0
        THEN
          p_middle_name := TRIM(SUBSTR(v_name, 1, i - 1));
        ELSE
          p_middle_name := TRIM(v_name);
        END IF;
      ELSE
        p_first_name := TRIM(v_name);
      END IF;
    ELSE
      p_last_name := v_name;
    END IF;
  END;

  PROCEDURE return_from_select
  (
    p_sql IN VARCHAR2
   ,p_in  IN NUMBER
   ,p_out OUT VARCHAR2
  ) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql
      USING OUT p_out, IN p_in;
  END;

  FUNCTION get_lang_id(p_lang_brief VARCHAR2) RETURN VARCHAR2 IS
    v_lang_id NUMBER;
  BEGIN
    BEGIN
      SELECT lang_id INTO v_lang_id FROM LANG WHERE brief = p_lang_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100, '�� ������ ����');
    END;
  
    RETURN v_lang_id;
  END;

  PROCEDURE register_message
  (
    p_message_brief     VARCHAR2
   ,p_message_name      VARCHAR2
   ,p_lang_id           NUMBER
   ,p_upd_mes_if_exists NUMBER DEFAULT c_true
  ) IS
    v_lang_id       NUMBER := NULL;
    v_message_brief VARCHAR2(200);
  BEGIN
    v_lang_id := p_lang_id;
  
    BEGIN
      SELECT brief
        INTO v_message_brief
        FROM SYS_MESSAGE
       WHERE lang_id = v_lang_id
         AND brief = p_message_brief;
    
      IF p_upd_mes_if_exists != c_true
      THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'��������� ' || v_message_brief || ' ��� ����������');
      END IF;
    
      UPDATE SYS_MESSAGE
         SET NAME = p_message_name
       WHERE lang_id = v_lang_id
         AND brief = v_message_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO SYS_MESSAGE
          (sys_message_id, lang_id, brief, NAME)
        VALUES
          (sq_message.NEXTVAL, v_lang_id, p_message_brief, p_message_name);
    END;
  
    COMMIT;
  END;

  PROCEDURE register_message
  (
    p_message_brief     VARCHAR2
   ,p_message_name      VARCHAR2
   ,p_lang_brief        VARCHAR2
   ,p_upd_mes_if_exists NUMBER DEFAULT c_true
  ) IS
    v_lang_id       NUMBER := NULL;
    v_message_brief VARCHAR2(200);
  BEGIN
    v_lang_id := get_lang_id(p_lang_brief);
  
    BEGIN
      SELECT brief
        INTO v_message_brief
        FROM SYS_MESSAGE
       WHERE lang_id = v_lang_id
         AND brief = p_message_brief;
    
      IF p_upd_mes_if_exists != c_true
      THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'��������� ' || v_message_brief || ' ��� ����������');
      END IF;
    
      UPDATE SYS_MESSAGE
         SET NAME = p_message_name
       WHERE lang_id = v_lang_id
         AND brief = v_message_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO SYS_MESSAGE
          (sys_message_id, lang_id, brief, NAME)
        VALUES
          (sq_message.NEXTVAL, v_lang_id, p_message_brief, p_message_name);
    END;
  
    COMMIT;
  END;

  FUNCTION GET_MESSAGE
  (
    p_message_brief VARCHAR2
   ,p_lang_id       NUMBER DEFAULT Ents.get_lang_id
   ,p_token_name1   VARCHAR2 DEFAULT miss_char
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token_name2   VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token_name3   VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token_name4   VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token_name5   VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2 IS
    v_lang_id NUMBER;
    v_message VARCHAR2(4000);
  BEGIN
    v_lang_id := p_lang_id;
  
    BEGIN
      SELECT NAME
        INTO v_message
        FROM SYS_MESSAGE
       WHERE lang_id = v_lang_id
         AND brief = p_message_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'��������� ' || p_message_brief || ' ��� ����� � ID = ' || v_lang_id ||
                                ' �� �������');
    END;
  
    IF p_token_name1 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name1, p_token1);
    END IF;
  
    IF p_token_name2 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name2, p_token2);
    END IF;
  
    IF p_token_name3 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name3, p_token3);
    END IF;
  
    IF p_token_name4 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name4, p_token4);
    END IF;
  
    IF p_token_name5 != miss_char
    THEN
      v_message := REPLACE(v_message, '%' || p_token_name5, p_token5);
    END IF;
  
    RETURN v_message;
  END;

  FUNCTION GET_MESSAGE
  (
    p_message_brief VARCHAR2
   ,p_lang_brief    VARCHAR2
   ,p_token_name1   VARCHAR2 DEFAULT miss_char
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token_name2   VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token_name3   VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token_name4   VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token_name5   VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2 IS
    v_lang_id NUMBER;
  BEGIN
    v_lang_id := get_lang_id(p_lang_brief);
    RETURN GET_MESSAGE(p_message_brief
                      ,v_lang_id
                      ,p_token_name1
                      ,p_token1
                      ,p_token_name2
                      ,p_token2
                      ,p_token_name3
                      ,p_token3
                      ,p_token_name4
                      ,p_token4
                      ,p_token_name5
                      ,p_token5);
  END;

  FUNCTION get_mes1
  (
    p_message_brief VARCHAR2
   ,p_lang_id       NUMBER DEFAULT Ents.get_lang_id
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2 IS
    v_lang_id    NUMBER;
    v_token_name VARCHAR(100);
    v_token      VARCHAR(1000);
    v_message    VARCHAR2(4000);
    start_pos    NUMBER;
    stop_pos     NUMBER;
    i            NUMBER := 1;
  BEGIN
    v_lang_id := p_lang_id;
  
    BEGIN
      SELECT NAME
        INTO v_message
        FROM SYS_MESSAGE
       WHERE lang_id = v_lang_id
         AND brief = p_message_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20100
                               ,'��������� ' || p_message_brief || ' ��� ����� � ID = ' || v_lang_id ||
                                ' �� �������');
    END;
  
    LOOP
      start_pos := INSTR(v_message, '%');
    
      IF start_pos != 0
      THEN
        stop_pos := INSTR(v_message, ' ', start_pos);
      
        IF stop_pos = 0
        THEN
          stop_pos := LENGTH(v_message);
        END IF;
      
        v_token_name := SUBSTR(v_message, start_pos, stop_pos - start_pos);
      
        IF i = 1
        THEN
          v_token := p_token1;
        ELSIF i = 2
        THEN
          v_token := p_token2;
        ELSIF i = 3
        THEN
          v_token := p_token3;
        ELSIF i = 4
        THEN
          v_token := p_token4;
        ELSIF i = 5
        THEN
          v_token := p_token5;
        ELSE
          RAISE_APPLICATION_ERROR(-20100
                                 ,'�������������� �� ����� 5 ���������� ���������');
        END IF;
      
        i         := i + 1;
        v_message := REPLACE(v_message, v_token_name, v_token);
      ELSE
        EXIT;
      END IF;
    END LOOP;
  
    RETURN v_message;
  END;

  FUNCTION get_mes
  (
    p_message_brief VARCHAR2
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN get_mes1(p_message_brief
                   ,Ents.get_lang_id
                   ,p_token1
                   ,p_token2
                   ,p_token3
                   ,p_token4
                   ,p_token5);
  END;

  PROCEDURE raise_err
  (
    p_message_brief VARCHAR2
   ,p_error_code    NUMBER
   ,p_text          VARCHAR2
   ,p_token1        VARCHAR2 DEFAULT miss_char
   ,p_token2        VARCHAR2 DEFAULT miss_char
   ,p_token3        VARCHAR2 DEFAULT miss_char
   ,p_token4        VARCHAR2 DEFAULT miss_char
   ,p_token5        VARCHAR2 DEFAULT miss_char
  ) IS
    v_err      VARCHAR2(4000) := NULL;
    v_err_code NUMBER := NVL(p_error_code, -20100);
  BEGIN
    IF is_empty(p_message_brief) = c_false
    THEN
      v_err := get_mes(p_message_brief, p_token1, p_token2, p_token3, p_token4, p_token5);
    END IF;
  
    IF is_empty(p_text) = c_false
    THEN
      IF v_err IS NULL
      THEN
        v_err := p_text;
      ELSE
        v_err := v_err || CHR(10) || p_text;
      END IF;
    END IF;
  
    RAISE_APPLICATION_ERROR(v_err_code, v_err);
  END;

  PROCEDURE raise_entity_err
  (
    p_error_code NUMBER
   ,p_text       VARCHAR2
   ,p_ent_id     IN NUMBER DEFAULT NULL
  ) IS
    v_err VARCHAR2(4000);
  BEGIN
    v_err := Ents.TRANS_ERR(p_error_code, p_text, p_ent_id);
    raise_err(NULL, -20000, v_err);
  END;

  FUNCTION is_empty(p_value NUMBER) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_num
    THEN
      RETURN c_true;
    END IF;
  
    RETURN c_false;
  END;

  FUNCTION is_empty(p_value VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_char
    THEN
      RETURN c_true;
    END IF;
  
    RETURN c_false;
  END;

  FUNCTION is_empty(p_value DATE) RETURN NUMBER IS
  BEGIN
    IF p_value IS NULL
       OR p_value = miss_date
    THEN
      RETURN c_true;
    END IF;
  
    RETURN c_false;
  END;

  PROCEDURE exec_immediate
  (
    p_sql IN VARCHAR2
   ,res   OUT NUMBER
  ) IS
  BEGIN
    EXECUTE IMMEDIATE p_sql;
  
    res := 1;
  EXCEPTION
    WHEN OTHERS THEN
      res := 0;
  END;

  -- �������� � ������ ��� ������� symb �� symbto (������� ��������� �������) � ������ ������  trim
  FUNCTION replaceall
  (
    str    IN VARCHAR2
   ,symb   IN VARCHAR2 DEFAULT ',,'
   ,symbto IN VARCHAR2 DEFAULT ','
   ,dotrim IN CHAR DEFAULT 'Y'
  ) RETURN VARCHAR2 IS
    TMP  VARCHAR2(4000);
    tmp1 VARCHAR2(4000);
  BEGIN
    DBMS_OUTPUT.PUT_LINE('str=' || str);
    IF str IS NOT NULL
       AND LENGTH(str) > 0
    THEN
      TMP := str;
    
      LOOP
        tmp1 := TMP;
        TMP  := REPLACE(TMP, symb, symbto);
        EXIT WHEN tmp1 = TMP;
      END LOOP;
    
      IF dotrim = 'Y'
      THEN
        IF LENGTH(str) > 0
        THEN
          TMP := TRIM(TMP);
          TMP := TRIM(symbto FROM TMP);
        END IF;
      END IF;
    
      RETURN TMP;
    ELSE
      RETURN '';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN '';
  END;
  /*IF (str <> '') and (str IS NOT NULL)
     THEN RETURN '2';
    ELSE
        tmp := str;
        DBMS_OUTPUT.put_line ('1');
  
        LOOP
           tmp1 := tmp;
           tmp := REPLACE (tmp, symb, symbto);
           EXIT WHEN tmp1 = tmp;
        END LOOP;
  
        IF dotrim = 'Y'
        THEN
           IF tmp <> ''
           THEN
              tmp := TRIM (tmp);
              tmp := TRIM (symbto FROM tmp);
           END IF;
        END IF;
  
        RETURN tmp;
     END IF;
  EXCEPTION
     WHEN OTHERS
     THEN
        RETURN '5';
  END;*/
  PROCEDURE cm IS
  BEGIN
    COMMIT;
  END;

  FUNCTION snp_case
  (
    -- �������� ����� ��� (Surname, Name and Patronymic in Case form)
    -- valerytin, hexcept@narod.ru, 2003-11-18
    p_fio   IN VARCHAR2
   , -- ������,���������� �������,��� � ��������
    p_padzh IN VARCHAR2
   , -- ����� (������ ������e): '�'|'�'-�����������,
    -- '�'|'�'-���������,etc., ���� �����:
    -- 1-������������, 2-�����������, 3-���������, etc. 
    p_fio_fmt IN VARCHAR2 DEFAULT '���'
   , -- ������ ������� ������-��� (�.�.
    -- '������� �����'->'��',
    -- '����� ������� ������-��������'->
    -- '���',etc.)
    p_sex IN VARCHAR2 DEFAULT NULL -- ��� '�'|'�'|'�'|'�'
  ) RETURN VARCHAR2 -- ����� � ������ ������
   IS
    l_pdzh_chr VARCHAR2(1);
    l_pdzh     PLS_INTEGER;
    l_sex      VARCHAR2(1) := SUBSTR(LTRIM(LOWER(p_sex)), 1, 1);
    l_tailchr  VARCHAR2(1);
    l_nmlen    NUMBER(2, 0);
    l_ul       VARCHAR2(1) := 'N';
    l_uf       VARCHAR2(1) := 'N';
    l_um       VARCHAR2(1) := 'N';
    l_name_s   VARCHAR2(80);
    l_name_n   VARCHAR2(80) := NULL;
    l_name_p   VARCHAR2(80) := NULL;
    l_fio      VARCHAR2(500);
    l_fname    VARCHAR2(80);
    l_mname    VARCHAR2(80);
    l_fullname VARCHAR2(500) := LTRIM(RTRIM(p_fio, ' -'), ' -');
    l_pos      PLS_INTEGER;
    l_fio_fmt  VARCHAR2(3) := NVL(UPPER(SUBSTR(LTRIM(p_fio_fmt), 1, 3)), '���');
    --
    FUNCTION single_space
    (
      p_data VARCHAR2
     ,p_dv   VARCHAR2 DEFAULT ' '
    ) RETURN VARCHAR2 IS
      v_str VARCHAR2(2000) := p_data;
    BEGIN
      WHILE INSTR(v_str, p_dv || p_dv) > 0
      LOOP
        v_str := REPLACE(v_str, p_dv || p_dv, p_dv);
      END LOOP;
      RETURN v_str;
    END single_space;
    --
    FUNCTION term_cmp
    (
      s IN VARCHAR2
     ,t IN VARCHAR2
    ) RETURN BOOLEAN IS
    BEGIN
      IF NVL(LENGTH(s), 0) < NVL(LENGTH(t), 0)
      THEN
        RETURN FALSE;
      END IF;
      IF SUBSTR(LOWER(s), -LENGTH(t)) = t
      THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END term_cmp;
    --
    PROCEDURE chng
    (
      s     IN OUT VARCHAR2
     ,n     IN NUMBER
     ,pzrod IN VARCHAR2
     ,pzdat IN VARCHAR2
     ,pzvin IN VARCHAR2
     ,pztvo IN VARCHAR2
     ,pzpre IN VARCHAR2
    ) IS
    BEGIN
      IF l_pdzh = 1
      THEN
        NULL;
      ELSE
        SELECT SUBSTR(s, 1, LENGTH(s) - n) ||
               DECODE(l_pdzh, 2, pzrod, 3, pzdat, 4, pzvin, 5, pztvo, 6, pzpre)
          INTO s
          FROM dual;
      END IF;
    END chng;
    --
    PROCEDURE prep
    (
      fnm  IN OUT VARCHAR2
     ,lfm2 IN OUT VARCHAR2
    ) IS
      pp VARCHAR2(1) := SUBSTR(lfm2, 1, 1);
      nm VARCHAR2(80);
    BEGIN
      l_pos := INSTR(fnm, ' ');
      IF l_pos > 0
      THEN
        nm    := SUBSTR(fnm, 1, l_pos - 1);
        fnm   := LTRIM(SUBSTR(fnm, l_pos + 1));
        l_pos := INSTR(fnm, ' ');
      ELSE
        nm  := fnm;
        fnm := NULL;
      END IF;
      IF pp = '�'
      THEN
        l_name_s := nm;
        lfm2     := REPLACE(lfm2, '�');
      ELSIF pp = '�'
      THEN
        l_fname := nm;
        lfm2    := REPLACE(lfm2, '�');
      ELSIF pp = '�'
      THEN
        l_mname := nm;
        lfm2    := REPLACE(lfm2, '�');
      END IF;
    END;
    --
  BEGIN
    -- snp_case()
    l_fullname := REPLACE(REPLACE(single_space(l_fullname), ' -', '-'), '- ', '-');
    IF l_fullname IS NULL
    THEN
      RETURN p_fio;
    END IF;
    IF SUBSTR(l_fio_fmt, 1, 1) NOT IN ('�', '�', '�')
    THEN
      RETURN p_fio;
    END IF;
    IF NVL(SUBSTR(l_fio_fmt, 2, 1), '�') NOT IN ('�', '�', '�')
    THEN
      RETURN p_fio;
    END IF;
    IF NVL(SUBSTR(l_fio_fmt, 3, 1), '�') NOT IN ('�', '�', '�')
    THEN
      RETURN p_fio;
    END IF;
    -- ����, ����:
    IF LOWER(LTRIM(RTRIM(l_fullname))) LIKE '%����%'
       AND LENGTH(l_fullname) > 4
    THEN
      l_name_p   := SUBSTR(l_fullname, INSTR(LOWER(l_fullname), '����'), 4);
      l_fullname := REPLACE(REPLACE(REPLACE(REPLACE(l_fullname, '����', NULL), '����', NULL)
                                   ,'����'
                                   ,NULL)
                           ,'  '
                           ,' ');
      l_sex      := NVL(l_sex, '�');
    ELSIF LOWER(LTRIM(RTRIM(l_fullname))) LIKE '%����%'
          AND LENGTH(l_fullname) > 4
    THEN
      l_name_p   := SUBSTR(l_fullname, INSTR(LOWER(l_fullname), '����'), 4);
      l_fullname := REPLACE(REPLACE(REPLACE(REPLACE(l_fullname, '����', NULL), '����', NULL)
                                   ,'����'
                                   ,NULL)
                           ,'  '
                           ,' ');
      l_sex      := NVL(l_sex, '�');
    END IF;
    LOOP
      IF l_fullname IS NOT NULL
      THEN
        prep(l_fullname, l_fio_fmt);
      ELSE
        EXIT;
      END IF;
    END LOOP;
    l_nmlen    := NVL(LENGTH(l_name_s), 0);
    l_pdzh_chr := UPPER(SUBSTR(p_padzh, 1, 1));
    SELECT DECODE(l_pdzh_chr, '�', 1, '�', 2, '�', 3, '�', 4, '�', 5, '�', 6, 0)
      INTO l_pdzh
      FROM dual;
    IF l_pdzh = 0
    THEN
      BEGIN
        l_pdzh := TO_NUMBER(l_pdzh_chr);
      EXCEPTION
        WHEN OTHERS THEN
          RETURN p_fio;
      END;
    END IF;
    IF NVL(l_sex, 'z') NOT IN ('�', '�')
    THEN
      -- ���� ��� �� ���������,
      -- �� ������� ���������� ��� �� ��������:
      IF l_mname IS NOT NULL
         AND (UPPER(SUBSTR(l_mname, -1)) = '�' OR LOWER(l_name_p) LIKE '����')
      THEN
        l_sex := '�';
      ELSE
        l_sex := '�';
      END IF;
    END IF;
    IF l_name_s IS NOT NULL
    THEN
      -- �������
      IF UPPER(l_name_s) = l_name_s
      THEN
        l_ul := 'Y';
      END IF;
      -- ������������ ��������� ��������� �������:
      IF INSTR(l_name_s, '-') > 0
         AND LOWER(l_name_s) NOT LIKE '���-%'
      THEN
        l_name_n := SUBSTR(l_name_s, 1, INSTR(l_name_s, '-') - 1) || ' ' || l_fname || ' ' || l_mname;
        l_fio    := snp_case(l_name_n, p_padzh, '���', l_sex);
        l_name_n := SUBSTR(l_fio, 1, INSTR(l_fio, ' ') - 1) || '-';
        l_name_s := SUBSTR(l_name_s, INSTR(l_name_s, '-') + 1);
      END IF;
      l_tailchr := LOWER(SUBSTR(l_name_s, -1));
      IF l_sex = '�'
      THEN
        -- �������
        IF l_tailchr NOT IN ('�', '�', '�', '�', '�', '�', '�')
        THEN
          IF l_tailchr = '�'
          THEN
            chng(l_name_s, 0, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
                AND term_cmp(l_name_s, '��')
          THEN
            chng(l_name_s, 0, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
                AND term_cmp(l_name_s, '��')
          THEN
            IF l_nmlen > 3
               AND SUBSTR(l_name_s, -3) IN ('���', '���', '���', '���', '���')
            THEN
              chng(l_name_s, 2, '���', '���', '���', '����', '���');
            ELSIF l_nmlen > 3
                  AND LOWER(SUBSTR(l_name_s, -3)) IN
                  ('���', '���', '���', '���', '���', '���', '���')
                  AND LOWER(SUBSTR(l_name_s, -4, 1)) IN
                  ('�', '�', '�', '�', '�', '�', '�', '�', '�', '�')
            THEN
              chng(l_name_s, 2, '��', '��', '��', '���', '��');
            ELSIF l_nmlen > 3
                  AND LOWER(SUBSTR(l_name_s, -3)) = '���'
            THEN
              chng(l_name_s, 2, '���', '���', '���', '����', '���');
            ELSE
              chng(l_name_s, 0, '�', '�', '�', '��', '�');
            END IF;
          ELSIF l_tailchr = '�'
                AND (term_cmp(l_name_s, '��') OR term_cmp(l_name_s, '��'))
          THEN
            chng(l_name_s, 0, NULL, NULL, NULL, NULL, NULL);
          ELSIF l_tailchr IN ('�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�')
          THEN
            chng(l_name_s, 0, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
                AND NOT (term_cmp(l_name_s, '��') OR term_cmp(l_name_s, '��'))
          THEN
            chng(l_name_s, 1, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
                AND NOT (term_cmp(l_name_s, '��') OR term_cmp(l_name_s, '��'))
          THEN
            chng(l_name_s, 1, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
          THEN
            chng(l_name_s, 1, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
          THEN
            IF l_nmlen > 4
               AND term_cmp(l_name_s, '��')
            THEN
              chng(l_name_s, 2, '��', '��', '��', '���', '��');
            ELSIF l_nmlen > 4
                  AND (term_cmp(l_name_s, '���') OR term_cmp(l_name_s, '���'))
            THEN
              chng(l_name_s, 2, '���', '���', '���', '����', '���');
            ELSE
              chng(l_name_s, 0, '�', '�', '�', '��', '�');
            END IF;
          ELSIF l_tailchr = '�'
          THEN
            IF l_nmlen > 4
            THEN
              IF (term_cmp(l_name_s, '���') OR term_cmp(l_name_s, '���'))
              THEN
                chng(l_name_s, 2, '���', '���', '���', '��', '��');
              ELSIF term_cmp(l_name_s, '��')
              THEN
                chng(l_name_s, 2, '���', '���', '���', '��', '��');
              ELSIF term_cmp(l_name_s, '��')
              THEN
                chng(l_name_s, 2, '���', '���', '���', '��', '��');
              ELSIF LOWER(SUBSTR(l_name_s, -3)) IN ('���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���'
                                                   ,'���')
              THEN
                chng(l_name_s, 1, '�', '�', '�', '��', '�');
              ELSIF term_cmp(l_name_s, '��')
              THEN
                chng(l_name_s, 2, '���', '���', '���', '��', '��');
              ELSE
                chng(l_name_s, 1, '�', '�', '�', '��', '�');
              END IF;
            ELSE
              chng(l_name_s, 1, '�', '�', '�', '��', '�');
            END IF;
          END IF;
        END IF;
      ELSIF l_sex = '�'
      THEN
        -- �������
        IF LOWER(SUBSTR(l_name_s, -3)) IN ('���', '���', '���', '���', '���')
        THEN
          chng(l_name_s, 1, '��', '��', '�', '��', '��');
        ELSIF term_cmp(l_name_s, '��')
              AND LOWER(SUBSTR(l_name_s, -3, 1)) IN ('�')
        THEN
          chng(l_name_s, 2, '��', '��', '��', '��', '��');
        ELSIF term_cmp(l_name_s, '��')
        THEN
          chng(l_name_s, 2, '��', '��', '��', '��', '��');
        ELSIF term_cmp(l_name_s, '��')
              OR term_cmp(l_name_s, '��')
        THEN
          chng(l_name_s, 1, '�', '�', '�', '��', '�');
        ELSIF term_cmp(l_name_s, '�')
              AND LOWER(SUBSTR(l_name_s, -2, 1)) IN ('�')
        THEN
          chng(l_name_s, 1, '�', '�', '�', '��', '�');
        END IF;
      END IF;
    END IF;
    IF l_fname IS NOT NULL
    THEN
      -- ���
      IF UPPER(l_fname) = l_fname
      THEN
        l_uf := 'Y';
      END IF;
      l_tailchr := LOWER(SUBSTR(l_fname, -1));
      IF l_sex = '�'
      THEN
        -- �������
        IF l_tailchr NOT IN ('�', '�', '�')
        THEN
          IF UPPER(l_fname) = '���'
          THEN
            chng(l_fname, 2, '���', '���', '���', '����', '���');
          ELSIF l_tailchr IN ('�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�'
                             ,'�')
          THEN
            chng(l_fname, 0, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
          THEN
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
          THEN
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
          THEN
            IF term_cmp(l_fname, '��')
            THEN
              chng(l_fname, 1, '�', '�', '�', '��', '�');
            ELSIF term_cmp(l_fname, '��')
            THEN
              chng(l_fname, 1, '�', '�', '�', '��', '�');
            ELSE
              chng(l_fname, 1, '�', '�', '�', '��', '�');
            END IF;
          ELSIF l_tailchr = '�'
          THEN
            IF term_cmp(l_fname, '��')
            THEN
              chng(l_fname, 1, '�', '�', '�', '��', '�');
            ELSE
              IF term_cmp(l_fname, '��')
              THEN
                chng(l_fname, 1, '�', '�', '�', '��', '�');
              ELSE
                chng(l_fname, 1, '�', '�', '�', '��', '�');
              END IF;
            END IF;
          ELSIF l_tailchr = '�'
          THEN
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          ELSIF l_tailchr = '�'
          THEN
            IF term_cmp(l_fname, '����')
            THEN
              chng(l_fname, 2, '��', '��', '��', '���', '��');
            ELSE
              chng(l_fname, 0, '�', '�', '�', '��', '�');
            END IF;
          END IF;
        END IF;
      ELSIF l_sex = '�'
      THEN
        -- �������
        IF l_tailchr = '�'
           AND NVL(LENGTH(l_fname), 0) > 1
        THEN
          IF LOWER(SUBSTR(l_fname, -2)) IN ('��', '��', '��', '��', '��', '��', '��')
          THEN
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          ELSE
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          END IF;
        ELSIF l_tailchr = '�'
              AND NVL(LENGTH(l_fname), 0) > 1
        THEN
          IF term_cmp(l_fname, '��')
             AND LOWER(SUBSTR(l_fname, -4)) IN ('����')
          THEN
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          ELSIF term_cmp(l_fname, '��')
          THEN
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          ELSE
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          END IF;
        ELSIF l_tailchr = '�'
        THEN
          IF term_cmp(l_fname, '��')
          THEN
            chng(l_fname, 1, '�', '�', '�', '��', '�');
          ELSE
            chng(l_fname, 1, '�', '�', '�', '��', '��');
          END IF;
        END IF;
      END IF;
    END IF;
    IF l_mname IS NOT NULL
    THEN
      -- ��������
      IF UPPER(l_mname) = l_mname
      THEN
        l_um := 'Y';
      END IF;
      l_tailchr := LOWER(SUBSTR(l_mname, -1));
      IF l_sex = '�'
      THEN
        -- �������
        IF l_tailchr = '�'
        THEN
          chng(l_mname, 0, '�', '�', '�', '��', '�');
        END IF;
      ELSIF l_sex = '�'
      THEN
        -- �������
        IF l_tailchr = '�'
           AND LENGTH(l_mname) <> 1
        THEN
          chng(l_mname, 1, '�', '�', '�', '��', '�');
        END IF;
      END IF;
    END IF;
    -- ������������� ������������
    l_fio_fmt := NVL(UPPER(SUBSTR(LTRIM(p_fio_fmt), 1, 3)), '���'); -- �.�. ��������...
    l_pos     := 1;
    LOOP
      IF l_pos > 1
      THEN
        l_fullname := l_fullname || ' ';
      END IF;
      SELECT l_fullname ||
             DECODE(SUBSTR(l_fio_fmt, l_pos, 1)
                   ,'�'
                   ,DECODE(l_ul, 'Y', UPPER(l_name_n || l_name_s), l_name_n || l_name_s)
                   ,'�'
                   ,DECODE(l_uf, 'Y', UPPER(l_fname), l_fname)
                   ,'�'
                   ,DECODE(l_um
                          ,'Y'
                          ,UPPER(REPLACE(REPLACE(l_mname, '����', NULL), '����', NULL) ||
                                 DECODE(INSTR(l_mname, '-'), 0, ' ', NULL) || l_name_p)
                          ,REPLACE(REPLACE(l_mname, '����', NULL), '����', NULL) ||
                           DECODE(INSTR(l_mname, '-'), 0, ' ', NULL) || l_name_p))
        INTO l_fullname
        FROM dual;
      l_pos := l_pos + 1;
      IF l_pos > NVL(LENGTH(l_fio_fmt), 0)
      THEN
        EXIT;
      END IF;
    END LOOP;
    RETURN NVL(LTRIM(RTRIM(l_fullname, ' -'), ' -'), LTRIM(RTRIM(single_space(p_fio), ' -'), ' -'));
  END snp_case;

  FUNCTION date2speach
  (
    for_convert     DATE
   ,question_suffix NUMBER DEFAULT 2
  ) RETURN VARCHAR2 IS
    TYPE date_root_t IS TABLE OF VARCHAR2(30) INDEX BY PLS_INTEGER;
  
    date_root_v    date_root_t;
    converted_date VARCHAR2(100);
    day_num        PLS_INTEGER;
    day_simple     PLS_INTEGER;
    millenium      PLS_INTEGER;
    year_num       PLS_INTEGER;
    year_simple    PLS_INTEGER;
    suffix_day     VARCHAR2(5);
    third_day      VARCHAR2(10);
    suffix_year    VARCHAR2(5);
    third_year     VARCHAR2(10);
  
    FUNCTION two_dig_to_str
    (
      full_dig   PLS_INTEGER
     ,simple_dig PLS_INTEGER
     ,is_day     BOOLEAN
    ) RETURN VARCHAR2 IS
      converted_dig VARCHAR2(50) DEFAULT '';
      suffix        VARCHAR2(5);
      third         VARCHAR2(10);
    BEGIN
      IF is_day
      THEN
        suffix := suffix_day;
        third  := third_day;
      ELSE
        suffix := suffix_year;
        third  := third_year;
      END IF;
    
      IF full_dig < 20
      THEN
        CASE
          WHEN simple_dig = 3
               AND full_dig <> 13 THEN
            converted_dig := converted_dig || third;
          ELSE
            converted_dig := date_root_v(full_dig) || suffix;
        END CASE;
      ELSE
        IF simple_dig <> 0
        THEN
          converted_dig := date_root_v(TRUNC(full_dig, -1)) || ' ';
        
          IF simple_dig = 3
          THEN
            converted_dig := converted_dig || third;
          ELSE
            converted_dig := converted_dig || date_root_v(simple_dig) || suffix;
          END IF;
        ELSE
          converted_dig := converted_dig || date_root_v(-full_dig) || suffix;
        END IF;
      END IF;
    
      RETURN converted_dig;
    END two_dig_to_str;
  BEGIN
    -- �������������� ������������ �������
    date_root_v(0) := '';
    date_root_v(1) := '����';
    date_root_v(2) := '����';
    date_root_v(3) := '����';
    date_root_v(4) := '������';
    date_root_v(5) := '���';
    date_root_v(6) := '����';
    date_root_v(7) := '�����';
    date_root_v(8) := '�����';
    date_root_v(9) := '�����';
    date_root_v(10) := '�����';
    date_root_v(11) := '����������';
    date_root_v(12) := '���������';
    date_root_v(13) := '���������';
    date_root_v(14) := '�����������';
    date_root_v(15) := '���������';
    date_root_v(16) := '����������';
    date_root_v(17) := '���������';
    date_root_v(18) := '�����������';
    date_root_v(19) := '�����������';
    date_root_v(20) := '��������';
    date_root_v(30) := '��������';
    date_root_v(40) := 'c����';
    date_root_v(50) := '���������';
    date_root_v(60) := '����������';
    date_root_v(70) := '���������';
    date_root_v(80) := '�����������';
    date_root_v(90) := '���������';
    date_root_v(-20) := '�������';
    date_root_v(-30) := '�������';
    date_root_v(-40) := '�������';
    date_root_v(-50) := '���������';
    date_root_v(-60) := '����������';
    date_root_v(-70) := '���������';
    date_root_v(-80) := '�����������';
    date_root_v(-90) := '��������';
  
    CASE question_suffix
      WHEN 1 THEN
        suffix_day := '�� ';
        third_day  := '������ ';
      WHEN 2 THEN
        suffix_day := '��� ';
        third_day  := '�������� ';
      ELSE
        RAISE NO_DATA_FOUND;
    END CASE;
  
    suffix_year := '��� ';
    third_year  := '�������� ';
    --����
    day_num        := TO_NUMBER(EXTRACT(DAY FROM for_convert));
    day_simple     := MOD(day_num, 10);
    converted_date := two_dig_to_str(day_num, day_simple, TRUE);
  
    --�����
    CASE TO_NUMBER(EXTRACT(MONTH FROM for_convert))
      WHEN 1 THEN
        converted_date := converted_date || '������';
      WHEN 2 THEN
        converted_date := converted_date || '�������';
      WHEN 3 THEN
        converted_date := converted_date || '�����';
      WHEN 4 THEN
        converted_date := converted_date || '������';
      WHEN 5 THEN
        converted_date := converted_date || '���';
      WHEN 6 THEN
        converted_date := converted_date || '����';
      WHEN 7 THEN
        converted_date := converted_date || '����';
      WHEN 8 THEN
        converted_date := converted_date || '�������';
      WHEN 9 THEN
        converted_date := converted_date || '��������';
      WHEN 10 THEN
        converted_date := converted_date || '�������';
      WHEN 11 THEN
        converted_date := converted_date || '������';
      WHEN 12 THEN
        converted_date := converted_date || '�������';
      ELSE
        converted_date := converted_date;
    END CASE;
    -- ����������� 
    millenium   := TRUNC(TO_NUMBER(EXTRACT(YEAR FROM for_convert)) / 1000);
    year_num    := MOD(MOD(TO_NUMBER(EXTRACT(YEAR FROM for_convert)), 1000), 100);
    year_simple := MOD(year_num, 10);
  
    CASE millenium
      WHEN 1 THEN
        converted_date := converted_date || ' ���� ������ ��������� ';
      WHEN 2 THEN
        converted_date := converted_date || ' ��� ������  ';
      ELSE
        converted_date := converted_date;
    END CASE;
    -- ��� 
    converted_date := converted_date || two_dig_to_str(year_num, year_simple, FALSE);
    RETURN converted_date;
  
  END date2speach;
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  FUNCTION get_count_days
  (
    p_start_date DATE
   ,p_end_date   DATE DEFAULT NULL
  ) RETURN NUMBER IS
    v_bd    DATE;
    v_ed    DATE;
    v_count NUMBER;
    v_year  VARCHAR2(4);
  BEGIN
    v_count := 0;
    v_bd    := TRUNC(p_start_date);
    IF p_end_date IS NOT NULL
    THEN
      v_ed := TRUNC(p_end_date);
    ELSE
      --������ ���� ����� ������� ����� ���
    
      v_ed := v_bd + 365;
    
      v_year := TO_CHAR(v_bd, 'yyyy');
    
      IF MOD(TO_NUMBER(v_year), 4) = 0
      THEN
        -- ���������� ���
        IF TO_DATE('2902' || v_year, 'ddmmyyyy') >= v_bd
        THEN
          v_ed := v_ed + 1;
        END IF;
      END IF;
    
      v_year := TO_CHAR(v_ed, 'yyyy');
    
      IF MOD(TO_NUMBER(v_year), 4) = 0
      THEN
        -- ���������� ���
        IF TO_DATE('2902' || v_year, 'ddmmyyyy') <= v_ed
        THEN
          v_ed := v_ed + 1;
        END IF;
      END IF;
    
    END IF;
  
    BEGIN
      v_count := v_ed - v_bd;
    EXCEPTION
      WHEN OTHERS THEN
        v_count := 0;
    END;
  
    RETURN v_count;
  
  END;

  PROCEDURE sleep(p_delay NUMBER) IS
  BEGIN
    dbms_lock.sleep(p_delay);
  END;

END;
/
