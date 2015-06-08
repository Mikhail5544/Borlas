create or replace force view v_agent_report_cont as
select arc."AGENT_REPORT_CONT_ID",arc."ENT_ID",arc."FILIAL_ID",arc."COMISSION_SUM",arc."AGENT_REPORT_ID",arc."IS_DEDUCT",arc."EXT_ID",arc."P_POLICY_AGENT_COM_ID",arc."TRANS_ID",arc."AG_TYPE_RATE_VALUE_ID",arc."PART_AGENT",arc."SAV",arc."POLICY_ID",arc."DATE_PAY",arc."SUM_PREMIUM",arc."SUM_RETURN",arc."METHOD_PAYMENT",arc."P_COVER_ID",arc."PROD_LINE_OPTION_ID",arc."MLEAD_ID",
       plo.description prod_line_opt_name,
       pl.description prod_line_name,
       ig.description ins_group_name,
       pi.contact_name issuer_name,
       c.premium cover_premium_amount,
       NULL agent_premium_amount,
   /*    (
        select nvl(sum(t.trans_amount), 0)
        from   trans t, oper o, trans_templ tt, doc_set_off dso
        where  t.a5_dt_uro_id = c.p_cover_id and
               o.oper_id = t.oper_id and
               o.document_id = dso.doc_set_off_id and
               dso.child_doc_id = ap.payment_id and
               t.trans_templ_id = tt.trans_templ_id and
               tt.brief = 'ПеренесЗадолж'
       ) agent_premium_amount, */
       tdf.name defin_rate_name,
       trv.name type_rate_name,
       NULL rate_value,
       NULL payment_num,
       NULL payment_date,
       --ca.rate_value,
 /*      ap.num payment_num,
       ap.real_pay_date payment_date, */
       d.num policy_num,
							plo.id PROD_LINE_OPT_code
  from agent_report_cont  arc,
     --  p_cover_agent      ca,
       p_cover            c,
       t_prod_line_option plo,
       t_product_line     pl,
       t_insurance_group  ig,
       v_pol_issuer       pi,
       as_asset           a,
      -- ag_rate            r,
       ag_type_defin_rate tdf,
       ag_type_rate_value trv,
      -- ven_ac_payment         ap,
       document d
 where 1=1--arc.cover_agent_id = ca.cover_agent_id
   and arc.p_cover_id = c.p_cover_id
   and c.t_prod_line_option_id = plo.id
   and plo.product_line_id = pl.id
   and pl.insurance_group_id = ig.t_insurance_group_id
   and pi.policy_id = a.p_policy_id
   and a.as_asset_id = c.as_asset_id
  -- and ca.rate_id = r.ag_rate_id(+)
 --  and r.type_defin_rate_id = tdf.ag_type_defin_rate_id(+)
 --  and r.type_rate_value_id = trv.ag_type_rate_value_id(+)
  -- and arc.payment_id = ap.payment_id
   and d.document_id = a.p_policy_id
;

