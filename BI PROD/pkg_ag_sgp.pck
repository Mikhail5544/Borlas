CREATE OR REPLACE PACKAGE pkg_ag_sgp IS

  -- Author  : DKOLGANOV
  -- Created : 21.05.2008 15:32:08
  -- Purpose : пакет для подсчета и обработки СГП менеджеров и 
  --           директоров по новой мотивации от 14.04.2008

  /**
  *  расчет суммы собственных продаж и суммы продаж подчиненных 
  *  агентов у менеджеров и директоров по новой мотивации от 14.04.2008
  *  
  * @author Колганов Дмитрий
  * @param p_date_begin дата начала отчетного периода
  * @param p_ag_contract_header_id ИД агентского договора
  */
  /*
    procedure sgp_own_calc(p_date_begin            in date,
                           p_ag_roll_id            in number,
                           p_ag_contract_header_id in number default null);
  */
  /**
  *  добавление продаж и суммы продаж подчиненных 
  *  агентов у менеджеров и директоров по новой мотивации от 14.04.2008
  *  
  * @author Колганов Дмитрий
  * @param p_date_begin дата начала отчетного периода
  * @param p_ag_contract_header_id ИД агентского договора
  */
  /*
    procedure sgp_child_calc(p_date_begin            in date,
                             p_ag_roll_id            in number,
                             p_ag_contract_header_id in number default null);
  */
  /**
  *  расчет всей суммы по новой мотивации от 14.04.2008
  *  
  * @author Колганов Дмитрий
  * @param p_date_begin дата начала отчетного периода
  * @param p_ag_contract_header_id ИД агентского договора
  */
  /*
  procedure sgp_all_calc(p_date_begin            in date,
                         p_ag_roll_id            in number,
                         p_ag_contract_header_id in number default null);*/

  FUNCTION InsertIntoSgp(p_rec IN OUT ven_ag_sgp%ROWTYPE) RETURN NUMBER;

  FUNCTION InsertIntoSgpDet(p_rec IN OUT ven_ag_sgp_det%ROWTYPE) RETURN NUMBER;

  FUNCTION DeleteSgpByAgHeaderAgRoll
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  ) RETURN NUMBER;

  FUNCTION UpdateSummSgp(p_sgp_id NUMBER) RETURN NUMBER;

  FUNCTION get_sgp
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_sgp_type              IN NUMBER
  ) RETURN NUMBER;

  FUNCTION get_status
  (
    p_date                  IN DATE
   ,p_ag_contract_header_id IN NUMBER
  ) RETURN NUMBER;

END pkg_ag_sgp;
/
CREATE OR REPLACE PACKAGE BODY pkg_ag_sgp IS
  /*
  procedure sgp_own_calc(p_date_begin            in date,
                         p_ag_roll_id            in number,
                         p_ag_contract_header_id in number default null) IS
    v_ag_sgp1_id number;
    v_ag_sgp2_id number;
    v_status     number;
  begin
    for cur_sgp in (SELECT ch.ag_contract_header_id,
                           c.ag_contract_id,
                           c.category_id,
                           pkg_agent_sub.Get_Leader_Id_By_Date(last_day(p_date_begin),
                                                               ch.ag_contract_header_id,
                                                               last_day(p_date_begin)) leader_id
                      FROM ven_ag_contract c, ven_ag_contract_header ch
                     WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id,
                                                          last_day(p_date_begin)) =
                           c.ag_contract_id
                       AND ch.ag_contract_header_id =
                           NVL(p_ag_contract_header_id,
                               ch.ag_contract_header_id)
                       AND c.category_id in (3, 4)
                       AND Doc.get_doc_status_brief(ch.ag_contract_header_id,
                                                    last_day(p_date_begin)) IN
                           ('PRINTED', 'CURRENT', 'ACTIVE')
                       AND ch.ag_contract_templ_k = 0) loop
      select nvl(asa1.ag_stat_agent_id, null)
        into v_status
        from ag_stat_hist asa1
       where asa1.ag_stat_hist_id =
             (select nvl(max(ash.ag_stat_hist_id), null)
                from ag_stat_hist ash
               where ash.ag_contract_header_id =
                     cur_sgp.ag_contract_header_id
                 and ash.stat_date < to_date('30042008', 'ddmmyyyy'));
      select sq_ag_sgp.nextval into v_ag_sgp1_id from dual;
    
      insert into ag_sgp
        (ag_sgp_id,
         ag_contract_header_id,
         sgp_sum,
         sgp_type_id,
         date_calc,
         date_of_calc,
         category_id,
         leader_id,
         status_id,
         ag_roll_id)
      values
        (v_ag_sgp1_id,
         cur_sgp.ag_contract_header_id,
         0,
         1,
         p_date_begin,
         sysdate,
         cur_sgp.category_id,
         cur_sgp.leader_id,
         v_status,
         p_ag_roll_id);
      insert into ag_sgp_det
        select sq_ag_sgp_det.nextval,
               ag_contract_header_id,
               v_ag_sgp1_id,
               policy_id,
               agent_rate * koef * koef_GR *
               ((koef_ccy * sum_prem) - sum_izd),
               null,
               null,
               4411,
               null,
               null
          from (select (case
                         when (ar.brief = 'PERCENT') then
                          pa.part_agent / 100
                         when (ar.brief = 'ABSOL') then
                          pa.part_agent
                         else
                          pa.part_agent
                       end) agent_rate,
                       (case
                         when (pt.brief = 'Единовременно' and
                              ceil(months_between(last_day(pp.end_date),
                                                   last_day(pp.start_date))) > 12) then
                          0.1
                         when (((pt.brief = 'Единовременно') and
                              ceil(months_between(last_day(pp.end_date),
                                                    last_day(pp.start_date))) <= 12) or
                              pt.brief <> 'Единовременно') then
                          1
                         else
                          1
                       end) koef,
                       
                       (case
                         when pp.is_group_flag = 1 then
                          0.5
                         else
                          1
                       end) koef_GR,
                       acc_new.Get_Rate_By_ID(1, ph.fund_id, pp.start_date) koef_ccy,
                       pt.number_of_payments *
                       (select sum(pc.fee)
                          from ven_p_cover pc, ven_as_asset aa
                         where aa.p_policy_id = pp.policy_id
                           and aa.as_asset_id = pc.as_asset_id) sum_prem,
                       pkg_agent_1.find_sum_adm_izd(ph.policy_header_id) *
                       pt.number_of_payments sum_izd,
                       ch.ag_contract_header_id,
                       pp.policy_id
                  from (select ph1.policy_header_id,
                               ph1.start_date,
                               ph1.ag_contract_1_id,
                               ph1.ag_contract_2_id,
                               ph1.category_1_id,
                               ph1.category_2_id,
                               ph1.policy_id,
                               ph1.fund_id,
                               ph1.product_id
                          from ven_p_pol_header ph1
                         where (ph1.ag_contract_1_id =
                               cur_sgp.ag_contract_header_id and
                               ph1.category_1_id = cur_sgp.category_id)
                        union all
                        select ph2.policy_header_id,
                               ph2.start_date,
                               ph2.ag_contract_1_id,
                               ph2.ag_contract_2_id,
                               ph2.category_1_id,
                               ph2.category_2_id,
                               ph2.policy_id,
                               ph2.fund_id,
                               ph2.product_id
                          from ven_p_pol_header ph2
                         where (ph2.ag_contract_2_id =
                               cur_sgp.ag_contract_header_id and
                               ph2.category_2_id = cur_sgp.category_id)) ph
                  join ven_p_policy pp on (ph.policy_id = pp.policy_id)
                  join ven_p_policy_agent pa on (pa.policy_header_id =
                                                ph.policy_header_id)
                  join ven_ag_contract_header ch on (pa.ag_contract_header_id =
                                                    ch.ag_contract_header_id and
                                                    ch.t_sales_channel_id = 12)
                  join ven_ag_type_rate_value ar on (pa.ag_type_rate_value_id =
                                                    ar.ag_type_rate_value_id)
                  join ven_t_payment_terms pt on (pt.id = pp.payment_term_id)
                 where pkg_agent_1.get_agent_start_contr(ph.policy_header_id) between
                       p_date_begin and last_day(p_date_begin)
                   and ph.product_id in
                       (2267, 7503, 7670, 7678, 7679, 7680, 7681, 7677, 7687)
                   and exists (select 1
                          from ven_p_policy_contact ppc
                         where 6 = ppc.contact_policy_role_id
                           and ppc.policy_id = pp.policy_id
                           and ch.agent_id <> ppc.contact_id)
                   and exists (select 1
                          from ven_doc_doc d, ven_ac_payment ap
                         where d.parent_id = ph.policy_id
                           and ap.payment_id = d.child_id
                           and doc.get_doc_status_brief(ap.payment_id) =
                               'PAID'));
    
      update ag_sgp a
         set a.sgp_sum = (select nvl(sum(asd.sum), 0)
                            from ag_sgp_det asd
                           where asd.ag_sgp_id = v_ag_sgp1_id)
       where a.ag_sgp_id = v_ag_sgp1_id;
      select sq_ag_sgp.nextval into v_ag_sgp2_id from dual;
      insert into ag_sgp
        (ag_sgp_id,
         ag_contract_header_id,
         sgp_sum,
         sgp_type_id,
         date_calc,
         date_of_calc,
         category_id,
         leader_id,
         status_id,
         ag_roll_id)
      values
        (v_ag_sgp2_id,
         cur_sgp.ag_contract_header_id,
         0,
         2,
         p_date_begin,
         sysdate,
         cur_sgp.category_id,
         cur_sgp.leader_id,
         v_status,
         p_ag_roll_id);
      insert into ag_sgp_det
        select sq_ag_sgp_det.nextval,
               ag_contract_header_id,
               v_ag_sgp2_id,
               policy_id,
               agent_rate * koef * koef_GR *
               ((koef_ccy * sum_prem) - sum_izd),
               null,
               null,
               4411,
               null,
               null
          from (select (case
                         when (ar.brief = 'PERCENT') then
                          pa.part_agent / 100
                         when (ar.brief = 'ABSOL') then
                          pa.part_agent
                         else
                          pa.part_agent
                       end) agent_rate,
                       (case
                         when (pt.brief = 'Единовременно' and
                              ceil(months_between(last_day(pp.end_date),
                                                   last_day(pp.start_date))) > 12) then
                          0.1
                         when (((pt.brief = 'Единовременно') and
                              ceil(months_between(last_day(pp.end_date),
                                                    last_day(pp.start_date))) <= 12) or
                              pt.brief <> 'Единовременно') then
                          1
                         else
                          1
                       end) koef,
                       
                       (case
                         when pp.is_group_flag = 1 then
                          0.5
                         else
                          1
                       end) koef_GR,
                       acc_new.Get_Rate_By_ID(1, ph.fund_id, pp.start_date) koef_ccy,
                       pt.number_of_payments *
                       (select sum(pc.fee)
                          from ven_p_cover pc, ven_as_asset aa
                         where aa.p_policy_id = pp.policy_id
                           and aa.as_asset_id = pc.as_asset_id) sum_prem,
                       pkg_agent_1.find_sum_adm_izd(ph.policy_header_id) *
                       pt.number_of_payments sum_izd,
                       ch.ag_contract_header_id,
                       pp.policy_id
                  from (select ph1.policy_header_id,
                               ph1.start_date,
                               ph1.ag_contract_1_id,
                               ph1.ag_contract_2_id,
                               ph1.category_1_id,
                               ph1.category_2_id,
                               ph1.policy_id,
                               ph1.fund_id,
                               ph1.product_id
                          from ven_p_pol_header ph1
                         where (ph1.ag_contract_1_id =
                               cur_sgp.ag_contract_header_id and
                               ph1.category_1_id = cur_sgp.category_id)
                        union all
                        select ph2.policy_header_id,
                               ph2.start_date,
                               ph2.ag_contract_1_id,
                               ph2.ag_contract_2_id,
                               ph2.category_1_id,
                               ph2.category_2_id,
                               ph2.policy_id,
                               ph2.fund_id,
                               ph2.product_id
                          from ven_p_pol_header ph2
                         where (ph2.ag_contract_2_id =
                               cur_sgp.ag_contract_header_id and
                               ph2.category_2_id = cur_sgp.category_id)) ph
                  join ven_p_policy pp on (ph.policy_id = pp.policy_id)
                  join ven_p_policy_agent pa on (pa.policy_header_id =
                                                ph.policy_header_id)
                  join ven_ag_contract_header ch on (pa.ag_contract_header_id =
                                                    ch.ag_contract_header_id and
                                                    ch.t_sales_channel_id = 12)
                  join ven_ag_type_rate_value ar on (pa.ag_type_rate_value_id =
                                                    ar.ag_type_rate_value_id)
                  join ven_t_payment_terms pt on (pt.id = pp.payment_term_id)
                 where pkg_agent_1.get_agent_start_contr(ph.policy_header_id) between
                       p_date_begin and last_day(p_date_begin)
                   and ph.product_id in
                       (2267, 7503, 7670, 7678, 7679, 7680, 7681, 7677)
                   and exists (select 1
                          from ven_p_policy_contact ppc
                         where 6 = ppc.contact_policy_role_id
                           and ppc.policy_id = pp.policy_id
                           and ch.agent_id <> ppc.contact_id)
                   and exists (select 1
                          from ven_doc_doc d, ven_ac_payment ap
                         where d.parent_id = ph.policy_id
                           and ap.payment_id = d.child_id
                           and doc.get_doc_status_brief(ap.payment_id) =
                               'PAID'));
      update ag_sgp a
         set a.sgp_sum = (select nvl(sum(asd.sum), 0)
                            from ag_sgp_det asd
                           where asd.ag_sgp_id = v_ag_sgp2_id)
       where a.ag_sgp_id = v_ag_sgp2_id;
    end loop;
  end;
  
  procedure sgp_child_calc(p_date_begin            in date,
                           p_ag_roll_id            in number,
                           p_ag_contract_header_id in number default null) is
    max_prior number;
  begin
    select max(priority_in_calc) into max_prior from ag_stat_agent;
    for yyy in 1 .. max_prior loop
      for ttt in (SELECT ch.ag_contract_header_id,
                         ap.ag_contract_header_id ach,
                         c.ag_contract_id,
                         c.category_id,
                         asa.ag_stat_agent_id,
                         asa.priority_in_calc,
                         ap.ag_sgp_id,
                         ap.sgp_type_id,
                         asd.ag_contract_header_ch_id,
                         asd.policy_id,
                         asd.sum,
                         asp.ag_sgp_id sgp_id,
                         asp.sgp_sum head_sum
                    FROM ven_ag_contract        c,
                         ven_ag_contract_header ch,
                         ag_sgp                 ap,
                         ag_stat_agent          asa,
                         ag_sgp_det             asd,
                         ag_sgp                 asp
                   WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id,
                                                        last_day(p_date_begin)) =
                         c.ag_contract_id
                     and asa.ag_stat_agent_id =
                         (select h.ag_stat_agent_id
                            from ag_stat_hist h
                           where h.ag_stat_hist_id =
                                 (select max(ash.ag_stat_hist_id)
                                    from ag_stat_hist ash
                                   where ash.ag_contract_header_id =
                                         ch.ag_contract_header_id
                                     and ash.stat_date <
                                         last_day(p_date_begin)))
                     AND c.category_id in (3, 4)
                     AND ch.ag_contract_header_id =
                         NVL(p_ag_contract_header_id,
                             ch.ag_contract_header_id)
                     AND Doc.get_doc_status_brief(ch.ag_contract_header_id,
                                                  last_day(p_date_begin)) IN
                         ('PRINTED', 'CURRENT', 'ACTIVE')
                     and ap.leader_id = ch.ag_contract_header_id
                     and asd.ag_contract_header_ch_id <>
                         ap.ag_contract_header_id
                     AND ch.ag_contract_templ_k = 0
                     and asa.priority_in_calc = yyy
                     and ap.date_calc = p_date_begin
                     and ap.sgp_type_id = 1
                     and asd.ag_sgp_id = ap.ag_sgp_id
                     and asp.ag_contract_header_id =
                         ch.ag_contract_header_id
                     and asp.sgp_type_id = 1
                     and asp.date_calc = p_date_begin
                     and ap.ag_roll_id = p_ag_roll_id) loop
      
        insert into ag_sgp_det
          (ag_sgp_det_id,
           ag_contract_header_ch_id,
           ag_sgp_id,
           policy_id,
           sum,
           child_id)
        values
          (sq_ag_sgp_det.nextval,
           ttt.ag_contract_header_ch_id,
           ttt.sgp_id,
           ttt.policy_id,
           ttt.sum,
           ttt.ach);
      
        update ag_sgp a
           set a.sgp_sum = (select nvl(sum(asd.sum), 0)
                              from ag_sgp_det asd
                             where asd.ag_sgp_id = ttt.sgp_id)
         where a.ag_sgp_id = ttt.sgp_id;
      end loop;
    
      for tttq in (SELECT ch.ag_contract_header_id,
                          ap.ag_contract_header_id ach,
                          c.ag_contract_id,
                          c.category_id,
                          asa.ag_stat_agent_id,
                          asa.priority_in_calc,
                          ap.ag_sgp_id,
                          ap.sgp_type_id,
                          asd.ag_contract_header_ch_id,
                          asd.policy_id,
                          asd.sum,
                          asp.ag_sgp_id sgp_id,
                          asp.sgp_sum head_sum
                     FROM ven_ag_contract        c,
                          ven_ag_contract_header ch,
                          ag_sgp                 ap,
                          ag_stat_agent          asa,
                          ag_sgp_det             asd,
                          ag_sgp                 asp
                    WHERE Pkg_Agent_1.get_status_by_date(ch.ag_contract_header_id,
                                                         last_day(p_date_begin)) =
                          c.ag_contract_id
                      and asa.ag_stat_agent_id =
                          (select h.ag_stat_agent_id
                             from ag_stat_hist h
                            where h.ag_stat_hist_id =
                                  (select max(ash.ag_stat_hist_id)
                                     from ag_stat_hist ash
                                    where ash.ag_contract_header_id =
                                          ch.ag_contract_header_id
                                      and ash.stat_date <
                                          last_day(p_date_begin)))
                      AND c.category_id in (3, 4)
                      AND Doc.get_doc_status_brief(ch.ag_contract_header_id,
                                                   last_day(p_date_begin)) IN
                          ('PRINTED', 'CURRENT', 'ACTIVE')
                      AND ch.ag_contract_header_id =
                          NVL(p_ag_contract_header_id,
                              ch.ag_contract_header_id)
                      and ap.leader_id = ch.ag_contract_header_id
                      AND ch.ag_contract_templ_k = 0
                      and asa.priority_in_calc = yyy
                      and asd.ag_contract_header_ch_id <>
                          ap.ag_contract_header_id
                      and ap.date_calc = p_date_begin
                      and ap.sgp_type_id = 2
                      and asd.ag_sgp_id = ap.ag_sgp_id
                      and asp.ag_contract_header_id =
                          ch.ag_contract_header_id
                      and asp.sgp_type_id = 2
                      and asp.date_calc = p_date_begin
                      and ap.ag_roll_id = p_ag_roll_id) loop
      
        insert into ag_sgp_det
          (ag_sgp_det_id,
           ag_contract_header_ch_id,
           ag_sgp_id,
           policy_id,
           sum,
           child_id)
        values
          (sq_ag_sgp_det.nextval,
           tttq.ag_contract_header_ch_id,
           tttq.sgp_id,
           tttq.policy_id,
           tttq.sum,
           tttq.ach);
        update ag_sgp a
           set a.sgp_sum = (select nvl(sum(asd.sum), 0)
                              from ag_sgp_det asd
                             where asd.ag_sgp_id = tttq.sgp_id)
         where a.ag_sgp_id = tttq.sgp_id;
      end loop;
    end loop;
  end;
  
  procedure sgp_all_calc(p_date_begin            in date,
                         p_ag_roll_id            in number,
                         p_ag_contract_header_id in number default null) is
  begin
    delete from ag_sgp_det asd
     where asd.ag_sgp_det_id in
           (select d.ag_sgp_det_id
              from ag_sgp_det d, ag_sgp ap
             where d.ag_sgp_id = ap.ag_sgp_id
               and ap.ag_roll_id = p_ag_roll_id
               and ap.ag_contract_header_id =
                   NVL(p_ag_contract_header_id, ap.ag_contract_header_id));
  
    delete from ag_sgp a
     where a.ag_roll_id = p_ag_roll_id
       and a.ag_contract_header_id =
           NVL(p_ag_contract_header_id, a.ag_contract_header_id);
  
    sgp_own_calc(p_date_begin, p_ag_roll_id, p_ag_contract_header_id);
    sgp_child_calc(p_date_begin, p_ag_roll_id, p_ag_contract_header_id);
  end;
  */

  FUNCTION InsertIntoSgp(p_rec IN OUT ven_ag_sgp%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    IF (p_rec.ag_sgp_id IS NULL)
    THEN
      SELECT sq_ag_sgp.nextval INTO p_rec.ag_sgp_id FROM dual;
    END IF;
  
    INSERT INTO ven_ag_sgp
      (ag_sgp_id
      ,ag_contract_header_id
      ,ag_roll_id
      ,category_id
      ,date_calc
      ,date_of_calc
      ,leader_id
      ,sgp_sum
      ,sgp_type_id
      ,status_id)
    VALUES
      (p_rec.ag_sgp_id
      ,p_rec.ag_contract_header_id
      ,p_rec.ag_roll_id
      ,p_rec.category_id
      ,p_rec.date_calc
      ,p_rec.date_of_calc
      ,p_rec.leader_id
      ,p_rec.sgp_sum
      ,p_rec.sgp_type_id
      ,p_rec.status_id);
  
    RETURN Utils.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN UTILS.C_FALSE;
  END InsertIntoSgp;

  FUNCTION InsertIntoSgpDet(p_rec IN OUT ven_ag_sgp_det%ROWTYPE) RETURN NUMBER IS
  BEGIN
  
    IF (p_rec.ag_sgp_det_id IS NULL)
    THEN
      SELECT sq_ag_sgp_det.nextval INTO p_rec.ag_sgp_det_id FROM dual;
    END IF;
  
    INSERT INTO ven_ag_sgp_det
      (ag_sgp_det_id, ag_contract_header_ch_id, ag_sgp_id, child_id, policy_id, sail_type, SUM)
    VALUES
      (p_rec.ag_sgp_det_id
      ,p_rec.ag_contract_header_ch_id
      ,p_rec.ag_sgp_id
      ,p_rec.child_id
      ,p_rec.policy_id
      ,p_rec.sail_type
      ,p_rec.SUM);
  
    RETURN UTILS.C_TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN UTILS.C_FALSE;
  END InsertIntoSgpDet;

  FUNCTION DeleteSgpByAgHeaderAgRoll
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER DEFAULT NULL
  ) RETURN NUMBER IS
  BEGIN
  
    DELETE FROM ven_ag_sgp a
     WHERE a.ag_roll_id = p_ag_roll_id
       AND a.ag_contract_header_id = NVL(p_ag_contract_header_id, a.ag_contract_header_id);
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END DeleteSgpByAgHeaderAgRoll;

  FUNCTION UpdateSummSgp(p_sgp_id NUMBER) RETURN NUMBER IS
  BEGIN
  
    UPDATE ven_ag_sgp a
       SET a.sgp_sum =
           (SELECT nvl(SUM(asd.sum), 0) FROM ag_sgp_det asd WHERE asd.ag_sgp_id = p_sgp_id)
     WHERE a.ag_sgp_id = p_sgp_id;
  
    RETURN Utils.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN Utils.c_false;
  END UpdateSummSgp;

  FUNCTION get_sgp
  (
    p_ag_roll_id            IN NUMBER
   ,p_ag_contract_header_id IN NUMBER
   ,p_sgp_type              IN NUMBER
  ) RETURN NUMBER IS
    RESULT        NUMBER;
    text_ex_error VARCHAR2(255);
    ex_error EXCEPTION;
    CURSOR cur_sgp IS(
      SELECT a.sgp_sum
            ,COUNT(a.ag_contract_header_id) over(PARTITION BY a.ag_contract_header_id) AS row_count
        FROM ag_sgp a
       WHERE a.ag_contract_header_id = p_ag_contract_header_id
         AND a.sgp_type_id = p_sgp_type
         AND a.ag_roll_id = p_ag_roll_id);
    pr_sgp cur_sgp%ROWTYPE;
  BEGIN
    OPEN cur_sgp;
    FETCH cur_sgp
      INTO pr_sgp;
  
    IF (cur_sgp%NOTFOUND)
    THEN
      CLOSE cur_sgp;
      RETURN 0;
    END IF;
  
    IF (pr_sgp.row_count > 1)
    THEN
      CLOSE cur_sgp;
      text_ex_error := 'Было найдено ' || pr_sgp.row_count - 1 || ' задвоенностей по договору ' ||
                       p_ag_contract_header_id;
      RAISE ex_error;
    END IF;
  
    RESULT := pr_sgp.sgp_sum;
    CLOSE cur_sgp;
    RETURN(RESULT);
  
  END;
  --Каткевич А.Г. 17/10/2008 Поправил функцию
  FUNCTION get_status
  (
    p_date                  IN DATE
   ,p_ag_contract_header_id IN NUMBER
  ) RETURN NUMBER IS
    RESULT NUMBER;
    CURSOR cur_stat IS(
      SELECT ag_stat_agent_id
        FROM (SELECT ash.ag_stat_agent_id
                FROM ag_stat_hist ash
               WHERE ash.ag_contract_header_id = p_ag_contract_header_id
                 AND ash.stat_date < p_date
               ORDER BY ash.stat_date DESC
                       ,ash.num       DESC) h
       WHERE ROWNUM = 1);
    pr_stat cur_stat%ROWTYPE;
  BEGIN
    OPEN cur_stat;
    FETCH cur_stat
      INTO pr_stat;
  
    IF (cur_stat%NOTFOUND)
    THEN
      CLOSE cur_stat;
      RETURN 0;
    END IF;
  
    RESULT := pr_stat.ag_stat_agent_id;
    CLOSE cur_stat;
    RETURN(RESULT);
  
  END;

END pkg_ag_sgp;
/
