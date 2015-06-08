CREATE OR REPLACE VIEW V_BSO_DETAIL AS
select tp.name type_bso,
       ser.series_name ser_bso,
       bb.num num_bso,
       ht.name status_bso,
       h.num num_hist,
       h.hist_date date_hist,
       nvl(dep.name,'неопределен') department,
       nvl(c.obj_name_orig,'неопределен') contact_bso,
       (select cf.obj_name_orig
        from bso_hist hf,
             contact cf
        where hf.bso_id = h.bso_id
              and hf.num = h.num - 1
              and hf.contact_id = cf.contact_id) contact_from,
       tm.name type_act,
       doc.num num_act,
       nvl(to_char(doc.reg_date,'dd.mm.yyyy'),'') date_act
from bso bb,
     bso_series ser,
     bso_type tp,
     bso_hist h,
     bso_hist_type ht,
     department dep,
     contact c,
     bso_doc_cont dc,
     bso_document d,
     document doc,
     doc_templ tm
where bb.bso_series_id = ser.bso_series_id
      and ser.bso_type_id = tp.bso_type_id
      and bb.bso_id = h.bso_id
      and h.hist_type_id = ht.bso_hist_type_id
      and h.department_id = dep.department_id(+)
      and h.contact_id = c.contact_id(+)
      and h.bso_doc_cont_id = dc.bso_doc_cont_id(+)
      and dc.bso_document_id = d.bso_document_id(+)
      and doc.document_id(+) = d.bso_document_id
      and doc.doc_templ_id = tm.doc_templ_id(+)
      and h.hist_date BETWEEN (SELECT r.param_value
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'bso_detail'
                                AND r.param_name = 'date_from')
                            AND (SELECT r.param_value
                                   FROM ins_dwh.rep_param r
                                  WHERE r.rep_name = 'bso_detail'
                                    AND r.param_name = 'date_to')
      and (dep.name IN (SELECT r.param_value
                       FROM ins_dwh.rep_param r
                       WHERE r.rep_name = 'bso_detail'
                         AND r.param_name = 'agency')        OR (

        to_char((SELECT r.param_value
                          FROM ins_dwh.rep_param r
                         WHERE r.rep_name = 'bso_detail'
                           AND r.param_name = 'agency'
                           AND r.param_value= ' <Все>')) = ' <Все>'
           )
        );
