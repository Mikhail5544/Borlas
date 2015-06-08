create or replace force view v_cr_dog_service as
select as_prop.dog_num,                 --����� ��������
       as_prop.policy_header_id,        --�� ��������
       as_prop.policy_num policy_num,    --����� ������ ��������
       as_prop.policy_id policy_id,                 --�� ������ ��������
       as_prop.dog_start,                           --���� ������ ��������
       as_prop.dog_end,                             --���� ��������� ��������
       as_prop.card_num,                            --����� ������
       as_prop.assured_start_date,                  --���� ������ ������
       as_prop.assured_stop_date,                   --���� ������������� ������
       as_prop.code,                                --��� ��������� �����������
       aa.assured_contact_id,                       --�� ���������������
       as_prop.contact_id,                          --�� ���
       sm.c_service_med_id,                          --�� ��������� ������
       ent.obj_name(tp.ent_id,tp.id) med_type,        --��� ����������� ������
       as_prop.prod_type,                             --��� ��������
       as_prop.note                                   --����������
from ven_c_service_med sm
     left join ven_dms_rel_serv_act rsa on rsa.c_service_med_id=sm.c_service_med_id
     join ven_as_assured aa on aa.as_assured_id=sm.as_asset_id
     join v_cr_assured_prop as_prop on as_prop.assured_contact_id=aa.assured_contact_id
     join v_cr_pol_assured ass on ass.assured_contact_id=as_prop.assured_contact_id
     join v_cr_lpu_list lpu on lpu.contact_id=as_prop.contact_id
     left join ven_t_peril tp on tp.id=sm.dms_aid_type_id and tp.is_dms_code=1
;

