CREATE OR REPLACE PACKAGE pkg_avoid_mutation IS

  -- Author  : ARTUR.BAYTIN
  -- Created : 11.10.2013 10:49:40
  -- Purpose : Пакет для обхода мутаций

  /*
    Переменная пакета для хранения названия обновляемой в настоящее время таблицы
    Используется в триггерах row-level:
    TR_P_POLICY_CONTACT_AUPD
    TR_AS_ASSURED_AUPD
    TR_AS_ASSURED_AUPDF
    TR_AS_INSURED_AUPD
    TR_AS_INSURED_AUPDF
  
    statement-level:
    TR_P_POLICY_CONTACT_ST_BUPD
    TR_P_POLICY_CONTACT_ST_AUPD
    TR_AS_ASSURED_ST_BUPD
    TR_AS_ASSURED_ST_AUPD
    TR_AS_INSURED_ST_BUPD
    TR_AS_INSURED_ST_AUPD
  */
  gv_table VARCHAR2(30);

END pkg_avoid_mutation;
/
CREATE OR REPLACE PACKAGE BODY pkg_avoid_mutation IS
BEGIN
  NULL;
END pkg_avoid_mutation;
/
