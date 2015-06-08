create or replace function INS.SF_QUIT_JOURNAL
(
  par_date_begin     date
 ,par_date_end       date
 ,par_regulated_loss varchar2 -- ��������������� ������
 ,par_claimed_loss   varchar2 -- ���������� ������
 ,par_renew_quit     varchar2 -- �������������� � ����������� �� ��������� ��������� �������
 ,par_setoff_fin     varchar2 -- �����/���������� ��������
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
