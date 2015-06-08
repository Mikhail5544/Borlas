CREATE OR REPLACE PACKAGE dml_fund IS

  FUNCTION get_id_by_brief
  (
    par_brief IN FUND.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN fund.fund_id%TYPE;

  FUNCTION get_record(par_fund_id IN FUND.fund_id%TYPE)
    RETURN fund%ROWTYPE;

  PROCEDURE insert_record
  (
    par_name              IN FUND.name%TYPE
   ,par_brief             IN FUND.brief%TYPE
   ,par_code              IN FUND.code%TYPE
   ,par_is_active         IN FUND.is_active%TYPE DEFAULT 0
   ,par_add_code          IN FUND.add_code%TYPE DEFAULT NULL
   ,par_precision         IN FUND.precision%TYPE DEFAULT NULL
   ,par_rate_qty          IN FUND.rate_qty%TYPE DEFAULT NULL
   ,par_spell_1_whole     IN FUND.spell_1_whole%TYPE DEFAULT NULL
   ,par_spell_2_whole     IN FUND.spell_2_whole%TYPE DEFAULT NULL
   ,par_spell_5_whole     IN FUND.spell_5_whole%TYPE DEFAULT NULL
   ,par_spell_1_fract     IN FUND.spell_1_fract%TYPE DEFAULT NULL
   ,par_spell_2_fract     IN FUND.spell_2_fract%TYPE DEFAULT NULL
   ,par_spell_5_fract     IN FUND.spell_5_fract%TYPE DEFAULT NULL
   ,par_spell_short_whole IN FUND.spell_short_whole%TYPE DEFAULT NULL
   ,par_spell_short_fract IN FUND.spell_short_fract%TYPE DEFAULT NULL
   ,par_default_rate      IN FUND.default_rate%TYPE DEFAULT NULL
  );

  PROCEDURE insert_record(par_record IN OUT fund%ROWTYPE);

  PROCEDURE insert_record
  (
    par_name              IN FUND.name%TYPE
   ,par_brief             IN FUND.brief%TYPE
   ,par_code              IN FUND.code%TYPE
   ,par_is_active         IN FUND.is_active%TYPE DEFAULT 0
   ,par_add_code          IN FUND.add_code%TYPE DEFAULT NULL
   ,par_precision         IN FUND.precision%TYPE DEFAULT NULL
   ,par_rate_qty          IN FUND.rate_qty%TYPE DEFAULT NULL
   ,par_spell_1_whole     IN FUND.spell_1_whole%TYPE DEFAULT NULL
   ,par_spell_2_whole     IN FUND.spell_2_whole%TYPE DEFAULT NULL
   ,par_spell_5_whole     IN FUND.spell_5_whole%TYPE DEFAULT NULL
   ,par_spell_1_fract     IN FUND.spell_1_fract%TYPE DEFAULT NULL
   ,par_spell_2_fract     IN FUND.spell_2_fract%TYPE DEFAULT NULL
   ,par_spell_5_fract     IN FUND.spell_5_fract%TYPE DEFAULT NULL
   ,par_spell_short_whole IN FUND.spell_short_whole%TYPE DEFAULT NULL
   ,par_spell_short_fract IN FUND.spell_short_fract%TYPE DEFAULT NULL
   ,par_default_rate      IN FUND.default_rate%TYPE DEFAULT NULL
   ,par_fund_id           OUT FUND.fund_id%TYPE
  );

  PROCEDURE update_record
  (
   par_record IN fund%ROWTYPE
  );

  PROCEDURE delete_record
  (
    par_fund_id IN FUND.fund_id%TYPE
  );
END dml_fund;
/
CREATE OR REPLACE PACKAGE BODY dml_fund IS

  FUNCTION get_id_by_brief
  (
    par_brief IN FUND.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN fund.fund_id%TYPE  IS
    v_id fund.fund_id%TYPE;
  BEGIN
    BEGIN
      SELECT fund_id INTO v_id FROM fund WHERE brief = par_brief;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF par_raise_on_error
        THEN
          ex.raise('Не найдена запись в таблице "Валюта" по значению поля "Сокращение валюты": ' ||
                   par_brief);
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_fund_id IN FUND.fund_id%TYPE)
    RETURN fund%ROWTYPE IS
    vr_record fund%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM fund WHERE fund_id = par_fund_id;
    RETURN vr_record;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_name              IN FUND.name%TYPE
   ,par_brief             IN FUND.brief%TYPE
   ,par_code              IN FUND.code%TYPE
   ,par_is_active         IN FUND.is_active%TYPE DEFAULT 0
   ,par_add_code          IN FUND.add_code%TYPE DEFAULT NULL
   ,par_precision         IN FUND.precision%TYPE DEFAULT NULL
   ,par_rate_qty          IN FUND.rate_qty%TYPE DEFAULT NULL
   ,par_spell_1_whole     IN FUND.spell_1_whole%TYPE DEFAULT NULL
   ,par_spell_2_whole     IN FUND.spell_2_whole%TYPE DEFAULT NULL
   ,par_spell_5_whole     IN FUND.spell_5_whole%TYPE DEFAULT NULL
   ,par_spell_1_fract     IN FUND.spell_1_fract%TYPE DEFAULT NULL
   ,par_spell_2_fract     IN FUND.spell_2_fract%TYPE DEFAULT NULL
   ,par_spell_5_fract     IN FUND.spell_5_fract%TYPE DEFAULT NULL
   ,par_spell_short_whole IN FUND.spell_short_whole%TYPE DEFAULT NULL
   ,par_spell_short_fract IN FUND.spell_short_fract%TYPE DEFAULT NULL
   ,par_default_rate      IN FUND.default_rate%TYPE DEFAULT NULL
  ) IS
    v_id fund.fund_id%TYPE;
  BEGIN
    insert_record(par_name => par_name
                 ,par_brief => par_brief
                 ,par_code => par_code
                 ,par_is_active => par_is_active
                 ,par_add_code => par_add_code
                 ,par_precision => par_precision
                 ,par_rate_qty => par_rate_qty
                 ,par_spell_1_whole => par_spell_1_whole
                 ,par_spell_2_whole => par_spell_2_whole
                 ,par_spell_5_whole => par_spell_5_whole
                 ,par_spell_1_fract => par_spell_1_fract
                 ,par_spell_2_fract => par_spell_2_fract
                 ,par_spell_5_fract => par_spell_5_fract
                 ,par_spell_short_whole => par_spell_short_whole
                 ,par_spell_short_fract => par_spell_short_fract
                 ,par_default_rate => par_default_rate
                 ,par_fund_id => v_id);

  END insert_record;

  PROCEDURE insert_record(par_record IN OUT fund%ROWTYPE) IS
  BEGIN
    insert_record(par_name => par_record.name
                 ,par_brief => par_record.brief
                 ,par_code => par_record.code
                 ,par_is_active => par_record.is_active
                 ,par_add_code => par_record.add_code
                 ,par_precision => par_record.precision
                 ,par_rate_qty => par_record.rate_qty
                 ,par_spell_1_whole => par_record.spell_1_whole
                 ,par_spell_2_whole => par_record.spell_2_whole
                 ,par_spell_5_whole => par_record.spell_5_whole
                 ,par_spell_1_fract => par_record.spell_1_fract
                 ,par_spell_2_fract => par_record.spell_2_fract
                 ,par_spell_5_fract => par_record.spell_5_fract
                 ,par_spell_short_whole => par_record.spell_short_whole
                 ,par_spell_short_fract => par_record.spell_short_fract
                 ,par_default_rate => par_record.default_rate
                 ,par_fund_id => par_record.fund_id);

  END insert_record;

  PROCEDURE insert_record
  (
    par_name              IN FUND.name%TYPE
   ,par_brief             IN FUND.brief%TYPE
   ,par_code              IN FUND.code%TYPE
   ,par_is_active         IN FUND.is_active%TYPE DEFAULT 0
   ,par_add_code          IN FUND.add_code%TYPE DEFAULT NULL
   ,par_precision         IN FUND.precision%TYPE DEFAULT NULL
   ,par_rate_qty          IN FUND.rate_qty%TYPE DEFAULT NULL
   ,par_spell_1_whole     IN FUND.spell_1_whole%TYPE DEFAULT NULL
   ,par_spell_2_whole     IN FUND.spell_2_whole%TYPE DEFAULT NULL
   ,par_spell_5_whole     IN FUND.spell_5_whole%TYPE DEFAULT NULL
   ,par_spell_1_fract     IN FUND.spell_1_fract%TYPE DEFAULT NULL
   ,par_spell_2_fract     IN FUND.spell_2_fract%TYPE DEFAULT NULL
   ,par_spell_5_fract     IN FUND.spell_5_fract%TYPE DEFAULT NULL
   ,par_spell_short_whole IN FUND.spell_short_whole%TYPE DEFAULT NULL
   ,par_spell_short_fract IN FUND.spell_short_fract%TYPE DEFAULT NULL
   ,par_default_rate      IN FUND.default_rate%TYPE DEFAULT NULL
   ,par_fund_id           OUT FUND.fund_id%TYPE
  ) IS
  BEGIN
    SELECT sq_fund.nextval INTO par_fund_id FROM dual;
    INSERT INTO fund
      (fund_id
      ,spell_2_fract
      ,is_active
      ,spell_short_whole
      ,spell_short_fract
      ,name
      ,brief
      ,code
      ,add_code
      ,precision
      ,rate_qty
      ,spell_1_whole
      ,spell_2_whole
      ,spell_5_whole
      ,spell_1_fract
      ,default_rate
      ,spell_5_fract)
    VALUES
      (par_fund_id
      ,par_spell_2_fract
      ,par_is_active
      ,par_spell_short_whole
      ,par_spell_short_fract
      ,par_name
      ,par_brief
      ,par_code
      ,par_add_code
      ,par_precision
      ,par_rate_qty
      ,par_spell_1_whole
      ,par_spell_2_whole
      ,par_spell_5_whole
      ,par_spell_1_fract
      ,par_default_rate
      ,par_spell_5_fract);
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END insert_record;

  PROCEDURE update_record
  (
   par_record IN fund%ROWTYPE
  ) IS
  BEGIN
    UPDATE fund
      SET default_rate = par_record.default_rate
         ,spell_5_fract = par_record.spell_5_fract
         ,is_active = par_record.is_active
         ,spell_short_whole = par_record.spell_short_whole
         ,spell_short_fract = par_record.spell_short_fract
         ,name = par_record.name
         ,brief = par_record.brief
         ,code = par_record.code
         ,add_code = par_record.add_code
         ,precision = par_record.precision
         ,rate_qty = par_record.rate_qty
         ,spell_1_whole = par_record.spell_1_whole
         ,spell_2_whole = par_record.spell_2_whole
         ,spell_5_whole = par_record.spell_5_whole
         ,spell_1_fract = par_record.spell_1_fract
         ,spell_2_fract = par_record.spell_2_fract
    WHERE fund_id = par_record.fund_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END update_record;

  PROCEDURE delete_record
  (
    par_fund_id IN FUND.fund_id%TYPE
  ) IS
  BEGIN
    DELETE FROM fund
          WHERE fund_id = par_fund_id;
  EXCEPTION
    WHEN OTHERS THEN
      ex.raise;
  END delete_record;
END dml_fund;
/
