create or replace view ins_dwh.v_cbnt_contact as
select to_char(c.contact_id) insured_id,
       nvl(c.obj_name,'null') insured_name,
       cntel.email,
       nvl(to_char(cnid.vip_card),'null') vip_card,
       nvl(decode(p.gender, 1, 'М', 0, 'Ж', 'Н'),'null') gender
  from ins.contact c,
       ins.cn_person p,
       ins.t_contact_status cs,
       (select cnt1.*
          from (select ce.contact_id,
                       row_number() over(partition by ce.contact_id order by decode(et.id, 363, 0, 1, 1, 2, 2, 100)) rn,
                       ce.email
                  from ins.cn_contact_email ce, ins.t_email_type et
                 where ce.email_type = et.id) cnt1
         where cnt1.rn = 1) cntel,
       (select cnid1.*
          from (select i.contact_id,
                       row_number() over(partition by i.contact_id order by i.id_value) rn,
                       i.id_value vip_card
                  from ins.cn_contact_ident i, ins.t_id_type it
                 where i.id_type = it.id
                   and it.brief = 'VIPCard') cnid1
         where cnid1.rn = 1) cnid
 where c.contact_id          = p.contact_id
   and c.contact_id          = cntel.contact_id
   and c.t_contact_status_id = cs.t_contact_status_id
   and cs.name               = 'VIP'
   and cnid.contact_id       = c.contact_id
-- Если страхователь не VIP, но есть договор Инвестор
union all
select to_char(c.contact_id)
      ,nvl(c.obj_name,'null')
      ,cntel.email
      ,nvl(pp.pol_num,'null')
      ,nvl(decode(p.gender, 1, 'М', 0, 'Ж', 'Н'),'null')
  from ins.contact          c
      ,ins.t_contact_status cs
      ,ins.p_pol_header     ph
      ,ins.p_policy_contact pc
      ,ins.p_policy         pp
      ,ins.t_product        pr
      ,ins.cn_person        p
      ,(select cnt1.*
          from (select ce.contact_id,
                       row_number() over(partition by ce.contact_id order by decode(et.id, 363, 0, 1, 1, 2, 2, 100)) rn,
                       ce.email
                  from ins.cn_contact_email ce, ins.t_email_type et
                 where ce.email_type = et.id) cnt1
         where cnt1.rn = 1) cntel
 where c.t_contact_status_id     = cs.t_contact_status_id
   and cs.name                  != 'VIP'
   and pc.contact_id             = c.contact_id
   and ins.pkg_policy.get_last_version(ph.policy_header_id) = pp.policy_id
   and pp.policy_id              = pc.policy_id
   and pc.contact_policy_role_id = 6
   and ph.product_id             = pr.product_id
   and pr.brief                  = 'Investor'
   and c.contact_id              = cntel.contact_id
   and c.contact_id              = p.contact_id;
CREATE OR REPLACE VIEW INS_DWH.V_CBNT_POLICY AS
select nvl(to_char(policy.policy_id), 'null') policy_id,
       nvl(to_char(policy.insured_id), 'null') insured_id,
       nvl(policy.product_name, 'null') product_name,
       nvl(policy.pol_num, 'null') pol_num,
       nvl(to_char(policy.date_begin,'dd.mm.yyyy'), 'null') date_begin,
       nvl(to_char(policy.date_end,'dd.mm.yyyy'), 'null') date_end,
       nvl(to_char(policy.policy_header_id), 'null') policy_header_id,
       nvl(policy.payment_term, 'null') payment_term,
       nvl(policy.fund, 'null') fund,
       nvl(policy.status, 'null') status,
       nvl(to_char(policy.agent_id),'null') agent_id,
       nvl(to_char(policy.agency_id),'null') agency_id,
       nvl(to_char(policy.fee_index),'null') fee_index,
       nvl(cn.obj_name, 'null') agent_name,
       nvl(d.name, 'null') agency_name,
       nvl(null,'null') agency_address,
       nvl(null,'null') agency_phone,
       nvl(null,'null') indexing_persent,
       nvl(null,'null') invest_income
  from (select --pol.*,
         pol.policy_id,
         pol.insured_id,
         pol.product_name,
         pol.pol_num,
         pol.date_begin,
         pol.date_end,
         pol.policy_header_id,
         pol.payment_term,
         pol.fund,
         case  ins.doc.get_doc_status_name(last_ver.policy_id, sysdate)
          when 'Готовится к расторжению' then 'Расторгнут'
            else
             case ins.doc.get_doc_status_name(pol.policy_id, sysdate)
               when 'Завершен' then
                'Завершен'
               when 'Действующий' then
                'Действующий'
               when 'Индексация' then
                'Действующий'
               when 'Договор подписан' then
                'Действующий'
               when 'Готовится к расторжению' then
                'Расторгнут'
               when 'Расторгнут' then
                'Расторгнут'
               when 'Отменен' then
                'Отменен'
               when 'Приостановлен' then
                'Отменен'
               else
                'Выпуск полиса'
             end
           end
             status,
         (SELECT (SELECT agent_id
                    FROM ins.ag_contract_header ach
                   WHERE ach.ag_contract_header_id = ac.contract_id) agent_id

            FROM ins.ag_contract ac
           WHERE ac.category_id = 2
             AND ROWNUM = 1
           START WITH ac.ag_contract_id =
                      ins.pkg_agent_1.get_status_by_date(ins.pkg_renlife_utils.get_p_agent_current(pol.policy_header_id,
                                                                                                   least(pol.date_end,
                                                                                                         sysdate),
                                                                                                   1),
                                                         least(pol.date_end,
                                                               sysdate))
          CONNECT BY NOCYCLE
           PRIOR (SELECT ac1.contract_id
                              FROM ins.ag_contract ac1
                             WHERE ac1.ag_contract_id = ac.contract_leader_id) =
                      ac.contract_id
                 AND ac.ag_contract_id =
                     ins.pkg_agent_1.get_status_by_date(ac.contract_id,
                                                        least(pol.date_end,
                                                              sysdate))
                 AND ac.category_id <= 2) agent_id,

         (SELECT ac.agency_id
            FROM ins.ag_contract ac
           WHERE ac.category_id = 2
             AND ROWNUM = 1
           START WITH ac.ag_contract_id =
                      ins.pkg_agent_1.get_status_by_date(ins.pkg_renlife_utils.get_p_agent_current(pol.policy_header_id,
                                                                                                   least(pol.date_end,
                                                                                                         sysdate),
                                                                                                   1),
                                                         least(pol.date_end,
                                                               sysdate))
          CONNECT BY NOCYCLE
           PRIOR (SELECT ac1.contract_id
                              FROM ins.ag_contract ac1
                             WHERE ac1.ag_contract_id = ac.contract_leader_id) =
                      ac.contract_id
                 AND ac.ag_contract_id =
                     ins.pkg_agent_1.get_status_by_date(ac.contract_id,
                                                        least(pol.date_end,
                                                              sysdate))
                 AND ac.category_id <= 2) agency_id,

         case ins.doc.get_doc_status_name(last_ver.policy_id, sysdate)
           when 'Индексация' then
            (select round(sum(pc.fee), 2)
               from ins.p_cover pc, ins.as_asset a, ins.p_policy pp
              where pp.policy_id = a.p_policy_id
                and a.as_asset_id = pc.as_asset_id
                and pp.policy_id = last_ver.policy_id)
         end fee_index
          from (select pp.policy_id,
                       pol_insurer.contact_id insured_id,
                       p.description product_name,
                       pp.pol_num,
                       ph.start_date date_begin,
                       pp.end_date date_end,
                       ph.policy_header_id,
                       pt.description payment_term,
                       f.brief fund

                  from ins.ven_p_policy pp,
                       (select distinct pc.contact_id, pc.policy_id
                          from ins.p_policy_contact   pc,
                               ins_dwh.v_cbnt_contact c
                         where pc.contact_policy_role_id = 6
                           and c.insured_id = pc.contact_id) pol_insurer,
                       ins.t_product p,
                       ins.p_pol_header ph,
                       ins.fund f,
                       ins.t_payment_terms pt

                 where 1 = 1
                   and pp.policy_id = pol_insurer.policy_id
                   and ph.policy_id = pp.policy_id
                   and p.product_id = ph.product_id
                   and f.fund_id = ph.fund_id
                   and pt.id = pp.payment_term_id) pol,
               (select *
                  from (select pp.pol_header_id,
                               pp.policy_id,
                               pp.start_date,
                               pp.version_num,
                               row_number() over(partition by pp.pol_header_id order by pp.version_num desc, pp.start_date desc) rn
                          from ins.p_policy pp) last_ver1
                 where last_ver1.rn = 1) last_ver
         where pol.policy_header_id = last_ver.pol_header_id) policy,
       ins.contact cn,
       ins.department d
 where policy.agent_id = cn.contact_id(+)
   and policy.agency_id = d.department_id(+)
   and policy.status <>'Отменен';
create or replace view ins_dwh.v_cbnt_cover as
select nvl(to_char(pc.p_cover_id),'null') p_cover_id,
       nvl(to_char(pp.POLICY_ID),'null') policy_id,
       nvl(to_char(pc.start_date,'dd.mm.yyyy'),'null') date_begin,
       nvl(to_char(pc.end_date,'dd.mm.yyyy'),'null') date_end,
       to_char(nvl(pc.ins_amount,0)) insurance_sum,
       to_char(nvl(pc.fee,0)) fee,
       pl.description cover_type_name
      ,'null'         as annual
  from ins.p_cover pc, ins.as_asset a, ins_dwh.v_cbnt_policy pp, ins.t_prod_line_option plo, ins.t_product_line pl
      ,ins.p_pol_header ph, ins.t_product tp
 where pc.as_asset_id = a.as_asset_id
   and a.p_policy_id = pp.POLICY_ID
   and plo.product_line_id = pl.id
   and pc.t_prod_line_option_id = plo.id
   -- Байтин А. Выбираем все, кроме "Инвестора"
   and pp.policy_header_id = ph.policy_header_id
   and ph.product_id       = tp.product_id
   and tp.brief            != 'Investor'
-- Для продукта "Инвестор", исключаем административные издержки, а также генерим по три дополнительные строчки для каждого риска
union all
select nvl(to_char(pc.p_cover_id),'null') p_cover_id,
       nvl(to_char(pp.POLICY_ID),'null') policy_id,
       nvl(to_char(pc.start_date,'dd.mm.yyyy'),'null') date_begin,
       nvl(to_char(pc.end_date,'dd.mm.yyyy'),'null') date_end,
       to_char(nvl(pc.ins_amount,0)) insurance_sum,
       to_char(nvl(pc.fee,0)) fee,
       pl.description cover_type_name
      ,to_char(an.annual)         as annual
  from ins.p_cover pc, ins.as_asset a, ins_dwh.v_cbnt_policy pp, ins.t_prod_line_option plo, ins.t_product_line pl
      ,ins.p_pol_header ph, ins.t_product tp
      ,(select level as annual
          from dual
         connect by level <= 3
       ) an
 where pc.as_asset_id = a.as_asset_id
   and a.p_policy_id = pp.POLICY_ID
   and plo.product_line_id = pl.id
   and pc.t_prod_line_option_id = plo.id
   and pp.policy_header_id = ph.policy_header_id
   and ph.product_id       = tp.product_id
   and tp.brief            = 'Investor'
   and pl.description     != 'Административные издержки';