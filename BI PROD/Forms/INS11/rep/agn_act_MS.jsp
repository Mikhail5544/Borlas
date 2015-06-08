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
    <userParameter name="P_DEPT_ID"/>
	<userParameter name="DEPT" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_DEPT_NAME"/>
	<userParameter name="PAR_DATE" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="P_DATE_BEGIN" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="REP_DATE" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
       <dataSource name="Q_1">
      <select>
      <![CDATA[select count(*) OVER (order by dep.name) rn, 
       mch,
       mdep,
       mnum,
       mname,
       mcat,
       mfnum,
       mfname,
       mfcat,
       mrnum,
       mrname,
       mrcat,
       ch.description ach,
       dep.name adep,
       d.num anum,
       c.obj_name_orig aname,
       cat.category_name acat,
       fnum,
       fname,
       fcat,
       rnum,
       rname,
       rcat

from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     
     (select d.num fnum,
             c.obj_name_orig fname,
             cat.category_name fcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
		   ag_contract acf,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
			 and acf.contract_id = agh.ag_contract_header_id
             and to_date(:PAR_DATE,'dd.mm.yyyy') BETWEEN acf.date_begin and acf.date_end
             and acf.category_id = cat.ag_category_agent_id) fleader,
      (select d.num rnum,
             c.obj_name_orig rname,
             cat.category_name rcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
		   ag_contract acf,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
			 and acf.contract_id = agh.ag_contract_header_id
             and to_date(:PAR_DATE,'dd.mm.yyyy') BETWEEN acf.date_begin and acf.date_end
             and acf.category_id = cat.ag_category_agent_id) recruit,
     
     (select d.num mnum,
       c.obj_name_orig mname,
       dep.name mdep,
       cat.category_name mcat,
       agh.ag_contract_header_id mid,
       ch.description mch,
       tr.ag_parent_header_id mpid,
       mfnum,
       mfname,
       mfcat,
       mrnum,
       mrname,
       mrcat
from ins.ag_agent_tree tr,
     ag_contract_header agh,
     document d,
     ag_contract ag,
     contact c,
     department dep,
     ag_category_agent cat,
     t_sales_channel ch,
     (select d.num mfnum,
             c.obj_name_orig mfname,
             cat.category_name mfcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) fleader,
      (select d.num mrnum,
             c.obj_name_orig mrname,
             cat.category_name mrcat,
             ag.ag_contract_id
      from ag_contract ag,
           ag_contract_header agh,
           document d,
           contact c,
           ag_category_agent cat
       where ag.contract_id = agh.ag_contract_header_id
             and agh.ag_contract_header_id = d.document_id
             and agh.agent_id = c.contact_id
             and ag.category_id = cat.ag_category_agent_id) recruit
        
where tr.ag_contract_header_id = agh.ag_contract_header_id
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      and agh.t_sales_channel_id = ch.id
      
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
      and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end
      and cat.ag_category_agent_id > 2
      and dep.department_id = :P_DEPT_ID
     ) manag
     
where tr.ag_contract_header_id = agh.ag_contract_header_id
      and agh.ag_contract_header_id = d.document_id
      and nvl(agh.is_new,0) = 1
      and agh.ag_contract_header_id = ag.contract_id
      and ag.agency_id = dep.department_id
      and agh.agent_id = c.contact_id
      and cat.ag_category_agent_id = ag.category_id
      
      and to_date(:PAR_DATE,'dd.mm.yyyy') between tr.date_begin and tr.date_end
	  and to_date(:PAR_DATE,'dd.mm.yyyy') between ag.date_begin and ag.date_end
      and cat.category_name = 'Менеджер'
      and dep.department_id = :P_DEPT_ID
      and ch.id = agh.t_sales_channel_id
      
      and fleader.ag_contract_id(+) = ag.contract_f_lead_id
      and recruit.ag_contract_id(+) = ag.contract_recrut_id
      
      and manag.mid(+) = tr.ag_parent_header_id
]]>
      </select>
      <group name="GR_AGENT">
        <dataItem name="rn"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

begin
	select dep.name
		into :DEPT
	from department dep
	where dep.department_id = :P_DEPT_ID;
exception
	   when no_data_found then :DEPT := '';
end;	

select to_char(sysdate,'dd.mm.yyyy') 
	into :REP_DATE from dual;

select :P_DATE_BEGIN 
	into :PAR_DATE from dual;

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
%>
<rw:foreach id="fi0" src="GR_AGENT">
  <rw:getValue id="j_rec_count" src="rn"/>
  <% rec_count_all = new Integer(j_rec_count).intValue(); %>
</rw:foreach>

<body link=blue vlink=purple>

<table x:str border=0 cellpadding=0 cellspacing=0 width=741 style='border-collapse:
 collapse;table-layout:fixed;width:557pt'>
 <col width=48 style='mso-width-source:userset;mso-width-alt:1755;width:36pt'>
 <col width=82 style='mso-width-source:userset;mso-width-alt:2998;width:62pt'>
 <col width=87 style='mso-width-source:userset;mso-width-alt:3181;width:65pt'>
 <col width=61 style='mso-width-source:userset;mso-width-alt:2230;width:46pt'>
 <col width=84 style='mso-width-source:userset;mso-width-alt:3072;width:63pt'>
 <col width=164 style='mso-width-source:userset;mso-width-alt:5997;width:123pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 <col width=105 style='mso-width-source:userset;mso-width-alt:3840;width:79pt'>
  <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=20 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt'>
  АКТ СВЕРКИ СТРУКТУРЫ АГЕНТСКОЙ СЕТИ</td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'>Агентство</td>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'><rw:field id="" src="dept"/></td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'>Отчетный месяц:</td>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'><rw:field id="" src="par_date"/></td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'>Дата составления:</td>
  <td height=40 class=xl73 width=48 colspan=3 style='height:30.0pt;border-top:none;
  width:36pt'><rw:field id="" src="rep_date"/></td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl73 width=48 colspan=35 style='height:30.0pt;border-top:none;
  width:36pt'></td>
 </tr>
 
<tr height=40 style='height:30.0pt'>
  <td height=40 class=xl65 width=50 rowspan=2 style='height:30.0pt;border-top:none;width:36pt'>№ п/п</td>
  <td class=xl65 width=50 colspan=11 style='border-top:none;border-left:none;width:50pt'>Директор</td>
  <td class=xl65 width=50 colspan=11 style='border-top:none;border-left:none;width:50pt'>Менеджер</td>
  <td height=40 class=xl65 width=50 rowspan=2 style='height:30.0pt;border-top:none;width:36pt'>Примечания: ФИО, уволен / переведен в менеджеры / переведен в субагенты / переведен в директоры</td>
</tr>
<tr height=40 style='height:30.0pt'>
 
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Вид агентской сети (SAS / DSF)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Агентство</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Директора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Директора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД Вырастившего</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Вырастившего</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Вырастившего</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД Рекрутера</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Рекрутера</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Рекрутера</td>
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Вид агентской сети (SAS / DSF)</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Агентство</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Менеджера</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Менеджера</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД Вырастившего</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Вырастившего</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Вырастившего</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>№АД Рекрутера</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ФИО Рекрутера</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Категория Рекрутера</td>
 
 </tr>
 
 <rw:foreach id="fi2" src="GR_AGENT">
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl69 style='height:15.0pt;border-top:none'><%=++rec_count_current%></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mch"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mdep"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mnum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mcat"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mfnum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mfname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mfcat"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mrnum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mrname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="mrcat"></rw:field></td>
   <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ach"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="adep"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="anum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="aname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="acat"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fnum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fcat"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="rnum"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="rname"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="rcat"></rw:field></td>
 </tr>
 
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
