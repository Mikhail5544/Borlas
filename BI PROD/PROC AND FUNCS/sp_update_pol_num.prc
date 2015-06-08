CREATE OR REPLACE PROCEDURE Sp_Update_Pol_Num(p_pol_header_id NUMBER,p_pol_num VARCHAR2, p_pol_ser VARCHAR2) IS
 v_pos NUMBER;
 v_num VARCHAR2(100);
 v_ph_num VARCHAR2(100);
 p_ser varchar2(5);
 p_num varchar2(10);
 p_id number;
 CURSOR c1 IS (select vv.pol_ser, vv.pol_num, vv.policy_id
               from ven_p_policy vv
               where vv.pol_header_id = p_pol_header_id);
 BEGIN
 
  ------добавлено 15.01.2008


   OPEN c1;
   LOOP
      FETCH c1 INTO p_ser, p_num, p_id;
      EXIT WHEN c1%NOTFOUND;
      Sp_Insert_Object_History('p_policy','pol_num',p_id, nvl(p_ser,'')||nvl(p_num,'null'),nvl(p_pol_ser,'')||nvl(p_pol_num,'null'),'veselek','Заявка по изменению номера полиса');
   END LOOP;
   CLOSE c1;


 Sp_Insert_Object_History('document','num',p_pol_header_id,nvl(p_ser,'')||nvl(p_num,'null'),nvl(p_pol_ser,'')||nvl(p_pol_num,'null'),'veselek','Заявка по изменению номера полиса');
 
 ---------------
 	UPDATE ven_p_policy SET pol_ser = p_pol_ser,
	  		 			  	  		  		   pol_num = p_pol_num
									WHERE pol_header_id = p_pol_header_id;
	SELECT num INTO v_ph_num FROM ven_p_pol_header
		   WHERE policy_header_id = p_pol_header_id;
	FOR  dc IN (SELECT d.document_id, d.NUM FROM document d, doc_templ dt WHERE d.DOCUMENT_ID IN
	  		 (SELECT dd.CHILD_ID FROM doc_doc dd, doc_templ dt
			 		 WHERE 	dd.PARENT_ID IN (SELECT policy_id FROM 	 p_policy
																	WHERE pol_header_id = 	p_pol_header_id))
																		  AND dt.DOC_TEMPL_ID = d.DOC_TEMPL_ID
																		  AND dt.BRIEF IN ('PAYMENT', 'PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC')) LOOP
		IF dc.num IS NOT NULL THEN
				v_pos:= INSTR(dc.num, '/');
				IF NVL(v_pos,0)>0 THEN
				   v_num:= SUBSTR(dc.num, v_pos);
				   UPDATE document SET num=v_ph_num||v_num WHERE document_id = dc.document_id;
				END IF;
		END IF;
	 END LOOP;
 END;
/

