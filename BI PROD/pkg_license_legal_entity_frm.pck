CREATE OR REPLACE PACKAGE pkg_license_legal_entity_frm IS

  -- Author  : VESELEK
  -- Created : 22.07.2013 10:29:52
  -- Purpose : Вспомогательный пакет для обработки мутации таблиц

  TYPE tt_num IS TABLE OF NUMBER;

  gv_tt_cont tt_num := tt_num();
  gv_tt_id   tt_num := tt_num();

  PROCEDURE clear_table;
  PROCEDURE update_table;
  PROCEDURE insert_tmp_values
  (
    p_contact_id NUMBER
   ,p_id         NUMBER
  );

END pkg_license_legal_entity_frm;
/
CREATE OR REPLACE PACKAGE BODY pkg_license_legal_entity_frm IS

  PROCEDURE clear_table IS
  BEGIN
    gv_tt_cont.delete();
    gv_tt_id.delete();
  END;

  PROCEDURE update_table IS
  BEGIN
  
    FORALL i IN 1 .. gv_tt_id.count
      UPDATE ins.license_legal_entity jb
         SET jb.is_current = 0
       WHERE jb.license_legal_entity_id != gv_tt_id(i)
         AND jb.contact_id = (SELECT jb1.contact_id
                                FROM license_legal_entity jb1
                               WHERE jb1.license_legal_entity_id = gv_tt_id(i));
  
  END;

  PROCEDURE insert_tmp_values
  (
    p_contact_id NUMBER
   ,p_id         NUMBER
  ) IS
  BEGIN
    FOR i IN 1 .. gv_tt_cont.count
    LOOP
    
      IF gv_tt_cont(i) = p_contact_id
      THEN
        raise_application_error(-20001, 'Все плохо!');
      END IF;
    
    END LOOP;
  
    gv_tt_id.extend(1);
    gv_tt_id(gv_tt_id.last) := p_id;
  
    gv_tt_cont.extend(1);
    gv_tt_cont(gv_tt_cont.last) := p_contact_id;
  
  END;

END pkg_license_legal_entity_frm;
/
