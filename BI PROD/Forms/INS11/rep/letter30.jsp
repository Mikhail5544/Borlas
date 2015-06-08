<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report DTDVersion="9.0.2.0.10">

  <data>
    <userParameter name="P_SID"/>
    <userParameter name="P_UID"/>
    <userParameter name="P_NTID"/>

    <dataSource name="ds0">
      <select canParse="no">
select count(*) rec_count
  from notif_letter_rep
 where sessionid = :P_SID
      </select>
      <group name="group_count"><dataItem name="rec_count"/></group>
    </dataSource>

    <dataSource name="ds1">
      <select canParse="no">
select rownum rec_number,
       vlp.payment_period,
       vlp.contact_name,
       to_char(vlp.grace_date, 'dd.mm.yyyy') grace_date,
       ent.obj_name(37, vlp.policy_id) pol_num
  from v_letters_payment vlp, notif_letter_rep nlr
 where vlp.document_id = nlr.document_id
   and nlr.sessionid = :P_SID
      </select>
      <group name="group_data"><dataItem name="rec_number"/></group>
    </dataSource>

    <dataSource name="ds2">
      <select canParse="no">
select rownum rn2,
  c.name || ' ' || c.first_name || ' ' || c.middle_name name,
  eh.appointment  
from sys_user u, employee e, employee_hist eh, contact c
where e.employee_id = u.employee_id
  and eh.employee_id = e.employee_id
  and c.contact_id = e.contact_id
  and eh.date_hist = (select max(date_hist) from employee_hist where employee_id = e.employee_id)
  and eh.is_kicked != 1
  and u.sys_user_id = :P_UID
      </select>
      <group name="group_user"><dataItem name="rn2"/></group>
    </dataSource>
  </data>

</report>
</rw:objects>
<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>Письмо-напоминаение - напоминание за 30 дней до платежа</title>
<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
    {mso-style-parent:"";
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";}
h1
    {mso-style-next:Обычный;
    margin:0cm;
    margin-bottom:.0001pt;
    text-align:center;
    mso-pagination:widow-orphan;
    page-break-after:avoid;
    mso-outline-level:1;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-font-kerning:0pt;
    font-weight:normal;
    text-decoration:underline;
    text-underline:single;}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
    {margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    font-size:14.0pt;
    font-family:"Times New Roman";
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
</style>
<![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>

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

<h1><b><span style='color:#FF9900'>ПИСЬМО-НАПОМИНАНИЕ – НАПОМИНАНИЕ ЗА 30 ДНЕЙ
ДО ПЛАТЕЖА<o:p></o:p></span></b></h1>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><span
class=GramE><b><i>Уважаемый</i></b></span><b><i> (<span class=SpellE>ая</span>)
<span style='color:#3366FF'><rw:field id="" src="contact_name"/></span>!<o:p></o:p></i></b></p>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><span style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Напоминаем
Вам о том, что согласно условиям договора страхования<span
style='mso-spacerun:yes'>  </span>№ <rw:field id="" src="pol_num"/>,<span style='mso-spacerun:yes'> 
</span>Вам<span style='mso-spacerun:yes'>  </span>необходимо было оплатить
очередной <i><span style='color:#3366FF;mso-bidi-font-weight:bold'><rw:field id="" src="payment_period"/>
</span></i> страховой взнос <span class=GramE>к</span><span
style='mso-spacerun:yes'>   </span><i><span style='color:#3366FF;mso-bidi-font-weight:
bold'><rw:field id="" src="grace_date"/></span></i>.<span style='mso-spacerun:yes'> 
</span><o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><span style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>Мы
рекомендуем Вам воспользоваться отделениями <span class=SpellE>Росбанка</span>
в соответствии с приложенным к Вашему полису списком<span class=GramE>.</span><span
style='mso-spacerun:yes'>  </span>(<span class=GramE>к</span>омиссия за
перечисление средств НЕ ВЗИМАЕТСЯ) или произвести оплату взноса по Вашему
договору через Страхового агента, уполномоченного Компанией произвести оплату
от Вашего имени<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><span style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'>В
случае если уплата страхового взноса Вами уже была произведена, мы благодарим
Вас за сотрудничество и просим не принимать во внимание настоящее письмо<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:8.0pt;text-align:justify;line-height:
150%'><i><span style='mso-bidi-font-weight:bold'>С наилучшими пожеланиями</span></i><span
style='font-size:12.0pt;line-height:150%;mso-fareast-language:RU'><o:p></o:p></span></p>

<p class=MsoNormal style='line-height:150%'><b><i><%= empl_name %></i></b><b><i><span
lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></i></b></p>
<p class=MsoNormal style='line-height:150%'><b><i><span lang=EN-US
style='mso-ansi-language:EN-US'></span><%= empl_pos %></i></b><b><i><span
lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></i></b></p>

<% if (++rec_count_current < rec_count_all) { %>
<br clear=all style='page-break-before:always'>
<% } %>
</div>

</rw:foreach>

</body>

</html>


</rw:report>
