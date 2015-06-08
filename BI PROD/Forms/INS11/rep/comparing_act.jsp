<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="comparing_act" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="reestr" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POL_HEADER_ID"/>
    <userParameter name="P_DATE_BEGIN" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_DATE_END" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_CURRENT_DATE" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_ISSUER_SHORT" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_ISSUER_GENITIVE" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_ISSUER_DATIVE" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>	
	<userParameter name="P_ISSUER_INSTRUMENTAL" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_POL_NUM" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_CURRENCY" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_CURRENCY_BRIEF" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_POL_START_DATE" datatype="character" width="150" defaultWidth="0" defaultHeight="0"/>

	<dataSource name="Q_1">
      <select>
      <![CDATA[
-----------------------------------------
--основные данные от ЭПГ до документа платежа (ПП/ПД/А7)
-----------------------------------------
WITH epg_dso AS
 (SELECT pp.num AS pol_num
      ,pp.policy_id
      ,pp.version_num
      ,fu.brief fund_brief
      ,epg.plan_date epg_plan_date
      ,epg.grace_date epg_grace_date
      ,epg.payment_id epg_id
      ,epg.num epg_num
      ,dd.parent_amount debit_amount
      ,paym.num paym_num
      ,paym.amount paym_amount
      ,paym.due_date payer_date -- дата платежа /по ней мы суммируем платежи в рублях/
      ,paym.reg_date reg_date -- дата регистрации /по ней мы суммируем платежи в валюте/
      ,decode(fu.brief, 'RUR', paym.due_date, paym.reg_date) group_date_cred
      ,dso.doc_set_off_id
      ,epg.rev_rate
      ,nvl(dso.set_off_amount, 0) payer_sum_curr
      ,nvl(dso.set_off_child_amount, 0) payer_sum_rub
      ,dso.child_doc_id paym_id
      ,dso.pay_registry_item pay_registry_item
      ,paym.payer_brief --сокр платежа  
      ,CASE
         WHEN payer_brief IN ('ПП', 'ПП_ОБ', 'ПП_ПС', 'PAYORDER_SETOFF') THEN
          1 -- ППвх
         WHEN payer_brief IN ('A7', 'PD4') THEN
          2
         ELSE
          0
       END payer_type
  FROM p_pol_header ph
      ,ven_p_policy pp
       
      ,doc_doc dd
      ,ven_ac_payment epg
      ,doc_templ dt
      ,ven_doc_set_off dso
      ,(SELECT dt_paym.brief payer_brief
              ,paym.*
          FROM ven_ac_payment paym
              ,doc_templ      dt_paym
         WHERE paym.doc_templ_id = dt_paym.doc_templ_id
           AND dt_paym.brief NOT IN ('PAYMENT_SETOFF', 'PAYMENT_SETOFF_ACC')) paym
      ,ins.doc_status_ref dsr_epg
      ,fund fu
 WHERE ph.policy_header_id = :P_POL_HEADER_ID
   AND ph.policy_header_id = pp.pol_header_id
   AND fu.fund_id = ph.fund_id
   AND pp.policy_id = dd.parent_id
   AND dd.child_id = epg.payment_id
   AND epg.doc_templ_id = dt.doc_templ_id
      --выбираем эпг
   AND dt.brief = 'PAYMENT'
   AND epg.payment_id = dso.parent_doc_id(+)
   AND dso.child_doc_id = paym.payment_id(+)
      --не аннулированные
   AND epg.doc_status_ref_id = dsr_epg.doc_status_ref_id
   AND dsr_epg.brief NOT IN ('ANNULATED', 'NEW')
   AND dso.cancel_date IS NULL
  ),

-----------------------------------------  
--определение суммы по дебиту на дату графика
--определение версии к которой относится ЭПГ  
-----------------------------------------
debit_sum AS
 (SELECT x.epg_plan_date
        ,x.sdebit_amount
        ,(SELECT SUM(pc_.fee)
            FROM as_asset aa_
                ,p_cover  pc_
           WHERE aa_.p_policy_id = x.max_pol_id
             AND pc_.as_asset_id = aa_.as_asset_id) fee_sum
    FROM (SELECT ed.epg_plan_date
                ,SUM(ed.debit_amount) sdebit_amount
                ,MAX(ed.policy_id) keep(dense_rank FIRST ORDER BY ed.version_num DESC) max_pol_id
            FROM ( --так как epg_dso может содержать дубликаты из-за того что к одному эпг может быть привязано несклько платежей
                 select distinct epg_plan_date, debit_amount, policy_id, version_num
                 from epg_dso ed
                 ) ed
           GROUP BY ed.epg_plan_date) x),
-----------------------------------------
---данные по ПП связанные с ЭПГ через ПД4/А7  
-----------------------------------------
dso_ppvh AS
 (
 select set_off_paym_sum
        ,ppvh_num
        ,ppvh_reg_date
        ,ppvh_id
        ,pay_registry_item
        ,ppvh_amount
        ,dolg_a7_pd4
        ,color
        ,group_date_cred
        ,rev_rate
        ,payer_date
        ,pol_num
        ,postuplenie_sum
 from (
 select payer_sum_rub AS set_off_paym_sum
		,null doc_set_off_id
        ,ed.paym_num AS ppvh_num
        ,ed.reg_date as ppvh_reg_date
        ,ed.paym_id as ppvh_id
        ,ed.pay_registry_item as pay_registry_item
        ,ed.payer_sum_rub as ppvh_amount
        ,0 as dolg_a7_pd4
        ,'COMMON' color
        ,ed.paym_amount postuplenie_sum
        ,ed.group_date_cred
        ,ed.rev_rate
        ,ed.payer_date
        ,ed.pol_num
  from epg_dso ed
  where ed.payer_type = 1  
  union all
  SELECT /*ed.*
        ,*/nvl(dso.set_off_amount, 0) AS set_off_paym_sum
		,dso.doc_set_off_id
        ,ppvh.num AS ppvh_num
        ,ppvh.reg_date ppvh_reg_date
        ,ppvh.payment_id ppvh_id
        ,dso.pay_registry_item pay_registry_item
        ,dso.set_off_child_amount ppvh_amount
        ,ed.payer_sum_rub - pkg_payment.get_payment_amount_pd4_a7(ed.doc_set_off_id) as dolg_a7_pd4
        ,CASE
            WHEN ed.payer_type = 2
                 AND ed.payer_sum_rub > pkg_payment.get_payment_amount_pd4_a7(ed.doc_set_off_id) THEN
             'RED'
            ELSE
             'COMMON'
          END color
        ,ppvh.amount postuplenie_sum
        ,ed.group_date_cred
        ,ed.rev_rate
        ,ed.payer_date
        ,ed.pol_num
    FROM epg_dso            ed
        ,ins.doc_doc        dd
        ,ins.doc_set_off    dso
        ,ins.ven_ac_payment ppvh
        ,ins.doc_templ      dt
   WHERE ed.payer_type IN (2, 0) -- не ппвх
     AND ed.paym_id = dd.parent_id
     AND dd.child_id = dso.parent_doc_id
     AND dso.child_doc_id = ppvh.payment_id
     AND ppvh.doc_templ_id = dt.doc_templ_id
     AND dt.brief IN ('ПП', 'ПП_ОБ', 'ПП_ПС')
     and ed.payer_type != 1 
     )
     group by set_off_paym_sum
        ,doc_set_off_id --Сделано в рамках заявки 356472, не уверен что это будет работать нормально.
        ,ppvh_num
        ,ppvh_reg_date
        ,ppvh_id
        ,pay_registry_item
        ,ppvh_amount
        ,dolg_a7_pd4
        ,color
        ,group_date_cred
        ,rev_rate
        ,payer_date
        ,pol_num
        ,postuplenie_sum
     
     ),
-----------------------------------------
--строки по дебету и кредиту
-----------------------------------------     
wdebit_credit AS
 (
  --ДЕБЕТ     
  SELECT 'К оплате по дог.' || ed.pol_num || ' (' || to_char(ed.epg_plan_date, 'dd.mm.yyyy') AS oper_name
         ,to_char(epg_grace_date, 'dd.mm.yyyy') AS period
         ,CASE
            WHEN ds.sdebit_amount >= ds.fee_sum THEN
              ds.fee_sum
            ELSE             
			  ds.sdebit_amount
          END AS debit
          --Чирков №148793  п.4               
         ,NULL AS credit
         ,NULL AS credit_rub
         ,'COMMON' AS color
         ,ed.epg_plan_date AS due_date
         ,NULL rev_rate
         ,0 ord
         ,NULL dolg_a7_pd4
         ,NULL ppvh_num
         ,NULL ppvh_reg_date
         ,NULL ppvh_amount
         ,NULL er_id
         ,NULL postuplenie_sum
         ,1 cnt_cred
         ,1 row_num_cred
    FROM epg_dso   ed
         ,debit_sum ds
   WHERE ed.epg_plan_date = ds.epg_plan_date
   GROUP BY -- потому что в epg_dso у одного эпг может быть несколько ППВХ
             pol_num
            ,ed.epg_plan_date
            ,to_char(epg_grace_date, 'dd.mm.yyyy')
            ,CASE
             WHEN ds.sdebit_amount >= ds.fee_sum THEN
              ds.fee_sum
             ELSE             
			  ds.sdebit_amount
             END
             ,ed.fund_brief
  
  UNION ALL
  --КРЕДИТ     
  SELECT 'Оплачено по дог.' || dp.pol_num || ' (' || to_char(dp.group_date_cred, 'dd.mm.yyyy') AS oper_name
         ,NULL period
         ,NULL debit
         ,(SELECT SUM(ed_.payer_sum_curr) FROM epg_dso ed_ WHERE ed_.group_date_cred = dp.group_date_cred) credit
         ,(SELECT SUM(ed_.payer_sum_rub) FROM epg_dso ed_ WHERE ed_.group_date_cred = dp.group_date_cred) credit_rub
          --зачтенная сумма по платежу меньше суммы платежа (для ПД/А7)
         ,dp.color
         ,dp.payer_date
         ,', курс валюты ' ||
          to_char(dp.rev_rate, 'FM999G999G999G990D0000', 'NLS_NUMERIC_CHARACTERS = '', ''') AS rev_rate
         ,1 ord
          --формирование поля задолженность (для ПД/А7)
         ,dp.dolg_a7_pd4
          
          
          
         ,dp.ppvh_num
          
         ,dp.ppvh_reg_date
          
         ,dp.ppvh_amount
          
         ,dp.pay_registry_item er_id --элемент реестра
          
         ,dp.postuplenie_sum 
         ,COUNT(*) over(PARTITION BY dp.group_date_cred) cnt_cred
         ,row_number() over(PARTITION BY dp.group_date_cred ORDER BY dp.group_date_cred) row_num_cred
         
    FROM dso_ppvh dp),
-----------------------------------------
--ИТОГИ
-----------------------------------------
w_itogo AS
 (SELECT to_char(debit_total_after, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '', ''') debit_total_after
        ,to_char(credit_total_after, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '', ''') credit_total_after
        ,to_char(credit_total_rub_after, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '', ''') credit_total_rub_after
         --сальдо дебет на начало
        ,to_char(CASE
                   WHEN debit_total_before > credit_total_before THEN
                    debit_total_before - credit_total_before
                   ELSE
                    0
                 END
                ,'FM999G999G999G990D00'
                ,'NLS_NUMERIC_CHARACTERS = '', ''') saldo_debit_before
         --сальдо кредит на начало  
        ,to_char(CASE
                   WHEN credit_total_before > debit_total_before THEN
                    credit_total_before - debit_total_before
                   ELSE
                    0
                 END
                ,'FM999G999G999G990D00'
                ,'NLS_NUMERIC_CHARACTERS = '', ''') saldo_credit_before
         --сальдо дебет на дату окончания
        ,to_char(CASE
                   WHEN (debit_total_after + debit_total_before) > (credit_total_after + credit_total_before) THEN
                    (debit_total_after + debit_total_before) - (credit_total_after + credit_total_before)
                   ELSE
                    0
                 END
                ,'FM999G999G999G990D00'
                ,'NLS_NUMERIC_CHARACTERS = '', ''') saldo_debit_after
         --сальдо кредит на дату окончания  
        ,to_char(CASE
                   WHEN (credit_total_after + credit_total_before) > (debit_total_after + debit_total_before) THEN
                    (credit_total_after + credit_total_before) - (debit_total_after + debit_total_before)
                   ELSE
                    0
                 END
                ,'FM999G999G999G990D00'
                ,'NLS_NUMERIC_CHARACTERS = '', ''') saldo_credit_after
         
        ,to_char(ppvh_amount_sum, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '', ''') ppvh_amount_sum
         
         --итоговая строка задолженности
        ,CASE
           WHEN (debit_total_after + debit_total_before) > (credit_total_after + credit_total_before) THEN
            'задолженность ' || issuer_genitive || ' по полису ' || num ||
            ' перед ООО "СК "Ренессанс Жизнь" составляет ' ||
            to_char((debit_total_after + debit_total_before) -
                    (credit_total_after + credit_total_before)
                   ,'FM999G999G999G990D00'
                   ,'NLS_NUMERIC_CHARACTERS = '', ''') || ' (' ||
            pkg_num2str.num_to_str((debit_total_after + debit_total_before) -
                                   (credit_total_after + credit_total_before)
                                  ,fu_brief) || ').'
           ELSE
            'задолженность ООО "СК "Ренессанс Жизнь" по полису ' || num || ' перед Страхователем ' ||
            issuer_instrumental || ' составляет ' ||
            to_char((credit_total_after + credit_total_before) -
                    (debit_total_after + debit_total_before)
                   ,'FM999G999G999G990D00'
                   ,'NLS_NUMERIC_CHARACTERS = '', ''')
           
            || ' (' || pkg_num2str.num_to_str((credit_total_after + credit_total_before) -
                                              (debit_total_after + debit_total_before)
                                             ,fu_brief) || ').'
         END total_str
  
    FROM (SELECT
          --сальдо дебет на начало
           nvl((SELECT SUM(wdc_.debit)
                 FROM wdebit_credit wdc_
                WHERE wdc_.due_date < TO_DATE(:P_DATE_BEGIN, 'dd.mm.yyyy'))
              ,0) debit_total_before
           --сальдо дебет на конец
          ,nvl((SELECT SUM(wdc_.debit)
                 FROM wdebit_credit wdc_
                WHERE due_date BETWEEN TO_DATE(:P_DATE_BEGIN, 'dd.mm.yyyy') AND
                      TO_DATE(:P_DATE_END, 'dd.mm.yyyy'))
              ,0) debit_total_after
           
           --сальдо кредит на начало
          ,nvl((SELECT SUM(wdc_.credit)
                 FROM wdebit_credit wdc_
                WHERE due_date < TO_DATE(:P_DATE_BEGIN, 'dd.mm.yyyy'))
              ,0) credit_total_before
           --итого кредит в период выбранный параметрами пользователя в валюте
          ,nvl((SELECT SUM(credit)
                 FROM wdebit_credit wdc_
                WHERE due_date BETWEEN TO_DATE(:P_DATE_BEGIN, 'dd.mm.yyyy') AND
                      TO_DATE(:P_DATE_END, 'dd.mm.yyyy')
                  AND row_num_cred = 1)
              ,0) credit_total_after
           --итого кредит в период выбранный параметрами пользователя в рублях           
          ,nvl((SELECT SUM(credit_rub)
                 FROM wdebit_credit wdc_
                WHERE due_date BETWEEN TO_DATE(:P_DATE_BEGIN, 'dd.mm.yyyy') AND
                      TO_DATE(:P_DATE_END, 'dd.mm.yyyy')
                  AND row_num_cred = 1)
              ,0) credit_total_rub_after
           --итого сумма по ППвх в период выбранный параметрами пользователя                    
          ,nvl((SELECT SUM(ppvh_amount)
                 FROM wdebit_credit wdc_
                WHERE due_date BETWEEN TO_DATE(:P_DATE_BEGIN, 'dd.mm.yyyy') AND
                      TO_DATE(:P_DATE_END, 'dd.mm.yyyy'))
              ,0) ppvh_amount_sum
           
          ,pp.num
          ,fu.brief        fu_brief
          ,co.genitive     issuer_genitive --родительный падеж страхователя    
          ,co.instrumental issuer_instrumental --творительный подеж    
            FROM ins.p_pol_header ph
                ,ins.ven_p_policy pp
                ,ins.fund         fu
                ,contact          co
                ,v_pol_issuer     pi
           WHERE ph.policy_header_id = :P_POL_HEADER_ID
             AND pp.policy_id = ph.policy_id
             AND fu.fund_id = ph.fund_id
             AND pi.policy_id = pp.policy_id
             AND co.contact_id = pi.contact_id))
--------------------------------------------------------------------
------ОСНОВНОЙ ЗАПРОС
-------------------------------------------------------------------- 

SELECT row_number() over(ORDER BY due_date, ord, oper_name, row_num_cred) rn
      ,to_char(row_number() over(ORDER BY due_date, ord), 'FM00000') rn_char -- костыль для правильной сортировки
      ,oper_name
      ,period
      ,to_char(debit, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') as debit
      ,to_char(credit,'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', '''
                    )as credit
      ,to_char(credit_rub, 'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', '''
                   ) as credit_rub
      ,color
      ,rev_rate
      ,to_char(dolg_a7_pd4,'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') dolg_a7_pd4
      ,ppvh_num
      ,to_char(ppvh_reg_date,'dd.mm.yyyy') as PPVH_reg_date
      ,to_char(ppvh_amount, 'FM999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS = '', ''') ppvh_amount
      ,cnt_cred
      ,to_char(row_num_cred) row_num_cred
      ,er_id
      ,to_char(postuplenie_sum,'FM999G999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''')Postuplenie_sum  
      ,w_itogo.*
      ,COUNT(*) over() cnt
  FROM wdebit_credit
      ,w_itogo
 ORDER BY rn
]]>
      </select>
      <group name="GR_ROW">
        <dataItem name="rn"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[
function BeforeReport return boolean
is
  v_debit_total_before number;
  v_debit_total_after number;
  --v_debit_total_rub number;
  v_credit_total_before number;
  v_credit_total_rub_before number;
  v_credit_total_after number;
  v_credit_total_rub_after number;
  
  v_ppvh_total number;
begin
-- Текущая дата
	select to_char(sysdate,'dd.mm.yyyy') 
	  into :P_CURRENT_DATE
	  from dual;
  
-- Страхователь, Номер договора, Валюта ответственности
select co.name ||' '||substr(co.first_name,1,1)||'.'||substr(co.middle_name,1,1)||'.'
    ,co.genitive  --родительный падеж
	,co.dative  --дательный
    ,co.instrumental  -- творительный падеж
    ,pp.num
    ,fu.spell_1_whole
    ,fu.brief
    , case when to_date(md.start_date,'dd.mm.yyyy') < to_date(:P_DATE_BEGIN,'dd.mm.yyyy') then :P_DATE_BEGIN else md.start_date end --ЧИРКОВ №148793
    into :P_ISSUER_SHORT
    ,:P_ISSUER_GENITIVE
	,:P_ISSUER_DATIVE
    ,:P_ISSUER_INSTRUMENTAL
    ,:P_POL_NUM
    ,:P_CURRENCY
    ,:P_CURRENCY_BRIEF
    ,:P_POL_START_DATE
  from contact co
      ,v_pol_issuer pi
      ,p_pol_header ph
      ,ven_p_policy pp
      ,fund         fu
    ,(select to_char(min(pp1.start_date),'dd.mm.yyyy') as start_date
        from p_policy pp1
     where pp1.pol_header_id = :P_POL_HEADER_ID) md -- не дает делать коррелированные подзапросы
 where co.contact_id = pi.contact_id
   and pi.policy_id  = pp.policy_id
   and pp.policy_id  = pkg_policy.get_last_version(ph.policy_header_id)
   and ph.policy_header_id = :P_POL_HEADER_ID
   and ph.fund_id = fu.fund_id;

   
   return (TRUE);
end;
]]>
      </textSource>
    </function>
  </programUnits>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<style>
<!--table
	{mso-displayed-decimal-separator:"\.";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.75in .7in .75in .7in;
	mso-header-margin:.3in;
	mso-footer-margin:.3in;
	mso-page-orientation:landscape;}
tr
	{mso-height-source:userset;}
col
	{mso-width-source:userset;}
br
	{mso-data-placement:same-cell;}
.style0
	{mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	white-space:nowrap;
	mso-rotate:0;
	mso-background-source:auto;
	mso-pattern:auto;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Times New Roman, sans-serif;
	mso-font-charset:204;
	border:none;
	mso-protection:locked visible;
	mso-style-name:???????;
	mso-style-id:0;}
td
	{mso-style-parent:style0;
	padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Times New Roman, sans-serif;
	mso-font-charset:204;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;
	mso-protection:locked visible;
	mso-rotate:0;}
.header
	{mso-style-parent:style0;
	font-size:10.5pt;
	font-weight:400;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom: none;
	border-left:none;	
	height:15.75pt;
	}
.sub_header
	{mso-style-parent:style0;
	font-size:10.5pt;
	font-weight:400;
	text-align:left;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom: none;
	border-left:none;
	height:46.5pt;
	}
.table_header
	{mso-style-parent:style0;
	font-size:10.5pt;
	font-weight:400;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	height:30.0pt;
	}
.table_text
	{mso-style-parent:style0;
	font-size:10.5pt;
	font-weight:400;
	text-align:left;
	vertical-align:top;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	height:30.0pt;
	}
.table_date
	{mso-style-parent:style0;
	font-size:10.5pt;
	font-weight:400;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	}
.table_number
	{mso-style-parent:style0;
	font-size:10.5pt;
	font-weight:400;
	text-align:right;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	}
.footer
	{mso-style-parent:style0;
	font-size:10.5pt;
	font-weight:400;
	text-align:left;
	vertical-align:bottom;
	border-top:none;
	border-right:none;
	border-bottom: none;
	border-left:none;	
	height:15.75pt;
	}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>????1</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:Selected/>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>17</x:ActiveRow>
       <x:ActiveCol>6</x:ActiveCol>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????2</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????3</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>11955</x:WindowHeight>
  <x:WindowWidth>18975</x:WindowWidth>
  <x:WindowTopX>-615</x:WindowTopX>
  <x:WindowTopY>270</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
</xml><![endif]-->
</head>

<% 
  int rec_count_current = 0;
  String cnt_j = "";
  String rn_j = "";
  String P_DEBIT_TOTAL_AFTER = "";
  String P_CREDIT_TOTAL_AFTER = "";
  String P_CREDIT_TOTAL_RUB_AFTER = "";
  String P_DEBIT_SALDO_AFTER = "";
  String P_CREDIT_SALDO_AFTER = "";
  String PPVH_amount_sum_j = "";
  String total_str_j = "";
%>
<body link=blue vlink=purple>

<table x:str border=0 cellpadding=0 cellspacing=0 width=30 style='border-collapse:
 collapse;table-layout:fixed;width:30pt'>
 <rw:getValue id="CURRENCY_BRIEF" src="P_CURRENCY_BRIEF"/>

<% if (CURRENCY_BRIEF.equals("RUR")) { %>
 <col style='mso-width-source:userset;width:48px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:110px'>
 <col style='mso-width-source:userset;width:110px'>
 <col style='mso-width-source:userset;width:110px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:110px'>
 <col style='mso-width-source:userset;width:110px'>
 <col style='mso-width-source:userset;width:110px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <tr height=62 style='mso-height-source:userset'>
  <td colspan=14 height=62 class=header style='font-weight:700'>АКТ СВЕРКИ</td>
 </tr>
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <td colspan=14 height=62 class=header>взаимных расчетов по состоянию на <rw:field id="" src="P_CURRENT_DATE"/>г.</td>
 </tr>
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <td colspan=14 height=62 class=header>между ООО "СК "Ренессанс Жизнь"</td>
 </tr>
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <td colspan=14 height=62 class=header>и Страхователем <rw:field id="" src="P_ISSUER_INSTRUMENTAL"/> по договору страхования № <rw:field id="" src="P_POL_NUM"/></td>
 </tr>
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <td colspan=14 height=62 class=header></td>
 </tr>
 <tr height=62 style='mso-height-source:userset'>
  <td colspan=2 height=62 class=header><rw:field id="" src="P_CURRENT_DATE"/></td>
 </tr>
 <tr height=62 style='mso-height-source:userset'>
  <td colspan=14 height=62 class=sub_header>Мы, нижеподписавшиеся, Главный бухгалтер ООО "СК "Ренессанс Жизнь" Белоусова Е.В., с одной стороны, и <rw:field id="" src="P_ISSUER_SHORT"/>, с другой стороны, составили настоящий акт сверки в том, что состояние взаимных расчетов по данным учета следующее:</td>
 </tr>
<tr height=40 style='height:30.0pt'>
  <td height=40 class=table_header colspan=7 rowspan=2>По данным ООО "СК "Ренессанс Жизнь", <rw:field id="" src="P_CURRENCY"/></td>
  <td class=table_header colspan=5 rowspan=2>По данным Страхователя <rw:field id="" src="P_ISSUER_GENITIVE"/>, <rw:field id="" src="P_CURRENCY"/></td>
  <td class=table_header colspan=6 >Примечание</td>
</tr>
<tr height=40 style='height:30.0pt'>
  <td height=40 class=table_header style='height: 50pt'>Задолженность по оплате А7/ПД4</td>
  <td class=table_header colspan=5>Данные ППвх</td>
</tr>
<tr height=40 style='height:30.0pt'>
  <td class=table_header width=50 style='width:30pt;'>№</td>
  <td colspan=3 class=table_header width=30 style='width:50pt'>Наименование операции, документы</td>
  <td class=table_header width=50 style='width:100pt'>Льготный период</td>
  <td class=table_header width=50 style='width:79pt'>Дебет</td>
  <td class=table_header width=164 style='width:79pt'>Кредит</td>
  <td colspan=2 class=table_header width=30 style='width:30pt'>Наименование операции, документы</td>
  <td class=table_header width=164 style='width:79pt'>Льготный период</td>
  <td class=table_header width=164 style='width:79pt'>Дебет</td>
  <td class=table_header width=164 style='width:79pt'>Кредит</td>
  <td class=table_header width=30 style='width:79pt'>Сумма, руб.</td>
  <td class=table_header width=30 style='width:79pt'>№</td>
  <td class=table_header width=30 style='width:79pt'>Дата</td>
  <td class=table_header width=30 style='width:79pt'>Сумма, руб</td>
  <td class=table_header width=30 style='width:79pt'>ID элемента реестра</td>
  <td class=table_header width=30 style='width:79pt'>Сумма документа, руб</td>
 </tr>
 
 <rw:foreach id="fi2" src="GR_ROW">
 <% if (rec_count_current == 0) { %> 
  <tr height=20>
  <td height=20 class=table_text style='height: 15pt'><%=++rec_count_current%></td>
  <td colspan=3 class=table_text style='height: 15pt'>Сальдо на <rw:field id="" src="P_POL_START_DATE"/></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'><rw:field id="" src="SALDO_DEBIT_BEFORE"/></td>
  <td class=table_text style='height: 15pt'><rw:field id="" src="SALDO_CREDIT_BEFORE"/></td>
  <td colspan=2 class=table_text style='height: 15pt'>Сальдо на <rw:field id="" src="P_POL_START_DATE"/></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
 </tr>
  <rw:getValue id="ttt" src="saldo_debit_after"/>
 <% } %>
 
 <rw:getValue id="row_num_cr1" src="row_num_cred"/>
 <% if (row_num_cr1.equals("1")) { %> 
 <rw:getValue id="cnt_1" src="cnt_cred"/>
		<tr height=40 style='mso-height-source:userset'>
		  <td rowspan=<%=cnt_1%>  class=table_text><%=++rec_count_current%></td>
		  <td rowspan=<%=cnt_1%>  colspan=3 class=table_text><rw:field id="" src="oper_name"/>)</td>
		  <td rowspan=<%=cnt_1%>  class=table_date><rw:field id="" src="period"/></td>
		  <td rowspan=<%=cnt_1%>  class=table_number><rw:field id="" src="debit"/></td>
		  <rw:getValue id="j_color1" src="color"/>
		  <% if (j_color1.equals("RED")) { %>
			  <td rowspan=<%=cnt_1%>  class=table_number style='color:red'><rw:field id="" src="credit"/></td>
		  <% } else { %>
			  <td rowspan=<%=cnt_1%>  class=table_number><rw:field id="" src="credit"/></td>
		  <% } %>
		  <td rowspan=<%=cnt_1%>  height=100 colspan=2 class=table_text></td>
		  <td rowspan=<%=cnt_1%>  height=100 class=table_text></td>
		  <td rowspan=<%=cnt_1%>  height=100 class=table_text></td>
		  <td rowspan=<%=cnt_1%>  height=100 class=table_text></td> 
		  <td height=100 class=table_number><rw:field id="" src="Dolg_A7_PD4"/></td>
		  <td height=100 class=table_date><rw:field id="" src="PPVH_num"/></td>
		  <td height=100 class=table_number><rw:field id="" src="PPVH_reg_date"/></td>
		  <td height=100 class=table_date><rw:field id="" src="PPVH_amount"/></td>
		  <td height=100 class=table_number><rw:field id="" src="ER_ID"/></td>
		  <td height=100 class=table_date><rw:field id="" src="Postuplenie_sum"/></td>
		 </tr>
<%}else{%>
		 <tr height=60 style='mso-height-source:userset'; style='height: 60pt'>
			  <td height=100 class=table_number><rw:field id="" src="Dolg_A7_PD4"/></td>
			  <td height=100 class=table_date><rw:field id="" src="PPVH_num"/></td>
			  <td height=100 class=table_number><rw:field id="" src="PPVH_reg_date"/></td>
			  <td height=100 class=table_date><rw:field id="" src="PPVH_amount"/></td>	
			  <td height=100 class=table_number><rw:field id="" src="ER_ID"/></td>
		      <td height=100 class=table_date><rw:field id="" src="Postuplenie_sum"/></td>
		 </tr>
<% } %>


<rw:getValue id="cnt_r" src="cnt"/>
<rw:getValue id="rn_r" src="rn"/>
<rw:getValue id="debit_total_after_r" src="debit_total_after"/>
<rw:getValue id="credit_total_after_r" src="credit_total_after"/>
<rw:getValue id="PPVH_amount_sum_r" src="PPVH_amount_sum"/>
<%cnt_j = cnt_r; %>
<%rn_j = rn_r; %>
<%P_DEBIT_TOTAL_AFTER = debit_total_after_r; %>
<%P_CREDIT_TOTAL_AFTER = credit_total_after_r; %>
<%PPVH_amount_sum_j = PPVH_amount_sum_r;%>



<rw:getValue id="SALDO_DEBIT_AFTER_R" src="SALDO_DEBIT_AFTER"/>
<%P_DEBIT_SALDO_AFTER = SALDO_DEBIT_AFTER_R;%>

<rw:getValue id="SALDO_CREDIT_AFTER_R" src="SALDO_CREDIT_AFTER"/>
<%P_CREDIT_SALDO_AFTER = SALDO_CREDIT_AFTER_R;%>

<rw:getValue id="total_str_R" src="total_str"/>
<%total_str_j = total_str_R;%>

<% if (cnt_j.equals(rn_j)) { %>

 <tr height=20  style='height: 15pt'>
  <td height=20 class=table_text style='height: 15pt'></td>
  <td colspan=3 class=table_text style='height: 15pt'>Обороты за период</td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_number style='height: 15pt'><%=P_DEBIT_TOTAL_AFTER%></td>
  <td class=table_number style='height: 15pt'><%=P_CREDIT_TOTAL_AFTER%></td>
  <td colspan=2 class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'><%=PPVH_amount_sum_j%></td> 
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
 </tr>
 
 <tr height=20  style='height: 15pt'>
  <td height=20 class=table_text style='height: 15pt'></td>
  <td colspan=3 class=table_text style='height: 15pt'>Сальдо на <rw:field id="" src="P_CURRENT_DATE"/></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_number style='height: 15pt'><%=P_DEBIT_SALDO_AFTER%></td>
  <td class=table_number style='height: 15pt'><%=P_CREDIT_SALDO_AFTER%></td>
  <td colspan=2 class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
</tr>

<tr height=30 style='height:30.0pt'>
  <td height=30 class=footer colspan=7 rowspan=2>По данным ООО "СК "Ренессанс Жизнь"</td>
  <td class=footer colspan=5 rowspan=2>По данным Страхователя <rw:field id="" src="P_ISSUER_SHORT"/></td>
</tr>
<tr>
  <td></td>
  <td></td>
</tr>
<tr height=40 style='mso-height-source:userset;height:40.0pt'>
  <td height=40 class=footer colspan=8><%=total_str_j%></td>
</tr>
<% } %>

 </rw:foreach>



<%}else{%>
 <col style='mso-width-source:userset;width:48px'>
 <col style='mso-width-source:userset;width:60px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:150px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:80px'>
 <col style='mso-width-source:userset;width:80px'>
  <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 <col style='mso-width-source:userset;width:40px'>
 
<tr height=62 style='mso-height-source:userset'>
  <td colspan=15 height=62 class=header style='font-weight:700'>АКТ СВЕРКИ</td>
 </tr>
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <td colspan=15 height=62 class=header>взаимных расчетов по состоянию на <rw:field id="" src="P_CURRENT_DATE"/>г.</td>
 </tr>
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <td colspan=15 height=62 class=header>между ООО "СК "Ренессанс Жизнь"</td>
 </tr>
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <td colspan=15 height=62 class=header>и Страхователем <rw:field id="" src="P_ISSUER_SHORT"/> по договору страхования № <rw:field id="" src="P_POL_NUM"/></td>
 </tr>
 <tr height=62 style='mso-height-source:userset;height:15.75pt'>
  <td colspan=15 height=62 class=header></td>
 </tr>
 <tr height=62 style='mso-height-source:userset'>
  <td colspan=2 height=62 class=header><rw:field id="" src="P_CURRENT_DATE"/></td>
 </tr>
 <tr height=62 style='mso-height-source:userset'>
  <td colspan=15 height=62 class=sub_header>Мы, нижеподписавшиеся, Главный бухгалтер ООО "СК "Ренессанс Жизнь" Белоусова Е.В., с одной стороны, и <rw:field id="" src="P_ISSUER_SHORT"/>, с другой стороны, составили настоящий акт сверки в том, что состояние взаимных расчетов по данным учета следующее:</td>
 </tr>
 

<tr height=40 style='height:30.0pt'>
  <td height=40 class=table_header colspan=8 rowspan=2>По данным ООО "СК "Ренессанс Жизнь", <rw:field id="" src="P_CURRENCY"/></td>
  <td class=table_header colspan=5 rowspan=2>По данным Страхователя <rw:field id="" src="P_ISSUER_GENITIVE"/>, <rw:field id="" src="P_CURRENCY"/></td>
  <td class=table_header colspan=6 >Примечание</td>
</tr>
<tr height=40 style='height:30.0pt'>
  <td rowspan=1 height=40 class=table_header  style='height: 50pt'>Задолженность по оплате А7/ПД4</td>
  <td rowspan=1 class=table_header colspan=5>Данные ППвх</td>
</tr>
<tr height=40 style='height:30.0pt'>
  <td rowspan=2 class=table_header width=50 style='width:30pt;'>№</td>
  <td rowspan=2 colspan=3 class=table_header width=30 style='width:50pt'>Наименование операции, документы</td>

  <td colspan=2 class=table_header width=20 style='width:30pt'>Дебет</td>
  <td colspan=2 class=table_header width=30 style='width:79pt'>Кредит</td>
  <td rowspan=2 class=table_header width=30 style='width:60pt'>Наименование операции, документы</td>
  <td colspan=2 class=table_header width=30 style='width:30pt'>Дебет</td>
  <td colspan=2 class=table_header width=30 style='width:79pt'>Кредит</td>
  <td rowspan=2 class=table_header width=30 style='width:79pt'>Сумма, руб.</td>
  <td rowspan=2 class=table_header width=30 style='width:79pt'>№</td>
  <td rowspan=2 class=table_header width=30 style='width:79pt'>Дата</td>
  <td rowspan=2 class=table_header width=30 style='width:79pt'>Сумма, руб</td>
  <td rowspan=2 class=table_header width=30 style='width:79pt'>ID элемента реестра</td>
  <td rowspan=2 class=table_header width=30 style='width:79pt'>Сумма документа, руб</td>
 </tr>
 
  <rw:foreach id="fi2" src="GR_ROW">
 <% if (rec_count_current == 0) { %>  
 
 <tr height=20>
  <td colspan=2 class=table_text style='height: 15pt'><rw:field id="" src="P_CURRENCY"/></td>
  <td class=table_text style='height: 15pt'><rw:field id="" src="P_CURRENCY"/></td>
  <td class=table_text style='height: 15pt'>руб</td>
  <td colspan=2 class=table_text style='height: 15pt'><rw:field id="" src="P_CURRENCY"/></td>
  <td class=table_text style='height: 15pt'><rw:field id="" src="P_CURRENCY"/></td>
  <td class=table_text style='height: 15pt'>руб</td>
 </tr>
 
  <tr height=20>
  <td height=20 class=table_text style='height: 15pt'><%=++rec_count_current%></td>
  <td colspan=3 class=table_text style='height: 15pt'>Сальдо на <rw:field id="" src="P_POL_START_DATE"/></td>
  <td colspan=2 class=table_text style='height: 15pt'><rw:field id="" src="SALDO_DEBIT_BEFORE"/></td>
  <td class=table_text style='height: 15pt'><rw:field id="" src="SALDO_CREDIT_BEFORE"/></td>
  <td class=table_text style='height: 15pt'>0.00</td>
  <td class=table_text style='height: 15pt'>Сальдо на <rw:field id="" src="P_POL_START_DATE"/></td>
  <td colspan=2 class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
 </tr>
 
  <% } %>
 

 <rw:getValue id="row_num_cr2" src="row_num_cred"/>
  <% if (row_num_cr2.equals("1")) { %> 
     <rw:getValue id="cnt_2" src="cnt_cred"/>
	 <tr height=60 style='mso-height-source:userset'; style='height: 60pt'>
	  <td rowspan=<%=cnt_2%>  height=100 class=table_text><%=++rec_count_current%></td>
	  <td rowspan=<%=cnt_2%>  colspan=3 height=100 class=table_text><rw:field id="" src="oper_name"/> <rw:field id="" src="rev_rate"/>)</td>
	  <td rowspan=<%=cnt_2%>  colspan=2 height=100 class=table_number><rw:field id="" src="debit"/></td>
	  <td rowspan=<%=cnt_2%>  height=100 class=table_number><rw:field id="" src="credit"/></td>
	  <rw:getValue id="j_color" src="color"/>
	  <% if (j_color.equals("RED")) { %>
	  <td rowspan=<%=cnt_2%>  height=100 class=table_number style='color:red'><rw:field id="" src="credit_rub"/></td>
	  <% } else { %>
	  <td rowspan=<%=cnt_2%>  height=100 class=table_number><rw:field id="" src="credit_rub"/></td>
	  <% } %>
	  <td rowspan=<%=cnt_2%>  height=100  class=table_text></td>
	  <td rowspan=<%=cnt_2%>  height=100 colspan=2 class=table_text></td>
	  <td rowspan=<%=cnt_2%>  height=100 class=table_text></td> 
	  <td rowspan=<%=cnt_2%>  height=100 class=table_text></td> 
 	  <td height=100 class=table_number><rw:field id="" src="Dolg_A7_PD4"/></td>
	  <td height=100 class=table_date><rw:field id="" src="PPVH_num"/></td>
	  <td height=100 class=table_number><rw:field id="" src="PPVH_reg_date"/></td>
	  <td height=100 class=table_date><rw:field id="" src="PPVH_amount"/></td>
	  <td height=100 class=table_number><rw:field id="" src="ER_ID"/></td>
	  <td height=100 class=table_date><rw:field id="" src="Postuplenie_sum"/></td>
	 </tr>
<%}else{%>
	 <tr height=60 style='mso-height-source:userset'; style='height: 60pt'>
		  <td height=100 class=table_number><rw:field id="" src="Dolg_A7_PD4"/></td>
		  <td height=100 class=table_date><rw:field id="" src="PPVH_num"/></td>
		  <td height=100 class=table_number><rw:field id="" src="PPVH_reg_date"/></td>
		  <td height=100 class=table_date><rw:field id="" src="PPVH_amount"/></td>	
		  <td height=100 class=table_number><rw:field id="" src="ER_ID"/></td>
		  <td height=100 class=table_date><rw:field id="" src="Postuplenie_sum"/></td>
	 </tr>
<% } %>


<rw:getValue id="cnt_r2" src="cnt"/>
<rw:getValue id="rn_r2" src="rn"/>
<rw:getValue id="debit_total_after_r2" src="debit_total_after"/>
<rw:getValue id="credit_total_after_r2" src="credit_total_after"/>

<rw:getValue id="PPVH_amount_sum_r2" src="PPVH_amount_sum"/>
<%cnt_j = cnt_r2; %>
<%rn_j = rn_r2; %>



<%P_DEBIT_TOTAL_AFTER = debit_total_after_r2; %>
<%P_CREDIT_TOTAL_AFTER = credit_total_after_r2; %>

<%PPVH_amount_sum_j = PPVH_amount_sum_r2;%>

<rw:getValue id="credit_total_rub_after_r2" src="credit_total_rub_after"/>
<%P_CREDIT_TOTAL_RUB_AFTER = credit_total_rub_after_r2; %>

<rw:getValue id="SALDO_DEBIT_AFTER_R2" src="SALDO_DEBIT_AFTER"/>
<%P_DEBIT_SALDO_AFTER = SALDO_DEBIT_AFTER_R2;%>

<rw:getValue id="SALDO_CREDIT_AFTER_R2" src="SALDO_CREDIT_AFTER"/>
<%P_CREDIT_SALDO_AFTER = SALDO_CREDIT_AFTER_R2;%>


<rw:getValue id="total_str_R2" src="total_str"/>
<%total_str_j = total_str_R2;%>

 <% if (cnt_j.equals(rn_j)) { %>

 <tr height=20  style='height: 15pt'>
  <td height=20 class=table_text style='height: 15pt'></td>
  <td colspan=3 class=table_text style='height: 15pt'>Обороты за период</td>
  <td colspan=2 class=table_number style='height: 15pt'><%=P_DEBIT_TOTAL_AFTER%></td>
  <td class=table_number style='height: 15pt'><%=P_CREDIT_TOTAL_AFTER%></td>
  <td class=table_number style='height: 15pt'><%=P_CREDIT_TOTAL_RUB_AFTER%></td>
  
  <td class=table_text style='height: 15pt'></td>
  <td colspan=2 class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'><%=PPVH_amount_sum_j%></td> 
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
 </tr> 
 
<tr height=20  style='height: 15pt'>
  <td height=20 class=table_text style='height: 15pt'></td>
  <td colspan=3 class=table_text style='height: 15pt'>Сальдо на <rw:field id="" src="P_CURRENT_DATE"/></td>
  <td colspan=2 class=table_number style='height: 15pt'><%=P_DEBIT_SALDO_AFTER%></td>
  <td class=table_number style='height: 15pt'><%=P_CREDIT_SALDO_AFTER%></td>
  <td class=table_number style='height: 15pt'>0.00</td>  
  <td class=table_text style='height: 15pt'></td>
  <td colspan=2 class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
  <td class=table_text style='height: 15pt'></td>
</tr>
 
<tr height=30 style='height:30.0pt'>
  <td height=30 class=footer colspan=8 rowspan=2>По данным ООО "СК "Ренессанс Жизнь"</td>
  <td class=footer colspan=5 rowspan=2>По данным Страхователя <rw:field id="" src="P_ISSUER_GENITIVE"/></td>
</tr>
<tr>
  <td></td>
  <td></td>
</tr>
<tr height=40 style='mso-height-source:userset;height:40.0pt'>
  <td height=40 class=footer colspan=8><%=total_str_j%></td>
</tr>
 <% } %>

 </rw:foreach>

 <% } %>

 
 
<tr height=40 style='mso-height-source:userset;height:15.0pt'>
  <td height=40 class=footer colspan=7></td>
</tr>
<tr height=40 style='mso-height-source:userset;height:15.0pt'>
  <td height=40 class=footer colspan=7>От ООО "СК "Ренессанс Жизнь"</td>
</tr>
<tr height=40 style='mso-height-source:userset;height:15.0pt'>
  <td height=40 class=footer colspan=7>______________________________ (Белоусова Е.В.)</td>
</tr>
<tr height=40 style='mso-height-source:userset;height:15.0pt'>
  <td height=40 class=footer colspan=7>М.П.</td>
</tr>
<tr height=40 style='mso-height-source:userset;height:15.0pt'>
  <td height=40 class=footer colspan=7>______________________________ (Гусев В.В.)</td>
</tr>
</table>


 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=48 style='width:36pt'></td>
  <td width=82 style='width:62pt'></td>
  <td width=87 style='width:65pt'></td>
  <td width=61 style='width:46pt'></td>
 </tr>
 <![endif]>

</body>

</html>


</rw:report>
