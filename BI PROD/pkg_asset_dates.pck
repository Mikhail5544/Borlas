CREATE OR REPLACE PACKAGE pkg_asset_dates IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 13.05.2014 18:17:47
  -- Purpose : Работа с датами застрахованных

  FUNCTION get_asset_start_date
  (
    par_as_asset_id     NUMBER
   ,par_asset_header_id NUMBER
   ,par_is_group        NUMBER
  ) RETURN DATE;

  FUNCTION get_asset_end_date(par_as_asset_id NUMBER) RETURN DATE;
  PROCEDURE update_asset_dates(par_as_asset_id as_asset.as_asset_id%TYPE);
  PROCEDURE update_all_assets_dates
  (
    par_policy_id          p_policy.policy_id%TYPE
   ,par_is_group_flag      p_policy.is_group_flag%TYPE
   ,par_default_start_date as_asset.start_date%TYPE DEFAULT NULL
   ,par_default_end_date   as_asset.end_date%TYPE DEFAULT NULL
  );
END pkg_asset_dates;
/
CREATE OR REPLACE PACKAGE BODY pkg_asset_dates IS
  gc_pkg_name CONSTANT pkg_trace.t_object_name := 'PKG_ASSET_DATES';

  FUNCTION get_asset_start_date
  (
    par_as_asset_id     NUMBER
   ,par_asset_header_id NUMBER
   ,par_is_group        NUMBER
  ) RETURN DATE IS
    v_is_group   ins.p_policy.is_group_flag%TYPE;
    v_start_date DATE;
  BEGIN
    --определяем признак группопвого договора
  
    /*если договор групповой, то дата начала объекта (as_asset.start_date)
    определяется как минимальное значение из всех покрытий по всем объектам (as_asset_id),
    имеющих тот же заголовок объекта (as_asset_header_id).
    */
    IF par_is_group = 1
    THEN
      SELECT MIN(pc.start_date)
        INTO v_start_date
        FROM ins.as_asset aa
            ,ins.p_cover  pc
       WHERE aa.as_asset_id = pc.as_asset_id
         AND pc.status_hist_id IN (1, 2)
            --
         AND aa.p_asset_header_id = par_asset_header_id;
    ELSE
      /*если договоре не групповой, то берем минимальную дату по покрытиям данного объекта*/
      SELECT MIN(pc.start_date)
        INTO v_start_date
        FROM ins.p_cover pc
       WHERE pc.status_hist_id IN (1, 2)
            --
         AND pc.as_asset_id = par_as_asset_id;
    END IF;
    RETURN v_start_date;
  END get_asset_start_date;

  FUNCTION get_asset_end_date(par_as_asset_id NUMBER) RETURN DATE IS
    v_is_group ins.p_policy.is_group_flag%TYPE;
    v_end_date DATE;
  BEGIN
    SELECT MAX(pc.end_date)
      INTO v_end_date
      FROM ins.p_cover pc
     WHERE pc.status_hist_id IN (1, 2)
       AND pc.as_asset_id = par_as_asset_id;
    RETURN v_end_date;
  END get_asset_end_date;

  PROCEDURE update_asset_dates(par_as_asset_id as_asset.as_asset_id%TYPE) IS
    vc_proc_name CONSTANT pkg_trace.t_object_name := 'UPDATE_ASSET_DATES';
    v_start_date      DATE;
    v_end_date        DATE;
    v_asset_header_id as_asset.p_asset_header_id%TYPE;
    v_is_group_flag   p_policy.is_group_flag%TYPE;
  BEGIN
    pkg_trace.add_variable(par_trace_var_name  => 'par_as_asset_id'
                          ,par_trace_var_value => par_as_asset_id);
    pkg_trace.trace_procedure_start(par_trace_obj_name    => gc_pkg_name
                                   ,par_trace_subobj_name => vc_proc_name);
  
    SELECT aa.p_asset_header_id
          ,pp.is_group_flag
      INTO v_asset_header_id
          ,v_is_group_flag
      FROM as_asset aa
          ,p_policy pp
     WHERE aa.as_asset_id = par_as_asset_id
       AND aa.p_policy_id = pp.policy_id;
  
    v_start_date := get_asset_start_date(par_as_asset_id, v_asset_header_id, v_is_group_flag);
    v_end_date   := get_asset_end_date(par_as_asset_id);
  
    pkg_trace.add_variable(par_trace_var_name => 'v_start_date', par_trace_var_value => v_start_date);
    pkg_trace.add_variable(par_trace_var_name => 'v_end_date', par_trace_var_value => v_end_date);
    pkg_trace.trace(par_trace_obj_name    => gc_pkg_name
                   ,par_trace_subobj_name => vc_proc_name
                   ,par_message           => 'Обновление дат начала и окончания объекта страхования');
  
    UPDATE as_asset a
       SET a.start_date = v_start_date
          ,a.end_date   = v_end_date
     WHERE a.as_asset_id = par_as_asset_id;
  
    pkg_trace.trace_procedure_end(par_trace_obj_name    => gc_pkg_name
                                 ,par_trace_subobj_name => vc_proc_name);
  
  END update_asset_dates;

  PROCEDURE update_all_assets_dates
  (
    par_policy_id          p_policy.policy_id%TYPE
   ,par_is_group_flag      p_policy.is_group_flag%TYPE
   ,par_default_start_date as_asset.start_date%TYPE DEFAULT NULL
   ,par_default_end_date   as_asset.end_date%TYPE DEFAULT NULL
  ) IS
  BEGIN
    IF par_is_group_flag = 1
    THEN
      UPDATE as_asset a
         SET a.start_date =
             (SELECT nvl(MIN(pc.start_date), par_default_start_date)
                FROM ins.as_asset aa
                    ,ins.p_cover  pc
               WHERE aa.as_asset_id = pc.as_asset_id
                 AND pc.status_hist_id IN (1, 2)
                 AND aa.p_asset_header_id = a.p_asset_header_id)
            ,a.end_date  =
             (SELECT nvl(MAX(pc.end_date), par_default_end_date)
                FROM ins.p_cover pc
               WHERE pc.status_hist_id IN (1, 2)
                 AND pc.as_asset_id = a.as_asset_id)
       WHERE a.p_policy_id = par_policy_id;
    ELSE
      UPDATE as_asset a
         SET a.start_date =
             (SELECT nvl(MIN(pc.start_date), par_default_start_date)
                FROM ins.p_cover pc
               WHERE pc.status_hist_id IN (1, 2)
                    --
                 AND pc.as_asset_id = a.as_asset_id)
            ,a.end_date  =
             (SELECT nvl(MAX(pc.end_date), par_default_end_date)
                FROM ins.p_cover pc
               WHERE pc.status_hist_id IN (1, 2)
                 AND pc.as_asset_id = a.as_asset_id)
       WHERE a.p_policy_id = par_policy_id;
    END IF;
  END update_all_assets_dates;
END pkg_asset_dates;
/
