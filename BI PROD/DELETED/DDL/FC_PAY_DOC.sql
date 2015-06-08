create materialized view INS_DWH.FC_PAY_DOC
refresh force on demand
as
select /*ph.policy_header_id,
       ph.ids,
       pp.pol_num,
       plan_doc.num,*/

       pay_doc.num,
       plan_doc.payment_id epg_id,
       dso.Set_Off_Child_Amount set_of_amt_rur,
       dso.set_off_amount set_of_amt,
       dso.set_off_date,
       dso.set_off_rate,
       pay_pt.title payment_templ_title,
       pay_doc.due_date pay_date,
       pay_doc.reg_date pp_reg_date,
       f.brief pp_fund,
       dso.doc_set_off_id,
       null pd4_date,
       null "Сумма зачета в руб. по А7/ПД4",
       null "Сумма зачета по А7/ПД4",
       null "Дата оплаты по А7/ПД4",
       to_number(null) "Сумма зачета (реальная)",
       cm.description coll_metod,
       d_pay_doc.reg_date "Дата документа"
     from
          ins.p_pol_header          ph
          ,ins.t_product            prod
          ,ins.p_policy             pp
          ,ins.doc_doc              dd
          ,ins.ven_ac_payment       plan_doc
          ,ins.doc_set_off          dso
          ,ins.ven_ac_payment       pay_doc
          ,ins.ac_payment_templ     plan_pt
          ,ins.ac_payment_templ     pay_pt
          ,ins.fund                 f
          ,ins.t_collection_method  cm
          ,ins.document                 d_pay_doc --Чирков/182165: доработка отчета в DWH <Копия_DWH_Отчет для колл
      where 1=1
      and plan_doc.payment_id = dso.parent_doc_id
      and pay_doc.payment_id = dso.child_doc_id
      and plan_doc.payment_templ_id = plan_pt.payment_templ_id
      and plan_pt.brief = 'PAYMENT'
      and pay_doc.payment_templ_id in (2,16123,16125)
      and pay_doc.payment_templ_id = pay_pt.payment_templ_id
      and dd.child_id = plan_doc.payment_id
      and pp.policy_id = dd.parent_id
      and ph.policy_header_id = pp.pol_header_id
      and ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED'
      and pay_doc.fund_id = f.fund_id (+)
      and cm.id = pay_doc.collection_metod_id
      AND ph.product_id = prod.product_id
      AND prod.brief NOT IN ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
      --Чирков/182165: доработка отчета в DWH <Копия_DWH_Отчет для колл
      and d_pay_doc.document_id = pay_doc.payment_id
      --182165
      --and ph.ids in (1560118215)
      --and plan_doc.plan_date between to_date('26-02-2011','dd-mm-yyyy') and to_date('25-06-2011','dd-mm-yyyy')

union all

 -- оплата через ПД4 или А7
select /*ph.policy_header_id,
       ph.ids,
       pp.pol_num,
       plan_doc.num,*/

       pay_doc.num,
       plan_doc.payment_id epg_id,
       dso2.Set_Off_Child_Amount set_of_amt_rur,
       round(dso2.set_off_amount*ins.acc.Get_Cross_Rate_By_id(1,pay_doc.fund_id,ph.fund_id,pd4.due_date),2) set_of_amt,
       dso2.set_off_date,
       dso2.set_off_rate,
       pay_pt.title payment_templ_title,
       pay_doc.due_date pay_date,
       pay_doc.reg_date pp_reg_date,
       f.brief pp_fund,
       dso2.doc_set_off_id,
       pd4.due_date pd4_date,
       dso.Set_Off_Child_Amount "Сумма зачета в руб. по А7/ПД4",
       dso.set_off_amount "Сумма зачета по А7/ПД4",
       pd4.due_date "Дата оплаты по А7/ПД4",
       nvl(dso2.set_off_amount, dso.set_off_amount) "Сумма зачета (реальная)",
       cm.description coll_metod,       
       d_pd4.reg_date "Дата документа"
     from
          ins.p_pol_header ph
          JOIN ins.t_product prod ON (ph.product_id = prod.product_id
                                      AND prod.brief NOT IN ('CR92_1','CR92_1.1','CR92_2','CR92_2.1','CR92_3','CR92_3.1')
                                     )
          JOIN ins.ven_p_policy pp on (ph.policy_header_id = pp.pol_header_id)
          JOIN ins.doc_doc dd on (pp.policy_id = dd.parent_id)
          JOIN ins.ven_ac_payment plan_doc on (dd.child_id = plan_doc.payment_id)
          JOIN ins.doc_set_off dso on (plan_doc.payment_id = dso.parent_doc_id AND ins.doc.get_doc_status_brief(dso.doc_set_off_id) <> 'ANNULATED')
          JOIN ins.ac_payment pd4 on (pd4.payment_id = dso.child_doc_id
                                      and pd4.payment_templ_id not in (2,16123,16125,4982,6205,3625,4376,6439,6995,463,757,30,5674,4,736,759,710,1129,4984,475,474)
                                      )
          LEFT JOIN ins.doc_doc dd2 on (dso.child_doc_id = dd2.parent_id)
          LEFT JOIN ins.doc_set_off dso2 on (dso2.parent_doc_id = dd2.child_id AND ins.doc.get_doc_status_brief(dso2.doc_set_off_id) <> 'ANNULATED')
          LEFT JOIN ins.ven_ac_payment pay_doc on (dso2.child_doc_id = pay_doc.payment_id and pay_doc.payment_templ_id in (2,16123,16125))
          LEFT JOIN ins.ac_payment_templ plan_pt on (plan_doc.payment_templ_id = plan_pt.payment_templ_id and plan_pt.brief = 'PAYMENT')
          LEFT JOIN ins.ac_payment_templ pay_pt on (pay_doc.payment_templ_id = pay_pt.payment_templ_id)
          LEFT JOIN ins.fund f on (pay_doc.fund_id = f.fund_id)
          LEFT JOIN ins.t_collection_method cm on (cm.id = pay_doc.collection_metod_id)
          --Чирков/182165: доработка отчета в DWH <Копия_DWH_Отчет для колл                                      
          LEFT JOIN ins.document d_pd4 on d_pd4.document_id = pd4.payment_id
          --182165
          
      where 1=1;

grant select on ins_dwh.fc_pay_doc to ins;
grant select on ins_dwh.fc_pay_doc to ins_eul;
grant select on ins_dwh.fc_pay_doc to ins_read;

