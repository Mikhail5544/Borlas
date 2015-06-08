CREATE OR REPLACE PACKAGE PKG_XX_POL_IDS IS
  FUNCTION is_ids_correct(p_ids NUMBER) RETURN BOOLEAN;

  FUNCTION get_checksum(p_ids NUMBER) RETURN NUMBER;

  FUNCTION fill_checksum4ids(p_ids NUMBER) RETURN NUMBER;

  FUNCTION cre_new_ids
  (
    p_ser      VARCHAR2
   ,p_note_ser VARCHAR2
  ) RETURN NUMBER;

END PKG_XX_POL_IDS;
/
CREATE OR REPLACE PACKAGE BODY PKG_XX_POL_IDS IS
  --Проверка уникального идентификатора на корректность контрольного числа
  FUNCTION is_ids_correct(p_ids NUMBER) RETURN BOOLEAN IS
  BEGIN
    RETURN p_ids = fill_checksum4ids(p_ids);
  END is_ids_correct;

  --Вычисление контрольной суммы для уникального идентификатора (предполагается YYYYYYYYYS)
  FUNCTION get_checksum(p_ids NUMBER) RETURN NUMBER IS
    v_checksum NUMBER(10) := 0;
  BEGIN
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 1, 1)) * 2;
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 2, 1)) * 4;
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 3, 1)) * 10;
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 4, 1)) * 3;
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 5, 1)) * 5;
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 6, 1)) * 9;
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 7, 1)) * 4;
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 8, 1)) * 6;
    v_checksum := v_checksum + TO_NUMBER(SUBSTR(p_ids, 9, 1)) * 8;
    v_checksum := MOD(v_checksum, 11);
    v_checksum := MOD(v_checksum, 10);
    RETURN v_checksum;
  END get_checksum;

  --Заполнение у данного уникального идентификатора контрольного числа (предполагается YYYYYYYYY_)
  FUNCTION fill_checksum4ids(p_ids NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN TRUNC(p_ids, -1) + get_checksum(p_ids);
  END fill_checksum4ids;

  --Формирование уникального идентификатора по числовой серии БСО и серии заявления (предполагается XXX YYYYYY)
  FUNCTION cre_new_ids
  (
    p_ser      VARCHAR2
   ,p_note_ser VARCHAR2
  ) RETURN NUMBER IS
    v_ids      NUMBER;
    v_ser      NUMBER;
    v_note_ser NUMBER;
  
    FUNCTION num2str
    (
      p_num NUMBER
     ,p_c   NUMBER
    ) RETURN VARCHAR2 IS
    BEGIN
      RETURN TRIM(TO_CHAR(TRUNC(p_num) - TRUNC(p_num, -p_c), LPAD('0', p_c, '0')));
    END num2str;
  BEGIN
    BEGIN
      v_ser      := p_ser;
      v_note_ser := p_note_ser;
    EXCEPTION
      WHEN OTHERS THEN
        --Если приведение невозможно, то просто вернуть null
        RETURN TO_NUMBER(NULL);
    END;
  
    RETURN fill_checksum4ids(num2str(v_ser, 3) || num2str(v_note_ser, 6) || '0');
  END cre_new_ids;
END PKG_XX_POL_IDS;
/
