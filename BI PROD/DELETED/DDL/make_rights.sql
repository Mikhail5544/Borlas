begin
  sp_register_right(pname => 'Автоматическая перепривязка А7 в закрытом периоде',
                    pbrief => 'AUTO_LINK_A7_CLOSED',
                    prigthtype => 'CUSTOM');
  sp_register_right(pname => 'Автоматическая перепривязка А7 в открытом периоде',
                    pbrief => 'AUTO_LINK_A7_OPENED',
                    prigthtype => 'CUSTOM');
    sp_register_right(pname => 'ДС. Проверять причину расторжения при восстановлении',
                    pbrief => 'CHECK_DECL_REASON_RENEW',
                    prigthtype => 'CUSTOM');

  sp_register_right(pname => 'ДС. Создание версии "Технические изменения - Восстановление всего договора"',
                    pbrief => 'CREATE_TECH_RENEW',
                    prigthtype => 'CUSTOM');

  sp_register_right(pname => 'ДС. Создание версии "Основные изменения - Восстановление основной программы"',
                    pbrief => 'CREATE_MAIN_RENEW',
                    prigthtype => 'CUSTOM');
                    
  sp_register_right(pname => 'Хранимые файлы. Изменение примечания.',
                    pbrief => 'SF_UPD_NOTE_OBJ_NAME_CONCLUSION_AC',
                    prigthtype => 'CUSTOM');
                
end;
/