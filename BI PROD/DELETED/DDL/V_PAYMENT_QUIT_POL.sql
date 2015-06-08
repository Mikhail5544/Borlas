CREATE OR REPLACE VIEW INS_DWH.V_PAYMENT_QUIT_POL AS
select distinct
       pr.PAYMENT_REGISTER_ITEM_ID "��",
       pr.DUE_DATE "���� ��",
       pr.NUM      "����� ��",
       pr.AMOUNT           "����� �������",
       pr.sum2setoff       "����� �������� �������",
       pr.TERRITORY        "������",
       pr.PAYMENT_PURPOSE  "����������",
       pr.set_off_state_descr "������ ������ ���������",
       pr.NOTE "�����������",
       substr(pr.NOTE,48,10) "���",
       pp.pol_num "����� ������",
       cpol.obj_name_orig "������������",
       prod.description "�������",
       trm.description "�������������",
       (select pp.decline_date
        from ins.p_policy p
        where p.policy_id = ins.pkg_policy.get_last_version(ph.policy_header_id)) "���� �����������",
       (select dr.name
        from ins.p_policy p,
             ins.ven_t_decline_reason dr
        where p.policy_id = ins.pkg_policy.get_last_version(ph.policy_header_id)
              and dr.t_decline_reason_id(+) = pp.decline_reason_id) "������� �����������",
       ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 2, SYSDATE) "��������� ����������",
       ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 1, SYSDATE) "������ ������������",
       ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 1, SYSDATE) + 70 "���� ������������� + 70",
       case when ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 1, SYSDATE) + 70 >= pr.DUE_DATE then '������������ ��� �������������'
            when ins.pkg_renlife_utils.First_unpaid(ph.policy_header_id, 1, SYSDATE) + 70 < pr.DUE_DATE then '������������ ����������� �������'
            else '' end "������� ��������������",
       dep.name "���������",
       d.num||' '||cag.obj_name_orig "�����",
       (select dl.num||' '||cagl.obj_name_orig
       from ins.ag_contract ag,
            ins.ag_contract agl,
            ins.ag_contract_header aghl,
            ins.contact cagl,
            ins.document dl
       where ag.contract_id = agh.ag_contract_header_id
             and sysdate between ag.date_begin and ag.date_end
             and nvl(agh.is_new,0) = 1
             and ag.contract_leader_id = agl.ag_contract_id
             and agl.contract_id = aghl.ag_contract_header_id
             and aghl.ag_contract_header_id = dl.document_id
             and aghl.agent_id = cagl.contact_id) "������������ ������",
  (select tel.telephone_prefix||' '||tel.telephone_number tel
       from ins.t_telephone_type tt,
            ins.cn_contact_telephone tel
       where tel.contact_id = cpol.contact_id
             and tt.id = tel.telephone_type
             and tt.description in ('���������� �������')
             and length(tel.telephone_number) > 3
             and rownum = 1
        ) "���������� �������",
       (select tel.telephone_prefix||' '||tel.telephone_number tel
       from ins.t_telephone_type tt,
            ins.cn_contact_telephone tel
       where tel.contact_id = cpol.contact_id
             and tt.id = tel.telephone_type
             and tt.description in ('������ �������')
             and length(tel.telephone_number) > 3
             and rownum = 1
        ) "������ �������",
       (select tel.telephone_prefix||' '||tel.telephone_number tel
       from ins.t_telephone_type tt,
            ins.cn_contact_telephone tel
       where tel.contact_id = cpol.contact_id
             and tt.id = tel.telephone_type
             and tt.description in ('���������')
             and length(tel.telephone_number) > 3
             and rownum = 1
        ) "��������� �������",
        NVL(ca.name, ins.pkg_contact.get_address_name(ca.id)) "������ ������",
       (case when ca.street_name is not null then (CASE WHEN ca.street_type IS NOT NULL THEN ca.street_type ELSE '��.' END)||ca.street_name else '' end ||
       case when ca.house_nr is not null then ',�.'||ca.house_nr else '' end ||
       case when ca.block_number is not null then ','||ca.block_number else '' end ||
       case when ca.appartment_nr is not null then ',��.'||ca.appartment_nr else '' end) "����������� ������ ������",
       (case when ca.city_name is not null then (CASE WHEN ca.city_type IS NOT NULL THEN ca.city_type ELSE '�.' END)||ca.city_name else '' end) "�����",
       case when ca.region_name is not null then (CASE WHEN ca.region_type IS NOT NULL THEN ca.region_type||' ' ELSE '' END)||ca.region_name else '' end "�����",
       case when ca.province_name is not null then (CASE WHEN ca.province_type IS NOT NULL THEN ca.province_type||' ' ELSE '' END)||ca.province_name else '' end "�������",
       case when ca.district_name is not null then (CASE WHEN ca.district_type IS NOT NULL THEN ca.district_type||' ' ELSE '' END)||ca.district_name else '' end "���������� �����",
       (select distinct tc.description from ins.t_country tc where tc.id = ca.country_id) "������",
       ca.zip "������"

  FROM ins.V_PAYMENT_REGISTER pr
  JOIN ins.p_pol_header ph ON to_char(ph.Ids) = substr(pr.NOTE,48,10)
  JOIN ins.p_policy pp ON (ph.policy_id = pp.policy_id)
  JOIN ins.p_policy_contact pcnt ON (pcnt.policy_id = pp.policy_id)
  JOIN ins.t_contact_pol_role polr ON (pcnt.contact_policy_role_id = polr.id and polr.brief = '������������')
  JOIN ins.contact cpol ON (cpol.contact_id = pcnt.contact_id)
  JOIN ins.t_product prod ON (prod.product_id = ph.product_id)
  JOIN ins.t_payment_terms trm ON (pp.payment_term_id = trm.id)
  LEFT OUTER JOIN ins.department dep ON (ph.agency_id = dep.department_id)
  LEFT OUTER JOIN ins.p_policy_agent_doc pad ON (pad.policy_header_id = ph.policy_header_id and ins.doc.get_doc_status_brief(pad.p_policy_agent_doc_id) = 'CURRENT')
  LEFT OUTER JOIN ins.ag_contract_header agh ON (agh.ag_contract_header_id = pad.ag_contract_header_id)
  LEFT OUTER JOIN ins.document d ON (d.document_id = agh.ag_contract_header_id)
  LEFT OUTER JOIN ins.contact cag ON (cag.contact_id = agh.agent_id)
  LEFT OUTER JOIN ins.cn_address ca ON (ins.pkg_contact.get_primary_address(cpol.contact_id) = ca.ID)

 where pr.DUE_DATE between --to_date('01-01-2011','dd-mm-yyyy') and to_date('31-01-2011','dd-mm-yyyy')
       (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'quit_pay' and param_name = 'start_date')
                       and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'quit_pay' and param_name = 'end_date')
       and pr.set_off_state_descr = '�����������'
       --and pr.PAYMENT_PURPOSE like '%�������� ������ ���������� 004532-�������� ������ ����������';
