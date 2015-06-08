CREATE OR REPLACE VIEW V_UNSTOPPED_POLICY AS
SELECT
p.pol_header_id,
p.pol_ser AS "����� ��",
p.pol_num AS "����� ��",
pr.description    AS "�������",
p.policy_id       AS "policy_id �������� ������",
con.obj_name_orig AS "������������",
ph.start_date     as "���� ������ ��",
p.end_date        AS "���� ��������� ��",
pt.description    as "������������� �����",
p.version_num     as "����� ������",
doc.get_doc_status_name(p.policy_id) AS "������ �������� ������",

(SELECT p2.version_num
   FROM p_policy p2
  WHERE p2.policy_id = ph.last_ver_id
) AS "����� ��������� ������",

(SELECT doc.get_doc_status_name(a.policy_id)
   FROM (SELECT p2.policy_id,
                p2.version_num,
                p2.pol_header_id,
                row_number() over (PARTITION BY p2.pol_header_id ORDER BY p2.version_num DESC) rn
           FROM p_policy p2
        )a
  WHERE a.rn = 1
    AND a.pol_header_id = p.pol_header_id
) AS "������ ��������� ������",

(SELECT MAX(ds.change_date)
  FROM (SELECT p2.policy_id,
               p2.version_num,
               p2.pol_header_id,
               row_number() over (PARTITION BY p2.pol_header_id ORDER BY p2.version_num DESC) rn
          FROM p_policy p2
       )a,
       doc_status ds
 WHERE a.rn = 1
   AND a.pol_header_id = p.pol_header_id
   AND a.policy_id = ds.document_id
) AS "���� ������� ��������� ������",
nach.ta_nach_msfo   as "���� ��������� �� ��",
nach.ta_nach_rsbu   as "���� ��������� �� ��",
all_pay.ta_opl as "�������� �� ��",
case when nach.ta_nach_msfo - all_pay.ta_opl > 0 then nach.ta_nach_msfo - all_pay.ta_opl end "���� ��� �������������",
case when nach.ta_nach_msfo - all_pay.ta_opl < 0 then all_pay.ta_opl - nach.ta_nach_msfo end "���� ���� �������������",
case when nach.ta_nach_rsbu - all_pay.ta_opl > 0 then nach.ta_nach_rsbu - all_pay.ta_opl end "���� ��� �������������",
case when nach.ta_nach_rsbu - all_pay.ta_opl < 0 then all_pay.ta_opl - nach.ta_nach_rsbu end "���� ���� �������������"

 FROM p_pol_header  ph,
      p_policy      p,
      t_product     pr,
      contact       con,
      t_payment_terms pt,
      (select sum(ta_nach_msfo) ta_nach_msfo,
              sum(ta_nach_rsbu) ta_nach_rsbu,
              ph
         from (select case when t.trans_templ_id = 622 then sum(t.trans_amount) end ta_nach_msfo,
                      case when t.trans_templ_id = 21 then sum(t.trans_amount) end ta_nach_rsbu,
                      pp.pol_header_id ph
                 FROM trans    t,
                      p_policy pp
                WHERE t.trans_templ_id in (622,21) --622 !���� ������ ��������� --21!��������� ������
                  AND pp.policy_id = t.a2_ct_uro_id
               group by pp.pol_header_id, trans_templ_id
              ) n
       group by ph
       ) nach,
      (select sum(t.trans_amount) ta_opl,
              PP.POL_HEADER_ID ph
         FROM TRANS        T,
              OPER         O,
              P_COVER      PC,
              AS_ASSET     ASS,
              P_POLICY     PP,
              DOC_SET_OFF  DSO,
              DOCUMENT     D
        WHERE T.TRANS_TEMPL_ID IN (741, 661, 501, 44,562)
          AND T.OBJ_URO_ID = PC.P_COVER_ID
          AND PC.AS_ASSET_ID = ASS.AS_ASSET_ID
          AND ASS.P_POLICY_ID = PP.POLICY_ID
          AND T.OPER_ID = O.OPER_ID
          AND O.DOCUMENT_ID = DSO.DOC_SET_OFF_ID
          AND DSO.CHILD_DOC_ID = D.DOCUMENT_ID
          AND D.DOC_TEMPL_ID IN (86,5233,6453)
       group by PP.POL_HEADER_ID
       ) all_pay
WHERE ph.product_id  = pr.product_id
  AND p.policy_id    = ph.policy_id --�������� ������
  AND con.contact_id = pkg_policy.get_policy_contact(p.policy_id, '������������')
  AND doc.get_doc_status_brief(p.policy_id) IN ('ACTIVE','CURRENT','PRINTED','NEW')
  and pt.id = p.payment_term_id
  AND p.end_date < SYSDATE - 60
  and nach.ph    = ph.policy_header_id
  and all_pay.ph = ph.policy_header_id
  --and nach.ta_nach_msfo = nach.ta_nach_rsbu
  --and nach.ta_nach_msfo = all_pay.ta_opl
  --and p.pol_header_id = 801024
order by  p.end_date;
