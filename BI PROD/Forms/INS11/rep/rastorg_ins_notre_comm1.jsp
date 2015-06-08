<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251"%>

<rw:report id="report">
<rw:objects id="objects">

<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="rastorg_insurer_notretold" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="afterpform" unitOfMeasurement="centimeter">

  <data>
    <userParameter name="P_PID"/>
    <userParameter name="address" datatype="character" width="300"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="date_zad" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
 
     <dataSource name="Q_2">
      <select>
      <![CDATA[select rownum rn1,
         ent.obj_name('DOCUMENT',ph.policy_header_id) dog_num,
         ent.obj_name('CONTACT',ppc.contact_id) contact_name,
         to_char(nvl(ds.change_date,sysdate),'dd.mm.yyyy') decline_date
      from ven_p_policy pp,
         ven_p_pol_header ph,
         ven_p_policy_contact ppc,
         ven_t_contact_pol_role cpr,
         ven_doc_status ds
      where ppc.policy_id=pp.policy_id
          and cpr.id = ppc.contact_policy_role_id
          and cpr.brief = 'Страхователь'
          and ph.policy_header_id=pp.pol_header_id
         and ds.document_id=pp.policy_id
         and ds.change_date=(select max(ds1.change_date) from ven_doc_status ds1 where ds1.document_id=:P_PID)
          and pp.policy_id=:P_PID]]>
      </select>
      <group name="group_data">
        <dataItem name="rn1"/>
     </group>
    </dataSource>
    
  </data>

<programUnits>
    <function name="afterpform">
      <textSource>
      <![CDATA[function AfterPForm return boolean is
begin

 begin
   select aa.address_name 
into :address
      from ven_p_policy pp,
         ven_p_pol_header ph,
         ven_p_policy_contact ppc,
         ven_t_contact_pol_role cpr,
         ven_doc_status ds,
v_cn_contact_address aa
      where ppc.policy_id=pp.policy_id
          and cpr.id = ppc.contact_policy_role_id
          and cpr.brief = 'Страхователь'
          and ph.policy_header_id=pp.pol_header_id
         and ds.document_id=pp.policy_id
and aa.contact_id(+) = ppc.contact_id
and rownum = 1
         and ds.change_date=(select max(ds1.change_date) from ven_doc_status ds1 where ds1.document_id=:P_PID)
          and pp.policy_id=:P_PID;
  exception
      when no_data_found then :address := '';
  end;


begin
select to_char(decode(ss.plan_date,null,ss.due_date,ss.plan_date),'dd.mm.yyyy')
into :date_zad
from p_policy ph,
     v_policy_payment_schedule ss 
where ph.policy_id = :P_PID
      and ph.pol_header_id = ss.pol_header_id(+)
      and ss.doc_status_ref_name in ('К оплате','Новый')
      and rownum = 1;
exception
      when no_data_found then :date_zad := '';

end;


return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>


</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:m="http://schemas.microsoft.com/office/2004/12/omml"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>Адрес получателя:____________________</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>sitniol</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>V</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>3</o:TotalTime>
  <o:Created>2008-08-22T05:24:00Z</o:Created>
  <o:LastSaved>2008-08-22T05:24:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>213</o:Words>
  <o:Characters>1216</o:Characters>
  <o:Lines>10</o:Lines>
  <o:Paragraphs>2</o:Paragraphs>
  <o:CharactersWithSpaces>1427</o:CharactersWithSpaces>
  <o:Version>11.8107</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
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
	{font-family:Garamond;
	panose-1:2 2 4 4 3 3 1 1 8 3;
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
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Garamond;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
p.MsoFootnoteText, li.MsoFootnoteText, div.MsoFootnoteText
	{mso-style-noshow:yes;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
span.MsoFootnoteReference
	{mso-style-noshow:yes;
	vertical-align:super;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Garamond;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
 /* Page Definitions */
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
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="2050"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

<rw:foreach id="f1" src="group_data">

<div class=Section1>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='margin-left:167.4pt;border-collapse:collapse;border:none;mso-border-alt:
 solid windowtext .5pt;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=96 valign=top style='width:71.85pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right;line-height:150%'><b><span
  style='mso-bidi-font-style:italic'>Адрес получателя:<o:p></o:p></span></b></p>
  </td>
  <td width=319 valign=top style='width:239.3pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right;line-height:150%'><span
  lang=EN-US style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold;
  mso-bidi-font-style:italic'><o:p><rw:field id="" src="address"/></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes'>
  <td width=96 valign=top style='width:71.85pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right;line-height:150%'><b><span
  style='mso-bidi-font-style:italic'>Адресат:<o:p></o:p></span></b></p>
  </td>
  <td width=319 valign=top style='width:239.3pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right;line-height:150%'><span
  lang=EN-US style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold;
  mso-bidi-font-style:italic'><o:p><rw:field id="f_contact_name" src="contact_name"/></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal align=right style='text-align:right;line-height:150%'><span
lang=EN-US style='mso-ansi-language:EN-US;mso-bidi-font-weight:bold;mso-bidi-font-style:
italic'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal align=right style='text-align:right;line-height:150%'><b><i><o:p>&nbsp;</o:p></i></b></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><b><i>Уважаемый
(ая) <rw:field id="f_contact_name" src="contact_name"/>!<o:p></o:p></i></b></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><i><span
style='font-size:14.0pt;mso-bidi-font-size:10.0pt;line-height:150%;mso-bidi-font-weight:
bold'><o:p>&nbsp;</o:p></span></i></p>

<p class=MsoBodyText style='margin-top:12.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Сообщаем Вам,
что в соответствии с Вашим заявлением на расторжение<span
style='mso-spacerun:yes'> </span>договор страхования № <rw:field id="f_dog_num" src="dog_num"/> прекращает свое
действие<span style='mso-spacerun:yes'>  </span>на основании<span
style='mso-spacerun:yes'>  </span>п. 11.2.2. Общих условий страхования (по
программе "Гармония жизни") с <i><rw:field id="f_decline_date" src="decline_date"/></i></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Согласно п.
11.3 Общих условий страхования (по программе "Гармония жизни"), выплате подлежит «выкупная
сумма в пределах сформированного в установленном порядке страхового резерва по
основной программе страхования на момент прекращения действия договора
страхования, и часть страховой премии в размере доли последнего оплаченного
страхового взноса по дополнительным программам страхования, пропорционально не
истекшей части оплаченного периода».<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Согласно
Таблице выкупных сумм по основной программе, размер сформированного страхового
резерва на момент расторжения договора равен нулю. Последний оплаченный период
по Вашему договору истек <o:p><rw:field id="" src="date_zad"/></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Таким
образом, сумма страховой премии к возврату в связи с досрочным прекращением
договора № <rw:field id="f_dog_num" src="dog_num"/> <span style='mso-spacerun:yes'> </span>равна нулю.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Мы сожалеем о
необходимости пре</span><span lang=EN-US style='font-size:12.0pt;line-height:
150%;mso-ansi-language:EN-US;mso-fareast-language:RU'>c</span><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'> качестве
нашего клиента. Если Вы заинтересованы в возобновлении договорных отношений с
нашей Компанией или хотите получить информацию о других видах страхования,
которые предлагает ООО «СК «Ренессанс Жизнь», Вы можете связаться с нами либо с
Вашим страховым консультантом.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:12.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'><o:p>&nbsp;</o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><b><i><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>С уважением,<o:p></o:p></span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/image005.jpg" alt="Ященко Игорь"></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><b><i><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Директор
Операционного Управления<o:p></o:p></span></i></b></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><b><i><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Ященко И.В. <o:p></o:p></span></i></b></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

</div>
</rw:foreach>
</body>

</html>
</rw:report>
