-- Create table AC_PAYMENT_ADD_INFO
create table INS.AC_PAYMENT_ADD_INFO
(
  AC_PAYMENT_ADD_INFO_ID NUMBER not null,
  EXPENSE_CODE           NUMBER(6),
  EXPENSE_PERIOD         DATE,
  EXPENSE_DATE           DATE,
  NAV_REQ_NUMBER         VARCHAR2(20),
  NAV_REQ_DATE           DATE,
  NAV_REQ_PAYMENT_NUMBER VARCHAR2(20),
  RESPONSIBILITY_CENTER  VARCHAR2(20)
);
-- Add comments to the table 
comment on table INS.AC_PAYMENT_ADD_INFO
  is 'Дополнительная информация к платежу';
-- Add comments to the columns 
comment on column INS.AC_PAYMENT_ADD_INFO.AC_PAYMENT_ADD_INFO_ID
  is 'ИД объекта сущности Дополнительная информация к платежу';
comment on column INS.AC_PAYMENT_ADD_INFO.EXPENSE_CODE
  is 'Код расхода';
comment on column INS.AC_PAYMENT_ADD_INFO.EXPENSE_PERIOD
  is 'Период расхода';
comment on column INS.AC_PAYMENT_ADD_INFO.EXPENSE_DATE
  is 'Дата расхода';
comment on column INS.AC_PAYMENT_ADD_INFO.NAV_REQ_NUMBER
  is 'Номер реквеста Navision';
comment on column INS.AC_PAYMENT_ADD_INFO.NAV_REQ_DATE
  is 'Дата реквеста Navision';
comment on column INS.AC_PAYMENT_ADD_INFO.NAV_REQ_PAYMENT_NUMBER
  is 'Номер запроса на оплату Navision';
comment on column INS.AC_PAYMENT_ADD_INFO.RESPONSIBILITY_CENTER
  is 'Центр ответственности';
-- Create/Recreate primary, unique and foreign key constraints 
alter table INS.AC_PAYMENT_ADD_INFO
  add constraint PK_AC_PAYMENT_ADD_INFO primary key (AC_PAYMENT_ADD_INFO_ID)
  using index 
  tablespace "INDEX";
alter table INS.AC_PAYMENT_ADD_INFO
  add constraint FK_ADD_INFO_REF_AC_PAYMENT foreign key (AC_PAYMENT_ADD_INFO_ID)
  references INS.AC_PAYMENT (PAYMENT_ID);

-- Сущность
begin
  ents.create_ent(p_source => 'AC_PAYMENT_ADD_INFO'
                 ,p_name   => 'Дополнительная информация к платежу'
                 ,p_brief  => 'AC_PAYMENT_ADD_INFO');
end;
/
