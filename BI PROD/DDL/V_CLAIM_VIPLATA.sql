create or replace view v_claim_viplata as
select ch.c_event_id,
       ch.active_claim_id,
       opt.id opt_id,
       pr.description,
       nvl(pkg_renlife_utils.ret_amount_claim(ch.c_event_id, ch.c_claim_header_id, 'В'),0) s_v,
       nvl(pkg_renlife_utils.ret_amount_claim(ch.c_event_id, ch.c_claim_header_id, 'З'),0) s_z,
       (select min(pay.due_date) due_date
        from doc_doc dd,
             document doc,
             ac_payment pay,
             doc_status st,
             doc_status_ref ref,
             p_policy pol,
             doc_templ dt
        where dd.parent_id = pol.policy_id
              and pol.pol_header_id = p.pol_header_id
              and doc.document_id = dd.child_id
              and pay.payment_id = doc.document_id
              and st.document_id = pay.payment_id
              and doc.doc_templ_id = dt.doc_templ_id
              and dt.brief = 'PAYMENT'
              and ref.doc_status_ref_id = st.doc_status_ref_id
              and ref.name in ('Новый')
              and st.start_date = (SELECT MAX(dss.start_date)
                                  FROM DOC_STATUS dss
                                  WHERE dss.document_id = doc.document_id)) due_date,
        (select min(pay.due_date) due_date
        from doc_doc dd,
             document doc,
             ac_payment pay,
             doc_status st,
             doc_status_ref ref,
             p_policy pol,
             doc_templ dt
        where dd.parent_id = pol.policy_id
              and pol.pol_header_id = p.pol_header_id
              and doc.document_id = dd.child_id
              and pay.payment_id = doc.document_id
              and st.document_id = pay.payment_id
              and ref.doc_status_ref_id = st.doc_status_ref_id
              and doc.doc_templ_id = dt.doc_templ_id
              and dt.brief = 'PAYMENT'
              and ref.name in ('К оплате')
              and st.start_date = (SELECT MAX(dss.start_date)
                                  FROM DOC_STATUS dss
                                  WHERE dss.document_id = doc.document_id)) dko_date,
          nvl(( select a.amount
          from
            document d,
            ac_payment a,
            doc_templ dt,
            doc_doc dd,
            c_claim cc,
            c_claim_header chf,
            contact c,
            doc_status ds,
            doc_status_ref dsr,
            p_policy p,
            t_peril pr
          where
            d.document_id = a.payment_id
            and  d.doc_templ_id = dt.doc_templ_id
            and  dd.child_id = d.document_id
            and  dd.parent_id = cc.c_claim_id
            and  a.contact_id = c.contact_id
            and  ds.document_id = d.document_id
            and dt.brief = 'PAYORDER_SETOFF'
            and  ds.start_date = (
              select max(dss.start_date)
              from   doc_status dss
              where  dss.document_id = d.document_id)
            and  dsr.doc_status_ref_id = ds.doc_status_ref_id
            and chf.c_claim_header_id = cc.c_claim_header_id
            and p.policy_id = chf.p_policy_id
            and pr.id = chf.peril_id
            and chf.c_event_id = ch.c_event_id
            and cc.c_claim_id = ch.active_claim_id
            and chf.peril_id = ch.peril_id),0) real_z

from c_claim_header ch,
     p_cover pc,
     t_prod_line_option opt,
     p_policy p,
     t_peril pr
where p.policy_id = ch.p_policy_id
      and pr.id = ch.peril_id
      and ch.p_cover_id = pc.p_cover_id
      and pc.t_prod_line_option_id = opt.id
      and doc.get_last_doc_status_name(ch.active_claim_id) <> 'Закрыт'
      --and ch.c_event_id = 26026291