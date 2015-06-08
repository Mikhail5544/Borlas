CREATE OR REPLACE PACKAGE acc_link IS

  TYPE t_r_Acc_Link_Tree IS RECORD(
     NAME      VARCHAR2(255)
    ,Sort_Str  VARCHAR2(255)
    ,Node_Type NUMBER
    ,ID        NUMBER
    ,Parent_ID NUMBER);

  TYPE t_t_Acc_Link_Tree IS TABLE OF t_r_Acc_Link_Tree;

  --Исходные данные для дерева привязки счетов
  PROCEDURE Build_Acc_Link_Tree(p_Date DATE);
  --Построить дерево привязки счетов
  FUNCTION Get_Acc_Link_Tree(p_Date DATE) RETURN t_t_Acc_Link_Tree
    PIPELINED;

END acc_link;
/
CREATE OR REPLACE PACKAGE BODY "ACC_LINK" IS

  --Исходные данные для дерева привязки счетов
  PROCEDURE Build_Acc_Link_Tree(p_Date DATE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_Analytic_Type Analytic_Type%ROWTYPE;
    CURSOR c_Analytic_Type IS
      SELECT * FROM Analytic_Type att WHERE att.is_acc_link = 1 ORDER BY att.name;
    i     NUMBER;
    c     NUMBER;
    n     NUMBER;
    x     NUMBER;
    v_SQL VARCHAR2(4000);
  BEGIN
    --Очистить временную таблицу 
    DELETE t_Acc_Link;
    --Заголовок
    INSERT INTO t_Acc_Link
      (NAME, Sort_Str, Node_Type, ID, Parent_ID)
    VALUES
      ('Типы аналитики', '00', 0, 0, NULL);
    --Названия типов аналитики
    i := 0;
    OPEN c_Analytic_Type;
    LOOP
      FETCH c_Analytic_Type
        INTO v_Analytic_Type;
      EXIT WHEN c_Analytic_Type%NOTFOUND;
      BEGIN
        i := i + 1;
        INSERT INTO t_Acc_Link
          (NAME, Sort_Str, Node_Type, ID, Parent_ID)
        VALUES
          (v_Analytic_Type.Name
          ,TRIM(to_char(i, '09'))
          ,0
          ,v_Analytic_Type.Analytic_Type_Id * 10000000
          ,0);
        --Записать объекты по типу аналитики 
        v_SQL := upper(v_Analytic_Type.Obj_List_Sql_View);
        x     := instr(v_SQL, ':P_OBJ_DATE');
        IF (x > 0)
        THEN
          v_SQL := substr(v_SQL, 1, x - 1) || 'to_date(''' || to_char(p_Date, 'yyyymmdd') ||
                   ''', ''yyyymmdd'')' || substr(v_SQL, x + 11, length(v_SQL) - x - 10);
        END IF;
        v_SQL := 'insert into t_Acc_Link select tt.obj_name, ''' || TRIM(to_char(i, '09')) ||
                 ''' || tt.obj_name, ' || '1, tt.obj_id + ' ||
                 to_char(v_Analytic_Type.Analytic_Type_Id * 10000000) || ', ' ||
                 to_char(v_Analytic_Type.Analytic_Type_Id * 10000000) || ' from (' || v_SQL || ') tt';
        c     := dbms_sql.open_cursor;
        dbms_sql.parse(c, v_SQL, dbms_sql.native);
        n := dbms_sql.execute(c);
        dbms_sql.close_cursor(c);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
      END;
    END LOOP;
    CLOSE c_Analytic_Type;
    COMMIT;
  END;

  --Построить дерево привязки счетов
  FUNCTION Get_Acc_Link_Tree(p_Date DATE) RETURN t_t_Acc_Link_Tree
    PIPELINED IS
    v_r_Acc_Link_Tree t_r_Acc_Link_Tree;
    v_Acc_Link        t_Acc_Link%ROWTYPE;
    CURSOR c_Acc_Link IS
      SELECT * FROM t_Acc_Link t ORDER BY t.sort_str;
  BEGIN
    Build_Acc_Link_Tree(p_Date);
    OPEN c_Acc_Link;
    LOOP
      FETCH c_Acc_Link
        INTO v_Acc_Link;
      EXIT WHEN c_Acc_Link%NOTFOUND;
      BEGIN
        v_r_Acc_Link_Tree.Name      := v_Acc_Link.Name;
        v_r_Acc_Link_Tree.Sort_Str  := v_Acc_Link.Sort_Str;
        v_r_Acc_Link_Tree.Node_Type := v_Acc_Link.Node_Type;
        v_r_Acc_Link_Tree.ID        := v_Acc_Link.ID;
        v_r_Acc_Link_Tree.Parent_ID := v_Acc_Link.Parent_ID;
        PIPE ROW(v_r_Acc_Link_Tree);
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line(SQLERRM);
      END;
    END LOOP;
    CLOSE c_Acc_Link;
    RETURN;
  END;

END;
/
