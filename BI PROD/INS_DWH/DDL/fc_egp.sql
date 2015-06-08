CREATE OR REPLACE VIEW INS_DWH.FC_EGP AS
SELECT payment_id "ID ���"
       ,pol_header_id "ID �������� �����������"
       ,e.coll_method "��� ��������"
       ,plan_date "���� ���"
       ,e.due_date "���� ����������"
       ,e.grace_date "���� �������"
       ,num "����� ���"
       ,epg_status "������ ���"
       ,first_epg "������� 1��� ���"
       ,e.epg_amount_rur "����� ��� �"
       ,e.epg_amount "����� ���"
       ,e.pay_date "���� ������"
       ,e.set_of_amt_rur "��������� �� ��� ����� �"
       ,e.set_of_amt "��������� �� ��� �����"
       ,e.hold_amt_rur "��������� � ���� �� �"
       ,e.hold_amt "���������� � ���� ��"
       ,e.agent_id "Id ������"
       ,e.agent_ad_id "Id �� ��������"
       ,e.agent_stat "������ ������"
       ,nvl(nvl(e.agent_agency, e.manager_agency), e.dir_agency) "��������� ��."
       ,e.manager_id "Id ���������"
       ,e.manager_ad_id "Id ��� ��������"
       ,e.manager_stat "������ ���������"
       ,e.manager_agency "��������� ���."
       ,e.dir_id "Id ���������"
       ,e.dir_ad_id "Id ��� ��������"
       ,e.dir_stat "������ ���������"
       ,e.dir_agency "��������� ���."
       ,e.addendum_type "��� ���������"
       ,e.ape_amount_rur
       ,e.epg_num
       ,e.agent_agency_id
       ,e.index_fee
       ,e.index_fee_prop
       ,e.epg_amount_rur_acc
       ,e.epg_amount_acc
  FROM ins_dwh.t_fc_epg e;
