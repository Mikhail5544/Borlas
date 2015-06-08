CREATE OR REPLACE FORCE VIEW V_LETTERS_PAYMENT_IV AS
(
SELECT a."DAYS_REMAINING",a."PAYMENT_PERIOD",a."MB",a."POL_START_DATE",a."POL_END_DATE",a."POL_HEADER_ID",a."POLICY_ID",a."POLICY_NUMBER",a."POL_SER",a."POL_NUM",a."DOCUMENT_ID",a."NUM",a."DUE_DATE",a."GRACE_DATE",a."GRACE_PERIOD",a."AMOUNT",a."FUND",a."SUM_FEE",nvl(a.pay_amount,0) "PAY_AMOUNT",a."ACC_RATE",a."CONTACT_ID",a."CONTACT_NAME",a."INIT_NAME",a."CODE", a."ADDRESS_NAME" ,a."ID",a."DOC_STATUS_REF_ID",a."DOC_STATUS_REF_NAME",a."PRODUCT_ID",NVL2(a.pay_amount, a.amount*a.acc_rate, a.amount) rev_amount, nvl2(a.pay_amount,a.fund,'') rev_fund, a.type_contact, a.gender, a.pay_amount_dog FROM (
SELECT trunc(SYSDATE) - trunc(a.grace_date) days_remaining,
       CASE pt.DESCRIPTION
             WHEN 'Единовременно' THEN 'единовременный'
             WHEN 'Ежеквартально' THEN 'ежеквартальный'
             WHEN 'Ежемесячно' THEN 'ежемесячный'
             WHEN 'Раз в полгода' THEN 'полугодовой'
             WHEN 'Ежегодно' THEN 'годовой'
             ELSE pt.DESCRIPTION
       END AS payment_period,
       /*CASE
         WHEN trunc(months_between(trunc(p.END_DATE), trunc(p.START_DATE))) > 12 THEN
              trunc(months_between(trunc(a.due_date), trunc(p.start_date)))
         ELSE
          1
       END mb,*/
       case when mod(MONTHS_BETWEEN(a.DUE_DATE, ph.start_date),12) = 0 then 0 else 1 end mb,
       p.START_DATE POL_START_DATE,
       p.END_DATE POL_END_DATE,
       p.pol_header_id,
       p.policy_id,
       p.pol_ser||nvl2(p.pol_ser, ' ','')|| p.pol_num AS POLICY_NUMBER,
       nvl(p.pol_ser, '-') pol_ser,
       nvl(p.pol_num, '-') pol_num,
       a.payment_id document_id,
       a.num,
       a.due_date,
       a.grace_date,
       decode(ph.product_id, 2267, to_char(a.due_date + 45, 'dd.mm.yyyy'), 7680, to_char(a.due_date + 45, 'dd.mm.yyyy'), 7678, to_char(a.due_date + 45, 'dd.mm.yyyy'), 7679, to_char(a.due_date + 45, 'dd.mm.yyyy'), 20525, to_char(a.due_date + 30, 'dd.mm.yyyy'), 20544, to_char(a.due_date + 30, 'dd.mm.yyyy'), 28290, to_char(a.due_date + 30, 'dd.mm.yyyy'), to_char(a.grace_date, 'dd.mm.yyyy')) AS grace_period,
       a.amount,
       Pkg_Payment.get_set_off_amount(a.payment_id, NULL, NULL) pay_amount_dog,
       f.brief fund,
       (SELECT SUM(pc.fee)
          FROM as_asset aa,
               p_cover pc,
               t_prod_line_option tplo
         WHERE aa.p_policy_id = p.policy_id
           AND pc.as_asset_id = aa.as_asset_id
           AND pc.decline_reason_id IS NULL
           AND pc.t_prod_line_option_id = tplo.id
           AND tplo.description <> 'Административные издержки') sum_fee,
       (SELECT sum(t.trans_amount)
          FROM oper o,
               trans t,
               trans_templ tt
         WHERE o.document_id = dso.doc_set_off_id
           AND o.oper_id = t.oper_id
           AND t.trans_templ_id = tt.trans_templ_id
           AND tt.brief IN ('СтраховаяПремияОплачена', 'ЗачтВыплВозвр')) pay_amount,
       (SELECT max(t.acc_rate)
          FROM oper o,
               trans t,
               trans_templ tt
         WHERE o.document_id = dso.doc_set_off_id
           AND o.oper_id = t.oper_id
           AND t.trans_templ_id = tt.trans_templ_id
           AND tt.brief IN ('СтраховаяПремияОплачена', 'ЗачтВыплВозвр')) acc_rate,
       a.contact_id,
       case tc.id when 101 then 0 else 1 end type_contact,
       per.gender,
       /*case when tc.id = 101 then c.obj_name_orig else
            (case nvl(per.gender,0) when 0 then 'Уважаемая' else 'Уважаемый' end)||' '|| c.obj_name_orig end contact_name,*/
       c.obj_name_orig contact_name,
       nvl(c.NAME, '')||' '||nvl(substr(c.first_name, 1, 1)||'.','')||nvl(substr(c.middle_name, 1, 1)||'.','') init_name,
       nvl(dep.NAME, '00') code,
       NVL(ca.name, pkg_contact.get_address_name(ca.id)) address_name,
       ca.ID,
       dsr.doc_status_ref_id,
       dsr.NAME doc_status_ref_name,
       ph.product_id
  FROM p_pol_header ph,
       t_product prod,
       p_policy_agent     pag,
       ag_contract_header hed,
       department         dep,
       p_policy   p,
       T_PAYMENT_TERMS pt,
       doc_doc    dd,
       ven_ac_payment a,
       fund f,
       ac_payment_templ apt,
       doc_status_ref dsr,
       p_policy_contact ppc,
       T_CONTACT_POL_ROLE cpr,
       contact c,
       t_contact_type tc,
       cn_person per,
       cn_address ca,
       doc_set_off dso
 WHERE a.payment_templ_id = apt.payment_templ_id
   AND apt.brief = 'PAYMENT'
   AND doc.get_doc_status_id(a.payment_id) = dsr.doc_status_ref_id
   AND dsr.brief <> 'PAID'
   and dsr.name <> 'Аннулирован'
   AND a.payment_id = dd.child_id
   AND a.payment_id = dso.parent_doc_id (+)
   AND dd.parent_id = p.policy_id
   AND ph.product_id = prod.product_id
   AND p.pol_header_id = ph.policy_header_id
   --AND ph.product_id IN (2267, 7680, 7678, 7679, 28487, 20525, 20544, 28290)
   AND pt.ID = p.PAYMENT_TERM_ID
   AND pt.DESCRIPTION not in ('Единовременно')
   AND pag.policy_header_id = p.pol_header_id
   AND pag.status_id = 1
   AND hed.ag_contract_header_id = pag.ag_contract_header_id
   AND dep.department_id = hed.agency_id
   --AND a.contact_id = c.contact_id
   AND pkg_contact.get_primary_address(c.contact_id) = ca.ID
   AND f.fund_id = a.fund_id
   --and ph.policy_header_id = 6915255
   AND EXISTS (SELECT pr.policy_id
               FROM p_policy pr
               WHERE doc.get_doc_status_brief(pr.policy_id) IN ('CURRENT', 'PRINTED', 'ACTIVE')
                     AND pr.pol_header_id = p.pol_header_id)
   /*AND NOT EXISTS (SELECT pr.policy_id
                   FROM p_policy pr
                   WHERE doc.get_doc_status_brief(pr.policy_id) IN ('INDEXATING')
                         AND pr.pol_header_id = p.pol_header_id)*/
   AND doc.get_doc_status_brief(pkg_policy.get_last_version(p.pol_header_id)) NOT IN ('READY_TO_CANCEL', 'BREAK')
   and tc.id = c.contact_type_id
   and c.contact_id = per.contact_id
   and cpr.brief = 'Страхователь'
   and ppc.policy_id = p.policy_id
   AND ppc.contact_policy_role_id = cpr.id
   and c.contact_id = ppc.contact_id
   /*AND mod(MONTHS_BETWEEN(a.DUE_DATE, p.START_DATE),12)<>0*/) a
)

--select * from t_product t where t.product_id in (2267, 7680, 7678, 7679, 28487, 20525, 20544, 28290)
;

