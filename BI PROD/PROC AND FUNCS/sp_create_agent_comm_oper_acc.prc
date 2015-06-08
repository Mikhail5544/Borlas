CREATE OR REPLACE PROCEDURE Sp_Create_Agent_Comm_Oper_Acc IS
	   v_st NUMBER;
	   v_key NUMBER;
	   v_comm_amt NUMBER;
	   v_msfo_comm_oper_id NUMBER;
	   v_rez VARCHAR2(1000);
	   v_type VARCHAR2(1000);
	   v_res_id NUMBER;
   	   v_cnt NUMBER:=0;
BEGIN
 SELECT ot.oper_templ_id
   INTO v_msfo_comm_oper_id
   FROM OPER_TEMPL ot
  WHERE ot.brief = 'МСФОВознаграждениеНачисленоСч';
 -- Цикл по всем операциям начисления премии по счету, у которых нет агентских начислений
 FOR msfo_prem_trans_pol IN (SELECT t.*,pc.start_date,o.doc_status_ref_id,o.DOCUMENT_ID FROM OPER o, TRANS t, OPER_TEMPL ot, P_COVER pc WHERE
 	 					 					 	  	 	   t.OPER_ID = o.OPER_ID
												   AND o.OPER_TEMPL_ID = ot.OPER_TEMPL_ID
												   AND ot.BRIEF= 'МСФОПремияНачисленаСчет'
												   AND pc.P_COVER_ID =  t.A5_CT_URO_ID
												   AND o.document_ID NOT IN (SELECT oo.DOCUMENT_ID FROM OPER oo,OPER_TEMPL ott WHERE
																								   		  oo.OPER_TEMPL_ID = ott.OPER_TEMPL_ID
																								  AND  ott.BRIEF='МСФОВознаграждениеНачисленоСч')) LOOP
		v_rez:=0;
		v_type:= NULL;
  		dbms_output.put_line('По договору нет начислений комиссии: policy_id='||msfo_prem_trans_pol.A2_CT_URO_ID||' риск: '||msfo_prem_trans_pol.A4_CT_URO_ID);
		FOR ag IN (SELECT  pa.* FROM p_policy_agent pa, p_policy p,policy_agent_status pas WHERE
			   	  		   			 p.POLICY_ID = msfo_prem_trans_pol.A2_CT_URO_ID
							AND    p.POL_HEADER_ID = pa.POLICY_HEADER_ID
							AND   pa.STATUS_ID=pas.POLICY_AGENT_STATUS_ID
							AND    pas.BRIEF='CURRENT'
							AND NOT EXISTS (SELECT '1'   FROM ven_p_policy_agent_com pc
                            WHERE pc.p_policy_agent_id=pa.p_policy_agent_id)) LOOP
				dbms_output.put_line('По действующему агентy нет ставок: '||ag.P_POLICY_AGENT_ID||'.Попытка создания...');
				v_rez:=Pkg_Agent_1.define_agent_prod_line(ag.p_policy_agent_id, ag.ag_contract_header_id);
			    IF    v_rez = 0 THEN v_rez:=Pkg_Agent_1.check_defined_commission(ag.p_policy_agent_id, ag.ag_contract_header_id);
    			ELSIF v_rez = 1 THEN v_type:='Не определен продукт по полиси ';
    			ELSIF v_rez = 2 THEN v_type:='Невозможно удалить существующие Ставки КВ по агенту по договору ';
    			ELSIF v_rez = 3 THEN v_type:='Ошибка: при записи данных по новым Ставкам КВ в базу.';
    			ELSE  v_type:=SQLERRM(v_rez);
    			END IF;
    			IF    v_type='OK' AND  v_rez < 0 THEN
        			  v_type:='Ошибка при определении страховой программы:'||SQLERRM(v_rez);
    			ELSIF v_type='OK' AND  v_rez > 0 THEN
        			  v_type:='Не определены ставки комиссионного вознаграждения для '||v_rez||' программ';
    			END IF;
				IF v_rez!=0 THEN
				 dbms_output.put_line(v_type);
				END IF;
		END LOOP;
        FOR arec IN
            (SELECT ppac.ent_id,
                    	   ppac.p_policy_agent_com_id,
						   plo.description
             FROM   P_POLICY p,
                    P_POLICY_AGENT ppa,
                    P_POLICY_AGENT_COM ppac,
					t_prod_line_option plo
             WHERE  p.policy_id = msfo_prem_trans_pol.A2_CT_URO_ID AND
                    p.pol_header_id = ppa.policy_header_id AND
                    ppa.p_policy_agent_id = ppac.p_policy_agent_id AND
                    ppac.t_product_line_id = plo.PRODUCT_LINE_ID AND
					plo.ID =  msfo_prem_trans_pol.A4_CT_URO_ID AND
					v_rez=0)
		LOOP
		  Pkg_Agent_Rate.DATE_PAY := TO_CHAR(msfo_prem_trans_pol.start_date, 'dd.mm.yyyy');
          Pkg_Agent_Rate.av_oav_pol_ag_com(arec.p_policy_agent_com_id, Pkg_Agent_Rate.DATE_PAY, v_st, v_key);
		  IF NVL(v_st,0)=0 THEN
		  	 dbms_output.put_line('Рассчитанное вознаграждение =0 agent_comm_id= '|| arec.p_policy_agent_com_id||' '||arec.description||' '||msfo_prem_trans_pol.start_date);
		  END IF;
          IF v_key = 0 THEN
            v_comm_Amt := ROUND(msfo_prem_trans_pol.trans_amount * v_st/100, 2);
          ELSE
            v_comm_amt := v_st;
          END IF;
          IF v_comm_amt <> 0 THEN
		  		  dbms_output.put_line('Формирование начисления агентской комиссии policy_id='||msfo_prem_trans_pol.A2_CT_URO_ID);

            	  v_res_id := Acc_New.Run_Oper_By_Template(v_msfo_comm_oper_id,
                                                     msfo_prem_trans_pol.DOCUMENT_ID,
                                                     arec.ent_id,
                                                     arec.p_policy_agent_com_id,
                                                     msfo_prem_trans_pol.doc_status_ref_id,
                                                     1,
                                                     v_comm_amt);

					IF v_res_id=0 THEN
							dbms_output.put_line('Не сформировано начисление агентской комиссии policy_id='||msfo_prem_trans_pol.A2_CT_URO_ID);
					ELSE
							v_cnt:= v_cnt+1;
							dbms_output.put_line('Сформировано начисление агентской комиссии policy_id='||msfo_prem_trans_pol.A2_CT_URO_ID);
					END IF;
          END IF;
        END LOOP;
 END LOOP;
  dbms_output.put_line('Всего создано операций: '||v_cnt);
END;
/

