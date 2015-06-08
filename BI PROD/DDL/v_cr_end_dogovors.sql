create or replace force view v_cr_end_dogovors as
select ent.obj_name('DOCUMENT',ph.policy_header_id) dog_num, --����� ��������
       null code,                                         --��� ���������� �������������
       null dog,                                         --������ �� �������
       pp.policy_id,                                  --�� ������ ��������
       ph.start_date,                                --���� ������ ��������
       pp.end_date,                                  --���� ��������� ������
       pkg_payment.get_calc_amount_policy(pp.policy_id)||' '||f.brief amount,    --����������� ������
       null pay_amount,                                                --����������� ������ �� ��������
       null cont,                                                --���������� ����
       null empl,                                                --��������� ����������� ����
       null tel,                                                --������� ����������� ����
       ph.description                                       --����������
from ven_p_pol_header ph,
     ven_p_policy pp,
     ven_fund f
where pp.policy_id=ph.policy_id
      and f.fund_id=ph.fund_id
;

