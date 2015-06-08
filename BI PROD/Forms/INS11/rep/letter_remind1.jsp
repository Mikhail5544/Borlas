<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="letter_remind1" DTDVersion="9.0.2.0.10">
  <data>
    <userParameter name="P_SID"/>
    <userParameter name="P_UID"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select count(*) rec_count
  from notif_letter_rep
 where sessionid = :P_SID]]>
      </select>
      <group name="group_count">
        <dataItem name="rec_count"/>
      </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[select rownum rn2,
  c.name || ' ' || c.first_name || ' ' || c.middle_name name,
  eh.appointment,
nvl(pkg_contact.get_primary_tel(c.contact_id),pkg_rep_utils.contact_email(c.contact_id)) as tel  
from sys_user u, employee e, employee_hist eh, contact c
where e.employee_id = u.employee_id
  and eh.employee_id = e.employee_id
  and c.contact_id = e.contact_id
  and eh.date_hist = (select max(date_hist) from employee_hist where employee_id = e.employee_id)
  and eh.is_kicked != 1
  and u.sys_user_id = :P_UID]]>
      </select>
      <group name="group_user">
        <dataItem name="rn2"/>
      </group>
    </dataSource>
    <dataSource name="Q_3">
      <select>
      <![CDATA[select rownum rec_number,
       vlp.payment_period,
       vlp.contact_name,
       to_char(vlp.grace_date, 'dd.mm.yyyy') grace_date,
       ent.obj_name('DOCUMENT', vlp.policy_id) pol_num,
       to_char(vlp.amount,'999999999D99') amount,
       vlp.fund,
       to_char(vlp.grace_date+45,'dd.mm.yyyy') as grace_period
    from v_letters_payment vlp,
       notif_letter_rep nlr
 where vlp.document_id = nlr.document_id
       and nlr.sessionid = :P_SID]]>
      </select>
      <group name="group_data">
        <dataItem name="rec_number"/>
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
<title>Письмо-напоминаение об уплате взноса 1</title>
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Cambria Math";
	panose-1:2 4 5 3 5 4 6 3 2 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:-1610611985 1107304683 0 0 159 0;}
@font-face
	{font-family:Tahoma;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:1627400839 -2147483648 8 0 66047 0;}
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
a:link, span.MsoHyperlink
	{mso-style-unhide:no;
	color:blue;
	text-decoration:underline;
	text-underline:single;}
a:visited, span.MsoHyperlinkFollowed
	{mso-style-noshow:yes;
	mso-style-priority:99;
	color:purple;
	mso-themecolor:followedhyperlink;
	text-decoration:underline;
	text-underline:single;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-link:"Текст выноски Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:"Tahoma","sans-serif";
	mso-fareast-font-family:"Times New Roman";
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
	{mso-style-name:"Текст выноски Знак";
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"Текст выноски";
	mso-ansi-font-size:8.0pt;
	mso-bidi-font-size:8.0pt;
	font-family:"Tahoma","sans-serif";
	mso-ascii-font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Tahoma;
	mso-bidi-font-family:Tahoma;}
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
@page Section1
	{size:595.3pt 841.9pt;
	margin:21.3pt 42.5pt 42.55pt 3.0cm;
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
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
	{mso-style-name:"Обычная таблица";
	mso-tstyle-rowband-size:0;
	mso-tstyle-colband-size:0;
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-qformat:yes;
	mso-style-parent:"";
	mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
	mso-para-margin-top:0cm;
	mso-para-margin-right:0cm;
	mso-para-margin-bottom:10.0pt;
	mso-para-margin-left:0cm;
	line-height:115%;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	font-family:"Calibri","sans-serif";
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-fareast-language:EN-US;}
</style>
<![endif]-->
</head>

<body lang=RU link=blue vlink=purple style='tab-interval:35.4pt'>
<% 
  int rec_count_all = 0;
  int rec_count_current = 0;
  String empl_name = new String("-");
  String empl_pos = new String("-");
%>
<rw:foreach id="fi0" src="group_count">
  <rw:getValue id="j_rec_count" src="rec_count"/>
  <% rec_count_all = new Integer(j_rec_count).intValue(); %>
</rw:foreach>
<rw:foreach id="fi2" src="group_user">
  <rw:getValue id="j_e_name" src="name"/>
  <rw:getValue id="j_e_app" src="appointment"/>
  <% empl_name = new String(j_e_name); %>
  <% empl_pos  = new String(j_e_app); %>
</rw:foreach>

<rw:foreach id="fi1" src="group_data">
<div class=Section1>

<h3 align=center style='text-align:center'><u><span
style='font-family:"Times New Roman","serif";color:#FFCC00'>ПИСЬМО-НАПОМИНАНИЕ
ОБ УПЛАТЕ ВЗНОСА 1</span></u></h3>
<p>&nbsp;</p>
<p class=MsoNormal style='text-align:justify;line-height:150%'><b><i>Уважаемый(ая) <rw:field id="f_contact_name" src="contact_name"/>!</i></b></p>
<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Данное письмо
подлежит прочтению только в случае, если у Вас есть задолженность по уплате
взносов по договору № <rw:field id="f_pol_num" src="pol_num"/>. <b>В случае если уплата страхового взноса Вами уже была
произведена, мы благодарим Вас за сотрудничество и просим не принимать во
внимание настоящее письмо.</b></span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Напоминаем
Вам о том, что согласно условиям договора страхования № <rw:field id="f_pol_num" src="pol_num"/>,
Вам необходимо было оплатить
очередной <i><rw:field id="f_payment_period" src="payment_period"/></i> страховой взнос в размере <i>
<rw:field id="f_amount" src="amount"/> <rw:field id="f_fund" src="fund"/></i> к <i><rw:field id="f_grace_date" src="grace_date"/></i>. 
Однако, к настоящему моменту сумма взноса так и не поступила на наш расчетный счет.</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Информируем Вас о том, 
что возможность оплаты страхового взноса по Вашему договору страхования в соответствии 
с Общими условиями страхования, на основании которых заключен договор страхования, 
сохраняется до окончания льготного периода - <i><rw:field id="f_grace_period" src="grace_period"/></i>. 
Напоминаем Вам о том, что оплату взноса необходимо произвести не позднее даты 
окончания льготного периода, в противном случае договор страхования, обеспечивающий 
финансовую защиту для Вас и Ваших близких, будет расторгнут.</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Для
продолжения действия Вашего договора страхования, обращаемся к Вам с просьбой
оплатить очередной страховой взнос как можно скорее.</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Для уплаты
страхового взноса без дополнительных банковских комиссионных сборов мы
рекомендуем Вам воспользоваться:</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>1. 
Платежной системой </span><span lang=EN-US
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-ansi-language:EN-US;
mso-fareast-language:RU'>CONTACT</span>
<img width=60 height=40 src="<%=g_ImagesRoot%>/letter_remind/image002.jpg"></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'>
<span style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>
Со списком банков, работающих в Вашем регионе по платежной системе </span>
<span lang=EN-US style='mso-bidi-font-size:
11.0pt;line-height:150%;mso-ansi-language:EN-US;mso-fareast-language:RU'>CONTACT</span><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>,
можно ознакомиться на нашем сайте по адресу </span><span style='mso-bidi-font-size:
11.0pt;line-height:150%'><a href="http://www.renlife.ru/private/payments.html"
title="http://www.renlife.ru/private/payments.html">http://www.renlife.ru/private/payments.html</a>
либо на официальном сайте платежной системы Контакт <a
href="http://www.contact-sys.com/address/region.phtml?arg=XPEJ">http://www.contact-sys.com/address/region.phtml?arg=XPEJ</a>
</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%;tab-stops:18.0pt'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>2. 
Отделениями АКБ «РОСБАНК» (ОАО) </span>
<img width=49 height=36 src="<%=g_ImagesRoot%>/letter_remind/image004.jpg" alt="АКБ «РОСБАНК»"/></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Для уплаты
страховых взносов по договору Вы также можете воспользоваться услугами
Страхового агента, уполномоченного Компанией принимать страховые взносы.</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Если у Вас
есть вопросы, связанные с уплатой страхового взноса, пожалуйста, свяжитесь со
своим Страховым агентом.</span></p>

<p class=MsoBodyText style='margin-top:4.0pt'><b><i><span style='font-size:
12.0pt'>С наилучшими пожеланиями</span></i></b></p>

<p class=MsoNormal><b><i><span style='font-size:12.0pt;
line-height:150%;font-family:"Times New Roman","serif"'><%= empl_name %></span></i></b>
<br>
<b><i><span style='font-size:12.0pt;font-family:"Times New Roman","serif"'><%= empl_pos %></span></i></b></p>
<% if (++rec_count_current < rec_count_all) { %>
<br clear=all style='page-break-before:always'>
<% } %>
</div>
</rw:foreach>
</body>

</html>

</rw:report>
