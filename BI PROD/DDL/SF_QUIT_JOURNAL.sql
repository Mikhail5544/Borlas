create or replace function INS.SF_QUIT_JOURNAL
(
  par_date_begin     date
 ,par_date_end       date
 ,par_regulated_loss varchar2 -- Урегулированные убытки
 ,par_claimed_loss   varchar2 -- Заявленные убытки
 ,par_renew_quit     varchar2 -- Восстановления и расторжения за пределами отчетного периода
 ,par_setoff_fin     varchar2 -- Зачет/Финансовые каникулы
)
return number
is 
begin
  
  return pkg_quit_journal_rep.create_quit_journal
                             (par_date_begin
                            , par_date_end 
                            , par_regulated_loss
                            , par_claimed_loss
                            , par_renew_quit
                            , par_setoff_fin);

end SF_QUIT_JOURNAL;
/
