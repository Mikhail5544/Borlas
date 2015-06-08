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
   <userParameter name="P_ROLL_ID"/>
   <userParameter name="P_HEADER_ID"/>
<userParameter name="p_arh_date_begin" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_arh_date_end" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_to_rep" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_print_date" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_report_number" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_kvl" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_kvg" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_all" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_kvl_char" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_kvg_report" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="p_another_format" datatype="number" precision="10"
     defaultWidth="0" defaultHeight="0"/>
	
<userParameter name="recruit_num" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="recruit_name" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="recruit_name_roma" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="orig_recruit_name" datatype="character" width="255"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="date_begin" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="contact_id" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>
<userParameter name="ag_contract_header_id" datatype="character" width="40"
    defaultWidth="0" defaultHeight="0"/>

	<dataSource name="Q_1">
      <select>
      <![CDATA[
		SELECT 1 rec_num, vcp.contact_id, nvl(ctr.brief,'@') doc_desc, NVL (ctr.serial_nr, '@') p_ser,
		         NVL (ctr.id_value, '@') p_num, NVL (ctr.place_of_issue, '@') pvidan,
		         DECODE (TO_CHAR (NVL (ctr.issue_date,
		                               TO_DATE ('01.01.1900', 'DD.MM.YYYY')
		                              ),
		                          'DD.MM.YYYY'
		                         ),
		                 '01.01.1900', '@',
		                 TO_CHAR (ctr.issue_date, 'DD.MM.YYYY')
		                ) data_v
		    FROM contact vcp,
		         (select cci.id_value,
		                 cci.place_of_issue,
		                 cci.serial_nr,
		                 cci.issue_date,
		                 tit.brief,
		                 cci.contact_id
		          from cn_contact_ident cci, 
		               t_id_type tit
		          WHERE cci.id_type = tit.ID
		          AND (UPPER (tit.brief) IN ('PASS_RF','PASS_IN') or tit.id = 20003)
		          AND cci.is_used = 1
		          ) ctr
		   WHERE vcp.contact_id = ctr.contact_id(+)
		     and vcp.contact_id = (SELECT agh.agent_id FROM ins.ag_contract_header agh WHERE agh.ag_contract_header_id = :P_HEADER_ID)
		ORDER BY NVL (ctr.issue_date, TO_DATE ('01.01.1900', 'DD.MM.YYYY')) DESC 
	   ]]>
      </select>
      <group name="G_1">
        <dataItem name="rec_num"/>
      </group>
    </dataSource>
<dataSource name="Q_2">
      <select>
      <![CDATA[
	    SELECT ROWNUM,
			   t.*
		FROM
		(
		SELECT 1 rec_num1,
			   tr.product,
			   tr.epg_date,
		       tr.pol_num,
		       tr.holder,
		       tr.payment_date,
		       tr.pay_period,
		       TO_CHAR(tr.trans_sum,'99999990D99') trans_sum,
			   tr.ins_period
		  FROM ins.RLA_SECOND_TRANS tr
		 WHERE 1=1
		   AND tr.ag_contract_header_id = :P_HEADER_ID
		   AND tr.trans_sum != 0
		ORDER BY tr.pol_num,tr.product ASC,tr.payment_date DESC
		) t
	   ]]>
      </select>
      <group name="G_2">
        <dataItem name="rec_num1"/>
      </group>
    </dataSource>
<dataSource name="Q_3">
      <select>
      <![CDATA[
	SELECT ROWNUM,
		   DENSE_RANK() OVER (ORDER BY t.pol_num_1,t.payment_date_1) p_num_pp,
		   t.*
	FROM
	(SELECT ROWNUM rec_num2,
		   cm.product product_1,
		   cm.epg_date,
    			 cm.pol_num pol_num_1,
    			 cm.holder holder_1,
    			 cm.payment_date payment_date_1,
    			 cm.pay_period pay_period_1, 
    			 cm.ins_period ins_period_1,
    			 TRIM(TO_CHAR(cm.vol_amount,'99999990D99')) vol_amount_1,
    			 TRIM(TO_CHAR(cm.vol_rate,'99999990D9999')) vol_rate_1,				 
    			 /*Чирков комментарий по заявке 223849
				 TRIM(TO_CHAR(cm.detail_commiss,'99999990D99')) detail_commiss_1,*/
    			 TRIM(TO_CHAR(cm.kvl,'99999990D99')) kvl_1,
    			 TRIM(TO_CHAR(cm.trans_sum,'99999990D99')) trans_sum_1
    FROM ins.RLA_SECOND_COMMISS cm
    WHERE cm.ag_contract_header_id = :P_HEADER_ID
	  --AND cm.vol_amount != 0
	ORDER BY cm.pol_num, cm.product ASC, cm.payment_date DESC
	) t
	   ]]>
      </select>
      <group name="G_3">
        <dataItem name="rec_num2"/>
      </group>
    </dataSource>
<dataSource name="Q_4">
      <select>
      <![CDATA[
    /*SELECT 0 rec_num3,
		   '' num_agent,
    	   '' name_agent,
    	   '' vol_kvl,
    	   '' detail_rate,
    	   '' detail_amt,
    	   '' detail_commis
    FROM DUAL UNION*/
	SELECT 0 rec_num3,
      /*LPAD(kvg.ag_header_num,6,'0') num_agent,*/
       kvg.ag_header_num num_agent,
	   kvg.ag_header_name name_agent,
       --TRIM(TO_CHAR(kvg.vol_kvl,'99999990D99')) vol_kvl,
	   kvg.vol_kvl vol_kvl,
       TRIM(TO_CHAR(kvg.ag_contract_header_tar,'99999990D99')) detail_rate,
       --TRIM(TO_CHAR(kvg.ag_header_tar,'99999990D99')) detail_amt,
	   kvg.ag_header_tar detail_amt,
	   kvg.vol_kvg detail_commis
       --TRIM(TO_CHAR(kvg.vol_kvg,'99999990D99')) detail_commis
FROM RLA_SECOND_KVG kvg
WHERE kvg.ag_contract_header_id = :P_HEADER_ID
UNION ALL
	SELECT 0 rec_num3,
		   /*LPAD(cm.num_agent,6,'0') num_agent,*/
		   cm.num_agent num_agent,
		   cm.name_agent,
		   NULL,
		   '10%' detail_rate,
		   --TRIM(TO_CHAR(cm.vol_amount,'99999990D99')) detail_amt,
		   cm.vol_amount detail_amt,
		   --TRIM(TO_CHAR(cm.detail_commiss,'99999990D99')) detail_commis
		   cm.detail_commiss
    FROM ins.RLA_SECOND_2089 cm
	WHERE :P_HEADER_ID = cm.ag_contract_header_id
	   ]]>
      </select>
      <group name="G_4">
        <dataItem name="rec_num3"/>
      </group>
    </dataSource>
  </data>
<programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
p_min_payment_date VARCHAR2(30);
p_max_payment_date VARCHAR2(30);
p_kvl_num NUMBER;
p_kvg_num NUMBER;
p_kvg_all NUMBER;
p_header NUMBER;
p_header_roma NUMBER;
begin

BEGIN
SELECT ROUND(nvl(SUM(kvl),0),2)
INTO p_kvl_num
FROM ins.RLA_SECOND_COMMISS cm
WHERE cm.ag_contract_header_id = :P_HEADER_ID;
EXCEPTION WHEN NO_DATA_FOUND THEN
	p_kvl_num := 0;
END;

BEGIN
SELECT agh.ag_contract_header_id
INTO p_header_roma
FROM ins.ven_ag_contract_header agh,
	 ins.document               d,
     ins.doc_status_ref         rf
WHERE agh.agent_id IN (SELECT ach.agent_id
                       FROM ins.ven_ag_contract_header ach
                       WHERE ach.num = '47975'
                       )
  AND agh.ag_contract_header_id = d.document_id
  AND d.doc_status_ref_id = rf.doc_status_ref_id
  AND rf.brief = 'CURRENT'
  AND agh.t_sales_channel_id IN (SELECT ch.id
                                 FROM ins.t_sales_channel ch
                                 WHERE ch.brief = 'RLA')
  AND agh.ag_contract_header_id = (SELECT MAX(ag.ag_contract_header_id)
                                   FROM ins.ag_contract_header ag
                                   WHERE ag.agent_id = (SELECT acha.agent_id
                                                        FROM ins.ven_ag_contract_header acha
                                                        WHERE acha.num = '47975')
                                   );
EXCEPTION WHEN NO_DATA_FOUND THEN
	p_header_roma := 0;
END;

select DECODE(:P_HEADER_ID,p_header_roma,1,0)
into :p_another_format
from dual;

BEGIN
SELECT nvl(SUM(r.detail_commiss),0)
INTO p_kvg_num
FROM ins.rla_second_2089 r
WHERE r.ag_contract_header_id = :P_HEADER_ID;
EXCEPTION WHEN NO_DATA_FOUND THEN
	p_kvg_num := 0;
END;

BEGIN
SELECT nvl(SUM(vol_kvg),0)
INTO p_kvg_all
FROM RLA_SECOND_KVG
WHERE ag_contract_header_id = :P_HEADER_ID;
EXCEPTION WHEN NO_DATA_FOUND THEN
	p_kvg_all := 0;
END;
:p_kvg_report := to_char(nvl(p_kvg_all + p_kvg_num,0),'99999990D99');

BEGIN
SELECT REPLACE(to_char(nvl(p_kvl_num,0),'99999990D99'),'.',','),
	   REPLACE(to_char(p_kvg_num + p_kvg_all,'99999990D99'),'.',','),
	   REPLACE(to_char(nvl(p_kvg_num + p_kvl_num + p_kvg_all,0),'99999990D99'),'.',','),
	   ins.pkg_utils.money2speech(nvl(ROUND(nvl(p_kvg_num + p_kvl_num + p_kvg_all,0),2),0),122)
INTO :p_kvl, :p_kvg, :p_all, :p_kvl_char
FROM DUAL;
EXCEPTION WHEN NO_DATA_FOUND THEN
	SELECT '0,00',
		   '0,00',
		   '0,00',
	   	   ins.pkg_utils.money2speech(0,122)
	INTO :p_kvl, :p_kvg, :p_all, :p_kvl_char
	FROM DUAL;
END;


BEGIN
SELECT rs.recruit_num,
	   rs.recruit_name,
	   rs.date_begin,
	   rs.contact_id,
	   rs.ag_contract_header_id,
	   rs.contact_type||pkg_contact.get_fio_fmt(rs.orig_recruit_name,4),
	   pkg_contact.get_fio_fmt(rs.orig_recruit_name,4)
INTO :recruit_num,
	 :recruit_name,
	 :date_begin,
	 :contact_id,
	 :ag_contract_header_id,
	 :orig_recruit_name,
	 :recruit_name_roma
FROM ins.RLA_SECOND_RECRUIT rs
WHERE rs.ag_contract_header_id = :P_HEADER_ID;
EXCEPTION WHEN NO_DATA_FOUND THEN
	:recruit_num := '';
	:recruit_name := '';
	:date_begin := '';
	:contact_id := 0;
	:ag_contract_header_id := 0;
	:orig_recruit_name := '';
	:recruit_name_roma := '';
END;

BEGIN
SELECT ins.pkg_utils.date2genitive_case(NVL(rl.date_end,arh.date_end)) arh_date_end,
	       TRIM(TO_CHAR(NVL(rl.date_end,arh.date_end),'MM')||'/'||TO_CHAR(NVL(rl.date_end,arh.date_end),'YYYY')) to_rep,
	       ins.pkg_utils.date2genitive_case(TRUNC(NVL(rl.date_end,arh.date_end),'MM')) arh_date_begin,
	       TRIM(TO_CHAR(SYSDATE,'DD.MM.YYYY')) print_date,
	       TRIM(TO_CHAR(NVL(rl.date_begin,arh.date_begin),'MM')) report_number
INTO :p_arh_date_end,
		 :p_to_rep,
	     :p_arh_date_begin,
		 :p_print_date,
		 :p_report_number
FROM ins.ven_ag_roll_header arh,
	     ins.ven_ag_roll rl
WHERE arh.ag_roll_header_id = rl.ag_roll_header_id
  AND rl.ag_roll_id = :P_ROLL_ID;
EXCEPTION WHEN NO_DATA_FOUND THEN
	:p_arh_date_end := '';
	:p_to_rep := '';
	:p_arh_date_begin := '';
	:p_print_date := '';
	:p_report_number := '';
END;

  	:p_arh_date_begin := :p_arh_date_begin;
  	:p_arh_date_end := :p_arh_date_end;
	
	  
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
	font-weight:700;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:silver;
	mso-pattern:auto none;
	white-space:nowrap;}
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
	text-align:center;
	border:.5pt solid windowtext;
	white-space:nowrap;}
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
.xl79
	{border:.5pt solid windowtext;}
.xl80
	{border-left:.5pt solid windowtext;
	border-right:.5pt solid windowtext;
	border-top:none;
	border-bottom:1.5pt solit windowstext;}
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
  int rec_count_current = 0;
%>

<body link=blue vlink=purple>

<table border=0 width=70 style='width:70.0pt;border:none'>
<col width=10 pre-wrap style='mso-width-source:userset;mso-width-alt:3254;width:67pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4827;width:99pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:5010;width:103pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4937;width:101pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4461;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:4498;width:92pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3657;width:75pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3254;width:67pt'>
 <col width=30 pre-wrap style='mso-width-source:userset;mso-width-alt:3401;width:70pt'>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'><b>Приложение №2</b></p></td></tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'><b>К СУБАГЕНТСКОМУ ДОГОВОРУ (ПРИСОЕДИНЕНИЯ) КАТЕГОРИИ RLA</b></p></td></tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr>
<td colspan=9><p style='text-align:center;font-size:12.0pt'><b>ОТЧЕТ СУБАГЕНТА <rw:field id="" src="recruit_num"></rw:field></b></p></td></tr>
<tr><td colspan=9><p style='text-align:center;font-size:12.0pt'><b>ЗА ПЕРИОД С <rw:field id="" src="p_arh_date_begin"/> ПО <rw:field id="" src="p_arh_date_end"/></b></p></td></tr>
<tr><td colspan=9><p style='text-align:center;font-size:12.0pt'>К СУБАГЕНТСКОМУ ДОГОВОРУ (ПРИСОЕДИНЕНИЯ) КАТЕГОРИИ RLA</p></td>
</tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=5><p style='text-align:left;font-size:12.0pt'>г. Москва</p></td>
<td colspan=4 style='mso-number-format:"dd\/mm\/yyyy";'><p style='text-align:right;font-size:12.0pt'><rw:field id="" src="p_print_date"/></p></td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<rw:getValue id="paf" src="p_another_format"/> 

<% if (paf.equals("1")) { %>

<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>
<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>1</b> За период с <rw:field id="" src="p_arh_date_begin"/> по <rw:field id="" src="p_arh_date_end"/> при посредничестве СУБАГЕНТА
были заключены следующие договоры страхования, по которым страховая премия (страховой взнос) была оплачена в полном объеме
и поступила на расчетный счет СТРАХОВЩИКА, а также по ранее заключенным договорам:</p></td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>
<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=3 pre-wrap rowspan=2 style='width:3.0pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p style='text-align:justify;font-size:10.0pt'></p><b>№ п/п</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p style='text-align:justify;font-size:10.0pt'></p><b>№ договора</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Страхователь (Ф.И.О.)</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Программа страхования</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Срок уплаты взносов</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Оплачиваемый год действия договора</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Дата оплаты</b></p></td>
<td width=7 pre-wrap rowspan=2 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Уплаченная страховая премия, руб</b></p></td>
<td width=7 pre-wrap colspan=2 style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Размер субагентского вознаграждения</b></p></td>
</tr>
<tr>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>В % от взноса (премии)</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>В рублях</b></p></td>
</tr>
<rw:foreach id="F3" src="G_3">
<tr>
<td width=3 pre-wrap valign=top style='width:3.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="p_num_pp"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="pol_num_1"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="holder_1"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="product_1"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="ins_period_1"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="pay_period_1"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"dd\/mm\/yyyy";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="payment_date_1"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="trans_sum_1"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:Percent;width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="vol_rate_1"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="kvl_1"/></td>
</tr>
</rw:foreach>

<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'>Итого вознаграждение СУБАГЕНТА за отчетный период составляет : <rw:field id="" src="p_kvl"/> (<rw:field id="" src="p_kvl_char"/>)</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<% } else { %>

<rw:foreach id="F1" src="G_1">

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'>Субагент, <rw:field id="" src="recruit_name"></rw:field> паспорт серия <rw:field id="" src="p_ser"></rw:field> № <rw:field id="" src="p_num"></rw:field>
выдан <rw:field id="" src="data_v"></rw:field> <rw:field id="" src="pvidan"></rw:field> с одной стороны и Агент
ООО "Ренессанс Лайф Актив", в лице Генерального директора Чернявского А.В., действующего на основании Устава,
с другой стороны, составили и утвердили настоящий Отчет Субагента за период <rw:field id="" src="p_arh_date_begin"/> по <rw:field id="" src="p_arh_date_end"/>
(Далее "Отчет") к СУБАГЕНТСКОМУ ДОГОВОРУ (ПРИСОЕДИНЕНИЯ) категории RLA о нижеследующем:</p></td>
</tr>

</rw:foreach>

<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>
<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>1</b> За период с <rw:field id="" src="p_arh_date_begin"/> по <rw:field id="" src="p_arh_date_end"/> при содействии Субагента
были заключены следующие договоры:</p></td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=7 pre-wrap style='width:7.0pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p style='text-align:justify;font-size:10.0pt'></p><b>№ договора</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Страхователь (Ф.И.О.)</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Программа страхования</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Длительность программы страхования</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Оплачиваемый год действия договора</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Дата оплаты</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
  border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
  solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Уплаченная страховая премия, руб</b></p></td>
</tr>
<rw:foreach id="F2" src="G_2">
<tr>
<td width=7 pre-wrap valign=top style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="pol_num"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="holder"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="product"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="ins_period"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="pay_period"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"dd\/mm\/yyyy";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="payment_date"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="trans_sum"/></td>
</tr>
</rw:foreach>

<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>2</b> Расчет вознаграждения к отчету Субагента
за период с <rw:field id="" src="p_arh_date_begin"/> по <rw:field id="" src="p_arh_date_end"/></p></td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>2.1</b> Комиссионное вознаграждение за Личный Объем (КВЛ)</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'>За указанный период Субагент получает вознаграждение за следующие договоры страхования, заключенные при его посредничестве:</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=7 pre-wrap style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>№ договора</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Страхователь</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Программа страхования</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ДП лет</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ОГД</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Уплаченная страховая премия, рубли</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Единицы</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>СКВ в рублях</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Вознаграждение (КВЛ) в рублях</b></p></td>
</tr>
<rw:foreach id="F3" src="G_3">
<tr>
<td width=7 pre-wrap valign=top style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="pol_num_1"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="holder_1"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="product_1"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="ins_period_1"/></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="pay_period_1"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="trans_sum_1"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="vol_amount_1"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="vol_rate_1"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="kvl_1"/></td>
</tr>
</rw:foreach>	
<tr>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'> </td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'> </td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'> </td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'> </td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'> </td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'> </td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'> </td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>Итого:</td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
   border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
   solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="p_kvl"/></td>
</tr>

<tr><td><p style='text-align:left;font-size:9.0pt'>Где:</p></td></tr>
<tr><td><p style='text-align:left;font-size:9.0pt'>ДП - длительность программы страхования, лет</p></td></tr>
<tr><td><p style='text-align:left;font-size:9.0pt'>ОГД - оплачиваемый год действия договора</p></td></tr>
<tr><td><p style='text-align:left;font-size:9.0pt'>СКВ - ставка комиссионного вознаграждения, руб.</p></td></tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>2.2</b> Комиссионное вознаграждение за групповой Объем (КВГ):</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=2 width=14 pre-wrap style='width:14.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Лично привлеченные (прямые) консультанты</b></p></td>
<td rowspan=2 width=7 pre-wrap style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Совокупный объем Единиц, набранных группой прямого консультанта СО</b></p></td>
<td rowspan=2 width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>СКВ в рублях</b></p></td>
<td rowspan=2 width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>СКВК в рублях</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Вознаграждение (КВГ) в рублях</b></p></td>
</tr>
<tr>
<td width=7 pre-wrap style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>ID</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Ф.И.О.</b></p></td>
<td width=7 pre-wrap style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>КВГ</b></p></td>
</tr>
<rw:foreach id="F4" src="G_4">
<tr>
<td width=7 pre-wrap valign=top style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="num_agent"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="name_agent"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="vol_kvl"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="detail_rate"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="detail_amt"/></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="detail_commis"/></td>
</tr>
</rw:foreach>
<tr>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'></td>
<td width=7 pre-wrap valign=top style='width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'></td>
<td width=7 pre-wrap valign=top style='mso-number-format:"@";width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'>Итого:</td>
<td width=7 pre-wrap valign=top style='mso-number-format:"0\.00";width:7.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt;padding:0cm 5.4pt 0cm 5.4pt'><rw:field id="" src="p_kvg_report"></rw:field></td>
</tr>

<tr><td><p style='text-align:left;font-size:9.0pt'>Где:</p></td></tr>
<tr><td><p style='text-align:left;font-size:9.0pt'>СО - структурный объем</p></td></tr>
<tr><td><p style='text-align:left;font-size:9.0pt'>СКВК - ставка комиссионного вознаграждения лично привлеченного (прямого) Субагента</p></td></tr>
<tr><td><p style='text-align:left;font-size:9.0pt'>СКВ - ставка комиссионного вознаграждения Субагента</p></td></tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>2.3</b> Итого размер комиссионного вознаграждения (КВ) за период <rw:field id="" src="p_arh_date_begin"/> по <rw:field id="" src="p_arh_date_end"/>
 составляет:</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td width=14 pre-wrap style='width:14.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Комиссионное вознаграждение за Личный Объем КВЛ (в рублях)</b></p></td>
<td width=14 pre-wrap style='width:14.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Комиссионное вознаграждение за Групповой Объем КВГ (в рублях)</b></p></td>
<td width=14 pre-wrap style='width:14.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b>Общая сумма комиссионного вознаграждения (в рублях)</b></p></td>
</tr>

<tr>
<td width=14 pre-wrap style='mso-number-format:"0\.00";width:14.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b><rw:field id="" src="p_kvl"/></b></p></td>
<td width=14 pre-wrap style='mso-number-format:"0\.00";width:14.0pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b><rw:field id="" src="p_kvg"/></b></p></td>
<td width=14 pre-wrap style='mso-number-format:"0\.00";width:14.0pt;padding:0cm 5.4pt 0cm 5.4pt;border:solid black 1.0pt;
 border-right:solid black .5pt;mso-border-top-alt:solid black .5pt;mso-border-left-alt:
 solid black .5pt;mso-border-bottom-alt:solid black .5pt'><p><b><rw:field id="" src="p_all"/></b></p></td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'>Итого вознаграждение Субагента за отчетный период составляет : <rw:field id="" src="p_kvl_char"/></td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>3</b> Указанная сумма вознаграждения  Субагента включает в себя все налоги и сборы,
 подлежащие оплате в соответствии с законодательством РФ.</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>4</b> Агент признает обязательства Субагента по Договору сотрудничества в период 
<rw:field id="" src="p_arh_date_begin"/> по <rw:field id="" src="p_arh_date_end"/> выполненными в полном объеме.</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>5</b> Субагент претензий к Агенту не имеет.</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<td colspan=9><p style='text-align:justify;font-size:12.0pt'><b>6</b> Настоящий Отчет Субагента составлен в двух экземплярях, имеющих равную юридическую силу для каждой из Сторон.</td>
</tr>
<tr><td colspan=9><p style='text-align:right;font-size:12.0pt'>&nbsp;</p></td></tr>

<% } %>

<rw:getValue id="af" src="p_another_format"/>

<tr style='mso-yfti-irow:0;mso-yfti-firstrow:yes'>
<tr><td colspan=5><p style='text-align:left;font-size:12.0pt'><b>Агент</b></p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'><b>Субагент</b></p></td>
</tr>
<tr><td colspan=5><p style='text-align:left;font-size:12.0pt'>Генеральный директор</p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'><% if (af.equals("1")) { %>Индивидуальный предприниматель<% } else { %> <% } %></p></td>
</tr>
<tr><td colspan=5><p style='text-align:left;font-size:12.0pt'>ООО "Ренессанс Лайф Актив"</p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'> </p></td>
</tr>
<tr><td colspan=5><p style='text-align:left;font-size:12.0pt'>_____________________ /А.В. Чернявский /</p></td>
<td colspan=4><p style='text-align:left;font-size:12.0pt'>_____________________ /<% if (af.equals("1")) { %><rw:field id="" src="recruit_name_roma"/><% } else { %><rw:field id="" src="orig_recruit_name"/><% } %> /</p></td>
</tr>
</table>


</body>

</html>


</rw:report>
