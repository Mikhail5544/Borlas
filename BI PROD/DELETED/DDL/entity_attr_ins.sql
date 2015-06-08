declare
  at_id number;
begin
  insert into attr
  (attr_id, ent_id, name, brief, attr_type_id, source, col_name, calc, note, is_trans, is_key, ref_ent_id, is_excl, flg_del)
  values
  (SQ_ATTR.Nextval,283,'ИД валюты оплаты', 'FUND_PAY_ID', 7, 'P_POLICY', null,
  'begin
    SELECT ph.fund_pay_id
      into :ret_val
    FROM p_pol_header ph 
    where ph.policy_header_id = 
     (select p.pol_header_id from p_policy p where 
       p.policy_id = :p_doc_id);end;',
  null,0,0,null,0,0)
  returning attr_id into at_id;

  insert into ATTR_FUND_TYPE
  (attr_fund_type_id, ent_id, filial_id, fund_type_id, attr_id, ext_id)
  values
  (SQ_ATTR_FUND_TYPE.NEXTVAL,56,null,4, at_id,null);
end;
/
