CREATE OR REPLACE FORCE VIEW V_BSO_REGION AS
select a."Агентство",
       a."Статус",
       tt.name "Тип БСО",
       count(a.bso_id) "Количество"
 from (select dep.name "Агентство",
              case when b.policy_id is not null and ht.name <> 'Испорчен' then 'Использован' else ht.name end  "Статус",
              bh.bso_id,
              row_number()over (partition by bh.bso_id order by bh.hist_date desc, bh.num desc) c
         from bso_hist      bh,
              bso_hist_type ht,
              department    dep,
              bso           b,
              p_policy      pp
        where ht.bso_hist_type_id = bh.hist_type_id
          and bh.department_id    = dep.department_id
          and ((ht.name in ('Передан',
                          'Выдан',
                          'Возвращен',
                          'Испорчен',
                          'Утерян',
                          'Списан',
                          'Уничтожен')
               and bh.hist_date between (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name='bso_region' and param_name='DATE_FROM')
                                    and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name='bso_region' and param_name='DATE_TO')
              )
              or pp.notice_date between (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name='bso_region' and param_name='DATE_FROM')
                                    and (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name='bso_region' and param_name='DATE_TO')
              )
          and dep.name IN (SELECT r.param_value FROM ins_dwh.rep_param r WHERE r.rep_name = 'bso_region' AND r.param_name = 'AGENCY')
          and b.bso_id = bh.bso_id
          and b.policy_id = pp.policy_id (+)
      ) a,
      bso        b,
      bso_series ser,
      bso_type   tt
where a.c = 1
  and b.bso_id = a.bso_id
  and ser.bso_series_id = b.bso_series_id
  and tt.bso_type_id    = ser.bso_type_id
group by a."Агентство",a."Статус",tt.name;

