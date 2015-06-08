CREATE OR REPLACE FORCE VIEW V_NON_DELIVERY_PAYMENT AS
select pp.START_DATE as "���� ������ ������"
       , pp.pol_ser as "����� �����"
       , pp.pol_num As "����� �"
       , pp.notice_ser "��������� �����"
       , pp.notice_num "���������"
       , pkg_policy.get_last_version_status(pp.pol_header_id) "������ ������"
       --, doc.get_doc_status_name(pp.policy_id) "������ ������"
       , cc.obj_name_orig "������������"
       , prod.description as "�������"
       , db.num as "� �����"
       ,  d.num as "� ���������"
       , case when dt.brief like 'PD4COPY' then '��4' when dt.brief like 'A7COPY' then '�7' else '' end as "���"
       , dc.due_date "���� �������"
       , dc.payment_number "����� �������"
       , dc.real_pay_date "���� ���������"
       , ddB.Set_Off_Child_Amount "����� ���������"
      /* , Pkg_Payment.get_set_off_amount(dA.document_id, pp.pol_header_id,NULL) "������� �� ��������"
       , dd.parent_amount "����� �� ��������"*/
     , sh.part_amount "����� �� ��������"
     , sh.part_pay_amount "������� �� ��������"
     --, ddb.child_doc_id
     --, pkg_a7.get_a7_dso(ddb.child_doc_id)
     , case when nvl(pkg_a7.get_a7_dso(ddb.child_doc_id),0) > 0 then (select sum(dos.set_off_amount) from doc_set_off dos where dos.child_doc_id = pkg_a7.get_a7_dso(ddb.child_doc_id) and dos.parent_doc_id =
                 (SELECT d.document_id
                  FROM doc_doc dd, document d, doc_templ dt
                  WHERE dd.parent_id = ddb.child_doc_id
                        AND dd.child_id = d.document_id
                        AND d.doc_templ_id = dt.doc_templ_id
                        AND dt.brief in ('A7COPY', 'PD4COPY') ) ) else 0 end
     /*, (SELECT sum(t.acc_amount)
  FROM trans t,
       p_policy p
 WHERE t.trans_templ_id = 661
   AND (p.policy_id = pp.policy_id OR pp.policy_id IS NULL)
   AND ((t.a1_dt_ure_id = 283 AND t.a1_dt_uro_id = pp.policy_id)
    OR (t.a2_dt_ure_id = 283 AND t.a2_dt_uro_id = pp.policy_id)
    OR (t.a3_dt_ure_id = 283 AND t.a3_dt_uro_id = pp.policy_id)
    OR (t.a4_dt_ure_id = 283 AND t.a4_dt_uro_id = pp.policy_id)
    OR (t.a5_dt_ure_id = 283 AND t.a5_dt_uro_id = pp.policy_id)
    OR (t.a1_ct_ure_id = 283 AND t.a1_ct_uro_id = pp.policy_id)
    OR (t.a2_ct_ure_id = 283 AND t.a2_ct_uro_id = pp.policy_id)
    OR (t.a3_ct_ure_id = 283 AND t.a3_ct_uro_id = pp.policy_id)
    OR (t.a4_ct_ure_id = 283 AND t.a4_ct_uro_id = pp.policy_id)
    OR (t.a5_ct_ure_id = 283 AND t.a5_ct_uro_id = pp.policy_id)))*/ "����� �� ����������� ���������"
       ,j.agent_name "�����"
       ,j.num "� ��"
       ,j.date_begin "���� ������ ��"
       ,j.status_name "������"
       ,j.category_name "���������"
       ,j.dep_name "������"
from ins.ac_payment dc
    ,ins.document d
    , ins.doc_templ dt
    , ins.doc_doc dd
    , ins.document dA
    , ins.doc_set_off ddB
    , ins.document dB
    , ins.doc_doc ddP
    , ins.p_policy pp
    , ins.p_policy_contact cont
    , ins.contact cc
    , ins.p_pol_header hp
    , ins.t_product prod
    ,P_POLICY_AGENT a
    ,V_AG_CONTRACT_JOURNAL j
    , v_policy_payment_schedule sh

   /* (SELECT sum(t.acc_amount),
            pp.policy_id
     FROM trans t,
          p_policy pp,
          as_asset aa,
          p_cover pc
 WHERE t.trans_templ_id = 661
   --AND (pp.policy_id = 711783 OR 711783 IS NULL)
   and aa.p_policy_id = pp.policy_id
   and pc.as_asset_id = aa.as_asset_id
   and ((t.a1_dt_ure_id = 305 AND t.a1_dt_uro_id = pc.p_cover_id)
   or (t.a2_dt_ure_id = 305 AND t.a2_dt_uro_id = pc.p_cover_id)
   or (t.a3_dt_ure_id = 305 AND t.a3_dt_uro_id = pc.p_cover_id)
   or (t.a4_dt_ure_id = 305 AND t.a4_dt_uro_id = pc.p_cover_id)
   or (t.a5_dt_ure_id = 305 AND t.a5_dt_uro_id = pc.p_cover_id)
   or (t.a1_ct_ure_id = 305 AND t.a1_ct_uro_id = pc.p_cover_id)
   or (t.a2_ct_ure_id = 305 AND t.a2_ct_uro_id = pc.p_cover_id)
   or (t.a3_ct_ure_id = 305 AND t.a3_ct_uro_id = pc.p_cover_id)
   or (t.a4_ct_ure_id = 305 AND t.a4_ct_uro_id = pc.p_cover_id)
   or (t.a5_ct_ure_id = 305 AND t.a5_ct_uro_id = pc.p_cover_id))
   group by pp.policy_id) bb on (bb.policy_id = pp.policy_id)*/


where d.document_id = dc.payment_id
      and dt.doc_templ_id = d.doc_templ_id
      and dt.brief in ('PD4COPY', 'A7COPY')
      and ins.doc.get_last_doc_status_brief(dc.payment_id) = 'TO_PAY'
      and dd.child_id = dc.payment_id
      and dA.Document_Id = dd.parent_id
      and ddB.Child_Doc_Id = dA.Document_Id
      and dB.Document_Id = ddB.Parent_Doc_Id
      and ddP.Child_Id = dB.Document_Id
      and pp.policy_id = ddP.Parent_Id
      and pp.pol_header_id = hp.policy_header_id
      and sh.policy_id = pp.policy_id
      and sh.document_id = dB.Document_Id
      and hp.product_id = prod.product_id
      and pp.POL_HEADER_ID = a.POLICY_HEADER_ID
      and a.AG_CONTRACT_HEADER_ID= j.AG_CONTRACT_HEADER_ID
      and a.status_id not in (2,4)
      and (pp.policy_id = cont.policy_id and cont.contact_policy_role_id = 6)
      and cont.contact_id = cc.contact_id
--and sh.part_amount <> sh.part_pay_amount
--and pp.policy_id = 15956513
;

