CREATE OR REPLACE PACKAGE pkg_forms IS
  FUNCTION get_ent_id_by_brief
  (
    par_ent_brief IN VARCHAR2
   ,par_obj_id    IN NUMBER
  ) RETURN NUMBER;
  FUNCTION get_ent_form(par_ent_id IN NUMBER) RETURN VARCHAR2;
END pkg_forms;
/
CREATE OR REPLACE PACKAGE BODY pkg_forms IS

  FUNCTION get_ent_id_by_brief
  (
    par_ent_brief IN VARCHAR2
   ,par_obj_id    IN NUMBER
  ) RETURN NUMBER IS
    v_return NUMBER;
  BEGIN
    FOR rc IN (SELECT *
                 FROM (SELECT e.source
                             ,e.id_name
                         FROM entity e
                        START WITH e.brief = par_ent_brief
                       CONNECT BY PRIOR e.parent_id = e.ent_id
                        ORDER BY LEVEL DESC)
                WHERE rownum = 1)
    LOOP
      EXECUTE IMMEDIATE 'begin
      select ent_id
      into :ret
      from ' || rc.source || ' where ' || rc.id_name || '=:par;      
      end;'
        USING OUT v_return, IN par_obj_id;
      RETURN v_return;
    END LOOP;
    RETURN NULL;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
  END;

  FUNCTION get_ent_form(par_ent_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    FOR rc IN (SELECT e.form_name FROM entity e WHERE e.ent_id = par_ent_id)
    LOOP
      RETURN rc.form_name;
    END LOOP;
    RETURN NULL;
  END;

END pkg_forms;
/
