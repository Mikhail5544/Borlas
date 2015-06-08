<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="letter_years" DTDVersion="9.0.2.0.10">
  <data>
    <userParameter name="P_SID"/>
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
      <![CDATA[select rownum rec_number,
       vlp.contact_name,
       vlp.address_name,
       ent.obj_name('DOCUMENT', vlp.pol_header_id) dog_num,
       to_date(vlp.grace_date,'dd.mm.yyyy') grace_date,
       nvl(ent.obj_name('CONTACT',ach.agent_id),'0') agent
  from v_letters_payment vlp,
       notif_letter_rep nlr,
       ven_p_policy_agent pa,
       ven_ag_contract_header ach
 where vlp.document_id = nlr.document_id
       and pa.policy_header_id(+)=vlp.pol_header_id
       and ach.ag_contract_header_id(+)=pa.ag_contract_header_id
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
<title>Страховые годовщины</title>
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
<% 
  int rec_count_all = 0;
  int rec_count_current = 0;
%>
<rw:foreach id="fi0" src="group_count">
  <rw:getValue id="j_rec_count" src="rec_count"/>
  <% rec_count_all = new Integer(j_rec_count).intValue(); %>
</rw:foreach>

<rw:foreach id="fi1" src="group_data">
<div class=Section1>

<br><br><br><br>
<table width="52%" border="1" align="right">
 <tr>
  <td align=right style="font-size: 11;">Кому:</td> 
  <td style="font-size: 11;"><rw:field id="f_contact_name" src="contact_name"/></td> 
 </tr> 
 <tr>
  <td align=right style="font-size: 11;">Куда:</td>
  <td style="font-size: 11;"><rw:field id="f_address_name" src="address_name"/></td> 
 </tr>
 <tr>
  <td align=right style="font-size: 11;">От кого:</td> 
  <td style="font-size: 11;">ООО СК "Ренессанс Жизнь"</td> 
 </tr> 
 <tr>
  <td align=right style="font-size: 11;">Обратный адрес</td>
  <td style="font-size: 11;">Дербеневская наб., д.7, стр.22</td> 
 </tr> 

</table>

<br><br><br><br><br><br><br><br>

<p class=MsoNormal style='margin-top:4.0pt;margin-right:0cm;
margin-left:-1.0cm;text-align:justify;text-indent:1.0cm'><i><span
style='mso-bidi-font-size:10.0pt;font-family:"Times New Roman","serif"'>Исх. № ____________
</span></i></p>

<p class=MsoNormal style='margin-top:4.0pt;margin-right:0cm;
margin-left:-1.0cm;text-align:justify;text-indent:1.0cm'><i><span
style='mso-bidi-font-size:10.0pt;font-family:"Times New Roman","serif"'>От <    > ____________ 2008 г.
</span></i></p><br><br>

<p class=MsoNormal style='margin-left:-1.0cm;text-align:justify;text-indent:
1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;font-family:"Times New Roman","serif"'>Уважаемый
(ая) <rw:field id="f_contact_name" src="contact_name"/>!</span></i></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm;
line-height:100%;mso-layout-grid-align:none;text-autospace:none'><span
style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif"'>Благодарим
Вас за выбор Компании ООО «СК «Ренессанс Жизнь» в качестве Вашего страховщика.</span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm;
line-height:100%;mso-layout-grid-align:none;text-autospace:none'><span
style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif"'>В
приложении к настоящему письму Вы найдете квитанции на оплату взносов на
очередной страховой год по Вашему договору страхования № <rw:field id="f_dog_num" src="dog_num"/>. 
Напоминаем Вам о том,
что Вам необходимо оплатить очередной страховой взнос к <i><rw:field id="f_grace_date" src="grace_date"/></i>.
</span></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm;
line-height:100%;mso-layout-grid-align:none;text-autospace:none'><span
style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif"'>В
случае если Ваш договор заключен в валютном эквиваленте, уплату страховых
взносов необходимо производить в рублях по курсу ЦБ РФ на день оплаты.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Для уплаты страхового взноса без дополнительных
банковских комиссионных сборов мы рекомендуем Вам воспользоваться:</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>1.&nbsp; Платежной системой<span lang=EN-US
style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif";
mso-ansi-language:EN-US;mso-fareast-language:RU'>CONTACT</span>
<img width=60 height=40 src="<%=g_ImagesRoot%>/letter_remind/image002.jpg" alt="CONTACT"></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Со списком банков, работающих в Вашем регионе по платежной
системе </span><span lang=EN-US style='mso-bidi-font-size:11.0pt;line-height:
100%;font-family:"Times New Roman","serif";mso-ansi-language:EN-US;mso-fareast-language:
RU'>CONTACT</span><span style='mso-bidi-font-size:11.0pt;line-height:100%;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>, можно
ознакомиться на нашем сайте по адресу </span><span lang=EN-US style='mso-bidi-font-size:
11.0pt;line-height:100%;font-family:"Times New Roman","serif";mso-ansi-language:
EN-US'><a href="http://www.renlife.ru/private/payments.html">http://www.renlife.ru/private/payments.>html</a></span><span style='mso-bidi-font-size:11.0pt;line-height:
100%;font-family:"Times New Roman","serif"'> либо на официальном сайте
платежной системы Контакт </span><span lang=EN-US style='mso-bidi-font-size:
11.0pt;line-height:100%;font-family:"Times New Roman","serif";mso-ansi-language:
EN-US'><a href="http://www.contact-sys.com/address/region.phtml?arg=XPEJ">http://www.contact-sys.com/address/region.phtml?arg=XPEJ</a></span>.</p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>2. Отделениями АКБ «Росбанк» (ОАО) в соответствии с
приложенным к Вашему полису списком </span>
<img width=49 height=36 src="<%=g_ImagesRoot%>/letter_remind/image004.jpg" alt="АКБ «РОСБАНК»"></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'>&nbsp;</p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Для уплаты страховых взносов по договору Вы также
можете воспользоваться услугами Страхового агента, уполномоченного Компанией
принимать страховые взносы.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Если у Вас есть вопросы, связанные с уплатой
страхового взноса, пожалуйста, свяжитесь со своим Страховым агентом.</span></p>
<rw:getValue id="j_agent" src="agent"/>
  <% String agent = new String(j_agent);
  if (agent.compareTo("0")!=0) {%>
<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm;
line-height:100%;mso-layout-grid-align:none;text-autospace:none'><span
style='mso-bidi-font-size:11.0pt;line-height:100%;font-family:"Times New Roman","serif"'>Страховым
консультантом по Вашему договору является <i><%=agent%></i>.</span></p>
<%}%>
<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>&nbsp;</p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>С наилучшими пожеланиями,</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/image005.jpg" alt="Ященко Игорь"></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Операционный директор</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Ященко Игорь</span></i></b></p>

<% if (++rec_count_current < rec_count_all) { %>
<br clear=all style='page-break-before:always'>
<% } %>
</div>
</rw:foreach>
</body>

</html>

</rw:report>
