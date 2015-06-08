CREATE OR REPLACE FORCE VIEW V_TRAST_REPORT AS
select ph.ids
       , c.obj_name
       , cp.date_of_birth
       , (SELECT tg.description
          FROM ins.T_GENDER tg
         WHERE tg.id=cp.gender
           AND rownum=1)         gender       
       , plo.description
       , pc.start_date
       , pc.end_date
       , pc.ins_amount
       , nvl(pc.premium,0) as premium
       , CASE WHEN pp.version_num=1 THEN 'Договор страхования'
            ELSE 'Дополнительное соглашение' END policy_type    
       , pp.version_num
       , ins.pkg_readonly.get_doc_status_name(pp.policy_id) ver_status
       , vpi.contact_name issuer_name
       , sh.imaging       
from p_pol_header ph
     , p_policy pp
      ,ins.v_pol_issuer       vpi     
     , as_asset aa
     , as_assured aas
     , contact c
     , cn_person cp
     , p_cover pc
     , status_hist sh
     , t_prod_line_option plo
     , (select t1.rn, to_number(t1.column_value) ids, to_number(t2.column_value) ver_num from
          (
          select rownum rn , t.*
          from (      
          select column_value from table(cast(pkg_utils.get_splitted_string(replace(
                                           --'1920000395, 1920000370'
                                           --'1251113139'
                                           (SELECT r.param_value
                                           FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'trast_report'
                                            AND r.param_name = 'IDS')
               ,' '), ',') as ins.tt_one_col)) ) t )t1,
               
          (
          select rownum rn , t.*
          from (      
          select column_value from table(cast(pkg_utils.get_splitted_string(replace(
                                           --'1, 1'
                                           --'16'
                                           (SELECT r.param_value
                                           FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'trast_report'
                                            AND r.param_name = 'VER_NUM')
               ,' '), ',') as ins.tt_one_col)) ) t) t2
          where t1.rn = t2.rn
        ) tt
where 1=1
      and ph.policy_header_id = pp.pol_header_id
      and pp.policy_id = vpi.policy_id
      and pp.policy_id = aa.p_policy_id      
      and aa.as_asset_id = aas.as_assured_id 
      and aas.assured_contact_id = c.contact_id
      and c.contact_id = cp.contact_id
      and aa.as_asset_id = pc.as_asset_id
      and pc.t_prod_line_option_id = plo.id
      and aa.status_hist_id = sh.status_hist_id
      and sh.imaging = '+'
      and pp.start_date between --'01.01.1900' and '31.12.2999'
                                 nvl((SELECT r.param_value
                                           FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'trast_report'
                                            AND r.param_name = 'DATE_FROM'),'01.01.1900')
                                 and nvl((SELECT r.param_value
                                               FROM ins_dwh.rep_param r
                                              WHERE r.rep_name = 'trast_report'
                                                AND r.param_name = 'DATE_TO'),'31.12.2999')
--      and pp.is_group_flag = 1
      and ph.ids = tt.ids
      and pp.version_num = tt.ver_num
;

