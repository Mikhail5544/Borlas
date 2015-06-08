CREATE OR REPLACE VIEW V_REP_BROKER_SALES_CHN AS
select nvl(dep.name,'-') department,
       ch.description sales_chnl,
       ag_cur.num_agent||' '||ag_cur.name_agent agent_name,
       /*(select agh.num||' '||c.obj_name_orig
         from ins.p_policy_agent_doc pad,
              ins.ven_ag_contract_header agh,
              contact c
         where pad.policy_header_id = ph.policy_header_id
               and pad.ag_contract_header_id = agh.ag_contract_header_id
               and agh.agent_id = c.contact_id
               and doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
               and rownum = 1
       ) agent_name,*/
       NVL(ag_cur.num_rec,'-') recruit_num,
       NVL(ag_cur.name_rec,'-') recruit_name,
       pp.pol_num,
       prod.description product,
       ph.start_date,
       cpol.obj_name_orig holder,
       (SELECT rf.name
        FROM ins.doc_status_ref rf
        WHERE rf.doc_status_ref_id = d_act.doc_status_ref_id
       ) active_status,
       /*nvl(doc.get_doc_status_name(ph.policy_id),'-') active_status,*/
       (SELECT rfl.name
        FROM ins.doc_status_ref rfl
        WHERE rfl.doc_status_ref_id = d_last.doc_status_ref_id
       ) last_status,
       /*nvl(pkg_policy.get_last_version_status(ph.policy_header_id),'-') last_status,*/
       doc_st.start_date max_date_status,
       doc_st.change_date max_change_date_status,
       round(pp.end_date - doc_st.change_date,2) days_in_status,
       round(pp.end_date - ph.start_date,2) days_policy,
       doc_st.user_name,
       ph.description note
from p_policy pp,
     ven_p_pol_header ph,
     ins.document d_act,
     ins.document d_last,
     department dep,
     t_sales_channel ch,
     fund f,
     t_contact_pol_role polr,
     p_policy_contact pcnt,
     contact cpol,
     t_product prod,
     ins.document dpol,
     ins.doc_status doc_st,
     (SELECT agh.num num_agent,
             c.obj_name_orig name_agent,
             pad.policy_header_id,
             aghr.num num_rec,
             cr.obj_name_orig name_rec
      FROM ins.p_policy_agent_doc pad,
           ins.ven_ag_contract_header agh,
           ins.contact c,
           ins.document dpad,
           ins.doc_status_ref rfp,
           ins.ag_contract ag,
           ins.ag_contract agr,
           ins.ven_ag_contract_header aghr,
           ins.contact cr
      WHERE pad.ag_contract_header_id = agh.ag_contract_header_id
        AND agh.agent_id = c.contact_id
        AND pad.p_policy_agent_doc_id = dpad.document_id
        AND dpad.doc_status_ref_id = rfp.doc_status_ref_id
        AND rfp.brief = 'CURRENT'
        AND agh.last_ver_id = ag.ag_contract_id
        AND ag.contract_recrut_id = agr.ag_contract_id(+)
        AND agr.contract_id = aghr.ag_contract_header_id(+)
        AND aghr.agent_id = cr.contact_id(+)
     ) ag_cur
     /*(select ds.change_date, ds.user_name, ds.document_id, ds.start_date
       from doc_status ds) doc_st*/

where pp.policy_id = ph.last_ver_id
      AND ph.policy_id = d_act.document_id
      AND ph.last_ver_id = d_last.document_id
      and polr.brief = 'Страхователь'
      and pcnt.policy_id = pp.policy_id
      and pcnt.contact_policy_role_id = polr.id
      and cpol.contact_id = pcnt.contact_id
      and ph.fund_id = f.fund_id
      and ph.sales_channel_id = ch.id
      and ph.agency_id = dep.department_id(+)
      and prod.product_id = ph.product_id
      and doc_st.document_id = pp.policy_id
      AND dpol.document_id = pp.policy_id
      AND dpol.doc_status_id = doc_st.doc_status_id
      AND ag_cur.policy_header_id(+) = ph.policy_header_id
      /*and doc_st.start_date = (select max(dsa.start_date)
                                from doc_status dsa
                                where dsa.document_id = pp.policy_id)*/
      and ch.description in ('Брокерский','Брокерский без скидки','RLA')
      /*and ph.ids in (1920146644)*/
      and ph.start_date between to_date((SELECT r.param_value
                                         FROM ins_dwh.rep_param r
                                         WHERE r.rep_name = 'broker_sales'
                                           AND r.param_name = 'date_start'),
                                        'dd.mm.yyyy') and
                                to_date((SELECT r.param_value
                                         FROM ins_dwh.rep_param r
                                         WHERE r.rep_name = 'broker_sales'
                                           AND r.param_name = 'date_end'),
                                        'dd.mm.yyyy');
