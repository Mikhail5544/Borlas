CREATE OR REPLACE PACKAGE PKG_AUTOSQ AS
  /**
  * Нумератор  
  *
  * @author Surovtsev Alexey 
  * @version 1.0 
  */

  /*открытые функции для использования в приложении*/

  /*переменные*/
  LastIdSQ NUMBER; -- последний ID полученного номера

  /*получить следующий номер*/
  FUNCTION NEXTVAL
  (
    p_brief VARCHAR2
   ,p_param VARCHAR2
  ) RETURN VARCHAR2;

  /*подтвержедение использования функции*/
  PROCEDURE RegSQ(p_id NUMBER := LastIdSQ);
  PROCEDURE UnRegSQ(p_id NUMBER);

  PROCEDURE RegSQNum
  (
    p_sq_brief VARCHAR2
   ,p_brief    VARCHAR2
   ,p_val_last VARCHAR2
   ,p_val_type NUMBER
   ,p_val_calc VARCHAR2
  );
  /*---*/

  /*функции не для запуска в приложении*/
  /*Зарегистрировать номер*/
  FUNCTION RegisterVal
  (
    p_id_sq NUMBER
   ,p_val   VARCHAR2
  ) RETURN NUMBER;
  FUNCTION LockSQ(p_id_sq NUMBER) RETURN NUMBER;
  FUNCTION FindSQInRegister
  (
    p_sq       NUMBER
   ,p_template VARCHAR2
   ,p_out_sq   IN OUT VARCHAR2
  ) RETURN NUMBER;

  /*--*/
  FUNCTION GetNumberByQuery
  (
    p_query VARCHAR2
   ,p_val   VARCHAR2
  ) RETURN VARCHAR2;
  FUNCTION GetSQByQuery
  (
    p_id_sq   NUMBER
   ,p_sq_name VARCHAR2
   ,p_upd     BOOLEAN := TRUE
  ) RETURN VARCHAR2;
  FUNCTION InsertSQByQuery
  (
    p_id_sq   NUMBER
   ,p_sq_name VARCHAR2
  ) RETURN VARCHAR2;
  /*--*/

  FUNCTION ReplaceValToVal
  (
    p_id_sq NUMBER
   ,p_src   VARCHAR2
   ,p_val   VARCHAR2
  ) RETURN VARCHAR2;
  FUNCTION ReplaceValToSQVal
  (
    p_id_sq NUMBER
   ,p_src   VARCHAR2
   ,p_upd   BOOLEAN := TRUE
  ) RETURN VARCHAR2;

  /*--*/

  PROCEDURE ReplaceString
  (
    p_src  IN OUT VARCHAR2
   ,p_char VARCHAR2
  );

  /*--Перед пром экслплуатацие поменять на Utils.c_false и т.д*/
  c_false CONSTANT NUMBER := 0;
  c_true  CONSTANT NUMBER := 1;
  c_exept CONSTANT NUMBER := -1;

END PKG_AUTOSQ;
/
CREATE OR REPLACE PACKAGE BODY Pkg_Autosq AS
  /**
  * Нумератор
  * @author Surovtsev Alexey
  * @version 1.0
  */
  FUNCTION NEXTVAL
  (
    p_brief VARCHAR2
   ,p_param VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR cur_sq(c_brief VARCHAR2) IS
      SELECT * FROM auto_sq WHERE brief = c_brief;
  
    rec_sq cur_sq%ROWTYPE;
    sq_cur_notfound EXCEPTION;
  
    l_res            VARCHAR2(100);
    l_res_fun        NUMBER;
    l_res_format     VARCHAR2(100);
    l_res_find_sq_id NUMBER;
    l_reg            NUMBER;
  BEGIN
  
    OPEN cur_sq(p_brief);
    FETCH cur_sq
      INTO rec_sq;
  
    IF (cur_sq%NOTFOUND)
    THEN
      RAISE sq_cur_notfound;
    END IF;
  
    CLOSE cur_sq;
  
    l_res := ReplaceValToVal(rec_sq.auto_sq_id, rec_sq.format_str, p_param);
  
    /*--*/
    l_res_format := ReplaceValToSQVal(rec_sq.auto_sq_id, l_res, FALSE);
    LastIdSQ     := FindSQInRegister(rec_sq.auto_sq_id, l_res_format, l_res);
    /*---*/
  
    IF (LastIdSQ IS NOT NULL)
    THEN
      l_res_fun := c_true;
    ELSE
      l_res_fun := c_false;
    END IF;
  
    LOOP
      EXIT WHEN l_res_fun = c_true;
      l_res     := ReplaceValToSQVal(rec_sq.auto_sq_id, l_res);
      LastIdSQ  := RegisterVal(rec_sq.auto_sq_id, l_res);
      l_res_fun := LockSQ(LastIdSQ);
    END LOOP;
  
    RegSQ(LastIdSQ);
  
    RETURN l_res;
  EXCEPTION
    WHEN OTHERS THEN
      IF (cur_sq%ISOPEN)
      THEN
        CLOSE cur_sq;
      END IF;
      RETURN NULL;
  END NEXTVAL;

  FUNCTION FindSQInRegister
  (
    p_sq       NUMBER
   ,p_template VARCHAR2
   ,p_out_sq   IN OUT VARCHAR2
  ) RETURN NUMBER IS
  
    CURSOR cur_auto_sq_register
    (
      c_auto_sq_id NUMBER
     ,c_val        VARCHAR2
    ) IS
      SELECT *
        FROM AUTO_SQ_REGISTER A
       WHERE A.AUTO_SQ_ID = c_auto_sq_id
         AND A.VAL LIKE c_val
         AND A.USED = 0
       ORDER BY A.AUTO_SQ_REGISTER_ID ASC;
  
    l_res NUMBER;
  BEGIN
    FOR rec IN cur_auto_sq_register(p_sq, p_template)
    LOOP
      l_res := LockSQ(rec.auto_sq_register_id);
      IF (l_res = c_true)
      THEN
        p_out_sq := rec.val;
        RETURN rec.auto_sq_register_id;
      END IF;
    END LOOP;
  
    RETURN NULL;
  END FindSQInRegister;

  PROCEDURE sp_reg_sq
  (
    p_id   NUMBER
   ,p_used NUMBER
  ) IS
  BEGIN
    UPDATE AUTO_SQ_REGISTER A SET A.USED = p_used WHERE A.AUTO_SQ_REGISTER_ID = p_id;
  END sp_reg_sq;

  PROCEDURE RegSQ(p_id NUMBER := LastIdSQ) IS
  BEGIN
    sp_reg_sq(p_id, 1);
  END RegSQ;

  PROCEDURE UnRegSQ(p_id NUMBER) IS
  BEGIN
    sp_reg_sq(p_id, 0);
  END UnRegSQ;

  FUNCTION RegisterVal
  (
    p_id_sq NUMBER
   ,p_val   VARCHAR2
  ) RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    sq_val NUMBER;
  BEGIN
    SELECT SQ_AUTO_SQ_REGISTER.NEXTVAL INTO sq_val FROM dual;
  
    INSERT INTO AUTO_SQ_REGISTER
      (AUTO_SQ_REGISTER_ID, AUTO_SQ_ID, USED, VAL)
    VALUES
      (sq_val, p_id_sq, 0, p_val);
  
    COMMIT;
    RETURN sq_val;
  END RegisterVal;

  FUNCTION LockSQ(p_id_sq NUMBER) RETURN NUMBER IS
    CURSOR cur_sq_num(c_id VARCHAR2) IS
      SELECT * FROM AUTO_SQ_REGISTER A WHERE A.AUTO_SQ_REGISTER_ID = c_id FOR UPDATE NOWAIT;
  BEGIN
    OPEN cur_sq_num(p_id_sq);
    CLOSE cur_sq_num;
    RETURN c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN c_false;
  END LockSQ;

  FUNCTION GetNumberByQuery
  (
    p_query VARCHAR2
   ,p_val   VARCHAR2
  ) RETURN VARCHAR2 IS
    l_res VARCHAR2(50);
    l_sql VARCHAR2(1000);
  BEGIN
    l_sql := 'SELECT Q.RETURN_VAL FROM (' || p_query || ')Q';
    EXECUTE IMMEDIATE l_sql
      INTO l_res
      USING IN p_val;
  
    RETURN l_res;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN '!Нет';
    WHEN OTHERS THEN
      RETURN '!Ошибка';
  END GetNumberByQuery;

  FUNCTION ReplaceValToVal
  (
    p_id_sq NUMBER
   ,p_src   VARCHAR2
   ,p_val   VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR cur_auto_sq_num(c_auto_sq_id NUMBER) IS
      SELECT *
        FROM AUTO_SQ_NUM A
       WHERE A.AUTO_SQ_ID = c_auto_sq_id
         AND A.VAL_TYPE = 0;
  
    l_str_val VARCHAR2(50);
    l_src     VARCHAR2(100);
    i         NUMBER;
    i2        NUMBER;
    i3        NUMBER;
  BEGIN
    /*
          p_val := '%INS_GRUP:3%COD_PRODUCT:5';
          p_src := '%INS_GRUP%COD_PRODUCT-@%INS_GRUP@-%YY/%DEP';
    */
    l_src := p_src;
  
    FOR rec IN cur_auto_sq_num(p_id_sq)
    LOOP
      i := nvl(INSTR(p_val, '%' || rec.BRIEF), 0);
      IF (i > 0)
      THEN
        i2 := INSTR(p_val, ':', i);
        i3 := INSTR(p_val, '%', i2);
      END IF;
    
      IF (i > 0)
      THEN
      
        IF (i3 > i2)
        THEN
          i3 := i3 - 1;
        END IF;
      
        IF (i3 = 0)
        THEN
          i3 := LENGTH(p_val);
        END IF;
      
        l_str_val := SUBSTR(p_val, i2 + 1, i3 - i2);
      
        l_str_val := GetNumberByQuery(rec.val_calc, l_str_val);
      
        l_src := REPLACE(l_src, '%' || rec.BRIEF, l_str_val);
        --           l_src:=p_src_val;
      END IF;
    END LOOP;
  
    RETURN l_src;
  END ReplaceValToVal;

  FUNCTION ReplaceValToSQVal
  (
    p_id_sq NUMBER
   ,p_src   VARCHAR2
   ,p_upd   BOOLEAN := TRUE
  ) RETURN VARCHAR2 IS
    CURSOR cur_auto_sq_num(c_auto_sq_id NUMBER) IS
      SELECT *
        FROM AUTO_SQ_NUM A
       WHERE A.AUTO_SQ_ID = c_auto_sq_id
         AND A.VAL_TYPE = 1;
  
    l_exit    BOOLEAN := FALSE;
    l_src     VARCHAR2(100) := p_src;
    l_val_str VARCHAR2(1000);
    l_sq_name VARCHAR2(50);
    l_sq_val  VARCHAR2(50);
    i         NUMBER;
    i2        NUMBER;
    j         NUMBER;
    j2        NUMBER;
    ex EXCEPTION;
  BEGIN
    /*
          p_val := '%INS_GRUP:3%COD_PRODUCT:5';
          p_src := '35-@3@-..';
    */
  
    LOOP
      i := nvl(INSTR(l_src, '@'), 0);
    
      IF (i = 0)
      THEN
        EXIT;
      END IF;
    
      i2 := INSTR(l_src, '@', i + 1);
    
      IF (i2 > i)
      THEN
        l_sq_name := SUBSTR(l_src, i, i2 - i + 1);
      
        l_sq_val := GetSQByQuery(p_id_sq, l_sq_name, p_upd);
      
        IF (l_sq_val IS NULL)
        THEN
          l_sq_val := InsertSQByQuery(p_id_sq, l_sq_name);
        
          IF (l_sq_val IS NULL)
          THEN
            RAISE ex;
          END IF;
        
        END IF;
      
        l_src := REPLACE(l_src, l_sq_name, l_sq_val);
      END IF;
      EXIT WHEN l_exit = TRUE;
    END LOOP;
  
    RETURN l_src;
  
  END ReplaceValToSQVal;

  FUNCTION GetSQByQuery
  (
    p_id_sq   NUMBER
   ,p_sq_name VARCHAR2
   ,p_upd     BOOLEAN := TRUE
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    CURSOR cur_auto_sq_num
    (
      c_auto_sq_id NUMBER
     ,c_brief      VARCHAR2
    ) IS
      SELECT *
        FROM AUTO_SQ_NUM A
       WHERE A.AUTO_SQ_ID = c_auto_sq_id
         AND a.brief = c_brief
         FOR UPDATE NOWAIT;
  
    rec_auto_sq_num cur_auto_sq_num%ROWTYPE;
    l_res           VARCHAR2(50);
    l_sq_name       VARCHAR2(50);
    l_count         NUMBER;
    ex EXCEPTION;
  BEGIN
    l_sq_name := RTRIM(p_sq_name, '@');
    l_sq_name := LTRIM(l_sq_name, '@');
    OPEN cur_auto_sq_num(p_id_sq, l_sq_name);
    FETCH cur_auto_sq_num
      INTO rec_auto_sq_num;
  
    IF (cur_auto_sq_num%NOTFOUND)
    THEN
      RAISE ex;
    END IF;
  
    CLOSE cur_auto_sq_num;
  
    IF (rec_auto_sq_num.VAL_CALC IS NOT NULL)
    THEN
      EXECUTE IMMEDIATE 'SELECT A.RETURN_VAL from (' || rec_auto_sq_num.VAL_CALC || ')A'
        INTO l_res
        USING IN rec_auto_sq_num.VAL_LAST;
    END IF;
  
    IF (p_upd)
    THEN
      UPDATE AUTO_SQ_NUM SET VAL_LAST = l_res WHERE AUTO_SQ_NUM_ID = rec_auto_sq_num.AUTO_SQ_NUM_ID;
    ELSE
      --     l_count := LENGTH(l_res); 
      ReplaceString(l_res, '_');
    END IF;
  
    COMMIT;
    RETURN l_res;
  EXCEPTION
    WHEN ex THEN
      ROLLBACK;
      RETURN NULL;
    WHEN NO_DATA_FOUND THEN
      ROLLBACK;
      RETURN NULL;
    WHEN OTHERS THEN
      IF (cur_auto_sq_num%ISOPEN)
      THEN
        CLOSE cur_auto_sq_num;
      END IF;
      RETURN '!Ошибка';
  END GetSQByQuery;

  FUNCTION InsertSQByQuery
  (
    p_id_sq   NUMBER
   ,p_sq_name VARCHAR2
  ) RETURN VARCHAR2 IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  
    CURSOR cur_auto_sq_num
    (
      c_auto_sq_id NUMBER
     ,c_brief      VARCHAR2
    ) IS
      SELECT *
        FROM AUTO_SQ_NUM A
       WHERE A.AUTO_SQ_ID = c_auto_sq_id
         AND a.brief = c_brief;
  
    rec_auto_sq_num cur_auto_sq_num%ROWTYPE;
  
    sq_val        NUMBER;
    l_val         VARCHAR2(50);
    l_sq_name     VARCHAR2(50);
    l_sq_name_ins VARCHAR2(50);
    i             NUMBER;
    i2            NUMBER;
    ex EXCEPTION;
  BEGIN
    i := INSTR(p_sq_name, ':');
  
    IF (i = 0)
    THEN
      RAISE ex;
    END IF;
  
    i2 := LENGTH(p_sq_name);
    IF (i2 > i)
    THEN
      l_sq_name := SUBSTR(p_sq_name, i + 1, i2 - i - 1);
    
      OPEN cur_auto_sq_num(p_id_sq, l_sq_name);
      FETCH cur_auto_sq_num
        INTO rec_auto_sq_num;
    
      IF (cur_auto_sq_num%NOTFOUND)
      THEN
        RAISE ex;
      END IF;
    
      CLOSE cur_auto_sq_num;
    END IF;
  
    SELECT SQ_AUTO_SQ_NUM.NEXTVAL INTO sq_val FROM dual;
  
    l_sq_name_ins := LTRIM(p_sq_name, '@');
    l_sq_name_ins := RTRIM(l_sq_name_ins, '@');
  
    INSERT INTO AUTO_SQ_NUM
      (AUTO_SQ_NUM_ID, AUTO_SQ_ID, BRIEF, VAL_LAST, VAL_TYPE, VAL_CALC)
    VALUES
      (sq_val, p_id_sq, l_sq_name_ins, rec_auto_sq_num.VAL_LAST, 1, rec_auto_sq_num.VAL_CALC);
  
    COMMIT;
  
    l_val := GetSQByQuery(p_id_sq, p_sq_name, FALSE);
  
    RETURN l_val;
  EXCEPTION
    WHEN ex THEN
      IF (cur_auto_sq_num%ISOPEN)
      THEN
        CLOSE cur_auto_sq_num;
      END IF;
      ROLLBACK;
      RETURN '!Ошибка';
    WHEN OTHERS THEN
      IF (cur_auto_sq_num%ISOPEN)
      THEN
        CLOSE cur_auto_sq_num;
      END IF;
      ROLLBACK;
      RETURN NULL;
  END InsertSQByQuery;

  PROCEDURE ReplaceString
  (
    p_src  IN OUT VARCHAR2
   ,p_char VARCHAR2
  ) IS
  BEGIN
    FOR i IN 1 .. LENGTH(p_src)
    LOOP
      p_src := REPLACE(p_src, SUBSTR(p_src, i, 1), '_');
    END LOOP;
  END;

  PROCEDURE RegSQNum
  (
    p_sq_brief VARCHAR2
   ,p_brief    VARCHAR2
   ,p_val_last VARCHAR2
   ,p_val_type NUMBER
   ,p_val_calc VARCHAR2
  ) IS
    sq_val NUMBER;
  BEGIN
    SELECT SQ_AUTO_SQ_NUM.NEXTVAL INTO sq_val FROM dual;
  
    INSERT INTO AUTO_SQ_NUM
      (AUTO_SQ_NUM_ID, AUTO_SQ_ID, BRIEF, VAL_LAST, VAL_TYPE, VAL_CALC)
    VALUES
      (sq_val
      ,(SELECT A.AUTO_SQ_ID FROM AUTO_SQ A WHERE A.BRIEF = p_sq_brief)
      ,p_brief
      ,p_val_last
      ,p_val_type
      ,p_val_calc);
  END;

END Pkg_Autosq;
/
