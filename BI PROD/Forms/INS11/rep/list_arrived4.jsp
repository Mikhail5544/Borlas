<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bordero" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="reestr" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
   <userParameter name="P_SID"/>
    <userParameter name="PNUMBER"/>
	<userParameter name="NTID"/>
	<userParameter name="NUM"/>
    <userParameter name="P_MONTH" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="name_letter" datatype="character" width="250"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="SYS_DATE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_YEAR" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="NOTIF" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
       <dataSource name="Q_1">
      <select>
      <![CDATA[ select count(*) rec_count
  from notif_letter_rep rep,
   v_letters_payment vlp,
   p_pol_header ph,
   p_policy pp
 where vlp.document_id = rep.document_id
       and rep.sessionid = :P_SID--30378
       and vlp.pol_header_id = ph.policy_header_id
       and pp.policy_id = ph.policy_id
	   --изменено по заявке 307107: Доработка выгрузки писем-напоминаний и в ЛП
       and pp.payment_term_id != 1 --Единовременно
	   /*and ph.product_id in (select pv.number_val
                             from t_notification_type  nt
                                  ,t_n_ltrs_params      lp
                                  ,t_n_ltrs_params_vals pv
                             where nt.brief                  = 'REMIND_30_PDFN'
                               and lp.brief                  = 'PRODUCT'
                               and nt.t_notification_type_id = pv.t_notification_type_id
                               and lp.t_n_ltrs_params_id     = pv.t_notif_param_id
                                   )*/]]>
      </select>
      <group name="group_count">
        <dataItem name="rec_count"/>
      </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[

SELECT rownum rec_number,
               21||lpad(:NUM+rownum-1,6,'0') vhnum, b.*
FROM (
select mn.*
      ,trim(to_char(sum_zadol_num,'9999999990D00'))
       ||
       case when fund != 'RUR' then ' * '
       end sum_zadol
  from (
select payment_period,
       contact_name,
       contact_name||'!' contact_name_1,
       address_name,
       fadr,
	   distr_name,
       case when nvl(distr_name,'X') <> 'X' and nvl(city_name,'X') <> 'X' then city_name||', '||distr_name else 
                 (case when nvl(distr_name,'X') = 'X' then city_name else distr_name end) end city_name,
       province_name,
       region_name,
       case when nvl(country_name,'X') <> 'X' and nvl(province_name,'X') <> 'X' then province_name||', '||country_name else 
                 (case when nvl(province_name,'X') = 'X' then country_name else province_name end) end country_name,
       zip,
       code,
       init_name,
       due_date,
       fund,
       pol_num,
       ids,
       flag,
       dog_num,
       pol_ser,
       type_contact,
       is_adm,
       gender,
	   product,
	   start_date,
	   to_char(last_payd,'dd.mm.yyyy') last_payd,
       to_char(first_unpayd,'dd.mm.yyyy') first_unpayd,
	   oplata,
	   pay_amount,
	   agent_current,
	   leader_agent,
	   leader_manag,
	   contact_id,
	   grace_period,
       plan_date,
       case mb when 0 then trim(to_char(fee,'9999999990D00')) 
                      else trim(to_char(amount,'9999999990D00')) end amount,
       case when nvl(part_pay_amount,0) > 0 
             then trim(to_char((case mb when 0 then fee else amount end) - nvl(part_pay_amount,0),'9999999990D00'))
             else trim(to_char((case mb when 0 then fee else amount end),'9999999990D00'))
       end amount_new,
       last_pol_status,
       trim(to_char(non_pay_amount,'9999999990D00'))  non_pay_amount,
       /*case when nvl(part_pay_amount,0) > 0 
            then (case mb when 0 then fee else amount end) - nvl(part_pay_amount,0)-ir_amount
            else nvl(non_pay_amount,0) + (case mb when 0 then fee else amount end)-ir_amount
       end */
       decode( mb, 0, fee, amount) - ir_amount - abs(nvl(part_pay_amount,0)) sum_zadol_num,
       trim(to_char( nvl(part_pay_amount,0),'9999999990D00')) part_pay_amount
from
(select 

  (SELECT sum(a.amount) - sum(Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL))
  FROM
    DOCUMENT d,
    AC_PAYMENT a,
    DOC_TEMPL dt,
    DOC_DOC dd,
    P_POLICY p,
    P_POL_HEADER PPH,
    CONTACT c,
    DOC_STATUS ds,
    DOC_STATUS_REF dsr
  WHERE d.document_id = a.payment_id
        AND d.doc_templ_id = dt.doc_templ_id
        AND dt.brief = 'PAYMENT'
        AND dd.child_id = d.document_id
        AND dd.parent_id = p.policy_id
        AND pph.policy_header_id = p.pol_header_id
        AND a.contact_id = c.contact_id
        AND ds.document_id = d.document_id
        AND ds.start_date = (SELECT MAX(dss.start_date)
                             FROM DOC_STATUS dss
                             WHERE dss.document_id = d.document_id)
        AND dsr.doc_status_ref_id = ds.doc_status_ref_id
        AND dsr.name <> 'Аннулирован'
        and a.plan_date between pph.start_date and vlp.prev_due_date
  and a.due_date >= to_date('01.01.2008','dd.mm.yyyy')
        and p.pol_header_id = ph.policy_header_id) non_pay_amount,
      
  (SELECT sum(nvl(Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL),0))
  FROM
    DOCUMENT d,
    AC_PAYMENT a,
    DOC_TEMPL dt,
    DOC_DOC dd,
    P_POLICY p,
    P_POL_HEADER PPH,
    CONTACT c,
    DOC_STATUS ds,
    DOC_STATUS_REF dsr
  WHERE d.document_id = a.payment_id
        AND d.doc_templ_id = dt.doc_templ_id
        AND dt.brief = 'PAYMENT'
        AND dd.child_id = d.document_id
        AND dd.parent_id = p.policy_id
        AND pph.policy_header_id = p.pol_header_id
        AND a.contact_id = c.contact_id
        AND ds.document_id = d.document_id
        AND ds.start_date = (SELECT MAX(dss.start_date)
                             FROM DOC_STATUS dss
                             WHERE dss.document_id = d.document_id)
        AND dsr.doc_status_ref_id = ds.doc_status_ref_id
        AND dsr.name not in ('Аннулирован','Оплачен')
        and a.plan_date between vlp.due_date and vlp.due_date
        and a.due_date >= to_date('01.01.2008','dd.mm.yyyy')
        and p.pol_header_id = ph.policy_header_id) part_pay_amount,
		
  (SELECT nvl(sum(ir.invest_reserve_amount),0)
  FROM
    DOCUMENT d,
    AC_PAYMENT a,
    DOC_TEMPL dt,
    DOC_DOC dd,
    P_POLICY p,
    P_POL_HEADER PPH,
    CONTACT c,
    DOC_STATUS ds,
    DOC_STATUS_REF dsr,
    ac_payment_ir ir
  WHERE d.document_id = a.payment_id
        and a.payment_id = ir.ac_payment_id
        AND d.doc_templ_id = dt.doc_templ_id
        AND dt.brief = 'PAYMENT'
        AND dd.child_id = d.document_id
        AND dd.parent_id = p.policy_id
        AND pph.policy_header_id = p.pol_header_id
        AND a.contact_id = c.contact_id
        AND ds.document_id = d.document_id
        AND ds.start_date = (SELECT MAX(dss.start_date)
                             FROM DOC_STATUS dss
                             WHERE dss.document_id = d.document_id)
        AND dsr.doc_status_ref_id = ds.doc_status_ref_id
        AND dsr.name not in ('Аннулирован','Оплачен')
        and a.plan_date between vlp.due_date and vlp.due_date
        and a.due_date >= to_date('01.01.2008','dd.mm.yyyy')
        and p.pol_header_id = ph.policy_header_id) ir_amount,
		
(SELECT sum(Pkg_Payment.get_set_off_amount(d.document_id, NULL, NULL))
FROM
  DOCUMENT d,
  AC_PAYMENT a,
  DOC_TEMPL dt,
  DOC_DOC dd,
  P_POLICY p,
  P_POL_HEADER PPH,
  CONTACT c,
  DOC_STATUS ds,
  DOC_STATUS_REF dsr
WHERE d.document_id = a.payment_id
      AND d.doc_templ_id = dt.doc_templ_id
      AND dt.brief = 'PAYMENT'
      AND dd.child_id = d.document_id
      AND dd.parent_id = p.policy_id
      AND pph.policy_header_id = p.pol_header_id
      AND a.contact_id = c.contact_id
      AND ds.document_id = d.document_id
      AND ds.start_date = (SELECT MAX(dss.start_date)
                           FROM DOC_STATUS dss
                           WHERE dss.document_id = d.document_id)
      AND dsr.doc_status_ref_id = ds.doc_status_ref_id
      AND dsr.name <> 'Аннулирован'
      and a.plan_date between pph.start_date and vlp.prev_due_date
      and a.due_date >= to_date('01.01.2008','dd.mm.yyyy')
      and p.pol_header_id = ph.policy_header_id) pay_amount,

       vlp.payment_period,
       vlp.contact_name,
	   vlp.contact_id,
       vlp.address_name,
       vlp.fadr,
       vlp.city_name,
       vlp.province_name,
      (SELECT COUNT(*)
       FROM ins.p_policy pol,
            ins.as_asset at,
            ins.p_cover pct,
            ins.t_prod_line_option opt,
            ins.t_product_line pl
       WHERE pol.policy_id = at.p_policy_id
         AND at.as_asset_id = pct.as_asset_id
         AND pct.t_prod_line_option_id = opt.id
         AND pl.id = opt.product_line_id
         AND pol.pol_header_id = ph.policy_header_id
         AND pl.description IN 'Административные издержки'
      ) is_adm,
      vlp.distr_name,
      vlp.region_name,
      vlp.country_name,
      vlp.zip,
      vlp.code,
      vlp.mb,
      vlp.init_name,
      to_char(vlp.due_date, 'dd.mm.yyyy') due_date,
      vlp.sum_fee amount,
      vlp.pay_amount_dog,
      vlp.fund,
      pp.pol_num,
      ph.ids,
      case when length(pp.pol_num)>6 then 1 else 0 end flag,
      pp.pol_num dog_num,
      case when length(pp.pol_num)>6 then substr(pp.pol_num,1,3) else pp.pol_ser end pol_ser,
      vlp.type_contact,
      vlp.gender,
	  trim(to_char(vlp.oplata,'999999999D99')) oplata,
      sum(pc.fee) fee,
	  prod.description product,
	  to_char(ph.start_date,'dd.mm.yyyy') start_date,
	  pkg_renlife_utils.paid_unpaid(ph.policy_header_id, 2) last_payd,
      pkg_renlife_utils.paid_unpaid(ph.policy_header_id, 1) first_unpayd,
	  to_char(vlp.grace_date + 1,'dd.mm.yyyy') grace_period,
      to_char(vlp.plan_date,'dd.mm.yyyy') plan_date,
	  vlp.agent_current, vlp.leader_agent, vlp.leader_manag,
	  pkg_policy.get_last_version_status(ph.policy_header_id) as last_pol_status
       
  from v_letters_payment vlp, 
       notif_letter_rep nlr,
       p_pol_header ph,
       t_product prod,
       p_policy pp,
       as_asset a,
       p_cover pc,
      (select pol.pol_header_id, sum(decode(plt.brief,'OPTIONAL',1,'MANDATORY',1,0)) plt_cnt
      from ins.p_policy pol,
           ins.as_asset at,
           ins.p_cover pct,
           ins.t_prod_line_option opt,
           ins.t_product_line pl,
           ins.t_product_line_type plt
      where pol.policy_id = at.p_policy_id
            and at.as_asset_id = pct.as_asset_id
            and pct.t_prod_line_option_id = opt.id
            and pl.id = opt.product_line_id
            and pl.product_line_type_id = plt.product_line_type_id
            and opt.brief NOT IN ('Adm_Cost_Life','Adm_Cost_Acc','Penalty')
            and at.as_asset_id = pct.as_asset_id
      group by pol.pol_header_id) plt

 where vlp.document_id = nlr.document_id
   --изменено по заявке 307107: Доработка выгрузки писем-напоминаний и в ЛП
   AND pp.payment_term_id != 1 --Единовременно
   /*
   and prod.product_id in (select pv.number_val
                            from t_notification_type  nt
                                ,t_n_ltrs_params      lp
                                ,t_n_ltrs_params_vals pv
                           where nt.brief                  = 'REMIND_30_PDFN'
                             and lp.brief                  = 'PRODUCT'
                             and nt.t_notification_type_id = pv.t_notification_type_id
                             and lp.t_n_ltrs_params_id     = pv.t_notif_param_id
                         )*/

   and nlr.sessionid = :P_SID--1561944
   and ph.policy_header_id = vlp.pol_header_id
   and ph.product_id = prod.product_id
   and plt.pol_header_id = ph.policy_header_id
   and pp.policy_id = ph.policy_id
   and pp.policy_id = a.p_policy_id
   and a.as_asset_id = pc.as_asset_id
   and pc.status_hist_id <> 3
group by vlp.payment_period,
       vlp.contact_name,
       vlp.address_name,
       vlp.fadr,
       vlp.city_name,
       vlp.province_name,
       vlp.region_name,
       vlp.distr_name,
       vlp.country_name,
       vlp.zip,
       vlp.code,
       vlp.mb,
       vlp.init_name,
       to_char(vlp.due_date, 'dd.mm.yyyy'),
       vlp.due_date,
       vlp.prev_due_date,
       ph.policy_header_id,
       ph.ids,
       ph.start_date,
       vlp.sum_fee,
       vlp.pay_amount_dog,
       vlp.fund,
       pp.pol_num,
       ph.ids,
       case when length(pp.pol_num)>6 then 1 else 0 end,
       pp.pol_num,
       case when length(pp.pol_num)>6 then substr(pp.pol_num,1,3) else pp.pol_ser end,
       vlp.type_contact,
       vlp.gender,
	   prod.description,
	   vlp.oplata,
	   to_char(vlp.grace_date + 1,'dd.mm.yyyy'),
       to_char(vlp.plan_date,'dd.mm.yyyy'),
	   vlp.agent_current,
	   vlp.leader_agent,
	   vlp.leader_manag,
	   vlp.contact_id
))mn
,(select pv.number_val
        ,case lp.brief
           when 'SUM_DEBT_RUR' then 'RUR'
           when 'SUM_DEBT_USD' then 'USD'
           when 'SUM_DEBT_EUR' then 'EUR'
         end as fund_brief
    from t_notification_type  nt
        ,t_n_ltrs_params      lp
        ,t_n_ltrs_params_vals pv
   where nt.brief                  = 'REMIND_30_PDFN'
     and lp.brief in ('SUM_DEBT_RUR','SUM_DEBT_USD','SUM_DEBT_EUR')
     and nt.t_notification_type_id = pv.t_notification_type_id
     and lp.t_n_ltrs_params_id     = pv.t_notif_param_id
 ) sm
where mn.fund           = sm.fund_brief
  and mn.sum_zadol_num >= sm.number_val
  /**/
and mn.sum_zadol_num - mn.amount < (CASE mn.fund 
                                        WHEN 'RUR'
                                         THEN 600
                                        ELSE 20
                                      END)
  /**/
  --392218 Григорьев Ю. Проблема с выводом данных (сначала выводились страхователи, напечатанные большими буквами, а затем остальные (см. заявку))
order by upper(mn.contact_name)) b
	   
	   ]]>
      </select>
      <group name="group_data">
        <dataItem name="rec_number"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

select to_char(trunc(sysdate),'dd.mm.yyyy'),
	to_char(trunc(sysdate),'mm'),
       to_char(trunc(sysdate),'yyyy')
into :SYS_DATE, :P_MONTH, :P_YEAR
from dual;

select t.description
into :name_letter
from t_notification_type t
where t.t_notification_type_id = :NTID;

select to_number(:PNUMBER)
into :NUM
from dual;


return (TRUE);
end;]]>
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
	{mso-height-source:auto;}
col
	{mso-width-source:auto;}
br
	{mso-data-placement:same-cell;}
.style0
	{mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	mso-rotate:0;
	mso-background-source:auto;
	mso-pattern:auto;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
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
	font-family:Calibri, sans-serif;
	mso-font-charset:204;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;
	mso-protection:locked visible;
	mso-rotate:0;}
.xl65
	{mso-style-parent:style0;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:silver;
	mso-pattern:auto none;
	white-space:normal;}
.xl66
	{mso-style-parent:style0;
	border:.5pt solid windowtext;}
.xl67
	{mso-style-parent:style0;
	font-weight:700;}
.xl68
	{mso-style-parent:style0;
	vertical-align:middle;}
.xl69
	{mso-style-parent:style0;
	text-align:center;
	border:.5pt solid windowtext;}
.xl70
	{mso-style-parent:style0;
	font-weight:700;
	font-style:italic;}
.xl71
	{mso-style-parent:style0;
	font-weight:700;
	text-align:left;}
.xl72
	{mso-style-parent:style0;
	font-style:italic;}
.xl73
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl74
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
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
  int rec_count_all = 0;
  int rec_count_current = 0;
  int p_number = 0;
  String pnum = request.getParameter("PNUMBER");
  DecimalFormat decimalPlaces = new DecimalFormat("0000");
%>
<rw:foreach id="fi0" src="group_count">
  <rw:getValue id="j_rec_count" src="rec_count"/>
  <% rec_count_all = new Integer(j_rec_count).intValue(); %>
</rw:foreach>

<rw:getValue id="p_num" src="NUM"/>
<% p_number = new Integer(p_num).intValue(); %>


<body link=blue vlink=purple>

<table x:str border=0 cellpadding=0 cellspacing=0 width=741 style='border-collapse:
 collapse;width:557pt'>
 <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=28 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt'>Список<br>
    <rw:field id="" src="name_letter"/> (отправка с уведомлением)</td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl65 width=48 style='height:30.0pt;border-top:none;
  width:36pt'>№</td>
  <td class=xl65 width=60 style='border-top:none;border-left:none;width:62pt'>Исходящий номер</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страхователь</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Серия</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Номер</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Строка адреса</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Город</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Населенный пункт</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Район</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Область, республика</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страна</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Индекс</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Адрес Страхователя</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Программа</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата начала действия ДС</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Периодичность</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Валюта ответственности</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата последнего оплаченного ЭПГ</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата первого неоплаченного ЭПГ</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Оплачено</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сумма ЭПГ к оплате</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Из них оплачено</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Сумма задолженности</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата ЭПГ</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата расторжения</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ИДС договора</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Регион</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Действующий агент</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Руководитель агента/Менеджер</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Руководитель менеджера/Директор</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Статус последней версии</td>
  
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Contact_ID</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Вид сообщения</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Тип сообщения</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Тип реквизита</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Статус</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Описание</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Тема сообщения</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Дата регистрации</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Номер реестра</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Инициатор доставки</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Порядковый номер</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Комментарий</td>
  
 </tr>
 
 <rw:foreach id="fi2" src="group_data">
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl69 style='height:15.0pt;border-top:none'><rw:field id="" src="rec_number"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="vhnum"/>-<rw:field id="" src="P_MONTH"/>/<rw:field id="" src="P_YEAR"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="contact_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="pol_ser"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="pol_num"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fadr"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="city_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="distr_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="region_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="province_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="country_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="zip"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="address_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="product"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="start_date"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="payment_period"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fund"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="last_payd"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="first_unpayd"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="pay_amount"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="oplata"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="part_pay_amount"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="sum_zadol"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="plan_date"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="grace_period"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ids"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="code"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="agent_current"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="leader_agent"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="leader_manag"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="last_pol_status"></rw:field></td>
  
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'><rw:field id="" src="contact_id"></rw:field></td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Исходящий</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>письма за 30 дней</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Адрес</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Отправлен</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Очередной страховой взнос <rw:field id="" src="oplata"></rw:field>, задолженность по оплате предыдущих взносов <rw:field id="" src="sum_zadol"></rw:field> <rw:field id="" src="fund"></rw:field>, дата выставления платежа <rw:field id="" src="plan_date"></rw:field></td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>письмо 30 дн-напоминание об оплате</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'></td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'></td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'></td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'></td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'></td>
 </tr>
 
 </rw:foreach>
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=20 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=20 class=xl71 style='height:15.0pt'>Всего: <%=rec_count_current%></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=20 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=20 class=xl71 style='height:15.0pt'>Передал:
  ____________________/______________________________________</td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=20 class=xl71 style='height:15.0pt'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=20 class=xl71 style='height:15.0pt'>Принял:
  _____________________/______________________________________</td>
 </tr>
 <tr height=40 style='height:30.0pt;mso-xlrowspan:2'>
  <td height=40 colspan=20 style='height:30.0pt;mso-ignore:colspan'></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=48 style='width:36pt'></td>
  <td width=82 style='width:62pt'></td>
  <td width=87 style='width:65pt'></td>
  <td width=61 style='width:46pt'></td>
  <td width=84 style='width:63pt'></td>
  <td width=164 style='width:123pt'></td>
  <td width=110 style='width:83pt'></td>
  <td width=105 style='width:79pt'></td>
 </tr>
 <![endif]>
</table>

</body>

</html>


</rw:report>
