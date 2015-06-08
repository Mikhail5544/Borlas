<%@ include file="/inc/header_excel.jsp" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.DecimalFormat" %>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="bordero" DTDVersion="9.0.2.0.10"
beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="reestr" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
   <userParameter name="P_CH_ID"/>
   <userParameter name="P_CH_CUR"/>
    <userParameter name="P_TRANS_CH_ID"/>
	<userParameter name="DEPT" datatype="character" width="150"
     defaultWidth="0" defaultHeight="0"/>
      <dataSource name="Q_1">
      <select>
      <![CDATA[
	   
 (select 'Субагент' type_ag,
	   			ah.ag_contract_header_id id_num,
           d.num ad_num,
          decode(ch.description,'DSF',ch.description,'SAS',ch.description,'') chn,
          ent.obj_name(c.ent_id,c.contact_id) agent_name,
          trans_ag.trans_ad_num,
          trans_ag.trans_chn,
          trans_ag.trans_agent_name
   from AG_CONTRACT_HEADER AH
        left join AG_CONTRACT AC on (ac.ag_contract_id = ah.last_ver_id)
        left join t_sales_channel ch on (ch.id = ah.t_sales_channel_id)
        left join document d on (d.document_id = ah.ag_contract_header_id)
        left join contact c on (c.contact_id = ah.agent_id)
        left join (select d.num trans_ad_num,
                decode(ch.description,'DSF',ch.description,'SAS',ch.description,'') trans_chn,
                ent.obj_name(c.ent_id,c.contact_id) trans_agent_name
         from AG_CONTRACT_HEADER AH
              left join AG_CONTRACT AC on (ac.ag_contract_id = ah.last_ver_id)
              left join t_sales_channel ch on (ch.id = ah.t_sales_channel_id)
              left join document d on (d.document_id = ah.ag_contract_header_id)
              left join contact c on (c.contact_id = ah.agent_id)
         where AH.AG_CONTRACT_HEADER_ID = :P_TRANS_CH_ID) trans_ag on (1=1)
   where AH.AG_CONTRACT_HEADER_ID = :P_CH_ID)
  union all       
         
  (select  'Менеджер',
  			ah.ag_contract_header_id,
           ld.num,
          decode(lch.description,'DSF',lch.description,'SAS',lch.description,''),
          ent.obj_name(lc.ent_id,lc.contact_id),
          trans_ag.trans_lead_num,
          trans_ag.trans_lead_chn,
          trans_ag.trans_lead_name
   from AG_CONTRACT_HEADER AH
        left join AG_CONTRACT AC on (ac.ag_contract_id = ah.last_ver_id)
        left join ag_contract lead_ag on (lead_ag.ag_contract_id = ac.contract_leader_id)
        left join ag_contract_header lead_head on (lead_head.ag_contract_header_id = lead_ag.contract_id)
        left join ag_contract lead_agl on (lead_agl.ag_contract_id = pkg_agent_1.get_status_by_date(lead_head.ag_contract_header_id,sysdate))
        left join t_sales_channel lch on (lch.id = lead_head.t_sales_channel_id)
        left join document ld on (ld.document_id = lead_head.ag_contract_header_id)
        left join contact lc on (lc.contact_id = lead_head.agent_id)
        left join (select ld.num trans_lead_num,
                decode(lch.description,'DSF',lch.description,'SAS',lch.description,'') trans_lead_chn,
                ent.obj_name(lc.ent_id,lc.contact_id) trans_lead_name
         from AG_CONTRACT_HEADER AH
              left join AG_CONTRACT AC on (ac.ag_contract_id = ah.last_ver_id)
              left join ag_contract lead_ag on (lead_ag.ag_contract_id = ac.contract_leader_id)
              left join ag_contract_header lead_head on (lead_head.ag_contract_header_id = lead_ag.contract_id)
              left join ag_contract lead_agl on (lead_agl.ag_contract_id = pkg_agent_1.get_status_by_date(lead_head.ag_contract_header_id,sysdate))
              left join t_sales_channel lch on (lch.id = lead_head.t_sales_channel_id)
              left join document ld on (ld.document_id = lead_head.ag_contract_header_id)
              left join contact lc on (lc.contact_id = lead_head.agent_id)
         where AH.AG_CONTRACT_HEADER_ID = :P_TRANS_CH_ID) trans_ag on (1=1)
   where AH.AG_CONTRACT_HEADER_ID = :P_CH_ID)
         
   union      
         
  ( select  'Директор',
  			    ah.ag_contract_header_id,
            dd.num,
            decode(dch.description,'DSF',dch.description,'SAS',dch.description,''),
            ent.obj_name(dc.ent_id,dc.contact_id),
            trans_ag.trans_dir_num,
            trans_ag.trans_dir_chn,
            trans_ag.trans_dir_name
   from AG_CONTRACT_HEADER AH
        left join AG_CONTRACT AC on (ac.ag_contract_id = ah.last_ver_id)
        left join ag_contract lead_ag on (lead_ag.ag_contract_id = ac.contract_leader_id)
        left join ag_contract_header lead_head on (lead_head.ag_contract_header_id = lead_ag.contract_id)
        left join ag_contract lead_agl on (lead_agl.ag_contract_id = pkg_agent_1.get_status_by_date(lead_head.ag_contract_header_id,sysdate))
        left join ag_contract dir_ag on (dir_ag.ag_contract_id = lead_agl.contract_leader_id)
        left join ag_contract_header dir_head on (dir_head.ag_contract_header_id = dir_ag.contract_id)
        left join ag_contract dir_agl on (dir_agl.ag_contract_id = pkg_agent_1.get_status_by_date(dir_head.ag_contract_header_id,sysdate))
        left join t_sales_channel dch on (dch.id = dir_head.t_sales_channel_id)
        left join document dd on (dd.document_id = dir_head.ag_contract_header_id)
        left join contact dc on (dc.contact_id = dir_head.agent_id)
        left join (select dd.num trans_dir_num,
                          decode(dch.description,'DSF',dch.description,'SAS',dch.description,'') trans_dir_chn,
                          ent.obj_name(dc.ent_id,dc.contact_id) trans_dir_name
                   from AG_CONTRACT_HEADER AH
                        left join AG_CONTRACT AC on (ac.ag_contract_id = ah.last_ver_id)
                        left join ag_contract lead_ag on (lead_ag.ag_contract_id = ac.contract_leader_id)
                        left join ag_contract_header lead_head on (lead_head.ag_contract_header_id = lead_ag.contract_id)
                        left join ag_contract lead_agl on (lead_agl.ag_contract_id = pkg_agent_1.get_status_by_date(lead_head.ag_contract_header_id,sysdate))
                        left join ag_contract dir_ag on (dir_ag.ag_contract_id = lead_agl.contract_leader_id)
                        left join ag_contract_header dir_head on (dir_head.ag_contract_header_id = dir_ag.contract_id)
                        left join ag_contract dir_agl on (dir_agl.ag_contract_id = pkg_agent_1.get_status_by_date(dir_head.ag_contract_header_id,sysdate))
                        left join t_sales_channel dch on (dch.id = dir_head.t_sales_channel_id)
                        left join document dd on (dd.document_id = dir_head.ag_contract_header_id)
                        left join contact dc on (dc.contact_id = dir_head.agent_id)
                   where AH.AG_CONTRACT_HEADER_ID = :P_TRANS_CH_ID) trans_ag on (1=1)
   where AH.AG_CONTRACT_HEADER_ID = :P_CH_ID)
	   
	   ]]>
      </select>
      <group name="group_data">
        <dataItem name="id_num"/>
      </group>
    </dataSource>
	<dataSource name="Q_2">
      <select>
      <![CDATA[	select rownum rec_number,
	  					va.policy_header_id, 
               			va.num,
               			va.INSURER_NAME
              from V_AG_DOC_POLICY_CURRENT va where va.AG_CONTRACT_HEADER_ID = :P_CH_ID
	    ]]>
      </select>
      <group name="group_pol">
        <dataItem name="rec_number"/>
      </group>
    </dataSource>
	 <dataSource name="Q_3">
      <select>
      <![CDATA[select count(*) rec_count
  from V_AG_DOC_POLICY_CURRENT va 
  where va.AG_CONTRACT_HEADER_ID = :P_CH_ID]]>
      </select>
      <group name="group_count">
        <dataItem name="rec_count"/>
      </group>
    </dataSource>
<dataSource name="Q_4">
      <select>
      <![CDATA[	select rownum rec_number_1,
	  					va.policy_header_id policy_header_id_1, 
               			va.num num_1,
               			va.INSURER_NAME INSURER_NAME_1
              from V_AG_DOC_POLICY_CURRENT va 
			  where va.AG_CONTRACT_HEADER_ID = :P_CH_ID
			  		and va.DOC_STATUS_NAME = 'Действующий'
	    ]]>
      </select>
      <group name="group_pol_1">
        <dataItem name="rec_number_1"/>
      </group>
    </dataSource>
	 <dataSource name="Q_5">
      <select>
      <![CDATA[select count(*) rec_count_1
  from V_AG_DOC_POLICY_CURRENT va 
  where va.AG_CONTRACT_HEADER_ID = :P_CH_ID
  		and va.DOC_STATUS_NAME = 'Действующий']]>
      </select>
      <group name="group_count_1">
        <dataItem name="rec_count_1"/>
      </group>
    </dataSource>	
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

         select dep.name
		 into :DEPT
         from AG_CONTRACT_HEADER AH,
              AG_CONTRACT AC,
              department dep
         where ac.ag_contract_id = ah.last_ver_id
               and dep.department_id = ac.agency_id
               and AH.AG_CONTRACT_HEADER_ID = :P_CH_ID;


return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
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
	{mso-displayed-decimal-separator:"\.";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.75in .7in .75in .7in;
	mso-header-margin:.3in;
	mso-footer-margin:.3in;
	mso-page-orientation:landscape;}
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
	font-size:10.0pt;
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
	font-size:10.0pt;
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
	border-bottom:none;
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
.xl75
	{mso-style-parent:style0;
	text-align:right;
	border:none;}
.xl76
	{mso-style-parent:style0;
	text-align:center;
	border:none;
	font-size:6.0pt;}
.xl77
	{mso-style-parent:style0;
	text-align:center;
	border:none;}
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
%>


 <rw:getValue id="j_ch_cur" src="P_CH_CUR"/>

 <% if (j_ch_cur.equals("1")) { %>
 	<rw:foreach id="fi01" src="group_count_1">
  		<rw:getValue id="j_rec_count_1" src="rec_count_1"/>
  		<% rec_count_all = new Integer(j_rec_count_1).intValue(); %>
  	</rw:foreach>
 <% } else { %>
 	<rw:foreach id="fi0" src="group_count">
  		<rw:getValue id="j_rec_count" src="rec_count"/>
  		<% rec_count_all = new Integer(j_rec_count).intValue(); %>
  	</rw:foreach>
 <% } %>
  

<body link=blue vlink=purple>

<table x:str border=0 cellpadding=0 cellspacing=0 width=400 style='border-collapse:
 collapse;table-layout:fixed;width:400pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:1755;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:2998;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:3181;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:2230;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:3072;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:5997;width:50pt'>
 <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=7 height=62 class=xl73 width=400 style='height:46.5pt;width:400pt'>Акт передачи договоров страхования</td>
 </tr>
 
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl71 width=50 colspan=3 style='height:30.0pt;border-top:none;width:36pt'>Агентство:</td>
  <td height=40 class=xl71 width=50 colspan=4 style='height:30.0pt;border-top:none;width:36pt'><rw:field id="" src="DEPT"/></td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl71 width=50 colspan=3 style='height:30.0pt;border-top:none;width:36pt'>Отчетный месяц:</td>
  <td height=40 class=xl71 width=50 colspan=4 style='height:30.0pt;border-top:none;width:36pt'>__________________________</td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl71 width=50 colspan=3 style='height:30.0pt;border-top:none;width:36pt'>Дата составления:</td>
  <td height=40 class=xl71 width=50 colspan=4 style='height:30.0pt;border-top:none;width:36pt'>__________________________</td>
 </tr>
 
<tr height=40 style='height:30.0pt'>
  <td height=40 class=xl71 width=50 colspan=7 style='height:30.0pt;border-top:none;width:36pt'></td>
</tr>

<tr height=40 style='height:30.0pt'>
  <td height=40 class=xl71 width=50 colspan=7 style='height:30.0pt;border-top:none;width:36pt'>Таблица №1. Структура субагентской сети</td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl65 width=50 rowspan=2 style='height:30.0pt;border-top:none;width:36pt'>Тип агента</td>
  <td class=xl65 width=50 colspan=3 style='border-top:none;border-left:none;width:50pt'>Данные по агенту / субагенту, с которого передаются договора страхования</td>
  <td class=xl65 width=50 colspan=3 style='border-top:none;border-left:none;width:50pt'>Данные по агенту / субагенту, на которого передаются договора страхования</td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>ИД</td>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>Вид агентской сети (SAS/DSF)</td>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>ФИО</td>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>ИД</td>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>Вид агентской сети (SAS/DSF)</td>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>ФИО</td>
 </tr>
 
 <rw:foreach id="fi1" src="group_data">
 
 <tr height=20 style='height:15.0pt'>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="type_ag"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ad_num"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="chn"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="agent_name"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="trans_ad_num"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="trans_chn"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="trans_agent_name"/></td>
 </tr>
 
 </rw:foreach>

 <tr height=40 style='height:30.0pt;mso-xlrowspan:2'>
  <td height=40 colspan=3 style='height:30.0pt;mso-ignore:colspan'></td>
 </tr>
 </table>
 
 <table x:str border=0 cellpadding=0 cellspacing=0 width=400 style='border-collapse:
 collapse;table-layout:fixed;width:400pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:1755;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:2998;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:3181;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:2230;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:3072;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:5997;width:50pt'>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl71 width=50 colspan=3 style='height:30.0pt;border-top:none;width:36pt'>Таблица №2. Договора страхования</td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>№ п/п</td>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>№ договора страхования</td>
  <td class=xl65 width=50 style='border-top:none;border-left:none;width:50pt'>ФИО Страхователя</td>
 </tr>

<% if (j_ch_cur.equals("1")) { %>
	<rw:foreach id="fi2" src="group_pol_1">
	<tr height=20 style='height:15.0pt'>
 	<td class=xl69 style='border-top:none;border-left:none'><%=++rec_count_current%></td>
  	<td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="num_1"/></td>
  	<td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="insurer_name_1"/></td>
 	</tr>
	</rw:foreach>
<% } else { %>
	<rw:foreach id="fi3" src="group_pol">
	<tr height=20 style='height:15.0pt'>
 	<td class=xl69 style='border-top:none;border-left:none'><%=++rec_count_current%></td>
  	<td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="num"/></td>
  	<td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="insurer_name"/></td>
 	</tr>
	</rw:foreach>
<% } %>

 
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl72 style='height:15.0pt'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=50 style='width:50pt'></td>
  <td width=50 style='width:50pt'></td>
  <td width=50 style='width:50pt'></td>
  <td width=50 style='width:50pt'></td>
  <td width=50 style='width:50pt'></td>
  <td width=50 style='width:50pt'></td>
  <td width=50 style='width:50pt'></td>
 </tr>
 <![endif]>
</table>

<table x:str border=0 cellpadding=0 cellspacing=0 width=400 style='border-collapse:
 collapse;table-layout:fixed;width:400pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:1755;width:50pt'>
 <col width=50 style='mso-width-source:userset;mso-width-alt:2998;width:50pt'>
 <tr height=40 style='height:30.0pt'>
  <td class=xl75 width=50 colspan=3 style='border-top:none;border-left:none;width:50pt'>Директор обособленного подразделения:</td>
  <td class=xl77 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>____________________/</td>
  <td class=xl77 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>_______________________________________/</td>
 </tr>
 <tr height=20 style='height:5.0pt'>
  <td class=xl76 width=50 colspan=3 style='border-top:none;border-left:none;width:50pt'></td>
  <td class=xl76 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>подпись</td>
  <td class=xl76 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>ФИО</td>
 </tr>
 
 <tr height=40 style='height:30.0pt'>
  <td class=xl75 width=50 colspan=3 style='border-top:none;border-left:none;width:50pt'>Менеджер:</td>
  <td class=xl77 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>____________________/</td>
  <td class=xl77 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>_______________________________________/</td>
 </tr>
 <tr height=20 style='height:5.0pt'>
  <td class=xl76 width=50 colspan=3 style='border-top:none;border-left:none;width:50pt'></td>
  <td class=xl76 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>подпись</td>
  <td class=xl76 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>ФИО</td>
 </tr>
 
 <tr height=40 style='height:30.0pt'>
  <td class=xl75 width=50 colspan=3 style='border-top:none;border-left:none;width:150pt'>Субагент:</td>
  <td class=xl77 width=50 colspan=2 style='border-top:none;border-left:none;width:150pt'>____________________/</td>
  <td class=xl77 width=50 colspan=2 style='border-top:none;border-left:none;width:150pt'>_______________________________________/</td>
 </tr>
 <tr height=20 style='height:5.0pt'>
  <td class=xl76 width=50 colspan=3 style='border-top:none;border-left:none;width:150pt'></td>
  <td class=xl76 width=50 colspan=2 style='border-top:none;border-left:none;width:150pt'>подпись</td>
  <td class=xl76 width=50 colspan=2 style='border-top:none;border-left:none;width:150pt'>ФИО</td>
 </tr>
 
 <tr height=40 style='height:30.0pt'>
  <td class=xl75 width=50 colspan=3 style='border-top:none;border-left:none;width:50pt'>Специалист РОО:</td>
  <td class=xl77 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>____________________/</td>
  <td class=xl77 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>_______________________________________/</td>
 </tr>
 <tr height=20 style='height:5.0pt'>
  <td class=xl76 width=50 colspan=3 style='border-top:none;border-left:none;width:50pt'></td>
  <td class=xl76 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>подпись</td>
  <td class=xl76 width=50 colspan=2 style='border-top:none;border-left:none;width:50pt'>ФИО</td>
 </tr>

</table>

</body>

</html>


</rw:report>
