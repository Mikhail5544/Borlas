<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="opis" DTDVersion="9.0.2.0.10" beforeReportTrigger="beforereport"
  >
  <xmlSettings xmlTag="OPIS" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_ADDR" datatype="character" width="200"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_INS" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_POLICY_NUM" datatype="character" width="50"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_SYSDATE" datatype="character" width="50"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_EXECUTOR" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin 
select pkg_contact.get_fio_fmt(ent.obj_name ('CONTACT', 
		      pkg_policy.get_policy_holder_id(p.policy_id)),4) as P_INS,
			  
ent.obj_name('CN_ADDRESS',pkg_contact.get_primary_address(pkg_policy.get_policy_holder_id(p.policy_id))) as P_ADDR,
P.NUM as P_POLICY_NUM,
to_char(sysdate,'dd.mm.yyyy') as P_sysdate
into :P_INS, :P_ADDR, :P_POLICY_NUM, :P_SYSDATE
from ven_p_policy p where p.policy_id=:P_POLICY_ID;   --136846; --


select pkg_contact.get_fio_fmt(ent.obj_name('CONTACT', e.contact_id),4)
  into :P_EXECUTOR
  from sys_user su, employee e
 where e.employee_id(+) = su.employee_id
   and su.sys_user_name = user;
return  (True);
exception
 when no_data_found then return (True);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel"
xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<style>
<!--table
	{mso-displayed-decimal-separator:"\,";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.98in .59in .98in .79in;
	mso-header-margin:.51in;
	mso-footer-margin:.51in;}
tr
	{mso-height-source:auto;}
col
	{mso-width-source:auto;}
br
	{mso-data-placement:same-cell;}
.style0
	{mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	white-space:nowrap;
	mso-rotate:0;
	mso-background-source:auto;
	mso-pattern:auto;
	color:windowtext;
	font-size:10.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Arial;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	border:none;
	mso-protection:locked visible;
	mso-style-name:Обычный;
	mso-style-id:0;}
td
	{mso-style-parent:style0;
	padding:0px;
	mso-ignore:padding;
	color:windowtext;
	font-size:10.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Arial;
	mso-generic-font-family:auto;
	mso-font-charset:204;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:none;
	mso-background-source:auto;
	mso-pattern:auto;
	mso-protection:locked visible;
	white-space:nowrap;
	mso-rotate:0;}
.xl24
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;}
.xl25
	{mso-style-parent:style0;
	font-weight:700;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	text-align:left;}
.xl26
	{mso-style-parent:style0;
	font-weight:700;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	text-align:center;}
.xl27
	{mso-style-parent:style0;
	font-size:8.0pt;
	font-family:Arial, sans-serif;
	mso-font-charset:0;}
.xl28
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;}
.xl29
	{mso-style-parent:style0;
	text-align:center;}
.xl30
	{mso-style-parent:style0;
	mso-number-format:"Short Date";}
.xl31
	{mso-style-parent:style0;
	text-align:center;
	white-space:normal;}
.xl32
	{mso-style-parent:style0;
	mso-number-format:"Short Date";
	text-align:left;
	white-space:normal;}
.xl33
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	white-space:normal;}
.xl34
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:left;
	white-space:normal;
	padding-left:36px;
	mso-char-indent-count:3;}
.xl35
	{mso-style-parent:style0;
	text-align:justify;
	white-space:normal;}
.xl36
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:left;
	white-space:normal;
	padding-left:36px;
	mso-char-indent-count:3;}
.xl37
	{mso-style-parent:style0;
	white-space:normal;}
.xl38
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	white-space:normal;}
.xl39
	{mso-style-parent:style0;
	mso-number-format:0;
	text-align:left;}
.xl40
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:justify;
	white-space:normal;}
.xl41
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	vertical-align:justify;}
.xl42
	{mso-style-parent:style0;
	text-align:left;}
.xl43
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:center;
	white-space:normal;}
.xl44
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:justify;
	vertical-align:middle;
	white-space:normal;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>Опись</x:Name>
    <x:WorksheetOptions>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:Scale>91</x:Scale>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:CodeName>Sheet7</x:CodeName>
     <x:PageBreakZoom>60</x:PageBreakZoom>
     <x:Selected/>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>7</x:ActiveRow>
       <x:ActiveCol>10</x:ActiveCol>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>11250</x:WindowHeight>
  <x:WindowWidth>15480</x:WindowWidth>
  <x:WindowTopX>960</x:WindowTopX>
  <x:WindowTopY>1080</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
 <x:ExcelName>
  <x:Name>Print_Area</x:Name>
  <x:SheetIndex>1</x:SheetIndex>
  <x:Formula>=Опись!$A$1:$E$28</x:Formula>
 </x:ExcelName>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="1029"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body link=blue vlink=purple>

<table x:str border=0 cellpadding=0 cellspacing=0 width=1397 style='border-collapse:
 collapse;table-layout:fixed;width:1049pt'>
 <col width=329 style='mso-width-source:userset;mso-width-alt:12032;width:247pt'>
 <col width=65 style='mso-width-source:userset;mso-width-alt:2377;width:49pt'>
 <col width=219 style='mso-width-source:userset;mso-width-alt:8009;width:164pt'>
 <col width=32 style='mso-width-source:userset;mso-width-alt:1170;width:24pt'>
 <col width=22 span=2 style='mso-width-source:userset;mso-width-alt:804;
 width:17pt'>
 <col width=15 style='mso-width-source:userset;mso-width-alt:548;width:11pt'>
 <col width=13 style='mso-width-source:userset;mso-width-alt:475;width:10pt'>
 <col width=14 style='mso-width-source:userset;mso-width-alt:512;width:11pt'>
 <col width=64 style='width:48pt'>
 <col width=71 style='mso-width-source:userset;mso-width-alt:2596;width:53pt'>
 <col width=64 style='width:48pt'>
 <col width=83 style='mso-width-source:userset;mso-width-alt:3035;width:62pt'>
 <col width=64 span=6 style='width:48pt'>
 <tr height=19 style='height:14.25pt'>
  <td height=19 width=329 style='height:14.25pt;width:247pt' align=left
  valign=top><!--[if gte vml 1]><v:shapetype id="_x0000_t75" coordsize="21600,21600"
   o:spt="75" o:preferrelative="t" path="m@4@5l@4@11@9@11@9@5xe" filled="f"
   stroked="f">
   <v:stroke joinstyle="miter"/>
   <v:formulas>
    <v:f eqn="if lineDrawn pixelLineWidth 0"/>
    <v:f eqn="sum @0 1 0"/>
    <v:f eqn="sum 0 0 @1"/>
    <v:f eqn="prod @2 1 2"/>
    <v:f eqn="prod @3 21600 pixelWidth"/>
    <v:f eqn="prod @3 21600 pixelHeight"/>
    <v:f eqn="sum @0 0 1"/>
    <v:f eqn="prod @6 1 2"/>
    <v:f eqn="prod @7 21600 pixelWidth"/>
    <v:f eqn="sum @8 21600 0"/>
    <v:f eqn="prod @7 21600 pixelHeight"/>
    <v:f eqn="sum @10 21600 0"/>
   </v:formulas>
   <v:path o:extrusionok="f" gradientshapeok="t" o:connecttype="rect"/>
   <o:lock v:ext="edit" aspectratio="t"/>
  </v:shapetype><v:shape id="_x0000_s1027" type="#_x0000_t75" style='position:absolute;
   margin-left:6.75pt;margin-top:9pt;width:162.75pt;height:48pt;z-index:1'>
   <v:imagedata src="<%=g_ImagesRoot%>/note_enclosure/image001.gif" o:title="image002"/>
   <x:ClientData ObjectType="Pict">
    <x:SizeWithCells/>
    <x:CF>Bitmap</x:CF>
    <x:AutoPict/>
   </x:ClientData>
  </v:shape><![endif]--><![if !vml]><span style='mso-ignore:vglayout;
  position:absolute;z-index:1;margin-left:9px;margin-top:12px;width:217px;
  height:64px'><img width=217 height=64
  src="<%=g_ImagesRoot%>/note_enclosure/image001.gif" v:shapes="_x0000_s1027"></span><![endif]><span
  style='mso-ignore:vglayout2'>
  <table cellpadding=0 cellspacing=0>
   <tr>
    <td height=19 width=329 style='height:14.25pt;width:247pt'><a
    name="Print_Area"></a></td>
   </tr>
  </table>
  </span></td>
  <td class=xl24 width=65 style='width:49pt'></td>
  <td width=219 style='width:164pt' align=left valign=top><!--[if gte vml 1]><v:shape
   id="_x0000_s1028" type="#_x0000_t75" style='position:absolute;margin-left:135.75pt;
   margin-top:12.75pt;width:27.75pt;height:42pt;z-index:2'>
   <v:imagedata src="<%=g_ImagesRoot%>/note_enclosure/image002.gif" o:title="image004"/>
   <x:ClientData ObjectType="Pict">
    <x:SizeWithCells/>
    <x:CF>Bitmap</x:CF>
   </x:ClientData>
  </v:shape><![endif]--><span
  style='mso-ignore:vglayout2'>
  <table cellpadding=0 cellspacing=0>
   <tr>
    <td height=19 width=219 style='height:14.25pt;width:164pt'></td>
   </tr>
  </table>
  </span></td>
  <td width=32 style='width:24pt'></td>
  <td class=xl25 width=22 style='width:17pt'></td>
  <td width=22 style='width:17pt'></td>
  <td width=15 style='width:11pt'></td>
  <td width=13 style='width:10pt'></td>
  <td width=14 style='width:11pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=64 style='width:48pt'></td>
  <td class=xl24 width=83 style='width:62pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl26 style='height:15.0pt'></td>
  <td></td>
  <td class=xl27 x:str="115114, Москва, ">115114, Москва,<span
  style='mso-spacerun:yes'> </span></td>
  <td colspan=9 style='mso-ignore:colspan'></td>
  <td class=xl28></td>
  <td colspan=6 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 class=xl29 style='height:14.25pt'></td>
  <td class=xl24></td>
  <td class=xl27>Дербеневская наб., д.7, стр.22</td>
  <td colspan=9 style='mso-ignore:colspan'></td>
  <td class=xl30></td>
  <td colspan=6 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 class=xl29 style='height:14.25pt'></td>
  <td class=xl24></td>
  <td class=xl27>тел.:+7(495)981-2-981</td>
  <td colspan=16 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl31 style='height:15.0pt'></td>
  <td colspan=9 style='mso-ignore:colspan'></td>
  <td class=xl30></td>
  <td></td>
  <td class=xl28></td>
  <td colspan=3 style='mso-ignore:colspan'></td>
  <td class=xl28></td>
  <td align=center></td>
  <td class=xl28></td>
 </tr>
 <tr height=14 style='mso-height-source:userset;height:10.5pt'>
  <td height=14 class=xl32 style='height:10.5pt'></td>
  <td colspan=15 style='mso-ignore:colspan'></td>
  <td class=xl28></td>
  <td></td>
  <td class=xl28></td>
 </tr>
 <tr height=135 style='mso-height-source:userset;height:101.25pt'>
  <td height=135 colspan=2 style='height:101.25pt;mso-ignore:colspan'></td>
  <td class=xl33 width=219 style='width:164pt'><rw:field id="f_P_ADDR" src="P_ADDR" /><span style='mso-spacerun:yes'> </span></td>
  <td colspan=9 style='mso-ignore:colspan'></td>
  <td colspan=2 class=xl28 style='mso-ignore:colspan'></td>
  <td colspan=5 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='mso-height-source:userset;height:15.0pt'>
  <td height=20 class=xl34 style='height:15.0pt'></td>
  <td></td>
  <td colspan=3 rowspan=2 class=xl41>Адресат: <rw:field id="f_P_INS" src="P_INS" /></td>
  <td colspan=14 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='mso-height-source:userset;height:15.0pt'>
  <td height=20 class=xl34 style='height:15.0pt'></td>
  <td></td>
  <td colspan=14 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 class=xl35 style='height:12.75pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 class=xl35 style='height:12.75pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 class=xl35 style='height:12.75pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 class=xl34 style='height:14.25pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 class=xl35 style='height:12.75pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td colspan=3 height=17 class=xl31 width=613 style='height:12.75pt;
  width:460pt'>ОПИСЬ ВЛОЖЕНИЯ</td>
  <td colspan=16 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=34 style='mso-height-source:userset;height:25.5pt'>
  <td height=34 colspan=12 style='height:25.5pt;mso-ignore:colspan'></td>
  <td colspan=2 class=xl32 width=147 style='width:110pt'></td>
  <td colspan=3 class=xl32 width=192 style='width:144pt'></td>
  <td colspan=2 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td colspan=3 height=17 class=xl32 width=613 style='height:12.75pt;
  width:460pt'>1. Письмо-уведомление о расторжении договора страхования № <rw:field id="f_P_POLICY_NUM" src="P_POLICY_NUM" /></td>
  <td colspan=11 style='mso-ignore:colspan'></td>
  <td colspan=3 class=xl32 width=192 style='width:144pt'></td>
  <td colspan=2 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td colspan=3 height=17 class=xl42 style='height:12.75pt'></td>
  <td colspan=16 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td colspan=3 height=20 class=xl43 width=613 style='height:15.0pt;width:460pt'></td>
  <td colspan=9 style='mso-ignore:colspan'></td>
  <td colspan=3 class=xl44 width=211 style='width:158pt'></td>
  <td colspan=4 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl36 style='height:15.0pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 class=xl37 style='height:12.75pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 class=xl32 width=329 style='height:12.75pt;width:247pt'><rw:field id="f_P_SYSDATE" src="P_SYSDATE" /></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl38 style='height:15.0pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl38 width=329 style='height:15.0pt;width:247pt'>Начальник
  Операционного Управления</td>
  <td></td>
  <td>Ганаховская Н.С.</td>
  <td colspan=16 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl38 style='height:15.0pt'></td>
  <td colspan=11 style='mso-ignore:colspan'></td>
  <td colspan=3 class=xl44 width=211 style='width:158pt'></td>
  <td colspan=4 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl36 style='height:15.0pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 class=xl39 style='height:12.75pt'>Исполнитель: <rw:field id="f_P_EXECUTOR" src="P_EXECUTOR" /></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl36 style='height:15.0pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl40 style='height:15.0pt'></td>
  <td colspan=18 style='mso-ignore:colspan'></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=329 style='width:247pt'></td>
  <td width=65 style='width:49pt'></td>
  <td width=219 style='width:164pt'></td>
  <td width=32 style='width:24pt'></td>
  <td width=22 style='width:17pt'></td>
  <td width=22 style='width:17pt'></td>
  <td width=15 style='width:11pt'></td>
  <td width=13 style='width:10pt'></td>
  <td width=14 style='width:11pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=83 style='width:62pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
 </tr>
 <![endif]>
</table>

</body>

</html>

</rw:report>
