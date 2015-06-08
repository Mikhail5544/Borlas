CREATE OR REPLACE FUNCTION get_pers_doc (p_contact_id NUMBER)
   RETURN VARCHAR2
AS
   CURSOR doc_n
   IS
      SELECT   tit.description doc_desc,
               DECODE (NVL (cci.serial_nr, '@'),
                       '@', cci.id_value,
                       cci.serial_nr || '-' || cci.id_value
                      ) doc_ser_num,
               cci.place_of_issue, cci.issue_date
          FROM ven_cn_person vcp, ven_cn_contact_ident cci,
               ven_t_id_type tit
         WHERE vcp.contact_id = p_contact_id
           AND vcp.contact_id = cci.contact_id
           AND cci.id_type = tit.ID
      ORDER BY tit.SORT_ORDER;

   doc_n_var   doc_n%ROWTYPE;
   ret_val     VARCHAR2 (1500);
BEGIN
   ret_val := 'ret';

   OPEN doc_n;

   FETCH doc_n
    INTO doc_n_var;

   IF doc_n%NOTFOUND
   THEN
      ret_val := ' Нет данных.';
   ELSE
      ret_val :=
            doc_n_var.doc_desc
         || '  Номер: '
         || doc_n_var.doc_ser_num
         || '  Выдан: ';

      IF doc_n_var.place_of_issue IS NOT NULL
      THEN
         ret_val := ret_val || doc_n_var.place_of_issue;
      ELSE
         ret_val := ret_val || 'нет данных';
      END IF;

      ret_val := ret_val || ' Дата выдачи: ';

      IF doc_n_var.issue_date IS NOT NULL
      THEN
         ret_val := ret_val || TO_CHAR (doc_n_var.issue_date, 'DD.MM.YYYY');
      ELSE
         ret_val := ret_val || 'нет данных';
      END IF;
   END IF;

   CLOSE doc_n;

   RETURN ret_val;
END;
/

