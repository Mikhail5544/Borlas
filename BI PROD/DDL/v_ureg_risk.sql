create or replace force view v_ureg_risk as
select pl.description
     from t_prod_line_option pl
     where pl.description in ('������ ��������� �������','������ ��������� ������� ������������ �� �������� ���������',
                           '������������ �� ������ ������� ������������ �� �������� ���������','������������ �� ������ ���������� �������',
                           '������������ �� ������ ���������� ������� ������������ �� �������� ���������',
                           '������������ �� ������ ��������� �������')
     union
     select tp.description
     from t_peril tp;

