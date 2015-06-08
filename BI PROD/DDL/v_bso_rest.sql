create or replace force view v_bso_rest as
select "BSO_HIST_ID","ENT_ID","FILIAL_ID","BSO_ID","HIST_DATE","CONTACT_ID","HIST_TYPE_ID","NUM","BSO_DOC_CONT_ID","DEPARTMENT_ID","IS_HANDS","LAST_DATE"
          from (select bh.*,
                       'Да' is_hands,
                       lead(bh.hist_date, 1, to_date('31122999', 'DDMMYYYY')) over(partition by bh.bso_id order by bh.num) last_date
                  from bso_hist bh
                union all
                select bh.*,
                       'Нет' is_hands,
                       lead(bh.hist_date, 1, to_date('31122999', 'DDMMYYYY')) over(partition by bh.bso_id order by bh.num) last_date
                  from (select b.*
                          from bso_hist b, bso_hist_type bht
                         where b.hist_type_id = bht.bso_hist_type_id
                           and bht.brief <> 'Выдан') bh)
         where hist_date <> last_date
           and contact_id is not null;

