CREATE OR REPLACE TRIGGER tr_trans
  BEFORE INSERT OR DELETE ON trans
  FOR EACH ROW
BEGIN

  IF inserting
  THEN
    /*:new.doc_date := :new.trans_date;*/
    IF nvl(:new.note, '?') <> 'CONVERT'
       AND NOT acc_new.get_can_change_trans_in_closed
    THEN
      :new.trans_date := pkg_period_closed.check_closed_date(:new.trans_date);
    END IF;
  ELSIF deleting
  THEN
    IF pkg_period_closed.check_date_in_closed(:old.trans_date) = 1 -- если период закрыт
       AND not acc_new.get_can_change_trans_in_closed -- и не установлена возможность изменения проводки в закрытом периоде
    THEN
    
      raise_application_error(pkg_payment.v_closed_period_exception_id
                             ,'Проводка находится в закрытом периоде. Удаление невозможно');
    END IF;
  END IF;
END tr_trans;
/
