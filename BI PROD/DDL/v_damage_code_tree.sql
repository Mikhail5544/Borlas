create or replace view v_damage_code_tree as
select dc.id,
       dc.parent_id,
       dc.code,
       dc.description,
       dc.peril,
       dc.limit_val,
       pc.p_cover_id,
       plo.description pl_name
-- Áàéòèí À.
      ,ig.brief as ig_brief,
--
       pkg_claim.get_lim_amount(dc.id, pc.p_cover_id) limit_amount,
       pc.start_date,
       pc.end_date,
       dt.c_damage_type_id,
       dt.description c_damage_type_name,
       dt.brief c_damage_type_brief,
       dct.c_damage_cost_type_id c_damage_cost_type_id,
       dct.description c_damage_cost_type_name,
       dct.brief c_damage_cost_type_brief,
       pc.as_asset_id
  from p_cover               pc,
       t_prod_line_option    plo,
       t_prod_line_opt_peril plop,
       t_damage_code         dc,
       c_damage_type         dt,
       c_damage_cost_type    dct
-- Áàéòèí À.
      ,ven_t_peril           pe
      ,ven_t_insurance_group ig
--
 where plo.id = pc.t_prod_line_option_id
   and pc.t_prod_line_option_id = plop.product_line_option_id
   and dc.peril = plop.peril_id
   AND decode(dc.is_insurance,0,2,dc.is_insurance) = dt.c_damage_type_id
   AND decode(dc.Is_Refundable,0,2,dc.Is_Refundable) = dct.c_damage_cost_type_id
-- Áàéòèí À.
   and plop.peril_id         = pe.id
   and pe.insurance_group_id = ig.t_insurance_group_id
--
--Íàğêîìàíû????
/*   and ((dc.is_insurance = 1 and dt.brief = 'ÑÒĞÀÕÎÂÎÉ' and
       ((dc.is_refundable = 1 and dct.brief = 'ÂÎÇÌÅÙÀÅÌÛÅ') or
       (dc.is_refundable = 0 and dct.brief = 'ÍÅÂÎÇÌÅÙÀÅÌÛÅ'))) or
       (dc.is_insurance = 0 and dt.brief = 'ÄÎÏĞÀÑÕÎÄ' and
       ((dc.is_refundable = 1 and dct.brief = 'ÂÎÇÌÅÙÀÅÌÛÅ') or
       (dc.is_refundable = 0 and dct.brief = 'ÍÅÂÎÇÌÅÙÀÅÌÛÅ'))))
*/    and not exists (select 1
          from t_prod_line_damage pld
         where 1 = 1
           and pld.t_prod_line_opt_peril_id = plop.id
           and pld.t_damage_code_id = dc.id
           and pld.is_excluded = 1);
