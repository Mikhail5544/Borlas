<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
  String is_first = new String("Y");             
%>

<rw:report id="report"> 
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="indiv_cert" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="INDIV_CERT" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_ID" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_0">
      <select>
      <![CDATA[
      
  select  
	a.as_asset_id ID,
	    ( select count(*)
      from 
              ven_p_policy pp, 
              ven_as_asset ass, 
              ven_p_cover pc, 
              ven_t_prod_line_option plo,
              ven_t_product_line pl,
              ven_t_product_line_type plt
      where pp.policy_id = :P_POLICY_ID 
            and ass.as_asset_id = a.as_asset_id
       and ass.p_policy_id = pp.policy_id
       and pc.as_asset_id = ass.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and plo.product_line_id = pl.id
       and pl.product_line_type_id = plt.product_line_type_id
       and plt.brief = 'OPTIONAL'
       and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ') P_EXIST_DOP,
       
    (select count(*)
      from 
              ven_p_policy pp, 
              ven_as_asset ass, 
              ven_p_cover pc, 
              ven_t_prod_line_option plo,
              ven_t_product_line pl,
              ven_t_product_line_type plt,
              ven_t_lob_line tll,
              ven_t_lob tl,
              ven_t_insurance_group ig
      where pp.policy_id = :P_POLICY_ID
       and ass.as_asset_id = a.as_asset_id
       and ass.p_policy_id = pp.policy_id
       and pc.as_asset_id = ass.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and plo.product_line_id = pl.id
       and pl.product_line_type_id = plt.product_line_type_id
       and plt.brief = 'OPTIONAL'
       and pl.t_lob_line_id = tll.t_lob_line_id
       and tl.t_lob_id = tll.t_lob_id
       and ig.t_insurance_group_id = tll.insurance_group_id
       and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
       and ig.brief = 'Acc'
       and plo.id not in (22603,32005,44179,22629,27622,27624,28063,28065,28336,32005,43607,43609,
                         44103,44131,44177,57134,57138,57738,57802,57871,57925,58264)) P_EXIST_DOP_NS,
    decode(pp.pol_ser,null,pp.pol_num,pp.pol_ser || '-' || pp.pol_num) pol_num,
    to_char(ph.start_date,'dd.mm.yyyy') p_start_date,
    ins.pkg_utils.date2genitive_case(a.start_date,null,1) start_date_text,
	ins.pkg_utils.date2genitive_case(a.end_date,null,1) end_date_text,
	to_char(pp.end_date,'dd.mm.yyyy') p_end_date,
   ent.obj_name('CONTACT', pkg_policy.get_policy_holder_id(pp.policy_id)) pol_holder,
    ent.obj_name('CONTACT',s.assured_contact_id) pol_ass,
decode(vf.brief, 
           'RUR', 'руб.', 
           'USD', 'Доллары США',
           'EUR', 'евро',
           vf.brief) kod_val_up,
		   CASE WHEN pp.version_num = 1
          THEN 'к Договору группового страхования'
         WHEN pp.version_num != 1 AND pp.version_order_num IS NULL
          THEN 'к Дополнительному соглашению №'
                ||pol.max_dop||' к Договору группового страхования'
         WHEN pp.version_num != 1 AND pp.version_order_num IS NOT NULL
          THEN 'к Дополнительному соглашению №'||pp.version_order_num||' к Договору группового страхования'
    END num_dop
      from t_product ak, ven_p_policy pp, ven_p_pol_header ph, ven_as_asset a , status_hist hs, ven_as_assured s, contact cont, VEN_T_PAYMENT_TERMS vt, VEN_FUND vf,
	  (SELECT MAX(poll.version_order_num) max_dop,
                 poll.pol_header_id
          FROM ins.p_policy pol,
               ins.p_policy poll
          WHERE pol.policy_id = :P_POLICY_ID
            AND pol.pol_header_id = poll.pol_header_id
            AND poll.version_num < pol.version_num
          GROUP BY poll.pol_header_id
          ) pol,
    (select p.policy_id, count(1) row_cnt 
   from ven_policy_cash_surr p, ven_policy_cash_surr_d d 
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :P_POLICY_ID group by p.policy_id) rcnt,
  ( select document_id, start_date from (
    select ds.document_id, ds.start_date from ven_doc_status ds, ven_doc_status_ref dsr 
    where ds.doc_status_ref_id = dsr.doc_status_ref_id(+)
      and dsr.brief = 'ACTIVE' and ds.document_id = :P_POLICY_ID order by ds.start_date desc ) where rownum = 1) ds
    where pp.policy_id = :P_POLICY_ID
     and s.contact_id = cont.contact_id
     and ph.policy_header_id = pp.pol_header_id
     and a.p_policy_id = pp.policy_id
     and ak.product_id = ph.product_id
	 and a.status_hist_id = hs.status_hist_id
     and hs.brief = 'NEW'
     and pp.policy_id = ds.document_id(+) 
     and pp.policy_id = rcnt.policy_id(+)
     and ph.FUND_ID = vf.FUND_ID(+)     
     and s.as_assured_id = a.as_asset_id
     and pp.PAYMENT_TERM_ID = vt.ID(+)
	 AND pp.pol_header_id = pol.pol_header_id(+);

]]>
      </select>
	  <group name="G_0">
        <displayInfo x="2.20605" y="1.06458" width="1.09998" height="0.77246"/>
        <dataItem name="ID" oracleDatatype="number"
         columnOrder="1" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="ID">
          <dataDescriptor expression="a.as_asset_id"
           descriptiveExpression="ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="P_EXIST_DOP_NS" oracleDatatype="number"
         columnOrder="2" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="P EXIST DOP NS">
          <dataDescriptor expression="P_EXIST_DOP_NS"
           descriptiveExpression="P_EXIST_DOP_NS" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="P_EXIST_DOP" oracleDatatype="number"
         columnOrder="3" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="P EXIST DOP">
          <dataDescriptor expression="P_EXIST_DOP"
           descriptiveExpression="P_EXIST_DOP" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="pol_num" datatype="vchar2" columnOrder="4" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="pol num">
          <dataDescriptor expression="pol_num"
           descriptiveExpression="pol_num" order="4" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="p_start_date" datatype="vchar2" columnOrder="5" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="p start date">
          <dataDescriptor expression="p_start_date"
           descriptiveExpression="p_start_date" order="5" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
	    <dataItem name="start_date_text" datatype="vchar2" columnOrder="6" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="start date text">
          <dataDescriptor expression="start_date_text"
           descriptiveExpression="start_date_text" order="6" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="end_date_text" datatype="vchar2" columnOrder="7" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="end date text">
          <dataDescriptor expression="end_date_text"
           descriptiveExpression="end_date_text" order="7" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="p_end_date" datatype="vchar2" columnOrder="8" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="p end date">
          <dataDescriptor expression="p_end_date"
           descriptiveExpression="p_end_date" order="8" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="pol_holder" datatype="vchar2" columnOrder="9" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="pol holder">
          <dataDescriptor expression="pol_holder"
           descriptiveExpression="pol_holder" order="9" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="pol_ass" datatype="vchar2" columnOrder="10" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="pol ass">
          <dataDescriptor expression="pol_ass"
           descriptiveExpression="pol_ass" order="10" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="kod_val_up" datatype="vchar2" columnOrder="11" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="kod val up">
          <dataDescriptor expression="kod_val_up"
           descriptiveExpression="kod_val_up" order="11" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="num_dop" datatype="vchar2" columnOrder="12" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="num dop">
          <dataDescriptor expression="num_dop"
           descriptiveExpression="kod_valnum_dop_up" order="12" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select ass.as_asset_id, pkg_rep_utils.to_money_sep(pc.ins_amount) as dop_summ,
       pkg_rep_utils.to_money_sep(pc.fee) as dop_prem,
       '* '||decode(plo.description,'Дополнительный инвестиционный доход','ИНВЕСТ',
              upper(plo.description))
         as dop_progr,
         decode(upper(plo.description), 
              'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ', 1, 
              'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ', 1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ДАЛЬНЕЙШИХ ВЗНОСОВ РАСЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ ВЗНОСОВ РАСЧИТАННОЕ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
	'ЗАЩИТА СТРАХОВЫХ ВЗНОСОВ РАСЧИТАННАЯ ПО ОСНОВНОЙ ПРОГРАММЕ',1,
              0) as need_x
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt,
        ven_t_lob_line tll,
        ven_t_lob tl,
        ven_t_insurance_group ig
where pp.policy_id = :P_POLICY_ID
 and ass.as_asset_id = :ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 --and plt.brief = 'OPTIONAL'
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and (ig.brief <> 'Acc'
  or (ig.brief = 'Acc' and (plo.id = 22603 or plo.description like 'Освобождение%' or plo.description like 'Защита%'))) -- согласовано с Д.Ивановым! добавлено два последних or Веселуха
]]>
      </select>
	  <group name="G_1">
	  <displayInfo x="2.20605" y="1.06458" width="1.09998" height="0.77246"/>
        <dataItem name="as_asset_id1" oracleDatatype="number"
         columnOrder="1" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="as asset id1">
          <dataDescriptor expression="ass.as_asset_id"
           descriptiveExpression="as_asset_id" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="dop_summ" datatype="vchar2" columnOrder="2" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="dop summ">
          <dataDescriptor expression="pkg_rep_utils.to_money_sep(pc.ins_amount)"
           descriptiveExpression="dop_summ" order="2" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="dop_prem" datatype="vchar2" columnOrder="3" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="dop prem">
          <dataDescriptor expression="pkg_rep_utils.to_money_sep(pc.fee)"
           descriptiveExpression="dop_prem" order="3" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="dop_progr" datatype="vchar2" columnOrder="4" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="dop progr">
          <dataDescriptor expression="dop_progr"
           descriptiveExpression="dop_progr" order="4" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="need_x" datatype="vchar2" columnOrder="5" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="need x">
          <dataDescriptor expression="need_x"
           descriptiveExpression="need_x" order="5" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_3">
      <select>
      <![CDATA[
select  ass.as_asset_id,
       pkg_rep_utils.to_money_sep(pc.ins_amount) as dop_summ_ns,
       pkg_rep_utils.to_money_sep(pc.fee) as dop_prem_ns,
	   upper(plo.description) as dop_progr_ns
	   
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt,
        ven_t_lob_line tll,
        ven_t_lob tl,
        ven_t_insurance_group ig
where pp.policy_id = :P_POLICY_ID
 and ass.as_asset_id = :ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and pl.t_lob_line_id = tll.t_lob_line_id
 and tl.t_lob_id = tll.t_lob_id
 and ig.t_insurance_group_id = tll.insurance_group_id
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and ig.brief = 'Acc'
 and plo.id not in (22603,32005,44179,22629,27622,27624,28063,28065,28336,32005,43607,43609,44103,44131,44177,57134,57138,57738,57802,57871,57925,58264)
]]>
      </select>
      <group name="G_2">
 		<displayInfo x="2.20605" y="1.06458" width="1.09998" height="0.77246"/>
        <dataItem name="as_asset_id2" oracleDatatype="number"
         columnOrder="1" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="as asset id2">
          <dataDescriptor expression="ass.as_asset_id"
           descriptiveExpression="as_asset_id" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="dop_summ_ns" datatype="vchar2" columnOrder="2" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="dop summ ns">
          <dataDescriptor expression="pkg_rep_utils.to_money_sep(pc.ins_amount)"
           descriptiveExpression="dop_summ_ns" order="2" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="dop_prem_ns" datatype="vchar2" columnOrder="3" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="dop prem ns">
          <dataDescriptor expression="pkg_rep_utils.to_money_sep(pc.fee)"
           descriptiveExpression="dop_prem_ns" order="3" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="dop_progr_ns" datatype="vchar2" columnOrder="4" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="dop progr ns">
          <dataDescriptor expression="upper(plo.description)"
           descriptiveExpression="dop_progr_ns" order="4" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
	 </group>
    </dataSource>

  <link name="L_1" parentGroup="G_0" parentColumn="ID" childQuery="Q_1"
     childColumn="as_asset_id1" condition="eq" sqlClause="where"/>
  <link name="L_2" parentGroup="G_0" parentColumn="ID" childQuery="Q_3"
     childColumn="as_asset_id2" condition="eq" sqlClause="where"/>
  </data>
  <reportPrivate versionFlags2="0" templateName="rwbeige"/>
  <reportWebSettings>
  <![CDATA[]]>
  </reportWebSettings>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40"
xmlns:ns6="http://schemas.microsoft.com/office/2004/12/omml">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>Индивидуальный сертификат по полису</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>korendm</o:Author>
  <o:Template>policy_blank_06.dot</o:Template>
  <o:LastAuthor>Vitaly Ustinov</o:LastAuthor>
  <o:Revision>9</o:Revision>
  <o:TotalTime>5</o:TotalTime>
  <o:LastPrinted>2007-07-31T06:07:00Z</o:LastPrinted>
  <o:Created>2007-10-06T12:36:00Z</o:Created>
  <o:LastSaved>2007-10-06T12:40:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>793</o:Words>
  <o:Characters>4523</o:Characters>
  <o:Company>Renaissance Insurance Group</o:Company>
  <o:Lines>37</o:Lines>
  <o:Paragraphs>10</o:Paragraphs>
  <o:CharactersWithSpaces>5306</o:CharactersWithSpaces>
  <o:Version>11.8122</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:ValidateAgainstSchemas/>
  <w:SaveIfXMLInvalid>false</w:SaveIfXMLInvalid>
  <w:IgnoreMixedContent>false</w:IgnoreMixedContent>
  <w:AlwaysShowPlaceholderText>false</w:AlwaysShowPlaceholderText>
  <w:Compatibility>
   <w:SelectEntireFieldWithStartOrEnd/>
   <w:UseWord2002TableStyleRules/>
  </w:Compatibility>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
    {mso-style-parent:"";
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";
    mso-ansi-language:EN-US;
    mso-fareast-language:EN-US;}
h1
    {mso-style-next:Обычный;
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    page-break-after:avoid;
    mso-outline-level:1;
    font-size:8.0pt;
    font-family:"Times New Roman";
    mso-font-kerning:0pt;
    mso-bidi-font-weight:normal;}
h2
    {mso-style-next:Обычный;
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    page-break-after:avoid;
    mso-outline-level:2;
    font-size:10.0pt;
    font-family:"Times New Roman";
    mso-bidi-font-weight:normal;}
p.MsoHeader, li.MsoHeader, div.MsoHeader
    {margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    tab-stops:center 233.85pt right 467.75pt;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";
    mso-ansi-language:EN-US;
    mso-fareast-language:EN-US;}
p.MsoFooter, li.MsoFooter, div.MsoFooter
    {margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    tab-stops:center 233.85pt right 467.75pt;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";
    mso-ansi-language:EN-US;
    mso-fareast-language:EN-US;}
span.Items
    {mso-style-name:Items;
    font-weight:bold;
    mso-bidi-font-weight:normal;}
 /* Page Definitions */
@page Section1
    {size:595.3pt 841.9pt;
    margin:1.0cm 1.27cm 1.27cm 1.27cm;
    mso-header-margin:35.45pt;
    mso-footer-margin:14.2pt;
    mso-paper-source:0;}
div.Section1
    {page:Section1;}
@page Section2
    {size:595.3pt 841.9pt;
    margin:70.9pt 2.0cm 152.8pt 3.0cm;
    mso-header-margin:35.45pt;
    mso-footer-margin:14.2pt;
    mso-paper-source:0;}
div.Section2
    {page:Section2;}
@page Section3
    {size:595.3pt 841.9pt;
    margin:70.9pt 2.0cm 152.8pt 3.0cm;
    mso-header-margin:35.45pt;
    mso-footer-margin:14.2pt;
    mso-paper-source:0;}
div.Section3
    {page:Section3;}
 /* List Definitions */
 @list l0
    {mso-list-id:1868448227;
    mso-list-type:hybrid;
    mso-list-template-ids:-1196758838 67698703 67698713 67698715 67698703 67698713 67698715 67698703 67698713 67698715;}
@list l0:level1
    {mso-level-tab-stop:36.0pt;
    mso-level-number-position:left;
    text-indent:-18.0pt;}
ol
    {margin-bottom:0cm;}
ul
    {margin-bottom:0cm;}
-->
</style>
<!--[if gte mso 10]>
<style>
 /* Style Definitions */
 table.MsoNormalTable
    {mso-style-name:"Обычная таблица";
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
<![endif]--><!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="2050"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:36.0pt'>

<rw:foreach id="G_0" src="G_0">
<% if (is_first.equals("Y")) { is_first = "N"; } else {%>
<br clear=all style='page-break-before:always'>
<%}%>
<rw:getValue id="pol_num" src="pol_num"/>
<rw:getValue id="p_start_date" src="p_start_date"/>
<rw:getValue id="POL_HOLDER" src="POL_HOLDER"/>
<rw:getValue id="POL_ASS" src="POL_ASS"/>
<rw:getValue id="P_END_DATE" src="P_END_DATE"/>
<rw:getValue id="kod_val_up" src="kod_val_up"/>
<rw:getValue id="start_date_text" src="start_date_text"/>
<rw:getValue id="end_date_text" src="end_date_text"/>
<rw:getValue id="num_dop" src="num_dop"/>

<div class=Section1>
<br><br>
<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='margin-top:32.0pt;margin-right:0cm;
  margin-bottom:12.0pt;margin-left:0cm;text-align:center'><b><span
  style='font-size:15.0pt;mso-bidi-font-size:12.0pt;mso-ansi-language:
  RU'>Индивидуальный страховой сертификат</span></b></p>
  </td>
 </tr>
<tr style='mso-yfti-irow:12'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>

<tr style='mso-yfti-irow:2'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span
  style='font-size:12.0pt;mso-ansi-language:RU'><o:p><rw:field id="" src="num_dop">num_dop</rw:field> № <rw:field id="" src="pol_num">pol_num</rw:field> от 
<rw:field id="" src="p_start_date">p_start_date</rw:field> с ООО "СК "Ренессанс Жизнь".</o:p></span></p>
  </td>
 </tr>

<tr style='mso-yfti-irow:12'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  </td>
</tr>

<tr style='mso-yfti-irow:12'>
  <td width=508 valign=top style='width:331.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:12.0pt;mso-ansi-language:
  RU'><o:p> Страхователь:</o:p></span></p>
  </td>
  <td width=708 colspan=4 valign=top style='width:531.0pt;border-top:none;border-left:
  none;border-bottom:solid white 1.5pt;border-right:solid white 1.5pt;
  mso-border-top-alt:solid white 1.5pt;mso-border-left-alt:solid white 1.5pt;
  background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:12.0pt;mso-ansi-language:
  RU'><o:p> <b style='mso-bidi-font-weight:normal'><rw:field id="" src="POL_HOLDER">POL_HOLDER</rw:field></b></o:p></span></p>
  </td>
 </tr>
<tr style='mso-yfti-irow:9'>
  <td width=508 valign=top style='width:331.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:12.0pt;mso-ansi-language:RU'>
  <o:p>Застрахованное лицо:</o:p></span></p>
  </td>
  <td width=708 colspan=4 valign=top style='width:531.0pt;border-top:none;border-left:
  none;border-bottom:solid white 1.5pt;border-right:solid white 1.5pt;
  mso-border-top-alt:solid white 1.5pt;mso-border-left-alt:solid white 1.5pt;
  background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:12.0pt;mso-ansi-language:RU'>
  <o:p><b style='mso-bidi-font-weight:normal'> <rw:field id="" src="POL_ASS">POL_ASS</rw:field></b></o:p></span></p>
  </td>
 </tr>
<tr style='mso-yfti-irow:9'>
  <td width=508 valign=top style='width:331.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:12.0pt;mso-ansi-language:RU'>
  <o:p>Срок страхования:</o:p></span></p>
  </td>
  <td width=708 colspan=4 valign=top style='width:531.0pt;border-top:none;border-left:
  none;border-bottom:solid white 1.5pt;border-right:solid white 1.5pt;
  mso-border-top-alt:solid white 1.5pt;mso-border-left-alt:solid white 1.5pt;
  background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='font-size:12.0pt;mso-ansi-language:RU'>
  <o:p>с <b style='mso-bidi-font-weight:normal'><rw:field id="" src="start_date_text">start_date_text</rw:field> по <rw:field id="" src="end_date_text">end_date_text</rw:field></b></o:p></span></p>
  </td>
 </tr>
<tr style='mso-yfti-irow:12'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  </td>
</tr>
 <tr style='mso-yfti-irow:2'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:justify'><span
  style='font-size:12.0pt;mso-ansi-language:RU'><o:p>Настоящим Страховым Сертификатом подтверждается, что
 указанное выше лицо является застрахованным в соответствии с условиями Договора группового страхования 
№<rw:field id="" src="pol_num">pol_num</rw:field> на срок с <rw:field id="" src="start_date_text">start_date_text</rw:field> по <rw:field id="" src="end_date_text">end_date_text</rw:field> по нижеперечисленным страховым рискам:</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  </td>
</tr>
 <tr style='mso-yfti-irow:2'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span
  style='font-size:12.0pt;mso-ansi-language:RU'><b>Страховые риски и страховые суммы по рискам (указание валюты (<rw:field id="" src="kod_val_up">kod_val_up</rw:field>)) :</b></span></p>
  </td>
 </tr>
</table>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;'>

 <rw:getValue id="j_has_dop" src="P_EXIST_DOP"/>

 <% if (!j_has_dop.equals("0")) { %>

 <tr style='mso-yfti-irow:28;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border-top:none;border-left:
  none;border-bottom:solid white 1.5pt;border-right:solid white 1.5pt;
  mso-border-top-alt:solid white 1.5pt;mso-border-left-alt:solid white 1.5pt;
  background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>

 <% } %>

 <!-- ######################################################################## -->
 <rw:foreach id="G_1" src="G_1">

 <tr style='mso-yfti-irow:33;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-left:12.6pt;text-indent:-12.6pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><span style='mso-spacerun:yes'> 
  </span><rw:field id="" src="dop_progr"/></span></p>
  </td>

  <td width=143 colspan=2 valign=top style='width:107.5pt;border-top:none;border-left:
  none;border-bottom:solid white 1.5pt;border-right:solid white 1.5pt;
  mso-border-top-alt:solid white 1.5pt;mso-border-left-alt:solid white 1.5pt;
  background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:getValue id="j_need_x" src="need_x"/><% if (j_need_x.equals("1")) { %>X<% } else { %><rw:field id="" src="dop_summ"/><% } %></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:34;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:34;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border-top:none;border-left:
  none;border-bottom:solid white 1.5pt;border-right:solid white 1.5pt;
  mso-border-top-alt:solid white 1.5pt;mso-border-left-alt:solid white 1.5pt;
  background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</rw:foreach>

<rw:getValue id="j_has_ns" src="P_EXIST_DOP_NS"/>
<% if (!j_has_ns.equals("0")) { %>
 
 <!-- ########################################################################  -->
 <rw:foreach id="G_2" src="G_2"> 
 <tr style='mso-yfti-irow:39;'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-left:12.6pt;text-indent:-12.6pt'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><span
  style='mso-spacerun:yes'></span>&quot;<rw:field id="" src="dop_progr_ns"/>&quot;</span></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border-top:none;border-left:
  none;border-bottom:solid white 1.5pt;border-right:solid white 1.5pt;
  mso-border-top-alt:solid white 1.5pt;mso-border-left-alt:solid white 1.5pt;
  background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-ansi-language:
  RU'><rw:field id="" src="dop_summ_ns"/></span></b></p>
  </td>
 
 </tr>
 <tr style='mso-yfti-irow:40'>
  <td width=455 colspan=2 valign=top style='width:341.3pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
  <td width=143 colspan=2 valign=top style='width:107.5pt;border-top:none;border-left:
  none;border-bottom:solid white 1.5pt;border-right:solid white 1.5pt;
  mso-border-top-alt:solid white 1.5pt;mso-border-left-alt:solid white 1.5pt;
  background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:3.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 </rw:foreach>
 <% } %>
</table>

<br><br><br>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=708
 style='width:531.0pt;mar-gin-left:-48.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;'>
  
 <tr bgcolor='#F0F0F0' style='mso-yfti-irow:6;height:3.15pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.15pt'>
  <p class=MsoNormal style='margin-top:12.0pt;text-align:justify'><a
  name="print_days"><span
  style='font-size:12.0pt;mso-ansi-language:RU'>Время действия страховой защиты: 24 часа в сутки 365 дней в году.
</span></span><i><span style='font-size:10.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU;mso-no-proof:yes'><o:p></o:p></span></p>
  </td> 
 </tr>

 <tr bgcolor='#F0F0F0' style='mso-yfti-irow:6;height:3.15pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;border:solid white 1.5pt;
  border-top:none;mso-border-top-alt:solid white 1.5pt;background:#D9D9D9;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.15pt'>
  <p class=MsoNormal style='margin-top:12.0pt;text-align:justify'><a
  name="print_days"><span style='font-size:12.0pt;mso-ansi-language:RU'>Данный Страховой Сертификат выдан на основании Договора 
группового страхования №<rw:field id="" src="pol_num">pol_num</rw:field> <rw:field id="" src="POL_HOLDER">POL_HOLDER</rw:field> от 
<rw:field id="" src="p_start_date">p_start_date</rw:field> с ООО "СК "Ренессанс Жизнь", но не заменяет этот договор.
</span></span><span style='font-size:12.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU;mso-no-proof:yes'><o:p></o:p></span></p>
  </td> 
 </tr>

 <tr style='mso-yfti-irow:6;height:3.15pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.15pt'>
  <p class=MsoNormal style='margin-top:12.0pt;text-align:justify'><a
  name="print_days"><span
  style='font-size:8.0pt;mso-ansi-language:RU'>_____________________________________________________________________________ 
</span></span><span style='font-size:9.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU;mso-no-proof:yes'><o:p></o:p></span></p>
  </td> 
 </tr>

<tr style='mso-yfti-irow:12'>
  <td width=708 colspan=5 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:left'><span style='font-size:10.0pt;mso-ansi-language:
  RU'><o:p>&nbsp;</o:p></span></p>
  </td>
</tr>

 <tr style='mso-yfti-irow:6;height:3.15pt;'>
  <td width=708 colspan=12 valign=top style='width:531.0pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.15pt'>
  <p class=MsoNormal style='margin-top:12.0pt;text-align:justify'><a
  name="print_days"><b style='mso-bidi-font-weight:normal'><span
  style='font-size:12.0pt;mso-ansi-language:RU'>М.П. Страховщика 
</span></b></span><b
  style='mso-bidi-font-weight:normal'><span style='font-size:12.0pt;
  mso-bidi-font-size:12.0pt;mso-ansi-language:RU;mso-no-proof:yes'><o:p></o:p></span></b></p>
  </td> 
 </tr>

</table>
 

</div>

</rw:foreach>

</body>

</html>

</rw:report> 

