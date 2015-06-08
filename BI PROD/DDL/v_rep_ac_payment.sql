create or replace force view v_rep_ac_payment as
select
  ap.payment_id document_id,
  '№' || ap.num num,
  'от ' || pk_utils.date2genitive_case(ap.due_date) gen_due_date,
  ap.amount amount,
  pk_utils.money2speech(ap.amount, f.fund_id) speech_amount,
  to_char(ap.amount, '999g999g999d00') || ' ' || f.brief brief_amount,
  f.name fund_name,
  f.brief fund_brief,
  pf.name pay_fund_name,
  pf.brief pay_fund_brief,
  case
    when f.fund_id = pf.fund_id and pf.brief <> 'RUR' then 'в валюте ' || pf.name
    when f.fund_id = pf.fund_id and pf.brief = 'RUR'  then 'в рублях'
    when f.fund_id <> pf.fund_id and pf.brief = 'RUR' then 'в рублевом эквиваленте по курсу ' || rt.name || ' на день перечисления'
    else                                                   'в валюте ' || pf.name || ' по курсу ' || rt.name
  end pay_terms,
  case
    when ap.payment_direct_id = 1 then 'Счет'
    else                               'Распоряжение на выплату'
  end doc_header,
  case
    when dt.brief = 'PAYMENT' then 'Оплата страховой премии по договору №' || d.num
    when dt.brief = 'PAYORDBACK' then 'Выплата возврата по договору №' || d.num
    when dt.brief = 'PAYORDER' then 'Выплата возмещения по претензии №' || d.num
  end pay_note,
  case
    when ap.payment_direct_id = 1 then 'При оплате укажите, пожалуйста, № счета'
    else                               'При выплате укажите, пожалуйста, № распоряжения'
  end add_pay_note,
  case
    when ap.payment_direct_id = 1 then 'Поставщик'
    else                               'Плательщик'
  end company_role,
  c_com.obj_name_orig company_name,
  case
    when ap.payment_direct_id = 1 then 'Плательщик'
    else                               'Получатель'
  end contractor_role,
  ent.obj_name(c_con.ent_id, c_con.contact_id) contractor_name,
  ent.obj_name(ent.id_by_brief('CN_ADDRESS'),pkg_contact.get_primary_address(c_com.contact_id)) company_address,
  ent.obj_name(ent.id_by_brief('CN_ADDRESS'),pkg_contact.get_primary_address(c_com.contact_id)) company_mail_address,
  pkg_contact.get_essential(c_com.contact_id) company_essential,
  ent.obj_name(ent.id_by_brief('CN_ADDRESS'),pkg_contact.get_primary_address(c_con.contact_id)) contractor_address
from
  ven_ac_payment ap,
  fund f,
  fund pf,
  rate_type rt,
  doc_templ dt,
  doc_doc dd,
  ven_document d,
  contact c_com,
  contact c_con,
  t_brand_company bc
where
  ap.payment_type_id = 0 and
  ap.fund_id = f.fund_id and
  ap.rev_fund_id = pf.fund_id and
  ap.rev_rate_type_id = rt.rate_type_id(+) and
  ap.doc_templ_id = dt.doc_templ_id and
  dd.child_id = ap.payment_id and
  dd.parent_id = d.document_id and
  ap.contact_id = c_con.contact_id and
  bc.contact_id = c_com.contact_id;

