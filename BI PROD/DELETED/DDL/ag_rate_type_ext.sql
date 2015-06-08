drop index IX_RATE_TYPE_EXT_02;

drop index IX_RATE_TYPE_EXT_01;

drop table AG_RATE_TYPE_EXT cascade constraints;

/*==============================================================*/
/* Table: AG_RATE_TYPE_EXT                                      */
/*==============================================================*/
create table AG_RATE_TYPE_EXT  (
   AG_RATE_TYPE_EXT_ID  INTEGER                         not null,
   AG_AV_TYPE_CONFORM_ID NUMBER,
   AG_RATE_TYPE_ID      NUMBER,
   constraint PK_AG_RATE_TYPE_EXT primary key (AG_RATE_TYPE_EXT_ID),
   constraint FK_AG_RATE_EXT_REF_01 foreign key (AG_AV_TYPE_CONFORM_ID)
         references AG_AV_TYPE_CONFORM (AG_AV_TYPE_CONFORM_ID),
   constraint FK_AG_RATE_EXT_REF_02 foreign key (AG_RATE_TYPE_ID)
         references AG_RATE_TYPE (AG_RATE_TYPE_ID)
);

comment on table AG_RATE_TYPE_EXT is
'Справочник - внешние детали премий';

comment on column AG_RATE_TYPE_EXT.AG_RATE_TYPE_EXT_ID is
'Ид записи справочника внение детали премий';

comment on column AG_RATE_TYPE_EXT.AG_AV_TYPE_CONFORM_ID is
'ИД объекта сущности Cоответствие ведомостей, премий и статусов';

comment on column AG_RATE_TYPE_EXT.AG_RATE_TYPE_ID is
'ИД объекта сущности Вид премий агентов';

DELETE FROM entity e WHERE e.SOURCE = replace('AG_RATE_TYPE_EXT','"','');

execute execute immediate REPLACE( 'DROP VIEW VEN_AG_RATE_TYPE_EXT','"','');

BEGIN
ents.create_ent(replace('AG_RATE_TYPE_EXT','"',''),
                'Справочник - внешние детали премий',
                replace('AG_RATE_TYPE_EXT','"',''));
END;
/

/*==============================================================*/
/* Index: IX_RATE_TYPE_EXT_01                                   */
/*==============================================================*/
create index IX_RATE_TYPE_EXT_01 on AG_RATE_TYPE_EXT (
   AG_AV_TYPE_CONFORM_ID ASC
)
tablespace "INDEX";

/*==============================================================*/
/* Index: IX_RATE_TYPE_EXT_02                                   */
/*==============================================================*/
create index IX_RATE_TYPE_EXT_02 on AG_RATE_TYPE_EXT (
   AG_RATE_TYPE_ID ASC
)
tablespace "INDEX";

-- Drop columns 
alter table AG_RATE_TYPE drop column RATE_EXT_DETAIL;