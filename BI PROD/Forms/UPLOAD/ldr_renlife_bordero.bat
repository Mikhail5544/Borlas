export ORACLE_HOME=/u01/oracle/product/AS
export ORACLE_SID=prod
export NLS_LANG=RUSSIAN_CIS.CL8MSWIN1251
/u01/oracle/product/AS/bin/sqlldr userid=ins/BycYtLjcnegty56@prod  control=$1 data=$2 log=$2.log
