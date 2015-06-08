CREATE OR REPLACE PACKAGE ins.pkg_ag_roll IS

  FUNCTION insertagroll(p_rec IN OUT ven_ag_roll%ROWTYPE) RETURN NUMBER;
  FUNCTION updateagroll(p_rec ven_ag_roll%ROWTYPE) RETURN NUMBER;
  FUNCTION deleteagroll(p_rec NUMBER) RETURN NUMBER;
  FUNCTION getagroll(p_rec NUMBER) RETURN ven_ag_roll%ROWTYPE;

  FUNCTION insertagrollheader(p_rec IN OUT ven_ag_roll_header%ROWTYPE) RETURN NUMBER;
  FUNCTION updateagrollheader(p_rec ven_ag_roll_header%ROWTYPE) RETURN NUMBER;
  FUNCTION deleteagrollheader(p_rec NUMBER) RETURN NUMBER;
  FUNCTION getagrollheader(p_rec NUMBER) RETURN ven_ag_roll_header%ROWTYPE;

  FUNCTION getagrolltype(p_rec NUMBER) RETURN ven_ag_roll_type%ROWTYPE;

  FUNCTION get_last_ag_roll_id(p_ag_roll_header_id IN NUMBER) RETURN NUMBER;

END pkg_ag_roll;
/
CREATE OR REPLACE PACKAGE BODY ins.pkg_ag_roll IS

  FUNCTION insertagroll(p_rec IN OUT ven_ag_roll%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    IF (p_rec.ag_roll_id IS NULL)
    THEN
      p_rec.ag_roll_id := pkg_agent_utils.getnewsqagroll;
    END IF;
  
    INSERT INTO ven_ag_roll
      (ag_roll_id
      ,ent_id
      ,filial_id
      ,ext_id
      ,doc_folder_id
      ,doc_templ_id
      ,guid
      ,note
      ,num
      ,reg_date
      ,ag_roll_header_id
      ,user_name)
    VALUES
      (p_rec.ag_roll_id
      ,p_rec.ent_id
      ,p_rec.filial_id
      ,p_rec.ext_id
      ,p_rec.doc_folder_id
      ,p_rec.doc_templ_id
      ,p_rec.guid
      ,p_rec.note
      ,p_rec.num
      ,p_rec.reg_date
      ,p_rec.ag_roll_header_id
      ,p_rec.user_name);
  
    RETURN utils.c_true;
  END;

  FUNCTION updateagroll(p_rec ven_ag_roll%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    UPDATE ven_ag_roll
       SET ent_id            = p_rec.ent_id
          ,filial_id         = p_rec.filial_id
          ,ext_id            = p_rec.ext_id
          ,doc_folder_id     = p_rec.doc_folder_id
          ,doc_templ_id      = p_rec.doc_templ_id
          ,guid              = p_rec.guid
          ,note              = p_rec.note
          ,num               = p_rec.num
          ,reg_date          = p_rec.reg_date
          ,ag_roll_header_id = p_rec.ag_roll_header_id
          ,user_name         = p_rec.user_name
     WHERE ag_roll_id = p_rec.ag_roll_id;
  
    RETURN utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN utils.c_false;
  END;

  FUNCTION deleteagroll(p_rec NUMBER) RETURN NUMBER IS
  BEGIN
  
    DELETE FROM ven_ag_roll r WHERE r.ag_roll_id = p_rec;
  
    RETURN utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN utils.c_false;
  END;

  FUNCTION getagroll(p_rec NUMBER) RETURN ven_ag_roll%ROWTYPE IS
    CURSOR cur(p_id NUMBER) IS
      SELECT * FROM ven_ag_roll WHERE ag_roll_id = p_id;
  
    rec ven_ag_roll%ROWTYPE;
  BEGIN
  
    OPEN cur(p_rec);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN NULL;
    END IF;
  
    CLOSE cur;
    RETURN rec;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION insertagrollheader(p_rec IN OUT ven_ag_roll_header%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    IF (p_rec.ag_roll_header_id IS NULL)
    THEN
      p_rec.ag_roll_header_id := pkg_agent_utils.getnewsqagrollheader;
    END IF;
  
    INSERT INTO ven_ag_roll_header
      (ag_roll_header_id
      ,doc_templ_id
      ,note
      ,num
      ,reg_date
      ,ag_category_agent_id
      ,ag_roll_type_id
      ,date_begin
      ,date_end)
    VALUES
      (p_rec.ag_roll_header_id
      ,p_rec.doc_templ_id
      ,p_rec.note
      ,p_rec.num
      ,p_rec.reg_date
      ,p_rec.ag_category_agent_id
      ,p_rec.ag_roll_type_id
      ,p_rec.date_begin
      ,p_rec.date_end);
  
    RETURN utils.c_true;
  END;

  FUNCTION updateagrollheader(p_rec ven_ag_roll_header%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    UPDATE ven_ag_roll_header
       SET ent_id               = p_rec.ent_id
          ,filial_id            = p_rec.filial_id
          ,ext_id               = p_rec.ext_id
          ,doc_folder_id        = p_rec.doc_folder_id
          ,doc_templ_id         = p_rec.doc_templ_id
          ,guid                 = p_rec.guid
          ,note                 = p_rec.note
          ,num                  = p_rec.num
          ,reg_date             = p_rec.reg_date
          ,ag_category_agent_id = p_rec.ag_category_agent_id
          ,ag_roll_type_id      = p_rec.ag_roll_type_id
          ,date_begin           = p_rec.date_begin
          ,date_end             = p_rec.date_end
          ,months_date          = p_rec.months_date
     WHERE ag_roll_header_id = p_rec.ag_roll_header_id;
  
    RETURN utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN utils.c_false;
  END;

  FUNCTION deleteagrollheader(p_rec NUMBER) RETURN NUMBER IS
  BEGIN
    DELETE FROM ven_ag_roll_header v WHERE v.ag_roll_header_id = p_rec;
    RETURN utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN utils.c_false;
  END;

  FUNCTION getagrollheader(p_rec NUMBER) RETURN ven_ag_roll_header%ROWTYPE IS
    CURSOR cur(p_id NUMBER) IS
      SELECT * FROM ven_ag_roll_header WHERE ag_roll_header_id = p_id;
  
    rec ven_ag_roll_header%ROWTYPE;
  BEGIN
  
    OPEN cur(p_rec);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN NULL;
    END IF;
  
    CLOSE cur;
    RETURN rec;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  FUNCTION getagrolltype(p_rec NUMBER) RETURN ven_ag_roll_type%ROWTYPE IS
    CURSOR cur(p_id NUMBER) IS
      SELECT * FROM ven_ag_roll_type WHERE ag_roll_type_id = p_id;
  
    rec ven_ag_roll_type%ROWTYPE;
  BEGIN
  
    OPEN cur(p_rec);
    FETCH cur
      INTO rec;
  
    IF (cur%NOTFOUND)
    THEN
      CLOSE cur;
      RETURN NULL;
    END IF;
  
    CLOSE cur;
    RETURN rec;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END getagrolltype;

  FUNCTION get_last_ag_roll_id(p_ag_roll_header_id IN NUMBER) RETURN NUMBER AS
    v_ret_id NUMBER;
  BEGIN
    SELECT max(ag_roll_id) KEEP (dense_rank last ORDER BY num)
      INTO v_ret_id
      FROM ven_ag_roll
     WHERE ag_roll_header_id = p_ag_roll_header_id;

    RETURN v_ret_id;
  END get_last_ag_roll_id;

END pkg_ag_roll;
/
