create materialized view INS_DWH.PRE_AG_COMPLETE_POLICY
refresh force on demand
as
select a.DATE_POLICY accept_date,  -- ���� ������ �������� �������� (�� �7 ��� �� ��4), ��� �� start_date!
    SUM(a.SGP_AMOUNT) as sgp_amount, -- ����� ��� ������ �� ����
    count(*) as sgp_policy_count, -- ���������� ��������� �� ����
       a.AG_CONTRACT_HEADER_ID ag_contract_header_id-- ����� ���������� ���������
from
ins.AG_ALL_AGENT_SGP a
group by a.AG_CONTRACT_HEADER_ID,a.DATE_POLICY;

