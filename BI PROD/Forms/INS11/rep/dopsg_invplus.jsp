<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<rw:report id="report">

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="dopsg_ids" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="DOPSG_IDS" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="POL_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="p_report_id" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_signer_id" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_genitive_position_name" datatype="character" width="500"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="p_position_name" datatype="character" width="250"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_signer_name" datatype="character" width="1000"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_procurory_num" datatype="character" width="250"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_genitive_signer_name" datatype="character" width="1000"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_case_genitive_signer_name" datatype="character" width="1000"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="date_sysdate" datatype="character" width="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_version_num" datatype="character" width="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_date_from" datatype="character" width="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_pol_ser_num" datatype="character" width="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="is_legal_entity" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	
	<userParameter name="p_contact_name" datatype="character" width="1000"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_short_name" datatype="character" width="250"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_in_person_name" datatype="character" width="1000"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_in_person_position" datatype="character" width="250"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_lic_num" datatype="character" width="100"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_date_of_birth" datatype="character" width="10"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="p_doc_inf" datatype="character" width="250"
     defaultWidth="0" defaultHeight="0"/>
	 
    <dataSource name="Q_POLICY">
      <select canParse="no">
      <![CDATA[SELECT 1 rec_num FROM DUAL]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_POLICY">
        <dataItem name="rec_num"/>
      </group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
v_report_id NUMBER;
v_position_name VARCHAR2(2000);
v_signer_name VARCHAR2(600);
v_genitive_signer_name VARCHAR2(600);
v_case_genitive_signer_name VARCHAR2(255);
v_genitive_position_name VARCHAR2(2000);
v_procurory_num VARCHAR2(2000);
v_signer_id NUMBER;
begin

BEGIN
	SELECT r.rep_report_id
	INTO v_report_id
	FROM ins.rep_report r
	WHERE r.exe_name = 'ins11/dopsg_invplus.jsp';
EXCEPTION WHEN NO_DATA_FOUND THEN
	v_report_id := 0;
END;
:p_report_id := v_report_id;

BEGIN
	SELECT jp.genitive_position_name
				,jp.position_name
	INTO v_genitive_position_name
			,v_position_name
	FROM ins.t_job_position jp
	WHERE jp.dep_brief = 'ОПЕРУ'
	  AND jp.is_enabled = 1;
EXCEPTION WHEN NO_DATA_FOUND THEN
	v_genitive_position_name := '';
	v_position_name := '';
END;
  
BEGIN
	SELECT s.contact_name
        ,s.procuratory_num
        ,pkg_contact.get_fio_case(s.contact_name,'Р')
        ,pkg_contact.get_fio_fmt(pkg_contact.get_fio_case(s.contact_name,'Р'),4)
        ,s.t_signer_id
  INTO v_signer_name
      ,v_procurory_num
      ,v_genitive_signer_name
      ,v_case_genitive_signer_name
      ,v_signer_id
	FROM ins.t_report_signer sg,
	     ins.t_job_position jp,
       ins.t_signer s
	WHERE s.job_position_id = jp.t_job_position_id
	  AND jp.dep_brief = 'ОПЕРУ'
	  AND jp.is_enabled = 1
    AND s.t_signer_id = sg.t_signer_id
	  AND sg.report_id = v_report_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
	v_signer_name := '';
	v_procurory_num := '';
	v_genitive_signer_name := '';
	v_case_genitive_signer_name := '';
	v_signer_id := 0;
END;

:p_genitive_position_name := v_genitive_position_name;
:p_position_name := v_position_name;
:p_signer_name := v_signer_name;
:p_procurory_num := v_procurory_num;
:p_genitive_signer_name := v_genitive_signer_name;
:p_case_genitive_signer_name := v_case_genitive_signer_name;
:p_signer_id := v_signer_id;

select to_char(sysdate,'dd.mm.yyyy')
into :date_sysdate
from dual;

begin
SELECT p.VERSION_ordeR_NUM,
       to_char(p.start_date,'dd.mm.yyyy') date_from,
       NVL (DECODE (NVL (pol_ser, '@'),
                    '@', pol_num,
                    pol_ser || '-' || pol_num
                   ),
            '@@'
           ) pol_ser_num,
t.is_legal_entity
INTO :p_version_num, :p_date_from, :p_pol_ser_num, :is_legal_entity
  FROM ven_p_policy p, ven_p_pol_header ph, v_pol_issuer iss, ins.contact c, ins.t_contact_type t
WHERE p.POL_HEADER_ID = ph.POLICY_HEADER_ID
 AND p.policy_id = :POL_ID
 AND p.policy_id = iss.policy_id
 and c.contact_id = iss.contact_id
 and c.contact_type_id = t.id;
exception when no_data_found then
  :p_version_num := ''; :p_date_from := ''; :p_pol_ser_num := ''; :is_legal_entity := 1;
end;

IF :is_legal_entity = 1 THEN
BEGIN
 SELECT iss.contact_name,
       vc.short_name,
       ll.in_person_name,
       ll.in_person_position,
       NVL(ll.license_num,ll.letter_num) lic_num
 INTO :p_contact_name, :p_short_name, :p_in_person_name, :p_in_person_position, :p_lic_num
 FROM v_pol_issuer iss, ven_contact vc, license_legal_entity ll
 WHERE iss.contact_id = vc.contact_id
   and iss.policy_id = :POL_ID
   and vc.contact_id = ll.contact_id
   and ll.is_current = 1
   and :is_legal_entity = 1;
EXCEPTION WHEN NO_DATA_FOUND THEN
:p_contact_name := ''; :p_short_name := ''; :p_in_person_name := ''; :p_in_person_position := ''; :p_lic_num := '';
END;
ELSE
BEGIN
  SELECT iss.contact_name, to_char(vcp.date_of_birth,'dd.mm.yyyy') date_of_birth,
       case when vcp.contact_type_id not in (1,3,1030) then comp.dd else replace(NVL (TRIM (pkg_contact.get_primary_doc (iss.contact_id)),'@@'),'-',' ') end doc_inf, 
       vc.short_name
  INTO :p_contact_name, :p_date_of_birth, :p_doc_inf, :p_short_name
  FROM v_pol_issuer iss, ven_cn_person vcp, ven_contact vc, v_temp_company comp
  WHERE iss.contact_id = vcp.contact_id AND vc.contact_id = iss.contact_id and comp.contact_id = iss.contact_id
   and iss.policy_id = :POL_ID
   and :is_legal_entity = 0;
EXCEPTION WHEN NO_DATA_FOUND THEN
:p_contact_name := ''; :p_short_name := ''; :p_date_of_birth := ''; :p_doc_inf := '';
END;
END IF;

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
<title>Дополнительное соглашение</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>sterlta</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>7</o:Revision>
  <o:TotalTime>352</o:TotalTime>
  <o:LastPrinted>2007-07-11T07:09:00Z</o:LastPrinted>
  <o:Created>2007-11-06T14:26:00Z</o:Created>
  <o:LastSaved>2007-11-16T14:32:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>774</o:Words>
  <o:Characters>4412</o:Characters>
  <o:Lines>36</o:Lines>
  <o:Paragraphs>10</o:Paragraphs>
  <o:CharactersWithSpaces>5176</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>BestFit</w:Zoom>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:PunctuationKerning/>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:BreakWrappedTables/>
   <w:SnapToGridInCell/>
   <w:WrapTextWithPunct/>
   <w:UseAsianBreakRules/>
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
 /* Font Definitions */
 @font-face
	{font-family:SimSun;
	panose-1:2 1 6 0 3 1 1 1 1 1;
	mso-font-alt:\5B8B\4F53;
	mso-font-charset:134;
	mso-generic-font-family:auto;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:1 135135232 16 0 262144 0;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
@font-face
	{font-family:"\@SimSun";
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-charset:134;
	mso-generic-font-family:auto;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:1 135135232 16 0 262144 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	tab-stops:center 216.0pt right 432.0pt;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-GB;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
@page Section1
	{size:595.3pt 841.9pt;
	margin:42.55pt 42.55pt 42.55pt 70.9pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Table Normal";
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
table.MsoTableGrid
	{mso-style-name:"Table Grid";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	border:solid windowtext 1.0pt;
	mso-border-alt:solid windowtext .5pt;
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-border-insideh:.5pt solid windowtext;
	mso-border-insidev:.5pt solid windowtext;
	mso-para-margin:0cm;
	mso-para-margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ansi-language:#0400;
	mso-fareast-language:#0400;
	mso-bidi-language:#0400;}
</style>
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="9218"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<rw:foreach id="G_POLICY" src="G_POLICY">

<div class=Section1>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:16.0pt'>Дополнительное соглашение № 1</span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt'>к Договору страхования № <rw:field id="" src="p_pol_ser_num"/> от <rw:field id="" src="p_date_from"/></span></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='margin-left:-3.6pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=312 valign=top style='width:234.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>г. Москва</p>
  </td>
  <td width=348 valign=top style='width:261.0pt;padding:0cm 5.4pt 0cm 5.4pt'><a
  name="f_add_start_date"></a>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:11.0pt'><o:p><rw:field id="" src="date_sysdate"/></o:p></span></p>
  </td>
 </tr>
</table>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<rw:getValue id="is_ent" src="is_legal_entity"/>

<% if (is_ent.equals("0")) {%>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt'><span
style='letter-spacing:-.1pt'>ООО «СК «Ренессанс Жизнь», именуемое в дальнейшем
«Страховщик», в лице <rw:field id="" src="p_genitive_signer_name"/>, действующего на
основании Доверенности № <rw:field id="" src="p_procurory_num"/>, с одной стороны, и <rw:field id="" src="p_contact_name"/>,
<rw:field id="" src="p_doc_inf"/>, именуемый (ая)<span style='mso-spacerun:yes'>  </span>в
дальнейшем «Страхователь», с другой стороны, заключили настоящее Дополнительное
Соглашение к Договору страхования № <rw:field id="" src="p_pol_ser_num"/> от <rw:field id="" src="p_date_from"/> (далее
– Договор) о нижеследующем:<o:p></o:p></span></p>

<%} else {%>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt'><span
style='letter-spacing:-.1pt'>ООО «СК «Ренессанс Жизнь», именуемое в дальнейшем
«Страховщик», в лице <rw:field id="" src="p_genitive_signer_name"/>, действующего на
основании Доверенности № <rw:field id="" src="p_procurory_num"/>, с одной стороны, и <rw:field id="" src="p_contact_name"/>,
в лице <rw:field id="" src="p_in_person_position"/> <rw:field id="" src="p_in_person_name"/>, действующего на основании
<rw:field id="" src="p_lic_num"/>, именуемый (ая)<span style='mso-spacerun:yes'>  </span>в
дальнейшем «Страхователь», с другой стороны, заключили настоящее Дополнительное
Соглашение к Договору страхования № <rw:field id="" src="p_pol_ser_num"/> от <rw:field id="" src="p_date_from"/> (далее
– Договор) о нижеследующем:<o:p></o:p></span></p>

<%}%>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'>1. Стороны договорились изложить п. 7.5 Полисных условий страхования жизни по
программе "Инвестор плюс" в следующей редакции:<o:p></o:p></b></p>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>
<p class=MsoNormal>"7.5. Минимальный размер общей страховой премии (взноса) по всем
программам страхования не может быть менее 15 000 (Пятнадцати тысяч)  рублей".</p>
<p class=MsoNormal><o:p>&nbsp;</o:p></p>
<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'>2. Во всем остальном, что не предусмотрено настоящим Дополнительным Соглашением
Стороны руководствуются положениями Договора.</p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'>3. Настоящее Дополнительное соглашение вступает в силу с момента подписания его сторонами.</p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'>4. Настоящее Дополнительное Соглашение подписано в двух
экземплярах, имеющих одинаковую силу, по одному экземпляру для каждой Стороны.</p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify;line-height:
12.0pt'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=657
 style='width:492.75pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=372 valign=top style='width:279.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt'>СТРАХОВАТЕЛЬ</p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:-.25pt'>____________________/<rw:field id="" src="p_short_name"/>/ </p>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
  style='mso-spacerun:yes'>                                                                                                   
  </span><span style='mso-spacerun:yes'>                 </span></p>
  </td>
  <td width=285 valign=top style='width:213.75pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=372 valign=top style='width:278.95pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
  <td width=285 valign=top style='width:213.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

</div>

</rw:foreach>

</body>

</html>


</rw:report>
