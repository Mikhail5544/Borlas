<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
  SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
  DecimalFormat format = new DecimalFormat("0.00");  
  String DIAGNOZ_STR = new String(" ");  
  String TABL_VYPLAT_STR = new String(" ");    
  String TMP_STR = new String("");
  double PERCENT_ALL = 0;
  double SUM_CC = 0;    
  double SUM_VYPL_ALL = 0;    
  double SUM_VYPL = 0;  
  double COUNTER_I = 0;  
  double COUNTER_I2 = 0;    
%>

<rw:report id="report"> 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="ub_sost_del" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="DOPSG_IDS" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="EVENT_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_CLAIM">
      <select>
      <![CDATA[SELECT e.c_event_id, e.NUM num_dela, e.EVENT_DATE, p.pol_ser||'-'||p.pol_num pol_num,
       decode(nvl(p.IS_GROUP_FLAG,0),0,'Индивидуальный','Корпоративный') ind_korp,
       p.START_DATE, ent.obj_name(a.ent_id, a.as_asset_id) asset_name,
       e.DIAGNOSE,
       e.C_EVENT_ID,
       ent.obj_name('T_PROVINCE', p.region_id) FL_REG
  FROM ven_c_claim_header ch,
       ven_p_policy p,
       ven_c_event e,
       ven_as_asset a
 WHERE ch.p_policy_id = p.policy_id
   AND ch.c_event_id = e.c_event_id
   AND ch.as_asset_id = a.as_asset_id
   and ch.C_CLAIM_HEADER_ID = (select min(C_CLAIM_HEADER_ID) from ven_c_claim_header where c_event_id = :EVENT_ID)
   and e.c_event_id = :EVENT_ID]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_CLAIM">
        <displayInfo x="0.04041" y="0.62708" width="1.68176" height="2.48145"
        />
        <dataItem name="c_event_id2" oracleDatatype="number" columnOrder="22"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="C Event Id2">
          <dataDescriptor expression="e.c_event_id"
           descriptiveExpression="C_EVENT_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="num_dela" datatype="vchar2" columnOrder="13"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Num Dela">
          <dataDescriptor expression="e.NUM" descriptiveExpression="NUM_DELA"
           order="2" width="100"/>
        </dataItem>
        <dataItem name="EVENT_DATE" datatype="date" oracleDatatype="date"
         columnOrder="14" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Event Date">
          <dataDescriptor expression="e.EVENT_DATE"
           descriptiveExpression="EVENT_DATE" order="3" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="pol_num" datatype="vchar2" columnOrder="15"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num">
          <dataDescriptor expression="p.pol_ser || &apos;-&apos; || p.pol_num"
           descriptiveExpression="POL_NUM" order="4" width="2049"/>
        </dataItem>
        <dataItem name="ind_korp" datatype="vchar2" columnOrder="16"
         width="14" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ind Korp">
          <dataDescriptor
           expression="decode ( nvl ( p.IS_GROUP_FLAG , 0 ) , 0 , &apos;Индивидуальный&apos; , &apos;Корпоративный&apos; )"
           descriptiveExpression="IND_KORP" order="5" width="14"/>
        </dataItem>
        <dataItem name="START_DATE" datatype="date" oracleDatatype="date"
         columnOrder="17" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Start Date">
          <dataDescriptor expression="p.START_DATE"
           descriptiveExpression="START_DATE" order="6" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="asset_name" datatype="vchar2" columnOrder="18"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Asset Name">
          <dataDescriptor
           expression="ent.obj_name ( a.ent_id , a.as_asset_id )"
           descriptiveExpression="ASSET_NAME" order="7" width="4000"/>
        </dataItem>
        <dataItem name="DIAGNOSE" datatype="vchar2" columnOrder="19"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Diagnose">
          <dataDescriptor expression="e.DIAGNOSE"
           descriptiveExpression="DIAGNOSE" order="8" width="4000"/>
        </dataItem>
        <dataItem name="C_EVENT_ID" oracleDatatype="number" columnOrder="20"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="C Event Id">
          <dataDescriptor expression="e.C_EVENT_ID"
           descriptiveExpression="C_EVENT_ID" order="9"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FL_REG" datatype="vchar2" columnOrder="21"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Reg">
          <dataDescriptor
           expression="ent.obj_name ( &apos;T_PROVINCE&apos; , p.region_id )"
           descriptiveExpression="FL_REG" order="10" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STATUS_RISKA">
      <select>
      <![CDATA[SELECT ds.document_id, dsr.NAME status_riska
  FROM ven_doc_status ds, ven_doc_status_ref dsr
 WHERE dsr.doc_status_ref_id = ds.doc_status_ref_id
   and ds.change_date = (select max(change_date) from ven_doc_status where ds.DOCUMENT_ID = DOCUMENT_ID )
]]>
      </select>
      <displayInfo x="3.90649" y="0.05200" width="1.34375" height="0.32983"/>
      <group name="G_STATUS_RISKA">
        <displayInfo x="3.84851" y="0.68945" width="1.46301" height="0.77246"
        />
        <dataItem name="STATUS_RISKA" datatype="vchar2" columnOrder="24"
         width="150" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Status Riska">
          <dataDescriptor expression="dsr.NAME"
           descriptiveExpression="STATUS_RISKA" order="2" width="150"/>
        </dataItem>
        <dataItem name="DOCUMENT_ID" oracleDatatype="number" columnOrder="23"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Document Id">
          <dataDescriptor expression="ds.document_id"
           descriptiveExpression="DOCUMENT_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_EVENT">
      <select>
      <![CDATA[SELECT c.c_event_id, c.c_claim_header_id, c.c_claim_id, c.claim_status_id, tp.description, pc.INS_AMOUNT
  FROM v_c_claim c, ven_c_claim_header ch, ven_t_peril tp, ven_p_cover pc
 WHERE seqno = (SELECT MAX (seqno) FROM ven_c_claim WHERE c_claim_header_id = c.c_claim_header_id)
   AND c.c_claim_header_id = ch.c_claim_header_id
   AND c.P_COVER_ID = pc.P_COVER_ID
   AND tp.ID(+) = ch.peril_id]]>
      </select>
      <displayInfo x="2.12512" y="0.05200" width="1.23938" height="0.32983"/>
      <group name="G_EVENT">
        <displayInfo x="1.99390" y="0.65820" width="1.50610" height="1.45605"
        />
        <dataItem name="INS_AMOUNT" oracleDatatype="number" columnOrder="30"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Amount">
          <dataDescriptor expression="pc.INS_AMOUNT"
           descriptiveExpression="INS_AMOUNT" order="6" width="22" scale="2"
           precision="11"/>
        </dataItem>
        <dataItem name="c_event_id1" oracleDatatype="number" columnOrder="25"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="C Event Id1">
          <dataDescriptor expression="c.c_event_id"
           descriptiveExpression="C_EVENT_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="c_claim_header_id" oracleDatatype="number"
         columnOrder="26" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="C Claim Header Id">
          <dataDescriptor expression="c.c_claim_header_id"
           descriptiveExpression="C_CLAIM_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="c_claim_id" oracleDatatype="number" columnOrder="27"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="C Claim Id">
          <dataDescriptor expression="c.c_claim_id"
           descriptiveExpression="C_CLAIM_ID" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="claim_status_id" oracleDatatype="number"
         columnOrder="28" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Claim Status Id">
          <dataDescriptor expression="c.claim_status_id"
           descriptiveExpression="CLAIM_STATUS_ID" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="description" datatype="vchar2" columnOrder="29"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <dataDescriptor expression="tp.description"
           descriptiveExpression="DESCRIPTION" order="5" width="500"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DIAGNOZ">
      <select>
      <![CDATA[SELECT d.c_claim_id, dc.description, dc.code, d.payment_sum, c.ins_amount,
       DECODE (NVL (c.ins_amount, 0), 0, 0, ROUND (d.payment_sum / c.ins_amount * 100, 1) ) PERCENT
  FROM ven_c_damage d,
       ven_t_damage_code dc,
       ven_p_cover c,
       ven_c_damage_type dt,
       ven_c_damage_cost_type dct
 WHERE d.t_damage_code_id = dc.ID
   AND c.p_cover_id(+) = d.p_cover_id
   AND d.c_damage_type_id = dt.c_damage_type_id
   AND d.c_damage_cost_type_id = dct.c_damage_cost_type_id(+)
   AND DECODE (dt.brief,'СТРАХОВОЙ', 1, DECODE (dct.brief, 'ВОЗМЕЩАЕМЫЕ', 1, 0) ) = 1
]]>
      </select>
      <displayInfo x="5.51038" y="1.57300" width="1.15637" height="0.32983"/>
      <group name="G_DIAGNOZ">
        <displayInfo x="5.55078" y="2.15833" width="1.34839" height="1.28516"
        />
        <dataItem name="c_claim_id1" oracleDatatype="number" columnOrder="31"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="C Claim Id1">
          <dataDescriptor expression="d.c_claim_id"
           descriptiveExpression="C_CLAIM_ID" order="1" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="description1" datatype="vchar2" columnOrder="32"
         width="1000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description1">
          <dataDescriptor expression="dc.description"
           descriptiveExpression="DESCRIPTION" order="2" width="1000"/>
        </dataItem>
        <dataItem name="code" datatype="vchar2" columnOrder="33" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Code">
          <dataDescriptor expression="dc.code" descriptiveExpression="CODE"
           order="3" width="100"/>
        </dataItem>
        <dataItem name="payment_sum" oracleDatatype="number" columnOrder="34"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Payment Sum">
          <dataDescriptor expression="d.payment_sum"
           descriptiveExpression="PAYMENT_SUM" order="4" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="ins_amount1" oracleDatatype="number" columnOrder="35"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Amount1">
          <dataDescriptor expression="c.ins_amount"
           descriptiveExpression="INS_AMOUNT" order="5" width="22" scale="2"
           precision="11"/>
        </dataItem>
        <dataItem name="PERCENT" oracleDatatype="number" columnOrder="36"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Percent">
          <dataDescriptor
           expression="DECODE ( NVL ( c.ins_amount , 0 ) , 0 , 0 , ROUND ( d.payment_sum / c.ins_amount * 100 , 1 ) )"
           descriptiveExpression="PERCENT" order="6" width="22" precision="38"
          />
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_EVENT_DOC">
      <select>
      <![CDATA[SELECT q.c_claim_header_id, idt.name, 
       nvl(to_char(cid.receipt_date,'DD.MM.YYYY'),'@') receipt_date,  
       nvl(to_char(cid.request_date,'DD.MM.YYYY'),'@') request_date
    FROM ven_t_issuer_doc_type idt,
         ven_c_claim_issuer_doc cid,
         (SELECT   t_issuer_doc_type_id, MAX (is_required) is_required,
                   c_claim_header_id, MIN (sort_order) sort_order
              FROM (SELECT pid.t_issuer_doc_type_id, pid.is_required,
                           ch.c_claim_header_id, pid.sort_order
                      FROM ven_t_prod_issuer_doc pid,
                           ven_p_pol_header ph,
                           ven_p_policy p,
                           ven_c_claim_header ch
                     WHERE pid.t_product_id = ph.product_id
                       AND ph.policy_header_id = p.pol_header_id
                       AND ch.p_policy_id = p.policy_id
                    UNION ALL
                    SELECT plid.t_issuer_doc_type_id, plid.is_required,
                           c.c_claim_header_id, plid.sort_order
                      FROM ven_t_pline_issuer_doc plid,
                           ven_t_product_line pl,
                           ven_c_damage d,
                           ven_c_claim c,
                           ven_p_cover pc,
                           ven_t_prod_line_option plo
                     WHERE plid.t_prod_line_id = pl.ID
                       AND d.c_claim_id = c.c_claim_id
                       AND d.p_cover_id = pc.p_cover_id
                       AND pc.t_prod_line_option_id = plo.ID
                       AND plo.product_line_id = plid.t_prod_line_id)
          GROUP BY t_issuer_doc_type_id, c_claim_header_id) q
   WHERE idt.t_issuer_doc_type_id = q.t_issuer_doc_type_id
     AND q.c_claim_header_id = cid.c_claim_header_id(+)
ORDER BY q.sort_order, q.is_required DESC, idt.NAME
]]>
      </select>
      <displayInfo x="3.81262" y="2.34375" width="1.30212" height="0.32983"/>
      <group name="G_EVENT_DOC">
        <displayInfo x="3.66016" y="2.91870" width="1.65051" height="0.94336"
        />
        <dataItem name="c_claim_header_id1" oracleDatatype="number"
         columnOrder="37" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="C Claim Header Id1">
          <dataDescriptor expression="q.c_claim_header_id"
           descriptiveExpression="C_CLAIM_HEADER_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="name" datatype="vchar2" columnOrder="38" width="150"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Name">
          <dataDescriptor expression="idt.name" descriptiveExpression="NAME"
           order="2" width="150"/>
        </dataItem>
        <dataItem name="receipt_date" datatype="vchar2" columnOrder="39"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Receipt Date">
          <dataDescriptor
           expression="nvl ( to_char ( cid.receipt_date , &apos;DD.MM.YYYY&apos; ) , &apos;@&apos; )"
           descriptiveExpression="RECEIPT_DATE" order="3" width="10"/>
        </dataItem>
        <dataItem name="request_date" datatype="vchar2" columnOrder="40"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Request Date">
          <dataDescriptor
           expression="nvl ( to_char ( cid.request_date , &apos;DD.MM.YYYY&apos; ) , &apos;@&apos; )"
           descriptiveExpression="REQUEST_DATE" order="4" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_EVENT" parentColumn="c_claim_id"
     childQuery="Q_STATUS_RISKA" childColumn="DOCUMENT_ID" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_EVENT" parentColumn="c_claim_id"
     childQuery="Q_DIAGNOZ" childColumn="c_claim_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_3" parentGroup="G_CLAIM" parentColumn="c_event_id2"
     childQuery="Q_EVENT" childColumn="c_event_id1" condition="eq"
     sqlClause="where"/>
    <link name="L_4" parentGroup="G_EVENT" parentColumn="c_claim_header_id"
     childQuery="Q_EVENT_DOC" childColumn="c_claim_header_id1" condition="eq"
     sqlClause="where"/>
  </data>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>

<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<title>Отчет Состояние_дела</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>achistyakov</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>3</o:TotalTime>
  <o:Created>2007-07-16T06:48:00Z</o:Created>
  <o:LastSaved>2007-07-16T06:48:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>107</o:Words>
  <o:Characters>610</o:Characters>
  <o:Company>office</o:Company>
  <o:Lines>5</o:Lines>
  <o:Paragraphs>1</o:Paragraphs>
  <o:CharactersWithSpaces>716</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:SpellingState>Clean</w:SpellingState>
  <w:GrammarState>Clean</w:GrammarState>
  <w:PunctuationKerning/>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:BreakWrappedTables/>
   <w:SnapToGridInCell/>
   <w:WrapTextWithPunct/>
   <w:UseAsianBreakRules/>
   <w:DontGrowAutofit/>
  </w:Compatibility>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Book Antiqua";
	panose-1:2 4 6 2 5 3 5 3 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Book Antiqua";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
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
	{mso-style-name:"Table Normal";
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

<rw:foreach id="G_CLAIM" src="G_CLAIM">

<rw:getValue id="num_dela" src="num_dela"/>
<rw:getValue id="pol_num" src="pol_num"/>
<rw:getValue id="ind_korp" src="ind_korp"/>
<rw:getValue id="FL_REG" src="FL_REG"/>
<rw:getValue id="asset_name" src="asset_name"/>
<rw:getValue id="START_DATE" src="START_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="EVENT_DATE" src="EVENT_DATE" formatMask="DD.MM.YYYY"/>
<rw:getValue id="DIAGNOSE" src="DIAGNOSE"/>

<div class=Section1>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='mso-ansi-language:RU'><span style='mso-spacerun:yes'></span><o:p></o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:191;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=103 style='width:77.4pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:20.0pt;mso-ansi-language:
  RU'>№ дела <%=num_dela%><o:p></o:p></span></b></p>
  </td>
  <td width=192 style='width:144.0pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:14.0pt;mso-ansi-language:
  RU'>Срок: <%=sdf.format(new java.util.Date())%><o:p></o:p></span></b></p>
  </td>
  <td width=343 style='width:257.15pt;border:solid windowtext 1.0pt;border-left:
  none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:14.0pt;mso-ansi-language:RU'>Важные сведения<o:p></o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-size:8.0pt;mso-ansi-language:RU'><span
style='mso-spacerun:yes'>                     </span><o:p></o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='mso-ansi-language:RU'>Полис № <%=pol_num%><o:p></o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='mso-ansi-language:RU'><%=ind_korp%><o:p></o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='mso-ansi-language:RU'>Город по полису: <%=FL_REG%><o:p></o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><u><span
style='font-size:18.0pt;mso-ansi-language:RU'><%=asset_name%><o:p></o:p></span></u></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><u><span
style='font-size:8.0pt;mso-ansi-language:RU'><o:p><span style='text-decoration:
 none'>&nbsp;</span></o:p></span></u></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='mso-ansi-language:RU'>Договор действует: с <%=START_DATE%><o:p></o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='mso-ansi-language:RU'>Страховой случай наступил: <%=EVENT_DATE%><o:p></o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=668
 style='width:500.9pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:191;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
  style='mso-ansi-language:RU'>Описание<o:p></o:p></span></i></b></p>
  </td>
  <td width=109 valign=top style='width:81.5pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><i style='mso-bidi-font-style:normal'><span
  style='mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></i></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='mso-ansi-language:RU'>Диагноз:<o:p></o:p></span></b></p>
  </td>
  <td width=453 colspan=2 valign=top style='width:339.75pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-ansi-language:RU'><%=DIAGNOSE%></span></p>
  </td>
 </tr>
 
<rw:foreach id="G_EVENT" src="G_EVENT">
<% COUNTER_I = 0; SUM_VYPL = 0; %>
<rw:getValue id="description" src="description"/>
<rw:getValue id="INS_AMOUNT" src="INS_AMOUNT" formatMask="999999990.99"/>
<%SUM_CC = Double.valueOf(INS_AMOUNT).doubleValue();%>
<rw:foreach id="G_DIAGNOZ" src="G_DIAGNOZ">
<rw:getValue id="DESCRIPTION1" src="DESCRIPTION1"/>
<rw:getValue id="CODE" src="CODE"/>
<rw:getValue id="PAYMENT_SUM" src="PAYMENT_SUM" formatMask="999999990.99"/>
<rw:getValue id="PERCENT" src="PERCENT" formatMask="999999990.99"/>
 
<%
  if (COUNTER_I == 0){
    TABL_VYPLAT_STR = CODE + "-" + Double.valueOf(PERCENT).toString()+"%";
    DIAGNOZ_STR = DESCRIPTION1 + "-" + Double.valueOf(PERCENT).toString()+"%";
    COUNTER_I = COUNTER_I + 1;
  } else {
    TABL_VYPLAT_STR = TABL_VYPLAT_STR + ", " + CODE + "-" + Double.valueOf(PERCENT).toString()+"%";
    DIAGNOZ_STR = DIAGNOZ_STR + ", " + DESCRIPTION1 + "-" + Double.valueOf(PERCENT).toString()+"%";  
  }
  SUM_VYPL = SUM_VYPL + Double.valueOf(PAYMENT_SUM).doubleValue();
  SUM_VYPL_ALL = SUM_VYPL_ALL + Double.valueOf(PAYMENT_SUM).doubleValue();
%>

</rw:foreach>
 
<% 
  if (SUM_CC != 0) PERCENT_ALL = SUM_VYPL / SUM_CC * 100;
%> 
 
 <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:6.75pt'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:silver;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='background:silver;
  mso-highlight:silver'>Риски</span></b></span><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='background:silver;mso-highlight:silver'> <span
  class=SpellE>по</span> <span class=SpellE>полису №</span> <%=pol_num%> <o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:silver;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.75pt'>
  <p class=MsoNormal><span class=SpellE><span lang=EN-US style='background:
  silver;mso-highlight:silver'><%=description%></span><o:p></o:p></span></p>
  </td>
  <td width=109 rowspan=6 valign=top style='width:81.5pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.75pt'>
  
<rw:foreach id="G_STATUS_RISKA" src="G_STATUS_RISKA">
<rw:getValue id="STATUS_RISKA" src="STATUS_RISKA"/>
  <p class=MsoNormal><span lang=EN-US><%=STATUS_RISKA%><b style='mso-bidi-font-weight:
  normal'><o:p></o:p></b></span></p>
</rw:foreach>  

  </td>
 </tr>
 <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:6.75pt'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:#E6E6E6;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US>Диагноз</span></b></span><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US>:<o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0cm 5.4pt 0cm 5.4pt;
  height:6.75pt'>
  <p class=MsoNormal><span style='mso-ansi-language:RU'><%=DIAGNOZ_STR%>.<o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;page-break-inside:avoid'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US>СС<o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US><%=INS_AMOUNT%>р.</span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;page-break-inside:avoid'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US>% <span class=SpellE>от</span> СС<o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US><%=format.format(PERCENT_ALL)%>%</span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;page-break-inside:avoid'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US>№ п. <span class=SpellE>по</span> <span
  class=SpellE>Таблице</span> <span class=SpellE>выплат</span><o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US><%=TABL_VYPLAT_STR%></span></p>
  </td>
 </tr>
 
 
 
 <tr style='mso-yfti-irow:7;page-break-inside:avoid'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US>Сумма</span></b></span><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US> к <span class=SpellE>выплате</span><o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span lang=EN-US><%=format.format(SUM_VYPL)%>р.</span></p>
  </td>
 </tr>

<%COUNTER_I2= 0;%>
<rw:foreach id=" G_EVENT_DOC1" src="G_EVENT_DOC">
<rw:getValue id="NAME_D1" src="NAME"/>
<rw:getValue id="RECEIPT_DATE_D1" src="RECEIPT_DATE"/>
<rw:getValue id="REQUEST_DATE_D1" src="REQUEST_DATE"/>
<%if ( (REQUEST_DATE_D1.equals("@")) && (!RECEIPT_DATE_D1.equals("@")) ){%>
  <%if (COUNTER_I2 == 0) { TMP_STR = "Полученные документы"; COUNTER_I2 = COUNTER_I2 + 1; }
  else {TMP_STR = " ";} %>
 <tr style='mso-yfti-irow:9;height:6.75pt'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US><%=TMP_STR%></span><o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal><span lang=EN-US><o:p><%=NAME_D1%></o:p></span></p>
  </td>
  <td width=109 valign=top style='width:81.5pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal><span lang=EN-US><o:p>
  <%=RECEIPT_DATE_D1%></o:p></span></p>
  </td>
 </tr>
 <%}%>
</rw:foreach>   


<%COUNTER_I2 = 0;%>
<rw:foreach id=" G_EVENT_DOC2" src="G_EVENT_DOC">
<rw:getValue id="NAME_D2" src="NAME"/>
<rw:getValue id="RECEIPT_DATE_D2" src="RECEIPT_DATE"/>
<rw:getValue id="REQUEST_DATE_D2" src="REQUEST_DATE"/>
<%if ( (!REQUEST_DATE_D2.equals("@")) && (RECEIPT_DATE_D2.equals("@")) ){%>
  <%if (COUNTER_I2 == 0) { TMP_STR = "Направленные запросы"; COUNTER_I2 = COUNTER_I2 + 1; }
  else {TMP_STR = " ";} %>
 <tr style='mso-yfti-irow:10;mso-yfti-lastrow:yes;height:6.75pt'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US><%=TMP_STR%></span><o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal><span lang=EN-US><o:p><%=NAME_D2%></o:p></span></p>
  </td>
  <td width=109 valign=top style='width:81.5pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal><span lang=EN-US><o:p>
  <%=REQUEST_DATE_D2%></o:p></span></p>
  </td>
 </tr>
 <%}%>
 </rw:foreach>   
</rw:foreach>

 <tr style='mso-yfti-irow:8;height:6.75pt'>
  <td width=215 valign=top style='width:161.15pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:silver;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal align=right style='text-align:right'><span class=SpellE><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US>Итого</span></b></span><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US><span
  style='mso-spacerun:yes'>  </span>к <span class=SpellE>выплате</span><o:p></o:p></span></b></p>
  </td>
  <td width=344 valign=top style='width:258.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal><span class=SpellE><span lang=EN-US><%=format.format(SUM_VYPL_ALL)%>р</span></span><span
  lang=EN-US>.</span></p>
  </td>
  <td width=109 valign=top style='width:81.5pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:6.75pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=EN-US><o:p>&nbsp;</o:p></span></p>

</div>

</rw:foreach>

</body>

</html>


</rw:report>
