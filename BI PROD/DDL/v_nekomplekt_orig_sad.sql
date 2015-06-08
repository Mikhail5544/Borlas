--235310
CREATE OR REPLACE VIEW v_nekomplekt_orig_sad AS

 SELECT ach.num  "����� ���"
       ,cn.obj_name_orig "��� ���������"
       ,aca.category_name "������� ���������"
       ,dep.name          "�������"
       ,tsc.description   "����� ������"
       ,ach.date_begin    "���� ���������� ���"
       ,ins.pkg_readonly.get_doc_status_name(ach.ag_contract_header_id) "������ ��"
       ,adt.description   "��� ���������"
       ,ad.doc_date       "���� ���������"
       ,ins.pkg_readonly.get_doc_status_name(ad.ag_documents_id) "������ ���������"
       ,ins.pkg_readonly.get_aggregated_string(cast(multiset(
         SELECT dte.description
           FROM AG_DOCUMENT_ELEMENTS de, AG_DOC_TYPE_ELEMENT dte
          WHERE de.ag_doc_type_element_id=dte.ag_doc_type_element_id
            AND de.missing_original=1
            AND de.ag_documents_id=ad.ag_documents_id
             ) as ins.tt_one_col),', ')  "���������� ���������"
   FROM ins.ven_ag_contract_header ach
       ,ins.ag_contract            ac
       ,ins.ag_category_agent      aca
       ,ins.t_sales_channel        tsc
       ,ins.department             dep
       ,ins.ag_documents           ad
       ,ins.ag_doc_type            adt
       ,ins.contact                cn
  WHERE ac.ag_contract_id=ach.last_ver_id
    AND aca.ag_category_agent_id=ac.category_id
    AND tsc.id=ach.t_sales_channel_id
    AND dep.department_id=ac.agency_id
    AND ad.ag_contract_header_id=ach.ag_contract_header_id
    AND adt.ag_doc_type_id=ad.ag_doc_type_id
    AND cn.contact_id=ach.agent_id
    AND adt.brief IN ('NEW_AD'
                     ,'CAT_CHG'
                     ,'RLP_AD');
/
grant select on  v_nekomplekt_orig_sad to ins_eul;                         
grant select on  v_nekomplekt_orig_sad to ins_read;
/



--���������� ����
  declare
  v_rep_name varchar2(500) := '���������� ���������� ����������';
begin
  update ins_eul.EUL5_DOCUMENTS_TAB s
  set s.doc_description           = '��������: ��������� ������ ����������������� � ������ ������������ ��������� ����'
  where s.doc_name = v_rep_name;


  safety.add_safety_right(par_right_name => v_rep_name
                         ,par_right_type_brief => 'DISCOVERER'
                         );
                         
  safety.assign_right_to_role(par_right_name => v_rep_name
                             ,par_role_name => '�����'
                             ,par_right_type_brief => 'DISCOVERER'
                             );                         
  safety.assign_right_to_role(par_right_name => v_rep_name
                             ,par_role_name => '�����������'
                             ,par_right_type_brief => 'DISCOVERER'
                             );                                 
  safety.assign_right_to_role(par_right_name => v_rep_name
                             ,par_role_name => '������� ���������� �� ������ � ��������� �����'
                             ,par_right_type_brief => 'DISCOVERER'
                             ); 
    safety.assign_right_to_role(par_right_name => v_rep_name
                             ,par_role_name => '���������� �� ������ � ��������� �����'
                             ,par_right_type_brief => 'DISCOVERER'
                             );                                
--commit;                                              
end; 
