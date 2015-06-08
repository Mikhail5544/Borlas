create or replace force view v_gl_ins_contract as
select 1 CONTRACT_TYPE_ID, -- вид договора: 1 - прямой, 2 - принятый, 3  - переданный
       999 FINANCE_PERIOD_ID, -- финансовый период
       ph.fund_id CURRENCY_ID, -- валюта договора
       pl.insurance_group_id INS_LICENCE_TYPE_ID, -- вид страхования
       pc.start_date BEGIN_DATE, -- дата начала
       pc.end_date END_DATE,   -- дата окончания
       nach_first.trans_date ACC_DATE, -- дата первого начисления
       pp.sign_date REG_DATE, -- дата регистрации
       0 PROPORTIONAL, --Если Вид договора = "Принятый", то указывается Пропорциональный он или нет
       case doc.get_doc_status_name(pp.policy_id) -- дата расторжения
        when 'Расторгнут' then pp.start_date 
        else null
       end CANCEL_DATE,
       nach_prem.prem PREMIUM_AMOUNT, -- начисленная премия,
       pp.num CONTR_NUMBER, -- номер договора 
       pc.ent_id ORIGIN_ID, -- ид оригинальной сущности
       com.prem COMPENS_AMOUNT, -- вознаграждение по договору
       0 DEDUCT_AMOUNT,--Сумма отчислений по договору
       0 DECLARED_CLAIM_AMOUNT,--сумма заявленного  по договору убытка
       0 PAYS_CLAIM_AMOUNT,--сумма выплат по убытку
       0 CANCEL_PAYMENTS--выплаты в связи с расторжением
from ven_p_cover pc
 join t_prod_line_option plo on plo.id = pc.t_prod_line_option_id
 join t_product_line pl on pl.id = plo.product_line_id
 join as_asset ass on ass.as_asset_id  = pc.as_asset_id
 join ven_p_policy pp on pp.policy_id = ass.p_policy_id
 join p_pol_header ph on ph.policy_header_id = pp.pol_header_id
 join ( select  distinct tr.A5_DT_URO_ID cover,tr.trans_date 
        from trans tr
         join trans_templ tt on tt.trans_templ_id = tr.trans_templ_id
        where tt.brief = 'НачПремия' 
          and tr.trans_date = (select min (tr1.trans_date)
                               from trans tr1
                               where tr1.a5_dt_uro_id = tr.a5_dt_uro_id
                                 and tr1.trans_templ_id = tr.trans_templ_id
                              )
      ) nach_first on nach_first.cover = pc.p_cover_id
 join ( select  tr.a5_dt_uro_id cover,sum(tr.trans_amount) prem
        from trans tr
         join trans_templ tt on tt.trans_templ_id = tr.trans_templ_id
        where tt.brief = 'НачПремия' 
        group by tr.a5_dt_uro_id
      ) nach_prem on nach_prem.cover = pc.p_cover_id  
 left join ( select tr.A5_CT_URO_ID cover,nvl(sum(tr.acc_amount),0) prem
             from trans tr
              join trans_templ tt on tt.trans_templ_id = tr.trans_templ_id
             where tt.brief in ('НачКВ')
             group by tr.A5_CT_URO_ID
            ) com on com.cover = pc.p_cover_id
;

