create or replace force view v_cr_bso_act_issue as
select bs.bso_type_id,      -- Тип (вид) БСО
       bd.reg_date,         -- Дата акта выдачи
	   bd.num,              -- Номер акта выдачи
	   bs.bso_series_id,    -- ИД серии БСО
	   bdc.num_start,       -- Номер первого бланка
	   bdc.num_end,         -- Номер последнего бланка
	   bd.contact_from_id,  -- ИД материально ответсвенного (МО)
	   bd.contact_to_id,    -- ИД пользователя (Агента)
	   bd.department_from_id,  -- ИД департамента МО
	   bd.department_to_id     -- ИД департамента Агента
from
	ven_bso_document bd,
	ven_bso_doc_cont bdc,
    ven_doc_templ dt,
	ven_bso_series bs
where
	bd.doc_templ_id = dt.doc_templ_id
and	bd.bso_document_id = bdc.bso_document_id
and bs.bso_series_id = bdc.bso_series_id
and	dt.brief = 'ВыдачаБСО'
;

