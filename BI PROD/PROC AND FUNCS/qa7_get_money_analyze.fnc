create or replace function qA7_get_money_analyze(p_acp_id in number)
  return integer is
  Result         integer;
  tmp_doc_brief  varchar2(20);
  tmp_paym_brief varchar2(20);
begin

  select apt1.brief
    into tmp_doc_brief
    from ac_payment a11, ac_payment_templ apt1
   where p_acp_id = a11.payment_id
     and apt1.payment_templ_id = a11.payment_templ_id;

  select doc.get_doc_status_brief(a22.payment_id,
                                  to_date('31.12.9999', 'DD.MM.YYYY'))
    into tmp_paym_brief
    from doc_doc dd1, ac_payment a11, ac_payment a22, ac_payment_templ apt1
   where p_acp_id = a11.payment_id
     and dd1.parent_id = a11.payment_id
     and dd1.child_id = a22.payment_id
     AND (apt1.brief = 'A7' OR apt1.brief = 'PD4')
     and apt1.payment_templ_id = a11.payment_templ_id;

  if (tmp_doc_brief = 'оо') then
    tmp_paym_brief := 'PAID';
  end if;

  if tmp_paym_brief = 'PAID' then
    result := 1;
  else
    result := 0;
  end if;
  return(result);
end qA7_get_money_analyze;
/

