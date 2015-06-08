CREATE OR REPLACE PACKAGE PKG_JOB_POSITION_FRM IS

  -- Author  : VESELEK
  -- Created : 22.07.2013 10:29:52
  -- Purpose : Вспомогательный пакет для обработки мутации таблиц

  TYPE tt_num IS TABLE OF NUMBER;
  TYPE tt_char IS TABLE OF VARCHAR2(2000);

  gv_tt_num  tt_num := tt_num();
  gv_tt_char tt_char := tt_char();

  PROCEDURE CLEAR_TABLE;
  PROCEDURE UPDATE_TABLE;
  PROCEDURE INSERT_TMP_VALUES
  (
    p_brief  VARCHAR2
   ,p_pos_id NUMBER
  );

END PKG_JOB_POSITION_FRM;
/
CREATE OR REPLACE PACKAGE BODY PKG_JOB_POSITION_FRM IS

  PROCEDURE CLEAR_TABLE IS
  BEGIN
    gv_tt_num.delete();
    gv_tt_char.delete();
  END;

  PROCEDURE UPDATE_TABLE IS
  BEGIN
  
    FORALL i IN 1 .. gv_tt_num.count
      UPDATE ins.t_job_position jb
         SET jb.is_enabled = 0
       WHERE jb.t_job_position_id != gv_tt_num(i)
         AND jb.dep_brief =
             (SELECT jb1.dep_brief FROM t_job_position jb1 WHERE jb1.t_job_position_id = gv_tt_num(i));
  
  END;

  PROCEDURE INSERT_TMP_VALUES
  (
    p_brief  VARCHAR2
   ,p_pos_id NUMBER
  ) IS
  BEGIN
    FOR i IN 1 .. gv_tt_char.count
    LOOP
    
      IF gv_tt_char(i) = p_brief
      THEN
        RAISE_APPLICATION_ERROR(-20001, 'Все плохо!');
      END IF;
    
    END LOOP;
  
    gv_tt_num.extend(1);
    gv_tt_num(gv_tt_num.last) := p_pos_id;
  
    gv_tt_char.extend(1);
    gv_tt_char(gv_tt_char.last) := p_brief;
  
  END;

END PKG_JOB_POSITION_FRM;
/
