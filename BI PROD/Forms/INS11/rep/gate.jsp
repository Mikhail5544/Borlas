<%@ taglib uri="/WEB-INF/lib/reports_tld.jar" prefix="rw" %> 
<%@ page language="java" import="java.io.*" errorPage="/rwerror.jsp" session="false" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<rw:report id="report"> 
<rw:objects id="objects">
<?xml version="1.0" encoding="WINDOWS-1251" ?>
<report name="gate" DTDVersion="9.0.2.0.10" beforeReportTrigger="beforereport">
  <xmlSettings xmlTag="GATE" xmlPrologType="text">
  <![CDATA[<?xml version="1.0" encoding="&Encoding"?>]]>
  </xmlSettings>
  <data>
    <userParameter name="datebirth" datatype="character" width="150"/>
    <userParameter name="sex" datatype="character" width="2"/>
    <userParameter name="sumaa" datatype="number" width="10" precision="2"/>
    <userParameter name="sumas" datatype="number" width="10" precision="2"/>
    <userParameter name="sumak" datatype="number" width="10" precision="2"/>
    <userParameter name="p_answer" datatype="character" width="2000"/>
    <dataSource name="Q_1">
      <select>
      <![CDATA[select :p_answer as val from dual;]]>
      </select>
      <displayInfo x="1.65002" y="1.00000" width="0.69995" height="0.19995"/>
      <group name="G_val">
        <dataItem name="val" datatype="vchar2" columnOrder="12" width="2000"
         defaultWidth="1500000" defaultHeight="10000" columnFlags="33"
         defaultLabel="Val">
          <dataDescriptor expression="val" descriptiveExpression="VAL" order="1" width="150"/>
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
		  sys.dbms_output.disable;
		  ins.pkg_http_gateway.calc_cache_surrender(par_birth_date       => :datebirth
											   ,par_gender           => :sex
											   ,par_aggressive_sum   => to_number(:sumaa)
											   ,par_balanced_sum     => to_number(:sumas)
											   ,par_conservative_sum => to_number(:sumak)
											   ,par_answer           => :p_answer);
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
<rw:dataArea id="MGvalGRPFR54">
  <rw:foreach id="RGval541" src="G_val">
    <rw:field id="Fval54" src="val" nullValue="&nbsp;"> F_val </rw:field>
  </rw:foreach>
</rw:dataArea>
</rw:report>
