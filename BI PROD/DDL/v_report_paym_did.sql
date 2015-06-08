CREATE OR REPLACE FORCE VIEW V_REPORT_PAYM_DID AS
select ph.policy_header_id,
       pp.policy_id,
       ph.ids,
       cpol.obj_name_orig holder,
       cpol.contact_id,
       ct.description type_contact,
       decode(nvl(cpol.resident_flag,0),1,'Резидент',0,'НеРезидент','НеОпределен') resident,
       (select ctr.description
       from ins.cn_address cca,
            ins.t_country ctr
       where ins.pkg_contact.get_primary_address(cpol.contact_id) = cca.id(+)
             and ctr.id = cca.country_id) country_holder,
       nvl((select c.obj_name_orig
         from ven_ac_payment ap,
              doc_doc dd,
              ac_payment_templ apt,
              doc_templ dt,
              contact c
         where 1=1
            and ap.payment_id = dd.child_id
            AND ap.payment_templ_id = apt.payment_templ_id
            AND apt.brief = 'PAYREQ'
            AND ap.doc_templ_id = dt.doc_templ_id
            AND dt.brief = 'PAYREQ'
            and dd.parent_id = pp.policy_id
            and c.contact_id = ap.contact_id),cpol.obj_name_orig) beneficiary,
        nvl((select c.contact_id
         from ven_ac_payment ap,
              doc_doc dd,
              ac_payment_templ apt,
              doc_templ dt,
              contact c
         where 1=1
            and ap.payment_id = dd.child_id
            AND ap.payment_templ_id = apt.payment_templ_id
            AND apt.brief = 'PAYREQ'
            AND ap.doc_templ_id = dt.doc_templ_id
            AND dt.brief = 'PAYREQ'
            and dd.parent_id = pp.policy_id
            and c.contact_id = ap.contact_id),cpol.contact_id) beneficiary_contact_id,
       nvl((select ctb.description
         from ven_ac_payment ap,
              doc_doc dd,
              ac_payment_templ apt,
              doc_templ dt,
              contact c,
              t_contact_type ctb
         where 1=1
            and ap.payment_id = dd.child_id
            AND ap.payment_templ_id = apt.payment_templ_id
            AND apt.brief = 'PAYREQ'
            AND ap.doc_templ_id = dt.doc_templ_id
            AND dt.brief = 'PAYREQ'
            and dd.parent_id = pp.policy_id
            and c.contact_id = ap.contact_id
            and cpol.contact_type_id = ctb.id),ct.description) beneficiary_contact_type,
       nvl((select decode(nvl(c.resident_flag,0),1,'Резидент',0,'НеРезидент','НеОпределен')
         from ven_ac_payment ap,
              doc_doc dd,
              ac_payment_templ apt,
              doc_templ dt,
              contact c
         where 1=1
            and ap.payment_id = dd.child_id
            AND ap.payment_templ_id = apt.payment_templ_id
            AND apt.brief = 'PAYREQ'
            AND ap.doc_templ_id = dt.doc_templ_id
            AND dt.brief = 'PAYREQ'
            and dd.parent_id = pp.policy_id
            and c.contact_id = ap.contact_id),decode(nvl(cpol.resident_flag,0),1,'Резидент',0,'НеРезидент','НеОпределен')) beneficiary_resident,
       nvl((select ctrb.description
         from ven_ac_payment ap,
              doc_doc dd,
              ac_payment_templ apt,
              doc_templ dt,
              contact c,
              ins.cn_address cca,
              ins.t_country ctrb
         where 1=1
            and ap.payment_id = dd.child_id
            AND ap.payment_templ_id = apt.payment_templ_id
            AND apt.brief = 'PAYREQ'
            AND ap.doc_templ_id = dt.doc_templ_id
            AND dt.brief = 'PAYREQ'
            and dd.parent_id = pp.policy_id
            and c.contact_id = ap.contact_id
            and ins.pkg_contact.get_primary_address(c.contact_id) = cca.id(+)
            and ctrb.id = cca.country_id),
        (select ctr.description
         from ins.cn_address cca,
              ins.t_country ctr
         where ins.pkg_contact.get_primary_address(cpol.contact_id) = cca.id(+)
           and ctr.id = cca.country_id)) country_beneficiary,
        (select pd.issuer_return_date
        from ven_p_policy p,
             ven_t_decline_reason dr,
             ven_p_pol_header ph,
             v_pol_issuer vi,
             ven_fund fp,
             ven_t_payment_terms pt,
             ven_p_pol_decline pd
        where 1=1
          and p.decline_reason_id = dr.t_decline_reason_id(+)
          and ph.policy_header_id = p.pol_header_id
          and p.policy_id = vi.policy_id
          and ph.fund_id = fp.fund_id
          and pt.id = p.payment_term_id
          and p.policy_id = pd.p_policy_id
          and p.policy_id = pp.policy_id) issuer_return_date,
      round((select sum(pc.add_invest_income)
      from ven_p_pol_decline pd,
           p_cover_decline pc
      where pd.p_policy_id = pp.policy_id
            and pd.p_pol_decline_id = pc.p_pol_decline_id),2) add_invest_income,
      round(nvl(pp.return_summ,0),2) return_summ,
      f.brief currency
from p_pol_header ph,
     p_policy pp,
     t_contact_pol_role polr,
     p_policy_contact pcnt,
     contact cpol,
     t_contact_type ct,
     fund f
where pp.policy_id = pkg_policy.get_last_version(ph.policy_header_id)
      and doc.get_doc_status_brief(pp.policy_id) in ('TO_QUIT',
                                                     'TO_QUIT_CHECK_READY',
                                                     'TO_QUIT_CHECKED',
                                                     'QUIT_REQ_QUERY',
                                                     'QUIT_REQ_GET',
                                                     'QUIT_TO_PAY',
                                                     'QUIT')
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and cpol.contact_type_id = ct.id
      and f.fund_id = ph.fund_id
      and (select pd.issuer_return_date
          from ven_p_policy p,
               ven_t_decline_reason dr,
               ven_p_pol_header ph,
               v_pol_issuer vi,
               ven_fund fp,
               ven_t_payment_terms pt,
               ven_p_pol_decline pd
          where 1=1
            and p.decline_reason_id = dr.t_decline_reason_id(+)
            and ph.policy_header_id = p.pol_header_id
            and p.policy_id = vi.policy_id
            and ph.fund_id = fp.fund_id
            and pt.id = p.payment_term_id
            and p.policy_id = pd.p_policy_id
            and p.policy_id = pp.policy_id)
      between to_date((SELECT r.param_value
                   FROM ins_dwh.rep_param r
                   WHERE r.rep_name = 'rep_for_did'
                     AND r.param_name = 'date_from'),'dd.mm.yyyy') and
              to_date((SELECT r.param_value
                   FROM ins_dwh.rep_param r
                   WHERE r.rep_name = 'rep_for_did'
                     AND r.param_name = 'date_to'),'dd.mm.yyyy')
      --and ph.ids = 1150044633
;

