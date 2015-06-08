export ORACLE_HOME=/u01/oracle/product/AS
export ORACLE_SID=prod
export NLS_LANG=RUSSIAN_CIS.CL8MSWIN1251
$ORACLE_HOME/bin/sqlldr userid=ins/BycYtLjcnegty56@$ORACLE_SID  control=$1 data=$2 log=$2.log skip=1
