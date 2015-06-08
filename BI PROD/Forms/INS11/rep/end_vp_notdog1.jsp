<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="end_vp_no_docs" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="afterpform" unitOfMeasurement="centimeter">
  <data>
    <userParameter name="P_PID"/>
    <userParameter name="address" datatype="character" width="300"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_2">
      <select>
      <![CDATA[select rownum rn1,
      ent.obj_name('DOCUMENT',ph.policy_header_id) dog_num,
      decode(pp.notice_ser, null, pp.notice_num, pp.notice_ser || '-' || pp.notice_num) notice_num,
       pp.start_date,
       to_char(nvl(pkg_policy.get_waiting_per_end_date(pp.policy_id,pp.waiting_period_id,pp.start_date),sysdate),'dd.mm.yyyy') as data_wait,
       to_char(nvl(pkg_policy.get_waiting_per_end_date(pp.policy_id,pp.waiting_period_id,pp.start_date),sysdate)+1,'dd.mm.yyyy') as data_rast,
       ent.obj_name('CONTACT',ppc.contact_id) contact_name,
       decode(pkg_payment.get_to_pay_ret_amount(ph.policy_header_id),null,'0','0','0',to_char(pkg_payment.get_to_pay_ret_amount(ph.policy_header_id),'999999999D99')) summa
from ven_p_policy pp,
     ven_p_pol_header ph,
     ven_p_policy_contact ppc,
     ven_t_contact_pol_role cpr
where ph.policy_header_id=pp.pol_header_id
      and ppc.policy_id=pp.policy_id
      and cpr.id = ppc.contact_policy_role_id
      and cpr.brief = 'Страхователь'
      and  pp.policy_id=:P_PID]]>
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
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="PersonName"/>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>sitniol</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>V</o:LastAuthor>
  <o:Revision>3</o:Revision>
  <o:TotalTime>7</o:TotalTime>
  <o:Created>2008-08-28T11:04:00Z</o:Created>
  <o:LastSaved>2008-08-28T11:04:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>299</o:Words>
  <o:Characters>1705</o:Characters>
  <o:Lines>14</o:Lines>
  <o:Paragraphs>3</o:Paragraphs>
  <o:CharactersWithSpaces>2001</o:CharactersWithSpaces>
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
</xml><![endif]--><!--[if !mso]><object
 classid="clsid:38481807-CA0E-42D2-BF39-B33AF135CC4D" id=ieooui></object>
<style>
st1\:*{behavior:url(#ieooui) }
</style>
<![endif]-->
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
<![endif]-->
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

<p class=MsoNormal align=right style='text-align:right;line-height:150%'><b><i><o:p>&nbsp;</o:p></i></b></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><b><i>Уважаемый
(ая) <rw:field id="f_contact_name" src="contact_name"/>!<o:p></o:p></i></b></p>

<p class=MsoNormal style='margin-right:-18.25pt;text-align:justify;line-height:
150%'><span style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:
RU'>Сообщаем Вам о том, что согласно условиям Договора страхования (Соглашения о временном страховом покрытии)
 № <rw:field id="f_not_num" src="notice_num"/>,<span
style='mso-spacerun:yes'> </span>установленный для оценки степени страхового
риска выжидательный период, равный 60-ти календарным дням, истек <rw:field id="f_data_wait" src="data_wait"/>
г. К сожалению, до указанного момента Вами не были предоставлены заполненные
анкеты, необходимые для достоверной оценки степени страхового риска, и/или не было
пройдено медицинское обследование.</span><b><i><span style='mso-bidi-font-size:
11.0pt;line-height:150%'><o:p></o:p></span></i></b></p>

<p class=MsoBodyText style='margin-top:8.0pt;margin-right:-18.25pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:150%'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>Согласно
п. 5.8 Правил страхования жизни / п. 6.8 Правил страхования от несчастных
случаев и болезней, которые являются составной и неотъемлемой частью договора
страхования, Страховщик имеет право расторгнуть договор страхования в
одностороннем порядке в случае, если документы, необходимые для оценки степени
страхового риска, так и не будут предоставлены и/или медицинское обследование
не будет пройдено до окончания выжидательного периода. <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;margin-right:-18.25pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:150%'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>С
учетом вышеуказанного, договор страхования <rw:field id="f_dog_num" src="dog_num"/> расторгнут
Страховщиком <rw:field id="f_data_rast" src="data_rast"/>.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;margin-right:-18.25pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:150%'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>В
связи с расторжением договора страхования Вам будет возвращена сумма в размере 
<rw:field id="f_summa" src="summa"/>, за вычетом расходов Страховщика на Ваше медицинское
обследование (если такое медицинское обследование уже было Вами пройдено по
направлению Страховщика). Для перечисления сумм, причитающих к выплате в связи
с расторжением договора страхования, просим предоставить необходимые для этого
платежные реквизиты.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;margin-right:-18.25pt;margin-bottom:
0cm;margin-left:0cm;margin-bottom:.0001pt;line-height:150%'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>В
случае если документы Вами были все-таки предоставлены, Вы ответили на все
запросы Страховщика и/или прошли медицинское обследование, а Страховщик не
располагает об этом информацией, или Вы не получили информацию, что именно
необходимо предоставить для оценки степени риска или какие именно действия
необходимо совершить, мы просим Вас срочно связаться с нами по телефону (495) 981-29-81
<b style='mso-bidi-font-weight:normal'>или по телефону </b></span><span
style='font-size:9.0pt;line-height:150%;font-family:Arial'>8-800-200-5433</span><b
style='mso-bidi-font-weight:normal'><span style='mso-bidi-font-size:11.0pt;
line-height:150%;mso-fareast-language:RU'> (по последнему номеру звонок
бесплатный)</span></b><span style='mso-bidi-font-size:11.0pt;line-height:150%;
mso-fareast-language:RU'>.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>С
уважением,<o:p></o:p></span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/image005.jpg" alt="Ященко Игорь"></p>


<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>Директор
Операционного Управления <o:p></o:p></span></i></b></p>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><b
style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>Ященко
<st1:PersonName w:st="on">Игорь</st1:PersonName><o:p></o:p></span></i></b></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

</div>
</rw:foreach>
</body>

</html>
</rw:report>
