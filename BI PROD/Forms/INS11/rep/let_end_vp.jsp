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
      pp.notice_num notice_num,
      to_char(sysdate,'dd.mm.yyyy') p_sysdate,
      to_char(sysdate,'mm') p_month,
      to_char(sysdate,'yyyy') p_year,
       case when ph.start_date > to_date('01-01-2009','dd.mm.yyyy') then 1 else 0 end flag,
       to_char(nvl(pkg_policy.get_waiting_per_end_date(pp.policy_id,pp.waiting_period_id,pp.start_date),sysdate),'dd.mm.yyyy') as date_wait,
       to_char(nvl(pkg_policy.get_waiting_per_end_date(pp.policy_id,pp.waiting_period_id,pp.start_date),sysdate)+1,'dd.mm.yyyy') as date_rast,
       ent.obj_name('CONTACT',ppc.contact_id) pol_holder,
       decode(pkg_payment.get_to_pay_ret_amount(ph.policy_header_id),null,'0','0','0',to_char(pkg_payment.get_to_pay_ret_amount(ph.policy_header_id),'999999999D99')) summa,
       NVL(ca.name, pkg_contact.get_address_name(ca.id)) adr_name
from ven_p_policy pp,
     ven_p_pol_header ph,
     ven_p_policy_contact ppc,
     ven_t_contact_pol_role cpr,
     cn_person per,
     cn_address ca
where ph.policy_header_id=pp.pol_header_id
      and ppc.policy_id=pp.policy_id
      and cpr.id = ppc.contact_policy_role_id
      and cpr.brief = 'Страхователь'
      and ppc.contact_id = per.contact_id
      and pkg_contact.get_primary_address(ppc.contact_id) = ca.ID
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

<br><br><br><br><br><br><br>
<table width="52%" border="1" align="right">
 <tr>
  <td align=right style="font-size: 13;">Кому:</td> 
  <td style="font-size: 13;"><rw:field id="" src="POL_HOLDER"/></td> 
 </tr> 
 <tr>
  <td align=right style="font-size: 13;">Куда:</td>
  <td style="font-size: 13;"><rw:field id="" src="adr_name"/></td> 
 </tr>

</table>

<br>


<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<b><span style='mso-bidi-font-size:11.0pt;font-family:Times New Roman'>Дата: <rw:field id="" src="P_SYSDATE"/>
</span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<b><span style='mso-bidi-font-size:11.0pt;font-family:Times New Roman'>Исх.№ __________-<rw:field id="" src="p_month"/>/<rw:field id="" src="p_year"/></span></b></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>&nbsp;</p>

<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:center;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'><i><b>Уважаемый (ая) <rw:field id="" src="POL_HOLDER"/>!</i></b></span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>&nbsp;</p>

<rw:getValue id="flg" src="flag"/>
<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'>Сообщаем Вам о том, что согласно условиям Договора
страхования № <rw:field id="" src="notice_num"/> установленный 
<% if (flg.equals("0")) {%>для оценки степени страхового риска выжидательный период <%} else {%> период оценки страхового риска <%} %>
истек <rw:field id="" src="date_wait"/> г.</span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'>К сожалению, до указанного момента Вами 
не были предоставлены заполненные анкеты, необходимые для достоверной оценки степени страхового риска, и/или 
не было пройдено медицинское обследование.</span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'>Согласно 
<% if (flg.equals("0")) {%>п. 5.8 Правил страхования жизни <%} else {%>п.5.6.2 Полисных условий<%} %>, которые являются составной и 
неотъемлемой частью договора страхования, Компания имеет право проверить сведения, указанные Страхователем в 
заявлении на страхование и имеющие существенное значение для определения вероятности наступления страхового 
случая и размера возможных убытков, а также запросить у Страхователя дополнительные сведения о состоянии здоровья, 
опасных видах деятельности, доходах и финансовых обязательствах, а также требовать 
в течение <% if (flg.equals("0")) {%>выжидательного периода<%} else {%>периода оценки страхового риска<%} %> прохождения Застрахованным 
медицинского обследования в необходимом объеме и указанном лечебном учреждении. В случае, если Компания не 
получает дополнительную информацию, необходимую для оценки риска, <% if (flg.equals("0")) {%>Компания вправе расторгнуть 
договор страхования в одностороннем порядке<%} else {%>договор страхования прекращает свое действие<%} %>.</span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'>С учетом вышеуказанного, договор страхования 
№ <rw:field id="" src="notice_num"/> <% if (flg.equals("0")) {%>расторгнут Компанией <rw:field id="" src="date_rast"/><%} else {%>прекратил свое действие с <rw:field id="" src="date_rast"/><%} %>.</span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'>В связи с расторжением договора страхования 
Вам будет возвращена сумма, причитающаяся к возврату в соответствии с <% if (flg.equals("0")) {%>Правилами страхования<%} else {%>Полисными условиями<%} %>
<rw:field id="" src="summa"/>. Для перечисления сумм, причитающих к выплате в связи с расторжением договора страхования, 
просим предоставить Ваши банковские реквизиты.</span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-justify:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<span style='mso-bidi-font-size:12.0pt;font-family:Times New Roman'>В случае если документы Вами были предоставлены, 
Вы ответили на все запросы Компании и/или прошли медицинское обследование, а Компания не располагает об этом информацией, 
или Вы не получили информацию, что именно необходимо предоставить для оценки степени риска или какие именно действия 
необходимо совершить, мы просим Вас срочно связаться с нами по телефону (495) 981-29-81 либо со страховым представителем 
Страховой компании "Ренессанс Жизнь" в любом филиале / агентстве Компании.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>&nbsp;</p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:10.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>С наилучшими пожеланиями,</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/podpis0001.jpg" alt="Гусев Владислав"></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:9.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Директор Операционного департамента</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:9.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Гусев Владислав</span></i></b></p>

</div>
</rw:foreach>
</body>

</html>

<!--
</rw:report> 
-->