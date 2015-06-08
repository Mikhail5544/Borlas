<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="application/vnd.ms-excel;charset=windows-1251" %>
<%@ page import="java.text.*" %>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="CHECKING_LIST" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="CHECKING_LIST" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POL_ID" datatype="number" width="50" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_CH_ID" datatype="number" width="50" precision="10"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_MAIN">
      <select canParse="no">
      <![CDATA[select 
       qq.ch_id,
       qq.pol_id,
       qq.FL_REG,
       qq.FL_N1,
       qq.FL_N2,
       qq.FL_PR1,
       qq.FL_PR2,
       qq.FL_PR3,
       qq.FL_PR4,
       qq.FL_PR5,
       to_char(qq.FL_D1,'DD.MM.YYYY') FL_D1,
       to_char(qq.FL_D2,'DD.MM.YYYY') FL_D2,
       to_char(qq.FL_D3,'DD.MM.YYYY') FL_D3,
       to_char(qq.FL_D4,'DD.MM.YYYY') FL_D4,
       to_char(qq.FL_D9,'DD.MM.YYYY') FL_D9,
       to_char(qq.FL_D10,'DD.MM.YYYY') FL_D10,
       qq.FL_FIO1,
       qq.FL_FIO2,
       qq.FL_FIO3,
       qq.FL_NR,
       qq.FL_NU,
       qq.FL_ND,
       qq.S1,
       qq.S2,
       qq.S_VIP S3,
       qq.S_FR  S5,
       (qq.S_VIP*100/qq.S2) S6
       
       
from
(select  ch.c_claim_header_id ch_id
     ,  p.policy_id  pol_id
     , ent.obj_name('T_PROVINCE', p.region_id) FL_REG
     ,  cc.CLAIM_STATUS_DATE FL_D4
     ,  e.num FL_N1
     ,  p.pol_ser||'-'||p.pol_num FL_N2
     ,  decode(p.is_group_flag,1,'групповой','индивидуальный') FL_PR1
     ,  ph.start_date FL_D1
     ,  p.end_date FL_D2
     ,  ent.obj_name(a.ent_id, a.as_asset_id) FL_FIO1
     ,  ent.obj_name(con1.ent_id,con1.contact_id) FL_FIO2
     ,  e.event_date FL_D3
     ,  nvl(p.waiting_period_end_date,sysdate) FL_D5 
     , (case  
            when e.event_date between ph.start_date and nvl(p.waiting_period_end_date,sysdate)
            then 'Да'
            else 'Нет'
      end) FL_PR2
     ,  pc.start_date FL_D6
     ,  pc.end_date FL_D7
     , (case  
            when e.event_date between pc.start_date and nvl(pc.end_date,sysdate)
            then 'Да'
            else 'Нет'
      end) FL_PR3   
     ,  e.date_declare FL_D8
     , (case  
            when e.date_declare <= e.event_date+30
            then 'Да'
            else 'Нет'
      end) FL_PR4   
     , (select 'Да' from dual 
                  where exists (select '1' from ven_c_claim 
                                where ch.c_claim_header_id = c_claim_header_id 
                                and  doc.get_doc_status_brief(C_CLAIM_ID)='DOC_ALL')
        union                           
        select 'Нет'from dual 
                  where not exists (select '1' from ven_c_claim 
                                   where ch.c_claim_header_id = c_claim_header_id 
                                   and  doc.get_doc_status_brief(C_CLAIM_ID)='DOC_ALL')
           
        ) FL_PR5       
     ,  tp.description FL_NR
     , 
     (select dc.description from ven_t_damage_code dc  where d.t_damage_code_id = dc.id)
 FL_NU
     ,  d.rec_start_date FL_D9
     ,  d.rec_end_date FL_D10
     ,  d.rec_end_date-d.rec_start_date+1 S1
     ,  e.diagnose FL_ND
     ,  pc.ins_amount S2
     ,  round(d.payment_sum * acc.Get_Cross_Rate_By_Brief(1,fd.brief,f.brief,ch.declare_date), 2) S_VIP
     ,  ch.deductible_value S_FR
     ,  ent.obj_name(c.ent_id,c.contact_id) FL_FIO3


from ven_p_pol_header ph  
join ven_p_policy p on (ph.policy_header_id = p.pol_header_id)
join ven_t_product prod on (prod.product_id = ph.product_id)
join ven_c_claim_header ch on (ch.p_policy_id = p.policy_id)
join ven_c_claim cc on (ch.c_claim_header_id = cc.c_claim_header_id and doc.get_doc_status_brief(cc.C_CLAIM_ID)='REGULATE')
join ven_c_event e on (ch.c_event_id = e.c_event_id)
join ven_c_event_contact ec on (ch.declarant_id = ec.c_event_contact_id)
join ven_contact c on (ec.cn_person_id = c.contact_id)
join ven_cn_person per on (ch.curator_id = per.contact_id)
join ven_c_declarant_role dr on (dr.c_declarant_role_id = ch.declarant_role_id )
left join ven_department ct on (ch.depart_id = ct.department_id)
join ven_as_asset a on (ch.as_asset_id = a.as_asset_id)
left join ven_fund f on (ch.fund_id = f.fund_id)
join ven_c_claim_metod_type cmt on (ch.notice_type_id = cmt.c_claim_metod_type_id)
left join ven_p_cover pc on (ch.p_cover_id = pc.p_cover_id)
left join ven_t_prod_line_option pl on (pc.t_prod_line_option_id = pl.id)
left join ven_t_peril tp on (tp.id = ch.peril_id)
join ven_p_policy_contact pc1 on (pc1.policy_id=p.policy_id )
join ven_contact con1 on (pc1.contact_id=con1.contact_id)
join ven_t_contact_pol_role tpr1 on (pc1.contact_policy_role_id=tpr1.id and tpr1.brief='Страхователь')
join ven_c_damage d on (d.c_claim_id=cc.c_claim_id)
left join ven_fund fd on (d.damage_fund_id = fd.fund_id)
join ven_t_damage_code dc on (d.t_damage_code_id = dc.id )
join ven_c_damage_type dt on (d.c_damage_type_id = dt.c_damage_type_id and dt.brief='СТРАХОВОЙ')
) qq
where qq.pol_id=:P_POL_ID
 and  qq.ch_id = :P_CH_ID]]>
      </select>
      <displayInfo x="1.16663" y="0.65625" width="1.41675" height="0.44788"/>
      <group name="G_FL_REG">
        <displayInfo x="1.11255" y="1.36462" width="1.52283" height="5.04492"
        />
        <dataItem name="FL_REG" datatype="vchar2" columnOrder="13"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Reg">
          <dataDescriptor expression="FL_REG" descriptiveExpression="FL_REG"
           order="3" width="4000"/>
        </dataItem>
        <dataItem name="FL_N1" datatype="vchar2" columnOrder="14" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl N1">
          <dataDescriptor expression="FL_N1" descriptiveExpression="FL_N1"
           order="4" width="100"/>
        </dataItem>
        <dataItem name="FL_N2" datatype="vchar2" columnOrder="15" width="2049"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl N2">
          <dataDescriptor expression="FL_N2" descriptiveExpression="FL_N2"
           order="5" width="2049"/>
        </dataItem>
        <dataItem name="FL_PR1" datatype="vchar2" columnOrder="16" width="14"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Pr1">
          <dataDescriptor expression="FL_PR1" descriptiveExpression="FL_PR1"
           order="6" width="14"/>
        </dataItem>
        <dataItem name="FL_PR2" datatype="vchar2" columnOrder="17" width="3"
         defaultWidth="30000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Pr2">
          <dataDescriptor expression="FL_PR2" descriptiveExpression="FL_PR2"
           order="7" width="3"/>
        </dataItem>
        <dataItem name="FL_PR3" datatype="vchar2" columnOrder="18" width="3"
         defaultWidth="30000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Pr3">
          <dataDescriptor expression="FL_PR3" descriptiveExpression="FL_PR3"
           order="8" width="3"/>
        </dataItem>
        <dataItem name="FL_PR4" datatype="vchar2" columnOrder="19" width="3"
         defaultWidth="30000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Pr4">
          <dataDescriptor expression="FL_PR4" descriptiveExpression="FL_PR4"
           order="9" width="3"/>
        </dataItem>
        <dataItem name="FL_PR5" datatype="vchar2" columnOrder="20" width="3"
         defaultWidth="30000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Pr5">
          <dataDescriptor expression="FL_PR5" descriptiveExpression="FL_PR5"
           order="10" width="3"/>
        </dataItem>
        <dataItem name="FL_D1" datatype="vchar2" columnOrder="21"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl D1">
          <dataDescriptor expression="FL_D1" descriptiveExpression="FL_D1"
           order="11" width="10"/>
        </dataItem>
        <dataItem name="FL_D2" datatype="vchar2" columnOrder="22"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl D2">
          <dataDescriptor expression="FL_D2" descriptiveExpression="FL_D2"
           order="12" width="10"/>
        </dataItem>
        <dataItem name="FL_D3" datatype="vchar2" columnOrder="23"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl D3">
          <dataDescriptor expression="FL_D3" descriptiveExpression="FL_D3"
           order="13" width="10"/>
        </dataItem>
        <dataItem name="FL_D4" datatype="vchar2" columnOrder="24"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl D4">
          <dataDescriptor expression="FL_D4" descriptiveExpression="FL_D4"
           order="14" width="10"/>
        </dataItem>
        <dataItem name="FL_D9" datatype="vchar2" columnOrder="25"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl D9">
          <dataDescriptor expression="FL_D9" descriptiveExpression="FL_D9"
           order="15" width="10"/>
        </dataItem>
        <dataItem name="FL_D10" datatype="vchar2" columnOrder="26"
         defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl D10">
          <dataDescriptor expression="FL_D10" descriptiveExpression="FL_D10"
           order="16" width="10"/>
        </dataItem>
        <dataItem name="FL_FIO1" datatype="vchar2" columnOrder="27"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Fio1">
          <dataDescriptor expression="FL_FIO1" descriptiveExpression="FL_FIO1"
           order="17" width="4000"/>
        </dataItem>
        <dataItem name="FL_FIO2" datatype="vchar2" columnOrder="28"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Fio2">
          <dataDescriptor expression="FL_FIO2" descriptiveExpression="FL_FIO2"
           order="18" width="4000"/>
        </dataItem>
        <dataItem name="FL_FIO3" datatype="vchar2" columnOrder="29"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Fl Fio3">
          <dataDescriptor expression="FL_FIO3" descriptiveExpression="FL_FIO3"
           order="19" width="4000"/>
        </dataItem>
        <dataItem name="FL_NR" datatype="vchar2" columnOrder="30" width="500"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Nr">
          <dataDescriptor expression="FL_NR" descriptiveExpression="FL_NR"
           order="20" width="500"/>
        </dataItem>
        <dataItem name="FL_ND" datatype="vchar2" columnOrder="32" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Nd">
          <dataDescriptor expression="FL_ND" descriptiveExpression="FL_ND"
           order="22" width="4000"/>
        </dataItem>
        <dataItem name="S1" oracleDatatype="number" columnOrder="33"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S1">
          <dataDescriptor expression="S1" descriptiveExpression="S1"
           order="23" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="S2" oracleDatatype="number" columnOrder="34"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S2">
          <dataDescriptor expression="S2" descriptiveExpression="S2"
           order="24" oracleDatatype="number" width="22" scale="2"
           precision="11"/>
        </dataItem>
        <dataItem name="S5" oracleDatatype="number" columnOrder="36"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S5">
          <dataDescriptor expression="S5" descriptiveExpression="S5"
           order="26" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="S6" oracleDatatype="number" columnOrder="37"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S6">
          <dataDescriptor expression="S6" descriptiveExpression="S6"
           order="27" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <summary name="CS_S3" source="S3" function="sum" width="20"
         precision="10" reset="report" compute="report" defaultWidth="120000"
         defaultHeight="10000" columnFlags="8" defaultLabel="Cs S3">
          <displayInfo x="0.00000" y="0.00000" width="0.00000"
           height="0.00000"/>
        </summary>
        <summary name="CS_FL_NU" source="FL_NU" function="first" width="250"
         precision="10" reset="report" compute="report" defaultWidth="100000"
         defaultHeight="10000" columnFlags="8" defaultLabel="Cs Fl Nu">
          <displayInfo x="0.00000" y="0.00000" width="0.00000"
           height="0.00000"/>
        </summary>
        <dataItem name="CH_ID" oracleDatatype="number" columnOrder="38"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ch Id">
          <dataDescriptor expression="CH_ID" descriptiveExpression="CH_ID"
           order="1" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="POL_ID" oracleDatatype="number" columnOrder="39"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pol Id">
          <dataDescriptor expression="POL_ID" descriptiveExpression="POL_ID"
           order="2" oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
      </group>
      <group name="G_FL_NU">
        <displayInfo x="1.11255" y="6.96875" width="1.51245" height="0.94336"
        />
        <dataItem name="S3" oracleDatatype="number" columnOrder="35"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="S3">
          <dataDescriptor expression="S3" descriptiveExpression="S3"
           order="25" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="FL_NU" datatype="vchar2" columnOrder="31" width="1000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Nu">
          <dataDescriptor expression="FL_NU" descriptiveExpression="FL_NU"
           order="21" width="1000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AG">
      <select canParse="no">
      <![CDATA[select
      pol_id,
       FL_N,
       FL_AG
from(       
select distinct   pa.policy_header_id
 ,  p.policy_id pol_id
 ,  p.pol_ser||'-'||p.pol_num FL_N
 ,  ent.obj_name(con2.ent_id,con2.contact_id) FL_AG  
from ven_p_pol_header ph  
join ven_p_policy p on (ph.policy_header_id = p.pol_header_id)
join ven_c_claim_header ch on (ch.p_policy_id = p.policy_id)
join ven_c_claim cc on (ch.c_claim_header_id = cc.c_claim_header_id and doc.get_doc_status_brief(cc.C_CLAIM_ID)='REGULATE')
join ven_p_policy_agent pa on (ph.policy_header_id=pa.policy_header_id and cc.CLAIM_STATUS_DATE between pa.date_start and pa.date_end ) -- aгенты по договору страхования
join ven_policy_agent_status pas on (pa.status_id=pas.policy_agent_status_id and pas.brief ='CURRENT') -- статусы агентов по договору страхования
join ven_ag_contract_header ah on (pa.ag_contract_header_id=ah.ag_contract_header_id) -- договор с агентом
join ven_contact con2 on (con2.contact_id= ah.agent_id )
)
where POL_ID =:P_POL_ID]]>
      </select>
      <displayInfo x="3.93750" y="0.64575" width="0.90625" height="0.42712"/>
      <group name="G_AG">
        <displayInfo x="3.75916" y="1.58533" width="1.27209" height="0.77246"
        />
        <dataItem name="POL_ID1" oracleDatatype="number" columnOrder="44"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Pol Id1">
          <dataDescriptor expression="POL_ID" descriptiveExpression="POL_ID"
           order="1" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="FL_N" datatype="vchar2" columnOrder="43" width="2049"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl N">
          <dataDescriptor expression="FL_N" descriptiveExpression="FL_N"
           order="2" width="2049"/>
        </dataItem>
        <dataItem name="FL_AG" datatype="vchar2" columnOrder="42" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Fl Ag">
          <dataDescriptor expression="FL_AG" descriptiveExpression="FL_AG"
           order="3" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_FL_REG" childQuery="Q_AG"/>
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
<link rel=File-List href="U1.files/filelist.xml">
<link rel=Edit-Time-Data href="U1.files/editdata.mso">
<link rel=OLE-Object-Data href="U1.files/oledata.mso">
<!--[if gte mso 9]><xml>
 <o:DocumentProperties>
  <o:Author>MarkoOl</o:Author>
  <o:LastAuthor>admin</o:LastAuthor>
  <o:LastPrinted>2007-03-19T08:11:44Z</o:LastPrinted>
  <o:Created>2006-02-20T06:54:31Z</o:Created>
  <o:LastSaved>2007-07-11T12:34:19Z</o:LastSaved>
  <o:Company>RenLife</o:Company>
  <o:Version>11.6568</o:Version>
 </o:DocumentProperties>
 <o:CustomDocumentProperties>
  <o:_NewReviewCycle dt:dt="string"></o:_NewReviewCycle>
 </o:CustomDocumentProperties>
 <o:OfficeDocumentSettings>
  <o:DoNotRelyOnCSS/>
 </o:OfficeDocumentSettings>
</xml><![endif]-->
<style>
<!--table
	{mso-displayed-decimal-separator:"\,";
	mso-displayed-thousand-separator:" ";}
@page
	{margin:.39in .39in .39in .39in;
	mso-header-margin:.51in;
	mso-footer-margin:.12in;}
.font5
	{color:windowtext;
	font-size:14.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.font7
	{color:windowtext;
	font-size:12.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:"Arial Cyr";
	mso-generic-font-family:auto;
	mso-font-charset:204;}
.font10
	{color:windowtext;
	font-size:12.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.font11
	{color:windowtext;
	font-size:20.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.font13
	{color:windowtext;
	font-size:18.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.font14
	{color:windowtext;
	font-size:18.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:"Arial Cyr";
	mso-generic-font-family:auto;
	mso-font-charset:204;}
.font15
	{color:windowtext;
	font-size:18.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.font18
	{color:windowtext;
	font-size:16.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:"Arial Cyr";
	mso-generic-font-family:auto;
	mso-font-charset:204;}
.font20
	{color:blue;
	font-size:18.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.font21
	{color:blue;
	font-size:18.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
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
	mso-style-name:Обычный;
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
	font-size:14.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;}
.xl25
	{mso-style-parent:style0;
	text-align:center;}
.xl26
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;}
.xl27
	{mso-style-parent:style0;
	font-size:20.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;}
.xl28
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	white-space:normal;}
.xl29
	{mso-style-parent:style0;
	font-size:12.0pt;}
.xl30
	{mso-style-parent:style0;
	white-space:normal;}
.xl31
	{mso-style-parent:style0;
	text-align:center;
	vertical-align:middle;}
.xl32
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:middle;}
.xl33
	{mso-style-parent:style0;
	font-size:12.0pt;
	text-align:left;}
.xl34
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;}
.xl35
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;}
.xl36
	{mso-style-parent:style0;
	font-size:16.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl37
	{mso-style-parent:style0;
	font-size:18.0pt;}
.xl38
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:0;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;}
.xl39
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:middle;}
.xl40
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"\#\,\#\#0";
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	white-space:normal;}
.xl41
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	border:.5pt solid windowtext;}
.xl42
	{mso-style-parent:style0;
	font-size:16.0pt;}
.xl43
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl44
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"0\.0%";
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl45
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;}
.xl46
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:right;
	vertical-align:middle;}
.xl47
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";
	text-align:right;
	vertical-align:top;
	border:.5pt solid windowtext;}
.xl48
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"\@";
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;}
.xl49
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"\@";
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;}
.xl50
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;}
.xl51
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;}
.xl52
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	white-space:normal;}
.xl53
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"\#\,\#\#0";
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl54
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl55
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"\#\,\#\#0";
	vertical-align:middle;
	border:.5pt solid windowtext;}
.xl56
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl57
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:none;
	border-left:none;
	white-space:normal;}
.xl58
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:none;
	white-space:normal;}
.xl59
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	white-space:normal;}
.xl60
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl61
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	white-space:normal;}
.xl62
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl63
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;}
.xl64
	{mso-style-parent:style0;
	font-size:12.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:none;
	border-left:none;}
.xl65
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl66
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl67
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	text-decoration:underline;
	text-underline-style:single;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;}
.xl68
	{mso-style-parent:style0;
	font-size:14.0pt;
	font-weight:700;
	text-decoration:underline;
	text-underline-style:single;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;}
.xl69
	{mso-style-parent:style0;
	font-size:16.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	white-space:normal;}
.xl70
	{mso-style-parent:style0;
	font-size:16.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:none;
	white-space:normal;}
.xl71
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;}
.xl72
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;}
.xl73
	{mso-style-parent:style0;
	font-size:16.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;}
.xl74
	{mso-style-parent:style0;
	font-size:16.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;}
.xl75
	{mso-style-parent:style0;
	font-size:16.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;}
.xl76
	{mso-style-parent:style0;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;}
.xl77
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;}
.xl78
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl79
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl80
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:.5pt solid windowtext;
	white-space:normal;}
.xl81
	{mso-style-parent:style0;
	color:blue;
	font-size:18.0pt;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	mso-number-format:"Short Date";
	text-align:center;
	vertical-align:middle;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	white-space:normal;}
.xl82
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl83
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:center;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:none;
	border-left:.5pt solid windowtext;
	white-space:normal;}
.xl84
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:none;
	border-left:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl85
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:none;
	border-bottom:none;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl86
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl87
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:.5pt solid windowtext;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl88
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:none;
	border-right:none;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
.xl89
	{mso-style-parent:style0;
	font-size:18.0pt;
	font-weight:700;
	font-family:"Times New Roman", serif;
	mso-font-charset:204;
	text-align:left;
	vertical-align:middle;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:.5pt solid windowtext;
	border-left:none;
	background:#CCFFCC;
	mso-pattern:auto none;
	white-space:normal;}
-->
</style>
<!--[if gte mso 9]><xml>
 <x:ExcelWorkbook>
  <x:ExcelWorksheets>
   <x:ExcelWorksheet>
    <x:Name>Проверочный лист</x:Name>
    <x:WorksheetOptions>
     <x:Print>
      <x:ValidPrinterInfo/>
      <x:PaperSizeIndex>9</x:PaperSizeIndex>
      <x:Scale>47</x:Scale>
      <x:HorizontalResolution>600</x:HorizontalResolution>
      <x:VerticalResolution>600</x:VerticalResolution>
     </x:Print>
     <x:Zoom>70</x:Zoom>
     <x:PageBreakZoom>60</x:PageBreakZoom>
     <x:Selected/>
     <x:TopRowVisible>16</x:TopRowVisible>
     <x:Panes>
      <x:Pane>
       <x:Number>3</x:Number>
       <x:ActiveRow>12</x:ActiveRow>
       <x:RangeSelection>$A$13:$G$13</x:RangeSelection>
      </x:Pane>
     </x:Panes>
     <x:ProtectContents>False</x:ProtectContents>
     <x:ProtectObjects>False</x:ProtectObjects>
     <x:ProtectScenarios>False</x:ProtectScenarios>
    </x:WorksheetOptions>
   </x:ExcelWorksheet>
  </x:ExcelWorksheets>
  <x:WindowHeight>12120</x:WindowHeight>
  <x:WindowWidth>15180</x:WindowWidth>
  <x:WindowTopX>480</x:WindowTopX>
  <x:WindowTopY>45</x:WindowTopY>
  <x:ProtectStructure>False</x:ProtectStructure>
  <x:ProtectWindows>False</x:ProtectWindows>
 </x:ExcelWorkbook>
 <x:ExcelName>
  <x:Name>_FilterDatabase</x:Name>
  <x:Hidden/>
  <x:SheetIndex>1</x:SheetIndex>
  <x:Formula>='Проверочный лист'!#REF!</x:Formula>
 </x:ExcelName>
 <x:ExcelName>
  <x:Name>Print_Area</x:Name>
  <x:SheetIndex>1</x:SheetIndex>
  <x:Formula>='Проверочный лист'!$A$1:$H$43</x:Formula>
 </x:ExcelName>
</xml><![endif]-->
</head>

<body link=blue vlink=purple>
 <rw:foreach id="rpframe1" src="G_FL_REG">
<table x:str border=0 cellpadding=0 cellspacing=0 width=1697 style='border-collapse:
 collapse;table-layout:fixed;width:1274pt'>
 <col width=102 style='mso-width-source:userset;mso-width-alt:3730;width:77pt'>
 <col width=292 style='mso-width-source:userset;mso-width-alt:10678;width:219pt'>
 <col width=208 style='mso-width-source:userset;mso-width-alt:7606;width:156pt'>
 <col width=166 style='mso-width-source:userset;mso-width-alt:6070;width:125pt'>
 <col width=111 style='mso-width-source:userset;mso-width-alt:4059;width:83pt'>
 <col width=0 style='display:none;mso-width-source:userset;mso-width-alt:4571'>
 <col width=85 style='mso-width-source:userset;mso-width-alt:3108;width:64pt'>
 <col width=395 style='mso-width-source:userset;mso-width-alt:14445;width:296pt'>
 <col width=338 style='mso-width-source:userset;mso-width-alt:12361;width:254pt'>
 <col width=64 style='width:48pt'>
 <col width=95 style='mso-width-source:userset;mso-width-alt:3474;width:71pt'>
 <tr height=17 style='height:12.75pt'>
  <td height=17 width=102 style='height:12.75pt;width:77pt'></td>
  <td width=292 style='width:219pt'></td>
  <td width=208 style='width:156pt'></td>
  <td width=166 style='width:125pt'></td>
  <td width=111 style='width:83pt'></td>
  <td width=0></td>
  <td width=85 style='width:64pt'></td>
  <td width=395 style='width:296pt'></td>
  <td width=338 style='width:254pt'></td>
 </tr>
 <tr height=34 valign=bottom style='height:25.5pt'>
  <td colspan=8 height=34 class=xl27 align=center style='height:25.5pt'><font
  class="font11" face="Times New Roman" size="5"><b>ПРОВЕРОЧНЫЙ ЛИСТ</b></font></td>
  <td class=xl24></td>
 </tr>
 <tr height=23 valign=bottom style='mso-height-source:userset;height:17.25pt'>
  <td height=23 colspan=5 class=xl27 style='height:17.25pt;mso-ignore:colspan'></td>
  <td colspan=3 class=xl76></td>
  <td class=xl24></td>
 </tr>

 <tr height=34 valign=bottom style='mso-height-source:userset;height:25.5pt'>
  <td colspan=2 height=34 class=xl77 style='height:25.5pt'><font class="font20"
  face="Times New Roman" size="5"><b><rw:field id="REG" src="FL_REG"> &Field </rw:field></b></font></td>
  <td class=xl35></td>
  <td colspan=3 class=xl46 align=right valign=middle><font class="font13"
  face="Times New Roman" size="5"><b>Дата рассмотрения:</b></font></td>
  <td class=xl46></td>
  <td class=xl47 align=right valign=top><font class="font20"
  face="Times New Roman" size="5"><b><rw:field id="D4" src="FL_D4"> &Field </rw:field></b></font></td>
  <td class=xl24></td>
 </tr>
 <tr height=20 valign=bottom style='mso-height-source:userset;height:15.0pt'>
  <td height=20 colspan=8 class=xl35 style='height:15.0pt;mso-ignore:colspan'></td>
  <td class=xl24></td>
 </tr>
 <tr height=65 valign=bottom style='mso-height-source:userset;height:48.75pt'>
  <td colspan=2 height=65 class=xl78 bgcolor="#CCFFCC" valign=middle width=394
  style='border-right:.5pt solid black;height:48.75pt;width:296pt'><font
  class="font13" face="Times New Roman" size="5"><b>№ Претензии</b></font></td>
  <td class=xl48 align=center valign=middle style='border-left:none'><font
  class="font20" face="Times New Roman" size="5"><b><rw:field id="N1" src="FL_N1"> &Field </rw:field></b></font></td>
  <td colspan=4 class=xl78 bgcolor="#CCFFCC" valign=middle width=362
  style='border-right:.5pt solid black;border-left:none;width:272pt'><font
  class="font13" face="Times New Roman" size="5"><b>Застрахованный</b></font></td>
  <td class=xl52 align=center valign=middle width=395 style='border-left:none;
  width:296pt'><font class="font21" face="Times New Roman" size="5"><rw:field id="FIO1" src="FL_FIO1"> &Field </rw:field></font></td>
  <td></td>
 </tr>
 <tr height=64 valign=bottom style='mso-height-source:userset;height:48.0pt'>
  <td colspan=2 height=64 class=xl78 bgcolor="#CCFFCC" valign=middle width=394
  style='border-right:.5pt solid black;height:48.0pt;width:296pt'><font
  class="font13" face="Times New Roman" size="5"><b>№ Полиса</b></font></td>
  <td class=xl49 align=center valign=middle style='border-top:none;border-left:
  none'><font class="font21" face="Times New Roman" size="5"><rw:field id="N2" src="FL_N2"> &Field </rw:field></font></td>
  <td colspan=4 class=xl78 bgcolor="#CCFFCC" valign=middle width=362
  style='border-right:.5pt solid black;border-left:none;width:272pt'><font
  class="font13" face="Times New Roman" size="5"><b>Страхователь</b></font></td>
  <td class=xl52 align=center valign=middle width=395 style='border-top:none;
  border-left:none;width:296pt'><font class="font21" face="Times New Roman"
  size="5"><rw:field id="FIO2" src="FL_FIO2"> &Field </rw:field></font></td>
  <td></td>
 </tr>
 <tr height=64 valign=bottom style='mso-height-source:userset;height:48.0pt'>
  <td colspan=2 height=64 class=xl78 bgcolor="#CCFFCC" valign=middle width=394
  style='border-right:.5pt solid black;height:48.0pt;width:296pt'><font
  class="font13" face="Times New Roman" size="5"><b>Тип страхования</b></font></td>
  <td class=xl50 align=center valign=middle style='border-top:none;border-left:
  none'><font class="font21" face="Times New Roman" size="5"><rw:field id="PR1" src="FL_PR1"> &Field </rw:field></font></td>
  <td colspan=4 rowspan=2 class=xl84 bgcolor="#CCFFCC" valign=middle width=362
  style='border-right:.5pt solid black;border-bottom:.5pt solid black;
  width:272pt'><font class="font13" face="Times New Roman" size="5"><b>Дата
  наступления страхового случая</b></font></td>
  <td rowspan=2 class=xl80 align=center valign=middle width=395
  style='border-bottom:.5pt solid black;border-top:none;width:296pt'><font
  class="font21" face="Times New Roman" size="5"><rw:field id="D3" src="FL_D3"> &Field </rw:field></font></td>
  <td></td>
 </tr>
 <tr height=64 valign=bottom style='mso-height-source:userset;height:48.0pt'>
  <td colspan=2 height=64 class=xl78 bgcolor="#CCFFCC" valign=middle width=394
  style='border-right:.5pt solid black;height:48.0pt;width:296pt'><font
  class="font13" face="Times New Roman" size="5"><b>Дата вступления полиса в
  действие</b></font></td>
  <td class=xl51 align=center valign=middle style='border-top:none;border-left:
  none'><font class="font21" face="Times New Roman" size="5"><rw:field id="D1" src="FL_D1"> &Field </rw:field></font></td>
  <td></td>
 </tr>
 <tr height=65 valign=bottom style='mso-height-source:userset;height:48.75pt'>
  <td colspan=2 height=65 class=xl78 bgcolor="#CCFFCC" valign=middle width=394
  style='border-right:.5pt solid black;height:48.75pt;width:296pt'><font
  class="font13" face="Times New Roman" size="5"><b>Дата окончания действия
  полиса</b></font></td>
  <td class=xl51 align=center valign=middle style='border-top:none;border-left:
  none'><font class="font21" face="Times New Roman" size="5"><rw:field id="D2" src="FL_D2"> &Field </rw:field></font></td>

  <td colspan=4 class=xl78 bgcolor="#CCFFCC" valign=middle width=362
  style='border-right:.5pt solid black;border-left:none;width:272pt'><font
  class="font13" face="Times New Roman" size="5"><b>Агент</b></font></td>
  <td class=xl52 align=center valign=middle width=395 style='border-top:none;
  border-left:none;width:296pt'>
<rw:foreach id="rpframe2" src="G_AG">
  <font class="font21" face="Times New Roman"  size="5">
  <p> <rw:field id="AG" src="FL_AG"> &Field </rw:field>
  </font>
</rw:foreach>
  </td>
  <td></td>
 </tr>
 <tr height=20 valign=bottom style='mso-height-source:userset;height:15.0pt'>
  <td height=20 colspan=2 class=xl28 style='height:15.0pt;mso-ignore:colspan'></td>
  <td class=xl29></td>
  <td colspan=4 class=xl28 style='mso-ignore:colspan'></td>
  <td class=xl30></td>
  <td></td>
 </tr>
 <tr height=56 valign=bottom style='mso-height-source:userset;height:42.0pt'>
  <td colspan=7 height=56 class=xl69 valign=middle width=964 style='border-right:
  .5pt solid black;height:42.0pt;width:724pt'><font class="font16"
  face="Times New Roman" size="5">1. Произошел ли страховой случай в период
  действия договора (льготного, выжидательного периода)?</font></td>
  <td class=xl36 bgcolor="#CCFFCC" align=center valign=middle width=395
  style='border-left:none;width:296pt'><font class="font17"
  face="Times New Roman" size="5"><b><rw:field id="PR2" src="FL_PR2"> &Field </rw:field></b></font></td>
  <td></td>
 </tr>
 <tr height=56 valign=bottom style='mso-height-source:userset;height:42.0pt'>
  <td colspan=7 height=56 class=xl69 valign=middle width=964 style='border-right:
  .5pt solid black;height:42.0pt;width:724pt'><font class="font16"
  face="Times New Roman" size="5">2. Входят ли последствия несчастного случая
  (заболевания) в перечень покрываемых страховых рисков?</font></td>
  <td class=xl36 bgcolor="#CCFFCC" align=center valign=middle width=395
  style='border-top:none;border-left:none;width:296pt'><font class="font17"
  face="Times New Roman" size="5"><b><rw:field id="PR3" src="FL_PR3"> &Field </rw:field></b></font></td>
  <td></td>
 </tr>
 <tr height=56 valign=bottom style='mso-height-source:userset;height:42.0pt'>
  <td colspan=7 height=56 class=xl69 valign=middle width=964 style='border-right:
  .5pt solid black;height:42.0pt;width:724pt'><font class="font16"
  face="Times New Roman" size="5">3. Уведомление о страховом случае направлено
  в установленные договором сроки?</font></td>
  <td class=xl36 bgcolor="#CCFFCC" align=center valign=middle width=395
  style='border-top:none;border-left:none;width:296pt'><font class="font17"
  face="Times New Roman" size="5"><b><rw:field id="PR4" src="FL_PR4"> &Field </rw:field></b></font></td>
  <td></td>
 </tr>
 <tr height=56 valign=bottom style='mso-height-source:userset;height:42.0pt'>
  <td colspan=7 height=56 class=xl69 valign=middle width=964 style='border-right:
  .5pt solid black;height:42.0pt;width:724pt'><font class="font16"
  face="Times New Roman" size="5">4. Были ли полностью предоставлены
  запрашиваемые документы по данному событию?</font></td>
  <td class=xl36 bgcolor="#CCFFCC" align=center valign=middle width=395
  style='border-top:none;border-left:none;width:296pt'><font class="font17"
  face="Times New Roman" size="5"><b><rw:field id="PR5" src="FL_PR5"> &Field </rw:field></b></font></td>
  <td></td>
 </tr>
 <tr height=27 valign=bottom style='mso-height-source:userset;height:20.25pt'>
  <td height=27 colspan=7 style='height:20.25pt;mso-ignore:colspan'></td>
  <td class=xl31></td>
  <td></td>
 </tr>
 <tr height=30 valign=bottom style='mso-height-source:userset;height:22.5pt'>
  <td colspan=8 height=30 class=xl73 bgcolor="#CCFFCC" align=center
  style='border-right:.5pt solid black;height:22.5pt'><font class="font17"
  face="Times New Roman" size="5"><b>ОПИСАНИЕ РИСКОВ, НАСТУПИВШИХ ВСЛЕДСТВИЕ НС
  ИЛИ ЗАБОЛЕВАНИЯ</b></font></td>
  <td></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 colspan=9 style='height:12.75pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=17 valign=bottom style='mso-height-source:userset;height:12.75pt'>
  <td colspan=8 rowspan=2 height=158 class=xl83 align=center valign=middle
  width=1359 style='border-right:.5pt solid black;border-bottom:.5pt solid black;
  height:118.5pt;width:1020pt'><font class="font13" face="Times New Roman"
  size="5"><b><rw:field id="NR" src="FL_NR"> &Field </rw:field> - 
  <rw:field id="NU" src="CS_FL_NU"> &Field </rw:field> с 
  <rw:field id="D9" src="FL_D9"> &Field </rw:field> по 
  <rw:field id="D10" src="FL_D10"> &Field </rw:field> , общим количеством дней =
  <span style='mso-spacerun:yes'>  </span>
  <rw:field id="SS1" src="S1"> &Field </rw:field>. 
  <rw:field id="ND" src="FL_ND"> &Field </rw:field></b></font></td>
  <td></td>
 </tr>
 <tr height=141 valign=bottom style='mso-height-source:userset;height:105.75pt'>
  <td height=141 style='height:105.75pt'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 colspan=9 style='height:12.75pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=30 valign=bottom style='mso-height-source:userset;height:22.5pt'>
  <td colspan=8 height=30 class=xl71 bgcolor="#CCFFCC" align=center
  style='border-right:.5pt solid black;height:22.5pt'><font class="font13"
  face="Times New Roman" size="5"><b>РАСЧЕТ СТРАХОВОЙ ВЫПЛАТЫ</b></font></td>
  <td></td>
 </tr>
 <tr height=31 valign=bottom style='height:23.25pt'>
  <td height=31 colspan=8 class=xl37 style='height:23.25pt;mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr class=xl42 height=100 valign=bottom style='mso-height-source:userset;
  height:75.0pt'>
  <td colspan=2 height=100 class=xl65 bgcolor="#CCFFCC" align=center
  valign=middle width=394 style='border-right:.5pt solid black;height:75.0pt;
  width:296pt'><font class="font12" face="Times New Roman" size="4"><b>Название
  риска</b></font></td>
  <td class=xl54 bgcolor="#CCFFCC" valign=middle width=208 style='border-left:
  none;width:156pt'><font class="font12" face="Times New Roman" size="4"><b>Сумма
  страхового покрытия по риску</b></font></td>
  <td class=xl56 bgcolor="#CCFFCC" valign=middle width=166 style='width:125pt'><font
  class="font12" face="Times New Roman" size="4"><b>Сумма<span
  style='mso-spacerun:yes'>                                                                                                                                                                                                                                                                                 
  </span>(с франшизой)</b></font></td>
  <td class=xl43 bgcolor="#CCFFCC" align=center valign=middle width=111
  style='border-left:none;width:83pt'><font class="font12"
  face="Times New Roman" size="4"><b>% по таблице выплат</b></font></td>
  <td class=xl43 bgcolor="#CCFFCC" align=center valign=middle width=0
  style='border-left:none'><font class="font12" face="Times New Roman" size="4"><b>Количество
  дней</b></font></td>
  <td class=xl43 bgcolor="#CCFFCC" align=center valign=middle width=85
  style='border-left:none;width:64pt'><font class="font12"
  face="Times New Roman" size="4"><b>кол. дней</b></font></td>
  <td class=xl43 bgcolor="#CCFFCC" align=center valign=middle width=395
  style='border-left:none;width:296pt'><font class="font12"
  face="Times New Roman" size="4"><b><span
  style='mso-spacerun:yes'> </span>Сумма к выплате</b></font></td>
  <td class=xl42></td>
 </tr>
 <tr height=56 valign=bottom style='mso-height-source:userset;height:42.0pt'>
  <td colspan=2 height=56 class=xl67 align=center valign=middle
  style='border-right:.5pt solid black;height:42.0pt'><font class="font19"
  face="Times New Roman" size="4"><b><u><rw:field id="NR1" src="FL_NR"> &Field </rw:field></u></b></font></td>
  <td class=xl55 valign=middle style='border-top:none;border-left:none'><font
  class="font15" face="Times New Roman" size="5">
 <rw:field id="SS2" src="S2" formatMask="999999990.99"> &Field </rw:field></font></td>
  <td class=xl53 valign=middle style='border-top:none'><font class="font15"
  face="Times New Roman" size="5">
   <%DecimalFormat format = new DecimalFormat("0.00") ; %>
   <rw:getValue id="j_S3" src="CS_S3" formatMask="999999990.99"/>
   <rw:getValue id="j_S5" src="S5" formatMask="999999990.99"/>
    <p><%= format.format( Double.parseDouble(j_S3) + Double.parseDouble(j_S5)) %></p>
  <td class=xl44 align=center valign=middle style='border-top:none'><font
  class="font15" face="Times New Roman" size="5">
 <rw:field id="SS6" src="S6"> &Field </rw:field></font></td>
  <td class=xl38 style='border-top:none;border-left:none'><font class="font15"
  face="Times New Roman" size="5">&nbsp;</font></td>
  <td class=xl38 align=center valign=middle style='border-top:none;border-left:
  none'><font class="font15" face="Times New Roman" size="5">
  <rw:field id="S1" src="S1"> &Field </rw:field></font></td>
  <td class=xl40 align=center valign=middle width=395 style='border-top:none;
  border-left:none;width:296pt'><font class="font15" face="Times New Roman"
  size="5"><rw:field id="SS3" src="CS_S3" formatMask="999999990.99"> &Field </rw:field></font></td>
  <td></td>
 </tr>
 <tr height=17 valign=bottom style='height:12.75pt'>
  <td height=17 colspan=2 class=xl25 style='height:12.75pt;mso-ignore:colspan'></td>
  <td colspan=7 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=30 valign=bottom style='mso-height-source:userset;height:22.5pt'>
  <td height=30 colspan=2 class=xl25 style='height:22.5pt;mso-ignore:colspan'></td>
  <td></td>
  <td colspan=3 class=xl71 bgcolor="#CCFFCC" align=center style='border-right:
  .5pt solid black'><font class="font13" face="Times New Roman" size="5"><b>Получатель
  выплаты:</b></font></td>
  <td class=xl45 bgcolor="#CCFFCC"><font class="font13" face="Times New Roman"
  size="5"><b>&nbsp;</b></font></td>
  <td class=xl41 align=center style='border-left:none'><font class="font15"
  face="Times New Roman" size="5"><rw:field id="FIO3" src="FL_FIO3"> &Field </rw:field></font></td>
  <td></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 colspan=9 style='height:12.75pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=31 valign=bottom style='height:23.25pt'>
  <td height=31 colspan=8 class=xl37 style='height:23.25pt;mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr height=31 valign=bottom style='height:23.25pt'>
  <td colspan=2 height=31 class=xl63 style='height:23.25pt'><font class="font13"
  face="Times New Roman" size="5"><b>Дата утверждения:</b></font></td>
  <td class=xl39></td>
  <td colspan=5 class=xl37 style='mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr height=16 valign=bottom style='mso-height-source:userset;height:12.0pt'>
  <td height=16 colspan=2 class=xl34 style='height:12.0pt;mso-ignore:colspan'></td>
  <td class=xl32></td>
  <td colspan=6 style='mso-ignore:colspan'></td>
 </tr>
 <tr height=17 style='height:12.75pt'>
  <td height=17 colspan=9 style='height:12.75pt;mso-ignore:colspan'></td>
 </tr>
 <tr height=22 valign=bottom style='mso-height-source:userset;height:16.5pt'>
  <td height=22 class=xl26 style='height:16.5pt'><font class="font6"
  face="Times New Roman" size="3">Подпись:</font></td>
  <td class=xl26></td>
  <td colspan=6 class=xl62><font class="font6" face="Times New Roman" size="3"></font></td>
  <td></td>
 </tr>
 <tr height=18 valign=bottom style='mso-height-source:userset;height:13.5pt'>
  <td height=18 colspan=2 class=xl26 style='height:13.5pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl64><font class="font6" face="Times New Roman" size="3">Ф.И.О.
  эксперта по урегулированию убытков</font></td>
  <td></td>
 </tr>
 <tr height=20 valign=bottom style='height:15.0pt'>
  <td height=20 colspan=2 class=xl29 style='height:15.0pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl33 style='mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr height=21 valign=bottom style='height:15.75pt'>
  <td height=21 class=xl26 style='height:15.75pt'><font class="font6"
  face="Times New Roman" size="3">Подпись:</font></td>
  <td class=xl26></td>
  <td colspan=6 class=xl62><font class="font6" face="Times New Roman" size="3"></font></td>
  <td></td>
 </tr>
 <tr height=19 valign=bottom style='mso-height-source:userset;height:14.25pt'>
  <td height=19 colspan=2 class=xl26 style='height:14.25pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl64><font class="font6" face="Times New Roman" size="3">Ф.И.О.
  директора Управления андеррайтинга и методологии</font></td>
  <td></td>
 </tr>
 <tr height=20 valign=bottom style='height:15.0pt'>
  <td height=20 colspan=2 class=xl29 style='height:15.0pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl33 style='mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr height=21 valign=bottom style='height:15.75pt'>
  <td height=21 class=xl26 style='height:15.75pt'><font class="font6"
  face="Times New Roman" size="3">Подпись:</font></td>
  <td class=xl26></td>
  <td colspan=6 class=xl62><font class="font6" face="Times New Roman" size="3"></font></td>
  <td></td>
 </tr>
 <tr height=19 valign=bottom style='mso-height-source:userset;height:14.25pt'>
  <td height=19 colspan=2 class=xl26 style='height:14.25pt;mso-ignore:colspan'></td>
  <td colspan=6 class=xl64><font class="font6" face="Times New Roman" size="3">Ф.И.О.
  Управляющего директора</font></td>
  <td></td>
 </tr>

 <tr height=20 valign=bottom style='height:15.0pt'>
  <td height=20 colspan=8 class=xl29 style='height:15.0pt;mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <tr height=20 valign=bottom style='height:15.0pt'>
  <td height=20 colspan=8 class=xl29 style='height:15.0pt;mso-ignore:colspan'></td>
  <td></td>
 </tr>
 <![if supportMisalignedColumns]>
 <tr height=0 style='display:none'>
  <td width=102 style='width:77pt'></td>
  <td width=292 style='width:219pt'></td>
  <td width=208 style='width:156pt'></td>
  <td width=166 style='width:125pt'></td>
  <td width=111 style='width:83pt'></td>
  <td width=0></td>
  <td width=85 style='width:64pt'></td>
  <td width=395 style='width:296pt'></td>
  <td width=338 style='width:254pt'></td>
 </tr>
 <![endif]>
</table>
</rw:foreach>
</body>

</html>

</rw:report>
