create or replace force view v_cr_agent_anal_card
(bso_type_id, bso_series_id, bso_num, hist_type_id, act_num, reg_date, hist_date, bso_hist_num, bso_contact_id, contact_from_id, contact_to_id, doc_templ_id)
as
select  bs.bso_type_id,
		b.bso_series_id,
        b.num,
		bh.hist_type_id,
		bd.num,
		bd.reg_date,  -- дата регистрации акта
		bh.hist_date, -- дата смены состояния bso
		bh.num,
		(select bh1.contact_id  from bso_hist bh1
          where bh1.bso_id = bh.bso_id and bh1.num = bh.num  - 1
		  and rownum = 1 ) as contact_id, -- у кого БСО
		bd.contact_from_id, -- от кого
		bd.contact_to_id,    -- кому
		bd.doc_templ_id
 from ven_bso_hist bh,
      ven_bso b,
	  ven_bso_series bs,
	  ven_bso_doc_cont bdc,
	  ven_bso_document bd
where bh.bso_id = b.bso_id
  and bs.bso_series_id  = b.bso_series_id
  and bdc.bso_doc_cont_id(+) = bh.bso_doc_cont_id
  and bd.bso_document_id(+) = bdc.bso_document_id
  and bh.num in (select bh2.num+1 from bso_hist bh2
                  where bh2.bso_id = bh.bso_id
				  and  bh2.hist_type_id =1)
 union all
 select  bs.bso_type_id,
		b.bso_series_id,
        b.num,
		bh.hist_type_id,
		bd.num,
		bd.reg_date,  -- дата регистрации акта
		bh.hist_date, -- дата смены состояния bso
		bh.num,
		bh.contact_id, -- у кого БСО
		bd.contact_from_id, -- от кого
		bd.contact_to_id,    -- кому
		bd.doc_templ_id
 from ven_bso_hist bh,
      ven_bso b,
	  ven_bso_series bs,
	  ven_bso_doc_cont bdc,
	  ven_bso_document bd
where bh.bso_id = b.bso_id
  and bs.bso_series_id  = b.bso_series_id
  and bdc.bso_doc_cont_id(+) = bh.bso_doc_cont_id
  and bd.bso_document_id(+) = bdc.bso_document_id
  and  bh.hist_type_id = 1
;

