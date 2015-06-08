CREATE OR REPLACE VIEW INS_DWH.FC_EGP AS
SELECT payment_id "ID ���",
       pol_header_id "ID �������� �����������",
       e.coll_method "��� ��������",
       plan_date "���� ���",
       e.due_date "���� ����������",
       e.grace_date "���� �������",
       num "����� ���",
       epg_status "������ ���",
       first_epg "������� 1��� ���",
       e.epg_amount_rur "����� ��� �",
       e.epg_amount "����� ���",
       e.pay_date "���� ������",
       e.set_of_amt_rur "��������� �� ��� ����� �",
       e.set_of_amt "��������� �� ��� �����",
       e.hold_amt_rur "��������� � ���� �� �",
       e.hold_amt "���������� � ���� ��",
       e.agent_id "Id ������",
       e.agent_ad_id "Id �� ��������",
       e.agent_stat "������ ������",
       nvl(nvl(e.agent_agency, e.MANAGER_agency),e.DIR_agency) "��������� ��.",
       e.MANAGER_id "Id ���������",
       e.MANAGER_ad_id "Id ��� ��������",
       e.MANAGER_stat "������ ���������",
       e.MANAGER_agency "��������� ���.",
       e.DIR_id "Id ���������",
       e.DIR_ad_id "Id ��� ��������",
       e.DIR_stat "������ ���������",
       e.DIR_agency "��������� ���.",
       e.ape_amount_rur,
       e.epg_num,
       e.agent_agency_id,
       e.index_fee
  FROM ins_dwh.t_fc_epg e
/*DROP MATERIALIZED VIEW FC_EGP;

CREATE MATERIALIZED VIEW FC_EGP
REFRESH FORCE ON DEMAND
AS
SELECT payment_id "ID ���",
       pol_header_id "ID �������� �����������",
       e.coll_method "��� ��������",
       plan_date "���� ���",
       e.due_date "���� ����������",
       e.grace_date "���� �������",
       num "����� ���",
       epg_status "������ ���",
       first_epg "������� 1��� ���",
       e.epg_amount_rur "����� ��� �",
       e.epg_amount "����� ���",
       e.pay_date "���� ������",
       e.set_of_amt_rur "��������� �� ��� ����� �",
       e.set_of_amt "��������� �� ��� �����",
       e.hold_amt_rur "��������� � ���� �� �",
       e.hold_amt "���������� � ���� ��",
       e.agent_id "Id ������",
       e.agent_ad_id "Id �� ��������",
       e.agent_stat "������ ������",
       e.agent_agency "��������� ��.",
       e.MANAGER_id "Id ���������",
       e.MANAGER_ad_id "Id ��� ��������",
       e.MANAGER_stat "������ ���������",
       e.MANAGER_agency "��������� ���.",
       e.DIR_id "Id ���������",
       e.DIR_ad_id "Id ��� ��������",
       e.DIR_stat "������ ���������",
       e.DIR_agency "��������� ���.",
       e.epg_num
  FROM ins.v_epg_fact_preview e

begin
dbms_stats.gather_table_stats(
    'INS_DWH', 'fc_egp',
    degree => 1,
    CASCADE => TRUE
  );
end;*/;
