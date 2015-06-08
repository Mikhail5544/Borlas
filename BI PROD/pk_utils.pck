CREATE OR REPLACE PACKAGE pk_utils IS

  -- Внимание! Устарело

  FUNCTION int2speech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2;
  FUNCTION float2speech
  (
    VALUE IN NUMBER
   ,sex   IN VARCHAR2
   ,power IN INTEGER
  ) RETURN VARCHAR2;
  FUNCTION inttospeech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2;
  --Сумма в валюте прописью
  FUNCTION money2speech
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2;
  --Дата в родительном падеже
  FUNCTION date2genitive_case(p_date DATE) RETURN VARCHAR2;
  --Разобрать ФИО на составные части
  PROCEDURE fio2full_name
  (
    p_fio         IN VARCHAR2
   ,p_last_name   OUT VARCHAR2
   ,p_first_name  OUT VARCHAR2
   ,p_middle_name OUT VARCHAR2
  );

END pk_utils;
/
CREATE OR REPLACE PACKAGE BODY "PK_UTILS" IS

  -- Внимание! Устарело

  FUNCTION int2speech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_utils.int2speech(dig, sex);
  END;

  FUNCTION float2speech
  (
    VALUE IN NUMBER
   ,sex   IN VARCHAR2
   ,power IN INTEGER
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_utils.float2speech(VALUE, sex, power);
  END;

  FUNCTION inttospeech
  (
    dig IN NUMBER
   ,sex IN VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_utils.inttospeech(dig, sex);
  END;

  FUNCTION money2speech
  (
    quant     IN NUMBER
   ,p_fund_id IN NUMBER
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_utils.money2speech(quant, p_fund_id);
  END;

  FUNCTION date2genitive_case(p_date DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN pkg_utils.date2genitive_case(p_date);
  END;

  PROCEDURE fio2full_name
  (
    p_fio         IN VARCHAR2
   ,p_last_name   OUT VARCHAR2
   ,p_first_name  OUT VARCHAR2
   ,p_middle_name OUT VARCHAR2
  ) IS
  BEGIN
    pkg_utils.fio2full_name(p_fio, p_last_name, p_first_name, p_middle_name);
  END;

END pk_utils;
/
