-- Add/modify columns 
alter table AG_SALE_PLAN add Agency_ID inteGER;
-- Add comments to the columns 
comment on column AG_SALE_PLAN.Agency_ID
  is 'ИД филиала (для планов РУ) (department_id)';

BEGIN
ents.gen_ent_all('AG_SALE_PLAN');
END;
/