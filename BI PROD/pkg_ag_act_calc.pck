CREATE OR REPLACE PACKAGE pkg_ag_act_calc IS

  -- Author  : DKOLGANOV
  -- Created : 02.06.2008 13:54:00
  -- Purpose : пакет дл€ администрировани€ расчетов
  FUNCTION get_ag_rate_type_id(p_brief VARCHAR2) RETURN NUMBER;
  PROCEDURE insert_ag_perf_det(p_rec IN OUT ven_ag_perfom_work_det%ROWTYPE);
  PROCEDURE update_ag_perf_det(p_rect ven_ag_perfom_work_det%ROWTYPE);
  PROCEDURE insert_ag_perf_dpol(p_recd IN OUT ven_ag_perfom_work_dpol%ROWTYPE);

  /*убрано в другой пакет*/
  FUNCTION get_ag_perfomed_work_act(p_r NUMBER) RETURN ven_ag_perfomed_work_act%ROWTYPE;
  PROCEDURE update_ag_perfomed_work_act(p_rc ven_ag_perfomed_work_act%ROWTYPE);

END pkg_ag_act_calc;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_act_calc IS

  FUNCTION get_ag_rate_type_id(p_brief VARCHAR2) RETURN NUMBER IS
    CURSOR get_id(c_brief VARCHAR2) IS(
      SELECT art.ag_rate_type_id FROM ven_ag_rate_type art WHERE art.brief = c_brief);
    RESULT NUMBER;
  BEGIN
    OPEN get_id(p_brief);
    FETCH get_id
      INTO RESULT;
    IF (get_id%NOTFOUND)
    THEN
      CLOSE get_id;
      raise_application_error(-20001
                             ,'“акого вида премий не существует!!!');
    END IF;
    CLOSE get_id;
    RETURN RESULT;
  END;

  PROCEDURE insert_ag_perf_det(p_rec IN OUT ven_ag_perfom_work_det%ROWTYPE) IS
  BEGIN
    IF (p_rec.ag_perfom_work_det_id IS NULL)
    THEN
      p_rec.ag_perfom_work_det_id := pkg_agent_utils.GetNewSqAgPerfDet;
    END IF;
    INSERT INTO ven_ag_perfom_work_det d
      (ag_perfom_work_det_id
      ,ent_id
      ,filial_id
      ,ext_id
      ,ag_perfomed_work_act_id
      ,ag_rate_type_id
      ,count_recruit_agent
      ,mounth_num
      ,summ)
    VALUES
      (p_rec.ag_perfom_work_det_id
      ,p_rec.ent_id
      ,p_rec.filial_id
      ,p_rec.ext_id
      ,p_rec.ag_perfomed_work_act_id
      ,p_rec.ag_rate_type_id
      ,p_rec.count_recruit_agent
      ,p_rec.mounth_num
      ,p_rec.summ);
  END insert_ag_perf_det;

  PROCEDURE update_ag_perf_det(p_rect ven_ag_perfom_work_det%ROWTYPE) IS
  BEGIN
    UPDATE ven_ag_perfom_work_det
       SET ent_id                  = p_rect.ent_id
          ,filial_id               = p_rect.filial_id
          ,ext_id                  = p_rect.ext_id
          ,ag_perfomed_work_act_id = p_rect.ag_perfomed_work_act_id
          ,ag_rate_type_id         = p_rect.ag_rate_type_id
          ,count_recruit_agent     = p_rect.count_recruit_agent
          ,mounth_num              = p_rect.mounth_num
          ,summ                    = p_rect.summ
     WHERE ag_perfom_work_det_id = p_rect.ag_perfom_work_det_id;
  END update_ag_perf_det;

  PROCEDURE insert_ag_perf_dpol(p_recd IN OUT ven_ag_perfom_work_dpol%ROWTYPE) IS
  
    CURSOR get_pol(c_pol_id NUMBER) IS(
      SELECT pc.fee                   psum
            ,pc.t_prod_line_option_id prod_line
            ,pc.p_cover_id
        FROM ven_p_cover pc
        JOIN ven_as_asset aa
          ON (aa.as_asset_id = pc.as_asset_id AND aa.p_policy_id = c_pol_id));
  
    p_cur get_pol%ROWTYPE;
  BEGIN
    IF (p_recd.ag_perfom_work_dpol_id IS NULL)
    THEN
      p_recd.ag_perfom_work_dpol_id := pkg_agent_utils.GetNewSqAgPerfDpol;
    END IF;
    INSERT INTO ven_ag_perfom_work_dpol
      (ag_perfom_work_dpol_id
      ,ent_id
      ,filial_id
      ,ext_id
      ,ag_contract_header_ch_id
      ,ag_perfom_work_det_id
      ,policy_id
      ,summ
      ,num_months)
    VALUES
      (p_recd.ag_perfom_work_dpol_id
      ,p_recd.ent_id
      ,p_recd.filial_id
      ,p_recd.ext_id
      ,p_recd.ag_contract_header_ch_id
      ,p_recd.ag_perfom_work_det_id
      ,p_recd.policy_id
      ,p_recd.summ
      ,p_recd.num_months);
  
    OPEN get_pol(p_recd.policy_id);
    LOOP
      FETCH get_pol
        INTO p_cur.psum
            ,p_cur.prod_line
            ,p_cur.p_cover_id;
      EXIT WHEN get_pol%NOTFOUND;
      INSERT INTO ag_perf_work_dcover
        (ag_perf_work_dcover_id, p_cover_id, prod_line_id, summ, ag_perf_work_dpol_id)
      VALUES
        (sq_ag_perf_work_dcover.nextval
        ,p_cur.p_cover_id
        ,p_cur.prod_line
        ,p_cur.psum
        ,p_recd.ag_perfom_work_dpol_id);
    END LOOP;
    CLOSE get_pol;
  END;

  FUNCTION get_ag_perfomed_work_act(p_r NUMBER) RETURN ven_ag_perfomed_work_act%ROWTYPE IS
    CURSOR cur(p_id NUMBER) IS
      SELECT * FROM ven_ag_perfomed_work_act a WHERE a.ag_perfomed_work_act_id = p_id;
    rec ven_ag_perfomed_work_act%ROWTYPE;
  BEGIN
    OPEN cur(p_r);
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
  END get_ag_perfomed_work_act;

  PROCEDURE update_ag_perfomed_work_act(p_rc ven_ag_perfomed_work_act%ROWTYPE) IS
  BEGIN
    -- dbms_output.put_line(p_rc.sum || ' ' || p_rc.ag_perfomed_work_act_id);
    UPDATE ven_ag_perfomed_work_act
       SET ent_id                = p_rc.ent_id
          ,filial_id             = p_rc.filial_id
          ,ext_id                = p_rc.ext_id
          ,doc_folder_id         = p_rc.doc_folder_id
          ,doc_templ_id          = p_rc.doc_templ_id
          ,guid                  = p_rc.guid
          ,note                  = p_rc.note
          ,num                   = p_rc.num
          ,reg_date              = p_rc.reg_date
          ,ag_contract_header_id = p_rc.ag_contract_header_id
          ,ag_roll_id            = p_rc.ag_roll_id
          ,ag_stat_hist_id       = p_rc.ag_stat_hist_id
          ,date_calc             = p_rc.date_calc
          ,delta                 = p_rc.delta
          ,sgp1                  = p_rc.sgp1
          ,sgp2                  = p_rc.sgp2
          ,SUM                   = nvl(p_rc.sum, 0)
          ,status_id             = p_rc.status_id
     WHERE ag_perfomed_work_act_id = p_rc.ag_perfomed_work_act_id;
  END update_ag_perfomed_work_act;

END pkg_ag_act_calc;
/
