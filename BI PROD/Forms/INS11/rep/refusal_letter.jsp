<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="refusal_letter" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="REFUSAL_LETTER" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_CLAIM_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_ZAPAS" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select canParse="no">
      <![CDATA[select 
 p.pol_ser || '-' || p.pol_num as policy,
 pkg_contact.get_fio_case(ec.cn_person_id, -- ИД контакта
                      'Д') as FIO,
 pkg_contact.get_fio_fmt(ent.obj_name('CONTACT',ec.cn_person_id), 2) || ' ' || 
  pkg_contact.get_fio_fmt(ent.obj_name('CONTACT',ec.cn_person_id), 3) as IO,
 pkg_contact.get_address_name(pkg_contact.get_primary_address(ec.cn_person_id)) as addr,
 to_char(ch.declare_date,'dd.mm.yyyy') as decl_date,
 to_char(e.event_date,'dd.mm.yyyy') as event_date,
 e.diagnose,
 to_char(p.start_date,'dd.mm.yyyy') as start_wait_date,
 to_char(nvl(p.waiting_period_end_date,p.start_date),'dd.mm.yyyy') as end_wait_date,
 to_char(p.sign_date,'dd.mm.yyyy') as sign_date,
 ent.obj_name('T_PRODUCT',ph.product_id) as product,
  case  -- 1 в ожидательном периоде, -- 2 нет
    when e.event_date between p.start_date and p.waiting_period_end_date  then '1' 
	else '0'
	end  as is_in_wait_period
from ven_c_claim c, 
     ven_c_claim_header ch, 
	 ven_c_event_contact ec, 
	 ven_p_policy p, 
	 ven_p_pol_header ph,
     v_c_event e
where c.c_claim_id = :P_CLAIM_ID -- 189386 
   and c.c_claim_header_id = ch.c_claim_header_id
   and ch.declarant_id = ec.c_event_contact_id
   and ch.p_policy_id = p.policy_id
   and p.pol_header_id = ph.policy_header_id
   and ch.c_event_id = e.event_id
   ]]>
      </select>
      <displayInfo x="1.47913" y="1.22913" width="0.69995" height="0.19995"/>
      <group name="G_POLICY">
        <displayInfo x="0.98828" y="1.92908" width="1.68176" height="1.62695"
        />
        <dataItem name="POLICY" datatype="vchar2" columnOrder="13"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Policy">
          <dataDescriptor expression="POLICY" descriptiveExpression="POLICY"
           order="1" width="2049"/>
        </dataItem>
        <dataItem name="FIO" datatype="vchar2" columnOrder="14" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fio">
          <dataDescriptor expression="FIO" descriptiveExpression="FIO"
           order="2" width="4000"/>
        </dataItem>
        <dataItem name="IO" datatype="vchar2" columnOrder="15" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Io">
          <dataDescriptor expression="IO" descriptiveExpression="IO" order="3"
           width="4000"/>
        </dataItem>
        <dataItem name="ADDR" datatype="vchar2" columnOrder="16" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Addr">
          <dataDescriptor expression="ADDR" descriptiveExpression="ADDR"
           order="4" width="4000"/>
        </dataItem>
        <dataItem name="DECL_DATE" datatype="vchar2" columnOrder="17"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Decl Date">
          <dataDescriptor expression="DECL_DATE"
           descriptiveExpression="DECL_DATE" order="5" width="10"/>
        </dataItem>
        <dataItem name="EVENT_DATE" datatype="vchar2" columnOrder="18"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Event Date">
          <dataDescriptor expression="EVENT_DATE"
           descriptiveExpression="EVENT_DATE" order="6" width="10"/>
        </dataItem>
        <dataItem name="DIAGNOSE" datatype="vchar2" columnOrder="19"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Diagnose">
          <dataDescriptor expression="DIAGNOSE"
           descriptiveExpression="DIAGNOSE" order="7" width="4000"/>
        </dataItem>
        <dataItem name="START_WAIT_DATE" datatype="vchar2" columnOrder="20"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Start Wait Date">
          <dataDescriptor expression="START_WAIT_DATE"
           descriptiveExpression="START_WAIT_DATE" order="8" width="10"/>
        </dataItem>
        <dataItem name="END_WAIT_DATE" datatype="vchar2" columnOrder="21"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="End Wait Date">
          <dataDescriptor expression="END_WAIT_DATE"
           descriptiveExpression="END_WAIT_DATE" order="9" width="10"/>
        </dataItem>
        <dataItem name="SIGN_DATE" datatype="vchar2" columnOrder="22"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Sign Date">
          <dataDescriptor expression="SIGN_DATE"
           descriptiveExpression="SIGN_DATE" order="10" width="10"/>
        </dataItem>
        <dataItem name="PRODUCT" datatype="vchar2" columnOrder="23"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Product">
          <dataDescriptor expression="PRODUCT" descriptiveExpression="PRODUCT"
           order="11" width="4000"/>
        </dataItem>
        <dataItem name="IS_IN_WAIT_PERIOD" datatype="character"
         oracleDatatype="aFixedChar" columnOrder="24" width="1"
         defaultWidth="10000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Is In Wait Period">
          <dataDescriptor expression="IS_IN_WAIT_PERIOD"
           descriptiveExpression="IS_IN_WAIT_PERIOD" order="12" width="1"/>
        </dataItem>
      </group>
    </dataSource>
  </data>
  <layout>
  <section name="header" width="21.00000" height="29.70000">
    <body width="7.08655" height="9.33069">
      <location x="0.59058" y="1.18103"/>
    </body>
  </section>
  <section name="trailer" width="21.00000" height="29.70000">
    <body width="7.08655" height="9.33069">
      <location x="0.59058" y="1.18103"/>
    </body>
  </section>
  <section name="main" width="21.00000" height="29.70000">
    <body width="7.08655" height="9.33069">
      <location x="0.59058" y="1.18103"/>
    </body>
  </section>
  </layout>
  <parameterForm width="10.00000" height="10.00000"/>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
  
  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="refusal_letter.files/filelist.xml">
<title>Господину (же)</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>achistyakov</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>27</o:TotalTime>
  <o:LastPrinted>2007-07-09T11:06:00Z</o:LastPrinted>
  <o:Created>2007-07-10T08:57:00Z</o:Created>
  <o:LastSaved>2007-07-10T08:57:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>215</o:Words>
  <o:Characters>1229</o:Characters>
  <o:Company>office</o:Company>
  <o:Lines>10</o:Lines>
  <o:Paragraphs>2</o:Paragraphs>
  <o:CharactersWithSpaces>1442</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
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
   <w:DontGrowAutofit/>
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
	{font-family:"Book Antiqua";
	panose-1:2 4 6 2 5 3 5 3 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Book Antiqua";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:right 522.0pt;
	font-size:8.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Book Antiqua";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:2.0cm 42.5pt 2.0cm 3.0cm;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
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
table.MsoTableGrid
	{mso-style-name:"Сетка таблицы";
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
<![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>
<rw:foreach id="rg_main" src="G_POLICY">
<div class=Section1>

<p class=MsoNormal><span lang=EN-US><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=EN-US><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=EN-US style='font-size:14.0pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=619
 style='width:464.4pt;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=319 valign=top style='width:239.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=300 valign=top style='width:225.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>Господину
  (же)<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=319 valign=top style='width:239.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=300 valign=top style='width:225.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><rw:field id="f_FIO" src="FIO" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=319 valign=top style='width:239.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:14.0pt;font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=300 valign=top style='width:225.0pt;border:none;mso-border-top-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><rw:field id="f_addr" src="addr" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=319 valign=top style='width:239.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span class=SpellE><span lang=EN-US style='font-size:12.0pt;
  font-family:"Times New Roman"'>Исх</span></span><span lang=EN-US
  style='font-size:12.0pt;font-family:"Times New Roman"'>. № ____________ <span
  class=SpellE>от</span></span><span style='font-size:14.0pt;font-family:"Times New Roman";
  mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=300 valign=top style='width:225.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;mso-yfti-lastrow:yes'>
  <td width=319 valign=top style='width:239.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:12.0pt;font-family:"Times New Roman"'>«___»____200___г.<o:p></o:p></span></p>
  </td>
  <td width=300 valign=top style='width:225.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>Уважаемый
(ая) <rw:field id="f_IO" src="IO" />,<o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:14.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:14.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-top:0cm;margin-right:34.35pt;margin-bottom:
0cm;margin-left:19.95pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>ООО
«Страховая Компания «Ренессанс Жизнь» рассмотрела Ваше Заявление на страховую
выплату от <rw:field id="f_decl_date" src="decl_date" /> по произошедшему с Вами событию «<rw:field id="f_diagnose" src="diagnose" />» <rw:field id="f_event_date" src="event_date" />.<o:p></o:p></span></p>
<rw:getValue id="is_wait" src="is_in_wait_period"/>
<p class=MsoNormal style='margin-top:0cm;margin-right:34.35pt;margin-bottom:
0cm;margin-left:19.95pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<% if (is_wait.equals("1")) { %>

<p class=MsoNormal style='margin-top:0cm;margin-right:34.35pt;margin-bottom:
0cm;margin-left:19.95pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>Полученное
Вами телесное повреждение произошло в течение действия выжидательного периода
(Срок действия выжидательного периода: с <rw:field id="f_start_wait_date" src="start_wait_date" /> по <rw:field id="f_end_wait_date" src="end_wait_date" />).<o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>Заявленное
Вами событие не является страховым случаем, так как согласно Общим условиям
страхования Полиса № <rw:field id="f_policy" src="policy" /> в течение срока действия выжидательного периода
Страховщик обязуется произвести страховую выплату только в случае смерти
Застрахованного в результате несчастного случая, установления Застрахованному 1
или 2 группы инвалидности в результате несчастного случая (п. 2.6 Соглашения о
временном покрытии №….).<o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<% } else { %>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>Заявленное
Вами событие не является страховым случаем, так как согласно Общим условиям
страхования от несчастных случаев <rw:field id="f_product" src="product" /> по Полису № <rw:field id="f_policy" src="policy" /> от <rw:field id="f_sign_date" src="sign_date" /> телесное повреждение
полученное Вами (дата повреждения) не входит в перечень повреждений,
предусмотренных Таблицей выплат по страховому риску «Телесные повреждения в результате несчастного случая» (Приложение № 1,
Раздел ….., п. …..), а, следовательно, компания «СК «Ренессанс Жизнь»
отказывает в страховой выплате по вышеуказанному заявлению.<o:p></o:p></span></p>

<% } %>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>С
уважением,<o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>Начальник
Управления андеррайтинга, методологии,<o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify'><span
style='font-size:14.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>Перестрахования
и урегулирования убытков<o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;text-align:justify;tab-stops:
right 432.0pt'><span style='font-size:14.0pt;font-family:"Times New Roman";
mso-ansi-language:RU'>ООО «СК «Ренессанс Жизнь»<span style='mso-tab-count:1'>                                        </span>Иванов
И.Д.<o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:34.3pt;margin-bottom:
0cm;margin-left:19.85pt;margin-bottom:.0001pt;tab-stops:306.0pt'><span
style='font-size:12.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>Исполнитель:
<o:p></o:p></span></p>

<p class=MsoNormal style='margin-left:18.0pt;tab-stops:162.0pt'><span
style='font-size:12.0pt;font-family:"Times New Roman";mso-ansi-language:RU'>т.(495)
981-29-81 (<span class=SpellE>доб</span>.<span style='mso-tab-count:1'>          </span>)</span></p>

</div>
</rw:foreach>
</body>

</html>

</rw:report>
