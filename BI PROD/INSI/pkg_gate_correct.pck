CREATE OR REPLACE PACKAGE PKG_GATE_CORRECT IS
  PROCEDURE correct_table;
END PKG_GATE_CORRECT;
/
CREATE OR REPLACE PACKAGE BODY PKG_GATE_CORRECT IS
  PROCEDURE correct_table IS
  
    CURSOR cur_t(p_tab_name VARCHAR2) IS
      SELECT cols.column_name AS NAME
        FROM sys.user_tab_columns cols
       WHERE cols.table_name = p_tab_name
         AND cols.column_name NOT IN ('ROW_STATUS', 'GATE_PACKAGE_ID', 'CODE')
         AND cols.NULLABLE = 'N'
       ORDER BY column_id;
  
    CURSOR cur_exp_line IS
      SELECT * FROM GATE_OBJ_EXPORT_LINE;
  
  BEGIN
  
    FOR rec_exp_line IN cur_exp_line
    LOOP
      FOR rec_t IN cur_t(rec_exp_line.export_line)
      LOOP
        EXECUTE IMMEDIATE ' alter table ' || rec_exp_line.export_line || ' modify ' || rec_t.name ||
                          ' null ';
      END LOOP;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_gate.EventRet := pkg_gate.InserEvent('PKG_GATE_CORRECT.correct_table: ' || SQLERRM
                                              ,pkg_gate.event_error);
  END correct_table;
END PKG_GATE_CORRECT;
/
