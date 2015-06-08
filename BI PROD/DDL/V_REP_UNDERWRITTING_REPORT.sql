CREATE OR REPLACE VIEW INS_DWH.V_REP_UNDERWRITTING_REPORT AS
select "���������",
       "��� ���",
       "����� �� ��",
       /*"����� �� �� ����",
       "����� ������ ���� ������",
       "��������� ����",*/
       "����� ��",
       "����� ��",
       "�������",
       "���� ������ ��",
       "������������",
       "���� ������� ��",
       "���� ������� ���",
       "���� ������� �����",
       "������ ������",
       "������ ��������� ������",
       "��� ��������",
       nvl("�������������",'��� ��������������') "�������������",
       "���� ���������� �������",
       "������������",
       "�������� ����.",
       "����������",
       "���",
       policy_header_id,
       "������ 1 ���",
       "��� �������",
       user_name,
       "���� �� ����. �� ���. �������",
       "��� ���� ������� �� ��� �",
       trunc("��� ���� ������� �� ��� �",'dd') - "���� ������� ��" "���� �� ������� �� �� ��� �",
       case when "��� ���� ������� �� ��� �" is null then 'not issued'
            when "��� ���� ������� �� ��� �" - "���� ������� ��" < 8 then '�� 7'
            when "��� ���� ������� �� ��� �" - "���� ������� ��" < 15 then '�� 14'
            when "��� ���� ������� �� ��� �" - "���� ������� ��" < 22 then '�� 21'
            when "��� ���� ������� �� ��� �" - "���� ������� ��" < 29 then '�� 28'
            else '������' end "������",
       "��������� ��","����������� �����",
       "������� ����� ������������",
       "������� ����� ������ �� ��",
       "������� ����� ������ ������",
       "����������� ������" 
from (
SELECT ins.ent.obj_name('DEPARTMENT',a.agency_id) "���������",
       nvl(ins.ent.obj_name('CONTACT',(SELECT ach_lead.agent_id
                                     FROM ins.ag_contract_header ach_lead
                                    WHERE ach_lead.ag_contract_header_id = a.ac_lead_contract_id)), '��� ������������') "��� ���",
       ins.ent.obj_name('CONTACT', a.agent_id) "����� �� ��",
       (select ll.description
        from ins.contact c,
             ins.t_risk_level ll
        where c.contact_id = a.agent_id
              and c.risk_level = ll.t_risk_level_id) "������� ����� ������ �� ��",
       pp.pol_ser "����� ��",
       pp.pol_num "����� ��",
       tp.DESCRIPTION "�������",
       ph.start_date "���� ������ ��",
       ins.ent.obj_name('CONTACT',ins.pkg_policy.get_policy_contact(pp.policy_id,'������������')) "������������",
       (select ll.description
        from ins.contact c,
             ins.t_risk_level ll
        where c.contact_id = ins.pkg_policy.get_policy_contact(pp.policy_id,'������������')
              and c.risk_level = ll.t_risk_level_id) "������� ����� ������������",
       trunc(pp.sign_date, 'dd')    "���� ������� ��",
       to_char(pp.sign_date,'YYYY') "���� ������� ���",
       to_char(pp.sign_date,'mm')   "���� ������� �����",

       dsr.NAME "������ ������",
       ins.pkg_policy.get_last_version_status(ph.policy_header_id) "������ ��������� ������",
       --(select rf.name from ins.doc_status_ref rf where rf.doc_status_ref_id = doc.doc_status_ref_id) "������ ��������� ������",
       (select da.Note
         from ins.doc_templ_status   dts_src,
              ins.doc_templ_status   dts_dst,
              ins.doc_status_allowed da
        where ds.doc_status_ref_id = dts_dst.doc_status_ref_id
          AND dts_dst.doc_templ_id = pp.doc_templ_id
          AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
          AND dts_src.doc_templ_id = pp.doc_templ_id
          AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
          AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id
       ) "��� ��������",
       (select da.respons_pers
         from ins.doc_templ_status   dts_src,
              ins.doc_templ_status   dts_dst,
              ins.doc_status_allowed da
        where ds.doc_status_ref_id = dts_dst.doc_status_ref_id
          AND dts_dst.doc_templ_id = pp.doc_templ_id
          AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
          AND dts_src.doc_templ_id = pp.doc_templ_id
          AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
          AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id
       ) "�������������",
       ds.change_date "���� ���������� �������",
       round(ds.change_date - pp.sign_date) "������������",
       (select da.plan_duration
         from ins.doc_templ_status   dts_src,
              ins.doc_templ_status   dts_dst,
              ins.doc_status_allowed da
        where ds.doc_status_ref_id = dts_dst.doc_status_ref_id
          AND dts_dst.doc_templ_id = pp.doc_templ_id
          AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
          AND dts_src.doc_templ_id = pp.doc_templ_id
          AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
          AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id
       ) "�������� ����.",
       (select da.plan_duration-round(lead(ds.change_date,1,SYSDATE) OVER (ORDER BY ds.change_date)-ds.change_date,2)
         from ins.doc_templ_status   dts_src,
              ins.doc_templ_status   dts_dst,
              ins.doc_status_allowed da
        where ds.doc_status_ref_id = dts_dst.doc_status_ref_id
          AND dts_dst.doc_templ_id = pp.doc_templ_id
          AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
          AND dts_src.doc_templ_id = pp.doc_templ_id
          AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
          AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id
       ) "����������",
       ph.ids "���",
       ph.policy_header_id,
       (select min(ins.doc.get_doc_status_name(ap.payment_id))
          from ins.p_policy   p2,
               ins.ven_ac_payment ap,
               ins.document   d,
               ins.doc_templ  dt,
               ins.doc_doc    dd
         where dd.parent_id = p2.policy_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = dd.child_id
           and ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           and ap.plan_date = (select min(ap3.plan_date)
                                 from ins.p_policy p3,
                                      ins.doc_doc  dd3,
                                      ins.ven_ac_payment ap3,
                                      ins.document   d3,
                                      ins.doc_templ  dt3
                                where p3.pol_header_id = p2.pol_header_id
                                  and dd3.parent_id = p3.policy_id
                                  and d3.document_id = dd3.child_id
                                  and dt3.doc_templ_id = d3.doc_templ_id
                                  and dt3.brief = 'PAYMENT'
                                  and ap3.payment_id = dd3.child_id
                                  and ins.doc.get_doc_status_brief(ap3.payment_id) <> 'ANNULATED'
                               )
           and p2.pol_header_id = ph.policy_header_id
       ) "������ 1 ���",
       /*(case when ins.pkg_policy.get_last_version_status(ph.policy_header_id) in ('���������','�����') then
        (select decode(cm.description,'������ �������� � �����',cm.description,'������������ ������� ������������',cm.description,null)
          from ins.t_collection_method cm
         where cm.id = pp.collection_method_id
        )end
       )*/
       -- �������� �� ������ �70663
       (select cm.description
          from ins.t_collection_method cm
         where cm.id = pp.collection_method_id
       ) "��� �������",
       ds.user_name,
       (select trunc(ds.change_date - ds2.change_date)
          from (select ds.change_date,
                       ds.doc_status_id,
                       ds.document_id,
                       row_number() over (partition by ds.document_id order by ds.change_date desc) c
                  from ins.doc_status ds
               )a,
               ins.doc_status ds2
         where a.document_id = ds2.document_id
           and ds2.doc_status_id = a.doc_status_id
           and ds2.document_id = pp.policy_id
           and a.c = 2
       ) "���� �� ����. �� ���. �������",
       (select min(ds2.change_date)
          from ins.p_policy       p2,
               ins.doc_status     ds2,
               ins.doc_status_ref dsr2
         where p2.pol_header_id = ph.policy_header_id
           and ds2.document_id = p2.policy_id
           and dsr2.doc_status_ref_id = ds2.doc_status_ref_id
           and dsr2.brief in ('CONCLUDED','CURRENT')
       ) "��� ���� ������� �� ��� �",
       nvl(pp.is_group_flag,0) "��������� ��",
       ag_cur.agent_current "����������� �����",
       (select ll.description
        from ins.contact c,
             ins.t_risk_level ll
        where c.contact_id = ag_cur.agent_id
              and c.risk_level = ll.t_risk_level_id) "������� ����� ������ ������"
       --������ /192022 ��������� �� BI � ����� ����������� �����������        
       ,(
          select case jtw.work_type 
                   when 0 then '����������� ������'
                   when 1 then '������������ � ��'
                   when 2 then '������������ � ��'
                 end "����������� ������"         
          from ins.journal_tech_work jtw
          where jtw.policy_header_id = ph.policy_header_id
            and jtw.start_date       = (
                                         select min(jtw_.start_date)
                                         from ins.journal_tech_work jtw_
                                         where jtw_.policy_header_id = jtw.policy_header_id                                           
                                       ) 
       ) "����������� ������"
       -- ������ /192022//      
      
  FROM ins.p_pol_header       ph,
       ins.ven_p_policy       pp,
       ins.document           doc,
       ins.t_product          tp,
       ins.doc_status         ds,
       ins.doc_status_ref     dsr,
       (SELECT ph.policy_header_id,
               ach.agent_id,
               ach.agency_id,
               ac_lead.contract_id  ac_lead_contract_id,
               dep.name dep_name,
               ach.is_new,
               ach.ag_contract_header_id
          FROM ins.p_pol_header       ph,
               ins.ag_contract_header ach,
               ins.ag_contract        ac,
               ins.ag_contract        ac_lead,
               ins.department         dep
         where ach.ag_contract_header_id = ins.pkg_renlife_utils.get_p_agent_sale_new(ph.policy_header_id)
           AND ach.agency_id = dep.department_id
           AND ach.last_ver_id = ac.ag_contract_id
           AND ac.contract_leader_id = ac_lead.ag_contract_id (+)
       ) a,

       (SELECT ph.policy_header_id,
               ach.agent_id,
               ach.agency_id,
               ach.t_sales_channel_id,
               cagc.obj_name_orig agent_current
          from ins.p_pol_header   ph,
               ins.ven_ag_contract_header ach,
               ins.contact cagc
         where ach.ag_contract_header_id = ins.pkg_renlife_utils.get_p_agent_current_new(ph.policy_header_id)
           and cagc.contact_id = ach.agent_id
       ) ag_cur
 WHERE ph.policy_id = pp.policy_id
   AND pp.policy_id = doc.document_id
   AND tp.product_id = ph.product_id
   --and a.policy_header_id (+) = ph.policy_header_id
   and a.policy_header_id = ph.policy_header_id
   AND ins.doc.get_doc_status_rec_id(pp.policy_id,'01.01.3000') = ds.doc_status_id
   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
   and ph.policy_header_id = ag_cur.policy_header_id (+)
   AND tp.brief NOT IN ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
   AND pp.sign_date BETWEEN --to_date('01.01.2010','dd.mm.yyyy') and to_date('28.02.2011','dd.mm.yyyy')
                            (SELECT r.param_value
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'under_rep'
                                AND r.param_name = 'DATE_FROM')
                            AND (SELECT r.param_value
                                   FROM ins_dwh.rep_param r
                                  WHERE r.rep_name = 'under_rep'
                                    AND r.param_name = 'DATE_TO')
   AND (a.dep_name IN (SELECT r.param_value
                      FROM ins_dwh.rep_param r
                     WHERE r.rep_name = 'under_rep'
                       AND r.param_name = 'AGENCY')
        or a.dep_name is null
        )
  --and ph.policy_header_id = 28939669
)
ORDER BY 1,2,5,8;
