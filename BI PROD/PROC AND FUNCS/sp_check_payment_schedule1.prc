CREATE OR REPLACE PROCEDURE Sp_Check_Payment_Schedule1 IS
  v_plan_date DATE;
  v_next_plan_date DATE;
  v_order_num NUMBER;
  v_fee_sum NUMBER;
  v_all_sum NUMBER:=0;
  v_main_pl_start_date DATE;
  v_main_pl_end_date DATE;
  v_adm_cost_cover P_COVER%ROWTYPE;
  v_payment_term T_PAYMENT_TERMS%ROWTYPE;
  v_acc_sum NUMBER;
  v_acc_cnt NUMBER;
  v_err_cnt NUMBER;
  v_all_cnt_sum NUMBER:=0;
  v_first_acc_sum NUMBER;
  v_ok_cnt NUMBER:=0;
  p_pol_id NUMBER;
 BEGIN
   v_err_cnt:=0;
  FOR v_policy IN (SELECT p.* FROM P_POLICY p,
 	 	   	  		  	  	   			 		   P_POL_HEADER ph
									WHERE ph.policy_id = p.policy_id
										  	AND Doc.get_last_doc_status_brief(p.policy_id) IN ('NEW', 'CURRENT') ) LOOP
   p_pol_id := v_policy.policy_id;

   SELECT *  INTO v_payment_term FROM T_PAYMENT_TERMS WHERE id = v_policy.payment_term_id;
   IF v_payment_term.is_periodical=0  THEN
    -- Единовременно
	   SELECT NVL( SUM(pc.PREMIUM) ,0) INTO v_fee_sum
				     		  FROM P_COVER pc, AS_ASSET a
   		  					  WHERE a.P_POLICY_ID=p_pol_id
		  					  		AND pc.AS_ASSET_ID = a.AS_ASSET_ID;

				FOR acp IN (SELECT	ap.*
						   			FROM VEN_AC_PAYMENT ap,
							 	  DOC_DOC dd,
								  DOC_TEMPL dt
						WHERE ap.DUE_DATE>=v_plan_date
							  AND  ap.DUE_DATE<v_next_plan_date
							  AND ap.DUE_DATE<=SYSDATE
							  AND ap.PAYMENT_ID = dd.CHILD_ID
							  AND  dd.PARENT_ID=p_pol_id
							  AND ap.DOC_TEMPL_ID = dt.DOC_TEMPL_ID
							  AND dt.BRIEF='PAYMENT'
							  AND NVL(ap.AMOUNT,0)<>0
							  AND Doc.get_last_doc_status_brief(ap.payment_id)='NEW') LOOP
							  IF acp.amount<>v_fee_sum THEN
							   v_err_cnt:=							   v_err_cnt+1;
							   INSERT INTO xx_acc_migr_log(policy_id, acc_id, error, pol_num) VALUES(p_pol_id,acp.payment_id,'NOT_TO_PAY',v_policy.pol_num);
							   COMMIT;
							  ELSE
							   v_ok_cnt:=							   v_ok_cnt+1;
							   
							   INSERT INTO xx_acc_migr_log(policy_id, acc_id, error, pol_num) VALUES(p_pol_id,acp.payment_id,'TO_PAY',v_policy.pol_num);
							   COMMIT;
							  END IF;
					END LOOP;
   ELSE
      v_fee_sum:= 0;
	  v_order_num:= 0;
	  v_plan_date:= TRUNC(v_policy.first_pay_date,'DD');
   	  WHILE v_plan_date< ADD_MONTHS(TRUNC(v_policy.first_pay_date,'DD'), v_policy.fee_payment_term*12 ) LOOP
	  	  	      v_next_plan_date:= ADD_MONTHS(v_plan_date, 12/v_payment_term.number_of_payments);
			  	  v_order_num:=	  v_order_num+1;
				  IF v_order_num>v_payment_term.number_of_payments THEN
				  	 			v_order_num:=	1;
				  END IF;
				  SELECT NVL( SUM(pc.fee) ,0) INTO v_fee_sum
				     		  FROM P_COVER pc, AS_ASSET a,T_PROD_LINE_OPTION plo, T_PRODUCT_LINE pl
   		  					  WHERE a.P_POLICY_ID=p_pol_id
		  					  		AND pc.AS_ASSET_ID = a.AS_ASSET_ID
									AND  pc.T_PROD_LINE_OPTION_ID = plo.ID
									AND pc.START_DATE<=v_plan_date
									AND pc.END_DATE>v_plan_date
									AND plo.PRODUCT_LINE_ID = pl.ID
									AND (NVL(pl.BRIEF,'?')!='ADMIN_EXPENCES' OR v_order_num=1);

				FOR acp IN (SELECT	ap.*
						   			FROM VEN_AC_PAYMENT ap,
							 	  DOC_DOC dd,
								  DOC_TEMPL dt
						WHERE ap.DUE_DATE>=v_plan_date
							  AND  ap.DUE_DATE<v_next_plan_date
							  AND ap.DUE_DATE<=SYSDATE
							  AND ap.PAYMENT_ID = dd.CHILD_ID
							  AND  dd.PARENT_ID=p_pol_id
							  AND ap.DOC_TEMPL_ID = dt.DOC_TEMPL_ID
							  AND dt.BRIEF='PAYMENT'
							  AND NVL(ap.AMOUNT,0)<>0
							  AND Doc.get_last_doc_status_brief(ap.payment_id)='NEW') LOOP
							  IF acp.amount<>v_fee_sum THEN
							   v_err_cnt:=							   v_err_cnt+1;
							   IF (acp.amount+300 = v_fee_sum)OR(acp.amount-300 = v_fee_sum) THEN
							   	   INSERT INTO xx_acc_migr_log(policy_id, acc_id, error, pol_num) VALUES(p_pol_id,acp.payment_id,'NOT_TO_PAY_ADMIN_COST',v_policy.pol_num);
							   	   COMMIT;
							   ELSE
							   	   INSERT INTO xx_acc_migr_log(policy_id, acc_id, error, pol_num) VALUES(p_pol_id,acp.payment_id,'NOT_TO_PAY1',v_policy.pol_num);
							   	   COMMIT;
							   END IF;   
							  ELSE
							   v_ok_cnt:=							   v_ok_cnt+1;
/*
							   Doc.set_doc_status(p_doc_id=>acp.payment_id,
							   								 p_status_brief=>'TO_PAY',
															 p_note=>'Sp_Check_Payment_Schedule1');
*/								
							   INSERT INTO xx_acc_migr_log(policy_id, acc_id, error, pol_num) VALUES(p_pol_id,acp.payment_id,'TO_PAY1',v_policy.pol_num);
							   COMMIT;
							  END IF;
					END LOOP;
				 v_plan_date:= v_next_plan_date;
	  END LOOP;
   END IF;
   END LOOP;
   dbms_output.put_line(v_err_cnt||' '||v_ok_cnt);
 END;
/

