CREATE OR REPLACE VIEW V_REP_DAMAGE_NDFL AS
WITH damage_claim AS
 (SELECT /*+inline*/
        ap.contact_id
        ,sum(ROUND(dam.payment_sum *
               acc.get_cross_rate_by_id(1, f_d.fund_id, f_ch.fund_id, ch.declare_date)
              ,2)) AS amount
        ,damc.description damage_desc
        ,ch.c_event_id
        ,ch.p_policy_id
        ,ch.peril_id
        ,ch.as_asset_id
        ,e.event_date
        ,dsr.brief status
        ,ph.ids
        ,ph.fund_id
        ,ph.product_id
        ,p.pol_num
        ,p.pol_header_id
        ,p.confirm_date
        ,p.end_date
        ,p.t_product_conds_id
        ,ph.start_date
    FROM c_claim        c
        ,c_claim_header ch
        ,document       d
        ,doc_status_ref dsr
        ,ac_payment     ap
        ,document       dp
        ,doc_templ      dt
        ,doc_doc        dd
        ,c_damage       dam
        ,t_damage_code  damc
        ,c_event        e
        ,p_policy       p
        ,p_pol_header   ph
        ,fund           f_d
        ,fund           f_ch
   WHERE d.document_id = c.c_claim_id
     AND d.doc_status_ref_id = dsr.doc_status_ref_id
     AND dsr.brief IN ('FOR_PAY', 'GUIDANCE', 'CLOSE')
     AND dp.doc_templ_id = dt.doc_templ_id
     AND dt.brief IN ('PAYORDER', 'PAYORDER_SETOFF')
     AND dd.child_id = dp.document_id
     AND dd.parent_id = c.c_claim_id
     AND dp.document_id = ap.payment_id
     AND dam.c_claim_id = c.c_claim_id
     AND dam.t_damage_code_id = damc.id
     AND ch.c_event_id = e.c_event_id
     AND c.c_claim_header_id = ch.c_claim_header_id
     AND ch.p_policy_id = p.policy_id
     AND ph.policy_header_id = p.pol_header_id
     AND dam.damage_fund_id = f_d.fund_id
     AND ch.fund_id = f_ch.fund_id
group by ap.contact_id
        ,damc.description
        ,ch.c_event_id
        ,ch.p_policy_id
        ,ch.peril_id
        ,ch.as_asset_id
        ,e.event_date
        ,dsr.brief
        ,ph.ids
        ,ph.fund_id
        ,ph.product_id
        ,p.pol_num
        ,p.pol_header_id
        ,p.confirm_date
        ,p.end_date
        ,p.t_product_conds_id
        ,ph.start_date)
SELECT dc.pol_header_id
      ,dc.p_policy_id
      ,dc.ids /*AS "������� IDS"*/
      ,dc.pol_num /*AS "����� ��������"*/
      ,pr.description AS product_description
      ,decode(pfp.profit_type, 0, '���', 1, '���') AS tip_dog /*"��� �������� "*/
      ,dc.confirm_date /*AS "���� ��� ��� � ����"*/
      ,dc.end_date /*AS "���� ���� ������ ���"*/
      ,vi.contact_name AS fio_ass /* "������������ ���/������������"*/
      ,vi.contact_id AS id_ass /*"������������ ID ��������"*/
      ,ct.description AS tip_ass /*"��� �����(���.����/��.����)"*/
      ,ent.obj_name(a.ent_id, a.as_asset_id) AS fio_ins /*"��������������"*/
      ,cp.obj_name_orig AS fio_recipient /*"���������� ���/������������"*/
      ,dc.event_date /*AS "���� ���� ����� ������"*/
      ,tp.description AS risk /*"C�������� ����"*/
      ,cp.contact_id AS id_recipient /*"���������� ID ��������"*/
      ,ctp.description AS tip_recipient /* "��� �����(���.����/��.����)"*/
      ,nvl(pc.description
          ,decode(pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(cp.contact_id)
                                                                ,'<#TYPE_DESC>')
                 ,'������� ���������� ��'
                 ,'������'
                 ,NULL)) AS country /*"����������� ����������"*/
      ,decode((SELECT COUNT(*)
                FROM dual
               WHERE EXISTS (SELECT 1
                        FROM cn_contact_ident cci
                            ,t_id_type        it
                       WHERE cci.contact_id = cp.contact_id
                         AND cci.id_type = it.id
                         AND it.brief = 'PASS_RF'
                         AND cci.termination_date IS NULL))
             ,0
             ,NULL
             ,'��������') AS resident_recipient/*"���������� ��������?"*/
       ,vcp.date_of_birth /*AS "����.������(���� ��������)"*/
       ,ins.pkg_contact_rep_utils.get_address_by_mask(pkg_contact_rep_utils.get_letters_address_id(cp.contact_id)
                                                    ,'<#ADDRESS_FULL>') AS address /*"����.������(����� �����������)"*/
       ,pkg_contact_rep_utils.format_ident_doc_by_mask(pkg_contact_rep_utils.get_primary_doc_id(cp.contact_id)
                                                     ,'<#DOC_SERNUM>' || ' ' || '<#DOC_PLACE>' || ' ' ||
                                                      '<#DOC_DATE>') AS pasport /*"���������� ������"*/
       ,(CASE
         WHEN vi.contact_id <> a.as_asset_id THEN
          '�������'
         ELSE
          '���'
       END) AS attorney /*"������������ �� ����������"*/
       ,'' AS famaly /*"���.����� ����� � �����"*/
       ,dc.ins_pay /*AS "��������� �������"*/
       ,dc.did /* AS "���"*/
       ,dc.other /*AS "������"*/
       ,dc.ins_pay + dc.did + dc.other AS itogo /*"����� �� ��������"*/
       ,dc.prev_paid /*AS "����� ����� ������ ������"*/
       ,fn_get_ins_pay_inc_ref(dc.pol_header_id, dc.start_date, least(dc.event_date, dc.end_date)) AS ins_pay_inc_ref /*"����� ����� ���,�� �� �� ���"*/
       ,f.brief AS val /*"������ ��������"*/
       ,(SELECT pkg_utils.get_aggregated_string(CAST(MULTISET (SELECT crt.relationship_dsc
                                                      FROM cn_contact_rel     ccr
                                                          ,t_contact_rel_type crt
                                                     WHERE ccr.relationship_type = crt.id
                                                       AND ccr.contact_id_a = vi.contact_id
                                                       AND ccr.contact_id_b = cp.contact_id) AS
                                                   tt_one_col)
                                             ,', ')
         FROM dual) as relation
  FROM (SELECT dc1.p_policy_id
              ,dc1.as_asset_id
              ,dc1.ids
              ,dc1.pol_num
              ,dc1.pol_header_id
              ,dc1.start_date
              ,dc1.confirm_date
              ,dc1.end_date
              ,dc1.event_date
              ,dc1.contact_id
              ,dc1.peril_id
              ,dc1.fund_id
              ,dc1.product_id
              ,dc1.t_product_conds_id
              ,dc1.amount AS ins_pay
              ,(SELECT nvl(SUM(nvl(dc2.amount, 0)), 0)
                  FROM damage_claim dc2
                 WHERE dc2.c_event_id = dc1.c_event_id
                   AND dc2.damage_desc = '�������������� �������������� �����'
                   AND dc2.status IN ('FOR_PAY', 'GUIDANCE')) AS did
              ,(SELECT nvl(SUM(nvl(dc3.amount, 0)), 0)
                  FROM damage_claim dc3
                 WHERE dc3.ids = dc1.ids
                      /*����������� ������*/
                   AND dc3.damage_desc IN ('����������'
                                          ,'�������� �� ����������� ������ ����������'
                                          ,'������ ����� �������������'
                                          ,'������� �� ���������� ������������'
                                          ,'��������� �����'
                                          ,'���� �������'
                                          ,'����������'
                                          ,'���������� ��� �����')) AS other
              ,(SELECT nvl(SUM(nvl(dc4.amount, 0)), 0)
                  FROM damage_claim dc4
                 WHERE dc4.ids = dc1.ids
                      /*������ ��������� ����*/
                   AND (dc4.damage_desc NOT IN ('������� ��������������� ���� �� ������������� ���� ��� ���� ��������� ����� �����������'
                                               ,'�������������� �������������� �����'
                                               ,'����������'
                                               ,'�������� �� ����������� ������ ����������'
                                               ,'������ ����� �������������'
                                               ,'������� �� ���������� ������������'
                                               ,'��������� �����'
                                               ,'���� �������'
                                               ,'����������'
                                               ,'���������� ��� �����') OR (dc4.damage_desc =
                       '������� ��������������� ���� �� ������������� ���� ��� ���� ��������� ����� �����������' AND
                       dc4.status = 'CLOSE'))) prev_paid
          FROM damage_claim dc1
         WHERE dc1.damage_desc =
               '������� ��������������� ���� �� ������������� ���� ��� ���� ��������� ����� �����������'
           AND dc1.status IN ('FOR_PAY', 'GUIDANCE')) dc

      ,t_peril   tp
      ,t_product pr
      ,v_pol_issuer         vi
      ,contact              ci
      ,t_contact_type       ct
      ,as_asset             a
      ,contact              cp
      ,t_contact_type       ctp
      ,cn_person            t
      ,t_country            pc
      ,cn_person            vcp
      ,fund                 f
      ,t_policyform_product pfp
 WHERE tp.id = dc.peril_id
   AND pr.product_id = dc.product_id
   AND dc.p_policy_id = vi.policy_id
   AND ci.contact_id = vi.contact_id
   AND ct.id = ci.contact_type_id
   AND dc.as_asset_id = a.as_asset_id
   AND dc.contact_id = cp.contact_id
   AND ctp.id(+) = cp.contact_type_id
   AND t.contact_id(+) = cp.contact_id
   AND t.country_birth = pc.id(+)
   AND vcp.contact_id(+) = cp.contact_id
   AND dc.fund_id = f.fund_id
   AND pfp.t_policyform_product_id = dc.t_product_conds_id
;
