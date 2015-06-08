CREATE OR REPLACE TRIGGER tr_acq_daily_closing_biu
  BEFORE INSERT OR UPDATE ON acq_daily_closing
  FOR EACH ROW
BEGIN
  :new.changed_by := USER;
  :new.changed_at      := SYSDATE;
END tr_acq_daily_closing_biu;
/
