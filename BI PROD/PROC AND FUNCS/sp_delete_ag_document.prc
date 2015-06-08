create or replace procedure SP_DELETE_AG_DOCUMENT
/*
  ������ �.
  �������� ��������� ��
  �������� ������ �� ��������� ���������
  
  par_ag_document_id   - �� ���������
  par_header_status_id - �� ������� ��������� ��, ���� ���������� ��������
*/
(
  par_ag_document_id   in number
 ,par_header_status_id in number default null
)
is
  v_cnt              number(1);
  v_header_id        number;
  v_contract_id      number;
  v_prev_contract_id number;
  v_doc_date         date;
  v_doc_class        number(1);
begin
  -- ��������, �������� �� �������� ���������
  select count(1)
    into v_cnt
    from dual
   where exists (select null
                   from ag_documents ad
                       ,ag_documents ac
                  where ad.ag_documents_id       = par_ag_document_id
                    and ad.ag_contract_header_id = ac.ag_contract_header_id
                    and ad.doc_date              < ac.doc_date
                );
  if v_cnt = 1 then
    raise_application_error(-20001, '�������� ����������! ��������� �������� �� ���������.');
  end if;
  -- ��������� ���� ��������� � ID ��������� AD
  begin
    select ad.ag_contract_header_id
          ,ad.doc_date
          ,dt.doc_class
      into v_header_id
          ,v_doc_date
          ,v_doc_class
      from ag_documents ad
          ,ag_doc_type  dt
     where ad.ag_documents_id = par_ag_document_id
       and ad.ag_doc_type_id  = dt.ag_doc_type_id;
  exception
    when NO_DATA_FOUND then
      raise_application_error(-20001, '�� ������ �������� � ID: '||to_char(par_ag_document_id));
  end;

  -- �������� ��������� �� ��
  delete from ag_documents ad
        where ad.ag_documents_id = par_ag_document_id;
  -- �������� ��������� �� ������� document
  delete from document d
        where d.document_id = par_ag_document_id;
  -- �������� �������� ���������
  delete from doc_status ds
        where ds.document_id = par_ag_document_id;
  -- �������� ������� ��������� ��
  if par_header_status_id is not null then
    delete from doc_status ds
          where ds.doc_status_id = par_header_status_id;
  end if;
  -- ���� ��� ��������� ��������, ������ ���� �������������� ������
  if v_doc_class = 1 then
    -- ��������� ������ ��
    begin
      select ac.ag_contract_id
        into v_contract_id
        from ag_contract ac
       where ac.contract_id = v_header_id
         and ac.date_begin  = v_doc_date;

      -- ��������� ���������� ������ ���� ���������
      -- ��������� ID ���������� ������ ��
      select ag.ag_contract_id
        into v_prev_contract_id
        from ag_contract ag
       where ag.contract_id = v_header_id
         and ag.date_begin = (select max(am.date_begin)
                                from ag_contract am
                               where am.contract_id = ag.contract_id
                                 and am.date_begin  < v_doc_date
                             );
      -- ��������� ����
      update ag_contract ag
         set ag.date_end = to_date('31.12.2999','dd.mm.yyyy')
       where ag.ag_contract_id = v_prev_contract_id;

      -- ��������� ������� ������ � ��������� ��
      update ag_contract_header ah
         set ah.last_ver_id = v_prev_contract_id
       where ah.last_ver_id           = v_contract_id
         and ah.ag_contract_header_id = v_header_id;
      -- �������� ������� ������
      delete from ag_contract ag
            where ag.ag_contract_id = v_contract_id;
      -- �������� ������� ������ �� ������� document
      delete from document d
            where d.document_id = v_contract_id;
      -- �������� �������� ������� ������
      delete from doc_status ds
            where ds.document_id = v_contract_id;
    exception
      when NO_DATA_FOUND then
        null;
    end;
  end if;
end SP_DELETE_AG_DOCUMENT;
/

