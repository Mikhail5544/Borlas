-- Add/modify columns 
alter table INS.AG_AV_TYPE_CONFORM add SORT_ORDER INTEGER;
-- Add comments to the columns 
comment on column INS.AG_AV_TYPE_CONFORM.SORT_ORDER
  is 'Порядок рачсета';

BEGIN
ins.ents.gen_ent_all('AG_AV_TYPE_CONFORM');
END;
/