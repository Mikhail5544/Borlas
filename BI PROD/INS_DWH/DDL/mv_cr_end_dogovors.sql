create materialized view INS_DWH.MV_CR_END_DOGOVORS
build deferred
refresh force on demand
as
select ins.ent.obj_name('DOCUMENT',ph.policy_header_id) dog_num, --����� ��������
       cast(null as varchar2(2000))  code,                                         --��� ���������� �������������
       cast(null as varchar2(2000))  dog,                                         --������ �� �������
       pp.policy_id,                                  --�� ������ ��������
       ph.start_date,                                --���� ������ ��������
       pp.end_date,                                  --���� ��������� ������
       ins.pkg_payment.get_calc_amount_policy(pp.policy_id)||' '||f.brief amount,    --����������� ������
       cast(null as varchar2(2000)) pay_amount,                                                --����������� ������ �� ��������
       cast(null as varchar2(2000)) cont,                                                --���������� ����
       cast(null as varchar2(2000)) empl,                                                --��������� ����������� ����
       cast(null as varchar2(2000)) tel,                                                --������� ����������� ����
       ph.description                                       --����������
from ins.ven_p_pol_header ph,
     ins.ven_p_policy pp,
     ins.ven_fund f
where pp.policy_id=ph.policy_id
      and f.fund_id=ph.fund_id;

