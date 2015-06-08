-- Add/modify columns 
alter table AG_VOLUME add CONCLUDE_DATE date;
-- Add comments to the columns 
comment on column AG_VOLUME.CONCLUDE_DATE
  is 'Дата подписания';

BEGIN
ents.gen_ent_all('AG_VOLUME');
END;
/