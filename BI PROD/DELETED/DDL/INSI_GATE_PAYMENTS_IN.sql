-- Create table INSI.GATE_PAYMENTS_IN
create table INSI.GATE_PAYMENTS_IN
(
  AC_PAYMENT_ID      NUMBER not null,
  CONTACT_ID         NUMBER,
  REQ_NUMBER         VARCHAR2(20),
  REQ_DATE           DATE,
  PAYMENT_REQ_NUMBER VARCHAR2(20),
  PAYMENT_ORDER      VARCHAR2(20),
  PAYMENT_DATE       DATE
);
-- Add comments to the table 
comment on table INSI.GATE_PAYMENTS_IN
  is '����������� ��������� ���������';
-- Add comments to the columns 
comment on column INSI.GATE_PAYMENTS_IN.AC_PAYMENT_ID
  is 'ID ������ �� � Borlas';
comment on column INSI.GATE_PAYMENTS_IN.CONTACT_ID
  is 'ID ������ �������� � Borlas';
comment on column INSI.GATE_PAYMENTS_IN.REQ_NUMBER
  is '����� ��������';
comment on column INSI.GATE_PAYMENTS_IN.REQ_DATE
  is '���� ��������';
comment on column INSI.GATE_PAYMENTS_IN.PAYMENT_REQ_NUMBER
  is '����� ������� �� ������';
comment on column INSI.GATE_PAYMENTS_IN.PAYMENT_ORDER
  is '����� ���������� ���������';
comment on column INSI.GATE_PAYMENTS_IN.PAYMENT_DATE
  is '���� ������';
-- Create/Recreate primary, unique and foreign key constraints 
alter table INSI.GATE_PAYMENTS_IN
  add constraint PK_GATE_PAYMENTS_IN primary key (AC_PAYMENT_ID)
  using index 
  tablespace "INDEX";
-- Grant/Revoke object privileges 
grant select, delete on INSI.GATE_PAYMENTS_IN to INS;
grant select, delete, update on insi.gate_payments_out to INSI_PROXY;
