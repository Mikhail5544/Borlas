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
      <![CDATA[  select count(*) rec_count
    from notif_letter_rep rep
   where rep.sessionid = :P_SID
           ]]>
      </select>
      <group name="group_count">
        <dataItem name="rec_count"/>
      </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[
SELECT rownum
	  ,t.*
FROM
(
SELECT  ROWNUM rec_num
	  ,ids
      ,pol_num
      ,holder_name
	  ,contact_name
      ,fadr
      ,city_name
      ,region_name
      ,province_name
      ,distr_name
      ,country_name
      ,address_name
	  ,zip
      ,opt_name
      ,pol_start_date
      ,LPAD(:NUM+ROWNUM-1,6,'0') vhnum
FROM
(
SELECT (SELECT MAX(TRUNC(dsa.start_date))
        FROM ins.c_claim cla
            ,ins.doc_status dsa
            ,ins.doc_status_ref rfa
        WHERE cla.c_claim_header_id = ch.c_claim_header_id
          AND cla.c_claim_id = dsa.document_id
          AND dsa.doc_status_ref_id = rfa.doc_status_ref_id
          AND rfa.brief = 'DECISION'
        ) date_company
      ,d.num num
      ,ph.policy_header_id pol_header_id
      ,c.c_claim_id document_id
      ,ass.assured_contact_id contact_id
      ,cpol.obj_name_orig contact_name
      ,c_ins.obj_name_orig holder_name
      ,ph.ids
      ,TO_CHAR(ph.start_date,'dd.mm.yyyy') pol_start_date
      ,CASE WHEN NVL(ch.is_handset_ins_sum,0) = 1 THEN
                  ch.ins_sum
             WHEN NVL(pc.ins_amount,0) = 0 THEN
               pkg_claim.get_lim_amount(dmg.t_damage_code_id,dmg.p_cover_id, dmg.c_damage_id)
        ELSE
             NVL(pc.ins_amount,0)
        END amount
      ,NVL(dmg.decline_sum,0) decline_sum
      ,NVL(dmg.declare_sum,0) declare_sum
      ,NVL(dmg.payment_sum,0) pay_amount
      ,NVL(acc.Get_Cross_Rate_By_Brief(1,dmgf.brief,f.brief,ch.declare_date),1) rate
      ,pol.pol_num
      ,pol.confirm_date
      ,ins.pkg_contact.get_birth_date(cpol.contact_id) date_of_birth
      ,ins.pkg_contact.get_ident_number(cpol.contact_id,'PASS_RF') pass_num
      ,ins.pkg_contact.get_ident_seria(cpol.contact_id,'PASS_RF') pass_ser
      ,ins.pkg_contact.get_ident_date(cpol.contact_id,'PASS_RF') pass_date
      ,ins.pkg_contact.get_ident_place(cpol.contact_id,'PASS_RF') pass_place
      ,NVL(ca.name, pkg_contact.get_address_name(ca.id)) address_name
      ,(case when ca.street_name is not null then NVL(ca.street_type,'ул')||'.'||ca.street_name else '' end ||
      case when ca.house_nr is not null then ',д.'||ca.house_nr else '' end ||
      case when ca.block_number is not null then ','||ca.block_number else '' end ||
      case when ca.appartment_nr is not null then ',кв.'||ca.appartment_nr else '' end) fadr
      ,(case when ca.city_name is not null then 'г.'||ca.city_name else '' end) city_name
      ,case when ca.region_name is not null then ca.region_name||' '||ca.region_type else '' end region_name
      ,case when ca.province_name is not null then ca.province_name||' '||ca.province_type else '' end province_name
      ,case when ca.district_name is not null then ca.district_type||' '||ca.district_name else '' end distr_name
      ,(select distinct tc.description from t_country tc where tc.id = ca.country_id) country_name
      ,ca.zip
      ,opt.description opt_name
FROM ins.c_claim_header ch
    ,ins.document d
    ,ins.c_claim c
    ,ins.c_event e
    ,(SELECT pola.*
      FROM ins.p_policy pola
      WHERE pola.is_group_flag = 0
      ) pol
    ,ins.p_pol_header ph
    ,ins.as_asset a
    ,ins.p_cover pc
    ,ins.t_prod_line_option opt
    ,ins.fund f
    ,(SELECT dmga.*
      FROM ins.c_damage dmga
      WHERE dmga.payment_sum > 0
      ) dmg
    ,ins.fund dmgf
    ,ins.as_assured ass
    ,ins.contact cpol
    ,ins.cn_address ca
    ,ins.notif_letter_rep nlr
    ,ins.t_contact_pol_role polr
    ,ins.p_policy_contact pcnt
    ,ins.contact c_ins
WHERE ch.c_claim_header_id = c.c_claim_header_id
  AND ch.c_event_id = e.c_event_id
  AND ch.fund_id = f.fund_id
  AND ch.active_claim_id = c.c_claim_id
  AND ch.c_claim_header_id = d.document_id
  AND ch.p_policy_id = pol.policy_id
  AND pol.pol_header_id = ph.policy_header_id
  AND pol.policy_id = a.p_policy_id
  AND a.as_asset_id = pc.as_asset_id
  AND pc.t_prod_line_option_id = opt.id
  AND pc.p_cover_id = ch.p_cover_id
  AND opt.description IN ('Дожитие Застрахованного до потери постоянной работы по независящим от него причинам'
                         ,'Дожитие Страхователя до потери постоянно работы по независящим от него причинам'
                         ,'Дожитие Страхователя до потери постоянной работы по независящим от него причинам'
                          )
  AND pc.p_cover_id = dmg.p_cover_id
  AND dmg.damage_fund_id = dmgf.fund_id
  AND dmg.c_claim_id = c.c_claim_id
  AND EXISTS (SELECT NULL
                  FROM ins.c_claim cl
                      ,ins.doc_status ds
                      ,ins.doc_status_ref rf
                  WHERE cl.c_claim_header_id = ch.c_claim_header_id
                    AND cl.c_claim_id = ds.document_id
                    AND ds.doc_status_ref_id = rf.doc_status_ref_id
                    AND rf.brief = 'DECISION'
                  )
  AND ass.as_assured_id = a.as_asset_id
  AND ass.assured_contact_id = cpol.contact_id
  AND nlr.document_id = c.c_claim_id
  AND nlr.sessionid = :P_SID
  AND polr.brief = 'Страхователь'
  AND pcnt.policy_id = pol.policy_id
  AND pcnt.contact_policy_role_id = polr.id
  AND c_ins.contact_id = pcnt.contact_id
  AND pkg_contact.get_primary_address(c_ins.contact_id) = ca.ID
ORDER BY cpol.obj_name_orig)
) t
	   ]]>
      </select>
      <group name="group_data">
        <dataItem name="rec_num"/>
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
       to_char(trunc(sysdate),'yyyy')
into :SYS_DATE, :P_MONTH, :P_YEAR
from dual;

select t.description
into :name_letter
from t_notification_type t
where t.t_notification_type_id = :NTID;

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
  <td colspan=15 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt'>Список<br>
    <rw:field id="" src="name_letter"/> </td>
 </tr>
 <tr height=40 style='height:30.0pt'>
  <td height=40 class=xl65 width=48 style='height:30.0pt;border-top:none;
  width:36pt'>№</td>
  <td class=xl65 width=82 style='border-top:none;border-left:none;width:62pt'>Исходящий номер</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>ИДС договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Номер договора</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страхователь</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Строка адреса</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Город</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Населенный пункт</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Район</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Область, республика</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Страна</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Индекс</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Адрес Страхователя</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Программа</td>
  <td class=xl65 width=164 style='border-top:none;border-left:none;width:79pt'>Дата начала действия ДС</td>
 </tr>
 
 <rw:foreach id="fi2" src="group_data">
 <tr height=20 style='height:15.0pt'>
  <td height=20 class=xl69 style='height:15.0pt;border-top:none'><%=++rec_count_current%></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="vhnum"/>-<rw:field id="" src="P_MONTH"/>/<rw:field id="" src="P_YEAR"/></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="ids"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="pol_num"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="holder_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="fadr"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="city_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="distr_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="region_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="province_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="country_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="zip"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="address_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="opt_name"></rw:field></td>
  <td class=xl69 style='border-top:none;border-left:none'><rw:field id="" src="pol_start_date"></rw:field></td>
 </tr>
 
 </rw:foreach>
 
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=15 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=15 class=xl71 style='height:15.0pt'>Всего: <%=rec_count_all%></td>
 </tr>
 <tr height=20 style='height:15.0pt'>
  <td height=20 colspan=15 style='height:15.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=15 class=xl71 style='height:15.0pt'>Передал:
  ____________________/______________________________________</td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=15 class=xl71 style='height:15.0pt'></td>
 </tr>
 <tr class=xl67 height=20 style='height:15.0pt'>
  <td height=20 colspan=15 class=xl71 style='height:15.0pt'>Принял:
  _____________________/______________________________________</td>
 </tr>
 <tr height=40 style='height:30.0pt;mso-xlrowspan:2'>
  <td height=40 colspan=15 style='height:30.0pt;mso-ignore:colspan'></td>
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
