create or replace force view v_re_claim_payment as
select  dch.document_id,
        rc.re_claim_id,
        rch.num,
        ch.fund_id fund_id, 
        f.brief fund_brief,
        ch.fund_pay_id fund_pay_id,    
        fp.brief fund_brief_pay,
        rc.re_payment_sum payment_sum,
        0 Plan_Amount,
        0 Pay_amount,   
        cm.description col_name,
        pt.description term_name,
        pt.number_of_payments nums,
        rod.t_rate_on_date_id,
        rod.name rate_on_date,
        rod.brief rate_on_date_brief,
        rc.re_claim_status_date first_payment_date,
        pt.id payment_term_id  
 from document  dch,
      ven_re_claim_header rch,
      ven_re_claim rc,
      ven_c_claim_header ch,
      fund f,
      fund fp,
      ven_t_payment_terms      pt,
      ven_t_collection_method  cm,
      t_rate_on_date rod--,
    --  doc_doc dd,
    --  document dp,
    --  doc_templ dt,
     -- ac_payment ap
 where dch.document_id = rch.re_claim_header_id and 
       rch.c_claim_header_id  = ch.c_claim_header_id and  
       ch.fund_id = f.fund_id and
       ch.fund_pay_id = fp.fund_id and
       ch.rate_on_date_id = rod.t_rate_on_date_id(+) and
       pt.description = 'Единовременно' and 
       pt.collection_method_id = cm.id and
       cm.description = 'Безналичный расчет' and
       rc.re_claim_header_id = rch.re_claim_header_id
       and rc.seqno = (select max(rr.seqno)
                       from re_claim rr,
                            c_claim_status ss
                       where rr.re_claim_header_id =  rch.re_claim_header_id
                         and rr.status_id = ss.c_claim_status_id
                         and ss.brief != 'ЗАКРЫТО')
     --  and dd.parent_id = rch.re_claim_header_id
      -- and dp.document_id = dd.child_id 
      -- and dp.doc_templ_id  = dt.doc_templ_id
      -- and dt.brief = 'AccPayOutReins'  
      -- and ap.payment_id =  dp.document_id
;

