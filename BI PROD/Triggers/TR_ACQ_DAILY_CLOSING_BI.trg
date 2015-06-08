CREATE OR REPLACE TRIGGER tr_acq_daily_closing_bi
  BEFORE INSERT ON acq_daily_closing
  FOR EACH ROW
BEGIN
  :new.created_by := USER;
  :new.created_at := SYSDATE;
END tr_acq_daily_closing_bi;
/
