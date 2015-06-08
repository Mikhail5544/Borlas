CREATE OR REPLACE PACKAGE pkg_pol_cash_surr_method IS
  FUNCTION load_a_z(p_p_policy_id IN NUMBER) RETURN NUMBER;
  FUNCTION metod_f_t(p_p_policy_id IN NUMBER) RETURN NUMBER;
  PROCEDURE recalccashsurrmethod(p_policy_id NUMBER);
  PROCEDURE set_metod_f_t
  (
    p_p_policy_id IN NUMBER
   ,p_metod_id    IN NUMBER
  );
  /*Процедура возвращает номер годовщины договора страхования. Используется на форме Выкупных сумм,
   а также в отчетах. Сделано по заявке 218537: поправка шаблона доп. соглашения об индексации
   @autor Чирков В.Ю.
   @param par_policy_header_id - id заголовка ДС
   @param par_insurance_year_date - Дата очередной годовщины страхового полиса
  */

  FUNCTION get_insurance_year_date
  (
    par_policy_header_id    NUMBER
   ,par_insurance_year_date DATE
  ) RETURN NUMBER;
END;
/
CREATE OR REPLACE PACKAGE BODY pkg_pol_cash_surr_method IS
  FUNCTION load_a_z(p_p_policy_id IN NUMBER) RETURN NUMBER IS
  
    /*  cursor c_a_z is
    select method_id
    from INS.POL_CASH_SURR_METHOD
    where POLICY_ID = p_p_policy_id;*/
  
    /*   cursor c_a_z as
    select PP.CASH_SURR_METHOD_ID into l_method  from P_POLICY pp where PP.POLICY_ID = p_p_policy_id;*/
  
    l_method     NUMBER(1);
    l_start_date DATE;
    RESULT       NUMBER;
  
  BEGIN
    /*open c_a_z;
    fetch c_a_z into l_method;
    IF c_a_z%notfound THEN
      select
        start_date
        into l_start_date
      FROM INS.P_POL_HEADER ph where policy_header_id in (select pol_header_id from ins.p_policy pp
                                                      where pp.policy_id  = p_p_policy_id);*/
  
    /*
    
    IF l_start_date <= to_date ('01.01.2007', 'dd.mm.yyyy') THEN
      l_method := 0;
    ELSIF l_start_date <= to_date ('01.01.2008', 'dd.mm.yyyy') THEN
      l_method := 1;
    ELSIF l_start_date <= to_date ('01.02.2009', 'dd.mm.yyyy') THEN
      l_method := 2;
    END IF;
    
    INSERT INTO INS.VEN_POL_CASH_SURR_METHOD (POLICY_ID, METHOD_ID) VALUES (P_P_POLICY_ID, l_method);
    */
  
    SELECT pp.cash_surr_method_id INTO l_method FROM p_policy pp WHERE pp.policy_id = p_p_policy_id;
  
    --END IF;
  
    IF l_method = 0
    THEN
      RESULT := 0.03;
    ELSIF l_method = 1
    THEN
      RESULT := 0.04;
    ELSIF l_method = 2
    THEN
      RESULT := 0.04;
    END IF;
  
    RETURN RESULT;
  
  END;
  FUNCTION metod_f_t(p_p_policy_id IN NUMBER) RETURN NUMBER IS
    /*cursor c_a_z is
    select method_id
    from INS.POL_CASH_SURR_METHOD
    where POLICY_ID = p_p_policy_id;*/
  
    l_method     NUMBER(1);
    l_start_date DATE;
  
  BEGIN
    /* open c_a_z;
    fetch c_a_z into l_method;
    
    IF c_a_z%notfound THEN
      select
        start_date
        into l_start_date
      FROM INS.P_POL_HEADER ph where policy_header_id in (select pol_header_id from ins.p_policy pp
                                                      where pp.policy_id  = p_p_policy_id);*/
  
    /*  IF l_start_date <= to_date ('01.01.2007', 'dd.mm.yyyy') THEN
      l_method := 0;
    ELSIF l_start_date <= to_date ('01.01.2008', 'dd.mm.yyyy') THEN
      l_method := 1;
    ELSIF l_start_date <= to_date ('01.02.2009', 'dd.mm.yyyy') THEN
      l_method := 2;
    END IF;
    
    INSERT INTO INS.VEN_POL_CASH_SURR_METHOD (POLICY_ID, METHOD_ID) VALUES (P_P_POLICY_ID, l_method);
    */
  
    SELECT pp.cash_surr_method_id INTO l_method FROM p_policy pp WHERE pp.policy_id = p_p_policy_id;
  
    --  END IF;
  
    RETURN l_method;
  
  END;

  PROCEDURE recalccashsurrmethod(p_policy_id NUMBER) IS
    rec_doc_procedure doc_procedure%ROWTYPE;
  BEGIN
  
    IF (safety.check_right_custom('CSR_POLCASHSURR_CALC') = 0)
    THEN
      raise_application_error(-20000
                             ,'У вас не хватает прав для перерасчета выкупных сумм.');
    END IF;
  
    reserve.pkg_reserve_r_life.drop_reserve_for_policy(p_policy_id);
  
    FOR i IN (SELECT dp.*
                FROM ven_doc_procedure dp
               WHERE dp.name = 'Расчет резервов по договору')
    LOOP
      rec_doc_procedure := i;
    END LOOP;
  
    EXECUTE IMMEDIATE 'BEGIN ' || rec_doc_procedure.proc_name || '(:p_policy_id); END;'
      USING IN p_policy_id;
  
    FOR i IN (SELECT dp.*
                FROM ven_doc_procedure dp
               WHERE dp.name = 'Расчет выкупных сумм по версии договора страхования')
    LOOP
      rec_doc_procedure := i;
    END LOOP;
  
    EXECUTE IMMEDIATE 'BEGIN ' || rec_doc_procedure.proc_name || '(:p_policy_id); END;'
      USING IN p_policy_id;
  
  END recalccashsurrmethod;

  PROCEDURE set_metod_f_t
  (
    p_p_policy_id IN NUMBER
   ,p_metod_id    IN NUMBER
  ) IS
  BEGIN
    UPDATE p_policy SET cash_surr_method_id = p_metod_id WHERE policy_id = p_p_policy_id;
  END;

  /*Процедура возвращает номер годовщины договора страхования. Используется на форме Выкупных сумм,
   а также в отчетах. Сделано по заявке 218537: поправка шаблона доп. соглашения об индексации
   @autor Чирков В.Ю.
   @param par_policy_header_id - id заголовка ДС
   @param par_insurance_year_date - Дата очередной годовщины страхового полиса
  */

  FUNCTION get_insurance_year_date
  (
    par_policy_header_id    NUMBER
   ,par_insurance_year_date DATE
  ) RETURN NUMBER AS
    v_insurance_year_date NUMBER;
  BEGIN
    SELECT CASE
             WHEN pr.brief IN ('Family_Dep', 'Family_Dep_2011', 'Family_Dep_2014') THEN
              MONTHS_BETWEEN(par_insurance_year_date, ph.start_date) / 12
             ELSE
              MONTHS_BETWEEN(par_insurance_year_date, ph.start_date) / 12 + 1
           END
      INTO v_insurance_year_date
      FROM ins.p_pol_header ph
          ,t_product        pr
     WHERE ph.policy_header_id = par_policy_header_id
       AND ph.product_id = pr.product_id;
  
    RETURN v_insurance_year_date;
  END get_insurance_year_date;

END;
/
