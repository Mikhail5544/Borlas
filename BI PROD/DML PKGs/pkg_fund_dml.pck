CREATE OR REPLACE PACKAGE pkg_fund_dml IS

  /* Процедурры получения данных из таблицы */
  FUNCTION get_record(par_fund_id IN fund.fund_id%TYPE) RETURN fund%ROWTYPE;
  FUNCTION get_record_by_brief(par_fund_brief IN fund.brief%TYPE) RETURN fund%ROWTYPE;
  FUNCTION get_id_by_brief(par_fund_brief IN fund.brief%TYPE) RETURN fund.fund_id%TYPE;

  /* DML */
  PROCEDURE insert_record
  (
    par_brief             IN fund.brief%TYPE
   ,par_name              IN fund.name%TYPE
   ,par_code              IN fund.code%TYPE
   ,par_is_active         IN fund.is_active%TYPE DEFAULT 0
   ,par_spell_short_fract IN fund.spell_short_fract%TYPE DEFAULT NULL
   ,par_spell_short_whole IN fund.spell_short_whole%TYPE DEFAULT NULL
   ,par_spell_2_fract     IN fund.spell_2_fract%TYPE DEFAULT NULL
   ,par_default_rate      IN fund.default_rate%TYPE DEFAULT NULL
   ,par_spell_5_fract     IN fund.spell_5_fract%TYPE DEFAULT NULL
   ,par_add_code          IN fund.add_code%TYPE DEFAULT NULL
   ,par_precision         IN fund.precision%TYPE DEFAULT NULL
   ,par_rate_qty          IN fund.rate_qty%TYPE DEFAULT NULL
   ,par_spell_1_whole     IN fund.spell_1_whole%TYPE DEFAULT NULL
   ,par_spell_2_whole     IN fund.spell_2_whole%TYPE DEFAULT NULL
   ,par_spell_5_whole     IN fund.spell_5_whole%TYPE DEFAULT NULL
   ,par_spell_1_fract     IN fund.spell_1_fract%TYPE DEFAULT NULL
   ,par_fund_id           OUT fund.fund_id%TYPE
  );
  PROCEDURE update_record(par_record IN fund%ROWTYPE);
  PROCEDURE delete_record(par_fund_id IN fund.fund_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_fund_dml IS

  FUNCTION get_record(par_fund_id IN fund.fund_id%TYPE) RETURN fund%ROWTYPE IS
    vr_record fund%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM fund WHERE fund_id = par_fund_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  FUNCTION get_record_by_brief(par_fund_brief IN fund.brief%TYPE) RETURN fund%ROWTYPE IS
    vr_record fund%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM fund WHERE brief = par_fund_brief;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record_by_brief;
	
  FUNCTION get_id_by_brief(par_fund_brief IN fund.brief%TYPE) RETURN fund.fund_id%TYPE IS
    v_fund_id fund.fund_id%TYPE;
  BEGIN
    SELECT fund_id INTO v_fund_id FROM fund WHERE brief = par_fund_brief;
    RETURN v_fund_id;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_id_by_brief;

  PROCEDURE insert_record
  (
    par_brief             IN fund.brief%TYPE
   ,par_name              IN fund.name%TYPE
   ,par_code              IN fund.code%TYPE
   ,par_is_active         IN fund.is_active%TYPE DEFAULT 0
   ,par_spell_short_fract IN fund.spell_short_fract%TYPE DEFAULT NULL
   ,par_spell_short_whole IN fund.spell_short_whole%TYPE DEFAULT NULL
   ,par_spell_2_fract     IN fund.spell_2_fract%TYPE DEFAULT NULL
   ,par_default_rate      IN fund.default_rate%TYPE DEFAULT NULL
   ,par_spell_5_fract     IN fund.spell_5_fract%TYPE DEFAULT NULL
   ,par_add_code          IN fund.add_code%TYPE DEFAULT NULL
   ,par_precision         IN fund.precision%TYPE DEFAULT NULL
   ,par_rate_qty          IN fund.rate_qty%TYPE DEFAULT NULL
   ,par_spell_1_whole     IN fund.spell_1_whole%TYPE DEFAULT NULL
   ,par_spell_2_whole     IN fund.spell_2_whole%TYPE DEFAULT NULL
   ,par_spell_5_whole     IN fund.spell_5_whole%TYPE DEFAULT NULL
   ,par_spell_1_fract     IN fund.spell_1_fract%TYPE DEFAULT NULL
   ,par_fund_id           OUT fund.fund_id%TYPE
  ) IS
  BEGIN
    SELECT sq_fund.nextval INTO par_fund_id FROM dual;
    INSERT INTO fund
      (fund_id
      ,spell_2_fract
      ,is_active
      ,spell_short_whole
      ,spell_short_fract
      ,NAME
      ,brief
      ,code
      ,add_code
      ,PRECISION
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
  END insert_record;
  PROCEDURE update_record(par_record IN fund%ROWTYPE) IS
  BEGIN
    UPDATE fund
       SET default_rate      = par_record.default_rate
          ,spell_5_fract     = par_record.spell_5_fract
          ,is_active         = par_record.is_active
          ,spell_short_whole = par_record.spell_short_whole
          ,spell_short_fract = par_record.spell_short_fract
          ,NAME              = par_record.name
          ,brief             = par_record.brief
          ,code              = par_record.code
          ,add_code          = par_record.add_code
          ,PRECISION         = par_record.precision
          ,rate_qty          = par_record.rate_qty
          ,spell_1_whole     = par_record.spell_1_whole
          ,spell_2_whole     = par_record.spell_2_whole
          ,spell_5_whole     = par_record.spell_5_whole
          ,spell_1_fract     = par_record.spell_1_fract
          ,spell_2_fract     = par_record.spell_2_fract
     WHERE fund_id = par_record.fund_id;
  END update_record;
  PROCEDURE delete_record(par_fund_id IN fund.fund_id%TYPE) IS
  BEGIN
    DELETE FROM fund WHERE fund_id = par_fund_id;
  END delete_record;
END;
/
