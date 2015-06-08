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
   <userParameter name="P_POLICY_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
       <dataSource name="Q_1">
      <select>
      <![CDATA[select
nvl((select sum(nvl(t.sum_fee,0)) fee_r
from tmp$_risk_name t
where t.ins_name is not null
      and t.sch = 'DELETED'),0) fee_fl,	  
to_char(nvl((select sum(nvl(t.risk1,0)+nvl(t.risk2,0)+nvl(t.risk3,0)+nvl(t.risk4,0)+nvl(t.risk5,0)+nvl(t.risk6,0)+nvl(t.risk7,0)+nvl(t.risk8,0)+nvl(t.risk9,0)+nvl(t.risk10,0)+nvl(t.risk11,0)) fee_r
from tmp$_risk_name t
where t.ins_name is not null
      and t.sch = 'DELETED'),0),'99999990D99') fee_r,
nvl((select sum(nvl(t.risk1,0)+nvl(t.risk2,0)+nvl(t.risk3,0)+nvl(t.risk4,0)+nvl(t.risk5,0)+nvl(t.risk6,0)+nvl(t.risk7,0)+nvl(t.risk8,0)+nvl(t.risk9,0)+nvl(t.risk10,0)+nvl(t.risk11,0)) fee_r
from tmp$_risk_name t
where t.ins_name is not null
      and t.sch = 'DELETED'),0) fee_r_j,
to_char(nvl((select sum(nvl(t.sum_fee,0)) fee_s
from tmp$_risk_name t
where t.ins_name is not null
      and t.sch = 'NEW'),0),'99999990D99') fee_a,
nvl((select sum(nvl(t.sum_fee,0)) fee_s
from tmp$_risk_name t
where t.ins_name is not null
      and t.sch = 'NEW'),0) fee_a_j,
to_char(nvl((select sum(nvl(t.sum_fee,0)) fee_s
from tmp$_risk_name t
where t.ins_name is not null
      and t.sch != 'DELETED'),0),'99999990D99') fee_s,
(select pol_num 
from p_policy pp,
     p_pol_header ph
where ph.policy_header_id = pp.pol_header_id
      and pp.policy_id = :P_POLICY_ID
      and rownum = 1) pol_num,
(select decode(trm.description,'Ежеквартально','квартальный','Единовременно','единовременный','Ежегодно','годовой','Раз в полгода','полугодовой','ежемесячный')
from p_policy pp,
     t_payment_terms trm
where pp.payment_term_id = trm.id
      and pp.policy_id = :P_POLICY_ID
      and rownum = 1) name1,
(select decode(trm.description,'Ежеквартально','за квартал','Единовременно','единовременно','Ежегодно','за год','Раз в полгода','за полугодие','за месяц')
from p_policy pp,
     t_payment_terms trm
where pp.payment_term_id = trm.id
      and pp.policy_id = :P_POLICY_ID
      and rownum = 1) name2  
from dual
]]>
      </select>
      <group name="group_count">
        <dataItem name="fee_fl"/>
      </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[
select
     t.ins_name,
       to_char(t.date_of_birth,'dd.mm.yyyy') date_of_birth,
       t.sex,      
     nvl(t.risk10,0) rrak,
     to_char(nvl(t.risk1,0),'99999990D99') risk1,
       to_char(nvl(t.risk2,0),'99999990D99') risk2,
       to_char(nvl(t.risk3,0),'99999990D99') risk3,
       to_char(nvl(t.risk4,0),'99999990D99') risk4,
       to_char(nvl(t.risk5,0),'99999990D99') risk5,
       to_char(nvl(t.risk6,0),'99999990D99') risk6,
       to_char(nvl(t.risk7,0),'99999990D99') risk7,
       to_char(nvl(t.risk8,0),'99999990D99') risk8,
       to_char(nvl(t.risk9,0),'99999990D99') risk9,
       to_char(nvl(t.risk10,0),'99999990D99') risk10,
     to_char(nvl(t.risk11,0),'99999990D99') risk11,
       to_char(nvl(t.srisk1,0),'99999990D99') srisk1,
       to_char(nvl(t.srisk2,0),'99999990D99') srisk2,
       to_char(nvl(t.srisk3,0),'99999990D99') srisk3,
       to_char(nvl(t.srisk4,0),'99999990D99') srisk4,
       to_char(nvl(t.srisk5,0),'99999990D99') srisk5,
       to_char(nvl(t.srisk6,0),'99999990D99') srisk6,
       to_char(nvl(t.srisk7,0),'99999990D99') srisk7,
       to_char(nvl(t.srisk8,0),'99999990D99') srisk8,
       to_char(nvl(t.srisk9,0),'99999990D99') srisk9,
       to_char(nvl(t.srisk10,0),'99999990D99')srisk10 ,
     to_char(nvl(t.srisk11,0),'99999990D99')srisk11 ,
     to_char(nvl(t.drisk1,0),'99999990D99') drisk1,
       to_char(nvl(t.drisk2,0),'99999990D99') drisk2,
       to_char(nvl(t.drisk3,0),'99999990D99') drisk3,
       to_char(nvl(t.drisk4,0),'99999990D99') drisk4,
       to_char(nvl(t.drisk5,0),'99999990D99') drisk5,
       to_char(nvl(t.drisk6,0),'99999990D99') drisk6,
       to_char(nvl(t.drisk7,0),'99999990D99') drisk7,
       to_char(nvl(t.drisk8,0),'99999990D99') drisk8,
       to_char(nvl(t.drisk9,0),'99999990D99') drisk9,
       to_char(nvl(t.drisk10,0),'99999990D99')drisk10,
     to_char(nvl(t.drisk11,0),'99999990D99')drisk11,
     to_char(nvl(t.sum_dfee,0),'99999990D99') sum_dfee,
       to_char(nvl(t.sum_fee,0),'99999990D99') sum_fee,
       to_char(t.start_date,'dd.mm.yyyy') start_date,
       to_char(t.end_date,'dd.mm.yyyy') end_date,
     decode(t.sch,'NEW','Включен','DELETED','Исключен','Действующий') chn,
	 
	--Чирков 141620 Разработка - Заявка на добавление полей в отчет
	(select pt.description
	from p_policy pp 
		 ,t_payment_terms pt     
	where pp.payment_term_id = pt.id
		  and pp.policy_id = :P_POLICY_ID     
		  and rownum = 1     
	) payment_terms_name,      
	(select f.brief
	 from p_policy pp 
		  ,p_pol_header ph 
		  ,fund f
	 where pp.pol_header_id = ph.policy_header_id
		   and f.fund_id = ph.fund_id
		   and pp.policy_id = :P_POLICY_ID     
	) fund_brief   
	--end_141620 Разработка - Заявка на добавление полей в отчет  		 
	from tmp$_risk_name t
	where t.ins_name is not null

	  
 ]]>
      </select>
      <group name="group_data">
        <dataItem name="rrak"/>
      </group>
    </dataSource>
	<dataSource name="Q_3">
      <select>
      <![CDATA[                         
select (select 1 from dual) fl_ag,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk1 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск1') nrisk1,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk2 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск2') nrisk2,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk3 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск3') nrisk3,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk4 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск4') nrisk4,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk5 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск5') nrisk5,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk6 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск6') nrisk6,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk7 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск7') nrisk7,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk8 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск8') nrisk8,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk9 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск9') nrisk9,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk10 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск10') nrisk10,
nvl((select l.description 
from t_prod_line_option opt,
     t_product_line l
where opt.id in (select n.risk11 from tmp$_risk_name n where n.ins_name is null)
      and l.id = opt.product_line_id),'Риск11') nrisk11 from dual]]>
      </select>
      <group name="group_risk">
        <dataItem name="fl_ag"/>
      </group>
    </dataSource>
	<dataSource name="Q_4">
      <select>
      <![CDATA[                         
select
    (select decode(max(paym),0,nvl(sum(decode((Df - Db + 1),0,0,round(Py / (Df - Db + 1) * (Df - Dc + 1),2))),0),nvl(sum(decode((Dsf - Dc + 1),0,0,round(Py / (Dsf - Dc + 1) * (Dsf - Db + 1),2))),0)) fee_a
    from
    (
    select (nvl(t.risk1,0)+nvl(t.risk2,0)+nvl(t.risk3,0)+nvl(t.risk4,0)+nvl(t.risk5,0)+nvl(t.risk6,0)+nvl(t.risk7,0)+nvl(t.risk8,0)+nvl(t.risk8,0)+nvl(t.risk10,0)+nvl(t.risk11,0)) Py,
    t.start_date Dc,
    t.end_date Dsf,
    (select t.pol_start_date
    from tmp$_risk_name t
    where t.ins_name is null) Db,
    (select t.pol_end_date
    from tmp$_risk_name t
    where t.ins_name is null) Df,
    (select case t.t_payment when 'Единовременно' then 0
                             else 1 end
    from tmp$_risk_name t
    where t.ins_name is null) paym
    from tmp$_risk_name t
    where t.ins_name is not null
          and t.sch = 'NEW')) fee_a_test,
      
      
(select decode(max(paym),0,nvl(sum(decode((Df - Db + 1),0,0,round(Py / (Df - Db + 1) * (Df - Dc),2))),0),nvl(sum(decode((Dsf - Dc + 1),0,0,round(Py / (Dsf - Dc + 1) * (Dsf - Db),2))),0)) fee_r
from
(
select (nvl(t.risk1,0)+nvl(t.risk2,0)+nvl(t.risk3,0)+nvl(t.risk4,0)+nvl(t.risk5,0)+nvl(t.risk6,0)+nvl(t.risk7,0)+nvl(t.risk8,0)+nvl(t.risk8,0)+nvl(t.risk10,0)+nvl(t.risk11,0)) Py,
t.start_date Dc,
t.end_date Dsf,
(select t.pol_start_date
from tmp$_risk_name t
where t.ins_name is null) Db,
(select t.pol_end_date
from tmp$_risk_name t
where t.ins_name is null) Df,
(select case t.t_payment when 'Единовременно' then 0
                         else 1 end
from tmp$_risk_name t
where t.ins_name is null) paym
from tmp$_risk_name t
where t.ins_name is not null
      and t.sch = 'DELETED')) fee_r_test from dual]]>
      </select>
      <group name="group_summa">
        <dataItem name="fee_a_test"/>
      </group>
    </dataSource>
	
	<dataSource name="Q_9">
      <select>
      <![CDATA[select sum(nvl(t.risk1,0)) r1,
       sum(nvl(t.risk2,0)) r2,
       sum(nvl(t.risk3,0)) r3,
       sum(nvl(t.risk4,0)) r4,
       sum(nvl(t.risk5,0)) r5,
       sum(nvl(t.risk6,0)) r6,
       sum(nvl(t.risk7,0)) r7,
       sum(nvl(t.risk8,0)) r8,
       sum(nvl(t.risk9,0)) r9,
       sum(nvl(t.risk10,0)) r10,
	   sum(nvl(t.risk11,0)) r11,
       min((select kol_risk 
        from tmp$_risk_name t
        where t.ins_name is null)) kol_risk
from tmp$_risk_name t
where t.ins_name is not null 
      and t.sch <> 'CURRENT']]>
      </select>
      <group name="group_flag">
        <dataItem name="kol_risk"/>
      </group>
    </dataSource>
	
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

declare
n number;
begin
n := pkg_ren_group.tmp_group_report(:P_POLICY_ID);
end;

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
	white-space:nowrap;
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
	white-space:nowrap;
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

<body link=blue vlink=purple>

<table x:str border=0 cellpadding=0 cellspacing=0 width=741 style='border-collapse:
 collapse;table-layout:fixed;width:557pt'>
 <col width=150 style='mso-width-source:userset;mso-width-alt:1755;width:150pt'>
 <col width=82 style='mso-width-source:userset;mso-width-alt:2998;width:62pt'>
 <col width=82 style='mso-width-source:userset;mso-width-alt:3181;width:65pt'>
 <col width=87 style='mso-width-source:userset;mso-width-alt:2230;width:65pt'>
 <col width=87 style='mso-width-source:userset;mso-width-alt:3072;width:65pt'>
 <col width=87 style='mso-width-source:userset;mso-width-alt:5997;width:80pt'>
 <col width=80 style='mso-width-source:userset;mso-width-alt:4022;width:62pt'>
 <col width=82 style='mso-width-source:userset;mso-width-alt:3840;width:62pt'>
 <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <rw:foreach id="fi0" src="group_count">
  <td colspan=26 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt'>Расчет сумм страховых премий по договору группового страхования № <rw:field id="" src="pol_num"/>
  </td>
  </tr>
  <rw:foreach id="fi9" src="group_flag">
  <rw:getValue id="j_flg" src="kol_risk"/>
  <rw:getValue id="j_flg1" src="r1"/>
  <rw:getValue id="j_flg2" src="r2"/>
  <rw:getValue id="j_flg3" src="r3"/>
  <rw:getValue id="j_flg4" src="r4"/>
  <rw:getValue id="j_flg5" src="r5"/>
  <rw:getValue id="j_flg6" src="r6"/>
  <rw:getValue id="j_flg7" src="r7"/>
  <rw:getValue id="j_flg8" src="r8"/>
  <rw:getValue id="j_flg9" src="r9"/>
  <rw:getValue id="j_flg10" src="r10"/>
  <rw:getValue id="j_flg011" src="r11"/>

 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl65 rowspan=2 width=150 style='height:30.0pt;border-top:none;width:150pt'>Фио Застрахованного</td>
  <td class=xl65 width=82 rowspan=2 style='border-top:none;border-left:none;width:62pt'>Дата рождения Застрахованного</td>
  <td class=xl65 width=87 rowspan=2 style='border-top:none;border-left:none;width:65pt'>Пол Застрахованного</td>
  <td class=xl65 width=87 rowspan=2 style='border-top:none;border-left:none;width:65pt'>Периодичность оплаты</td>  
  <td class=xl65 width=87 rowspan=2 style='border-top:none;border-left:none;width:65pt'>Валюта ответственности</td>    
  <td class=xl65 width=97 rowspan=2 style='border-top:none;border-left:none;width:75pt'>Включение/Исключение</td>
  <% if (j_flg.equals("11")) { %>
  <td class=xl65 width=87 colspan=11 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td> <% } %>
  <% if (j_flg.equals("10")) { %>
  <td class=xl65 width=87 colspan=10 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td> <% } %>
  <% if (j_flg.equals("9")) { %>
  <td class=xl65 width=87 colspan=9 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td> <% } %>
  <% if (j_flg.equals("8")) { %>
  <td class=xl65 width=87 colspan=8 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td><% } %>
  <% if (j_flg.equals("7")) { %>
  <td class=xl65 width=87 colspan=7 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td><% } %>
  <% if (j_flg.equals("6")) { %>
  <td class=xl65 width=87 colspan=6 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td><% } %>
  <% if (j_flg.equals("5")) { %>
  <td class=xl65 width=87 colspan=5 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td><% } %>
  <% if (j_flg.equals("4")) { %>
  <td class=xl65 width=87 colspan=4 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td><% }%>
  <% if (j_flg.equals("3")) { %>
  <td class=xl65 width=87 colspan=3 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td><% } %>
  <% if (j_flg.equals("2")) { %>
  <td class=xl65 width=87 colspan=2 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td><% }  %>
  <% if (j_flg.equals("1")) { %>
  <td class=xl65 width=87 style='border-top:none;border-left:none;width:65pt'>Страховые суммы</td><% } %>
  
  <% if (j_flg.equals("11")) { %>
  <td class=xl65 width=87 colspan=110 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td> <% } %>
  <% if (j_flg.equals("10")) { %>
  <td class=xl65 width=87 colspan=10 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td> <% } %>
  <% if (j_flg.equals("9")) { %>
  <td class=xl65 width=87 colspan=9 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td> <% } %>
  <% if (j_flg.equals("8")) { %>
  <td class=xl65 width=87 colspan=8 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td><% } %>
  <% if (j_flg.equals("7")) { %>
  <td class=xl65 width=87 colspan=7 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td><% } %>
  <% if (j_flg.equals("6")) { %>
  <td class=xl65 width=87 colspan=6 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td><% } %>
  <% if (j_flg.equals("5")) { %>
  <td class=xl65 width=87 colspan=5 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td><% } %>
  <% if (j_flg.equals("4")) { %>
  <td class=xl65 width=87 colspan=4 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td><% }%>
  <% if (j_flg.equals("3")) { %>
  <td class=xl65 width=87 colspan=3 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td><% } %>
  <% if (j_flg.equals("2")) { %>
  <td class=xl65 width=87 colspan=2 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td><% }  %>
  <% if (j_flg.equals("1")) { %>
  <td class=xl65 width=87 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) к доплате (возврату) <rw:field id="" src="name2"/></td><% } %>
  
  <td class=xl65 width=80 rowspan=2 style='border-top:none;border-left:none;width:80pt'>Итого страховой взнос (премия) к доплате (возврату) <rw:field id="" src="name2"/></td>
  
  <% if (j_flg.equals("11")) { %>
  <td class=xl65 width=87 colspan=11 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td> <% } %>
  <% if (j_flg.equals("10")) { %>
  <td class=xl65 width=87 colspan=10 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td> <% } %>
  <% if (j_flg.equals("9")) { %>
  <td class=xl65 width=87 colspan=9 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td> <% } %>
  <% if (j_flg.equals("8")) { %>
  <td class=xl65 width=87 colspan=8 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td><% } %>
  <% if (j_flg.equals("7")) { %>
  <td class=xl65 width=87 colspan=7 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td><% } %>
  <% if (j_flg.equals("6")) { %>
  <td class=xl65 width=87 colspan=6 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td><% } %>
  <% if (j_flg.equals("5")) { %>
  <td class=xl65 width=87 colspan=5 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td><% } %>
  <% if (j_flg.equals("4")) { %>
  <td class=xl65 width=87 colspan=4 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td><% }%>
  <% if (j_flg.equals("3")) { %>
  <td class=xl65 width=87 colspan=3 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td><% } %>
  <% if (j_flg.equals("2")) { %>
  <td class=xl65 width=87 colspan=2 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td><% }  %>
  <% if (j_flg.equals("1")) { %>
  <td class=xl65 width=87 style='border-top:none;border-left:none;width:65pt'>Страховой взнос (страховые премии) <rw:field id="" src="name1"/></td><% } %>

  <td class=xl65 width=80 rowspan=2 style='border-top:none;border-left:none;width:80pt'>Итого страховой взнос (премия) <rw:field id="" src="name1"/></td>
  <td class=xl65 width=82 rowspan=2 style='border-top:none;border-left:none;width:62pt'>Дата начала срока страхования</td>
  <td class=xl65 width=82 rowspan=2 style='border-top:none;border-left:none;width:62pt'>Дата окончания срока страхования</td>
  <tr>
  <rw:foreach id="fi5" src="group_risk">
  <% if (!j_flg1.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk1"/></td>  <% } else { %><% } %>
  <% if (!j_flg2.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk2"/></td>  <% } else { %><% } %>
  <% if (!j_flg3.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk3"/></td>  <% } else { %><% } %>
  <% if (!j_flg4.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk4"/></td>  <% } else { %><% } %>
  <% if (!j_flg5.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk5"/></td>  <% } else { %><% } %>
  <% if (!j_flg6.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk6"/></td>  <% } else { %><% } %>
  <% if (!j_flg7.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk7"/></td>  <% } else { %><% } %>
  <% if (!j_flg8.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk8"/></td>  <% } else { %><% } %>
  <% if (!j_flg9.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'><rw:field id="" src="nrisk9"/></td>  <% } else { %><% } %>
  <% if (!j_flg10.equals("0")) { %>
  <td class=xl65 width=65 style='border-top:none;border-left:none;width:52pt'><rw:field id="" src="nrisk10"/></td>  <% } else { %><% } %>
  <% if (!j_flg011.equals("0")) { %>
  <td class=xl65 width=65 style='border-top:none;border-left:none;width:52pt'><rw:field id="" src="nrisk11"/></td>  <% } else { %><% } %>
  
  <% if (!j_flg1.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk1"/></td>  <% } else { %><% } %>
  <% if (!j_flg2.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk2"/></td>  <% } else { %><% } %>
  <% if (!j_flg3.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk3"/></td>  <% } else { %><% } %>
  <% if (!j_flg4.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk4"/></td>  <% } else { %><% } %>
  <% if (!j_flg5.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk5"/></td>  <% } else { %><% } %>
  <% if (!j_flg6.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk6"/></td>  <% } else { %><% } %>
  <% if (!j_flg7.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk7"/></td>  <% } else { %><% } %>
  <% if (!j_flg8.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk8"/></td>  <% } else { %><% } %>
  <% if (!j_flg9.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk9"/></td>  <% } else { %><% } %>
  <% if (!j_flg10.equals("0")) { %>
  <td class=xl65 width=65 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk10"/></td>  <% } else { %><% } %>
  <% if (!j_flg011.equals("0")) { %>
  <td class=xl65 width=65 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk11"/></td>  <% } else { %><% } %>
  
  <% if (!j_flg1.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk1"/></td>  <% } else { %><% } %>
  <% if (!j_flg2.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk2"/></td>  <% } else { %><% } %>
  <% if (!j_flg3.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk3"/></td>  <% } else { %><% } %>
  <% if (!j_flg4.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk4"/></td>  <% } else { %><% } %>
  <% if (!j_flg5.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk5"/></td>  <% } else { %><% } %>
  <% if (!j_flg6.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk6"/></td>  <% } else { %><% } %>
  <% if (!j_flg7.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk7"/></td>  <% } else { %><% } %>
  <% if (!j_flg8.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk8"/></td>  <% } else { %><% } %>
  <% if (!j_flg9.equals("0")) { %>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk9"/></td>  <% } else { %><% } %>
  <% if (!j_flg10.equals("0")) { %>
  <td class=xl65 width=65 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk10"/></td>  <% } else { %><% } %>
  <% if (!j_flg011.equals("0")) { %>
  <td class=xl65 width=65 style='border-top:none;border-left:none;width:80pt'><rw:field id="" src="nrisk11"/></td>  <% } else { %><% } %>
  
  </rw:foreach>
  </rw:foreach>
  </rw:foreach>
  </tr>
  </tr>
 
 <rw:foreach id="fi19" src="group_flag">
  <rw:getValue id="j_flg11" src="r1"/>
  <rw:getValue id="j_flg21" src="r2"/>
  <rw:getValue id="j_flg31" src="r3"/>
  <rw:getValue id="j_flg41" src="r4"/>
  <rw:getValue id="j_flg51" src="r5"/>
  <rw:getValue id="j_flg61" src="r6"/>
  <rw:getValue id="j_flg71" src="r7"/>
  <rw:getValue id="j_flg81" src="r8"/>
  <rw:getValue id="j_flg91" src="r9"/>
  <rw:getValue id="j_flg101" src="r10"/>
  <rw:getValue id="j_flg111" src="r11"/>
  
 <rw:foreach id="fi2" src="group_data">
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl69 style='height:15.0pt;border-top:none'><rw:field id="" src="ins_name"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="date_of_birth"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="sex"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="payment_terms_name"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fund_brief"/></td>  
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="chn"/></td>
  <% if (!j_flg11.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk1"/></td> <% } else { %><% } %>
  <% if (!j_flg21.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk2"/></td> <% } else { %><% } %>
  <% if (!j_flg31.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk3"/></td> <% } else { %><% } %>
  <% if (!j_flg41.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk4"/></td> <% } else { %><% } %>
  <% if (!j_flg51.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk5"/></td> <% } else { %><% } %>
  <% if (!j_flg61.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk6"/></td> <% } else { %><% } %>
  <% if (!j_flg71.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk7"/></td> <% } else { %><% } %>
  <% if (!j_flg81.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk8"/></td> <% } else { %><% } %>
  <% if (!j_flg91.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk9"/></td> <% } else { %><% } %>
  <% if (!j_flg101.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk10"/></td> <% } else { %><% } %>
  <% if (!j_flg111.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="srisk11"/></td> <% } else { %><% } %>
  
  <% if (!j_flg11.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk1"/></td> <% } else { %><% } %>
  <% if (!j_flg21.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk2"/></td><% } else { %><% } %>
  <% if (!j_flg31.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk3"/></td><% } else { %><% } %>
  <% if (!j_flg41.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk4"/></td><% } else { %><% } %>
  <% if (!j_flg51.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk5"/></td><% } else { %><% } %>
  <% if (!j_flg61.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk6"/></td><% } else { %><% } %>
  <% if (!j_flg71.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk7"/></td><% } else { %><% } %>
  <% if (!j_flg81.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk8"/></td><% } else { %><% } %>
  <% if (!j_flg91.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk9"/></td><% } else { %><% } %>
  <% if (!j_flg101.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk10"/></td><% } else { %><% } %>
  <% if (!j_flg111.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="drisk11"/></td><% } else { %><% } %>

  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="sum_dfee"/></td>
  
  <% if (!j_flg11.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk1"/></td><% } else { %><% } %>
  <% if (!j_flg21.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk2"/></td><% } else { %><% } %>
  <% if (!j_flg31.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk3"/></td><% } else { %><% } %>
  <% if (!j_flg41.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk4"/></td><% } else { %><% } %>
  <% if (!j_flg51.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk5"/></td><% } else { %><% } %>
  <% if (!j_flg61.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk6"/></td><% } else { %><% } %>
  <% if (!j_flg71.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk7"/></td><% } else { %><% } %>
  <% if (!j_flg81.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk8"/></td><% } else { %><% } %>
  <% if (!j_flg91.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk9"/></td><% } else { %><% } %>
  <% if (!j_flg101.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk10"/></td><% } else { %><% } %>
  <% if (!j_flg111.equals("0")) { %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="risk11"/></td><% } else { %><% } %>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="sum_fee"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="start_date"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="end_date"/></td>
 </tr>
 
 </rw:foreach>
 </rw:foreach>
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=8 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl70 style='height:15.0pt'
  </td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=8 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <rw:foreach id="fi1" src="group_count">
 <rw:foreach id="fi8" src="group_summa">
 <rw:getValue id="j_fee_a" src="fee_a_j"/>
 <rw:getValue id="j_fee_r" src="fee_r_J"/>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 colspan=6 style='height:15.0pt;mso-ignore:colspan'>Итого премия по договору группового 
  страхования №<rw:field id="" src="pol_num"/> составляет <rw:field id="" src="fee_s"/>.</td>
  <td colspan=2 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 style='height:15.0pt'></td>
  <td colspan=7 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <% if (!j_fee_a.equals("0")) { %>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 colspan=6 style='height:15.0pt;mso-ignore:colspan'>Итого сумма страховой премии (сумма взносов включенных без применения формулы из приказа), 
  подлежащей к доплате Страховщику по договору группового страхования №<rw:field id="" src="pol_num"/>, составляет <rw:field id="" src="fee_a"/>.</td>
  <td colspan=2 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 colspan=6 style='height:15.0pt;mso-ignore:colspan'></td>
  <td colspan=2 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <% } else { %><% } %>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl72 style='height:15.0pt'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <% if (!j_fee_r.equals("0")) { %>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 colspan=6 style='height:15.0pt;mso-ignore:colspan'>Итого сумма страховой премии (сумма взносов исключенных без применения формулы из приказа), 
  подлежащей к возврату Страховщику по договору группового страхования №<rw:field id="" src="pol_num"/>, составляет <rw:field id="" src="fee_r"/>.</td>
  <td colspan=2 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 colspan=6 style='height:15.0pt;mso-ignore:colspan'></td>
  <td colspan=2 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <% } else { %><% } %>
 <tr height=40 style='height:30.0pt;mso-xlrowspan:2'>
  <td height=40 colspan=8 style='height:30.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl72 style='height:15.0pt'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 </rw:foreach>
 </rw:foreach>
 
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
