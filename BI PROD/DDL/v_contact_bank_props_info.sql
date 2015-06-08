create or replace view ins.v_contact_bank_props_info as
select co.contact_id
      ,bik.id_value     as bik
      ,cb.obj_name_orig as name_bank
      ,ba.account_nr    as raccount_bank
      ,ba.lic_code      as licaccount_bank
      ,ba.account_corr  as bank_card_no
      ,inn.id_value     as inn_bank
      ,nvl(oc.obj_name_orig, co.obj_name_orig) as name_recipient
      ,nvl(oc.contact_id,co.contact_id)        as recipient_id
      ,ba.used_flag     as main
  from contact              co
      ,cn_contact_bank_acc  ba
      ,contact              cb
      ,contact              oc
      ,(select id_value, contact_id
          from (select ii.id_value, ii.contact_id
                      ,row_number() over (partition by ii.contact_id order by ii.is_used desc) as rn
                  from ins.cn_contact_ident ii,
                       ins.t_id_type t
                 where ii.id_type = t.id
                   and t.brief = 'BIK')
         where rn = 1
       ) bik
      ,(select id_value, contact_id
          from (select ii.id_value, ii.contact_id
                      ,row_number() over (partition by ii.contact_id order by ii.is_used desc) as rn
                  from ins.cn_contact_ident ii,
                       ins.t_id_type t
                 where ii.id_type = t.id
                   and t.brief = 'INN')
         where rn = 1
       ) inn
 where co.contact_id            = ba.contact_id
   and ba.bank_id               = cb.contact_id
   and cb.contact_id            = bik.contact_id
   and cb.contact_id            = inn.contact_id
   and ba.owner_contact_id      = oc.contact_id (+);
