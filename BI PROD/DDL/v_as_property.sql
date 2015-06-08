CREATE OR REPLACE FORCE VIEW V_AS_PROPERTY AS
SELECT p.as_property_id, p.p_policy_id, p.status_hist_id,
          p.p_asset_header_id, p.contact_id,
          ent.obj_name (ent.id_by_brief ('CONTACT'), p.contact_id) contact,
          p.cn_address_id,
          ent.obj_name (ent.id_by_brief ('CN_ADDRESS'),
                        p.cn_address_id
                       ) cn_address,
          p.lodger_type_id, ins_premium,
/*       (select description
          from ven_t_lodger_type
         where t_lodger_type_id = p.lodger_type_id) lodger_type,*/
/*       p.basement_type_id,
       (select description
          from ven_t_basement_type_ross
         where t_basement_type_ross_id = p.basement_type_id) basement_type,*/
                                        p.decor_material_id,
          (SELECT description
             FROM ven_t_bld_material
            WHERE t_bld_material_id = p.decor_material_id) decor_material,
          
/*       p.heating_type_id,
       (select description
          from ven_t_heating_type
         where t_heating_type_id = p.heating_type_id) heating_type,*/
          p.roofing_material_id,
          (SELECT description
             FROM ven_t_bld_material
            WHERE t_bld_material_id = p.roofing_material_id) roofing_material,
          p.floor_material_id,
          (SELECT description
             FROM ven_t_bld_material
            WHERE t_bld_material_id = p.floor_material_id) floor_material,
          p.wall_material_id,
          (SELECT description
             FROM ven_t_bld_material
            WHERE t_bld_material_id = p.wall_material_id) wall_material,
          p.neibour_building_id,
          (SELECT description
             FROM ven_t_neibour_building
            WHERE t_neibour_building_id =
                                       p.neibour_building_id)
                                                             neibour_building,
          p.deduct_type_id, (SELECT description
                               FROM t_deductible_type
                              WHERE ID = p.deduct_type_id) deduct_type,
          p.deduct_type_value_id,
          (SELECT description
             FROM t_deduct_val_type
            WHERE ID = p.deduct_type_value_id) deduct_type_value,
          p.deduct_value,
          (SELECT description
             FROM t_warehouse_code
            WHERE t_warehouse_code_id = p.t_warehouse_code_id) warehouse_code,
          p.t_warehouse_code_id,
          (SELECT    description
                  || ' (класс риска "'
                  || risk_class
                  || '")' description
             FROM t_act_type_code
            WHERE code = p.act_type_code) act_type_descr,
          p.act_type_code,
          (SELECT code || ' - ' || description
             FROM t_build_construct
            WHERE t_build_construct_id =
                               p.t_build_construct_id)
                                                      t_build_construct_descr,
          p.t_build_construct_id, p.t_warehouse_space_id,
          p.t_warehouse_height_id, p.packing_type,
          (SELECT description
             FROM v_warehouse_types_code
            WHERE num = p.packing_type
              AND t_warehouse_code_id = p.t_warehouse_code_id)
                                                          packing_types_descr,
          p.YEAR, p.square, p.year_last_major_repairs, p.stuff_placing_floor,
          p.is_seismic_activity, p.is_warehouse, p.is_has_sprinkler,
          p.is_has_risky_work, p.building_functional, p.floor_count,
          p.is_has_bsmt_loft, p.is_decoration, p.system_fire,
          (SELECT f.brief
             FROM p_policy pp, fund f, p_pol_header ph
            WHERE pp.policy_id = p.p_policy_id
              AND f.fund_id = ph.fund_id
              AND ph.policy_header_id = pp.pol_header_id) fund_brief,
          p.note, p.ins_price, p.ins_amount, p.start_date, p.end_date,
          p.is_first_event, p.t_guard_id,
          (SELECT g.NAME
             FROM ven_t_guard g
            WHERE g.t_guard_id = p.t_guard_id) guard_name, p.guard_col,
          p.is_signalling, p.t_system_signalling_id,
          (SELECT s.NAME
             FROM ven_t_system_signalling s
            WHERE s.t_system_signalling_id =
                                           p.t_system_signalling_id)
                                                                    sign_name,
          p.barrier, p.t_pult_signalling_id,
          (SELECT pl.NAME
             FROM ven_t_pult_signalling pl
            WHERE pl.t_pult_signalling_id = p.t_pult_signalling_id) pult_name,
          p.is_fire_wall, p.ownership, p.distance_fire_station,
          p.use_inflam_mat, p.is_tornado, p.is_vulcan, p.is_drought,
          p.is_precipitation, p.is_inundation, p.is_landslip,
          p.is_rise_level_water, p.pml, p.pml_calculated,
          p.t_zone_earthquake_id, p.t_zone_storm_id, p.is_fireproof,
          p.is_primary, p.assignment, p.titul_period, p.NAME
     FROM ven_as_property p;

