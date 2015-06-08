<%@ include file="/inc/header_msword.jsp" %>  
<%@ page contentType="text/html;charset=windows-1251"  %>
<%@ page import="java.text.*" %>

<rw:report id="report" >

<%
  double d_row_cnt = 0;
  double d_rn = 0;
  double d_prn = 0;
%>


<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="Med_queryInsurance" DTDVersion="9.0.2.0.10"
 beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="MED_QUERYINSURANCE" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_VEDOM_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_AG_REP_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="AS_ASSURED_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="POL_ID" datatype="character" width="40"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="POL_OLD_ID" datatype="character" width="40"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <userParameter name="AS_ASSURED_ID_OLD" datatype="character" width="40"
     precision="10" defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_Title">
      <select canParse="no">
      <![CDATA[select vass.AS_ASSURED_ID,ame.underwriting_note,
vpp.POL_NUM, vc.OBJ_NAME_ORIG, vpp.NOTICE_NUM, cnp.DATE_OF_BIRTH, vpp.NOTICE_DATE, 
decode(nvl(vass.GENDER,0),0,'Женский',1,'Мужской') GENDER, vass.weight, vass.height, vass.INSURED_AGE,
decode(nvl(vass.height,0),0,0,round(vass.weight/((vass.height*vass.height)/10000),0)) bmi,
pkg_policy.get_pol_agency_name(vpp.POL_HEADER_ID) city,
lower(vt.DESCRIPTION) period,
vtp.DESCRIPTION proff,
(select a.RESPONSE_DATE 
   from AS_ASSURED_DOCUM  a, ASSURED_DOCUM_TYPE b 
 where a.ASSURED_DOCUM_TYPE_ID = b.ASSURED_DOCUM_TYPE_ID 
 and b.BRIEF = 'FINANCE_FORM' and rownum = 1 and a.AS_ASSURED_ID= :AS_ASSURED_ID) date_f
from AS_ASSURED_DOCUM  asd,
     ASSURED_DOCUM_TYPE asdt,
     VEN_AS_ASSURED_UNDERWR ame,
     VEN_AS_ASSURED vass,
     ven_p_policy vpp,
     VEN_CONTACT vc,
     VEN_CN_PERSON cnp,
     VEN_T_PAYMENT_TERMS vt,
     VEN_T_PROFESSION vtp
where vass.AS_ASSURED_ID = asd.AS_ASSURED_ID(+) 
  and vass.P_POLICY_ID = vpp.POLICY_ID(+)
  and vass.ASSURED_CONTACT_ID = vc.CONTACT_ID(+)
  and vass.ASSURED_CONTACT_ID = cnp.CONTACT_ID(+)
  and vass.T_PROFESSION_ID = vtp.ID(+)
  and vass.AS_ASSURED_ID = ame.AS_ASSURED_ID(+)
  and asd.ASSURED_DOCUM_TYPE_ID = asdt.ASSURED_DOCUM_TYPE_ID(+)
  and nvl(asdt.BRIEF,' ') in('MEDICAL EXAM',' ')
  and vpp.PAYMENT_TERM_ID = vt.ID(+)
  and vass.AS_ASSURED_ID= :AS_ASSURED_ID;]]>
      </select>
      <displayInfo x="0.75012" y="0.26038" width="0.69995" height="0.19995"/>
      <group name="G_TITLE">
        <displayInfo x="0.30078" y="0.78125" width="1.59839" height="3.16504"
        />
        <dataItem name="UNDERWRITING_NOTE1" datatype="vchar2" columnOrder="32"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Underwriting Note1">
          <dataDescriptor expression="UNDERWRITING_NOTE"
           descriptiveExpression="UNDERWRITING_NOTE" order="2" width="4000"/>
        </dataItem>
        <dataItem name="DATE_F" datatype="date" oracleDatatype="date"
         columnOrder="31" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date F">
          <dataDescriptor expression="DATE_F" descriptiveExpression="DATE_F"
           order="16" oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="AS_ASSURED_ID1" oracleDatatype="number"
         columnOrder="17" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="As Assured Id1">
          <dataDescriptor expression="AS_ASSURED_ID"
           descriptiveExpression="AS_ASSURED_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POL_NUM" datatype="vchar2" columnOrder="18"
         width="1024" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Pol Num">
          <dataDescriptor expression="POL_NUM" descriptiveExpression="POL_NUM"
           order="3" width="1024"/>
        </dataItem>
        <dataItem name="OBJ_NAME_ORIG" datatype="vchar2" columnOrder="19"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Obj Name Orig">
          <dataDescriptor expression="OBJ_NAME_ORIG"
           descriptiveExpression="OBJ_NAME_ORIG" order="4" width="2000"/>
        </dataItem>
        <dataItem name="NOTICE_NUM" datatype="vchar2" columnOrder="20"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Notice Num">
          <dataDescriptor expression="NOTICE_NUM"
           descriptiveExpression="NOTICE_NUM" order="5" width="30"/>
        </dataItem>
        <dataItem name="DATE_OF_BIRTH" datatype="date" oracleDatatype="date"
         columnOrder="21" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Date Of Birth">
          <dataDescriptor expression="DATE_OF_BIRTH"
           descriptiveExpression="DATE_OF_BIRTH" order="6"
           oracleDatatype="date" width="9"/>
        </dataItem>
        <dataItem name="NOTICE_DATE" datatype="date" oracleDatatype="date"
         columnOrder="22" width="9" defaultWidth="90000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Notice Date">
          <dataDescriptor expression="NOTICE_DATE"
           descriptiveExpression="NOTICE_DATE" order="7" oracleDatatype="date"
           width="9"/>
        </dataItem>
        <dataItem name="GENDER" datatype="vchar2" columnOrder="23" width="7"
         defaultWidth="30000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Gender">
          <dataDescriptor expression="GENDER" descriptiveExpression="GENDER"
           order="8" width="7"/>
        </dataItem>
        <dataItem name="weight" oracleDatatype="number" columnOrder="24"
         width="22" defaultWidth="50000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Weight">
          <dataDescriptor expression="WEIGHT" descriptiveExpression="WEIGHT"
           order="9" oracleDatatype="number" width="22" precision="3"/>
        </dataItem>
        <dataItem name="height" oracleDatatype="number" columnOrder="25"
         width="22" defaultWidth="50000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Height">
          <dataDescriptor expression="HEIGHT" descriptiveExpression="HEIGHT"
           order="10" oracleDatatype="number" width="22" precision="3"/>
        </dataItem>
        <dataItem name="INSURED_AGE" oracleDatatype="number" columnOrder="26"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Insured Age">
          <dataDescriptor expression="INSURED_AGE"
           descriptiveExpression="INSURED_AGE" order="11"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="bmi" oracleDatatype="number" columnOrder="27"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bmi">
          <dataDescriptor expression="BMI" descriptiveExpression="BMI"
           order="12" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="city" datatype="vchar2" columnOrder="28" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="City">
          <dataDescriptor expression="CITY" descriptiveExpression="CITY"
           order="13" width="4000"/>
        </dataItem>
        <dataItem name="period" datatype="vchar2" columnOrder="29" width="500"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Period">
          <dataDescriptor expression="PERIOD" descriptiveExpression="PERIOD"
           order="14" width="500"/>
        </dataItem>
        <dataItem name="proff" datatype="vchar2" columnOrder="30" width="255"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Proff">
          <dataDescriptor expression="PROFF" descriptiveExpression="PROFF"
           order="15" width="255"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_Programm">
      <select canParse="no">
      <![CDATA[    select ass.AS_ASSET_ID,
pc.ins_amount ins_am_cel,
    pkg_rep_utils.to_money(pc.ins_amount) ins_amount, plo.DESCRIPTION,  
    round(months_between(pc.end_date,pc.start_date)/12,0) years, ll.BRIEF,
upper(ll.BRIEF) brief_risk,
decode((select 1 from STATUS_HIST sh where sh.STATUS_HIST_ID = pc.STATUS_HIST_ID and sh.brief = 'DELETED'),1,'Decl',' ') decl,
decode(nvl(pc.K_COEF_M,0),0,decode(nvl(pc.S_COEF_M,0),0,' ','+'||to_char(pc.S_COEF_M)||'‰'),'+'||to_char(pc.K_COEF_M)||'%') K_COEF_M, 
decode(nvl(pc.K_COEF_NM,0),0,decode(nvl(pc.S_COEF_NM,0),0,' ','+'||to_char(pc.S_COEF_NM)||'‰'),'+'||to_char(pc.K_COEF_NM)||'%') K_COEF_NM
    from 
		ven_p_policy pp, 
		ven_as_asset ass, 
		ven_p_cover pc, 
		ven_t_prod_line_option plo,
		ven_t_product_line pl,
		ven_t_product_line_type plt,
        t_lob_line ll
    where ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and plo.product_line_id = pl.id
     and pl.T_LOB_LINE_ID = ll.T_LOB_LINE_ID
     and pl.product_line_type_id = plt.product_line_type_id
     and plt.brief in ('RECOMMENDED','OPTIONAL')
     and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
     and ass.AS_ASSET_ID = :AS_ASSURED_ID
     order by plt.PRESENTATION_DESC desc
]]>
      </select>
      <displayInfo x="2.29163" y="0.19788" width="0.97070" height="0.19995"/>
      <group name="G_PROGRAMM">
        <displayInfo x="2.08728" y="0.76233" width="1.37964" height="2.31055"
        />
        <dataItem name="INS_AM_CEL1" oracleDatatype="number" columnOrder="42"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Am Cel1">
          <dataDescriptor expression="INS_AM_CEL"
           descriptiveExpression="INS_AM_CEL" order="2" width="22" scale="2"
           precision="11"/>
        </dataItem>
        <dataItem name="DECL" datatype="vchar2" columnOrder="41" width="4"
         defaultWidth="40000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Decl">
          <dataDescriptor expression="DECL" descriptiveExpression="DECL"
           order="8" width="4"/>
        </dataItem>
        <dataItem name="brief_risk" datatype="vchar2" columnOrder="40"
         width="30" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Brief Risk">
          <dataDescriptor expression="BRIEF_RISK"
           descriptiveExpression="BRIEF_RISK" order="7" width="30"/>
        </dataItem>
        <dataItem name="AS_ASSET_ID" oracleDatatype="number" columnOrder="33"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="As Asset Id">
          <dataDescriptor expression="AS_ASSET_ID"
           descriptiveExpression="AS_ASSET_ID" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="ins_amount" datatype="vchar2" columnOrder="34"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ins Amount">
          <dataDescriptor expression="INS_AMOUNT"
           descriptiveExpression="INS_AMOUNT" order="3" width="4000"/>
        </dataItem>
        <dataItem name="DESCRIPTION" datatype="vchar2" columnOrder="35"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <dataDescriptor expression="DESCRIPTION"
           descriptiveExpression="DESCRIPTION" order="4" width="255"/>
        </dataItem>
        <dataItem name="years" oracleDatatype="number" columnOrder="36"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Years">
          <dataDescriptor expression="YEARS" descriptiveExpression="YEARS"
           order="5" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="BRIEF" datatype="vchar2" columnOrder="37" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief">
          <dataDescriptor expression="BRIEF" descriptiveExpression="BRIEF"
           order="6" width="30"/>
        </dataItem>
        <dataItem name="K_COEF_M" datatype="vchar2" columnOrder="38"
         width="41" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="K Coef M">
          <dataDescriptor expression="K_COEF_M"
           descriptiveExpression="K_COEF_M" order="9" width="41"/>
        </dataItem>
        <dataItem name="K_COEF_NM" datatype="vchar2" columnOrder="39"
         width="41" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="K Coef Nm">
          <dataDescriptor expression="K_COEF_NM"
           descriptiveExpression="K_COEF_NM" order="10" width="41"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_MO">
      <select>
      <![CDATA[select a.*,
decode(nvl(to_number(rost),0),0,0,round(to_number(ves)/((to_number(rost)*to_number(rost))/10000),0)) bmi
 from
(
select assd.AS_ASSURED_ID, asme.UNDERWRITING_NOTE, ASSURED_MEDICAL_EXAM_ID,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Рост', asme.ASSURED_MEDICAL_EXAM_ID) rost,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Вес', asme.ASSURED_MEDICAL_EXAM_ID) ves,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Пульс', asme.ASSURED_MEDICAL_EXAM_ID) puls,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Стресс-ЭКГ', asme.ASSURED_MEDICAL_EXAM_ID) ekg,
INS.PKG_XX_AS_ASSURED.get_medical_result ('МЕ', asme.ASSURED_MEDICAL_EXAM_ID) МЕ,
INS.PKG_XX_AS_ASSURED.get_medical_result ('HIV', asme.ASSURED_MEDICAL_EXAM_ID) HIV,
INS.PKG_XX_AS_ASSURED.get_medical_result ('AD1', asme.ASSURED_MEDICAL_EXAM_ID) AD1,
INS.PKG_XX_AS_ASSURED.get_medical_result ('AD2', asme.ASSURED_MEDICAL_EXAM_ID) AD2,
INS.PKG_XX_AS_ASSURED.get_medical_result ('AD3', asme.ASSURED_MEDICAL_EXAM_ID) AD3,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Urinalysis', asme.ASSURED_MEDICAL_EXAM_ID) Urinalysis,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Клинический анализ крови', asme.ASSURED_MEDICAL_EXAM_ID) krov,
INS.PKG_XX_AS_ASSURED.get_medical_result ('Other:', asme.ASSURED_MEDICAL_EXAM_ID) other
from ASSURED_MEDICAL_EXAM asme, as_assured_docum assd
where asme.AS_ASSURED_DOCUM_ID = assd.AS_ASSURED_DOCUM_ID
  and assd.AS_ASSURED_ID = :AS_ASSURED_ID
) a]]>
      </select>
      <displayInfo x="4.19812" y="0.19788" width="0.69995" height="0.19995"/>
      <group name="G_MO">
        <displayInfo x="3.65491" y="0.82495" width="2.09509" height="2.99414"
        />
        <dataItem name="ASSURED_MEDICAL_EXAM_ID" oracleDatatype="number"
         columnOrder="58" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Assured Medical Exam Id">
          <dataDescriptor expression="a.ASSURED_MEDICAL_EXAM_ID"
           descriptiveExpression="ASSURED_MEDICAL_EXAM_ID" order="3"
           width="22" scale="-127"/>
        </dataItem>
        <dataItem name="AS_ASSURED_ID2" oracleDatatype="number"
         columnOrder="43" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1" defaultLabel="As Assured Id2">
          <dataDescriptor expression="a.AS_ASSURED_ID"
           descriptiveExpression="AS_ASSURED_ID" order="1"
           oracleDatatype="number" width="22" precision="15"/>
        </dataItem>
        <dataItem name="UNDERWRITING_NOTE" datatype="vchar2" columnOrder="44"
         width="2000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Underwriting Note">
          <dataDescriptor expression="a.UNDERWRITING_NOTE"
           descriptiveExpression="UNDERWRITING_NOTE" order="2" width="2000"/>
        </dataItem>
        <dataItem name="ROST" datatype="vchar2" columnOrder="45" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Rost">
          <dataDescriptor expression="a.ROST" descriptiveExpression="ROST"
           order="4" width="4000"/>
        </dataItem>
        <dataItem name="VES" datatype="vchar2" columnOrder="46" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ves">
          <dataDescriptor expression="a.VES" descriptiveExpression="VES"
           order="5" width="4000"/>
        </dataItem>
        <dataItem name="PULS" datatype="vchar2" columnOrder="47" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Puls">
          <dataDescriptor expression="a.PULS" descriptiveExpression="PULS"
           order="6" width="4000"/>
        </dataItem>
        <dataItem name="EKG" datatype="vchar2" columnOrder="48" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ekg">
          <dataDescriptor expression="a.EKG" descriptiveExpression="EKG"
           order="7" width="4000"/>
        </dataItem>
        <dataItem name="МЕ" datatype="vchar2" columnOrder="49" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ме">
          <dataDescriptor expression="a.МЕ" descriptiveExpression="МЕ"
           order="8" width="4000"/>
        </dataItem>
        <dataItem name="HIV" datatype="vchar2" columnOrder="50" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Hiv">
          <dataDescriptor expression="a.HIV" descriptiveExpression="HIV"
           order="9" width="4000"/>
        </dataItem>
        <dataItem name="AD1" datatype="vchar2" columnOrder="51" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ad1">
          <dataDescriptor expression="a.AD1" descriptiveExpression="AD1"
           order="10" width="4000"/>
        </dataItem>
        <dataItem name="AD2" datatype="vchar2" columnOrder="52" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ad2">
          <dataDescriptor expression="a.AD2" descriptiveExpression="AD2"
           order="11" width="4000"/>
        </dataItem>
        <dataItem name="AD3" datatype="vchar2" columnOrder="53" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ad3">
          <dataDescriptor expression="a.AD3" descriptiveExpression="AD3"
           order="12" width="4000"/>
        </dataItem>
        <dataItem name="URINALYSIS" datatype="vchar2" columnOrder="54"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Urinalysis">
          <dataDescriptor expression="a.URINALYSIS"
           descriptiveExpression="URINALYSIS" order="13" width="4000"/>
        </dataItem>
        <dataItem name="KROV" datatype="vchar2" columnOrder="55" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Krov">
          <dataDescriptor expression="a.KROV" descriptiveExpression="KROV"
           order="14" width="4000"/>
        </dataItem>
        <dataItem name="OTHER" datatype="vchar2" columnOrder="56" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Other">
          <dataDescriptor expression="a.OTHER" descriptiveExpression="OTHER"
           order="15" width="4000"/>
        </dataItem>
        <dataItem name="bmi1" oracleDatatype="number" columnOrder="57"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Bmi1">
          <dataDescriptor
           expression="decode ( nvl ( to_number ( rost ) , 0 ) , 0 , 0 , round ( to_number ( ves ) / ( ( to_number ( rost ) * to_number ( rost ) ) / 10000 ) , 0 ) )"
           descriptiveExpression="BMI" order="16" oracleDatatype="number"
           width="22" precision="38"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_ANDERRAITER">
      <select canParse="no">
      <![CDATA[select a.rn, a.name anderraiter from(
select rownum rn, c.name from doc_status a, doc_status_ref b, VEN_SYS_USER c, VEN_AS_ASSURED v 
where a.DOC_STATUS_REF_ID = b.DOC_STATUS_REF_ID
and a.USER_NAME = c.SYS_USER_NAME
and v.P_POLICY_ID = a.document_id 
and b.brief in ('ACTIVE','PROJECT','READY_TO_CANCEL')
and v.AS_ASSURED_ID = :AS_ASSURED_ID
order by a.start_date desc) a
where a.rn = 1
]]>
      </select>
      <displayInfo x="2.62500" y="4.14587" width="0.69995" height="0.19995"/>
      <group name="G_ANDERRAITER">
        <displayInfo x="2.54041" y="4.75195" width="1.39001" height="0.60156"
        />
        <dataItem name="RN" oracleDatatype="number" columnOrder="59"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Rn">
          <dataDescriptor expression="RN" descriptiveExpression="RN" order="1"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="ANDERRAITER" datatype="vchar2" columnOrder="60"
         width="150" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Anderraiter">
          <dataDescriptor expression="ANDERRAITER"
           descriptiveExpression="ANDERRAITER" order="2" width="150"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_1">
      <select canParse="no">
      <![CDATA[select nvl(b.items,c.items) items, 
       nvl(b.dat_doc,c.dat_doc) dat_doc,
       b.ins_amount,
       b.ins_am_cel,
       b.ins_amount_old_cel,
       b.description,
       b.years,
       b.brief
from
(select rn from ( 
 (select rownum rn
    from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc,
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt
    where ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and plo.product_line_id = pl.id
     and pl.product_line_type_id = plt.product_line_type_id
     and plt.brief in ('RECOMMENDED','OPTIONAL')
     and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
     and ass.AS_ASSET_ID = :AS_ASSURED_ID
     order by plt.brief desc, plt.PRESENTATION_DESC)) a
union 
select rownum+4 rn      
from ASSURED_MEDICAL_EXAM asme, as_assured_docum assd, MEDICAL_EXAM_RESULT mer, T_medical_result tm
where asme.AS_ASSURED_DOCUM_ID = assd.AS_ASSURED_DOCUM_ID
  and tm.T_MEDICAL_RESULT_ID = mer.T_MEDICAL_RESULT_ID
  and mer.ASSURED_MEDICAL_EXAM_ID = asme.ASSURED_MEDICAL_EXAM_ID
  and mer.RESULT_DATE is not null 
  and assd.AS_ASSURED_ID = :AS_ASSURED_ID) a,
(
select     
0 AS_ASSURED_DOCUM_ID,
decode(a.rn,1,'Items',2,'Application form with health declaration',3,'FQ',4,'ME','') items,
decode(a.rn,1,'Date',2,to_char(a.dat_doc_l),3,' ',4,' ','') dat_doc,
a.*
from    
(    select ass.AS_ASSET_ID, count(1) over() row_cnt, rownum rn,
    pkg_rep_utils.to_money(pc.ins_amount) ins_amount, pc.ins_amount ins_am_cel, 
    nvl((select sum(ins_amount) from ven_p_cover where as_asset_id = :AS_ASSURED_ID_OLD and pc.t_prod_line_option_id = t_prod_line_option_id ),pc.ins_amount) ins_amount_old_cel,    
    plo.DESCRIPTION,  
    round(months_between(pc.end_date,pc.start_date)/12,0) years, ll.BRIEF,
upper(ll.BRIEF) brief_risk,
    nvl(pc.K_COEF_M,0) K_COEF_M, nvl(pc.K_COEF_NM,0) K_COEF_NM, to_char(pp.NOTICE_DATE,'dd.mm.yyyy') dat_doc_l
    from 
        ven_p_policy pp, 
        ven_as_asset ass, 
        ven_p_cover pc,
        ven_t_prod_line_option plo,
        ven_t_product_line pl,
        ven_t_product_line_type plt,
        t_lob_line ll
    where ass.p_policy_id = pp.policy_id
     and pc.as_asset_id = ass.as_asset_id
     and plo.id = pc.t_prod_line_option_id
     and plo.product_line_id = pl.id
     and pl.T_LOB_LINE_ID = ll.T_LOB_LINE_ID
     and pl.product_line_type_id = plt.product_line_type_id
     and plt.brief in ('RECOMMENDED','OPTIONAL')
     and upper(trim(plo.description)) <> 'АДМИНИСТРАТИВНЫЕ ИЗДЕРЖКИ'
     and ass.AS_ASSET_ID = :AS_ASSURED_ID
     order by plt.brief desc, plt.PRESENTATION_DESC)a )b,
(select rownum+4 rn, mer.MEDICAL_EXAM_Result_ID AS_ASSURED_DOCUM_ID, tm.BRIEF items, to_char(mer.RESULT_DATE,'dd.mm.yyyy') dat_doc,
      assd.AS_ASSURED_ID
from ASSURED_MEDICAL_EXAM asme, as_assured_docum assd, MEDICAL_EXAM_RESULT mer, T_medical_result tm
where asme.AS_ASSURED_DOCUM_ID = assd.AS_ASSURED_DOCUM_ID
  and tm.T_MEDICAL_RESULT_ID = mer.T_MEDICAL_RESULT_ID
  and mer.ASSURED_MEDICAL_EXAM_ID = asme.ASSURED_MEDICAL_EXAM_ID
  and mer.RESULT_DATE is not null 
  and assd.AS_ASSURED_ID = :AS_ASSURED_ID
)c
where a.rn = b.rn(+)
   and a.rn = c.rn(+)

]]>
      </select>
      <displayInfo x="5.92712" y="3.23950" width="0.69995" height="0.19995"/>
      <group name="G_PROGR">
        <displayInfo x="3.80603" y="3.70837" width="1.98376" height="20.59668"
        />
        <dataItem name="INS_AMOUNT_OLD_CEL" oracleDatatype="number"
         columnOrder="68" width="22" defaultWidth="20000"
         defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Amount Old Cel">
          <dataDescriptor expression="INS_AMOUNT_OLD_CEL"
           descriptiveExpression="INS_AMOUNT_OLD_CEL" order="5"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="INS_AM_CEL" oracleDatatype="number" columnOrder="67"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Am Cel">
          <dataDescriptor expression="INS_AM_CEL"
           descriptiveExpression="INS_AM_CEL" order="4"
           oracleDatatype="number" width="22" scale="2" precision="11"/>
        </dataItem>
        <dataItem name="ITEMS" datatype="vchar2" columnOrder="61" width="40"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Items">
          <dataDescriptor expression="ITEMS" descriptiveExpression="ITEMS"
           order="1" width="40"/>
        </dataItem>
        <dataItem name="DAT_DOC" datatype="vchar2" columnOrder="62"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Dat Doc">
          <dataDescriptor expression="DAT_DOC" descriptiveExpression="DAT_DOC"
           order="2" width="10"/>
        </dataItem>
        <dataItem name="INS_AMOUNT1" datatype="vchar2" columnOrder="63"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Ins Amount1">
          <dataDescriptor expression="INS_AMOUNT"
           descriptiveExpression="INS_AMOUNT" order="3" width="4000"/>
        </dataItem>
        <dataItem name="DESCRIPTION1" datatype="vchar2" columnOrder="64"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description1">
          <dataDescriptor expression="DESCRIPTION"
           descriptiveExpression="DESCRIPTION" order="6" width="255"/>
        </dataItem>
        <dataItem name="YEARS1" oracleDatatype="number" columnOrder="65"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Years1">
          <dataDescriptor expression="YEARS" descriptiveExpression="YEARS"
           order="7" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="BRIEF1" datatype="vchar2" columnOrder="66" width="30"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Brief1">
          <dataDescriptor expression="BRIEF" descriptiveExpression="BRIEF"
           order="8" width="30"/>
        </dataItem>
      </group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
begin

begin
	select p_policy_id into :POL_ID from ven_as_asset where AS_ASSET_ID = :AS_ASSURED_ID;
end;	

  
  begin
select policy_id into :POL_OLD_ID
from(
select rownum rn, vpp.POLICY_ID 
from ven_p_policy vpp, document d, doc_templ dt
where vpp.POL_HEADER_ID = (select pol_header_id from ven_p_policy where policy_id = :POL_ID)
and d.doc_templ_id = dt.doc_templ_id
and vpp.POLICY_ID <> :POL_ID
and d.document_id = decode(vpp.VERSION_NUM, 1, vpp.POL_HEADER_ID, vpp.POLICY_ID)
order by vpp.START_DATE desc)
where rn = 1;
  exception
      when no_data_found then :POL_OLD_ID  := 0; 
  end;


begin
	select AS_ASSET_ID into :AS_ASSURED_ID_OLD from ven_as_asset where p_policy_id = :POL_OLD_ID;
 exception
     when no_data_found then :AS_ASSURED_ID_OLD := 0; 
end;

  
  return (TRUE);
end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate templateName="rwbeige"/>
</report>
</rw:objects>


<html xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:w="urn:schemas-microsoft-com:office:word"
xmlns:st1="urn:schemas-microsoft-com:office:smarttags"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<title>UNDERWRITING DECISION / ЗАКЛЮЧЕНИЕ ПО АНДЕРРАЙТИНГУ</title>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="City"/>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="place"/>
<o:SmartTagType namespaceuri="urn:schemas-microsoft-com:office:smarttags"
 name="country-region"/>
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>NGrek</o:Author>
  <o:Template>Normal</o:Template>
  <o:LastAuthor>NGrek</o:LastAuthor>
  <o:Revision>2</o:Revision>
  <o:TotalTime>2</o:TotalTime>
  <o:Created>2007-12-11T09:11:00Z</o:Created>
  <o:LastSaved>2007-12-11T09:11:00Z</o:LastSaved>
  <o:Pages>1</o:Pages>
  <o:Words>174</o:Words>
  <o:Characters>994</o:Characters>
  <o:Company>BelsoftBorlasGrup</o:Company>
  <o:Lines>8</o:Lines>
  <o:Paragraphs>2</o:Paragraphs>
  <o:CharactersWithSpaces>1166</o:CharactersWithSpaces>
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
</xml><![endif]--><!--[if !mso]><object
 classid="clsid:38481807-CA0E-42D2-BF39-B33AF135CC4D" id=ieooui></object>
<style>
st1\:*{behavior:url(#ieooui) }
</style>
<![endif]-->
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
h2
	{mso-style-next:Normal;
	margin-top:6.0pt;
	margin-right:0cm;
	margin-bottom:0cm;
	margin-left:0cm;
	margin-bottom:.0001pt;
	text-indent:36.0pt;
	mso-pagination:widow-orphan;
	page-break-after:avoid;
	mso-outline-level:2;
	font-size:11.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:Arial;
	mso-fareast-language:EN-US;}
p.MsoTitle, li.MsoTitle, div.MsoTitle
	{margin:0cm;
	margin-bottom:.0001pt;
	text-align:center;
	mso-pagination:widow-orphan;
	font-size:11.0pt;
	mso-bidi-font-size:12.0pt;
	font-family:Arial;
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:EN-US;
	mso-fareast-language:EN-US;
	font-weight:bold;}
span.SpellE
	{mso-style-name:"";
	mso-spl-e:yes;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:31.2pt 31.2pt 1.0cm 62.35pt;
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
table.TableNormal1
	{mso-style-name:"Table Normal1";
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
table.TableGrid1
	{mso-style-name:"Table Grid1";
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
</head>

<body lang=RU style='tab-interval:35.4pt'>

<rw:foreach id="G_TITLE" src="G_TITLE">

<div class=Section1>


<p class=MsoTitle><span lang=EN-US style='font-size:8.0pt'>UNDERWRITING DECISION
/ </span><span style='font-size:8.0pt;mso-ansi-language:RU'>ЗАКЛЮЧЕНИЕ</span><span
style='font-size:8.0pt'> </span><span style='font-size:8.0pt;mso-ansi-language:
RU'>ПО</span><span style='font-size:8.0pt'> </span><span style='font-size:8.0pt;
mso-ansi-language:RU'>АНДЕРРАЙТИНГУ</span><span lang=EN-US style='font-size:
8.0pt'><o:p></o:p></span></p>

<p class=MsoTitle><span lang=EN-US style='font-size:8.0pt'>Renaissance Life
Insurance Company, <st1:place w:st="on"><st1:City w:st="on">Moscow</st1:City></st1:place>
<o:p></o:p></span></p>

<p class=MsoNormal style='tab-stops:18.0pt'><b><span lang=EN-US
style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></b></p>

<table class=TableGrid1 border=0 cellspacing=0 cellpadding=0 style='border-collapse:
 collapse;mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><b><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Arial'>Insured
  Person/</span></b><b><span style='font-size:8.0pt;line-height:150%;
  font-family:Arial;mso-ansi-language:RU'>Застрахованный<o:p></o:p></span></b></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="OBJ_NAME_ORIG"></rw:field></o:p></span></p>
  </td>
  <td width=180 valign=top style='width:135.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><b><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Arial'>Proposal/</span></b><b><span
  style='font-size:8.0pt;line-height:150%;font-family:Arial;mso-ansi-language:
  RU'>Заявление<o:p></o:p></span></b></p>
  </td>
  <td width=84 valign=top style='width:63.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="NOTICE_NUM"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><b><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Arial'>Date of
  Birth/</span></b><b><span style='font-size:8.0pt;line-height:150%;font-family:
  Arial;mso-ansi-language:RU'>Дата рождения<o:p></o:p></span></b></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="DATE_OF_BIRTH" formatMask="DD.MM.YYYY"></rw:field></o:p></span></p>
  </td>
  <td width=180 valign=top style='width:135.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><b><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Arial'>Proposal
  Date/</span></b><b><span style='font-size:8.0pt;line-height:150%;font-family:
  Arial;mso-ansi-language:RU'>Дата заявления<o:p></o:p></span></b></p>
  </td>
  <td width=84 valign=top style='width:63.0pt;border:none;border-bottom:solid windowtext 1.0pt;
  mso-border-bottom-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="NOTICE_DATE" formatMask="DD.MM.YYYY"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;mso-yfti-lastrow:yes'>
  <td width=187 valign=top style='width:140.4pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='text-align:justify;line-height:150%;tab-stops:18.0pt'><b><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Arial'>City
  (region)</span></b><b><span style='font-size:8.0pt;line-height:150%;
  font-family:Arial;mso-ansi-language:RU'>/Город (регион)<o:p></o:p></span></b></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="CITY"></rw:field></o:p></span></p>
  </td>
  <td width=180 valign=top style='width:135.0pt;border:none;border-right:solid windowtext 1.0pt;
  mso-border-right-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><b><span
  lang=EN-US style='font-size:8.0pt;line-height:150%;font-family:Arial'>Agreement</span></b><b><span
  style='font-size:8.0pt;line-height:150%;font-family:Arial;mso-ansi-language:
  RU'>/ Полис<o:p></o:p></span></b></p>
  </td>
  <td width=84 valign=top style='width:63.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='line-height:150%;tab-stops:18.0pt'><span
  style='font-size:9.0pt;line-height:150%;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<p class=MsoNormal style='tab-stops:18.0pt'><b><span lang=EN-US
style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></b></p>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=187 valign=top style='width:140.4pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='tab-stops:18.0pt'><b><span lang=EN-US
  style='font-size:8.0pt;font-family:Arial'>Program/</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Программа<o:p></o:p></span></b></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='tab-stops:18.0pt'><b><span lang=EN-US
  style='font-size:8.0pt;font-family:Arial'>Sum assured/</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  <p class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:8.0pt;
  font-family:Arial;mso-ansi-language:RU'>Страховая сумма<o:p></o:p></span></b></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='tab-stops:18.0pt'><b><span lang=EN-US
  style='font-size:8.0pt;font-family:Arial'>Term/</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Срок<o:p></o:p></span></b></p>
  </td>
  <td width=312 colspan=2 valign=top style='width:234.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>LIST</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>OF</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>EVIDENCE</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>ATTACHED</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>/<o:p></o:p></span></b></p>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'><span
  style='mso-spacerun:yes'> </span>СПИСОК ПРИЛАГАЕМЫХ ДОКУМЕНТОВ:<o:p></o:p></span></b></p>
  </td>
 </tr>
 
<rw:foreach id="G_PROGR" src="G_PROGR">

 <tr style='mso-yfti-irow:1'>
  <td width=187 valign=top style='width:140.4pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal style='tab-stops:18.0pt'><b><span lang=EN-US
  style='font-size:8.0pt;font-family:Arial'><o:p>
        <rw:field id="" src="BRIEF1"></rw:field>
  </o:p></span></b></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p align="right" class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:9.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>
  
        <rw:field id="" src="INS_AMOUNT_OLD_CEL" formatMask="999 999 990"></rw:field>
  
  </o:p></span></b></p>
  </td>
  <td width=72 valign=top style='width:54.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p align="center" class=MsoNormal style='tab-stops:18.0pt'><b><span style='font-size:9.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>
  
        <rw:field id="" src="YEARS1"></rw:field>
  
  </o:p></span></b></p>
  </td>
  <td width=228 valign=top style='width:171.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'><rw:field id="" src="ITEMS"></rw:field><o:p></o:p></span></b></p>
  </td>
  <td width=84 valign=top style='width:63.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'><rw:field id="" src="DAT_DOC"></rw:field><o:p></o:p></span></b></p>
  </td>
 </tr>
</rw:foreach>  
</table>

<p class=MsoNormal style='tab-stops:18.0pt'><b><span lang=EN-US
style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;tab-stops:9.0pt'><b><span
lang=EN-US style='font-size:8.0pt;font-family:Arial;text-transform:uppercase'>Additional</span></b><b><span
lang=EN-US style='font-size:8.0pt;font-family:Arial;text-transform:uppercase;
mso-ansi-language:RU'> </span></b><b><span lang=EN-US style='font-size:8.0pt;
font-family:Arial;text-transform:uppercase'>Data </span></b><b><span
style='font-size:8.0pt;font-family:Arial;text-transform:uppercase;mso-ansi-language:
RU'>/ Дополнительная информация:<o:p></o:p></span></b></p>

<table class=TableNormal1 border=1 cellspacing=0 cellpadding=0 width=684
 style='width:513.0pt;margin-left:-3.6pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:21.75pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Application</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>/ </span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Заявление </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=4 style='width:423.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal style='margin-left:2.85pt'><span style='font-size:9.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></p>
  </td>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:21.75pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Family</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>history</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>/ </span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Семейный
  анамнез<o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=4 style='width:423.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal><span lang=EN-US style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
  </td>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:25.85pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><span
  class=SpellE><b><span lang=EN-US style='font-size:8.0pt;font-family:Arial'>Heigt</span></b></span><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>/</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> Рост:</span></b><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:8.0pt;
  font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Weight / </span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Вес<o:p></o:p></span></b></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>BMI</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td width=204 style='width:153.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p class=MsoNormal align=center style='text-align:center'><span class=SpellE><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Alcogol</span></b></span><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'> / </span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Алкоголь</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=192 style='width:144.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Smoking</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>/</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> Курение<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;page-break-inside:avoid;height:21.75pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <h2 align=center style='margin-top:0cm;margin-right:-5.4pt;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;text-align:center;text-indent:0cm'><span
  style='font-size:9.0pt;font-weight:normal;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="HEIGHT"></rw:field></o:p></span></h2>
  </td>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p align="center" class=MsoNormal style='margin-left:2.85pt'><span lang=EN-US
  style='font-size:9.0pt;font-family:Arial'><o:p><rw:field id="" src="WEIGHT"></rw:field></o:p></span></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p align="center" class=MsoNormal style='margin-left:2.85pt'><span lang=EN-US
  style='font-size:9.0pt;font-family:Arial'><o:p><rw:field id="" src="BMI"></rw:field></o:p></span></p>
  </td>
  <td width=204 style='width:153.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p align="center" class=MsoNormal style='margin-left:2.85pt'><span lang=EN-US
  style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
  </td>
  <td width=192 style='width:144.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p align="center" class=MsoNormal style='margin-left:2.85pt'><span lang=EN-US
  style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:21.75pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <h2 align=center style='margin-top:0cm;margin-right:-5.4pt;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;text-align:center;text-indent:0cm'><span
  style='font-size:8.0pt'>Особые</span><span style='font-size:8.0pt;mso-ansi-language:
  EN-US'> </span><span style='font-size:8.0pt'>риски</span><span lang=EN-US
  style='font-size:8.0pt;mso-ansi-language:EN-US'> /<o:p></o:p></span></h2>
  <h2 align=center style='margin-top:0cm;margin-right:-5.4pt;margin-bottom:
  0cm;margin-left:0cm;margin-bottom:.0001pt;text-align:center;text-indent:0cm'><span
  class=GramE><span lang=EN-US style='font-size:8.0pt;mso-ansi-language:EN-US'>special</span></span><span
  lang=EN-US style='font-size:8.0pt;mso-ansi-language:EN-US'> risks:<o:p></o:p></span></h2>
  </td>
  <td width=564 colspan=4 style='width:423.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal style='margin-left:2.85pt'><span lang=EN-US
  style='font-size:9.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></p>
  </td>
 </tr>
</table>

<rw:foreach id="G_MO" src="G_MO">

<p class=MsoNormal style='margin-top:6.0pt;tab-stops:9.0pt'><b><span
style='font-size:8.0pt;font-family:Arial;text-transform:uppercase;mso-ansi-language:
RU'><span style='mso-spacerun:yes'> </span></span></b><b><span lang=EN-US
style='font-size:8.0pt;font-family:Arial;text-transform:uppercase'>MEDICAL
EXAMINATION</span></b><b><span style='font-size:8.0pt;font-family:Arial;
text-transform:uppercase;mso-ansi-language:RU'> / Медицинское обследование<o:p></o:p></span></b></p>

<table class=TableNormal1 border=1 cellspacing=0 cellpadding=0 width=684
 style='width:513.0pt;margin-left:-3.6pt;border-collapse:collapse;border:none;
 mso-border-alt:solid windowtext .5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:21.75pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>МЕ</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'> results</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>/ </span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Результаты МО</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=7 style='width:423.0pt;border:solid windowtext 1.0pt;
  border-left:none;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal style='margin-left:2.85pt'><span style='font-size:9.0pt;
  font-family:Arial;mso-ansi-language:RU'><o:p><rw:field id="" src="МЕ"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:1;height:12.75pt'>
  <td width=120 rowspan=2 style='width:90.0pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><span
  class=SpellE><b><span lang=EN-US style='font-size:8.0pt;font-family:Arial'>Heigt</span></b></span><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>/</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> Рост:</span></b><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:8.0pt;
  font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=96 rowspan=2 style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><b><span lang=EN-US style='font-size:8.0pt;font-family:
  Arial'>Weight / </span></b><b><span style='font-size:8.0pt;font-family:Arial;
  mso-ansi-language:RU'>Вес<o:p></o:p></span></b></p>
  </td>
  <td width=72 rowspan=2 style='width:54.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>BMI</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td width=204 colspan=3 style='width:153.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>BP / AD (</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>мм</span></b><b><span
  style='font-size:8.0pt;font-family:Arial'> </span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>рт</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>.</span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>ст</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>.)<o:p></o:p></span></b></p>
  </td>
  <td width=96 rowspan=2 style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><b><span lang=EN-US style='font-size:8.0pt;font-family:
  Arial'>Pulse / </span></b><b><span style='font-size:8.0pt;font-family:Arial;
  mso-ansi-language:RU'>Пульс</span></b><b><span lang=EN-US style='font-size:
  8.0pt;font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=96 rowspan=2 style='width:72.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:8.0pt;font-family:Arial'>HIV /</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;font-family:
  Arial;mso-ansi-language:RU'> Тест ВИЧ</span></b><b style='mso-bidi-font-weight:
  normal'><span lang=EN-US style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2;height:12.75pt'>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>1-е изм<span
  style='mso-spacerun:yes'>       </span></span></b><b><span lang=EN-US
  style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>2-е изм</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=60 style='width:45.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.75pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>3-е изм</span></b><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'><o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3;height:25.85pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><span
  style='font-size:9.0pt;font-family:Arial;mso-ansi-language:RU;mso-bidi-font-weight:
  bold'><o:p><rw:field id="" src="ROST"></rw:field></o:p></span></p>
  </td>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p align="center" class=MsoNormal><span style='font-size:9.0pt;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="VES"></rw:field></o:p></span></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p align="center" class=MsoNormal><span lang=EN-US style='font-size:9.0pt;font-family:Arial;
  mso-bidi-font-weight:bold'><o:p><rw:field id="" src="BMI1"></rw:field></o:p></span></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p align="center" class=MsoNormal><span style='font-size:9.0pt;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="AD1"></rw:field></o:p></span></p>
  </td>
  <td width=72 style='width:54.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p align="center" class=MsoNormal><span style='font-size:9.0pt;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="AD2"></rw:field></o:p></span></p>
  </td>
  <td width=60 style='width:45.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p align="center" class=MsoNormal><span style='font-size:9.0pt;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="AD3"></rw:field></o:p></span></p>
  </td>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p align="center" class=MsoNormal><span style='font-size:9.0pt;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="PULS"></rw:field></o:p></span></p>
  </td>
  <td width=96 style='width:72.0pt;border-top:none;border-left:none;border-bottom:
  solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;mso-border-top-alt:
  solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;mso-border-alt:
  solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p align="center" class=MsoNormal><span style='font-size:9.0pt;font-family:Arial;mso-ansi-language:
  RU;mso-bidi-font-weight:bold'><o:p><rw:field id="" src="HIV"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4;height:25.85pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>ECG / </span></b><b><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>ЭКГ</span></b><b
  style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;font-family:
  Arial;mso-ansi-language:RU'><o:p></o:p></span></b></p>
  </td>
  <td width=564 colspan=7 style='width:423.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:25.85pt'>
  <p class=MsoNormal><span style='font-size:9.0pt;font-family:Arial;mso-ansi-language:
  RU'><o:p><rw:field id="" src="EKG"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5;page-break-inside:avoid;height:12.0pt'>
  <td width=120 rowspan=2 style='width:90.0pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <h2 style='margin-top:0cm;margin-right:-5.4pt;margin-bottom:0cm;margin-left:
  0cm;margin-bottom:.0001pt;text-indent:0cm'><span lang=EN-US style='font-size:
  8.0pt;mso-ansi-language:EN-US'>Laboratory tests / </span><span
  style='font-size:8.0pt'>Лабораторные исследования<o:p></o:p></span></h2>
  </td>
  <td width=240 colspan=3 style='width:180.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p class=MsoNormal align=center style='margin-left:2.85pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:8.0pt;
  font-family:Arial'>Urinalysis</span></b><b style='mso-bidi-font-weight:normal'><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'> </span></b><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:8.0pt;
  font-family:Arial'>/ </span></b><b style='mso-bidi-font-weight:normal'><span
  style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Моча </span></b><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:8.0pt;
  font-family:Arial'><o:p></o:p></span></b></p>
  </td>
  <td width=324 colspan=4 style='width:243.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:8.0pt;
  font-family:Arial'>Blood tests / </span></b><b style='mso-bidi-font-weight:
  normal'><span style='font-size:8.0pt;font-family:Arial;mso-ansi-language:
  RU'>Кровь</span></b><b style='mso-bidi-font-weight:normal'><span lang=EN-US
  style='font-size:8.0pt;font-family:Arial'> <o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6;page-break-inside:avoid;height:12.0pt'>
  <td width=240 colspan=3 style='width:180.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p align="center" class=MsoNormal style='margin-left:2.85pt'><span lang=EN-US
  style='font-size:9.0pt;font-family:Arial'><o:p><rw:field id="" src="URINALYSIS"></rw:field></o:p></span></p>
  </td>
  <td width=324 colspan=4 style='width:243.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:12.0pt'>
  <p align="center" class=MsoNormal style='margin-left:2.85pt'><span lang=EN-US
  style='font-size:9.0pt;font-family:Arial'><o:p><rw:field id="" src="KROV"></rw:field></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7;mso-yfti-lastrow:yes;page-break-inside:avoid;
  height:21.75pt'>
  <td width=120 style='width:90.0pt;border:solid windowtext 1.0pt;border-top:
  none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <h2 style='margin-top:0cm;margin-right:-5.4pt;margin-bottom:0cm;margin-left:
  0cm;margin-bottom:.0001pt;text-indent:0cm'><span lang=EN-US style='font-size:
  8.0pt;mso-ansi-language:EN-US'>Additionally /<o:p></o:p></span></h2>
  <h2 style='margin-top:0cm;margin-right:-5.4pt;margin-bottom:0cm;margin-left:
  0cm;margin-bottom:.0001pt;text-indent:0cm'><span style='font-size:8.0pt'>Дополнительно<o:p></o:p></span></h2>
  </td>
  <td width=564 colspan=7 style='width:423.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:21.75pt'>
  <p class=MsoNormal style='margin-left:2.85pt'><span lang=EN-US
  style='font-size:9.0pt;font-family:Arial'><o:p><rw:field id="" src="OTHER"></rw:field></o:p></span></p>
  </td>
 </tr>
</table>


</rw:foreach>


<p class=MsoNormal style='margin-top:6.0pt;tab-stops:9.0pt'><b><span
lang=EN-US style='font-size:8.0pt;font-family:Arial'>Decision / </span></b><b><span
style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'>Решение</span></b><b><span
lang=EN-US style='font-size:8.0pt;font-family:Arial'>: </span></b><b><span
style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'><o:p></o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;tab-stops:9.0pt'><b><span
style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=684
 style='width:513.0pt;margin-left:-3.6pt;border-collapse:collapse;mso-padding-alt:
 0cm 5.4pt 0cm 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;height:12.4pt'>
  <td width=132 valign=top style='width:99.0pt;border:solid windowtext 1.0pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:12.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Risks / <span
  class=SpellE>Риски</span><o:p></o:p></span></b></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:solid windowtext 1.0pt;
  border-left:none;padding:0cm 5.4pt 0cm 5.4pt;height:12.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Med<o:p></o:p></span></b></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:solid windowtext 1.0pt;
  border-left:none;padding:0cm 5.4pt 0cm 5.4pt;height:12.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Non Med<o:p></o:p></span></b></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border:solid windowtext 1.0pt;
  border-left:none;padding:0cm 5.4pt 0cm 5.4pt;height:12.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Decline<o:p></o:p></span></b></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border:solid windowtext 1.0pt;
  border-left:none;padding:0cm 5.4pt 0cm 5.4pt;height:12.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Excl.<o:p></o:p></span></b></p>
  </td>
  <td width=84 valign=top style='width:63.0pt;border:solid windowtext 1.0pt;
  border-left:none;padding:0cm 5.4pt 0cm 5.4pt;height:12.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'>Diff. <st1:place w:st="on"><st1:country-region
   w:st="on">S.A.</st1:country-region></st1:place><o:p></o:p></span></b></p>
  </td>
 </tr>
<rw:foreach id="G_PROGRAMM" src="G_PROGRAMM">
 <tr style='mso-yfti-irow:1;mso-yfti-lastrow:yes;height:13.5pt'>
  <td width=132 valign=top style='width:99.0pt;border:solid windowtext 1.0pt;
  border-top:none;padding:0cm 5.4pt 0cm 5.4pt;height:13.5pt'>
  <p class=MsoNormal align=center style='text-align:center'><b><span
  lang=EN-US style='font-size:8.0pt;font-family:Arial'><rw:field id="" src="BRIEF_RISK"></rw:field><o:p></o:p></span></b></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:13.5pt'>
  <p align="center" class=MsoNormal><span lang=EN-US style='font-size:9.0pt;font-family:Arial'><rw:field id="" src="K_COEF_M"></rw:field><o:p></o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:13.5pt'>
  <p align="center" class=MsoNormal><span lang=EN-US style='font-size:9.0pt;font-family:Arial'><rw:field id="" src="K_COEF_NM"></rw:field><o:p></o:p></span></p>
  </td>
  <td width=120 valign=top style='width:90.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:13.5pt'>
  <p align="center" class=MsoNormal><span lang=EN-US style='font-size:9.0pt;font-family:Arial'><rw:field id="" src="DECL"></rw:field><o:p></o:p></span></p>
  </td>
  <td width=108 valign=top style='width:81.0pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:13.5pt'>
  <p align="center" class=MsoNormal><span lang=EN-US style='font-size:9.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
  </td>
  <td width=84 valign=top style='width:63.0pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  padding:0cm 5.4pt 0cm 5.4pt;height:13.5pt'>
  <p align="center" class=MsoNormal><span lang=EN-US style='font-size:9.0pt;font-family:Arial'>&nbsp;<o:p></o:p></span></p>
  </td>
 </tr>
</rw:foreach>
</table>

<p class=MsoNormal style='margin-top:6.0pt;tab-stops:9.0pt'><b><span
style='font-size:8.0pt;font-family:Arial;text-transform:uppercase;mso-ansi-language:
RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal style='margin-top:6.0pt;tab-stops:9.0pt'><b><span
lang=EN-US style='font-size:8.0pt;font-family:Arial;text-transform:uppercase'>comments
on decision / </span></b><b><span style='font-size:8.0pt;font-family:Arial;
text-transform:uppercase;mso-ansi-language:RU'>Заключение<o:p></o:p></span></b></p>

<rw:getValue id="j_underwriting_note" src="UNDERWRITING_NOTE1"/>

<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0 align=left
 style='border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-table-lspace:9.0pt;margin-left:6.75pt;mso-table-rspace:
 9.0pt;margin-right:6.75pt;mso-table-anchor-vertical:paragraph;mso-table-anchor-horizontal:
 margin;mso-table-left:-3.65pt;mso-table-top:5.5pt;mso-padding-alt:0cm 5.4pt 0cm 5.4pt;
 mso-border-insideh:.5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes;
  height:1.0cm'>
  <td width=684 valign=top style='width:513.0pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;padding:0cm 5.4pt 0cm 5.4pt;height:1.0cm'>
  <p class=MsoNormal style='mso-element:frame;mso-element-frame-hspace:9.0pt;
  mso-element-wrap:around;mso-element-anchor-vertical:paragraph;mso-element-anchor-horizontal:
  margin;mso-element-left:-3.6pt;mso-element-top:5.5pt;mso-height-rule:exactly'><b
  style='mso-bidi-font-weight:normal'><span lang=EN-US style='font-size:8.0pt;
  font-family:Arial'><o:p>

  <% if (j_underwriting_note != null) { %>
  <%=j_underwriting_note.replaceAll("\r|\n", "<BR/>")%>
  <%}%>

  </o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
style='font-size:8.0pt;font-family:Arial'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span
style='font-size:8.0pt;font-family:Arial;mso-ansi-language:RU'><o:p>&nbsp;</o:p></span></b></p>

<p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=EN-US
style='font-size:8.0pt;font-family:Arial'>Underwriter</span></b><b
style='mso-bidi-font-weight:normal'><span style='font-size:8.0pt;font-family:
Arial;mso-ansi-language:RU'> / Андеррайтер<span style='mso-spacerun:yes'>  
</span><u><rw:foreach id="G_ANDERRAITER" src="G_ANDERRAITER"> <rw:field id="" src="ANDERRAITER"></rw:field> </rw:foreach></u></span></b><span style='font-size:9.0pt;font-family:Arial;
mso-ansi-language:RU'><span style='mso-tab-count:1'> </span><o:p></o:p></span></p>

<p class=MsoNormal><span style='mso-ansi-language:RU'><span
style='mso-spacerun:yes'> </span></span><span style='font-size:8.0pt;
mso-ansi-language:RU'><o:p></o:p></span></p>



</div>

</rw:foreach> 

</body>

</html>


</rw:report>