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
	  val_7,
	  val_3,
	  val_2,
	  val_4,
	  val_6
	  from load_file_rows
	  where load_file_id = :P_LOAD_FILE_ID;]]>
      </select>
      <displayInfo x="1.65002" y="1.00000" width="0.69995" height="0.19995"/>
      <group name="G_val">
        <dataItem name="val_1" datatype="vchar2" columnOrder="12" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="Val_1">
          <dataDescriptor expression="val_1" descriptiveExpression="val_1" order="1" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_7" datatype="vchar2" columnOrder="13" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_7">
          <dataDescriptor expression="val_7" descriptiveExpression="val_7" order="2" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_3" datatype="vchar2" columnOrder="14" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_3">
          <dataDescriptor expression="val_3" descriptiveExpression="val_3" order="3" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_2" datatype="vchar2" columnOrder="15" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="Val_2">
          <dataDescriptor expression="val_2" descriptiveExpression="VAL_2" order="4" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_4" datatype="vchar2" columnOrder="16" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_4">
          <dataDescriptor expression="val_4" descriptiveExpression="val_4" order="5" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_6" datatype="vchar2" columnOrder="17" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_6">
          <dataDescriptor expression="val_6" descriptiveExpression="val_6" order="6" width="150"/>
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

<table x:str border=0 cellpadding=0 cellspacing=0 width=1037 style='border-collapse:
 collapse;table-layout:fixed;width:779pt'>
 <col width=82 style='mso-width-source:userset;mso-width-alt:2998;width:62pt'>
 <col width=231 style='mso-width-source:userset;mso-width-alt:8448;width:173pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 <col width=96 style='mso-width-source:userset;mso-width-alt:3510;width:72pt'>
 <col width=408 style='mso-width-source:userset;mso-width-alt:14921;width:306pt'>
 
 <tr class=xl68 height=62 style='mso-height-source:userset;height:24pt'>
  <td colspan=6 height=62 class=xl73 width=1037 style='height:24pt;width:779pt;border: 1px solid black;'>Отчет о загруженных записях</td>
 </tr>
 
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 width=82 style='mso-width-source:userset;width:62pt;border: 1px solid black;'>ИДС</td>
  <td class=xl65 width=231 style='mso-width-source:userset;width:173pt;border: 1px solid black;'>ФИО Страхователя</td>
  <td class=xl65 width=110 style='mso-width-source:userset;width:83pt;border: 1px solid black;'>Дата расторжения</td>
  <td class=xl65 width=110 style='mso-width-source:userset;width:83pt;border: 1px solid black;'>Дата акта</td>
  <td class=xl65 width=96 style='mso-width-source:userset;width:72pt;border: 1px solid black;'>Код причины расторжения</td>
  <td class=xl65 width=408 style='mso-width-source:userset;width:306pt;border: 1px solid black;'>Результат заливки</td>
 </tr>
 
<rw:foreach id="fi2" src="G_val">
<rw:dataArea id="MGvalGRPFR54">
 <tr height=20 style='height:15.0pt'>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_1" src="val_1" nullValue="&nbsp;"> F_val_1 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_7" src="val_7" nullValue="&nbsp;"> F_val_7 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_3" src="val_3" nullValue="&nbsp;"> F_val_3 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_2" src="val_2" nullValue="&nbsp;"> F_val_2 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_4" src="val_4" nullValue="&nbsp;"> F_val_4 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_6" src="val_6" nullValue="&nbsp;"> F_val_6 </rw:field></td>
 </tr>
 </rw:dataArea> 
 </rw:foreach>
</table>

</body>

</html>
</rw:report>
