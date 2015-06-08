create materialized view INS_DWH.FC_C_DAMAGE
refresh force on demand
as
select damage_on_date.*,
       charging_payment.trans_date payment_date,
       nvl(charging_payment.s,0) payment_sum,
       nvl(lag(charging_payment.s)
           over(partition by damage_on_date.c_claim_header_id,
                damage_on_date.t_damage_code_id order by
                charging_payment.trans_date, damage_on_date.c_damage_id),
           0) delta_payment_sum
  from (select
        --       count(*)
        --       /*
         dd.date_id,
         dd.sql_date,
         damages.t_damage_code_id,
         damages.c_claim_header_id,
         damages.t_prod_line_option_id risk_type_id,
         damages.policy_header_id,
         damages.insurer_contact_id,
         damages.assured_contact_id,
         damages.risk_type_gaap_id,
         damages.event_date,
         damages.reg_date,
         --  damages.payment_date, -- todo вычислить
         damages.declare_sum,
         damages.deduct_sum,
         damages.decline_sum,
         damages.to_payment_sum, -- к выплате
         --   damages.payment_sum, -- суммы выплаты
         damages.c_damage_id,
         /*
                         case
                           when dd.sql_date = damages.start_date then
                            1
                           else
                            0
                         end is_new_state,       */
         nvl(damages.declare_sum, 0) -
         nvl(lag(damages.declare_sum)
             over(partition by damages.c_claim_header_id,
                  damages.t_damage_code_id order by damages.start_date,
                  damages.c_damage_id),
             0) delta_declare_sum,
         nvl(damages.deduct_sum, 0) -
         nvl(lag(damages.deduct_sum)
             over(partition by damages.c_claim_header_id,
                  damages.t_damage_code_id order by damages.start_date,
                  damages.c_damage_id),
             0) delta_deduct_sum,
         nvl(damages.decline_sum, 0) -
         nvl(lag(damages.decline_sum)
             over(partition by damages.c_claim_header_id,
                  damages.t_damage_code_id order by damages.start_date,
                  damages.c_damage_id),
             0) delta_decline_sum,
         -- нужно проверить, что здесь хранится - реально выпленная сумма?
         -- может быть, потребуетс вычислять
         nvl(damages.payment_sum, 0) -
         nvl(lag(damages.payment_sum)
             over(partition by damages.c_claim_header_id,
                  damages.t_damage_code_id order by damages.start_date,
                  damages.c_damage_id),
             0) delta_to_payment_sum,
        -- 0 delta_payment_sum,
         damages.fund_brief,
         damages.rate,
         ins.doc.get_doc_status_name(damages.c_claim_id, dd.sql_date) status,
         damages.damage_type,
         damages.damage_cost_type,
         damages.is_policy_cancelation,
         sysdate created_date,
         sysdate modified_date

        --           */
          from dm_date dd,

               (select cd.t_damage_code_id,
                       ch.c_claim_header_id,
                       c.c_claim_id,
                       pc.t_prod_line_option_id,
                       ph.policy_header_id,
                       insurers.contact_id insurer_contact_id,
                       aa.assured_contact_id assured_contact_id,
                       ce.event_date,
                       ce.reg_date,
                       to_date('01011900', 'ddmmyyyy') payment_date,
                       (case
                         when months_between(pp.end_date + 1, ph.start_date) > 12 then
                          case
                         when gt.life_property = 1 then
                          2
                         when gt.life_property = 0 then
                          4
                         else
                          -1
                       end else case
                          when gt.life_property = 1 then
                           1
                          when gt.life_property = 0 then
                           3
                          else
                           -1
                        end end) risk_type_gaap_id,
                       ch.num,
                       trunc(c.claim_status_date, 'dd') start_date,
                       nvl(trunc(lead(c.claim_status_date)
                                 over(partition by ch.c_claim_header_id order by
                                      -- к сожалению даты недостаточно
                                      c.claim_status_date,
                                      cd.c_damage_id),
                                 'dd') - 1,
                           to_date('01013000', 'ddmmyyyy')) end_date,
                       nvl(cd.declare_sum, 0) declare_sum,
                       nvl(cd.deduct_sum, 0) deduct_sum,
                       nvl(cd.decline_sum, 0) decline_sum,
                       nvl(cd.payment_sum, 0) to_payment_sum,
                       0 payment_sum,
                       f.brief fund_brief,
                       -- можно оптимизировать получением запросом
                       ins.acc_new.get_rate_by_id(1, f.fund_id, ce.reg_date) rate, -- на дату регистрации убытка
                       cd.c_damage_id,
                       decode(nvl(cd.c_damage_type_id, 1), 1, 'Д', 'Н') damage_type,
                       decode(nvl(cd.c_damage_cost_type_id, 1), 1, 'Д', 'Н') damage_cost_type,
                       'Н' is_policy_cancelation
                  from ins.c_damage cd,
                       ins.c_claim c,
                       ins.ven_c_claim_header ch,
                       ins.ven_c_event ce,
                       ins.p_cover pc,
                       ins.ven_as_assured aa,
                       ins.p_policy pp,
                       ins.p_pol_header ph,
                       ins.gaap_pl_types gt,
                       ins.t_prod_line_option plo,
                       ins.fund f,
                       (select polc.policy_id, polc.contact_id
                          from ins.p_policy_contact   polc,
                               ins.t_contact_pol_role pr
                         where polc.contact_policy_role_id = pr.id
                           and pr.brief = 'Страхователь') insurers

                 where c.c_claim_header_id = ch.c_claim_header_id
                   and cd.c_claim_id = c.c_claim_id
                   and pc.p_cover_id = cd.p_cover_id
                   and aa.as_assured_id = pc.as_asset_id
                   and aa.p_policy_id = pp.policy_id
                   and pp.pol_header_id = ph.policy_header_id
                   and pc.t_prod_line_option_id = plo.id
                   and gt.id(+) = plo.product_line_id
                   and insurers.policy_id = pp.policy_id
                   and ch.c_event_id = ce.c_event_id
                   and ch.fund_id = f.fund_id
                -- and ch.num = '000000164/1'
                 order by cd.c_damage_id) damages
         where dd.sql_date between damages.start_date and damages.end_date) damage_on_date,
       (select sum(t.trans_amount) s,
               t.trans_date trans_date,
               t.obj_uro_id c_damage_id
          from ins.trans t
         where t.dt_account_id = 69 --- может быть нужно поменять на 77.09.02, если реально платежки будут привязывать
         group by t.trans_date, t.obj_uro_id) charging_payment

 where damage_on_date.sql_date = charging_payment.trans_date(+)
   and damage_on_date.c_damage_id = charging_payment.c_damage_id(+);

