-- Add/modify columns 
alter table AG_PERF_WORK_VOL add EXT_PERFORM_WORK_DET_ID INTEGER;
-- Add comments to the columns 
comment on column AG_PERF_WORK_VOL.EXT_PERFORM_WORK_DET_ID
  is '—сылка на внешнюю детализацию премии если сама преми€ не имеет деталей';
-- Create/Recreate primary, unique and foreign key constraints 
alter table AG_PERF_WORK_VOL
  add constraint FK_AG_PERF_VOL_REF_02 foreign key (EXT_PERFORM_WORK_DET_ID)
  references ag_perfom_work_det (AG_PERFOM_WORK_DET_ID);
