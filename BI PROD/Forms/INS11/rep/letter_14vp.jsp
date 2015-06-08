<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="letter_14vp" DTDVersion="9.0.2.0.10">
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
      ent.obj_name('DOCUMENT',vlp.pol_header_id) dog_num,
      to_char(vlp.grace_date,'dd.mm.yyyy') grace_date,
      pkg_policy.get_waiting_per_end_date(pp.policy_id,pp.waiting_period_id,pp.start_date) as data_wait,
      pkg_policy.get_waiting_per_end_date(pp.policy_id,pp.waiting_period_id,pp.start_date)+1 as data_rast
from ven_p_policy pp,
     v_letters_payment vlp,
     notif_letter_rep nlr
where vlp.document_id = nlr.document_id
      and pp.policy_id=vlp.policy_id
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
<title>Письмо об истечении ВП за 14 дней</title>
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
	{mso-style-noshow:yes;
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
	mso-style-noshow:yes;
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
	font-size:10.0pt;
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	mso-ascii-font-family:Calibri;
	mso-ascii-theme-font:minor-latin;
	mso-fareast-font-family:Calibri;
	mso-fareast-theme-font:minor-latin;
	mso-hansi-font-family:Calibri;
	mso-hansi-theme-font:minor-latin;
	mso-bidi-font-family:"Times New Roman";
	mso-bidi-theme-font:minor-bidi;
	mso-fareast-language:EN-US;}
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
</head>

<body lang=RU style='tab-interval:35.4pt'>
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

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'><b><i><span
style='mso-bidi-font-size:11.0pt;font-family:"Times New Roman","serif"'>Уважаемый
(ая) <rw:field id="f_contact_name" src="contact_name"/>!</span></i></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>&nbsp;</p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
150%'><span style='mso-bidi-font-size:11.0pt;line-height:150%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Напоминаем Вам о том, что согласно условиям Договора
страхования (Соглашения о временном страховом покрытии) №
<rw:field id="f_dog_num" src="dog_num"/>, установленный
для оценки степени страхового риска выжидательный период, равный 60-ти
календарным дням, истекает <i><rw:field id="f_data_wait" src="data_wait"/></i>. К сожалению, до настоящего
момента Вами не были предоставлены документы, необходимые для достоверной
оценки степени страхового риска.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
150%'><span style='mso-bidi-font-size:11.0pt;line-height:150%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Информируем Вас о том, что согласно п. 11.2.1 Общих
условий страхования по индивидуальному страхованию жизни и страхованию от
несчастных случаев и болезней, которые являются составной и неотъемлемой частью
договора страхования, Страховщик имеет право расторгнуть договор страхования в
одностороннем порядке в случае, если документы, необходимые для оценки степени
страхового риска, так и не будут предоставлены. Обращаем Ваше внимание, что
действие Выжидательного периода может быть продлено в соответствии с Вашим заявлением при условии
согласования со Страховщиком.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
150%'><span style='mso-bidi-font-size:11.0pt;line-height:150%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Для продолжения действия страхового покрытия 
по Вашему договору обращаемся к Вам с
просьбой предоставить необходимые документы 
как можно скорее (до даты истечения выжидательного периода). К сожалению,
в условиях отсутствия необходимой для оценки риска информации или заявления от
Вас о продлении выжидательного периода, Компания будет вынуждена расторгнуть
договор страхования № <rw:field id="f_dog_num1" src="dog_num"/> с 
<i><rw:field id="f_data_rast" src="data_rast"/></i></span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
150%'><span style='mso-bidi-font-size:11.0pt;line-height:150%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>В случае если документы Вами уже были предоставлены,
Вы ответили на все запросы Страховщика или Вы не получили информацию, что
именно необходимо предоставить для оценки степени риска или какие именно
действия необходимо совершить, мы просим Вас срочно связаться с нами по
телефону (495) 981-2-981.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><span
style='mso-bidi-font-size:11.0pt;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Надеемся на дальнейшее сотрудничество.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>&nbsp;</p>

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

<% if (++rec_count_current < rec_count_all) { %>
<br clear=all style='page-break-before:always'>
<% } %>
</div>
</rw:foreach>
</body>

</html>

</rw:report>
