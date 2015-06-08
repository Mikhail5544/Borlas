CREATE OR REPLACE PACKAGE PKG_AGENT_UTILS IS

  FUNCTION GetNewSqAgContractHeader RETURN NUMBER;
  FUNCTION GetNewSqAgContract RETURN NUMBER;
  FUNCTION GetNewSqAgAttestDocument RETURN NUMBER;
  FUNCTION GetNewSqAgAttestDocCon RETURN NUMBER;
  FUNCTION GetNewSqAgRollHeader RETURN NUMBER;
  FUNCTION GetNewSqAgRoll RETURN NUMBER;

  FUNCTION GetDocTemplAgAttestDocument RETURN NUMBER;
  FUNCTION GetDocTemplAgRoll RETURN NUMBER;
  FUNCTION GetDocTemplAgRollHeader RETURN NUMBER;
  FUNCTION GetDocTemplAgPerfomedWorkAct RETURN NUMBER;

  FUNCTION GetNewSqAgPerfDet RETURN NUMBER;
  FUNCTION GetNewSqAgPerfDpol RETURN NUMBER;
  FUNCTION GetNewSqAgPerfDcov RETURN NUMBER;
  FUNCTION GetNewSqAgPerfAct RETURN NUMBER;

END PKG_AGENT_UTILS;
/
CREATE OR REPLACE PACKAGE BODY PKG_AGENT_UTILS IS

  FUNCTION GetNewSqAgContractHeader RETURN NUMBER IS
    ret_val NUMBER;
  BEGIN
    SELECT sq_ag_contract_header.nextval INTO ret_val FROM dual;
    RETURN ret_val;
  END GetNewSqAgContractHeader;

  FUNCTION GetNewSqAgContract RETURN NUMBER IS
    ret_val NUMBER;
  BEGIN
    SELECT sq_ag_contract.nextval INTO ret_val FROM dual;
    RETURN ret_val;
  END GetNewSqAgContract;

  FUNCTION GetNewSqAgAttestDocument RETURN NUMBER IS
    ret NUMBER;
  BEGIN
    SELECT SQ_AG_ATTEST_DOCUMENT.nextval INTO ret FROM dual;
    RETURN ret;
  END GetNewSqAgAttestDocument;

  FUNCTION GetNewSqAgAttestDocCon RETURN NUMBER IS
    ret NUMBER;
  BEGIN
    SELECT SQ_AG_ATTEST_DOC_CONT.nextval INTO ret FROM dual;
    RETURN ret;
  END GetNewSqAgAttestDocCon;

  FUNCTION GetNewSqAgRollHeader RETURN NUMBER IS
    ret NUMBER;
  BEGIN
  
    SELECT SQ_AG_ROLL_HEADER.nextval INTO ret FROM dual;
    RETURN ret;
  
  END GetNewSqAgRollHeader;

  FUNCTION GetNewSqAgRoll RETURN NUMBER IS
    ret NUMBER;
  BEGIN
  
    SELECT SQ_AG_ROLL.nextval INTO ret FROM dual;
    RETURN ret;
  
  END GetNewSqAgRoll;

  FUNCTION GetDocTemplAgAttestDocument RETURN NUMBER IS
    ret NUMBER;
  BEGIN
    SELECT DT.DOC_TEMPL_ID INTO ret FROM DOC_TEMPL DT WHERE DT.BRIEF = 'AG_ATTEST_DOCUMENT';
    RETURN ret;
  END GetDocTemplAgAttestDocument;

  FUNCTION GetDocTemplAgRoll RETURN NUMBER IS
    ret NUMBER;
  BEGIN
    SELECT DT.DOC_TEMPL_ID INTO ret FROM DOC_TEMPL DT WHERE DT.BRIEF = 'AG_ROLL';
    RETURN ret;
  END GetDocTemplAgRoll;

  FUNCTION GetDocTemplAgRollHeader RETURN NUMBER IS
    ret NUMBER;
  BEGIN
    SELECT DT.DOC_TEMPL_ID INTO ret FROM DOC_TEMPL DT WHERE DT.BRIEF = 'AG_ROLL_HEADER';
    RETURN ret;
  END GetDocTemplAgRollHeader;

  FUNCTION GetDocTemplAgPerfomedWorkAct RETURN NUMBER IS
    ret NUMBER;
  BEGIN
    SELECT DT.DOC_TEMPL_ID INTO ret FROM DOC_TEMPL DT WHERE DT.BRIEF = 'AG_PERFOMED_WORK_ACT';
    RETURN ret;
  END GetDocTemplAgPerfomedWorkAct;

  FUNCTION GetNewSqAgPerfDet RETURN NUMBER IS
    ret NUMBER;
  BEGIN
  
    SELECT sq_ag_perfom_work_det.nextval INTO ret FROM dual;
    RETURN ret;
  END GetNewSqAgPerfDet;

  FUNCTION GetNewSqAgPerfDpol RETURN NUMBER IS
    ret NUMBER;
  BEGIN
  
    SELECT sq_ag_perfom_work_dpol.nextval INTO ret FROM dual;
    RETURN ret;
  END GetNewSqAgPerfDpol;

  FUNCTION GetNewSqAgPerfDcov RETURN NUMBER IS
    ret NUMBER;
  BEGIN
  
    SELECT sq_ag_perf_work_dcover.nextval INTO ret FROM dual;
    RETURN ret;
  END GetNewSqAgPerfDcov;

  FUNCTION GetNewSqAgPerfAct RETURN NUMBER IS
    ret NUMBER;
  BEGIN
  
    SELECT sq_ag_perfomed_work_act.nextval INTO ret FROM dual;
    RETURN ret;
  END GetNewSqAgPerfAct;

END PKG_AGENT_UTILS;
/
