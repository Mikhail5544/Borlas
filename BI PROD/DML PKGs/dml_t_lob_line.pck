CREATE OR REPLACE PACKAGE dml_t_lob_line IS
  FUNCTION get_id_by_brief
  (
    par_brief          IN t_lob_line.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_lob_line.t_lob_id%TYPE;
  FUNCTION get_record(par_t_lob_line_id IN t_lob_line.t_lob_line_id%TYPE) RETURN t_lob_line%ROWTYPE;
  PROCEDURE insert_record
  (
    par_description         IN t_lob_line.description%TYPE
   ,par_insurance_group_id  IN t_lob_line.insurance_group_id%TYPE DEFAULT NULL
   ,par_t_lob_id            IN t_lob_line.t_lob_id%TYPE DEFAULT NULL
   ,par_min_age             IN t_lob_line.min_age%TYPE DEFAULT NULL
   ,par_max_age             IN t_lob_line.max_age%TYPE DEFAULT NULL
   ,par_brief               IN t_lob_line.brief%TYPE DEFAULT NULL
   ,par_note                IN t_lob_line.note%TYPE DEFAULT NULL
   ,par_pre_calc_ins_amount IN t_lob_line.pre_calc_ins_amount%TYPE DEFAULT 0
   ,par_pre_calc_fee        IN t_lob_line.pre_calc_fee%TYPE DEFAULT 0
  );
  PROCEDURE insert_record
  (
    par_description         IN t_lob_line.description%TYPE
   ,par_insurance_group_id  IN t_lob_line.insurance_group_id%TYPE DEFAULT NULL
   ,par_t_lob_id            IN t_lob_line.t_lob_id%TYPE DEFAULT NULL
   ,par_min_age             IN t_lob_line.min_age%TYPE DEFAULT NULL
   ,par_max_age             IN t_lob_line.max_age%TYPE DEFAULT NULL
   ,par_brief               IN t_lob_line.brief%TYPE DEFAULT NULL
   ,par_note                IN t_lob_line.note%TYPE DEFAULT NULL
   ,par_pre_calc_ins_amount IN t_lob_line.pre_calc_ins_amount%TYPE DEFAULT 0
   ,par_pre_calc_fee        IN t_lob_line.pre_calc_fee%TYPE DEFAULT 0
   ,par_t_lob_line_id       OUT t_lob_line.t_lob_line_id%TYPE
  );
  PROCEDURE update_record(par_record IN t_lob_line%ROWTYPE);
  PROCEDURE delete_record(par_t_lob_line_id IN t_lob_line.t_lob_line_id%TYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY dml_t_lob_line IS

  FUNCTION get_id_by_brief
  (
    par_brief          IN t_lob_line.brief%TYPE
   ,par_raise_on_error BOOLEAN DEFAULT TRUE
  ) RETURN t_lob_line.t_lob_id%TYPE IS
    v_id t_lob_line.t_lob_line_id%TYPE;
  BEGIN
    BEGIN
      SELECT t_lob_line_id INTO v_id FROM t_lob_line WHERE brief = par_brief;
    EXCEPTION
      WHEN no_data_found THEN
        IF par_raise_on_error
        THEN
          raise_application_error(-20001
                                 ,'Не найдена запись по значению поля "' || par_brief || '"');
        ELSE
          v_id := NULL;
        END IF;
    END;
    RETURN v_id;
  END get_id_by_brief;

  FUNCTION get_record(par_t_lob_line_id IN t_lob_line.t_lob_line_id%TYPE) RETURN t_lob_line%ROWTYPE IS
    vr_record t_lob_line%ROWTYPE;
  BEGIN
    SELECT * INTO vr_record FROM t_lob_line WHERE t_lob_line_id = par_t_lob_line_id;
    RETURN vr_record;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END get_record;

  PROCEDURE insert_record
  (
    par_description         IN t_lob_line.description%TYPE
   ,par_insurance_group_id  IN t_lob_line.insurance_group_id%TYPE DEFAULT NULL
   ,par_t_lob_id            IN t_lob_line.t_lob_id%TYPE DEFAULT NULL
   ,par_min_age             IN t_lob_line.min_age%TYPE DEFAULT NULL
   ,par_max_age             IN t_lob_line.max_age%TYPE DEFAULT NULL
   ,par_brief               IN t_lob_line.brief%TYPE DEFAULT NULL
   ,par_note                IN t_lob_line.note%TYPE DEFAULT NULL
   ,par_pre_calc_ins_amount IN t_lob_line.pre_calc_ins_amount%TYPE DEFAULT 0
   ,par_pre_calc_fee        IN t_lob_line.pre_calc_fee%TYPE DEFAULT 0
  ) IS
    v_t_lob_line_id t_lob_line.t_lob_line_id%TYPE;
  BEGIN
    insert_record(par_description         => par_description
                 ,par_insurance_group_id  => par_insurance_group_id
                 ,par_t_lob_id            => par_t_lob_id
                 ,par_min_age             => par_min_age
                 ,par_max_age             => par_max_age
                 ,par_brief               => par_brief
                 ,par_note                => par_note
                 ,par_pre_calc_ins_amount => par_pre_calc_ins_amount
                 ,par_pre_calc_fee        => par_pre_calc_fee
                 ,par_t_lob_line_id       => v_t_lob_line_id);
  END insert_record;

  PROCEDURE insert_record
  (
    par_description         IN t_lob_line.description%TYPE
   ,par_insurance_group_id  IN t_lob_line.insurance_group_id%TYPE DEFAULT NULL
   ,par_t_lob_id            IN t_lob_line.t_lob_id%TYPE DEFAULT NULL
   ,par_min_age             IN t_lob_line.min_age%TYPE DEFAULT NULL
   ,par_max_age             IN t_lob_line.max_age%TYPE DEFAULT NULL
   ,par_brief               IN t_lob_line.brief%TYPE DEFAULT NULL
   ,par_note                IN t_lob_line.note%TYPE DEFAULT NULL
   ,par_pre_calc_ins_amount IN t_lob_line.pre_calc_ins_amount%TYPE DEFAULT 0
   ,par_pre_calc_fee        IN t_lob_line.pre_calc_fee%TYPE DEFAULT 0
   ,par_t_lob_line_id       OUT t_lob_line.t_lob_line_id%TYPE
  ) IS
  BEGIN
    SELECT sq_t_lob_line.nextval INTO par_t_lob_line_id FROM dual;
    INSERT INTO t_lob_line
      (t_lob_line_id
      ,pre_calc_fee
      ,description
      ,note
      ,t_lob_id
      ,min_age
      ,max_age
      ,brief
      ,pre_calc_ins_amount
      ,insurance_group_id)
    VALUES
      (par_t_lob_line_id
      ,par_pre_calc_fee
      ,par_description
      ,par_note
      ,par_t_lob_id
      ,par_min_age
      ,par_max_age
      ,par_brief
      ,par_pre_calc_ins_amount
      ,par_insurance_group_id);
  END insert_record;
  PROCEDURE update_record(par_record IN t_lob_line%ROWTYPE) IS
  BEGIN
    UPDATE t_lob_line
       SET pre_calc_ins_amount = par_record.pre_calc_ins_amount
          ,pre_calc_fee        = par_record.pre_calc_fee
          ,description         = par_record.description
          ,insurance_group_id  = par_record.insurance_group_id
          ,t_lob_id            = par_record.t_lob_id
          ,min_age             = par_record.min_age
          ,max_age             = par_record.max_age
          ,brief               = par_record.brief
          ,note                = par_record.note
     WHERE t_lob_line_id = par_record.t_lob_line_id;
  END update_record;
  PROCEDURE delete_record(par_t_lob_line_id IN t_lob_line.t_lob_line_id%TYPE) IS
  BEGIN
    DELETE FROM t_lob_line WHERE t_lob_line_id = par_t_lob_line_id;
  END delete_record;
END;
/
