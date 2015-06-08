create or replace force view v_tmp_first_date as
select least(NVL((select --least(NVL( 
                  min(pa2.reg_date) over(partition by ph.policy_header_id) date_a7 
                   from ven_doc_doc      d, 
                        ven_ac_payment   ap, 
                        doc_set_off      dso, 
                        ven_ac_payment   pa2, 
                        ac_payment_templ acpt, 
                        p_pol_header     ph, 
                        p_policy         pp 
                  where ph.policy_header_id = pph.policy_header_id 
                    and pp.pol_header_id = ph.policy_header_id 
                    and d.parent_id = pp.policy_id 
                    and acpt.payment_templ_id = pa2.payment_templ_id 
                    and ap.payment_id = d.child_id 
                    and doc.get_doc_status_brief(ap.payment_id) = 'PAID' 
                    and dso.parent_doc_id = ap.payment_id 
                    and dso.child_doc_id = pa2.payment_id 
                    and acpt.brief = 'A7' 
                    and rownum <= 1), 
                 pph.start_date), 
             pph.start_date) as var_date_ret, 
			 pph.POLICY_HEADER_ID 
  from p_pol_header pph
;

