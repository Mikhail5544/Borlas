<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*, java.text.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="text/html;charset=windows-1251" %>
<%
  DecimalFormat format = new DecimalFormat("0.0#");
  SimpleDateFormat sdf = new SimpleDateFormat("dd.MM.yyyy");
  int tarif[][] = {{296,151,51},{218,28,48},{50,27,9},{131,131,131},{96,96,96}};
  int progRow = 0;
  double premTot = 0.0;
%>
<rw:report id="report">
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="abc_prilozenie3_model" DTDVersion="9.0.2.0.10">
  <xmlSettings xmlTag="ABC_PRILOZENIE3_MODEL" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_POLICY_HEADER_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <userParameter name="P_POLICY_ID" datatype="character" width="40"
     defaultWidth="0" defaultHeight="0"/>
    <dataSource name="Q_POLICY">
      <select canParse="no">
      <![CDATA[SELECT   SUM(COUNT(1)) OVER() CNT_TOT, COUNT (1)  cnt,p_policy_id, description, ins_amount, age_group
    FROM (SELECT   progr.description, asset.p_policy_id, asset.ins_amount,
        case 
           WHEN MONTHS_BETWEEN(round(sysdate,'YEAR'), ROUND(pers.DATE_OF_BIRTH,'YEAR')) / 12 between 18 and 35 THEN '18-35'
        
           WHEN MONTHS_BETWEEN(round(sysdate,'YEAR'), ROUND(pers.DATE_OF_BIRTH,'YEAR')) / 12 between 36 and 45 THEN '36-45'
        
           WHEN MONTHS_BETWEEN(round(sysdate,'YEAR'), ROUND(pers.DATE_OF_BIRTH,'YEAR')) / 12 between 46 and 60 THEN '46-60'
        
        END age_group    
              FROM ven_as_asset asset,
                   ven_as_assured assured,
                   ven_cn_person pers,
                   ven_p_cover cover,
                   ven_t_prod_line_option grisk,
                   ven_t_product_line prodl,
                   ven_t_lob_line progr
             WHERE asset.as_asset_id = cover.as_asset_id
               AND cover.t_prod_line_option_id = grisk.ID
               AND grisk.product_line_id = prodl.ID
               AND prodl.t_lob_line_id = progr.t_lob_line_id
               AND (   progr.description LIKE '%"АЗ"%'
                    OR progr.description LIKE '%"БУКИ"%'
                    OR progr.description LIKE '%"ВЕДИ"%'
                    OR progr.description LIKE '%"ГЛАГОЛЬ"%'
                    OR progr.description LIKE '%"ДОБРО"%'
                   )
               AND asset.as_asset_id = assured.as_assured_id
               AND assured.contact_id = pers.contact_id
               AND asset.p_policy_id = :P_POLICY_ID
          ORDER BY progr.description, age_group)
GROUP BY p_policy_id, description, ins_amount, age_group]]>
      </select>
      <displayInfo x="1.22864" y="0.11462" width="0.69995" height="0.19995"/>
      <group name="G_POLICY">
        <displayInfo x="0.79529" y="0.66675" width="1.57056" height="0.60156"
        />
        <dataItem name="P_POLICY_ID1" oracleDatatype="number" columnOrder="14"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="P Policy Id1">
          <dataDescriptor expression="P_POLICY_ID"
           descriptiveExpression="P_POLICY_ID" order="3"
           oracleDatatype="number" width="22" scale="-127"/>
        </dataItem>
        <dataItem name="CNT_TOT" oracleDatatype="number" columnOrder="18"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt Tot">
          <dataDescriptor expression="CNT_TOT" descriptiveExpression="CNT_TOT"
           order="1" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
      </group>
      <group name="G_DESCRIPTION">
        <displayInfo x="0.81616" y="1.59460" width="1.53760" height="0.77246"
        />
        <dataItem name="DESCRIPTION" datatype="vchar2" columnOrder="15"
         width="255" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Description">
          <dataDescriptor expression="DESCRIPTION"
           descriptiveExpression="DESCRIPTION" order="4" width="255"/>
        </dataItem>
      </group>
      <group name="G_PROG_TOT">
        <displayInfo x="0.82605" y="2.69849" width="1.50464" height="0.94336"
        />
        <dataItem name="CNT" oracleDatatype="number" columnOrder="13"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Cnt">
          <dataDescriptor expression="CNT" descriptiveExpression="CNT"
           order="2" oracleDatatype="number" width="22" precision="38"/>
        </dataItem>
        <dataItem name="INS_AMOUNT" oracleDatatype="number" columnOrder="16"
         width="22" defaultWidth="90000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Ins Amount">
          <dataDescriptor expression="INS_AMOUNT"
           descriptiveExpression="INS_AMOUNT" order="5"
           oracleDatatype="number" width="22" scale="2" precision="11"/>
        </dataItem>
        <dataItem name="AGE_GROUP" datatype="character"
         oracleDatatype="aFixedChar" columnOrder="17" width="5"
         defaultWidth="50000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Age Group">
          <dataDescriptor expression="AGE_GROUP"
           descriptiveExpression="AGE_GROUP" order="6"
           oracleDatatype="aFixedChar" width="5"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_STRAHOVATEL">
      <select>
      <![CDATA[SELECT iss.policy_id, contact_name, pkg_contact.get_primary_tel(iss.contact_id) TEL
        FROM v_pol_issuer iss]]>
      </select>
      <displayInfo x="3.62500" y="0.62500" width="0.69995" height="0.32983"/>
      <group name="G_STRAHOVATEL">
        <displayInfo x="3.29565" y="1.32495" width="1.35876" height="0.77246"
        />
        <dataItem name="policy_id" oracleDatatype="number" columnOrder="19"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id">
          <dataDescriptor expression="iss.policy_id"
           descriptiveExpression="POLICY_ID" order="1" width="22" scale="-127"
          />
        </dataItem>
        <dataItem name="contact_name" datatype="vchar2" columnOrder="20"
         width="4000" defaultWidth="100000" defaultHeight="10000"
         columnFlags="1" defaultLabel="Contact Name">
          <dataDescriptor expression="contact_name"
           descriptiveExpression="CONTACT_NAME" order="2" width="4000"/>
        </dataItem>
        <dataItem name="TEL" datatype="vchar2" columnOrder="21" width="4000"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Tel">
          <dataDescriptor
           expression="pkg_contact.get_primary_tel ( iss.contact_id )"
           descriptiveExpression="TEL" order="3" width="4000"/>
        </dataItem>
      </group>
    </dataSource>
    <dataSource name="Q_AGENT_NUM">
      <select>
      <![CDATA[SELECT pol.POLICY_ID, ah.num
  FROM ven_p_policy pol,
       ven_p_pol_header pph,
       ven_p_policy_agent pa,
       ven_ag_contract_header ah
 WHERE pol.policy_id = pph.policy_id
   AND pph.policy_header_id = pa.policy_header_id
   AND pa.ag_contract_header_id = ah.ag_contract_header_id]]>
      </select>
      <displayInfo x="4.71875" y="3.02087" width="0.69995" height="0.32983"/>
      <group name="G_AGENT_NUM">
        <displayInfo x="4.44141" y="3.72083" width="1.25464" height="0.60156"
        />
        <dataItem name="POLICY_ID1" oracleDatatype="number" columnOrder="22"
         width="22" defaultWidth="20000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Policy Id1">
          <dataDescriptor expression="pol.POLICY_ID"
           descriptiveExpression="POLICY_ID" order="1" width="22" scale="-127"
          />
        </dataItem>
        <dataItem name="num" datatype="vchar2" columnOrder="23" width="100"
         defaultWidth="100000" defaultHeight="10000" columnFlags="1"
         defaultLabel="Num">
          <dataDescriptor expression="ah.num" descriptiveExpression="NUM"
           order="2" width="100"/>
        </dataItem>
      </group>
    </dataSource>
    <link name="L_1" parentGroup="G_POLICY" parentColumn="P_POLICY_ID1"
     childQuery="Q_STRAHOVATEL" childColumn="policy_id" condition="eq"
     sqlClause="where"/>
    <link name="L_2" parentGroup="G_POLICY" parentColumn="P_POLICY_ID1"
     childQuery="Q_AGENT_NUM" childColumn="POLICY_ID1" condition="eq"
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
<meta name=ProgId content=Word.Document>
<meta name=Generator content="Microsoft Word 11">
<meta name=Originator content="Microsoft Word 11">
<link rel=File-List href="abc_prilozenie3.files/filelist.xml">
<title>Приложение №3</title>
<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Arial Narrow";
	panose-1:2 11 5 6 2 2 2 3 2 4;
	mso-font-charset:204;
	mso-generic-font-family:swiss;
	mso-font-pitch:variable;
	mso-font-signature:647 0 0 0 159 0;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{mso-style-parent:"";
	margin:0in;
	margin-bottom:.0001pt;
	mso-pagination:widow-orphan;
	font-size:12.0pt;
	font-family:"Times New Roman";
	mso-fareast-font-family:"Times New Roman";
	mso-ansi-language:RU;
	mso-fareast-language:RU;}
span.GramE
	{mso-style-name:"";
	mso-gram-e:yes;}
@page Section1
	{size:595.3pt 841.9pt;
	margin:26.95pt 42.55pt 35.95pt 48.2pt;
	mso-header-margin:35.45pt;
	mso-footer-margin:35.45pt;
	mso-paper-source:0;}
div.Section1
	{page:Section1;}
-->
</style>
</head>

<body lang=EN-US style='tab-interval:.5in'>

<div class=Section1>
<rw:foreach id="gpolicy" src="G_POLICY">
<p class=MsoNormal><span style='font-size:9.0pt;font-family:"Arial Narrow";
mso-ansi-language:EN-US'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width=670
 style='width:502.5pt;border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:
 0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=670 valign=top style='width:502.45pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=right style='text-align:right'><span lang=RU>Приложение
  №3</span></p>
  <p class=MsoNormal align=right style='text-align:right'><span lang=RU>к
  Приказу <span class=GramE>от</span> __________ № ___________</span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='font-size:11.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><span lang=RU
  style='font-size:11.0pt;font-family:"Arial Narrow"'>ПРЕДВАРИТЕЛЬНЫЙ РАСЧЕТ 
  СТРАХОВОЙ ПРЕМИИ<o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:11.0pt;font-family:"Arial Narrow"'>Название
  юридического лица: <i style='mso-bidi-font-style:normal'><u>
  <rw:foreach id="gstr" src="G_STRAHOVATEL">
  <rw:field id="F_CONTACT_NAME" src="CONTACT_NAME"> &Field </rw:field>
  <o:p></o:p></u></i></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:11.0pt;font-family:"Arial Narrow"'>Контактное
  лицо (Ф.И.О., телефон, </span><span style='font-size:11.0pt;font-family:"Arial Narrow";
  mso-ansi-language:EN-US'>e</span><span lang=RU style='font-size:11.0pt;
  font-family:"Arial Narrow"'>-</span><span style='font-size:11.0pt;font-family:
  "Arial Narrow";mso-ansi-language:EN-US'>mail</span><span lang=RU
  style='font-size:11.0pt;font-family:"Arial Narrow"'>) <i style='mso-bidi-font-style:
  normal'><u>
  <rw:field id="F_TEL" src="TEL"> &Field </rw:field>
  <o:p></o:p></u></i></span></p>
  </rw:foreach>
  <p class=MsoNormal><span lang=RU style='font-size:11.0pt;font-family:"Arial Narrow"'>Общее
  число сотрудников ________________ Число страхуемых сотрудников <i
  style='mso-bidi-font-style:normal'><u>
  <rw:field id="F_CNT_TOT" src="CNT_TOT"> &Field </rw:field>
  <o:p></o:p></u></i></span></p>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal style='text-align:justify'><span lang=RU style='font-size:
  8.0pt;font-family:"Arial Narrow"'>Общее число страхуемых сотрудников не может
  быть менее<span style='mso-spacerun:yes'>  </span>5 и больше 50,<span
  style='mso-spacerun:yes'>  </span>не может быть менее 90% от численности
  всего коллектива. <o:p></o:p></span></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><u><span lang=RU
  style='font-size:9.0pt;font-family:"Arial Narrow"'><o:p><span
   style='text-decoration:none'>&nbsp;</span></o:p></span></u></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><u><span lang=RU
  style='font-size:9.0pt;font-family:"Arial Narrow"'>Инструкции для
  представителя ООО «СК «Ренессанс Жизнь»: <o:p></o:p></span></u></b></p>
  <p class=MsoNormal><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'>1.
  Впишите число лиц соответствующей возрастной категории, впишите страховые
  суммы. В незаполненных местах поставьте прочерки. <o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'>2.
  По каждой строке сложите страховые суммы, предварительно умноженные на число
  лиц, сложите полученные результаты, разделите полученную сумму на тариф,
  приведенный в строке. Полученный результат впишите в столбце «Сумма по
  строке»*.<o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'>4.
  Сложите результаты трех строк и впишите сумму в графу «Итого страховая премия
  по программе…».<o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'>5.
  Сложите общие страховые взносы по каждой программе и впишите сумму внизу
  страницы. <o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'>6.
  Убедитесь, что полученный результат устраивает будущего Страхователя, и Вы
  можете приступить к подготовке страховых документов. Окончательный расчет
  может быть осуществлен только на основании списков страхуемых лиц, содержащих
  информацию о точном возрасте. <o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'>7.
  Оставьте копию предварительного расчета будущему Страхователю.<span
  style='mso-spacerun:yes'>  </span><o:p></o:p></span></p>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
  font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=RU style='font-size:9.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width=670
 style='width:502.5pt;border-collapse:collapse;border:none;mso-border-alt:solid windowtext .5pt;
 mso-yfti-tbllook:480;mso-padding-alt:0in 5.4pt 0in 5.4pt;mso-border-insideh:
 .5pt solid windowtext;mso-border-insidev:.5pt solid windowtext'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
  <td width=670 colspan=10 valign=top style='width:502.5pt;border:solid windowtext 1.0pt;
  mso-border-alt:solid windowtext .5pt;background:silver;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:4.0pt;
  font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 <rw:foreach id="gdesc" src="G_DESCRIPTION">
 <rw:getValue id="prodDesc" src="DESCRIPTION"/> 
  <%

   if (prodDesc.indexOf("АЗ") != -1)      {progRow = 0;}
   if (prodDesc.indexOf("БУКИ") != -1)    progRow = 1;
   if (prodDesc.indexOf("ВЕДИ") != -1)    progRow = 2;
   if (prodDesc.indexOf("ГЛАГОЛЬ") != -1) progRow = 3;
   if (prodDesc.indexOf("ДОБРО") != -1)   progRow = 4;   

   double grAmount[][]  = {{0.0,0.0,0.0},{0.0,0.0,0.0},{0.0,0.0,0.0}};
   int grAssured[][] = {{0,0,0},{0,0,0},{0,0,0}};
   int i=0,j=0,k=0;
   double grTotFirst = 0.0;
   double grTotSecond = 0.0;
   double grTotThird = 0.0;
    
 %>
    <rw:foreach id="gptot" src="G_PROG_TOT">
        <rw:getValue id="ageGroup" src="AGE_GROUP"/>
        <rw:getValue id="amount" src="INS_AMOUNT"/>
        <rw:getValue id="assured" src="CNT"/>
     <%
      if  (ageGroup.equals("18-35") && i< 3) {
       grAmount[0][i] = Double.valueOf(amount).doubleValue();
       grAssured[0][i] = Integer.valueOf(assured).intValue();
       grTotFirst = grTotFirst + grAmount[0][i] * grAssured[0][i];
       i++;}
      if  (ageGroup.equals("36-45") && j< 3) {
       grAmount[1][j] = Double.valueOf(amount).doubleValue();
       grAssured[1][j] = Integer.valueOf(assured).intValue();
      grTotSecond = grTotSecond + grAmount[1][j] * grAssured[1][j];
       j++;}

      if  (ageGroup.equals("46-60") && k< 3) {
       grAmount[2][k] = Double.valueOf(amount).doubleValue();
       grAssured[2][k] = Integer.valueOf(assured).intValue();
       grTotThird = grTotThird + grAmount[2][k] * grAssured[2][k];
       k++;}

        
 %>
 </rw:foreach>
 <tr style='mso-yfti-irow:1'>
  <td width=670 colspan=10 valign=top style='width:502.5pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
  font-family:"Arial Narrow"'>Укажите число застрахованных лиц<span
  style='mso-spacerun:yes'>  </span>и страховые суммы (не менее 100&nbsp;000
  рублей и не более 1&nbsp;500&nbsp;000 рублей)<o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:2'>
  <td width=73 rowspan=4 valign=top style='width:54.7pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>
  <rw:field id="F_DESCRIPTION1" src="DESCRIPTION"> &Field </rw:field>
  <o:p></o:p></span></b></p>
  </td>
  <td width=75 valign=top style='width:56.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Возрастные группы<o:p></o:p></span></b></p>
  </td>
  <td width=40 valign=top style='width:30.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Число<o:p></o:p></span></b></p>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>лиц<o:p></o:p></span></b></p>
  </td>
  <td width=72 valign=top style='width:54.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-2.0pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Страховая сумма 1<o:p></o:p></span></b></p>
  </td>
  <td width=36 valign=top style='width:27.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Число<o:p></o:p></span></b></p>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>лиц<o:p></o:p></span></b></p>
  </td>
  <td width=74 valign=top style='width:55.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Страховая сумма 2<o:p></o:p></span></b></p>
  </td>
  <td width=34 valign=top style='width:25.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Число<o:p></o:p></span></b></p>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>лиц<o:p></o:p></span></b></p>
  </td>
  <td width=70 valign=top style='width:52.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Страховая сумма 3<o:p></o:p></span></b></p>
  </td>
  <td width=35 valign=top style='width:26.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Тариф<o:p></o:p></span></b></p>
  </td>
  <td width=160 valign=top style='width:119.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:8.0pt;
  font-family:"Arial Narrow"'>Сумма по строке*:</span></b><span lang=RU
  style='font-size:8.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:3'>
  <td width=75 valign=top style='width:56.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>18-35<o:p></o:p></span></b></p>
  </td>
  <td width=40 valign=top style='width:30.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt;text-align:center'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:10.0pt;font-family:"Arial Narrow"'>
  <%=grAssured[0][0]%>
  </span></b></p>
  </td>
  <td width=72 valign=top style='width:54.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
 <%=grAmount[0][0]%>
  </span></b></p>
  </td>
  <td width=36 valign=top style='width:27.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAssured[0][1]%>
  </span></b</p>
  </td>
  <td width=74 valign=top style='width:55.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAmount[0][1]%>
  </span></b></p>
  </td>
  <td width=34 valign=top style='width:25.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAssured[0][2]%>
  </span></b></p>
  </td>
  <td width=70 valign=top style='width:52.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.9pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAmount[0][2]%>
  </span></b></p>
  </td>
  <td width=35 valign=top style='width:26.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
  "Arial Narrow";mso-ansi-language:EN-US'>
  <%=tarif[progRow][0]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=160 valign=top style='width:119.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt';text-align:center>
  <p class=MsoNormal align=center style='margin-right:-6.9pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%= format.format(grTotFirst / tarif[progRow][0])%>
  <%premTot = premTot + grTotFirst / tarif[progRow][0];%>
  </span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:4'>
  <td width=75 valign=top style='width:56.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
  "Arial Narrow";mso-ansi-language:EN-US'>3</span></b><b style='mso-bidi-font-weight:
  normal'><span lang=RU style='font-size:10.0pt;font-family:"Arial Narrow"'>6-45<o:p></o:p></span></b></p>
  </td>
  <td width=40 valign=top style='width:30.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt;text-align:center'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:10.0pt;font-family:"Arial Narrow"'>
    <%=grAssured[1][0]%>
  </span></b></p>
  </td>
  <td width=72 valign=top style='width:54.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
    <%=grAmount[1][0]%>
  </span></b></p>
  </td>
  <td width=36 valign=top style='width:27.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAssured[1][1]%>
  </span></b></p>
  </td>
  <td width=74 valign=top style='width:55.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
    <%=grAmount[1][1]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=34 valign=top style='width:25.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAssured[1][2]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=70 valign=top style='width:52.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.9pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAmount[1][2]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=35 valign=top style='width:26.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
  "Arial Narrow";mso-ansi-language:EN-US'>
    <%=tarif[progRow][1]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=160 valign=top style='width:119.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.9pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%= format.format(grTotSecond / tarif[progRow][1])%>
  <%premTot = premTot + grTotSecond / tarif[progRow][1];%>
  <o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:5'>
  <td width=75 valign=top style='width:56.05pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt;text-align:center'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>46-60<o:p></o:p></span></b></p>
  </td>
  <td width=40 valign=top style='text-align:center;width:30.25pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:10.0pt;font-family:"Arial Narrow"'>
  <%=grAssured[2][0]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=72 valign=top style='width:54.2pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt;text-align:center'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAmount[2][0]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=36 valign=top style='width:27.1pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAssured[2][1]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=74 valign=top style='width:55.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAmount[2][1]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=34 valign=top style='width:25.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-5.4pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAssured[2][2]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=70 valign=top style='width:52.7pt;border-top:none;border-left:none;
  border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;background:#E6E6E6;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.9pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%=grAmount[2][2]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=35 valign=top style='width:26.45pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.95pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span style='font-size:10.0pt;font-family:
  "Arial Narrow";mso-ansi-language:EN-US'>
  <%=tarif[progRow][2]%>
  <o:p></o:p></span></b></p>
  </td>
  <td width=160 valign=top style='width:119.65pt;border-top:none;border-left:
  none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;
  mso-border-top-alt:solid windowtext .5pt;mso-border-left-alt:solid windowtext .5pt;
  mso-border-alt:solid windowtext .5pt;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='margin-right:-6.9pt;text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:10.0pt;
  font-family:"Arial Narrow"'>
  <%= format.format(grTotThird / tarif[progRow][2])%>
  <%premTot = premTot + grTotThird / tarif[progRow][0];%>
  <o:p></o:p></span></b></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:6'>
  <td width=670 colspan=10 valign=top style='width:502.5pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:9.0pt;font-family:"Arial Narrow"'>Итого страховая премия по
  <i style='mso-bidi-font-style:normal'>
  <rw:field id="F_DESCRIPTION1" src="DESCRIPTION"> &Field </rw:field>
   (сумма строк): </i></span></b><span
  lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'><o:p></o:p></span></p>
  </td>
 </tr>
 <tr style='mso-yfti-irow:7'>
  <td width=670 colspan=10 valign=top style='width:502.5pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  background:silver;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:4.0pt;
  font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
 </rw:foreach>
 <tr style='mso-yfti-irow:8;mso-yfti-lastrow:yes'>
  <td width=670 colspan=10 valign=top style='width:502.5pt;border:solid windowtext 1.0pt;
  border-top:none;mso-border-top-alt:solid windowtext .5pt;mso-border-alt:solid windowtext .5pt;
  padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:9.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
  <p class=MsoNormal><b style='mso-bidi-font-weight:normal'><span lang=RU
  style='font-size:9.0pt;font-family:"Arial Narrow"'>Страховая премия по всем
  программам страхования:    <o:p></o:p></span><span >
  <%=format.format(premTot)%>
  </span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>

<table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0
 style='border-collapse:collapse;mso-yfti-tbllook:480;mso-padding-alt:0in 5.4pt 0in 5.4pt'>
 <tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes;mso-yfti-lastrow:yes'>
  <td width=667 valign=top style='width:6.95in;padding:0in 5.4pt 0in 5.4pt'>
  <p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'>*
  = ( число лиц Х страховая сумма 1 + число лиц Х страховая сумма 2 + число лиц
  Х страховая сумма 3) / тариф<o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:11.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:11.0pt;font-family:"Arial Narrow"'>С
  предварительным расчетом согласен, прошу произвести окончательный расчет на
  основании списков страхуемых лиц и подготовить страховые документы. Подпись
  представителя Страхователя<span class=GramE> __________(___________________)</span><o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:11.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:11.0pt;font-family:"Arial Narrow"'>Дата
  предварительного расчета: <i style='mso-bidi-font-style:normal'><u>
  <%=sdf.format(new java.util.Date())%>
  </u></i><o:p></o:p></span></p>
  <p class=MsoNormal><span lang=RU style='font-size:11.0pt;font-family:"Arial Narrow"'>Подпись
  агента: ________________________________ Код агента: <i style='mso-bidi-font-style:
  normal'><u>
  <rw:foreach id="gag" src="G_AGENT_NUM">
  <rw:field id="f_num" src="NUM">&Field </rw:field>
  </rw:foreach>
  <o:p></o:p></u></i></span></p>
  <p class=MsoNormal align=center style='text-align:center'><b
  style='mso-bidi-font-weight:normal'><span lang=RU style='font-size:9.0pt;
  font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></b></p>
  </td>
 </tr>
</table>

<p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>

<p class=MsoNormal><span lang=RU style='font-size:8.0pt;font-family:"Arial Narrow"'><o:p>&nbsp;</o:p></span></p>
</rw:foreach>
</div>

</body>

</html>

</rw:report>
