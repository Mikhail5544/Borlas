CREATE OR REPLACE VIEW V_POL_LPA_REPORT AS
SELECT
/*
Обзор для отчета om_pol_LPA195_0
17.04.2014 Черных М.
*/
 cc.name || ' ' ||
 pkg_contact.get_address_name(pkg_contact_rep_utils.get_last_active_address_id(cc.contact_id, 'LEGAL')) addr
,CASE
   WHEN nvl(t1.id_value, 0) = 0 THEN
    ''
   ELSE
    'ИНН ' || ' ' || t1.id_value
 END || CASE
   WHEN nvl(bc.account_nr, 0) = 0 THEN
    ''
   ELSE
    ' Р/С' || ' ' || bc.account_nr || ' ' || bc.bank_name || ' ' || bc.branch_name
 END || CASE
   WHEN nvl(t2.id_value, 0) = 0 THEN
    ''
   ELSE
    ' БИК' || ' ' || t2.id_value
 END || CASE
   WHEN nvl(t3.id_value, 0) = 0 THEN
    ''
   ELSE
    ' К/С' || ' ' || t3.id_value
 END AS dd
,cc.contact_id
,cc.is_public_contact
  FROM contact             cc
      ,cn_contact_ident    t1
      ,cn_contact_ident    t2
      ,cn_contact_ident    t3
      ,cn_contact_bank_acc bc
 WHERE cc.contact_id = t1.contact_id(+)
   AND t1.id_type(+) = 1 /*ИНН*/
   AND t1.table_id(+) = pkg_contact.get_contact_document_id(cc.contact_id, 'INN')
   AND cc.contact_id = t2.contact_id(+)
   AND t2.id_type(+) = 10 /*БИК*/
   AND t2.table_id(+) = pkg_contact.get_contact_document_id(cc.contact_id, 'BIK')
   AND cc.contact_id= t3.contact_id(+)
   AND t3.id_type(+) = 11 /*Кор.счет*/
   AND t3.table_id(+) = pkg_contact.get_contact_document_id(cc.contact_id, 'KORR')
   AND cc.contact_id = bc.contact_id(+)
   AND bc.used_flag(+) = 1 /*Флаг использования счета 1/0*/
   AND bc.id(+) = pkg_contact.get_primary_banc_acc(cc.contact_id);
