CREATE OR REPLACE PROCEDURE sp_correct_acc_analitic(p_acc_chart_brief VARCHAR2, p_acc_num VARCHAR2) IS
  v_acc_num VARCHAR2(100):= p_acc_num;
  v_acc_id NUMBER;

  v_val_cr_obj_id1 NUMBER;
  v_val_cr_ent_id1 NUMBER;
  v_val_cr_obj_id2 NUMBER;
  v_val_cr_ent_id2 NUMBER;
  v_val_cr_obj_id3 NUMBER;
  v_val_cr_ent_id3 NUMBER;
  v_val_cr_obj_id4 NUMBER;
  v_val_cr_ent_id4 NUMBER;
  v_val_cr_obj_id5 NUMBER;
  v_val_cr_ent_id5 NUMBER;

  v_val_dt_obj_id1 NUMBER;
  v_val_dt_ent_id1 NUMBER;
  v_val_dt_obj_id2 NUMBER;
  v_val_dt_ent_id2 NUMBER;
  v_val_dt_obj_id3 NUMBER;
  v_val_dt_ent_id3 NUMBER;
  v_val_dt_obj_id4 NUMBER;
  v_val_dt_ent_id4 NUMBER;
  v_val_dt_obj_id5 NUMBER;
  v_val_dt_ent_id5 NUMBER;

BEGIN
 SELECT a.account_id INTO v_acc_id FROM ACCOUNT a,
 					 	  		   				   				 ACC_CHART_TYPE ct
													WHERE a.num=v_acc_num
														  AND a.ACC_CHART_TYPE_ID = ct.ACC_CHART_TYPE_ID
														  AND  ct.BRIEF= p_acc_chart_brief;

 FOR op IN (SELECT o.* FROM OPER o) LOOP
 	 	 	 FOR t IN (SELECT tt.* FROM TRANS tt WHERE tt.OPER_ID = op.oper_id
			 	   	  		  	   			  	 	   			  		  AND (tt.CT_ACCOUNT_ID = v_acc_id
																		  OR tt.DT_ACCOUNT_ID = v_acc_id)) LOOP
			 	 Acc_New.Get_Analytic(p_account_id=>t.CT_ACCOUNT_ID,
				 									p_an_num=>1,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_cr_ent_id1,
													p_an_obj_id=>  v_val_cr_obj_id1);
			 	 Acc_New.Get_Analytic(p_account_id=>t.CT_ACCOUNT_ID,
				 									p_an_num=>2,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_cr_ent_id2,
													p_an_obj_id=>  v_val_cr_obj_id2);
			 	 Acc_New.Get_Analytic(p_account_id=>t.CT_ACCOUNT_ID,
				 									p_an_num=>3,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_cr_ent_id3,
													p_an_obj_id=>  v_val_cr_obj_id3);
			 	 Acc_New.Get_Analytic(p_account_id=>t.CT_ACCOUNT_ID,
				 									p_an_num=>4,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_cr_ent_id4,
													p_an_obj_id=>  v_val_cr_obj_id4);
			 	 Acc_New.Get_Analytic(p_account_id=>t.CT_ACCOUNT_ID,
				 									p_an_num=>5,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_cr_ent_id5,
													p_an_obj_id=>  v_val_cr_obj_id5);

			 	 Acc_New.Get_Analytic(p_account_id=>t.DT_ACCOUNT_ID,
				 									p_an_num=>1,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_dt_ent_id1,
													p_an_obj_id=>  v_val_dt_obj_id1);
			 	 Acc_New.Get_Analytic(p_account_id=>t.DT_ACCOUNT_ID,
				 									p_an_num=>2,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_dt_ent_id2,
													p_an_obj_id=>  v_val_dt_obj_id2);
			 	 Acc_New.Get_Analytic(p_account_id=>t.DT_ACCOUNT_ID,
				 									p_an_num=>3,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_dt_ent_id3,
													p_an_obj_id=>  v_val_dt_obj_id3);
			 	 Acc_New.Get_Analytic(p_account_id=>t.DT_ACCOUNT_ID,
				 									p_an_num=>4,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_dt_ent_id4,
													p_an_obj_id=>  v_val_dt_obj_id4);
			 	 Acc_New.Get_Analytic(p_account_id=>t.DT_ACCOUNT_ID,
				 									p_an_num=>5,
													p_service_ent_ID => t.OBJ_URE_ID,
                         							p_service_obj_id => t.OBJ_URO_ID,
                         							p_an_ent_id =>  v_val_dt_ent_id5,
													p_an_obj_id=>  v_val_dt_obj_id5);

				UPDATE TRANS tr SET
					   a1_dt_ure_id =v_val_dt_ent_id1,
					   a1_dt_uro_id=v_val_dt_obj_id1,
					   a2_dt_ure_id =v_val_dt_ent_id2,
					   a2_dt_uro_id=v_val_dt_obj_id2,
					   a3_dt_ure_id =v_val_dt_ent_id3,
					   a3_dt_uro_id=v_val_dt_obj_id3,
					   a4_dt_ure_id =v_val_dt_ent_id4,
					   a4_dt_uro_id=v_val_dt_obj_id4,
					   a5_dt_ure_id =v_val_dt_ent_id5,
					   a5_dt_uro_id=v_val_dt_obj_id5,

					   a1_ct_ure_id =v_val_cr_ent_id1,
					   a1_ct_uro_id=v_val_cr_obj_id1,
					   a2_ct_ure_id =v_val_cr_ent_id2,
					   a2_ct_uro_id=v_val_cr_obj_id2,
					   a3_ct_ure_id =v_val_cr_ent_id3,
					   a3_ct_uro_id=v_val_cr_obj_id3,
					   a4_ct_ure_id =v_val_cr_ent_id4,
					   a4_ct_uro_id=v_val_cr_obj_id4,
					   a5_ct_ure_id =v_val_cr_ent_id5,
					   a5_ct_uro_id=v_val_cr_obj_id5
				 WHERE tr.TRANS_ID = t.TRANS_ID;
			 END LOOP;
 END LOOP;
END;
/

