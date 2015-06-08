CREATE OR REPLACE FORCE VIEW INS_DWH.V_REP_RAST_POLICY AS
SELECT
/*ROWNUM*/ null "��",
DECODE(a.min_back_stat, 'PAID', '�����', '�������') "��� ��������",
DECODE(ig.life_property, 1, '�', 0, '��') "��� �����������",
a."���",
a."� ������",
a."����� ���������",
a."� ���������",
a."�������� ���������",
plo.description "����� �� ��������",
pc.p_cover_id "ID ��������",
plo.id "ID ������������ �����",
a."������" "������ �� Borlas",
a."��� �������",
a."������������",
a."�� ������������" "�� �������� (������������)",
(select decode(tpc.description,'���������� ����',tpc.description,'����������� ����')
 from ins.ven_contact c,
      ins.t_contact_type tpc
 where c.contact_id = a."�� ������������"
   and c.contact_type_id = tpc.id) "��� ������������",
(select decode(nvl(c.resident_flag,0),0,'����������',1,'��������','') from ins.ven_contact c where c.contact_id = a."�� ������������") "�������/����������",
(select cca.COUNTRY_NAME from ins.v_cn_contact_address cca where cca.contact_id = a."�� ������������" and ins.pkg_contact.get_primary_address(a."�� ������������") = cca.id(+)) "������ ���������� ������������",
null "Contractor � �� Navision",
case when nvl(a.beneficiary_pay,'X') = 'X' and a.return_summ <= 0
          then a."������������"
     when nvl(a.beneficiary_pay,'X') = 'X' and a.return_summ > 0
          then ''
     when nvl(a.beneficiary_pay,'X') <> 'X'
          then a.beneficiary_pay
     else
          nvl(a.beneficiary_pay,a."������������")
end "���������� �����.����������",
case when nvl(a.beneficiary_id,0) = 0 and a.return_summ <= 0
          then a."�� ������������"
     when nvl(a.beneficiary_id,0) = 0 and a.return_summ > 0
          then 0
     when nvl(a.beneficiary_id,0) <> 0
          then a.beneficiary_id
     else
          nvl(a.beneficiary_id,a."�� ������������")
end "�� ��������(���.�����.����.)",

(select decode(tpc.description,'���������� ����',tpc.description,'����������� ����')
 from ins.ven_contact c,
      ins.t_contact_type tpc
 where c.contact_id = (case when nvl(a.beneficiary_id,0) = 0 and a.return_summ <= 0
                                 then a."�� ������������"
                            when nvl(a.beneficiary_id,0) = 0 and a.return_summ > 0
                                 then 0
                            when nvl(a.beneficiary_id,0) <> 0
                                 then a.beneficiary_id
                            else
                                 nvl(a.beneficiary_id,a."�� ������������")
                       end)
   and c.contact_type_id = tpc.id) "��� ���.�����.����.",
(select decode(nvl(c.resident_flag,0),0,'����������',1,'��������','')
 from ins.ven_contact c
 where c.contact_id = (case when nvl(a.beneficiary_id,0) = 0 and a.return_summ <= 0
                                 then a."�� ������������"
                            when nvl(a.beneficiary_id,0) = 0 and a.return_summ > 0
                                 then 0
                            when nvl(a.beneficiary_id,0) <> 0
                                 then a.beneficiary_id
                            else
                                 nvl(a.beneficiary_id,a."�� ������������")
                       end)
                       ) "��� ���.�����.����. ���/�����",
(select cca.COUNTRY_NAME
 from ins.v_cn_contact_address cca
 where cca.contact_id = a."�� ������������"
   and ins.pkg_contact.get_primary_address(case when nvl(a.beneficiary_id,0) = 0 and a.return_summ <= 0
                                                  then a."�� ������������"
                                             when nvl(a.beneficiary_id,0) = 0 and a.return_summ > 0
                                                  then 0
                                             when nvl(a.beneficiary_id,0) <> 0
                                                  then a.beneficiary_id
                                             else
                                                  nvl(a.beneficiary_id,a."�� ������������")
                                        end) = cca.id(+)) "������ ���� ���.����.����.",
a."�����",
a."������ ��������",
pc.ins_amount "��������� �����",
a."���� ������ ���������������",
a."���� ��������� ���������������",
pc.start_date    "���� ������ �� �����",
pc.end_date      "���� ��������� �� �����",
NULL "���� �� �������� ����",
pc.fee     "����� ������/������",
pc.premium "������� ������",
a."������������� ������ �������",
a.db,
ADD_MONTHS(a.db,12/a.number_of_payments) dg,
a.ppo,
a.po,
 (  SELECT max(ap.amount)
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = a.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID'
           and ap.plan_date = a.db
           ) epg_amount_db,

(select sum(t.acc_amount) from ins.oper o, ins.trans t, ins.account a
where 1=1
and o.oper_id = t.oper_id
and t.ct_account_id = a.account_id
and a.num = '92.01'
and t.trans_amount > 0
and t.a4_ct_uro_id = plo.id
and t.a3_ct_uro_id = aa.p_asset_header_id) charge_amount_rur,

(select sum(t.acc_amount) from ins.oper o, ins.trans t, ins.account a
where 1=1
and o.oper_id = t.oper_id
and t.ct_account_id = a.account_id
and a.num = '92.01'
and t.trans_amount < 0
and t.a4_ct_uro_id = plo.id
and t.a3_ct_uro_id = aa.p_asset_header_id) storno_charge_amount_rur,

(select sum(t.acc_amount)
  FROM INS.TRANS T,
       ins.oper o,
       ins.DOC_SET_OFF  DSO,
       ins.DOCUMENT     D,
       ins.doc_templ    dt,
       ins.trans_templ  tt,
       ins.p_cover pc1,
       ins.as_asset a1
 WHERE

       tt.trans_templ_id = T.TRANS_TEMPL_ID
   AND o.oper_id = t.oper_id
   AND o.document_id    = DSO.DOC_SET_OFF_ID
   and t.obj_ure_id = 305
   and t.obj_uro_id = pc1.p_cover_id
   and pc1.as_asset_id = a1.as_asset_id
   and pc1.t_prod_line_option_id = plo.id
   and a1.p_asset_header_id = aa.p_asset_header_id
   AND DSO.CHILD_DOC_ID = D.DOCUMENT_ID
   AND dt.doc_templ_id  = D.DOC_TEMPL_ID
   AND t.acc_amount >0
   AND ((tt.brief in ('�����������������������',
                      '�����������',
                      '������������������',
                      '�����������������������')
        and dt.brief in ('��','��_��','��_��')
        )
        or (tt.brief in ('�����������������������','�������') --������ � ������� ��
            and dt.brief in ('PAYORDER_SETOFF','������_��')
           )
       )
) payd_amount_rur,

(select sum(t.acc_amount)
  FROM INS.TRANS T,
       ins.oper o,
       ins.DOC_SET_OFF  DSO,
       ins.DOCUMENT     D,
       ins.doc_templ    dt,
       ins.trans_templ  tt,
       ins.p_cover pc1,
       ins.as_asset a1
 WHERE

       tt.trans_templ_id = T.TRANS_TEMPL_ID
   AND o.oper_id = t.oper_id
   AND o.document_id    = DSO.DOC_SET_OFF_ID
   and t.obj_ure_id = 305
   and t.obj_uro_id = pc1.p_cover_id
   and pc1.as_asset_id = a1.as_asset_id
   and pc1.t_prod_line_option_id = plo.id
   and a1.p_asset_header_id = aa.p_asset_header_id
   AND DSO.CHILD_DOC_ID = D.DOCUMENT_ID
   AND dt.doc_templ_id  = D.DOC_TEMPL_ID
   AND t.acc_amount <0
   AND ((tt.brief in ('�����������������������',
                      '�����������',
                      '������������������',
                      '�����������������������')
        and dt.brief in ('��','��_��','��_��')
        )
        or (tt.brief in ('�����������������������','�������') --������ � ������� ��
            and dt.brief in ('PAYORDER_SETOFF','������_��')
           )
       )
) storno_payd_amount_rur,

pc.fee/(SELECT MIN(ap.plan_date) - ADD_MONTHS(MIN(ap.plan_date),-12/a.number_of_payments)+1
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = a.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           AND dt.doc_templ_id = d.doc_templ_id
           AND dt.brief = 'PAYMENT'
           AND ap.payment_id = d.document_id
           AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           AND ap.plan_date > a."���� �����������"
       ) "�� �� ���� ����",
a."���-�� ���������� ��� ����",
a."������ ��",
decode(a."������� ������� � �����������",1,
(select sum(nvl(pcd.redemption_sum,0))
from ins.as_asset ast,
     ins.P_COVER_DECLINE pcd,
     ins.t_product_line tpl
where ast.p_policy_id = a.past_policy_id
      and pcd.as_asset_id = ast.as_asset_id
      and tpl.id = pl.id
      and pcd.t_product_line_id = tpl.id),
(SELECT nvl(pcsd.value,0)
   FROM ins.POLICY_CASH_SURR   pcs,
        ins.POLICY_CASH_SURR_D pcsd
  WHERE pcs.policy_id = a.policy_id
    AND pcs.t_lob_line_id = ll.t_lob_line_id
    AND pcsd.policy_cash_surr_id = pcs.policy_cash_surr_id
    AND pcsd.start_cash_surr_date < a."���� �����������"
    AND pcsd.end_cash_surr_date   > a."���� �����������"
    AND ROWNUM = 1
)
) "�������� �����",

case when a.is_group_flag = 1 then

   decode(a."������� ������� � �����������",1,
      (select sum(nvl(pcd.return_bonus_part,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),
      (CASE WHEN DECODE(ig.life_property,1,'�',0,'��') = '��'
           THEN pc.fee/(SELECT MIN(ap.plan_date) - ADD_MONTHS(MIN(ap.plan_date),-12/a.number_of_payments)+1
                          FROM ins.p_policy   p2,
                               ins.doc_doc    dd,
                               ins.document   d,
                               ins.doc_templ  dt,
                               ins.ac_payment ap
                         WHERE p2.pol_header_id = a.policy_header_id
                           AND dd.parent_id = p2.policy_id
                           AND d.document_id = dd.child_id
                           AND dt.doc_templ_id = d.doc_templ_id
                           AND dt.brief = 'PAYMENT'
                           AND ap.payment_id = d.document_id
                           AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
                           AND ap.plan_date > a."���� �����������"
                       ) * a."���-�� ���������� ��� ����"
           ELSE NULL
       END) )

else

   decode(a."������� ������� � �����������",1,
      (select sum(nvl(pcd.return_bonus_part,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),
      (CASE WHEN DECODE(ig.life_property,1,'�',0,'��') = '��'
           THEN pc.fee/(SELECT MIN(ap.plan_date) - ADD_MONTHS(MIN(ap.plan_date),-12/a.number_of_payments)+1
                          FROM ins.p_policy   p2,
                               ins.doc_doc    dd,
                               ins.document   d,
                               ins.doc_templ  dt,
                               ins.ac_payment ap
                         WHERE p2.pol_header_id = a.policy_header_id
                           AND dd.parent_id = p2.policy_id
                           AND d.document_id = dd.child_id
                           AND dt.doc_templ_id = d.doc_templ_id
                           AND dt.brief = 'PAYMENT'
                           AND ap.payment_id = d.document_id
                           AND ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
                           AND ap.plan_date > a."���� �����������"
                       ) * a."���-�� ���������� ��� ����"
           ELSE NULL
       END) )

end "������� ����� ������",

case when a.is_group_flag = 1 then

     case when (select sum(pcd.add_invest_income)
          from ins.as_asset ast,
               ins.P_COVER_DECLINE pcd
          where ast.p_policy_id = a.past_policy_id
                and pcd.as_asset_id = ast.as_asset_id
                --
                and ast.as_asset_id = aa.as_asset_id
                --
                and pcd.t_product_line_id = pl.id) >= 0
     then (select sum(nvl(pcd.add_invest_income,0))
          from ins.as_asset ast,
               ins.P_COVER_DECLINE pcd
          where ast.p_policy_id = a.past_policy_id
                and pcd.as_asset_id = ast.as_asset_id
                --
                and ast.as_asset_id = aa.as_asset_id
                --
                and pcd.t_product_line_id = pl.id)
     else (select sum(adi.add_income_cur)
           from ins.v_add_invest_income adi
           where adi.pol_header_id = a.policy_header_id
                 and adi.t_product_line_id = pl.id
                 and UPPER(adi.as_asset_name) = UPPER(cas.obj_name_orig)
                 and adi.income_date =
                    ( SELECT  MAX( aii2.income_date )
                        FROM  ins.ven_p_add_invest_income aii2
                        WHERE aii2.income_date <= a."���� �����������"
                          AND aii2.pol_header_id = policy_header_id
                          AND aii2.t_product_line_id = pl.id )
           )

     end

else

     case when (select sum(pcd.add_invest_income)
          from ins.as_asset ast,
               ins.P_COVER_DECLINE pcd
          where ast.p_policy_id = a.past_policy_id
                and pcd.as_asset_id = ast.as_asset_id
                and pcd.t_product_line_id = pl.id ) >= 0
     then (select sum(nvl(pcd.add_invest_income,0))
          from ins.as_asset ast,
               ins.P_COVER_DECLINE pcd
          where ast.p_policy_id = a.past_policy_id
                and pcd.as_asset_id = ast.as_asset_id
                and pcd.t_product_line_id = pl.id
                )
     else (select sum(adi.add_income_cur)
           from ins.v_add_invest_income adi
           where adi.pol_header_id = a.policy_header_id
                 and adi.t_product_line_id = pl.id
                 and adi.income_date =
                    ( SELECT  MAX( aii2.income_date )
                        FROM  ins.ven_p_add_invest_income aii2
                        WHERE aii2.income_date <= a."���� �����������"
                          AND aii2.pol_header_id = policy_header_id
                          AND aii2.t_product_line_id = pl.id )
          )

     end

end "���. ������ �����",
NULL "����� � �������� � ������",

case when a.is_group_flag = 1 then

decode(a."������� ������� � �����������",1,
      (select case when sum(nvl(pcd.underpayment_actual,0)) > 0 then -sum(nvl(pcd.underpayment_actual,0)) else 0 end
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),NULL)

else

decode(a."������� ������� � �����������",1,
      (select case when sum(nvl(pcd.underpayment_actual,0)) > 0 then -sum(nvl(pcd.underpayment_actual,0)) else 0 end
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),NULL)

end "��������� (���)",
case when a.is_group_flag = 1 then

decode(a."������� ������� � �����������",1,
      (select case when sum(nvl(pcd.admin_expenses,0)) > 0 then -sum(nvl(pcd.admin_expenses,0)) else 0 end
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),NULL)

else

decode(a."������� ������� � �����������",1,
      (select case when sum(nvl(pcd.admin_expenses,0)) > 0 then -sum(nvl(pcd.admin_expenses,0)) else 0 end
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),NULL)

end "��� ���",
case when plt.brief = 'RECOMMENDED' then
        decode(a."������� ������� � �����������",1,
        (select nvl(pod.overpayment,0)
         from ins.ven_p_pol_decline pod
         where pod.p_policy_id = a.policy_id),null)
     else 0 end "���������",
case when plt.brief = 'RECOMMENDED' then
        decode(a."������� ������� � �����������",1,
        (select nvl(pod.medo_cost ,0)
         from ins.ven_p_pol_decline pod
         where pod.p_policy_id = a.policy_id),null)
     else 0 end "��������� ��",

case when a.is_group_flag = 1 then

decode(a."������� ������� � �����������",1,
      (select sum(nvl(pcd.bonus_off_current,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),NULL)

else

decode(a."������� ������� � �����������",1,
      (select sum(nvl(pcd.bonus_off_current,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),NULL)

end "������ 92 �����",

case when a.is_group_flag = 1 then

decode(a."������� ������� � �����������",1,
      (select sum(nvl(pcd.bonus_off_prev,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            --
            and ast.as_asset_id = aa.as_asset_id
            --
            and pcd.t_product_line_id = pl.id),NULL)
else

decode(a."������� ������� � �����������",1,
      (select sum(nvl(pcd.bonus_off_prev,0))
      from ins.as_asset ast,
           ins.P_COVER_DECLINE pcd
      where ast.p_policy_id = a.past_policy_id
            and pcd.as_asset_id = ast.as_asset_id
            and pcd.t_product_line_id = pl.id),NULL)

end "91 ����",

(select pd.income_tax_sum
from ins.ven_p_pol_decline pd
where pd.p_policy_id = a.policy_id) "����� ���� (��� ������� �����)",
(select pd.act_date
from ins.ven_p_pol_decline pd
where pd.p_policy_id = a.policy_id) "���� ����",

decode(a."���������� ���� �������",1,
        (select pod.issuer_return_date
         from ins.ven_p_pol_decline pod
         where pod.p_policy_id = a.policy_id),null) "���� �������",
null "�������� �������",
a."���� �����������",
a."������� �����������",
a."���������",
a."��� �����������",
a."��� �����������",

(select pd.other_pol_num
 from ins.ven_p_pol_decline pd
 where pd.p_policy_id = a.past_policy_id) "������� ����� �� ������ ��",
(SELECT ppt.pol_header_id
FROM
  ins.DOCUMENT d,
  ins.AC_PAYMENT a,
  ins.DOC_TEMPL dt,
  ins.DOC_DOC dd,
  ins.P_POLICY p,
  ins.doc_set_off f1,
  ins.doc_set_off f2,
  ins.doc_doc ddt,
  ins.p_policy ppt
WHERE d.document_id = a.payment_id
  AND d.doc_templ_id = dt.doc_templ_id
  AND dt.brief IN ('PAYORDBACK','PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
  AND dd.child_id = d.document_id
  AND dd.parent_id = p.policy_id
  and d.document_id = f1.parent_doc_id(+)
  and d.document_id = f2.child_doc_id(+)
  and ddt.child_id = nvl(f1.parent_doc_id,f2.parent_doc_id)
  and ppt.policy_id = ddt.parent_id
  and p.pol_header_id = a.policy_header_id
  and ppt.pol_num = (select pd.other_pol_num
                     from ins.ven_p_pol_decline pd
                     where pd.p_policy_id = a.past_policy_id)
  and rownum = 1) "POL_ID_Head (������� ������)",
null "������� ����� �� ��� �� ��",
null "����� 92 � 91 �����",
null "�����������",
case when plt.brief = 'RECOMMENDED' then
    decode(a."������� ������� � �����������",1,
            (select pod.total_fee_payment_sum
             from ins.ven_p_pol_decline pod
             where pod.p_policy_id = a.policy_id),null)
     else 0 end  "����� ����� ���������� �������",
(select c.obj_name_orig from ins.contact c where c.contact_id = ass.assured_contact_id) "��������������",
(select c.contact_id from ins.contact c where c.contact_id = ass.assured_contact_id) "�� �������� (��������������)",
a."���� ����������� ��������",
ll.description "���� ������ ������",
policy_header_id "�� ����� ��",
policy_id        "�� ��"
FROM (
SELECT
       to_char(ph.ids) "���",
       ph.policy_header_id,
       p.policy_id,
       (SELECT MIN(ins.doc.get_doc_status_brief(ab.payment_id))
          FROM ins.DOCUMENT   db,
               ins.AC_PAYMENT ab,
               ins.DOC_TEMPL  dtb,
               ins.DOC_DOC    ddb
         WHERE db.document_id = ab.payment_id
           AND db.doc_templ_id = dtb.doc_templ_id
           AND dtb.brief IN ('PAYORDBACK','PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC', 'PAYORDER_SETOFF')
           AND ddb.child_id = db.document_id
           AND ddb.parent_id = p.policy_id
           and ins.doc.get_doc_status_brief(ab.payment_id) <> 'ANNULATED'
       ) min_back_stat,
       p.pol_num "� ������",
       p.notice_ser "����� ���������",
       p.notice_num "� ���������",
       tp.description "�������� ���������",
       nvl(depph.name,(select depa.name
                       from ins.p_pol_header pha,
                            ins.p_policy_agent_doc pad,
                            ins.ag_contract_header ach,
                            ins.ag_contract ag,
                            ins.department depa
                       where pha.policy_header_id = ph.policy_header_id
                             and pha.policy_header_id = pad.policy_header_id
                             and pad.ag_contract_header_id = ach.ag_contract_header_id
                             and ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                             and ag.contract_id = ach.ag_contract_header_id
                             and sysdate between ag.date_begin and ag.date_end
                             and nvl(ach.is_new,0) = 1
                             and ag.agency_id = depa.department_id)) "������",
       case when nvl(depph.name,'X') = 'X' then
       (select to_char(depa.department_code)
                       from ins.p_pol_header pha,
                            ins.p_policy_agent_doc pad,
                            ins.ag_contract_header ach,
                            ins.ag_contract ag,
                            ins.department depa
                       where pha.policy_header_id = ph.policy_header_id
                             and pha.policy_header_id = pad.policy_header_id
                             and pad.ag_contract_header_id = ach.ag_contract_header_id
                             and ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
                             and ag.contract_id = ach.ag_contract_header_id
                             and sysdate between ag.date_begin and ag.date_end
                             and nvl(ach.is_new,0) = 1
                             and ag.agency_id = depa.department_id)
       else SUBSTR(tpr.ocatd,1,2) end "��� �������",
       ins.pkg_policy.get_policy_contact(p.policy_id, '������������') "�� ������������",
       ins.ent.obj_name('CONTACT',ins.pkg_policy.get_policy_contact(p.policy_id, '������������')) "������������",
       (select cag.obj_name_orig
        from ins.p_pol_header pha,
             ins.p_policy_agent_doc pad,
             ins.ag_contract_header ach,
             ins.contact cag
        where pha.policy_header_id = ph.policy_header_id
              and pha.policy_header_id = pad.policy_header_id
              and pad.ag_contract_header_id = ach.ag_contract_header_id
              and ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT'
              and nvl(ach.is_new,0) = 1
              and ach.agent_id = cag.contact_id) "�����",
       f.brief "������ ��������",
       ph.start_date "���� ������ ���������������",
       p.end_date    "���� ��������� ���������������",
       tpt.description  "������������� ������ �������",
       tpt.number_of_payments,
       (SELECT MIN(ap.plan_date) - pgkr.decline_date
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           and ap.plan_date > pgkr.decline_date
       ) "���-�� ���������� ��� ����",

       (SELECT MAX(ap.plan_date)
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID') db,

         (SELECT sum(ap.amount)
          FROM ins.p_policy   p2,
               ins.doc_doc    dd,
               ins.document   d,
               ins.doc_templ  dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           AND dd.parent_id = p2.policy_id
           AND d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) <> 'ANNULATED'
           and ap.plan_date <= pgkr.decline_date) ppo,

       (SELECT SUM(ins.Pkg_Payment.get_set_off_amount(ap.payment_id, ph.policy_header_id,NULL))
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           and dd.parent_id = p2.policy_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ins.doc.get_doc_status_brief(ap.payment_id) = 'PAID'
           and ap.plan_date <= pgkr.decline_date) po,

       (SELECT SUM(dd.parent_amount - ins.Pkg_Payment.get_set_off_amount(ap.payment_id, ph.policy_header_id,NULL))
          FROM ins.p_policy  p2,
               ins.doc_doc   dd,
               ins.document  d,
               ins.doc_templ dt,
               ins.ac_payment ap
         WHERE p2.pol_header_id = ph.policy_header_id
           and dd.parent_id = p2.policy_id
           and d.document_id = dd.child_id
           and dt.doc_templ_id = d.doc_templ_id
           and dt.brief = 'PAYMENT'
           and ap.payment_id = d.document_id
           and ap.plan_date <= pgkr.decline_date
       )"������ ���������/���������",
       to_char(pgkr.decline_date,'dd.mm.yyyy') "���� �����������",
       tdr.name "������� �����������",
       case tdr.name when '�������� ���������� ������' then '����������'
                     when '��������� �������������� �������' then '����������'
                     when '���������� ������� ���������� �����' then '����������'
                     when '�������� ������� ������' then '����������'
                     when '����� �����������' then '����������'
                     when '��������� �������' then '������������'
                     when '����� ������������ �� ��' then '������������'
                     when '������� ���� (�������������)' then '����'
                     when '������� ���� (�����������)' then '����'
                     when '������ ������������' then '����'
                     when '������ ���������������' then '����'
                     when '����� ������������ �� ��������' then '������������'
                     else ''
       end "���������",
       to_char(pgkr.decline_date,'yyyy') "��� �����������",
       case tdr.name when '�������� ���������� ������' then '�����������'
                     when '��������� �������������� �������' then '�����������'
                     when '���������� ������� ���������� �����' then '�����������'
                     when '�������� ������� ������' then '�������������'
                     when '����� �����������' then '�������������'
                     when '��������� �������' then '�����������'
                     when '����� ������������ �� ��' then '�������������'
                     when '������� ���� (�������������)' then '�������������'
                     when '������� ���� (�����������)' then '�����������'
                     when '������ ������������' then '�����������'
                     when '������ ���������������' then '�����������'
                     when '����� ������������ �� ��������' then '�������������'
                     else tdt.name
       end "��� �����������",
       ins.doc.get_doc_status_name(pgkr.policy_id) "������ ��",
       decode(ins.doc.get_doc_status_name(pgkr.policy_id),'� �����������',1,
                                                          '� �����������. ����� ��� ��������',1,
                                                          '� �����������. ��������',1,
                                                          '���������',1,
                                                          0) "������� ������� � �����������",
       decode(ins.doc.get_doc_status_name(pgkr.policy_id),'� �����������',1,
                                                          '� �����������. ����� ��� ��������',1,
                                                          '� �����������. ��������',1,
                                                          '���������',1,
                                                          '���������.� �������',1,
                                                          '���������. ������ ����������',1,
                                                          '���������. ��������� ��������',1,
                                                          0) "���������� ���� �������",                                                          
                                                          
                                                          
       p.version_num,
       (select pas.policy_id
       from ins.p_policy pas
       where pas.pol_header_id = ph.policy_header_id
             and pas.version_num = pgkr.version_num - 1) past_policy_id,
       p.is_group_flag,

(select c.obj_name_orig
from ins.ven_ac_payment ap,
     ins.doc_doc dd,
     ins.ac_payment_templ apt,
     ins.doc_templ dt,
     ins.contact c,
     ins.cn_contact_bank_acc ccba --������ ������� 209752	��������� ����������
where dd.parent_id = pgkr.policy_id
  AND ap.payment_id = dd.child_id
  AND ap.payment_templ_id = apt.payment_templ_id
  AND apt.brief = 'PAYREQ'
  AND ap.doc_templ_id = dt.doc_templ_id
  AND dt.brief = 'PAYREQ'
  --������ ����������� 209752	��������� ����������
  --and c.contact_id        = ap.contact_id                            
  --������ ������� 209752	��������� ����������
  and ap.contact_bank_acc_id  = ccba.id
  and ccba.owner_contact_id   = c.contact_id
  --  
  and rownum = 1) beneficiary_pay,

(select c.contact_id
from ins.ven_ac_payment ap,
     ins.doc_doc dd,
     ins.ac_payment_templ apt,
     ins.doc_templ dt,
     ins.contact c,
     ins.cn_contact_bank_acc ccba --������ ������� 209752	��������� ����������
where dd.parent_id = pgkr.policy_id
  AND ap.payment_id = dd.child_id
  AND ap.payment_templ_id = apt.payment_templ_id
  AND apt.brief = 'PAYREQ'
  AND ap.doc_templ_id = dt.doc_templ_id
  AND dt.brief = 'PAYREQ'
  --������ ����������� 209752	��������� ����������
  --and c.contact_id        = ap.contact_id                            
  --������ ������� 209752	��������� ����������
  and ap.contact_bank_acc_id  = ccba.id
  and ccba.owner_contact_id   = c.contact_id
  --      
  and rownum = 1) beneficiary_id,
 pgkr.return_summ,
 cr_prod.description "���� ����������� ��������"

  FROM ins.p_policy     p,
       ins.p_pol_header ph,
       ins.t_product    tp,
       (select prod1.description, prod1.product_id from ins.t_product prod1 where prod1.brief like '%CR%') cr_prod,
       ins.department depph,
       ins.t_province   tpr,
       ins.fund                f,
       ins.t_payment_terms     tpt,
       ins.p_policy         pgkr,
       ins.t_decline_reason tdr,
       ins.t_decline_type   tdt
 WHERE 1=1
   AND p.policy_id = ph.policy_id
   AND tp.product_id = ph.product_id
   AND tp.product_id = cr_prod.product_id (+)
   AND tpr.province_id(+) = p.region_id
   AND ph.agency_id = depph.department_id(+)
   AND f.fund_id = ph.fund_id
   AND tpt.id = p.payment_term_id
   AND pgkr.pol_header_id = ph.policy_header_id
   AND ins.doc.get_doc_status_brief(pgkr.policy_id) in ('READY_TO_CANCEL','QUIT_DECL','TO_QUIT','TO_QUIT_CHECK_READY','TO_QUIT_CHECKED','QUIT_REQ_QUERY','QUIT_REQ_GET','QUIT_TO_PAY','QUIT')
   AND pgkr.policy_id  = (select max(ppl.policy_id) from ins.p_policy ppl where ppl.pol_header_id = ph.policy_header_id)
   AND tdr.t_decline_reason_id = pgkr.decline_reason_id
   AND tdt.t_decline_type_id(+) = pgkr.decline_type_id
   --and ph.policy_header_id in (25295935)
) a,
      ins.as_asset            aa,
      ins.as_assured          ass,
      ins.contact             cas,
      ins.status_hist         sha,
      ins.p_cover             pc,
      ins.status_hist         shp,
      ins.t_prod_line_option  plo,
      ins.t_product_line      pl,
      ins.t_product_line_type plt,
      ins.t_lob_line          ll,
      ins.t_insurance_group   ig
WHERE aa.p_policy_id = a.past_policy_id
  AND sha.status_hist_id = aa.status_hist_id
  AND sha.brief <> 'DELETED'
  AND pc.as_asset_id = aa.as_asset_id
  AND aa.as_asset_id = ass.as_assured_id(+)
  AND ass.assured_contact_id = cas.contact_id(+)
  AND shp.status_hist_id = pc.status_hist_id
  AND plo.id = pc.t_prod_line_option_id
  AND plo.product_line_id = pl.id
  AND pl.t_lob_line_id = ll.t_lob_line_id
  AND pl.product_line_type_id = plt.product_line_type_id
  AND ll.insurance_group_id = ig.t_insurance_group_id
  --and policy_header_id in (25295935);
;

