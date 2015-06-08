create or replace view ins.v_personal_profile_insured
as
select t.insured_id
      ,t.insured_name
      ,t.login_name
      ,t.pwd
      ,case t.sending_status
         when 0 then '�� ����������'
         when 1 then '����������, ����� �� �������'
         when 2 then '���������� ��� ������'
         when 3 then '������ ��� ������� �� ������� ��'
       end as sending_status
      ,t.email
      ,t.gender
      ,t.when_sent
      ,t.sending_error
  from ins.personal_profile_insured t;

grant select on ins.v_personal_profile_insured to ins_read;
grant select on ins.v_personal_profile_insured to ins_eul;
