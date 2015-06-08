create materialized view MV_PAY_CAH_MAX
refresh force on demand
as
select a.*,
       cc.max_sum_v,
       cc.max_sum,
       cc.max_pay_date_v,
       cc.max_pay_date,
       cc.ta_v,
       cc.sum_ta,
       cc.ta_v_fund,
       cc.sum_ta_fund,
       cc.pay_count
  FROM (select max(c.max_sum_v)      max_sum_v,
               max(c.max_sum)        max_sum,
               max(c.max_pay_date_v) max_pay_date_v,
               max(c.max_pay_date)   max_pay_date,
               sum(c.ta_v)        ta_v,
               sum(c.sum_ta)      sum_ta,
               sum(c.ta_v_fund)   ta_v_fund,
               sum(c.sum_ta_fund) sum_ta_fund,
               count(distinct c.parent_doc_id) pay_count,
               c.POL_HEADER_ID,
               c.risk_type_id
        from (
        select case when b.n = 1 or b.n_v = 1 then b.ta_v   end max_sum_v,
               case when b.n = 1 or b.n_v = 1 then b.sum_ta end max_sum,
               case when b.n = 1 or b.n_v = 1 then b.pay_date_v end max_pay_date_v,
               case when b.n = 1 or b.n_v = 1 then b.pay_date   end max_pay_date,
               b.ta_v,
               b.sum_ta,
               b.ta_v_fund,
               b.sum_ta_fund,
               b.parent_doc_id,
               b.POL_HEADER_ID,
               b.risk_type_id
         from (select case when t.tRANS_TEMPL_ID =  562 then SUM(t.rur_amount) end ta_v,
                      case when t.tRANS_TEMPL_ID <> 562 then SUM(t.rur_amount) end sum_ta,
                      case when t.tRANS_TEMPL_ID =  562
                           then SUM(case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                                         then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                        ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
                                         else t.doc_amount end) end ta_v_fund,
                      case when t.tRANS_TEMPL_ID <> 562
                           then SUM(case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                                         then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                        ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
                                         else t.doc_amount end) end sum_ta_fund,
                      case when t.tRANS_TEMPL_ID =  562 then d.reg_date end pay_date_v,
                      case when t.tRANS_TEMPL_ID <> 562 then d.reg_date end pay_date,
                      t.pol_header_id,
                      t.risk_type_id,
                      dso.parent_doc_id,
                      case when t.tRANS_TEMPL_ID =  562 then
                      row_number() over (PARTITION BY t.pol_header_id, t.risk_type_id ORDER BY d.Reg_Date DESC, d.document_id DESC) end n_v,
                      case when t.tRANS_TEMPL_ID <> 562 then
                      row_number() over (PARTITION BY t.pol_header_id, t.risk_type_id ORDER BY d.Reg_Date DESC, d.document_id DESC) end n
                 FROM INS_DWH.FC_TRANS T,
                      DOC_SET_OFF  DSO,
                      DOCUMENT     D,
                      doc_templ    dt,
                      trans_templ  tt,
                      p_pol_header ph
                WHERE tt.trans_templ_id = T.TRANS_TEMPL_ID
                  and ph.policy_header_id = t.pol_header_id
                  AND T.DOCUMENT_ID = DSO.DOC_SET_OFF_ID
                  AND DSO.CHILD_DOC_ID = D.DOCUMENT_ID
                  AND dt.doc_templ_id  = D.DOC_TEMPL_ID
                  and dt.brief in ('ПП','ПП_ОБ','ПП_ПС','PAYORDER_SETOFF','ЗачетУ_КВ')--,'PAYMENT_SETOFF_ACC','PAYMENT_SETOFF')
                  and doc.get_doc_status_brief(d.document_id) <> 'ANNULATED'
                  and tt.brief in ('СтраховаяПремияОплачена','УдержКВ','ЗачВзнСтрАг',--'ВозврПремииВыплВзаимозач',
                                   'ПремияОплаченаПоср','СтраховаяПремияАвансОпл')
                  --and t.pol_header_id =  8742760
               group by t.pol_header_id, t.risk_type_id, d.reg_date, d.document_id, t.tRANS_TEMPL_ID,dso.parent_doc_id
              ) b
             )c
        group by c.POL_HEADER_ID, c.risk_type_id
       ) cc,
       MV_pay_cah_risk a
where cc.POL_HEADER_ID (+)= a.ph_id
  and cc.risk_type_id  (+)= a.plo_id;

