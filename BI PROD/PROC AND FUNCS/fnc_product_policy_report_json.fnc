CREATE OR REPLACE FUNCTION fnc_policy_to_json(par_policy_header_id p_pol_header.policy_header_id%TYPE)
  RETURN JSON IS

  TYPE tt_policy_rec IS RECORD(
     ids                          p_pol_header.ids%TYPE
    ,pol_num                      p_policy.pol_num%TYPE
    ,premium                      p_policy.premium%TYPE
    ,total_fee                    NUMBER
    ,ins_amount                   p_policy.ins_amount%TYPE
    ,start_date                   p_pol_header.start_date%TYPE
    ,end_date                     p_policy.end_date%TYPE
    ,product_brief                t_product.brief%TYPE
    ,agent_num                    document.num%TYPE
    ,policy_period                NUMBER
    ,is_credit                    p_policy.is_credit%TYPE
    ,base_sum                     p_policy.base_sum%TYPE
    ,fund_brief                   fund.brief%TYPE
    ,discount_brief               discount_f.brief%TYPE
    ,payment_term_brief           t_payment_terms.brief%TYPE
    ,insuree_contact_id           contact.contact_id%TYPE
    ,policy_header_id             p_pol_header.policy_header_id%TYPE
    ,policy_id                    p_policy.policy_id%TYPE
    ,last_version_status_brief    doc_status_ref.brief%TYPE
    ,current_version_status_brief doc_status_ref.brief%TYPE);

  v_policy_json       JSON := JSON();
  v_policy_info_json  JSON := JSON();
  v_insuree_info_json JSON := JSON();
  v_asset_array       JSON_LIST := JSON_LIST;
  v_cash_surr_table   JSON_LIST;

  v_policy_rec tt_policy_rec;

  FUNCTION generate_contact_info_json(par_contact_id contact.contact_id%TYPE) RETURN JSON IS
    v_contact_info_json JSON := JSON();
    vr_contact          contact%ROWTYPE;
    vr_cn_person        cn_person%ROWTYPE;
    v_address_list      JSON_LIST;
    v_ident_list        JSON_LIST;
    v_telephone_list    JSON_LIST;
  BEGIN
    SELECT * INTO vr_contact FROM contact c WHERE c.contact_id = par_contact_id;
    BEGIN
      SELECT * INTO vr_cn_person FROM cn_person cp WHERE cp.contact_id = par_contact_id;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    v_contact_info_json.put('surname', vr_contact.name);
    v_contact_info_json.put('name', vr_contact.first_name);
    v_contact_info_json.put('midname', vr_contact.middle_name);
  
    IF vr_cn_person.gender = 0
    THEN
      v_contact_info_json.put('gender', 'f');
    ELSE
      v_contact_info_json.put('gender', 'm');
    END IF;
  
    IF vr_cn_person.date_of_birth IS NOT NULL
    THEN
      v_contact_info_json.put('birth_date', to_char(vr_cn_person.date_of_birth, 'dd.mm.yyyy'));
    END IF;
  
    v_contact_info_json.put('is_company'
                           ,1 - pkg_contact.get_is_individual(par_contact_id => par_contact_id));
  
    DECLARE
      v_email cn_contact_email.email%TYPE;
    BEGIN
      SELECT email
        INTO v_email
        FROM (SELECT email
                FROM cn_contact_email cce
               WHERE cce.contact_id = par_contact_id
               ORDER BY cce.is_temp DESC
                       ,cce.status  DESC
                       ,cce.id      DESC)
       WHERE rownum = 1;
      v_contact_info_json.put('email', v_email);
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    IF vr_contact.resident_flag = 0
    THEN
      v_contact_info_json.put('is_foreign', 1);
    ELSE
      v_contact_info_json.put('is_foreign', 0);
    END IF;
  
    v_contact_info_json.put('is_public', vr_contact.is_public_contact);
  
    FOR rec_address IN (SELECT pkg_contact.get_address_name(ca.id) NAME
                              ,ca.zip
                              ,at.brief
                              ,ca.code
                          FROM cn_contact_address cca
                              ,cn_address         ca
                              ,t_address_type     at
                         WHERE cca.contact_id = par_contact_id
                           AND cca.address_type = at.id
                           AND cca.adress_id = ca.id)
    LOOP
      DECLARE
        v_address_json JSON := JSON();
      BEGIN
        IF v_address_list IS NULL
        THEN
          v_address_list := JSON_LIST();
        END IF;
        v_address_json.put('address', rec_address.name);
        v_address_json.put('zip', rec_address.zip);
        v_address_json.put('type', rec_address.brief);
        v_address_json.put('kladr_code', rec_address.code);
        v_address_list.append(v_address_json.to_json_value);
      END;
    END LOOP;
  
    IF v_address_list IS NOT NULL
    THEN
      v_contact_info_json.put('addresses', v_address_list.to_json_value);
    END IF;
  
    FOR rec_certs IN (SELECT it.brief
                            ,cci.serial_nr
                            ,cci.id_value
                            ,cci.place_of_issue
                            ,cci.issue_date
                        FROM cn_contact_ident cci
                            ,t_id_type        it
                       WHERE cci.contact_id = par_contact_id
                         AND cci.id_type = it.id
                         AND it.brief IN ('PASS_RF', 'BIRTH_CERT', 'PASS_IN'))
    LOOP
      DECLARE
        v_ident_json JSON := JSON();
      BEGIN
        IF v_ident_list IS NULL
        THEN
          v_ident_list := JSON_LIST();
        END IF;
        v_ident_json.put('type', rec_certs.brief);
        v_ident_json.put('ser', rec_certs.serial_nr);
        v_ident_json.put('num', rec_certs.id_value);
        v_ident_json.put('post', rec_certs.place_of_issue);
        v_ident_json.put('date', rec_certs.issue_date);
        v_ident_list.append(v_ident_json.to_json_value);
      END;
    END LOOP;
  
    IF v_ident_list IS NOT NULL
    THEN
      v_contact_info_json.put('certificates', v_ident_list.to_json_value);
    END IF;
  
    FOR rec_phones IN (SELECT ttt.brief
                             ,cct.telephone_number
                         FROM cn_contact_telephone cct
                             ,t_telephone_type     ttt
                        WHERE cct.contact_id = par_contact_id
                          AND cct.telephone_type = ttt.id)
    LOOP
      DECLARE
        v_tel_json JSON := JSON();
      BEGIN
        IF v_telephone_list IS NULL
        THEN
          v_telephone_list := JSON_LIST();
        END IF;
        v_tel_json.put('type', rec_phones.brief);
        v_tel_json.put('num', rec_phones.telephone_number);
      
        v_telephone_list.append(v_tel_json.to_json_value);
      END;
    END LOOP;
  
    IF v_telephone_list IS NOT NULL
    THEN
      v_contact_info_json.put('phones', v_telephone_list.to_json_value);
    END IF;
  
    RETURN v_contact_info_json;
  
  END generate_contact_info_json;

  FUNCTION generate_insuree_info_json
  (
    par_policy_id  NUMBER
   ,par_contact_id NUMBER
  ) RETURN JSON IS
    v_insuree_info JSON;
    v_profession   t_profession.description%TYPE;
    v_work_group   t_work_group.description%TYPE;
    v_hobby        t_hobby.description%TYPE;
  
  BEGIN
    v_insuree_info := generate_contact_info_json(par_contact_id);
  
    BEGIN
      SELECT wg.description
            ,pr.description
            ,h.description
        INTO v_work_group
            ,v_profession
            ,v_hobby
        FROM as_insured   ai
            ,t_work_group wg
            ,t_profession pr
            ,t_hobby      h
       WHERE ai.policy_id = par_policy_id
         AND ai.t_profession_id = pr.id(+)
         AND ai.work_group_id = wg.t_work_group_id(+)
         AND ai.t_hobby_id = h.t_hobby_id(+);
    
      v_insuree_info.put('profession', v_profession);
      v_insuree_info.put('work_group', v_work_group);
      v_insuree_info.put('hobby', v_hobby);
    
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
    END;
  
    RETURN v_insuree_info;
  
  END generate_insuree_info_json;

  FUNCTION generate_benificiary_info_json(par_beneficiary_id as_beneficiary.as_beneficiary_id%TYPE)
    RETURN JSON IS
    v_benificiary_info JSON := JSON();
    v_value            as_beneficiary.value%TYPE;
    v_value_type_brief t_path_type.brief%TYPE;
    v_fund_brief       fund.brief%TYPE;
    v_rel_name         t_contact_rel_type.relationship_dsc%TYPE;
    v_contact_id       contact.contact_id%TYPE;
  BEGIN
    SELECT b.contact_id
          ,b.value
          ,pt.brief
          ,f.brief
          ,crt.relationship_dsc
      INTO v_contact_id
          ,v_value
          ,v_value_type_brief
          ,v_fund_brief
          ,v_rel_name
      FROM as_beneficiary     b
          ,t_path_type        pt
          ,fund               f
          ,cn_contact_rel     ccr
          ,t_contact_rel_type crt
     WHERE b.as_beneficiary_id = par_beneficiary_id
       AND b.value_type_id = pt.t_path_type_id(+)
       AND b.t_currency_id = f.fund_id(+)
       AND b.cn_contact_rel_id = ccr.id(+)
       AND ccr.relationship_type = crt.id(+);
  
    v_benificiary_info := generate_contact_info_json(v_contact_id);
  
    v_benificiary_info.put('related', v_rel_name);
    v_benificiary_info.put('share', v_value);
    v_benificiary_info.put('share_type', v_value_type_brief);
    v_benificiary_info.put('fund', v_fund_brief);
  
    RETURN v_benificiary_info;
  
  END generate_benificiary_info_json;

  FUNCTION generate_assured_info_json(par_asset_id NUMBER) RETURN JSON IS
    v_assured_info       JSON;
    v_work_group         t_work_group.description%TYPE;
    v_hobby              t_hobby.description%TYPE;
    v_category_brief     t_assured_category.brief%TYPE;
    v_assured_contact_id as_assured.assured_contact_id%TYPE;
    v_asset_type_brief   t_asset_type.brief%TYPE;
    v_profession         t_profession.description%TYPE;
    v_asset_header_id    p_asset_header.p_asset_header_id%TYPE;
    v_benificiaries      JSON_LIST;
    v_programs           JSON_LIST;
  BEGIN
    SELECT aas.assured_contact_id
          ,at.brief
          ,ac.brief
          ,pr.description
          ,h.description
          ,wg.description
          ,ah.p_asset_header_id
      INTO v_assured_contact_id
          ,v_asset_type_brief
          ,v_category_brief
          ,v_profession
          ,v_hobby
          ,v_work_group
          ,v_asset_header_id
      FROM as_assured         aas
          ,as_asset           aa
          ,p_asset_header     ah
          ,t_asset_type       at
          ,t_assured_category ac
          ,t_profession       pr
          ,t_hobby            h
          ,t_work_group       wg
     WHERE aas.as_assured_id = par_asset_id
       AND aa.as_asset_id = aas.as_assured_id
       AND aa.p_asset_header_id = ah.p_asset_header_id
       AND ah.t_asset_type_id = at.t_asset_type_id
       AND aas.assured_category_id = ac.t_assured_category_id(+)
       AND aas.t_profession_id = pr.id(+)
       AND aas.t_hobby_id = h.t_hobby_id(+)
       AND aas.work_group_id = wg.t_work_group_id(+);
  
    v_assured_info := generate_contact_info_json(v_assured_contact_id);
    v_assured_info.put('insured_type', v_asset_type_brief);
    v_assured_info.put('category_brief', v_category_brief);
    v_assured_info.put('work_group', v_work_group);
    v_assured_info.put('profession', v_profession);
    v_assured_info.put('hobby', v_hobby);
    v_assured_info.put('asset_id', v_asset_header_id);
  
    FOR rec_benif IN (SELECT b.as_beneficiary_id
                        FROM as_beneficiary b
                      
                       WHERE b.as_asset_id = par_asset_id)
    LOOP
      IF v_benificiaries IS NULL
      THEN
        v_benificiaries := JSON_LIST();
      END IF;
    
      v_benificiaries.append(generate_benificiary_info_json(rec_benif.as_beneficiary_id).to_json_value);
    END LOOP;
  
    IF v_benificiaries IS NOT NULL
    THEN
      v_assured_info.put('assignees', v_benificiaries.to_json_value);
    END IF;
  
    FOR rec_prog IN (SELECT pl.description  program_name
                           ,plt.description program_type
                           ,plo.brief       program_brief
                           ,pc.fee
                           ,pc.premium
                           ,pc.ins_amount
                           ,pc.start_date
                           ,pc.end_date
                       FROM p_cover             pc
                           ,t_prod_line_option  plo
                           ,t_product_line      pl
                           ,t_product_line_type plt
                      WHERE pc.as_asset_id = par_asset_id
                        AND pc.t_prod_line_option_id = plo.id
                        AND plo.product_line_id = pl.id
                        AND pl.product_line_type_id = plt.product_line_type_id)
    LOOP
      DECLARE
        v_program_json JSON := JSON();
      BEGIN
        IF v_programs IS NULL
        THEN
          v_programs := JSON_LIST();
        END IF;
      
        v_program_json.put('program_name', rec_prog.program_name);
        v_program_json.put('program_brief', rec_prog.program_brief);
        v_program_json.put('program_type', rec_prog.program_type);
        v_program_json.put('fee', rec_prog.fee);
        v_program_json.put('premium', rec_prog.premium);
        v_program_json.put('ins_amount', rec_prog.ins_amount);
        v_program_json.put('start_date', rec_prog.start_date);
        v_program_json.put('end_date', rec_prog.end_date);
      
        v_programs.append(v_program_json.to_json_value);
      
      END;
    END LOOP;
  
    IF v_programs IS NOT NULL
    THEN
      v_assured_info.put('programs', v_programs.to_json_value);
    END IF;
  
    RETURN v_assured_info;
  
  END generate_assured_info_json;

  FUNCTION generate_cash_surrender_info(par_policy_id p_policy.policy_id%TYPE) RETURN JSON_LIST IS
    v_cash_surr_table_json JSON_LIST;
    v_cash_surr_row        JSON;
  BEGIN
    FOR vr_surr IN (SELECT cd.insurance_year_number
                          ,cd.insurance_year_number AS payment_number
                          ,cd.start_cash_surr_date
                          ,cd.end_cash_surr_date
                          ,ROUND(SUM(cd.value), 2) AS VALUE
                      FROM policy_cash_surr   cs
                          ,policy_cash_surr_d cd
                          ,t_lob_line         ll
                     WHERE cs.policy_id = par_policy_id
                       AND cs.policy_cash_surr_id = cd.policy_cash_surr_id
                       AND cs.t_lob_line_id = ll.t_lob_line_id
                     GROUP BY cd.insurance_year_number
                             ,cd.start_cash_surr_date
                             ,cd.end_cash_surr_date)
    LOOP
      IF v_cash_surr_table_json IS NULL
      THEN
        v_cash_surr_table_json := JSON_LIST();
      END IF;
      v_cash_surr_row := JSON();
      v_cash_surr_row.put('year', vr_surr.insurance_year_number);
      v_cash_surr_row.put('payment', vr_surr.payment_number);
      v_cash_surr_row.put('start', vr_surr.start_cash_surr_date);
      v_cash_surr_row.put('end', vr_surr.end_cash_surr_date);
      v_cash_surr_row.put('value', vr_surr.value);
      v_cash_surr_table_json.append(v_cash_surr_row.to_json_value);
    END LOOP;
  
    RETURN v_cash_surr_table_json;
  END;
BEGIN

  SELECT ph.ids
        ,pp.pol_num
        ,pp.premium
        ,pp.ins_amount
        ,(SELECT nvl(SUM(aa.fee), 0) FROM as_asset aa WHERE aa.p_policy_id = pp.policy_id) total_fee
        ,ph.start_date
        ,pp.end_date
        ,p.brief product_brief
        ,(SELECT num
            FROM document d
           WHERE d.document_id = pkg_agn_control.get_current_policy_agent(ph.policy_header_id)) agent_num
        ,ROUND(MONTHS_BETWEEN(pp.end_date, ph.start_date), 2) policy_period
        ,pp.is_credit
        ,pp.base_sum
        ,f.brief fund_brief
        ,dis.brief discount_brief
        ,pt.brief payment_term_brief
        ,pi.contact_id insuree_contact_id
        ,ph.policy_header_id
        ,pp.policy_id
        ,doc.get_last_doc_status_brief(ph.policy_id)
        ,doc.get_last_doc_status_brief(ph.last_ver_id)
    INTO v_policy_rec.ids
        ,v_policy_rec.pol_num
        ,v_policy_rec.premium
        ,v_policy_rec.ins_amount
        ,v_policy_rec.total_fee
        ,v_policy_rec.start_date
        ,v_policy_rec.end_date
        ,v_policy_rec.product_brief
        ,v_policy_rec.agent_num
        ,v_policy_rec.policy_period
        ,v_policy_rec.is_credit
        ,v_policy_rec.base_sum
        ,v_policy_rec.fund_brief
        ,v_policy_rec.discount_brief
        ,v_policy_rec.payment_term_brief
        ,v_policy_rec.insuree_contact_id
        ,v_policy_rec.policy_header_id
        ,v_policy_rec.policy_id
        ,v_policy_rec.current_version_status_brief
        ,v_policy_rec.last_version_status_brief
    FROM t_product       p
        ,p_pol_header    ph
        ,p_policy        pp
        ,fund            f
        ,discount_f      dis
        ,t_payment_terms pt
        ,v_pol_issuer    pi
   WHERE ph.policy_header_id = par_policy_header_id
     AND p.product_id = ph.product_id
     AND ph.policy_id = pp.policy_id
     AND ph.fund_id = f.fund_id(+)
     AND pp.discount_f_id = dis.discount_f_id(+)
     AND pp.payment_term_id = pt.id(+)
     AND pp.policy_id = pi.policy_id(+);

  v_policy_info_json.put(pair_name => 'ids', pair_value => v_policy_rec.ids);
  v_policy_info_json.put(pair_name => 'pol_num', pair_value => v_policy_rec.pol_num);
  v_policy_info_json.put(pair_name => 'product_brief', pair_value => v_policy_rec.product_brief);
  v_policy_info_json.put(pair_name => 'ag_contract_num', pair_value => v_policy_rec.agent_num);
  v_policy_info_json.put(pair_name => 'policy_period', pair_value => v_policy_rec.policy_period);
  v_policy_info_json.put(pair_name => 'total_premium', pair_value => v_policy_rec.premium);
  v_policy_info_json.put(pair_name => 'total_fee', pair_value => v_policy_rec.total_fee);
  v_policy_info_json.put(pair_name => 'ins_amount', pair_value => v_policy_rec.ins_amount);
  v_policy_info_json.put(pair_name => 'series', pair_value => substr(v_policy_rec.ids, 1, 3));
  v_policy_info_json.put(pair_name => 'payment_terms', pair_value => v_policy_rec.payment_term_brief);
  v_policy_info_json.put(pair_name => 'start_date', pair_value => v_policy_rec.start_date);
  v_policy_info_json.put(pair_name => 'end_date', pair_value => v_policy_rec.end_date);
  v_policy_info_json.put(pair_name => 'is_credit', pair_value => v_policy_rec.is_credit);
  v_policy_info_json.put(pair_name => 'discount_brief', pair_value => v_policy_rec.discount_brief);
  v_policy_info_json.put(pair_name => 'base_sum', pair_value => v_policy_rec.base_sum);
  v_policy_info_json.put(pair_name => 'fund', pair_value => v_policy_rec.fund_brief);
  v_policy_info_json.put(pair_name  => 'current_version_status_brief'
                        ,pair_value => v_policy_rec.current_version_status_brief);
  v_policy_info_json.put(pair_name  => 'last_version_status_brief'
                        ,pair_value => v_policy_rec.last_version_status_brief);

  v_policy_json.put(pair_name => 'policy', pair_value => v_policy_info_json.to_json_value);

  v_insuree_info_json := generate_insuree_info_json(v_policy_rec.policy_id
                                                   ,v_policy_rec.insuree_contact_id);

  v_policy_json.put('insuree', v_insuree_info_json);

  FOR rec_asset IN (SELECT aa.as_asset_id
                      FROM as_asset aa
                     WHERE aa.p_policy_id = v_policy_rec.policy_id)
  LOOP
    v_asset_array.append(generate_assured_info_json(rec_asset.as_asset_id).to_json_value);
  END LOOP;

  v_policy_json.put('insured', v_asset_array);

  v_cash_surr_table := generate_cash_surrender_info(v_policy_rec.policy_id);

  IF v_cash_surr_table IS NOT NULL
  THEN
    v_policy_json.put('surr_sums', v_cash_surr_table);
  END IF;

  RETURN(v_policy_json);
END fnc_policy_to_json;
/
