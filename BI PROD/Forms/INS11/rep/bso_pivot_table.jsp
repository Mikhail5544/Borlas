<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bso_pivot_table" DTDVersion="9.0.2.0.10" 
afterParameterFormTrigger="afterpform" beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="BSO_ACT_ISSUE" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_DATA_START" datatype="character" width="100" precision="50"
     defaultWidth="0" defaultHeight="0"/>
     <userParameter name="P_DATA_END" datatype="character" width="100" precision="50"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select rownum,
       rep.N,
       rep.NN,
	   rep.BSO_TYPE,
	   rep.IN_QUANTITY,
	   rep.IN_NUM_START,
	   rep.IN_NUM_END,
	   to_char(rep.IN_REG_DATE,'dd.mm.yyyy') as IN_REG_DATE,
	   rep.OUT_QUANTITY,
	   rep.OUT_NUM_START,
	   rep.OUT_NUM_END,
	   to_char(rep.OUT_REG_DATE,'dd.mm.yyyy') as OUT_REG_DATE,
	   rep.OUT_BSO_STATUS,
	   rep.REST_BEGIN,
	   rep.REST_END,
	   rep.REST_CHANGE
from ins_dwh.bso_pivot_table_tmp rep
--where rep.bso_type is not null]]>
      </select>
      <displayInfo x="1.36462" y="1.13538" width="0.69995" height="0.19995"/>
      <group name="G_rownum"><dataItem name="rownum"/></group>
    </dataSource>
  </data>
   <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
    return (TRUE);
end;]]>
      </textSource>
    </function>
    <function name="afterpform">
      <textSource>
      <![CDATA[function AfterPForm return boolean is
begin
  /*pkg_rep_utils.set_p_dates(to_date(:P_DATA_START,'dd.mm.yyyy'),to_date(:P_DATA_END,'dd.mm.yyyy'));*/
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
<title>АКТ ПРИЕМА-ПЕРЕДАЧИ  БЛАНКОВ СТРОГОЙ ОТЧЕТНОСТИ</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>skushenko</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>404</o:TotalTime>
  <o:Created>2007-03-09T06:28:00Z</o:Created>
  <o:LastSaved>2007-03-09T06:28:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>74</o:Words>
  <o:Characters>427</o:Characters>
  <o:Company>borlas</o:Company>
  <o:Lines>3</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>500</o:CharactersWithSpaces>
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
    {font-family:Tahoma;
    panose-1:2 11 6 4 3 5 4 4 2 4;
    mso-font-charset:204;
    mso-generic-font-family:swiss;
    mso-font-pitch:variable;
    mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
@font-face
    {font-family:Verdana;
    panose-1:2 11 6 4 3 5 4 4 2 4;
    mso-font-charset:204;
    mso-generic-font-family:swiss;
    mso-font-pitch:variable;
    mso-font-signature:536871559 0 0 0 415 0;}
@font-face
    {font-family:"Book Antiqua";
    panose-1:2 4 6 2 5 3 5 3 3 4;
    mso-font-charset:204;
    mso-generic-font-family:roman;
    mso-font-pitch:variable;
    mso-font-signature:647 0 0 0 159 0;}
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
h3
    {mso-style-next:Обычный;
    margin-top:12.0pt;
    margin-right:0cm;
    margin-bottom:3.0pt;
    margin-left:0cm;
    mso-pagination:widow-orphan;
    page-break-after:avoid;
    mso-outline-level:3;
    font-size:13.0pt;
    font-family:Arial;}
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
p.MsoCommentText, li.MsoCommentText, div.MsoCommentText
    {mso-style-noshow:yes;
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    font-size:10.0pt;
    font-family:"Book Antiqua";
    mso-fareast-font-family:"Times New Roman";
    mso-bidi-font-family:"Times New Roman";
    mso-ansi-language:EN-US;}
span.MsoCommentReference
    {mso-style-noshow:yes;
    mso-ansi-font-size:8.0pt;
    mso-bidi-font-size:8.0pt;}
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
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
    {mso-style-noshow:yes;
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    font-size:8.0pt;
    font-family:Tahoma;
    mso-fareast-font-family:"Times New Roman";}
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
span.GramE
    {mso-style-name:"";
    mso-gram-e:yes;}
@page Section1
    {size:841.9pt 595.3pt;
    mso-page-orientation:landscape;
    margin:2.0cm 22.95pt 42.55pt 36.0pt;
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

 
<h3 align=center style='text-align:center'><span style='font-family:"Times New Roman";
mso-bidi-font-family:Arial'>Отчет Операционного управления перед Бухгалтерией<o:p></o:p></span></h3>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'><span
style='mso-spacerun:yes'> </span>о движении и остатках бланков<span
style='color:blue'> </span><o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></b></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=380
 style='width:285.0pt;margin-left:-.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=165 valign=top style='width:123.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1 style='margin-top:6.0pt'><a name="_Toc122226875"></a><a
  name="_Toc118529300"><span style='mso-bookmark:_Toc122226875'><i><span
  style='font-size:12.0pt;font-family:"Times New Roman";mso-bidi-font-family:
  Arial;mso-font-kerning:0pt;font-weight:normal;mso-bidi-font-weight:bold'>Отчетный
  период:</span></i></span></a><i><span style='font-size:12.0pt;font-family:
  "Times New Roman";mso-bidi-font-family:Arial;mso-font-kerning:0pt;font-weight:
  normal;mso-bidi-font-weight:bold'><o:p></o:p></span></i></h1>
  </td>
  <td width=215 style='width:161.3pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'>с <rw:field id="start" src="P_DATA_START" /> </span> <span
  style='mso-ansi-language:EN-US'> </span>по <rw:field id="f_end" src="P_DATA_END" /></p>
  </td>
 </tr>
</table>

<p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
none;punctuation-wrap:simple;text-autospace:none'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></b></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=1053
 style='width:790.0pt;margin-left:-9.25pt;border-collapse:collapse;mso-padding-alt:
 0cm 0cm 0cm 0cm'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
  height:32.25pt'>
  <td width=25 rowspan=2 style='width:18.95pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;
  height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>№</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=192 rowspan=2 style='width:144.05pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>Вид бланка</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=84 rowspan=2 style='width:63.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>Остаток на начало<span style='mso-spacerun:yes'> 
  </span>периода</span></b><b><span style='font-size:10.0pt;mso-fareast-font-family:
  "Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=268 colspan=4 style='width:201.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>Приход </span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=250 colspan=4 style='width:187.55pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>Расход</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=77 rowspan=2 style='width:58.1pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>Остаток на конец<span style='mso-spacerun:yes'> 
  </span>периода</span></b><b><span style='font-size:10.0pt;mso-fareast-font-family:
  "Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=88 rowspan=2 valign=top style='width:66.2pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>Статус<o:p></o:p></span></b></p>
  </td>
  <td width=68 rowspan=2 valign=top style='width:51.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:32.25pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>Изменение<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:17.1pt'>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:17.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>кол-во</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:17.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>с</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=60 style='width:45.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:17.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>по</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=64 valign=top style='width:48.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:17.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>дата<o:p></o:p></span></b></p>
  </td>
  <td width=68 style='width:50.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;
  height:17.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>кол-во</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=60 style='width:45.05pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:17.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>с</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=57 style='width:42.7pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:17.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>по </span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
  <td width=65 style='width:48.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:17.1pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:10.0pt'>дата</span></b><b><span style='font-size:10.0pt;
  mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <rw:foreach id="rg_01" src="G_rownum">
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:12.75pt'>
  <td width=25 nowrap style='width:18.95pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
  solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;padding:
  .75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt;mso-fareast-font-family:
  "Arial Unicode MS"'><rw:field id="f_n" src="rownum" /><o:p></o:p></span></p>
  </td>
  <td width=192 nowrap style='width:144.05pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt'><rw:field id="f_bt" src="BSO_TYPE" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=84 nowrap style='width:63.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt'><rw:field id="f_rb1" src="REST_BEGIN" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=72 nowrap style='width:54.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt'><rw:field id="f_inqu1" src="IN_QUANTITY" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=72 nowrap style='width:54.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt'><rw:field id="f_in1c" src="IN_NUM_START" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=60 nowrap style='width:45.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt'><rw:field id="f_in3213" src="IN_NUM_END" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=64 style='width:48.15pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt'><rw:field id="f_rd898" src="IN_REG_DATE" /><o:p></o:p></span></p>
  </td>
  <td width=68 nowrap style='width:50.85pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;
  height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt;mso-fareast-font-family:
  "Arial Unicode MS"'><rw:field id="f_out434" src="OUT_QUANTITY" /><o:p></o:p></span></p>
  </td>
  <td width=60 nowrap style='width:45.05pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt'><rw:field id="f_ore39439" src="OUT_NUM_START" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=57 nowrap style='width:42.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt;mso-fareast-font-family:
  "Arial Unicode MS"'><rw:field id="f_out_ne32423" src="OUT_NUM_END" /><o:p></o:p></span></p>
  </td>
  <td width=65 nowrap style='width:48.95pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt;mso-fareast-font-family:
  "Arial Unicode MS"'><rw:field id="f_out_rg324" src="OUT_REG_DATE" /><o:p></o:p></span></p>
  </td>
  <td width=77 nowrap style='width:58.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:.75pt .75pt 0cm .75pt;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt'><rw:field id="f_rsd55end" src="REST_END" /></span><span
  style='font-size:10.0pt;mso-fareast-font-family:"Arial Unicode MS"'><o:p></o:p></span></p>
  </td>
  <td width=88 nowrap style='width:66.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:.75pt .75pt 0cm .75pt;
  height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt;mso-fareast-font-family:
  "Arial Unicode MS"'><rw:field id="f_ewrwe44" src="OUT_BSO_STATUS" /><o:p></o:p></span></p>
  </td>
  <td width=68 style='width:51.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 0cm 0cm 0cm;height:12.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span style='font-size:10.0pt;mso-fareast-font-family:
  "Arial Unicode MS"'><rw:field id="f_esada3245" src="REST_CHANGE" /><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'><span lang=EN-US style='mso-bidi-font-size:10.0pt;
mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=703 valign=top style='width:527.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
    <td width=501 valign=top style='width:376.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Сотрудник
    Операционного управления:<o:p></o:p></span></b></p>
    </td>
    <td width=174 valign=top style='width:130.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1'>
    <td width=501 valign=top style='width:376.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
    <p class=MsoNormal style='text-align:justify;tab-stops:102.6pt;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'><u>/<span
    style='mso-tab-count:1'>                                 </span></u> /<span
    style='mso-spacerun:yes'>                      </span><span
    style='mso-spacerun:yes'>     </span><span
    style='mso-spacerun:yes'>             </span>/<span style='color:black'><o:p></o:p></span></p>
    </td>
    <td width=174 valign=top style='width:130.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Дата<span
    class=GramE> :</span><o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2'>
    <td width=501 valign=top style='width:376.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'>&nbsp;<b><span
    style='color:black'>Ответственное лицо в<span style='mso-spacerun:yes'> 
    </span>бухгалтерии:<o:p></o:p></span></b></p>
    </td>
    <td width=174 valign=top style='width:130.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes'>
    <td width=501 valign=top style='width:376.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal align=center style='text-align:center;mso-layout-grid-align:
    none;punctuation-wrap:simple;text-autospace:none'><o:p>&nbsp;</o:p></p>
    <p class=MsoNormal style='tab-stops:102.6pt;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><u><span lang=EN-US
    style='mso-ansi-language:EN-US'>/<span style='mso-tab-count:1'>                                 </span></span></u>
    /<span style='mso-spacerun:yes'>                                       
    </span>/<span style='mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=174 valign=top style='width:130.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><span style='color:black'><o:p>&nbsp;</o:p></span></p>
    <p class=MsoNormal style='text-align:justify;mso-layout-grid-align:none;
    punctuation-wrap:simple;text-autospace:none'><b><span style='color:black'>Дата<span
    class=GramE> :</span><o:p></o:p></span></b></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
  text-autospace:none'><span style='mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='mso-layout-grid-align:none;punctuation-wrap:simple;
text-autospace:none'><o:p>&nbsp;</o:p></p>

</div>

</body>

</html>

</rw:report>
