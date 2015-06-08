CREATE OR REPLACE PROCEDURE add_contact_ur
IS
   CURSOR cur_bank (
      p_bik    VARCHAR2,
      p_korr   VARCHAR2,
      p_inn    VARCHAR2,
      p_name   VARCHAR2
   )
   IS
      WITH doc_sel AS
           (SELECT UPPER (tt.brief) AS brief, cci.contact_id, cci.id_value
              FROM ins.cn_contact_ident cci, ins.t_id_type tt
             WHERE cci.id_type = tt.ID)
      SELECT c.NAME, doc_korr.id_value AS korr_value,
             doc_inn.id_value AS inn_value, doc_bik.id_value AS bik_value,
             c.contact_id
        FROM ins.contact c,
             doc_sel doc_korr,
             doc_sel doc_bik,
             doc_sel doc_inn
       WHERE doc_korr.brief = UPPER ('KORR')
         AND doc_bik.brief = UPPER ('BIK')
         AND doc_inn.brief = UPPER ('INN')
         AND c.contact_id = doc_inn.contact_id
         AND c.contact_id = doc_korr.contact_id
         AND c.contact_id = doc_bik.contact_id
         AND doc_korr.id_value = p_korr
         AND doc_bik.id_value = p_bik
         AND doc_inn.id_value = p_inn
         AND c.NAME = p_name
         AND ROWNUM = 1;

   l_res              NUMBER;
   rec_bank           cur_bank%ROWTYPE;
   rev_val            NUMBER (1)         := 0;
   sq_contact         NUMBER;
   sq_addres          NUMBER;
   sq_val             NUMBER;
   cotnact_is         NUMBER             := 0;
   name_tabl          VARCHAR2 (30);
   name_contact       VARCHAR2 (255);
   id_type            NUMBER (9);
   inn_contact        VARCHAR2 (20);
   id_fund            NUMBER (9);
   id_fund_acc_bank   NUMBER (9);
   id_country         NUMBER (9);
   id_country_tel     NUMBER (9);
   l_exit_id          NUMBER;
   
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

      INSERT INTO ins.cn_contact_telephone
                  (ID, contact_id,
                   country_id,
                   telephone_type, telephone_prefix, telephone_number,
                   telephone_extension, remarks, ent_id
                  )
           VALUES (sq_val, sq_contact,
                   (SELECT t.ID
                      FROM t_country_dial_code t
                     WHERE t.country_id = p_telephone_country_id),
                   p_telephone_type, p_telephone_prefix, p_telephone_number,
                   p_telephone_extension, p_telephone_remarks, 221
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
      INSERT INTO cn_contact_ident
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

   PROCEDURE insert_account (
      p_bik          VARCHAR2,
      p_inn          VARCHAR2,
      p_korr         VARCHAR2,
      p_name_bank    VARCHAR2,
      p_acc_number   VARCHAR2,
      p_acc_notice   VARCHAR2,
      p_contact      NUMBER,
      p_fund         NUMBER
   )
   IS
   BEGIN
      OPEN cur_bank (p_bik, p_korr, p_inn, p_name_bank);

      FETCH cur_bank
       INTO rec_bank;

      pkg_convert.raise_exb (cur_bank%NOTFOUND, TRUE);

      CLOSE cur_bank;

      INSERT INTO ins.cn_contact_bank_acc
                  (ID, contact_id,
                   bank_id, account_nr,
                   bank_account_currency_id, bank_name, bic_code,
                   account_corr, remarks
                  )
           VALUES (ins.sq_cn_contact_bank_acc.NEXTVAL, p_contact,
                   rec_bank.contact_id, p_acc_number,
                   (SELECT f.fund_id
                      FROM ins.fund f
                     WHERE f.code = p_fund), p_name_bank, p_bik,
                   p_korr, p_acc_notice
                  );
   EXCEPTION
      WHEN pkg_convert.res_exception
      THEN
         CLOSE cur_bank;

         RETURN;
   END insert_account;
BEGIN
   FOR rec IN (SELECT *
                 FROM convert_add_contact_ur ca
                WHERE NOT EXISTS (
                         SELECT 1
                           FROM contact c
                          WHERE ca.NAME = c.NAME))
   LOOP
      name_contact := rec.NAME;
      inn_contact := rec.inn;
      l_exit_id := rec.ext_id;
      l_res := pkg_convert.c_true;

      SELECT f.fund_id
        INTO id_fund
        FROM ins.fund f
       WHERE f.code = rec.currency_id;

      id_country := 643;

      IF (l_res = pkg_convert.c_true)
      THEN
         SELECT ins.sq_contact.NEXTVAL
           INTO sq_contact
           FROM DUAL;

         INSERT INTO ins.contact
                     (contact_id, NAME, short_name,
                      resident_flag, t_contact_status_id, contact_type_id,
                      ext_id
                     )
              VALUES (sq_contact, rec.NAME, rec.short_name,
                      rec.resident_flag, 1, rec.type_contact_id,
                      rec.ext_id
                     );

         IF (rec.telephone_number IS NOT NULL)
         THEN
            insert_tel (643,
                        NULL,
                        rec.telephone_number,
                        NULL,
                        NULL,
                        rec.telephone_type
                       );
         END IF;

         IF (rec.inn IS NOT NULL)
         THEN
            insert_doc ('INN', sq_contact, rec.inn, id_country);

            INSERT INTO ins.cn_company
                        (contact_id, web_site, currency_id
                        )
                 VALUES (sq_contact, NULL, id_fund
                        );
         END IF;

         IF (rec.kpp IS NOT NULL)
         THEN
            insert_doc ('KPP', sq_contact, rec.kpp, id_country);
         END IF;

         IF (rec.okpo IS NOT NULL)
         THEN
            insert_doc ('OKPO', sq_contact, rec.okpo, id_country);
         END IF;

         IF (fn_insert_addresse (rec.ext_id, sq_contact) <> pkg_convert.c_true
            )
         THEN
            RETURN ;
         END IF;

         IF (rec.num_account IS NOT NULL)
         THEN
            insert_account (rec.acc_bik_bank,
                            rec.acc_inn_bank,
                            rec.acc_korr_bank,
                            rec.acc_name_bank,
                            rec.num_account,
                            rec.account_notice,
                            sq_contact,
                            rec.fund_acc
                           );
         END IF;

         IF (rec.num_account2 IS NOT NULL)
         THEN
            insert_account (rec.acc_bik_bank2,
                            rec.acc_inn_bank2,
                            rec.acc_korr_bank2,
                            rec.acc_name_bank2,
                            rec.num_account2,
                            rec.account_notice2,
                            sq_contact,
                            rec.fund_acc2
                           );
         END IF;

--         pkg_convert.updateconvert ('ins.convert_contact', rec.rrw);
      END IF;
   END LOOP;
END add_contact_ur;
/

