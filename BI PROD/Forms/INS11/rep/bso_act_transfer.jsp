<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bso_act_transfer" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="АКТ ПРИЕМА-ПЕРЕДАЧИ" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_BSO_DOCUMENT_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_MAIN">
   <select>
      <![CDATA[ select
       rownum,
	   bd.num ACT_NUM,
	   dt.brief as BSO_TEMPL_BRIEF,
	   replace(pkg_utils.date2genitive_case(bd.reg_date),'года','г.') as ACT_DATE,  
       decode(ct_from.brief,'ПБОЮЛ',c_from.name || ' ' || c_from.first_name,
	                           'ФЛ',c_from.name || ' ' || c_from.first_name,
	                                c_from.name) as CONTACT_FROM,
       decode(ct_to.brief,'ПБОЮЛ',c_to.name || ' ' || c_to.first_name,
	                         'ФЛ',c_to.name || ' ' || c_to.first_name,    
                                  c_to.name)  as CONTACT_TO,
	   -- 1 из ЦО,2 в ЦО
	   decode(ot_from.organisation_tree_id,null,2,decode(ot_from.parent_id,null,1,2)) as CO_FLAG,
	   ot_from.name ORG_FROM,
	   ot_to.name   ORG_TO
	   
	from  ven_bso_document bd,  -- Документ БСО (CONTACT TO|FROM, DEPARTMENT TO|FROM)
  		  ven_doc_templ dt,      -- Шаблон документа (BRIEF = 'ПередачаБСО','ВыдачаБСО')
          ven_contact c_to,
		  ven_contact c_from,
		  ven_t_contact_type ct_to,
		  ven_t_contact_type ct_from,
		  ven_department dep_from,
		  ven_organisation_tree ot_from,
		  ven_department dep_to,
		  ven_organisation_tree ot_to
	where bd.bso_document_id = :P_BSO_DOCUMENT_ID
      and bd.doc_templ_id = dt.doc_templ_id
	  and bd.contact_to_id = c_to.contact_id and ct_to.id = c_to.contact_type_id
	  and bd.contact_from_id = c_from.contact_id and ct_from.id = c_from.contact_type_id
	  and bd.department_from_id = dep_from.department_id (+)
	  and dep_from.org_tree_id = ot_from.organisation_tree_id (+)
	  and bd.department_to_id = dep_to.department_id (+)
	  and dep_to.org_tree_id = ot_to.organisation_tree_id (+) ]]>
      </select>
      <group name="G_MAIN"><dataItem name="rownum"/>
              </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[ select
       rownum as nn,
       NUM_START,
       NUM_END,
	   QUANTITY,
	   SERIA,
	   BSO_TYPE
from (select 
	   rownum as nn,
	   bdc.num_start NUM_START, 
       nvl(bdc.num_end,bdc.num_start) NUM_END, 
       decode(bdc.num_end,null,1,to_number(bdc.num_end)-to_number(bdc.num_start)+1) as QUANTITY, 
       bs.series_name as SERIA, 
       bt.name BSO_TYPE
	from ven_bso_doc_cont bdc, -- Содержимое док. БСО (BSO_ID, N_START,N_END, BSO_SERIES_ID)
         ven_bso_type bt,      -- Вид БСО (NAME = 'Квитанция №13','Полис Осаго')
	     ven_bso_series bs    -- Серия БСО (SERIES_NAME, BSO_TYPE_ID)
    where bs.bso_type_id = bt.bso_type_id
      and bdc.bso_series_id = bs.bso_series_id
      and bdc.bso_document_id = :P_BSO_DOCUMENT_ID
	order by bdc.num_start)]]>
      </select>
      <group name="G_NN"><dataItem name="nn"/>
              </group>
    </dataSource>

      </data>
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
<link rel=File-List href="АКТ%20ПРИЕМА-ПЕРЕДАЧИ.files/filelist.xml">
<title>АКТ ПРИЕМА-ПЕРЕДАЧИ  БЛАНКОВ СТРОГОЙ ОТЧЕТНОСТИ</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>skushenko</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>58</o:TotalTime>
  <o:Created>2007-02-28T13:09:00Z</o:Created>
  <o:LastSaved>2007-02-28T13:09:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>55</o:Words>
  <o:Characters>314</o:Characters>
  <o:Company>borlas</o:Company>
  <o:Lines>2</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>368</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
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
	{font-family:"Arial Unicode MS";
	panose-1:2 11 6 4 2 2 2 2 2 4;
	mso-font-charset:128;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1 -369098753 63 0 4129279 0;}
@font-face
	{font-family:"Times New Roman CYR";
	panose-1:2 2 6 3 5 4 5 2 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:536902279 -2147483648 8 0 511 0;}
@font-face
	{font-family:Verdana;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:536871559 0 0 0 415 0;}
@font-face
	{font-family:"\@Arial Unicode MS";
	panose-1:2 11 6 4 2 2 2 2 2 4;
	mso-font-charset:128;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1 -369098753 63 0 4129279 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
h1
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	font-size:16.0pt;
	font-family:Arial;
	mso-font-kerning:16.0pt;}
p.MsoHeading7, li.MsoHeading7, div.MsoHeading7
	{mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	mso-outline-level:7;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	mso-layout-grid-align:none;
	punctuation-wrap:simple;
	text-autospace:none;
	font-size:16.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
p.MsoSubtitle, li.MsoSubtitle, div.MsoSubtitle
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;
	font-weight:bold;}
p.2, li.2, div.2
	{mso-style-name:" Знак2";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:8.0pt;
	margin-left:0cm;
	line-height:12.0pt;
	mso-line-height-rule:exactly;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:Verdana;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:841.9pt 595.3pt;
	mso-page-orientation:landscape;
	margin:2.0cm 2.0cm 42.55pt 2.0cm;
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
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="2050"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<div class=Section1>
<rw:foreach id="rg_main" src="G_MAIN">
<rw:getValue id="co" src="CO_FLAG"/>
<p class=MsoTitle align=left style='text-align:left'><o:p>&nbsp;</o:p></p>

<p class=MsoSubtitle align=left style='text-align:left;tab-stops:180.0pt'><span
style='mso-ansi-language:RU'><span style='mso-tab-count:1'>                                                            </span>АКТ
ПРИЕМА-ПЕРЕДАЧИ<span style='mso-spacerun:yes'>  </span>БЛАНКОВ СТРОГОЙ
ОТЧЕТНОСТИ<o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='margin-left:5.4pt;border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=112 valign=top style='width:84.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1><i><span style='font-size:12.0pt;font-family:"Times New Roman CYR";
  mso-bidi-font-family:Arial;mso-font-kerning:0pt;font-weight:normal;
  mso-bidi-font-weight:bold'>Агентство:</span></i><i><span style='font-size:
  12.0pt;mso-bidi-font-size:16.0pt;font-weight:normal'><o:p></o:p></span></i></h1>
  </td>
  <td width=636 valign=top style='width:477.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='tab-stops:234.6pt'><u><% if (co.equals("1")) { %><rw:field id="f_org_to" src="ORG_TO" /><% } else { %><rw:field id="f_org_from" src="ORG_FROM" /><% } %><span
  style='mso-tab-count:1'>                                                            </span><o:p></o:p></u></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";color:black;mso-bidi-font-style:italic'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman";color:black;mso-bidi-font-style:italic'><rw:field id="f_con_from" src="CONTACT_FROM" /> передает</span><span style='font-family:"Times New Roman CYR";
mso-bidi-font-family:"Times New Roman"'>, а <rw:field id="f_con_to" src="CONTACT_TO" /> принимает следующие бланки
строгой отчетности: </span><span style='mso-bidi-font-size:10.0pt;font-family:
"Times New Roman CYR";mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>
<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=501
 style='width:375.6pt;margin-left:.75pt;border-collapse:collapse;mso-padding-alt:
 0cm 0cm 0cm 0cm'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
  height:32.25pt'>
  <td width=48 rowspan=2 valign=top style='width:35.7pt;border:solid windowtext 1.0pt;
  border-bottom:solid black 1.0pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>№</b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=271 rowspan=2 valign=top style='width:203.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center;text-indent:.45pt'><b>Вид
  бланка</b><b><span style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=122 colspan=2 valign=top style='width:91.7pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>Нумерация </b><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=60 rowspan=2 valign=top style='width:45.2pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='mso-fareast-font-family:"Arial Unicode MS"'>Кол-во, <span
  class=SpellE><span class=GramE>шт</span></span><o:p></o:p></span></b></p>
  </td>
 </tr>
  <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:32.25pt'>
  <td width=53 valign=top style='width:40.0pt;border-top:none;border-left:none;
  border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;mso-border-bottom-alt:solid black .5pt;
  padding:.75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>с<o:p></o:p></b></p>
  </td>
  <td width=69 valign=top style='width:51.7pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid black 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid black .5pt;padding:0cm 0cm 0cm 0cm;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b>по<o:p></o:p></b></p>
  </td>
 </tr>
 <rw:foreach id="rg_nn" src="G_NN">

 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:18.4pt'>
  <td width=48 valign=top style='width:35.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><rw:field id="f_nn" src="NN" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=271 valign=top style='width:203.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_bsotype" src="BSO_TYPE" /><o:p></o:p></span></p>
  </td>
  <td width=53 valign=top style='width:40.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt'><rw:field id="f_start" src="NUM_START" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=69 valign=top style='width:51.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt'><rw:field id="f_end" src="NUM_END" /><o:p></o:p></span></p>
  </td>
  <td width=60 valign=top style='width:45.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;
  height:18.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><rw:field id="f_QUANTITY" src="QUANTITY" /><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoNormal align=center style='text-align:center'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=724
 style='width:543.1pt;margin-left:5.4pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=724 valign=top style='width:543.1pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=528 valign=top style='width:396.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black'>Ответственное
    лицо от Центрального офиса (МО<span class=GramE>1</span>):<o:p></o:p></span></b></p>
    </td>
    <td width=181 valign=top style='width:135.45pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1'>
    <td width=528 valign=top style='width:396.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
    <p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
    text-autospace:none'>___<span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman"'>_____________ / <% if (co.equals("1")) { %><rw:field id="f_con_from" src="CONTACT_FROM" /><% } else { %><rw:field id="f_con_to" src="CONTACT_TO" /><% } %>
/</span><span
    style='mso-bidi-font-size:10.0pt;font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=181 valign=top style='width:135.45pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black'>Дата<span
    class=GramE> :</span><o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2'>
    <td width=528 valign=top style='width:396.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black'>Ответственное
    лицо в агентстве (МО<span class=GramE>2</span>):<o:p></o:p></span></b></p>
    </td>
    <td width=181 valign=top style='width:135.45pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes'>
    <td width=528 valign=top style='width:396.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
    <p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
    text-autospace:none'>___<span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman"'>_____________ / <% if (co.equals("2")) { %><rw:field id="f_con_from" src="CONTACT_FROM" /><% } else { %><rw:field id="f_con_to" src="CONTACT_TO" /><% } %>
/</span><span
    style='mso-bidi-font-size:10.0pt;font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman"'><o:p></o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=181 valign=top style='width:135.45pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='font-family:"Times New Roman CYR";
    mso-bidi-font-family:"Times New Roman";color:black'><o:p>&nbsp;</o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='font-family:
    "Times New Roman CYR";mso-bidi-font-family:"Times New Roman";color:black'>Дата<span
    class=GramE> :</span><o:p></o:p></span></b></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal><o:p></o:p></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'><o:p>&nbsp;</o:p></p>
</rw:foreach>
</div>

</body>

</html>

</rw:report>
