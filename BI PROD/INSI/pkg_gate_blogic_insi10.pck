CREATE OR REPLACE PACKAGE PKG_GATE_BLOGIC_INSI10 IS
  NamePrfx     CONSTANT VARCHAR2(10) := 'TRI11';
  ShemaPrfx    CONSTANT VARCHAR2(10) := 'INSI';
  ShemaTabPrfx CONSTANT VARCHAR2(10) := 'INS.';
  EventRet NUMBER;

  FUNCTION GenericTrigger RETURN NUMBER;
END PKG_GATE_BLOGIC_INSI10;
/
CREATE OR REPLACE PACKAGE BODY PKG_GATE_BLOGIC_INSI10 IS
  FUNCTION GenericTrigger RETURN NUMBER IS
  
    name_trigger VARCHAR2(32);
    res_fun      NUMBER;
  
    CURSOR cur_ent_tab IS
      SELECT g.*
            ,e.SOURCE
            ,COUNT(*) OVER(PARTITION BY g.ent_id ORDER BY g.gate_obj_type_id ASC) AS C_NUM
        FROM gate_ent_table g
            ,ins.entity     e
       WHERE e.ent_id = g.ent_id;
  
    FUNCTION CreateTriggerTop
    (
      p_name        VARCHAR2
     ,p_table       VARCHAR2
     ,p_type        NUMBER
     ,p_id_name     VARCHAR2
     ,p_ent_id      NUMBER
     ,p_del_rel_val VARCHAR2
    ) RETURN NUMBER IS
      sql_str VARCHAR2(1000);
    BEGIN
      sql_str := ' CREATE OR REPLACE TRIGGER ' || ShemaPrfx || '.' || p_name ||
                 ' AFTER DELETE OR INSERT OR UPDATE ' || ' ON ' || ShemaTabPrfx || p_table ||
                 ' REFERENCING NEW AS NEW OLD AS OLD ' || ' FOR EACH ROW ' || ' declare ' ||
                 ' status_row number; ' || ' p_id_val number; ' || ' l_res varchar2(50) ;' ||
                 ' begin ' || ' if deleting then ' || '  status_row := ' || ShemaPrfx ||
                 '.PKG_GATE.row_delete; ';
    
      IF (p_del_rel_val IS NOT NULL)
      THEN
        sql_str := sql_str || ' begin ' || '	 select res into l_res from (' || p_del_rel_val || ');' ||
                   ' exception ' || '  when others then ' || '   return;' || ' end;';
      END IF;
    
      sql_str := sql_str || ' end if; ' || ' if inserting then ' || '  status_row := ' || ShemaPrfx ||
                 '.PKG_GATE.row_insert; ' || ' end if; ' || ' if updating then ' || '  status_row := ' ||
                 ShemaPrfx || '.PKG_GATE.row_update; ' || ' end if; ' || ' if (status_row = ' ||
                 ShemaPrfx || '.pkg_gate.row_delete)then ' || '  p_id_val := :OLD.' || p_id_name || '; ' ||
                 ' else ' || '  p_id_val := :NEW.' || p_id_name || '; ' || ' end if; ' || ShemaPrfx ||
                 '.PKG_GATE.ChangeRow(status_row,' || p_type || ',p_id_val,' || p_ent_id || ',' || '''' ||
                 p_name || '''' || ');' || ' end;';
    
      EXECUTE IMMEDIATE sql_str;
    
      RETURN INS.Utils.c_true;
    EXCEPTION
      WHEN OTHERS THEN
        EventRet := pkg_gate.InserEvent('PKG_GATE.GenericTrigger.CreateTriggerTop: ' || sql_str
                                       ,pkg_gate.event_error);
        EventRet := pkg_gate.InserEvent('PKG_GATE.GenericTrigger.CreateTriggerTop: ' || SQLERRM
                                       ,pkg_gate.event_error);
        RETURN INS.Utils.c_false;
    END CreateTriggerTop;
  
    FUNCTION CreateTriggerSimple
    (
      p_name    VARCHAR2
     ,p_table   VARCHAR2
     ,p_type    NUMBER
     ,p_id_name VARCHAR2
     ,p_ent_id  NUMBER
    ) RETURN NUMBER IS
      sql_str VARCHAR2(1000);
    BEGIN
      sql_str := ' CREATE OR REPLACE TRIGGER ' || ShemaPrfx || '.' || p_name ||
                 ' AFTER DELETE OR INSERT OR UPDATE ' || ' ON ' || ShemaTabPrfx || p_table ||
                 ' REFERENCING NEW AS NEW OLD AS OLD ' || ' FOR EACH ROW ' || ' declare ' ||
                 ' p_id_val number; ' || ' begin ' || ' if deleting then ' || '  p_id_val := :OLD.' ||
                 p_id_name || '; ' || ' else ' || '  p_id_val := :NEW.' || p_id_name || '; ' ||
                 ' end if; ' || ShemaPrfx || '.PKG_GATE.ChangeRow(' || ShemaPrfx ||
                 '.PKG_GATE.row_update,' || p_type || ',p_id_val,' || p_ent_id || ',' || '''' ||
                 p_name || '''' || ');' || ' end;';
    
      EXECUTE IMMEDIATE sql_str;
      RETURN INS.Utils.c_true;
    EXCEPTION
      WHEN OTHERS THEN
        EventRet := pkg_gate.InserEvent('PKG_GATE.GenericTrigger.CreateTriggerSimple: ' || sql_str
                                       ,pkg_gate.event_error);
        EventRet := pkg_gate.InserEvent('PKG_GATE.GenericTrigger.CreateTriggerSimple: ' || SQLERRM
                                       ,pkg_gate.event_error);
        RETURN INS.Utils.c_false;
    END CreateTriggerSimple;
  
  BEGIN
    FOR rec IN cur_ent_tab
    LOOP
      name_trigger := NamePrfx || '_' || rec.SOURCE || rec.C_NUM;
    
      IF (rec.table_type = 0)
      THEN
        res_fun := CreateTriggerTop(p_name        => name_trigger
                                   ,p_table       => rec.SOURCE
                                   ,p_type        => rec.GATE_OBJ_TYPE_ID
                                   ,p_id_name     => rec.ID_NAME
                                   ,p_ent_id      => rec.ENT_ID
                                   ,p_del_rel_val => rec.DEL_REAL_VAL);
      END IF;
    
      IF (rec.table_type = 1)
      THEN
        res_fun := CreateTriggerSimple(name_trigger
                                      ,rec.SOURCE
                                      ,rec.GATE_OBJ_TYPE_ID
                                      ,rec.ID_NAME
                                      ,rec.ENT_ID);
      END IF;
    
      IF (res_fun = INS.Utils.c_true)
      THEN
        UPDATE GATE_ENT_TABLE G
           SET G.TR_NAME = name_trigger
         WHERE G.ENT_ID = rec.ENT_ID
           AND G.GATE_OBJ_TYPE_ID = rec.GATE_OBJ_TYPE_ID;
      END IF;
    END LOOP;
  
    RETURN INS.Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      EventRet := pkg_gate.InserEvent('PKG_GATE.GenericTrigger: ' || SQLERRM, pkg_gate.event_error);
      RETURN INS.Utils.c_false;
  END GenericTrigger;

END PKG_GATE_BLOGIC_INSI10;
/
