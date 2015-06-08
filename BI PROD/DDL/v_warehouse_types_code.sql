create or replace force view v_warehouse_types_code as
select "NUM","DESCRIPTION","CODE","T_WAREHOUSE_CODE_ID","ACT_TYPE_DESCR"
  from (select 0 num,
               '�������� � ����, ��������' description,
               bunker_code code,
               t_warehouse_code_id,
               (select description || ' (����� ����� "' || risk_class || '")' description from t_act_type_code where code = bunker_code) act_type_descr
          from t_warehouse_code
        union
        select 1 num,
               '�1 - ��� ��������' description,
               u1_code code,
               t_warehouse_code_id,
               (select description || ' (����� ����� "' || risk_class || '")' description from t_act_type_code where code = u1_code) act_type_descr
          from t_warehouse_code
        union
        select 2 num,
               '�2 - ��������� ��������' description,
               u2_code code,
               t_warehouse_code_id,
               (select description || ' (����� ����� "' || risk_class || '")' description from t_act_type_code where code = u2_code) act_type_descr
          from t_warehouse_code
        union
        select 3 num,
               '�3 - �������� ������� ��������' description,
               u3_code code,
               t_warehouse_code_id,
               (select description || ' (����� ����� "' || risk_class || '")' description from t_act_type_code where code = u3_code) act_type_descr
          from t_warehouse_code
        union
        select 4 num,
               '�4 - ��������� ������� ��������' description,
               u4_code code,
               t_warehouse_code_id,
               (select description || ' (����� ����� "' || risk_class || '")' description from t_act_type_code where code = u4_code) act_type_descr
          from t_warehouse_code
        union
        select 5 num,
               '�5 - ��������� ������� �������� �� ���������� ���������� ����������� ������� � ��������� ������������ ������� ��������' description,
               u5_code code,
               t_warehouse_code_id,
               (select description || ' (����� ����� "' || risk_class || '")' description from t_act_type_code where code = u5_code) act_type_descr
          from t_warehouse_code)
 where code is not null
 order by num;

