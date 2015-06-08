CREATE OR REPLACE FUNCTION get_pol_br(pol_head    IN NUMBER,
                                      status_date IN DATE DEFAULT SYSDATE)
  RETURN VARCHAR2 IS
  rv VARCHAR2(30);

BEGIN

  SELECT a.q
    into rv
    FROM (SELECT MAX(pp1.policy_id) OVER(PARTITION BY pp1.pol_header_id) m,
                 pp1.policy_id,
                 dsr.brief q
            FROM p_policy pp1, doc_status ds, doc_status_ref dsr
           WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
             and pp1.policy_id = ds.document_id
             and trunc(ds.start_date) <= trunc(last_day(status_date)) --date
             and pp1.pol_header_id = pol_head
          --   and dsr.brief in ('PRINTED', 'CURRENT', 'ACTIVE')
           order by ds.start_date desc) a --p_pol_header
   WHERE a.m = a.policy_id
     and rownum = 1;

  RETURN rv;
END get_pol_br;
/

