CREATE OR REPLACE PROCEDURE av_insert_report_cont_vadim
  				(p_oav                   IN NUMBER --сумма комиссии
                                 ,p_agent_report_id       IN NUMBER -- ИД акта
                                 ,p_is_deduct             IN NUMBER DEFAULT 0 --c удержанием/без
                                 ,policy_agent_com_id     IN NUMBER,
                                  p_trans_id              IN NUMBER -- номер транзакции
                                 ,p_ag_type_rate_value_id IN NUMBER,
                                  p_part_agent            IN NUMBER,
                                  p_sav                   IN NUMBER,
                                  p_policy_id             IN NUMBER,
                                  p_day_pay               IN DATE,
                                  p_sum_premium           IN NUMBER,
                                  p_sum_return            IN NUMBER,
                                  p_mlead_id              IN NUMBER,
                                  p_err_code              OUT NUMBER)

   IS
    v_report_cont AGENT_REPORT_CONT%ROWTYPE;
  BEGIN
    SELECT sq_agent_report_cont.NEXTVAL
      INTO v_report_cont.agent_report_cont_id
      FROM dual;

    INSERT INTO ven_agent_report_cont
      (agent_report_cont_id,
       agent_report_id,
       ag_type_rate_value_id,
       comission_sum,
       date_pay,
       is_deduct,
       part_agent,
       policy_id,
       p_policy_agent_com_id,
       sav,
       sum_premium,
       sum_return,
       trans_id,
       mlead_id)
    VALUES
      (v_report_cont.agent_report_cont_id,
       p_agent_report_id,
       p_ag_type_rate_value_id,
       p_oav,
       p_day_pay,
       p_is_deduct,
       p_part_agent,
       p_policy_id,
       policy_agent_com_id,
       p_sav,
       p_sum_premium,
       p_sum_return,
       p_trans_id,
       p_mlead_id);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,
                              'Ошибка вставки в таблицу agent_report_cont.См. ошибку Oracle:' ||
                              SQLERRM(SQLCODE));

  END;
/

