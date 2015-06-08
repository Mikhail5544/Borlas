CREATE OR REPLACE PACKAGE pkg_ag_perfomed_work_act IS

  FUNCTION GetAgPerfomedWorkAct(p_rec NUMBER) RETURN VEN_ag_perfomed_work_act%ROWTYPE;

  FUNCTION InsertAgPerfomedWorkAct(p_rec IN OUT VEN_ag_perfomed_work_act%ROWTYPE) RETURN NUMBER;

  FUNCTION UpdateAgPerfomedWorkAct(p_rec IN OUT VEN_ag_perfomed_work_act%ROWTYPE) RETURN NUMBER;

END PKG_ag_perfomed_work_act;
/
CREATE OR REPLACE PACKAGE BODY PKG_ag_perfomed_work_act IS
  FUNCTION GetAgPerfomedWorkAct(p_rec NUMBER) RETURN VEN_ag_perfomed_work_act%ROWTYPE IS
    CURSOR cur(p_id NUMBER) IS
      SELECT * FROM VEN_ag_perfomed_work_act WHERE ag_perfomed_work_act_ID = p_id;
    rec VEN_ag_perfomed_work_act%ROWTYPE;
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
  END GetAgPerfomedWorkAct;

  FUNCTION InsertAgPerfomedWorkAct(p_rec IN OUT VEN_ag_perfomed_work_act%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    IF (p_rec.ag_perfomed_work_act_id IS NULL)
    THEN
      p_rec.ag_perfomed_work_act_id := PKG_AGENT_UTILS.GetNewSqAgPerfAct;
    END IF;
  
    INSERT INTO VEN_AG_PERFOMED_WORK_ACT
      (ag_perfomed_work_act_id
      ,ent_id
      ,filial_id
      ,ext_id
      ,doc_folder_id
      ,doc_templ_id
      ,guid
      ,note
      ,num
      ,reg_date
      ,ag_contract_header_id
      ,ag_roll_id
      ,ag_stat_hist_id
      ,date_calc
      ,delta
      ,sgp1
      ,sgp2
      ,SUM
      ,status_id)
    VALUES
      (p_rec.ag_perfomed_work_act_id
      ,p_rec.ent_id
      ,p_rec.filial_id
      ,p_rec.ext_id
      ,p_rec.doc_folder_id
      ,p_rec.doc_templ_id
      ,p_rec.guid
      ,p_rec.note
      ,p_rec.num
      ,p_rec.reg_date
      ,p_rec.ag_contract_header_id
      ,p_rec.ag_roll_id
      ,p_rec.ag_stat_hist_id
      ,p_rec.date_calc
      ,p_rec.delta
      ,p_rec.sgp1
      ,p_rec.sgp2
      ,p_rec.SUM
      ,p_rec.status_id);
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END InsertAgPerfomedWorkAct;

  FUNCTION UpdateAgPerfomedWorkAct(p_rec IN OUT VEN_ag_perfomed_work_act%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    UPDATE VEN_AG_PERFOMED_WORK_ACT
       SET ent_id                = p_rec.ent_id
          ,filial_id             = p_rec.filial_id
          ,ext_id                = p_rec.ext_id
          ,doc_folder_id         = p_rec.doc_folder_id
          ,doc_templ_id          = p_rec.doc_templ_id
          ,guid                  = p_rec.guid
          ,note                  = p_rec.note
          ,num                   = p_rec.num
          ,reg_date              = p_rec.reg_date
          ,ag_contract_header_id = p_rec.ag_contract_header_id
          ,ag_roll_id            = p_rec.ag_roll_id
          ,ag_stat_hist_id       = p_rec.ag_stat_hist_id
          ,date_calc             = p_rec.date_calc
          ,delta                 = p_rec.delta
          ,sgp1                  = p_rec.sgp1
          ,sgp2                  = p_rec.sgp2
          ,SUM                   = p_rec.SUM
          ,status_id             = p_rec.status_id
     WHERE AG_PERFOMED_WORK_ACT_ID = p_rec.AG_PERFOMED_WORK_ACT_ID;
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END UpdateAgPerfomedWorkAct;

END PKG_ag_perfomed_work_act;
/
