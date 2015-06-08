create or replace function get_p_cover_id_by_date(p_p_cover_id in number,
                                                  p_date in date)
 return number is
  Result number;
  v_pol_header_id number;
  v_plo_id number;
  v_policy_id number;
begin
  SELECT plo.id,
         pp.pol_header_id
    into v_plo_id, v_pol_header_id
    FROM T_PROD_LINE_OPTION plo,
         P_POLICY pp,
         AS_ASSET aa,
         P_COVER pc
   WHERE pp.policy_id = aa.p_policy_id
     AND aa.as_asset_id = pc.as_asset_id
     AND plo.id = pc.t_prod_line_option_id
     AND pc.p_cover_id = p_p_cover_id
  ;

  SELECT a.policy_id
    into v_policy_id
    FROM (SELECT MAX(pp1.policy_id) OVER(PARTITION BY pp1.pol_header_id) m,
                 pp1.policy_id,
                 dsr.brief q,
                 ds.start_date
            FROM p_policy pp1, doc_status ds, doc_status_ref dsr
           WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
             and pp1.policy_id = ds.document_id
             and ds.start_date <= p_date
             and pp1.pol_header_id = v_pol_header_id
          -- здесь можно поставить ограничение на статус полиса
          -- and dsr.brief in ('PRINTED', 'CURRENT', 'ACTIVE')
           order by ds.start_date desc) a --p_pol_header
   WHERE a.m = a.policy_id
     and rownum = 1;

  SELECT pc.p_cover_id
    into Result
    FROM T_PROD_LINE_OPTION plo, P_POLICY pp, AS_ASSET aa, P_COVER pc
   WHERE pp.policy_id = aa.p_policy_id
     AND aa.as_asset_id = pc.as_asset_id
     AND plo.id = pc.t_prod_line_option_id
     AND pp.policy_id = v_policy_id
     and plo.id = v_plo_id;
  return(Result);
exception
  when others then
    return null;
end get_p_cover_id_by_date;
/

