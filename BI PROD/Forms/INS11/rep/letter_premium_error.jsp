<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="letter_premium_error" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="LETTER_PREMIUM_ERROR" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_PID"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select rownum rec_number,
      ent.obj_name('CONTACT',ppc.contact_id) contact_name,
      decode(pp.premium,null,'0','0','0',to_char(pp.premium,'999999999D99')) cur_prem,
       decode((pp.premium-prev_pp.premium),null,'0','0','0',to_char((pp.premium-prev_pp.premium),'999999999D99')) differ,
       f.brief,
       nvl(pp.notice_num,'...') notice,
       to_char(nvl(pkg_policy.get_privilege_per_end_date(pp.policy_id,pp.grace_period_id,pp.start_date),pp.start_date+45),'dd.mm.yyyy') period
    from ven_p_pol_header ph,
    ven_p_policy pp,
     ven_p_policy prev_pp,
     ven_p_policy_contact ppc,
     ven_t_contact_pol_role cpr,
     ven_fund f
    where cpr.id = ppc.contact_policy_role_id
      and cpr.brief = 'Страхователь'
      and ppc.policy_id= pp.policy_id
      and pp.policy_id=:P_PID
      and ph.policy_header_id=pp.pol_header_id
      and prev_pp.pol_header_id=ph.policy_header_id
      and prev_pp.version_num=pp.version_num-1
      and (pp.premium-prev_pp.premium)>0
      and f.fund_id=ph.fund_id]]>
      </select>
      <group name="group_data">
        <dataItem name="rec_number"/>
      </group>
    </dataSource>
  </data>
  <reportPrivate templateName="rwbeige"/>
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
<title>Письмо об ошибке в расчете премии</title>
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
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";
	mso-fareast-font-family:"Times New Roman";}
h1
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	font-size:12.0pt;
	font-family:"Times New Roman","serif";
	mso-font-kerning:0pt;
	font-weight:normal;
	text-decoration:underline;
	text-underline:single;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{mso-style-unhide:no;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:14.0pt;
	font-family:"Times New Roman","serif";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
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
<rw:foreach id="fi1" src="group_data">
<div class=Section1>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><img width=156 height=56
src="<%=g_ImagesRoot%>/letter_remind/image001.jpg"></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'>&nbsp;</p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><span
class=GramE><b><i>Уважаемый (ая) <rw:field id="f_contact_name" src="contact_name"/>!</i></b></span></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'>&nbsp;</p>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><span style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Сообщаем
Вам, что при расчете страховой премии по договору страхования, заключенному на
основании Вашего заявления на страхование № <rw:field id="f_notice" src="notice"/> произошла техническая
ошибка. В соответствии с указанной Вами в заявлении информации согласно залицензированным
Компанией страховым тарифам страховая премия должна составить 
<i><rw:field id="f_cur_prem" src="cur_prem"/> <rw:field id="f_brief1" src="brief"/></i>. 
Правильный расчет подлежащей уплате страховой премии Вы
найдете в приложении к настоящему письму.</span></p>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><span style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Для
продолжения действия страхового покрытия по Вашему договору, обращаемся к Вам с
просьбой в течение действия льготного периода, предоставляемого согласно Общим
условиям страхования, доплатить страховую премию в размере 
<i><rw:field id="f_differ" src="differ"/> <rw:field id="f_brief" src="brief"/></i>. 
С сожалением вынуждены сообщить Вам, что если к <i><rw:field id="f_period" src="period"/></i>, дате окончания льготного периода, сумма подлежащей
доплате страховой премии не будет уплачена или в течение это периода Вы
выразите несогласие с приведенным расчетом, договор страхования будет
расторгнут и сумма уплаченных страховых взносов возвращена на указанный Вами в
Заявлении на страхование расчетный счет. </span></p>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><span style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Для
оплаты страховых взносов мы рекомендуем Вам воспользоваться отделениями 
Росбанка в соответствии с приложенным к Вашему полису
списком. При оплате страховых взносов через вышеупомянутые отделения 
не взимается комиссия банка за перечисление средств.</span></p>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><span style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Мы
приносим свои извинения за доставленные неудобства и надеемся, что сложившаяся
ситуация будет успешно урегулирована.</span></p>

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
