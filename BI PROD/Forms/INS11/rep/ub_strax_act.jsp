<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="application/vnd.ms-excel;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
  DecimalFormat format = new DecimalFormat("0.00");
  double SUM_VYPL = 0;
  double D_I = 0;              
  double COUNT_DAY = 0;                
  String DESC_RISK = new String();  
%>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ub_strax_act" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="DOPSG_IDS" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="CLAIM_H_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_CLAIM">
      <select canParse="no">
      <![CDATA[  SELECT ph.policy_header_id, ch.c_claim_header_id,
               ent.obj_name ('T_PROVINCE', p.region_id) fl_reg,
cc.claim_status_date fl_d4,
               e.num fl_n1,
               p.pol_ser || '-' || p.pol_num fl_n2,
               DECODE (p.is_group_flag,
                       1, 'групповой',
                       'индивидуальный'
                      ) fl_pr1,
               ph.start_date fl_d1, p.end_date fl_d2,
               ent.obj_name (a.ent_id, a.as_asset_id) fl_fio1,
               ent.obj_name (con1.ent_id, con1.contact_id) fl_fio2,
               e.event_date fl_d3,
               NVL (p.waiting_period_end_date, SYSDATE) fl_d5,
               pc.start_date fl_d6, pc.end_date fl_d7,
               e.date_declare fl_d8,
               tp.description fl_nr, 
               e.diagnose fl_nd,
               pc.ins_amount s2,
               ch.deductible_value s_fr,
               ent.obj_name (c.ent_id, c.contact_id) fl_fio3
          FROM ven_p_pol_header ph JOIN ven_p_policy p
               ON (ph.policy_header_id = p.pol_header_id)
               JOIN ven_t_product prod ON (prod.product_id = ph.product_id)
               JOIN ven_c_claim_header ch ON (ch.p_policy_id = p.policy_id)
               JOIN ven_c_claim cc
               ON (    ch.c_claim_header_id = cc.c_claim_header_id
                   AND doc.get_doc_status_brief (cc.c_claim_id) = 'REGULATE'
                  )
               JOIN ven_c_event e ON (ch.c_event_id = e.c_event_id)
               JOIN ven_c_event_contact ec
               ON (ch.declarant_id = ec.c_event_contact_id)
               JOIN ven_contact c ON (ec.cn_person_id = c.contact_id)
               JOIN ven_cn_person per ON (ch.curator_id = per.contact_id)
               JOIN ven_c_declarant_role dr
               ON (dr.c_declarant_role_id = ch.declarant_role_id)
               LEFT JOIN ven_department ct ON (ch.depart_id = ct.department_id
                                              )
               JOIN ven_as_asset a ON (ch.as_asset_id = a.as_asset_id)
               LEFT JOIN ven_fund f ON (ch.fund_id = f.fund_id)
               JOIN ven_c_claim_metod_type cmt
               ON (ch.notice_type_id = cmt.c_claim_metod_type_id)
               LEFT JOIN ven_p_cover pc ON (ch.p_cover_id = pc.p_cover_id)
               LEFT JOIN ven_t_prod_line_option pl
               ON (pc.t_prod_line_option_id = pl.ID)
               LEFT JOIN ven_t_peril tp ON (tp.ID = ch.peril_id)
               JOIN ven_p_policy_contact pc1 ON (pc1.policy_id = p.policy_id)
               JOIN ven_contact con1 ON (pc1.contact_id = con1.contact_id)
               JOIN ven_t_contact_pol_role tpr1
               ON (    pc1.contact_policy_role_id = tpr1.ID
                   AND tpr1.brief = 'Страхователь'
                  )
where ch.c_claim_header_id = :CLAIM_H_ID             
]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_CLAIM">
        <displayInfo x="0.04150" y="0.57495" width="1.68176" height="3.84863"
        />
        <dataItem name="FL_D4" datatype="date" oracleDatatype="date"
         columnOrder="38" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl D4">
          <dataDescriptor expression="FL_D4" descriptiveExpression="FL_D4"
           order="4" width="9"/>
        </dataItem>
        <dataItem name="C_CLAIM_HEADER_ID" oracleDatatype="number"
         columnOrder="13" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="C Claim Header Id">
          <dataDescriptor expression="C_CLAIM_HEADER_ID"
           descriptiveExpression="C_CLAIM_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FL_REG" datatype="vchar2" columnOrder="14"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Reg">
          <dataDescriptor expression="FL_REG" descriptiveExpression="FL_REG"
           order="3" width="4000"/>
        </dataItem>
        <dataItem name="FL_N1" datatype="vchar2" columnOrder="15" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl N1">
          <dataDescriptor expression="FL_N1" descriptiveExpression="FL_N1"
           order="5" width="100"/>
        </dataItem>
        <dataItem name="FL_N2" datatype="vchar2" columnOrder="16" width="2049"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl N2">
          <dataDescriptor expression="FL_N2" descriptiveExpression="FL_N2"
           order="6" width="2049"/>
        </dataItem>
        <dataItem name="FL_PR1" datatype="vchar2" columnOrder="17" width="14"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Pr1">
          <dataDescriptor expression="FL_PR1" descriptiveExpression="FL_PR1"
           order="7" width="14"/>
        </dataItem>
        <dataItem name="FL_D1" datatype="date" oracleDatatype="date"
         columnOrder="18" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl D1">
          <dataDescriptor expression="FL_D1" descriptiveExpression="FL_D1"
           order="8" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="FL_D2" datatype="date" oracleDatatype="date"
         columnOrder="19" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl D2">
          <dataDescriptor expression="FL_D2" descriptiveExpression="FL_D2"
           order="9" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="FL_FIO1" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Fio1">
          <dataDescriptor expression="FL_FIO1" descriptiveExpression="FL_FIO1"
           order="10" width="4000"/>
        </dataItem>
        <dataItem name="FL_FIO2" datatype="vchar2" columnOrder="21"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Fio2">
          <dataDescriptor expression="FL_FIO2" descriptiveExpression="FL_FIO2"
           order="11" width="4000"/>
        </dataItem>
        <dataItem name="FL_D3" datatype="date" oracleDatatype="date"
         columnOrder="22" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl D3">
          <dataDescriptor expression="FL_D3" descriptiveExpression="FL_D3"
           order="12" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="FL_D5" datatype="date" oracleDatatype="date"
         columnOrder="23" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl D5">
          <dataDescriptor expression="FL_D5" descriptiveExpression="FL_D5"
           order="13" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="FL_D6" datatype="date" oracleDatatype="date"
         columnOrder="24" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl D6">
          <dataDescriptor expression="FL_D6" descriptiveExpression="FL_D6"
           order="14" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="FL_D7" datatype="date" oracleDatatype="date"
         columnOrder="25" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl D7">
          <dataDescriptor expression="FL_D7" descriptiveExpression="FL_D7"
           order="15" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="FL_D8" datatype="date" oracleDatatype="date"
         columnOrder="26" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl D8">
          <dataDescriptor expression="FL_D8" descriptiveExpression="FL_D8"
           order="16" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="FL_NR" datatype="vchar2" columnOrder="27" width="500"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Nr">
          <dataDescriptor expression="FL_NR" descriptiveExpression="FL_NR"
           order="17" width="500"/>
        </dataItem>
        <dataItem name="FL_ND" datatype="vchar2" columnOrder="28" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Nd">
          <dataDescriptor expression="FL_ND" descriptiveExpression="FL_ND"
           order="18" width="4000"/>
        </dataItem>
        <dataItem name="S2" oracleDatatype="number" columnOrder="29"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S2">
          <dataDescriptor expression="S2" descriptiveExpression="S2"
           order="19" oracleDatatype="number" width="22" scale="2"
           precision="11"/>
        </dataItem>
        <dataItem name="S_FR" oracleDatatype="number" columnOrder="30"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S Fr">
          <dataDescriptor expression="S_FR" descriptiveExpression="S_FR"
           order="20" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FL_FIO3" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Fio3">
          <dataDescriptor expression="FL_FIO3" descriptiveExpression="FL_FIO3"
           order="21" width="4000"/>
        </dataItem>
        <dataItem name="POLICY_HEADER_ID" oracleDatatype="number"
         columnOrder="12" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Policy Header Id">
          <dataDescriptor expression="POLICY_HEADER_ID"
           descriptiveExpression="POLICY_HEADER_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DAMAGE">
      <select canParse="no">
      <![CDATA[SELECT nvl(to_char(d.rec_start_date,'dd.mm.yyyy'),'@') fl_d9, 
       nvl(to_char(d.rec_end_date,'dd.mm.yyyy'),'@') fl_d10,
       nvl(d.rec_end_date - d.rec_start_date + 1,0) s1, 
       e.diagnose fl_nd,
       dc.description fl_nu,
       ROUND (d.payment_sum * acc.get_cross_rate_by_brief(1,fd.brief,f.brief,ch.declare_date),2) s_vip
  FROM ven_c_claim_header ch 
       JOIN ven_c_claim cc ON ( ch.c_claim_header_id = cc.c_claim_header_id
                                AND doc.get_doc_status_brief (cc.c_claim_id) = 'REGULATE')
       LEFT JOIN ven_fund f ON (ch.fund_id = f.fund_id)
       JOIN ven_c_event e ON (ch.c_event_id = e.c_event_id)
       JOIN ven_c_damage d ON (d.c_claim_id = cc.c_claim_id)
       LEFT JOIN ven_fund fd ON (d.damage_fund_id = fd.fund_id)
       JOIN ven_t_damage_code dc ON (d.t_damage_code_id = dc.ID)
       JOIN ven_c_damage_type dt ON (d.c_damage_type_id = dt.c_damage_type_id AND dt.brief = 'СТРАХОВОЙ' )
 WHERE cc.c_claim_header_id = :CLAIM_H_ID 
]]>
      </select>
      <displayInfo x="2.12427" y="0.09387" width="1.32312" height="0.32983"/>
      <group name="G_DAMAGE">
        <displayInfo x="2.10815" y="0.64563" width="1.35876" height="1.45605"
        />
        <dataItem name="FL_D9" datatype="vchar2" columnOrder="32"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl D9">
          <dataDescriptor expression="FL_D9" descriptiveExpression="FL_D9"
           order="1" width="10"/>
        </dataItem>
        <dataItem name="FL_D10" datatype="vchar2" columnOrder="33"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl D10">
          <dataDescriptor expression="FL_D10" descriptiveExpression="FL_D10"
           order="2" width="10"/>
        </dataItem>
        <dataItem name="S1" oracleDatatype="number" columnOrder="34"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S1">
          <dataDescriptor expression="S1" descriptiveExpression="S1" order="3"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="FL_ND1" datatype="vchar2" columnOrder="35"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Nd1">
          <dataDescriptor expression="FL_ND" descriptiveExpression="FL_ND"
           order="4" width="4000"/>
        </dataItem>
        <dataItem name="FL_NU" datatype="vchar2" columnOrder="36" width="1000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Nu">
          <dataDescriptor expression="FL_NU" descriptiveExpression="FL_NU"
           order="5" width="1000"/>
        </dataItem>
        <dataItem name="S_VIP" oracleDatatype="number" columnOrder="37"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S Vip">
          <dataDescriptor expression="S_VIP" descriptiveExpression="S_VIP"
           order="6" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
  </data>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel"
xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>MarkoOl</o:Author>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:LastPrinted>2007-03-19T08:11:44Z</o:LastPrinted>
  <o:Created>2006-02-20T06:54:31Z</o:Created>
  <o:LastSaved>2007-07-17T09:16:13Z</o:LastSaved>
  <o:Company>RenLife</o:Company>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
 <o:CustomDocumentProperties>
  <o:_NewReviewCycle dt:dt="string"></o:_NewReviewCycle>
 </o:CustomDocumentProperties>
</xml><![endif]-->
<style>
<!--table
	{mso-displayed-decimal-separator:"\,";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.39in .39in .39in .39in;
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
	font-family:"Arial Cyr";
	mso-generic-font-family:auto;
	mso-font-charset:204;
	border:none;
	mso-protection:locked visible;
	mso-style-name:Normal;
	mso-style-id:0;}
td
	{mso-style-parent:style0;
	padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:windowtext;
	font-size:10.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:"Arial Cyr";
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
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.xl25
	{mso-style-parent:style0;
	font-size:20.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;}
.xl26
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;}
.xl27
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;}
.xl28
	{mso-style-parent:style0;
	font-size:18.0pt;}
.xl29
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;}
.xl30
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;}
.xl31
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";}
.xl32
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.xl33
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	white-space:normal;}
.xl34
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	white-space:normal;}
.xl35
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"\#\,\#\#0\0022р\.\0022";
	text-align:center;}
.xl36
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";
	text-align:center;}
.xl37
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";
	text-align:right;}
.xl38
	{mso-style-parent:style0;
	font-size:18.0pt;
	mso-number-format:"Short Date";
	text-align:center;}
.xl39
	{mso-style-parent:style0;
	mso-number-format:"Short Date";
	text-align:center;}
.xl40
	{mso-style-parent:style0;
	text-align:center;}
.xl41
	{mso-style-parent:style0;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;}
.xl42
	{mso-style-parent:style0;
	font-size:18.0pt;
	text-align:center;}
.xl43
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"\#\,\#\#0\0022р\.\0022";}
.xl44
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"\@";
	text-align:center;}
.xl45
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:none;
	border-left:none;}
.xl46
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	white-space:normal;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>Страховой Акт</x:Name>
    <x:WorksheetOptions>
     <x:DefaultRowHeight>315</x:DefaultRowHeight>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:Scale>66</x:Scale>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:PageBreakZoom>60</x:PageBreakZoom>
     <x:Selected/>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>39</x:ActiveRow>
       <x:ActiveCol>11</x:ActiveCol>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>11640</x:WindowHeight>
  <x:WindowWidth>15180</x:WindowWidth>
  <x:WindowTopX>480</x:WindowTopX>
  <x:WindowTopY>45</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
 <x:ExcelName>
  <x:Name>Print_Area</x:Name>
  <x:SheetIndex>1</x:SheetIndex>
  <x:Formula>='Страховой Акт'!$A$1:$I$53</x:Formula>
 </x:ExcelName>
</xml><![endif]-->
</head>

<body link=blue vlink=purple>

<rw:foreach id="G_CLAIM" src="G_CLAIM">

<rw:getValue id="FL_N1" src="FL_N1"/>
<rw:getValue id="FL_N2" src="FL_N2"/>
<rw:getValue id="FL_D1" src="FL_D1" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FL_D2" src="FL_D2" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FL_D3" src="FL_D3" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FL_D4" src="FL_D4" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FL_REG" src="FL_REG" formatMask="DD.MM.YYYY"/>
<rw:getValue id="FL_FIO1" src="FL_FIO1"/>
<rw:getValue id="FL_FIO2" src="FL_FIO2"/>


<rw:foreach id="G_DAMAGE" src="G_DAMAGE">
<rw:getValue id="FL_D9" src="FL_D9"/>
<rw:getValue id="FL_D10" src="FL_D10"/>
<rw:getValue id="FL_ND1" src="FL_ND1"/>
<rw:getValue id="FL_NU" src="FL_NU"/>
<rw:getValue id="S_VIP" src="S_VIP" formatMask="999999990.99"/>
<rw:getValue id="S1" src="S1" formatMask="999999990"/>

<%
  SUM_VYPL = SUM_VYPL + Double.valueOf(S_VIP).doubleValue();
  COUNT_DAY = Double.valueOf(S1).doubleValue();
  if (COUNT_DAY > 0) {
    if (D_I > 0){
      DESC_RISK = DESC_RISK + ", "+ FL_ND1 + "-" + FL_NU + " c " + FL_D9 + " по " + FL_D10 + " общим количеством дней=" + S1;
    } else {
      DESC_RISK = FL_ND1 + "-" + FL_NU + " c " + FL_D9 + " по " + FL_D10 + " общим количеством дней=" + S1;    
      D_I = D_I + 1;      
    }
  } else {
    if (D_I > 0){
      DESC_RISK = DESC_RISK + ", "+ FL_ND1 + "-" + FL_NU;
    } else {
      DESC_RISK = FL_ND1 + "-" + FL_NU;
      D_I = D_I + 1;      
    }
  }
%>
</rw:foreach>


<table x:str border=0 cellpadding=0 cellspacing=0 width=887 style='border-collapse:
 collapse;table-layout:fixed;width:665pt'>
 <col class=xl24 width=80 style='mso-width-source:userset;mso-width-alt:2925;
 width:60pt'>
 <col class=xl24 width=93 style='mso-width-source:userset;mso-width-alt:3401;
 width:70pt'>
 <col width=39 style='mso-width-source:userset;mso-width-alt:1426;width:29pt'>
 <col width=64 span=3 style='width:48pt'>
 <col width=55 style='mso-width-source:userset;mso-width-alt:2011;width:41pt'>
 <col width=169 style='mso-width-source:userset;mso-width-alt:6180;width:127pt'>
 <col width=259 style='mso-width-source:userset;mso-width-alt:9472;width:194pt'>
 <tr height=21 style='height:15.75pt'>
  <td height=21 class=xl24 width=80 style='height:15.75pt;width:60pt'></td>
  <td class=xl24 width=93 style='width:70pt'></td>
  <td width=39 style='width:29pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=55 style='width:41pt'></td>
  <td width=169 style='width:127pt'></td>
  <td width=259 style='width:194pt'></td>
 </tr>
 <tr height=37 style='mso-height-source:userset;height:27.75pt'>
  <td colspan=9 height=37 class=xl25 style='height:27.75pt'>СТРАХОВОЙ АКТ</td>
 </tr>
 <tr height=24 style='mso-height-source:userset;height:18.0pt'>
  <td height=24 colspan=9 class=xl25 style='height:18.0pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=21 style='mso-height-source:userset;height:15.75pt'>
  <td height=21 colspan=9 class=xl25 style='height:15.75pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=23 style='mso-height-source:userset;height:17.25pt'>
  <td height=23 colspan=9 class=xl25 style='height:17.25pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=21 style='height:15.75pt'>
  <td height=21 colspan=2 class=xl24 style='height:15.75pt;mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=31 style='height:23.25pt'>
  <td colspan=2 height=31 class=xl30 style='height:23.25pt'><%=FL_REG%></td>
  <td colspan=2 class=xl32 style='mso-ignore:colspan'></td>
  <td colspan=2 class=xl30 style='mso-ignore:colspan'></td>
  <td colspan=2 class=xl29>Дата рассмотрения:</td>
  <td class=xl37 ><%=FL_D4%></td>
 </tr>
 <tr height=21 style='mso-height-source:userset;height:15.75pt'>
  <td height=21 colspan=2 class=xl24 style='height:15.75pt;mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=22 style='mso-height-source:userset;height:16.5pt'>
  <td height=22 colspan=2 class=xl24 style='height:16.5pt;mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=13 style='mso-height-source:userset;height:9.75pt'>
  <td height=13 colspan=2 class=xl24 style='height:9.75pt;mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=16 style='mso-height-source:userset;height:12.0pt'>
  <td height=16 colspan=2 class=xl24 style='height:12.0pt;mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=30 style='mso-height-source:userset;height:22.5pt'>
  <td colspan=3 height=30 class=xl30 style='height:22.5pt'>Дата утверждения:</td>
  <td class=xl38></td>
  <td class=xl31></td>
  <td colspan=2 class=xl32 style='mso-ignore:colspan'></td>
  <td class=xl36></td>
  <td class=xl32></td>
 </tr>
 <tr height=27 style='mso-height-source:userset;height:20.25pt'>
  <td height=27 colspan=3 class=xl26 style='height:20.25pt;mso-ignore:colspan'></td>
  <td colspan=2 class=xl39 style='mso-ignore:colspan'></td>
  <td colspan=4 class=xl40 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=27 style='mso-height-source:userset;height:20.25pt'>
  <td colspan=2 height=27 class=xl30 style='height:20.25pt'>Подпись:</td>
  <td colspan=6 class=xl27></td>
  <td class=xl27></td>
 </tr>
 <tr height=22 style='mso-height-source:userset;height:16.5pt'>
  <td height=22 colspan=2 class=xl30 style='height:16.5pt;mso-ignore:colspan'></td>
  <td colspan=7 class=xl45>Ф.И.О. эксперта по урегулированию убытков</td>
 </tr>
 <tr height=23 style='mso-height-source:userset;height:17.25pt'>
  <td height=23 colspan=2 class=xl30 style='height:17.25pt;mso-ignore:colspan'></td>
  <td colspan=7 class=xl41 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=27 style='mso-height-source:userset;height:20.25pt'>
  <td colspan=2 height=27 class=xl30 style='height:20.25pt'>Подпись:</td>
  <td colspan=6 class=xl27></td>
  <td class=xl27></td>
 </tr>
 <tr height=25 style='mso-height-source:userset;height:18.75pt'>
  <td height=25 colspan=2 class=xl30 style='height:18.75pt;mso-ignore:colspan'></td>
  <td colspan=7 class=xl45>Ф.И.О. директора Управления андеррайтинга и
  методологии</td>
 </tr>
 <tr height=21 style='mso-height-source:userset;height:15.75pt'>
  <td height=21 colspan=2 class=xl30 style='height:15.75pt;mso-ignore:colspan'></td>
  <td colspan=7 class=xl41 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=30 style='mso-height-source:userset;height:22.5pt'>
  <td colspan=2 height=30 class=xl30 style='height:22.5pt'>Подпись:</td>
  <td colspan=6 class=xl27></td>
  <td></td>
 </tr>
 <tr height=23 style='mso-height-source:userset;height:17.25pt'>
  <td height=23 colspan=2 class=xl24 style='height:17.25pt;mso-ignore:colspan'></td>
  <td colspan=7 class=xl45>Ф.И.О. Управляющего директора</td>
 </tr>
 <tr height=22 style='mso-height-source:userset;height:16.5pt'>
  <td height=22 colspan=2 class=xl24 style='height:16.5pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl41 style='mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr height=13 style='mso-height-source:userset;height:9.75pt'>
  <td height=13 colspan=2 class=xl24 style='height:9.75pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl41 style='mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr height=13 style='mso-height-source:userset;height:9.75pt'>
  <td height=13 colspan=2 class=xl24 style='height:9.75pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl41 style='mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr height=25 style='mso-height-source:userset;height:18.75pt'>
  <td height=25 colspan=2 class=xl24 style='height:18.75pt;mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=39 style='mso-height-source:userset;height:29.25pt'>
  <td colspan=4 height=39 class=xl30 style='height:29.25pt'>N страховой
  претензии</td>
  <td colspan=3 class=xl32 style='mso-ignore:colspan'></td>
  <td class=xl29><%=FL_N1%></td>
  <td class=xl32></td>
 </tr>
 <tr height=33 style='mso-height-source:userset;height:24.75pt'>
  <td height=33 colspan=3 class=xl30 style='height:24.75pt;mso-ignore:colspan'></td>
  <td colspan=4 class=xl42 style='mso-ignore:colspan'></td>
  <td class=xl29></td>
  <td class=xl42></td>
 </tr>
 <tr height=35 style='mso-height-source:userset;height:26.25pt'>
  <td colspan=4 height=35 class=xl30 style='height:26.25pt'>N полиса</td>
  <td colspan=3 class=xl32 style='mso-ignore:colspan'></td>
  <td class=xl44><%=FL_N2%></td>
  <td class=xl32></td>
 </tr>
 <tr height=46 style='mso-height-source:userset;height:34.5pt'>
  <td height=46 colspan=3 class=xl30 style='height:34.5pt;mso-ignore:colspan'></td>
  <td class=xl28></td>
  <td colspan=3 class=xl42 style='mso-ignore:colspan'></td>
  <td class=xl29></td>
  <td class=xl42></td>
 </tr>
 <tr height=31 style='mso-height-source:userset;height:23.25pt'>
  <td colspan=6 height=31 class=xl30 style='height:23.25pt'>Дата вступления
  полиса в действие</td>
  <td class=xl42></td>
  <td class=xl36><%=FL_D1%></td>
  <td class=xl42></td>
 </tr>
 <tr height=41 style='mso-height-source:userset;height:30.75pt'>
  <td height=41 colspan=6 class=xl30 style='height:30.75pt;mso-ignore:colspan'></td>
  <td class=xl42></td>
  <td class=xl29></td>
  <td class=xl42></td>
 </tr>
 <tr height=28 style='mso-height-source:userset;height:21.0pt'>
  <td colspan=6 height=28 class=xl30 style='height:21.0pt'>Дата окончания
  действия полиса</td>
  <td class=xl42></td>
  <td class=xl36><%=FL_D2%></td>
  <td class=xl42></td>
 </tr>
 <tr height=19 style='mso-height-source:userset;height:14.25pt'>
  <td height=19 colspan=6 class=xl30 style='height:14.25pt;mso-ignore:colspan'></td>
  <td class=xl42></td>
  <td class=xl29></td>
  <td class=xl42></td>
 </tr>
 <tr height=31 style='mso-height-source:userset;height:23.25pt'>
  <td colspan=6 height=31 class=xl30 style='height:23.25pt'>Дата наступления
  страхового случая</td>
  <td class=xl42></td>
  <td class=xl36><%=FL_D3%></td>
  <td class=xl42></td>
 </tr>
 <tr height=38 style='mso-height-source:userset;height:28.5pt'>
  <td height=38 colspan=5 class=xl30 style='height:28.5pt;mso-ignore:colspan'></td>
  <td colspan=2 class=xl42 style='mso-ignore:colspan'></td>
  <td class=xl29></td>
  <td class=xl42></td>
 </tr>
 <tr height=33 style='mso-height-source:userset;height:24.75pt'>
  <td colspan=4 height=33 class=xl30 style='height:24.75pt'>Застрахованный</td>
  <td colspan=2 class=xl32 style='mso-ignore:colspan'></td>
  <td colspan=3 class="xl36" ><%=FL_FIO1%></td>
 </tr>
 <tr height=46 style='mso-height-source:userset;height:34.5pt'>
  <td height=46 colspan=3 class=xl30 style='height:34.5pt;mso-ignore:colspan'></td>
  <td class=xl28></td>
  <td colspan=5 class=xl29 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=29 style='mso-height-source:userset;height:21.75pt'>
  <td colspan=4 height=29 class=xl30 style='height:21.75pt'>Страхователь</td>
  <td colspan=2 class=xl29 style='mso-ignore:colspan'></td>
  <td colspan=3 class="xl36"><%=FL_FIO2%></td>
 </tr>
 <tr height=17 style='mso-height-source:userset;height:12.75pt'>
  <td height=17 colspan=3 class=xl30 style='height:12.75pt;mso-ignore:colspan'></td>
  <td class=xl28></td>
  <td colspan=5 class=xl42 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=195 style='mso-height-source:userset;height:146.25pt'>
  <td colspan=3 height=195 class=xl33 width=212 style='height:146.25pt;
  width:159pt'>Описание рисков</td>
  <td colspan=6 class=xl46 width=675 style='width:506pt'><%=DESC_RISK%></td>
 </tr>
 <tr height=24 style='mso-height-source:userset;height:18.0pt'>
  <td height=24 colspan=3 class=xl33 style='height:18.0pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl34 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=23 style='mso-height-source:userset;height:17.25pt'>
  <td height=23 colspan=3 class=xl33 style='height:17.25pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl34 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=23 style='mso-height-source:userset;height:17.25pt'>
  <td height=23 colspan=3 class=xl33 style='height:17.25pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl34 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=20 style='mso-height-source:userset;height:15.0pt'>
  <td height=20 colspan=2 class=xl32 style='height:15.0pt;mso-ignore:colspan'></td>
  <td colspan=7 class=xl28 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=31 style='height:23.25pt'>
  <td colspan=6 height=31 class=xl30 style='height:23.25pt'>Общая сумма к
  выплате:</td>
  <td class=xl43></td>
  <td class=xl43 align=center><%=format.format(SUM_VYPL)%></td>
  <td class=xl43></td>
 </tr>
 <tr height=27 style='mso-height-source:userset;height:20.25pt'>
  <td height=27 colspan=3 class=xl30 style='height:20.25pt;mso-ignore:colspan'></td>
  <td class=xl28></td>
  <td colspan=5 class=xl35 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=22 style='mso-height-source:userset;height:16.5pt'>
  <td height=22 colspan=2 class=xl32 style='height:16.5pt;mso-ignore:colspan'></td>
  <td colspan=7 class=xl28 style='mso-ignore:colspan'></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=80 style='width:60pt'></td>
  <td width=93 style='width:70pt'></td>
  <td width=39 style='width:29pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=64 style='width:48pt'></td>
  <td width=55 style='width:41pt'></td>
  <td width=169 style='width:127pt'></td>
  <td width=259 style='width:194pt'></td>
 </tr>
 <![endif]>
</table>

</rw:foreach>

</body>

</html>


</rw:report>

