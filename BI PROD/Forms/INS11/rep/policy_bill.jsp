<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="policy_bill" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="POLICY_BILL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_PAYMENT_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_COMPANY" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_INN" datatype="character" width="50" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_KPP" datatype="character" width="50" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select 
    -- Плательщик
    rownum,
	decode(pkg_contact.get_brief_contact_type_prior(ap.contact_id),'ЮЛ',bct2.brief || ' <' || ent.obj_name('CONTACT',ap.contact_id) || '>',
	'ФЛ',ent.obj_name('CONTACT',ap.contact_id))	as platel,

    -- Банк 
    bct.brief || ' <' ||cba.bank_name || '>' as bank,
	cba.account_nr as account_nr,
	cba.account_corr as account_corr,
	pkg_contact.get_ident_number(cba.bank_id,'BIK') as BIK, 

	
	-- Счет
	ap.num as ap_num,
	to_char(ap.reg_date,'dd.mm.yyyy') as reg_date,
	pkg_rep_utils.to_money(ap.amount) as amount,
	pkg_utils.money2speech(ap.amount,ap.fund_id) amount_speach,
	p.pol_ser || '-' || p.pol_num as policy

from ven_ac_payment ap
 ,   ven_cn_contact_bank_acc cba
 ,   ven_contact c 
 ,   ven_contact c2
 ,   ven_T_CONTACT_TYPE bct
 ,   ven_T_CONTACT_TYPE bct2
 ,   ven_doc_doc dd   
 ,   ven_p_policy p


where ap.payment_id = :P_PAYMENT_ID 
  and ap.company_bank_acc_id =  cba.id (+)
  and c.contact_id(+) = cba.bank_id 
  and bct.id (+) = c.contact_type_id
  and dd.child_id(+) = ap.payment_id
  and p.policy_id(+) = dd.parent_id
  and c2.contact_id  = ap.contact_id
  and bct2.id (+) = c2.contact_type_id
  and rownum = 1
]]>
      </select>
      <group name="G_main"><dataItem name="rownum"/></group>
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
  -- Страховщик
  begin
    select decode(COMPANY_NAME,' ',' ',COMPANY_TYPE || ' ' || COMPANY_NAME),INN,KPP
    into :P_COMPANY, :P_INN, :P_KPP
	from v_company_info;
  exception
	when no_data_found then  :P_COMPANY := '                        '; 
	                         :P_INN := '          '; 
							 :P_KPP := '         ';
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
<title>Д Е Б Е Т – Н О Т А</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>Noss</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>3</o:Revision>
  <o:TotalTime>4</o:TotalTime>
  <o:LastPrinted>2006-08-28T11:44:00Z</o:LastPrinted>
  <o:Created>2007-07-11T10:10:00Z</o:Created>
  <o:LastSaved>2007-07-11T10:13:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>46</o:Words>
  <o:Characters>267</o:Characters>
  <o:Company>Noss Enterprises</o:Company>
  <o:Lines>2</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>312</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:DisplayHorizontalDrawingGridEvery>0</w:DisplayHorizontalDrawingGridEvery>
  <w:DisplayVerticalDrawingGridEvery>0</w:DisplayVerticalDrawingGridEvery>
  <w:UseMarginsForDrawingGridOrigin/>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:FootnoteLayoutLikeWW8/>
   <w:ShapeLayoutLikeWW8/>
   <w:AlignTablesRowByRow/>
   <w:ForgetLastTabAlignment/>
   <w:LayoutRawTableWidth/>
   <w:LayoutTableRowsApart/>
   <w:UseWord97LineBreakingRules/>
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
 /* Font Definitions */
 @font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-AU;}
h1
	{mso-style-next:Обычный;
	margin-top:18.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	tab-stops:184.3pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-font-kerning:0pt;
	font-weight:normal;}
h2
	{mso-style-next:Обычный;
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	tab-stops:184.3pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-bidi-font-weight:normal;}
h3
	{mso-style-next:Обычный;
	margin-top:6.0pt;
	margin-right:-97.1pt;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:3;
	tab-stops:184.3pt;
	border:none;
	mso-border-bottom-alt:solid windowtext .5pt;
	padding:0cm;
	mso-padding-alt:0cm 0cm 1.0pt 0cm;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-bidi-font-weight:normal;}
h4
	{mso-style-next:Обычный;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:4;
	tab-stops:219.75pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	font-weight:normal;}
h5
	{mso-style-next:Обычный;
	margin-top:6.0pt;
	margin-right:-96.95pt;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:5;
	tab-stops:184.3pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-bidi-font-family:"Times New Roman";
	font-weight:normal;}
h6
	{mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:6;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-font-weight:normal;}
p.MsoHeading7, li.MsoHeading7, div.MsoHeading7
	{mso-style-next:Обычный;
	margin-top:6.0pt;
	margin-right:-96.95pt;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:7;
	tab-stops:21.3pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	font-weight:bold;}
p.MsoHeading8, li.MsoHeading8, div.MsoHeading8
	{mso-style-next:Обычный;
	margin-top:6.0pt;
	margin-right:-96.95pt;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:8;
	tab-stops:21.3pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";}
p.MsoHeading9, li.MsoHeading9, div.MsoHeading9
	{mso-style-next:Обычный;
	margin-top:6.0pt;
	margin-right:-1.9pt;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:9;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	text-align:center;
	mso-pagination:widow-orphan;
	border:none;
	mso-border-alt:solid windowtext .5pt;
	padding:0cm;
	mso-padding-alt:1.0pt 4.0pt 1.0pt 4.0pt;
	font-size:16.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";}
p.MsoBodyText2, li.MsoBodyText2, div.MsoBodyText2
	{margin-top:0cm;
	margin-right:-97.1pt;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoBlockText, li.MsoBlockText, div.MsoBlockText
	{margin-top:6.0pt;
	margin-right:-96.95pt;
	margin-bottom:0cm;
	margin-left:184.3pt;
	margin-bottom:.0001pt;
	text-indent:-148.85pt;
	mso-pagination:widow-orphan;
	tab-stops:184.3pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-AU;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:35.45pt 42.45pt 72.0pt 63.8pt;
	mso-header-margin:36.0pt;
	mso-footer-margin:36.0pt;
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
</style>
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="3074"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:36.0pt'>
<rw:foreach id="rg_main" src="G_main">
<div class=Section1>

<p class=MsoTitle style='background:white;border:none;mso-padding-alt:0cm 0cm 0cm 0cm'><b
style='mso-bidi-font-weight:normal'><span style='font-family:Arial;mso-bidi-font-family:
"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoTitle style='background:white;border:none;mso-padding-alt:0cm 0cm 0cm 0cm'><b
style='mso-bidi-font-weight:normal'><span style='font-family:Arial;mso-bidi-font-family:
"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoTitle style='background:white;border:none;mso-padding-alt:0cm 0cm 0cm 0cm'><b
style='mso-bidi-font-weight:normal'><span style='font-family:Arial;mso-bidi-font-family:
"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoTitle style='background:white;border:none;mso-padding-alt:0cm 0cm 0cm 0cm'><b
style='mso-bidi-font-weight:normal'><span style='font-family:Arial;mso-bidi-font-family:
"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoTitle style='background:white;border:none;mso-padding-alt:0cm 0cm 0cm 0cm'><b
style='mso-bidi-font-weight:normal'><span style='font-family:Arial;mso-bidi-font-family:
"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoTitle style='background:white;border:none;mso-padding-alt:0cm 0cm 0cm 0cm'><b
style='mso-bidi-font-weight:normal'><span style='font-family:Arial;mso-bidi-font-family:
"Times New Roman"'>СЧЕТ № <rw:field id="f_ap_num" src="ap_num" /><o:p></o:p></span></b></p>

<p class=MsoTitle align=left style='text-align:left;background:white;
border:none;mso-padding-alt:0cm 0cm 0cm 0cm'><b style='mso-bidi-font-weight:
normal'><span style='font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt'><b style='mso-bidi-font-weight:
normal'><span style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:
Arial;mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'>Дата: <rw:field id="f_reg_date" src="reg_date" /></o:p></span></b></p>

<p class=MsoTitle style='background:white;border:none;mso-padding-alt:0cm 0cm 0cm 0cm'><span
style='font-family:Arial;mso-bidi-font-family:"Times New Roman"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;tab-stops:3.0cm'><b
style='mso-bidi-font-weight:normal'><span style='font-size:12.0pt;mso-bidi-font-size:
10.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman";mso-ansi-language:
RU'>Плательщик:<span style='mso-tab-count:1'>  </span><rw:field id="f_platel" src="platel" /><o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt'><b style='mso-bidi-font-weight:
normal'><span style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:
Arial;mso-bidi-font-family:"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;tab-stops:3.0cm'><b
style='mso-bidi-font-weight:normal'><span style='font-size:12.0pt;mso-bidi-font-size:
10.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman";mso-ansi-language:
RU'>Получатель:<span style='mso-tab-count:1'>   </span><rw:field id="f_P_COMPANY" src="P_COMPANY" /><o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt'><span style='mso-bidi-font-size:
8.0pt;mso-ansi-language:RU'>ИНН <rw:field id="f_P_INN" src="P_INN" />, КПП<span style='mso-bidi-font-weight:bold'>
<rw:field id="f_P_KPP" src="P_KPP" /></span>, <span class=GramE>Р</span>/С <rw:field id="f_account_nr" src="account_nr" /><o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt'><span style='mso-bidi-font-size:
8.0pt;mso-ansi-language:RU'>в <rw:field id="f_bank" src="bank" />, БИК <rw:field id="f_BIK" src="BIK" />,<o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt'><span style='mso-bidi-font-size:
8.0pt;mso-ansi-language:RU'>К/С <rw:field id="f_account_corr" src="account_corr" /></span><b style='mso-bidi-font-weight:normal'><span
style='mso-bidi-font-size:8.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU'><o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-56.75pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt'><a name="Insurer_Natural"></a><a
name="Insurer_Natural_FirstName"></a><span style='mso-bookmark:Insurer_Natural'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'><span style='mso-spacerun:yes'> </span><a
name="Insurer_Natural_ParentName"></a><o:p></o:p></span></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=669
 style='width:501.55pt;border-collapse:collapse;border:none;mso-border-alt:
 solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=414 valign=top style='width:310.2pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoHeading9><span style='mso-bookmark:Insurer_Natural'>Предмет счета</span></p>
  </td>
  <span style='mso-bookmark:Insurer_Natural'></span>
  <td width=255 valign=top style='width:191.35pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='margin-top:6.0pt;text-align:center'><span
  style='mso-bookmark:Insurer_Natural'><b><span style='font-size:14.0pt;
  mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Сумма, руб.<o:p></o:p></span></b></span></p>
  </td>
  <span style='mso-bookmark:Insurer_Natural'></span>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=414 valign=top style='width:310.2pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-top:6.0pt;margin-right:-1.9pt;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt'><span style='mso-bookmark:Insurer_Natural'><span
  style='font-size:11.0pt;mso-bidi-font-size:10.0pt;mso-ansi-language:RU'>Оплата
  страховой премии по договору № <rw:field id="f_policy" src="policy" /><o:p></o:p></span></span></p>
  </td>
  <span style='mso-bookmark:Insurer_Natural'></span>
  <td width=255 valign=top style='width:191.35pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='margin-top:6.0pt;margin-right:-1.9pt;
  margin-bottom:0cm;margin-left:0cm;margin-bottom:.0001pt;text-align:center'><span
  style='mso-bookmark:Insurer_Natural'><span style='font-size:11.0pt;
  mso-bidi-font-size:10.0pt;mso-ansi-language:RU'><rw:field id="f_amount" src="amount" /><o:p></o:p></span></span></p>
  </td>
  <span style='mso-bookmark:Insurer_Natural'></span>
 </tr>
</table>

<span style='mso-bookmark:Insurer_Natural'></span>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:14.2pt;margin-bottom:.0001pt;tab-stops:21.3pt'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'><span style='mso-tab-count:1'>  </span><o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:49.65pt'><b><span
style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'>Всего:<span style='mso-tab-count:1'>    </span><rw:field id="f_amount_speach" src="amount_speach" /><o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:184.3pt'><span
style='font-size:11.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU;mso-bidi-font-weight:bold'>Без расходов для
бенефициара (ООО «СК «Ренессанс Жизнь»)</span><span style='font-size:12.0pt;
mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:"Times New Roman";
mso-ansi-language:RU;mso-bidi-font-weight:bold'><o:p></o:p></span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:184.3pt'><b
style='mso-bidi-font-weight:normal'><span style='font-size:11.0pt;mso-bidi-font-size:
10.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:21.3pt'><b><span
style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:21.3pt'><b><span
style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:21.3pt'><b><span
style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:21.3pt'><b><span
style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'>Управляющий Директор<o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:21.3pt'><b><span
style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'>ООО «СК «Ренессанс Жизнь»<o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:-96.95pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;tab-stops:21.3pt'><b><span
style='font-size:12.0pt;mso-bidi-font-size:10.0pt;font-family:Arial;mso-bidi-font-family:
"Times New Roman";mso-ansi-language:RU'>Киселев О. М.<o:p></o:p></span></b></p>

</div>
</rw:foreach>
</body>

</html>

</rw:report>
