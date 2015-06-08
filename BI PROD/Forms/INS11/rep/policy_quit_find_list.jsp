<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %>
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="application/vnd.ms-excel;charset=windows-1251" %>
<%@ page import="java.text.*" %>

<rw:report id="report"> 
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="gate" DTDVersion="9.0.2.0.10" beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="GATE" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="P_LOAD_FILE_ID" datatype="number" width="10" precision="2"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select val_1,
	  val_2,
	  val_3,
	  pkg_load_file_to_table.get_status_desc(row_status) as row_status,
	  row_comment
	  from load_file_rows
	  where load_file_id = :P_LOAD_FILE_ID;]]>
      </select>
      <displayInfo x="1.65002" y="1.00000" width="0.69995" height="0.19995"/>
      <group name="G_val">
        <dataItem name="val_1" datatype="vchar2" columnOrder="12" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="Val_1">
          <dataDescriptor expression="val_1" descriptiveExpression="VAL_1" order="1" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_2" datatype="vchar2" columnOrder="13" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="Val_2">
          <dataDescriptor expression="val_2" descriptiveExpression="VAL_2" order="2" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_3" datatype="vchar2" columnOrder="14" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_3">
          <dataDescriptor expression="val_3" descriptiveExpression="val_3" order="3" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="row_status" datatype="vchar2" columnOrder="15" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="row_status">
          <dataDescriptor expression="row_status" descriptiveExpression="row_status" order="4" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="row_comment" datatype="vchar2" columnOrder="16" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="row_comment">
          <dataDescriptor expression="row_comment" descriptiveExpression="row_comment" order="5" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
      </group>
    </dataSource>
  </data>
  <programUnits>
    <function name="beforereport">
      <textSource>
      <![CDATA[function BeforeReport return boolean is
		begin
		  return (TRUE);
		end;]]>
      </textSource>
    </function>
  </programUnits>
  <reportPrivate defaultReportType="tabular" versionFlags2="0" templateName=""
  />
  <reportWebSettings>
  <![CDATA[]]>
  </reportWebSettings>
</report>
</rw:objects>

<html xmlns:v="urn:schemas-microsoft-com:vml"
xmlns:o="urn:schemas-microsoft-com:office:office"
xmlns:x="urn:schemas-microsoft-com:office:excel"
xmlns="http://www.w3.org/TR/REC-html40">

<head>
<meta http-equiv=Content-Type content="text/html; charset=windows-1251">
<meta name=ProgId content=Excel.Sheet>
<meta name=Generator content="Microsoft Excel 11">
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
 
 <tr class=xl68 height=62 style='mso-height-source:userset;height:46.5pt'>
  <td colspan=8 height=62 class=xl73 width=741 style='height:46.5pt;width:557pt;border: 1px solid black;'>Отчет о загруженных записях</td>
 </tr>
 
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 width=82 style='border: 1px solid black;width:62pt'>IDS</td>
  <td class=xl65 width=87 style='border: 1px solid black;width:65pt'>Номер договора</td>
  <td class=xl65 width=61 style='border: 1px solid black;width:46pt'>Страхователь</td>
  <td class=xl65 width=105 style='border: 1px solid black;width:79pt'>Статус строки</td>
  <td class=xl65 width=105 style='border: 1px solid black;width:79pt'>Комментарий</td>
 </tr>
 
<rw:foreach id="fi2" src="G_val">
<rw:dataArea id="MGvalGRPFR54">
 <tr height=20 style='height:15.0pt'>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_1" src="val_1" nullValue="&nbsp;"> F_val_1 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_2" src="val_2" nullValue="&nbsp;"> F_val_2 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_3" src="val_3" nullValue="&nbsp;"> F_val_3 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_8" src="row_status" nullValue="&nbsp;"> F_val_8 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_9" src="row_comment" nullValue="&nbsp;"> F_val_9 </rw:field></td>
 </tr>
 </rw:dataArea> 
 </rw:foreach>
</table>

</body>

</html>
</rw:report>
