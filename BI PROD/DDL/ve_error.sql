create or replace force view ve_error as
select 1 n,
       null ent_id,
       'Нарушено соглашение о наименованиях для объекта "' || o.object_name || '" типа "' || o.object_type || '"' error
from tmp_uo o
where (o.object_type = 'FUNCTION'  and not(o.object_name like 'FN\_%' escape '\' or o.object_name like 'FNI\_%' escape '\'))
   or (o.object_type = 'PROCEDURE' and not(o.object_name like 'SP\_%' escape '\' or o.object_name like 'SPU\_%' escape '\'))
   or (o.object_type = 'SEQUENCE'  and o.object_name not like 'SQ\_%' escape '\' 
                                   and not exists (select 1 from check_excl ce where ce.excl_type in ('DEV_SQ'))
      )                          
   or (o.object_type = 'TRIGGER'   and not(o.object_name like 'TR%\_%' escape '\' or o.object_name like 'TRE\_%' escape '\' or o.object_name like 'TREV\_%' escape '\'))
   or (o.object_type = 'TYPE'      and not(o.object_name like 'TT\_%' escape '\' or o.object_name like 'TO\_%' escape '\' or o.object_name like 'SYS\_PLSQL\_%' escape '\'))
   or (o.object_type = 'VIEW'      and not(o.object_name like 'V\_%' escape '\' or o.object_name like 'VE\_%' escape '\' or o.object_name like 'VEN\_%' escape '\'))
   or (o.object_type = 'INDEX'     and not( o.object_name like 'IX\_%' escape '\' 
                                            or o.object_name like 'PK\_%' escape '\' 
                                            or o.object_name like 'UK\_%' escape '\'
                                          )
                                   and not exists ( select 1
                                                    from user_indexes ui
                                                    inner join ve_dev_tables dt on ui.table_name = dt.name                                          
                                                  )
      )
union all
select 2 n, 
       null ent_id,
      'Нарушено соглашение о наименованиях для объекта "' || c.constraint_name || '" типа "' || c.constraint_type || '"' error
from tmp_uc c
where c.generated = 'USER NAME'
      and (
            ( c.constraint_type = 'C' and not( c.constraint_name = 'CHE_' || c.table_name
                                               or ents.check_name(c.constraint_name, 'CH_', c.table_name) = 1
                                             )
            )
            or (c.constraint_type = 'P' and c.constraint_name <> 'PK_' || substr(c.table_name, 1, 27))
            or ( c.constraint_type = 'R' and not( c.constraint_name = 'FKI_' || c.table_name
                                                  or ents.check_name(c.constraint_name, 'FK_', c.table_name) = 1
                                                  or ents.check_name(c.constraint_name, 'UK_', c.table_name) = 1
                                                )  
               )
            or (c.constraint_type = 'U' and ents.check_name(c.constraint_name, 'UK_', c.table_name) <> 1)
          ) 
union all
select 3 n,
       null ent_id,
       'Нарушено соглашение о наименованиях для поля "' || cc.column_name || '", идентифицирующего запись таблицы "' 
       || cc.table_name || '"' error
from tmp_ucc cc
     inner join tmp_uc c on c.constraint_name = cc.constraint_name
                            and c.table_name = cc.table_name
                            and c.constraint_type = 'P'
where cc.position = 1
      and cc.column_name <> cc.table_name || '_ID'
      and cc.table_name not in ('ENTITY', 'UREF')
      and not exists (select 1 from ve_dev_tables dt where dt.name = cc.table_name)
      -- Это можно отключить
      and not exists (select 1 from entity e where e.source = cc.table_name and e.id_name = cc.column_name)
-- Таблицы
union all
select 4 n,
       e.ent_id ent_id,
       'Сущность "' || e.name || '" не имеет соответствующей таблицы "' || e.source || '"' error
from entity e
where e.source not in (select t.table_name from tmp_ut t)
union all
select 5 n,
       null,
       'Таблица "' || t.table_name || '" не описана как сущность'
from tmp_ut t
where t.table_name not in ( select e.source from entity e 
                            union all 
                            select name from ve_tables
                            union all
                            select name from ve_dev_tables
                            union all
                            select name from check_excl ce where ce.excl_type = 'USER'
                            union all
                            select name from check_excl ce where ce.excl_type = 'RESERV'                            
                          ) 
-- Поля
union all
select 6 n,
       e.ent_id,
       'Сущность "' || e.name || '" не имеет поля "' || e.source || '_ID" Сущность "' || e.name || '" не имеет поля "' || e.id_name || '" или оно не соответсвует типу "NUMBER NOT NULL" или NUMBER(3/6/9) NOT NULL"'
from entity e 
     inner join tmp_ut t on t.table_name = e.source
where not exists ( select 1
                   from tmp_utc tc
                   where tc.table_name = e.source 
                         and (tc.column_name = e.source || '_ID' or e.source in ( select ce.name 
                                                                                  from check_excl ce 
                                                                                  where ce.excl_type = 'EXCL_ID')
                                                                                )
                         and data_type = 'NUMBER' 
                         and (tc.data_precision is null or tc.data_precision in (3,6,9))
                         and (tc.data_scale is null or tc.data_scale = 0)
                         and tc.nullable = 'N'
                 )
/*                        
select 6 n,
       e.ent_id,
       'Сущность "' || e.name || '" не имеет поля "' || e.id_name || '" или оно не соответсвует типу "NUMBER NOT NULL" или NUMBER(9) NOT NULL'
from entity e inner join tmp_ut t on t.table_name = e.source
where not exists ( select 1
                   from tmp_utc tc
                   where tc.table_name = e.source 
                         and tc.column_name = e.id_name
                         and data_type = 'NUMBER' 
                         and (tc.data_precision is null or tc.data_precision in (9))
                         and (tc.data_scale is null or tc.data_scale = 0)
                         and tc.nullable = 'N')
*/                         
union all
select 7 n,
       e.ent_id,
       'Сущность "' || e.name || '" не имеет поля "ENT_ID" или оно не соответсвует типу "NUMBER(6) NOT NULL"'
from entity e 
     inner join tmp_ut t on t.table_name = e.source
where e.parent_id is null 
      and not exists ( select 1
                       from tmp_utc tc
                       where tc.table_name = e.source and tc.column_name = 'ENT_ID' and
                             data_type = 'NUMBER' and tc.data_precision = 6 and tc.nullable = 'N'
                     )
union all
select 8 n,
       e.ent_id,
       'Сущность "' || e.name || '" не имеет поля "FILIAL_ID" или оно не соответсвует типу "NUMBER(6) NULL"'
from entity e 
     inner join tmp_ut t on t.table_name = e.source
where not exists ( select 1
                   from tmp_utc tc
                   where tc.table_name = e.source and tc.column_name = 'FILIAL_ID' and
                         data_type = 'NUMBER' and tc.data_precision = 6 and tc.nullable = 'Y'
                 )
union all
select 9 n,
       e.ent_id,
       'Сущность "' || e.name || '" имеет поле "ENT_ID"'
from entity e 
     inner join tmp_ut t on t.table_name = e.source
where e.parent_id is not null 
      and exists ( select 1
                   from tmp_utc tc
                   where tc.table_name = e.source and tc.column_name = 'ENT_ID'
                 )
union all
select 10 n,
       e.ent_id,
       'Неопределено наименование объекта для сущности "' || e.name || '"'
from entity e
where e.parent_id is null and e.obj_name is null and e.uref = 1
-- Первичные и внешние ключи
union all
select 11 n,
       e.ent_id,
       'Отсутствует первичный ключ "PK_' || e.source || '" сущности "' || e.name || '"'
from entity e inner join tmp_utc tc on tc.table_name = e.source and tc.column_name = e.source || '_ID'
where not exists (select *
       from tmp_uc c
       where c.constraint_type = 'P' and c.table_name = e.source and
             c.constraint_name = 'PK_' || e.source)       
union all             
select 12 n,
       e.ent_id,
       'Отсутствует внешний ключ "FKI_' || e.source || '" для унаследованной сущности "' || e.name || '"'
from entity e inner join tmp_utc tc on tc.table_name = e.source and tc.column_name = e.source || '_ID'
where e.parent_id is not null and not exists
 (select *
       from tmp_uc c
       where c.constraint_type = 'R' and c.table_name = e.source and
             c.constraint_name = 'FKI_' || e.source)       
-- Проверки
union all
select 13 n,
       e.ent_id,
       'Отсутствует проверка "CHE_' || e.source || '" поля "ENT_ID" сущности "' || e.name || '"'
from entity e
where e.parent_id is null and not exists (select *
       from tmp_uc c
       where c.constraint_type = 'C' and c.table_name = e.source and
             c.constraint_name = 'CHE_' || e.source)
-- Последовательности
union all
select 14 n,
       e.ent_id,
       'Отсутствует последовательность "SQ_' || e.source || '" для сущности "' || e.name || '"'
from entity e
where e.parent_id is null 
      and not exists ( select 1 from user_sequences s
                       where s.sequence_name = 'SQ_' || e.source
                     )
union all       
select 15 n,
       e.ent_id,
       'Отсутствует синоним "SQ_' || e.source || '" последовательности "SQ_' || pe.source || '"'
from entity e left outer join entity pe on pe.ent_id = e.parent_id
where e.parent_id is not null 
      and not exists ( select *
                       from user_synonyms s
                       where s.synonym_name = 'SQ_' || e.source 
                             and s.table_name = 'SQ_' || pe.source)
union all       
select 16 n,
       null,
       'Отсутствует таблица для последовательности "' || s.sequence_name || '"'
from user_sequences s
where not exists (select * from tmp_ut t where 'SQ_' || t.table_name = s.sequence_name)
      and not exists (select 1 from check_excl ce where ce.excl_type in ('DEV_SQ', 'ENT_SQ'))
union all
select 17 n,
       null,
       'Отсутствует таблица для синонима "' || s.synonym_name || '" последовательности'
from user_synonyms s
where s.synonym_name like 'SQ\_' escape '\' and not exists (select *
       from tmp_ut t
       where 'SQ_' || t.table_name = s.synonym_name)
-- Триггеры
union all
select 18 n,
       e.ent_id ent_id,
       'Сущность "' || e.name || '" не имеет триггера "TRE_' || e.source || '"' error
from entity e
where (e.uref = 1 or exists
       (select *
        from tmp_utc tc
        where tc.table_name = e.source
        and substr(tc.column_name, length(tc.column_name) - 6, 7) in ('_URE_ID', '_URO_ID')))
       and not exists (select * from tmp_uo o where o.object_type = 'TRIGGER' and o.object_name = 'TRE_' || e.source)
union all
select 19 n,
       e.ent_id ent_id,
       'Триггер "TRE_' || e.source || '" cущности "' || e.name || '" INVALID' error
from entity e
inner join tmp_uo o on o.object_type = 'TRIGGER'
                      and o.object_name = 'TRE_' || e.source
 where(e.uref = 1
                             or exists (select *
                                    from tmp_utc tc
                                    where tc.table_name = e.source
                                    and substr(tc.column_name, length(tc.column_name) - 6, 7) in
                                          ('_URE_ID', '_URO_ID')))
                      and o.status = 'INVALID'
-- Комментарии
union all
select 20 n,
       e.ent_id ent_id,
       'Отсутствует комментарий к колонке "' || cm.column_name || '" cущности "' || e.name || '"' error
from entity e
inner join user_col_comments cm on cm.table_name = e.source where cm.comments is null
-- Ссылки
union all
select 21 n,
       e.ent_id ent_id,
       'Отсутствует внешний ключ для поля ссылки "' || a.col_name || '" cущности "' || e.name || '"' error
from attr a
     inner join attr_type aty on aty.attr_type_id = a.attr_type_id
     inner join entity e on e.ent_id = a.ent_id
where aty.brief = 'R'
      and a.brief <> 'EXT_ID'
      and not exists (select *
                      from tmp_ucc cc
                           inner join tmp_uc c on 
                             c.constraint_type = 'R' and c.constraint_name = cc.constraint_name
                      where cc.position = 1 and cc.table_name = a.source and cc.column_name = a.col_name)
union all
select 22 n,
       a.ent_id,
      'Поле "' || a.col_name || '" cущности "' || e.name || '" ошибочно задействовано в ограничении' error  
from attr a
     inner join attr_type aty on aty.attr_type_id = a.attr_type_id
     inner join entity e on e.ent_id = a.ent_id
where aty.brief not in ('R', 'OI', 'UR')
      and exists (select *
                  from tmp_ucc cc
                       inner join tmp_uc c on 
                         c.constraint_type = 'R' and c.constraint_name = cc.constraint_name
                  where cc.position = 1 and cc.table_name = a.source and cc.column_name = a.col_name
                  )
      and a.source || '.' || a.col_name not in (select name from check_excl ce where ce.excl_type = 'EXCL_R') 
-- Универсальные ссылки
union all
select 23 n,
       e.ent_id,
      'Поля "' || t.ur_col || '%" универсальной ссылки cущности "' || e.name || '" являются непарными' error
from 
  entity e
  inner join ( select 
                 tc.table_name table_name,
                 ents.uref_col_name(tc.column_name) ur_col
               from 
                 tmp_utc tc 
               where
                 (tc.column_name like '%\_URE\_ID' escape '\' or tc.column_name like '%\_URO\_ID' escape '\')
               group by  
                 tc.table_name,
                 ents.uref_col_name(tc.column_name)
               having 
                 count(ents.uref_col_name(tc.column_name)) <> 2
              ) t on t.table_name = e.source
union all
select 24 n,
       e.ent_id,
      'Неверно заведен или отсутсвует внешний ключ для полей "' || t.ur_col || '%" универсальной ссылки cущности "' || e.name || '"' error
from 
  entity e
  inner join ( select 
                 tc.table_name table_name,
                 ents.uref_col_name(tc.column_name) ur_col
               from 
                 tmp_utc tc 
               where
                 (tc.column_name like '%\_URE\_ID' escape '\' or tc.column_name like '%\_URO\_ID' escape '\')
               group by  
                 tc.table_name,
                 ents.uref_col_name(tc.column_name)
               having 
                 count(ents.uref_col_name(tc.column_name)) = 2
              ) t on t.table_name = e.source
where
  not exists ( select *
               from tmp_ucc cc
               inner join tmp_uc c on cc.constraint_name = c.constraint_name
                                            and c.constraint_name like 'FK_%'
                                            and c.constraint_type = 'R'
                                            and c.r_constraint_name = 'PK_UREF'
                                            and c.delete_rule = 'NO ACTION'
--                                            and c.status = 'ENABLED'
               where cc.table_name = e.source
                     and cc.column_name = t.ur_col || '_URE_ID'
                     and cc.position = 1
              )
  or 
  not exists ( select *
               from tmp_ucc cc
               inner join tmp_uc c on cc.constraint_name = c.constraint_name
                                            and c.constraint_name like 'FK\_%' escape '\'
                                            and c.constraint_type = 'R'
                                            and c.r_constraint_name = 'PK_UREF'
                                            and c.delete_rule = 'NO ACTION'
--                                            and c.status = 'ENABLED'
               where cc.table_name = e.source
                     and cc.column_name = t.ur_col || '_URO_ID'
                     and cc.position = 2
             )
-- FK
union all
select 26,
       null,
       'Отсутствует индекс по ключу "' || constraint_name || '" таблицы "' || table_name || '" (' || column_name || ')'
from ve_error_fk_not_ix v
;

