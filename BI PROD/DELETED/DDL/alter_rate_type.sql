-- Add/modify columns 
alter table INS.AG_RATE_TYPE add RATE_EXT_DETAIL integer;
-- Add comments to the columns 
comment on column INS.AG_RATE_TYPE.RATE_EXT_DETAIL
  is '������ �� ��� ������ ������� �������� ������ �� ������� ���� ������';
  
BEGIN
ents.gen_ent_all('AG_RATE_TYPE');
END;
/