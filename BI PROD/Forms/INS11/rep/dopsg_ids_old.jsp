<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
  DecimalFormatSymbols unusualSymbols =  new DecimalFormatSymbols();
  unusualSymbols.setDecimalSeparator('.');
  String strange = "0";
  DecimalFormat format = new DecimalFormat(strange, unusualSymbols);  

  SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
  String strax_fio = new String("");
  String strax_doc = new String("");
  String strax_fio_sokr = new String("");
  String D_ADMIN_PAY = new String("X");
  String D_ITOGO_PREM = new String("X"); 
  String S_DAT_VYZH = new String("X"); 
  double NUM_PP = 2; 
  double ROW_PRIL = 0;    
%>

<rw:report id="report">

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="dopsg_ids" DTDVersion="9.0.2.0.10" beforeReportTrigger="afterpform">
  <xmlSettings xmlTag="DOPSG_IDS" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="POL_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_EXIST_DOP"/>
    <dataSource name="Q_POLICY">
      <select canParse="no">
      <![CDATA[SELECT p.policy_id, ph.policy_header_id,nvl(ame.ADDENDUM_NOTE,'@') as ADDENDUM_NOTE,
       p.VERSION_ORDER_NUM VERSION_NUM,
       p.CONFIRM_DATE,
p.CONFIRM_DATE_ADDENDUM,
       NVL (DECODE (NVL (pol_ser, '@'),
                    '@', pol_num,
                    pol_ser || '-' || pol_num
                   ),
            '@@'
           ) pol_ser_num,
nvl(ame.UNDERWRITING_NOTE,'@') as UNDERWRITING_NOTE,
(select lower(DESCRIPTION) from VEN_T_PAYMENT_TERMS where ID = p.PAYMENT_TERM_ID) as PA_PERIODICH
  FROM ven_p_policy p, ven_p_pol_header ph, ven_as_asset ass, ven_ASSURED_MEDICAL_EXAM ame
WHERE p.POL_HEADER_ID = ph.POLICY_HEADER_ID
  and p.POLICY_ID = ass.P_POLICY_ID(+)
  AND ass.AS_ASSET_ID = ame.AS_ASSURED_ID(+)
 AND p.policy_id = :POL_ID]]>
      </select>
      <displayInfo x="0.21875" y="0.09387" width="1.33325" height="0.19995"/>
      <group name="G_POLICY">
        <displayInfo x="0.04041" y="0.60620" width="1.68176" height="1.62695"
        />
        <dataItem name="PA_PERIODICH" datatype="vchar2" columnOrder="20"
         width="500" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pa Periodich">
          <dataDescriptor expression="PA_PERIODICH"
           descriptiveExpression="PA_PERIODICH" order="9" width="500"/>
        </dataItem>
        <dataItem name="UNDERWRITING_NOTE" datatype="vchar2" columnOrder="19"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Underwriting Note">
          <dataDescriptor expression="UNDERWRITING_NOTE"
           descriptiveExpression="UNDERWRITING_NOTE" order="8" width="2000"/>
        </dataItem>
        <dataItem name="CONFIRM_DATE_ADDENDUM" datatype="date"
         oracleDatatype="date" columnOrder="18" width="9" defaultWidth="90000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Confirm Date Addendum">
          <dataDescriptor expression="CONFIRM_DATE_ADDENDUM"
           descriptiveExpression="CONFIRM_DATE_ADDENDUM" order="6"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="ADDENDUM_NOTE" datatype="vchar2" columnOrder="17"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Addendum Note">
          <dataDescriptor expression="ADDENDUM_NOTE"
           descriptiveExpression="ADDENDUM_NOTE" order="3" width="2000"/>
        </dataItem>
        <dataItem name="VERSION_NUM" oracleDatatype="number" columnOrder="15"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Version Num">
          <dataDescriptor expression="VERSION_NUM"
           descriptiveExpression="VERSION_NUM" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="CONFIRM_DATE" datatype="date" oracleDatatype="date"
         columnOrder="16" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Confirm Date">
          <dataDescriptor expression="CONFIRM_DATE"
           descriptiveExpression="CONFIRM_DATE" order="5"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="policy_id" oracleDatatype="number" columnOrder="12"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id">
          <dataDescriptor expression="POLICY_ID"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POLICY_HEADER_ID" oracleDatatype="number"
         columnOrder="13" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Policy Header Id">
          <dataDescriptor expression="POLICY_HEADER_ID"
           descriptiveExpression="POLICY_HEADER_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="pol_ser_num" datatype="vchar2" columnOrder="14"
         width="2049" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Ser Num">
          <dataDescriptor expression="POL_SER_NUM"
           descriptiveExpression="POL_SER_NUM" order="7" width="2049"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STRAHOVATEL">
      <select>
      <![CDATA[SELECT iss.policy_id, iss.contact_id, iss.contact_name, vcp.date_of_birth,
       replace(NVL (TRIM (pkg_contact.get_primary_doc_2 (iss.contact_id)),'@@'),'-',' ') doc_inf, 
       vc.short_name
  FROM v_pol_issuer iss, ven_cn_person vcp, ven_contact vc
 WHERE iss.contact_id = vcp.contact_id AND vc.contact_id = iss.contact_id;       ]]>
      </select>
      <displayInfo x="2.12427" y="0.09387" width="1.32312" height="0.32983"/>
      <group name="G_STRAHOVATEL">
        <displayInfo x="2.10815" y="0.64563" width="1.35876" height="1.45605"
        />
        <dataItem name="short_name" datatype="vchar2" columnOrder="26"
         width="100" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Short Name">
          <dataDescriptor expression="vc.short_name"
           descriptiveExpression="SHORT_NAME" order="6" width="100"/>
        </dataItem>
        <dataItem name="policy_id1" oracleDatatype="number" columnOrder="21"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id1">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="contact_name" datatype="vchar2" columnOrder="23"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name">
          <dataDescriptor expression="iss.contact_name"
           descriptiveExpression="CONTACT_NAME" order="3" width="4000"/>
        </dataItem>
        <dataItem name="contact_id" oracleDatatype="number" columnOrder="22"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Contact Id">
          <dataDescriptor expression="iss.contact_id"
           descriptiveExpression="CONTACT_ID" order="2"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="date_of_birth" datatype="date" oracleDatatype="date"
         columnOrder="24" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth">
          <dataDescriptor expression="vcp.date_of_birth"
           descriptiveExpression="DATE_OF_BIRTH" order="4"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="doc_inf" datatype="vchar2" columnOrder="25"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Doc Inf">
          <dataDescriptor
           expression="replace ( NVL ( TRIM ( pkg_contact.get_primary_doc ( iss.contact_id ) ) , &apos;@@&apos; ) , &apos;-&apos; , &apos; &apos; )"
           descriptiveExpression="DOC_INF" order="5" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_MAIN_COVER">
      <select>
      <![CDATA[    select pkg_rep_utils.to_money_sep(pc.ins_amount) MAIN_COVER_SUM,
       pkg_rep_utils.to_money_sep(pc.fee) MAIN_COVER_PREM,
         upper(plo.description) MAIN_COVER
    from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and plo.product_line_id = pl.id
     and pl.product_line_type_id = plt.product_line_type_id
     and plt.brief = 'RECOMMENDED'
     and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
     and rownum = 1;
]]>
      </select>
      <displayInfo x="0.29175" y="2.78125" width="1.50000" height="0.19995"/>
      <group name="G_MAIN_COVER">
        <displayInfo x="0.23840" y="3.24158" width="1.60535" height="0.77246"
        />
        <dataItem name="MAIN_COVER_SUM" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pkg Rep Utils To Money Pc Ins">
          <xmlSettings xmlTag="PKG_REP_UTILS_TO_MONEY_PC_INS_"/>
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( pc.ins_amount )"
           descriptiveExpression="MAIN_COVER_SUM" order="1" width="4000"/>
        </dataItem>
        <dataItem name="MAIN_COVER_PREM" datatype="vchar2" columnOrder="28"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pkg Rep Utils To Money Pc Prem">
          <xmlSettings xmlTag="PKG_REP_UTILS_TO_MONEY_PC_PREM"/>
          <dataDescriptor expression="pkg_rep_utils.to_money_sep ( pc.premium )"
           descriptiveExpression="MAIN_COVER_PREM" order="2" width="4000"/>
        </dataItem>
        <dataItem name="MAIN_COVER" datatype="vchar2" columnOrder="29"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <xmlSettings xmlTag="DESCRIPTION"/>
          <dataDescriptor expression="plo.description"
           descriptiveExpression="MAIN_COVER" order="3" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ITOG_PREM">
      <select>
      <![CDATA[  select pkg_rep_utils.to_money_sep(sum(pc.fee)) ITOGO_PREM
  from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_t_prod_line_option plo
  where pp.policy_id = :POL_ID
   and ass.p_policy_id = pp.policy_id
   and pc.as_asset_id = ass.as_asset_id
   and plo.id = pc.t_prod_line_option_id
   and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ';
]]>
      </select>
      <displayInfo x="2.29163" y="2.80212" width="1.13538" height="0.19995"/>
      <group name="G_ITOGO_PREM">
        <displayInfo x="2.19666" y="3.27283" width="1.32751" height="0.43066"
        />
        <dataItem name="ITOGO_PREM" datatype="vchar2" columnOrder="30"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Itogo Prem">
          <dataDescriptor
           expression="pkg_rep_utils.to_money_sep ( sum ( pc.premium ) )"
           descriptiveExpression="ITOGO_PREM" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ADMIN_PAY">
      <select>
      <![CDATA[select pkg_rep_utils.to_money_sep(pc.fee) ADMIN_PAY
    from 
            ven_p_policy pp, 
            ven_as_asset ass, 
            ven_p_cover pc, 
            ven_t_prod_line_option plo
    where pp.policy_id = :POL_ID
     and ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and upper(trim(plo.description)) = 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
     and rownum = 1;]]>
      </select>
      <displayInfo x="3.71912" y="2.75000" width="1.11450" height="0.19995"/>
      <group name="G_ADMIN_PAY">
        <displayInfo x="3.63940" y="3.26257" width="1.27551" height="0.43066"
        />
        <dataItem name="ADMIN_PAY" datatype="vchar2" columnOrder="31"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Admin Pay">
          <dataDescriptor expression="pkg_rep_utils.to_money_sep ( pc.premium )"
           descriptiveExpression="ADMIN_PAY" order="1" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DOP_SUMM">
      <select>
      <![CDATA[-- Доплнительные программы
select pkg_rep_utils.to_money_sep(pc.ins_amount) as dop_summ,
       pkg_rep_utils.to_money_sep(pc.fee) as dop_prem,
       upper(plo.description) as dop_progr,
       decode(upper(plo.description), 'ОСВОБОЖДЕНИЕ ОТ УПЛАТЫ СТРАХОВЫХ ВЗНОСОВ', 1, 0) as need_x
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_status_hist sh,
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
where pp.policy_id = :POL_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and pc.status_hist_id = sh.status_hist_id
 and decode(sh.imaging || decode(p_cover_id, null, 0, 1),
              '-1',
              0,
              decode(p_cover_id, null, 0, 1)) > 0
 ]]>
     </select>
      <group name="G_dop_summ">
      </group>
    </dataSource>
    <dataSource name="Q_VYK_SUMM">
      <select canParse="no">
      <![CDATA[select 
rownum as n,
v.insurance_year_number as year_number,
to_char(v.start_cash_surr_date,'dd.mm.yyyy') as period_start,
to_char(v.end_cash_surr_date,'dd.mm.yyyy') as period_end,
pkg_rep_utils.to_money_sep(v.value) as ransom
from
 (select d.* from ven_policy_cash_surr p, ven_policy_cash_surr_d d 
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
  order by d.start_cash_surr_date) v]]>
      </select>
      <displayInfo x="5.60425" y="0.20837" width="1.06250" height="0.19995"/>
      <group name="G_VYK_SUMM">
        <displayInfo x="5.40540" y="0.71033" width="1.45251" height="1.11426"
        />
        <dataItem name="N" oracleDatatype="number" columnOrder="35" width="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="N">
          <dataDescriptor expression="N" descriptiveExpression="N" order="1"
           width="22" precision="38"/>
        </dataItem>
        <dataItem name="YEAR_NUMBER" oracleDatatype="number" columnOrder="36"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Year Number">
          <dataDescriptor expression="YEAR_NUMBER"
           descriptiveExpression="YEAR_NUMBER" order="2" width="22"
           scale="-127"/>
        </dataItem>
        <dataItem name="PERIOD_START" datatype="vchar2" columnOrder="37"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period Start">
          <dataDescriptor expression="PERIOD_START"
           descriptiveExpression="PERIOD_START" order="3" width="10"/>
        </dataItem>
        <dataItem name="PERIOD_END" datatype="vchar2" columnOrder="38"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period End">
          <dataDescriptor expression="PERIOD_END"
           descriptiveExpression="PERIOD_END" order="4" width="10"/>
        </dataItem>
        <dataItem name="RANSOM" datatype="vchar2" columnOrder="39"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ransom">
          <dataDescriptor expression="RANSOM" descriptiveExpression="RANSOM"
           order="5" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_DAT_VYZH">
      <select>
      <![CDATA[select to_char(ds.start_date,'dd.mm.yyyy') dat_vyzh
from ven_doc_status ds, ven_doc_status_ref dsr 
    where ds.doc_status_ref_id = dsr.doc_status_ref_id(+)
      and dsr.brief = 'ACTIVE' and ds.document_id =:POL_ID]]>
      </select>
      <displayInfo x="5.29175" y="2.14575" width="0.96863" height="0.19995"/>
      <group name="G_dat_vyzh">
        <displayInfo x="5.21753" y="2.67920" width="1.16089" height="0.43066"
        />
        <dataItem name="dat_vyzh" datatype="vchar2" columnOrder="40"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Dat Vyzh">
          <dataDescriptor
           expression="to_char ( ds.start_date , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="DAT_VYZH" order="1" width="10"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_PA_ROW_PRIL">
      <select>
      <![CDATA[select count(1) PA_ROW_PRIL
   from ven_policy_cash_surr p, ven_policy_cash_surr_d d 
  where d.policy_cash_surr_id = p.policy_cash_surr_id
  and p.policy_id= :POL_ID
]]>
      </select>
      <displayInfo x="5.10413" y="3.37500" width="1.39587" height="0.19995"/>
      <group name="G_PA_ROW_PRIL">
        <displayInfo x="5.15417" y="3.85608" width="1.09998" height="0.43066"
        />
        <dataItem name="PA_ROW_PRIL" oracleDatatype="number" columnOrder="41"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Row Cnt">
          <dataDescriptor expression="count ( 1 )"
           descriptiveExpression="PA_ROW_PRIL" order="1"
           oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_POLICY" parentColumn="policy_id"
     childQuery="Q_STRAHOVATEL" childColumn="policy_id1" condition="eq"
     sqlClause="where"/>
  </data>
  <programUnits>
    <function name="afterpform">
      <textSource>
      <![CDATA[function AfterPForm return boolean is
begin
  -- Доплнительные программы
  begin


select count(*) into :P_EXIST_DOP
from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc, 
        ven_status_hist sh,
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
where pp.policy_id = :POL_ID
 and ass.p_policy_id = pp.policy_id
 and pc.as_asset_id = ass.as_asset_id
 and plo.id = pc.t_prod_line_option_id
 and plo.product_line_id = pl.id
 and pl.product_line_type_id = plt.product_line_type_id
 and plt.brief = 'OPTIONAL'
 and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
 and pc.status_hist_id = sh.status_hist_id
 and decode(sh.imaging || decode(p_cover_id, null, 0, 1),
              '-1',
              0,
              decode(p_cover_id, null, 0, 1)) > 0;
 
  exception
      when no_data_found then :P_EXIST_DOP := 0; 
  end;

  return true;

end;
]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>


<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="dopsg_ids_files/filelist.xml">
<title>Дополнительное соглашение</title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>sterlta</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>3</o:Revision>
  <o:TotalTime>4</o:TotalTime>
  <o:LastPrinted>2007-07-11T07:09:00Z</o:LastPrinted>
  <o:Created>2007-09-10T12:53:00Z</o:Created>
  <o:LastSaved>2007-09-10T12:58:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>285</o:Words>
  <o:Characters>1628</o:Characters>
  <o:Lines>13</o:Lines>
  <o:Paragraphs>3</o:Paragraphs>
  <o:CharactersWithSpaces>1910</o:CharactersWithSpaces>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>BestFit</w:Zoom>
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
 /* Font Definitions */
 @font-face
    {font-family:SimSun;
    panose-1:2 1 6 0 3 1 1 1 1 1;
    mso-font-alt:\5B8B\4F53;
    mso-font-charset:134;
    mso-generic-font-family:auto;
    mso-font-format:other;
    mso-font-pitch:variable;
    mso-font-signature:1 135135232 16 0 262144 0;}
@font-face
    {font-family:Tahoma;
    panose-1:2 11 6 4 3 5 4 4 2 4;
    mso-font-charset:204;
    mso-generic-font-family:swiss;
    mso-font-pitch:variable;
    mso-font-signature:1627421319 -2147483648 8 0 66047 0;}
@font-face
    {font-family:"\@SimSun";
    panose-1:0 0 0 0 0 0 0 0 0 0;
    mso-font-charset:134;
    mso-generic-font-family:auto;
    mso-font-format:other;
    mso-font-pitch:variable;
    mso-font-signature:1 135135232 16 0 262144 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
    {mso-style-parent:"";
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    font-size:12.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";}
p.MsoFooter, li.MsoFooter, div.MsoFooter
    {margin:0cm;
    margin-bottom:.0001pt;
    text-align:center;
    mso-pagination:widow-orphan;
    tab-stops:center 216.0pt right 432.0pt;
    font-size:9.0pt;
    mso-bidi-font-size:10.0pt;
    font-family:"Times New Roman";
    mso-fareast-font-family:"Times New Roman";
    mso-ansi-language:EN-GB;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
    {mso-style-noshow:yes;
    margin:0cm;
    margin-bottom:.0001pt;
    mso-pagination:widow-orphan;
    font-size:8.0pt;
    font-family:Tahoma;
    mso-fareast-font-family:"Times New Roman";}
@page Section1
    {size:595.3pt 841.9pt;
    margin:42.55pt 42.55pt 42.55pt 70.9pt;
    mso-header-margin:35.45pt;
    mso-footer-margin:35.45pt;
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
table.MsoTableGrid
    {mso-style-name:"Table Grid";
    mso-tstyle-rowband-size:0;
    mso-tstyle-colband-size:0;
    border:solid windowtext 1.0pt;
    mso-border-alt:solid windowtext .5pt;
    mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
    mso-border-insideh:.5pt solid windowtext;
    mso-border-insidev:.5pt solid windowtext;
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
 <o:shapedefaults v:ext="edit" spidmax="4098"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU style='tab-interval:35.4pt'>


<rw:foreach id="gstrahovatel" src="G_STRAHOVATEL">
<rw:getValue id="strahName_tmp" src="CONTACT_NAME"/>
<rw:getValue id="SHORT_NAME_TMP" src="SHORT_NAME"/>
<rw:getValue id="tmpVal" src="DOC_INF"/>  
<%
  if (!tmpVal.equals("@@")){ strax_doc = tmpVal; }
  strax_fio = strahName_tmp;
  strax_fio_sokr = SHORT_NAME_TMP;
%>
</rw:foreach>

<rw:foreach id="G_ADMIN_PAY" src="G_ADMIN_PAY">
<rw:getValue id="ADMIN_PAY" src="ADMIN_PAY"/>
<% D_ADMIN_PAY = ADMIN_PAY;%>
</rw:foreach>

<rw:foreach id="G_PA_ROW_PRIL" src="G_PA_ROW_PRIL">
<rw:getValue id="PA_ROW_PRIL" src="PA_ROW_PRIL"/>
<% ROW_PRIL = Double.valueOf(PA_ROW_PRIL).doubleValue();%>
</rw:foreach>

<rw:foreach id="G_dat_vyzh" src="G_dat_vyzh">
<rw:getValue id="DAT_VYZH" src="DAT_VYZH"/>
<% S_DAT_VYZH = DAT_VYZH;%>
</rw:foreach>

<rw:foreach id="G_ITOGO_PREM" src="G_ITOGO_PREM">
<rw:getValue id="ITOGO_PREM" src="ITOGO_PREM"/>
<% D_ITOGO_PREM = ITOGO_PREM;%>
</rw:foreach>

<rw:foreach id="G_POLICY" src="G_POLICY">
<rw:getValue id="VERSION_NUM" src="VERSION_NUM"/>
<rw:getValue id="pol_ser_num" src="pol_ser_num"/>
<rw:getValue id="ADDENDUM_NOTE" src="ADDENDUM_NOTE"/>
<rw:getValue id="UNDERWRITING_NOTE" src="UNDERWRITING_NOTE"/>
<rw:getValue id="PA_PERIODICH" src="PA_PERIODICH"/>
<rw:getValue id="CONFIRM_DATE" src="CONFIRM_DATE" formatMask="DD.MM.YYYY"/>  
<rw:getValue id="CONFIRM_DATE_ADDENDUM" src="CONFIRM_DATE_ADDENDUM" formatMask="DD.MM.YYYY"/>  

<div class=Section1>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:16.0pt'>Дополнительное соглашение № <%=VERSION_NUM%></span></p>

<p class=MsoNormal align=center style='text-align:center'><span
style='font-size:14.0pt'>к Договору страхования № <%=pol_ser_num%> от <%=CONFIRM_DATE_ADDENDUM%></span></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='margin-left:-3.6pt;border-collapse:collapse;mso-yfti-tbllook:480;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=312 valign=top style='width:234.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal>г. Москва</p>
  </td>
<td width=348 valign=top style='width:261.0pt;padding:0cm 5.4pt 0cm 5.4pt'><a
  name="f_add_start_date"></a>
  <p class=MsoNormal align=right style='text-align:right'><span
  style='mso-bookmark:f_add_start_date'><span style='font-size:10.0pt'><o:p><%=sdf.format(new java.util.Date())%></o:p></span></span></p>
  </td>  
 </tr>
</table>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify;text-indent:18.0pt'><span
style='letter-spacing:-.1pt'>ООО «СК «Ренессанс Жизнь», именуемое в дальнейшем
«Страховщик», в лице Управляющего
Директора Киселева О.М., действующего на основании Доверенности № 2006/07/23 от
23.11.2006 г., с одной стороны, и <%=strax_fio%>, <%=strax_doc%>, именуемый (ая)<span
style='mso-spacerun:yes'>  </span>в дальнейшем «Страхователь», с другой
стороны, заключили настоящее Дополнительное Соглашение к Договору страхования №
<%=pol_ser_num%> от <%=CONFIRM_DATE_ADDENDUM%> (далее – Договор) о нижеследующем:<o:p></o:p></span></p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<p class=MsoNormal style='text-align:justify'>1. Стороны договорились п. 4
Договора изложить в следующей редакции:</p>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b><span style='font-size:9.0pt;
  mso-bidi-font-size:8.0pt;color:#FF6600'>4. ПРОГРАММЫ СТРАХОВАНИЯ</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Страховая
  сумма, руб<o:p></o:p></span></i></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:8.0pt'>Премия, руб<o:p></o:p></span></i></p>
  </td>
 </tr>
 
 <tr style='mso-yfti-irow:2;height:3.5pt'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:3.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>

 <rw:foreach id="G_MAIN_COVER" src="G_MAIN_COVER">
<rw:getValue id="MAIN_COVER" src="MAIN_COVER"/>
<rw:getValue id="MAIN_COVER_SUM" src="MAIN_COVER_SUM" formatMask="999999990.99"/>
<rw:getValue id="MAIN_COVER_PREM" src="MAIN_COVER_PREM" formatMask="999999990.99"/>

 <tr style='mso-yfti-irow:3'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ОСНОВНАЯ ПРОГРАММА: </span></b><span
  style='font-size:8.0pt;mso-bidi-font-weight:bold'>&quot;<rw:field id="" src="MAIN_COVER"/>&quot;<!-- (ПУНКТ 3.1. ОБЩИХ УСЛОВИЙ СТРАХОВАНИЯ ПО ИНДИВИДУАЛЬНОМУ
  СТРАХОВАНИЮ И СТРАХОВАНИЮ ОТ НЕСЧАСТНЫХ СЛУЧАЕВ (ДАЛЕЕ - ОБЩИХ УСЛОВИЙ
  СТРАХОВАНИЯ)--></span><span style='font-size:8.0pt'><o:p></o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><%=MAIN_COVER_SUM%></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><%=MAIN_COVER_PREM%></o:p></span></b></p>
  </td>  
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</rw:foreach>  
 
 <rw:getValue id="J_EXIST_DOP" src="P_EXIST_DOP"/>

 <% if ( !J_EXIST_DOP.equals("0") ) { %>
 <tr style='mso-yfti-irow:5'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ДОПОЛНИТЕЛЬНЫЕ ПРОГРАММЫ<o:p></o:p></span></b></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 
 <rw:foreach id="G_DOP_SUMM" src="G_DOP_SUMM">
 
 <tr style='mso-yfti-irow:7'>
  <td width=367 colspan=3 valign=top style='width:275.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:8.0pt'><o:p><rw:field id="" src="dop_progr"/></o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border-top:dashed windowtext 1.0pt;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><rw:getValue id="j_need_x" src="need_x"/><% if (j_need_x.equals("1")) { %>X<% } else { %><rw:field id="" src="dop_summ"/><% } %></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:dashed windowtext 1.0pt;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><rw:field id="" src="dop_prem"/></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=203 colspan=2 valign=top style='width:152.25pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=168 valign=top style='width:126.0pt;border:none;mso-border-top-alt:
  dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-top-alt:dashed windowtext .5pt;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:6.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</rw:foreach>
  <% } %>   
 
 <tr style='mso-yfti-irow:9'>
  <td width=535 colspan=4 valign=top style='width:401.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>ИТОГО ПРЕМИЯ<% if ( !J_EXIST_DOP.equals("0") ) { %>: ОСНОВНАЯ И ДОПОЛНИТЕЛЬНЫЕ
  ПРОГРАММЫ<% } %> (<i style='mso-bidi-font-style:normal'>уплачивается <%=PA_PERIODICH%></i>):<o:p></o:p></span></b></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border-top:none;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><%=D_ITOGO_PREM%></o:p></span></b></p>
  </td>

 </tr>
 <tr style='mso-yfti-irow:10'>
  <td width=164 valign=top style='width:123.15pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=155 valign=top style='width:116.25pt;border:none;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=216 colspan=2 valign=top style='width:162.0pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=122 valign=top style='width:91.35pt;border:none;border-bottom:none;
  mso-border-bottom-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><span style='font-size:2.0pt'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 
 <% if (!D_ADMIN_PAY.equals("X")) { %>
 <tr style='mso-yfti-irow:11;'>
  <td width=535 colspan=4 valign=top style='width:401.4pt;border:none;
  border-right:dashed windowtext 1.0pt;mso-border-right-alt:dashed windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt'>АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ (<i
  style='mso-bidi-font-style:normal'>уплачивается раз в год</i>):<o:p></o:p></span></b></p>
  </td>
  
  <td width=122 valign=top style='width:91.35pt;border-top:dashed windowtext 1.0pt;border-left:
  none;border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dashed windowtext .5pt;mso-border-left-alt:dashed windowtext .5pt;
  mso-border-alt:dashed windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'><o:p><%=D_ADMIN_PAY%></o:p></span></b></p>
  </td>
 </tr>
 <% } %>

 <tr style='mso-yfti-irow:12;mso-yfti-lastrow:yes;'>
  <td width=657 colspan=5 valign=top style='width:492.75pt;border:none;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify'><i style='mso-bidi-font-style:
  normal'><span style='font-size:8.0pt'>Все банковские расходы, связанные с
  оплатой страховой премии, оплачиваются Страхователем.<o:p></o:p></span></i></p>
  </td>
 </tr>
 <![if !supportMisalignedColumns]>
 <tr height=0>
  <td width=164 style='border:none'></td>
  <td width=155 style='border:none'></td>
  <td width=48 style='border:none'></td>
  <td width=168 style='border:none'></td>
  <td width=122 style='border:none'></td>
 </tr>
 <![endif]>
</table>

<p class=MsoNormal style='text-align:justify'><o:p>&nbsp;</o:p></p>

<% if (ROW_PRIL > 0) {%>

<p class=MsoNormal style='text-align:justify'><%=format.format(NUM_PP++)%>. Стороны договорились Приложение
№ 1<span style='color:blue'> </span>Договора изложить в следующей редакции:</p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;margin-left:-12.6pt;border-collapse:collapse;mso-yfti-tbllook:
 480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  page-break-inside:avoid'>
  <td width=626 valign=top style='width:469.2pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal><span style='mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ПРИЛОЖЕНИЕ № 1<o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><i
  style='mso-bidi-font-style:normal'><span style='font-size:9.0pt'>Является
  составной и неотъемлемой частью полиса № <span style='mso-spacerun:yes'> 
  </span><%=pol_ser_num%><o:p></o:p></span></i></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'>ТАБЛИЦА ВЫКУПНЫХ СУММ ПО<span
  style='mso-spacerun:yes'>  </span>ОСНОВНОЙ ПРОГРАММЕ <o:p></o:p></b></p>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:4.55pt'><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='margin-top:0cm;margin-right:4.55pt;margin-bottom:
0cm;margin-left:-12.45pt;margin-bottom:.0001pt;line-height:1.0pt;mso-line-height-rule:
exactly;tab-stops:77.4pt 176.4pt 243.75pt 329.4pt 456.6pt'><b style='mso-bidi-font-weight:
normal'><span style='font-size:8.0pt'><span style='mso-tab-count:4'>                                                                                                                                                        </span></span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
EN-US'><o:p></o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=626
 style='width:469.2pt;border-collapse:collapse;border:none;mso-border-alt:dash-small-gap windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt dash-small-gap windowtext;mso-border-insidev:.5pt dash-small-gap windowtext'>
 <thead>
  <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
   <td width=120 valign=top style='width:90.0pt;border:dashed windowtext 1.0pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ГОД
   ДЕЙСТВИЯ ДОГОВОРА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=132 valign=top style='width:99.0pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НОМЕР
   ПЕРИОДА</span></b><b style='mso-bidi-font-weight:normal'><span
   style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=90 valign=top style='width:67.35pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>НАЧАЛО</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=114 valign=top style='width:85.65pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ОКОНЧАНИЕ</span></b><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;mso-fareast-language:
   EN-US'><o:p></o:p></span></b></p>
   </td>
   <td width=170 valign=top style='width:127.2pt;border:dashed windowtext 1.0pt;
   border-left:none;mso-border-left-alt:dash-small-gap windowtext .5pt;
   mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
   <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><b
   style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt'>ВЫКУПНАЯ
   СУММА, <a name="currency_3">РУБ.</a></span></b><b style='mso-bidi-font-weight:
   normal'><span style='font-size:8.0pt;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
   </td>
  </tr>
 </thead>
 
 <rw:foreach id="G_VYK_SUMM" src="G_VYK_SUMM">
<rw:getValue id="N" src="N"/>
<rw:getValue id="YEAR_NUMBER" src="YEAR_NUMBER"/>
<rw:getValue id="PERIOD_START" src="PERIOD_START"/>
<rw:getValue id="PERIOD_END" src="PERIOD_END"/>
<rw:getValue id="RANSOM" src="RANSOM"/>
 
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:11.35pt'>
  <td width=120 style='width:90.0pt;border:dashed windowtext 1.0pt;border-top:
  none;mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-alt:dash-small-gap windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><%=N%></o:p></span></p>
  </td>
  <td width=132 style='width:99.0pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><%=YEAR_NUMBER%></o:p></span></p>
  </td>
  <td width=90 style='width:67.35pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><%=PERIOD_START%></o:p></span></p>
  </td>
  <td width=114 style='width:85.65pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><%=PERIOD_END%></o:p></span></p>
  </td>
  <td width=170 style='width:127.2pt;border-top:none;border-left:none;
  border-bottom:dashed windowtext 1.0pt;border-right:dashed windowtext 1.0pt;
  mso-border-top-alt:dash-small-gap windowtext .5pt;mso-border-left-alt:dash-small-gap windowtext .5pt;
  mso-border-alt:dash-small-gap windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:11.35pt'>
  <p class=MsoNormal align=center style='margin-right:4.55pt;text-align:center'><span
  style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-language:EN-US'><o:p><%=RANSOM%></o:p></span></p>
  </td>
 </tr>
</rw:foreach>     
</table>

<% } %>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<% if (!ADDENDUM_NOTE.equals("@")) { %>


<p class=MsoFooter style='margin-right:-.25pt;text-align:justify'><span
style='font-size:12.0pt;letter-spacing:-.1pt;mso-ansi-language:RU'><%=format.format(NUM_PP++)%>.Стороны
договорились дополнить п.8 Договора подпунктом 
<% if (S_DAT_VYZH == "X") {%>6<%} else {%>7<%}%> следующего содержания:<o:p></o:p></span></p>

<p class=MsoNormal><span style='letter-spacing:-.1pt'><span
style='mso-spacerun:yes'> </span>«<%=ADDENDUM_NOTE%>».</span></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<% } %>

<p class=MsoFooter style='margin-right:-.25pt;text-align:justify'><span
style='font-size:12.0pt;letter-spacing:-.1pt;mso-ansi-language:RU'><%=format.format(NUM_PP++)%>. Во всем остальном,
что не предусмотрено настоящим Дополнительным Соглашением Стороны
руководствуются положениями Договора, Правилами страхования жизни.<o:p></o:p></span></p>

<p class=MsoFooter style='margin-right:-.25pt;text-align:justify'><span
style='font-size:12.0pt;mso-ansi-language:RU'><%=format.format(NUM_PP++)%>. Настоящее Дополнительное
соглашение вступает в силу с момента подписания его Сторонами.<span
style='letter-spacing:-.1pt'><o:p></o:p></span></span></p>

<p class=MsoFooter style='margin-right:-.25pt;text-align:justify'><span
style='font-size:12.0pt;letter-spacing:-.1pt;mso-ansi-language:RU'><%=format.format(NUM_PP++)%>. Настоящее
Дополнительное соглашение является составной и неотъемлемой частью Договора
страхования № <%=pol_ser_num%> от <%=CONFIRM_DATE_ADDENDUM%>.<o:p></o:p></span></p>

<p class=MsoFooter style='margin-right:-.25pt;text-align:justify'><span
style='font-size:12.0pt;mso-fareast-font-family:SimSun;mso-ansi-language:RU;
mso-fareast-language:ZH-CN'><%=format.format(NUM_PP++)%>. Настоящее Дополнительное Соглашение</span><span
style='font-size:12.0pt;mso-ansi-language:RU'> подписано в двух экземплярах,
имеющих одинаковую силу, по одному экземпляру для каждой Стороны.<o:p></o:p></span></p>

<p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>

<table class=MsoTableGrid border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=372 valign=top style='width:279.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt'>СТРАХОВАТЕЛЬ</p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-right:-.25pt'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:-.25pt;margin-bottom:
  0cm;margin-left:3.6pt;margin-bottom:.0001pt'>____________________/<%=strax_fio_sokr%>/</p>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><span
  style='mso-spacerun:yes'>                                                                                                                    
  </span></p>
  </td>
  <td width=285 valign=top style='width:213.75pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='margin-right:-.25pt;text-align:justify'><o:p>&nbsp;</o:p></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

</div>

</rw:foreach>

</body>

</html>


</rw:report>
