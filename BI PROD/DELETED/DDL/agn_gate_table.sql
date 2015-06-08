drop trigger TRG_AGN_GATE_TABLE
/

drop table AGN_GATE_TABLE cascade constraints
/

/*==============================================================*/
/* Table: AGN_GATE_TABLE                                        */
/*==============================================================*/
drop sequence SQ_AGN_GATE_TABLE;

create sequence SQ_AGN_GATE_TABLE;

create table AGN_GATE_TABLE  (
   AGN_GATE_TABLE_ID    INTEGER                         not null,
   AGENT_ID             VARCHAR(10),
   COMPANY_ID           INTEGER,
   TAC_ID               INTEGER,
   FIRST_NAME           VARCHAR(255),
   LAST_NAME            VARCHAR(255),
   MIDDLE_NAME          VARCHAR(255),
   CITY                 VARCHAR(255),
   CONTRACT_DATE        DATE,
   BIRTH_DATE           DATE,
   OPERATION            INTEGER,
   STATE                INTEGER                        default 0 not null,
   ERROR_TEXT           VARCHAR(255),
   constraint PK_AGN_GATE_TABLE primary key (AGN_GATE_TABLE_ID)
)
/

comment on table AGN_GATE_TABLE is
'Таблица шлюза для передачи информации в B2B'
/

comment on column AGN_GATE_TABLE.AGN_GATE_TABLE_ID is
'Ид записи'
/

comment on column AGN_GATE_TABLE.AGENT_ID is
'Номер АД'
/

comment on column AGN_GATE_TABLE.COMPANY_ID is
'Ид компании'
/

comment on column AGN_GATE_TABLE.TAC_ID is
'Ид ТАП'
/

comment on column AGN_GATE_TABLE.FIRST_NAME is
'Имя'
/

comment on column AGN_GATE_TABLE.LAST_NAME is
'Фамилия'
/

comment on column AGN_GATE_TABLE.MIDDLE_NAME is
'Отчество'
/

comment on column AGN_GATE_TABLE.CITY is
'Город (агентство?)'
/

comment on column AGN_GATE_TABLE.CONTRACT_DATE is
'Дата АД'
/

comment on column AGN_GATE_TABLE.BIRTH_DATE is
'Дата рождения'
/

comment on column AGN_GATE_TABLE.OPERATION is
'1 - включение 0 - отключение'
/

comment on column AGN_GATE_TABLE.STATE is
'0 - новая запись 1 - успешно загружен, n - статусы "ошибки"'
/

comment on column AGN_GATE_TABLE.ERROR_TEXT is
'Текст ошибки из принимающей базы'
/


create trigger TRG_AGN_GATE_TABLE before insert
on AGN_GATE_TABLE for each row
declare
    integrity_error  exception;
    errno            integer;
    errmsg           char(200);
    dummy            integer;
    found            boolean;

begin
    --  Column "AGN_GATE_TABLE_ID" uses sequence SQ_AGN_GATE_TABLE
    select SQ_AGN_GATE_TABLE.NEXTVAL INTO :new.AGN_GATE_TABLE_ID from dual;

--  Errors handling
exception
    when integrity_error then
       raise_application_error(errno, errmsg);
end;
/
