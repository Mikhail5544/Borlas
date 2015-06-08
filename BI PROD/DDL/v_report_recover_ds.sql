CREATE or replace view v_report_recover_ds 
AS
select main.IDS
      ,main.strahovatel
      ,main.type_of_change
      ,main.date_dec
      ,main.date_in_curr
      ,main.st_ver_vosstan
      ,main.Number_vosstan
from(with ad_type as
    (select vppat.p_policy_id, add_t.brief, add_t.DESCRIPTION
    from ins.P_POL_ADDENDUM_TYPE vppat
        ,(select t_addendum_type_id, brief, DESCRIPTION
        from  ins.t_addendum_type t
        where brief in ('RECOVER_MAIN', 'FULL_POLICY_RECOVER')) add_t
    where
    vppat.t_addendum_type_id = add_t.t_addendum_type_id)
    SELECT ph.ids
           ,v.obj_name_orig strahovatel
           ,add_t.DESCRIPTION type_of_change
           ,p2.decline_date date_dec
            ,(
            select trunc(min(ds.change_date))
            from ins.doc_status ds
            where ds.document_id = p.policy_id
            and ds.doc_status_ref_id = 2
            )         date_in_curr
            ,ins.pkg_readonly.get_doc_status_name(p.policy_id) st_ver_vosstan
           ,p.version_num Number_vosstan
    FROM
    ins.p_pol_header ph
    ,ins.p_policy p
    ,ins.ad_type add_t
    ,ins.v_pol_issuer vi   
    ,ins.VEN_CONTACT v
    ,ins.p_policy p2
    ,ins.document d_p2
    ,ins.doc_status_ref dsr_p2
WHERE ph.policy_header_id = p.pol_header_id
  AND add_t.p_policy_id = p.policy_id
  AND P.POLICY_ID = VI.POLICY_ID
  AND vi.contact_id = v.contact_id(+)
  --AND PH.IDS = 1140343031
  and p2.pol_header_id = p.pol_header_id
  and p2.version_num  = p.version_num - 1
  and p2.policy_id = d_p2.document_id
  and dsr_p2.doc_status_ref_id = d_p2.doc_status_ref_id
  and dsr_p2.name = 'Прекращен'
    and exists(select *
               from ins.doc_status ds
               where ds.document_id = p.policy_id
               and ds.doc_status_ref_id = 2
               )
    ORDER BY ph.ids
           ,p.version_num
) main
where main.date_in_curr between
                                        (SELECT r.param_value
                                           FROM ins_dwh.rep_param r
                                          WHERE r.rep_name = 'recover_ds'
                                            AND r.param_name = 'start_date')
                                        AND (SELECT r.param_value
                                               FROM ins_dwh.rep_param r
                                              WHERE r.rep_name = 'recover_ds'
                                                AND r.param_name = 'end_date');

--main.date_in_curr between to_date('01.01.2013', 'dd.mm.yyyy') and to_date('31.01.2013','dd.mm.yyyy');

grant select on  v_report_recover_ds to ins_eul;  
grant select on  v_report_recover_ds to ins_read;

