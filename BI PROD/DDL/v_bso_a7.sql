CREATE OR REPLACE FORCE VIEW V_BSO_A7 AS
select bh.reg_date "Дата привязки БСО",
       b.num "Номер БСО",
       'Использован' "Статус БСО",
       ent.obj_name('CONTACT',pkg_policy.get_policy_contact(p.policy_id, 'Страхователь')) "Страхователь",
       p.pol_num "Номер ДС",
       tp.description "Продукт"
  from bso           b,
       bso_series    bs,
       bso_type      bt,
       bso_hist      bh,
       bso_hist_type bht,
       p_policy      p,
       p_pol_header  ph,
       t_product     tp
 where bs.bso_series_id = b.bso_series_id
   and bt.bso_type_id = bs.bso_type_id
   and bt.brief = 'A7'
   and bh.bso_id = b.bso_id --текущее состояние БСО может быть изменено
   and bht.bso_hist_type_id = bh.hist_type_id
   and bht.brief = 'Использован'
   and ph.policy_header_id = b.pol_header_id
   and p.policy_id = ph.policy_id
   and tp.product_id = ph.product_id
   and bh.reg_date between (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_a7' and param_name = 'start_date')
                          and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_a7' and param_name = 'end_date')
;

