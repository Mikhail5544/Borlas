create or replace view v_contact_passport_info as
select co.contact_id
      ,pas.description
      ,pas.serial_nr   as ser_pasp
      ,pas.id_value    as num_pasp
      ,pas.issue_date
      ,pas.place_of_issue as place_issue_pasp
  from contact   co
      ,(select id_value, contact_id, description
              ,serial_nr, issue_date
              ,place_of_issue
          from (select ii.id_value, ii.contact_id, t.description
                      ,ii.serial_nr, ii.issue_date
                      ,ii.place_of_issue
                      ,row_number() over (partition by ii.contact_id order by ii.is_used desc) as rn
                  from ins.cn_contact_ident ii,
                       ins.t_id_type t
                 where ii.id_type = t.id
                   and t.brief = 'PASS_RF')
         where rn = 1
       ) pas
 where co.contact_id = pas.contact_id;
