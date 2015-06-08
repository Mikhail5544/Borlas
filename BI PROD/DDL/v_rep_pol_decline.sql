create or replace force view v_rep_pol_decline as
select ids                       "ИДС"
     , vi.contact_name           "Страхователь"
     , pd.act_date               "Дата акта"
     , pp.decline_date           "Дата расторжения"
     , pd.issuer_return_date     "Дата выплаты"
     , pd.issuer_return_sum      issuer_return_sum
     , pp.return_summ            "Итого к выплате"
     , pd.income_tax_sum         "Сумма НДФЛ"
     , dsr.name                  "Статус последней версии"
  from ins.ven_p_pol_header      ph 
     , ins.doc_status_ref        dsr 
     , ins.ven_p_policy          pp 
     , ins.p_pol_decline         pd
     , ins.v_pol_issuer          vi
 where ph.last_ver_id        = pp.policy_id
   and pp.doc_status_ref_id  = dsr.doc_status_ref_id 
   and pp.policy_id          = pd.p_policy_id
   and pp.policy_id          = vi.policy_id
   and dsr.brief in ('TO_QUIT'
                    ,'TO_QUIT_CHECK_READY'
                    ,'TO_QUIT_CHECKED'
                    ,'QUIT'
                    ,'QUIT_REQ_QUERY'
                    ,'QUIT_REQ_GET'
                    ,'QUIT_TO_PAY') 
 order by ids;

