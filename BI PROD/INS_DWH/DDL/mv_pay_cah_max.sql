CREATE MATERIALIZED VIEW INS_DWH.MV_PAY_CAH_MAX
REFRESH FORCE ON DEMAND
AS
SELECT a.*,
       cc.max_sum_v,
       cc.max_sum,
       cc.max_pay_date_v,
       cc.max_pay_date,
       cc.ta_v,
       cc.ta_vu,
       cc.sum_ta,
       cc.ta_v_fund,
       cc.ta_vu_fund,
       cc.sum_ta_fund,
       cc.pay_count
  FROM (SELECT max(c.max_sum_v)      max_sum_v,
               max(c.max_sum)        max_sum,
               max(c.max_pay_date_v) max_pay_date_v,
               max(c.max_pay_date)   max_pay_date,
               sum(c.ta_v)        ta_v,
               sum(c.ta_vu)       ta_vu,
               sum(c.sum_ta)      sum_ta,
               sum(c.ta_v_fund)   ta_v_fund,
               sum(c.ta_vu_fund)  ta_vu_fund,
               sum(c.sum_ta_fund) sum_ta_fund,
               count(distinct c.parent_doc_id) pay_count,
               c.POL_HEADER_ID,
               c.risk_type_id
          FROM (
        SELECT case when b.n = 1 or b.n_v = 1 then b.ta_v   end max_sum_v,
               case when b.n = 1 or b.n_v = 1 then b.sum_ta end max_sum,
               case when b.n = 1 or b.n_v = 1 then b.pay_date_v end max_pay_date_v,
               case when b.n = 1 or b.n_v = 1 then b.pay_date   end max_pay_date,
               b.ta_vu,
               b.ta_vu_fund,
               b.ta_v,
               b.sum_ta,
               b.ta_v_fund,
               b.sum_ta_fund,
               b.parent_doc_id,
               b.POL_HEADER_ID,
               b.risk_type_id
         FROM (SELECT case when t.tRANS_TEMPL_ID =  562 then -SUM(t.rur_amount) end ta_v,
                      sum(CASE WHEN t.trans_templ_id = 741 AND t1.dt_account_id = 501 THEN t.rur_amount eND) ta_vu,
                      case when t.tRANS_TEMPL_ID <> 562 then SUM(t.rur_amount) end sum_ta,
                      sum(case when t.tRANS_TEMPL_ID =  741 AND t1.dt_account_id = 501
                           then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                                         then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                        ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
                                         else t.doc_amount END end) ta_vu_fund,
                      case when t.tRANS_TEMPL_ID =  562
                           then -SUM(case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
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
                      ins.trans        t1,
                      ins.DOC_SET_OFF  DSO,
                      ins.DOCUMENT     D,
                      ins.doc_templ    dt,
                      ins.trans_templ  tt,
                      ins.p_pol_header ph
                WHERE tt.trans_templ_id = T.TRANS_TEMPL_ID
                  AND t1.trans_id = t.trans_id
                  and ph.policy_header_id = t.pol_header_id
                  AND T.DOCUMENT_ID = DSO.DOC_SET_OFF_ID
                  AND DSO.CHILD_DOC_ID = D.DOCUMENT_ID
                  AND dt.doc_templ_id  = D.DOC_TEMPL_ID
                  and dt.brief in ('ПП','ПП_ОБ','ПП_ПС','PAYORDER_SETOFF','ЗачетУ_КВ','PAYMENT_SETOFF_ACC','PAYMENT_SETOFF')
                  and ins.doc.get_doc_status_brief(d.document_id) <> 'ANNULATED'
                  and tt.brief in ('СтраховаяПремияОплачена',
                                   'УдержКВ',
                                   'ЗачВзнСтрАг',
                                   'ВозврПремииВыплВзаимозач',
                                   'ПремияОплаченаПоср',
                                   'СтраховаяПремияАвансОпл')
                  --and t.pol_header_id =  798838
               GROUP by t.pol_header_id, t.risk_type_id, d.reg_date, d.document_id, t.tRANS_TEMPL_ID,dso.parent_doc_id
              ) b
             )c
        GROUP by c.POL_HEADER_ID, c.risk_type_id
       ) cc,
       ins_dwh.MV_pay_cah_risk a
WHERE cc.POL_HEADER_ID (+)= a.ph_id
  and cc.risk_type_id  (+)= a.plo_id;

