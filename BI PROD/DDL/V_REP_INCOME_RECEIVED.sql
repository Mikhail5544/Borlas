CREATE OR REPLACE VIEW V_REP_INCOME_RECEIVED AS
SELECT pkg_policy.get_pol_agency_name(ph.policy_header_id) "Агентство"
       ,vi.contact_name AS "ФИО"
       ,ph.ids          AS "ИДС"
       ,pp.num          AS "Номер договора"
       ,ph.start_date   AS "Дата начала договора"
       ,f.brief         AS "Валюта"
       ,pr.description  AS "Продукт"
       ,dsr.name        AS "Статус последний версии"
  FROM ins.p_pol_header   ph
      ,ins.ven_p_policy   pp
      ,ins.v_pol_issuer   vi
      ,ins.fund           f
      ,ins.t_product      pr
      ,ins.doc_status_ref dsr
       ,(select t.pol_num, rn
          from (      
                select column_value pol_num, rownum rn
                from table(cast(pkg_utils.get_splitted_string(replace(
                                        (SELECT r.param_value
                                           FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'income_received'
                                            AND r.param_name = 'pol_num')
               ,' '), ',') as ins.tt_one_col)) ) t )t1
      
where ph.last_ver_id                    = pp.policy_id
      and pp.policy_id                  = vi.policy_id
      and ph.fund_id                    = f.fund_id
      and pr.product_id                 = ph.product_id
      and pp.doc_status_ref_id          = dsr.doc_status_ref_id
      and t1.pol_num                    = pp.pol_num
order by rn;

grant select on V_REP_INCOME_RECEIVED to ins_eul;
grant select on V_REP_INCOME_RECEIVED to ins_read;
    