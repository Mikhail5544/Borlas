CREATE OR REPLACE FUNCTION get_plan_acc_date(p_acc_id NUMBER) RETURN DATE IS
	    v_months_cnt NUMBER;
		v_num_of_payments NUMBER;
		v_first_pay_date DATE;
		v_pol_id NUMBER;
		v_pt_brief VARCHAR2(100);
		v_due_date DATE;
		v_months_diff NUMBER;
		v_years NUMBER;
		v_months NUMBER;
   BEGIN
		 -- Получаю полис
	BEGIN
	  SELECT dd.PARENT_ID, ap.due_date INTO v_pol_id, v_due_date
	  		 FROM DOC_DOC dd,
			 	  		DOCUMENT d,
						DOC_TEMPL dt,
						AC_PAYMENT ap
			WHERE dd.CHILD_ID = p_acc_id
				  AND  dd.parent_id = d.DOCUMENT_ID
				  AND d.DOC_TEMPL_ID = dt.DOC_TEMPL_ID
				  AND dt.BRIEF='POLICY'
				  AND ap.payment_id= p_acc_id;
	  EXCEPTION WHEN NO_DATA_FOUND THEN
	  		RETURN NULL;
	  END;
		-- Получаю кол-во платежей в году и дату первого платежа
	  SELECT pt.number_of_payments,
	  		 	  p.FIRST_PAY_DATE,
				  pt.BRIEF
		INTO v_num_of_payments,
		        v_first_pay_date,
				v_pt_brief
		FROM T_PAYMENT_TERMS pt, P_POLICY p
	   WHERE p.policy_id=v_pol_id
	   		 AND pt.ID(+) = p.PAYMENT_TERM_ID;

	   IF NVL(v_pt_brief,'?')='Единовременно' THEN	RETURN v_first_pay_date;
	   ELSE
	   	   IF v_num_of_payments IS NULL THEN
		   	  RAISE_APPLICATION_ERROR(-20100, 'Количество платежей в год не задано. p_policy_id= '||v_pol_id);
		   END IF;
		   v_due_date:= TRUNC(v_due_date,'DD');
		   v_first_pay_date:=	TRUNC(v_first_pay_date, 'DD');
		   IF v_due_date<v_first_pay_date  THEN
		   	  RETURN v_first_pay_date;
		   END IF;
		   v_months_diff:= MONTHS_BETWEEN(v_due_date, v_first_pay_date);
		   -- сколько целых лет между датами
		   v_years:= TRUNC(v_months_diff/12);
		   -- сколько целых периодов оплаты от начала страхового года до даты счета
		   v_months:= TRUNC( MOD(v_months_diff, 12)/ (12/v_num_of_payments));
		   RETURN ADD_MONTHS( ADD_MONTHS(v_first_pay_date,12*v_years), (12/v_num_of_payments)*v_months);
	   END IF;
   END;
/

