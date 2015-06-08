CREATE OR REPLACE PACKAGE pkg_reminder_ins IS

  PROCEDURE policy_end_200;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_reminder_ins IS

  PROCEDURE policy_end_200 AS
    v_stop_date   ven_sys_user_reminder_msg.stop_date%TYPE DEFAULT SYSDATE + 200;
    v_reminder_id ven_reminder.reminder_id%TYPE;
    v_sys_user_id ven_sys_user.sys_user_id%TYPE;
  BEGIN
    v_reminder_id := pkg_reminder.v_reminder_id;
    v_sys_user_id := pkg_reminder.v_sys_user_id;
  
    FOR v_r IN (SELECT pp.pol_header_id
                      ,'Заканчивает действие полис ' || pp.pol_ser || '-' || pp.pol_num note
                  FROM p_policy pp
                 INNER JOIN p_pol_header pph
                    ON pph.policy_id = pp.policy_id
                 WHERE doc.get_doc_status_brief(pp.policy_id) = 'CURRENT'
                   AND pp.end_date >= SYSDATE
                   AND pp.end_date <= v_stop_date
                MINUS
                SELECT to_number(param)
                      ,note
                  FROM ven_sys_user_reminder_msg surm
                 WHERE surm.sys_user_id = v_sys_user_id
                   AND surm.reminder_id = v_reminder_id
                
                )
    LOOP
      INSERT INTO ven_sys_user_reminder_msg
        (sys_user_id, reminder_id, note, start_date, stop_date, action_type, action, param)
      VALUES
        (v_sys_user_id
        ,v_reminder_id
        ,v_r.note
        ,SYSDATE
        ,v_stop_date
        ,'FORM'
        ,'ACTION_POLICY_FORM'
        ,v_r.pol_header_id);
    END LOOP;
  END;

END;
/
