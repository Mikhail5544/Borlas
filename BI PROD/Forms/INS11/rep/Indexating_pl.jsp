<%@ include file="/inc/header_msword.jsp" %> 
<%@ page contentType="text/html;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<%
  String is_first = new String("Y");             
%>

<rw:report id="report" > 

<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="Indexating_Pril" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="Indexating_Pril" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="POL_HEAD_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="SID" datatype="character" width="40" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select t2_1, t2_2, t2_3, t2_4, t2_5, policy_header_id from (select
row_number() over (partition by cs.POLICY_CASH_SURR_ID order by START_CASH_SURR_DATE) t2_1, -- номер периода
cs.INSURANCE_YEAR_NUMBER t2_2, -- годовщина
to_char(cs.START_CASH_SURR_DATE,'dd.mm.yyyy') t2_3, -- начало периода
to_char(cs.END_CASH_SURR_DATE,'dd.mm.yyyy') t2_4, -- окончание
to_char(cs.VALUE, 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') t2_5 -- выкупная сумма
, ph.policy_header_id, cs.START_CASH_SURR_DATE, pp.START_DATE 
from VEN_P_POL_HEADER ph,
     VEN_P_POLICY pp,
     VEN_POLICY_CASH_SURR pcs, 
     VEN_POLICY_CASH_SURR_D cs,
    (select distinct a.p_policy_id, pl.description, plt.presentation_desc plt_desc, pl.t_lob_line_id
     from as_asset a,
          p_asset_header pah,
          p_cover pc, 
          t_prod_line_option plo,
          t_product_line pl,
          t_product_line_type plt
     where pah.p_asset_header_id = a.p_asset_header_id
       and pc.as_asset_id = a.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and pl.id = plo.product_line_id
       and plt.product_line_type_id = pl.product_line_type_id
       and plt.presentation_desc = 'ОСН') tt
where pp.pol_header_id = ph.policy_header_id
  and tt.p_policy_id = pp.policy_id
  and pcs.policy_id = pp.policy_id
  and pcs.t_lob_line_id = tt.t_lob_line_id
  and cs.POLICY_CASH_SURR_ID = pcs.POLICY_CASH_SURR_ID
  and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING'
  and ph.policy_header_id = :id
order by cs.INSURANCE_YEAR_NUMBER, cs.START_CASH_SURR_DATE) temp
where temp.START_CASH_SURR_DATE >= temp.START_DATE]]>
      </select>
      <displayInfo x="3.93750" y="0.42725" width="0.69995" height="0.32983"/>
      <group name="G_2">
        <displayInfo x="3.81067" y="1.24182" width="1.09998" height="1.11426"
        />
        <dataItem name="policy_header_id1" oracleDatatype="number"
         columnOrder="18" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Header Id1">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="POLICY_HEADER_ID" order="6"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t2_1" oracleDatatype="number" columnOrder="13"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T2 1">
          <dataDescriptor
           expression="row_number ( ) over ( partition by cs.POLICY_CASH_SURR_ID order by START_CASH_SURR_DATE )"
           descriptiveExpression="T2_1" order="1" oracleDatatype="number"
           width="22" precision="38"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t2_2" oracleDatatype="number" columnOrder="14"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T2 2">
          <dataDescriptor expression="cs.INSURANCE_YEAR_NUMBER"
           descriptiveExpression="T2_2" order="2" oracleDatatype="number"
           width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t2_3" datatype="vchar2" columnOrder="15"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T2 3">
          <dataDescriptor
           expression="to_char ( cs.START_CASH_SURR_DATE , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="T2_3" order="3" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t2_4" datatype="vchar2" columnOrder="16"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T2 4">
          <dataDescriptor
           expression="to_char ( cs.END_CASH_SURR_DATE , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="T2_4" order="4" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t2_5" datatype="vchar2" columnOrder="17" width="15"
         defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T2 5">
          <dataDescriptor
           expression="to_char ( cs.VALUE , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="T2_5" order="5" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_2">
      <select>
      <![CDATA[select t3_1, t3_2, t3_3, t3_4, t3_5, policy_header_id from (select
row_number() over (partition by cs.POLICY_CASH_SURR_ID order by START_CASH_SURR_DATE) t3_1, -- номер периода
cs.INSURANCE_YEAR_NUMBER t3_2, -- годовщина
to_char(cs.START_CASH_SURR_DATE,'dd.mm.yyyy') t3_3, -- начало периода
to_char(cs.END_CASH_SURR_DATE,'dd.mm.yyyy') t3_4, -- окончание
to_char(cs.VALUE, 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') t3_5 -- выкупная сумма
,ph.policy_header_id, cs.START_CASH_SURR_DATE, pp.START_DATE 
from VEN_P_POL_HEADER ph,
     VEN_P_POLICY pp,
     VEN_POLICY_CASH_SURR pcs, 
     VEN_POLICY_CASH_SURR_D cs,
    (select distinct a.p_policy_id, pl.description, plt.presentation_desc plt_desc, pl.t_lob_line_id
     from as_asset a,
          p_asset_header pah,
          p_cover pc, 
          t_prod_line_option plo,
          t_product_line pl,
          t_product_line_type plt
     where pah.p_asset_header_id = a.p_asset_header_id
       and pc.as_asset_id = a.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and pl.id = plo.product_line_id
       and plt.product_line_type_id = pl.product_line_type_id
       and pl.description in ('ИНВЕСТ', 'ИНВЕСТ2')) tt
where pp.pol_header_id = ph.policy_header_id
  and tt.p_policy_id = pp.policy_id
  and pcs.policy_id = pp.policy_id
  and pcs.t_lob_line_id = tt.t_lob_line_id
  and cs.POLICY_CASH_SURR_ID = pcs.POLICY_CASH_SURR_ID
  and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING'
  and ph.policy_header_id = :id
order by cs.INSURANCE_YEAR_NUMBER, cs.START_CASH_SURR_DATE) temp
where temp.START_CASH_SURR_DATE >= temp.START_DATE]]>
      </select>
      <displayInfo x="5.70825" y="0.38538" width="0.69995" height="0.32983"/>
      <group name="G_3">
        <displayInfo x="5.74805" y="1.30420" width="1.09998" height="1.11426"
        />
        <dataItem name="policy_header_id2" oracleDatatype="number"
         columnOrder="24" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Header Id2">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="POLICY_HEADER_ID" order="6"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t3_1" oracleDatatype="number" columnOrder="19"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T3 1">
          <dataDescriptor
           expression="row_number ( ) over ( partition by cs.POLICY_CASH_SURR_ID order by START_CASH_SURR_DATE )"
           descriptiveExpression="T3_1" order="1" oracleDatatype="number"
           width="22" precision="38"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t3_2" oracleDatatype="number" columnOrder="20"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T3 2">
          <dataDescriptor expression="cs.INSURANCE_YEAR_NUMBER"
           descriptiveExpression="T3_2" order="2" oracleDatatype="number"
           width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t3_3" datatype="vchar2" columnOrder="21"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T3 3">
          <dataDescriptor
           expression="to_char ( cs.START_CASH_SURR_DATE , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="T3_3" order="3" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t3_4" datatype="vchar2" columnOrder="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T3 4">
          <dataDescriptor
           expression="to_char ( cs.END_CASH_SURR_DATE , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="T3_4" order="4" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t3_5" datatype="vchar2" columnOrder="23" width="15"
         defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T3 5">
          <dataDescriptor
           expression="to_char ( cs.VALUE , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="T3_5" order="5" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_3">
      <select>
      <![CDATA[select max(pl.description) t1_1, to_char(sum(pc.INS_AMOUNT), 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') t1_2, to_char(sum(pc.FEE), 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') t1_3, ph.policy_header_id
     from ven_p_pol_header ph,
          ven_p_policy pp,
          as_asset a,
          p_asset_header pah,
          p_cover pc, 
          t_prod_line_option plo,
          t_product_line pl,
          t_product_line_type plt
     where pp.pol_header_id = ph.policy_header_id
       and a.p_policy_id = pp.policy_id
       and pah.p_asset_header_id = a.p_asset_header_id
       and pc.as_asset_id = a.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and pl.id = plo.product_line_id
       and plt.product_line_type_id = pl.product_line_type_id
       and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING'
       and plt.presentation_desc = 'ДОП'
       and pl.description <> 'Административные издержки'
     group by pl.id, ph.policy_header_id 
     order by 1]]>
      </select>
      <displayInfo x="2.28125" y="0.44812" width="0.69995" height="0.32983"/>
      <group name="G_1">
        <displayInfo x="2.20605" y="1.06458" width="1.09998" height="0.77246"
        />
        <dataItem name="policy_header_id" oracleDatatype="number"
         columnOrder="28" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="Policy Header Id">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="POLICY_HEADER_ID" order="4"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t1_1" datatype="vchar2" columnOrder="25" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T1 1">
          <dataDescriptor expression="max ( pl.description )"
           descriptiveExpression="T1_1" order="1" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t1_2" datatype="vchar2" columnOrder="26" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T1 2">
          <dataDescriptor
           expression="to_char ( sum ( pc.INS_AMOUNT ) , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="T1_2" order="2" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="t1_3" datatype="vchar2" columnOrder="27" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="T1 3">
          <dataDescriptor
           expression="to_char ( sum ( pc.FEE ) , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="T1_3" order="3" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_0">
      <select>
      <![CDATA[    select ph.policy_header_id ID, decode(nvl(max(pp.MAILING),0),0,'B',1,'V') FLAG,
           to_char(sum(decode(pl.description, 'Административные издержки', 0, pc.FEE)), 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') P_18,
           to_char(sum(decode(pl.description, 'Административные издержки', pc.PREMIUM, 0)), 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') P_19,
           to_char(sum(decode(pl.description, 'Административные издержки', pc.PREMIUM, pc.FEE)), 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') P_03
    from p_pol_header ph,
         p_policy pp,
         NOTIF_LETTER_REP tt,
         as_asset a,
         p_asset_header pah,
         p_cover pc, 
         t_prod_line_option plo,
         t_product_line pl
    where pp.pol_header_id = ph.policy_header_id
      and ph.policy_header_id = tt.document_id
      and a.p_policy_id = pp.policy_id
      and pah.p_asset_header_id = a.p_asset_header_id
      and pc.as_asset_id = a.as_asset_id
      and plo.id = pc.t_prod_line_option_id
      and pl.id = plo.product_line_id
      and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING'
      and tt.SESSIONID = :SID
    group by ph.policy_header_id
    order by 2]]>
      </select>
      <displayInfo x="0.05200" y="2.42700" width="0.69995" height="0.19995"/>
      <group name="G_0">
        <displayInfo x="0.70630" y="2.94983" width="1.09998" height="0.77246"
        />
        <dataItem name="P_18" datatype="vchar2" columnOrder="31" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 18">
          <dataDescriptor
           expression="to_char ( sum ( decode ( pl.description , &apos;Административные издержки&apos; , 0 , pc.FEE ) ) , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="P_18" order="3" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_19" datatype="vchar2" columnOrder="32" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 19">
          <dataDescriptor
           expression="to_char ( sum ( decode ( pl.description , &apos;Административные издержки&apos; , pc.PREMIUM , 0 ) ) , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="P_19" order="4" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_03" datatype="vchar2" columnOrder="33" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 03">
          <dataDescriptor
           expression="to_char ( sum ( decode ( pl.description , &apos;Административные издержки&apos; , pc.PREMIUM , pc.FEE ) ) , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="P_03" order="5" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="ID" oracleDatatype="number" columnOrder="29"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Id">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="ID" order="1" oracleDatatype="number"
           width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="FLAG" datatype="vchar2" columnOrder="30" width="1"
         defaultWidth="10000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Flag">
          <dataDescriptor
           expression="decode ( nvl ( max ( pp.MAILING ) , 0 ) , 0 , &apos;B&apos; , 1 , &apos;V&apos; )"
           descriptiveExpression="FLAG" order="2" width="1"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_4">
      <select>
      <![CDATA[--определяем, есть ли в активной версии договора программа ИНВЕСТ
  select max(decode(pl.description, 'ИНВЕСТ','Y', 'ИНВЕСТ2','Y', 'N')) F_2,
         ph.policy_header_id
    from p_pol_header ph,
         p_policy pp,
         as_asset aa,
         p_cover pc,
         t_prod_line_option plo,
         t_product_line pl
    where pp.policy_id = ph.policy_id
      and aa.p_policy_id = pp.policy_id
      and pc.as_asset_id = aa.as_asset_id
      and plo.id = pc.t_prod_line_option_id
      and pl.id = plo.product_line_id
      group by ph.policy_header_id]]>
      </select>
      <displayInfo x="3.56262" y="2.47925" width="0.69995" height="0.32983"/>
      <group name="G_4">
        <displayInfo x="3.27478" y="3.05408" width="1.56714" height="0.60156"
        />
        <dataItem name="F_2" datatype="vchar2" columnOrder="34" width="1"
         defaultWidth="10000" defaultHeight="10000" columnFlags="1"
         defaultLabel="F 2">
          <dataDescriptor
           expression="decode ( count ( pl.id ) , 0 , &apos;N&apos; , &apos;Y&apos; )"
           descriptiveExpression="F_2" order="1" width="1"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="policy_header_id3" oracleDatatype="number"
         columnOrder="35" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Header Id3">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="POLICY_HEADER_ID" order="2" width="22"
           scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_5">
      <select>
      <![CDATA[--основная программа
select max(pl.description) P_14,
       to_char(sum(pc.INS_AMOUNT), 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') P_15,
       to_char(sum(pc.FEE), 'FM999G999G990D00','NLS_NUMERIC_CHARACTERS = '', ''') P_16,
       ph.policy_header_id
     from ven_p_pol_header ph,
          ven_p_policy pp,
          as_asset a,
          p_asset_header pah,
          p_cover pc, 
          t_prod_line_option plo,
          t_product_line pl,
          t_product_line_type plt
     where pp.pol_header_id = ph.policy_header_id
       and a.p_policy_id = pp.policy_id
       and pah.p_asset_header_id = a.p_asset_header_id
       and pc.as_asset_id = a.as_asset_id
       and plo.id = pc.t_prod_line_option_id
       and pl.id = plo.product_line_id
       and plt.product_line_type_id = pl.product_line_type_id
       and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING'
       and plt.presentation_desc = 'ОСН'
       group by ph.policy_header_id]]>
      </select>
      <displayInfo x="1.78113" y="4.45850" width="0.69995" height="0.32983"/>
      <group name="G_5">
        <displayInfo x="0.39966" y="5.12695" width="1.56714" height="0.94336"
        />
        <dataItem name="P_14" datatype="vchar2" columnOrder="36" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 14">
          <dataDescriptor expression="max ( pl.description )"
           descriptiveExpression="P_14" order="1" width="255"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_15" datatype="vchar2" columnOrder="37" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 15">
          <dataDescriptor
           expression="to_char ( sum ( pc.INS_AMOUNT ) , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="P_15" order="2" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_16" datatype="vchar2" columnOrder="38" width="15"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 16">
          <dataDescriptor
           expression="to_char ( sum ( pc.FEE ) , &apos;FM999G999G990D00&apos; , &apos;NLS_NUMERIC_CHARACTERS = &apos;&apos;, &apos;&apos;&apos; )"
           descriptiveExpression="P_16" order="3" width="15"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="policy_header_id4" oracleDatatype="number"
         columnOrder="39" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Header Id4">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="POLICY_HEADER_ID" order="4" width="22"
           scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_7">
      <select>
      <![CDATA[--реквизиты договора
select pp.num P_2,
       to_char(ph.start_date,'dd.mm.yyyy') P_3,
       '"'||to_char(sysdate,'dd')||'"'||substr(pkg_utils.date2genitive_case(sysdate),3) P_4,
       PKG_CONTACT.GET_FIO_CASE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id), 'И') P_5,
       PKG_CONTACT.GET_FIO_FMT(PKG_CONTACT.GET_FIO_CASE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id), 'И'),4) P_6,
       nvl(PKG_CONTACT.GET_IDENT_NUMBER(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id),'PASS_RF'),lpad('_',15,'_')) P_7,
       nvl(PKG_CONTACT.GET_IDENT_PLACE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id),'PASS_RF'),lpad('_',35,'_')) P_8,
       nvl(to_char(PKG_CONTACT.GET_IDENT_DATE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id),'PASS_RF'), 'dd.mm.yyyy'),lpad('_',10,'_')) P_9,
       to_char(PKG_CONTACT.GET_BIRTH_DATE(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id)), 'dd.mm.yyyy') P_10,
       PKG_CONTACT.GET_FIO_CASE(C.CONTACT_ID, 'И') P_11,
       to_char(PKG_CONTACT.GET_BIRTH_DATE(C.CONTACT_ID), 'dd.mm.yyyy') P_12,
       nvl(PKG_CONTACT.GET_IDENT_NUMBER(C.CONTACT_ID,'PASS_RF'),lpad('_',15,'_')) P_13_1,
       nvl(PKG_CONTACT.GET_IDENT_PLACE(C.CONTACT_ID,'PASS_RF'),lpad('_',35,'_')) P_13_2,
       nvl(to_char(PKG_CONTACT.GET_IDENT_DATE(C.CONTACT_ID,'PASS_RF'), 'dd.mm.yyyy'),lpad('_',10,'_')) P_13_3,
       'уплачивается ' || lower(PT.DESCRIPTION) P_17,
       nvl2(pp.VERSION_ORDER_NUM,'№ '||pp.VERSION_ORDER_NUM,pp.VERSION_ORDER_NUM) P_01,
       '"'||to_char(pp.START_DATE,'dd')||'"'||substr(pkg_utils.date2genitive_case(pp.START_DATE),3) P_02,
       --pkg_contact.get_address_region(pkg_contact.get_primary_address(PKG_POLICY.GET_POLICY_HOLDER_ID(pp.policy_id))) P_04_old,
      pkg_rep_utils.get_agency_to_PD4(pp.policy_id) P_04,
       ph.policy_header_id
from ven_p_pol_header ph,
     ven_p_policy pp,
     VEN_T_PAYMENT_TERMS PT,
     (select max(nvl(assured_contact_id, contact_id)) contact_id, p_policy_id from ven_as_assured group by p_policy_id) t,
     ven_contact c
where pp.pol_header_id = ph.policy_header_id
  and PT.ID = pp.PAYMENT_TERM_ID
  and T.P_POLICY_ID(+) = pp.policy_id
  and C.CONTACT_ID(+) = T.CONTACT_ID
  and doc.get_doc_status_brief(pp.policy_id) = 'INDEXATING']]>
      </select>
      <displayInfo x="5.20837" y="4.14575" width="0.69995" height="0.32983"/>
      <group name="G_7">
        <displayInfo x="4.87891" y="4.81458" width="1.56714" height="1.62695"
        />
        <dataItem name="P_2" datatype="vchar2" columnOrder="40" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 2">
          <dataDescriptor expression="pp.num" descriptiveExpression="P_2"
           order="1" width="100"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_3" datatype="vchar2" columnOrder="41"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 3">
          <dataDescriptor
           expression="to_char ( ph.start_date , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="P_3" order="2" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_4" datatype="vchar2" columnOrder="42" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 4">
          <dataDescriptor
           expression="&apos;&quot;&apos; || to_char ( sysdate , &apos;dd&apos; ) || &apos;&quot;&apos; || substr ( pkg_utils.date2genitive_case ( sysdate ) , 3 )"
           descriptiveExpression="P_4" order="3" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_5" datatype="vchar2" columnOrder="43" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 5">
          <dataDescriptor
           expression="PKG_CONTACT.GET_FIO_CASE ( PKG_POLICY.GET_POLICY_HOLDER_ID ( pp.policy_id ) , &apos;И&apos; )"
           descriptiveExpression="P_5" order="4" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_6" datatype="vchar2" columnOrder="44" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 6">
          <dataDescriptor
           expression="PKG_CONTACT.GET_FIO_FMT ( PKG_CONTACT.GET_FIO_CASE ( PKG_POLICY.GET_POLICY_HOLDER_ID ( pp.policy_id ) , &apos;И&apos; ) , 4 )"
           descriptiveExpression="P_6" order="5" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_7" datatype="vchar2" columnOrder="45" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 7">
          <dataDescriptor
           expression="nvl ( PKG_CONTACT.GET_IDENT_NUMBER ( PKG_POLICY.GET_POLICY_HOLDER_ID ( pp.policy_id ) , &apos;PASS_RF&apos; ) , lpad ( &apos;_&apos; , 15 , &apos;_&apos; ) )"
           descriptiveExpression="P_7" order="6" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_8" datatype="vchar2" columnOrder="46" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 8">
          <dataDescriptor
           expression="nvl ( PKG_CONTACT.GET_IDENT_PLACE ( PKG_POLICY.GET_POLICY_HOLDER_ID ( pp.policy_id ) , &apos;PASS_RF&apos; ) , lpad ( &apos;_&apos; , 35 , &apos;_&apos; ) )"
           descriptiveExpression="P_8" order="7" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_9" datatype="vchar2" columnOrder="47"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 9">
          <dataDescriptor
           expression="nvl ( to_char ( PKG_CONTACT.GET_IDENT_DATE ( PKG_POLICY.GET_POLICY_HOLDER_ID ( pp.policy_id ) , &apos;PASS_RF&apos; ) , &apos;dd.mm.yyyy&apos; ) , lpad ( &apos;_&apos; , 10 , &apos;_&apos; ) )"
           descriptiveExpression="P_9" order="8" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_10" datatype="vchar2" columnOrder="48"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 10">
          <dataDescriptor
           expression="to_char ( PKG_CONTACT.GET_BIRTH_DATE ( PKG_POLICY.GET_POLICY_HOLDER_ID ( pp.policy_id ) ) , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="P_10" order="9" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_11" datatype="vchar2" columnOrder="49" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 11">
          <dataDescriptor
           expression="PKG_CONTACT.GET_FIO_CASE ( C.CONTACT_ID , &apos;И&apos; )"
           descriptiveExpression="P_11" order="10" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_12" datatype="vchar2" columnOrder="50"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 12">
          <dataDescriptor
           expression="to_char ( PKG_CONTACT.GET_BIRTH_DATE ( C.CONTACT_ID ) , &apos;dd.mm.yyyy&apos; )"
           descriptiveExpression="P_12" order="11" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_13_1" datatype="vchar2" columnOrder="51"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="P 13 1">
          <dataDescriptor
           expression="nvl ( PKG_CONTACT.GET_IDENT_NUMBER ( C.CONTACT_ID , &apos;PASS_RF&apos; ) , lpad ( &apos;_&apos; , 15 , &apos;_&apos; ) )"
           descriptiveExpression="P_13_1" order="12" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_13_2" datatype="vchar2" columnOrder="52"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="P 13 2">
          <dataDescriptor
           expression="nvl ( PKG_CONTACT.GET_IDENT_PLACE ( C.CONTACT_ID , &apos;PASS_RF&apos; ) , lpad ( &apos;_&apos; , 35 , &apos;_&apos; ) )"
           descriptiveExpression="P_13_2" order="13" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_13_3" datatype="vchar2" columnOrder="53"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 13 3">
          <dataDescriptor
           expression="nvl ( to_char ( PKG_CONTACT.GET_IDENT_DATE ( C.CONTACT_ID , &apos;PASS_RF&apos; ) , &apos;dd.mm.yyyy&apos; ) , lpad ( &apos;_&apos; , 10 , &apos;_&apos; ) )"
           descriptiveExpression="P_13_3" order="14" width="10"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_17" datatype="vchar2" columnOrder="54" width="513"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 17">
          <dataDescriptor
           expression="&apos;уплачивается &apos; || lower ( PT.DESCRIPTION )"
           descriptiveExpression="P_17" order="15" width="513"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_01" datatype="vchar2" columnOrder="55" width="42"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 01">
          <dataDescriptor
           expression="nvl2 ( pp.VERSION_ORDER_NUM , &apos;№ &apos; || pp.VERSION_ORDER_NUM , pp.VERSION_ORDER_NUM )"
           descriptiveExpression="P_01" order="16" width="42"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_02" datatype="vchar2" columnOrder="56" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 02">
          <dataDescriptor
           expression="&apos;&quot;&apos; || to_char ( pp.START_DATE , &apos;dd&apos; ) || &apos;&quot;&apos; || substr ( pkg_utils.date2genitive_case ( pp.START_DATE ) , 3 )"
           descriptiveExpression="P_02" order="17" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="P_04" datatype="vchar2" columnOrder="57" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P 04">
          <dataDescriptor
           expression="pkg_rep_utils.get_agency_to_PD4 ( pp.policy_id )"
           descriptiveExpression="P_04" order="18" width="4000"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
        <dataItem name="policy_header_id6" oracleDatatype="number"
         columnOrder="58" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Header Id6">
          <dataDescriptor expression="ph.policy_header_id"
           descriptiveExpression="POLICY_HEADER_ID" order="19"
           oracleDatatype="number" width="22" scale="-127"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_0" parentColumn="ID" childQuery="Q_3"
     childColumn="policy_header_id" condition="eq" sqlClause="where"/>
    <link name="L_2" parentGroup="G_0" parentColumn="ID" childQuery="Q_1"
     childColumn="policy_header_id1" condition="eq" sqlClause="where"/>
    <link name="L_3" parentGroup="G_0" parentColumn="ID" childQuery="Q_2"
     childColumn="policy_header_id2" condition="eq" sqlClause="where"/>
    <link name="L_4" parentGroup="G_0" parentColumn="ID" childQuery="Q_4"
     childColumn="policy_header_id3" condition="eq" sqlClause="where"/>
    <link name="L_5" parentGroup="G_0" parentColumn="ID" childQuery="Q_5"
     childColumn="policy_header_id4" condition="eq" sqlClause="where"/>
    <link name="L_6" parentGroup="G_0" parentColumn="ID" childQuery="Q_7"
     childColumn="policy_header_id6" condition="eq" sqlClause="where"/>
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
<link rel=File-List href="<%=g_ImagesRoot%>/Pril_B.files/filelist.xml">
<link rel=Edit-Time-Data href="<%=g_ImagesRoot%>/Pril_B.files/editdata.mso">
<!--[if !mso]>
<style>
v\:* {behavior:url(#default#VML);}
o\:* {behavior:url(#default#VML);}
w\:* {behavior:url(#default#VML);}
.shape {behavior:url(#default#VML);}
</style>
<![endif]-->
<title>Дополнительное соглашение по условиям индексации премии № </title>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>pavel.ikonopiscev</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>s.sizon</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>78</o:TotalTime>
  <o:LastPrinted>2008-12-30T09:56:00Z</o:LastPrinted>
  <o:Created>2009-03-30T18:09:00Z</o:Created>
  <o:LastSaved>2009-03-30T18:09:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>1694</o:Words>
  <o:Characters>9659</o:Characters>
  <o:Lines>80</o:Lines>
  <o:Paragraphs>22</o:Paragraphs>
  <o:CharactersWithSpaces>11331</o:CharactersWithSpaces>
  <o:Version>11.9999</o:Version>
 </o:DocumentProperties>
 <o:OfficeDocumentSettings>
  <o:RelyOnVML/>
  <o:AllowPNG/>
 </o:OfficeDocumentSettings>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:WordDocument>
  <w:View>Print</w:View>
  <w:Zoom>108</w:Zoom>
  <w:PunctuationKerning/>
  <w:DrawingGridHorizontalSpacing>6 пт</w:DrawingGridHorizontalSpacing>
  <w:DisplayHorizontalDrawingGridEvery>2</w:DisplayHorizontalDrawingGridEvery>
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
   <w:SplitPgBreakAndParaMark/>
   <w:DontVertAlignCellWithSp/>
   <w:DontBreakConstrainedForcedTables/>
   <w:DontVertAlignInTxbx/>
   <w:Word11KerningPairs/>
   <w:CachedColBalance/>
  </w:Compatibility>
  <w:BrowserLevel>MicrosoftInternetExplorer4</w:BrowserLevel>
  <w:TrackMoves>false</w:TrackMoves>
  <w:TrackFormatting/>
  <w:DoNotPromoteQF/>
  <w:LidThemeOther>RU</w:LidThemeOther>
  <w:LidThemeAsian>X-NONE</w:LidThemeAsian>
  <w:LidThemeComplexScript>X-NONE</w:LidThemeComplexScript>
  <m:mathPr>
   <m:mathFont m:val="Cambria Math"/>
   <m:brkBin m:val="before"/>
   <m:brkBinSub m:val="--"/>
   <m:smallFrac m:val="off"/>
   <m:dispDef/>
   <m:lMargin m:val="0"/>
   <m:rMargin m:val="0"/>
   <m:defJc m:val="centerGroup"/>
   <m:wrapIndent m:val="1440"/>
   <m:intLim m:val="subSup"/>
   <m:naryLim m:val="undOvr"/>
  </m:mathPr>
 </w:WordDocument>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <w:LatentStyles DefLockedState="false" LatentStyleCount="156">
 </w:LatentStyles>
</xml><![endif]-->
<style>
<!--p.MSONORMAL
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
li.MSONORMAL
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
div.MSONORMAL
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
h1
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-fareast-theme-font:minor-fareast;}
h2
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-fareast-theme-font:minor-fareast;}
h3
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-fareast-theme-font:minor-fareast;}
h4
	{mso-style-unhide:no;
	mso-style-qformat:yes;
	mso-fareast-theme-font:minor-fareast;}
p.MSOTOC1
	{mso-style-unhide:no;}
li.MSOTOC1
	{mso-style-unhide:no;}
div.MSOTOC1
	{mso-style-unhide:no;}
p.MSOTOC2
	{mso-style-unhide:no;}
li.MSOTOC2
	{mso-style-unhide:no;}
div.MSOTOC2
	{mso-style-unhide:no;}
p.MSOTOC3
	{mso-style-unhide:no;}
li.MSOTOC3
	{mso-style-unhide:no;}
div.MSOTOC3
	{mso-style-unhide:no;}
p.MSONORMALINDENT
	{mso-style-unhide:no;}
li.MSONORMALINDENT
	{mso-style-unhide:no;}
div.MSONORMALINDENT
	{mso-style-unhide:no;}
p.MSOFOOTNOTETEXT
	{mso-style-unhide:no;}
li.MSOFOOTNOTETEXT
	{mso-style-unhide:no;}
div.MSOFOOTNOTETEXT
	{mso-style-unhide:no;}
p.MSOCOMMENTTEXT
	{mso-style-unhide:no;}
li.MSOCOMMENTTEXT
	{mso-style-unhide:no;}
div.MSOCOMMENTTEXT
	{mso-style-unhide:no;}
p.MSOHEADER
	{mso-style-unhide:no;}
li.MSOHEADER
	{mso-style-unhide:no;}
div.MSOHEADER
	{mso-style-unhide:no;}
p.MSOFOOTER
	{mso-style-unhide:no;}
li.MSOFOOTER
	{mso-style-unhide:no;}
div.MSOFOOTER
	{mso-style-unhide:no;}
p.MSOCAPTION
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
li.MSOCAPTION
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
div.MSOCAPTION
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
p.MSOLISTNUMBER
	{mso-style-unhide:no;}
li.MSOLISTNUMBER
	{mso-style-unhide:no;}
div.MSOLISTNUMBER
	{mso-style-unhide:no;}
p.MSOTITLE
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
li.MSOTITLE
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
div.MSOTITLE
	{mso-style-unhide:no;
	mso-style-qformat:yes;}
p.MSOBODYTEXT
	{mso-style-unhide:no;}
li.MSOBODYTEXT
	{mso-style-unhide:no;}
div.MSOBODYTEXT
	{mso-style-unhide:no;}
p.MSOBODYTEXTINDENT
	{mso-style-unhide:no;}
li.MSOBODYTEXTINDENT
	{mso-style-unhide:no;}
div.MSOBODYTEXTINDENT
	{mso-style-unhide:no;}
a:link
	{mso-style-unhide:no;}
span.MSOHYPERLINK
	{mso-style-unhide:no;}
a:visited
	{mso-style-unhide:no;}
span.MSOHYPERLINKFOLLOWED
	{mso-style-unhide:no;}
p.MSODOCUMENTMAP
	{mso-style-unhide:no;}
li.MSODOCUMENTMAP
	{mso-style-unhide:no;}
div.MSODOCUMENTMAP
	{mso-style-unhide:no;}
p.MSOCOMMENTSUBJECT
	{mso-style-unhide:no;}
li.MSOCOMMENTSUBJECT
	{mso-style-unhide:no;}
div.MSOCOMMENTSUBJECT
	{mso-style-unhide:no;}
p.MSOACETATE
	{mso-style-unhide:no;}
li.MSOACETATE
	{mso-style-unhide:no;}
div.MSOACETATE
	{mso-style-unhide:no;}
p.MSOLISTPARAGRAPH
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
li.MSOLISTPARAGRAPH
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
div.MSOLISTPARAGRAPH
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
p.MSOLISTPARAGRAPHCXSPFIRST
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
li.MSOLISTPARAGRAPHCXSPFIRST
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
div.MSOLISTPARAGRAPHCXSPFIRST
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
p.MSOLISTPARAGRAPHCXSPMIDDLE
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
li.MSOLISTPARAGRAPHCXSPMIDDLE
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
div.MSOLISTPARAGRAPHCXSPMIDDLE
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
p.MSOLISTPARAGRAPHCXSPLAST
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
li.MSOLISTPARAGRAPHCXSPLAST
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
div.MSOLISTPARAGRAPHCXSPLAST
	{mso-style-priority:34;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
p.MSOTOCHEADING
	{mso-style-priority:39;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
li.MSOTOCHEADING
	{mso-style-priority:39;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
div.MSOTOCHEADING
	{mso-style-priority:39;
	mso-style-unhide:no;
	mso-style-qformat:yes;}
span.1
	{mso-style-unhide:no;
	mso-ascii-theme-font:major-latin;
	mso-fareast-theme-font:major-fareast;
	mso-hansi-theme-font:major-latin;
	mso-bidi-theme-font:major-bidi;
	mso-themecolor:accent1;
	mso-themeshade:191;}
span.2
	{mso-style-unhide:no;
	mso-ascii-theme-font:major-latin;
	mso-fareast-theme-font:major-fareast;
	mso-hansi-theme-font:major-latin;
	mso-bidi-theme-font:major-bidi;
	mso-themecolor:accent1;}
span.3
	{mso-style-unhide:no;
	mso-ascii-theme-font:major-latin;
	mso-fareast-theme-font:major-fareast;
	mso-hansi-theme-font:major-latin;
	mso-bidi-theme-font:major-bidi;
	mso-themecolor:accent1;}
span.4
	{mso-style-unhide:no;
	mso-ascii-theme-font:major-latin;
	mso-fareast-theme-font:major-fareast;
	mso-hansi-theme-font:major-latin;
	mso-bidi-theme-font:major-bidi;
	mso-themecolor:accent1;}
span.A
	{mso-style-unhide:no;}
span.A0
	{mso-style-unhide:no;}
span.A1
	{mso-style-unhide:no;}
span.A2
	{mso-style-unhide:no;}
span.A3
	{mso-style-unhide:no;
	mso-ascii-theme-font:major-latin;
	mso-fareast-theme-font:major-fareast;
	mso-hansi-theme-font:major-latin;
	mso-bidi-theme-font:major-bidi;
	mso-themecolor:text2;
	mso-themeshade:191;}
span.A4
	{mso-style-unhide:no;}
span.A5
	{mso-style-unhide:no;}
span.A6
	{mso-style-unhide:no;}
span.A7
	{mso-style-unhide:no;}
span.A8
	{mso-style-unhide:no;}
p.20
	{mso-style-unhide:no;}
li.20
	{mso-style-unhide:no;}
div.20
	{mso-style-unhide:no;}
p.A9
	{mso-style-unhide:no;}
li.A9
	{mso-style-unhide:no;}
div.A9
	{mso-style-unhide:no;}
p.AA
	{mso-style-unhide:no;}
li.AA
	{mso-style-unhide:no;}
div.AA
	{mso-style-unhide:no;}
p.TABLETEXT
	{mso-style-unhide:no;}
li.TABLETEXT
	{mso-style-unhide:no;}
div.TABLETEXT
	{mso-style-unhide:no;}
p.TABLEHEADING
	{mso-style-unhide:no;}
li.TABLEHEADING
	{mso-style-unhide:no;}
div.TABLEHEADING
	{mso-style-unhide:no;}
p.200
	{mso-style-unhide:no;}
li.200
	{mso-style-unhide:no;}
div.200
	{mso-style-unhide:no;}
p.10
	{mso-style-unhide:no;}
li.10
	{mso-style-unhide:no;}
div.10
	{mso-style-unhide:no;}
p.4CHARCHAR
	{mso-style-unhide:no;}
li.4CHARCHAR
	{mso-style-unhide:no;}
div.4CHARCHAR
	{mso-style-unhide:no;}
p.AB
	{mso-style-unhide:no;}
li.AB
	{mso-style-unhide:no;}
div.AB
	{mso-style-unhide:no;}
p.AC
	{mso-style-unhide:no;}
li.AC
	{mso-style-unhide:no;}
div.AC
	{mso-style-unhide:no;}
p.OAENOCAEEAIEY
	{mso-style-unhide:no;}
li.OAENOCAEEAIEY
	{mso-style-unhide:no;}
div.OAENOCAEEAIEY
	{mso-style-unhide:no;}
p.MSONORMALCXSPMIDDLE
	{mso-style-unhide:no;}
li.MSONORMALCXSPMIDDLE
	{mso-style-unhide:no;}
div.MSONORMALCXSPMIDDLE
	{mso-style-unhide:no;}
p.MSONORMALCXSPLAST
	{mso-style-unhide:no;}
li.MSONORMALCXSPLAST
	{mso-style-unhide:no;}
div.MSONORMALCXSPLAST
	{mso-style-unhide:no;}
span.13
	{mso-style-unhide:no;}
span.21
	{mso-style-unhide:no;}
span.31
	{mso-style-unhide:no;}
span.41
	{mso-style-unhide:no;}
span.11
	{mso-style-unhide:no;}
span.12
	{mso-style-unhide:no;}
span.14
	{mso-style-unhide:no;}
span.15
	{mso-style-unhide:no;}
span.16
	{mso-style-unhide:no;}
span.5
	{mso-style-unhide:no;}
span.17
	{mso-style-unhide:no;}
span.18
	{mso-style-unhide:no;}
span.19
	{mso-style-unhide:no;}
span.1A
	{mso-style-unhide:no;}
.MSOCHPDEFAULT
	{mso-default-props:yes;}
table.MSONORMALTABLE
	{mso-style-priority:99;
	mso-style-qformat:yes;}
table.MSOTABLEGRID
	{mso-style-unhide:no;}
table.TABLENORMAL
	{mso-style-unhide:no;}
table.1B
	{mso-style-unhide:no;}

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
	{font-family:Garamond;
	panose-1:2 2 4 4 3 3 1 1 8 3;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:Calibri;
	mso-font-alt:"Century Gothic";
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:-1610611985 1073750139 0 0 159 0;}
@font-face
	{font-family:PragmaticaCTT;
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:"Times New Roman";
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:auto;
	mso-font-signature:0 0 0 0 0 0;}
@font-face
	{font-family:Physics;
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:"Times New Roman";
	mso-font-charset:0;
	mso-generic-font-family:roman;
	mso-font-format:other;
	mso-font-pitch:auto;
	mso-font-signature:0 0 0 0 0 0;}
@font-face
	{font-family:Cambria;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:-1610611985 1073741899 0 0 159 0;}
@font-face
	{font-family:"MS Sans Serif";
	panose-1:0 0 0 0 0 0 0 0 0 0;
	mso-font-alt:Arial;
	mso-font-charset:0;
	mso-generic-font-family:swiss;
	mso-font-format:other;
	mso-font-pitch:variable;
	mso-font-signature:3 0 0 0 1 0;}
@font-face
	{font-family:Verdana;
	panose-1:2 11 6 4 3 5 4 4 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:536871559 0 0 0 415 0;}
@font-face
	{font-family:"Book Antiqua";
	panose-1:2 4 6 2 5 3 5 3 3 4;
	mso-font-charset:204;
	mso-generic-font-family:roman;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
@font-face
	{font-family:"Arial Narrow";
	panose-1:2 11 5 6 2 2 2 3 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
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
h1
	{mso-style-update:auto;
	mso-style-link:"Заголовок 1 Знак";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:18.0pt;
	text-indent:-18.0pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:1;
	mso-list:l1 level1 lfo2;
	tab-stops:list 36.0pt;
	font-size:16.0pt;
	font-family:Arial;
	mso-font-kerning:16.0pt;}
h2
	{mso-style-link:"Заголовок 2 Знак";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:55.8pt;
	text-indent:-21.6pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	mso-list:l1 level2 lfo2;
	tab-stops:list 72.9pt;
	font-size:14.0pt;
	font-family:Arial;
	font-style:italic;}
h3
	{mso-style-link:"Заголовок 3 Знак";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:3;
	font-size:13.0pt;
	font-family:Arial;}
h4
	{mso-style-link:"Заголовок 4 Знак";
	mso-style-next:Обычный;
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:4;
	font-size:14.0pt;
	font-family:"Times New Roman";}
p.MsoToc1, li.MsoToc1, div.MsoToc1
	{mso-style-update:auto;
	mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoToc2, li.MsoToc2, div.MsoToc2
	{mso-style-update:auto;
	mso-style-next:Обычный;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:12.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoToc3, li.MsoToc3, div.MsoToc3
	{mso-style-update:auto;
	mso-style-next:Обычный;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:24.0pt;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoNormalIndent, li.MsoNormalIndent, div.MsoNormalIndent
	{margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:14.2pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:1.0cm;
	mso-pagination:widow-orphan;
	tab-stops:list 60.55pt;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;
	mso-ansi-language:EN-GB;}
p.MsoFootnoteText, li.MsoFootnoteText, div.MsoFootnoteText
	{mso-style-noshow:yes;
	mso-style-link:"Текст сноски Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;}
p.MsoCommentText, li.MsoCommentText, div.MsoCommentText
	{mso-style-noshow:yes;
	mso-style-link:"Текст примечания Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoHeader, li.MsoHeader, div.MsoHeader
	{mso-style-noshow:yes;
	mso-style-link:"Верхний колонтитул Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoFooter, li.MsoFooter, div.MsoFooter
	{mso-style-link:"Нижний колонтитул Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	tab-stops:center 233.85pt right 467.75pt;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoCaption, li.MsoCaption, div.MsoCaption
	{mso-style-next:Обычный;
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;}
p.MsoListNumber, li.MsoListNumber, div.MsoListNumber
	{margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	text-align:center;
	text-indent:-18.0pt;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt list 36.0pt;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;
	text-transform:uppercase;
	font-weight:bold;
	mso-bidi-font-weight:normal;
	font-style:italic;
	mso-bidi-font-style:normal;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{mso-style-link:"Название Знак";
	margin-top:70.85pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:none;
	tab-stops:334.45pt;
	layout-grid-mode:char;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";}
p.MsoBodyText, li.MsoBodyText, div.MsoBodyText
	{mso-style-link:"Основной текст Знак";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.MsoBodyTextIndent, li.MsoBodyTextIndent, div.MsoBodyTextIndent
	{mso-style-link:"Основной текст с отступом Знак";
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:42.55pt;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt list 78.55pt;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;
	mso-ansi-language:EN-GB;}
a:link, span.MsoHyperlink
	{color:#993300;
	text-decoration:underline;
	text-underline:single;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;
	text-underline:single;}
p.MsoDocumentMap, li.MsoDocumentMap, div.MsoDocumentMap
	{mso-style-noshow:yes;
	mso-style-link:"Схема документа Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	background:navy;
	font-size:10.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
p.MsoCommentSubject, li.MsoCommentSubject, div.MsoCommentSubject
	{mso-style-noshow:yes;
	mso-style-parent:"Текст примечания";
	mso-style-link:"Тема примечания Знак";
	mso-style-next:"Текст примечания";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;}
p.MsoAcetate, li.MsoAcetate, div.MsoAcetate
	{mso-style-noshow:yes;
	mso-style-link:"Текст выноски Знак";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:8.0pt;
	font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";}
span.1
	{mso-style-name:"Заголовок 1 Знак";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 1";
	mso-ansi-font-size:14.0pt;
	mso-bidi-font-size:14.0pt;
	font-family:Cambria;
	mso-ascii-font-family:Cambria;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Cambria;
	mso-bidi-font-family:"Times New Roman";
	color:#365F91;
	font-weight:bold;}
span.21
	{mso-style-name:"Заголовок 2 Знак1";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 2";
	mso-ansi-font-size:14.0pt;
	mso-bidi-font-size:14.0pt;
	font-family:Arial;
	mso-ascii-font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	mso-fareast-language:RU;
	font-weight:bold;
	font-style:italic;}
span.31
	{mso-style-name:"Заголовок 3 Знак1";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 3";
	mso-ansi-font-size:13.0pt;
	mso-bidi-font-size:13.0pt;
	font-family:Arial;
	mso-ascii-font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	mso-fareast-language:RU;
	font-weight:bold;}
span.41
	{mso-style-name:"Заголовок 4 Знак1";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 4";
	mso-ansi-font-size:14.0pt;
	mso-bidi-font-size:14.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;
	font-weight:bold;}
span.10
	{mso-style-name:"Текст сноски Знак1";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Текст сноски";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	color:black;
	mso-fareast-language:RU;}
span.11
	{mso-style-name:"Текст примечания Знак1";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Текст примечания";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.12
	{mso-style-name:"Верхний колонтитул Знак1";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Верхний колонтитул";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.13
	{mso-style-name:"Нижний колонтитул Знак1";
	mso-style-locked:yes;
	mso-style-link:"Нижний колонтитул";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.14
	{mso-style-name:"Название Знак1";
	mso-style-locked:yes;
	mso-style-link:Название;
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"MS Sans Serif";
	mso-ascii-font-family:"MS Sans Serif";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"MS Sans Serif";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
span.a
	{mso-style-name:"Основной текст Знак";
	mso-style-locked:yes;
	mso-style-link:"Основной текст";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;}
span.15
	{mso-style-name:"Основной текст с отступом Знак1";
	mso-style-locked:yes;
	mso-style-link:"Основной текст с отступом";
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	color:black;
	mso-ansi-language:EN-GB;
	mso-fareast-language:RU;}
span.16
	{mso-style-name:"Схема документа Знак1";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Схема документа";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Tahoma;
	mso-ascii-font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Tahoma;
	mso-bidi-font-family:Tahoma;
	background:navy;
	mso-fareast-language:RU;}
span.17
	{mso-style-name:"Тема примечания Знак1";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-parent:"Текст примечания Знак1";
	mso-style-link:"Тема примечания";
	mso-ansi-font-size:10.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;
	font-weight:bold;}
span.18
	{mso-style-name:"Текст выноски Знак1";
	mso-style-noshow:yes;
	mso-style-locked:yes;
	mso-style-link:"Текст выноски";
	mso-ansi-font-size:8.0pt;
	mso-bidi-font-size:8.0pt;
	font-family:Tahoma;
	mso-ascii-font-family:Tahoma;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Tahoma;
	mso-bidi-font-family:Tahoma;
	mso-fareast-language:RU;}
p.msolistparagraph, li.msolistparagraph, div.msolistparagraph
	{mso-style-name:msolistparagraph;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-add-space:auto;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.msolistparagraphCxSpFirst, li.msolistparagraphCxSpFirst, div.msolistparagraphCxSpFirst
	{mso-style-name:msolistparagraphCxSpFirst;
	mso-style-type:export-only;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-add-space:auto;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.msolistparagraphCxSpMiddle, li.msolistparagraphCxSpMiddle, div.msolistparagraphCxSpMiddle
	{mso-style-name:msolistparagraphCxSpMiddle;
	mso-style-type:export-only;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-add-space:auto;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.msolistparagraphCxSpLast, li.msolistparagraphCxSpLast, div.msolistparagraphCxSpLast
	{mso-style-name:msolistparagraphCxSpLast;
	mso-style-type:export-only;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:36.0pt;
	margin-bottom:.0001pt;
	mso-add-space:auto;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.msotocheading, li.msotocheading, div.msotocheading
	{mso-style-name:msotocheading;
	mso-style-parent:"Заголовок 1";
	mso-style-next:Обычный;
	margin-top:24.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	line-height:115%;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	font-size:14.0pt;
	font-family:Cambria;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	color:#365F91;
	mso-fareast-language:EN-US;
	font-weight:bold;}
p.2, li.2, div.2
	{mso-style-name:"Стиль Заголовок 2 + Междустр\.интервал\:  полуторный";
	mso-style-update:auto;
	mso-style-parent:"Заголовок 2";
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:55.8pt;
	text-indent:-21.6pt;
	line-height:150%;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	mso-list:l1 level2 lfo2;
	tab-stops:list 72.9pt;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	font-weight:bold;
	font-style:italic;}
p.a0, li.a0, div.a0
	{mso-style-name:"Стиль Междустр\.интервал\:  полуторный";
	mso-style-update:auto;
	margin:0cm;
	margin-bottom:.0001pt;
	line-height:150%;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a1, li.a1, div.a1
	{mso-style-name:"Знак Знак Знак Знак Знак Знак Знак";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:8.0pt;
	margin-left:0cm;
	line-height:12.0pt;
	mso-line-height-rule:exactly;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:Verdana;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
p.TableText, li.TableText, div.TableText
	{mso-style-name:"Table Text";
	margin:0cm;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan lines-together;
	font-size:8.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Book Antiqua";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;}
p.TableHeading, li.TableHeading, div.TableHeading
	{mso-style-name:"Table Heading";
	mso-style-parent:"Table Text";
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:6.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan lines-together;
	font-size:8.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Book Antiqua";
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	font-weight:bold;
	mso-bidi-font-weight:normal;}
p.200, li.200, div.200
	{mso-style-name:"Стиль Заголовок 2 + Слева\:  0 см Первая строка\:  0 см";
	mso-style-parent:"Заголовок 2";
	margin-top:12.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:14.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	font-weight:bold;
	font-style:italic;}
p.19, li.19, div.19
	{mso-style-name:Обычный1;
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:14.2pt;
	margin-bottom:.0001pt;
	text-align:justify;
	text-indent:1.0cm;
	mso-pagination:widow-orphan;
	tab-stops:14.2pt list 78.55pt;
	font-size:11.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	color:black;}
p.4CharChar, li.4CharChar, div.4CharChar
	{mso-style-name:"Знак4 Знак Знак Char Char Знак Знак Знак";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:8.0pt;
	margin-left:0cm;
	line-height:12.0pt;
	mso-line-height-rule:exactly;
	mso-pagination:widow-orphan;
	font-size:10.0pt;
	font-family:Verdana;
	mso-fareast-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;}
p.a2, li.a2, div.a2
	{mso-style-name:"Текст таблицы";
	margin-top:0cm;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:1.7pt;
	margin-bottom:.0001pt;
	text-align:justify;
	mso-pagination:widow-orphan;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.a3, li.a3, div.a3
	{mso-style-name:"Шапка таблицы";
	mso-style-next:"Текст таблицы";
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:3.0pt;
	margin-left:0cm;
	text-align:justify;
	mso-pagination:widow-orphan lines-together;
	page-break-after:avoid;
	font-size:9.0pt;
	mso-bidi-font-size:10.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	font-weight:bold;
	mso-bidi-font-weight:normal;}
p.oaenocaeeaiey, li.oaenocaeeaiey, div.oaenocaeeaiey
	{mso-style-name:oaenocaeeaiey;
	mso-margin-top-alt:auto;
	margin-right:0cm;
	mso-margin-bottom-alt:auto;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.msonormalcxspmiddle, li.msonormalcxspmiddle, div.msonormalcxspmiddle
	{mso-style-name:msonormalcxspmiddle;
	mso-margin-top-alt:auto;
	margin-right:0cm;
	mso-margin-bottom-alt:auto;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
p.msonormalcxsplast, li.msonormalcxsplast, div.msonormalcxsplast
	{mso-style-name:msonormalcxsplast;
	mso-margin-top-alt:auto;
	margin-right:0cm;
	mso-margin-bottom-alt:auto;
	margin-left:0cm;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";}
span.20
	{mso-style-name:"Заголовок 2 Знак";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 2";
	mso-ansi-font-size:13.0pt;
	mso-bidi-font-size:13.0pt;
	font-family:Cambria;
	mso-ascii-font-family:Cambria;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Cambria;
	mso-bidi-font-family:"Times New Roman";
	color:#4F81BD;
	font-weight:bold;}
span.3
	{mso-style-name:"Заголовок 3 Знак";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 3";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:Cambria;
	mso-ascii-font-family:Cambria;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Cambria;
	mso-bidi-font-family:"Times New Roman";
	color:#4F81BD;
	font-weight:bold;}
span.4
	{mso-style-name:"Заголовок 4 Знак";
	mso-style-locked:yes;
	mso-style-link:"Заголовок 4";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:Cambria;
	mso-ascii-font-family:Cambria;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Cambria;
	mso-bidi-font-family:"Times New Roman";
	color:#4F81BD;
	font-weight:bold;
	font-style:italic;}
span.a4
	{mso-style-name:"Текст сноски Знак";
	mso-style-locked:yes;
	mso-style-link:"Текст сноски";}
span.a5
	{mso-style-name:"Текст примечания Знак";
	mso-style-locked:yes;
	mso-style-link:"Текст примечания";}
span.a6
	{mso-style-name:"Верхний колонтитул Знак";
	mso-style-locked:yes;
	mso-style-link:"Верхний колонтитул";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;}
span.a7
	{mso-style-name:"Нижний колонтитул Знак";
	mso-style-locked:yes;
	mso-style-link:"Нижний колонтитул";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;}
span.a8
	{mso-style-name:"Название Знак";
	mso-style-locked:yes;
	mso-style-link:Название;
	mso-ansi-font-size:26.0pt;
	mso-bidi-font-size:26.0pt;
	font-family:Cambria;
	mso-ascii-font-family:Cambria;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Cambria;
	mso-bidi-font-family:"Times New Roman";
	color:#17365D;
	letter-spacing:.25pt;
	mso-font-kerning:14.0pt;}
span.a9
	{mso-style-name:"Основной текст с отступом Знак";
	mso-style-locked:yes;
	mso-style-link:"Основной текст с отступом";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;}
span.aa
	{mso-style-name:"Схема документа Знак";
	mso-style-locked:yes;
	mso-style-link:"Схема документа";
	mso-ansi-font-size:8.0pt;
	mso-bidi-font-size:8.0pt;
	font-family:Tahoma;
	mso-ascii-font-family:Tahoma;
	mso-hansi-font-family:Tahoma;
	mso-bidi-font-family:Tahoma;}
span.ab
	{mso-style-name:"Тема примечания Знак";
	mso-style-locked:yes;
	mso-style-parent:"Текст примечания Знак";
	mso-style-link:"Тема примечания";
	font-weight:bold;}
span.ac
	{mso-style-name:"Текст выноски Знак";
	mso-style-locked:yes;
	mso-style-link:"Текст выноски";
	mso-ansi-font-size:8.0pt;
	mso-bidi-font-size:8.0pt;
	font-family:Tahoma;
	mso-ascii-font-family:Tahoma;
	mso-hansi-font-family:Tahoma;
	mso-bidi-font-family:Tahoma;}
span.130
	{mso-style-name:"Знак Знак13";
	mso-ansi-font-size:16.0pt;
	mso-bidi-font-size:16.0pt;
	font-family:Arial;
	mso-ascii-font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:Arial;
	mso-bidi-font-family:Arial;
	mso-font-kerning:16.0pt;
	font-weight:bold;}
span.5
	{mso-style-name:"Знак Знак5";
	mso-ansi-font-size:12.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:"Times New Roman";
	mso-ascii-font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-hansi-font-family:"Times New Roman";
	mso-bidi-font-family:"Times New Roman";
	mso-fareast-language:RU;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:2.0cm 62.95pt 2.0cm 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
@page Section2
	{size:595.3pt 841.9pt;
	margin:2.0cm 62.95pt 2.0cm 42.55pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section2
	{page:Section2;}
 /* List Definitions */
 @list l0
	{mso-list-id:-120;
	mso-list-type:simple;
	mso-list-template-ids:321713970;}
@list l0:level1
	{mso-level-style-link:"Нумерованный список";
	mso-level-tab-stop:18.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l1
	{mso-list-id:1155756171;
	mso-list-template-ids:-384640348;}
@list l1:level1
	{mso-level-style-link:"Заголовок 1";
	mso-level-text:%1;
	mso-level-tab-stop:36.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l1:level2
	{mso-level-style-link:"Заголовок 2";
	mso-level-text:"%1\.%2";
	mso-level-tab-stop:72.9pt;
	mso-level-number-position:left;
	margin-left:55.8pt;
	text-indent:-21.6pt;}
@list l1:level3
	{mso-level-text:"%1\.%2\.%3\.";
	mso-level-tab-stop:126.0pt;
	mso-level-number-position:left;
	margin-left:61.2pt;
	text-indent:-25.2pt;}
@list l1:level4
	{mso-level-text:"%1\.%2\.%3\.%4\.";
	mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	margin-left:86.4pt;
	text-indent:-32.4pt;}
@list l1:level5
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.";
	mso-level-tab-stop:216.0pt;
	mso-level-number-position:left;
	margin-left:111.6pt;
	text-indent:-39.6pt;}
@list l1:level6
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.";
	mso-level-tab-stop:270.0pt;
	mso-level-number-position:left;
	margin-left:136.8pt;
	text-indent:-46.8pt;}
@list l1:level7
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.";
	mso-level-tab-stop:306.0pt;
	mso-level-number-position:left;
	margin-left:162.0pt;
	text-indent:-54.0pt;}
@list l1:level8
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.";
	mso-level-tab-stop:360.0pt;
	mso-level-number-position:left;
	margin-left:187.2pt;
	text-indent:-61.2pt;}
@list l1:level9
	{mso-level-text:"%1\.%2\.%3\.%4\.%5\.%6\.%7\.%8\.%9\.";
	mso-level-tab-stop:396.0pt;
	mso-level-number-position:left;
	margin-left:216.0pt;
	text-indent:-72.0pt;}
@list l2
	{mso-list-id:1288076459;
	mso-list-type:hybrid;
	mso-list-template-ids:-1146192126 1301434110 68747265 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l2:level1
	{mso-level-text:"%1\)";
	mso-level-tab-stop:18.0pt;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l2:level2
	{mso-level-number-format:bullet;
	mso-level-text:\F0B7;
	mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;
	font-family:Symbol;}
@list l2:level3
	{mso-level-tab-stop:108.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level4
	{mso-level-tab-stop:144.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level5
	{mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level6
	{mso-level-tab-stop:216.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level7
	{mso-level-tab-stop:252.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level8
	{mso-level-tab-stop:288.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l2:level9
	{mso-level-tab-stop:324.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3
	{mso-list-id:1351225284;
	mso-list-type:hybrid;
	mso-list-template-ids:753709194 68747279 68747289 68747291 68747279 68747289 68747291 68747279 68747289 68747291;}
@list l3:level1
	{mso-level-tab-stop:none;
	mso-level-number-position:left;
	margin-left:18.0pt;
	text-indent:-18.0pt;}
@list l3:level2
	{mso-level-tab-stop:72.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level3
	{mso-level-tab-stop:108.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level4
	{mso-level-tab-stop:144.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level5
	{mso-level-tab-stop:180.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level6
	{mso-level-tab-stop:216.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level7
	{mso-level-tab-stop:252.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level8
	{mso-level-tab-stop:288.0pt;
	mso-level-number-position:left;
	text-indent:-18.0pt;}
@list l3:level9
	{mso-level-tab-stop:324.0pt;
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
table.MsoTableGrid
	{mso-style-name:"Сетка таблицы";
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
table.TableNormal
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
table.1a
	{mso-style-name:"Сетка таблицы1";
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
<![endif]-->
<link rel=dataStoreItem href="приложение%20Б(пример).files/item0004.xml"
target="приложение%20Б(пример).files/props0005.xml">
<link rel=themeData href="приложение%20Б(пример).files/themedata.thmx">
<link rel=colorSchemeMapping
href="приложение%20Б(пример).files/colorschememapping.xml">
<!--[if gte mso 9]><xml>
 <o:shapedefaults v:ext="edit" spidmax="10242"/>
</xml><![endif]--><!--[if gte mso 9]><xml>
 <o:shapelayout v:ext="edit">
  <o:idmap v:ext="edit" data="1"/>
 </o:shapelayout></xml><![endif]-->
</head>

<body lang=RU link="#993300" vlink=purple style='tab-interval:35.4pt'>

<rw:foreach id="G_0" src="G_0">

<% if (is_first.equals("Y")) { is_first = "N"; } else {%>
<br clear=all style='page-break-before:always'>
<%}%>

<rw:getValue id="FLAG" src="FLAG"/>

<rw:foreach id="G_4" src="G_4">
<rw:getValue id="F_2" src="F_2"/>

<rw:foreach id="G_5" src="G_5">
<rw:foreach id="G_7" src="G_7">

<div class=Section2>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt'>Квитанция для оплаты через банк ВТБ-24<o:p></o:p></span></b></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<p class=MsoNormal><o:p>&nbsp;</o:p></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=677
 style='width:507.6pt;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:17.0pt'>
  <td width=156 valign=bottom style='width:117.0pt;border:double windowtext 1.5pt;
  border-bottom:none;padding:0cm 5.4pt 0cm 5.4pt;height:17.0pt'>
  <p class=MsoNormal align=center style='text-align:center'>ИЗВЕЩЕНИЕ<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:double windowtext 1.5pt;
  border-left:none;border-bottom:none;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.0pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Наименование получателя:<span
  style='mso-spacerun:yes'>            </span>ООО СК «Ренессанс Жизнь»<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
  6.0pt;margin-left:-1.0cm;text-indent:1.0cm'>ИНН 7725520440 <span
  style='mso-no-proof:yes'><v:shapetype id="_x0000_t75" coordsize="21600,21600"
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
  </v:shapetype><v:shape id="Рисунок_x0020_61" o:spid="_x0000_i1025" type="#_x0000_t75"
   style='width:112.5pt;height:48.75pt;visibility:visible'>
   <v:imagedata src="<%=g_ImagesRoot%>/Pril_B.files/image001.emz" o:title=""/>
  </v:shape></span><span style='mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal style='tab-stops:316.5pt'>Р/с 40701810019000007118 в ВТБ24
  (ЗАО)<span style='mso-tab-count:1'>                                 </span><span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Кор.сч.30101810100000000716, БИК 044525716<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-bottom-alt:solid windowtext .75pt;mso-border-right-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>ФИО Плательщика <span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-top-alt:solid .75pt;mso-border-left-alt:double 1.5pt;mso-border-bottom-alt:
  solid .75pt;mso-border-right-alt:double 1.5pt;mso-border-color-alt:windowtext;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Адрес Плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Регион
  <rw:field id="" src="P_04">P_04</rw:field>
  <span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:8;height:16.35pt'>
  <td width=156 rowspan=2 valign=top style='width:117.0pt;border-top:none;
  border-left:double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Назначение платежа<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Дата<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Сумма<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:9;height:22.95pt'>
  <td width=288 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Страховой взнос по полису
  <rw:field id="" src="P_2">P_2</rw:field>,<span style='font-family:
  Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  <p class=MsoNormal>
  <rw:field id="" src="P_5">P_5</rw:field>
  <span style='font-family:
  Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-family:Garamond;mso-ansi-language:EN-US;mso-fareast-language:
  EN-US'>
  <rw:field id="" src="P_03">P_03</rw:field>
  <o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:10;height:24.75pt'>
  <td width=156 valign=bottom style='width:117.0pt;border:double windowtext 1.5pt;
  border-top:none;padding:0cm 5.4pt 0cm 5.4pt;height:24.75pt'>
  <p class=MsoNormal align=center style='text-align:center'>Кассир<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.75pt'>
  <p class=MsoNormal>Подпись плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:11;height:17.0pt'>
  <td width=156 style='width:117.0pt;border-top:none;border-left:double windowtext 1.5pt;
  border-bottom:none;border-right:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:17.0pt'>
  <p class=MsoNormal align=center style='text-align:center'>КВИТАНЦИЯ<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:17.0pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:12;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Наименование получателя:<span
  style='mso-spacerun:yes'>            </span>ООО СК «Ренессанс Жизнь»<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:13;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
  6.0pt;margin-left:-1.0cm;text-indent:1.0cm'>ИНН 7725520440 <span
  style='mso-no-proof:yes'><v:shape id="Рисунок_x0020_60" o:spid="_x0000_i1026"
   type="#_x0000_t75" style='width:112.5pt;height:48.75pt;visibility:visible'>
   <v:imagedata src="<%=g_ImagesRoot%>/Pril_B.files/image001.emz" o:title=""/>
  </v:shape></span><span style='mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:14;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Р/с 40701810019000007118 в ВТБ24 (ЗАО)<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:15;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border:none;
  border-right:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Кор.сч.30101810100000000716, БИК 044525716<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:16;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-bottom-alt:solid windowtext .75pt;mso-border-right-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>ФИО Плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:17;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:solid windowtext 1.0pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:double windowtext 1.5pt;
  mso-border-top-alt:solid .75pt;mso-border-left-alt:double 1.5pt;mso-border-bottom-alt:

  solid .75pt;mso-border-right-alt:double 1.5pt;mso-border-color-alt:windowtext;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Адрес Плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:18;height:14.2pt'>
  <td width=156 valign=top style='width:117.0pt;border-top:none;border-left:
  double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:solid windowtext .75pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:14.2pt'>
  <p class=MsoNormal>Регион
  <rw:field id="" src="P_04">P_04</rw:field>
  <span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:19;height:16.35pt'>
  <td width=156 rowspan=2 valign=top style='width:117.0pt;border-top:none;
  border-left:double windowtext 1.5pt;border-bottom:none;border-right:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=288 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Назначение платежа<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Дата<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border:double windowtext 1.5pt;
  border-left:none;mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:16.35pt'>
  <p class=MsoNormal align=center style='text-align:center'>Сумма<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:20;height:22.95pt'>
  <td width=288 valign=top style='width:216.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal>Страховой взнос по полису
  <rw:field id="" src="P_2">P_2</rw:field>, <span style='font-family:
  Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  <p class=MsoNormal>
  <rw:field id="" src="P_5">P_5</rw:field>
  <span style='font-family:
  Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><span style='font-family:Garamond;mso-fareast-language:
  EN-US'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=125 valign=top style='width:93.6pt;border-top:none;border-left:
  none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-top-alt:double windowtext 1.5pt;mso-border-left-alt:double windowtext 1.5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:22.95pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
  style='font-family:Garamond;mso-fareast-language:EN-US'>
  <rw:field id="" src="P_03">P_03</rw:field>
  <o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:21;mso-yfti-lastrow:yes;height:24.75pt'>
  <td width=156 valign=bottom style='width:117.0pt;border:double windowtext 1.5pt;
  border-top:none;padding:0cm 5.4pt 0cm 5.4pt;height:24.75pt'>
  <p class=MsoNormal align=center style='text-align:center'>Кассир<span
  style='font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=521 colspan=3 valign=top style='width:390.6pt;border-top:none;
  border-left:none;border-bottom:double windowtext 1.5pt;border-right:double windowtext 1.5pt;
  mso-border-left-alt:double windowtext 1.5pt;padding:0cm 5.4pt 0cm 5.4pt;
  height:24.75pt'>
  <p class=MsoNormal>Подпись плательщика<span style='font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal align=center style='text-align:center;page-break-before:
always'><b style='mso-bidi-font-weight:normal'><span style='font-size:14.0pt;
font-family:Calibri'>Квитанция для оплаты через прочие банки<o:p></o:p></span></b></p>

<p class=MsoNormal align=center style='text-align:center'><b style='mso-bidi-font-weight:
normal'><span style='font-size:14.0pt;font-family:Calibri'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-right:-28.4pt'><b style='mso-bidi-font-weight:
normal'><span style='font-size:10.0pt;font-family:PragmaticaCTT'><o:p>&nbsp;</o:p></span></b></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
 style='margin-left:-12.6pt;border-collapse:collapse;mso-table-layout-alt:fixed;
 border:none;mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;
 mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt solid windowtext;
 mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:231.45pt'>
  <td width=132 valign=top style='width:99.0pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:231.45pt'>
  <p class=MsoNormal style='margin-left:6.6pt'><v:shapetype id="_x0000_t202"
   coordsize="21600,21600" o:spt="202" path="m,l,21600r21600,l21600,xe">
   <v:stroke joinstyle="miter"/>
   <v:path gradientshapeok="t" o:connecttype="rect"/>
  </v:shapetype><v:shape id="_x0000_s1026" type="#_x0000_t202" style='position:absolute;
   left:0;text-align:left;margin-left:-68.15pt;margin-top:-9.35pt;width:36pt;
   height:45pt;z-index:1' stroked="f">
   <v:textbox style='mso-next-textbox:#_x0000_s1026'>
    <![if !mso]>
    <table cellpadding=0 cellspacing=0 width="100%">
     <tr>
      <td><![endif]>
      <div>
      <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
      style='font-size:42.0pt;mso-bidi-font-size:12.0pt;font-family:Physics'><o:p>&nbsp;</o:p></span></b></p>
      </div>
      <![if !mso]></td>
     </tr>
    </table>
    <![endif]></v:textbox>
  </v:shape><span style='font-size:6.0pt;mso-bidi-font-size:12.0pt;font-family:
  Garamond;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <br style='mso-ignore:vglayout' clear=ALL>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-top:0cm;margin-right:20.65pt;margin-bottom:
  0cm;margin-left:6.6pt;margin-bottom:.0001pt;line-height:12.0pt;mso-line-height-rule:
  exactly;background:white'><span style='font-size:6.0pt;mso-bidi-font-size:
  12.0pt'><span style='mso-spacerun:yes'>         </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='mso-spacerun:yes'>             </span><span
  style='font-size:10.0pt'><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>Отправить в д/о _______</p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span
  style='mso-spacerun:yes'>                                          </span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>ИЗВЕЩЕНИЕ</p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='font-size:6.0pt;mso-bidi-font-size:12.0pt'>Кассир</span><span
  style='font-size:6.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=523 valign=top style='width:392.15pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:231.45pt'>
  <p class=msolistparagraph align=right style='text-align:right'><b
  style='mso-bidi-font-weight:normal'><span style='mso-fareast-font-family:
  Calibri'>Форма ПД-4</span></b><b style='mso-bidi-font-weight:normal'><span
  style='font-size:13.5pt;mso-fareast-font-family:Calibri'><o:p></o:p></span></b></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='margin-left:.25pt;border-collapse:collapse;mso-table-layout-alt:fixed;
   border:none;mso-border-alt:dash-small-gap windowtext .5pt;mso-yfti-tbllook:
   1184;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:64.9pt'>
    <td width=196 valign=top style='width:147.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:64.9pt'>
    <p class=MsoNormal style='mso-margin-top-alt:auto;mso-margin-bottom-alt:
    auto'><span style='font-size:10.0pt;mso-fareast-font-family:Calibri'>ООО</span><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-font-family:
    Calibri'>«С</span><span style='font-size:10.0pt;mso-fareast-font-family:
    Calibri'>К «Ренессанс Жизнь»<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>ИНН<span
    style='mso-spacerun:yes'>  </span>7725520440, КПП 775001001<span
    style='mso-spacerun:yes'>                </span><o:p></o:p></span></p>
    <p class=MsoNormal><b><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>Р/С</span></b><span
    style='font-size:7.0pt;mso-bidi-font-size:8.0pt'> <span
    style='mso-spacerun:yes'>   </span><b>40701810800001410925</b></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>В
    ЗАО «Райффайзенбанк» г. Москва<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>БИК
    044525700 , К/С 30101810200000000700</span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td width=317 rowspan=2 valign=top style='width:237.7pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:64.9pt'>
    <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:-1.0cm;text-indent:1.0cm'><span style='mso-no-proof:yes'><v:shape
     id="Рисунок_x0020_58" o:spid="_x0000_i1027" type="#_x0000_t75" style='width:112.5pt;
     height:48.75pt;visibility:visible'>
     <v:imagedata src="<%=g_ImagesRoot%>/Pril_B.files/image001.emz" o:title=""/>
    </v:shape></span><span style='mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:8.7pt'>
    <td width=196 valign=top style='width:147.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:8.7pt'>
    <h1 style='text-indent:0cm;mso-list:none;tab-stops:35.4pt'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-font-family:
    Calibri;font-weight:normal'><o:p>&nbsp;</o:p></span></h1>
    </td>
   </tr>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt solid windowtext;mso-border-insidev:
   .5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:21.05pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:21.05pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Плательщик </span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span>________________________________________________________</span><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:27.05pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:27.05pt'>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                                                  
    </span><span style='mso-spacerun:yes'>               </span>(Фамилия, Имя,
    Отчество плательщика)</span><span style='font-size:7.0pt;mso-bidi-font-size:
    12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>___________________________________________________________________________________________<o:p></o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Адрес плательщика)</span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:17.75pt'>
    <td width=515 colspan=3 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:17.75pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Страхователь</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'> </span><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>
	<u><rw:field id="" src="P_5">P_5</rw:field></u>
	</span><span style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>
    </span><span style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:
    Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:9.95pt;mso-row-margin-right:81.0pt'>
    <td width=125 valign=top style='width:93.65pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:9.95pt'>
    <p class=oaenocaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm;text-autospace:ideograph-other'><o:p>&nbsp;</o:p></p>
    </td>
    <td width=282 valign=top style='width:211.45pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:9.95pt'>
    <p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                     </span><span
    style='mso-spacerun:yes'>   </span></span><span style='font-size:7.0pt;
    mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество страхователя)</span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=108><p class='MsoNormal'></td>
   </tr>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:4.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:12.1pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:12.1pt'>
    <p class=MsoNormal style='margin-bottom:3.0pt'><b><span style='font-size:
    9.0pt;mso-bidi-font-size:12.0pt'>Назначение платежа:</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>  </span></span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'>Страховой взнос</span><b><span style='font-size:
    8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:
    EN-US'><o:p></o:p></span></b></p>
    </td>
    <td width=97 valign=top style='width:72.8pt;border:solid black 1.0pt;
    border-left:none;mso-border-left-alt:solid black .5pt;mso-border-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:12.1pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Сумма, руб.</span><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:16.05pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:16.05pt'>
    <p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
    3.0pt;margin-left:0cm'><b><span style='font-size:8.0pt;mso-bidi-font-size:
    12.0pt'>по</span><span style='mso-no-proof:yes'> </span></b><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>полису<span
    style='mso-spacerun:yes'>   </span>№
	<rw:field id="" src="P_2">P_2</rw:field>
	</span></b><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
    </td>
    <td width=97 rowspan=3 style='width:72.8pt;border-top:none;border-left:
    none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .5pt;
    mso-border-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:16.05pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span style='font-size:11.0pt;
    font-family:Garamond;mso-fareast-language:EN-US'>
	<rw:field id="" src="P_03">P_03</rw:field>
	</span></b><b
    style='mso-bidi-font-weight:normal'><span style='font-size:9.0pt;
    mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:6.2pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:6.2pt'>
    <p class=oaenocaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm'><b><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'> </span></span></b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:5.4pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:5.4pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                                      
    </span></span><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span></span><span style='font-size:7.0pt;
    mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=msolistparagraph><span style='mso-fareast-font-family:Calibri'>«_____»
  ___________200 __ г.<span style='mso-spacerun:yes'>              </span><span
  style='mso-spacerun:yes'>  </span>Подпись плательщика _______________________
  <o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:224.0pt'>
  <td width=132 valign=top style='width:99.0pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:224.0pt'>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><span style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='font-size:10.0pt'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><span style='mso-spacerun:yes'>                             </span></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'><o:p>&nbsp;</o:p></p>
  <p class=MsoNormal style='margin-left:6.6pt;mso-pagination:none;mso-layout-grid-align:
  none'>КВИТАНЦИЯ</p>
  <p class=MsoNormal style='margin-left:6.6pt'><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt'>Кассир</span><span style='font-size:6.0pt;
  mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
  </td>
  <td width=523 valign=top style='width:392.15pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:224.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:6.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt;mso-border-insideh:.5pt solid windowtext;mso-border-insidev:
   .5pt solid windowtext'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:52.5pt'>
    <td width=197 colspan=2 valign=top style='width:147.6pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
    <p class=msolistparagraph><span style='mso-fareast-font-family:Calibri'>ООО
    «СК «Ренессанс Жизнь»<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>ИНН<span
    style='mso-spacerun:yes'>  </span>7725520440, КПП775001001<o:p></o:p></span></p>
    <p class=MsoNormal><b><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>Р/С</span></b><span
    style='font-size:7.0pt;mso-bidi-font-size:8.0pt'><span
    style='mso-spacerun:yes'>    </span><b>40701810800001410925</b></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>В
    ЗАО «Райффайзенбанк» г. Москва<o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:8.0pt'>БИК
    044525700 , К/С 30101810200000000700</span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td width=317 colspan=2 rowspan=2 valign=top style='width:237.4pt;
    border:none;padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
    <p class=MsoBodyText style='margin-top:4.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:-1.0cm;text-indent:1.0cm'><span style='mso-no-proof:yes'><v:shape
     id="Рисунок_x0020_59" o:spid="_x0000_i1028" type="#_x0000_t75" style='width:112.5pt;
     height:48.75pt;visibility:visible'>
     <v:imagedata src="<%=g_ImagesRoot%>/Pril_B.files/image001.emz" o:title=""/>
    </v:shape></span><span style='mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td width=257 colspan=2 rowspan=2 valign=top style='width:192.8pt;
    border:none;padding:0cm 5.4pt 0cm 5.4pt;height:52.5pt'>
    <p class=MsoNormal align=right style='margin-right:-1.7pt;text-align:right'><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:8.6pt'>
    <td width=197 colspan=2 valign=top style='width:147.6pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:8.6pt'>
    <h1 style='text-indent:0cm;mso-list:none;tab-stops:35.4pt'><span
    style='font-size:10.0pt;mso-bidi-font-size:12.0pt;mso-fareast-font-family:
    Calibri;font-weight:normal'><o:p>&nbsp;</o:p></span></h1>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:17.85pt;
    mso-row-margin-right:191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:17.85pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Плательщик </span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'> </span>_______________________________________________________</span><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'></td>
   </tr>
   <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:4.0pt;mso-row-margin-right:
    191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество
    плательщика)</span><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt;
    font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    <p class=MsoNormal><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>________________________________________________________________________________________<o:p></o:p></span></p>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Адрес плательщика)</span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'></td>
   </tr>
   <tr style='mso-yfti-irow:4;page-break-inside:avoid;height:20.85pt;
    mso-row-margin-right:191.7pt'>
    <td width=515 colspan=5 valign=top style='width:386.1pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:20.85pt'>
    <p class=MsoNormal style='margin-top:6.0pt;text-align:justify'><b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Страхователь</span></b><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'> </span><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>
	<u><rw:field id="" src="P_5">P_5</rw:field></u>
	</span><span style='font-size:8.0pt;mso-bidi-font-size:12.0pt'>
    </span><span style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:
    Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=256><p class='MsoNormal'></td>
   </tr>
   <tr style='mso-yfti-irow:5;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:4.0pt;mso-row-margin-right:272.7pt'>
    <td width=125 valign=top style='width:93.65pt;border:none;padding:0cm 5.4pt 0cm 5.4pt;
    height:4.0pt'>
    <p class=oaenocaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm;text-autospace:ideograph-other'><o:p>&nbsp;</o:p></p>
    </td>
    <td width=282 colspan=2 valign=top style='width:211.45pt;border:none;
    padding:0cm 5.4pt 0cm 5.4pt;height:4.0pt'>
    <p class=MsoNormal><span style='font-size:5.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                            </span></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'>(Фамилия, Имя, Отчество
    страхователя)</span><span style='font-size:7.0pt;mso-bidi-font-size:12.0pt;
    font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
    <td style='mso-cell-special:placeholder;border:none;padding:0cm 0cm 0cm 0cm'
    width=364 colspan=3><p class='MsoNormal'></td>
   </tr>
   <![if !supportMisalignedColumns]>
   <tr height=0>
    <td width=125 style='border:none'></td>
    <td width=72 style='border:none'></td>
    <td width=210 style='border:none'></td>
    <td width=107 style='border:none'></td>
    <td width=1 style='border:none'></td>
    <td width=256 style='border:none'></td>
   </tr>
   <![endif]>
  </table>
  <p class=MsoNormal align=center style='text-align:center'><span
  style='font-size:5.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
  mso-fareast-language:EN-US'><o:p>&nbsp;</o:p></span></p>
  <table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0
   style='border-collapse:collapse;mso-table-layout-alt:fixed;border:none;
   mso-border-alt:solid windowtext .5pt;mso-yfti-tbllook:1184;mso-padding-alt:
   0cm 5.4pt 0cm 5.4pt'>
   <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;page-break-inside:avoid;
    height:10.3pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:solid windowtext 1.0pt;
    border-left:solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
    mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:10.3pt'>
    <p class=MsoNormal><b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Назначение
    платежа:</span></b><span style='font-size:9.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>  </span></span><span style='font-size:8.0pt;
    mso-bidi-font-size:12.0pt'>Страховой взнос </span><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
    </td>
    <td width=97 valign=top style='width:72.8pt;border:solid black 1.0pt;
    border-left:none;mso-border-left-alt:solid black .5pt;mso-border-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:10.3pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt'>Сумма, руб.</span><span
    style='font-size:9.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:1;page-break-inside:avoid;height:3.5pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
    <p class=MsoNormal style='margin-top:6.0pt;margin-right:0cm;margin-bottom:
    6.0pt;margin-left:0cm'><b><span style='font-size:8.0pt;mso-bidi-font-size:
    12.0pt'>по полису<span style='mso-spacerun:yes'>  </span>№
	<rw:field id="" src="P_2">P_2</rw:field>
	</span></b><b><span
    style='font-size:8.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></b></p>
    </td>
    <td width=97 rowspan=3 style='width:72.8pt;border-top:none;border-left:
    none;border-bottom:solid black 1.0pt;border-right:solid black 1.0pt;
    mso-border-top-alt:solid black .5pt;mso-border-left-alt:solid black .5pt;
    mso-border-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:3.5pt'>
    <p class=MsoNormal align=center style='text-align:center'><b
    style='mso-bidi-font-weight:normal'><span style='font-size:11.0pt;
    font-family:Garamond;mso-fareast-language:EN-US'>
	<rw:field id="" src="P_03">P_03</rw:field>
	<o:p></o:p></span></b></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:2;page-break-inside:avoid;height:5.1pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:none;border-right:solid black 1.0pt;
    mso-border-left-alt:solid windowtext .5pt;mso-border-right-alt:solid black .5pt;
    padding:0cm 5.4pt 0cm 5.4pt;height:5.1pt'>
    <p class=oaenocaeeaiey style='margin-bottom:0cm;margin-bottom:.0001pt;
    tab-stops:35.4pt 4.0cm 8.0cm 12.0cm 16.0cm'><o:p>&nbsp;</o:p></p>
    </td>
   </tr>
   <tr style='mso-yfti-irow:3;mso-yfti-lastrow:yes;page-break-inside:avoid;
    height:3.5pt'>
    <td width=411 valign=top style='width:308.55pt;border-top:none;border-left:
    solid windowtext 1.0pt;border-bottom:solid windowtext 1.0pt;border-right:
    solid black 1.0pt;mso-border-left-alt:solid windowtext .5pt;mso-border-bottom-alt:
    solid windowtext .5pt;mso-border-right-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt;
    height:3.5pt'>
    <p class=MsoNormal align=center style='text-align:center'><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt'><span
    style='mso-spacerun:yes'>                                    </span></span><span
    style='font-size:7.0pt;mso-bidi-font-size:12.0pt;font-family:Garamond;
    mso-fareast-language:EN-US'><o:p></o:p></span></p>
    </td>
   </tr>
  </table>
  <p class=MsoNormal style='margin-top:6.0pt'><span style='font-size:8.0pt;
  mso-bidi-font-size:12.0pt'>«_____» ___________200 __ г.<span
  style='mso-spacerun:yes'>                </span>Подпись плательщика
  _______________________</span><sub><span style='font-size:8.0pt;mso-bidi-font-size:
  12.0pt;font-family:Garamond;mso-fareast-language:EN-US'><o:p></o:p></span></sub></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=EN-US style='mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

</div>

</rw:foreach>
</rw:foreach>
</rw:foreach>
</rw:foreach>

</body>

</html>

</rw:report> 

