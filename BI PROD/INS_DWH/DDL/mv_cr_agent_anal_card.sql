create materialized view INS_DWH.MV_CR_AGENT_ANAL_CARD
build deferred
refresh force on demand
as
select bs.bso_type_id,
       b.bso_series_id,
       b.num bso_num,
       bh.hist_type_id,
       bd.num act_num,
       bd.reg_date, -- дата регистрации акта
       bh.hist_date, -- дата смены состояния bso
       bh.num bso_hist_num,
       q.contact_id bso_contact_id, -- у кого БСО
       bd.contact_from_id, -- от кого
       bd.contact_to_id, -- кому
       bd.doc_templ_id
  from ins.ven_bso_hist     bh,
       ins.ven_bso          b,
       ins.ven_bso_series   bs,
       ins.ven_bso_doc_cont bdc,
       ins.ven_bso_document bd,
       (select bhl.contact_id, bhl.bso_id, bhl.num, row_number() over (partition by bhl.bso_id, bhl.num order by bhl.bso_hist_id) rn from ins.bso_hist bhl) q
 where bh.bso_id = b.bso_id
   and bs.bso_series_id = b.bso_series_id
   and bdc.bso_doc_cont_id(+) = bh.bso_doc_cont_id
   and bd.bso_document_id(+) = bdc.bso_document_id
   and bh.num in (select bh2.num + 1
                    from ins.bso_hist bh2
                   where bh2.bso_id = bh.bso_id
                     and bh2.hist_type_id = 1)
   and q.num(+) = bh.num-1 and q.rn(+) = 1 and q.bso_id(+) = bh.bso_id
union all
select bs.bso_type_id,
       b.bso_series_id,
       b.num,
       bh.hist_type_id,
       bd.num,
       bd.reg_date, -- дата регистрации акта
       bh.hist_date, -- дата смены состояния bso
       bh.num,
       bh.contact_id, -- у кого БСО
       bd.contact_from_id, -- от кого
       bd.contact_to_id, -- кому
       bd.doc_templ_id
  from ins.ven_bso_hist     bh,
       ins.ven_bso          b,
       ins.ven_bso_series   bs,
       ins.ven_bso_doc_cont bdc,
       ins.ven_bso_document bd
 where bh.bso_id = b.bso_id
   and bs.bso_series_id = b.bso_series_id
   and bdc.bso_doc_cont_id(+) = bh.bso_doc_cont_id
   and bd.bso_document_id(+) = bdc.bso_document_id
   and bh.hist_type_id = 1;

