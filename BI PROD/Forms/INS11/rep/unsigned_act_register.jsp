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
   <userParameter name="P_LOAD_FILE_ID"/>
   <userParameter name="p_position_name" datatype="character" width="200"
    defaultWidth="0" defaultHeight="0"/>
   <userParameter name="p_case_signer_name" datatype="character" width="200"
    defaultWidth="0" defaultHeight="0"/>
      <dataSource name="Q_1">
      <select>
      <![CDATA[
SELECT ROWNUM
      ,t.*
  FROM (SELECT DECODE(cd.is_subtotal, 1, dense_rank() over(ORDER BY cd.load_file_rows_id), NULL) rn
              ,DECODE(cd.is_subtotal, 1, to_char(ph.ids), NULL) ids
              ,DECODE(cd.is_subtotal, 1, d.num, NULL) num
              ,DECODE(cd.is_subtotal, 1, pf.t_policy_form_short_name, NULL) policyform
              ,DECODE(cd.is_subtotal, 1, c2.obj_name_orig, NULL) issuer_name
              ,DECODE(cd.is_subtotal, 1, dr.name, NULL) decline_reason
              ,DECODE(cd.is_subtotal, 1, TO_CHAR(ph.start_date, 'DD.MM.RRRR'), NULL) start_date
              ,DECODE(cd.is_subtotal, 1, TO_CHAR(pp.decline_date, 'DD.MM.RRRR'), NULL) decline_date
              ,DECODE(cd.is_subtotal, 1, pt.description, NULL) payment_term
              ,DECODE(cd.is_subtotal, 1, pd.reg_code, NULL) region_code
              ,DECODE(cd.is_subtotal, 1, TO_CHAR(pd.act_date, 'DD.MM.RRRR'), NULL) act_date
              ,DECODE(cd.is_subtotal, 1, f.name, NULL) fund
              ,DECODE(cd.is_subtotal, 1, NVL(pd.management_expenses, 0), NULL) management_expenses
              ,DECODE(cd.is_subtotal, 1, NVL(pd.issuer_return_sum, 0), NULL) issuer_return_sum
              ,DECODE(cd.is_subtotal, 1, NVL(pd.overpayment, 0) - NVL(pp.debt_summ, 0), NULL) saldo
              ,DECODE(cd.is_subtotal, 1, NVL(pd.medo_cost, 0), NULL) medo_cost
              ,DECODE(cd.is_subtotal
                     ,1
                     ,NVL(pd.issuer_return_sum, 0) + NVL(pd.overpayment, 0) - NVL(pp.debt_summ, 0) -
                      NVL(pd.medo_cost, 0) - NVL(pd.admin_expenses, 0)
                     ,NULL) return_sum
              ,DECODE(cd.is_subtotal, 1, c.obj_name_orig, NULL) assured_name
              ,cd.product_line_name
              ,cd.cover_period
              ,cd.redemption_sum
              ,cd.add_invest_income
              ,cd.return_bonus_part
              ,cd.bonus_off_prev
              ,cd.bonus_off_corrent
              ,cd.is_subtotal
              ,cd.load_file_rows_id
          FROM p_pol_header ph
              ,p_policy pp
              ,t_policy_form pf
              ,t_policyform_product pfp
              ,p_pol_decline pd
              ,p_policy_contact pc
              ,t_decline_reason dr
              ,t_illegal_decline il
              ,t_payment_terms pt
              ,contact c
              ,contact c2
              ,fund f
              ,as_assured aas
              ,document d
              ,doc_status_ref dsr
              ,(SELECT pd1.p_pol_decline_id
                      ,cd1.as_asset_id
                      ,lfr.load_file_rows_id
                      ,DECODE(GROUPING(pl1.description)
                             ,1
                             ,'Итого по рискам'
                             ,pl1.description) product_line_name
                      ,DECODE(GROUPING(pl1.description), 1, NULL, cd1.cover_period) cover_period
                      ,NVL(SUM(cd1.redemption_sum), 0) redemption_sum
                      ,NVL(SUM(cd1.add_invest_income), 0) add_invest_income
                      ,NVL(SUM(cd1.return_bonus_part), 0) return_bonus_part
                      ,NVL(SUM(cd1.bonus_off_prev), 0) bonus_off_prev
                      ,NVL(SUM(cd1.bonus_off_current), 0) bonus_off_corrent
                      ,GROUPING(pl1.description) grouping_by_as_asset
                      ,GROUPING(cd1.cover_period) grouping_by_cover_period
                      ,DECODE(grouping_id(pl1.description, cd1.cover_period), 0, 0, 1) is_subtotal
                  FROM p_policy        pp1
                      ,p_pol_decline   pd1
                      ,p_cover_decline cd1
                      ,t_product_line  pl1
                      ,p_pol_header    ph1
                      ,load_file       lf
                      ,load_file_rows  lfr
                      ,document        d
                      ,doc_status_ref  dsr
                 WHERE pp1.policy_id = pd1.p_policy_id
                   AND pd1.p_pol_decline_id = cd1.p_pol_decline_id
                   AND cd1.t_product_line_id = pl1.id
                   AND pp1.pol_header_id = ph1.policy_header_id
                   AND lf.load_file_id = :P_LOAD_FILE_ID
                   AND lfr.load_file_id = lf.load_file_id
                   AND TRIM(lfr.val_1) = TO_CHAR(ph1.ids)
                   AND pp1.policy_id = d.document_id
                   AND d.doc_status_ref_id = dsr.doc_status_ref_id
                   AND dsr.brief IN ('QUIT', 'TO_QUIT','TO_QUIT_CHECK_READY','TO_QUIT_CHECKED','QUIT_REQ_QUERY','QUIT_REQ_GET','QUIT_TO_PAY')
                   AND pp1.policy_id = (SELECT MAX(policy_id)
                                          FROM p_policy       pp2
                                              ,document       d2
                                              ,doc_status_ref dsr2
                                         WHERE pp2.pol_header_id = pp1.pol_header_id
                                           AND pp2.policy_id = d2.document_id
                                           AND d2.doc_status_ref_id = dsr2.doc_status_ref_id
                                           AND dsr2.brief IN ('QUIT', 'TO_QUIT','TO_QUIT_CHECK_READY','TO_QUIT_CHECKED','QUIT_REQ_QUERY','QUIT_REQ_GET','QUIT_TO_PAY'))
                --AND ph1.ids = 1910094394
                 GROUP BY pd1.p_pol_decline_id
                         ,cd1.as_asset_id
                         ,ROLLUP(lfr.load_file_rows_id, pl1.description, cd1.cover_period)
                HAVING grouping_id(lfr.load_file_rows_id, pl1.description, cd1.cover_period) NOT IN(1
                                                                                                  ,7)) cd
         WHERE cd.p_pol_decline_id = pd.p_pol_decline_id
           AND pd.p_policy_id = pp.policy_id
           AND pp.pol_header_id = ph.policy_header_id
           AND cd.as_asset_id = aas.as_assured_id
           AND c.contact_id = aas.assured_contact_id
           AND pp.decline_reason_id = dr.t_decline_reason_id(+)
           AND pd.t_illegal_decline_id = il.t_illegal_decline_id(+)
           AND pp.payment_term_id = pt.id
           AND pp.policy_id = d.document_id
           AND d.doc_status_ref_id = dsr.doc_status_ref_id
           AND pp.policy_id = pc.policy_id
           AND pc.contact_policy_role_id = 6 -- Страхователь
           AND pc.contact_id = c2.contact_id
           AND ph.fund_id = f.fund_id
           AND pp.t_product_conds_id = pfp.t_policyform_product_id
           AND pfp.t_policy_form_id = pf.t_policy_form_id
         ORDER BY load_file_rows_id
                 ,c.obj_name
                 ,cd.is_subtotal DESC) t

	   
	   ]]>
      </select>
      <group name="group_data">
        <dataItem name="rn"/>
      </group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
v_report_id NUMBER;
v_position_name VARCHAR2(2000);
v_case_signer_name VARCHAR2(255);
begin

BEGIN
	SELECT r.rep_report_id
	INTO v_report_id
	FROM ins.rep_report r
	WHERE r.exe_name = 'ins11/unsigned_act_register.jsp';
EXCEPTION WHEN NO_DATA_FOUND THEN
	v_report_id := 0;
END;

BEGIN
	SELECT jp.position_name
	INTO v_position_name
	FROM ins.t_job_position jp
	WHERE jp.dep_brief = 'ЗАМ_ОПЕРУ'
	  AND jp.is_enabled = 1;
EXCEPTION WHEN NO_DATA_FOUND THEN
	v_position_name := '';
END;

BEGIN
  SELECT pkg_contact.get_fio_fmt(s.contact_name,4)
  INTO v_case_signer_name
	FROM ins.t_report_signer sg,
	     ins.t_job_position jp,
         ins.t_signer s
	WHERE s.job_position_id = jp.t_job_position_id
	  AND jp.dep_brief = 'ЗАМ_ОПЕРУ'
	  AND jp.is_enabled = 1
      AND s.t_signer_id = sg.t_signer_id
	  AND sg.report_id = v_report_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
	v_case_signer_name := '';
END;

:p_position_name := v_position_name;
:p_case_signer_name := v_case_signer_name;

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
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:7.0pt;
	mso-bidi-font-size:6.0pt;
	font-family:"Garamond","serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
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
	white-space:nowrap;
	mso-rotate:0;
	mso-background-source:auto;
	mso-pattern:auto;
	color:black;
	font-size:6.0pt;
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
	font-size:5.0pt;
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
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:silver;
	mso-pattern:auto none;
	white-space:nowrap;}
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
	text-align:center;
	border:.5pt solid windowtext;
	white-space:nowrap;}
.xl71
	{mso-style-parent:style0;
	font-weight:700;
	text-align:left;}
.xl72
	{mso-style-parent:style0;
	font-style:italic;}
.xl73
	{mso-style-parent:style0;
	font-size:9.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:none;
	border-left:none;
	white-space:normal;}
.xl74
	{mso-style-parent:style0;
	font-size:9.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl75
	{mso-style-parent:style0;
	text-align:right;
	border:none;}
.xl76
	{mso-style-parent:style0;
	text-align:center;
	border:none;
	font-size:6.0pt;}
.xl77
	{mso-style-parent:style0;
	text-align:center;
	border:none;}
.xl79
	{border:.5pt solid windowtext;}
.xl80
	{border-left:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-top:none;
	border-bottom:1.5pt solit windowstext;}
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
  
<body link=blue vlink=purple>
<table border=0 cellpadding=0 cellspacing=0 width=400 style='border-collapse:collapse;table-layout:fixed;width:400pt'>
 <col width=21 style='mso-width-source:userset;mso-width-alt:800;width:16pt'>
 <col width=77 style='mso-width-source:userset;mso-width-alt:3000;width:30pt'>
 <col width=77 style='mso-width-source:userset;mso-width-alt:3000;width:30pt'>
 <col width=213 style='mso-width-source:userset;mso-width-alt:3000;width:160pt'>
 <col width=174 style='mso-width-source:userset;mso-width-alt:3000;width:131pt'>
 <col width=79 style='mso-width-source:userset;mso-width-alt:2700;width:59pt'>
 <col width=76 style='mso-width-source:userset;mso-width-alt:2700;width:57pt'>
 <col width=108 style='mso-width-source:userset;mso-width-alt:3000;width:81pt'>
 <col width=112 style='mso-width-source:userset;mso-width-alt:2700;width:84pt'>
 <col width=26 style='mso-width-source:userset;mso-width-alt:950;width:20pt'>
 <col width=69 style='mso-width-source:userset;mso-width-alt:2700;width:52pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:1200;width:83pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:1800;width:38pt'>
 <col width=64 style='mso-width-source:userset;mso-width-alt:2350;width:48pt'>
 <col width=52 span=2 style='mso-width-source:userset;mso-width-alt:1900;width:39pt'>
 <col width=72 style='mso-width-source:userset;mso-width-alt:2650;width:54pt'>
 <col width=213 style='mso-width-source:userset;mso-width-alt:3000;width:160pt'>
 <col width=181 style='mso-width-source:userset;mso-width-alt:6000;width:146pt'>
 <col width=38 style='mso-width-source:userset;mso-width-alt:1400;width:29pt'>
 <col width=60 style='mso-width-source:userset;mso-width-alt:2200;width:45pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:1800;width:38pt'>
 <col width=52 style='mso-width-source:userset;mso-width-alt:1900;width:39pt'>
 <col width=66 style='mso-width-source:userset;mso-width-alt:2400;width:50pt'>
 <col width=58 style='mso-width-source:userset;mso-width-alt:2100;width:44pt'>
 <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=25 height=62 class=xl73 width=1200 style='height:46.5pt;width:400pt'>Реестр актов о признании договоров незаключенными</td>
 </tr>
 <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=25 height=62 class=xl73 width=1200 style='height:46.5pt;width:400pt'></td>
 </tr> 
  
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 style='border-top:none;border-left:none'>№</td>
  <td class=xl65 style='border-top:none;border-left:none'>ИДС</td>
  <td class=xl65 style='border-top:none;border-left:none'>Номер договора</td>
  <td class=xl65 style='border-top:none;border-left:none'>Страхователь</td>
  <td class=xl65 style='border-top:none;border-left:none'>Причина расторжения</td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;'>Дата начала договора</td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;'>Дата расторжения</td>
  <td class=xl65 style='border-top:none;border-left:none'>Периодичность уплаты взноса</td>
  <td class=xl65 style='border-top:none;border-left:none'>Полисные условия</td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;width:30pt;'>Код региона</td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;'>Дата акта</td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;width:30pt;'>Валюта</td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;'>Расходы на ведение дела (в целом по договору) </td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;'>Сумма к возврату (в целом по договору)</td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;'>-Недоплата/ +Переплата</td>
  <td width=50 class=xl65 style='border-top:none;border-left:none;'>МЕДО  (в целом по договору)</td>
  <td width=50 width=50 class=xl65 style='border-top:none;border-left:none;'>К перечислению Страхователю  (в целом по договору)</td>
  <td class=xl65 style='border-top:none;border-left:none'>Застрахованный</td>
  <td class=xl65 style='border-top:none;border-left:none'>Риски</td>
  <td width=50 class=xl65 style='width:50pt;border-top:none;border-left:none;'>Срок страхования</td>
  <td width=50 class=xl65 style='width:50pt;border-top:none;border-left:none;'>Выкупная сумма</td>
  <td width=50 class=xl65 style='width:50pt;border-top:none;border-left:none;'>ДИД</td>
  <td width=50 class=xl65 style='width:50pt;border-top:none;border-left:none;'>Возврат части премии/платежа</td>
  <td width=50 class=xl65 style='width:50pt;border-top:none;border-left:none;'>Начисленная премия к списанию прошлых лет</td>
  <td width=50 class=xl65 style='width:50pt;border-top:none;border-left:none;'>Начисленная премия к списанию текущего года</td> </tr>
  
 <rw:foreach id="fi1" src="group_data">
 
 <tr>
  <rw:getValue id="bord" src="is_subtotal"/>

  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;'<%}%>><rw:field id="" src="rn"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;'<%}%>><rw:field id="" src="ids"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;'<%}%>><rw:field id="" src="num"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;'<%}%>><rw:field id="" src="issuer_name"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;'<%}%>><rw:field id="" src="decline_reason"/></td>
  <td width=50 <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;mso-number-format:"dd\/mm\/yyyy";'<%}%>><rw:field id="" src="start_date"/></td>
  <td width=50 <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;mso-number-format:"dd\/mm\/yyyy";'<%}%>><rw:field id="" src="decline_date"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;'<%}%>><rw:field id="" src="payment_term"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;'<%}%>><rw:field id="" src="policyform"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;width:30pt;'<%}%>><rw:field id="" src="region_code"/></td>
  <td width=50 <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;mso-number-format:"dd\/mm\/yyyy";'<%}%>><rw:field id="" src="act_date"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;width:30pt;'<%}%>><rw:field id="" src="fund"/></td>
  <td width=50 <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;mso-number-format:"0\.00";'<%}%>><rw:field id="" src="management_expenses"/></td>
  <td width=50 <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;mso-number-format:"0\.00";'<%}%>><rw:field id="" src="issuer_return_sum"/></td>
  <td width=50 <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;mso-number-format:"0\.00";'<%}%>><rw:field id="" src="saldo"/></td>
  <td width=50 <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;mso-number-format:"0\.00";'<%}%>><rw:field id="" src="medo_cost"/></td>
  <td width=50 <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;mso-number-format:"0\.00";'<%}%>><rw:field id="" src="return_sum"/></td>
  <td <% if (bord.equals("1")) {%>style='border:.5pt solid windowtext;'<%}%>><rw:field id="" src="assured_name"/></td>
  <td style='border:.5pt solid windowtext;<% if (bord.equals("1")) {%>font-weight:bolder;<%}%>'><rw:field id="" src="product_line_name"/></td>
  <td width=50 style='width:50pt;border:.5pt solid windowtext;mso-number-format:"0\.00";<% if (bord.equals("1")) {%>font-weight:bolder;<%}%>'><rw:field id="" src="cover_period"/></td>
  <td width=50 style='width:50pt;border:.5pt solid windowtext;mso-number-format:"0\.00";<% if (bord.equals("1")) {%>font-weight:bolder;<%}%>'><rw:field id="" src="redemption_sum"/></td>
  <td width=50 style='width:50pt;border:.5pt solid windowtext;mso-number-format:"0\.00";<% if (bord.equals("1")) {%>font-weight:bolder;<%}%>'><rw:field id="" src="add_invest_income"/></td>
  <td width=50 style='width:50pt;border:.5pt solid windowtext;mso-number-format:"0\.00";<% if (bord.equals("1")) {%>font-weight:bolder;<%}%>'><rw:field id="" src="return_bonus_part"/></td>
  <td width=50 style='width:50pt;border:.5pt solid windowtext;mso-number-format:"0\.00";<% if (bord.equals("1")) {%>font-weight:bolder;<%}%>'><rw:field id="" src="bonus_off_prev"/></td>
  <td width=50 style='width:50pt;border:.5pt solid windowtext;mso-number-format:"0\.00";<% if (bord.equals("1")) {%>font-weight:bolder;<%}%>'><rw:field id="" src="bonus_off_corrent"/></td>
 </tr>
 
 </rw:foreach>
<tr>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
</tr>
<tr>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td colspan=4 style='text-align:right;'>Подпись:</td>
  <td colspan=3 style='border-bottom:.5pt solid windowtext;'></td>
  <td></td><td></td><td></td>
</tr>
<tr>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td colspan=4 style='text-align:right;'><rw:field id="" src="p_case_signer_name"/>, <rw:field id="" src="p_position_name"/></td>
  <td></td><td></td><td></td><td></td><td></td><td></td>
</tr>
<tr>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  
</tr>
<tr>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td colspan=4 style='text-align:right;'>Подготовлено:</td>
  <td colspan=3 style='border-bottom:.5pt solid windowtext;'></td>
  <td colspan=2>Специалист ОИУД</td><td></td>
</tr>
<tr>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
</tr>
<tr>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td></td><td></td><td></td><td></td><td></td>
  <td colspan=4 style='text-align:right;'>Проверено:</td>
  <td colspan=3 style='border-bottom:.5pt solid windowtext;'></td>
  <td colspan=2>Начальник ОИУД</td><td></td>
</tr>	
 </table>

</body>

</html>


</rw:report>
