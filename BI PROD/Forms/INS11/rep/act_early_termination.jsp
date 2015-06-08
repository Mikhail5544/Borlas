<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="act_early_termination" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="ACT_EARLY_TERMINATION" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_NACHIS_ITOGO" datatype="character" width="50"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_VOZVRAT_ITOGO" datatype="character" width="50"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_EXECUTOR" datatype="character" width="100"
     precision="10" defaultWidth="0" defaultHeight="0"/>
   <dataSource name="Q_1">
      <select>
      <![CDATA[select
rownum as n1, 
p.pol_ser || ' ' || p.pol_num as pol_num,
ent.obj_name('CONTACT',pkg_policy.get_policy_holder_id(p.policy_id)) as pol_holder,
p.notice_num,
pkg_rep_utils.to_money(p.med_cost) as med_cost,
to_char(p.decline_date,'dd.mm.yyyy') as decline_date,
dt.name as decline_reason,
ent.obj_name('T_PAYMENT_TERMS',p.payment_term_id) as period,
decode(lower(tprt.description),'город',tpr.province_name,
                                'республика',decode(tpr.province_name,
								                     'Кабардино-Балкарская',tpr.province_name||' '||tprt.description,
													 'Карачаево-Черкесская',tpr.province_name||' '||tprt.description,
													 'Удмуртская',tpr.province_name||' '||tprt.description,
													 'Чеченская',tpr.province_name||' '||tprt.description,
													 'Чувашская',tpr.province_name||' '||tprt.description,
								                     tprt.description || ' ' || tpr.province_name),
                                 tpr.province_name||' '||lower(tprt.description))  region,
f.brief	as valuta,
to_char(sysdate,'dd.mm.yyyy') as f_sysdate,
decode (dp.brief,'По соглашению сторон','.2)','Страхователь','.2)',
                 'Страховщик','.1)',')') as rule_point,
ent.obj_name('T_PRODUCT',ph.product_id) as product_name,
decode (f.brief,'RUR',0,1) as is_ukaz_sum						 
 from ven_p_policy p, 
      ven_t_decline_type dt,
	  ven_t_decline_party dp ,  
	  ven_t_province tpr,
	  ven_t_province_type tprt,
	  ven_p_pol_header ph,
	  ven_fund f
where p.policy_id = :P_POLICY_ID
  and dt.t_decline_type_id(+) = p.decline_type_id
  and dp.t_decline_party_id(+) = p.decline_party_id 
  and tpr.province_id(+) = p.region_id
  and tprt.province_type_id(+) = tpr.province_type_id
  and ph.policy_header_id = p.pol_header_id
  and f.fund_id = ph.fund_id]]>
      </select>
      <group name="G_MAIN"><dataItem name="n1"/></group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[ select 
    rownum as n2,
	dd.prod_line_name as prod_line_name,
	round(months_between(pc.end_date,pc.start_date)/12) as srok,
	pkg_rep_utils.to_money(dd.return_summ) as prem_vozvr,
    pkg_rep_utils.to_money(dd.added_summ - dd.payed_summ) as prem_nachisl
from v_decline_details dd, ven_p_cover pc
 where pc.p_cover_id = dd.cover_id  
 and  dd.policy_id =  :P_POLICY_ID --115222 ]]>
      </select>
      <group name="G2"><dataItem name="n2"/></group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin
select pkg_contact.get_fio_fmt(ent.obj_name('CONTACT', e.contact_id),4)
  into :P_EXECUTOR
  from sys_user su, employee e
 where e.employee_id(+) = su.employee_id
   and su.sys_user_name = user;

select 
    pkg_rep_utils.to_money(sum(pkg_payment.get_charge_cover_amount_pfa(pc.start_date,pc.end_date,dd.cover_id) -
	pkg_payment.get_pay_cover_amount_pfa(pc.start_date,pc.end_date,dd.cover_id))),
	pkg_rep_utils.to_money(sum(dd.decline_summ)) as prem_vozvr
into :P_NACHIS_ITOGO, :P_VOZVRAT_ITOGO
 from v_decline_details dd, ven_p_cover pc 
 where pc.p_cover_id = dd.cover_id
 and  dd.policy_id = :P_POLICY_ID;
return (true);
exception 
when no_data_found then return (true);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<style>
<!--table
	{mso-displayed-decimal-separator:"\,";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.26in .26in .98in .21in;
	mso-header-margin:.26in;
	mso-footer-margin:.5in;}
.font9
	{color:#FF9900;
	font-size:11.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;}
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
	font-family:Arial, sans-serif;
	mso-font-charset:0;}
.xl25
	{mso-style-parent:style0;
	color:#FF9900;
	font-size:11.0pt;
	font-weight:700;
	text-decoration:underline;
	text-underline-style:single;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:justify;}
.xl26
	{mso-style-parent:style0;
	color:#FF9900;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	mso-number-format:"Short Date";
	text-align:right;}
.xl27
	{mso-style-parent:style0;
	color:navy;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:justify;}
.xl28
	{mso-style-parent:style0;
	color:navy;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:left;}
.xl29
	{mso-style-parent:style0;
	text-align:left;}
.xl30
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;}
.xl31
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;}
.xl32
	{mso-style-parent:style0;
	mso-number-format:"Short Date";}
.xl33
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:justify;}
.xl34
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:justify;}
.xl35
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:center;}
.xl36
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:center;
	vertical-align:top;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl37
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl38
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	mso-number-format:Fixed;
	text-align:center;
	vertical-align:top;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl39
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:left;}
.xl40
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	mso-number-format:"Short Date";
	text-align:left;}
.xl41
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:left;}
.xl42
	{mso-style-parent:style0;
	font-weight:700;
	font-family:Arial, sans-serif;
	mso-font-charset:204;
	text-align:left;}
.xl43
	{mso-style-parent:style0;
	font-weight:700;
	font-family:Arial, sans-serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;}
.xl44
	{mso-style-parent:style0;
	color:#FF9900;
	font-size:14.0pt;
	font-weight:700;
	font-family:Arial, sans-serif;
	mso-font-charset:0;
	text-align:center;}
.xl45
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:center;}
.xl46
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	mso-number-format:"Short Date";
	text-align:left;}
.xl47
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	text-decoration:underline;
	text-underline-style:single;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:left;}
.xl48
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:center;
	vertical-align:top;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	white-space:normal;}
.xl49
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:center;
	vertical-align:top;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl50
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:center;
	vertical-align:top;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid black;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl51
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:left;
	white-space:normal;}
.xl52
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	white-space:normal;}
.xl53
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	mso-number-format:Standard;
	text-align:left;}
.xl54
	{mso-style-parent:style0;
	font-size:11.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:0;
	text-align:left;
	white-space:normal;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>отказ от полиса_акт</x:Name>
    <x:WorksheetOptions>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:Scale>79</x:Scale>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:CodeName>Sheet3</x:CodeName>
     <x:PageBreakZoom>60</x:PageBreakZoom>
     <x:Selected/>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>8</x:ActiveRow>
       <x:ActiveCol>1</x:ActiveCol>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>11640</x:WindowHeight>
  <x:WindowWidth>15480</x:WindowWidth>
  <x:WindowTopX>480</x:WindowTopX>
  <x:WindowTopY>570</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
 <x:ExcelName>
  <x:Name>Print_Area</x:Name>
  <x:SheetIndex>1</x:SheetIndex>
  <x:Formula>='отказ от полиса_акт'!$A$1:$H$56</x:Formula>
 </x:ExcelName>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="1027"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body link=blue vlink=purple>
<rw:foreach id="rg_main" src="G_main">
<table x:str border=0 cellpadding=0 cellspacing=0 width=1263 style='border-collapse:
 collapse;table-layout:fixed;width:947pt'>
 <col width=6 style='mso-width-source:userset;mso-width-alt:219;width:5pt'>
 <col width=64 style='width:48pt'>
 <col width=80 style='mso-width-source:userset;mso-width-alt:2925;width:60pt'>
 <col width=71 style='mso-width-source:userset;mso-width-alt:2596;width:53pt'>
 <col width=114 style='mso-width-source:userset;mso-width-alt:4169;width:86pt'>
 <col width=131 style='mso-width-source:userset;mso-width-alt:4790;width:98pt'>
 <col width=172 style='mso-width-source:userset;mso-width-alt:6290;width:129pt'>
 <col width=171 style='mso-width-source:userset;mso-width-alt:6253;width:128pt'>
 <col width=71 style='mso-width-source:userset;mso-width-alt:2596;width:53pt'>
 <col width=56 style='mso-width-source:userset;mso-width-alt:2048;width:42pt'>
 <col width=71 style='mso-width-source:userset;mso-width-alt:2596;width:53pt'>
 <col width=64 span=4 style='width:48pt'>
 <tr height=17 style='height:12.75pt'>
  <td height=17 width=6 style='height:12.75pt;width:5pt'><a name="Print_Area"></a></td>
  <td width=64 style='width:48pt' align=left valign=top><!--[if gte vml 1]><v:shapetype
   id="_x0000_t75" coordsize="21600,21600" o:spt="75" o:preferrelative="t"
   path="m@4@5l@4@11@9@11@9@5xe" filled="f" stroked="f">
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
  </v:shapetype><v:shape id="_x0000_s1026" type="#_x0000_t75" style='position:absolute;
   margin-left:1.5pt;margin-top:9pt;width:162.75pt;height:48pt;z-index:1'>
   <v:imagedata src="<%=g_ImagesRoot%>/act_early_termination/image001.gif" o:title="image002"/>
   <x:ClientData ObjectType="Pict">
    <x:SizeWithCells/>
    <x:CF>Bitmap</x:CF>
    <x:AutoPict/>
   </x:ClientData>
  </v:shape><![endif]--><![if !vml]><span style='mso-ignore:vglayout;
  position:absolute;z-index:1;margin-left:2px;margin-top:12px;width:217px;
  height:64px'><img width=217 height=64
  src="<%=g_ImagesRoot%>/act_early_termination/image001.gif" v:shapes="_x0000_s1026"></span><![endif]><span
  style='mso-ignore:vglayout2'>
  <table cellpadding=0 cellspacing=0>
   <tr>
    <td height=17 width=64 style='height:12.75pt;width:48pt'></td>
   </tr>
  </table>
  </span></td>
  <td width=80 style='width:60pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=114 style='width:86pt'></td>
  <td width=131 style='width:98pt'></td>
  <td width=172 style='width:129pt'></td>
  <td width=171 style='width:128pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=56 style='width:42pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
 </tr>
 <tr height=102 style='height:76.5pt;mso-xlrowspan:6'>
  <td height=102 colspan=15 style='height:76.5pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=24 style='mso-height-source:userset;height:18.0pt'>
  <td height=24 style='height:18.0pt'></td>
  <td colspan=7 class=xl44>АКТ О ДОСРОЧНОМ ПРЕКРАЩЕНИИ ДОГОВОРА СТРАХОВАНИЯ</td>
  <td colspan=7 class=xl45></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td class=xl24></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl25>Москва<font class="font9"><span
  style='mso-spacerun:yes'>                  </span></font></td>
  <td colspan=5 style='mso-ignore:colspan'></td>
  <td class=xl26><rw:field id="f_f_sysdate" src="f_sysdate" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl27></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl28 colspan=3 style='mso-ignore:colspan'>Договор страхования:</td>
  <td></td>
  <td colspan=3 class=xl29><rw:field id="f_pol_num" src="pol_num" /><span
  style='mso-spacerun:yes'> </span></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=9 style='mso-height-source:userset;height:6.75pt'>
  <td height=9 style='height:6.75pt'></td>
  <td class=xl27></td>
  <td colspan=3 style='mso-ignore:colspan'></td>
  <td class=xl29></td>
  <td colspan=9 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl28 colspan=3 style='mso-ignore:colspan'>Заявление на страхование:</td>
  <td></td>
  <td colspan=3 class=xl29><rw:field id="f_notice_num" src="notice_num" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=8 style='mso-height-source:userset;height:6.0pt'>
  <td height=8 style='height:6.0pt'></td>
  <td class=xl27></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td class=xl28 colspan=2 style='mso-ignore:colspan'>Страхователь:</td>
  <td colspan=2 style='mso-ignore:colspan'></td>
  <td colspan=3 class=xl30><rw:field id="f_pol_holder" src="pol_holder" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=8 style='mso-height-source:userset;height:6.0pt'>
  <td height=8 style='height:6.0pt'></td>
  <td class=xl30></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl28 colspan=4 style='mso-ignore:colspan'>Причина досрочного
  прекращения Договора:</td>
  <td colspan=3></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=9 style='mso-height-source:userset;height:6.75pt'>
  <td height=9 style='height:6.75pt'></td>
  <td class=xl31></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 style='height:12.75pt'></td>
  <td colspan=7><rw:field id="f_decline_reason" src="decline_reason" /></td>
  <td></td>
  <td class=xl32></td>
  <td colspan=5 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=10 style='mso-height-source:userset;height:7.5pt'>
  <td height=10 style='height:7.5pt'></td>
  <td class=xl33></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td class=xl28 colspan=4 style='mso-ignore:colspan'>Дата досрочного
  прекращения Договора:</td>
  <td colspan=2 class=xl46><rw:field id="f_decline_date" src="decline_date" /></td>
  <td colspan=8 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=7 style='mso-height-source:userset;height:5.25pt'>
  <td height=7 style='height:5.25pt'></td>
  <td class=xl33></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td colspan=5 class=xl47>Условия Договора страхования:</td>
  <td colspan=2 style='mso-ignore:colspan'></td>
  <td colspan=2 class=xl32 style='mso-ignore:colspan'></td>
  <td colspan=5 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl34></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl28 colspan=2 style='mso-ignore:colspan'>Код региона:</td>
  <td colspan=2 class=xl28 style='mso-ignore:colspan'></td>
  <td colspan=3><rw:field id="f_region" src="region" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=9 style='mso-height-source:userset;height:6.75pt'>
  <td height=9 style='height:6.75pt'></td>
  <td colspan=4 class=xl28 style='mso-ignore:colspan'></td>
  <td colspan=10 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl28 colspan=4 style='mso-ignore:colspan'>Периодичность уплаты
  взносов:</td>
  <td colspan=3><rw:field id="f_period" src="period" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl35></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=49 style='mso-height-source:userset;height:36.75pt'>
  <td height=49 style='height:36.75pt'></td>
  <td colspan=4 class=xl48 width=329 style='border-right:.5pt solid black;
  width:247pt'>Программа</td>
  <td class=xl36 width=131 style='width:98pt'>Срок страхования</td>
  <td class=xl36 width=172 style='width:129pt'>Премия к возврату Страхователю, <rw:field id="f_valuta" src="valuta" /></td>
  <td class=xl36 width=171 style='width:128pt'>Начисленная премия к списанию, <rw:field id="f_valuta" src="valuta" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <rw:foreach id="rg2" src="G2">
 <tr height=57 style='mso-height-source:userset;height:42.75pt'>
  <td height=57 style='height:42.75pt'></td>
  <td colspan=4 class=xl48 width=329 style='border-right:.5pt solid black;
  width:247pt'><rw:field id="f_prod_line_name" src="prod_line_name" /><span style='mso-spacerun:yes'> </span></td>
  <td class=xl37 width=131 style='width:98pt'><rw:field id="f_srok" src="srok" /></td>
  <td class=xl38 width=172 style='width:129pt'><rw:field id="f_prem_vozvr" src="prem_vozvr" /></td>
  <td class=xl38 width=171 style='width:128pt'><rw:field id="f_prem_nachisl" src="prem_nachisl" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 </rw:foreach>
 <tr height=21 style='height:15.75pt'>
  <td height=21 style='height:15.75pt'></td>
  <td colspan=4 class=xl48 width=329 style='border-right:.5pt solid black;
  width:247pt'>ИТОГО</td>
  <td class=xl37 width=131 style='width:98pt'>&nbsp;</td>
  <td class=xl38 width=172 style='width:129pt'><rw:field id="f_P_VOZVRAT_ITOGO" src="P_VOZVRAT_ITOGO" /></td>
  <td class=xl38 width=171 style='width:128pt'><rw:field id="f_P_NACHIS_ITOGO" src="P_NACHIS_ITOGO" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl34></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl28 colspan=5 style='mso-ignore:colspan'>Решение принято на
  основании следующих документов:</td>
  <td colspan=2 class=xl28 style='mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=0 style='display:none'>
  <td height=0></td>
  <td colspan=7 class=xl39>Общие условия страхования по программе «Успешный
  старт» от 23.06.2006 г. (согласно п. 11.2.1.2)</td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=0 style='display:none;mso-height-source:userset;mso-height-alt:
  615'>
  <td height=0></td>
  <td colspan=7 class=xl51 width=803 style='width:602pt'>Общие условия
  страхования по программе «Гармония жизни» от 21.03.2005 г. (согласно п.
  11.2.1.2)</td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=41 style='mso-height-source:userset;height:30.75pt'>
  <td height=41 style='height:30.75pt'></td>
  <td colspan=4 class=xl51 width=329 style='width:247pt'>Общие условия
  страхования по программе:</td>
  <td colspan=3 class=xl52 width=474 style='width:355pt'><rw:field id="f_product_name" src="product_name" /> от 23.06.2006 (согласно п. 11.2<rw:field id="f_rule_point" src="rule_point" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=21 style='height:15.75pt'>
  <td height=21 style='height:15.75pt'></td>
  <td class=xl40 colspan=3 style='mso-ignore:colspan'>Заявление Страхователя</td>
  <td class=xl40><span style='mso-spacerun:yes'> </span></td>
  <td colspan=3 class=xl39 style='mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td colspan=7 class=xl41></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td colspan=7 class=xl41></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td colspan=7 class=xl41 style='mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl28 colspan=6 style='mso-ignore:colspan'>В связи с досрочным
  прекращением Договора сумма премии к возврату Страхователю:</td>
  <td class=xl28></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=19 style='height:14.25pt'>
  <td height=19 style='height:14.25pt'></td>
  <td class=xl34></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <rw:getValue id="flag_rur" src="is_ukaz_sum"/>
 <tr height=59 style='mso-height-source:userset;height:44.25pt'>
  <td height=59 style='height:44.25pt'></td>
  <td colspan=3 class=xl53><rw:field id="f_P_VOZVRAT_ITOGO" src="P_VOZVRAT_ITOGO" /> <rw:field id="f_valuta" src="valuta" /></td>
  <td colspan=4 class=xl54 width=588 style='width:441pt'><% if (flag_rur.equals("1")) { %>Указанная сумма должна
  быть рассчитана по курсу ЦБ РФ на дату выплаты <% } %></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td colspan=3 class=xl33><span style='mso-spacerun:yes'> </span></td>
  <td class=xl42><span style='mso-spacerun:yes'> </span></td>
  <td colspan=3><span style='mso-spacerun:yes'> </span></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <rw:getValue id="flag_med" src="med_cost"/>
 <tr height=18 style='mso-height-source:userset;height:13.5pt'>
  <td height=18 style='height:13.5pt'></td>
  <td colspan=7 rowspan=2 class=xl33><% if (!flag_med.equals("0,00")) { %>Из суммы к выплате удержана плата за медицинское обслуживание в размере <rw:field id="f_med_cost" src="med_cost" /> <rw:field id="f_valuta" src="valuta" /><% } %></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=3 style='mso-height-source:userset;height:2.25pt'>
  <td height=3 style='height:2.25pt'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td class=xl33></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td colspan=6 class=xl41
  x:str="Подпись: ________________                                                                             ">Подпись:
  ________________<span
  style='mso-spacerun:yes'>                                                                             </span></td>
  <td class=xl32><rw:field id="f_f_sysdate" src="f_sysdate" /></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td colspan=7 class=xl30>Ященко И.В., Операционный Директор</td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td class=xl33></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td class=xl41 colspan=2 style='mso-ignore:colspan' x:str="Подготовлено: ">Подготовлено:<span
  style='mso-spacerun:yes'> </span></td>
  <td colspan=4><rw:field id="f_P_EXECUTOR" src="P_EXECUTOR" /></td>
  <td colspan=8 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 colspan=15 style='height:12.75pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td class=xl33></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td class=xl33></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 colspan=15 style='height:12.75pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 style='height:12.75pt'></td>
  <td class=xl43></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 style='height:12.75pt'></td>
  <td class=xl43></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 style='height:12.75pt'></td>
  <td class=xl43></td>
  <td colspan=13 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=51 style='height:38.25pt;mso-xlrowspan:3'>
  <td height=51 colspan=15 style='height:38.25pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 style='height:15.0pt'></td>
  <td colspan=3 class=xl33></td>
  <td colspan=11 style='mso-ignore:colspan'></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=6 style='width:5pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=80 style='width:60pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=114 style='width:86pt'></td>
  <td width=131 style='width:98pt'></td>
  <td width=172 style='width:129pt'></td>
  <td width=171 style='width:128pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=56 style='width:42pt'></td>
  <td width=71 style='width:53pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
 </tr>
 <![endif]>
</table>

</rw:foreach>

</body>

</html>

</rw:report>
