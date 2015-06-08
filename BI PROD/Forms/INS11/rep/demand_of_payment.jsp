<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="demand_of_payment" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="DEMAND_OF_PAYMENT" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_PAYMENT_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_VARIANT" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_POL_NUM" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_HOLDER" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_AGENT" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_REGION" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_PRODUCT" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_DOC_TEMPL_BRIEF" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_USER_NAME" datatype="character" width="500"
     precision="10" defaultWidth="0" defaultHeight="0"/>

    <dataSource name="Q_1">
      <select>
      <![CDATA[select 
    -- Плательщик
    rownum,
    ent.obj_name('CONTACT',ap.contact_id)  as beneficiary,
    pkg_contact.get_address_name(pkg_contact.get_primary_address(ap.contact_id)) as addr,
    ent.obj_name('CONTACT',v.contact_id_a) as bank,
    pkg_contact.get_address_name(pkg_contact.get_primary_address(v.contact_id_a)) as bank_addr,
    cba.account_nr as account_nr,
    pkg_contact.get_ident_number(v.contact_id_a,'BIK') as BIK,
    pkg_contact.get_ident_number(v.contact_id_a,'KORR') as KORR,
    pkg_contact.get_ident_number(v.contact_id_a,'INN') as bank_INN,
    pkg_contact.get_ident_number(v.contact_id_a,'KPP') as bank_KPP,
    pkg_contact.get_ident_number(ap.contact_id,'INN') as INN,
    -- Счет
    ap.num as num,
    to_char(ap.reg_date,'dd.mm.yyyy') as reg_date,
    pkg_rep_utils.to_money(ap.amount) as amount,
    f.brief as fund,
    pkg_utils.money2speech(ap.amount,ap.fund_id) as amount_speech
from ven_ac_payment ap
 ,   ven_fund f
 ,   VEN_CN_CONTACT_REL V
 ,   VEN_T_CONTACT_REL_TYPE T
 ,   ven_cn_contact_bank_acc cba
where ap.payment_id = :P_PAYMENT_ID
  and f.fund_id = ap.fund_id
  and ap.contact_bank_acc_id = cba.id (+)
  and ap.CONTACT_ID = v.contact_id_b
  AND V.RELATIONSHIP_TYPE=t.reverse_relationship_type
  AND UPPER(t.FOR_DSC)=UPPER('Клиент')]]>
      </select>
        <group name="G_main"><dataItem name="rownum"/></group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
l_policy_id number;
begin
  case :P_DOC_TEMPL_BRIEF
  when 'PAYORDER' then :P_VARIANT := 2;
  when 'PAYORDBACK' then :P_VARIANT := 4;
  else :P_VARIANT := 0;
  end case;
    /*
  1 - Перестрахование
  2 - Выплата страхового обеспечения, возмещения
  3 - Агентское вознагрождение
  4 - Возврат премии
  5 - Экспертиза
  */
  
      -- Версия №4 (Выплата страхового возмещения)
  if :P_VARIANT = 2  then 
    begin
      select ch.p_policy_id -- policy_id
      into l_policy_id 
      from ven_doc_doc dd , ven_c_claim cc, ven_c_claim_header ch
      where dd.child_id = :P_PAYMENT_ID 
	    and dd.parent_id = cc.c_claim_id
		and ch.c_claim_header_id = cc.c_claim_header_id
		and rownum = 1;
    exception
      when no_data_found then l_policy_id := null;
    end;
  end if;
  -- Версия №4 (Возврат премии)
  if :P_VARIANT = 4  then 
    begin
      select dd.parent_id   -- policy_id
      into l_policy_id 
      from ven_doc_doc dd
      where dd.child_id = :P_PAYMENT_ID 
        and rownum = 1;
    exception
      when no_data_found then l_policy_id := null;
    end;
  end if;
  
  begin
  select 
    	p.pol_ser || ' - ' || p.pol_num,
        ent.obj_name('CONTACT',pkg_policy.get_policy_holder_id(p.policy_id)),
		ent.obj_name('CONTACT',pkg_policy.get_policy_agent_id(p.policy_id)),
		p.region_id,
		pr.brief
  into :P_POL_NUM, :P_HOLDER, :P_AGENT, :P_REGION, :P_PRODUCT
  from ven_p_policy p, ven_p_pol_header ph, ven_t_product pr
  where p.policy_id = l_policy_id
    and ph.policy_header_id = p.pol_header_id
	and pr.product_id = ph.product_id;
  exception
    when no_data_found then :P_POL_NUM := ''; 
	                        :P_HOLDER:= ''; 
							:P_AGENT := ''; 
							:P_REGION:= ''; 
							:P_PRODUCT := '';
  end;
  
  -- Текущий пользователь системы
  begin
     select pkg_contact.get_fio_fmt(ent.obj_name('CONTACT', c.contact_id),4)
     into :P_USER_NAME
     from sys_user su, employee e, contact c
    where e.employee_id(+) = su.employee_id
     and e.contact_id = c.contact_id(+)
     and upper(su.sys_user_name) = upper(user)
     and rownum = 1;
  exception
       when no_data_found then :P_USER_NAME :='';
  end;
  
return (TRUE);
end;
]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>Дата</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>KocheYu</o:Author>
  <o:LastAuthor>skushenko</o:LastAuthor>
  <o:Revision>5</o:Revision>
  <o:TotalTime>50</o:TotalTime>
  <o:LastPrinted>2007-06-04T12:00:00Z</o:LastPrinted>
  <o:Created>2007-06-04T13:54:00Z</o:Created>
  <o:LastSaved>2007-06-04T14:19:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>197</o:Words>
  <o:Characters>1127</o:Characters>
  <o:Company>Renaissance Insurance Group</o:Company>
  <o:Lines>9</o:Lines>
  <o:Paragraphs>2</o:Paragraphs>
  <o:CharactersWithSpaces>1322</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
 <o:CustomDocumentProperties>
  <o:_AdHocReviewCycleID dt:dt="float">1517516409</o:_AdHocReviewCycleID>
  <o:_NewReviewCycle dt:dt="string"></o:_NewReviewCycle>
  <o:_EmailSubject dt:dt="string">Расторжения</o:_EmailSubject>
  <o:_AuthorEmail dt:dt="string">ngospodarik@renlife.com</o:_AuthorEmail>
  <o:_AuthorEmailDisplayName dt:dt="string">Gospodarik Nikolay</o:_AuthorEmailDisplayName>
  <o:_ReviewingToolsShownOnce dt:dt="string"></o:_ReviewingToolsShownOnce>
 </o:CustomDocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:DrawingGridHorizontalSpacing>5 пт</w:DrawingGridHorizontalSpacing>
  <w:DrawingGridVerticalSpacing>6,8 пт</w:DrawingGridVerticalSpacing>
  <w:DisplayHorizontalDrawingGridEvery>0</w:DisplayHorizontalDrawingGridEvery>
  <w:DisplayVerticalDrawingGridEvery>2</w:DisplayVerticalDrawingGridEvery>
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
 /* Font Definitions */
 @font-face
	{font-family:Wingdings;
	panose-1:5 0 0 0 0 0 0 0 0 0;
	mso-font-charset:2;
	mso-generic-font-family:auto;
	mso-font-pitch:variable;
	mso-font-signature:0 268435456 0 0 -2147483648 0;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
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
	font-size:10.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-font-kerning:0pt;
	mso-fareast-language:EN-US;}
p.MsoCommentText, li.MsoCommentText, div.MsoCommentText
	{mso-style-noshow:yes;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
span.MsoCommentReference
	{mso-style-noshow:yes;
	mso-ansi-font-size:8.0pt;
	mso-bidi-font-size:8.0pt;}
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
p.MsoCommentSubject, li.MsoCommentSubject, div.MsoCommentSubject
	{mso-style-noshow:yes;
	mso-style-parent:"Текст примечания";
	mso-style-next:"Текст примечания";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
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
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:21.0cm 842.0pt;
	margin:42.55pt 42.55pt 34.0pt 2.0cm;
	mso-header-margin:36.0pt;
	mso-footer-margin:36.0pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
 /* List Definitions */
 @list l0
	{mso-list-id:1560091561;
	mso-list-type:hybrid;
	mso-list-template-ids:-1830811496 -1538255260 67698691 67698693 67698689 67698691 67698693 67698689 67698691 67698693;}
@list l0:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F06E;
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	mso-ansi-font-size:8.0pt;
	font-family:Wingdings;}
@list l0:level2
	{mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l0:level3
	{mso-level-tab-stop:108.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l0:level4
	{mso-level-tab-stop:144.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l0:level5
	{mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l0:level6
	{mso-level-tab-stop:216.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l0:level7
	{mso-level-tab-stop:252.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l0:level8
	{mso-level-tab-stop:288.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l0:level9
	{mso-level-tab-stop:324.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1
	{mso-list-id:1918902131;
	mso-list-type:hybrid;
	mso-list-template-ids:1275523880 2000085090 67698691 67698693 67698689 67698691 67698693 67698689 67698691 67698693;}
@list l1:level1
	{mso-level-number-format:bullet;
	mso-level-text:\F071;
	mso-level-tab-stop:36.3pt;
	mso-level-number-position:left;
	margin-left:36.3pt;
	text-indent:-18.0pt;
	mso-ansi-font-size:8.0pt;
	font-family:Wingdings;}
@list l1:level2
	{mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1:level3
	{mso-level-tab-stop:108.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1:level4
	{mso-level-tab-stop:144.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1:level5
	{mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1:level6
	{mso-level-tab-stop:216.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1:level7
	{mso-level-tab-stop:252.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1:level8
	{mso-level-tab-stop:288.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l1:level9
	{mso-level-tab-stop:324.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
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
</style>
<![endif]-->
</head>

<body lang=RU style='tab-interval:36.0pt'>
<rw:foreach id="rg_main" src="G_main">
<div class=Section1>

<p class=MsoTitle><span style='font-size:14.0pt;mso-bidi-font-size:12.0pt'>Платежное
требование/</span><span lang=EN-US style='font-size:14.0pt;mso-bidi-font-size:
12.0pt;mso-ansi-language:EN-US'>Payment Request</span><span style='font-size:
14.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>

<p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=643
 style='width:17.0cm;margin-left:.4pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=167 style='width:125.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Дата/</span></b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Date</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>:<o:p></o:p></span></p>
  </td>
  <td width=180 style='width:135.0pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><rw:field id="f_reg_date" src="reg_date" /></span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;color:red;mso-ansi-language:
  RU'><o:p></o:p></span></p>
  </td>
  <td width=33 style='width:25.0pt;border:none;mso-border-left-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=107 style='width:80.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Номер/</span></b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Number</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>:<o:p></o:p></span></p>
  </td>
  <td width=133 style='width:100.0pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><rw:field id="f_num" src="num" /><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span style='font-size:8.0pt;mso-bidi-font-size:12.0pt;
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span style='font-size:8.0pt;mso-bidi-font-size:12.0pt;
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=695
 style='width:521.6pt;margin-left:-9.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1>Номер договора/</h1>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Contract</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>number</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_P_POL_NUM" src="P_POL_NUM" /></span><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1>Страхователь/</h1>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Policyholder<o:p></o:p></span></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_P_HOLDER" src="P_HOLDER" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Агент</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/<o:p></o:p></span></b></p>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-bidi-font-weight:bold'>Agent<o:p></o:p></span></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_P_AGENT" src="P_AGENT" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1>Сумма платежа/</h1>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Amount</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_amount" src="amount" /><o:p></o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Валюта</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/ </span></b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Currency<o:p></o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_fund" src="fund" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Сумма</span></b><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'> </span></b><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>прописью</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'> /</span></b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'> Amount in
  words<o:p></o:p></span></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_amount_speech" src="amount_speech" /></span><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1>Банк получателя/</h1>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Beneficiary</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Bank</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_bank" src="bank" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10;page-break-inside:avoid;height:30.6pt'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:30.6pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Страна,
  адрес банка<o:p></o:p></span></b></p>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>получателя/</span></b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Beneficiary</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Bank</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>address</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:30.6pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_bank_addr" src="bank_addr" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>БИК</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/</span></b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>BIC<o:p></o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_BIK" src="BIK" /><o:p></o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>корр</span></b></span><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>. </span></b><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>счет</span></b><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'> </span></b><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>банка</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/<o:p></o:p></span></b></p>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>correspondence bank
  account<o:p></o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_KORR" src="KORR" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1>Получатель<span lang=EN-US style='mso-ansi-language:EN-US'>/<o:p></o:p></span></h1>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Beneficiary<o:p></o:p></span></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_beneficiary" src="beneficiary" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border-top:solid windowtext 1.0pt;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:none;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>ИНН
  банка получателя/<o:p></o:p></span></b></p>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Beneficiary</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>tax</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>code</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_bank_INN" src="bank_INN" /><o:p></o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>расч</span></b></span><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>.
  счет получателя/<o:p></o:p></span></b></p>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Beneficiary</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>account</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_account_nr" src="account_nr" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:19'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>КПП</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/</span></b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>CPP<o:p></o:p></span></p>
  <p class=MsoNormal align=right style='text-align:right'><b><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt;mso-bidi-font-weight:bold'><rw:field id="f_bank_KPP" src="bank_KPP" /><o:p></o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:21'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:22;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Примечания</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/<o:p></o:p></span></b></p>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Comments</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=502 colspan=7 valign=top style='width:376.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:23'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  border-top:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:24'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Наименование
  <span class=SpellE>кост-центра</span>/ </span></b><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Name</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>of</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>cost</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>center</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><o:p></o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:25'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:26'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <h1>Код продукта/</h1>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Product</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>code</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_P_PRODUCT" src="P_PRODUCT" /></span><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;border:none;
  border-right:solid windowtext 1.0pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Код</span></b><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'> </span></b><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>региона</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/ <o:p></o:p></span></b></p>
  <p class=MsoNormal align=right style='text-align:right'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Region code<o:p></o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_P_REGION" src="P_REGION" /><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:27'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=164 colspan=2 valign=top style='width:122.9pt;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=183 colspan=3 valign=top style='width:137.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=156 colspan=2 valign=top style='width:116.7pt;border:none;
  mso-border-top-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:4.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <rw:getValue id="f_var" src="P_VARIANT"/>
 <tr style='mso-yfti-irow:28'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Вид</span></b><b><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt'> </span></b><b><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>платежа</span></b><b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/</span></b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Type of payment<o:p></o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;<% if (f_var.equals("1")) out.print("background:black;"); %>padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=297 colspan=2 valign=top style='width:223.1pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Перестрахование/</span></b><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'> </span><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Reinsurance</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=20 valign=top style='width:15.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=56 colspan=2 valign=top style='width:42.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=113 valign=top style='width:84.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:29'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=297 colspan=2 valign=top style='width:223.1pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=20 valign=top style='width:15.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=56 colspan=2 valign=top style='width:42.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=113 valign=top style='width:84.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:30;page-break-inside:avoid'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;<% if (f_var.equals("2")) out.print("background:black;"); %>padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=486 colspan=6 valign=top style='width:364.8pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Выплата страхового обеспечения, возмещения /</span></b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'> </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Claim</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>, </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>surrender</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>, </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>maturity</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:31'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=297 colspan=2 valign=top style='width:223.1pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=20 valign=top style='width:15.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=56 colspan=2 valign=top style='width:42.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=113 valign=top style='width:84.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:32'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;<% if (f_var.equals("3")) out.print("background:black;"); %>padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=297 colspan=2 valign=top style='width:223.1pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Агентское вознаграждение/</span></b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'> </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Brokerage</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=20 valign=top style='width:15.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=56 colspan=2 valign=top style='width:42.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=113 valign=top style='width:84.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:33'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=297 colspan=2 valign=top style='width:223.1pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=20 valign=top style='width:15.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=56 colspan=2 valign=top style='width:42.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=113 valign=top style='width:84.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:34'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;<% if (f_var.equals("4")) out.print("background:black;"); %>padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=297 colspan=2 valign=top style='width:223.1pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Возврат премии/ </span></b><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Premium</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>return</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=20 valign=top style='width:15.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=56 colspan=2 valign=top style='width:42.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=113 valign=top style='width:84.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:35'>
  <td width=193 valign=top style='width:145.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:solid windowtext .5pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=297 colspan=2 valign=top style='width:223.1pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=20 valign=top style='width:15.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=56 colspan=2 valign=top style='width:42.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=113 valign=top style='width:84.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:36;mso-yfti-lastrow:yes'>
  <td width=193 valign=top style='width:145.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=16 valign=top style='width:11.8pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;<% if (f_var.equals("5")) out.print("background:black;"); %>padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=297 colspan=2 valign=top style='width:223.1pt;border:none;
  mso-border-left-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Экспертиза</span></b><b><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/</span></b><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'> Examination<o:p></o:p></span></p>
  </td>
  <td width=20 valign=top style='width:15.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=56 colspan=2 valign=top style='width:42.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=113 valign=top style='width:84.7pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=193 style='border:none'></td>
  <td width=16 style='border:none'></td>
  <td width=148 style='border:none'></td>
  <td width=149 style='border:none'></td>
  <td width=20 style='border:none'></td>
  <td width=13 style='border:none'></td>
  <td width=43 style='border:none'></td>
  <td width=113 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal><span style='font-size:4.0pt;mso-bidi-font-size:12.0pt;
mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=696
 style='width:521.65pt;margin-left:-9.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:27.7pt'>
  <td width=182 valign=top style='width:136.3pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.7pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Налогообложение платежа/</span></b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'> </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Tax</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>deductible</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>:<o:p></o:p></span></p>
  </td>
  <td width=25 valign=top style='width:18.7pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.7pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=313 valign=top style='width:234.75pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:27.7pt'>
  <p class=MsoNormal style='margin-left:18.0pt'><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:18.3pt'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;font-family:"Wingdings 2";
  mso-ascii-font-family:"Times New Roman";mso-hansi-font-family:"Times New Roman";
  mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'><span
  style='mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'>&pound;</span></span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><span
  style='mso-tab-count:1'>    </span>Н<span class=GramE>ДС вкл</span>ючен/ </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>VAT</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Included</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=169 valign=bottom style='width:126.75pt;border:none;border-bottom:
  solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:27.7pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Сумма НДС/ </span><span lang=EN-US style='font-size:
  10.0pt;mso-bidi-font-size:12.0pt'>VAT</span><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'> </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>amount</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:17.95pt'>
  <td width=182 valign=top style='width:136.3pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.95pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=25 valign=top style='width:18.7pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.95pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=313 valign=top style='width:234.75pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.95pt'>
  <p class=MsoNormal style='margin-left:18.0pt'><span style='font-size:5.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:18.0pt'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;font-family:"Wingdings 2";
  mso-ascii-font-family:"Times New Roman";mso-hansi-font-family:"Times New Roman";
  mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'><span
  style='mso-char-type:symbol;mso-symbol-font-family:"Wingdings 2"'>&cent;</span></span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><span
  style='mso-tab-count:1'>    </span></span><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>НДС</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'> </span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>не</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'> </span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>взимается</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>/ VAT Not Applicable<o:p></o:p></span></p>
  </td>
  <td width=169 valign=top style='width:126.75pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:17.95pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:5.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
12.0pt'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=696
 style='width:521.65pt;margin-left:-9.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:18.95pt'>
  <td width=238 valign=top style='width:178.55pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:18.95pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Подготовлено / </span></b><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Prepared</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>by</span><b><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td width=249 valign=top style='width:186.45pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:18.95pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:
  12.0pt'><rw:field id="f_P_USER_NAME" src="P_USER_NAME" /><o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=202 valign=top style='width:151.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:18.95pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:16.25pt'>
  <td width=238 valign=top style='width:178.55pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.25pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Одобрено/</span></b><span lang=EN-US style='font-size:
  10.0pt;mso-bidi-font-size:12.0pt'>Accepted</span><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'> </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>by</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>:<o:p></o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=249 valign=top style='width:186.45pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.25pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=202 valign=top style='width:151.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.25pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=238 valign=top style='width:178.55pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'>Главный бухгалтер/</span></b><span style='font-size:
  10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'> </span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Chief</span><span
  lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'> </span><span lang=EN-US style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>accountant</span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p></o:p></span></p>
  </td>
  <td width=249 valign=top style='width:186.45pt;border:none;border-bottom:
  solid windowtext 1.0pt;mso-border-bottom-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=202 valign=top style='width:151.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='tab-stops:66.0pt center 79.1pt'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='tab-stops:66.0pt center 79.1pt'><span class=SpellE><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Ланге</span></span><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'> О.В.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;height:41.9pt'>
  <td width=238 valign=top style='width:178.55pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:41.9pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Операционный
  директор<o:p></o:p></span></b></p>
  </td>
  <td width=249 valign=top style='width:186.45pt;border:none;border-bottom:
  solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .5pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-bottom-alt:solid windowtext .5pt;padding:
  0cm 5.4pt 0cm 5.4pt;height:41.9pt'>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;
  mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=202 valign=top style='width:151.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:41.9pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU'>Грузинов Ю. Т.<o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>

</div>
</rw:foreach>
</body>

</html>

</rw:report>
