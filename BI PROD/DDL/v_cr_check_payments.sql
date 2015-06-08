create or replace force view v_cr_check_payments as
select ent.obj_name('DOCUMENT',ac.payment_id) as pay_number,--����� �����
       ac.reg_date as data_act,           --���� ����������� ����� (����������� ���������)
       ac.contact_id as lpu,         --�� ��� (�����������-����������)
       decode(upper(f.brief),'RUR',ac.rev_amount,ac.amount*acc.Get_Cross_Rate_By_Brief(rt.rate_type_id,f1.brief,'RUR',ac.reg_date)) as summa,          --�����
       apt.brief as brief               --��� ���������
from ven_ac_payment ac,
     ven_ac_payment_templ apt,
     ven_fund f,
     ven_fund f1,
     ven_rate_type rt
where apt.payment_templ_id=ac.payment_templ_id
      and upper(apt.brief) in ('���','DMS_INV_LPU_SERV','WRITEOFFEXP')
      and f.fund_id=ac.rev_fund_id
      and rt.is_default=1
      and f1.fund_id=ac.fund_id
;

