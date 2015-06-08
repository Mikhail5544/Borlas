-- Create table INSI.GATE_PAYMENTS_OUT
create table INSI.GATE_PAYMENTS_OUT
(
  AC_PAYMENT_ID         NUMBER not null,
  CONTACT_ID            NUMBER not null,
  POLICY_HEADER_ID      NUMBER,
  EXPENSE_PERIOD        DATE not null,
  EXPENSE_DATE          DATE not null,
  DESCRIPTION           VARCHAR2(4000) not null,
  EXPENSE_CODE          VARCHAR2(5) not null,
  TOTAL                 NUMBER not null,
  COST_CENTER           VARCHAR2(20) not null,
  RESPONSIBILITY_CENTER VARCHAR2(20) not null
);
-- Add comments to the table 
comment on table INSI.GATE_PAYMENTS_OUT
  is 'Отправляемые платежные поручения';
-- Add comments to the columns 
comment on column INSI.GATE_PAYMENTS_OUT.AC_PAYMENT_ID
  is 'ID записи ПП в Borlas';
comment on column INSI.GATE_PAYMENTS_OUT.CONTACT_ID
  is 'ID записи контакта в Borlas';
comment on column INSI.GATE_PAYMENTS_OUT.POLICY_HEADER_ID
  is 'ID записи заголовка ДС';
comment on column INSI.GATE_PAYMENTS_OUT.EXPENSE_PERIOD
  is 'Период расхода';
comment on column INSI.GATE_PAYMENTS_OUT.EXPENSE_DATE
  is 'Дата расхода';
comment on column INSI.GATE_PAYMENTS_OUT.DESCRIPTION
  is 'Описание товаров и услуг';
comment on column INSI.GATE_PAYMENTS_OUT.EXPENSE_CODE
  is 'Код расхода';
comment on column INSI.GATE_PAYMENTS_OUT.TOTAL
  is 'Сумма';
comment on column INSI.GATE_PAYMENTS_OUT.COST_CENTER
  is 'Центр затрат';
comment on column INSI.GATE_PAYMENTS_OUT.RESPONSIBILITY_CENTER
  is 'Центр ответственности';
-- Create/Recreate primary, unique and foreign key constraints 
alter table INSI.GATE_PAYMENTS_OUT
  add constraint PK_GATE_PAYMENTS_OUT primary key (AC_PAYMENT_ID)
  using index 
  tablespace "INDEX";

-- Grant/Revoke object privileges
grant insert, delete on INSI.GATE_PAYMENTS_OUT to INS;
grant select on INSI.GATE_PAYMENTS_OUT to INSI_PROXY;
