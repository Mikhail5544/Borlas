CREATE OR REPLACE PROCEDURE correct_agent_date(v_ag_num       in varchar, --номер агенского договора 6 знаков
                                              v_num          in number, --пор€дковый номер ƒ—
                                              v_now_date     in date, --дата котора€ сейчас задана
                                              v_correct_date in date) as--дата которую необходимо установить
begin
 
  correct_DS_date(v_ag_num , v_num, v_now_date, v_correct_date);
  correct_dov_date(v_ag_num , v_num, v_now_date, v_correct_date);
 
exception
  when others then
    DBMS_OUTPUT.put_line(sqlerrm);
end correct_agent_date;
/

