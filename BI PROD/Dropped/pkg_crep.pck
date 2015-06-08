CREATE OR REPLACE PACKAGE pkg_crep IS

  -- Author  : KALABUKHOV
  -- Created : 08.01.2007 20:46:35
  -- Purpose : Пакет поддержки общесистемных отчетов

  -- функция вычисляет сколько оплачено по договору
  FUNCTION policy_pay(p_pol_header_id IN NUMBER) RETURN NUMBER;

  -- функция вычисляет сколько возвращено по договору
  FUNCTION policy_ret(p_pol_header_id IN NUMBER) RETURN NUMBER;

  -- функция вычисляет количество страхововых событий по договору
  FUNCTION policy_events(p_pol_header_id IN NUMBER) RETURN NUMBER;

  -- функция вычисляет дату очередного неоплаченного счета по договору
  FUNCTION policy_next_pay_date(p_pol_header_id IN NUMBER) RETURN DATE;

  -- функция вычисляет величину заявленных и оплаченных убытков по договору
  FUNCTION policy_loss(p_pol_header_id IN NUMBER) RETURN NUMBER;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_crep IS

  FUNCTION policy_pay(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_res NUMBER;
  BEGIN
    SELECT SUM(t.acc_amount)
      INTO v_res
      FROM trans t
      JOIN trans_templ tt
        ON tt.trans_templ_id = tt.trans_templ_id
      JOIN p_policy p
        ON p.policy_id = t.a2_ct_uro_id
     WHERE tt.brief = 'ЗачВзнСтрАг'
       AND p.pol_header_id = p_pol_header_id;
    RETURN(v_res);
  EXCEPTION
    WHEN no_data_found THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE;
  END;

  FUNCTION policy_ret(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_res NUMBER;
  BEGIN
    SELECT SUM(t.acc_amount)
      INTO v_res
      FROM trans t
      JOIN trans_templ tt
        ON tt.trans_templ_id = tt.trans_templ_id
      JOIN p_policy p
        ON p.policy_id = t.a2_dt_uro_id
     WHERE tt.brief = 'ВозвратЗачДог'
       AND p.pol_header_id = p_pol_header_id;
    RETURN(v_res);
  END;

  FUNCTION policy_events(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_res NUMBER;
  BEGIN
    SELECT COUNT(e.c_event_id)
      INTO v_res
      FROM c_event e
      JOIN as_asset a
        ON a.as_asset_id = e.as_asset_id
      JOIN p_policy p
        ON p.policy_id = a.p_policy_id
     WHERE p.pol_header_id = p_pol_header_id;
    RETURN(v_res);
  END;

  FUNCTION policy_next_pay_date(p_pol_header_id IN NUMBER) RETURN DATE IS
    v_res DATE;
  BEGIN
    SELECT MIN(pvs.due_date)
      INTO v_res
      FROM v_policy_payment_schedule pvs
     WHERE pvs.pol_header_id = p_pol_header_id
       AND NOT EXISTS (SELECT ppsf.parent_doc_id
              FROM v_policy_payment_set_off ppsf
             WHERE ppsf.parent_doc_id = pvs.document_id);
    RETURN(v_res);
  END;

  FUNCTION policy_loss(p_pol_header_id IN NUMBER) RETURN NUMBER IS
    v_res NUMBER;
  BEGIN
    SELECT SUM(c.payment_sum)
      INTO v_res
      FROM c_event e
      JOIN as_asset a
        ON a.as_asset_id = e.as_asset_id
      JOIN p_policy p
        ON p.policy_id = a.p_policy_id
      JOIN c_claim_header ch
        ON ch.c_event_id = e.c_event_id
      JOIN c_claim c
        ON c.c_claim_header_id = ch.c_claim_header_id
     WHERE p.pol_header_id = p_pol_header_id
       AND c.seqno =
           (SELECT MAX(c2.seqno) FROM c_claim c2 WHERE c2.c_claim_header_id = ch.c_claim_header_id);
    RETURN(v_res);
  END;

END;
/
