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
'������� ����� ��� �������� ���������� � B2B'
/

comment on column AGN_GATE_TABLE.AGN_GATE_TABLE_ID is
'�� ������'
/

comment on column AGN_GATE_TABLE.AGENT_ID is
'����� ��'
/

comment on column AGN_GATE_TABLE.COMPANY_ID is
'�� ��������'
/

comment on column AGN_GATE_TABLE.TAC_ID is
'�� ���'
/

comment on column AGN_GATE_TABLE.FIRST_NAME is
'���'
/

comment on column AGN_GATE_TABLE.LAST_NAME is
'�������'
/

comment on column AGN_GATE_TABLE.MIDDLE_NAME is
'��������'
/

comment on column AGN_GATE_TABLE.CITY is
'����� (���������?)'
/

comment on column AGN_GATE_TABLE.CONTRACT_DATE is
'���� ��'
/

comment on column AGN_GATE_TABLE.BIRTH_DATE is
'���� ��������'
/

comment on column AGN_GATE_TABLE.OPERATION is
'1 - ��������� 0 - ����������'
/

comment on column AGN_GATE_TABLE.STATE is
'0 - ����� ������ 1 - ������� ��������, n - ������� "������"'
/

comment on column AGN_GATE_TABLE.ERROR_TEXT is
'����� ������ �� ����������� ����'
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
