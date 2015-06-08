CREATE OR REPLACE PROCEDURE correct_agent_date(v_ag_num       in varchar, --����� ��������� �������� 6 ������
                                              v_num          in number, --���������� ����� ��
                                              v_now_date     in date, --���� ������� ������ ������
                                              v_correct_date in date) as--���� ������� ���������� ����������
begin
 
  correct_DS_date(v_ag_num , v_num, v_now_date, v_correct_date);
  correct_dov_date(v_ag_num , v_num, v_now_date, v_correct_date);
 
exception
  when others then
    DBMS_OUTPUT.put_line(sqlerrm);
end correct_agent_date;
/

