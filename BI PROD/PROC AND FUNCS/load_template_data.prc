CREATE OR REPLACE PROCEDURE load_template_data
IS
--Курсор временной таблицы
   CURSOR cur_casco_assured_temp
   IS
      SELECT     *
            FROM casco_assured_temp
           WHERE is_load = '1'
      FOR UPDATE;

--
   row_p_asset_header   p_asset_header%ROWTYPE;
   row_ven_as_asset     ven_as_asset%ROWTYPE;
   row_ven_as_vehicle   ven_as_vehicle%ROWTYPE;
   row_ven_p_cover      ven_p_cover%ROWTYPE;
--
   tmp_val              NUMBER (3);
BEGIN
   FOR rec_casco_temp IN cur_casco_assured_temp
   LOOP
      BEGIN
         --p_asset_header
         SELECT sq_p_asset_header.NEXTVAL
           INTO row_p_asset_header.p_asset_header_id
           FROM DUAL;

         row_p_asset_header.t_asset_type_id := 1;

         --:parameter.T_asset_type_id;
         SELECT ent_id
           INTO row_p_asset_header.ent_id
           FROM entity
          WHERE brief = 'P_ASSET_HEADER';

         INSERT INTO p_asset_header
              VALUES row_p_asset_header;

         --ven_as_asset
         SELECT sq_as_asset.NEXTVAL
           INTO row_ven_as_asset.as_asset_id
           FROM DUAL;

         SELECT status_hist_id
           INTO row_ven_as_asset.status_hist_id
           FROM status_hist
          WHERE brief = 'NEW';

         row_ven_as_asset.p_asset_header_id :=
                                          row_p_asset_header.p_asset_header_id;
         row_ven_as_asset.p_policy_id := 1;          --:parameter.p_policy_id;
         row_ven_as_asset.contact_id := 1;            --:parameter.contact_id;
         row_ven_as_asset.ins_amount := NVL (rec_casco_temp.ins_amount1, 0);
         row_ven_as_asset.ins_premium :=
              NVL (rec_casco_temp.premium1, 0)
            + NVL (rec_casco_temp.premium2, 0)
            + NVL (rec_casco_temp.premium3, 0)
            + NVL (rec_casco_temp.premium4, 0)
            + NVL (rec_casco_temp.premium5, 0);

         SELECT start_date, end_date
           INTO row_ven_as_asset.start_date, row_ven_as_asset.end_date
           FROM p_policy
          WHERE policy_id = 1;                       --:parameter.p_policy_id;

         row_ven_as_asset.ins_price := rec_casco_temp.basic_sur_amt;

         INSERT INTO ven_as_asset
              VALUES row_ven_as_asset;

         --ven_as_vehicle
           --ven_as_vehicle
           --as_vehicle
         SELECT sq_as_vehicle.NEXTVAL
           INTO row_ven_as_vehicle.as_vehicle_id
           FROM DUAL;

         row_ven_as_vehicle.t_vehicle_mark_id :=
                                              rec_casco_temp.t_vehicle_mark_id;
         row_ven_as_vehicle.model_year :=
                                         TO_NUMBER (rec_casco_temp.model_year);
         row_ven_as_vehicle.t_vehicle_type_id :=
                                                rec_casco_temp.vehicle_type_id;
         --row_ven_as_vehicle.is_foreing_reg:=0;
         --row_ven_as_vehicle.is_to_reg:=0;
         --row_ven_as_vehicle.is_rent:=0;
         row_ven_as_vehicle.pts_s := rec_casco_temp.pts_s;
         row_ven_as_vehicle.pts_n := rec_casco_temp.pts_n;

         --row_ven_as_vehicle.is_driver_no_lim:=0;
         SELECT   ca.ID, DECODE (a.brief, 'CONST', 1, 2) tmp
             INTO row_ven_as_vehicle.cn_contact_address_id, tmp_val
             FROM ven_cn_contact_address ca, ven_t_address_type a
            WHERE ca.contact_id = 1                   --:parameter.contact_id;
              AND a.ID = ca.address_type
              AND ROWNUM = 1
         ORDER BY tmp;

         /*row_ven_as_vehicle.is_violation:=0;
         row_ven_as_vehicle.is_sng_reg:=0;
         row_ven_as_vehicle.is_right_handed:=0;
         row_ven_as_vehicle.is_new:=1;*/
         IF rec_casco_temp.is_damage = 'Да'
         THEN
            row_ven_as_vehicle.is_damage := 1;
         ELSE
            row_ven_as_vehicle.is_damage := 0;
         END IF;

         row_ven_as_vehicle.license_plate := rec_casco_temp.license_plate;
         row_ven_as_vehicle.vin := rec_casco_temp.vin;
         row_ven_as_vehicle.basic_sur_amt :=
                                      TO_NUMBER (rec_casco_temp.basic_sur_amt);
         row_ven_as_vehicle.t_main_model_id := rec_casco_temp.t_main_model_id;
         row_ven_as_vehicle.reg_n := TO_NUMBER (rec_casco_temp.reg_n);
         row_ven_as_vehicle.wear := rec_casco_temp.wear;

         INSERT INTO ven_as_vehicle
              VALUES row_ven_as_vehicle;

         --Автокаско
         IF     (rec_casco_temp.ins_amount1 IS NOT NULL)
            AND (rec_casco_temp.ins_amount2 IS NOT NULL)
         THEN
            SELECT sq_p_cover.NEXTVAL
              INTO row_ven_p_cover.p_cover_id
              FROM DUAL;

            row_ven_p_cover.as_asset_id := row_ven_as_asset.as_asset_id;

            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM p_policy pol,
                   p_pol_header polh,
                   t_product p,
                   t_product_version pv,
                   t_product_ver_lob pvl,
                   t_product_line pl,
                   t_prod_line_option plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = 55071              --:parameter.p_policy_id
               AND pv.version_nr = (SELECT MAX (t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = 'Автокаско';

            row_ven_p_cover.status_hist_id := row_ven_as_asset.status_hist_id;
            row_ven_p_cover.start_date := row_ven_as_asset.start_date;
            row_ven_p_cover.end_date := row_ven_as_asset.end_date;
            row_ven_p_cover.ins_amount := rec_casco_temp.ins_amount1;
            row_ven_p_cover.premium := rec_casco_temp.premium1;
            row_ven_p_cover.tariff := rec_casco_temp.tariff1;
            row_ven_p_cover.t_deductible_type_id :=
                                          rec_casco_temp.t_deductible_type_id1;
            row_ven_p_cover.t_deduct_val_type_id :=
                                          rec_casco_temp.t_deduct_val_type_id1;
            row_ven_p_cover.deductible_value :=
                                              rec_casco_temp.deductible_value1;
            row_ven_p_cover.ins_price := rec_casco_temp.basic_sur_amt;

            INSERT INTO ven_p_cover
                 VALUES row_ven_p_cover;
         END IF;

         --Ущерб
         IF     (rec_casco_temp.ins_amount1 IS NULL)
            AND (rec_casco_temp.ins_amount2 IS NOT NULL)
         THEN
            SELECT sq_p_cover.NEXTVAL
              INTO row_ven_p_cover.p_cover_id
              FROM DUAL;

            row_ven_p_cover.as_asset_id := row_ven_as_asset.as_asset_id;

            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM p_policy pol,
                   p_pol_header polh,
                   t_product p,
                   t_product_version pv,
                   t_product_ver_lob pvl,
                   t_product_line pl,
                   t_prod_line_option plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = 55071              --:parameter.p_policy_id
               AND pv.version_nr = (SELECT MAX (t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = 'Ущерб';

            row_ven_p_cover.status_hist_id := row_ven_as_asset.status_hist_id;
            row_ven_p_cover.start_date := row_ven_as_asset.start_date;
            row_ven_p_cover.end_date := row_ven_as_asset.end_date;
            row_ven_p_cover.ins_amount := rec_casco_temp.ins_amount2;
            row_ven_p_cover.premium := rec_casco_temp.premium2;
            row_ven_p_cover.tariff := rec_casco_temp.tariff2;
            row_ven_p_cover.t_deductible_type_id :=
                                          rec_casco_temp.t_deductible_type_id2;
            row_ven_p_cover.t_deduct_val_type_id :=
                                          rec_casco_temp.t_deduct_val_type_id2;
            row_ven_p_cover.deductible_value :=
                                              rec_casco_temp.deductible_value2;
            row_ven_p_cover.ins_price := rec_casco_temp.basic_sur_amt;

            INSERT INTO ven_p_cover
                 VALUES row_ven_p_cover;
         END IF;

         --Гражданская ответственность
         IF (rec_casco_temp.ins_amount3 IS NOT NULL)
         THEN
            SELECT sq_p_cover.NEXTVAL
              INTO row_ven_p_cover.p_cover_id
              FROM DUAL;

            row_ven_p_cover.as_asset_id := row_ven_as_asset.as_asset_id;

            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM p_policy pol,
                   p_pol_header polh,
                   t_product p,
                   t_product_version pv,
                   t_product_ver_lob pvl,
                   t_product_line pl,
                   t_prod_line_option plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = 55071              --:parameter.p_policy_id
               AND pv.version_nr = (SELECT MAX (t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = 'Гражданская ответственность';

            row_ven_p_cover.status_hist_id := row_ven_as_asset.status_hist_id;
            row_ven_p_cover.start_date := row_ven_as_asset.start_date;
            row_ven_p_cover.end_date := row_ven_as_asset.end_date;
            row_ven_p_cover.ins_amount := rec_casco_temp.ins_amount3;
            row_ven_p_cover.premium := rec_casco_temp.premium3;
            row_ven_p_cover.tariff := rec_casco_temp.tariff3;
            row_ven_p_cover.t_deductible_type_id :=
                                          rec_casco_temp.t_deductible_type_id3;
            row_ven_p_cover.t_deduct_val_type_id :=
                                          rec_casco_temp.t_deduct_val_type_id3;
            row_ven_p_cover.deductible_value :=
                                              rec_casco_temp.deductible_value3;
            row_ven_p_cover.ins_price := rec_casco_temp.basic_sur_amt;

            INSERT INTO ven_p_cover
                 VALUES row_ven_p_cover;
         END IF;

         --Дополнительное оборудование
         IF (rec_casco_temp.ins_amount4 IS NOT NULL)
         THEN
            SELECT sq_p_cover.NEXTVAL
              INTO row_ven_p_cover.p_cover_id
              FROM DUAL;

            row_ven_p_cover.as_asset_id := row_ven_as_asset.as_asset_id;

            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM p_policy pol,
                   p_pol_header polh,
                   t_product p,
                   t_product_version pv,
                   t_product_ver_lob pvl,
                   t_product_line pl,
                   t_prod_line_option plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = 55071              --:parameter.p_policy_id
               AND pv.version_nr = (SELECT MAX (t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = 'Дополнительное оборудование';

            row_ven_p_cover.status_hist_id := row_ven_as_asset.status_hist_id;
            row_ven_p_cover.start_date := row_ven_as_asset.start_date;
            row_ven_p_cover.end_date := row_ven_as_asset.end_date;
            row_ven_p_cover.ins_amount := rec_casco_temp.ins_amount4;
            row_ven_p_cover.premium := rec_casco_temp.premium4;
            row_ven_p_cover.tariff := rec_casco_temp.tariff4;
            row_ven_p_cover.t_deductible_type_id :=
                                          rec_casco_temp.t_deductible_type_id4;
            row_ven_p_cover.t_deduct_val_type_id :=
                                          rec_casco_temp.t_deduct_val_type_id4;
            row_ven_p_cover.deductible_value :=
                                              rec_casco_temp.deductible_value4;
            row_ven_p_cover.ins_price := rec_casco_temp.basic_sur_amt;

            INSERT INTO ven_p_cover
                 VALUES row_ven_p_cover;
         END IF;

         --Несчастные случаи
         IF (rec_casco_temp.ins_amount5 IS NOT NULL)
         THEN
            SELECT sq_p_cover.NEXTVAL
              INTO row_ven_p_cover.p_cover_id
              FROM DUAL;

            row_ven_p_cover.as_asset_id := row_ven_as_asset.as_asset_id;

            SELECT plo.ID
              INTO row_ven_p_cover.t_prod_line_option_id
              FROM p_policy pol,
                   p_pol_header polh,
                   t_product p,
                   t_product_version pv,
                   t_product_ver_lob pvl,
                   t_product_line pl,
                   t_prod_line_option plo
             WHERE polh.policy_header_id = pol.pol_header_id
               AND p.product_id = polh.product_id
               AND pv.product_id = p.product_id
               AND pvl.product_version_id = pv.t_product_version_id
               AND pl.product_ver_lob_id = pvl.t_product_ver_lob_id
               AND plo.product_line_id = pl.ID
               AND pol.policy_id = 55071              --:parameter.p_policy_id
               AND pv.version_nr = (SELECT MAX (t1.version_nr)
                                      FROM t_product_version t1
                                     WHERE t1.product_id = p.product_id)
               AND pl.description = 'Несчастные случаи';

            row_ven_p_cover.status_hist_id := row_ven_as_asset.status_hist_id;
            row_ven_p_cover.start_date := row_ven_as_asset.start_date;
            row_ven_p_cover.end_date := row_ven_as_asset.end_date;
            row_ven_p_cover.ins_amount := rec_casco_temp.ins_amount5;
            row_ven_p_cover.premium := rec_casco_temp.premium5;
            row_ven_p_cover.tariff := rec_casco_temp.tariff5;
            row_ven_p_cover.t_deductible_type_id :=
                                          rec_casco_temp.t_deductible_type_id5;
            row_ven_p_cover.t_deduct_val_type_id :=
                                          rec_casco_temp.t_deduct_val_type_id5;
            row_ven_p_cover.deductible_value :=
                                              rec_casco_temp.deductible_value5;
            row_ven_p_cover.ins_price := rec_casco_temp.basic_sur_amt;

            INSERT INTO ven_p_cover
                 VALUES row_ven_p_cover;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END LOOP;
END;
/

