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
   <userParameter name="P_SESSION_ID"/>
      <dataSource name="Q_1">
      <select>
      <![CDATA[
select null rn
,SESSION_ID
,ROW_ID
,SURNAME
,FIRST_NAME
,MIDDLE_NAME
,BIRTH_DATE
,DOC_SER
,DOC_NUM
,DOC_ISSUED_BY
,DOC_ISSUED_DATE
,PERSON_ADDRES
,PERSON_TELEPHONE
,NOTICE_NUM
,NOTICE_DATE
,START_DATE
,END_DATE
,INS_SUM
,INS_PREM
,GENDER
,FUND
,IS_LOADED
,ERROR_TEXT
from as_bordero_load bl
where session_id = :P_SESSION_ID
  and error_text is not null  

	   ]]>
      </select>
      <group name="group_data">
        <dataItem name="rn"/>
      </group>
    </dataSource>
  </data>
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

<body link=blue vlink=purple>
<table border=0 cellspacing=0 cellpadding=0 width=100
 style='width:100.0pt;font-size:8.0pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'> 
 <col width=10% style='border-top:none;border-left:none'>
 <col width=10% style='border-top:none;border-left:none'>
 <col width=10% style='border-top:none;border-left:none'>
 <col width=70% style='border-top:none;border-left:none'>

  
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 style='border-top:none;border-left:none'>Фамилия</td>
  <td class=xl65 style='border-top:none;border-left:none'>Имя</td>
  <td class=xl65 style='border-top:none;border-left:none'>Отчество</td>
  <td class=xl65 style='border-top:none;border-left:none'>Дата рождения</td>  
  <td class=xl65 style='border-top:none;border-left:none'>Пол</td>      
  <td class=xl65 style='border-top:none;border-left:none'>Серия</td>
  <td class=xl65 style='border-top:none;border-left:none'>Номер</td>
  <td class=xl65 style='border-top:none;border-left:none'>Выдан</td>
  <td class=xl65 style='border-top:none;border-left:none'>Дата выдачи</td>
  <td class=xl65 style='border-top:none;border-left:none'>Адрес</td>
  <td class=xl65 style='border-top:none;border-left:none'>Телефон</td>  
  <td class=xl65 style='border-top:none;border-left:none'>Заявление</td>    
  <td class=xl65 style='border-top:none;border-left:none'>Дата заявления</td>
  <td class=xl65 style='border-top:none;border-left:none'>Начало страхования</td>
  <td class=xl65 style='border-top:none;border-left:none'>Окончание страхования</td>
  <td class=xl65 style='border-top:none;border-left:none'>Сумма</td>
  <td class=xl65 style='border-top:none;border-left:none'>Премия</td>  

  <td class=xl65 style='border-top:none;border-left:none'>Валюта</td>  
  <td class=xl65 style='border-top:none;border-left:none'>Ошибка</td>    

  </tr>
  
 <rw:foreach id="fi1" src="group_data">
 
 <tr>
  <td width=10% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="SURNAME"/></td>
  <td width=10% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="FIRST_NAME"/></td>
  <td width=10% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="MIDDLE_NAME"/></td>
  <td width=70% style='mso-number-format:"dd\/mm\/yyyy";border:.5pt solid windowtext'>
      <rw:field id="" src="BIRTH_DATE" formatMask="DD.MM.YYYY"/></td> 
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="GENDER"/></td>  
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="DOC_SER"/></td>
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="DOC_NUM"/></td>
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="DOC_ISSUED_BY"/></td>	
  <td width=70% style='mso-number-format:"dd\/mm\/yyyy";border:.5pt solid windowtext'>
      <rw:field id="" src="DOC_ISSUED_DATE" formatMask="DD.MM.YYYY"/></td>
  
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="PERSON_ADDRES"/></td>
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="PERSON_TELEPHONE"/></td>
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="NOTICE_NUM"/></td>
  <td width=70% style='mso-number-format:"dd\/mm\/yyyy";border:.5pt solid windowtext'>
	  <rw:field id="" src="NOTICE_DATE" formatMask="DD.MM.YYYY"/></td>
  <td width=70% style='mso-number-format:"dd\/mm\/yyyy";border:.5pt solid windowtext'>
	  <rw:field id="" src="START_DATE" formatMask="DD.MM.YYYY"/></td>
  <td width=70% style='mso-number-format:"dd\/mm\/yyyy";border:.5pt solid windowtext'>
	  <rw:field id="" src="END_DATE" formatMask="DD.MM.YYYY"/></td>  
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="INS_SUM"/></td>  
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="INS_PREM"/></td>  
  
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="FUND"/></td>    
  <td width=70% class=table_text style='border:.5pt solid windowtext;'><rw:field id="" src="ERROR_TEXT"/></td>    
  </tr>
 
 </rw:foreach>
 </table>
</body>
</html>


</rw:report>
