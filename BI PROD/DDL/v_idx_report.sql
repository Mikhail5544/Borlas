create or replace view v_idx_report as
select TO_CHAR(ph.start_date,'MM')||'.'||TO_CHAR(hn.date_index,'YYYY') date_idx,
       pa.filial,
       hn.name_status_item status_name,

       ph.num pol_num,
       ent.obj_name('CONTACT', PKG_POLICY.GET_POLICY_HOLDER_ID(ph.POLICY_ID)) insurer,
       case when hn.name_status_item in ('Согласились на индексацию','Напечатан','Индексация') then dop2.ins_premiumi else 0 end ins_premiumi,
       nvl(case when hn.name_status_item in ('Согласились на индексацию','Напечатан','Индексация','Отменен','Отказались от индексации') then dop1.ins_premium else 0 end,dop.premium) ins_premium,
       case when hn.name_status_item in ('Согласились на индексацию','Напечатан','Индексация') then (case when dop2.ins_premiumi - dop1.ins_premium < 0 then 0 else dop2.ins_premiumi - dop1.ins_premium end) else 0 end diff,
       ph.start_date
from ( select max(to_char(h.date_index,'dd.mm')) dm,
              extract(year from h.date_index) year,
             i.policy_header_id
        from policy_index_header h,
             policy_index_item i,
             ins.document d,
             ins.doc_status_ref rf
        where h.policy_index_header_id = i.policy_index_header_id
              AND h.policy_index_header_id = d.document_id
              AND d.doc_status_ref_id = rf.doc_status_ref_id
              AND rf.brief != 'CANCEL'
              /*AND i.policy_header_id = 795901*/
        group by extract(year from h.date_index),
                 i.policy_header_id) h

  join (select i.policy_index_item_id,
               to_char(h.date_index,'dd.mm') dm,
               extract(year from h.date_index) year,
               i.policy_header_id,
               h.date_index,
               rfi.name name_status_item
        from policy_index_header h,
             policy_index_item i,
             ins.document d,
             ins.doc_status_ref rf,
             ins.document di,
             ins.doc_status_ref rfi
        where h.policy_index_header_id = i.policy_index_header_id
              AND h.policy_index_header_id = d.document_id
              AND d.doc_status_ref_id = rf.doc_status_ref_id
              AND rf.brief != 'CANCEL'
              AND i.policy_index_item_id = di.document_id
              AND di.doc_status_ref_id = rfi.doc_status_ref_id
              /*AND i.policy_header_id = 795901*/
        ) hn on (hn.policy_header_id = h.POLICY_HEADER_ID
                and hn.dm = h.dm
                and hn.year = h.year)
  join ven_p_pol_header ph on (ph.policy_header_id = h.POLICY_HEADER_ID)

left join (select a.p_policy_agent_doc_id pa_id,
                  a.policy_header_id,
                  a.ag_contract_header_id,
                  dep.name filial
           from ins.p_policy_agent_doc a,
                ins.document da,
                ins.doc_status_ref rfa,
                department dep,
                ins.ag_contract_header agh
           where a.p_policy_agent_doc_id = da.document_id
                 AND da.doc_status_ref_id = rfa.doc_status_ref_id
                 AND rfa.brief = 'CURRENT'
                 AND a.ag_contract_header_id = agh.ag_contract_header_id
                 AND agh.agency_id = dep.department_id
           ) pa on (ph.policy_header_id = pa.policy_header_id)

  join (
       select ph.start_date,
       sum(pc.fee * trm.number_of_payments) + 300 premium,
       p.version_num,
       ph.policy_header_id,
       p.policy_id
       from p_pol_header ph,
            t_payment_terms trm,
            p_policy p,
            as_asset ast,
            p_cover pc,
            t_prod_line_option plo,
            t_product_line pl,
            t_product_line_type plt
       where ph.policy_header_id = p.pol_header_id
             and ast.p_policy_id = p.policy_id
             and trm.id = p.payment_term_id
             and ast.as_asset_id = pc.as_asset_id
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pc.decline_date is null
             and pl.product_line_type_id = plt.product_line_type_id
             --and plt.brief = 'RECOMMENDED'
             and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
             /*and ph.policy_header_id = 795901*/
       group by ph.start_date,
                p.version_num,
                ph.policy_header_id,
                p.policy_id) dop on (dop.policy_id = ph.policy_id)


left join (
       select ph.start_date,
       sum(pc.fee * trm.number_of_payments) + 300 ins_premiumi,
       p.version_num,
       ph.policy_header_id,
       p.policy_id,
       TO_CHAR(p.start_date,'YYYY') year_pol
       from p_pol_header ph,
            t_payment_terms trm,
            p_policy p,
            as_asset ast,
            p_cover pc,
            t_prod_line_option plo,
            t_product_line pl,
            t_product_line_type plt,
            p_pol_addendum_type adt
       where ph.policy_header_id = p.pol_header_id
             and ast.p_policy_id = p.policy_id
             and trm.id = p.payment_term_id
             and ast.as_asset_id = pc.as_asset_id
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pc.decline_date is null
             and pl.product_line_type_id = plt.product_line_type_id
             --and plt.brief = 'RECOMMENDED'
             and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
             and adt.p_policy_id = p.policy_id
             and adt.t_addendum_type_id = 20
             /*and ph.policy_header_id = 795901*/
       group by ph.start_date,
                p.version_num,
                ph.policy_header_id,
                p.policy_id,
                p.start_date) dop2 on (dop2.policy_header_id = h.policy_header_id
                                      AND dop2.year_pol = hn.year)
left join (
       select ph.start_date,
       sum(pc.fee * trm.number_of_payments) + 300 ins_premium,
       p.version_num,
       ph.policy_header_id,
       p.policy_id
       from p_pol_header ph,
            t_payment_terms trm,
            p_policy p,
            as_asset ast,
            p_cover pc,
            t_prod_line_option plo,
            t_product_line pl,
            t_product_line_type plt
       where ph.policy_header_id = p.pol_header_id
             and ast.p_policy_id = p.policy_id
             and trm.id = p.payment_term_id
             and ast.as_asset_id = pc.as_asset_id
             and plo.id = pc.t_prod_line_option_id
             and plo.product_line_id = pl.id
             and pc.decline_date is null
             and pl.product_line_type_id = plt.product_line_type_id
             --and plt.brief = 'RECOMMENDED'
             and upper(trim(plo.description)) NOT IN ('АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ')
             /*and ph.policy_header_id = 795901*/
       group by ph.start_date,
                p.version_num,
                ph.policy_header_id,
                p.policy_id) dop1 on (dop1.policy_header_id = h.policy_header_id
                                      and dop1.version_num = dop2.version_num - 1)

 where hn.name_status_item NOT IN ('Ошибка в расчете')
       --and ph.num like '%032167%'
       /*and ph.policy_header_id = 795901*/
       --and doc.get_doc_status_name(hn.POLICY_INDEX_ITEM_ID) = 'Отказались от индексации';
