<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="application/vnd.ms-excel;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bordero" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="reestr" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
   <userParameter name="P_SID"/>
    <userParameter name="PNUMBER"/>
	<userParameter name="NTID"/>
	<userParameter name="NUM"/>
    <userParameter name="P_MONTH" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	 <userParameter name="name_letter" datatype="character" width="250"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="SYS_DATE" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_YEAR" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
	<userParameter name="NOTIF" datatype="character" width="150"
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
       amount,
       fund,
       pol_num,
	     ids,
	     flag,
       dog_num,
       pol_ser,
	     type_contact,
	     gender,
       fee,
       start_date,
       ag_fio,
       dept,
       date_index
from (
select payment_period,
       contact_name,
       address_name,
	     code,
       init_name,
       due_date,
       amount,
       fund,
       pol_num,
	     ids,
	     flag,
       dog_num,
       pol_ser,
	     type_contact,
	     gender,
       trim(to_char(sum(fee),'999999999D99')) fee,
       start_date,
       ag_fio,
       dept,
       date_index
from
(select --rownum rec_number,
       vlp.payment_period,
       vlp.contact_name,
       vlp.address_name,
	   vlp.code,
       vlp.init_name,
       to_char(min(vlp.due_date), 'dd.mm.yyyy') due_date,
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
     pc.fee,
     to_char(ph.start_date, 'dd.mm.yyyy') start_date,
     agc.obj_name_orig ag_fio,
     dep.name dept,
     to_char(h.date_index, 'dd.mm.yyyy') date_index
       
  from iv_letters_payment vlp, 
       notif_letter_rep nlr,
       p_pol_header ph,
       p_policy pp,
       
       as_asset a,
       p_cover pc,
       p_policy_agent pa,
       ag_contract_header ag,
       contact agc,
       department dep,
       policy_index_item it,
       policy_index_header h
 where vlp.pol_header_id = nlr.document_id
   and nlr.sessionid = :P_SID
   --and vlp.mb <> 12
   and ph.policy_header_id = vlp.pol_header_id
  and pp.pol_header_id = ph.policy_header_id
  and pp.version_num = (select max(p.version_num)
                        from p_policy p
                        where p.pol_header_id = ph.policy_header_id)
   and pp.policy_id = a.p_policy_id
   and a.as_asset_id = pc.as_asset_id
   and pa.policy_header_id = ph.policy_header_id
   and pa.status_id = 1
   and pa.ag_contract_header_id = ag.ag_contract_header_id
   and agc.contact_id = ag.agent_id
   and ag.agency_id = dep.department_id
   and it.policy_header_id = ph.policy_header_id
   and it.policy_index_header_id = h.policy_index_header_id
   group by vlp.payment_period,
       vlp.contact_name,
       vlp.address_name,
	   vlp.code,
       vlp.init_name,
       
       to_char(vlp.sum_fee,'999999999D99'),
       vlp.fund,
       pp.pol_num,
	   ph.ids,
	   case when length(pp.pol_num)>6 then 1 else 0 end,
       case when length(pp.pol_num)>6 then substr(pp.pol_num,4,6) else pp.pol_num end,
       case when length(pp.pol_num)>6 then substr(pp.pol_num,1,3) else pp.pol_ser end,
	   vlp.type_contact,
	   vlp.gender,
     pc.fee,
     to_char(ph.start_date, 'dd.mm.yyyy'),
     agc.obj_name_orig,
     dep.name,
     to_char(h.date_index, 'dd.mm.yyyy'))
     group by 
     payment_period,
       contact_name,
       address_name,
	     code,
       init_name,
       due_date,
       amount,
       fund,
       pol_num,
	     ids,
	     flag,
       dog_num,
       pol_ser,
	     type_contact,
	     gender,
       start_date,
       ag_fio,
       dept,
       date_index)]]>
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
xmlns:x="urn:schemas-microsoft-com:office:excel"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<link rel=File-List href="??????%20??????.files/filelist.xml">
<link rel=Edit-Time-Data href="??????%20??????.files/editdata.mso">
<link rel=OLE-Object-Data href="??????%20??????.files/oledata.mso">
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>dzerassa.boraeva</o:Author>
  <o:LastAuthor>V</o:LastAuthor>
  <o:LastPrinted>2009-06-09T12:24:06Z</o:LastPrinted>
  <o:Created>2009-06-09T07:48:44Z</o:Created>
  <o:LastSaved>2009-06-09T12:24:26Z</o:LastSaved>
  <o:Company>Grizli777</o:Company>
  <o:Version>11.8107</o:Version>
 </o:DocumentProperties>
</xml><![endif]-->
<style>
<!--table
	{mso-displayed-decimal-separator:"\.";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.75in .7in .75in .7in;
	mso-header-margin:.3in;
	mso-footer-margin:.3in;
	mso-page-orientation:landscape;}
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
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:204;
	border:none;
	mso-protection:locked visible;
	mso-style-name:???????;
	mso-style-id:0;}
td
	{mso-style-parent:style0;
	padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
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
.xl65
	{mso-style-parent:style0;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:silver;
	mso-pattern:auto none;
	white-space:normal;}
.xl66
	{mso-style-parent:style0;
	border:.5pt solid windowtext;}
.xl67
	{mso-style-parent:style0;
	font-weight:700;}
.xl68
	{mso-style-parent:style0;
	vertical-align:middle;}
.xl69
	{mso-style-parent:style0;
	text-align:center;
	border:.5pt solid windowtext;}
.xl70
	{mso-style-parent:style0;
	font-weight:700;
	font-style:italic;}
.xl71
	{mso-style-parent:style0;
	font-weight:700;
	text-align:left;}
.xl72
	{mso-style-parent:style0;
	font-style:italic;}
.xl73
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl74
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>????1</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:Selected/>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>17</x:ActiveRow>
       <x:ActiveCol>6</x:ActiveCol>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????2</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
   <x:ExcelWorksheet>
    <x:Name>????3</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>300</x:DefaultRowHeight>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>11955</x:WindowHeight>
  <x:WindowWidth>18975</x:WindowWidth>
  <x:WindowTopX>-615</x:WindowTopX>
  <x:WindowTopY>270</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
</xml><![endif]-->
</head>


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

<body link=blue vlink=purple>

<table x:str border=0 cellpadding=0 cellspacing=0 width=741 style='border-collapse:
 collapse;table-layout:fixed;width:557pt'>
 <col width=48 style='mso-width-source:userset;mso-width-alt:1755;width:36pt'>
 <col width=82 style='mso-width-source:userset;mso-width-alt:2998;width:62pt'>
 <col width=87 style='mso-width-source:userset;mso-width-alt:3181;width:65pt'>
 <col width=61 style='mso-width-source:userset;mso-width-alt:2230;width:46pt'>
 <col width=84 style='mso-width-source:userset;mso-width-alt:3072;width:63pt'>
 <col width=164 style='mso-width-source:userset;mso-width-alt:5997;width:123pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 <col width=105 style='mso-width-source:userset;mso-width-alt:3840;width:79pt'>
 <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=8 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt'>Отчет (письма Индексация)</td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Дата индексации</td>
  <td class=xl65 width=87 style='border-top:none;border-left:none;width:65pt'>№ полиса</td>
  <td class=xl65 width=61 style='border-top:none;border-left:none;width:46pt'>Дата начала действия</td>
  <td class=xl65 width=84 style='border-top:none;border-left:none;width:63pt'>Дата платежа</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:123pt'>Индексированный взнос</td>
  <td class=xl65 width=110 style='border-top:none;border-left:none;width:83pt'>Страхователь</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Агент</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Менеджер</td>
  <td class=xl65 width=105 style='border-top:none;border-left:none;width:79pt'>Подразделение</td>
 </tr>
 
 <rw:foreach id="fi2" src="group_data">
 
 <tr height=20 style='height:15.0pt'>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="f_date_index" src="date_index"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="f_pol_num" src="pol_num"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="f_start_date" src="start_date"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="f_due_date" src="due_date"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="f_fee" src="fee"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="f_contact_name" src="contact_name"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="f_ag_gio" src="ag_fio"/></td>
  <td class=xl69 style='border-top:none;border-left:none'>&nbsp;</td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="f_dept" src="dept"/></td>
 </tr>
 
 </rw:foreach>
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=8 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl70 style='height:15.0pt'>Всего: <%=rec_count_all%></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=8 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 colspan=6 style='height:15.0pt;mso-ignore:colspan'>Передал:
  ____________________/______________________________________</td>
  <td colspan=2 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 style='height:15.0pt'></td>
  <td colspan=7 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 class=xl71 colspan=6 style='height:15.0pt;mso-ignore:colspan'>Принял:
  _____________________/______________________________________</td>
  <td colspan=2 class=xl67 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=40 style='height:30.0pt;mso-xlrowspan:2'>
  <td height=40 colspan=8 style='height:30.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl72 style='height:15.0pt'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=48 style='width:36pt'></td>
  <td width=82 style='width:62pt'></td>
  <td width=87 style='width:65pt'></td>
  <td width=61 style='width:46pt'></td>
  <td width=84 style='width:63pt'></td>
  <td width=164 style='width:123pt'></td>
  <td width=110 style='width:83pt'></td>
  <td width=105 style='width:79pt'></td>
 </tr>
 <![endif]>
</table>

</body>

</html>


</rw:report>
