<%@ include file="/inc/header_msword.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="letters_reestr" DTDVersion="9.0.2.0.10">
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
       vlp.address_name
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
<title>Письмо-напоминание  об уплате взноса 2</title>
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
/* p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-style-parent:"";
	margin:0cm;
	
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Garamond","serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
*/
 .MsoNormal
	{font-size: 11.0pt;
	font-family: "Garamond","serif";
	mso-fareast-font-family: "Times New Roman";
	mso-bidi-font-family: "Times New Roman";}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{mso-style-noshow:yes;
	mso-style-link:"Основной текст Знак";
	margin:0cm;
	
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
ol
	{margin-bottom:0cm;}
ul
	{margin-bottom:0cm;}
.my_class {
color: red;
}
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


<p class=MsoNormal style='margin-top:4.0pt;margin-right:0cm;margin-bottom:0cm;
margin-top:-1.0cm;text-align:centre;text-indent:1.0cm'><b><span
style='mso-bidi-font-size:10.0pt;font-family:"Times New Roman","serif"'>Список отправлений</span></b></p>
<p class=MsoNormal style='margin-top:4.0pt;margin-right:0cm;margin-bottom:0cm;
margin-top:-1.0cm;text-align:centre;text-indent:1.0cm'><b><span
style='mso-bidi-font-size:10.0pt;font-family:"Times New Roman","serif"'>(письма без уведомления)</span></b></p>



<div class=Section1>

<br>
<table width="52%" border="1" align="justify">
<tr>
 <td align=right style="font-size: 13;">Кому:</td> 
 <td align=right style="font-size: 13;">Куда:</td> 
<td align=right style="font-size: 13;">Вес:</td> 
<td align=right style="font-size: 13;">Плотность:</td> 
<td align=right style="font-size: 13;">Штрих код:</td> 

<rw:foreach id="fi2" src="group_data">
</tr>
<tr>
 <td style="font-size: 13;"><rw:field id="f_contact_name" src="contact_name"> &Field </rw:field></td> 
 <td style="font-size: 13;"><rw:field id="f_address_name" src="address_name"> &Field </rw:field></td> 
</tr>
</rw:foreach>


</table>

<br>



<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;text-indent:1.0cm;line-height:
100%'><span style='mso-bidi-font-size:10.0pt;line-height:100%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>Всего писем: <%=rec_count_all%></b></span></p>

<br><br>
<p class=MsoNormal style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;text-indent:1.0cm'><i><span style='mso-bidi-font-size:10.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Специалист административного управления</span></i></p>
<p></p>
<p class=MsoNormal style='margin-top:2.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;text-indent:1.0cm'><i><span style='mso-bidi-font-size:10.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>Корендясев Дмитрий</span></i></p>


</div>

</body>

</html>

</rw:report>
