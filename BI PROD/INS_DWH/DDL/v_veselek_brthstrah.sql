create or replace force view ins_dwh.v_veselek_brthstrah as
select pp.insurer_name "������������",
       t1.telephone_prefix||'-'||t1.telephone_number "������ �������",
       t2.telephone_prefix||'-'||t2.telephone_number "������� �������",
       t3.telephone_prefix||'-'||t3.telephone_number "�������� �������",
       t4.telephone_prefix||'-'||t4.telephone_number "��������� �������",
       cn.date_of_birth "���� ��������",
       case nvl(cn.gender,2) when 0 then '�' when 1 then '�' else '���' end "���",

       pp.pol_ser "����� ������",
       pp.num "����� ������",
       pp.notice_num "����� ���������",
       prod.description "�������",
       term.description "�������������",
       pp.f_resp "������",
       dag.num "�� �������",
       cag.name||' '||cag.first_name||' '||cag.middle_name "�����",
       dep.name "���������",
       sh.description "����� ������",
       pp.status_name "������",
       ins.pkg_policy.get_last_version_status(pp.policy_header_id) "������ ��������� ������"


from ins.v_policy_version_journal pp
     left join ins.t_product prod on (prod.product_id = pp.product_id)
     left join ins.t_sales_channel sh on (sh.id = pp.sales_channel_id)
     left join ins.t_payment_terms term on (term.id = pp.payment_term_id)
     left join ins.p_policy_agent pc on (pc.policy_header_id = pp.policy_header_id and pc.status_id = 1)
     left join ins.ag_contract_header ag on (ag.ag_contract_header_id = pc.ag_contract_header_id)
     left join ins.document dag on (dag.document_id = ag.ag_contract_header_id)
     left join ins.contact cag on (cag.contact_id = ag.agent_id)
     left join ins.cn_person cn on (cn.contact_id = pp.insurer_id)
     left join ins.department dep on (dep.department_id = ag.agency_id)

     left join ins.cn_contact_telephone t1 on (t1.contact_id = pp.insurer_id and t1.telephone_type = 1)
     left join ins.cn_contact_telephone t2 on (t2.contact_id = pp.insurer_id and t2.telephone_type = 2)
     left join ins.cn_contact_telephone t3 on (t3.contact_id = pp.insurer_id and t3.telephone_type = 3)
     left join ins.cn_contact_telephone t4 on (t4.contact_id = pp.insurer_id and t4.telephone_type = 4)




where pp.policy_id = pp.active_policy_id
      and pp.status_name not in ('�������','��������','����������','��������� � �����������')
      and cag.name||' '||cag.first_name||' '||cag.middle_name not like '%������������ �����%'
      and sh.brief in ('MLM','SAS 2','SAS')
      and dep.department_id <> 8127
      and ins.pkg_policy.get_last_version_status(pp.policy_header_id) <> '��������� � �����������';

