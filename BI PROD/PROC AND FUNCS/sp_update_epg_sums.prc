create or replace procedure SP_UPDATE_EPG_SUMS
/*
  Байтин А.
  Процедура для облегчения выполнения заявок с просьбами поправить суммы ЭПГ.
  
  par_ids - ИДС
  par_epg_date - дата ЭПГ
  par_due_date - дата выставления ЭПГ
  par_payment_id - ИД ЭПГ
  par_payment_num - Номер ЭПГ
  par_sum - сумма, на которую нужно изменить
*/
(
  par_ids         in number
 ,par_plan_date   in date     default null
 ,par_due_date    in date     default null
 ,par_payment_id  in number   default null
 ,par_payment_num in varchar2 default null
 ,par_sum         in number
)
is
  v_payment_id number;
  v_doc_doc_id number;
begin
  if par_plan_date is not null then
    select ap.payment_id
          ,dd.doc_doc_id
      into v_payment_id
          ,v_doc_doc_id
      from p_pol_header ph
          ,p_policy     pp
          ,doc_doc      dd
          ,ac_payment   ap
          ,document     dc
          ,doc_templ    dt
     where ph.ids              = par_ids
       and ph.policy_header_id = pp.pol_header_id
       and pp.policy_id        = dd.parent_id
       and dd.child_id         = ap.payment_id
       and ap.payment_id       = dc.document_id
       and dc.doc_templ_id     = dt.doc_templ_id
       and dt.brief            = 'PAYMENT'
       and ap.plan_date        = par_plan_date;
  elsif par_due_date is not null then
    select ap.payment_id
          ,dd.doc_doc_id
      into v_payment_id
          ,v_doc_doc_id
      from p_pol_header ph
          ,p_policy     pp
          ,doc_doc      dd
          ,ac_payment   ap
          ,document     dc
          ,doc_templ    dt
     where ph.ids              = par_ids
       and ph.policy_header_id = pp.pol_header_id
       and pp.policy_id        = dd.parent_id
       and dd.child_id         = ap.payment_id
       and ap.payment_id       = dc.document_id
       and dc.doc_templ_id     = dt.doc_templ_id
       and dt.brief            = 'PAYMENT'
       and ap.due_date         = par_due_date;
  elsif par_payment_id is not null then
    select ap.payment_id
          ,dd.doc_doc_id
      into v_payment_id
          ,v_doc_doc_id
      from p_pol_header ph
          ,p_policy     pp
          ,doc_doc      dd
          ,ac_payment   ap
     where ph.ids              = par_ids
       and ph.policy_header_id = pp.pol_header_id
       and pp.policy_id        = dd.parent_id
       and dd.child_id         = ap.payment_id
       and ap.payment_id       = par_payment_id;
  elsif par_payment_num is not null then
    select ap.payment_id
          ,dd.doc_doc_id
      into v_payment_id
          ,v_doc_doc_id
      from p_pol_header ph
          ,p_policy     pp
          ,doc_doc      dd
          ,ac_payment   ap
          ,document     dc
          ,doc_templ    dt
     where ph.ids              = par_ids
       and ph.policy_header_id = pp.pol_header_id
       and pp.policy_id        = dd.parent_id
       and dd.child_id         = ap.payment_id
       and ap.payment_id       = dc.document_id
       and dc.doc_templ_id     = dt.doc_templ_id
       and dt.brief            = 'PAYMENT'
       and dc.num              = par_payment_num;
  end if;

  update ven_ac_payment p
     set amount     = par_sum
        ,rev_amount = par_sum
   where p.payment_id = v_payment_id;

  update doc_doc dd
     set dd.parent_amount = par_sum
        ,dd.child_amount  = par_sum
   where dd.doc_doc_id = v_doc_doc_id;

end SP_UPDATE_EPG_SUMS;
/

