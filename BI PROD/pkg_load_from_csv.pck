CREATE OR REPLACE PACKAGE pkg_load_from_csv AS
  /*
  * ������ � ����������, ������������ �� CSV-������ (����� � �����)
  * @author ��������� �.
  * @version 2
  * @headcom
  */

  /**
  * ��������� ��������� ������� ��� ����������� �� ��������� ������� ������� (�����) �� csv-�����
  * @author ��������� �.
  * @param p_session_id ID ������ ������������ ���������� ���� ������ ��������� � ������� ���������
  */
  PROCEDURE update_casco_tmpdata(p_session_id IN NUMBER);

  /**
  * ��������� ��������� ������� (�����) � ���� �� ������������� �������
  * @author ��������� �.
  * @param p_session_id ID ������ ������������ ���������� ���� ������ ��������� � ������� ���������
  * @param p_policy_id_ ID �������� �����������
  * @param p_contact_id ID ��������
  * @param p_asset_type_id ID ���� ������� �����������
  * @param res_str �������� ������ ���������� �������� �������� � ����
  */
  PROCEDURE load_casco_data
  (
    p_session_id    IN NUMBER
   ,p_policy_id_    IN NUMBER
   ,p_contact_id    IN NUMBER
   ,p_asset_type_id IN NUMBER
   ,res_str         OUT VARCHAR2
  );

  /**
  * ��������� ��������� ������� ��� ����������� �� ��������� ������� ������� (�����) �� csv-�����
  * @author ��������� �.
  * @param p_session_id ID ������ ������������ ���������� ���� ������ ��������� � ������� ���������
  * @param p_policy_id_ ID �������� �����������
  */
  PROCEDURE update_osago_tmpdata
  (
    p_session_id IN NUMBER
   ,p_policy_id  NUMBER
  );

  PROCEDURE load_osago_gen_policy
  (
    p_session_id    IN NUMBER
   ,p_gen_policy_id IN NUMBER
   ,p_asset_type_id IN NUMBER
   ,res_str         OUT VARCHAR2
  );
END pkg_load_from_csv;
/
CREATE OR REPLACE PACKAGE BODY PKG_LOAD_FROM_CSV AS
  PROCEDURE update_casco_tmpdata(p_session_id IN NUMBER) IS
    p_error VARCHAR(2000);
  BEGIN
    /*-------------------------*/
    UPDATE CASCO_ASSURED_TEMP t
       SET (t.t_vehicle_mark_id, t.is_national_mark1) =
           (SELECT a.t_vehicle_mark_id
                  ,a.is_national_mark
              FROM T_VEHICLE_MARK a
             WHERE TRIM(a.NAME) = TRIM(t.t_vehicle_mark_name))
          ,
           
           t.t_main_model_id =
           (SELECT a.t_main_model_id
              FROM ven_t_main_model a
             WHERE TRIM(a.NAME) = TRIM(t.t_main_model_name)
               AND a.t_vehicle_mark_id =
                   (SELECT b.t_vehicle_mark_id
                      FROM ven_t_vehicle_mark b
                     WHERE TRIM(b.NAME) = TRIM(t.t_vehicle_mark_name)))
          ,t.vehicle_type_id =
           (SELECT a.t_vehicle_type_id
              FROM T_VEHICLE_TYPE a
             WHERE TRIM(a.NAME) = TRIM(t.t_vehicle_type_name))
          ,
           
           -- �����
           t.deduct_type_desc1     = DECODE(t.ins_amount1
                                           ,NULL
                                           ,NULL
                                           ,NVL(t.deduct_type_desc1, '���'))
          ,t.deduct_type_desc2     = DECODE(t.ins_amount2
                                           ,NULL
                                           ,NULL
                                           ,NVL(t.deduct_type_desc2, '���'))
          ,t.deduct_type_desc3     = DECODE(t.ins_amount3
                                           ,NULL
                                           ,NULL
                                           ,NVL(t.deduct_type_desc3, '���'))
          ,t.deduct_val_type_desc1 = DECODE(t.ins_amount1
                                           ,NULL
                                           ,NULL
                                           ,NVL(t.deduct_val_type_desc1, '�������'))
          ,t.deduct_val_type_desc2 = DECODE(t.ins_amount2
                                           ,NULL
                                           ,NULL
                                           ,NVL(t.deduct_val_type_desc2, '�������'))
          ,t.deduct_val_type_desc3 = DECODE(t.ins_amount3
                                           ,NULL
                                           ,NULL
                                           ,NVL(t.deduct_val_type_desc3, '�������'))
          ,t.t_deductible_type_id1 = DECODE(t.ins_amount1
                                           ,NULL
                                           ,NULL
                                           ,(SELECT a.ID
                                              FROM T_DEDUCTIBLE_TYPE a
                                             WHERE a.description = NVL(t.deduct_type_desc1, '���')))
          ,t.t_deductible_type_id2 = DECODE(t.ins_amount2
                                           ,NULL
                                           ,NULL
                                           ,(SELECT a.ID
                                              FROM T_DEDUCTIBLE_TYPE a
                                             WHERE a.description = NVL(t.deduct_type_desc2, '���')))
          ,t.t_deductible_type_id3 = DECODE(t.ins_amount3
                                           ,NULL
                                           ,NULL
                                           ,(SELECT a.ID
                                              FROM T_DEDUCTIBLE_TYPE a
                                             WHERE a.description = NVL(t.deduct_type_desc3, '���')))
          ,t.t_deductible_type_id4 =
           (SELECT a.ID FROM T_DEDUCTIBLE_TYPE a WHERE a.description = '�����')
          ,t.t_deductible_type_id5 =
           (SELECT a.ID FROM T_DEDUCTIBLE_TYPE a WHERE a.description = '���')
          ,t.t_deduct_val_type_id1 = DECODE(t.ins_amount1
                                           ,NULL
                                           ,NULL
                                           ,(SELECT a.ID
                                              FROM T_DEDUCT_VAL_TYPE a
                                             WHERE a.description =
                                                   NVL(t.deduct_val_type_desc1, '�������')))
          ,t.t_deduct_val_type_id2 = DECODE(t.ins_amount2
                                           ,NULL
                                           ,NULL
                                           ,(SELECT a.ID
                                              FROM T_DEDUCT_VAL_TYPE a
                                             WHERE a.description =
                                                   NVL(t.deduct_val_type_desc2, '�������')))
          ,t.t_deduct_val_type_id3 = DECODE(t.ins_amount3
                                           ,NULL
                                           ,NULL
                                           ,(SELECT a.ID
                                              FROM T_DEDUCT_VAL_TYPE a
                                             WHERE a.description =
                                                   NVL(t.deduct_val_type_desc3, '�������')))
          ,t.t_deduct_val_type_id4 =
           (SELECT a.ID FROM T_DEDUCT_VAL_TYPE a WHERE a.DESCRIPTION = '�������')
          ,t.t_deduct_val_type_id5 =
           (SELECT a.ID FROM T_DEDUCT_VAL_TYPE a WHERE a.DESCRIPTION = '�������')
          ,t.deductible_value1     = DECODE(t.ins_amount1, NULL, NULL, NVL(t.deductible_value1, '0'))
          ,t.deductible_value2     = DECODE(t.ins_amount2, NULL, NULL, NVL(t.deductible_value2, '0'))
          ,t.deductible_value3     = DECODE(t.ins_amount3, NULL, NULL, NVL(t.deductible_value3, '0'))
    
     WHERE t.session_id = p_session_id;
  
    /*--------------------------*/
    UPDATE CASCO_ASSURED_TEMP t
       SET t.is_load = '0'
     WHERE t.is_load <> '2'
       AND t.session_id = p_session_id;
  
    UPDATE CASCO_ASSURED_TEMP t
       SET t.is_load = '1'
     WHERE t.session_id = p_session_id
       AND t.is_load <> '2'
       AND t.t_vehicle_mark_id IS NOT NULL
       AND t.is_national_mark1 IS NOT NULL
       AND t.t_main_model_id IS NOT NULL
       AND t.vehicle_type_id IS NOT NULL
       AND t.model_year IS NOT NULL
       AND t.model_year LIKE '____'
       AND t.pts_s IS NOT NULL
       AND t.pts_n IS NOT NULL
          --�������� ������� ������ ��� �����
       AND (t.ins_amount1 IS NOT NULL OR t.ins_amount2 IS NOT NULL)
          --��� ��������
       AND (t.deduct_type_desc1 IS NULL OR t.t_deductible_type_id1 IS NOT NULL)
       AND (t.deduct_type_desc2 IS NULL OR t.t_deductible_type_id2 IS NOT NULL)
       AND (t.deduct_type_desc3 IS NULL OR t.t_deductible_type_id3 IS NOT NULL)
          --��� �������� ��������
       AND ((t.deduct_type_desc1 IS NULL AND t.deduct_val_type_desc1 IS NULL) OR
           (t.t_deductible_type_id1 IS NOT NULL AND t.deduct_type_desc1 IS NOT NULL))
       AND ((t.deduct_type_desc2 IS NULL AND t.deduct_val_type_desc2 IS NULL) OR
           (t.t_deductible_type_id2 IS NOT NULL AND t.deduct_type_desc2 IS NOT NULL))
       AND ((t.deduct_type_desc3 IS NULL AND t.deduct_val_type_desc3 IS NULL) OR
           (t.t_deductible_type_id3 IS NOT NULL AND t.deduct_type_desc3 IS NOT NULL));
  
    /*--------------------------*/
    DECLARE
      CURSOR cur_casco_ass_temp IS
        SELECT *
          FROM CASCO_ASSURED_TEMP
         WHERE is_load IN ('0', '1')
           AND session_id = p_session_id;
    BEGIN
      FOR t IN cur_casco_ass_temp
      LOOP
        BEGIN
          p_error := '';
        
          IF t.t_vehicle_mark_id IS NULL
          THEN
            p_error := p_error || ',' || '�����';
          END IF;
        
          IF t.t_main_model_id IS NULL
          THEN
            p_error := p_error || ',' || '������';
          END IF;
        
          IF t.vehicle_type_id IS NULL
          THEN
            p_error := p_error || ',' || '���';
          END IF;
        
          IF (t.model_year IS NULL)
             OR (t.model_year NOT LIKE '____')
          THEN
            p_error := p_error || ',' || '���';
          END IF;
        
          IF t.pts_s IS NULL
          THEN
            p_error := p_error || ',' || '��� �����';
          END IF;
        
          IF t.pts_n IS NULL
          THEN
            p_error := p_error || ',' || '��� �����';
          END IF;
        
          --�������� ������� ����� � ������
          IF (t.ins_amount1 IS NULL)
             AND (t.ins_amount2 IS NULL)
          THEN
            p_error := p_error || ',' || '��������� ����� (�����, �����)';
          END IF;
        
          IF (t.ins_amount1 IS NOT NULL)
             AND (t.ins_amount2 IS NOT NULL)
          THEN
            p_error := p_error || ',' || '������������� ��������� (�����, �����)';
          END IF;
        
          --�������� ���� ��������
          IF (t.deduct_type_desc1 IS NOT NULL AND t.t_deductible_type_id1 IS NULL)
          THEN
            p_error := p_error || ',' || '��� �������� (�����)';
          END IF;
        
          IF (t.deduct_type_desc2 IS NOT NULL AND t.t_deductible_type_id2 IS NULL)
          THEN
            p_error := p_error || ',' || '��� �������� (�����)';
          END IF;
        
          IF (t.deduct_type_desc3 IS NOT NULL AND t.t_deductible_type_id3 IS NULL)
          THEN
            p_error := p_error || ',' || '��� �������� (��)';
          END IF;
        
          --�������� ���� �������� ��������
          IF (t.t_deductible_type_id1 IS NOT NULL)
             AND (t.t_deduct_val_type_id1 IS NULL)
          THEN
            p_error := p_error || ',' || '��� �������� �������� (�����)';
          END IF;
        
          IF (t.t_deductible_type_id2 IS NOT NULL)
             AND (t.t_deduct_val_type_id2 IS NULL)
          THEN
            p_error := p_error || ',' || '��� �������� �������� (�����)';
          END IF;
        
          IF (t.t_deductible_type_id3 IS NOT NULL)
             AND (t.t_deduct_val_type_id3 IS NULL)
          THEN
            p_error := p_error || ',' || '��� �������� �������� (��)';
          END IF;
          -- �������� ��
          IF ((t.T_ACCIDENT_TYPE = '������� ����') AND
             ((t.PLACE_NUM IS NULL) OR (t.PLACE_AMOUNT IS NULL)))
             OR ((t.INS_AMOUNT5 IS NOT NULL) AND (t.T_ACCIDENT_TYPE IS NULL))
          THEN
            p_error := p_error || ',' || '������� �����������';
          END IF;
        
          p_error := Utils.replaceall(p_error);
        
          UPDATE CASCO_ASSURED_TEMP t1
             SET t1.text_error = substr(p_error, 1, 1024)
           WHERE t1.rec_number = t.rec_number
             AND t1.session_id = p_session_id;
        
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE CASCO_ASSURED_TEMP t1
               SET t1.text_error = '�������� �� ���������!'
             WHERE t1.rec_number = t.rec_number;
          
        END;
      END LOOP;
    END;
  
  END;

  /*-----------------------------------------------------------------------------------*/
  PROCEDURE load_casco_data
  (
    p_session_id    IN NUMBER
   ,p_policy_id_    IN NUMBER
   ,p_contact_id    IN NUMBER
   ,p_asset_type_id IN NUMBER
   ,res_str         OUT VARCHAR2
  ) IS
    /* ������������ �������� � ������� "������ � ��������"
       cur_casco_assured_temp.is_load
          0 - ��������� �� ��������� �������
          1 - ���������� �� ������������ � ������ � �������� � �������
          2 - ��������� � �������
    */
  
    CURSOR cur_casco_assured_temp IS
      SELECT *
        FROM CASCO_ASSURED_TEMP
       WHERE session_id = p_session_id
         AND is_load = '1';
  
    row_p_asset_header VEN_P_ASSET_HEADER%ROWTYPE;
    row_ven_as_vehicle VEN_AS_VEHICLE%ROWTYPE;
    row_ven_p_cover    VEN_P_COVER%ROWTYPE;
  
    tmp_val  NUMBER;
    num_load NUMBER(10) := 0;
    -- num_noload  NUMBER(10) := 0;
    res_str_tmp VARCHAR2(4000);
    v_product   t_product.brief%TYPE;
  BEGIN
    -- ��� �������� ���������-����������� ����� �������� ������������
    SELECT t.brief
      INTO v_product
      FROM p_policy     p
          ,p_pol_header ph
          ,t_product    t
     WHERE ph.product_id = t.product_id
       AND p.pol_header_id = ph.policy_header_id
       AND p.policy_id = p_policy_id_;
  
    FOR rec_casco_temp IN cur_casco_assured_temp
    LOOP
      BEGIN
        SAVEPOINT savepoint_1;
        res_str_tmp := '';
        BEGIN
          --p_asset_header
          SELECT sq_p_asset_header.nextval INTO row_p_asset_header.p_asset_header_id FROM dual;
          row_p_asset_header.t_asset_type_id := p_asset_type_id;
        
          INSERT INTO ven_p_asset_header VALUES row_p_asset_header;
        
          res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':Asset_Header-Load-#-';
        EXCEPTION
          WHEN OTHERS THEN
            res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':Asset_Header-NotLoad-#-' ||
                           SQLERRM;
            RAISE;
        END;
      
        BEGIN
          -- as_vehicle
          SELECT sq_as_vehicle.nextval INTO row_ven_as_vehicle.as_vehicle_id FROM dual;
        
          row_ven_as_vehicle.contact_id        := p_contact_id;
          row_ven_as_vehicle.p_asset_header_id := row_p_asset_header.p_asset_header_id;
          row_ven_as_vehicle.p_policy_id       := p_policy_id_;
        
          SELECT status_hist_id
            INTO row_ven_as_vehicle.status_hist_id
            FROM status_hist
           WHERE brief = 'NEW';
        
          SELECT contact_address_id
            INTO row_ven_as_vehicle.cn_contact_address_id
            FROM (SELECT ca.ID AS contact_address_id
                    FROM ven_cn_contact_address ca
                        ,ven_t_address_type     a
                   WHERE ca.contact_id = p_contact_id
                     AND a.ID = ca.address_type
                   ORDER BY nvl(ca.is_default, 0) DESC)
           WHERE rownum = 1;
        
          IF rec_casco_temp.is_damage = '��'
          THEN
            row_ven_as_vehicle.is_damage := 1;
          ELSE
            row_ven_as_vehicle.is_damage := 0;
          END IF;
        
          row_ven_as_vehicle.model_year        := TO_NUMBER(rec_casco_temp.model_year);
          row_ven_as_vehicle.pts_s             := rec_casco_temp.pts_s;
          row_ven_as_vehicle.pts_n             := rec_casco_temp.pts_n;
          row_ven_as_vehicle.t_vehicle_mark_id := rec_casco_temp.t_vehicle_mark_id;
          row_ven_as_vehicle.t_vehicle_type_id := rec_casco_temp.vehicle_type_id;
          row_ven_as_vehicle.is_driver_no_lim  := 1;
          SELECT start_date
                ,end_date
            INTO row_ven_as_vehicle.start_date
                ,row_ven_as_vehicle.end_date
            FROM p_policy
           WHERE policy_id = p_policy_id_;
        
          row_ven_as_vehicle.ins_amount      := NVL(rec_casco_temp.ins_amount2, 0);
          row_ven_as_vehicle.ins_premium     := NVL(rec_casco_temp.premium1, 0) +
                                                NVL(rec_casco_temp.premium2, 0) +
                                                NVL(rec_casco_temp.premium3, 0) +
                                                NVL(rec_casco_temp.premium4, 0) +
                                                NVL(rec_casco_temp.premium5, 0);
          row_ven_as_vehicle.ins_price       := rec_casco_temp.basic_sur_amt;
          row_ven_as_vehicle.license_plate   := rec_casco_temp.license_plate;
          row_ven_as_vehicle.reg_n           := rec_casco_temp.reg_n;
          row_ven_as_vehicle.t_main_model_id := rec_casco_temp.t_main_model_id;
          row_ven_as_vehicle.vin             := rec_casco_temp.vin;
          --  row_ven_as_vehicle.wear            := rec_casco_temp.wear;
          row_ven_as_vehicle.key_num := TO_NUMBER(rec_casco_temp.key_num);
          SELECT a.id
            INTO row_ven_as_vehicle.t_casco_comp_type_id
            FROM ven_t_casco_comp_type a
           WHERE a.description = '������ �� ���� �� ����������� �����������';
        
          INSERT INTO ven_as_vehicle VALUES row_ven_as_vehicle;
        
          res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':Vehicle-Load-#-';
        EXCEPTION
          WHEN OTHERS THEN
            res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':Vehicle-NotLoad-#- ' ||
                           SQLERRM;
            RAISE;
        END;
      
        --���������
        IF (rec_casco_temp.ins_amount1 IS NOT NULL)
        THEN
          BEGIN
            SELECT sq_p_cover.nextval INTO row_ven_p_cover.p_cover_id FROM DUAL;
          
            row_ven_p_cover.as_asset_id := row_ven_as_vehicle.as_vehicle_id;
          
            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM P_POLICY           pol
                  ,P_POL_HEADER       polh
                  ,T_PRODUCT          p
                  ,T_PRODUCT_VERSION  pv
                  ,T_PRODUCT_VER_LOB  pvl
                  ,T_PRODUCT_LINE     pl
                  ,T_PROD_LINE_OPTION plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = p_policy_id_
               AND pv.version_nr = (SELECT MAX(t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = '���������';
          
            row_ven_p_cover.status_hist_id        := row_ven_as_vehicle.status_hist_id;
            row_ven_p_cover.start_date            := row_ven_as_vehicle.start_date;
            row_ven_p_cover.end_date              := row_ven_as_vehicle.end_date;
            row_ven_p_cover.ins_amount            := NULL;
            row_ven_p_cover.premium               := NULL;
            row_ven_p_cover.tariff                := NULL;
            row_ven_p_cover.t_deductible_type_id  := rec_casco_temp.t_deductible_type_id1;
            row_ven_p_cover.t_deduct_val_type_id  := rec_casco_temp.t_deduct_val_type_id1;
            row_ven_p_cover.deductible_value      := rec_casco_temp.deductible_value1;
            row_ven_p_cover.ins_price             := rec_casco_temp.basic_sur_amt;
            row_ven_p_cover.is_handchange_amount  := 0;
            row_ven_p_cover.is_handchange_decline := 0;
            row_ven_p_cover.is_handchange_deduct  := 0;
            row_ven_p_cover.is_handchange_premium := 0;
            row_ven_p_cover.is_handchange_tariff  := 0;
          
            INSERT INTO ven_p_cover VALUES row_ven_p_cover;
          
            IF v_product = '���������-�����������'
            THEN
              -- ������� ��������� ������������
              tmp_val := pkg_tariff.recalc_tariff_casco(row_ven_p_cover.p_cover_id);
              -- ��������� ����������� �������������� ���������� ���, ����� ��� ����������� ������ ���������� �����������
              UPDATE p_cover_coef pcc
                 SET pcc.val = rec_casco_temp.tariff1 / tmp_val
               WHERE pcc.p_cover_id = row_ven_p_cover.p_cover_id
                 AND pcc.t_prod_coef_type_id =
                     (SELECT pct.t_prod_coef_type_id
                        FROM t_prod_coef_type pct
                       WHERE pct.brief = 'CASCO_DAMAGE_K15');
            END IF;
            -- ������ ������,��������� ����� � ������, ����������� �� ��������� ������������� �� �����������
            UPDATE p_cover pc
               SET pc.ins_amount            = rec_casco_temp.ins_amount1
                  ,pc.premium               = rec_casco_temp.premium1
                  ,pc.tariff                = rec_casco_temp.tariff1
                  ,pc.is_handchange_amount  = 1
                  ,pc.is_handchange_premium = 1
                  ,pc.is_handchange_tariff  = 1
                  ,pc.is_handchange_deduct  = 1
                  ,pc.is_handchange_decline = 1
             WHERE pc.p_cover_id = row_ven_p_cover.p_cover_id;
          
            res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':Casco-Load-#-';
          EXCEPTION
            WHEN OTHERS THEN
              res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':Casco-NotLoad-#-' ||
                             SQLERRM;
              RAISE;
          END;
        END IF;
      
        --�����
        IF (rec_casco_temp.ins_amount1 IS NULL)
           AND (rec_casco_temp.ins_amount2 IS NOT NULL)
        THEN
          BEGIN
            SELECT sq_p_cover.nextval INTO row_ven_p_cover.p_cover_id FROM dual;
          
            row_ven_p_cover.as_asset_id := row_ven_as_vehicle.as_vehicle_id;
          
            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM P_POLICY           pol
                  ,P_POL_HEADER       polh
                  ,T_PRODUCT          p
                  ,T_PRODUCT_VERSION  pv
                  ,T_PRODUCT_VER_LOB  pvl
                  ,T_PRODUCT_LINE     pl
                  ,T_PROD_LINE_OPTION plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = p_policy_id_
               AND pv.version_nr = (SELECT MAX(t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = '�����';
          
            row_ven_p_cover.status_hist_id        := row_ven_as_vehicle.status_hist_id;
            row_ven_p_cover.start_date            := row_ven_as_vehicle.start_date;
            row_ven_p_cover.end_date              := row_ven_as_vehicle.end_date;
            row_ven_p_cover.ins_amount            := NULL;
            row_ven_p_cover.premium               := NULL;
            row_ven_p_cover.tariff                := NULL;
            row_ven_p_cover.t_deductible_type_id  := rec_casco_temp.t_deductible_type_id2;
            row_ven_p_cover.t_deduct_val_type_id  := rec_casco_temp.t_deduct_val_type_id2;
            row_ven_p_cover.deductible_value      := rec_casco_temp.deductible_value2;
            row_ven_p_cover.ins_price             := rec_casco_temp.basic_sur_amt;
            row_ven_p_cover.is_handchange_amount  := 0;
            row_ven_p_cover.is_handchange_decline := 0;
            row_ven_p_cover.is_handchange_deduct  := 0;
            row_ven_p_cover.is_handchange_premium := 0;
            row_ven_p_cover.is_handchange_tariff  := 0;
          
            INSERT INTO ven_p_cover VALUES row_ven_p_cover;
          
            IF v_product = '���������-�����������'
            THEN
              -- ������� ��������� ������������
              tmp_val := pkg_tariff.recalc_tariff_casco(row_ven_p_cover.p_cover_id);
              -- ��������� ����������� �������������� ���������� ���, ����� ��� ����������� ������ ���������� �����������
              UPDATE p_cover_coef pcc
                 SET pcc.val = rec_casco_temp.tariff2 / tmp_val
               WHERE pcc.p_cover_id = row_ven_p_cover.p_cover_id
                 AND pcc.t_prod_coef_type_id =
                     (SELECT pct.t_prod_coef_type_id
                        FROM t_prod_coef_type pct
                       WHERE pct.brief = 'CASCO_DAMAGE_K15');
            END IF;
            -- ������ ������,��������� ����� � ������, ����������� �� ��������� ������������� �� �����������
            UPDATE p_cover pc
               SET pc.ins_amount            = rec_casco_temp.ins_amount2
                  ,pc.premium               = rec_casco_temp.premium2
                  ,pc.tariff                = rec_casco_temp.tariff2
                  ,pc.is_handchange_amount  = 1
                  ,pc.is_handchange_premium = 1
                  ,pc.is_handchange_tariff  = 1
                  ,pc.is_handchange_deduct  = 1
                  ,pc.is_handchange_decline = 1
             WHERE pc.p_cover_id = row_ven_p_cover.p_cover_id;
          
            res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':Uscherb-Load-#-';
          EXCEPTION
            WHEN OTHERS THEN
              res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':Uscherb-NotLoad-#- ' ||
                             SQLERRM;
              RAISE;
          END;
        END IF;
      
        --�������������� ������������
        IF (rec_casco_temp.ins_amount3 IS NOT NULL)
        THEN
          DECLARE
            row_ven_as_vehicle_stuff ven_as_vehicle_stuff%ROWTYPE;
          BEGIN
            SELECT sq_p_cover.nextval INTO row_ven_p_cover.p_cover_id FROM DUAL;
          
            row_ven_p_cover.as_asset_id := row_ven_as_vehicle.as_vehicle_id;
          
            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM P_POLICY           pol
                  ,P_POL_HEADER       polh
                  ,T_PRODUCT          p
                  ,T_PRODUCT_VERSION  pv
                  ,T_PRODUCT_VER_LOB  pvl
                  ,T_PRODUCT_LINE     pl
                  ,T_PROD_LINE_OPTION plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = p_policy_id_
               AND pv.version_nr = (SELECT MAX(t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = '�������������� ������������';
          
            row_ven_p_cover.status_hist_id        := row_ven_as_vehicle.status_hist_id;
            row_ven_p_cover.start_date            := row_ven_as_vehicle.start_date;
            row_ven_p_cover.end_date              := row_ven_as_vehicle.end_date;
            row_ven_p_cover.ins_amount            := NULL;
            row_ven_p_cover.premium               := NULL;
            row_ven_p_cover.tariff                := NULL;
            row_ven_p_cover.t_deductible_type_id  := rec_casco_temp.t_deductible_type_id3;
            row_ven_p_cover.t_deduct_val_type_id  := rec_casco_temp.t_deduct_val_type_id3;
            row_ven_p_cover.deductible_value      := rec_casco_temp.deductible_value3;
            row_ven_p_cover.ins_price             := rec_casco_temp.basic_sur_amt;
            row_ven_p_cover.is_handchange_amount  := 0;
            row_ven_p_cover.is_handchange_decline := 0;
            row_ven_p_cover.is_handchange_deduct  := 0;
            row_ven_p_cover.is_handchange_premium := 0;
            row_ven_p_cover.is_handchange_tariff  := 0;
          
            INSERT INTO ven_p_cover VALUES row_ven_p_cover;
            --�������������� ������������
            row_ven_as_vehicle_stuff.as_vehicle_id := row_ven_as_vehicle.as_vehicle_id;
          
            SELECT vs.t_vehicle_stuff_type_id
                  ,vs.name
              INTO row_ven_as_vehicle_stuff.t_vehicle_stuff_type_id
                  ,row_ven_as_vehicle_stuff.name
              FROM ven_t_vehicle_stuff_type vs
             WHERE vs.t_vehicle_stuff_type_id = 1;
          
            INSERT INTO ven_as_vehicle_stuff VALUES row_ven_as_vehicle_stuff;
          
            IF v_product = '���������-�����������'
            THEN
              -- ������� ��������� ������������
              tmp_val := pkg_tariff.recalc_tariff_casco(row_ven_p_cover.p_cover_id);
              -- ��������� ����������� �������������� ���������� ���, ����� ��� ����������� ������ ���������� �����������
              UPDATE p_cover_coef pcc
                 SET pcc.val = rec_casco_temp.tariff3 / tmp_val
               WHERE pcc.p_cover_id = row_ven_p_cover.p_cover_id
                 AND pcc.t_prod_coef_type_id =
                     (SELECT pct.t_prod_coef_type_id
                        FROM t_prod_coef_type pct
                       WHERE pct.brief = 'CASCO_DAMAGE_K15');
            END IF;
            -- ������ ������,��������� ����� � ������, ����������� �� ��������� ������������� �� �����������
            UPDATE p_cover pc
               SET pc.ins_amount            = rec_casco_temp.ins_amount3
                  ,pc.premium               = rec_casco_temp.premium3
                  ,pc.tariff                = rec_casco_temp.tariff3
                  ,pc.is_handchange_amount  = 1
                  ,pc.is_handchange_premium = 1
                  ,pc.is_handchange_tariff  = 1
                  ,pc.is_handchange_deduct  = 1
                  ,pc.is_handchange_decline = 1
             WHERE pc.p_cover_id = row_ven_p_cover.p_cover_id;
          
            res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':DO-Load-#-';
          EXCEPTION
            WHEN OTHERS THEN
              res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':DO-NotLoad-#- ' || SQLERRM;
              RAISE;
          END;
        END IF;
      
        --����������� ���������������
        IF (rec_casco_temp.ins_amount4 IS NOT NULL)
        THEN
          BEGIN
            SELECT sq_p_cover.nextval INTO row_ven_p_cover.p_cover_id FROM dual;
          
            row_ven_p_cover.as_asset_id := row_ven_as_vehicle.as_vehicle_id;
          
            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM P_POLICY           pol
                  ,P_POL_HEADER       polh
                  ,T_PRODUCT          p
                  ,T_PRODUCT_VERSION  pv
                  ,T_PRODUCT_VER_LOB  pvl
                  ,T_PRODUCT_LINE     pl
                  ,T_PROD_LINE_OPTION plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = p_policy_id_
               AND pv.version_nr = (SELECT MAX(t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = '����������� ���������������';
          
            row_ven_p_cover.status_hist_id        := row_ven_as_vehicle.status_hist_id;
            row_ven_p_cover.start_date            := row_ven_as_vehicle.start_date;
            row_ven_p_cover.end_date              := row_ven_as_vehicle.end_date;
            row_ven_p_cover.ins_amount            := NULL;
            row_ven_p_cover.premium               := NULL;
            row_ven_p_cover.tariff                := NULL;
            row_ven_p_cover.t_deductible_type_id  := rec_casco_temp.t_deductible_type_id4;
            row_ven_p_cover.t_deduct_val_type_id  := rec_casco_temp.t_deduct_val_type_id4;
            row_ven_p_cover.deductible_value      := NULL;
            row_ven_p_cover.ins_price             := rec_casco_temp.basic_sur_amt;
            row_ven_p_cover.is_handchange_amount  := 0;
            row_ven_p_cover.is_handchange_decline := 0;
            row_ven_p_cover.is_handchange_deduct  := 0;
            row_ven_p_cover.is_handchange_premium := 0;
            row_ven_p_cover.is_handchange_tariff  := 0;
          
            INSERT INTO ven_p_cover VALUES row_ven_p_cover;
          
            IF v_product = '���������-�����������'
            THEN
              -- ������� ��������� ������������
              tmp_val := pkg_tariff.recalc_tariff_casco(row_ven_p_cover.p_cover_id);
              -- ��������� ����������� �������������� ���������� ���, ����� ��� ����������� ������ ���������� �����������
              UPDATE p_cover_coef pcc
                 SET pcc.val = rec_casco_temp.tariff4 / tmp_val
               WHERE pcc.p_cover_id = row_ven_p_cover.p_cover_id
                 AND pcc.t_prod_coef_type_id =
                     (SELECT pct.t_prod_coef_type_id
                        FROM t_prod_coef_type pct
                       WHERE pct.brief = 'CASCO_DAMAGE_K15');
            END IF;
            -- ������ ������,��������� ����� � ������, ����������� �� ��������� ������������� �� �����������
            UPDATE p_cover pc
               SET pc.ins_amount            = rec_casco_temp.ins_amount4
                  ,pc.premium               = rec_casco_temp.premium4
                  ,pc.tariff                = rec_casco_temp.tariff4
                  ,pc.is_handchange_amount  = 1
                  ,pc.is_handchange_premium = 1
                  ,pc.is_handchange_tariff  = 1
                  ,pc.is_handchange_deduct  = 1
                  ,pc.is_handchange_decline = 1
             WHERE pc.p_cover_id = row_ven_p_cover.p_cover_id;
          
            res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':GO-Load-#-';
          EXCEPTION
            WHEN OTHERS THEN
              res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':GO-NotLoad-#- ' || SQLERRM;
              RAISE;
          END;
        END IF;
      
        --���������� ������
        IF (rec_casco_temp.ins_amount5 IS NOT NULL)
        THEN
          DECLARE
            row_ven_p_cover_accident ven_p_cover_accident%ROWTYPE;
          BEGIN
            SELECT sq_p_cover_accident.nextval INTO row_ven_p_cover_accident.id FROM dual;
          
            row_ven_p_cover_accident.as_asset_id := row_ven_as_vehicle.as_vehicle_id;
          
            SELECT plo.ID
              INTO row_ven_p_cover_accident.t_prod_line_option_id
              FROM P_POLICY           pol
                  ,P_POL_HEADER       polh
                  ,T_PRODUCT          p
                  ,T_PRODUCT_VERSION  pv
                  ,T_PRODUCT_VER_LOB  pvl
                  ,T_PRODUCT_LINE     pl
                  ,T_PROD_LINE_OPTION plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = p_policy_id_
               AND pv.version_nr = (SELECT MAX(t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = '���������� ������';
          
            row_ven_p_cover_accident.status_hist_id        := row_ven_as_vehicle.status_hist_id;
            row_ven_p_cover_accident.start_date            := row_ven_as_vehicle.start_date;
            row_ven_p_cover_accident.end_date              := row_ven_as_vehicle.end_date;
            row_ven_p_cover_accident.ins_amount            := NULL;
            row_ven_p_cover_accident.premium               := NULL;
            row_ven_p_cover_accident.tariff                := NULL;
            row_ven_p_cover_accident.t_deductible_type_id  := rec_casco_temp.t_deductible_type_id5;
            row_ven_p_cover_accident.t_deduct_val_type_id  := rec_casco_temp.t_deduct_val_type_id5;
            row_ven_p_cover_accident.deductible_value      := NULL;
            row_ven_p_cover_accident.ins_price             := rec_casco_temp.basic_sur_amt;
            row_ven_p_cover_accident.is_handchange_amount  := 0;
            row_ven_p_cover_accident.is_handchange_decline := 0;
            row_ven_p_cover_accident.is_handchange_deduct  := 0;
            row_ven_p_cover_accident.is_handchange_premium := 0;
            row_ven_p_cover_accident.is_handchange_tariff  := 0;
            -- ���� ���� ������� p_cover_accident
            row_ven_p_cover_accident.DRIVER_INSURED_AMOUNT     := NULL;
            row_ven_p_cover_accident.SECOND_PSNGR_INSURED_AMNT := NULL;
            row_ven_p_cover_accident.NUMBER_OF_SEATS           := to_number(rec_casco_temp.place_num);
            row_ven_p_cover_accident.PER_SEAT_INSURED_AMOUNT   := to_number(rec_casco_temp.place_amount);
            row_ven_p_cover_accident.COUNT_PLACES_ID           := NULL;
          
            SELECT a.t_casco_accident_typ_id
              INTO row_ven_p_cover_accident.ACCIDENT_INSURANCE_TYPE
              FROM t_casco_accident_typ a
             WHERE a.description = rec_casco_temp.T_ACCIDENT_TYPE;
          
            INSERT INTO ven_p_cover_accident VALUES row_ven_p_cover_accident;
          
            IF v_product = '���������-�����������'
            THEN
              -- ������� ��������� ������������
              tmp_val := pkg_tariff.recalc_tariff_casco(row_ven_p_cover_accident.id);
              -- ��������� ����������� �������������� ���������� ���, ����� ��� ����������� ������ ���������� �����������
              UPDATE p_cover_coef pcc
                 SET pcc.val = rec_casco_temp.tariff5 / tmp_val
               WHERE pcc.p_cover_id = row_ven_p_cover_accident.id
                 AND pcc.t_prod_coef_type_id =
                     (SELECT pct.t_prod_coef_type_id
                        FROM t_prod_coef_type pct
                       WHERE pct.brief = 'CASCO_DAMAGE_K15');
            END IF;
            -- ������ ������,��������� ����� � ������, ����������� �� ��������� ������������� �� �����������
            UPDATE ven_p_cover_accident pc
               SET pc.ins_amount            = rec_casco_temp.ins_amount5
                  ,pc.premium               = rec_casco_temp.premium5
                  ,pc.tariff                = rec_casco_temp.tariff5
                  ,pc.is_handchange_amount  = 1
                  ,pc.is_handchange_premium = 1
                  ,pc.is_handchange_tariff  = 1
                  ,pc.is_handchange_deduct  = 1
                  ,pc.is_handchange_decline = 1
             WHERE pc.id = row_ven_p_cover_accident.id;
          
            res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':NS-Load-#-';
          EXCEPTION
            WHEN OTHERS THEN
              res_str_tmp := res_str_tmp || rec_casco_temp.rec_number || ':NS-NotLoad-#- ' || SQLERRM;
              RAISE;
          END;
        END IF;
      
        --ven_as_asset_per
        DECLARE
          row_ven_as_asset_per ven_as_asset_per%ROWTYPE;
        BEGIN
          row_ven_as_asset_per.as_asset_id := row_ven_as_vehicle.as_vehicle_id;
          row_ven_as_asset_per.start_date  := row_ven_as_vehicle.start_date;
          row_ven_as_asset_per.end_date    := row_ven_as_vehicle.end_date;
        
          INSERT INTO ven_as_asset_per VALUES row_ven_as_asset_per;
        END;
      
        UPDATE CASCO_ASSURED_TEMP t1
           SET t1.is_load = 2
         WHERE t1.session_id = p_session_id
           AND t1.rec_number = rec_casco_temp.rec_number;
      
        num_load := num_load + 1;
      
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO savepoint_1;
        
          UPDATE CASCO_ASSURED_TEMP t1
             SET t1.is_load    = 0
                ,t1.text_error = substr(res_str_tmp, 1, 1024)
           WHERE t1.session_id = p_session_id
             AND t1.rec_number = rec_casco_temp.rec_number;
        
        --  num_noload := num_noload + 1;
      END;
    END LOOP;
  
    res_str := '���������� ����������� ������������ ������� ' || num_load;
  END;

  ---------------------------------------------------------------------------------------------
  --  OSAGO
  ---------------------------------------------------------------------------------------------
  PROCEDURE update_osago_tmpdata
  (
    p_session_id IN NUMBER
   ,p_policy_id  NUMBER
  ) IS
    p_error VARCHAR(2000);
    v_rez   NUMBER := 0;
    v_rez_1 NUMBER;
  
    v_temp_type_id   NUMBER;
    v_temp_type_name VARCHAR2(400);
  BEGIN
    /*--------------------------*/
  
    UPDATE OSAGO_ASSURED_TEMP t
       SET (t.t_vehicle_mark_id) =
           (SELECT a.t_vehicle_mark_id
              FROM T_VEHICLE_MARK a
             WHERE UPPER(TRIM(a.NAME)) = UPPER(TRIM(t.t_vehicle_mark_name)))
          ,t.t_main_model_id =
           (SELECT a.t_main_model_id
              FROM ven_t_main_model a
             WHERE UPPER(TRIM(a.NAME)) = UPPER(TRIM(t.t_main_model_name))
               AND a.t_vehicle_mark_id =
                   (SELECT b.t_vehicle_mark_id
                      FROM ven_t_vehicle_mark b
                     WHERE UPPER(TRIM(b.NAME)) = UPPER(TRIM(t.t_vehicle_mark_name))))
          ,t.vehicle_type_id =
           (SELECT a.t_vehicle_type_id
              FROM T_VEHICLE_TYPE a
                  ,t_asset_type   s
             WHERE UPPER(TRIM(a.NAME)) = UPPER(TRIM(t.t_vehicle_type_name))
               AND s.t_asset_type_id = a.asset_type_id
               AND s.brief = 'VEHICLE_OSAGO')
          ,t.t_vehicle_usage_id =
           (SELECT a.t_vehicle_usage_id
              FROM T_VEHICLE_USAGE a
                  ,t_asset_type    s
             WHERE UPPER(TRIM(a.NAME)) = UPPER(TRIM(t.t_vehicle_usage_name))
               AND s.t_asset_type_id = a.asset_type_id
               AND s.brief = 'VEHICLE_OSAGO')
     WHERE t.session_id = p_session_id;
  
    FOR cur IN (SELECT rec_number
                      ,session_id
                      ,base_tariff
                  FROM OSAGO_ASSURED_TEMP
                 WHERE session_id = p_session_id
                   AND base_tariff IN (2375, 1980, 395, 2965, 3240, 810, 1010, 305))
    LOOP
      CASE cur.base_tariff
        WHEN 2375 THEN
          SELECT t_vehicle_type_id
                ,NAME
            INTO v_temp_type_id
                ,v_temp_type_name
            FROM t_vehicle_type
           WHERE brief = 'CAR';
        WHEN 1980 THEN
          SELECT t_vehicle_type_id
                ,NAME
            INTO v_temp_type_id
                ,v_temp_type_name
            FROM t_vehicle_type
           WHERE brief = 'CAR';
        WHEN 395 THEN
          SELECT t_vehicle_type_id
                ,NAME
            INTO v_temp_type_id
                ,v_temp_type_name
            FROM t_vehicle_type
           WHERE brief = 'CAR_TRAILER';
        WHEN 3240 THEN
          SELECT t_vehicle_type_id
                ,NAME
            INTO v_temp_type_id
                ,v_temp_type_name
            FROM t_vehicle_type
           WHERE brief = 'TRUCK';
        WHEN 810 THEN
          SELECT t_vehicle_type_id
                ,NAME
            INTO v_temp_type_id
                ,v_temp_type_name
            FROM t_vehicle_type
           WHERE brief = 'TRUCK_TRAILER';
        WHEN 1010 THEN
          SELECT t_vehicle_type_id
                ,NAME
            INTO v_temp_type_id
                ,v_temp_type_name
            FROM t_vehicle_type
           WHERE brief = 'TRAM';
        WHEN 305 THEN
          SELECT t_vehicle_type_id
                ,NAME
            INTO v_temp_type_id
                ,v_temp_type_name
            FROM t_vehicle_type
           WHERE brief = 'TRACTOR_TRAILER';
        ELSE
          NULL;
      END CASE;
    
      UPDATE OSAGO_ASSURED_TEMP
         SET vehicle_type_id     = v_temp_type_id
            ,t_vehicle_type_name = v_temp_type_name
       WHERE rec_number = cur.rec_number
         AND session_id = cur.session_id;
    END LOOP;
  
    /*--------------------------*/ --as_vehicle
    UPDATE OSAGO_ASSURED_TEMP t
       SET t.is_load = '0'
     WHERE t.session_id = p_session_id
       AND t.is_load <> '2';
  
    UPDATE OSAGO_ASSURED_TEMP t
       SET t.is_load = '1'
     WHERE t.session_id = p_session_id
       AND t.is_load <> '2'
       AND t.t_vehicle_mark_id IS NOT NULL
       AND t.t_main_model_id IS NOT NULL
       AND t.vehicle_type_id IS NOT NULL
       AND t.model_year IS NOT NULL
       AND t.model_year LIKE '____'
       AND t.power_hp IS NOT NULL
       AND t.pts_s IS NOT NULL
       AND t.pts_n IS NOT NULL
       AND t.is_rent IS NOT NULL
       AND t.is_rent IN ('��', '���')
       AND t.t_vehicle_usage_id IS NOT NULL
       AND t.polis_seria IS NOT NULL
       AND t.polis_number IS NOT NULL
       AND t.sz_seria IS NOT NULL
       AND t.sz_number IS NOT NULL
       AND ((t.vehicle_type_id IN (4) AND t.max_weight IS NOT NULL) OR (t.vehicle_type_id NOT IN (4)))
       AND ((t.vehicle_type_id IN (6, 7, 8) AND t.passangers IS NOT NULL) OR
           (t.vehicle_type_id NOT IN (6, 7, 8)));
  
    /*--------------------------*/
    DECLARE
      CURSOR cur_osago_ass_temp IS
        SELECT *
          FROM OSAGO_ASSURED_TEMP
         WHERE session_id = p_session_id
           AND is_load IN ('0', '1');
    BEGIN
      FOR t IN cur_osago_ass_temp
      LOOP
        BEGIN
          p_error := '';
        
          IF t.t_vehicle_mark_id IS NULL
          THEN
            p_error := p_error || ',' || '�����';
          END IF;
        
          IF t.t_main_model_id IS NULL
          THEN
            p_error := p_error || ',' || '������';
          END IF;
        
          IF t.vehicle_type_id IS NULL
          THEN
            p_error := p_error || ',' || '���';
          END IF;
        
          IF (t.model_year IS NULL)
             OR (t.model_year NOT LIKE '____')
          THEN
            p_error := p_error || ',' || '���';
          END IF;
        
          IF (t.power_hp IS NULL)
          THEN
            p_error := p_error || ',' || '����. ��������� (�.�.)';
          END IF;
        
          IF (t.vehicle_type_id = 4 AND t.max_weight IS NULL)
          THEN
            p_error := p_error || ',' || '����. ����� (��)';
          END IF;
        
          IF (t.vehicle_type_id IN (6, 7, 8) AND t.passangers IS NULL)
          THEN
            p_error := p_error || ',' || '����. ����';
          END IF;
        
          IF t.pts_s IS NULL
          THEN
            p_error := p_error || ',' || '��� �����';
          END IF;
        
          IF t.pts_n IS NULL
          THEN
            p_error := p_error || ',' || '��� �����';
          END IF;
        
          IF (t.is_rent IS NULL)
             OR (t.is_rent NOT IN ('��', '���'))
          THEN
            p_error := p_error || ',' || '������ (������)';
          END IF;
        
          IF (t.t_vehicle_usage_id IS NULL)
          THEN
            p_error := p_error || ',' || '���� �������������';
          END IF;
        
          IF (t.polis_seria IS NULL)
          THEN
            p_error := p_error || ',' || '����� (��������� �����)';
            v_rez   := 1;
          END IF;
        
          IF (t.polis_number IS NULL)
          THEN
            p_error := p_error || ',' || '����� (��������� �����)';
            v_rez   := 1;
          END IF;
        
          IF p_policy_id IS NOT NULL
          THEN
            -- �������� ���(��������� �����) � ������������� ���������
            IF v_rez = 0
            THEN
              v_rez_1 := Pkg_Bso.check_relation_bso_pol('�����'
                                                       ,t.polis_seria
                                                       ,t.polis_number
                                                       ,p_policy_id);
              IF v_rez_1 <> 0
              THEN
                v_rez_1 := Pkg_Bso.check_relation_bso_pol('�������'
                                                         ,t.polis_seria
                                                         ,t.polis_number
                                                         ,p_policy_id);
              END IF;
              IF v_rez_1 <> 0
              THEN
                v_rez_1 := Pkg_Bso.check_relation_bso_pol('�������_�'
                                                         ,t.polis_seria
                                                         ,t.polis_number
                                                         ,p_policy_id);
              END IF;
              IF v_rez_1 <> 0
              THEN
                v_rez_1 := Pkg_Bso.check_relation_bso_pol('�������_�'
                                                         ,t.polis_seria
                                                         ,t.polis_number
                                                         ,p_policy_id);
              END IF;
            
              CASE v_rez_1
                WHEN 0 THEN
                  v_rez := 0;
                WHEN 1 THEN
                  p_error := p_error || ',' || '��� �� ������';
                WHEN 2 THEN
                  p_error := p_error || ',' || '������� �� ������';
                WHEN 3 THEN
                  p_error := p_error || ',' || '��� �� ����������� ��������';
                WHEN 4 THEN
                  p_error := p_error || ',' ||
                             '������� �� ���������, ��������� ���-�� ������ ���� ���';
                WHEN 5 THEN
                  p_error := p_error || ',' || '��� ' || TO_CHAR(t.polis_seria) || ' ' ||
                             TO_CHAR(t.polis_number) || ' �������� � ������� ������';
                WHEN 6 THEN
                  p_error := p_error || ',' || '��� �������� � ������ ������ ������';
                WHEN 7 THEN
                  p_error := p_error || ',' || '��������� ��� �� ��������� �������� � ��� �����';
                ELSE
                  p_error := p_error || ',' || '��������� ����������� �� :' || TO_CHAR(v_rez_1);
              END CASE;
            END IF;
            -- ����� �������� ���(��������� �����)
          
            -- ����� �������� ���(���� ����)
          END IF;
          p_error := Utils.replaceall(p_error);
        
          UPDATE OSAGO_ASSURED_TEMP t1
             SET t1.text_error = p_error
           WHERE t1.session_id = p_session_id
             AND t1.rec_number = t.rec_number;
        
          DBMS_OUTPUT.put_line(SQL%ROWCOUNT);
        EXCEPTION
          WHEN OTHERS THEN
            UPDATE OSAGO_ASSURED_TEMP t1
               SET t1.text_error = '�������� �� ���������!'
             WHERE t1.session_id = p_session_id
               AND t1.rec_number = t.rec_number;
          
        END;
      END LOOP;
    END;
  
  END;

  PROCEDURE load_osago_gen_policy
  (
    p_session_id    IN NUMBER
   ,p_gen_policy_id IN NUMBER
   ,p_asset_type_id IN NUMBER
   ,res_str         OUT VARCHAR2
  ) IS
    CURSOR cur_osago_assured_temp IS
      SELECT *
        FROM OSAGO_ASSURED_TEMP
       WHERE session_id = p_session_id
         AND is_load <> '2'
         AND POLIS_NUMBER IS NOT NULL;
  
    count_osago_assured_temp NUMBER(10) := 0;
    row_p_asset_header       ven_P_ASSET_HEADER%ROWTYPE;
    row_ven_as_vehicle       ven_as_vehicle%ROWTYPE;
  
    row_gp      ven_gen_policy%ROWTYPE;
    v_header_id NUMBER;
    v_policy_id NUMBER;
    v_pc_id     NUMBER;
  
    num_load    NUMBER(10) := 0;
    num_noload  NUMBER(10) := 0;
    res_str_tmp VARCHAR2(4000);
  
    v_res      NUMBER;
    v_type_pol VARCHAR2(255);
  
    v_premium NUMBER;
  BEGIN
    res_str := '';
    BEGIN
      SELECT * INTO row_gp FROM ven_gen_policy gp WHERE gp.gen_policy_id = p_gen_policy_id;
    EXCEPTION
      WHEN OTHERS THEN
        res_str := '�� ������ ��������� ����������� �������.';
        RAISE;
    END;
  
    FOR rec_osago_temp IN cur_osago_assured_temp
    LOOP
      BEGIN
        SAVEPOINT savepoint_1;
      
        BEGIN
          -- ���������� ����� �� ���.��������
          Pkg_Gen_Policy.new_policy(row_gp.gen_policy_id, v_header_id);
        EXCEPTION
          WHEN OTHERS THEN
            res_str := res_str || SQLERRM || ' (�������� ������)';
            RAISE;
        END;
      
        BEGIN
          SELECT ph.policy_id
            INTO v_policy_id
            FROM P_POL_HEADER ph
           WHERE ph.policy_header_id = v_header_id;
        EXCEPTION
          WHEN OTHERS THEN
            res_str := SQLERRM || ' (��������� ������ ������)';
            RAISE;
        END;
      
        BEGIN
          -- p_pol_header
          UPDATE P_POL_HEADER ph
             SET ph.prev_policy_company = rec_osago_temp.prev_ins_comp
                ,ph.prev_event_count    = nvl(rec_osago_temp.count_event, 0)
                ,ph.prev_policy_ser     = DECODE(rec_osago_temp.prev_pol_num, NULL, NULL, '���')
                ,ph.prev_policy_num     = rec_osago_temp.prev_pol_num
          
           WHERE ph.policy_header_id = v_header_id;
        EXCEPTION
          WHEN OTHERS THEN
            res_str := SQLERRM || ' (���������� pol_header)';
            RAISE;
        END;
      
        BEGIN
          -- p_asset_header
          SELECT sq_p_asset_header.NEXTVAL INTO row_p_asset_header.p_asset_header_id FROM DUAL;
        
          row_p_asset_header.t_asset_type_id := p_asset_type_id;
        
          INSERT INTO ven_P_ASSET_HEADER VALUES row_p_asset_header;
        
          res_str_tmp := res_str_tmp || rec_osago_temp.rec_number || ':Asset_Header-Load-#- ' ||
                         SQLERRM;
        EXCEPTION
          WHEN OTHERS THEN
            res_str_tmp := res_str_tmp || rec_osago_temp.rec_number || ':Asset_Header-NotLoad-#-';
            res_str     := SQLERRM || ' (�������� asset_header)';
            RAISE;
        END;
      
        BEGIN
          -- as_vehicle
          SELECT sq_as_vehicle.NEXTVAL INTO row_ven_as_vehicle.as_vehicle_id FROM DUAL;
        
          row_ven_as_vehicle.contact_id        := nvl(row_gp.owner_id, row_gp.insurer_id);
          row_ven_as_vehicle.p_asset_header_id := row_p_asset_header.p_asset_header_id;
          row_ven_as_vehicle.p_policy_id       := v_policy_id;
          BEGIN
            SELECT status_hist_id
              INTO row_ven_as_vehicle.status_hist_id
              FROM STATUS_HIST
             WHERE brief = 'NEW';
          EXCEPTION
            WHEN OTHERS THEN
              res_str := SQLERRM || ' (select status_hist)';
              RAISE;
          END;
          BEGIN
            SELECT contact_address_id
              INTO row_ven_as_vehicle.cn_contact_address_id
              FROM (SELECT ca.ID AS contact_address_id
                      FROM ven_cn_contact_address ca
                          ,ven_t_address_type     a
                     WHERE ca.contact_id = row_ven_as_vehicle.contact_id
                       AND a.ID = ca.address_type
                     ORDER BY nvl(ca.is_default, 0) DESC)
             WHERE rownum = 1;
          
          EXCEPTION
            WHEN OTHERS THEN
              res_str := SQLERRM || ' (����� ���������������)';
              RAISE;
          END;
        
          row_ven_as_vehicle.model_year        := TO_NUMBER(rec_osago_temp.model_year);
          row_ven_as_vehicle.pts_s             := rec_osago_temp.pts_s;
          row_ven_as_vehicle.pts_n             := rec_osago_temp.pts_n;
          row_ven_as_vehicle.pts_date          := TO_DATE(rec_osago_temp.pts_date, 'dd.mm.yyyy');
          row_ven_as_vehicle.t_vehicle_mark_id := rec_osago_temp.t_vehicle_mark_id;
          row_ven_as_vehicle.t_vehicle_type_id := rec_osago_temp.vehicle_type_id;
        
          BEGIN
            SELECT start_date
                  ,end_date
              INTO row_ven_as_vehicle.start_date
                  ,row_ven_as_vehicle.end_date
              FROM P_POLICY
             WHERE policy_id = v_policy_id;
          EXCEPTION
            WHEN OTHERS THEN
              res_str := SQLERRM || ' (get date from policy)';
              RAISE;
          END;
        
          row_ven_as_vehicle.license_plate   := rec_osago_temp.license_plate;
          row_ven_as_vehicle.t_main_model_id := rec_osago_temp.t_main_model_id;
          IF rec_osago_temp.vin = '�����������'
          THEN
            row_ven_as_vehicle.is_vin_missing := 1;
          ELSE
            row_ven_as_vehicle.vin := rec_osago_temp.vin;
          END IF;
          row_ven_as_vehicle.key_num    := 1;
          row_ven_as_vehicle.power_hp   := rec_osago_temp.power_hp;
          row_ven_as_vehicle.max_weight := rec_osago_temp.max_weight;
          row_ven_as_vehicle.passangers := rec_osago_temp.passangers;
          row_ven_as_vehicle.chassis_nr := rec_osago_temp.chassis_nr;
          row_ven_as_vehicle.body_nr    := rec_osago_temp.body_nr;
        
          IF rec_osago_temp.is_rent IN ('��')
          THEN
            row_ven_as_vehicle.is_rent := 1;
          ELSE
            row_ven_as_vehicle.is_rent := 0;
          END IF;
        
          row_ven_as_vehicle.t_vehicle_usage_id := rec_osago_temp.t_vehicle_usage_id;
        
          -- �������� ��� ( ����� ����� )
          v_res := Pkg_Bso.check_relation_bso_pol('�����'
                                                 ,rec_osago_temp.polis_seria
                                                 ,rec_osago_temp.polis_number
                                                 ,v_policy_id);
          IF v_res = 0
          THEN
            Pkg_Bso.create_relation_bso_pol('�����'
                                           ,rec_osago_temp.polis_seria
                                           ,rec_osago_temp.polis_number
                                           ,v_policy_id);
          
          ELSE
          
            raise_application_error(-20005
                                   ,'load_osago_gen_policy ������ �������� ��� "����� �����" � �������� ' ||
                                    v_res || '  ' || rec_osago_temp.polis_seria || ' ' ||
                                    rec_osago_temp.polis_number || ' ' || v_policy_id);
          
          END IF;
        
          BEGIN
            UPDATE ven_p_policy p
               SET p.pol_ser        = rec_osago_temp.polis_seria
                  ,p.pol_num        = rec_osago_temp.polis_number
                  ,p.osago_sign_num = rec_osago_temp.polis_number
                  ,p.osago_sign_ser = rec_osago_temp.polis_seria
                  ,p.num            = rec_osago_temp.polis_seria || '-' || rec_osago_temp.polis_number
             WHERE p.policy_id = v_policy_id;
          EXCEPTION
            WHEN OTHERS THEN
              res_str := SQLERRM || ' (update policy)';
              RAISE;
          END;
        
          row_ven_as_vehicle.polis_seria  := rec_osago_temp.polis_seria;
          row_ven_as_vehicle.polis_number := rec_osago_temp.polis_number;
        
          -- �������� ������� ��� ��������� ����� 
          BEGIN
            v_type_pol := '�������';
            v_res      := 0;
            Pkg_Bso.create_relation_bso_pol(v_type_pol
                                           ,rec_osago_temp.sz_seria
                                           ,rec_osago_temp.sz_number
                                           ,v_policy_id);
          EXCEPTION
            WHEN OTHERS THEN
              v_res := 1;
          END;
        
          BEGIN
            v_type_pol := '�������_�';
            IF v_res = 1
            THEN
              v_res := 0;
              Pkg_Bso.create_relation_bso_pol(v_type_pol
                                             ,rec_osago_temp.sz_seria
                                             ,rec_osago_temp.sz_number
                                             ,v_policy_id);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              v_res := 1;
          END;
        
          BEGIN
            v_type_pol := '�������_�';
            IF v_res = 1
            THEN
              Pkg_Bso.create_relation_bso_pol(v_type_pol
                                             ,rec_osago_temp.sz_seria
                                             ,rec_osago_temp.sz_number
                                             ,v_policy_id);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              NULL;
          END;
        
          row_ven_as_vehicle.sz_seria         := rec_osago_temp.sz_seria;
          row_ven_as_vehicle.sz_number        := rec_osago_temp.sz_number;
          row_ven_as_vehicle.is_driver_no_lim := 1;
        
          SELECT bm.t_bonus_malus_id
            INTO row_ven_as_vehicle.t_bonus_malus_id
            FROM t_bonus_malus bm
           WHERE bm.coef = rec_osago_temp.coef_kbm;
        
          BEGIN
            SELECT a1.osago_period_use_id
              INTO row_ven_as_vehicle.osago_period_use_id
              FROM ven_osago_period_use a1
             WHERE a1.description IN ('��������� �� ������ �����������');
          EXCEPTION
            WHEN OTHERS THEN
              res_str := SQLERRM || ' (�� ������� ���������)';
              RAISE;
          END;
        
          BEGIN
            INSERT INTO ven_as_vehicle VALUES row_ven_as_vehicle;
          EXCEPTION
            WHEN OTHERS THEN
              res_str := SQLERRM || ' (������� as_vechicle)';
              RAISE;
          END;
        
          res_str_tmp := res_str_tmp || rec_osago_temp.rec_number || ':Vehicle-Load-#-';
        EXCEPTION
          WHEN OTHERS THEN
            res_str_tmp := res_str_tmp || rec_osago_temp.rec_number || ':Vehicle-NotLoad-#-';
            IF res_str IS NULL
            THEN
              res_str := SQLERRM || ' (�������� as_vechicle)';
            END IF;
            RAISE;
        END;
      
        DECLARE
          -- as_asset_per
          row_ven_as_asset_per ven_as_asset_per%ROWTYPE;
        BEGIN
          row_ven_as_asset_per.as_asset_id := row_ven_as_vehicle.as_vehicle_id;
          row_ven_as_asset_per.start_date  := row_ven_as_vehicle.start_date;
          row_ven_as_asset_per.end_date    := row_ven_as_vehicle.end_date;
        
          INSERT INTO ven_as_asset_per VALUES row_ven_as_asset_per;
        END;
      
        -- ���������� ������ ������, ���������� �� ���� � �� (����� �� ��������� � ���������)
        Pkg_Cover.inc_mandatory_covers_by_asset(row_ven_as_vehicle.as_vehicle_id);
      
        SELECT pc.p_cover_id
              ,pc.premium
          INTO v_pc_id
              ,v_premium
          FROM P_COVER pc
         WHERE pc.as_asset_id = row_ven_as_vehicle.as_vehicle_id;
      
        UPDATE P_COVER pc SET pc.is_handchange_amount = 1 WHERE pc.p_cover_id = v_pc_id;
      
        FOR coef IN (SELECT pcc.p_cover_coef_id
                           ,pct.brief
                       FROM P_COVER_COEF pcc
                       JOIN T_PROD_COEF_TYPE pct
                         ON pct.t_prod_coef_type_id = pcc.t_prod_coef_type_id
                      WHERE pcc.p_cover_id = v_pc_id)
        LOOP
          CASE coef.brief
            WHEN 'OSAGO_BASE' THEN
              UPDATE P_COVER_COEF pcc
                 SET pcc.val = rec_osago_temp.base_tariff
               WHERE pcc.p_cover_coef_id = coef.p_cover_coef_id;
            WHEN 'OSAGO_AREA' THEN
              UPDATE P_COVER_COEF pcc
                 SET pcc.val = rec_osago_temp.coef_area
               WHERE pcc.p_cover_coef_id = coef.p_cover_coef_id;
            WHEN 'OSAGO_KBM' THEN
              UPDATE P_COVER_COEF pcc
                 SET pcc.val = rec_osago_temp.coef_kbm
               WHERE pcc.p_cover_coef_id = coef.p_cover_coef_id;
            WHEN 'OSAGO_Max_Coef_Driver' THEN
              UPDATE P_COVER_COEF pcc
                 SET pcc.val = rec_osago_temp.coef_age
               WHERE pcc.p_cover_coef_id = coef.p_cover_coef_id;
            WHEN 'OSAGO_TERM' THEN
              UPDATE P_COVER_COEF pcc
                 SET pcc.val = rec_osago_temp.coef_srok
               WHERE pcc.p_cover_coef_id = coef.p_cover_coef_id;
            WHEN 'OSAGO_PERIOD_OF_USE' THEN
              UPDATE P_COVER_COEF pcc
                 SET pcc.val = rec_osago_temp.coef_period
               WHERE pcc.p_cover_coef_id = coef.p_cover_coef_id;
            WHEN 'OSAGO_POWER_HP' THEN
              UPDATE P_COVER_COEF pcc
                 SET pcc.val = rec_osago_temp.coef_power
               WHERE pcc.p_cover_coef_id = coef.p_cover_coef_id;
            WHEN 'OSAGO_IS_VIOLATION' THEN
              UPDATE P_COVER_COEF pcc
                 SET pcc.val = rec_osago_temp.coef_breach
               WHERE pcc.p_cover_coef_id = coef.p_cover_coef_id;
            ELSE
              NULL;
          END CASE;
        END LOOP;
      
        /* ���� ��������� ������ ���������� �� ���������, �� ����������� ���������,
          a � �������� ������ (ph.description) ����������� ����������� � �����������
          ������
        */
      
        IF ROUND(v_premium, 2) <> ROUND(rec_osago_temp.ins_premium, 2)
        THEN
          UPDATE ven_p_pol_header ph
             SET description = '������ �� ��������� (' || ROUND(rec_osago_temp.ins_premium, 2) ||
                               ') ���������� �� ������������ �������� ������ (' || ROUND(v_premium, 2) ||
                               '). ' || note
           WHERE policy_id = v_policy_id;
        END IF;
      
        UPDATE ven_P_COVER pc
           SET pc.premium = rec_osago_temp.INS_PREMIUM
         WHERE pc.p_cover_id = v_pc_id;
      
        UPDATE ven_as_asset a
           SET a.ins_premium = rec_osago_temp.INS_PREMIUM
         WHERE a.p_policy_id = v_policy_id;
      
        UPDATE ven_p_policy p
           SET p.premium = rec_osago_temp.INS_PREMIUM
         WHERE p.policy_id = v_policy_id;
      
        UPDATE OSAGO_ASSURED_TEMP t1
           SET t1.is_load    = 2
              ,t1.text_error = ''
         WHERE t1.session_id = p_session_id
           AND t1.rec_number = rec_osago_temp.rec_number;
      
        num_load := num_load + 1;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO savepoint_1;
        
          UPDATE OSAGO_ASSURED_TEMP t1
             SET t1.is_load    = 0
                ,t1.text_error = res_str
           WHERE t1.session_id = p_session_id
             AND t1.rec_number = rec_osago_temp.rec_number;
          res_str    := NULL;
          num_noload := num_noload + 1;
      END;
    END LOOP;
  
    SELECT COUNT(*)
      INTO count_osago_assured_temp
      FROM OSAGO_ASSURED_TEMP
     WHERE session_id = p_session_id
       AND is_load NOT IN ('2')
       AND POLIS_NUMBER IS NOT NULL;
  
    res_str := '��������� �� �������� "����� � ��������"=' || num_load || CHR(10) ||
               '�� ��������� �� �������� "����� � ��������"=' || num_noload || CHR(10) ||
               '�� ��������� �����=' || count_osago_assured_temp;
  END;

END Pkg_Load_From_Csv;
/
