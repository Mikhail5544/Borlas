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
         and cpr.brief = '������������'
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
<title>���������������� ������ � ������</title>
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
	mso-style-link:"��������� 3 ����";
	mso-style-next:�������;
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
	mso-style-link:"�������� ����� ����";
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
	mso-style-link:"����� ������� ����";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:"Tahoma","sans-serif";
	mso-fareast-font-family:"Times New Roman";
	mso-fareast-language:EN-US;}
span.3
	{mso-style-name:"��������� 3 ����";
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"��������� 3";
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
	{mso-style-name:"�������� ����� ����";
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"�������� �����";
	mso-bidi-font-size:10.0pt;
	font-family:"Garamond","serif";
	mso-ascii-font-family:Garamond;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Garamond;
	mso-bidi-font-family:"Times New Roman";}
span.a0
	{mso-style-name:"����� ������� ����";
	mso-style-noshow:yes;
	mso-style-priority:99;
	mso-style-unhide:no;
	mso-style-locked:yes;
	mso-style-link:"����� �������";
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
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>���������
(��) <rw:field id="f_name" src="name"/>!</span></i></b></p>

<p class=MsoNormal style='margin-top:6.0pt;text-align:justify;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>��������
������������ ��� ����� (���������� ��������� �������) �������� ����� ��������.</span></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>����������
��� �� ����� �������� ��� ��� ���������� ������ � �������� ������ �����������.</span></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>��������
���, ��� ���� �������� �������� ��� ������, ����� ���������� �� ����� �������
������ �������� ��������������� ����� � ������� �������.</span></p>

<p class=MsoNormal style='text-align:justify;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif"'>������
��� ��������� ������������ ������ � ������ � �� ������������ ������ � ����� ��������� � �������� ��
�����������</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>��� ������ ����������� ��������� ������� ���
�������������� ���������� ������������ ������ �� ����������� ���
���������������:</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;line-height:150%;tab-stops:18.0pt'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>1.&nbsp; ��������� �������� </span><span lang=EN-US
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-ansi-language:EN-US;
mso-fareast-language:RU'>CONTACT</span><img width=60 height=40 src="<%=g_ImagesRoot%>/letter_remind/image002.jpg" alt="CONTACT"></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%;tab-stops:list 0cm 18.0pt'><span
style='mso-bidi-font-size:11.0pt;line-height:150%;mso-fareast-language:RU'>��
������� ������, ���������� � ����� ������� �� ��������� ������� </span><span
lang=EN-US style='mso-bidi-font-size:11.0pt;line-height:150%;mso-ansi-language:
EN-US;mso-fareast-language:RU'>CONTACT</span><span style='mso-bidi-font-size:
11.0pt;line-height:150%;mso-fareast-language:RU'>, ����� ������������ �� �����
����� �� ������ </span><span style='mso-bidi-font-size:11.0pt;line-height:150%'><a
href="http://www.renlife.ru/private/payments.html"
title="http://www.renlife.ru/private/payments.html">http://www.renlife.ru/private/payments.html</a>
���� �� ����������� ����� ��������� ������� ������� <a
href="http://www.contact-sys.com/address/region.phtml?arg=XPEJ">http://www.contact-sys.com/address/region.phtml?arg=XPEJ</a>
</span></p>

<p class=MsoBodyText style='margin-top:4.0pt;line-height:150%;tab-stops:18.0pt'><span style='mso-bidi-font-size:11.0pt;
line-height:150%;mso-fareast-language:RU'>2.&nbsp; ����������� ��� �������ʻ (���) </span>
<img width=49 height=36
src="<%=g_ImagesRoot%>/letter_remind/image004.jpg" alt="��� �������ʻ"></p>

<p class=MsoNormal>&nbsp;</p>

<p class=MsoBodyText style='line-height:150%'><span style='font-size:12.0pt;
line-height:150%;font-family:"Times New Roman","serif";mso-fareast-language:
RU'>��� ������ ��������� ������� �� �������� �� ����� ������ ���������������
�������� ���������� ������, ��������������� ��������� ��������� ���������
������.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;line-height:150%'><span
style='font-size:12.0pt;line-height:150%;font-family:"Times New Roman","serif";
mso-fareast-language:RU'>���� ��
�������������� � ��������� ���������� � ������ ����� �����������, �������
���������� ���� ��������, ������ ��� ��������� � ����, ���� � ����� ���������
�������.</span></p>

<p class=MsoNormal style='line-height:150%'><span style='font-size:12.0pt;
line-height:150%;font-family:"Times New Roman","serif"'>�������� �������� ��
��, ��� �� ���������� �������� ��������� ������ ������������ � �������
��������� ���������.</span></p>

<p class=MsoBodyText style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>� ���������,</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'>
<img width=132 height=55 src="<%=g_ImagesRoot%>/letter_remind/image003.jpg" alt="���������� �����"></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>���������
������������� ����������</span></i></b></p>

<p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
0cm;margin-left:-1.0cm;margin-bottom:.0001pt;text-indent:1.0cm'><b><i><span style='mso-bidi-font-size:11.0pt;
font-family:"Times New Roman","serif";mso-fareast-language:RU'>���������� �����</span></i></b></p>

</div>
</rw:foreach>
</body>

</html>

</rw:report>
