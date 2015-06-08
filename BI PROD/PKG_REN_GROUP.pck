CREATE OR REPLACE PACKAGE PKG_REN_GROUP IS

  FUNCTION tmp_group_report(p_p_policy NUMBER) RETURN NUMBER;

END PKG_REN_GROUP;
/
CREATE OR REPLACE PACKAGE BODY PKG_REN_GROUP IS

  FUNCTION tmp_group_report(p_p_policy NUMBER) RETURN NUMBER IS
  
    rnm             NUMBER;
    id              NUMBER;
    pol_id          NUMBER;
    p_ins_name      VARCHAR2(250);
    p_date_of_birth DATE;
    p_gender        VARCHAR2(5);
    p_fee           NUMBER;
    p_ins_amount    NUMBER;
    p_start_date    DATE;
    p_end_date      DATE;
    p_sum_fee       NUMBER;
    p_plo_id        NUMBER;
    p_sch           VARCHAR2(25);
    res             NUMBER;
    p_pol_start     DATE;
    p_pol_end       DATE;
    p_paym          VARCHAR2(65);
    p_kol_risk      NUMBER := 0;
  
    CURSOR c1 IS(
      SELECT rownum
            ,risk_id
            ,policy_id
            ,pol_start_date
            ,pol_end_date
            ,paym
        FROM (SELECT COUNT(*)
                    ,plo.description risk_name
                    ,plo.id risk_id
                    ,pp.policy_id
                    ,ph.start_date pol_start_date
                    ,trunc(pp.end_date) pol_end_date
                    ,trm.description paym
                FROM ven_p_policy            pp
                    ,p_pol_header            ph
                    ,ven_as_asset            ass
                    ,ven_p_cover             pc
                    ,ven_t_prod_line_option  plo
                    ,ven_t_product_line      pl
                    ,ven_t_product_line_type plt
                    ,t_payment_terms         trm
               WHERE pp.policy_id = p_p_policy
                 AND ass.p_policy_id = pp.policy_id
                 AND pc.as_asset_id = ass.as_asset_id
                 AND plo.id = pc.t_prod_line_option_id
                 AND plo.product_line_id = pl.id
                 AND ph.policy_header_id = pp.pol_header_id
                 AND pl.product_line_type_id = plt.product_line_type_id
                 AND trm.id = pp.payment_term_id
               GROUP BY plo.description
                       ,plo.id
                       ,pp.policy_id
                       ,ph.start_date
                       ,pp.end_date
                       ,trm.description
               ORDER BY plo.id));
  
    CURSOR c_r1 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,
             /*pc.fee,*/pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk1
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r2 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk2
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r3 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk3
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r4 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk4
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r5 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk5
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r6 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk6
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r7 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk7
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r8 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk8
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r9 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk9
         AND pl.product_line_type_id = plt.product_line_type_id);
  
    CURSOR c_r10 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk10
         AND pl.product_line_type_id = plt.product_line_type_id);
    CURSOR c_r11 IS(
      SELECT ent.obj_name(c.ent_id, red.assured_contact_id)
            ,per.date_of_birth
            ,decode(nvl(per.gender, 0), 0, 'Жен', 'Муж') gender
            ,CASE
               WHEN pc.decline_date IS NULL THEN
                pc.fee
               ELSE
                pc.return_summ
             END fee
            ,pc.ins_amount
            ,pc.start_date
            ,nvl(pc.decline_date, pc.end_date) end_date
            ,sh.brief
            ,(SELECT SUM(nvl(pc2.fee, 0))
                FROM t_product_line     pl2
                    ,t_prod_line_option plo2
                    ,p_cover            pc2
                    ,ven_status_hist    sh2
                    ,as_asset           aa2
               WHERE 1 = 1
                 AND aa2.p_policy_id = pp.policy_id
                 AND pc2.as_asset_id = aa2.as_asset_id
                 AND pc2.as_asset_id = red.as_assured_id
                 AND sh2.status_hist_id = pc2.status_hist_id
                    --AND sh2.brief != 'DELETED'
                 AND sh2.brief = 'NEW'
                 AND plo2.ID = pc2.t_prod_line_option_id
                 AND pl2.ID = plo2.product_line_id) sum_fee
            ,plo.id
        FROM ven_p_policy            pp
            ,ven_as_asset            ass
            ,as_assured              red
            ,contact                 c
            ,ven_p_cover             pc
            ,ven_t_prod_line_option  plo
            ,ven_t_product_line      pl
            ,ven_t_product_line_type plt
            ,cn_person               per
            ,status_hist             sh
            ,tmp$_risk_name          tmp
       WHERE pp.policy_id = p_p_policy
         AND ass.p_policy_id = pp.policy_id
         AND ass.as_asset_id = red.as_assured_id
         AND red.assured_contact_id = c.contact_id
         AND per.contact_id = c.contact_id
         AND pc.as_asset_id = ass.as_asset_id
         AND plo.id = pc.t_prod_line_option_id
         AND plo.product_line_id = pl.id
         AND pc.status_hist_id = sh.status_hist_id
         AND sh.brief != 'CURRENT'
         AND plo.id = tmp.risk11
         AND pl.product_line_type_id = plt.product_line_type_id);
  
  BEGIN
  
    DELETE FROM TMP$_RISK_NAME;
  
    OPEN c1;
    LOOP
      FETCH c1
        INTO rnm
            ,id
            ,pol_id
            ,p_pol_start
            ,p_pol_end
            ,p_paym;
      EXIT WHEN c1%NOTFOUND;
      IF rnm = 1
      THEN
      
        INSERT INTO TMP$_RISK_NAME
          (risk1, p_policy_id, pol_start_date, pol_end_date, t_payment)
        VALUES
          (id, pol_id, p_pol_start, p_pol_end, p_paym);
      
      ELSIF rnm = 2
      THEN
        UPDATE TMP$_RISK_NAME SET risk2 = id;
      ELSIF rnm = 3
      THEN
        UPDATE TMP$_RISK_NAME SET risk3 = id;
      ELSIF rnm = 4
      THEN
        UPDATE TMP$_RISK_NAME SET risk4 = id;
      ELSIF rnm = 5
      THEN
        UPDATE TMP$_RISK_NAME SET risk5 = id;
      ELSIF rnm = 6
      THEN
        UPDATE TMP$_RISK_NAME SET risk6 = id;
      ELSIF rnm = 7
      THEN
        UPDATE TMP$_RISK_NAME SET risk7 = id;
      ELSIF rnm = 8
      THEN
        UPDATE TMP$_RISK_NAME SET risk8 = id;
      ELSIF rnm = 9
      THEN
        UPDATE TMP$_RISK_NAME SET risk9 = id;
      ELSIF rnm = 10
      THEN
        UPDATE TMP$_RISK_NAME SET risk10 = id;
      ELSIF rnm = 11
      THEN
        UPDATE TMP$_RISK_NAME SET risk11 = id;
      ELSIF rnm = 12
      THEN
        UPDATE TMP$_RISK_NAME SET risk12 = id;
      ELSIF rnm = 13
      THEN
        UPDATE TMP$_RISK_NAME SET risk13 = id;
      ELSIF rnm = 14
      THEN
        UPDATE TMP$_RISK_NAME SET risk14 = id;
      ELSIF rnm = 15
      THEN
        UPDATE TMP$_RISK_NAME SET risk15 = id;
      END IF;
    END LOOP;
    CLOSE c1;
  
    OPEN c_r1;
    LOOP
      FETCH c_r1
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r1%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
    
      UPDATE tmp$_risk_name
         SET risk1  = p_fee
            ,srisk1 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
      UPDATE tmp$_risk_name
         SET drisk1 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
                FROM (SELECT (nvl(t.risk1, 0)) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r1;
    OPEN c_r2;
    LOOP
      FETCH c_r2
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r2%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk2  = p_fee
            ,srisk2 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
      UPDATE tmp$_risk_name
         SET drisk2 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk2, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r2;
    OPEN c_r3;
    LOOP
      FETCH c_r3
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r3%NOTFOUND;
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
    
      UPDATE tmp$_risk_name
         SET risk3  = p_fee
            ,srisk3 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk3 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk3, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r3;
    OPEN c_r4;
    LOOP
      FETCH c_r4
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r4%NOTFOUND;
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk4  = p_fee
            ,srisk4 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk4 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk4, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r4;
    OPEN c_r5;
    LOOP
      FETCH c_r5
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r5%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk5  = p_fee
            ,srisk5 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk5 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk5, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r5;
    OPEN c_r6;
    LOOP
      FETCH c_r6
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r6%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk6  = p_fee
            ,srisk6 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk6 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk6, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r6;
    OPEN c_r7;
    LOOP
      FETCH c_r7
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r7%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk7  = p_fee
            ,srisk7 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk7 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk7, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r7;
    OPEN c_r8;
    LOOP
      FETCH c_r8
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r8%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk8  = p_fee
            ,srisk8 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk8 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk8, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r8;
    OPEN c_r9;
    LOOP
      FETCH c_r9
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r9%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk9  = p_fee
            ,srisk9 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk9 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk9, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r9;
    OPEN c_r10;
    LOOP
      FETCH c_r10
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r10%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk10  = p_fee
            ,srisk10 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk10 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk10, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r10;
  
    OPEN c_r11;
    LOOP
      FETCH c_r11
        INTO p_ins_name
            ,p_date_of_birth
            ,p_gender
            ,p_fee
            ,p_ins_amount
            ,p_start_date
            ,p_end_date
            ,p_sch
            ,p_sum_fee
            ,p_plo_id;
      EXIT WHEN c_r11%NOTFOUND;
    
      SELECT COUNT(*)
        INTO res
        FROM tmp$_risk_name
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      IF nvl(res, 0) <= 0
      THEN
        INSERT INTO tmp$_risk_name
          (ins_name, date_of_birth, sex, start_date, end_date, sch, sum_fee)
        VALUES
          (p_ins_name, p_date_of_birth, p_gender, p_start_date, p_end_date, p_sch, p_sum_fee);
      END IF;
      UPDATE tmp$_risk_name
         SET risk11  = p_fee
            ,srisk11 = p_ins_amount
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
      UPDATE tmp$_risk_name
         SET drisk11 =
             (SELECT CASE sch
                       WHEN 1 THEN
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db + 1), 2)))
                                  ,0))
                       ELSE
                        decode((paym)
                              ,0
                              ,0
                              ,nvl(decode((Dsf - Dc + 1)
                                         ,0
                                         ,0
                                         ,(ROUND(Py / (Dsf - Dc + 1) * (Dsf - Db), 2)))
                                  ,0))
                     END
              /*case sch when 1 then decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2)),0))
              else decode((paym),0,0,nvl((round(Py / (Dsf - Dc + 1) * (Dsf - Db),2)),0))
              end*/
                FROM (SELECT nvl(t.risk11, 0) Py
                            ,t.start_date Dc
                            ,t.end_date Dsf
                            ,(SELECT t.pol_start_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Db
                            ,(SELECT t.pol_end_date FROM tmp$_risk_name t WHERE t.ins_name IS NULL) Df
                            ,(SELECT CASE t.t_payment
                                       WHEN 'Единовременно' THEN
                                        0
                                       ELSE
                                        1
                                     END
                                FROM tmp$_risk_name t
                               WHERE t.ins_name IS NULL) paym
                            ,decode(t.sch, 'NEW', 1, 0) sch
                        FROM tmp$_risk_name t
                       WHERE t.ins_name = p_ins_name
                         AND t.date_of_birth = p_date_of_birth
                         AND t.sch IN ('NEW', 'DELETED')
                         AND t.start_date = p_start_date))
       WHERE ins_name = p_ins_name
         AND date_of_birth = p_date_of_birth
         AND start_date = p_start_date;
    
    END LOOP;
    CLOSE c_r11;
  
    FOR c_rec IN (SELECT t.ins_name
                        ,t.date_of_birth
                        ,nvl(t.drisk1, 0) drisk1
                        ,nvl(t.drisk2, 0) drisk2
                        ,nvl(t.drisk3, 0) drisk3
                        ,nvl(t.drisk4, 0) drisk4
                        ,nvl(t.drisk5, 0) drisk5
                        ,nvl(t.drisk6, 0) drisk6
                        ,nvl(t.drisk7, 0) drisk7
                        ,nvl(t.drisk8, 0) drisk8
                        ,nvl(t.drisk9, 0) drisk9
                        ,nvl(t.drisk10, 0) drisk10
                        ,nvl(t.drisk11, 0) drisk11
                        ,t.start_date
                    FROM tmp$_risk_name t
                   WHERE t.ins_name IS NOT NULL)
    LOOP
      UPDATE tmp$_risk_name
         SET sum_dfee =
             (nvl(c_rec.drisk1, 0) + nvl(c_rec.drisk2, 0) + nvl(c_rec.drisk3, 0) +
             nvl(c_rec.drisk4, 0) + nvl(c_rec.drisk5, 0) + nvl(c_rec.drisk6, 0) +
             nvl(c_rec.drisk7, 0) + nvl(c_rec.drisk8, 0) + nvl(c_rec.drisk9, 0) +
             nvl(c_rec.drisk10, 0) + nvl(c_rec.drisk11, 0))
       WHERE ins_name = c_rec.ins_name
         AND date_of_birth = c_rec.date_of_birth
         AND start_date = c_rec.start_date;
    END LOOP;
  
    FOR c_r IN (SELECT SUM(nvl(t.risk1, 0)) r1
                      ,SUM(nvl(t.risk2, 0)) r2
                      ,SUM(nvl(t.risk3, 0)) r3
                      ,SUM(nvl(t.risk4, 0)) r4
                      ,SUM(nvl(t.risk5, 0)) r5
                      ,SUM(nvl(t.risk6, 0)) r6
                      ,SUM(nvl(t.risk7, 0)) r7
                      ,SUM(nvl(t.risk8, 0)) r8
                      ,SUM(nvl(t.risk9, 0)) r9
                      ,SUM(nvl(t.risk10, 0)) r10
                      ,SUM(nvl(t.risk11, 0)) r11
                  FROM tmp$_risk_name t
                 WHERE t.ins_name IS NOT NULL
                   AND t.sch <> 'CURRENT')
    LOOP
      IF c_r.r1 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r2 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r3 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r4 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r5 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r6 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r7 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r8 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r9 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r10 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
      IF c_r.r11 > 0
      THEN
        p_kol_risk := p_kol_risk + 1;
      END IF;
    
      UPDATE tmp$_risk_name SET kol_risk = p_kol_risk WHERE ins_name IS NULL;
    END LOOP;
  
    RETURN 1;
  
  END;

END PKG_REN_GROUP;
/
