create or replace force view ve_attr_col as
select a.attr_id,
       a.ent_id,
       a.source,
       decode(att.brief, 'UR', replace(a.col_name, '_URE_ID', tur.s), a.col_name) col_name,
       case
         when att.brief = 'OI' then 1
         when att.brief = 'OE' then 2
         when att.brief = 'OF' then 3
         when a.col_name = 'EXT_ID' then 4
         else tc.column_id * 10
       end col_order,
       a.is_trans,
       att.brief attr_type_brief,
       tc.nullable is_null
from attr a 
     inner join attr_type att on att.attr_type_id = a.attr_type_id 
     left outer join ( select '_URE_ID' s from dual
                       union all
                       select '_URO_ID' s from dual
                     ) tur on att.brief = 'UR'
     left outer join user_tab_columns tc on tc.table_name = a.source
                                            and tc.column_name = a.col_name;

