-- Add/modify columns 
alter table P_POLICY add AMOUNT_OF_CHARGE_OFF number default 0;
-- Add comments to the columns 
comment on column P_POLICY.AMOUNT_OF_CHARGE_OFF
  is 'Сумма по заявлению на списание';
