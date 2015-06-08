CREATE OR REPLACE FORCE VIEW V_TEST_OAV_DETAIL AS
select agj.AG_CONTRACT_HEADER_ID as AG_CONTRACT_HEADER_ID,
       agj.AGENT_NAME,
       agj.NUM as ag,
       agj.STATUS_NAME as STATUS_NAME_agentskiy,
       agj.DATE_BEGIN,
       agj.DATE_END,
       agj.CATEGORY_NAME,
       stt.name,
       agj.dep_name,
       agj.sales_channel,
       hp.policy_id as policy_id,
       p.pol_ser,
       p.pol_num,
       pl.status_name as status_name_policy,
       rf.name as status_active,
       dss.start_date as date_status_active,
       hp.start_date,
       p.end_date,
       case when extract(month from to_date(sysdate,'dd.mm.yyyy')) > extract(month from to_date(hp.start_date,'dd.mm.yyyy')) then
            extract(year from to_date(sysdate,'dd.mm.yyyy')) - extract(year from to_date(hp.start_date,'dd.mm.yyyy')) + 1
            else extract(year from to_date(sysdate,'dd.mm.yyyy')) - extract(year from to_date(hp.start_date,'dd.mm.yyyy')) end as year_ins,
       p.ins_amount,
       prod.PREMIUM,
       --p.premium,
       pl.prod_desc,
       prod.description as all_progr,
       pl.insurer_name,
       pl.f_resp,
       pl.f_pay,
       pag.part_agent,
       st.name as status_name_agent_po_policy,
       pag.date_start as date_vstupl,
       pag.date_end as date_okonch,
       a.payment_id,
       a.payment_number,
       a.plan_date,
       a.amount,
       ds.name_pl,
       dzp.name_pr,
       dz.num,
       az.due_date as date_pl,
       az.real_pay_date as real_date,
       k.s,
       nn.comission_sum,
       nn.sav,
       k.date_pay as date_oplati_v_vedom,
       av.date_begin as date_begin_vedom,
       av.date_end as date_end_vedom

       /*ass.as_asset_id,
      prod.P_COVER_ID,
      prod.AS_ASSET_ID,
      prod.id,
      prod.is_set,
      prod.for_premium,
      prod.description,
      prod.deduct_name,
      prod.fee,
      prod.for_re,
      prod.plt_desc,
      prod.START_DATE,
      prod.END_DATE,
      prod.INS_AMOUNT,
      prod.PREMIUM,
      prod.imaging,
      prod.brief,
      prod.p_policy_id*/

  from v_ag_contract_journal agj
       left join p_policy_agent ag on (ag.ag_contract_header_id = agj.ag_contract_header_id)
       left join p_pol_header hp on (hp.policy_header_id = ag.policy_header_id)
       left join p_policy p on (p.policy_id = hp.policy_id)
       left join as_asset ass on (ass.p_policy_id = p.policy_id)

      left join (SELECT P_COVER_ID,
                           AS_ASSET_ID,
                           id,
                           decode(imaging || decode(p_cover_id, null, 0, 1),
                           '-1',
                           0,
                           decode(p_cover_id, null, 0, 1)) is_set,
                           pl.for_premium,
                           description,
                           pkg_policy.get_deduct_name(p_cover_id) as deduct_name,
                           fee,
                           pl.for_re,
                           pl.plt_desc,
                           START_DATE,
                           END_DATE,
                           INS_AMOUNT,
                           PREMIUM,
                           imaging,
                           brief,
                           pl.p_policy_id
                   FROM ((select pl.brief,
                                 pl.description,
                                 pl.id,
                                 pl.for_premium,
                                 pl.sort_order,
                                 pv.product_id,
                                 a.as_asset_id asset_id,
                                 pkg_re_bordero.cover_reins(pl.id, a.as_asset_id) for_re,
                                 plt.presentation_desc plt_desc,
                                 a.p_policy_id
                           from t_product_version   pv,
                                t_product_ver_lob   pvl,
                                t_product_line      pl,
                                t_product_line_type plt,
                                t_as_type_prod_line atpl,
                                as_asset            a,
                                p_asset_header      pah
                           where pvl.t_product_ver_lob_id = pl.product_ver_lob_id
                                 and pv.t_product_version_id = pvl.product_version_id
                                 and pl.visible_flag = 1
                                 and pl.id = atpl.product_line_id
                                 and a.p_asset_header_id = pah.p_asset_header_id
                                 and atpl.asset_common_type_id = pah.t_asset_type_id
                                 and plt.product_line_type_id = pl.product_line_type_id
                                 and a.ins_var_id is null) union
                           (select pl.brief,
                                   pl.description,
                                   pl.t_prod_line_dms_id id,
                                   pl.for_premium,
                                   pl.sort_order,
                                   (select product_id from ven_t_product where brief = 'ÄÌÑ'),
                                   a.as_asset_id asset_id,
                                   pkg_re_bordero.cover_reins(pl.t_prod_line_dms_id, a.as_asset_id) for_re,
                                   plt.presentation_desc plt_desc,
                                   a.p_policy_id
                             from ven_t_prod_line_dms pl,
                                  t_product_line_type plt,
                                  as_asset a
                             where pl.p_policy_id = a.P_POLICY_ID
                                   and plt.product_line_type_id = pl.PRODUCT_LINE_TYPE_ID)) pl,
                           (select pc.*, sh.imaging, plo.product_line_id
                            from p_cover pc, t_prod_line_option plo, ven_status_hist sh
                            where pc.t_prod_line_option_id = plo.id
                                  and pc.status_hist_id = sh.status_hist_id) pc
                 WHERE pl.id = pc.product_line_id(+)
                       and pc.as_asset_id(+) = pl.asset_id
                       and (pl.asset_id is not null or pl.id is null)
                       and decode(imaging || decode(p_cover_id, null, 0, 1),
                       '-1',
                       0,
                       decode(p_cover_id, null, 0, 1)) = 1) prod on (prod.p_policy_id = p.policy_id and prod.as_asset_id = ass.as_asset_id)


       left join v_policy_journal pl on (pl.policy_header_id = hp.policy_header_id)
       left join ven_p_policy_agent pag on (pag.p_policy_agent_id = ag.p_policy_agent_id)
       left join policy_agent_status st on (st.policy_agent_status_id = pag.status_id)

       /*inner join doc_doc dd on (dd.parent_id = p.policy_id)
       inner join document d on (dd.child_id = d.document_id)
       inner join doc_templ dt on (dt.doc_templ_id = d.doc_templ_id and dt.brief = 'PAYMENT')
       inner join ac_payment a on (a.payment_id = d.document_id and a.payment_id = dd.child_id)*/

       left join (SELECT
                    p.pol_header_id,
                    p.policy_id,
                    d.document_id,
                    a.payment_number,
                    d.num,
                    a.due_date,
                    a.grace_date,
                    a.amount,
                    dd.parent_amount part_amount,
                    Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL) pay_amount,
                    Pkg_Payment.get_set_off_amount(d.document_id, p.pol_header_id,NULL) part_pay_amount,
                    a.contact_id,
                    c.obj_name_orig contact_name,
                    dsr.doc_status_ref_id,
                    dsr.name doc_status_ref_name,
                    a.plan_date,
                    a.payment_id
                  FROM
                    DOCUMENT d,
                    AC_PAYMENT a,
                    DOC_TEMPL dt,
                    DOC_DOC dd,
                    P_POLICY p,
                    CONTACT c,
                    DOC_STATUS ds,
                    DOC_STATUS_REF dsr
                  WHERE
                    d.document_id = a.payment_id
                    AND
                    d.doc_templ_id = dt.doc_templ_id
                    AND
                    dt.brief = 'PAYMENT'
                    AND
                    dd.child_id = d.document_id
                    AND
                    dd.parent_id = p.policy_id
                    AND
                    a.contact_id = c.contact_id
                    AND
                    ds.document_id = d.document_id
                    AND
                    ds.start_date = (
                      SELECT MAX(dss.start_date)
                      FROM   DOC_STATUS dss
                      WHERE  dss.document_id = d.document_id
                    )
                    AND dsr.doc_status_ref_id = ds.doc_status_ref_id) a on (a.pol_header_id = hp.policy_header_id)

       inner join (select min(ac.plan_date) as mm, ac.payment_id
                   from ac_payment ac
                   group by ac.payment_id ) maxa on (maxa.payment_id = a.document_id)

       left join doc_set_off dso on (dso.parent_doc_id=a.payment_id)--
       left join document dz on (dz.document_id = dso.child_doc_id)
       left join ac_payment az on (dz.document_id = az.payment_id)


       left join contact ct on (a.contact_id = ct.contact_id)
       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pl, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) ds on (a.document_id = ds.document_id )
       left join (select doc.get_last_doc_status_name(ds.document_id) as name_pr, ds.document_id
                  from doc_status ds
                  where ds.doc_status_id = doc.get_last_doc_status_id(ds.document_id)) dzp on (dz.document_id = dzp.document_id )


       left join agent_report rep on (ag.ag_contract_header_id = rep.ag_contract_h_id and t_ag_av_id= 41)
       left join ag_vedom_av av on (av.ag_vedom_av_id = rep.ag_vedom_av_id)
       left join (select sum(comission_sum) as s, c.agent_report_id, c.policy_id, c.date_pay --
                   from agent_report_cont c
                   group by c.agent_report_id,c.policy_id,c.date_pay) k on k.agent_report_id = rep.agent_report_id and p.policy_id = k.policy_id

       left join (select agc.comission_sum,
                         cc.t_product_line_id,
                         agc.agent_report_id,
                         agc.policy_id,
                         agc.sav
                  from agent_report_cont agc
                       left join p_policy_agent_com cc on (cc.p_policy_agent_com_id = agc.p_policy_agent_com_id)
                  ) nn on (nn.agent_report_id = rep.agent_report_id and nn.policy_id = p.policy_id and prod.id = nn.t_product_line_id)

       left join ag_stat_hist agh on (agh.ag_stat_hist_id = pkg_agent_1.get_agent_status_by_date(ag.ag_contract_header_id, maxa.mm))
       left join ag_stat_agent stt on (stt.ag_stat_agent_id = agh.ag_stat_agent_id)

       left join doc_status dss on (dss.document_id = p.policy_id and dss.doc_status_ref_id = 19)
       left join doc_status_ref rf on (dss.doc_status_ref_id = rf.doc_status_ref_id)
where --agj.ag_contract_header_id in (571979)
        --p.policy_id = 1993316
        --and st.name not like 'ÎÒÌÅÍÅÍ'
        av.date_begin >= to_date('01-10-2007','dd-mm-yyyy')
        --and a.payment_number < 10
        and a.plan_date between to_date('01-08-2007','dd-mm-yyyy') and to_date('01-04-2008','dd-mm-yyyy')
        and az.due_date between to_date('01-08-2007','dd-mm-yyyy') and to_date('01-04-2008','dd-mm-yyyy')
;

