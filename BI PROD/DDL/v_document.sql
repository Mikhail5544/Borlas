create or replace force view v_document as
select "DOCUMENT_ID","ENT_ID","FILIAL_ID","NUM","DOC_FOLDER_ID","DOC_TEMPL_ID","NOTE","REG_DATE","EXT_ID"
-- Устарело, используется в отчета БСО
from document
;

