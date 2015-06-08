CREATE OR REPLACE VIEW V_AGENT_BANK_INFO AS
SELECT ach.agent_id  contact_id
      ,cn.obj_name_orig  --1
      ,ach.num           --1
      --181102 Проблемы с представлением insi.v_agent_bank_info_facade /комментарий/
      /*,(SELECT cci_in.id_value
          FROM ins.cn_contact_ident cci_in
         WHERE cci_in.contact_id=vabp.bank_id
           AND cci_in.id_type=10)                      bik*/
      ,(  
         SELECT cci_in.id_value
         FROM ins.cn_contact_ident cci_in
         WHERE cci_in.table_id  =  pkg_contact.get_contact_document_id(vabp.bank_id, 'BIK')
       ) bik
      --end--181102 Проблемы с представлением insi.v_agent_bank_info_facade
      ,(SELECT bcn.obj_name_orig FROM contact bcn WHERE bcn.contact_id=vabp.bank_id) name_bank
      ,vabp.account              raccount_bank
      ,vabp.payment_props        licaccount_bank
      ,nvl(cba.account_corr,vabp.payment_props)        bank_card_no
      --181102 Проблемы с представлением insi.v_agent_bank_info_facade /комментарий/
      /*,(SELECT cci_in.id_value
          FROM ins.cn_contact_ident cci_in
         WHERE cci_in.contact_id=vabp.bank_id
           AND cci_in.id_type=1)                    inn_bank*/
      ,(   
         SELECT cci_in.id_value
         FROM ins.cn_contact_ident cci_in
         WHERE cci_in.table_id  =  pkg_contact.get_contact_document_id(vabp.bank_id, 'INN')     
        ) inn_bank
      --end--181102 Проблемы с представлением insi.v_agent_bank_info_facade
      ,nvl(cba.owner_contact_id,ach.agent_id)                          recipient_id
      ,(SELECT ocn.obj_name_orig 
        FROM contact ocn 
        WHERE ocn.contact_id=nvl(cba.owner_contact_id,ach.agent_id)
       ) name_recipient
      ,vabp.enable              main
  FROM ins.ven_ag_contract_header    ach
      ,ins.contact                   cn
      ,ins.document                  dc
      ,ven_ag_bank_props             vabp
      ,ins.cn_contact_bank_acc       cba
  WHERE cn.contact_id                = ach.agent_id
   AND dc.document_id                = ach.ag_contract_header_id
   AND vabp.ag_contract_header_id    = ach.ag_contract_header_id
   AND cba.id(+)                     = vabp.cn_contact_bank_acc_id
   AND dc.doc_status_ref_id          = 2
   AND ach.is_new                    = 1;
                       
                       
                       
