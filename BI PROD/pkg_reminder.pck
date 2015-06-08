CREATE OR REPLACE PACKAGE pkg_reminder IS

  -- Author  : Alexander Kalabukhov
  -- Created : 26.06.2006 18:06:14
  -- Purpose : ќбслуживание напоминаний пользовател€

  v_sys_user_reminder_msg_id ven_sys_user_reminder_msg.sys_user_reminder_msg_id%TYPE;
  v_sys_user_id              ven_sys_user.sys_user_id%TYPE;
  v_reminder_id              ven_reminder.reminder_id%TYPE;
  v_interval                 NUMBER;

  /**
  * ќбновить напоминани€ дл€ всех пользователей
  * @author Alexander Kalabukhov
  */
  PROCEDURE refresh_all_users;

  /**
  * ќбновить напоминани€ дл€ пользовател€
  * @author Alexander Kalabukhov
  * @param p_sys_user_id »ƒ пользовател€ системы, €вл€тс€ необ€зательным автоматически инициализируетс€ 
  */
  PROCEDURE refresh(p_sys_user_id IN NUMBER DEFAULT NULL);

  /**
  * ¬ыполнить действие по напоминанию
  * @author Alexander Kalabukhov
  * @param p_sys_user_id »ƒ пользовател€ системы, €вл€тс€ необ€зательным автоматически инициализируетс€ 
  */
  PROCEDURE exec(p_sys_user_reminder_msg_id IN NUMBER);

  /**
  * —уществуют ли у пользовател€ напоминани€
  * @author Alexander Kalabukhov
  * @param p_sys_user_id »ƒ пользовател€ системы, €вл€тс€ необ€зательным автоматически инициализируетс€ 
  * @return существуют или нет у пользовател€ напоминани€  
  */
  FUNCTION is_sys_user_reminder(p_sys_user_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN;

  /**
  * —уществуют ли дл€ пользовател€ напоминани€
  * @author Alexander Kalabukhov
  * @param p_sys_user_id »ƒ пользовател€ системы, €вл€тс€ необ€зательным автоматически инициализируетс€ 
  * @return существуют или нет дл€ пользовател€ напоминани€  
  */
  FUNCTION is_sys_user_reminder_msg(p_sys_user_id IN NUMBER DEFAULT NULL) RETURN BOOLEAN;

END;
/
create or replace package body pkg_reminder is

/*
begin
  sys.dbms_job.submit(job => :job,
                      what => 'begin pkg_reminder.refresh_all_users; end;',
                      next_date => to_date('03-07-2006 11:03:20', 'dd-mm-yyyy hh24:mi:ss'),
                      interval => 'sysdate + 1/72');
  commit;
end;
/
*/

  procedure set_sys_user_id(p_sys_user_id in number) as
  begin
    if p_sys_user_id is null then 
      v_sys_user_id := safety.curr_sys_user;
    else
      v_sys_user_id := p_sys_user_id;  
    end if;  
  end;
    

  procedure refresh(p_sys_user_id in number default null) is
  begin
    set_sys_user_id(p_sys_user_id);
    
    delete from ven_sys_user_reminder_msg surm 
    where surm.sys_user_id = v_sys_user_id and surm.stop_date < sysdate;
    commit;
  
    for v_r in ( select sur.sys_user_id, sur.reminder_id, r.calc, r.name
                 from sys_user_reminder sur,
                      reminder r
                 where sur.sys_user_id = v_sys_user_id
                       and r.reminder_id = sur.reminder_id
                       and r.calc is not null
               ) loop
      v_reminder_id := v_r.reminder_id;
      begin
        execute immediate v_r.calc;
        commit;
      exception
        when others then
          rollback;
      end;        
    end loop;
  end;

  
  procedure refresh_all_users is
  begin
    for v_r in ( select * from ve_session_reminder) loop
      refresh(v_r.sys_user_id);
    end loop;
  end;
  

  procedure exec(p_sys_user_reminder_msg_id in number) as
    v_action ven_sys_user_reminder_msg.action%type;
  begin
    v_sys_user_reminder_msg_id := p_sys_user_reminder_msg_id;
  
    select surm.sys_user_id, surm.reminder_id, surm.action 
    into v_sys_user_id, v_reminder_id, v_action
    from ven_sys_user_reminder_msg surm
    where surm.sys_user_reminder_msg_id = v_sys_user_reminder_msg_id;
    
    execute immediate v_action;
  end;

  
  function is_sys_user_reminder(p_sys_user_id in number default null) return boolean as
    v number(1);
  begin
    set_sys_user_id(p_sys_user_id);
    select 1 into v
    from ven_sys_user_reminder sur
    where sur.sys_user_id = v_sys_user_id and rownum = 1;
    return true;
  exception
    when no_data_found then
      return false;
    when others then
      raise;  
  end;  

  
  function is_sys_user_reminder_msg(p_sys_user_id in number default null) return boolean as
    v number(1);
  begin
    set_sys_user_id(p_sys_user_id);  
    select 1 into v
    from ven_sys_user_reminder_msg surm
    where surm.sys_user_id = v_sys_user_id and surm.is_skip = 0 and rownum = 1;
    return true;
  exception
    when no_data_found then
      return false;
    when others then
      raise;  
  end;  
  
end;
/
