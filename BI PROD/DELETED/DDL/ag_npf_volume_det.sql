-- Add/modify columns 
alter table AG_NPF_VOLUME_DET add OPS_IS_SEH inteGER;
-- Add comments to the columns 
comment on column AG_NPF_VOLUME_DET.OPS_IS_SEH
  is '������� ������� ����. ����� �������� ������';

  
BEGIN
ents.gen_ent_all('AG_NPF_VOLUME_DET');
END; 
/