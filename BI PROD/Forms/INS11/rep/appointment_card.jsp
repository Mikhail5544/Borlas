<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="appointment card" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="APPOINTMENT CARD" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_MEDICAL_EXAM_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_USER_NAME" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_USER_PHONE" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_DOC_NUM" datatype="character" width="20"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select rownum as nn,
       -- LPU
       ent.obj_name('CONTACT',ame.medical_contact_id) as LPU,
       pkg_contact.get_address_name(pkg_contact.get_primary_address(ame.medical_contact_id)) as addr,
	   pkg_contact.get_primary_tel(ame.medical_contact_id) as phone,
	   ent.obj_name('CONTACT',pkg_contact.get_rel_contact_id(ame.medical_contact_id,'Контактное лицо в компании')) as ice,
	   -- ASSURED
	   ent.obj_name('CONTACT',ass.assured_contact_id) assured,
	   
	   to_char(pkg_contact.get_birth_date(ass.assured_contact_id),'dd') as birth_dd,
	   to_char(pkg_contact.get_birth_date(ass.assured_contact_id),'mm') as birth_mm,
	   to_char(pkg_contact.get_birth_date(ass.assured_contact_id),'yyyy') as birth_yyyy,
	   
	   pkg_contact.get_ident_seria(ass.assured_contact_id,'PASS_RF') || 
	   ' № ' || pkg_contact.get_ident_number (ass.assured_contact_id,'PASS_RF') || 
	   ' выдали: ' || to_char(pkg_contact.get_ident_date (ass.assured_contact_id,'PASS_RF'),'dd.mm.yyyy') || ' ' || pkg_contact.get_ident_place (ass.assured_contact_id,'PASS_RF') as passport,
           to_char(ame.exam_date,'dd') as exam_dd,
	   to_char(ame.exam_date,'mm') as exam_mm,
	   to_char(ame.exam_date,'yyyy') as exam_yyyy,
	   to_char(ame.exam_date,'hh24') as exam_hh,
	   to_char(ame.exam_date,'mi') as exam_mi,
	   nvl(met.brief,'M0') as exam_type,
	  -- Консультант
	   to_char(sysdate,'dd') as date_dd,
	   to_char(sysdate,'mm') as date_mm,
	   to_char(sysdate,'yyyy') as date_yyyy
	   
from ven_assured_medical_exam ame, ven_as_assured ass, ven_medical_exam_type met, ven_as_assured_docum d 
where ame.assured_medical_exam_id = :P_MEDICAL_EXAM_ID --322
  and d.as_assured_docum_id = ame.as_assured_docum_id
  and ass.as_assured_id = d.as_assured_id
  and met.medical_exam_type_id(+) = ame.medical_exam_type_id
 
]]>
      </select>
      <group name="G_MAIN"><dataItem name="nn"/></group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
  begin
   select ent.obj_name('CONTACT', c.contact_id),
       pkg_contact.get_primary_tel(c.contact_id)
   into :P_USER_NAME, :P_USER_PHONE
   from sys_user su, employee e, contact c
  where e.employee_id(+) = su.employee_id
   and e.contact_id = c.contact_id(+)
   and upper(su.sys_user_name) = upper(user)
   and rownum = 1;
   exception
     when no_data_found then :P_USER_NAME :=''; :P_USER_PHONE:='';
   end;
    
   begin 
     select p.notice_num
       into :P_DOC_NUM
       from ven_p_policy p,ven_as_asset a, ven_assured_medical_exam ame
      where ame.assured_medical_exam_id = :P_MEDICAL_EXAM_ID
        and a.as_asset_id = ame.as_assured_id
        and p.policy_id = a.p_policy_id
        and rownum = 1;
   exception
     when no_data_found then :P_DOC_NUM :='';
   end;
  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]-->
<title>НАПРАВЛЕНИЕ НА МЕДИЦИНСКОЕ ОБСЛЕДОВАНИЕ</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>SerdjLa</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>7</o:Revision>
  <o:TotalTime>23</o:TotalTime>
  <o:LastPrinted>2005-03-02T14:37:00Z</o:LastPrinted>
  <o:Created>2007-06-28T09:47:00Z</o:Created>
  <o:LastSaved>2007-06-28T09:57:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>112</o:Words>
  <o:Characters>644</o:Characters>
  <o:Company>Renaissance Insurance Group</o:Company>
  <o:Lines>5</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>755</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:SelectEntireFieldWithStartOrEnd/>
   <w:UseWord2002TableStyleRules/>
  </w:Compatibility>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
h1
	{mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:right;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-font-kerning:0pt;
	mso-fareast-language:EN-US;}
h2
	{mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-language:EN-US;
	font-weight:normal;
	font-style:italic;}
h3
	{mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:3;
	font-size:10.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
h4
	{mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:4;
	font-size:12.0pt;
	font-family:"Times New Roman";
	color:#FF9900;
	mso-fareast-language:EN-US;}
h5
	{mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:right;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:5;
	font-size:9.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:Arial;
	color:#FF9900;
	mso-fareast-language:EN-US;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:EN-US;
	font-weight:bold;}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:12.6pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:21.6pt 530.5pt;
	layout-grid-mode:char;
	font-size:9.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	color:black;
	mso-fareast-language:EN-US;}
p.MsoBodyTextIndent2, li.MsoBodyTextIndent2, div.MsoBodyTextIndent2
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:3.6pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:18.3pt 447.85pt;
	layout-grid-mode:char;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
p.1, li.1, div.1
	{mso-style-name:Обычный1;
	mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	layout-grid-mode:char;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
 /* Page Definitions */
 @page
	{mso-footnote-separator:url("<%=g_ImagesRoot%>/appointment_card.files/header.jsp") fs;
	mso-footnote-continuation-separator:url("<%=g_ImagesRoot%>/appointment_card.files/header.jsp") fcs;
	mso-endnote-separator:url("<%=g_ImagesRoot%>/appointment_card.files/header.jsp") es;
	mso-endnote-continuation-separator:url("<%=g_ImagesRoot%>/appointment_card.files/header.jsp") ecs;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:50.95pt 42.5pt 35.95pt 63.0pt;
	mso-header-margin:18.0pt;
	mso-footer-margin:35.4pt;
	mso-header:url("<%=g_ImagesRoot%>/appointment_card.files/header.jsp") h1;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
@page Section2
	{size:595.3pt 841.9pt;
	margin:50.95pt 42.5pt 35.95pt 63.0pt;
	mso-header-margin:18.0pt;
	mso-footer-margin:35.4pt;
	mso-header:url("<%=g_ImagesRoot%>/appointment_card.files/header.jsp") h1;
	mso-paper-source:0;}
div.Section2
	{page:Section2;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Обычная таблица";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-noshow:yes;
	mso-style-parent:"";
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-para-margin:0cm;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;}
</style>
<![endif]-->
</head>

<body lang=RU style='tab-interval:36.0pt'>
<rw:foreach id="rg_main" src="G_MAIN">
<div class=Section1>

<p class=MsoNormal align=right style='text-align:right'><span style='mso-ansi-language:
RU'>Приложение №7<o:p></o:p></span></p>

<p class=MsoNormal align=right style='text-align:right'><span style='mso-ansi-language:
RU'><span style='mso-spacerun:yes'> </span>к Положению по оценке риска.</span><span
style='font-size:8.0pt;mso-bidi-font-size:12.0pt;color:#FF9900;mso-ansi-language:
RU'><o:p></o:p></span></p>

<p class=MsoTitle><span style='font-size:8.0pt;mso-bidi-font-size:12.0pt;
color:#FF9900'><o:p>&nbsp;</o:p></span></p>

<p class=MsoTitle align=left style='text-align:left;tab-stops:54.0pt 389.85pt'><span
style='font-size:9.0pt;mso-bidi-font-size:12.0pt;color:green'><span
style='mso-tab-count:1'>                        </span>НАПРАВЛЕНИЕ НА
МЕДИЦИНСКОЕ ОБСЛЕДОВАНИЕ К ЗАЯВЛЕНИЮ №<span style='mso-tab-count:1'>     </span></span><u><span
style='font-size:9.0pt;mso-bidi-font-size:12.0pt;color:#FF6600'><rw:field id="f_P_DOC_NUM" src="P_DOC_NUM" /></span></u><u><span
style='font-size:9.0pt;mso-bidi-font-size:12.0pt;color:green'><o:p></o:p></span></u></p>

<p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt;
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=672
 style='width:504.0pt;margin-left:-3.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:4.0pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=516 valign=top style='width:387.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:8.9pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'>Название поликлиники<o:p></o:p></span></b></p>
  </td>
  <td width=516 valign=top style='width:387.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><rw:field id="f_LPU" src="LPU" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:4.0pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:#FF9900;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=516 valign=top style='width:387.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:5.85pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'>Адрес</span></b><b><span style='font-size:
  10.0pt;mso-bidi-font-size:12.0pt;color:purple;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td width=516 valign=top style='width:387.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><rw:field id="f_addr" src="addr" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:4.0pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:#FF9900;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=516 valign=top style='width:387.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:4.0pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'>Телефон</span></b><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;color:purple;mso-ansi-language:
  RU'><o:p></o:p></span></b></p>
  </td>
  <td width=516 valign=top style='width:387.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><rw:field id="f_phone" src="phone" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;height:4.0pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:#FF9900;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=516 valign=top style='width:387.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;mso-yfti-lastrow:yes;height:8.2pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.2pt'>
  <p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'>Контактное лицо<o:p></o:p></span></b></p>
  </td>
  <td width=516 valign=top style='width:387.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.2pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><rw:field id="f_ice" src="ice" /><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span style='font-size:8.0pt;mso-bidi-font-size:12.0pt;
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><b><span style='font-size:9.0pt;
mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'>Настоящим
просим Вас оказать услуги по медицинскому обследованию нашему клиенту:<o:p></o:p></span></b></p>

<p class=MsoNormal style='text-align:justify'><i><span style='font-size:9.0pt;
mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=672
 style='width:504.0pt;margin-left:-3.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:8.9pt'>
  <td width=144 colspan=2 valign=top style='width:107.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <h4><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple'>ФИО <o:p></o:p></span></h4>
  </td>
  <td width=528 colspan=21 valign=top style='width:396.2pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_assured" src="assured" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:4.0pt'>
  <td width=144 colspan=2 valign=top style='width:107.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=528 colspan=21 valign=top style='width:396.2pt;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:5.85pt'>
  <td width=144 colspan=2 valign=top style='width:107.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'>Дата рождения<o:p></o:p></span></b></p>
  </td>
  <td width=48 valign=top style='width:36.2pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_birth_dd" src="birth_dd" /><o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:17.7pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'>/<o:p></o:p></span></p>
  </td>
  <td width=43 colspan=3 valign=top style='width:31.95pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_birth_mm" src="birth_mm" /><o:p></o:p></span></p>
  </td>
  <td width=18 valign=top style='width:13.35pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'>/<o:p></o:p></span></p>
  </td>
  <td width=60 colspan=3 valign=top style='width:45.0pt;border:none;border-bottom:
  solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_birth_yyyy" src="birth_yyyy" /><o:p></o:p></span></p>
  </td>
  <td width=336 colspan=12 valign=top style='width:252.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:4.0pt'>
  <td width=144 colspan=2 valign=top style='width:107.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><i><span style='font-size:2.0pt;mso-bidi-font-size:
  12.0pt;font-family:Arial;color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></b></p>
  </td>
  <td width=528 colspan=21 valign=top style='width:396.2pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal style='tab-stops:54.0pt 106.5pt'><i><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'>ЧИСЛО<span style='mso-tab-count:1'>                        </span>МЕСЯЦ<span
  style='mso-tab-count:1'>                      </span>ГОД<o:p></o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:4.0pt'>
  <td width=144 colspan=2 valign=top style='width:107.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'>Паспортные данные<o:p></o:p></span></b></p>
  </td>
  <td width=528 colspan=21 valign=top style='width:396.2pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_passport" src="passport" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:4.0pt'>
  <td width=144 colspan=2 valign=top style='width:107.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=528 colspan=21 valign=top style='width:396.2pt;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;page-break-inside:avoid;height:4.0pt'>
  <td width=144 colspan=2 valign=top style='width:107.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'>Дата обследования <o:p></o:p></span></b></p>
  </td>
  <td width=48 valign=top style='width:36.2pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_exam_dd" src="exam_dd" /><o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:17.7pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'>/<o:p></o:p></span></p>
  </td>
  <td width=43 colspan=3 valign=top style='width:31.95pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_exam_mm" src="exam_mm" /><o:p></o:p></span></p>
  </td>
  <td width=18 valign=top style='width:13.35pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'>/<o:p></o:p></span></p>
  </td>
  <td width=60 colspan=3 valign=top style='width:45.0pt;border:none;border-bottom:
  solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_exam_yyyy" src="exam_yyyy" /><o:p></o:p></span></p>
  </td>
  <td width=108 colspan=6 valign=top style='width:81.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <h5><span style='color:purple'>Время <o:p></o:p></span></h5>
  </td>
  <td width=60 valign=top style='width:45.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_exam_hh" src="exam_hh" /><o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'>:<o:p></o:p></span></b></p>
  </td>
  <td width=68 valign=top style='width:51.2pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_exam_mi" src="exam_mi" /><o:p></o:p></span></p>
  </td>
  <td width=84 colspan=3 valign=top style='width:63.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:4.0pt'>
  <td width=144 colspan=2 valign=top style='width:107.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><i><span style='font-size:2.0pt;mso-bidi-font-size:
  12.0pt;font-family:Arial;color:#FF9900;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></b></p>
  </td>
  <td width=528 colspan=21 valign=top style='width:396.2pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal style='tab-stops:54.7pt 107.9pt 235.95pt 291.8pt'><i><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'>ЧИСЛО<span style='mso-tab-count:1'>                        </span>МЕСЯЦ<span
  style='mso-tab-count:1'>                       </span>ГОД<span
  style='mso-tab-count:1'>                                                                               </span>ЧАСЫ<span
  style='mso-tab-count:1'>                           </span>МИНУТЫ<o:p></o:p></span></i></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;page-break-inside:avoid;height:8.9pt;mso-row-margin-left:
  9.0pt;mso-row-margin-right:189.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=204 colspan=4 valign=top style='width:153.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=36 colspan=2 valign=top style='width:27.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=36 colspan=2 valign=top style='width:27.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=36 colspan=2 valign=top style='width:27.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:8.9pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=24 colspan=2 valign=top style='width:18.0pt;border:none;border-bottom:
  solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=252 colspan=7><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <rw:getValue id="f_exam" src="exam_type"/>
 <tr style='mso-yfti-irow:9;page-break-inside:avoid;height:8.9pt;mso-row-margin-left:
  9.0pt;mso-row-margin-right:189.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=204 colspan=4 valign=top style='width:153.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal style='tab-stops:126.25pt'><b><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'>в следующем
  объеме</span></b><i><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'>:<span style='mso-tab-count:1'>           </span></span></i><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'>М1<o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;mso-bidi-font-size:
  12.0pt;font-family:Arial'><% if (f_exam.equals("M1")) out.print("V"); %></span><span style='font-size:9.0pt;mso-bidi-font-size:
  12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=36 colspan=2 valign=top style='width:27.0pt;border:none;border-right:
  solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'>М2<o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><% if (f_exam.equals("M2")) out.print("V"); %><o:p></o:p></span></p>
  </td>
  <td width=36 colspan=2 valign=top style='width:27.0pt;border:none;border-right:
  solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'>М3<o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><% if (f_exam.equals("M3")) out.print("V"); %><o:p></o:p></span></p>
  </td>
  <td width=36 colspan=2 valign=top style='width:27.0pt;border:none;border-right:
  solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-left-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'>М4<o:p></o:p></span></p>
  </td>
  <td width=24 colspan=2 valign=top style='width:18.0pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:8.9pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><% if (f_exam.equals("M4")) out.print("V"); %><o:p></o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=252 colspan=7><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:10;page-break-inside:avoid;height:4.0pt;mso-row-margin-left:
  9.0pt;mso-row-margin-right:198.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=372 colspan=12 valign=top style='width:279.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=24 colspan=2 valign=top style='width:18.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=264 colspan=8><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:11;page-break-inside:avoid;height:4.0pt;mso-row-margin-left:
  9.0pt;mso-row-margin-right:198.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=372 colspan=12 valign=top style='width:279.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'>Дополнительно:<o:p></o:p></span></b></p>
  </td>
  <td width=24 colspan=2 valign=top style='width:18.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=264 colspan=8><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:12;page-break-inside:avoid;height:5.85pt;mso-row-margin-left:
  9.0pt;mso-row-margin-right:18.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=300 colspan=9 valign=top style='width:225.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:5.85pt'>
  <p class=MsoNormal style='text-indent:120.6pt'><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;color:black;mso-ansi-language:
  RU;layout-grid-mode:line'>Анализ крови на ВИЧ</span><span style='font-size:
  9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 colspan=10 valign=top style='width:216.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:5.85pt'>
  <p class=MsoNormal style='text-indent:48.6pt'><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;color:black;mso-ansi-language:
  RU;layout-grid-mode:line'>Серологический тест (гепатит В и С)</span><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=24><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:13;page-break-inside:avoid;height:3.5pt;mso-row-margin-left:
  9.0pt;mso-row-margin-right:18.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=300 colspan=9 valign=top style='width:225.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-indent:120.6pt'><span style='font-size:2.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 colspan=10 valign=top style='width:216.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-indent:48.6pt'><span style='font-size:2.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=24><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:14;page-break-inside:avoid;height:4.0pt;mso-row-margin-left:
  9.0pt;mso-row-margin-right:18.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=300 colspan=9 valign=top style='width:225.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal style='text-indent:120.6pt'><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'>ЭКГ<o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 colspan=10 valign=top style='width:216.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal style='text-indent:48.6pt'><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'>ЭКГ с
  нагрузкой<o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=24><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:15;page-break-inside:avoid;height:4.0pt;mso-row-margin-left:
  9.0pt;mso-row-margin-right:18.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=300 colspan=9 valign=top style='width:225.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal style='text-indent:120.6pt'><span style='font-size:2.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 colspan=10 valign=top style='width:216.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal style='text-indent:48.6pt'><span style='font-size:2.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=24><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <tr style='mso-yfti-irow:16;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:8.2pt;mso-row-margin-left:9.0pt;mso-row-margin-right:18.0pt'>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=12><p class='MsoNormal'>&nbsp;</td>
  <td width=300 colspan=9 valign=top style='width:225.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:8.2pt'>
  <p class=MsoNormal style='text-indent:120.6pt'><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;color:black;mso-ansi-language:
  RU;layout-grid-mode:line'>Прием уролога</span><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:8.2pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 colspan=10 valign=top style='width:216.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:8.2pt'>
  <p class=MsoNormal style='text-indent:48.6pt'><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;color:black;mso-ansi-language:
  RU;layout-grid-mode:line'>Прием гинеколога</span><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:18.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:8.2pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
  width=24><p class='MsoNormal'>&nbsp;</td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=12 style='border:none'></td>
  <td width=131 style='border:none'></td>
  <td width=48 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=0 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=18 style='border:none'></td>
  <td width=18 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=12 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=12 style='border:none'></td>
  <td width=12 style='border:none'></td>
  <td width=12 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=60 style='border:none'></td>
  <td width=18 style='border:none'></td>
  <td width=68 style='border:none'></td>
  <td width=36 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=24 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt;
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt;
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=672
 style='width:504.0pt;margin-left:-3.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:4.0pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=516 colspan=8 valign=top style='width:387.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:4.0pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'>ФИО консультанта</span></b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;color:purple;mso-ansi-language:
  RU'><o:p></o:p></span></p>
  </td>
  <td width=276 colspan=6 valign=top style='width:207.2pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  color:black;mso-ansi-language:RU'><rw:field id="f_P_USER_NAME" src="P_USER_NAME" /><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'>Телефон конт.</span></b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;color:purple;mso-ansi-language:
  RU'><o:p></o:p></span></p>
  </td>
  <td width=132 valign=top style='width:98.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><rw:field id="f_P_USER_PHONE" src="P_USER_PHONE" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:11.9pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.9pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=516 colspan=8 valign=top style='width:387.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.9pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:5.85pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'>Подпись консультанта</span></b><b><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;color:purple;mso-ansi-language:
  RU'><o:p></o:p></span></b></p>
  </td>
  <td width=276 colspan=6 valign=top style='width:207.2pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=132 valign=top style='width:98.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:5.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:6.35pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.35pt'>
  <p class=MsoNormal><b><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=516 colspan=8 valign=top style='width:387.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.35pt'>
  <p class=MsoNormal><span style='font-size:2.0pt;mso-bidi-font-size:12.0pt;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:4.0pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'>Дата <o:p></o:p></span></b></p>
  </td>
  <td width=48 valign=top style='width:36.2pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_date_dd" src="date_dd" /><o:p></o:p></span></p>
  </td>
  <td width=24 valign=top style='width:17.7pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'>/<o:p></o:p></span></p>
  </td>
  <td width=43 valign=top style='width:31.95pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_date_mm" src="date_mm" /><o:p></o:p></span></p>
  </td>
  <td width=18 valign=top style='width:13.35pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'>/<o:p></o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;mso-ansi-language:RU'><rw:field id="f_date_yyyy" src="date_yyyy" /><o:p></o:p></span></p>
  </td>
  <td width=84 valign=top style='width:63.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=132 valign=top style='width:98.8pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:4.0pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial;color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;mso-yfti-lastrow:yes;height:3.5pt'>
  <td width=156 valign=top style='width:117.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal><b><i><span style='font-size:5.0pt;mso-bidi-font-size:
  12.0pt;font-family:Arial;color:purple;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></b></p>
  </td>
  <td width=516 colspan=8 valign=top style='width:387.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='tab-stops:53.2pt 105.0pt'><i><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt;font-family:Arial;
  color:purple;mso-ansi-language:RU'>ЧИСЛО<span style='mso-tab-count:1'>                       </span>МЕСЯЦ<span
  style='mso-tab-count:1'>                      </span>ГОД<o:p></o:p></span></i></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=156 style='border:none'></td>
  <td width=48 style='border:none'></td>
  <td width=24 style='border:none'></td>
  <td width=43 style='border:none'></td>
  <td width=18 style='border:none'></td>
  <td width=60 style='border:none'></td>
  <td width=84 style='border:none'></td>
  <td width=108 style='border:none'></td>
  <td width=132 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><span
style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

</div>

<span style='font-size:12.0pt;font-family:"Times New Roman";mso-fareast-font-family:
"Times New Roman";mso-ansi-language:RU;mso-fareast-language:EN-US;mso-bidi-language:
AR-SA'><br clear=all style='page-break-before:auto;mso-break-type:section-break'>
</span>

<div class=Section2>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=804
 style='width:603.0pt;margin-left:-57.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  height:3.5pt'>
  <td width=804 valign=top style='width:603.0pt;border:none;border-top:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><span
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoHeader style='tab-stops:36.0pt center 233.85pt right 467.75pt'><span
style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

</div>
</rw:foreach>
</body>

</html>

</rw:report>
