create or replace force view v_agent_report_c as
select pi.contact_id, -- ИД страхователь
       pi.contact_name, -- страхователь
       ph.num POLICY_NUM, --номер договора страх.
       ph.start_date, --дата заключения
       tp.description tp_desc, --вид страхования
       pl.description pl_desc, -- продукт
       t.trans_amount, --полученная премия
       t.trans_amount premium, --начисленная по договору
       pa.part_agent,
       (select case
                 when dr.brief = 'CONSTANT' and rv.brief = 'PERCENT' then
                  pac.val_com || ' %'
                 when dr.brief = 'CONSTANT' and rv.brief = 'ABSOL' then
                  to_char(pac.val_com)
                 when dr.brief = 'FUNCTION' then
                  to_char(pkg_tariff_calc.calc_fun(pac.t_prod_coef_type_id,
                                                   c.ent_id,
                                                   c.p_cover_id))
                 else
                  null
               end
          from ven_ag_type_defin_rate dr, ven_ag_type_rate_value rv
         where pac.ag_type_defin_rate_id = dr.ag_type_defin_rate_id
           and pac.ag_type_rate_value_id = rv.ag_type_rate_value_id(+)
       ) val_com, --ставка агента
       arc.comission_sum KB_amount,
       (
        select xap.num
        from   oper xo,
               doc_set_off xdso,
               ven_ac_payment xap
        where  xo.oper_id = t.oper_id and
               xo.document_id = xdso.doc_set_off_id and
               xdso.child_doc_id = xap.payment_id
       ) payment_number, --номер платежа
       (
        select xap.due_date
        from   oper xo,
               doc_set_off xdso,
               ven_ac_payment xap
        where  xo.oper_id = t.oper_id and
               xo.document_id = xdso.doc_set_off_id and
               xdso.child_doc_id = xap.payment_id
       ) real_pay_date, --реальная дата платежа
       ph.policy_header_id,
       p.policy_id,
       a.as_asset_id,
       c.p_cover_id,
       pa.p_policy_agent_id,
       pac.p_policy_agent_com_id,
       ar.agent_report_id, -- ИД акта
       arc.agent_report_cont_id,
       arc.is_deduct,
       ar.REPORT_DATE,
       ar.num as AGENT_REPORT_NUM

  from ven_p_policy_agent_com  pac,
       ven_p_policy_agent      pa,
       ven_p_pol_header        ph,
       ven_p_policy            p,
       ven_as_asset            a,
       ven_p_cover             c,
       ven_status_hist         sh,
       ven_t_prod_line_option  plo,
       ven_t_product_line      pl,
       v_pol_issuer            pi,
       ven_t_product           tp,
       ven_agent_report        ar,
       ven_agent_report_cont   arc,
       ven_trans               t

 where pac.p_policy_agent_id = pa.p_policy_agent_id
   and pa.policy_header_id = ph.policy_header_id
   and p.policy_id = ph.policy_id
   and a.p_policy_id = p.policy_id
   and a.as_asset_id = c.as_asset_id
   and sh.status_hist_id = c.status_hist_id
   and c.t_prod_line_option_id = plo.id
   and plo.product_line_id = pac.t_product_line_id
   and pl.id = pac.t_product_line_id
   and pi.policy_id = p.policy_id
   and tp.product_id = ph.product_id
   and arc.agent_report_id = ar.agent_report_id
   and arc.p_policy_agent_com_id = pac.p_policy_agent_com_id
   and t.trans_id = arc.trans_id
;

