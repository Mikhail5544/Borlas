CREATE OR REPLACE VIEW V_BSO_REP_NEW AS
SELECT bt.name                             "Тип БСО"
      ,b.num                               "Номер"
      ,bs.series_num                       "Серия"
      ,bt.name                             "Наименование"
      ,NVL(cn.obj_name_orig,'--нет--')     "Держатель БСО"
      ,NVL(dep.name,'--нет--')             "Подразделение"
      ,NVL(cn.obj_name_orig,'неопределен') "Владелец"
      ,bht.name                            "Состояние бланка"
      ,bh.hist_date                        "Дата состояния"
      ,bdc.bso_document_id                 "Номер акта"
      ,bht.name                            "bso_state"
      ,bs.series_num                       "bso_ser"
      ,dep.name                            "agency"
                        
                        
  FROM ins.bso b
      ,ins.bso_hist bh
      ,ins.bso_hist_type bht
      ,ins.bso_series bs
      ,ins.bso_type bt
      ,ins.contact  cn
      ,ins.department dep
      ,ins.bso_doc_cont bdc
 WHERE bh.bso_hist_id=b.bso_hist_id
   AND bht.bso_hist_type_id=bh.hist_type_id
   AND bs.bso_series_id=b.bso_series_id
   AND bt.bso_type_id=bs.bso_type_id
   --Параметр Состояние бланка
   AND (bht.name IN      (SELECT to_char(r.param_value)
                            FROM ins_dwh.rep_param r
                           WHERE r.rep_name    = 'v_bso_rep_new'
                             AND r.param_name  = 'bso_state')
    OR      (    to_char((SELECT r.param_value
                            FROM ins_dwh.rep_param r
                           WHERE r.rep_name    = 'v_bso_rep_new'
                             AND r.param_name  = 'bso_state'
                             AND r.param_value = ' <Все>')) = ' <Все>') )
   --Параметр Серия бланка                             
   AND (to_char(bs.series_num) IN (SELECT to_char(r.param_value)
                            FROM ins_dwh.rep_param r
                           WHERE r.rep_name    = 'v_bso_rep_new'
                             AND r.param_name  = 'bso_ser')
    OR      (    to_char((SELECT to_char(r.param_value)
                            FROM ins_dwh.rep_param r
                           WHERE r.rep_name    = 'v_bso_rep_new'
                             AND r.param_name  = 'bso_ser'
                             AND r.param_value = ' <Все>')) = ' <Все>') )
   --Параметр Подразделение                             
   AND (dep.name IN (SELECT to_char(r.param_value)
                       FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'v_bso_rep_new'
                        AND r.param_name = 'agency')
    OR (    to_char((SELECT to_char(r.param_value)
                       FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'v_bso_rep_new'
                        AND r.param_name = 'agency'
                        AND r.param_value= ' <Все>')) = ' <Все>') )
   --Параметр Дата состояния
   AND bh.hist_date BETWEEN (SELECT to_date(r.param_value,'dd.mm.yyyy')
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'v_bso_rep_new'
                                AND r.param_name = 'date_from')
                        AND (SELECT to_date(r.param_value,'dd.mm.yyyy')
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'v_bso_rep_new'
                                AND r.param_name = 'date_to')
   --Параметр Тип БСО                                
   AND (bt.name  IN (SELECT to_char(r.param_value)
                       FROM ins_dwh.rep_param r
                      WHERE r.rep_name   = 'v_bso_rep_new'
                        AND r.param_name = 'bso_type')
    OR (    to_char((SELECT r.param_value
                       FROM ins_dwh.rep_param r
                      WHERE r.rep_name   = 'v_bso_rep_new'
                        AND r.param_name = 'bso_type'
                        AND r.param_value= ' <Все>')) = ' <Все>') )
  --Параметр  С учетом фиктивных БСО                       
  AND (('НЕТ' = (SELECT upper(to_char(r.param_value))
                       FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'v_bso_rep_new'
                        AND r.param_name = 'is_fict_bso')
        and cn.contact_id != 4002)               --Владелец Фиктивных Бсо
       or ('ДА' = (SELECT upper(to_char(r.param_value))
                       FROM ins_dwh.rep_param r
                      WHERE r.rep_name = 'v_bso_rep_new'
                        AND r.param_name = 'is_fict_bso')))                                                                        
   AND cn.contact_id=NVL(b.contact_id,bh.contact_id)
   AND bdc.bso_doc_cont_id(+)=bh.bso_doc_cont_id
   AND dep.department_id=bh.department_id;

   grant select on V_BSO_REP_NEW to ins_read;
   grant select on V_BSO_REP_NEW to ins_eul;
   
