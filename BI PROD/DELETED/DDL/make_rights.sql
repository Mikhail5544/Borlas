begin
  sp_register_right(pname => '�������������� ������������ �7 � �������� �������',
                    pbrief => 'AUTO_LINK_A7_CLOSED',
                    prigthtype => 'CUSTOM');
  sp_register_right(pname => '�������������� ������������ �7 � �������� �������',
                    pbrief => 'AUTO_LINK_A7_OPENED',
                    prigthtype => 'CUSTOM');
    sp_register_right(pname => '��. ��������� ������� ����������� ��� ��������������',
                    pbrief => 'CHECK_DECL_REASON_RENEW',
                    prigthtype => 'CUSTOM');

  sp_register_right(pname => '��. �������� ������ "����������� ��������� - �������������� ����� ��������"',
                    pbrief => 'CREATE_TECH_RENEW',
                    prigthtype => 'CUSTOM');

  sp_register_right(pname => '��. �������� ������ "�������� ��������� - �������������� �������� ���������"',
                    pbrief => 'CREATE_MAIN_RENEW',
                    prigthtype => 'CUSTOM');
                    
  sp_register_right(pname => '�������� �����. ��������� ����������.',
                    pbrief => 'SF_UPD_NOTE_OBJ_NAME_CONCLUSION_AC',
                    prigthtype => 'CUSTOM');
                
end;
/