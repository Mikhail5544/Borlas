<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report DTDVersion="9.0.2.0.10">
  
  <data>
    <userParameter name="P_PID" datatype="number"/>
    <dataSource name="Q_3">
      <select>
      <![CDATA[select
      rownum rec_number,
       ent.obj_name('CONTACT',ppc.contact_id) as name
      from 
       ven_p_policy_contact ppc,
       ven_t_contact_pol_role cpr
       where cpr.id = ppc.contact_policy_role_id
         and cpr.brief = 'Страхователь'
       and ppc.policy_id= :P_PID]]>
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
<title>Сопроводительное письмо к полису</title>
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
<body lang=RU link=blue vlink=purple style='tab-interval:35.4pt'>
<rw:foreach id="fi1" src="group_data">

<div class=Section1>

<p class=MsoBodyText style='margin-top:2.0pt;text-align:justify;line-height:
150%'><img width=156 height=56
src="<%=g_ImagesRoot%>/letter_remind/image001.jpg"></p>
<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><b><i><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>Уважаемый
(ая) <rw:field id="f_name" src="name"/>!</span></i></b></p>

<p class=MsoNormal style='margin-top:6.0pt;text-align:justify;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>Сердечно
приветствуем Вас среди (владельцев страховых полисов) клиентов нашей компании.</span></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>Благодарим
Вас за выбор Компании ООО «СК «Ренессанс Жизнь» в качестве Вашего Страховщика.</span></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>Заверяем
Вас, что наша Компания приложит все усилия, чтобы поддержать на самом высоком
уровне качество предоставляемых услуг и уровень сервиса.</span></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>Просим
Вас проверить правильность данных в полисе и их соответствие данным в Вашем заявлении о принятии на
страхование</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Для уплаты последующих страховых взносов без
дополнительных банковских комиссионных сборов мы рекомендуем Вам
воспользоваться:</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;line-height:150%;tab-stops:18.0pt'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>1.&nbsp; Платежной системой </span><span lang=EN-US
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-ansi-language:EN-US;
mso-fareast-language:RU'>CONTACT</span><img width=60 height=40 src="<%=g_ImagesRoot%>/letter_remind/image002.jpg" alt="CONTACT"></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%;tab-stops:list 0cm 18.0pt'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>Со
списком банков, работающих в Вашем регионе по платежной системе </span><span
lang=EN-US style='mso-bidi-font-size:11.0pt;line-height:150%;mso-ansi-language:
EN-US;mso-fareast-language:RU'>CONTACT</span><span style='mso-bidi-font-size:
11.0pt;line-height:150%;mso-fareast-language:RU'>, можно ознакомиться на нашем
сайте по адресу </span><span style='mso-bidi-font-size:11.0pt;line-height:150%'><a
href="http://www.renlife.ru/private/payments.html"
title="http://www.renlife.ru/private/payments.html">http://www.renlife.ru/private/payments.html</a>
либо на официальном сайте платежной системы Контакт <a
href="http://www.contact-sys.com/address/region.phtml?arg=XPEJ">http://www.contact-sys.com/address/region.phtml?arg=XPEJ</a>
</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%;tab-stops:18.0pt'><span style='mso-bidi-font-size:11.0pt;
line-height:150%;mso-fareast-language:RU'>2.&nbsp; Отделениями АКБ «РОСБАНК» (ОАО) </span>
<img width=49 height=36
src="<%=g_ImagesRoot%>/letter_remind/image004.jpg" alt="АКБ «РОСБАНК»"></p>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoBodyText style='line-height:150%'><span style='font-size:12.0pt;
line-height:150%;font-family:"Times New Roman","serif";mso-fareast-language:
RU'>Для уплаты страховых взносов по договору Вы также можете воспользоваться
услугами Страхового агента, уполномоченного Компанией принимать страховые
взносы.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Если Вы
заинтересованы в получении информации о других видах страхования, которые
предлагает наша Компания, просим Вас связаться с нами, либо с Вашим страховым
агентом.</span></p>

<p class=MsoNormal style='line-height:150%'><span style='font-size:12.0pt;
line-height:150%;font-family:"Times New Roman","serif"'>Искренне надеемся на
то, что Вы останетесь довольны качеством нашего обслуживания и уровнем
страховых продуктов.</span></p>

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
