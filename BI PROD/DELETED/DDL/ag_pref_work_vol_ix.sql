-- Create/Recreate indexes 
create index IX_AG_PREF_WORK_VOL_01 on AG_PERF_WORK_VOL (AG_VOLUME_ID)
  tablespace INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  );