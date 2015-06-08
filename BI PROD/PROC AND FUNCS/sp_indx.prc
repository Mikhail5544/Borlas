CREATE OR REPLACE PROCEDURE sp_indx AS
  v_i NUMBER;
  v_n NUMBER;
  v_indx VARCHAR2(2);
  v_cols VARCHAR2(1000);
  v_sql VARCHAR2(32000);
  v_prev_tab VARCHAR2(30);
BEGIN
  ents.prepare_ve_error;

  FOR v_r IN ( SELECT DISTINCT cc.table_name, cc.constraint_name, cc.column_name, cc.position
               FROM tmp_uc uc
                    inner join tmp_ucc cc ON cc.owner = uc.owner AND cc.constraint_name = uc.constraint_name
--                    inner join tmp_uc uc_r on uc_r.owner = uc.r_owner
--                                              and uc_r.constraint_name = uc.r_constraint_name
--                    inner join tmp_uc uc_rt on uc_rt.owner = uc_r.owner
--                                               and uc_rt.table_name = uc_r.table_name
               WHERE uc.constraint_type = 'R'
--                     and uc_rt.constraint_type = 'R'
                     AND NOT EXISTS ( SELECT 1
                                      FROM user_indexes ui
                                           inner join user_ind_columns uic ON uic.index_name = ui.index_name
                                       WHERE uic.table_name = cc.table_name
                                             AND uic.column_name = cc.column_name
                                             AND uic.column_position = cc.position
                                    )
--                     and uc.table_name = 'T_RULE_LINE'
               ORDER BY cc.table_name, cc.constraint_name, cc.position DESC
             ) LOOP

    IF (v_prev_tab IS NULL) OR (v_prev_tab <> v_r.table_name) THEN
      v_prev_tab := v_r.table_name;
      v_i := 0;
    END IF;

    IF v_r.position = 1 THEN
      -- Определение номера
      WHILE v_i < 100 LOOP
        v_i := v_i + 1;
        v_indx := v_i;
        IF LENGTH(v_indx) = 1 THEN
          v_indx := '0' || v_indx;
        END IF;
        BEGIN
          SELECT 1 INTO v_n
          FROM user_indexes ui
          WHERE ui.index_name = 'IX_' || v_r.table_name || '_' || v_indx;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            EXIT;
        END;
      END LOOP;

      v_sql := 'create index IX_' || v_r.table_name || '_' || v_indx || ' on ' || v_r.table_name || '('
        || v_r.column_name || v_cols || ');';
      dbms_output.put_line(v_sql);
      v_cols := '';
    ELSE
      v_cols := ', ' || v_r.column_name || v_cols;
    END IF;

  END LOOP;
END;
/

