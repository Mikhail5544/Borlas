CREATE OR REPLACE PROCEDURE sp_gen_form_item_script(p_form_name VARCHAR2,
	   	  		  											 		  					  p_item_name VARCHAR2) IS
    v_str VARCHAR2(2000);
	BEGIN
	 FOR fi IN (SELECT ffi.* FROM FORM_ITEM ffi WHERE LOWER(ffi.item_name) = LOWER(p_item_name)
	 	 	   		   			 		   		 				  		 AND  LOWER(ffi.form_name)=LOWER(p_form_name)) LOOP
				FOR fis IN (SELECT ffis.* FROM FORM_ITEM_STATUS ffis WHERE ffis.form_item_id= fi.form_item_id) LOOP
					v_str:= '            sp_add_form_item_info(p_form_name =>'''||p_form_name||'''';
					dbms_output.put_line(v_str);
					v_str:= '                                 '||',p_item_name =>'''||p_item_name||'''';
					dbms_output.put_line(v_str);
					IF fi.is_block IS NOT NULL THEN
										v_str:= '                                 '||',p_is_block=>'||fi.is_block;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.is_vis IS NOT NULL THEN
										v_str:= '                                 '||',p_def_is_vis=>'||fi.is_vis;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.is_ia IS NOT NULL THEN
										v_str:= '                                 '||',p_def_is_ia=>'||fi.is_ia;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.is_ua IS NOT NULL THEN
										v_str:= '                                 '||',p_def_is_ua=>'||fi.is_ua;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.is_da IS NOT NULL THEN
										v_str:= '                                 '||',p_def_is_da=>'||fi.is_da;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.is_req IS NOT NULL THEN
										v_str:= '                                 '||',p_def_is_req=>'||fi.is_req;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.is_en IS NOT NULL THEN
										v_str:= '                                 '||',p_def_is_en=>'||fi.is_en;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.width IS NOT NULL THEN
										v_str:= '                                 '||',p_def_width=>'||fi.width;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.prompt IS NOT NULL THEN
										v_str:= '                                 '||',p_def_prompt=>'''||fi.prompt||'''';
										dbms_output.put_line(v_str);
					END IF;
					IF fis.is_vis IS NOT NULL THEN
										v_str:= '                                 '||',p_is_vis=>'||fis.is_vis;
										dbms_output.put_line(v_str);
					END IF;
					IF fis.is_ia IS NOT NULL THEN
										v_str:= '                                 '||',p_is_ia=>'||fis.is_ia;
										dbms_output.put_line(v_str);
					END IF;
					IF fis.is_ua IS NOT NULL THEN
										v_str:= '                                 '||',p_is_ua=>'||fis.is_ua;
										dbms_output.put_line(v_str);
					END IF;
					IF fis.is_da IS NOT NULL THEN
										v_str:= '                                 '||',p_is_da=>'||fis.is_da;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.is_block IS NOT NULL THEN
										v_str:='                                 '|| ',p_is_req=>'||fis.is_req;
										dbms_output.put_line(v_str);
					END IF;
					IF fis.is_en IS NOT NULL THEN
										v_str:='                                 '||',p_is_en=>'||fis.is_en;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.width IS NOT NULL THEN
										v_str:='                                 '|| ',p_width=>'||fi.width;
										dbms_output.put_line(v_str);
					END IF;
					IF fis.prompt IS NOT NULL THEN
										v_str:= '                                 '||',p_prompt=>'''||fis.prompt||'''';
										dbms_output.put_line(v_str);
					END IF;
					IF fis.id1 IS NOT NULL THEN
										v_str:='                                 '|| ',p_id1=>'''||fis.id1||'''';
										dbms_output.put_line(v_str);
					END IF;
					IF fis.id2 IS NOT NULL THEN
										v_str:='                                 '|| ',p_id2=>'''||fis.id2||'''';
										dbms_output.put_line(v_str);
					END IF;
					IF fis.id3 IS NOT NULL THEN
										v_str:='                                 '|| ',p_id3=>'''||fis.id3||'''';
										dbms_output.put_line(v_str);
					END IF;
					IF fis.field1 IS NOT NULL THEN
										v_str:='                                 '|| ',p_val1=>'''||fis.field1||'''';
										dbms_output.put_line(v_str);
					END IF;
					IF fis.field2 IS NOT NULL THEN
										v_str:='                                 '|| ',p_val2=>'''||fis.field2||'''';
										dbms_output.put_line(v_str);
					END IF;
					IF fis.field3 IS NOT NULL THEN
										v_str:='                                 '|| ',p_val3=>'''||fis.field3||'''';
										dbms_output.put_line(v_str);
					END IF;
					IF fis.seq_order IS NOT NULL THEN
										v_str:='                                 '|| ',p_seq_order=>'||fis.seq_order;
										dbms_output.put_line(v_str);
					END IF;
					IF fis.full_width IS NOT NULL THEN
					   					v_str:= '                                 '||',p_full_width=>'||fis.full_width;
										dbms_output.put_line(v_str);
					END IF;
					IF fis.is_manual_position IS NOT NULL THEN
										v_str:='                                 '|| ',p_is_manual_pos=>'||fis.is_manual_position;
										dbms_output.put_line(v_str);
					END IF;
					IF fi.element_type IS NOT NULL THEN
										v_str:='                                 '|| ',p_element_type=>'''||fi.element_type||'''';
										dbms_output.put_line(v_str);
					END IF;
					v_str:= '                                 '||');';
					dbms_output.put_line(v_str);
				END LOOP;
	 END LOOP;
	END;
/

