CREATE OR REPLACE PACKAGE pkg_agregation IS

  FUNCTION connect_by_insuree(par_agr_custom_id t_agr_custom.t_agr_custom_id%TYPE) RETURN NUMBER;

  FUNCTION get_agr_rate_value(par_fund_id fund.fund_id%TYPE) RETURN rate.rate_value%TYPE;

  PROCEDURE check_agregation(par_cover_id p_cover.p_cover_id%TYPE);

  /*
    Функция проверки образование "дырки" в интервалах
    формы "Группы лимитов" блока "Данные по лимитам"
  */
  FUNCTION check_limit_group_age_blanks
  (
    par_t_agr_limit_group_id     t_agr_limit_group_age.t_agr_limit_group_id%TYPE
   ,par_t_agr_limit_group_age_id t_agr_limit_group_age.t_agr_limit_group_age_id%TYPE
  ) RETURN NUMBER;

END pkg_agregation;
/
CREATE OR REPLACE PACKAGE BODY pkg_agregation IS

  gc_insuree_asset_type_brief t_asset_type.brief%TYPE := 'ASSET_INSUREE_PERSON';
  gc_insuree_asset_type_id    t_asset_type.t_asset_type_id%TYPE;

  FUNCTION connect_by_insuree(par_agr_custom_id t_agr_custom.t_agr_custom_id%TYPE) RETURN NUMBER IS
    v_connect_by_insuree NUMBER(1);
  BEGIN
    SELECT COUNT(*)
      INTO v_connect_by_insuree
      FROM t_agr_custom t
     WHERE t.t_agr_custom_id = par_agr_custom_id
       AND t.t_asset_type_id = gc_insuree_asset_type_id
       AND NOT EXISTS (SELECT NULL
              FROM t_as_type_prod_line atpl
                  ,t_prod_line_option  plo
                  ,t_product_line      pl1
                  ,t_product_line      pl2
                  ,t_product_ver_lob   pvl1
                  ,t_product_ver_lob   pvl2
             WHERE plo.id = t.t_prod_line_option_id
               AND plo.product_line_id = pl1.id
               AND pl1.product_ver_lob_id = pvl1.t_product_ver_lob_id
               AND pvl2.product_version_id = pvl2.product_version_id
               AND pvl2.t_product_ver_lob_id = pl2.product_ver_lob_id
               AND pl2.id = atpl.product_line_id
               AND atpl.asset_common_type_id = t.t_asset_type_id);
    RETURN v_connect_by_insuree;
  END;

  FUNCTION get_agr_rate_value(par_fund_id fund.fund_id%TYPE) RETURN rate.rate_value%TYPE IS
    v_rate_value rate.rate_value%TYPE;
  BEGIN
    SELECT nvl(MAX(rate_value) keep(dense_rank FIRST ORDER BY r.rate_date), 1)
      INTO v_rate_value
      FROM rate      r
          ,rate_type rt
     WHERE 1 = 1
       AND r.rate_type_id = rt.rate_type_id
       AND rt.brief = 'AGGREGATION_EXCHANGE_RATES'
       AND r.base_fund_id = 122
       AND r.contra_fund_id = par_fund_id;
  
    RETURN v_rate_value;
  END get_agr_rate_value;

  PROCEDURE check_agregation(par_cover_id p_cover.p_cover_id%TYPE) IS
    v_prod_line_option_id        p_cover.t_prod_line_option_id%TYPE;
    v_cover_name                 t_prod_line_option.description%TYPE;
    v_agency_id                  p_pol_header.agency_id%TYPE;
    v_asset_type_id              p_asset_header.t_asset_type_id%TYPE;
    v_product_id                 p_pol_header.product_id%TYPE;
    v_policy_header_id           p_pol_header.policy_header_id%TYPE;
    v_policy_id                  p_policy.policy_id%TYPE;
    v_assured_contact_id         NUMBER;
    v_assured_age                NUMBER;
    v_insuree_contact_id         NUMBER;
    v_insuree_age                NUMBER;
    v_is_ins_amo_agregation_skip NUMBER;
  
    v_agregation_limit t_agr_age_limit.limit_value%TYPE;
    v_ins_amount       NUMBER;
  
    v_custom_agregation_found BOOLEAN := FALSE;
  
    FUNCTION check_status_addendum_type(par_policy_id p_policy.policy_id%TYPE) RETURN BOOLEAN IS
      v_run_agregation_check NUMBER(1);
    BEGIN
      SELECT COUNT(*)
        INTO v_run_agregation_check
        FROM dual
       WHERE EXISTS (SELECT NULL
                FROM p_policy            pp
                    ,p_pol_addendum_type pa
                    ,document            d
                    ,doc_templ_status    dts
                    ,t_agr_addendum_type aat
                    ,t_agr_policy_status aps
               WHERE pp.policy_id = par_policy_id
                 AND pa.p_policy_id = pp.policy_id
                 AND pa.t_addendum_type_id = aat.t_addendum_type_id
                 AND pp.policy_id = d.document_id
                 AND d.doc_status_ref_id = dts.doc_status_ref_id
                 AND dts.doc_templ_status_id = aps.doc_templ_status_id);
      RETURN v_run_agregation_check = 1;
    END check_status_addendum_type;
  
    FUNCTION get_limit_for_age
    (
      par_limit_group_id NUMBER
     ,par_age            NUMBER
     ,par_cover_name     VARCHAR2
    ) RETURN t_agr_age_limit.limit_value%TYPE IS
      v_limit_value t_agr_age_limit.limit_value%TYPE;
      v_group_num   t_agr_limit_group.group_num%TYPE;
    
      v_t_agr_limit_group dml_t_agr_limit_group.tt_t_agr_limit_group;
    BEGIN
    
      SELECT l.limit_value
            ,lg.group_num
        INTO v_limit_value
            ,v_group_num
        FROM ins.t_agr_limit_group     lg
            ,ins.t_agr_limit_group_age lga
            ,ins.t_agr_age_limit       l
       WHERE lg.t_agr_limit_group_id = par_limit_group_id
         AND lg.t_agr_limit_group_id = lga.t_agr_limit_group_id
         AND lga.t_agr_age_limit_id = l.t_agr_age_limit_id
         AND par_age >= l.age_from
         AND par_age < l.age_to;
    
      RETURN v_limit_value;
    EXCEPTION
      WHEN no_data_found THEN
        v_t_agr_limit_group := dml_t_agr_limit_group.get_record(par_limit_group_id);
      
        raise_application_error(-20001
                               ,'Внимание! Программа "' || par_cover_name ||
                                '": В настройке выбранной группы лимита №' ||
                                v_t_agr_limit_group.group_num ||
                                ' отсутствует лимит для возраста клиента ' || par_age ||
                                ', возможен перевод в статус "Нестандартный"');
    END get_limit_for_age;
  
  BEGIN
    SELECT pc.t_prod_line_option_id
          ,plo.description
           /** Капля П. 
           Действующим может быть только один агент, 
           но иногда бывают ошикбки в данных и их два, тогда берем последнего
           */
          ,(SELECT MAX(dep.department_id) keep(dense_rank FIRST ORDER BY pad.p_policy_agent_doc_id DESC)
              FROM p_policy_agent_doc pad
                  ,document           d_pad
                  ,doc_status_ref     dsr_pad
                  ,ag_contract_header ach
                  ,department         dep
             WHERE 1 = 1
               AND pad.ag_contract_header_id = ach.ag_contract_header_id
               AND pad.p_policy_agent_doc_id = d_pad.document_id
               AND d_pad.doc_status_ref_id = dsr_pad.doc_status_ref_id
               AND dsr_pad.brief = 'CURRENT'
                  --AND SYSDATE BETWEEN pad.date_begin AND pad.date_end
               AND ach.agency_id = dep.department_id
               AND pad.policy_header_id = ph.policy_header_id) agency_id
          ,ah.t_asset_type_id
          ,ph.product_id
          ,ph.policy_header_id
          ,aa.p_policy_id
          ,aas.assured_contact_id
          ,CASE
             WHEN MONTHS_BETWEEN(pp.start_date, cp_a.date_of_birth) / 12 > 1 THEN
              FLOOR(MONTHS_BETWEEN(pp.start_date, cp_a.date_of_birth) / 12)
             ELSE
              MONTHS_BETWEEN(pp.start_date, cp_a.date_of_birth) / 12
           END assured_age
          ,vi.contact_id
          ,CASE
             WHEN MONTHS_BETWEEN(pp.start_date, cp.date_of_birth) / 12 > 1 THEN
              FLOOR(MONTHS_BETWEEN(pp.start_date, cp.date_of_birth) / 12)
             ELSE
              MONTHS_BETWEEN(pp.start_date, cp.date_of_birth) / 12
           END insuree_age
          ,plo.is_ins_amount_agregation_skip
      INTO v_prod_line_option_id
          ,v_cover_name
          ,v_agency_id
          ,v_asset_type_id
          ,v_product_id
          ,v_policy_header_id
          ,v_policy_id
          ,v_assured_contact_id
          ,v_assured_age
          ,v_insuree_contact_id
          ,v_insuree_age
          ,v_is_ins_amo_agregation_skip
      FROM p_cover            pc
          ,t_prod_line_option plo
          ,as_asset           aa
          ,as_assured         aas
          ,p_policy           pp
          ,p_pol_header       ph
          ,p_asset_header     ah
          ,v_pol_issuer       vi
          ,cn_person          cp
          ,cn_person          cp_a
     WHERE pc.p_cover_id = par_cover_id
       AND pc.t_prod_line_option_id = plo.id
       AND pc.as_asset_id = aa.as_asset_id
       AND aa.as_asset_id = aas.as_assured_id
       AND aa.p_policy_id = pp.policy_id
       AND pp.pol_header_id = ph.policy_header_id
       AND ah.p_asset_header_id = aa.p_asset_header_id
       AND vi.policy_id = pp.policy_id
       AND vi.contact_id = cp.contact_id(+)
       AND aas.assured_contact_id = cp_a.contact_id(+)
       AND plo.agregation_control_flag = 1;
  
    /*
    Агрегация считается только для первой неотмененной версии либо для версий со статусами/доп. соглашениями из списков
    */
    IF v_policy_id =
       pkg_policy.get_first_uncanceled_version(par_policy_header_id => v_policy_header_id)
       OR check_status_addendum_type(v_policy_id)
    THEN
      FOR rec IN (SELECT ac.t_agr_custom_group_id
                        ,ac.t_agr_custom_id
                        ,ac.t_agr_limit_group_id
                        ,lg.group_num
                        ,lg.name
                        ,decode(connect_by_insuree(ac.t_agr_custom_id)
                               ,1
                               ,v_insuree_age
                               ,v_assured_age) age
                        ,decode(connect_by_insuree(ac.t_agr_custom_id)
                               ,1
                               ,v_insuree_contact_id
                               ,v_assured_contact_id) contact_id
                        ,c.obj_name_orig contact_name
                    FROM ins.t_agr_custom      ac
                        ,ins.t_agr_limit_group lg
                        ,contact               c
                   WHERE ac.t_prod_line_option_id = v_prod_line_option_id
                     AND ac.t_agr_limit_group_id = lg.t_agr_limit_group_id
                     AND (ac.t_asset_type_id = v_asset_type_id OR
                         connect_by_insuree(ac.t_agr_custom_id) = 1)
                     AND CASE
                           WHEN ac.department_id IS NOT NULL
                                AND ac.department_id = v_agency_id THEN
                            1
                           WHEN ac.department_id IS NULL
                                AND (SELECT COUNT(*)
                                       FROM t_agr_custom ac2
                                      WHERE ac2.t_agr_custom_group_id = ac.t_agr_custom_group_id
                                        AND ac2.t_prod_line_option_id = ac.t_prod_line_option_id
                                        AND ac2.t_asset_type_id = ac.t_asset_type_id
                                        AND ac2.department_id = v_agency_id) = 0 THEN
                            1
                           ELSE
                            0
                         END = 1
                     AND c.contact_id = decode(connect_by_insuree(ac.t_agr_custom_id)
                                              ,1
                                              ,v_insuree_contact_id
                                              ,v_assured_contact_id))
      LOOP
        v_custom_agregation_found := TRUE;
      
        v_agregation_limit := get_limit_for_age(par_limit_group_id => rec.t_agr_limit_group_id
                                               ,par_age            => rec.age
                                               ,par_cover_name     => v_cover_name);
      
        /*
                WITH asset AS
                 (SELECT aa.as_asset_id
                        ,NULL AS t_asset_type_id
                        ,'INSUREE' typ
                    FROM v_pol_issuer pi
                        ,as_asset     aa
                   WHERE 1 = 1
                     AND pi.policy_id = aa.p_policy_id
                     AND pi.contact_id = rec.contact_id
                  UNION ALL
                  SELECT aa.as_asset_id
                        ,ah.t_asset_type_id
                        ,'ASSURED' typ
                    FROM as_asset       aa
                        ,as_assured     aas
                        ,p_asset_header ah
                   WHERE 1 = 1
                     AND aas.as_assured_id = aa.as_asset_id
                     AND ah.p_asset_header_id = aa.p_asset_header_id
                     AND aas.assured_contact_id = rec.contact_id)
        */
        WITH asset AS
         (SELECT aa.as_asset_id
            FROM v_pol_issuer pi
                ,as_asset     aa
           WHERE 1 = 1
             AND pi.policy_id = aa.p_policy_id
             AND pi.contact_id = rec.contact_id
          UNION
          SELECT aa.as_asset_id
            FROM as_asset       aa
                ,as_assured     aas
                ,p_asset_header ah
           WHERE 1 = 1
             AND aas.as_assured_id = aa.as_asset_id
             AND ah.p_asset_header_id = aa.p_asset_header_id
             AND aas.assured_contact_id = rec.contact_id)
        SELECT nvl(SUM(ROUND(get_agr_rate_value(ph.fund_id) * pc.ins_amount, 2)), 0)
          INTO v_ins_amount
          FROM asset              aaa
              ,p_pol_header       ph
              ,as_asset           aa
              ,t_agr_custom       ac
              ,p_cover            pc
              ,t_prod_line_option plo
              ,status_hist        sh
         WHERE 1 = 1
           AND aaa.as_asset_id = aa.as_asset_id
              /*
              AND ((pkg_agregation.connect_by_insuree(ac.t_agr_custom_id) = 1 AND
                  aaa.as_asset_id = aa.as_asset_id AND aaa.typ = 'INSUREE') OR
                  (pkg_agregation.connect_by_insuree(ac.t_agr_custom_id) = 0 AND
                  aaa.as_asset_id = aa.as_asset_id AND aaa.t_asset_type_id = ac.t_asset_type_id AND
                  aaa.typ = 'ASSURED'))
              */
           AND ac.t_agr_custom_group_id = rec.t_agr_custom_group_id
           AND ac.t_prod_line_option_id = pc.t_prod_line_option_id
           AND aa.as_asset_id = pc.as_asset_id
           AND pc.t_prod_line_option_id = plo.id
           AND pc.status_hist_id = sh.status_hist_id
           AND sh.brief != 'DELETED'
           AND ac.department_id IS NULL
           AND ph.max_uncancelled_policy_id = aa.p_policy_id
           AND plo.is_ins_amount_agregation_skip = 0
              /**********************************************
              Если программа является Родительской и существует
              связь с Дочерней программой с флагом = 1, то
              Ищем, входит ли найденная программа в состав 
              набора рисков по ДС. Если не входит, то Родительская
              программа не должна быть в отборе
              ***********************************************/
           AND CASE v_is_ins_amo_agregation_skip
                 WHEN 0 THEN
                  CASE
                    WHEN EXISTS (SELECT NULL
                            FROM parent_prod_line   ppl2
                                ,t_prod_line_option plo2
                           WHERE 1 = 1
                             AND ppl2.t_parent_prod_line_id = plo.product_line_id
                             AND ppl2.t_prod_line_id = plo2.product_line_id
                             AND plo2.is_ins_amount_agregation_skip = 1)
                         AND NOT EXISTS (SELECT NULL
                            FROM parent_prod_line   ppl3
                                ,t_prod_line_option plo3
                                ,p_cover            pc3
                           WHERE 1 = 1
                             AND ppl3.t_parent_prod_line_id = plo.product_line_id
                             AND ppl3.t_prod_line_id = plo3.product_line_id
                             AND plo3.id = pc3.t_prod_line_option_id
                             AND pc3.as_asset_id = aa.as_asset_id
                             AND plo3.is_ins_amount_agregation_skip = 1) THEN
                     0
                  
                    ELSE
                     1
                  END
                 ELSE
                  1
               END = 1
           AND EXISTS (SELECT NULL
                  FROM document                d
                      ,doc_templ               dt
                      ,doc_templ_status        dts
                      ,ins.t_agr_policy_status aps
                 WHERE d.document_id = aa.p_policy_id
                   AND d.doc_templ_id = dt.doc_templ_id
                   AND dt.brief = 'POLICY'
                   AND d.doc_templ_id = dts.doc_templ_id
                   AND d.doc_status_ref_id = dts.doc_status_ref_id
                   AND dts.doc_templ_status_id = aps.doc_templ_status_id);
        IF v_agregation_limit < v_ins_amount
        THEN
          raise_application_error(-20001
                                 ,'Внимание! Страховая сумма по программе ' || v_cover_name ||
                                  ' в договорах клиента ' || rec.contact_name || ' составляет ' ||
                                  v_ins_amount ||
                                  ' рублей - что превышает допустимый лимит в размере ' ||
                                  v_agregation_limit || ', возможен перевод в статус "Нестандартный"');
        END IF;
      
      END LOOP;
    
      IF NOT v_custom_agregation_found
      THEN
        FOR rec IN (SELECT plop.peril_id
                          ,pa.t_agr_limit_group_id
                          ,p.description
                      FROM t_prod_line_opt_peril plop
                          ,t_peril_agregation    pa
                          ,t_peril               p
                     WHERE plop.product_line_option_id = v_prod_line_option_id
                       AND plop.peril_id = pa.t_peril_id
                       AND plop.peril_id = p.id)
        LOOP
          v_custom_agregation_found := TRUE;
        
          v_agregation_limit := get_limit_for_age(par_limit_group_id => rec.t_agr_limit_group_id
                                                 ,par_age            => v_assured_age
                                                 ,par_cover_name     => v_cover_name);
        
          SELECT nvl(SUM(ROUND(get_agr_rate_value(ph.fund_id) * pc.ins_amount, 2)), 0)
            INTO v_ins_amount
            FROM p_cover               pc
                ,as_asset              aa
                ,p_pol_header          ph
                ,as_assured            aas
                ,t_prod_line_opt_peril plop
                ,status_hist           sh
                ,t_prod_line_option    plo
           WHERE aas.assured_contact_id = v_assured_contact_id
             AND aas.as_assured_id = aa.as_asset_id
             AND aa.as_asset_id = pc.as_asset_id
             AND pc.status_hist_id = sh.status_hist_id
             AND sh.brief != 'DELETED'
             AND pc.t_prod_line_option_id = plop.product_line_option_id
             AND plop.peril_id = rec.peril_id
             AND pc.t_prod_line_option_id = plo.id
             AND plo.agregation_control_flag = 1
             AND plo.is_ins_amount_agregation_skip = 0
             AND ph.max_uncancelled_policy_id = aa.p_policy_id
             AND EXISTS (SELECT NULL
                    FROM document                d
                        ,doc_templ               dt
                        ,doc_templ_status        dts
                        ,ins.t_agr_policy_status aps
                   WHERE d.document_id = aa.p_policy_id
                     AND d.doc_templ_id = dt.doc_templ_id
                     AND dt.brief = 'POLICY'
                     AND d.doc_templ_id = dts.doc_templ_id
                     AND d.doc_status_ref_id = dts.doc_status_ref_id
                     AND dts.doc_templ_status_id = aps.doc_templ_status_id);
        
          IF v_agregation_limit < v_ins_amount
          THEN
            raise_application_error(-20001
                                   ,'Внимание! Страховая сумма по программе ' || v_cover_name ||
                                    ' в договорах клиента составляет ' ||
                                    pkg_contact.get_contact_name_by_id(v_assured_contact_id) ||
                                    ' составляет ' || v_ins_amount ||
                                    ' рублей - что превышает допустимый лимит в размере ' ||
                                    v_agregation_limit ||
                                    ', возможен перевод в статус "Нестандартный"');
          END IF;
        
        END LOOP;
      
        IF NOT v_custom_agregation_found
        THEN
          raise_application_error(-20001
                                 ,'Внимание! В настройке агрегации рисков нет настройки для риска ' ||
                                  v_cover_name || ', возможен перевод в статус "Нестандартный"');
        END IF;
      
      END IF;
    END IF;
  
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END check_agregation;

  /*
    Функция проверки образование "дырки" в интервалах
    формы "Группы лимитов" блока "Данные по лимитам"
  */
  FUNCTION check_limit_group_age_blanks
  (
    par_t_agr_limit_group_id     t_agr_limit_group_age.t_agr_limit_group_id%TYPE
   ,par_t_agr_limit_group_age_id t_agr_limit_group_age.t_agr_limit_group_age_id%TYPE
  ) RETURN NUMBER IS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*)
      INTO v_result
      FROM dual
     WHERE EXISTS (SELECT NULL
              FROM (SELECT CASE
                             WHEN al.age_to =
                                  nvl(lead(al.age_from) over(PARTITION BY lga.t_agr_limit_group_id
                                           ORDER BY al.age_from)
                                     ,al.age_to) THEN
                              1
                             ELSE
                              0
                           END age_check
                      FROM t_agr_limit_group_age lga
                          ,t_agr_age_limit       al
                     WHERE lga.t_agr_age_limit_id = al.t_agr_age_limit_id
                       AND lga.t_agr_limit_group_id = par_t_agr_limit_group_id
                       AND lga.t_agr_limit_group_age_id <> par_t_agr_limit_group_age_id)
             WHERE age_check = 0);
  
    RETURN v_result;
  END check_limit_group_age_blanks;

BEGIN
  SELECT at.t_asset_type_id
    INTO gc_insuree_asset_type_id
    FROM t_asset_type at
   WHERE at.brief = gc_insuree_asset_type_brief;
END pkg_agregation;
/
