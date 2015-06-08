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
	  val_4,
	  val_5,
	  val_6,
	  val_7,
	  val_8,
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
		<dataItem name="val_4" datatype="vchar2" columnOrder="15" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_4">
          <dataDescriptor expression="val_4" descriptiveExpression="val_4" order="4" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_5" datatype="vchar2" columnOrder="16" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_5">
          <dataDescriptor expression="val_5" descriptiveExpression="val_5" order="5" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_6" datatype="vchar2" columnOrder="17" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_6">
          <dataDescriptor expression="val_6" descriptiveExpression="val_6" order="6" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_7" datatype="vchar2" columnOrder="18" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_7">
          <dataDescriptor expression="val_7" descriptiveExpression="val_7" order="7" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="val_8" datatype="vchar2" columnOrder="18" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="val_8">
          <dataDescriptor expression="val_8" descriptiveExpression="val_8" order="8" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="row_status" datatype="vchar2" columnOrder="19" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="row_status">
          <dataDescriptor expression="row_status" descriptiveExpression="row_status" order="9" width="150"/>
          <dataItemPrivate adtName="" schemaName=""/>
        </dataItem>
		<dataItem name="row_comment" datatype="vchar2" columnOrder="20" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="row_comment">
          <dataDescriptor expression="row_comment" descriptiveExpression="row_comment" order="10" width="150"/>
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
 <col width=61 style='mso-width-source:userset;mso-width-alt:2230;width:120pt'>
 <col width=84 style='mso-width-source:userset;mso-width-alt:3072;width:63pt'>
 <col width=164 style='mso-width-source:userset;mso-width-alt:5997;width:123pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 <col width=110 style='mso-width-source:userset;mso-width-alt:4022;width:83pt'>
 
 <tr class=xl68 height=62 style='mso-height-source:userset;height:24pt'>
  <td colspan=10 height=62 class=xl73 width=741 style='height:24pt;width:557pt;border: 1px solid black;'>Отчет о загруженных записях</td>
 </tr>
 
 <tr height=40 style='height:30.0pt'>
  <td class=xl65 width=82 style='mso-width-source:userset;width:62pt;border: 1px solid black;'>#</td>
  <td class=xl65 width=87 style='mso-width-source:userset;width:65pt;border: 1px solid black;'>ИДС</td>
  <td class=xl65 width=61 style='mso-width-source:userset;width:46pt;border: 1px solid black;'>БИК</td>
  <td class=xl65 width=84 style='mso-width-source:userset;width:120pt;border: 1px solid black;'>Расчетный счет</td>
  <td class=xl65 width=164 style='mso-width-source:userset;width:123pt;border: 1px solid black;'>ИД причины расторжения</td>
  <td class=xl65 width=110 style='mso-width-source:userset;width:83pt;border: 1px solid black;'>Номер договора</td>
  <td class=xl65 width=105 style='mso-width-source:userset;width:79pt;border: 1px solid black;'>Страхователь</td>
  <td class=xl65 width=105 style='mso-width-source:userset;width:120pt;border: 1px solid black;'>Причина расторжения</td>
  <td class=xl65 width=105 style='mso-width-source:userset;width:79pt;border: 1px solid black;'>Статус строки</td>
  <td class=xl65 width=105 style='mso-width-source:userset;width:79pt;border: 1px solid black;'>Комментарий</td>
 </tr>
 
<rw:foreach id="fi2" src="G_val">
<rw:dataArea id="MGvalGRPFR54">
 <tr height=20 style='height:15.0pt'>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_1" src="val_1" nullValue="&nbsp;"> F_val_1 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_2" src="val_2" nullValue="&nbsp;"> F_val_2 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_3" src="val_3" nullValue="&nbsp;"> F_val_3 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_4" src="val_4" nullValue="&nbsp;"> F_val_4 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_5" src="val_5" nullValue="&nbsp;"> F_val_5 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_6" src="val_6" nullValue="&nbsp;"> F_val_6 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_7" src="val_7" nullValue="&nbsp;"> F_val_7 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_8" src="val_8" nullValue="&nbsp;"> F_val_8 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_9" src="row_status" nullValue="&nbsp;"> F_val_9 </rw:field></td>
  <td class=xl69 style='border: 1px solid black;'><rw:field id="f_val_10" src="row_comment" nullValue="&nbsp;"> F_val_10 </rw:field></td>
 </tr>
 </rw:dataArea> 
 </rw:foreach>
</table>

</body>

</html>
</rw:report>
