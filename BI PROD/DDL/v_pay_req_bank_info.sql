create or replace force view v_pay_req_bank_info as
select c.obj_name_orig as receiver_name-- ФИО получателя
      ,(select ci.id_value
          from ins.ven_cn_contact_ident    ci
              ,ins.t_id_type               it
         where it.brief            = 'INN'
           and ci.country_id       = cn.id
           and ci.id_type          = it.id
           and ci.contact_id       = acc.bank_id) as inn_value -- ИНН банка
      ,p.pol_num -- Договор №
      ,(select ci.id_value
          from ins.ven_cn_contact_ident    ci
              ,ins.t_id_type               it
         where it.brief            = 'BIK'
           and ci.country_id       = cn.id
           and ci.id_type          = it.id
           and ci.contact_id       = acc.bank_id) as bik_value -- БИК
      ,acc.account_nr -- Р/сч
      , case when nvl(acc.account_corr,'X') = 'X' then acc.account_nr
             else acc.account_corr end as card_num -- Лицевой счет/Карточный номер
      ,acc.bank_name -- Отделение банка
      ,(select ci.id_value
          from ins.ven_cn_contact_ident    ci
              ,ins.t_id_type               it
         where it.brief            = 'KPP'
           and ci.country_id       = cn.id
           and ci.id_type          = it.id
           and ci.contact_id       = acc.bank_id) as kpp_value -- КПП банка
  from ins.ven_ac_payment          ap
      ,ins.doc_doc                 dd
      ,ins.ac_payment_templ        apt
      ,ins.doc_templ               dt
      ,ins.p_policy                p
      ,ins.contact                 c
      ,ins.ven_cn_contact_bank_acc acc
      ,ins.ven_cn_contact_bank_acc ccba
      ,ins.t_country               cn
 where ap.payment_id          = dd.child_id
   and ap.payment_templ_id    = apt.payment_templ_id
   and apt.brief              = 'PAYREQ'
   and ap.doc_templ_id        = dt.doc_templ_id
   and dt.brief               = 'PAYREQ'
   and dd.parent_id           = p.policy_id
   and ap.contact_id          = c.contact_id
   and ap.contact_bank_acc_id = acc.id
   and c.contact_id           = ccba.bank_id (+)
   and cn.description         = 'Россия'
;

