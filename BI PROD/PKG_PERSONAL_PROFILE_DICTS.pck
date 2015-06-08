CREATE OR REPLACE PACKAGE PKG_PERSONAL_PROFILE_DICTS IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 28.01.2013 17:09:11
  -- Purpose : Работа со справочниками для ЛК

  PROCEDURE delete_yield_for_profile(par_load_csv_list_id NUMBER);

  PROCEDURE load_yield_for_profile_row(par_load_file_rows_id NUMBER);

  PROCEDURE check_yield_for_profile_row
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );

  PROCEDURE delete_yield(par_load_csv_list_id NUMBER);

  PROCEDURE load_yield_row(par_load_file_rows_id NUMBER);

  PROCEDURE check_yield_row
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  );
  PROCEDURE delete_stocks_and_bonds(par_load_csv_list_id NUMBER);
  PROCEDURE load_stocks_and_bonds_row(par_load_file_rows_id NUMBER);
  PROCEDURE delete_fee_reserve(par_load_csv_list_id NUMBER);
  PROCEDURE load_fee_reserve_row(par_load_file_rows_id NUMBER);
  PROCEDURE delete_fonds(par_load_csv_list_id NUMBER);
  PROCEDURE load_fonds_row(par_load_file_rows_id NUMBER);
  PROCEDURE delete_dynamics_of_assets(par_load_csv_list_id NUMBER);
  PROCEDURE load_dynamics_of_assets_row(par_load_file_rows_id NUMBER);
END PKG_PERSONAL_PROFILE_DICTS;
/
CREATE OR REPLACE PACKAGE BODY PKG_PERSONAL_PROFILE_DICTS IS

  PROCEDURE convert_perc_to_number
  (
    par_value       VARCHAR2
   ,par_column_name VARCHAR2
   ,par_result      OUT NUMBER
   ,par_comment     OUT VARCHAR2
   ,par_status      OUT NUMBER
  ) IS
  BEGIN
    par_result := to_number(REPLACE(par_value, '%'), '990D99', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100;
  EXCEPTION
    WHEN OTHERS THEN
      par_status  := pkg_load_file_to_table.get_error;
      par_comment := 'Невозможно преобразовать значение поля "' || par_column_name || '" в число: "' ||
                     par_value || '"';
  END convert_perc_to_number;

  PROCEDURE delete_yield_for_profile(par_load_csv_list_id NUMBER) IS
  BEGIN
    DELETE FROM t_reference_yield_profile;
  END;

  PROCEDURE load_yield_for_profile_row(par_load_file_rows_id NUMBER) IS
    vr_file_row load_file_rows%ROWTYPE;
    v_month     VARCHAR2(3);
    v_year      VARCHAR2(2);
    vt_columns  tt_one_col;
    vr_yield    t_reference_yield%ROWTYPE;
    v_status    load_file_rows.row_status%TYPE;
    v_comment   load_file_rows.row_comment%TYPE;
  
  BEGIN
    SELECT lf.*
      INTO vr_file_row
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    SELECT cs.column_name BULK COLLECT
      INTO vt_columns
      FROM load_file         lf
          ,load_csv_list     cl
          ,load_csv_settings cs
     WHERE lf.load_file_id = vr_file_row.load_file_id
       AND lf.load_csv_list_id = cl.load_csv_list_id
       AND cl.load_csv_list_id = cs.load_csv_list_id
     ORDER BY cs.num;
  
    FOR idx IN 1 .. vt_columns.count
    LOOP
      IF v_status IS NULL
      THEN
        CASE idx
          WHEN 1 THEN
            v_month := regexp_substr(vr_file_row.val_1, '^\w{3}');
            v_year  := regexp_substr(vr_file_row.val_1, '\d{2}$');
            CASE v_month
              WHEN 'янв' THEN
                vr_file_row.val_1 := '01.01.';
              WHEN 'фев' THEN
                vr_file_row.val_1 := '01.02.';
              WHEN 'мар' THEN
                vr_file_row.val_1 := '01.03.';
              WHEN 'апр' THEN
                vr_file_row.val_1 := '01.04.';
              WHEN 'май' THEN
                vr_file_row.val_1 := '01.05.';
              WHEN 'июн' THEN
                vr_file_row.val_1 := '01.06.';
              WHEN 'июл' THEN
                vr_file_row.val_1 := '01.07.';
              WHEN 'авг' THEN
                vr_file_row.val_1 := '01.08.';
              WHEN 'сен' THEN
                vr_file_row.val_1 := '01.09.';
              WHEN 'окт' THEN
                vr_file_row.val_1 := '01.10.';
              WHEN 'ноя' THEN
                vr_file_row.val_1 := '01.11.';
              WHEN 'дек' THEN
                vr_file_row.val_1 := '01.12.';
              ELSE
                v_comment := 'Некорректно заполнен месяц!';
                v_status  := pkg_load_file_to_table.get_error;
            END CASE;
            IF v_year IS NOT NULL
            THEN
              vr_yield.t_date_yield := to_date(vr_file_row.val_1 || v_year, 'dd.mm.rr');
            ELSE
              v_comment := 'Некорректно заполнен год!';
              v_status  := pkg_load_file_to_table.get_error;
            END IF;
          WHEN 2 THEN
            convert_perc_to_number(vr_file_row.val_2
                                  ,vt_columns(idx)
                                  ,vr_yield.conservative_min
                                  ,v_comment
                                  ,v_status);
          WHEN 3 THEN
            convert_perc_to_number(vr_file_row.val_3
                                  ,vt_columns(idx)
                                  ,vr_yield.conservative_max
                                  ,v_comment
                                  ,v_status);
          WHEN 4 THEN
            convert_perc_to_number(vr_file_row.val_4
                                  ,vt_columns(idx)
                                  ,vr_yield.base_min
                                  ,v_comment
                                  ,v_status);
          WHEN 5 THEN
            convert_perc_to_number(vr_file_row.val_5
                                  ,vt_columns(idx)
                                  ,vr_yield.base_max
                                  ,v_comment
                                  ,v_status);
          WHEN 6 THEN
            convert_perc_to_number(vr_file_row.val_6
                                  ,vt_columns(idx)
                                  ,vr_yield.aggressive_min
                                  ,v_comment
                                  ,v_status);
          WHEN 7 THEN
            convert_perc_to_number(vr_file_row.val_7
                                  ,vt_columns(idx)
                                  ,vr_yield.aggressive_max
                                  ,v_comment
                                  ,v_status);
          WHEN 8 THEN
            convert_perc_to_number(vr_file_row.val_8
                                  ,vt_columns(idx)
                                  ,vr_yield.aggressive_plus_min
                                  ,v_comment
                                  ,v_status);
          WHEN 9 THEN
            convert_perc_to_number(vr_file_row.val_9
                                  ,vt_columns(idx)
                                  ,vr_yield.aggressive_plus_max
                                  ,v_comment
                                  ,v_status);
          WHEN 10 THEN
            convert_perc_to_number(vr_file_row.val_10
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_prot_min
                                  ,v_comment
                                  ,v_status);
          WHEN 11 THEN
            convert_perc_to_number(vr_file_row.val_11
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_prot_max
                                  ,v_comment
                                  ,v_status);
          WHEN 12 THEN
            convert_perc_to_number(vr_file_row.val_12
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_peril_min
                                  ,v_comment
                                  ,v_status);
          WHEN 13 THEN
            convert_perc_to_number(vr_file_row.val_13
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_peril_max
                                  ,v_comment
                                  ,v_status);
          WHEN 14 THEN
            convert_perc_to_number(vr_file_row.val_14
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_prot_min
                                  ,v_comment
                                  ,v_status);
          WHEN 15 THEN
            convert_perc_to_number(vr_file_row.val_15
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_prot_max
                                  ,v_comment
                                  ,v_status);
          WHEN 16 THEN
            convert_perc_to_number(vr_file_row.val_16
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_peril_min
                                  ,v_comment
                                  ,v_status);
          WHEN 17 THEN
            convert_perc_to_number(vr_file_row.val_17
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_peril_max
                                  ,v_comment
                                  ,v_status);
          WHEN 18 THEN
            convert_perc_to_number(vr_file_row.val_18
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_change
                                  ,v_comment
                                  ,v_status);
          WHEN 19 THEN
            convert_perc_to_number(vr_file_row.val_19
                                  ,vt_columns(idx)
                                  ,vr_yield.total_petroleum_min
                                  ,v_comment
                                  ,v_status);
          WHEN 20 THEN
            convert_perc_to_number(vr_file_row.val_20
                                  ,vt_columns(idx)
                                  ,vr_yield.total_petroleum_max
                                  ,v_comment
                                  ,v_status);
          WHEN 21 THEN
            convert_perc_to_number(vr_file_row.val_21
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_change
                                  ,v_comment
                                  ,v_status);
          WHEN 22 THEN
            convert_perc_to_number(vr_file_row.val_22
                                  ,vt_columns(idx)
                                  ,vr_yield.total_gold_min
                                  ,v_comment
                                  ,v_status);
          WHEN 23 THEN
            convert_perc_to_number(vr_file_row.val_23
                                  ,vt_columns(idx)
                                  ,vr_yield.total_gold_max
                                  ,v_comment
                                  ,v_status);
        END CASE;
      END IF;
    END LOOP;
    IF v_status IS NULL
    THEN
      INSERT INTO t_reference_yield_profile
        (t_reference_yield_profile_id
        ,t_date_yield
        ,conservative_min
        ,conservative_max
        ,base_min
        ,base_max
        ,aggressive_min
        ,aggressive_max
        ,aggressive_plus_min
        ,aggressive_plus_max
        ,petroleum_prot_min
        ,petroleum_prot_max
        ,petroleum_peril_min
        ,petroleum_peril_max
        ,gold_prot_min
        ,gold_prot_max
        ,gold_peril_min
        ,gold_peril_max
        ,petroleum_change
        ,total_petroleum_min
        ,total_petroleum_max
        ,gold_change
        ,total_gold_min
        ,total_gold_max)
      VALUES
        (sq_t_reference_yield_profile.nextval
        ,vr_yield.t_date_yield
        ,vr_yield.conservative_min
        ,vr_yield.conservative_max
        ,vr_yield.base_min
        ,vr_yield.base_max
        ,vr_yield.aggressive_min
        ,vr_yield.aggressive_max
        ,vr_yield.aggressive_plus_min
        ,vr_yield.aggressive_plus_max
        ,vr_yield.petroleum_prot_min
        ,vr_yield.petroleum_prot_max
        ,vr_yield.petroleum_peril_min
        ,vr_yield.petroleum_peril_max
        ,vr_yield.gold_prot_min
        ,vr_yield.gold_prot_max
        ,vr_yield.gold_peril_min
        ,vr_yield.gold_peril_max
        ,vr_yield.petroleum_change
        ,vr_yield.total_petroleum_min
        ,vr_yield.total_petroleum_max
        ,vr_yield.gold_change
        ,vr_yield.total_gold_min
        ,vr_yield.total_gold_max);
    
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_row_comment       => NULL);
    ELSE
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_error
                                           ,par_row_comment       => v_comment
                                           ,par_is_checked        => 0);
    END IF;
  END load_yield_for_profile_row;

  -- Проверяем и приводим к нормальному виду
  PROCEDURE check_yield_for_profile_row
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    vr_file_row load_file_rows%ROWTYPE;
    vt_columns  tt_one_col;
  
    PROCEDURE check_number
    (
      par_value       VARCHAR2
     ,par_column_name VARCHAR2
     ,par_comment     OUT VARCHAR2
     ,par_status      OUT NUMBER
    ) IS
    BEGIN
      IF NOT regexp_like(par_value, '((-?\d{1,3},\d{1,2})|(0))%')
      THEN
        par_comment := 'Поле "' || par_column_name || '" содержит некорректное значение: "' ||
                       par_value || '"!';
        par_status  := pkg_load_file_to_table.get_error;
      END IF;
    END check_number;
  BEGIN
    SELECT lf.*
      INTO vr_file_row
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    SELECT cs.column_name BULK COLLECT
      INTO vt_columns
      FROM load_file         lf
          ,load_csv_list     cl
          ,load_csv_settings cs
     WHERE lf.load_file_id = vr_file_row.load_file_id
       AND lf.load_csv_list_id = cl.load_csv_list_id
       AND cl.load_csv_list_id = cs.load_csv_list_id
     ORDER BY cs.num;
  
    FOR idx IN 1 .. vt_columns.count
    LOOP
      IF par_status IS NULL
      THEN
        CASE idx
        -- Проверка даты
          WHEN 1 THEN
            IF NOT regexp_like(vr_file_row.val_1, '^\w{3}\.\d{2}$')
            THEN
              par_comment := 'Некорректно заполнено поле "Дата": "' || vr_file_row.val_1 || '"!';
              par_status  := pkg_load_file_to_table.get_error;
            ELSIF regexp_substr(vr_file_row.val_1, '^\w{3}') NOT IN
                  ('янв'
                  ,'фев'
                  ,'мар'
                  ,'апр'
                  ,'май'
                  ,'июн'
                  ,'июл'
                  ,'авг'
                  ,'сен'
                  ,'окт'
                  ,'ноя'
                  ,'дек')
            THEN
              par_comment := 'Некорректно заполнен месяц в поле "Дата": "' ||
                             regexp_substr(vr_file_row.val_1, '^\w{3}') || '"!';
              par_status  := pkg_load_file_to_table.get_error;
            END IF;
          WHEN 2 THEN
            check_number(vr_file_row.val_2, vt_columns(idx), par_comment, par_status);
          WHEN 3 THEN
            check_number(vr_file_row.val_3, vt_columns(idx), par_comment, par_status);
          WHEN 4 THEN
            check_number(vr_file_row.val_4, vt_columns(idx), par_comment, par_status);
          WHEN 5 THEN
            check_number(vr_file_row.val_5, vt_columns(idx), par_comment, par_status);
          WHEN 6 THEN
            check_number(vr_file_row.val_6, vt_columns(idx), par_comment, par_status);
          WHEN 7 THEN
            check_number(vr_file_row.val_7, vt_columns(idx), par_comment, par_status);
          WHEN 8 THEN
            check_number(vr_file_row.val_8, vt_columns(idx), par_comment, par_status);
          WHEN 9 THEN
            check_number(vr_file_row.val_9, vt_columns(idx), par_comment, par_status);
          WHEN 10 THEN
            check_number(vr_file_row.val_10, vt_columns(idx), par_comment, par_status);
          WHEN 11 THEN
            check_number(vr_file_row.val_11, vt_columns(idx), par_comment, par_status);
          WHEN 12 THEN
            check_number(vr_file_row.val_12, vt_columns(idx), par_comment, par_status);
          WHEN 13 THEN
            check_number(vr_file_row.val_13, vt_columns(idx), par_comment, par_status);
          WHEN 14 THEN
            check_number(vr_file_row.val_14, vt_columns(idx), par_comment, par_status);
          WHEN 15 THEN
            check_number(vr_file_row.val_15, vt_columns(idx), par_comment, par_status);
          WHEN 16 THEN
            check_number(vr_file_row.val_16, vt_columns(idx), par_comment, par_status);
          WHEN 17 THEN
            check_number(vr_file_row.val_17, vt_columns(idx), par_comment, par_status);
          WHEN 18 THEN
            check_number(vr_file_row.val_18, vt_columns(idx), par_comment, par_status);
          WHEN 19 THEN
            check_number(vr_file_row.val_19, vt_columns(idx), par_comment, par_status);
          WHEN 20 THEN
            check_number(vr_file_row.val_20, vt_columns(idx), par_comment, par_status);
          WHEN 21 THEN
            check_number(vr_file_row.val_21, vt_columns(idx), par_comment, par_status);
          WHEN 22 THEN
            check_number(vr_file_row.val_22, vt_columns(idx), par_comment, par_status);
          WHEN 23 THEN
            check_number(vr_file_row.val_23, vt_columns(idx), par_comment, par_status);
        END CASE;
      END IF;
    END LOOP;
    IF par_status IS NULL
    THEN
      par_status  := pkg_load_file_to_table.get_checked;
      par_comment := NULL;
    END IF;
  END check_yield_for_profile_row;

  PROCEDURE delete_yield(par_load_csv_list_id NUMBER) IS
  BEGIN
    DELETE FROM t_reference_yield;
  END;

  PROCEDURE load_yield_row(par_load_file_rows_id NUMBER) IS
    vr_file_row load_file_rows%ROWTYPE;
    v_month     VARCHAR2(3);
    v_year      VARCHAR2(2);
    vt_columns  tt_one_col;
    vr_yield    t_reference_yield%ROWTYPE;
    v_status    load_file_rows.row_status%TYPE;
    v_comment   load_file_rows.row_comment%TYPE;
  
  BEGIN
    SELECT lf.*
      INTO vr_file_row
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    SELECT cs.column_name BULK COLLECT
      INTO vt_columns
      FROM load_file         lf
          ,load_csv_list     cl
          ,load_csv_settings cs
     WHERE lf.load_file_id = vr_file_row.load_file_id
       AND lf.load_csv_list_id = cl.load_csv_list_id
       AND cl.load_csv_list_id = cs.load_csv_list_id
     ORDER BY cs.num;
  
    FOR idx IN 1 .. vt_columns.count
    LOOP
      IF v_status IS NULL
      THEN
        CASE idx
          WHEN 1 THEN
            v_month := regexp_substr(vr_file_row.val_1, '^\w{3}');
            v_year  := regexp_substr(vr_file_row.val_1, '\d{2}$');
            CASE v_month
              WHEN 'янв' THEN
                vr_file_row.val_1 := '01.01.';
              WHEN 'фев' THEN
                vr_file_row.val_1 := '01.02.';
              WHEN 'мар' THEN
                vr_file_row.val_1 := '01.03.';
              WHEN 'апр' THEN
                vr_file_row.val_1 := '01.04.';
              WHEN 'май' THEN
                vr_file_row.val_1 := '01.05.';
              WHEN 'июн' THEN
                vr_file_row.val_1 := '01.06.';
              WHEN 'июл' THEN
                vr_file_row.val_1 := '01.07.';
              WHEN 'авг' THEN
                vr_file_row.val_1 := '01.08.';
              WHEN 'сен' THEN
                vr_file_row.val_1 := '01.09.';
              WHEN 'окт' THEN
                vr_file_row.val_1 := '01.10.';
              WHEN 'ноя' THEN
                vr_file_row.val_1 := '01.11.';
              WHEN 'дек' THEN
                vr_file_row.val_1 := '01.12.';
              ELSE
                v_comment := 'Некорректно заполнен месяц!';
                v_status  := pkg_load_file_to_table.get_error;
            END CASE;
            IF v_year IS NOT NULL
            THEN
              vr_yield.t_date_yield := to_date(vr_file_row.val_1 || v_year, 'dd.mm.rr');
            ELSE
              v_comment := 'Некорректно заполнен год!';
              v_status  := pkg_load_file_to_table.get_error;
            END IF;
          WHEN 2 THEN
            convert_perc_to_number(vr_file_row.val_2
                                  ,vt_columns(idx)
                                  ,vr_yield.conservative_min
                                  ,v_comment
                                  ,v_status);
          WHEN 3 THEN
            convert_perc_to_number(vr_file_row.val_3
                                  ,vt_columns(idx)
                                  ,vr_yield.conservative_max
                                  ,v_comment
                                  ,v_status);
          WHEN 4 THEN
            convert_perc_to_number(vr_file_row.val_4
                                  ,vt_columns(idx)
                                  ,vr_yield.base_min
                                  ,v_comment
                                  ,v_status);
          WHEN 5 THEN
            convert_perc_to_number(vr_file_row.val_5
                                  ,vt_columns(idx)
                                  ,vr_yield.base_max
                                  ,v_comment
                                  ,v_status);
          WHEN 6 THEN
            convert_perc_to_number(vr_file_row.val_6
                                  ,vt_columns(idx)
                                  ,vr_yield.aggressive_min
                                  ,v_comment
                                  ,v_status);
          WHEN 7 THEN
            convert_perc_to_number(vr_file_row.val_7
                                  ,vt_columns(idx)
                                  ,vr_yield.aggressive_max
                                  ,v_comment
                                  ,v_status);
          WHEN 8 THEN
            convert_perc_to_number(vr_file_row.val_8
                                  ,vt_columns(idx)
                                  ,vr_yield.aggressive_plus_min
                                  ,v_comment
                                  ,v_status);
          WHEN 9 THEN
            convert_perc_to_number(vr_file_row.val_9
                                  ,vt_columns(idx)
                                  ,vr_yield.aggressive_plus_max
                                  ,v_comment
                                  ,v_status);
          WHEN 10 THEN
            convert_perc_to_number(vr_file_row.val_10
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_prot_min
                                  ,v_comment
                                  ,v_status);
          WHEN 11 THEN
            convert_perc_to_number(vr_file_row.val_11
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_prot_max
                                  ,v_comment
                                  ,v_status);
          WHEN 12 THEN
            convert_perc_to_number(vr_file_row.val_12
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_peril_min
                                  ,v_comment
                                  ,v_status);
          WHEN 13 THEN
            convert_perc_to_number(vr_file_row.val_13
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_peril_max
                                  ,v_comment
                                  ,v_status);
          WHEN 14 THEN
            convert_perc_to_number(vr_file_row.val_14
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_prot_min
                                  ,v_comment
                                  ,v_status);
          WHEN 15 THEN
            convert_perc_to_number(vr_file_row.val_15
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_prot_max
                                  ,v_comment
                                  ,v_status);
          WHEN 16 THEN
            convert_perc_to_number(vr_file_row.val_16
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_peril_min
                                  ,v_comment
                                  ,v_status);
          WHEN 17 THEN
            convert_perc_to_number(vr_file_row.val_17
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_peril_max
                                  ,v_comment
                                  ,v_status);
          WHEN 18 THEN
            convert_perc_to_number(vr_file_row.val_18
                                  ,vt_columns(idx)
                                  ,vr_yield.petroleum_change
                                  ,v_comment
                                  ,v_status);
          WHEN 19 THEN
            convert_perc_to_number(vr_file_row.val_19
                                  ,vt_columns(idx)
                                  ,vr_yield.total_petroleum_min
                                  ,v_comment
                                  ,v_status);
          WHEN 20 THEN
            convert_perc_to_number(vr_file_row.val_20
                                  ,vt_columns(idx)
                                  ,vr_yield.total_petroleum_max
                                  ,v_comment
                                  ,v_status);
          WHEN 21 THEN
            convert_perc_to_number(vr_file_row.val_21
                                  ,vt_columns(idx)
                                  ,vr_yield.gold_change
                                  ,v_comment
                                  ,v_status);
          WHEN 22 THEN
            convert_perc_to_number(vr_file_row.val_22
                                  ,vt_columns(idx)
                                  ,vr_yield.total_gold_min
                                  ,v_comment
                                  ,v_status);
          WHEN 23 THEN
            convert_perc_to_number(vr_file_row.val_23
                                  ,vt_columns(idx)
                                  ,vr_yield.total_gold_max
                                  ,v_comment
                                  ,v_status);
        END CASE;
      END IF;
    END LOOP;
    IF v_status IS NULL
    THEN
      INSERT INTO t_reference_yield
        (t_reference_yield_id
        ,t_date_yield
        ,conservative_min
        ,conservative_max
        ,base_min
        ,base_max
        ,aggressive_min
        ,aggressive_max
        ,aggressive_plus_min
        ,aggressive_plus_max
        ,petroleum_prot_min
        ,petroleum_prot_max
        ,petroleum_peril_min
        ,petroleum_peril_max
        ,gold_prot_min
        ,gold_prot_max
        ,gold_peril_min
        ,gold_peril_max
        ,petroleum_change
        ,total_petroleum_min
        ,total_petroleum_max
        ,gold_change
        ,total_gold_min
        ,total_gold_max)
      VALUES
        (sq_t_reference_yield.nextval
        ,vr_yield.t_date_yield
        ,vr_yield.conservative_min
        ,vr_yield.conservative_max
        ,vr_yield.base_min
        ,vr_yield.base_max
        ,vr_yield.aggressive_min
        ,vr_yield.aggressive_max
        ,vr_yield.aggressive_plus_min
        ,vr_yield.aggressive_plus_max
        ,vr_yield.petroleum_prot_min
        ,vr_yield.petroleum_prot_max
        ,vr_yield.petroleum_peril_min
        ,vr_yield.petroleum_peril_max
        ,vr_yield.gold_prot_min
        ,vr_yield.gold_prot_max
        ,vr_yield.gold_peril_min
        ,vr_yield.gold_peril_max
        ,vr_yield.petroleum_change
        ,vr_yield.total_petroleum_min
        ,vr_yield.total_petroleum_max
        ,vr_yield.gold_change
        ,vr_yield.total_gold_min
        ,vr_yield.total_gold_max);
    
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_row_comment       => NULL);
    ELSE
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_error
                                           ,par_row_comment       => v_comment
                                           ,par_is_checked        => 0);
    END IF;
  END load_yield_row;

  -- Проверяем и приводим к нормальному виду
  PROCEDURE check_yield_row
  (
    par_load_file_rows_id NUMBER
   ,par_status            OUT VARCHAR2
   ,par_comment           OUT VARCHAR2
  ) IS
    vr_file_row load_file_rows%ROWTYPE;
    vt_columns  tt_one_col;
  
    PROCEDURE check_number
    (
      par_value       VARCHAR2
     ,par_column_name VARCHAR2
     ,par_comment     OUT VARCHAR2
     ,par_status      OUT NUMBER
    ) IS
    BEGIN
      IF NOT regexp_like(par_value, '((-?\d{1,3},\d{1,2})|(0))%')
      THEN
        par_comment := 'Поле "' || par_column_name || '" содержит некорректное значение: "' ||
                       par_value || '"!';
        par_status  := pkg_load_file_to_table.get_error;
      END IF;
    END check_number;
  BEGIN
    SELECT lf.*
      INTO vr_file_row
      FROM load_file_rows lf
     WHERE lf.load_file_rows_id = par_load_file_rows_id;
  
    SELECT cs.column_name BULK COLLECT
      INTO vt_columns
      FROM load_file         lf
          ,load_csv_list     cl
          ,load_csv_settings cs
     WHERE lf.load_file_id = vr_file_row.load_file_id
       AND lf.load_csv_list_id = cl.load_csv_list_id
       AND cl.load_csv_list_id = cs.load_csv_list_id
     ORDER BY cs.num;
  
    FOR idx IN 1 .. vt_columns.count
    LOOP
      IF par_status IS NULL
      THEN
        CASE idx
        -- Проверка даты
          WHEN 1 THEN
            IF NOT regexp_like(vr_file_row.val_1, '^\w{3}\.\d{2}$')
            THEN
              par_comment := 'Некорректно заполнено поле "Дата": "' || vr_file_row.val_1 || '"!';
              par_status  := pkg_load_file_to_table.get_error;
            ELSIF regexp_substr(vr_file_row.val_1, '^\w{3}') NOT IN
                  ('янв'
                  ,'фев'
                  ,'мар'
                  ,'апр'
                  ,'май'
                  ,'июн'
                  ,'июл'
                  ,'авг'
                  ,'сен'
                  ,'окт'
                  ,'ноя'
                  ,'дек')
            THEN
              par_comment := 'Некорректно заполнен месяц в поле "Дата": "' ||
                             regexp_substr(vr_file_row.val_1, '^\w{3}') || '"!';
              par_status  := pkg_load_file_to_table.get_error;
            END IF;
          WHEN 2 THEN
            check_number(vr_file_row.val_2, vt_columns(idx), par_comment, par_status);
          WHEN 3 THEN
            check_number(vr_file_row.val_3, vt_columns(idx), par_comment, par_status);
          WHEN 4 THEN
            check_number(vr_file_row.val_4, vt_columns(idx), par_comment, par_status);
          WHEN 5 THEN
            check_number(vr_file_row.val_5, vt_columns(idx), par_comment, par_status);
          WHEN 6 THEN
            check_number(vr_file_row.val_6, vt_columns(idx), par_comment, par_status);
          WHEN 7 THEN
            check_number(vr_file_row.val_7, vt_columns(idx), par_comment, par_status);
          WHEN 8 THEN
            check_number(vr_file_row.val_8, vt_columns(idx), par_comment, par_status);
          WHEN 9 THEN
            check_number(vr_file_row.val_9, vt_columns(idx), par_comment, par_status);
          WHEN 10 THEN
            check_number(vr_file_row.val_10, vt_columns(idx), par_comment, par_status);
          WHEN 11 THEN
            check_number(vr_file_row.val_11, vt_columns(idx), par_comment, par_status);
          WHEN 12 THEN
            check_number(vr_file_row.val_12, vt_columns(idx), par_comment, par_status);
          WHEN 13 THEN
            check_number(vr_file_row.val_13, vt_columns(idx), par_comment, par_status);
          WHEN 14 THEN
            check_number(vr_file_row.val_14, vt_columns(idx), par_comment, par_status);
          WHEN 15 THEN
            check_number(vr_file_row.val_15, vt_columns(idx), par_comment, par_status);
          WHEN 16 THEN
            check_number(vr_file_row.val_16, vt_columns(idx), par_comment, par_status);
          WHEN 17 THEN
            check_number(vr_file_row.val_17, vt_columns(idx), par_comment, par_status);
          WHEN 18 THEN
            check_number(vr_file_row.val_18, vt_columns(idx), par_comment, par_status);
          WHEN 19 THEN
            check_number(vr_file_row.val_19, vt_columns(idx), par_comment, par_status);
          WHEN 20 THEN
            check_number(vr_file_row.val_20, vt_columns(idx), par_comment, par_status);
          WHEN 21 THEN
            check_number(vr_file_row.val_21, vt_columns(idx), par_comment, par_status);
          WHEN 22 THEN
            check_number(vr_file_row.val_22, vt_columns(idx), par_comment, par_status);
          WHEN 23 THEN
            check_number(vr_file_row.val_23, vt_columns(idx), par_comment, par_status);
        END CASE;
      END IF;
    END LOOP;
    IF par_status IS NULL
    THEN
      par_status  := pkg_load_file_to_table.get_checked;
      par_comment := NULL;
    END IF;
  END check_yield_row;

  PROCEDURE delete_stocks_and_bonds(par_load_csv_list_id NUMBER) IS
  BEGIN
    DELETE FROM t_stocks_and_bonds;
  END;

  /*
    Байтин А.
    Загрузка справочника акций-облигаций
  */
  PROCEDURE load_stocks_and_bonds_row(par_load_file_rows_id NUMBER) IS
  BEGIN
    INSERT INTO t_stocks_and_bonds
      (t_stocks_and_bonds_id, strategy, stock_or_bond, numb, NAME, part)
      SELECT sq_t_stocks_and_bonds.nextval
            ,CASE upper(fr.val_1)
               WHEN 'СБАЛАНСИРОВАННАЯ' THEN
                0
               WHEN 'АГРЕССИВНАЯ' THEN
                1
               WHEN 'КОНСЕРВАТИВНАЯ' THEN
                2
               WHEN 'АГРЕССИВНАЯ ПЛЮС' THEN
                3
               WHEN 'НЕФТЬ' THEN
                4
               WHEN 'ЗОЛОТО' THEN
                5
             END
            ,CASE upper(fr.val_2)
               WHEN 'АКЦИИ' THEN
                0
               WHEN 'ОБЛИГАЦИИ' THEN
                1
               WHEN 'ДЕПОЗИТЫ' THEN
                2
               WHEN 'ФЬЮЧЕРСЫ' THEN
                3
             END
            ,to_number(fr.val_3)
            ,fr.val_4
            ,fr.val_5
        FROM load_file_rows fr
       WHERE fr.load_file_rows_id = par_load_file_rows_id;
    IF SQL%ROWCOUNT != 0
    THEN
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_is_checked        => 1);
    ELSE
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_not_loaded
                                           ,par_Row_Comment       => 'Не найдена загружаемая срока'
                                           ,par_is_checked        => 0);
    END IF;
  END load_stocks_and_bonds_row;

  PROCEDURE delete_fee_reserve(par_load_csv_list_id NUMBER) IS
  BEGIN
    DELETE FROM t_fee_reserve;
  END;

  /*
    Байтин А.
    Загрузка справочника взнос-резерв
  */
  PROCEDURE load_fee_reserve_row(par_load_file_rows_id NUMBER) IS
  BEGIN
    INSERT INTO t_fee_reserve
      (t_fee_reserve_id, program, period, year_num, strategy, reserve_in_fee_part)
      SELECT sq_t_fee_reserve.nextval
            ,fr.val_1
            ,to_number(fr.val_2)
            ,to_number(fr.val_3)
            ,CASE upper(fr.val_4)
               WHEN 'СБАЛАНСИРОВАННАЯ' THEN
                0
               WHEN 'АГРЕССИВНАЯ' THEN
                1
               WHEN 'КОНСЕРВАТИВНАЯ' THEN
                2
               WHEN 'АГРЕССИВНАЯ ПЛЮС' THEN
                3
             END
            ,to_number(fr.val_5, '990D999999999999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        FROM load_file_rows fr
       WHERE fr.load_file_rows_id = par_load_file_rows_id;
    IF SQL%ROWCOUNT != 0
    THEN
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_is_checked        => 1);
    ELSE
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_not_loaded
                                           ,par_Row_Comment       => 'Не найдена загружаемая срока'
                                           ,par_is_checked        => 0);
    END IF;
  END load_fee_reserve_row;

  PROCEDURE delete_fonds(par_load_csv_list_id NUMBER) IS
  BEGIN
    DELETE FROM t_fonds;
  END delete_fonds;

  /*
    Байтин А.
    Загрузка справочника фондов
  */
  PROCEDURE load_fonds_row(par_load_file_rows_id NUMBER) IS
  BEGIN
    INSERT INTO t_fonds
      (t_fonds_id, strategy, stock_or_bond, part)
      SELECT sq_t_fonds.nextval
            ,CASE upper(fr.val_1)
               WHEN 'СБАЛАНСИРОВАННАЯ' THEN
                0
               WHEN 'АГРЕССИВНАЯ' THEN
                1
               WHEN 'КОНСЕРВАТИВНАЯ' THEN
                2
               WHEN 'АГРЕССИВНАЯ ПЛЮС' THEN
                3
               WHEN 'НЕФТЬ' THEN
                4
               WHEN 'ЗОЛОТО' THEN
                5
             END
            ,CASE upper(fr.val_2)
               WHEN 'АКЦИИ' THEN
                0
               WHEN 'ОБЛИГАЦИИ' THEN
                1
               WHEN 'ДЕПОЗИТЫ' THEN
                2
               WHEN 'ФЬЮЧЕРСЫ' THEN
                3
             END
            ,to_number(fr.val_3, '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''')
        FROM load_file_rows fr
       WHERE fr.load_file_rows_id = par_load_file_rows_id;
    IF SQL%ROWCOUNT != 0
    THEN
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_is_checked        => 1);
    ELSE
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_not_loaded
                                           ,par_Row_Comment       => 'Не найдена загружаемая срока'
                                           ,par_is_checked        => 0);
    END IF;
  END load_fonds_row;

  PROCEDURE delete_dynamics_of_assets(par_load_csv_list_id NUMBER) IS
  BEGIN
    DELETE FROM t_dynamics_of_assets;
  END delete_dynamics_of_assets;

  /*
    Байтин А.
    Загрузка справочника динамики стоимости активов
  */
  PROCEDURE load_dynamics_of_assets_row(par_load_file_rows_id NUMBER) IS
  BEGIN
    INSERT INTO t_dynamics_of_assets
      (t_dynamics_of_assets_id
      ,change_date
      ,cons_6_months
      ,cons_from_year_begining
      ,cons_year
      ,cons_whole_history
      ,bal_6_months
      ,bal_from_year_begining
      ,bal_year
      ,bal_whole_history
      ,aggr_6_months
      ,aggr_from_year_begining
      ,aggr_year
      ,aggr_whole_history
      ,aggr_pl_6_months
      ,aggr_pl_from_year_begining
      ,aggr_pl_year
      ,aggr_pl_whole_history
      ,common_6_months
      ,common_from_year_begining
      ,common_year
      ,common_whole_history)
      SELECT sq_t_dynamics_of_assets.nextval
            ,to_date(fr.val_1, 'dd.mm.yyyy')
            ,to_number(REPLACE(fr.val_2, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_3, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_4, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_5, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_6, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_7, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_8, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_9, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_10, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_11, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_12, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_13, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_14, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_15, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_16, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_17, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_18, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_19, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_20, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
            ,to_number(REPLACE(fr.val_21, '%'), '990D999', 'NLS_NUMERIC_CHARACTERS = '',.''') / 100
        FROM load_file_rows fr
       WHERE fr.load_file_rows_id = par_load_file_rows_id;
    IF SQL%ROWCOUNT != 0
    THEN
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_loaded
                                           ,par_is_checked        => 1);
    ELSE
      pkg_load_file_to_table.set_row_status(par_load_file_rows_id => par_load_file_rows_id
                                           ,par_row_status        => pkg_load_file_to_table.get_not_loaded
                                           ,par_Row_Comment       => 'Не найдена загружаемая срока'
                                           ,par_is_checked        => 0);
    END IF;
  END load_dynamics_of_assets_row;

END PKG_PERSONAL_PROFILE_DICTS;
/
