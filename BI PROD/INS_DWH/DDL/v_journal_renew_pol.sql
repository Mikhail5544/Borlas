CREATE OR REPLACE FORCE VIEW INS_DWH.V_JOURNAL_RENEW_POL AS
select trunc(vost_date.stat_vost_date) date_renew,
       pol.decline_date,
       to_char(ph.ids) ids,
       pol.pol_num,
       cpol.obj_name_orig holder,
       dep.name agency,
       prod.description product,
       p.ins_amount,
       ph.start_date header_start_date,
       f.brief curr,
       trm.description per,
       ch.description sales_ch,

       (select max(pp.start_date)
        from ins.p_policy pp,
             ins.p_pol_addendum_type pad,
             ins.t_addendum_type tt
        where 1=1
              and pp.policy_id = pad.p_policy_id
              and pad.t_addendum_type_id = tt.t_addendum_type_id
              and pp.pol_header_id = ph.policy_header_id
              and tt.description in ('Восстановление основной программы','Восстановление всего договора')
            ) min_date_nonpayed,

       (SELECT count(*)
        FROM
          ins.DOCUMENT d,
          ins.AC_PAYMENT a,
          ins.DOC_TEMPL dt,
          ins.DOC_DOC dd,
          ins.doc_set_off ddo,
          ins.doc_status dso,
          ins.P_POLICY p1,
          ins.DOC_STATUS ds,
          ins.DOC_STATUS_REF dsr
        WHERE d.document_id = a.payment_id
          AND d.doc_templ_id = dt.doc_templ_id
          AND dt.brief = 'PAYMENT'
          AND dd.child_id = d.document_id
          AND dd.parent_id = p1.policy_id
          AND ds.document_id = d.document_id
          AND ds.start_date = (SELECT MAX(dss.start_date)
                               FROM ins.DOC_STATUS dss
                               WHERE dss.document_id = d.document_id)
          AND dsr.doc_status_ref_id = ds.doc_status_ref_id
          and dsr.brief in ('PAID')
          and a.plan_date < p.decline_date

          and ddo.parent_doc_id = a.payment_id
          and ddo.doc_set_off_id = dso.document_id
          and dso.start_date = (SELECT MAX(dss.start_date)
                                FROM ins.DOC_STATUS dss
                                WHERE dss.document_id = dso.document_id)
          and dso.start_date > p.decline_date

          and p1.pol_header_id = p.pol_header_id) cnt_nonpayed,
       nvl((SELECT sum(nvl(dd.parent_amount,0))
        FROM
          ins.DOCUMENT d,
          ins.AC_PAYMENT a,
          ins.DOC_TEMPL dt,
          ins.DOC_DOC dd,
          ins.P_POLICY p1,
          ins.DOC_STATUS ds,
          ins.DOC_STATUS_REF dsr
        WHERE d.document_id = a.payment_id
          AND d.doc_templ_id = dt.doc_templ_id
          AND dt.brief = 'PAYMENT'
          AND dd.child_id = d.document_id
          AND dd.parent_id = p1.policy_id
          AND ds.document_id = d.document_id
          AND ds.start_date = (SELECT MAX(dss.start_date)
                               FROM ins.DOC_STATUS dss
                               WHERE dss.document_id = d.document_id)
          AND dsr.doc_status_ref_id = ds.doc_status_ref_id
          and dsr.brief in ('TO_PAY')
          and a.plan_date < p.decline_date
          and p1.pol_header_id = p.pol_header_id),0) sum_nonpayed,
        ins.pkg_renlife_utils.get_grace_date_nonpayed(p.pol_header_id, p.decline_date) grace_date_nonpayed,
        ins.pkg_renlife_utils.get_due_date_payed(p.pol_header_id, p.decline_date, 1) due_date_payed,
        ins.pkg_renlife_utils.get_due_date_payed(p.pol_header_id, p.decline_date, 2) sum_payed,
       (SELECT count(*)
        FROM
          ins.DOCUMENT d,
          ins.AC_PAYMENT a,
          ins.DOC_TEMPL dt,
          ins.DOC_DOC dd,
          ins.P_POLICY p1,
          ins.DOC_STATUS ds,
          ins.DOC_STATUS_REF dsr
        WHERE d.document_id = a.payment_id
          AND d.doc_templ_id = dt.doc_templ_id
          AND dt.brief = 'PAYMENT'
          AND dd.child_id = d.document_id
          AND dd.parent_id = p1.policy_id
          AND ds.document_id = d.document_id
          AND ds.start_date = (SELECT MAX(dss.start_date)
                               FROM ins.DOC_STATUS dss
                               WHERE dss.document_id = d.document_id)
          AND dsr.doc_status_ref_id = ds.doc_status_ref_id
          and dsr.brief in ('TO_PAY')
          and a.plan_date < sysdate
          and p1.pol_header_id = p.pol_header_id) cnt_sysdate,
       nvl((SELECT sum(nvl(dd.parent_amount,0))
        FROM
          ins.DOCUMENT d,
          ins.AC_PAYMENT a,
          ins.DOC_TEMPL dt,
          ins.DOC_DOC dd,
          ins.P_POLICY p1,
          ins.DOC_STATUS ds,
          ins.DOC_STATUS_REF dsr
        WHERE d.document_id = a.payment_id
          AND d.doc_templ_id = dt.doc_templ_id
          AND dt.brief = 'PAYMENT'
          AND dd.child_id = d.document_id
          AND dd.parent_id = p1.policy_id
          AND ds.document_id = d.document_id
          AND ds.start_date = (SELECT MAX(dss.start_date)
                               FROM ins.DOC_STATUS dss
                               WHERE dss.document_id = d.document_id)
          AND dsr.doc_status_ref_id = ds.doc_status_ref_id
          and dsr.brief in ('TO_PAY')
          and a.plan_date < sysdate
          and p1.pol_header_id = p.pol_header_id),0) sum_sysdate,
       ins.pkg_renlife_utils.get_grace_date_nonpayed(p.pol_header_id, sysdate) grace_date_sysdate,
       '' date_to_pay,
       '' note,
       '' date_notice_decline,
       '' date_notice_renew,
       NVL(ca.name, ins.pkg_contact.get_address_name(ca.id)) address_name,
       (case when ca.street_name is not null then 'ул.'||ca.street_name else '' end ||
       case when ca.house_nr is not null then ',д.'||ca.house_nr else '' end ||
       case when ca.block_number is not null then ','||ca.block_number else '' end ||
       case when ca.appartment_nr is not null then ',кв.'||ca.appartment_nr else '' end) fadr,
       (case when ca.city_name is not null then 'г.'||ca.city_name else '' end) city_name,
       case when distr.district_name is not null then tdistr.description_short||' '||distr.district_name else '' end distr_name,
       case when prov.province_name is not null then prov.province_name||' '||tprov.description_short else '' end province_name,
       case when reg.region_name is not null then reg.region_name||' '||treg.description_short else '' end region_name,
       (select distinct tc.description from ins.t_country tc where tc.id = ca.country_id) country_name,
       ca.zip,
       vost.pol_header_id,
       ins.pkg_policy.get_last_version_status(ph.policy_header_id) last_stat,

       (select ds.user_name from ins.doc_status ds where ds.doc_status_id = (select max(ds.doc_status_id) stat_id_max
                                                                             from ins.doc_status ds
                                                                             where ds.document_id = ins.pkg_policy.get_last_version(pol.pol_header_id)
                                                                             )
       ) user_name,



      (select max(ppm.decline_date) max_date
            from ins.p_pol_header phm,
                 ins.p_policy ppm,
                 ins.doc_status dsm,
                 ins.doc_status_ref rfm
            where 1=1
                  and phm.policy_header_id = ppm.pol_header_id
                  and ppm.policy_id = dsm.document_id
                  and dsm.doc_status_ref_id = rfm.doc_status_ref_id
                  and rfm.brief in ('READY_TO_CANCEL','TO_QUIT','TO_QUIT_CHECK_READY','TO_QUIT_CHECKED','QUIT_REQ_QUERY','QUIT_REQ_GET','QUIT_TO_PAY','QUIT')
                  and ppm.decline_date is not null
                  and phm.policy_header_id = ph.policy_header_id) new_date_decline
from (select distinct pp.pol_header_id
      from ins.p_policy pp,
           ins.p_pol_addendum_type pad,
           ins.t_addendum_type tt
      where 1=1
            and pp.policy_id = pad.p_policy_id
            and pad.t_addendum_type_id = tt.t_addendum_type_id
            and tt.description in ('Восстановление основной программы','Восстановление всего договора')
      ) vost,
      (select max(ds.start_date) stat_vost_date, pp.pol_header_id
      from ins.p_policy pp,
           ins.p_pol_addendum_type pad,
           ins.t_addendum_type tt,
           ins.doc_status ds,
           ins.doc_status_ref rf
      where 1=1
            and pp.policy_id = pad.p_policy_id
            and pad.t_addendum_type_id = tt.t_addendum_type_id
            and tt.description in ('Восстановление основной программы','Восстановление всего договора')
            and ds.doc_status_ref_id = rf.doc_status_ref_id
            and rf.brief = 'CURRENT'
            and pp.policy_id = ds.document_id
      group by pp.pol_header_id
      ) vost_date,
      (select pp.policy_id, pp.pol_header_id, pp.decline_date, pp.pol_num
      from ins.p_policy pp,
           (select max(pp.decline_date) max_date, ph.policy_header_id, pp.pol_num, ph.ids--lead(pp.policy_id) over (ORDER BY pp.decline_date)--min(pp.decline_date) md, ph.policy_header_id, pp.pol_num, ph.ids
            from ins.p_pol_header ph,
                 ins.p_policy pp,
                 ins.doc_status ds,
                 ins.doc_status_ref rf
            where 1=1
                  and ph.policy_header_id = pp.pol_header_id
                  and pp.policy_id = ds.document_id
                  and ds.doc_status_ref_id = rf.doc_status_ref_id
                  and rf.brief IN ('READY_TO_CANCEL','QUIT')
                  and pp.decline_date is not null
            group by ph.policy_header_id,pp.pol_num, ph.ids) gkr
      where gkr.policy_header_id = pp.pol_header_id
            and pp.decline_date = gkr.max_date
      ) pol,
      ins.p_pol_header ph,
      ins.p_policy p,
      ins.t_product prod,
      ins.t_contact_pol_role polr,
      ins.p_policy_contact pcnt,
      ins.contact cpol,
      ins.fund f,
      ins.department dep,
      ins.t_sales_channel ch,
      ins.t_payment_terms trm,

      ins.cn_address ca,
      ins.t_province prov,
      ins.t_region reg,
      ins.t_district distr,
      ins.t_region_type treg,
      ins.t_province_type tprov,
      ins.t_district_type tdistr
where vost.pol_header_id = pol.pol_header_id
      and vost_date.pol_header_id = vost.pol_header_id
      and pol.pol_header_id = ph.policy_header_id
      and p.policy_id = pol.policy_id
      and prod.product_id = ph.product_id
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = p.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and ph.fund_id = f.fund_id
      and ph.agency_id = dep.department_id(+)
      and ph.sales_channel_id = ch.id(+)
      and p.payment_term_id = trm.id

      AND ins.pkg_contact.get_primary_address(cpol.contact_id) = ca.ID
      and ca.region_id = reg.region_id(+)
      and ca.province_id = prov.province_id(+)
      and ca.district_id = distr.district_id(+)
      and reg.region_type_id = treg.region_type_id(+)
      and prov.province_type_id = tprov.province_type_id(+)
      and distr.district_type_id = tdistr.district_type_id(+)
--order by 1,5
;

