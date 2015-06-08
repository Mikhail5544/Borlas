<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="policy_bonus_part" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="POLICY_BONUS_PART" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_FLAG_PLO" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_INS_DUE" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select rownum,
      pp.pol_ser || ' - ' || pp.pol_num  as pol_num,
upper(pkg_utils.date2genitive_case(pp.reg_date)) as reg_date,
pkg_utils.date2genitive_case(ph.start_date) as start_date,
pkg_utils.date2genitive_case(pp.end_date) as end_date,
replace(pkg_utils.date2genitive_case(sysdate),'года','г.') as print_date,
ent.obj_name('CONTACT',pkg_policy.get_policy_holder_id(pp.policy_id)) as pol_holder,
pkg_contact.get_fio_fmt(ent.obj_name('CONTACT',pkg_policy.get_policy_holder_id(pp.policy_id)),4) as pol_holder_sign,
pkg_contact.get_birth_date(pkg_policy.get_policy_holder_id(pp.policy_id)) as holder_birthday,
pkg_contact.get_primary_doc (pkg_policy.get_policy_holder_id(pp.policy_id)) as holder_doc,
pkg_contact.get_primary_tel(pkg_policy.get_policy_holder_id(pp.policy_id)) as holder_phone,
ent.obj_name('CN_ADDRESS',pkg_contact.get_primary_address(pkg_policy.get_policy_holder_id(pp.policy_id))) as holder_addr,
tpt.number_of_payments as number_of_payments
from ven_p_policy pp,
        ven_p_pol_header ph,
		VEN_T_PAYMENT_TERMS tpt
where pp.policy_id = :P_POLICY_ID
   and ph.policy_header_id = pp.pol_header_id
   and tpt.id = pp.payment_term_id]]>
      </select>
      <group name="G_MAIN"><dataItem name="rownum"/></group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[select 
       rownum as nn,
       ent.obj_name('CONTACT', b.contact_id) as beneficiary,
	   to_char(pkg_contact.get_birth_date(b.contact_id), 'dd.mm.yyyy') as ben_birth,
	   pkg_contact.get_rel_description(su.contact_id, b.contact_id) as ben_rel,
	   pkg_rep_utils.to_money(b.value) || ' %'  as BEN_PART
  from ven_as_asset       a,
	   ven_as_assured     su,
	   ven_as_beneficiary b,
	   t_path_type        pth
 where a.p_policy_id = :P_POLICY_ID
   and b.as_asset_id(+) = a.as_asset_id
   and su.as_assured_id = a.as_asset_id
   and pth.t_path_type_id(+) = b.value_type_id]]>
      </select>
      <group name="G_NN"><dataItem name="nn"/></group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
      begin
      select pkg_rep_utils.to_money(pps.amount) || ' (' || pkg_utils.money2speech(pps.amount,ap.fund_id) || ')'
      into :P_INS_DUE
          from v_policy_payment_schedule pps, ven_ac_payment ap
          where pps.policy_id = :P_POLICY_ID
          and pps.document_id = ap.payment_id
          and ap.payment_number = 1;
    exception 
      when no_data_found then :P_INS_DUE := '';
    end;
    begin
    	select decode(plo.description,'Вариант № 1','1','Вариант № 2','2','Вариант № 3','3','0')
    	into :P_FLAG_PLO
    	from 
    	ven_as_asset a,
    	ven_p_cover c,
    	ven_t_prod_line_option plo
    	where a.p_policy_id = :P_POLICY_ID
    	  and c.as_asset_id = a.as_asset_id
    	  and plo.id = c.t_prod_line_option_id
    	  and plo.description like 'Вариант%'
    	  and rownum = 1;
	exception 
      when no_data_found then :P_FLAG_PLO := '-1';
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
<title>ДОГОВОР НАКОПИТЕЛЬНОГО СТРАХОВАНИЯ ЖИЗНИ № F1 </title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>skushenko</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>4</o:Revision>
  <o:TotalTime>59</o:TotalTime>
  <o:LastPrinted>2007-06-22T13:28:00Z</o:LastPrinted>
  <o:Created>2007-06-22T13:25:00Z</o:Created>
  <o:LastSaved>2007-06-22T13:40:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>403</o:Words>
  <o:Characters>2303</o:Characters>
  <o:Company>borlas</o:Company>
  <o:Lines>19</o:Lines>
  <o:Paragraphs>5</o:Paragraphs>
  <o:CharactersWithSpaces>2701</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>120</w:Zoom>
  <w:HideGrammaticalErrors/>
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
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
@font-face
	{font-family:"Arial Narrow";
	panose-1:2 11 5 6 2 2 2 3 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Wingdings 2";
	panose-1:5 2 1 2 1 5 7 7 7 7;
	mso-font-charset:2;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
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
	margin-bottom:0cm;
	margin-left:225.0pt;
	margin-bottom:.0001pt;
	text-align:center;
	text-indent:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	mso-list:l2 level2 lfo2;
	tab-stops:list 243.0pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	text-transform:uppercase;
	mso-font-kerning:0pt;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
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
p.MsoNormalIndent, li.MsoNormalIndent, div.MsoNormalIndent
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:14.2pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:1.0cm;
	mso-pagination:widow-orphan;
	mso-list:l2 level5 lfo2;
	tab-stops:list 60.55pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-GB;}
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
	mso-fareast-font-family:"Times New Roman";}
p.MsoListNumber, li.MsoListNumber, div.MsoListNumber
	{margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	text-indent:0cm;
	mso-pagination:widow-orphan;
	mso-list:l2 level1 lfo2;
	tab-stops:14.2pt list 18.0pt;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	text-transform:uppercase;
	font-weight:bold;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:42.55pt;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:-15.55pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:42.55pt;
	mso-pagination:widow-orphan;
	mso-list:l2 level3 lfo2;
	tab-stops:14.2pt list 63.0pt;
	font-size:12.0pt;
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
p.1, li.1, div.1
	{mso-style-name:Обычный1;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:25.65pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:1.0cm;
	mso-pagination:widow-orphan;
	mso-list:l2 level4 lfo2;
	tab-stops:14.2pt list 90.0pt;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:31.2pt 42.55pt 31.2pt 48.2pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:-120;
	mso-list-type:simple;
	mso-list-template-ids:-70112850;}
@list l0:level1
	{mso-level-style-link:"Нумерованный список";
	mso-level-tab-stop:18.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l1
	{mso-list-id:944844690;
	mso-list-template-ids:1710004144;}
@list l1:level1
	{mso-level-start-at:3;
	mso-level-tab-stop:18.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l1:level2
	{mso-level-text:"%1\.%2\.";
	mso-level-tab-stop:18.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l1:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:36.0pt;
	text-indent:-36.0pt;}
@list l1:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:36.0pt;
	text-indent:-36.0pt;}
@list l1:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:36.0pt;
	text-indent:-36.0pt;}
@list l1:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:54.0pt;
	mso-level-number-position:left;
	margin-left:54.0pt;
	text-indent:-54.0pt;}
@list l1:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:54.0pt;
	mso-level-number-position:left;
	margin-left:54.0pt;
	text-indent:-54.0pt;}
@list l1:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	margin-left:72.0pt;
	text-indent:-72.0pt;}
@list l1:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	margin-left:72.0pt;
	text-indent:-72.0pt;}
@list l2
	{mso-list-id:1351108930;
	mso-list-template-ids:865734612;}
@list l2:level1
	{mso-level-number-format:none;
	mso-level-style-link:"Нумерованный список";
	mso-level-text:"";
	mso-level-tab-stop:18.0pt;
	mso-level-number-position:left;
	margin-left:0cm;
	text-indent:0cm;}
@list l2:level2
	{mso-level-style-link:"Заголовок 1";
	mso-level-text:"%1%2\.";
	mso-level-tab-stop:243.0pt;
	mso-level-number-position:left;
	margin-left:225.0pt;
	text-indent:0cm;}
@list l2:level3
	{mso-level-style-link:"Основной текст с отступом";
	mso-level-text:"%1%2\.%3\.";
	mso-level-tab-stop:63.0pt;
	mso-level-number-position:left;
	margin-left:-15.55pt;
	text-indent:42.55pt;}
@list l2:level4
	{mso-level-style-link:Обычный1;
	mso-level-text:"%1%2\.%3\.%4\.";
	mso-level-tab-stop:90.0pt;
	mso-level-number-position:left;
	margin-left:25.65pt;
	text-indent:1.0cm;
	mso-ansi-font-size:9.0pt;
	mso-bidi-font-size:9.0pt;
	font-family:Arial;}
@list l2:level5
	{mso-level-number-format:none;
	mso-level-style-link:"Обычный отступ";
	mso-level-text:%1;
	mso-level-tab-stop:60.55pt;
	mso-level-number-position:left;
	margin-left:14.2pt;
	text-indent:1.0cm;}
@list l2:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6";
	mso-level-tab-stop:57.6pt;
	mso-level-number-position:left;
	margin-left:57.6pt;
	text-indent:-57.6pt;}
@list l2:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7";
	mso-level-tab-stop:64.8pt;
	mso-level-number-position:left;
	margin-left:64.8pt;
	text-indent:-64.8pt;}
@list l2:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8";
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	margin-left:72.0pt;
	text-indent:-72.0pt;}
@list l2:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9";
	mso-level-tab-stop:79.2pt;
	mso-level-number-position:left;
	margin-left:79.2pt;
	text-indent:-79.2pt;}
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
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
 <o:shapedefaults v:ext="edit" spidmax="3074"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>
<rw:foreach id="rg_main" src="G_main">
<div class=Section1>

<h1 style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;margin-left:
0cm;margin-bottom:.0001pt;mso-list:none;tab-stops:27.0pt'><a name="_Toc99349889"><span
style='font-size:9.0pt;font-family:Arial;font-style:normal'>договор
накопительного страхования жизни № </span></a><span style='mso-bookmark:_Toc99349889'><u><span
lang=EN-US style='font-size:9.0pt;font-family:Arial;mso-ansi-language:EN-US;
font-style:normal'><rw:field id="f_pol_num" src="pol_num" /></span></u></span><span style='mso-bookmark:_Toc99349889'></span><span
style='mso-bookmark:_Toc99349889'><span style='font-size:9.0pt;font-family:
Arial;font-style:normal'> <o:p></o:p></span></span></h1>

<h1 style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;margin-left:
0cm;margin-bottom:.0001pt;mso-list:none;tab-stops:27.0pt'><span
style='mso-bookmark:_Toc99349889'><span style='font-size:9.0pt;font-family:
Arial;font-style:normal'>от </span></span><span style='mso-bookmark:_Toc99349889'><u><span
lang=EN-US style='font-size:9.0pt;font-family:Arial;mso-ansi-language:EN-US;
font-style:normal'><rw:field id="f_reg_date" src="reg_date" /></span></u></span><span style='mso-bookmark:_Toc99349889'><u><span
style='font-size:9.0pt;font-family:Arial;font-style:normal'></span></u></span><span
style='mso-bookmark:_Toc99349889'><span style='font-size:9.0pt;font-family:
Arial;font-style:normal'> <o:p></o:p></span></span></h1>

<h1 style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;margin-left:
0cm;margin-bottom:.0001pt;mso-list:none;tab-stops:27.0pt'><span
style='mso-bookmark:_Toc99349889'><span style='font-size:9.0pt;font-family:
Arial;font-style:normal'>Программа страхования жизни «БОНУС – ПАРТНЕР»<o:p></o:p></span></span></h1>

<span style='mso-bookmark:_Toc99349889'></span>

<p class=MsoNormal style='text-align:justify;tab-stops:6.3pt 430.0pt'><span
style='font-size:8.0pt;font-family:Arial;letter-spacing:-.1pt'><span
style='mso-tab-count:1'>   </span>г. Москва<span style='mso-tab-count:1'>                                                                                                                                                         </span></span><u><span
lang=EN-US style='font-size:8.0pt;font-family:Arial;letter-spacing:-.1pt;
mso-ansi-language:EN-US'><rw:field id="f_print_date" src="print_date" /></span></u><u><span style='font-size:8.0pt;
font-family:Arial;letter-spacing:-.1pt'></span></u><span style='font-size:
8.0pt;font-family:Arial;letter-spacing:-.1pt'><o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:5.0pt;
font-family:Arial;letter-spacing:-.1pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:5.0pt;
font-family:Arial;letter-spacing:-.1pt'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='text-align:justify;tab-stops:72.0pt 99.0pt 162.0pt 234.0pt 261.0pt 315.0pt 338.75pt 396.0pt 418.55pt 453.55pt 496.95pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial;
letter-spacing:-.1pt'>1. ООО «СК «Ренессанс Жизнь», именуемое в дальнейшем
«Страховщик», в лице Управляющего директора Киселева О.М., действующего <span
style='mso-tab-count:1'>                                </span>на <span
style='mso-tab-count:1'>       </span>основании <span style='mso-tab-count:
1'>         </span>Доверенности <span style='mso-tab-count:1'>       </span>№ <span
style='mso-tab-count:1'>       </span>2005/02/32 <span style='mso-tab-count:
1'>     </span>от <span style='mso-tab-count:1'>      </span>23.12.2005, <span
style='mso-tab-count:1'>     </span>с <span style='mso-tab-count:1'>       </span>одной
<span style='mso-tab-count:1'>     </span>стороны,<span style='mso-tab-count:
1'>    </span>и<o:p></o:p></span></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0 width=673
 style='width:504.9pt;margin-left:5.4pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:11.4pt'>
  <td width=673 style='width:504.9pt;padding:0cm 5.4pt 0cm 5.4pt;height:11.4pt'>
  <p class=MsoNormal style='margin-left:-5.4pt;text-align:justify;tab-stops:
  494.1pt'><u><span lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";
  mso-bidi-font-family:Arial;letter-spacing:-.1pt;mso-ansi-language:EN-US'><rw:field id="f_pol_holder" src="pol_holder" />, <rw:field id="f_holder_birthday" src="holder_birthday" />, <rw:field id="f_holder_doc" src="holder_doc" />, <rw:field id="f_holder_addr" src="holder_addr" />, <rw:field id="f_holder_phone" src="holder_phone" /><span
  style='mso-tab-count:1'>                                                                                                                                                                                                             </span><o:p></o:p></span></u></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:17.5pt'>
  <td width=673 valign=top style='width:504.9pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:7.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial;
  letter-spacing:-.1pt'>(укажите фамилию, имя, отчество Страхователя, дату
  рождения, данные документа, удостоверяющие личность, домашний адрес (адрес
  проживания) с указанием индекса и телефоны для связи)<o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt;
font-family:"Arial Narrow";mso-bidi-font-family:Arial;letter-spacing:-.1pt'>именуемы<span
class=GramE>й(</span>-ая) в дальнейшем Страхователь, с другой стороны,
заключили настоящий Договор (далее Договор страхования).<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>2.
Застрахованным по настоящему договору является Страхователь.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>3.
Страховыми случаями признаются следующие события, при условии, что они
произошли в период действия договора страхования, кроме случаев,
предусмотренных п. 4.2.-4.4.Общих условий</span><span style='font-size:10.0pt;
font-family:"Arial Narrow"'> страхования от «___» ________ 200__ года (далее
«Общие условия»)</span><span style='font-size:10.0pt;font-family:"Arial Narrow";
mso-bidi-font-family:Arial'>:<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;margin-right:0cm;margin-bottom:0cm;
margin-left:18.0pt;margin-bottom:.0001pt;text-indent:-18.0pt;mso-list:l1 level2 lfo5;
tab-stops:list 18.0pt left 27.0pt'><a name="z_3_1_2"><![if !supportLists]><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-fareast-font-family:
"Arial Narrow";mso-bidi-font-family:"Arial Narrow"'><span style='mso-list:Ignore'>3.1.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>смерть
</span></a><span class=GramE><span style='font-size:10.0pt;font-family:"Arial Narrow";
mso-bidi-font-family:Arial'>Застрахованного</span></span><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>
по любой причине;<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;margin-right:0cm;margin-bottom:0cm;
margin-left:18.0pt;margin-bottom:.0001pt;text-indent:-18.0pt;mso-list:l1 level2 lfo5;
tab-stops:list 18.0pt left 27.0pt'><a name="_Ref60118614"></a><a name="z_3_1_1"><span
style='mso-bookmark:_Ref60118614'><![if !supportLists]><span style='font-size:
10.0pt;font-family:"Arial Narrow";mso-fareast-font-family:"Arial Narrow";
mso-bidi-font-family:"Arial Narrow"'><span style='mso-list:Ignore'>3.2.<span
style='font:7.0pt "Times New Roman"'>&nbsp;&nbsp; </span></span></span><![endif]><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>дожитие
Застрахованного</span></span></a><span style='mso-bookmark:_Ref60118614'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>
до даты окончания Договора страхования</span></span><span style='font-size:
10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial;
mso-bidi-font-style:italic'>4. Страховые взносы </span><span style='font-size:
10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>(<span
class=GramE>нужное</span> отметьте, ненужное зачеркните)<span style='mso-bidi-font-style:
italic'>: <o:p></o:p></span></span></p>
<rw:getValue id="flag4" src="number_of_payments"/>
<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Wingdings 2";mso-ascii-font-family:"Arial Narrow";
mso-hansi-font-family:"Arial Narrow";mso-bidi-font-family:Arial;mso-char-type:
symbol;mso-symbol-font-family:"Wingdings 2";mso-bidi-font-style:italic'><span
style='mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'><% if (flag4.equals("12")) { %> R <% } else { %> &pound; <% } %></span></span><b
style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
"Arial Narrow";mso-bidi-font-family:Arial;mso-bidi-font-style:italic'> </span></b><span
class=GramE><u><span lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";
mso-bidi-font-family:Arial;mso-ansi-language:EN-US;mso-bidi-font-style:italic'><% if (flag4.equals("12")) { %><rw:field id="f_P_INS_DUE" src="P_INS_DUE" /><% } %></span></u><u><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial;
mso-bidi-font-style:italic'></span></u></span><span style='font-size:10.0pt;
font-family:"Arial Narrow";mso-bidi-font-family:Arial;mso-bidi-font-style:italic'>
<% if (!flag4.equals("12")) { %><s><% } %>ежемесячно<% if (!flag4.equals("12")) { %></s><% } %> <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Wingdings 2";mso-ascii-font-family:"Arial Narrow";
mso-hansi-font-family:"Arial Narrow";mso-bidi-font-family:Arial;mso-char-type:
symbol;mso-symbol-font-family:"Wingdings 2";mso-bidi-font-style:italic'><span
style='mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'><% if (flag4.equals("4")) { %> R <% } else { %> &pound; <% } %></span></span><b
style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
"Arial Narrow";mso-bidi-font-family:Arial;mso-bidi-font-style:italic'> </span></b><span
class=GramE><u><span lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";
mso-bidi-font-family:Arial;mso-ansi-language:EN-US;mso-bidi-font-style:italic'><% if (flag4.equals("4")) { %><rw:field id="f_P_INS_DUE" src="P_INS_DUE" /><% } %></span></u></span><span style='font-size:10.0pt;
font-family:"Arial Narrow";mso-bidi-font-family:Arial;mso-bidi-font-style:italic'>
<% if (!flag4.equals("4")) { %><s><% } %>ежеквартально.<% if (!flag4.equals("4")) { %></s><% } %> <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial;
mso-bidi-font-style:italic'>4.1. Период оплаты страховых взносов равен сроку
страхования.</span><i><span style='font-size:8.0pt;font-family:"Arial Narrow";
mso-bidi-font-family:Arial'><o:p></o:p></span></i></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:-9.0pt 14.2pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>5.
Общая страховая сумма по рискам, указанным в п.3.1. и 3.2. настоящего Договора
(<span class=GramE>нужное</span> отметьте, ненужное зачеркните): <o:p></o:p></span></p>
<rw:getValue id="flag5" src="P_FLAG_PLO"/>
<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Wingdings 2";mso-ascii-font-family:"Arial Narrow";
mso-hansi-font-family:"Arial Narrow";mso-bidi-font-family:Arial;mso-char-type:
symbol;mso-symbol-font-family:"Wingdings 2";mso-bidi-font-style:italic'><span
style='mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'><% if (flag5.equals("1")) { %> R <% } else { %> &pound; <% } %></span></span><b
style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
"Arial Narrow";mso-bidi-font-family:Arial;mso-bidi-font-style:italic'> <% if (!flag5.equals("1")) { %><s><% } %>50&nbsp;000
</span></b><span style='font-size:10.0pt;font-family:"Arial Narrow";
mso-bidi-font-family:Arial'>(пятьдесят тысяч) рублей</span><% if (!flag5.equals("1")) { %></s><% } %><b
style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
"Arial Narrow";mso-bidi-font-family:Arial;mso-bidi-font-style:italic'><o:p></o:p></span></b></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Wingdings 2";mso-ascii-font-family:"Arial Narrow";
mso-hansi-font-family:"Arial Narrow";mso-bidi-font-family:Arial;mso-char-type:
symbol;mso-symbol-font-family:"Wingdings 2";mso-bidi-font-style:italic'><span
style='mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'><% if (flag5.equals("2")) { %> R <% } else { %> &pound; <% } %></span></span><b
style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
"Arial Narrow";mso-bidi-font-family:Arial;mso-bidi-font-style:italic'>
<% if (!flag5.equals("2")) { %><s><% } %>100&nbsp;000 </span></b><span style='font-size:10.0pt;font-family:"Arial Narrow";
mso-bidi-font-family:Arial'>(сто тысяч) рублей<% if (!flag5.equals("2")) { %></s><% } %><b style='mso-bidi-font-weight:
normal'><span style='mso-bidi-font-style:italic'> <o:p></o:p></span></b></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Wingdings 2";mso-ascii-font-family:"Arial Narrow";
mso-hansi-font-family:"Arial Narrow";mso-bidi-font-family:Arial;mso-char-type:
symbol;mso-symbol-font-family:"Wingdings 2";mso-bidi-font-style:italic'><span
style='mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'><% if (flag5.equals("3")) { %> R <% } else { %> &pound; <% } %></span></span><b
style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
"Arial Narrow";mso-bidi-font-family:Arial;mso-bidi-font-style:italic'> <% if (!flag5.equals("3")) { %><s><% } %>200 000</span></b><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>
(двести тысяч) рублей.<% if (!flag5.equals("3")) { %></s><% } %><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>6.
Период страхования:<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>6.1.
Договор страхования заключается сроком на 5 (пять) лет с </span><u><span
lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:
Arial;mso-ansi-language:EN-US'><rw:field id="f_start_date" src="start_date" /></span></u><u><span style='font-size:10.0pt;
font-family:"Arial Narrow";mso-bidi-font-family:Arial'></span></u><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>
по </span><u><span lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";
mso-bidi-font-family:Arial;mso-ansi-language:EN-US'><rw:field id="f_end_date" src="end_date" /></span></u><u><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'></span></u><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>.
Договор вступает в силу после оплаты Страхователем<span
style='mso-spacerun:yes'>  </span>первого страхового взноса в соответствие с п.
4 настоящего Договора.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>7.
Страховые выплаты.<span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>7.1.
При наступлении страховых случаев, предусмотренных п.3.1. или п. 3.2.
настоящего Договора, выплачивается страховая сумма, указанная <span
class=GramE>в</span> п.5. <span class=GramE>настоящего</span> Договора. <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'>8.
При досрочном расторжении Договора страхования Страхователю выплачивается
выкупная сумма <span class=GramE>в размере сформированного на момент
расторжения резерва за вычетом задолженности Страхователя перед Страховщиком по
уплате</span> страховых взносов.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow"'>9. Выгодоприобретатели на
случай смерти <span class=GramE>Застрахованного</span>:<o:p></o:p></span></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 width=680
 style='width:18.0cm;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=31 valign=top style='width:23.45pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  style='font-size:10.0pt;font-family:"Arial Narrow"'>№ <span class=SpellE><span
  class=GramE>п</span></span>/<span class=SpellE>п</span><o:p></o:p></span></p>
  </td>
  <td width=313 valign=top style='width:234.4pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyText align=center style='margin-top:0cm;text-align:center;
  text-indent:0cm;tab-stops:57.6pt'><span style='font-size:10.0pt;font-family:
  "Arial Narrow"'>Фамилия, Имя, Отчество<o:p></o:p></span></p>
  </td>
  <td width=96 valign=top style='width:72.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  style='font-size:10.0pt;font-family:"Arial Narrow"'>Дата рождения<o:p></o:p></span></p>
  </td>
  <td width=132 valign=top style='width:99.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  style='font-size:10.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoBodyText align=center style='margin-top:0cm;text-align:center;
  text-indent:0cm;tab-stops:27.0pt'><span style='font-size:10.0pt;font-family:
  "Arial Narrow"'>Степень родства<o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText align=left style='margin-top:0cm;text-align:left;
  text-indent:0cm;tab-stops:27.0pt'><span style='font-size:10.0pt;font-family:
  "Arial Narrow"'>Процент от страховой суммы<o:p></o:p></span></p>
  </td>
 </tr>
 <rw:foreach id="rg_nn" src="G_NN">
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=31 valign=top style='width:23.45pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";mso-ansi-language:
  EN-US'><rw:field id="f_nn" src="nn" /><o:p></o:p></span></p>
  </td>
  <td width=313 valign=top style='width:234.4pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";mso-ansi-language:
  EN-US'><rw:field id="f_beneficiary" src="beneficiary" /><o:p></o:p></span></p>
  </td>
  <td width=96 valign=top style='width:72.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  style='font-size:10.0pt;font-family:"Arial Narrow"'><rw:field id="f_ben_birth" src="ben_birth" /></span><span
  lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";mso-ansi-language:
  EN-US'><o:p></o:p></span></p>
  </td>
  <td width=132 valign=top style='width:99.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";mso-ansi-language:
  EN-US'><rw:field id="f_ben_rel" src="ben_rel" /><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
  lang=EN-US style='font-size:10.0pt;font-family:"Arial Narrow";mso-ansi-language:
  EN-US'><rw:field id="f_BEN_PART" src="BEN_PART" /><o:p></o:p></span></p>
  </td>
 </tr>
 </rw:foreach>
</table>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow"'>10. Во всем остальном, что
не урегулировано настоящим Договором, Стороны руководствуются Общими условиями.
<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow"'>11. Общие условия являются
неотъемлемой частью настоящего Договора страхования. <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:0cm;text-indent:0cm;tab-stops:27.0pt'><span
style='font-size:10.0pt;font-family:"Arial Narrow"'>12. Подписи сторон. Стороны
признают факсимильно воспроизведенную подпись Страховщика подлинной.<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt;
font-family:"Arial Narrow";mso-bidi-font-family:Arial'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=672
 style='width:503.7pt;margin-left:5.7pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  height:52.2pt'>
  <td width=224 valign=top style='width:167.85pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:52.2pt'>
  <div style='mso-element:para-border-div;border:none;border-bottom:solid windowtext 1.5pt;
  padding:0cm 0cm 1.0pt 0cm'>
  <p class=MsoNormal align=center style='text-align:center;border:none;
  mso-border-bottom-alt:solid windowtext 1.5pt;padding:0cm;mso-padding-alt:
  0cm 0cm 1.0pt 0cm'><i><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt;
  font-family:Arial'><!--[if gte vml 1]><v:shapetype id="_x0000_t75"
   coordsize="21600,21600" o:spt="75" o:preferrelative="t" path="m@4@5l@4@11@9@11@9@5xe"
   filled="f" stroked="f">
   <v:stroke joinstyle="miter"/>
   <v:formulas>
    <v:f eqn="if lineDrawn pixelLineWidth 0"/>
    <v:f eqn="sum @0 1 0"/>
    <v:f eqn="sum 0 0 @1"/>
    <v:f eqn="prod @2 1 2"/>
    <v:f eqn="prod @3 21600 pixelWidth"/>
    <v:f eqn="prod @3 21600 pixelHeight"/>
    <v:f eqn="sum @0 0 1"/>
    <v:f eqn="prod @6 1 2"/>
    <v:f eqn="prod @7 21600 pixelWidth"/>
    <v:f eqn="sum @8 21600 0"/>
    <v:f eqn="prod @7 21600 pixelHeight"/>
    <v:f eqn="sum @10 21600 0"/>
   </v:formulas>
   <v:path o:extrusionok="f" gradientshapeok="t" o:connecttype="rect"/>
   <o:lock v:ext="edit" aspectratio="t"/>
  </v:shapetype><v:shape id="_x0000_i1025" type="#_x0000_t75" style='width:57.75pt;
   height:32.25pt'>
   <v:imagedata src="<%=g_ImagesRoot%>/policy_bonus_part/sign.png" o:title="cut_факсимеле О"/>
  </v:shape><![endif]--><![if !vml]><img width=77 height=43
  src="<%=g_ImagesRoot%>/policy_bonus_parts/sign.gif" alt="Created with The GIMP"
  v:shapes="_x0000_i1025"><![endif]><o:p></o:p></span></i></p>
  </div>
  <h3 style='margin:0cm;margin-bottom:.0001pt'><span style='font-size:8.0pt;
  font-weight:normal;mso-bidi-font-weight:bold'>Страховщик<o:p></o:p></span></h3>
  <p class=MsoNormal style='tab-stops:66.3pt'><span lang=EN-US
  style='mso-ansi-language:EN-US'><span style='mso-tab-count:1'>                      </span></span><span
  style='font-size:10.0pt;font-family:Arial'>М.П.<span style='color:silver'><o:p></o:p></span></span></p>
  </td>
  <td width=202 valign=top style='width:151.45pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:52.2pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i><span style='font-size:8.0pt;
  font-family:Arial'><o:p>&nbsp;</o:p></span></i></b></p>
  </td>
  <td width=246 valign=top style='width:184.4pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:52.2pt'>
  <div style='mso-element:para-border-div;border:none;border-bottom:solid windowtext 1.5pt;
  padding:0cm 0cm 1.0pt 0cm'>
  <p class=MsoNormal style='text-align:justify;border:none;mso-border-bottom-alt:
  solid windowtext 1.5pt;padding:0cm;mso-padding-alt:0cm 0cm 1.0pt 0cm'><i><span
  style='font-size:7.0pt;font-family:Arial'>Общие условия страхования получил.<o:p></o:p></span></i></p>
  <p class=MsoNormal style='text-align:justify;border:none;mso-border-bottom-alt:
  solid windowtext 1.5pt;padding:0cm;mso-padding-alt:0cm 0cm 1.0pt 0cm'><i><span
  style='font-size:7.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></i></p>
  <p class=MsoNormal style='text-align:justify;border:none;mso-border-bottom-alt:
  solid windowtext 1.5pt;padding:0cm;mso-padding-alt:0cm 0cm 1.0pt 0cm'><i><span
  style='font-size:7.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></i></p>
  <p class=MsoNormal style='text-align:justify;tab-stops:84.15pt;border:none;
  mso-border-bottom-alt:solid windowtext 1.5pt;padding:0cm;mso-padding-alt:
  0cm 0cm 1.0pt 0cm'><i><span style='font-size:7.0pt;font-family:Arial'><span
  style='mso-tab-count:1'>                                     </span><span
  class=GramE>(<span lang=EN-US style='mso-ansi-language:EN-US'><rw:field id="f_pol_holder_sign" src="pol_holder_sign" /></span>)</span><o:p></o:p></span></i></p>
  </div>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i><span style='font-size:8.0pt;
  font-family:Arial'>Страхователь</span></i></b><b style='mso-bidi-font-weight:
  normal'><i><span style='font-size:6.0pt;mso-bidi-font-size:8.0pt;font-family:
  Arial'><o:p></o:p></span></i></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i><span style='font-size:6.0pt;
  mso-bidi-font-size:8.0pt;font-family:Arial'>(</span></i></b><i><span
  style='font-size:6.0pt;mso-bidi-font-size:8.0pt;font-family:Arial;mso-bidi-font-weight:
  bold'>подпись, фамилия, инициалы<b>)</b></span></i><i><span style='font-size:
  9.0pt;mso-bidi-font-size:12.0pt;font-family:Arial'><o:p></o:p></span></i></p>
  </td>
 </tr>
</table>

<p class=MsoNormal align=center style='margin-right:-225.0pt;text-align:center'><span
style='font-size:8.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal style='margin-right:-225.0pt;tab-stops:333.0pt'><span
style='font-size:8.0pt;font-family:"Arial Narrow";mso-bidi-font-family:Arial'><span
style='mso-spacerun:yes'> </span><span style='mso-tab-count:1'>                                                                                                                                                   </span>«________»_______________________20_____г.<o:p></o:p></span></p>

<p class=MsoNormal style='margin-right:-225.0pt'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

</div>
</rw:foreach>
</body>

</html>

</rw:report>
