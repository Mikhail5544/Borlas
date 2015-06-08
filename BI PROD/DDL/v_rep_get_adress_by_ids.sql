create or replace view v_rep_get_adress_by_ids
as
select  vi.contact_name  as "Фио"
        ,ph.ids          as "ИДС"
        ,pp.pol_num      as "Номер договора"
        ,va.address_name as "Адрес"
from ins.p_pol_header       ph 
     ,ins.p_policy          pp 
     ,ins.v_pol_issuer      vi
     ,ins.v_cn_contact_address va
     ,(select t.IDS
          from (      
                select column_value IDS
                from table(cast(pkg_utils.get_splitted_string(replace(
                                        (SELECT r.param_value
                                           FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'get_adress_rep'
                                            AND r.param_name = 'IDS')
               ,' '), ',') as ins.tt_one_col)) ) t )t1
               
where pp.policy_id          = ph.last_ver_id
      and pp.policy_id      = vi.policy_id
      and va.contact_id     = vi.contact_id
      and ph.ids            = t1.IDS;
      
grant select on  v_rep_get_adress_by_ids to ins_eul;                         
grant select on  v_rep_get_adress_by_ids to ins_read;
