create or replace view ins.report_sales_dep as
select sd.universal_code "������������� ���",
       sd.dept_name "�������� �������������",
       sd.legal_name "����������� ��������",
       sd.marketing_name "������������� ��������",
       sd.short_name "������� �����������",
       sd.company_name "��������",
       sd.sales_channel "����� ������",
       sd.initiator_name "��������� ��������",
       sd.local_director_name "��������������� ��������",
       sd.manager_name "������������",
       sd.roo_name "�������� ���",
       sd.tap_number "���",
       sd.roo_number "����� ���",
       sd.branch_name "����",
       sd.address "�����",
       sd.cc_code "��� ������ ������",    
       sd.kpp "��� �������������",
       tt.tac_number "���",
       sd.open_date "���� ��������",
       sd.close_date "���� ��������",
       sd.ver_num "������ �����",
       sd.start_date "���� ������"

from ins.sales_dept_header sdh,
     ins.v_sales_depts sd,
     (select tt.t_tap_header_id
              ,tc.tac_number
              ,tc.tac_name
          from ven_t_tac_to_tap       tt
              ,ven_t_tac              tc
              ,ven_t_tac_header       tch
         where tt.t_tac_id = tc.t_tac_id
           and tc.t_tac_id = tch.last_tac_id
           and tt.end_date = pkg_tac.get_default_end_date
      ) tt
where sdh.last_sales_dept_id = sd.sales_dept_id
      and sd.t_tap_header_id = tt.t_tap_header_id (+);
