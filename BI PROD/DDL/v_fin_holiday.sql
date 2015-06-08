create or replace force view v_fin_holiday as
select pl.policy_id,
       pl.version_num,
       dep.name agency,
       pl.pol_ser||' '||pl.pol_num pol_num,
       nvl(vin.ex_inv,'Нет') invest,
       pl.start_date,
       pl.notice_date_addendum,
       trunc(dst.start_date) stat_date,
--     pay.plan_date,
       so.list_doc_amount,
       Pkg_Payment.get_set_off_amount(pay.child_id, pl.pol_header_id,NULL) part_pay_amount,
       pay.parent_amount,
       so.list_doc_date,
        (select f.brief from fund f where f.fund_id = pay.fund_id) fund_pay
from (select max(pp.policy_id) pol_id, pp.pol_header_id
           from p_policy pp
                join p_pol_addendum_type at on at.p_policy_id = pp.policy_id
           where at.t_addendum_type_id = 682
           group by pp.pol_header_id) mpol
     join p_policy pl on (pl.policy_id = mpol.pol_id)
     join p_pol_header ph on (ph.policy_header_id = pl.pol_header_id)
     left join department dep on dep.department_id = ph.agency_id
     left join (select ds.document_id, min(ds.start_date) start_date
                from ven_doc_status ds, ven_doc_status_ref dsr
                where ds.doc_status_ref_id = dsr.doc_status_ref_id(+)
                      and dsr.brief = 'CURRENT'
                group by ds.document_id) dst on (dst.document_id = pl.policy_id)
     left join (select p.pol_header_id, p.version_num, 'ДА' ex_inv
                from p_policy p,
                     as_asset ass,
		                 p_cover pc,
		                 t_prod_line_option plo
                where ass.p_policy_id = p.policy_id
                      and p.policy_id = ass.p_policy_id
                      and pc.as_asset_id = ass.as_asset_id
                      and plo.id = pc.t_prod_line_option_id
                      and (plo.description = 'Дополнительный инвестиционный доход'
	  		                   or plo.description = 'ИНВЕСТ'
			                     or plo.description = 'ИНВЕСТ2'
			                     or plo.description = 'ИНВЕСТ2_1')) vin on (vin.pol_header_id = pl.pol_header_id and vin.version_num = pl.version_num - 1)
    left join (select dd.parent_id, ac.plan_date, dd.child_id, ac.fund_id, dd.parent_amount
               from doc_doc dd
                    left join document d on (d.document_id = dd.child_id)
                    left join ac_payment ac on (ac.payment_id = d.document_id)
                    left join doc_status ds on (ds.document_id = ac.payment_id)
                    left join doc_status_ref rf on (rf.doc_status_ref_id = ds.doc_status_ref_id)
               where rf.name = 'Оплачен') pay on (pay.parent_id = pl.policy_id and pay.plan_date = pl.start_date)
   left join v_policy_payment_set_off so on (so.main_doc_id = pay.child_id)

/*Просьба в отчет Финансовые каникулы внести следующие изменения:
Добавить колонку <валюта оплаты>
В поле <сумма оплаты> должна попадать сумма по ЭПГ = <сумма по договору>, т.е. данные в этом поле должны быть всегда,
 а в поле <сумма зачтено> - только если был зачет.*/

--where at.t_addendum_type_id = 682

--select * from p_pol_addendum_type tt where tt.p_policy_id = 5844313 for update
     --select * from v_policy_payment_schedule
;

