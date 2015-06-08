create or replace force view v_ag_all_agent_sgp as
select --SQ_ AG_STAT_DET _TMP.nextval AG_STAT_DET_TMP_ID, 
                        A.ag_contract_header_id-- иди договора агента 
                       , 
                        A.POL_HEADER_ID -- заголовок договора страхования 
        , 
      A.POLicy_ID -- версия договора страхования 
                       , 
                        A.agent_rate * A.koef * ((A.koef_ccy * A.sum_prem) - A.sum_izd) sgp_amount/** koef_prikaz */ -- сумма премии минус издержки с учетом коэффициентов 
      , 
       pkg_agent_1.get_agent_start_contr(a.POL_HEADER_ID) as date_policy 
      , 
      to_char(pkg_agent_1.get_agent_start_contr(a.POL_HEADER_ID),'mm.yyyy') as date_month 
                  from (select (case -- коэффициент доли агента при заключении договора 
                                  when (ar.brief = 'PERCENT') then pa.part_agent / 100 -- процент 
          --- для данного условия сделан коментарий 
                               /*when (ar.brief = 'ABSOL') then pa.part_agent -- абсолютная величина*/ 
                               else  pa.part_agent -- в противном случае доля агента, как абсолютная величина 
                               end) 
        agent_rate, 
                               (case 
                                  when pt.brief = 'Единовременно' and 
                                       ceil(months_between(last_day(pp.end_date), 
                                       last_day(pkg_agent_1.get_agent_start_contr(ph.policy_header_id)))) > 12 then 0.1 -- более года 
          --- для данного условия сделан коментарий 
                                  /*when (pt.brief = 'Единовременно' and 
                                      ceil(months_between(last_day(pp.end_date), 
                                       last_day(pkg_agent_1.get_agent_start_contr(ph.policy_header_id)))) <= 12) or pt.brief <> 'Единовременно' then 1*/ 
                                  else 1 
                                end) 
         koef, 
                                acc_new.Get_Rate_By_ID( (select rt.rate_type_id from Rate_Type rt where rt.brief = 'ЦБ'), 
                                                      ph.fund_id, 
                                                      pp.start_date) 
         koef_ccy, 
                                pt.number_of_payments * (select sum(pc.fee) 
                                    from p_cover pc, as_asset aa 
                                   where aa.p_policy_id = pp.policy_id 
                                     and aa.as_asset_id = pc.as_asset_id) 
                     sum_prem /*сумма премии*/, 
                           pkg_agent_1.find_sum_adm_izd(ph.policy_header_id) * pt.number_of_payments sum_izd, -- сумма издержек * на количество выплат в году 
                           pp.policy_id policy_id, -- версия договора страхования 
         pp.POL_HEADER_ID, -- голова договора страхования 
         pa.ag_contract_header_id 
                         from ven_p_pol_header ph, 
                                ven_p_policy     pp, 
                                ven_p_policy_agent      pa, 
                                ven_ag_contract_header  ch, 
                                ven_policy_agent_status pas, 
                                ven_ag_type_rate_value  ar, 
                                ven_t_payment_terms pt -- заголовок договора страхования 
                          where ph.policy_id = pp.policy_id 
                            and exists 
                             (select 1 
                                      from ven_doc_doc    d, 
                                           ven_ac_payment ap, 
                                           doc_set_off    dso, 
                                           ven_ac_payment pa2, 
                                           ac_payment_templ acpt, 
                                           -- возможно что версия поменялась 
                                           -- Счета могут быть выставлены и не с текущей версии 
                                           p_policy pp_2 
                                     where pp_2.pol_header_id = ph.policy_header_id 
                                       and d.parent_id = pp_2.policy_id 
                                       and acpt.payment_templ_id = pa2.payment_templ_id 
                                       and ap.payment_id = d.child_id 
                                       and doc.get_doc_status_brief(ap.payment_id) = 'PAID' 
                                       and dso.parent_doc_id = ap.payment_id 
                                       and dso.child_doc_id = pa2.payment_id 
                                       ) 
                            and ph.policy_header_id = pa.policy_header_id 
                            and ch.ag_contract_header_id = pa.ag_contract_header_id 
                            and pa.status_id = pas.policy_agent_status_id 
                            and pa.ag_type_rate_value_id = ar.ag_type_rate_value_id 
                            and pt.id = pp.payment_term_id 
                            -- Если оплата пришла по А7 то дату считать от даты Документа, иначе брать дату ДС 
                            and pas.brief in ('CURRENT') -- статус агента по договору страхования 
                            and exists (select 1 from ven_p_policy_contact ppc, ven_t_contact_pol_role tcp 
                                  where tcp.id = ppc.contact_policy_role_id 
                                    and tcp.brief = 'Страхователь' 
                                    and ppc.policy_id = pp.policy_id 
                                    and ch.agent_id <> ppc.contact_id) 
      ) A
;

