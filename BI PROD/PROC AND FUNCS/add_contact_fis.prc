create or replace procedure add_contact_fis is
   l_res            NUMBER;
   rec_bank         convert_add_contact_fis%ROWTYPE;
   rev_val          NUMBER (1)                        := 0;
   sq_contact       NUMBER;
   sq_addres        NUMBER;
   sq_val           NUMBER;
   cotnact_is       NUMBER                            := 0;
   name_tabl        VARCHAR2 (30);
   name_contact     VARCHAR2 (255);
   id_type          NUMBER (9);
   inn_contact      VARCHAR2 (20);
   id_country_tel   NUMBER (9);
   l_exit_id        NUMBER;

   FUNCTION fn_insert_addresse (p_ext_id_contact VARCHAR2, p_contact_id NUMBER)
      RETURN NUMBER
   IS
      CURSOR cur_add (c_contact_ext_id VARCHAR2)
      IS
         SELECT *
           FROM convert_add_addresse t
          WHERE t.contact_ext_id = c_contact_ext_id;

      sq_addres   NUMBER;
      sq_val      NUMBER;
   BEGIN
      FOR rec IN cur_add (p_ext_id_contact)
      LOOP
         SELECT ins.sq_cn_address.NEXTVAL
           INTO sq_addres
           FROM DUAL;

         INSERT INTO ins.cn_address
                     (ID, country_id, NAME,
                      remarks, ext_id
                     )
              VALUES (sq_addres, rec.country_id, rec.adr_name,
                      rec.adr_remarks, rec.ext_id
                     );

         SELECT ins.sq_cn_contact_address.NEXTVAL
           INTO sq_val
           FROM DUAL;

         INSERT INTO ins.cn_contact_address
                     (ID, contact_id, address_type, adress_id,
                      ext_id
                     )
              VALUES (sq_val, p_contact_id, rec.address_type_id, sq_addres,
                      rec.ext_id
                     );
      END LOOP;

      RETURN pkg_convert.c_true;
   EXCEPTION
      WHEN OTHERS
      THEN
         pkg_convert.sp_eventerror ('Ошибка при конвертации адреса',
                                    'PKG_CONVERT_BLogic',
                                    'FN_INSERT_ADDRESSE',
                                    SQLCODE,
                                    SQLERRM
                                   );
         RETURN pkg_convert.c_false;
   END fn_insert_addresse;

   PROCEDURE insert_tel (
      p_telephone_country_id   NUMBER,
      p_telephone_prefix       VARCHAR2,
      p_telephone_number       VARCHAR2,
      p_telephone_extension    VARCHAR2,
      p_telephone_remarks      VARCHAR2,
      p_telephone_type         NUMBER
   )
   IS
   BEGIN
      SELECT ins.sq_cn_contact_telephone.NEXTVAL
        INTO sq_val
        FROM DUAL;

      INSERT INTO ins.ven_cn_contact_telephone
                  (ID, contact_id,
                   country_id,
                   telephone_type, telephone_prefix,
                   telephone_number, telephone_extension,
                   remarks, ent_id
                  )
           VALUES (sq_val, sq_contact,
                   (SELECT t.ID
                      FROM t_country_dial_code t
                     WHERE t.country_id = p_telephone_country_id),
                   p_telephone_type, p_telephone_prefix,
                   SUBSTR (p_telephone_number, 1, 30), p_telephone_extension,
                   p_telephone_remarks, 221
                  );
   END;

   PROCEDURE insert_doc (
      p_brief     VARCHAR2,
      p_contact   NUMBER,
      p_val       VARCHAR2,
      p_country   NUMBER
   )
   IS
   BEGIN
      INSERT INTO ven_cn_contact_ident
                  (table_id, contact_id,
                   id_type, id_value,
                   country_id
                  )
           VALUES (sq_cn_contact_ident.NEXTVAL, p_contact,
                   (SELECT t.ID
                      FROM ins.t_id_type t
                     WHERE UPPER (t.brief) = UPPER (p_brief)), p_val,
                   p_country
                  );
   END insert_doc;
BEGIN
   FOR rec IN (SELECT *
                 FROM convert_add_contact_fis ca
                WHERE NOT EXISTS (
                         SELECT 1
                           FROM contact c
                          WHERE ca.NAME = c.NAME
                            AND ca.first_name = c.first_name
                            AND ca.middle_name = c.middle_name))
   LOOP
      name_contact := rec.NAME;
      inn_contact := rec.inn;
      l_exit_id := rec.ext_id;

      SELECT ins.sq_contact.NEXTVAL
        INTO sq_contact
        FROM DUAL;

      /*   insert into INS.VEN_CONTACT (CONTACT_ID, NAME, FIRST_NAME, MIDDLE_NAME,
                 RESIDENT_FLAG,NOTE,T_CONTACT_STATUS_ID,CONTACT_TYPE_ID,EXT_ID)
          values();*/
      name_tabl := 1;

      INSERT INTO ins.ven_cn_person
                  (contact_id, NAME, first_name, middle_name,
                   resident_flag, note, t_contact_status_id,
                   contact_type_id, ext_id, date_of_birth,
                   gender, family_status, title
                  )
           VALUES (sq_contact, rec.NAME, rec.first_name, rec.middle_name,
                   rec.resident_flag, rec.contact_note, 1,
                   rec.type_contact_id, rec.ext_id, rec.date_of_birth,
                   rec.gender, rec.family_status, rec.person_title
                  );

      name_tabl := 2;

      IF (rec.telephone_number IS NOT NULL)
      THEN
         insert_tel (rec.telephone_country_id,
                     NULL,
                     rec.telephone_number,
                     NULL,
                     NULL,
                     rec.telephone_type
                    );
      END IF;

      name_tabl := 3;

      IF (rec.telephone_number2 IS NOT NULL)
      THEN
         insert_tel (rec.telephone_country_id2,
                     NULL,
                     rec.telephone_number2,
                     NULL,
                     NULL,
                     rec.telephone_type2
                    );
      END IF;

      name_tabl := 4;

      IF (rec.telephone_number3 IS NOT NULL)
      THEN
         insert_tel (rec.telephone_country_id3,
                     NULL,
                     rec.telephone_number3,
                     NULL,
                     NULL,
                     rec.telephone_type3
                    );
      END IF;

      name_tabl := 5;

      IF (rec.inn IS NOT NULL)
      THEN
         insert_doc ('INN', sq_contact, rec.inn, 643);
      END IF;

      name_tabl := 6;

      IF (rec.number_passport IS NOT NULL)
      THEN
         SELECT ins.sq_cn_contact_ident.NEXTVAL
           INTO sq_val
           FROM DUAL;

         id_type := rec.passport_brif;
         name_tabl := 7;

         INSERT INTO ins.ven_cn_contact_ident
                     (table_id, contact_id, id_type, id_value,
                      serial_nr, issue_date, country_id,
                      place_of_issue
                     )
              VALUES (sq_val, sq_contact, id_type, rec.number_passport,
                      rec.serial_nr_passport, rec.issue_date_passport, 643,
                      rec.place_of_issue_passport
                     );
      END IF;

      name_tabl := 8;

      IF (fn_insert_addresse (rec.ext_id, sq_contact) <> pkg_convert.c_true)
      THEN
         RETURN ;
      END IF;
--  pkg_convert.UpdateConvert('ins.convert_contact',rec.rrw);
   END LOOP;
END;
/

