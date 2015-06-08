CREATE OR REPLACE VIEW V_TEMP_COMPANY AS
SELECT cc.name || ' ' || adr.address_name AS addr
      ,CASE
         WHEN nvl(t1.id_value, 0) = 0 THEN
          ''
         ELSE
          '»ÕÕ ' || ' ' || t1.id_value
       END || CASE
         WHEN nvl(bc.account_nr, 0) = 0 THEN
          ''
         ELSE
          ' –/—' || ' ' || bc.account_nr || ' ' || bc.bank_name || ' ' || bc.branch_name
       END || CASE
         WHEN nvl(t2.id_value, 0) = 0 THEN
          ''
         ELSE
          ' ¡» ' || ' ' || t2.id_value
       END || CASE
         WHEN nvl(t3.id_value, 0) = 0 THEN
          ''
         ELSE
          '  /—' || ' ' || t3.id_value
       END AS dd
      ,cc.contact_id
      ,cc.is_public_contact

  FROM ins.contact cc
  LEFT JOIN ins.cn_contact_ident t1
    ON (cc.contact_id = t1.contact_id AND t1.id_type = 1 AND
       t1.table_id = pkg_contact.get_contact_document_id(cc.contact_id, 'INN'))
  LEFT JOIN ins.cn_contact_ident t2
    ON (cc.contact_id = t2.contact_id AND t2.id_type = 10 AND
       t2.table_id = pkg_contact.get_contact_document_id(cc.contact_id, 'BIK'))
  LEFT JOIN ins.cn_contact_ident t3
    ON (cc.contact_id = t3.contact_id AND t3.id_type = 11 AND
       t3.table_id = pkg_contact.get_contact_document_id(cc.contact_id, 'KORR'))
  LEFT JOIN ins.v_cn_contact_address adr
    ON (adr.contact_id = cc.contact_id AND adr.address_type = 6 AND
       adr.adress_id = pkg_contact_rep_utils.get_address_id_by_type(adr.contact_id, 'LEGAL'))
  LEFT JOIN ins.cn_contact_bank_acc bc
    ON (bc.contact_id = cc.contact_id AND bc.used_flag = 1 AND
       bc.id = pkg_contact.get_primary_banc_acc(cc.contact_id));
