CREATE OR REPLACE VIEW V_SMS_REPORT_PAYMENT AS
SELECT contact_name
      ,init_name
      ,pol_ser
      ,pol_num
      ,ids
      ,period
      ,pol_status
      ,department
      ,set_off_amount
      ,cur_brief
      ,due_date
      ,reg_date
      ,tel
      ,tel_1
      ,tel_2
      ,coll_method_desc
      ,'Уважаемый клиент, платеж в размере ' || TRIM(to_char(set_off_amount, '99999990D99')) || ' ' ||
       cur_brief || ' от ' || to_char(due_date, 'dd.mm.yyyy') ||
       ' был зачислен на договор страхования №' || TRIM(to_char(ids)) ||
       ' Ренессанс Жизнь, (495) 981-2-981' text_field
      ,recognize_data
  FROM (SELECT pol.contact_name
              ,pol.init_name
              ,pol.pol_ser
              ,pol.pol_num
              ,pol.ids
              ,pol.period
              ,pol.pol_status
              ,pol.department
              ,SUM(paym.payment_sum) set_off_amount
              ,paym.payment_currency cur_brief
              ,trunc(nvl(pri.payment_data, paym.due_date)) AS due_date
              ,trunc(paym.reg_date) reg_date
              ,pol.tel
              ,pol.tel_1
              ,pol.tel_2
              ,decode(clm.description, 'Прямое списание с карты', 1, 0) coll_method
              ,clm.description coll_method_desc
              ,pri.recognize_data
          FROM ins.tmp$_sms_report_pol   pol
              ,ins.tmp$_sms_report_paym  paym
              ,ins.payment_register_item pri
              ,ins.p_policy              pp
              ,ins.t_collection_method   clm
         WHERE pol.policy_header_id = paym.pol_header_id
           AND pol.policy_id = paym.policy_id
           AND pol.policy_id = pp.policy_id
           AND pp.collection_method_id = clm.id
           AND NOT EXISTS (SELECT 1
                  FROM ins.ven_journal_tech_work jtw
                      ,ins.doc_status_ref        dsr
                 WHERE jtw.doc_status_ref_id = dsr.doc_status_ref_id
                   AND jtw.policy_header_id = pol.policy_header_id
                   AND dsr.brief = 'CURRENT'
                   AND jtw.work_type = 0)
           AND paym.payment_register_item_id = pri.payment_register_item_id
        --and nvl(pri.payment_data, paym.due_date) between DATE '2014-11-24' and DATE '2014-12-24'  
        --and pri.payment_register_item_id=7969519
        
         GROUP BY pol.contact_name
                 ,pol.init_name
                 ,pol.pol_ser
                 ,pol.pol_num
                 ,pol.ids
                 ,pol.period
                 ,pol.pol_status
                 ,pol.department
                 ,paym.payment_currency
                 ,pri.payment_data
                 ,paym.due_date
                 ,trunc(paym.reg_date)
                 ,pol.tel
                 ,pol.tel_1
                 ,pol.tel_2
                 ,clm.description
                 ,pri.recognize_data)
 WHERE set_off_amount > (CASE cur_brief
         WHEN 'RUR' THEN
          200
         WHEN 'EUR' THEN
          6
         WHEN 'USD' THEN
          6
         ELSE
          200
       END);
