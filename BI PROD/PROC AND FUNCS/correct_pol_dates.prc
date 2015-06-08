CREATE OR REPLACE PROCEDURE Correct_Pol_Dates(p_pol_id NUMBER, p_new_start_date DATE) IS
		  v_months_cnt NUMBER;
		  v_one_sec NUMBER:= 1/3600/24;
      start_d date;
      end_d date;
      ppol number;
		  BEGIN
		  	SELECT CEIL(MONTHS_BETWEEN(end_date, start_date))
			  INTO v_months_cnt
			  FROM p_policy
			  WHERE policy_id = p_pol_id;

select pp.start_date, pp.end_date
into start_d, end_d
from p_policy pp
where pp.policy_id = p_pol_id;

			   UPDATE p_policy SET start_date = p_new_start_date,
			   		  		   	   			  	  end_date = ADD_MONTHS(p_new_start_date, v_months_cnt)-v_one_sec,
												  first_pay_date = p_new_start_date
											WHERE 	  		policy_id = p_pol_id;

sp_insert_object_history('p_policy','start_date',p_pol_id,to_char(start_d,'dd-mm-yyyy'),to_char(p_new_start_date,'dd-mm-yyyy'),'veselek','Изменение дат начала страхования');
sp_insert_object_history('p_policy','end_date',p_pol_id,to_char(end_d,'dd-mm-yyyy'),to_char(ADD_MONTHS(p_new_start_date, v_months_cnt)-v_one_sec,'dd-mm-yyyy'),'veselek','Изменение дат окончания страхования');

				UPDATE p_pol_header SET start_date =  p_new_start_date
					   				WHERE policy_header_id IN
									  (SELECT pol_header_id FROM p_policy
									  		  			WHERE policy_id=p_pol_id);
select pol_header_id
into ppol
from p_policy
where policy_id=p_pol_id;

sp_insert_object_history('p_pol_header','start_date',ppol,to_char(start_d,'dd-mm-yyyy'),to_char(p_new_start_date,'dd-mm-yyyy'),'veselek','Изменение дат начала страхования в шапке');

				FOR ass IN (SELECT ast.as_asset_id,
						   		   			    CEIL(MONTHS_BETWEEN(ast.end_date, ast.start_date)) mbas
										FROM as_asset ast
										WHERE ast.p_policy_id = p_pol_id) LOOP

				  UPDATE as_asset SET start_date = p_new_start_date,
				  		 	 	 			  	   	  end_date = ADD_MONTHS(p_new_start_date, ass.mbas)-v_one_sec
										WHERE as_asset_id = ass.as_asset_id;

			      FOR pcov IN (SELECT pc.p_cover_id,
			   	   		   		   				 CEIL(MONTHS_BETWEEN(pc.end_date, pc.start_date)) mbpc
										FROM p_cover pc
										WHERE pc.AS_ASSET_ID = ass.as_asset_id) LOOP

							  UPDATE p_cover SET start_date = p_new_start_date,
				  		 	 	 			  	   	  end_date = ADD_MONTHS(p_new_start_date, pcov.mbpc)-v_one_sec
										WHERE p_cover_id = pcov.p_cover_id;

				  END LOOP;
				 END LOOP;
		  END;
/

