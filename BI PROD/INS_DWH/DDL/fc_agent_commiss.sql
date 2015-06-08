CREATE MATERIALIZED VIEW INS_DWH.FC_AGENT_COMMISS
REFRESH FORCE ON DEMAND
AS
SELECT pol_header "ID �������� �����������",
       com_epg "��� � ���������� ���������",
       date_from "���� �",
       fee "������ ����� �� 1��",
       adm_cost "�������� �� 1��",
       pay_term "������������� �� 1��",
       f_date "���� ������ 1��� ���",
       f_pay "����� ������ 1��� ���",
       sale_ad "ID ���������� ��",
       cat_ad "�������� ����������",
       stat_ad "������ ����������",
       mng_ad "ID ������������",
       FIO_MNG "��� ������������",
       AD_NUM_MNG "�� ������������",
       CAT_MNG "��������� ������������",
       STAT_MNG "������ ������������",
       GET_AD "ID ����������� ��",
       FIO_GET "��� �����������",
       AD_NUM_GET "�� �����������",
       GET_AGENCY "��������� �����������",
       CAT_GET "�������� �����������",
       STAT_GET "������ �����������",
       MONTH_NUM "����� ��������",
       TYPE_AV "��� ��",
       CALC_DATE "���� ������� ��",
       CALC_PER "�������� ������",
       SUB_TYPE_AV "��� ��",
       COM_SUMm "����� ��������"
  FROM ins.v_commis_fact_preview_oav a
 WHERE 1!=1
UNION ALL
SELECT * FROM ins.v_commis_fact_preview_dav
WHERE 1!=1
UNION ALL
SELECT * FROM ins.v_commis_fact_preview_prem
WHERE 1!=1;

