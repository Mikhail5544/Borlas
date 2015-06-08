CREATE OR REPLACE VIEW INS_DWH.V_REP_UNDERWRITTING_REPORT AS
WITH wpol_head AS
 (SELECT ph.*
        ,dep.name dep_name
        ,tp.description prod_name
        ,vi.contact_name insurer_name
        ,ll.description ins_risk_lev
        ,(SELECT MAX(pad.ag_contract_header_id) keep(dense_rank FIRST ORDER BY pad.date_begin DESC, pad.p_policy_agent_doc_id DESC)

            FROM ins.p_policy_agent_doc pad
           WHERE pad.policy_header_id = ph.policy_header_id
             AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) NOT IN ('ERROR')) ag_cur_head_id
        ,(SELECT MAX(pad.ag_contract_header_id) keep(dense_rank FIRST ORDER BY pad.date_begin ASC, pad.p_policy_agent_doc_id ASC)

            FROM ins.p_policy_agent_doc pad
           WHERE pad.policy_header_id = ph.policy_header_id
             AND ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) NOT IN ('ERROR')) ag_head_id

    FROM ins.p_pol_header ph
        ,ins.p_policy     pp
        ,ins.department   dep
        ,t_product        tp
        ,ins.v_pol_issuer vi
        ,ins.contact      cins
        ,ins.t_risk_level ll
   WHERE ph.policy_id = pp.policy_id
     AND dep.department_id(+) = ph.agency_id
     AND tp.product_id = ph.product_id
     AND pp.policy_id = vi.policy_id
     AND vi.contact_id = cins.contact_id
     AND cins.risk_level = ll.t_risk_level_id(+)
     AND pp.sign_date BETWEEN --to_date('01.01.2010','dd.mm.yyyy') and to_date('31.12.2013','dd.mm.yyyy')
         TO_DATE((SELECT r.param_value
                   FROM ins_dwh.rep_param r
                  WHERE r.rep_name = 'under_rep'
                    AND r.param_name = 'DATE_FROM')
                ,'dd.mm.yyyy')
     AND TO_DATE((SELECT r.param_value
                   FROM ins_dwh.rep_param r
                  WHERE r.rep_name = 'under_rep'
                    AND r.param_name = 'DATE_TO')
                ,'dd.mm.yyyy')

     AND tp.brief NOT IN ('CR92_1', 'CR92_1.1', 'CR92_2', 'CR92_2.1', 'CR92_3', 'CR92_3.1')

  ),
wag_head AS
 (SELECT ph.policy_header_id
        ,ach.agent_id
        ,ach.agency_id
        ,ac_lead.contract_id       ac_lead_contract_id
        ,dep.name                  dep_name
        ,ach.is_new
        ,ach.ag_contract_header_id
        ,cagc.obj_name_orig        agent_current
        ,clead.obj_name_orig       lead_name
        ,ll.description            risk_level_name
    FROM ins.wpol_head          ph
        ,ins.ag_contract_header ach
        ,ins.ag_contract        ac
        ,ins.ag_contract        ac_lead
        ,ins.ag_contract_header ach_lead
        ,ins.department         dep
        ,ins.contact            cagc
        ,ins.contact            clead
        ,ins.t_risk_level       ll
   WHERE ach.ag_contract_header_id = ph.ag_head_id
     AND ach.agency_id = dep.department_id
     AND ach.last_ver_id = ac.ag_contract_id
     AND ac.contract_leader_id = ac_lead.ag_contract_id(+)
     AND ac_lead.contract_id = ach_lead.ag_contract_header_id(+)
     AND ach_lead.agent_id = clead.contact_id(+)
     AND cagc.contact_id = ach.agent_id
     AND cagc.risk_level = ll.t_risk_level_id(+)),
wag_cur_head AS
 (SELECT ph.policy_header_id
        ,ach.agent_id
        ,ach.agency_id
        ,ach.ag_contract_header_id
        ,cagc.obj_name_orig        agent_name
        ,ll.description            risk_level_name

    FROM ins.wpol_head          ph
        ,ins.ag_contract_header ach
        ,ins.contact            cagc
        ,ins.t_risk_level       ll
   WHERE ach.ag_contract_header_id = ph.ag_cur_head_id
     AND cagc.contact_id = ach.agent_id
     AND cagc.risk_level = ll.t_risk_level_id(+)),
qmain AS
 (

  SELECT --ins.ent.obj_name('DEPARTMENT',NVL(a.agency_id,ph.agency_id)),
   nvl(a.dep_name, dep_ph.name) "���������"
    ,nvl(a.lead_name, '��� ������������') "��� ���"
    ,ins.ent.obj_name('CONTACT', a.agent_id) "����� �� ��"
    ,a.risk_level_name "������� ����� ������ �� ��"
    ,pp.pol_ser "����� ��"
    ,pp.pol_num "����� ��"
    ,ph.prod_name "�������"
    ,ph.start_date "���� ������ ��"
    ,ph.insurer_name "������������"
    ,ph.ins_risk_lev "������� ����� ������������"
    ,trunc(pp.sign_date, 'dd') "���� ������� ��"
    ,to_char(pp.sign_date, 'YYYY') "���� ������� ���"
    ,to_char(pp.sign_date, 'mm') "���� ������� �����"
    ,dsr.name "������ ������"
    ,ins.pkg_policy.get_last_version_status(ph.policy_header_id) "������ ��������� ������"
    ,(SELECT da.note
       FROM ins.doc_templ_status   dts_src
           ,ins.doc_templ_status   dts_dst
           ,ins.doc_status_allowed da
      WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
        AND dts_dst.doc_templ_id = pp.doc_templ_id
        AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
        AND dts_src.doc_templ_id = pp.doc_templ_id
        AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
        AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "��� ��������"
    ,(SELECT da.respons_pers
       FROM ins.doc_templ_status   dts_src
           ,ins.doc_templ_status   dts_dst
           ,ins.doc_status_allowed da
      WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
        AND dts_dst.doc_templ_id = pp.doc_templ_id
        AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
        AND dts_src.doc_templ_id = pp.doc_templ_id
        AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
        AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "�������������"
    ,ds.change_date "���� ���������� �������"
    ,ROUND(ds.change_date - pp.sign_date) "������������"
    ,(SELECT da.plan_duration
       FROM ins.doc_templ_status   dts_src
           ,ins.doc_templ_status   dts_dst
           ,ins.doc_status_allowed da
      WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
        AND dts_dst.doc_templ_id = pp.doc_templ_id
        AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
        AND dts_src.doc_templ_id = pp.doc_templ_id
        AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
        AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "�������� ����."
    ,(SELECT da.plan_duration -
            ROUND(lead(ds.change_date, 1, SYSDATE) over(ORDER BY ds.change_date) - ds.change_date, 2)
       FROM ins.doc_templ_status   dts_src
           ,ins.doc_templ_status   dts_dst
           ,ins.doc_status_allowed da
      WHERE ds.doc_status_ref_id = dts_dst.doc_status_ref_id
        AND dts_dst.doc_templ_id = pp.doc_templ_id
        AND ds.src_doc_status_ref_id = dts_src.doc_status_ref_id
        AND dts_src.doc_templ_id = pp.doc_templ_id
        AND da.src_doc_templ_status_id = dts_src.doc_templ_status_id
        AND da.dest_doc_templ_status_id = dts_dst.doc_templ_status_id) "����������"
    ,ph.ids "���"
    ,ph.policy_header_id
    ,
    --

    (SELECT MIN(ins.doc.get_doc_status_name(ap.payment_id))
       FROM ins.p_policy       p2
           ,ins.ven_ac_payment ap
           ,ins.document       d
           ,ins.doc_templ      dt
           ,ins.doc_doc        dd
      WHERE dd.parent_id = p2.policy_id
        AND d.document_id = dd.child_id
        AND dt.doc_templ_id = d.doc_templ_id
        AND dt.brief = 'PAYMENT'
        AND ap.payment_id = dd.child_id
        AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
        AND ap.plan_date =
            (SELECT MIN(ap3.plan_date)
               FROM ins.p_policy       p3
                   ,ins.doc_doc        dd3
                   ,ins.ven_ac_payment ap3
                   ,ins.document       d3
                   ,ins.doc_templ      dt3
              WHERE p3.pol_header_id = p2.pol_header_id
                AND dd3.parent_id = p3.policy_id
                AND d3.document_id = dd3.child_id
                AND dt3.doc_templ_id = d3.doc_templ_id
                AND dt3.brief = 'PAYMENT'
                AND ap3.payment_id = dd3.child_id
                AND ins.doc.get_doc_status_brief(ap3.payment_id) <> 'ANNULATED')
        AND p2.pol_header_id = ph.policy_header_id) "������ 1 ���"
    ,

    -- �������� �� ������ �70663
    (SELECT cm.description FROM ins.t_collection_method cm WHERE cm.id = pp.collection_method_id) "��� �������"
    ,ds.user_name
    ,(SELECT trunc(ds.change_date - ds2.change_date)
       FROM (SELECT ds.change_date
                   ,ds.doc_status_id
                   ,ds.document_id
                   ,row_number() over(PARTITION BY ds.document_id ORDER BY ds.change_date DESC) c
               FROM ins.doc_status ds) a
           ,ins.doc_status ds2
      WHERE a.document_id = ds2.document_id
        AND ds2.doc_status_id = a.doc_status_id
        AND ds2.document_id = pp.policy_id
        AND a.c = 2) "���� �� ����. �� ���. �������"
    ,(SELECT MIN(ds2.change_date)
       FROM ins.p_policy       p2
           ,ins.doc_status     ds2
           ,ins.doc_status_ref dsr2
      WHERE p2.pol_header_id = ph.policy_header_id
        AND ds2.document_id = p2.policy_id
        AND dsr2.doc_status_ref_id = ds2.doc_status_ref_id
        AND dsr2.brief IN ('CONCLUDED', 'CURRENT')) "��� ���� ������� �� ��� �"
    ,nvl(pp.is_group_flag, 0) "��������� ��"
    ,a_cur.agent_name "����������� �����"
    ,a_cur.risk_level_name "������� ����� ������ ������"
    --������ /192022 ��������� �� BI � ����� ����������� �����������
    ,(SELECT CASE jtw.work_type
              WHEN 0 THEN
               '����������� ������'
              WHEN 1 THEN
               '������������ � ��'
              WHEN 2 THEN
               '������������ � ��'
            END "����������� ������"
       FROM ins.journal_tech_work jtw
      WHERE jtw.policy_header_id = ph.policy_header_id
        AND jtw.start_date = (SELECT MIN(jtw_.start_date)
                                FROM ins.journal_tech_work jtw_
                               WHERE jtw_.policy_header_id = jtw.policy_header_id)) "����������� ������"
  -- ������ /192022//

    FROM wpol_head          ph
         ,ins.ven_p_policy   pp
         ,ins.doc_status     ds
         ,ins.doc_status_ref dsr
         ,wag_head           a
         ,wag_cur_head       a_cur
         ,ins.department     dep_ph

   WHERE ph.policy_id = pp.policy_id
     AND ph.policy_header_id = a.policy_header_id(+)
     AND ph.policy_header_id = a_cur.policy_header_id(+)
     AND ph.agency_id = dep_ph.department_id
     AND ds.doc_status_id = pp.doc_status_id
     AND pp.doc_status_ref_id = dsr.doc_status_ref_id
     AND (nvl(ph.dep_name, a.dep_name) IN --('������ ��������', '������ �������� ������������� 3', '������ �������� ������������� 4', '������ �������� 2', '������ ��������-2', '������ ��������-5 SAS')
         (SELECT r.param_value
             FROM ins_dwh.rep_param r
            WHERE r.rep_name = 'under_rep'
              AND r.param_name = 'AGENCY')

         OR (to_char((SELECT to_char(r.param_value)
                        FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'under_rep'
                         AND r.param_name = 'AGENCY'
                         AND r.param_value = ' <���>')) = ' <���>'))

  )
SELECT

 "���������"
 ,"��� ���"
 ,"����� �� ��"
 ,"����� ��"
 ,"����� ��"
 ,"�������"
 ,"���� ������ ��"
 ,"������������"
 ,"���� ������� ��"
 ,"���� ������� ���"
 ,"���� ������� �����"
 ,"������ ������"
 ,"������ ��������� ������"
 ,"��� ��������"
 ,nvl("�������������", '��� ��������������') "�������������"
 ,"���� ���������� �������"
 ,"������������"
 ,"�������� ����."
 ,"����������"
 ,"���"
 ,policy_header_id
 ,"������ 1 ���"
 ,"��� �������"
 ,user_name
 ,"���� �� ����. �� ���. �������"
 ,"��� ���� ������� �� ��� �"
 ,trunc("��� ���� ������� �� ��� �", 'dd') - "���� ������� ��" "���� �� ������� �� �� ��� �"
 ,CASE
   WHEN "��� ���� ������� �� ��� �" IS NULL THEN
    'not issued'
   WHEN "��� ���� ������� �� ��� �" - "���� ������� ��" < 8 THEN
    '�� 7'
   WHEN "��� ���� ������� �� ��� �" - "���� ������� ��" < 15 THEN
    '�� 14'
   WHEN "��� ���� ������� �� ��� �" - "���� ������� ��" < 22 THEN
    '�� 21'
   WHEN "��� ���� ������� �� ��� �" - "���� ������� ��" < 29 THEN
    '�� 28'
   ELSE
    '������'
 END "������"
 ,"��������� ��"
 ,"����������� �����"
 ,"������� ����� ������������"
 ,"������� ����� ������ �� ��"
 ,"������� ����� ������ ������"
 ,"����������� ������"
  FROM qmain
 ORDER BY 1
         ,2
         ,5
         ,8
;
