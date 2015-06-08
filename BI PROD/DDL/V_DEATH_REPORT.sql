CREATE OR REPLACE VIEW V_DEATH_REPORT AS
SELECT
/*+RULE*/
 0 is_double --Признак необходимости дублировать ДС
,pph.ids
,pp.pol_ser
,pp.pol_num

,c_as.obj_name_orig  assured_fio
,p_as.date_of_death assured_date_of_death
,c_ins.obj_name_orig insured_fio
,p_ins.date_of_death insured_date_of_death
,ppc.policy_id /*ДС, где заполена дата смерти "Страхователя"*/
,ppc.contact_id
,p_ins.date_of_death
,(SELECT dsr.name
    FROM document       dc
        ,doc_status_ref dsr
   WHERE dc.document_id = pph.policy_id
     AND dc.doc_status_ref_id = dsr.doc_status_ref_id) cur_status_name
,(SELECT dsr.name
    FROM document       dc
        ,doc_status_ref dsr
   WHERE dc.document_id = pph.last_ver_id
     AND dc.doc_status_ref_id = dsr.doc_status_ref_id) last_status_name
,ent.obj_name('T_PRODUCT', pph.product_id) product_name
,(SELECT dep.name FROM department dep WHERE dep.department_id = pph.agency_id) agency_name
,pf.t_policy_form_name
  FROM p_policy_contact     ppc
      ,t_contact_pol_role   cr
      ,contact              c_ins
      ,cn_person            p_ins
      ,p_policy             pp
      ,p_pol_header         pph
      ,t_policyform_product prc
      ,t_policy_form        pf
      ,as_asset             ast
      ,as_assured           asd
      ,contact              c_as
      ,cn_person            p_as
 WHERE ppc.contact_id = p_ins.contact_id
   AND p_ins.contact_id = c_ins.contact_id
   AND ppc.contact_policy_role_id = cr.id
   AND cr.brief || '' = 'Страхователь'
   AND p_ins.date_of_death BETWEEN --to_date('01.05.2014','dd.mm.rrrr') and to_date('01.05.2014','dd.mm.rrrr')
       (SELECT to_date(r.param_value, 'dd.mm.rrrr')
          FROM ins_dwh.rep_param r
         WHERE r.rep_name = 'death_report'
           AND r.param_name = 'par_start_date')
   AND (SELECT to_date(r.param_value, 'dd.mm.rrrr')
          FROM ins_dwh.rep_param r
         WHERE r.rep_name = 'death_report'
           AND r.param_name = 'par_end_date')
   AND ppc.policy_id = pp.policy_id
   AND pp.policy_id = pph.policy_id
   AND pp.t_product_conds_id = prc.t_policyform_product_id(+)
   AND prc.t_policy_form_id = pf.t_policy_form_id(+)
   AND pp.is_group_flag = 0 /*Не групповой*/
   AND NOT EXISTS (SELECT NULL
          FROM document       dc
              ,doc_status_ref dsr
         WHERE dc.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief IN ('BREAK' /*Расторгнут*/
                            ,'STOPED' /*Завершен*/
                            ,'STOP' /*Приостановлен*/
                            ,'READY_TO_CANCEL' /*Готовится к расторжению*/
                            ,'CANCEL' /*Отменен*/
                            ,'QUIT' /*Прекращен*/)
           AND dc.document_id = pp.policy_id)

      /*Информация по застрахованному*/
   AND pp.policy_id = ast.p_policy_id
   AND ast.as_asset_id = asd.as_assured_id
   AND asd.assured_contact_id = c_as.contact_id
   AND c_as.contact_id = p_as.contact_id
/*информация по застраованному, умершему в период*/
UNION
SELECT
/*+RULE*/
 decode(c_ins.contact_id, c_as.contact_id, 0, 1) is_double
, --Дублируем вывод ДС, если разные контакты
 pph.ids
,pp.pol_ser
,pp.pol_num

,c_as.obj_name_orig  assured_fio
,p_as.date_of_death  assured_date_of_death
,c_ins.obj_name_orig insured_fio
,p_ins.date_of_death insured_date_of_death

,ppc.policy_id /*ДС, где заполена дата смерти "Страхователя"*/
,ppc.contact_id
,p_ins.date_of_death
,(SELECT dsr.name
    FROM document       dc
        ,doc_status_ref dsr
   WHERE dc.document_id = pph.policy_id
     AND dc.doc_status_ref_id = dsr.doc_status_ref_id) cur_status_name
,(SELECT dsr.name
    FROM document       dc
        ,doc_status_ref dsr
   WHERE dc.document_id = pph.last_ver_id
     AND dc.doc_status_ref_id = dsr.doc_status_ref_id) last_status_name
,ent.obj_name('T_PRODUCT', pph.product_id) product_name
,(SELECT dep.name FROM department dep WHERE dep.department_id = pph.agency_id) agency_name
,pf.t_policy_form_name
  FROM p_policy_contact     ppc
      ,t_contact_pol_role   cr
      ,contact              c_ins
      ,cn_person            p_ins
      ,p_policy             pp
      ,p_pol_header         pph
      ,t_policyform_product prc
      ,t_policy_form        pf
      ,as_asset             ast
      ,as_assured           asd
      ,contact              c_as
      ,cn_person            p_as
 WHERE

 ppc.contact_id = p_ins.contact_id
 AND p_ins.contact_id = c_ins.contact_id
 AND ppc.contact_policy_role_id = cr.id
 AND cr.brief || '' = 'Страхователь'
 AND p_as.date_of_death BETWEEN (SELECT to_date(r.param_value, 'dd.mm.rrrr')
                               FROM ins_dwh.rep_param r
                              WHERE r.rep_name = 'death_report'
                                AND r.param_name = 'par_start_date'
                                )
 AND (SELECT to_date(r.param_value, 'dd.mm.rrrr')
    FROM ins_dwh.rep_param r
   WHERE r.rep_name = 'death_report'
     AND r.param_name = 'par_end_date'
     )
 AND ppc.policy_id = pp.policy_id
 AND pp.policy_id = pph.policy_id
 AND pp.t_product_conds_id = prc.t_policyform_product_id(+)
 AND prc.t_policy_form_id = pf.t_policy_form_id(+)
 AND pp.is_group_flag = 0 /*Не групповой*/
 AND NOT EXISTS (SELECT NULL
    FROM document       dc
        ,doc_status_ref dsr
   WHERE dc.doc_status_ref_id = dsr.doc_status_ref_id
     AND dsr.brief IN ('BREAK' /*Расторгнут*/
                      ,'STOPED' /*Завершен*/
                      ,'STOP' /*Приостановлен*/
                      ,'READY_TO_CANCEL' /*Готовится к расторжению*/
                      ,'CANCEL' /*Отменен*/
                      ,'QUIT' /*Прекращен*/)
     AND dc.document_id = pp.policy_id)

/*Информация по застрахованному*/
 AND pp.policy_id = ast.p_policy_id
 AND ast.as_asset_id = asd.as_assured_id
 AND asd.assured_contact_id = c_as.contact_id
 AND c_as.contact_id = p_as.contact_id
;
