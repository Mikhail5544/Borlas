<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="letter_error_premium" DTDVersion="9.0.2.0.10">
  <data>
    <userParameter name="P_PID"/>
     <dataSource name="Q_3">
      <select>
      <![CDATA[select rownum rec_number,
       ent.obj_name('CONTACT',ppc.contact_id) contact_name,
       nvl(pp.notice_num,'...') num,
       to_char(ph.start_date,'dd.mm.yyyy') start_date,
       to_char(ds.change_date,'dd.mm.yyyy') decline_date,
       decode(pkg_payment.get_to_pay_ret_amount(ph.policy_header_id),null,'0','0','0',to_char(pkg_payment.get_to_pay_ret_amount(ph.policy_header_id),'999999999D99')) summa
      from 
       ven_p_policy_contact ppc,
       ven_t_contact_pol_role cpr,
       ven_p_pol_header ph,
       ven_p_policy pp,
       ven_doc_status ds
     where cpr.id = ppc.contact_policy_role_id
       and cpr.brief = 'Страхователь'
       and ppc.policy_id=ph.policy_id
       and ph.policy_header_id=pp.pol_header_id
       and ds.document_id=pp.policy_id
       and ds.change_date=(select max(ds1.change_date) from ven_doc_status ds1 where ds1.document_id=:P_PID)
        and pp.policy_id=:P_PID]]>
      </select>
      <group name="group_data">
        <dataItem name="rec_number" oracleDatatype="number"/>
      </group>
    </dataSource>
  </data>
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
<title>Письмо об отказе в страховании (по результатам мед. обследования)</title>
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;
	mso-font-charset:1;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:0 0 0 0 0 0;}
@font-face
	{font-family:Garamond;
	panose-1:2 2 4 4 3 3 1 1 8 3;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Garamond","serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
h3
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-link:"Заголовок 3 Знак";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:3;
	font-size:13.0pt;
	font-family:"Arial","sans-serif";
	mso-fareast-font-family:"Times New Roman";}
p.MsoFootnoteText, li.MsoFootnoteText, div.MsoFootnoteText
	{mso-style-noshow:yes;
	mso-style-unhide:no;
	mso-style-link:"Текст сноски Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman","serif";
	mso-fareast-font-family:"Times New Roman";}
span.MsoFootnoteReference
	{mso-style-noshow:yes;
	mso-style-unhide:no;
	vertical-align:super;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{mso-style-unhide:no;
	mso-style-link:"Основной текст Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Garamond","serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
span.3
	{mso-style-name:"Заголовок 3 Знак";
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"Заголовок 3";
	mso-ansi-font-size:13.0pt;
	mso-bidi-font-size:13.0pt;
	font-family:"Arial","sans-serif";
	mso-ascii-font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	mso-fareast-language:RU;
	font-weight:bold;}
span.a
	{mso-style-name:"Основной текст Знак";
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"Основной текст";
	mso-bidi-font-size:10.0pt;
	font-family:"Garamond","serif";
	mso-ascii-font-family:Garamond;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Garamond;
	mso-bidi-font-family:"Times New Roman";}
span.a0
	{mso-style-name:"Текст сноски Знак";
	mso-style-noshow:yes;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"Текст сноски";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman","serif";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
.MsoChpDefault
	{mso-style-type:export-only;
	mso-default-props:yes;
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;
	mso-fareast-language:EN-US;}
.MsoPapDefault
	{mso-style-type:export-only;
	margin-bottom:10.0pt;
	line-height:115%;}
 /* Page Definitions */
@page Section1
	{size:595.3pt 841.9pt;
	margin:2.0cm 42.5pt 2.0cm 3.0cm;
	mso-header-margin:35.4pt;
	mso-footer-margin:35.4pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
-->
</style>
</head>

<body lang=RU style='tab-interval:35.4pt'>
<% 
  String ret_sum = new String("0");
%>

<rw:foreach id="fi1" src="group_data">
<rw:getValue id="j_e_sum" src="summa"/>
  <% ret_sum = new String(j_e_sum); %>
<div class=Section1>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><img width=156 height=56
src="<%=g_ImagesRoot%>/letter_remind/image001.jpg"></p>
<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><b><i>Уважаемый(ая) 
<rw:field id="f_contact_name" src="contact_name"/>!</i></b></p>

<p class=MsoBodyText style='margin-top:12.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>К сожалению,
вынуждены сообщить Вам, что, основываясь на проведенной нами процедуре оценки
степени страхового риска (изучения предоставленной Вами в Заявлении на
страхование информации и результатов медицинского обследования), мы вынуждены были 
принять решение об отказе от дальнейшего страхования по Вашему договору. 
О возможности принятия компанией отрицательного решения и отказе от 
дальнейшего страхования  по результатам оценки степени страхового риска 
Вы были предупреждены в заполненном Вами Заявлении на страхование. Настоящим 
письмом уведомляем Вас, что договор страхования, заключенный на основании Вашего 
Заявления на страхование № <rw:field id="f_num" src="num"/>, прекращает свое действие
с <i><rw:field id="f_decline_date" src="decline_date"/></i>.</span></p>

<p class=MsoBodyText style='margin-top:12.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Компания
приносит Вам свои извинения, и если Вы заинтересованы в получении информации о
других видах страхования, которые предлагает наша Компания, просим Вас
связаться с нами, либо с Вашим страховым консультантом.</span></p>

<%if (!ret_sum.equals("0"))
{%>
<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Сумма 
уплаченной Вами страховой премии будет
возвращена на указанный Вами в Заявлении на страхование расчетный счет. Если по
каким-то причинам Вы не указали в Заявлении необходимые данные или произошло
изменение этих данных, просим Вас направить в адрес нашей Компании письмо с
указанием реквизитов (наименование
банка, БИК, ИНН, корр. счет, расчетный счет, лицевой счет), 
на которые необходимо произвести перечисление
средств.</span></p>
<%}%>

<p class=MsoBodyText style='margin-top:8.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Мы
рекомендуем Вам проконсультироваться с Вашим лечащим врачом. По Вашему запросу
Вам может быть предоставлена копия документов по результатам пройденного
медицинского обследования.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>С уважением,</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/image003.jpg" alt="Загрядская Елена"></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Начальник
Операционного Управления</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Загрядская Елена</span></i></b></p>
</div>
</rw:foreach>
</body>
</html>
</rw:report>