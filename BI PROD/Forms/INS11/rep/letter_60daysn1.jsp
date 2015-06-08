<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="letter_60days" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <data>
    <userParameter name="P_SID"/>
    <userParameter name="PNUMBER"/>
    <userParameter name="NUM"/>
    <userParameter name="P_MONTH" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="SYS_DATE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_YEAR" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>

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
       payment_period,
       contact_name,
       address_name,
	     code,
       init_name,
       due_date,
       --amount,
       fund,
       pol_num,
	     ids,
	     flag,
       dog_num,
       pol_ser,
	     type_contact,
	     gender,
       case mb when 12 then to_char(fee,'999999999D99') else amount end amount
       
from
(select 
       vlp.payment_period,
       vlp.contact_name,
       vlp.address_name,
	   vlp.code,
     vlp.mb,
       vlp.init_name,
       to_char(vlp.due_date, 'dd.mm.yyyy') due_date,
       --ent.obj_name('DOCUMENT', vlp.pol_header_id) dog_num,
       to_char(vlp.sum_fee,'999999999D99') amount,
       vlp.fund,
       pp.pol_num,
	   ph.ids,
	   case when length(pp.pol_num)>6 then 1 else 0 end flag,
       case when length(pp.pol_num)>6 then substr(pp.pol_num,4,6) else pp.pol_num end dog_num,
       case when length(pp.pol_num)>6 then substr(pp.pol_num,1,3) else pp.pol_ser end pol_ser,
	   vlp.type_contact,
	   vlp.gender,
     sum(pc.fee) fee
       
  from v_letters_payment vlp, 
       notif_letter_rep nlr,
       p_pol_header ph,
       p_policy pp,
       as_asset a,
       p_cover pc
 where vlp.document_id = nlr.document_id
   and nlr.sessionid = :P_SID
   --and vlp.mb <> 12
   and ph.policy_header_id = vlp.pol_header_id
   and pp.policy_id = ph.policy_id
   and pp.policy_id = a.p_policy_id
   and a.as_asset_id = pc.as_asset_id
group by vlp.payment_period,
       vlp.contact_name,
       vlp.address_name,
	   vlp.code,
     vlp.mb,
       vlp.init_name,
       to_char(vlp.due_date, 'dd.mm.yyyy'),
       to_char(vlp.sum_fee,'999999999D99'),
       vlp.fund,
       pp.pol_num,
	   ph.ids,
	   case when length(pp.pol_num)>6 then 1 else 0 end,
       case when length(pp.pol_num)>6 then substr(pp.pol_num,4,6) else pp.pol_num end,
       case when length(pp.pol_num)>6 then substr(pp.pol_num,1,3) else pp.pol_ser end,
	   vlp.type_contact,
	   vlp.gender)]]>
      </select>
      <group name="group_data">
        <dataItem name="rec_number"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

select to_char(trunc(sysdate),'dd.mm.yyyy'),
	to_char(trunc(sysdate),'mm'),
       to_char(trunc(sysdate),'yy')
into :SYS_DATE, :P_MONTH, :P_YEAR
from dual;


select case when substr(:PNUMBER,1,3) = '000' then to_number(substr(:PNUMBER,4,1))
            when substr(:PNUMBER,1,2) = '00' then to_number(substr(:PNUMBER,3,2))
            when substr(:PNUMBER,1,1) = '0' then to_number(substr(:PNUMBER,2,3))
            when substr(:PNUMBER,1,1) <> '0' then to_number(:PNUMBER)
       end
into :NUM
from dual;


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
<title>Письмо-напоминание - за 60 дней до платежа</title>
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
	font-size:10.0pt;
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
	font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Garamond","serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
a:link, span.MsoHyperlink
	{mso-style-noshow:yes;
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
 /* List Definitions */
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
  int p_number = 0;
  String pnum = request.getParameter("PNUMBER");
  DecimalFormat decimalPlaces = new DecimalFormat("0000");
%>
<rw:foreach id="fi0" src="group_count">
  <rw:getValue id="j_rec_count" src="rec_count"/>
  <% rec_count_all = new Integer(j_rec_count).intValue(); %>
</rw:foreach>

<rw:getValue id="p_num" src="NUM"/>
<% p_number = new Integer(p_num).intValue(); %>

<rw:foreach id="fi1" src="group_data">
<div class=Section1>

<br><br><br><br><br><br><br>
<table width="52%" border="1" align="right">
 <tr>
  <td align=right style="font-size: 13;">Кому:</td> 
  <td style="font-size: 13;"><rw:field id="f_contact_name" src="contact_name"/></td> 
 </tr> 
 <tr>
  <td align=right style="font-size: 13;">Куда:</td>
  <td style="font-size: 13;"><rw:field id="f_address_name" src="address_name"/></td> 
 </tr>

</table>

<br>


<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<b><span style='mso-bidi-font-size:11.0pt;font-family:Calibri'>Дата: <rw:field id="" src="SYS_DATE"/>
</span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<b><span style='mso-bidi-font-size:11.0pt;font-family:Calibri'>Исх.№ <%=decimalPlaces.format(rec_count_current + p_number)%>-<rw:field id="" src="P_MONTH"/>/<rw:field id="" src="P_YEAR"/></span></b></p>

<br>
<rw:getValue id="type" src="type_contact"/>
<rw:getValue id="sex" src="gender"/>

<p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:0cm;
margin-left:-1.0cm;margin-bottom:.0001pt;text-align:justify;text-indent:1.0cm'>
<b><i><span style='mso-bidi-font-size:11.0pt;font-family:Calibri'>
<% if (type.equals("0") ) { %> <% } else { %> 
<% if (sex.equals("0") ) { %>Уважаемая<% } else { %>Уважаемый <% } %>
                                          <% } %>
 <rw:field id="f_contact_name" src="contact_name"/>!</span></i></b></p>

<rw:getValue id="fund" src="fund"/>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:10.0pt;line-height:100%;font-family:Calibri;
mso-fareast-language:RU'>Компания "Ренессанс Жизнь" благодарит Вас за сотрудничество и напоминает,
 что согласно условиям договора страхования № <b><i><rw:field id="f_pol_num" src="pol_num"/></i></b>,
Вам необходимо оплатить очередной <i><rw:field id="f_payment_period" src="payment_period"/></i>
страховой взнос в размере <b><i><rw:field id="f_amount" src="amount"/> <rw:field id="f_fund" src="fund"/></i></b>
<% if (fund.equals("RUR") ) { %> <% } else { %> (по курсу ЦБ на дату оплаты) <% } %>
к <b><i><rw:field id="f_due_date" src="due_date"/></i></b>.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:10.0pt;line-height:100%;font-family:Calibri;
mso-fareast-language:RU'>В случае если уплата страхового взноса Вами
уже была произведена, просим не принимать во внимание настоящее письмо.</span></p>

<rw:getValue id="j_flag" src="flag"/>

<% if (j_flag.equals("1")) { %><% } else { %>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:10.0pt;line-height:100%;font-family:Calibri;
mso-fareast-language:RU'>Также сообщаем Вам, что в целях стандартизации процесса приема платежей, 
Вашему договору присвоен идентификационный номер <b><i><rw:field id="f_ids" src="ids"/></i></b>. 
Просим Вас при оплате страховых взносов в назначении платежа вместо номера договора указывать данный 
идентификационный номер.</span></p>

<% } %>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-2.0cm;margin-bottom:.0001pt;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:10.0pt;line-height:100%;font-family:Calibri;
mso-fareast-language:RU'>Оплатить очередной взнос Вы можете по следующим
реквизитам:</span></p>

<p class=MsoNormal style='text-align:justify'><span style='font-size:10.0pt;
font-family:Calibri'>Реквизиты для оплаты через<span style='mso-spacerun:yes'> 
</span>банк ВТБ-24:<o:p></o:p></span></p>

<p class=MsoBodyText style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>Получатель платежа: ООО «СК «Ренессанс
Жизнь», ИНН 7725520440, КПП 775001001, <o:p></o:p></span></p>

<p class=MsoBodyText style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>р/с 40701810019000007118 в ВТБ24 (ЗАО), БИК 044525716, к/с
30101810100000000716. <o:p></o:p></p>

<p class=MsoBodyText style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>Назначение платежа: <span
style='mso-spacerun:yes'> </span>Страховая премия по договору № <i
style='mso-bidi-font-style:normal'><rw:field id="f_ids" src="ids"/></i>. <o:p></o:p></span></p>


<p class=MsoBodyText style='margin-top:6.0pt'><span style='font-size:10.0pt;
font-family:Calibri'>Реквизиты для оплаты через прочие банки:<o:p></o:p></span></p>
<p class=MsoNormal style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>Получатель платежа: ООО «СК «Ренессанс
Жизнь», ИНН 7725520440, КПП 775001001, <o:p></o:p></span></p>

<p class=MsoBodyText style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>р/с
40701810800001410925 в ЗАО «Райффайзенбанк» г. Москва, БИК 044525700, к/с
<o:p></o:p></span></p>

<p class=MsoBodyText style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>30101810200000000700. <o:p></o:p></span></p>

<p class=MsoBodyText style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>Назначение платежа: <span
style='mso-spacerun:yes'> </span>Страховая премия по договору № <i
style='mso-bidi-font-style:normal'><rw:field id="f_ids" src="ids"/> <rw:field id="f_init_name" src="init_name"/></i>. <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:6.0pt'><span style='font-size:10.0pt;
font-family:Calibri'>Реквизиты для оплаты через<span style='mso-spacerun:yes'> 
</span>платежную систему Contact:<o:p></o:p></span></p>

<p class=MsoBodyText style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>Получатель платежа: ООО «СК «Ренессанс
Жизнь», ИНН 7725520440, </span><span lang=EN-US style='font-size:11.0pt;
font-family:Calibri;mso-ansi-language:EN-US;font-weight:normal'>XPEJ</span><span
style='font-size:10.0pt;font-family:Calibri;font-weight:normal'> <o:p></o:p></span></p>

<p class=MsoBodyText style='text-indent:27.0pt;line-height:normal'><span style='font-size:10.0pt;
font-family:Calibri'>Назначение платежа: <span
style='mso-spacerun:yes'> </span>Страховая премия по договору № <i
style='mso-bidi-font-style:normal'><rw:field id="f_ids" src="ids"/> <rw:field id="f_init_name" src="init_name"/></i>. <o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:6.0pt'><span style='font-size:10.0pt;
font-family:Calibri'>Для уплаты страхового взноса без дополнительных банковских
комиссионных сборов Вы можете воспользоваться:<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:6.0pt;text-align:justify;text-indent:1.0cm'><span
style='font-size:10.0pt;font-family:Calibri'>1. Платежной системой CONTACT. Со
списком банков, работающих в Вашем регионе по платежной системе CONTACT, можно
ознакомиться на нашем сайте по адресу <a
href="http://www.renlife.ru/private/payments.html">http://www.renlife.ru/private/payments.html</a>.<o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:6.0pt;text-align:justify;text-indent:1.0cm'><span
style='font-size:10.0pt;font-family:Calibri'>2. Отделениями банка «ВТБ24». Со
списком отделений банка, в Вашем регионе вы можете ознакомиться на сайте банка <a
href="http://www.vtb24.ru/">http://www.vtb24.ru/</a><o:p></o:p></span></p>

<p class=MsoBodyText style='margin-top:6.0pt;text-align:justify;text-indent:1.0cm'><span
style='font-size:10.0pt;font-family:Calibri'>3. Услугами
Страхового агента «Ренессанс Жизнь», уполномоченного Компанией принимать
страховые взносы. Вызвать агента Вы можете, позвонив по телефону +7 (495) 981-2-981.</p>

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




<p class=MsoNormal align=center style='text-align:center;page-break-before:always'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;font-family:Calibri'>Квитанция для оплаты
через банк ВТБ-24<o:p></o:p></span></b></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=677
 style='width:507.6pt;margin-left:-39.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:17.0pt'>
  <td width=156 valign=bottom style='width:117.0pt;border:none;border-right:
  double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;height:17.0pt'>
  <p class=MsoNormal align=center style='text-align:center'>ИЗВЕЩЕНИЕ</p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.0pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
  <p class=MsoNormal>Наименование получателя:<span
  style='mso-spacerun:yes'>            </span>ООО СК «Ренессанс Жизнь»</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
   mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
   height:14.2pt'>
  <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
   0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>ИНН 7725520440 </p>
  </p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
  <p class=MsoNormal style='tab-stops:316.5pt'><span class=GramE>Р</span>/с
  40701810019000007118 в ВТБ24 (ЗАО)<span style='mso-tab-count:1'>                                 </span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=3 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
  <p class=MsoNormal>Кор.сч.30101810100000000716, БИК 044525716</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-bottom-alt:solid windowtext .75pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>ФИО Плательщика </p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .75pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-top-alt:solid windowtext .75pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-bottom-alt:solid windowtext .75pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Адрес Плательщика</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  border-bottom:double windowtext 1.5pt;mso-border-top-alt:solid windowtext .75pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
  <p class=MsoNormal>ФИО Страхователя <b><rw:field id="f_init" src="init_name"/></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;height:16.35pt'>
  <td width=156 rowspan=2 valign=top style='width:117.0pt;border:none;
  border-right:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=208 valign=top colspan=2 style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Назначение платежа</p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Дата</p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Сумма</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9;height:22.95pt'>
  <td width=208 valign=top colspan=2 style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Страховая премия по договору</p>
  </td>
  <td width=108 valign=top rowspan=2 style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=125 valign=top rowspan=2 style='width:93.6pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='mso-ansi-language:EN-US'><% if (fund.equals("RUR") ) { %><rw:field id="f_amount" src="amount"/><% } else { %><% } %><o:p></o:p></span></b></p>
  </td>
 </tr>
 

 <tr style='mso-yfti-irow:9;height:22.95pt'>
 <td width=156 valign=bottom style='width:117.0pt;border-top:none;border-left:
  none;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:24.75pt'>
  <p class=MsoNormal align=center style='text-align:center'></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Серия <b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='mso-ansi-language:EN-US'>
  <% if (j_flag.equals("2")) { %><rw:field id="f_pol_ser" src="pol_ser"/><% } else { %><% } %> </span></b><span
  lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=208 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Номер <b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='mso-ansi-language:EN-US'>
  <% if (j_flag.equals("2")) { %><rw:field id="f_dog_num" src="dog_num"/><% } else { %><rw:field id="f_ids" src="ids"/><% } %> </span></b><span
  lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 
 
 <tr style='mso-yfti-irow:21;mso-yfti-lastrow:yes;height:24.75pt'>
  <td width=156 valign=bottom style='width:117.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:24.75pt'>
  <p class=MsoNormal align=center style='text-align:center'>Кассир</p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.75pt'>
  <p class=MsoNormal>Подпись плательщика</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;height:17.0pt'>
  <td width=156 style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:17.0pt'>
  <p class=MsoNormal align=center style='text-align:center'>КВИТАНЦИЯ</p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.0pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
  <p class=MsoNormal>Наименование получателя:<span
  style='mso-spacerun:yes'>            </span>ООО СК «Ренессанс Жизнь»</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
   0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>ИНН 7725520440 </p>
  </p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
  <p class=MsoNormal><span class=GramE>Р</span>/с 40701810019000007118 в ВТБ24
  (ЗАО)</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
  <p class=MsoNormal>Кор.сч.30101810100000000716, БИК 044525716</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-bottom-alt:solid windowtext .75pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>ФИО Плательщика</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  border-bottom:solid windowtext 1.0pt;mso-border-top-alt:solid windowtext .75pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-top-alt:solid windowtext .75pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-bottom-alt:solid windowtext .75pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Адрес Плательщика</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border:none;
  border-bottom:double windowtext 1.5pt;mso-border-top-alt:solid windowtext .75pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:14.2pt'>
  <p class=MsoNormal>ФИО Страхователя <b><rw:field id="f_init" src="init_name"/></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:19;height:16.35pt'>
  <td width=156 rowspan=2 valign=top style='width:117.0pt;border:none;
  border-right:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=208 valign=top colspan=2 style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Назначение платежа</p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Дата</p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Сумма</p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9;height:22.95pt'>
  <td width=208 valign=top colspan=2 style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Страховая премия по договору</p>
  </td>
  <td width=108 valign=top rowspan=2 style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><o:p>&nbsp;</o:p></p>
  </td>
  <td width=125 valign=top rowspan=2 style='width:93.6pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='mso-ansi-language:EN-US'><% if (fund.equals("RUR") ) { %><rw:field id="f_amount" src="amount"/><% } else { %><% } %><o:p></o:p></span></b></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:9;height:22.95pt'>
 <td width=156 valign=bottom style='width:117.0pt;border-top:none;border-left:
  none;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:24.75pt'>
  <p class=MsoNormal align=center style='text-align:center'></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Серия <b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='mso-ansi-language:EN-US'>
  <% if (j_flag.equals("2")) { %><rw:field id="f_pol_ser" src="pol_ser"/><% } else { %><% } %> </span></b><span
  lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=208 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Номер <b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='mso-ansi-language:EN-US'>
  <% if (j_flag.equals("2")) { %><rw:field id="f_dog_num" src="dog_num"/><% } else { %><rw:field id="f_ids" src="ids"/><% } %> </span></b><span
  lang=EN-US style='mso-ansi-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:21;mso-yfti-lastrow:yes;height:24.75pt'>
  <td width=156 valign=bottom style='width:117.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:24.75pt'>
  <p class=MsoNormal align=center style='text-align:center'>Кассир</p>
  </td>
  <td width=400 colspan=4 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.75pt'>
  <p class=MsoNormal>Подпись плательщика</p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>


<p class=MsoNormal align=center style='text-align:center;page-break-before:always'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;font-family:Calibri'>Квитанция для оплаты
через прочие банки<o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;font-family:Calibri'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-right:-28.4pt'><b style='mso-bidi-font-weight:
normal'><span style='font-family:PragmaticaCTT'><o:p>&nbsp;</o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='margin-left:-12.6pt;border-collapse:collapse;mso-table-layout-alt:fixed;
 border:none;mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:231.45pt'>
  <td width=132 valign=top style='width:99.0pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:231.45pt'>
  <p class=MsoNormal style='margin-left:6.6pt'><!--[if gte vml 1]><v:shapetype
   id="_x0000_t202" coordsize="21600,21600" o:spt="202" path="m,l,21600r21600,l21600,xe">
   <v:stroke joinstyle="miter"/>
   <v:path gradientshapeok="t" o:connecttype="rect"/>
  </v:shapetype><v:shape id="_x0000_s1026" type="#_x0000_t202" style='position:absolute;
   left:0;text-align:left;margin-left:-68.15pt;margin-top:-9.35pt;width:36pt;
   height:45pt;z-index:1' stroked="f">
   <v:textbox style='mso-next-textbox:#_x0000_s1026'/>
  </v:shape><![endif]--><![if !vml]><span style='mso-ignore:vglayout;
  position:relative;z-index:1'><span style='left:0px;position:absolute;
  left:-91px;top:-12px;width:52px;height:64px'>
  <table cellpadding=0 cellspacing=0>
   <tr>
    <td width=52 height=64 bgcolor=white style='vertical-align:top;background:
    white'><![endif]><![if !mso]><span style='position:absolute;mso-ignore:
    vglayout;left:0pt;z-index:1'>
    <table cellpadding=0 cellspacing=0 width="100%">
     <tr>
      <td><![endif]>
      <div v:shape="_x0000_s1026" style='padding:3.6pt 7.2pt 3.6pt 7.2pt'
      class=shape>
      <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
      style='font-size:42.0pt;mso-bidi-font-size:12.0pt;font-family:Physics'><o:p>&nbsp;</o:p></span></b></p>
      </div>
      <![if !mso]></td>
     </tr>
    </table>
    </span><![endif]><![if !mso & !vml]>&nbsp;<![endif]><![if !vml]></td>
   </tr>
  </table>
  </span></span><![endif]><span style='font-size:6.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <br style='mso-ignore:vglayout' clear=ALL>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:20.65pt;margin-bottom:
  0cm;margin-left:6.6pt;margin-bottom:.0001pt;line-height:12.0pt;mso-line-height-rule:
  exactly;background:white'><span style='font-size:6.0pt;mso-bidi-font-size:
  12.0pt'><span style='mso-spacerun:yes'>         </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='mso-spacerun:yes'>             </span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>Отправить в <span class=SpellE><span class=GramE>д</span></span>/о
  _______</p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span
  style='mso-spacerun:yes'>                                          </span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>ИЗВЕЩЕНИЕ</p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>Кассир<o:p></o:p></span></p>
  </td>
  <td width=523 valign=top style='width:392.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:231.45pt'>
  <h3 align=right style='margin-right:-.05pt;text-align:right;mso-list:skip'><a
  name="_Toc154371481"></a><a name="_Toc154370935"></a><a name="_Toc153344671"></a><a
  name="_Toc130614122"></a><a name="_Toc130114381"></a><a name="_Toc130114271"><span
  style='mso-bookmark:_Toc130114381'><span style='mso-bookmark:_Toc130614122'><span
  style='mso-bookmark:_Toc153344671'><span style='mso-bookmark:_Toc154370935'><span
  style='mso-bookmark:_Toc154371481'>Форма ПД-4</span></span></span></span></span></a></h3>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='margin-left:.25pt;border-collapse:collapse;mso-table-layout-alt:fixed;
   border:none;mso-border-alt:dash-small-gap windowtext .5pt;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:64.9pt'>
    <td width=196 valign=top style='width:147.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:64.9pt'>
    <h1><a name="_Toc154371482"></a><a name="_Toc154370936"></a><a
    name="_Toc153344672"></a><a name="_Toc130614123"></a><a name="_Toc130114382"><span
    style='mso-bookmark:_Toc130614123'><span style='mso-bookmark:_Toc153344672'><span
    style='mso-bookmark:_Toc154370936'><span style='mso-bookmark:_Toc154371482'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;line-height:150%'>ООО</span></span></span></span></span></a><span
    class=GramE><span style='mso-bookmark:_Toc130114382'><span
    style='mso-bookmark:_Toc130614123'><span style='mso-bookmark:_Toc153344672'><span
    style='mso-bookmark:_Toc154370936'><span style='mso-bookmark:_Toc154371482'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;line-height:150%'>«С</span></span></span></span></span></span></span><span
    style='mso-bookmark:_Toc130114382'><span style='mso-bookmark:_Toc130614123'><span
    style='mso-bookmark:_Toc153344672'><span style='mso-bookmark:_Toc154370936'><span
    style='mso-bookmark:_Toc154371482'><span style='font-size:10.0pt;
    mso-bidi-font-size:12.0pt;line-height:150%'>К «Ренессанс Жизнь»</span></span></span></span></span></span><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;line-height:150%'><o:p></o:p></span></h1>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>ИНН<span
    style='mso-spacerun:yes'>  </span>7725520440, КПП 775001001<span
    style='mso-spacerun:yes'>                </span><o:p></o:p></span></p>
    <p class=MsoNormal><span class=GramE><b><span style='font-size:7.0pt;
    mso-bidi-font-size:8.0pt'>Р</span></b></span><b><span style='font-size:
    7.0pt;mso-bidi-font-size:8.0pt'>/С</span></b><span style='font-size:7.0pt;
    mso-bidi-font-size:8.0pt'><span style='mso-spacerun:yes'>  </span><span
    style='mso-spacerun:yes'>  </span><b>40701810800001410925</b></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>В
    ЗАО «<span class=SpellE>Райффайзенбанк</span>» г. Москва<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>БИК
    044525700 , К/С 30101810200000000700</span><span style='font-size:8.0pt;
    mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
    </td>
    <td width=317 rowspan=2 valign=top style='width:237.7pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:64.9pt'>
  <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
   0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
   <img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/logo_new.jpg" alt="logo"></p>
  </p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:8.7pt'>
    <td width=196 valign=top style='width:147.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:8.7pt'>
    <h1><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;line-height:
    150%;font-weight:normal'><o:p>&nbsp;</o:p></span></h1>
    </td>
   </tr>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
   mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:21.05pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:21.05pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Плательщик </span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span>________________________________________________________<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:27.05pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:27.05pt'>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                                             
    </span><span style='mso-spacerun:yes'>                    </span>(Фамилия,
    Имя, Отчество плательщика)<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>___________________________________________________________________________________________<o:p></o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Адрес плательщика)<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:17.75pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:17.75pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Страхователь</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'> </span><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>____________<rw:field id="f_init_name" src="init_name"/>__________________<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:9.95pt;mso-row-margin-right:81.0pt'>
    <td width=125 valign=top style='width:93.65pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:9.95pt'>
    <p class=OaenoCaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    line-height:normal;mso-pagination:widow-orphan;tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm;
    text-autospace:ideograph-other'><span style='mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=282 valign=top style='width:211.45pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:9.95pt'>
    <p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                        </span></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество
    страхователя)<o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=108><p class='MsoNormal'>&nbsp;</td>
   </tr>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.1pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:12.1pt'>
    <p class=MsoNormal style='margin-bottom:3.0pt'><b><span style='font-size:
    9.0pt;mso-bidi-font-size:12.0pt'>Назначение платежа:</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>  </span></span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'>Страховая премия<b><o:p></o:p></b></span></p>
    </td>
    <td width=97 valign=top style='width:72.8pt;border:solid black 1.0pt;
    border-left:none;mso-border-left-alt:solid black .5pt;mso-border-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:12.1pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Сумма, руб.<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:16.05pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:16.05pt'>
    <p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
    3.0pt;margin-left:0cm'><b><span style='font-size:8.0pt;mso-bidi-font-size:
    12.0pt'>по</span></b><b><span style='font-size:10.0pt;mso-bidi-font-size:
    12.0pt;mso-fareast-language:EN-US;mso-no-proof:yes'> </span></b><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>договору<span
    style='mso-spacerun:yes'>   </span>№ <rw:field id="f_ids" src="ids"/>  <rw:field id="f_init_name" src="init_name"/><o:p></o:p></span></b></p>
    </td>
    <td width=97 rowspan=3 style='width:72.8pt;border-top:none;border-left:
    none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .5pt;
    mso-border-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:11.0pt;
    mso-ansi-language:EN-US'><% if (fund.equals("RUR") ) { %><rw:field id="f_amount" src="amount"/><% } else { %><% } %><o:p></o:p></span></b></p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:6.2pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:6.2pt'>
    <p class=OaenoCaeeaiey align=left style='margin-bottom:0cm;margin-bottom:
    .0001pt;text-align:left;line-height:normal;mso-pagination:widow-orphan;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm'><b><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'> </span></span></b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:5.4pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:5.4pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                                      
    </span></span><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <h1 style='margin-top:5.0pt'><span style='font-size:8.0pt;mso-bidi-font-size:
  12.0pt;line-height:150%;font-weight:normal;mso-bidi-font-weight:bold'>«_____»
  ___________200 __ г.<span style='mso-spacerun:yes'>               
  </span>Подпись плательщика _______________________ <sub><o:p></o:p></sub></span></h1>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:224.0pt'>
  <td width=132 valign=top style='width:99.0pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:224.0pt'>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='mso-spacerun:yes'>                             </span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>КВИТАНЦИЯ</p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt'>Кассир<o:p></o:p></span></p>
  </td>
  <td width=523 valign=top style='width:392.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:224.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
   mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:52.5pt'>
    <td width=197 colspan=2 valign=top style='width:147.6pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
    <h1><a name="_Toc154371484"></a><a name="_Toc154370938"></a><a
    name="_Toc153344674"></a><a name="_Toc130614125"></a><a name="_Toc130114384"><span
    style='mso-bookmark:_Toc130614125'><span style='mso-bookmark:_Toc153344674'><span
    style='mso-bookmark:_Toc154370938'><span style='mso-bookmark:_Toc154371484'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;line-height:150%'>ООО «СК
    «Ренессанс Жизнь»</span></span></span></span></span></a><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;line-height:150%'><o:p></o:p></span></h1>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>ИНН<span
    style='mso-spacerun:yes'>  </span>7725520440, КПП775001001<o:p></o:p></span></p>
    <p class=MsoNormal><span class=GramE><b><span style='font-size:7.0pt;
    mso-bidi-font-size:8.0pt'>Р</span></b></span><b><span style='font-size:
    7.0pt;mso-bidi-font-size:8.0pt'>/С</span></b><span style='font-size:7.0pt;
    mso-bidi-font-size:8.0pt'><span style='mso-spacerun:yes'>    </span><b>40701810800001410925</b></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>В
    ЗАО «<span class=SpellE>Райффайзенбанк</span>» г. Москва<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>БИК
    044525700 , К/С 30101810200000000700</span><span style='font-size:8.0pt;
    mso-bidi-font-size:10.0pt'><o:p></o:p></span></p>
    </td>
    <td width=317 colspan=2 rowspan=2 valign=top style='width:237.4pt;
    border:none;padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
   0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
   <img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/logo_new.jpg" alt="logo"></p>
  </p>
    </td>
    <td width=257 colspan=2 rowspan=2 valign=top style='width:192.8pt;
    border:none;padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
    <p class=MsoNormal align=right style='margin-right:-1.7pt;text-align:right'><span
    style='font-size:8.0pt;mso-bidi-font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:8.6pt'>
    <td width=197 colspan=2 valign=top style='width:147.6pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:8.6pt'>
    <h1><span style='font-size:10.0pt;mso-bidi-font-size:12.0pt;line-height:
    150%;font-weight:normal'><o:p>&nbsp;</o:p></span></h1>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:17.85pt;
    mso-row-margin-right:191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:17.85pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Плательщик </span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span>_______________________________________________________<o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'>&nbsp;</td>
   </tr>
   <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:4.0pt;mso-row-margin-right:
    191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество
    плательщика)<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>________________________________________________________________________________________<o:p></o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Адрес плательщика)<o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'>&nbsp;</td>
   </tr>
   <tr style='mso-yfti-irow:4;page-break-inside:avoid;height:20.85pt;
    mso-row-margin-right:191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:20.85pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Страхователь</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'> </span><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt'>_____________<rw:field id="f_init_name" src="init_name"/>___________________<o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'>&nbsp;</td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:4.0pt;mso-row-margin-right:272.7pt'>
    <td width=125 valign=top style='width:93.65pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:4.0pt'>
    <p class=OaenoCaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    line-height:normal;mso-pagination:widow-orphan;tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm;
    text-autospace:ideograph-other'><span style='mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
    </td>
    <td width=282 colspan=2 valign=top style='width:211.45pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
    <p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                            </span></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество
    страхователя)<o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=364 colspan=3><p class='MsoNormal'>&nbsp;</td>
   </tr>
   <![if !supportMisalignedColumns]>
   <tr height=0>
    <td width=125 style='border:none'></td>
    <td width=72 style='border:none'></td>
    <td width=210 style='border:none'></td>
    <td width=107 style='border:none'></td>
    <td width=1 style='border:none'></td>
    <td width=256 style='border:none'></td>
   </tr>
   <![endif]>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:10.3pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:10.3pt'>
    <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Назначение
    платежа:</span></b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>  </span></span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'>Страховая премия <b><o:p></o:p></b></span></p>
    </td>
    <td width=97 valign=top style='width:72.8pt;border:solid black 1.0pt;
    border-left:none;mso-border-left-alt:solid black .5pt;mso-border-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:10.3pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Сумма, руб.<o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:3.5pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
    <p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:0cm'><b><span style='font-size:8.0pt;mso-bidi-font-size:
    12.0pt'>по договору<span style='mso-spacerun:yes'>  </span>№ <rw:field id="f_ids" src="ids"/>  <rw:field id="f_init_name" src="init_name"/><span
    style='mso-spacerun:yes'>  </span><o:p></o:p></span></b></p>
    </td>
    <td width=97 rowspan=3 valign=top style='width:72.8pt;border-top:none;
    border-left:none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .5pt;
    mso-border-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:11.0pt;
    mso-ansi-language:EN-US'><% if (fund.equals("RUR") ) { %><rw:field id="f_amount" src="amount"/><% } else { %><% } %><o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:5.1pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:5.1pt'>
    <p class=OaenoCaeeaiey align=left style='margin-bottom:0cm;margin-bottom:
    .0001pt;text-align:left;line-height:normal;mso-pagination:widow-orphan;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm'><span style='mso-bidi-font-size:
    12.0pt'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:3.5pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:3.5pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                    </span><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='margin-top:6.0pt'><span style='font-size:8.0pt;
  mso-bidi-font-size:12.0pt'>«_____» ___________200 __ г.<span
  style='mso-spacerun:yes'>                </span>Подпись плательщика _______________________<sub><o:p></o:p></sub></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>




<% if (++rec_count_current < rec_count_all) { %>
<br clear=all style='page-break-before:always'>
<% } %>
</div>
</rw:foreach>
</body>

</html>

</rw:report>
