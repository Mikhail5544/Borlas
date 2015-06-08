<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="letter_overpayment" DTDVersion="9.0.2.0.10">
  <data>
    <userParameter name="P_PID"/>
    <dataSource name="Q_3">
      <select>
      <![CDATA[select rownum rec_number,
       vlp.contact_name,
       ent.obj_name('DOCUMENT', vlp.policy_id) pol_num,
       decode(vlp.amount,null,'0','0','0',to_char(vlp.amount,'999999999D99')) amount,
      decode(vlp.pay_amount,null,'0','0','0',to_char(vlp.pay_amount,'999999999D99')) pay_amount,
      decode((vlp.pay_amount-vlp.amount),null,'0','0','0',to_char((vlp.pay_amount-vlp.amount),'999999999D99')) overpayment
  from v_letters_payment vlp
 where vlp.policy_id=:P_PID
  and (vlp.pay_amount-vlp.amount)>0
	and vlp.grace_date<sysdate
      order by vlp.grace_date]]>
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
<title>Письмо о переплате</title>
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
h2
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-link:"Заголовок 2 Знак";
	mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
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
span.2
	{mso-style-name:"Заголовок 2 Знак";
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"Заголовок 2";
	mso-bidi-font-size:10.0pt;
	font-family:"Garamond","serif";
	mso-ascii-font-family:Garamond;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Garamond;
	mso-bidi-font-family:"Times New Roman";
	font-weight:bold;}
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
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
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

<body lang=RU style='tab-interval:35.4pt'>

<rw:foreach id="fi1" src="group_data">
<div class=Section1>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><img width=156 height=56
src="<%=g_ImagesRoot%>/letter_remind/image001.jpg"></p>
<p class=MsoNormal>&nbsp;</p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><b><i>Уважаемый(ая)
<rw:field id="f_contact_name" src="contact_name"/>!</i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Настоящим
доводим до Вашего сведения, что на счет ООО «СК «Ренессанс Жизнь» в качестве
оплаты страхового взноса по договору № <i><rw:field id="f_pol_num" src="pol_num"/></i> 
поступили денежные средства в сумме <i><rw:field id="f_pay_amount" src="pay_amount"/></i> рублей,
в то время как сумма взноса, которая должна была быть Вами оплачена, составляет
<i><rw:field id="f_amount" src="amount"/></i> рублей.</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Информируем
Вас о том, что переплата в размере <i><rw:field id="f_overpayment" src="overpayment"/></i>
рублей может быть учтена в счет оплаты последующих взносов по мере наступления
очередного оплачиваемого периода по договору или возвращена на Ваш расчетный
счет.</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span style='font-size:12.0pt;line-height:150%;mso-fareast-language:
RU'>В случае принятия решения о возврате суммы переплаты, просим Вас направить
в адрес нашей Компании письмо с указанием
реквизитов (наименование банка, БИК, ИНН, корр. счет, расчетный счет,
лицевой счет), на которые необходимо
произвести перечисление средств. </span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Квитанцию на
оплату очередного страхового взноса, с учетом суммы переплаты, Вы найдете в
приложении к настоящему письму.</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Благодарим за
оказанное нам доверие. Надеемся на дальнейшее взаимовыгодное сотрудничество.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>С наилучшими пожеланиями,</span></i></b></p>

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
