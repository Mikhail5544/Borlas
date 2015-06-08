create or replace force view v_doc_templ as
select "DOC_TEMPL_ID","ENT_ID","FILIAL_ID","DOC_ENT_ID","NAME","BRIEF","PREFIX","ENDING","NUM_LEN_MIN","NUM_LEN_MAX","DEF_DOC_FOLDER_ID","DEF_DOC_STATUS_REF_ID","NUM_CODE","EXT_ID"
-- Устарело, используется в отчета БСО
from doc_templ
;

