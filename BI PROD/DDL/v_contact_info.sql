create or replace view v_contact_info as
select co.contact_id
      ,co.name
      ,co.obj_name_orig as full_name
      ,inn.id_value as inn
      ,kpp.id_value as kpp
      ,ct.description
  from contact co
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
                   and t.brief = 'KPP')
         where rn = 1
       ) kpp
      ,t_contact_type  ct
 where co.contact_id      = inn.contact_id (+)
   and co.contact_id      = kpp.contact_id (+)
   and co.contact_type_id = ct.id;
