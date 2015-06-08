CREATE OR REPLACE PROCEDURE 
           sp_add_form_item_info(p_form_name VARCHAR2,
                             p_item_name VARCHAR2,
                          p_is_block NUMBER DEFAULT 0,
                          p_def_is_vis NUMBER DEFAULT 0,
                          p_def_is_ia NUMBER DEFAULT NULL,
                          p_def_is_ua NUMBER DEFAULT NULL,
                          p_def_is_da NUMBER DEFAULT NULL,
                          p_def_is_req NUMBER DEFAULT NULL,
                          p_def_is_en NUMBER DEFAULT NULL,
                          p_def_width NUMBER DEFAULT NULL,
                          p_def_prompt VARCHAR2 DEFAULT NULL,
                          p_is_vis NUMBER DEFAULT 0,
                          p_is_ia NUMBER DEFAULT NULL,
                          p_is_ua NUMBER DEFAULT NULL,
                          p_is_da NUMBER DEFAULT NULL,
                          p_is_req NUMBER DEFAULT NULL,
                          p_is_en NUMBER DEFAULT NULL,
                          p_width NUMBER DEFAULT NULL,
                          p_prompt VARCHAR2 DEFAULT NULL,
                          p_id1 VARCHAR2 DEFAULT NULL,
                          p_id2 VARCHAR2 DEFAULT NULL,
                          p_id3 VARCHAR2 DEFAULT NULL,
                          p_val1 VARCHAR2 DEFAULT NULL,
                          p_val2 VARCHAR2 DEFAULT NULL,
                          p_val3 VARCHAR2 DEFAULT NULL,
                          p_seq_order NUMBER DEFAULT NULL,
                          p_full_width NUMBER DEFAULT NULL,
                          p_is_manual_pos NUMBER DEFAULT NULL,
                          p_element_type VARCHAR2 DEFAULT NULL) IS
 v_form_item_id NUMBER;
 v_fis_id NUMBER;
BEGIN
  BEGIN
   SELECT form_item_id INTO v_form_item_id  FROM FORM_ITEM fi
           WHERE LOWER(fi.item_name) = LOWER(p_item_name) AND LOWER(fi.form_name) = LOWER(p_form_name)
          AND fi.form_item_id NOT IN (SELECT fis.form_item_id FROM FORM_ITEM_STATUS fis WHERE NVL(fis.is_new_rec,0)=0);

   UPDATE FORM_ITEM SET is_block = p_is_block,
                             is_vis = p_def_is_vis,
                        is_ia = p_def_is_ia,
                        is_ua = p_def_is_ua,
                        is_da = p_def_is_da,
                        is_req =p_def_is_req,
                        is_en = p_def_is_en,
                        width = p_def_width,
                        prompt = p_def_prompt,
                        element_type = p_element_type
            WHERE form_item_id = v_form_item_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
   SELECT sq_form_item.NEXTVAL INTO v_form_item_id FROM dual;
   INSERT INTO FORM_ITEM(form_item_id, form_name, item_name, is_vis, is_block, is_ia, is_ua, is_da, is_req, is_en, width, prompt, element_type)
    VALUES (v_form_item_id, p_form_name, p_item_name, p_def_is_vis,  p_is_block,  p_def_is_ia,  p_def_is_ua,  p_def_is_da,  p_def_is_req, p_def_is_en, p_def_width, p_def_prompt, p_element_type);
   WHEN TOO_MANY_ROWS THEN
    RAISE_APPLICATION_ERROR(-20100, 'Две записи в FORM_ITEM об элементе '||p_item_name||' на форме '||p_form_name);
  END;
  BEGIN
   SELECT form_item_status_id INTO v_fis_id  FROM FORM_ITEM_STATUS
           WHERE form_item_id = v_form_item_id
           AND NVL(id1,'nodatafound') = NVL(p_id1,'nodatafound')
           AND NVL(id2,'nodatafound') = NVL(p_id2,'nodatafound')
           AND NVL(id3,'nodatafound') = NVL(p_id3,'nodatafound')
           AND NVL(field1,'nodatafound') = NVL(p_val1,'nodatafound')
           AND NVL(field2,'nodatafound') = NVL(p_val2,'nodatafound')
           AND NVL(field3,'nodatafound') = NVL(p_val3,'nodatafound')
           AND is_new_rec = 1;
    UPDATE FORM_ITEM_STATUS SET
                           is_vis = p_is_vis,
                        is_ia = p_is_ia,
                        is_ua = p_is_ua,
                        is_da = p_is_da,
                        is_req =p_is_req,
                        is_en = p_is_en,
                        seq_order = p_seq_order,
                        full_width = p_full_width,
                        prompt = p_prompt,
                        is_manual_position = p_is_manual_pos,
                        width = p_width
          WHERE form_item_status_id = v_fis_id;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    SELECT sq_form_item_status.NEXTVAL INTO v_fis_id FROM dual;
    INSERT INTO FORM_ITEM_STATUS(
                           form_item_status_id,
                        form_item_id,
                           is_vis,
                        is_ia,
                        is_ua,
                        is_da,
                        is_req,
                        is_en,
                        seq_order,
                        full_width,
                        prompt,
                        id1,
                        id2,
                        id3,
                        field1,
                        field2,
                        field3,
                        is_new_rec,
                        is_manual_position,
                        width)
            VALUES(v_fis_id,
                   v_form_item_id,
                   p_is_vis,
                   p_is_ia,
                   p_is_ua,
                   p_is_da,
                   p_is_req,
                   p_is_en,
                   p_seq_order,
                   p_full_width,
                   p_prompt,
                   p_id1,
                   p_id2,
                   p_id3,
                   p_val1,
                   p_val2,
                   p_val3,
                   1,
                   p_is_manual_pos,
                   p_width);
  END;
END;
/

