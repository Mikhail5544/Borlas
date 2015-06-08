create materialized view INS_DWH.DM_RISK_TYPE_GAAP
refresh force on demand
as
select 1 RISK_TYPE_GAAP_ID, '�������� �����' name, 'short_life' brief
  from dual
union all
select 2 RISK_TYPE_GAAP_ID, '������� �����' name, 'long_life' brief
  from dual
union all
select 3 RISK_TYPE_GAAP_ID, '�������� ��' name, 'short_ns' brief
  from dual
union all
select 4 RISK_TYPE_GAAP_ID, '������� ��' name, 'long_ns' brief
  from dual
union all
select -1 RISK_TYPE_GAAP_ID, '�� ����������' name, '�� ����������' brief from dual;

