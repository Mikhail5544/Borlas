CREATE MATERIALIZED VIEW INS_DWH.MV_PAY_CAH
REFRESH FORCE ON DEMAND
AS
SELECT a.*,
       b.min_BACK_date,
       b.ta_BACK_ru,
       b.ta_BACK_fund,
       b.min_BACK_pay_date,
       b.ta_BACK_pay_ru,
       b.ta_BACK_pay_fund,
       b.min_KV_date,
       b.ta_KV_ru,
       b.ta_KV_fund,
       b.min_FK_date,
       b.ta_FK_ru,
       b.ta_FK_fund,
       b.nach_after_gkr
  FROM ins_dwh.MV_pay_cah_max a,
       (SELECT min(case when tt.brief = 'НачВозврат' then t.trans_date end) min_BACK_date,
               sum(case when tt.brief = 'НачВозврат' then t.rur_amount end) ta_BACK_ru,
               sum(case when tt.brief = 'НачВозврат'
                        then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                                  then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                 ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
                                  else t.doc_amount end end) ta_BACK_fund,

               min(case when tt.brief = 'ВозврПремииВыплВзаимозач' then t.trans_date end) min_BACK_pay_date,
               sum(case when tt.brief = 'ВозврПремииВыплВзаимозач' then t.rur_amount end) ta_BACK_pay_ru,
               sum(case when tt.brief = 'ВозврПремииВыплВзаимозач'
                        then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                                  then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                 ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
                                  else t.doc_amount end end) ta_BACK_pay_fund,

               min(case when tt.brief = 'УдержКВ' then t.trans_date end) min_KV_date,
               sum(case when tt.brief = 'УдержКВ' then t.rur_amount end) ta_KV_ru,
               sum(case when tt.brief = 'УдержКВ'
                        then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                                  then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                 ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
                                  else t.doc_amount end end) ta_KV_fund,
               min(case when tt.brief = 'Storno.NachPrem' then t.trans_date end) min_FK_date,
               sum(case when tt.brief = 'Storno.NachPrem' then t.rur_amount end) ta_FK_ru,
               sum(case when tt.brief = 'Storno.NachPrem'
                        then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                                  then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                 ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
                                  else t.doc_amount end end) ta_FK_fund,
               sum(case when tt.brief = 'НачПремия' then t.rur_amount end) nach_after_gkr,
               t.pol_header_id ph,
               t.risk_type_id  plo
          FROM INS_DWH.FC_TRANS T,
               ins.trans_templ      tt,
               ins.p_pol_header     ph
         WHERE tt.trans_templ_id = t.trans_templ_id
           and ph.policy_header_id = t.pol_header_id
           and ((tt.brief in ('НачВозврат','УдержКВ','ВозврПремииВыплВзаимозач')
                 or(tt.brief = 'НачПремия'
                    and t.trans_date > = (SELECT max(p2.start_date)
                                            FROM ins.p_policy        p2
                                           WHERE ins.doc.get_doc_status_brief(p2.policy_id) in ('READY_TO_CANCEL','BREAK')
                                             and p2.pol_header_id = t.pol_header_id
                                          )
                   )
                and t.trans_date between '01.01.2010' and '31.12.2010'
                )
                or (tt.brief = 'Storno.NachPrem'
                    and t.trans_date >= '01.01.2010')
               )
        GROUP by t.pol_header_id, t.risk_type_id
        )b
 WHERE b.ph (+) = a.ph_id
   and b.plo (+)= a.plo_id;

