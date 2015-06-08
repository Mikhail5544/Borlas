-- Create table
create table AGN_SALES_OPS
(
  AGN_SALES_OPS_ID  INTEGER not null,
  STATE             INTEGER,
  OPERATION         VARCHAR2(20),
  ERROR_TEXT        VARCHAR2(2000),
  OPERATION_DATE    DATE,
  OPERATION_STMNT   VARCHAR2(2000),
  AGENT_NUM         NUMBER(10),
  SALES_DATE        DATE
)
tablespace INS_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 6M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table AGN_SALES_OPS
  is '������� ��� ��������� ��������� ���� ������� �� ������� �� b2b';
-- Add comments to the columns 
comment on column AGN_SALES_OPS.AGN_SALES_OPS_ID
  is '�� ������ (NOT IMPORTED)';
comment on column AGN_SALES_OPS.STATE
  is '0 - ����� ������ 1 - ������� ��������, n - ������� "������" (NOT IMPORTED)';
comment on column AGN_SALES_OPS.OPERATION
  is '��� �������� ������������ � b2b';
comment on column AGN_SALES_OPS.ERROR_TEXT
  is '����� ������ �� ����������� ���� (NOT IMPORTED)';
comment on column AGN_SALES_OPS.OPERATION_DATE
  is '���� �������� (NOT IMPORTED)';
comment on column AGN_SALES_OPS.OPERATION_STMNT
  is '����� �������� JSON (NOT IMPORTED)';
comment on column AGN_SALES_OPS.AGENT_NUM
  is '����� ��';
comment on column AGN_SALES_OPS.SALES_DATE
  is '���� ������� (NOT IMPORTED)';
-- Create/Recreate primary, unique and foreign key constraints 
alter table AGN_SALES_OPS
  add constraint PK_AGN_SALES_OPS primary key (AGN_SALES_OPS_ID)
  using index 
  tablespace INS_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 192K
    minextents 1
    maxextents unlimited
  );
-- Grant/Revoke object privileges 
grant select on AGN_SALES_OPS to INS_READ;

/
begin
ents.create_ent('AGN_SALES_OPS','���� ������� ���','AGN_SALES_OPS');
end;
/

-- Add comments to the columns 
comment on column AGN_SALES_OPS.AGN_SALES_OPS_ID
  is '�� ������� �������� ���� ������� ���  (NOT IMPORTED)';
comment on column AGN_SALES_OPS.STATE
  is '0 - ����� ������ 1 - ������� ��������, n - ������� "������" (NOT IMPORTED)';
comment on column AGN_SALES_OPS.OPERATION
  is '��� �������� ������������ � b2b  (NOT IMPORTED)';
comment on column AGN_SALES_OPS.ERROR_TEXT
  is '����� ������ �� ����������� ���� (NOT IMPORTED)';
comment on column AGN_SALES_OPS.OPERATION_DATE
  is '���� �������� (NOT IMPORTED)';
comment on column AGN_SALES_OPS.OPERATION_STMNT
  is '����� �������� JSON (NOT IMPORTED)';
comment on column AGN_SALES_OPS.AGENT_NUM
  is '����� ��';
comment on column AGN_SALES_OPS.SALES_DATE
  is '���� �������  (NOT IMPORTED)';
comment on column AGN_SALES_OPS.ENT_ID
  is '�� ��������  (NOT IMPORTED)';
comment on column AGN_SALES_OPS.FILIAL_ID
  is '�� �������  (NOT IMPORTED)';
comment on column AGN_SALES_OPS.EXT_ID
  is '�� ������� ������  (NOT IMPORTED)';