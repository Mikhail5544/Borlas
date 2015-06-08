create or replace force view v_cr_pay_to_lpu as
select t.contact_id,                                        --�� ���
       decode(templ.brief,'PAYADVLPU','����������','����') pay_type, --��� ������
       ent.obj_name('DOCUMENT',t1.payment_id) pay_num,              --����� �����
       t1.reg_date,                                         --���� ����������� �����(���������)
       dso.set_off_date,                                    --���� ������ �����(���� ������)
       null med_type,                                       --��� ����������� ������
       dso.set_off_amount,                                  --����� �������� (����� ������)
       dso.note                                             --����������
from ven_ac_payment t,
      ven_doc_set_off dso,
      ven_doc_doc dd,
      ven_ac_payment t1,
      ven_ac_payment_templ templ
where templ.payment_templ_id=t.payment_templ_id
and upper(templ.brief) in ('PAYADVLPU','PAYORDLPU')
and dso.parent_doc_id(+)=t.payment_id
and dd.child_id(+)=t.payment_id
and t1.payment_id(+)=dd.parent_id
;

