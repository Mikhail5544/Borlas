create or replace force view ve_error_fk2_not_ix as
select table_name,
       constraint_name, 
       namel || nvl2(name2, ',' || name2, null) || nvl2(name3, ',' || name3, null) 
         || nvl2(name4, ',' || name4, null) || nvl2(name5, ',' || name5, null) 
         || nvl2(name6, ',' || name6, null) || nvl2(name7, ',' || name7, null) 
         || nvl2(name8, ',' || name8, null) column_name
from ( select b.table_name,
              b.constraint_name,
              max(decode(position, 1, column_name, null)) namel,
              max(decode(position, 2, column_name, null)) name2,
              max(decode(position, 3, column_name, null)) name3,
              max(decode(position, 4, column_name, null)) name4,
              max(decode(position, 5, column_name, null)) name5,
              max(decode(position, 6, column_name, null)) name6,
              max(decode(position, 7, column_name, null)) name7,
              max(decode(position, 8, column_name, null)) name8,
              count(*) col_cnt
       from ( select substr(table_name, 1, 30) table_name,
                     substr(constraint_name, 1, 30) constraint_name,
                     substr(column_name, 1, 30) column_name,
                     position
              from tmp_ucc
            ) a,
            tmp_uc b
            inner join tmp_uc uc_r on uc_r.owner = b.r_owner and uc_r.constraint_name = b.r_constraint_name 
            inner join tmp_uc uc_rt on uc_rt.owner = uc_r.owner and uc_rt.table_name = uc_r.table_name     
       where a.constraint_name = b.constraint_name
             and b.constraint_type = 'R'
       group by b.table_name, b.constraint_name
     ) cons
where col_cnt > ALL( select count(*)
                     from tmp_uic i
                     where i.table_name = cons.table_name
                           and i.column_name in (namel, name2, name3, name4, name5, name6, name7, name8)
                           and i.column_position <= cons.col_cnt
                     group by i.index_name
                   );

