CREATE OR REPLACE VIEW INS_DWH.V_TRANS_REP AS
SELECT PP.POL_HEADER_ID,
       'о' "Тип",
       t.risk_type_id,
       t.trans_id,
       t.trans_templ_id,
       tt.name "Шаблон проводки",
       Case
                When trunc(t.trans_date,'dd') between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then trunc(t.trans_date,'dd')
       End
       as trans_date  
      ,Case
                When trunc(t.trans_doc_date,'dd') between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then trunc(t.trans_doc_date,'dd')
       End
       as trans_doc_date  
      ,Case
                When trunc(d.due_date,'dd') between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then trunc(d.due_date,'dd')
       End
       as trans_doc_date_2         
       
      ,Case
                When trunc(t.trans_reg_date,'dd') between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then trunc(t.trans_reg_date,'dd')
       End
       as trans_reg_date,    
       t.rur_amount,
       case when ph.fund_id <> 122 and t.doc_fund = 'RUR' 
            then round(t.doc_amount/decode(ins.pkg_readonly.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                 ins.pkg_readonly.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
            else t.doc_amount end doc_amount,
       t.doc_fund,
       'Borlas' Borlas,
       t.p_cover_id
      ,t.dt_num
      ,t.ct_num
 FROM INS_DWH.FC_TRANS T,
       ins.P_POLICY     PP,
       ins.p_pol_header ph,
       ins.DOC_SET_OFF  DSO,
       ins.ven_ac_payment  D,
       ins.doc_templ    dt,
       ins.trans_templ  tt,
       ins.ac_payment   ap
 WHERE tt.trans_templ_id = T.TRANS_TEMPL_ID
   AND PP.POL_HEADER_ID  = t.pol_header_id 
   and pp.policy_id      = ph.policy_id
   AND pp.is_group_flag  = 0
   AND T.DOCUMENT_ID    = DSO.DOC_SET_OFF_ID
   AND DSO.CHILD_DOC_ID = D.payment_id 
   AND dt.doc_templ_id  = D.DOC_TEMPL_ID
   AND ((tt.brief in ('СтраховаяПремияОплачена',
                      'ЗачВзнСтрАг',
                      'ПремияОплаченаПоср',
                      'СтраховаяПремияАвансОпл')
        and dt.brief in ('ПП','ПП_ОБ','ПП_ПС')
        )
        or (tt.brief in ('СтраховаяПремияАвансОпл','УдержКВ') --Убыток и выплата КВ
            and dt.brief in ('PAYORDER_SETOFF','ЗачетУ_КВ')
           )
       )               
   and t.trans_date between ins_dwh.pkg_reserves_vs_profit.get_trans_begin_date
                        and ins_dwh.pkg_reserves_vs_profit.get_trans_end_date
   and ap.payment_id = dso.parent_doc_id   
 --  AND t.trans_id = 35523168
union all
-------Детализация начислений:
SELECT pp.pol_header_id,
       'н' "Тип",
       t.risk_type_id,
       t.trans_id,
       t.trans_templ_id,      
       tt.name "Шаблон проводки",
       Case
                When trunc(t.trans_date,'dd') between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then trunc(t.trans_date,'dd')
       End
       as trans_date,         
       Case
                When trunc(t.trans_doc_date,'dd') between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then trunc(t.trans_doc_date,'dd')
       End
       as trans_doc_date,              
       null trans_doc_date_2,
       Case
                When trunc(t.trans_reg_date,'dd') between to_date('01.01.1900', 'dd.mm.yyyy') and to_date('31.12.2099', 'dd.mm.yyyy')
                Then trunc(t.trans_reg_date,'dd')
       End as trans_reg_date,            
       t.rur_amount,
       case when ph.fund_id <> 122 and t.doc_fund = 'RUR' 
            then round(t.doc_amount/decode(ins.pkg_readonly.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                                 ins.pkg_readonly.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
            else t.doc_amount end doc_amount,
       t.doc_fund,
       'Borlas' Borlas,
       t.p_cover_id
      ,t.dt_num
      ,t.ct_num
  FROM INS_DWH.FC_TRANS t,
       ins.p_policy pp,
       ins.p_pol_header ph,
       ins.trans_templ  tt
 WHERE tt.trans_templ_id = t.trans_templ_id
   /*and tt.brief in ('НачПремия'
                    ,'МСФОПремияНачAPE'
                    ,'МСФОПремияНач'
                    ,'НачВозврат'
                    ,'Storno.NachPrem'
                    ,'ПоложКРОтАгента'
                    ,'ОтрицКРБезАгента'
                    ,'QUIT_MAIN_1'
                    ,'QUIT_MAIN_2'
                    ,'НачПремияПрЛет'
                    ,'QUIT_FIX_33'
                    ,'ДеньгиВыплБезнал'
                    ,'QUIT_MAIN_15'
                    )*/
   and tt.brief not in('СтраховаяПремияОплачена',
                       'ЗачВзнСтрАг',
                       'ПремияОплаченаПоср',
                       'СтраховаяПремияАвансОпл'
                      ,'УдержКВ')
   AND ph.policy_header_id = t.pol_header_id
   and pp.policy_id = ph.policy_id
   and t.trans_date between ins_dwh.pkg_reserves_vs_profit.get_trans_begin_date
                        and ins_dwh.pkg_reserves_vs_profit.get_trans_end_date;
