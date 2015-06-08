CREATE OR REPLACE VIEW ins_eul.eul5_documents
(doc_id, doc_name, doc_developer_key, doc_description, doc_eu_id, doc_length, doc_batch, doc_content_type,
 doc_document, doc_user_prop2, doc_user_prop1, doc_element_state, doc_created_by, doc_created_date, doc_updated_by,
 doc_updated_date, notm, doc_folder_id)
AS
SELECT doc_id
      ,doc_name
      ,doc_developer_key
      ,doc_description
      ,doc_eu_id
      ,doc_length
      ,doc_batch
      ,doc_content_type
      ,doc_document
      ,doc_user_prop2
      ,doc_user_prop1
      ,doc_element_state
      ,doc_created_by
      ,doc_created_date
      ,doc_updated_by
      ,doc_updated_date
      ,notm
      ,doc_folder_id
  FROM ins_eul.eul5_documents_tab
 WHERE ins.safety.check_right_discoverer (doc_id) = 1;
