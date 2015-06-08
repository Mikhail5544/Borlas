CREATE OR REPLACE FUNCTION fn_check_double_contact
(
  par_contact_id_1 IN NUMBER
 ,par_contact_id_2 IN NUMBER
) RETURN NUMBER IS
  RESULT NUMBER;
  /*
  347798: Доработки отчетов по НДФЛ
  Функция "проверка дублей" 
  Доброхотова И., август, 2014
  */
  TYPE t_info_contact IS RECORD(
     contact_id    contact.contact_id%TYPE
    ,fio           VARCHAR2(1000)
    ,date_of_birth cn_person.date_of_birth%TYPE
    ,doc_id        cn_contact_ident.table_id%TYPE
    ,doc_info      VARCHAR2(500));

  v_p  NUMBER := 0; -- вероятность совпадения
  v_c1 t_info_contact;
  v_c2 t_info_contact;

  PROCEDURE p_get_contact_info(par_contact_inout IN OUT t_info_contact) IS
  BEGIN
    SELECT c.name || ' ' || c.first_name || ' ' || c.middle_name
          ,nvl(cp.date_of_birth, to_date('01.01.2999', 'dd.mm.yyyy'))
      INTO par_contact_inout.fio
          ,par_contact_inout.date_of_birth
      FROM contact   c
          ,cn_person cp
     WHERE c.contact_id = par_contact_inout.contact_id
       AND c.contact_id = cp.contact_id(+);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE p_get_doc_info(par_contact_inout IN OUT t_info_contact) IS
  BEGIN
    SELECT ltrim(REPLACE(serial_nr, ' '), '0') || ' ' || ltrim(REPLACE(id_value, ' '), '0')
      INTO par_contact_inout.doc_info
      FROM cn_contact_ident cci
     WHERE cci.table_id = par_contact_inout.doc_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

BEGIN
  IF par_contact_id_1 = par_contact_id_2
  THEN
    RESULT := 1;
  ELSE
    BEGIN
      v_c1.contact_id := par_contact_id_1;
      v_c2.contact_id := par_contact_id_2;
    
      p_get_contact_info(v_c1);
      p_get_contact_info(v_c2);
    
      IF v_c1.fio = v_c2.fio
      THEN
        v_p := v_p + 0.25;
      END IF;
      IF v_c1.date_of_birth = v_c2.date_of_birth
      THEN
        v_p := v_p + 0.25;
      END IF;
      -- если фио и/или ДР не совпадают, сравнимаем паспорт 
      IF v_p < 0.5
      THEN
        v_c1.doc_id := pkg_contact_rep_utils.get_primary_doc_id(par_contact_id => v_c1.contact_id);
        v_c2.doc_id := pkg_contact_rep_utils.get_primary_doc_id(par_contact_id => v_c2.contact_id);
        p_get_doc_info(v_c1);
        p_get_doc_info(v_c2);
        IF v_c1.doc_info = v_c2.doc_info
        THEN
          v_p := v_p + 0.5;
        END IF;
      END IF;
    
      IF v_p >= 0.5
      THEN
        RESULT := 1;
      ELSE
        RESULT := 0;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RESULT := 0;
    END;
  END IF;

  RETURN(RESULT);
END fn_check_double_contact;
/
