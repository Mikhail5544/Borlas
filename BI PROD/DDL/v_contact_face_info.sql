create or replace view v_contact_face_info as
select co.contact_id
      ,co.name
      ,co.first_name
      ,co.middle_name
      ,cp.date_of_birth as birth_date
      ,pens.id_value    as num_pens
      ,inn.id_value     as inn_contact
  from contact   co
      ,cn_person cp
      ,(select id_value, contact_id
          from (select ii.id_value, ii.contact_id
                      ,row_number() over (partition by ii.contact_id order by ii.is_used desc) as rn
                  from ins.cn_contact_ident ii,
                       ins.t_id_type t
                 where ii.id_type = t.id
                   and t.brief = 'INN')
         where rn = 1
       ) inn
      ,(select id_value, contact_id
          from (select ii.id_value, ii.contact_id
                      ,row_number() over (partition by ii.contact_id order by ii.is_used desc) as rn
                  from ins.cn_contact_ident ii,
                       ins.t_id_type t
                 where ii.id_type = t.id
                   and t.brief = 'PENS')
         where rn = 1
       ) pens
      ,t_contact_type  ct
 where co.contact_id      = inn.contact_id (+)
   and co.contact_id      = pens.contact_id (+)
   and co.contact_type_id = ct.id
   and ct.brief           = 'тк'
   and co.contact_id      = cp.contact_id;
