CREATE OR REPLACE FORCE VIEW V_BSO_ACCOUNT AS
SELECT bso_name AS "Тип БСО",
       SUM(s_np) AS "Остаток на начало периода",
       SUM(s_pr) AS "Приход за период",
       SUM(s_rash) AS "Расход за период",
       SUM(s_ep)   AS "Остаток на конец периода"
  FROM (
  SELECT a.bso_name, a.bso_num,
         MAX(a.np_pr) - MAX(a.np_rash) s_np,
         MAX(a.pr) s_pr,
         decode (MAX(a.np_rash),1,0,MAX(a.rash)) s_rash, -- учет предшествующего попадания в расход
         MAX(a.ep_pr) - MAX(a.ep_rash) s_ep
    FROM (
    select bso_name,
           bso_num,
           CASE WHEN doc_reg_date < (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_acc' and param_name = 'begin_date')
           THEN 1
           ELSE 0 END np_pr,
           CASE WHEN hist_date < (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_acc' and param_name = 'begin_date')
                 AND hist_name IN  ('Использован','Испорчен','Списан','Утерян')
           THEN 1
           ELSE 0 END np_rash,

           CASE WHEN doc_reg_date >= (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_acc' and param_name = 'begin_date')
                 AND trunc(doc_reg_date,'dd') <= (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_acc' and param_name = 'end_date')
           THEN 1
           ELSE 0 END pr,
           CASE WHEN hist_date >= (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_acc' and param_name = 'begin_date')
                 AND trunc(hist_date,'dd') <= (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_acc' and param_name = 'end_date')
                 AND hist_name IN  ('Использован','Испорчен','Списан','Утерян')
           THEN 1
           ELSE 0 END rash,

           CASE WHEN trunc(doc_reg_date,'dd') <= (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_acc' and param_name = 'end_date')
           THEN 1
           ELSE 0 END ep_pr,
           CASE WHEN trunc(hist_date,'dd') <= (SELECT param_value FROM ins_dwh.rep_param WHERE rep_name = 'bso_acc' and param_name = 'end_date')
                 AND hist_name IN  ('Использован','Испорчен','Списан','Утерян')
           THEN 1
           ELSE 0 END ep_rash
   from (
         select aa.bso_name,
                bh.bso_id,
                aa.bso_num,
                bh.num hist_num,
                bh.hist_date,
                bht.name hist_name,
                decode(bh.num,1, aa.REG_DATE, null) doc_reg_date
           from bso_hist bh,
                BSO_HIST_TYPE bht,
                (SELECT DOC.REG_DATE,
                        doc.num,
                        b.bso_id,
                        bt.name bso_name,
                        b.num bso_num,
                        dt.NAME akt_name
                  FROM  document     doc,
                        doc_templ    dt,
                        bso_doc_cont bdc,
                        bso_hist     bh2,
                        bso_series   bs,
                        bso_type     bt,
                        bso          b
                  WHERE doc.doc_templ_id    = dt.doc_templ_id
                    AND dt.brief            IN ('ФормированиеБСО','НакладнаяБСО', 'ПередачаБСО')--с актами передачи!
                    AND doc.document_id     = bdc.bso_document_id
                    AND bdc.bso_doc_cont_id = bh2.bso_doc_cont_id
                    AND bdc.bso_series_id   = bs.bso_series_id
                    AND bs.bso_type_id      = bt.bso_type_id
                    AND bh2.num             = 1
                    AND bh2.bso_id          = b.bso_id
                    --AND bt.bso_type_id      = 999
                 ) aa
          where bh.bso_id = aa.bso_id
            AND bh.hist_type_id = bht.bso_hist_type_id
        )
     ) a
GROUP BY a.bso_name, a.bso_num
)
GROUP BY bso_name
order by bso_name
;

