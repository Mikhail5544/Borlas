CREATE OR REPLACE PACKAGE "PKG_CONVERT_BLOGIC" AS
  /**
  * Пакет реализующий функции конвертации по отдельным сущностям.
  * <p>
  * Пакет содержит фукнции частичной проверки данных на целостность и функции конвертации.
  * <p>
  * Вызов функций из пакета осуществляется пакетом {@link PKG_CONVERT}
  * @author Surovtsev Alexey
  * @author Sheshko Andrei
  * @version 1.0
  * @headcom
  */

  /**
  * Функция загрузки выгодопреобретателей
  * @param p_valid не испольуется
  */
  FUNCTION FN_AS_BENEFICIARY(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция детальной ифнормации по выкупным суммам
  * @param p_valid не испольуется
  */
  FUNCTION FN_POLICY_CASH_SURR_D(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки заголовков по выкупным суммам
  * @param p_valid не испольуется
  */
  FUNCTION FN_POLICY_CASH_SURR(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки статусов по договорам страхования
  * @param p_valid не испольуется
  */
  FUNCTION FN_POLICY_STATUS(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки договоров
  * @param p_valid не испольуется
  */
  FUNCTION FN_P_POLICY(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки доверенностей по договорам с агентами
  * @param p_valid не испольуется
  */
  FUNCTION FN_AG_CONTRACT_DOVER(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки квартальных планов для агентов
  * @param p_valid не испольуется
  */
  FUNCTION FN_AG_PLAN_KV(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки истории статусов агентов
  * @param p_valid не испольуется
  */
  FUNCTION FN_AG_STATE(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки версий агенских договоров
  * @param p_valid не испольуется
  */
  FUNCTION FN_AG_CONTRACT(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки заголовков агенских договоров
  * @param p_valid не испольуется
  */
  FUNCTION FN_AG_HEADER(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки Ставки КВ по агенту по договору
  * @param p_valid не испольуется
  */
  FUNCTION FN_P_POL_AGENT_COM(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки агенств
  * @param p_valid не испольуется
  */
  FUNCTION FN_AGENCY(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки агенств по договору
  * @param p_valid не испольуется
  */
  FUNCTION FN_POLICY_AGENT(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки юридических контактов
  * @param p_valid не испольуется
  */
  FUNCTION FN_CONTACT_UR(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки физических контактов
  * @param p_valid не испольуется
  */
  FUNCTION FN_CONTACT_FIS(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки банков
  * @param p_valid не испольуется
  */
  FUNCTION FN_BANK(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки Таблица отношений застрахованных к группам
  * @param p_valid не испольуется
  */
  FUNCTION FN_ASSURED_GROUP(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки группы застрахованных
  * @param p_valid не испольуется
  */
  FUNCTION FN_P_ASSURED_GROUP(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки привязка программы к группе
  * @param p_valid не испольуется
  */
  FUNCTION FN_P_GROUP_PROD_LINE(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки договоров страхования
  * @param p_valid не испольуется
  */
  --FUNCTION  FN_POLIСY       (p_valid number)   RETURN NUMBER;

  /**
  * Функция загрузки контактов по договору
  * @param p_valid не испольуется
  */
  FUNCTION FN_POLIСY_CONTACT(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки начисления в разрезе покрытий
  * @param p_valid не испольуется
  */
  FUNCTION FN_POLICY_CHARGE(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки застрахованных объектов
  * @param p_valid не испольуется
  */
  FUNCTION FN_ASSET(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки покрытий
  * @param p_valid не испольуется
  */
  FUNCTION FN_COVER(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки страховых событий
  * @param p_valid не испольуется
  */
  FUNCTION FN_EVENT(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки заявления на оплату ущерба
  * @param p_valid не испольуется
  */
  FUNCTION FN_CLAIM(p_valid NUMBER) RETURN NUMBER;

  /**
  * Функция загрузки ущерба при страховом случае
  * @param p_valid не испольуется
  */
  FUNCTION FN_DAMAGE(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки БСО
  */
  FUNCTION FN_BSO(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки Акты по БСО
  */
  FUNCTION FN_BSO_ACT(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки Содержание актов по БСО
  */
  FUNCTION FN_BSO_DOC_CONT(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки Дат актов по БСО
  */
  FUNCTION FN_BSO_DOC_DATE(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки История БСО
  */
  FUNCTION FN_BSO_HISTORY(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки Плана оплат - Документ
  */
  FUNCTION FN_PLAN_PAYMENT_DOC(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки Плана оплат - Тразнакции
  */
  FUNCTION FN_PLAN_PAYMENT_TRANS(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки Оплаты - Документ
  */
  FUNCTION FN_FACT_PAYMENT_DOC(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура загрузки Оплаты - Тразнакции
  */
  FUNCTION FN_FACT_PAYMENT_TRANS(p_valid NUMBER) RETURN NUMBER;

  /**
  * Процедура проверки правильности заполнения юридических контактов
  */
  PROCEDURE FN_VALID_CONTACT_UR;

  /**
  * Процедура проверки правильности заполнения адресов
  */
  PROCEDURE FN_VALID_ADDRESSE;

  /**
  * Процедура проверки правильности заполнения агенских договоров
  */
  PROCEDURE FN_VALID_AG_HEADER;

  /**
  * Процедура проверки правильности  заполнения контактов по договору
  */
  PROCEDURE FN_VALID_P_POLICY_CONTACT;

  /**
  * Процедура проверки правильности  заполнения выкупных сумм
  */
  PROCEDURE FN_VALID_POLICY_CASH_SURR;

  /**
  * Процедура проверки правильности  заполнения застрахованных
  */
  PROCEDURE FN_VALID_AS_ASSET;

  /**
  * Функция получения ID документа по внешенму ключу и brief
  *
  * @param p_ext_id внешиний ключ
  * @param p_brief уникальный ключ сущности
  */
  FUNCTION GetDocument
  (
    p_ext_id NUMBER
   ,p_brief  VARCHAR2
  ) RETURN NUMBER;

  /**
  * Функция получения number
  *
  * @param p_str значение, например 111.2
  */
  FUNCTION S2N(p_str VARCHAR2) RETURN NUMBER;

  /**
  * Функция получения ID хобби
  *
  * @param p_str значение, например 'Другой'
  */
  FUNCTION GetHobby(p_str VARCHAR2) RETURN NUMBER;

  FUNCTION SetStatusDoc
  (
    p_from_status VARCHAR2
   ,p_to_status   VARCHAR2
   ,p_doc_id      INTEGER
   ,p_num         INTEGER
   ,p_curdate     DATE := SYSDATE
  ) RETURN NUMBER;

--  function GetEntId(p_brief varchar2) return number;
END PKG_CONVERT_BLogic;
/
CREATE OR REPLACE PACKAGE BODY "PKG_CONVERT_BLOGIC" AS
  /**
  * Загрузка данных по контрагентам
  *
  * @author Sheshko Andrei
  * @author Surovtsev Alexey
  * @version 1.1
  */

  /*
   внутренние функции
  */

  /*  cursor cur_rol(c_ext_policy_id number)  is
  select t.*,rowid as rrw from CONVERT_POLICY_LINK t where t.EXT_POLICY_ID = c_ext_policy_id;*/

  CURSOR cur_convert_asset IS
    SELECT t.*
          ,ROWID AS rrw
      FROM ins.cnv_asset t;

  CURSOR cur_cnv_p_cover IS
    SELECT t.*
          ,ROWID AS rrw
      FROM ins.CONVERT_P_COVER t;

  CURSOR cur_event IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.cnv_c_event c;

  CURSOR cur_event_contact IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.cnv_c_event_contact c;

  CURSOR cur_claim IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.cnv_c_claim c
     WHERE c.HEAD_EXT_ID IS NULL;

  CURSOR cur_claim_add IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.cnv_c_claim c
     WHERE c.HEAD_EXT_ID IS NOT NULL
     ORDER BY SEQNO ASC;

  CURSOR cur_damage IS
    SELECT d.*
          ,ROWID AS rrw
      FROM ins.cnv_c_damage d;

  CURSOR cur_agency IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.convert_agency c;

  CURSOR cur_ag_HEADER IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_AG_HEADER c;

  CURSOR cur_AG_CONTRACT IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_AG_CONTRACT c
     ORDER BY c.EXT_ID ASC;

  CURSOR cur_AG_STATE IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_AG_STATE c
     ORDER BY c.EXT_ID ASC;

  CURSOR cur_AG_PLAN_KV IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_AG_PLAN_KV c
     ORDER BY c.EXT_ID ASC;

  CURSOR cur_AG_CONTRACT_DOVER IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_AG_CONTRACT_DOVER c
     ORDER BY c.EXT_ID ASC;

  CURSOR cur_P_POLICY IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_P_POLICY c
     ORDER BY c.EXT_ID ASC;

  CURSOR cur_POLICY_STATUS IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_POLICY_STATUS c
     ORDER BY c.EXT_POLICY_ID
             ,c.DOC_STATUS_ID;

  CURSOR cur_policy_cash_surr IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_policy_cash_surr c
     ORDER BY c.EXT_ID;

  CURSOR cur_policy_cash_surr_d IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_policy_cash_surr_d c
     ORDER BY c.EXT_ID;

  CURSOR cur_AS_BENEFICIARY IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_AS_BENEFICIARY c
     ORDER BY c.EXT_ID;

  CURSOR cur_contact_clear IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONTACT c
     WHERE c.EXT_ID IS NOT NULL;

  CURSOR cur_contact_UR IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_CONTACT_UR c;

  CURSOR cur_contact_FIS IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_CONTACT_FIS c;

  CURSOR cur_contact_bank IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_BANK c;

  CURSOR cur_policy_contact IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_P_POLICY_CONTACT c;

  CURSOR cur_as_asset IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_AG_ASSET c;

  CURSOR cur_policy_charge IS
    SELECT c.*
          ,ROWID AS rrw
      FROM ins.CONVERT_POLICY_CHARGE c
     ORDER BY c.P_POLICY_ID         ASC
             ,c.AS_ASSET_ASSURED_ID ASC
             ,c.P_COVER_ID          ASC;

  /* получение COUNTRY_ID по COUNTRY_CODE */
  FUNCTION FN_GET_ID_COUNTRY
  (
    p_country_code NUMBER
   ,p_res          OUT NUMBER
  ) RETURN NUMBER IS
    CURSOR cur_country(c_contry_code NUMBER) IS
      SELECT * FROM T_COUNTRY t WHERE t.COUNTRY_CODE = c_contry_code;
  
    rec_country cur_country%ROWTYPE;
  BEGIN
    OPEN cur_country(p_country_code);
    FETCH cur_country
      INTO rec_country;
  
    pkg_convert.Raise_ExB(cur_country%NOTFOUND, TRUE);
    CLOSE cur_country;
  
    p_res := rec_country.ID;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      IF (cur_country%ISOPEN)
      THEN
        CLOSE cur_country;
      END IF;
      pkg_convert.SP_EventError('ошибка при конвертации объектов'
                               ,'pkg_convert_blogic'
                               ,'FN_GET_ID_COUNTRY'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN PKG_CONVERT.c_exept;
  END FN_GET_ID_COUNTRY;

  FUNCTION FN_INSERT_ADDRESSE
  (
    p_ext_id_contact VARCHAR2
   ,p_contact_id     NUMBER
  ) RETURN NUMBER IS
  
    CURSOR cur_add(c_contact_ext_id VARCHAR2) IS
      SELECT * FROM convert_addresse t WHERE t.CONTACT_EXT_ID = c_contact_ext_id;
  
    sq_addres NUMBER;
    sq_val    NUMBER;
  BEGIN
  
    FOR rec IN cur_add(p_ext_id_contact)
    LOOP
      SELECT INS.SQ_CN_ADDRESS.nextval INTO sq_addres FROM dual;
    
      INSERT INTO INS.CN_ADDRESS
        (ID, COUNTRY_ID, NAME, REMARKS, EXT_ID)
      VALUES
        (sq_addres, rec.country_id, rec.ADR_NAME, rec.ADR_REMARKS, rec.EXT_ID);
    
      SELECT INS.SQ_CN_CONTACT_ADDRESS.nextval INTO sq_val FROM dual;
      INSERT INTO INS.CN_CONTACT_ADDRESS
        (ID, CONTACT_ID, ADDRESS_TYPE, ADRESS_ID, EXT_ID)
      VALUES
        (sq_val, p_contact_id, rec.ADDRESS_TYPE_ID, sq_addres, rec.EXT_ID);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации адреса'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_INSERT_ADDRESSE'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_INSERT_ADDRESSE;

  FUNCTION GetDocument
  (
    p_ext_id NUMBER
   ,p_brief  VARCHAR2
  ) RETURN NUMBER IS
    CURSOR cur_document
    (
      c_ext_id NUMBER
     ,c_brief  VARCHAR2
    ) IS
      SELECT d.*
        FROM ins.document  d
            ,ins.doc_templ dt
       WHERE dt.DOC_TEMPL_ID = d.DOC_TEMPL_ID
         AND dt.BRIEF = P_brief
         AND d.ext_id = p_ext_id;
  
    rec_document cur_document%ROWTYPE;
  
    l_val NUMBER := NULL;
  BEGIN
  
    OPEN cur_document(p_ext_id, p_brief);
    FETCH cur_document
      INTO rec_document;
  
    IF (cur_document%FOUND)
    THEN
      l_val := rec_document.document_id;
    END IF;
    CLOSE cur_document;
    RETURN l_val;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при поиске документа'
                               ,'PKG_CONVERT_BLogic'
                               ,'GetDocument'
                               ,SQLCODE
                               ,SQLERRM);
      RAISE;
  END GetDocument;

  /* function insert_ppolicy(rec cur_convert_policy%rowtype, p_sq_pol_header number,p_sq_pol out number) return number
  is
   sq_doc_status number;
   sq_pol_cont   number;
   l_EXIT_ID   NUMBER;
  begin
     l_EXIT_ID := rec.EXT_ID;
      select ins.sq_document.nextval into p_sq_pol from dual;
      insert into VEN_P_POLICY (POL_HEADER_ID,
                                     POLICY_ID,
                                     DOC_TEMPL_ID,
                                     NUM,
                                     REG_DATE,
                                     END_DATE,
                                     PAYMENT_TERM_ID,
                                     PERIOD_ID,
                                     START_DATE,
                                     VERSION_NUM,
                                     FILIAL_ID,
                                     EXT_ID,
                                     DOC_FOLDER_ID,
                                     NOTE,
                                     ADMIN_COST,
                                     COMPENSATION_LIMIT,
                                     CONFIRM_DATE,
                                     DECLINE_DATE,
                                     DECLINE_INITIATOR_ID,
                                     DECLINE_REASON_ID,
                                     DECLINE_SUMM,
                                     FACT_J,
                                     FEE_PAYMENT_TERM,
                                     FIRST_PAY_DATE,
                                     INS_AMOUNT,
                                     ISSUE_DATE,
                                     IS_CHARGE,
                                     IS_COMISSION,
                                     IS_DECLINE_CHANGED,
                                     IS_LISING,
                                     NOTICE_DATE,
                                     OSAGO_SIGN_NUM,
                                     OSAGO_SIGN_SER,
                                     PAYMENTOFF_TERM_ID,
                                     POL_NUM,
                                     POL_SER,
                                     PREMIUM,
                                     SIGN_DATE,
                                     T_CASCO_PROGRAMM_END,
                                     T_CASCO_PROGRAMM_ID,
                                     T_CASCO_PROGRAMM_START,
                                     T_CASCO_PROG_CARD_NUMBER )
                     values(
                           p_sq_pol_header,
                         p_sq_pol,
                         /*rec.DOC_TEMPL_ID*/
  /*(select T.DOC_TEMPL_ID from ins.DOC_TEMPL T where UPPER(T.BRIEF) = UPPER('POLICY')),
  rec.NUM,
  rec.REG_DATE,
  rec.END_DATE,
  rec.PAYMENT_TERM_ID,
  rec.PERIOD_ID,
  rec.START_DATE,
  rec.VERSION_NUM,
  rec.FILIAL_ID,
  rec.EXT_ID,
  /*rec.DOC_FOLDER_ID*/
  /*NULL,
                         rec.NOTE,
                         rec.ADMIN_COST,
                         rec.COMPENSATION_LIMIT,
                         rec.CONFIRM_DATE,
                         rec.DECLINE_DATE,
                         rec.DECLINE_INITIATOR_ID,
                         rec.DECLINE_REASON_ID,
                         rec.DECLINE_SUMM,
                         rec.FACT_J,
                         rec.FEE_PAYMENT_TERM,
                         rec.FIRST_PAY_DATE,
                         rec.INS_AMOUNT,
                         rec.ISSUE_DATE,
                         rec.IS_CHARGE,
                         rec.IS_COMISSION,
                         rec.IS_DECLINE_CHANGED,
                         rec.IS_LISING,
                         rec.NOTICE_DATE,
                         rec.OSAGO_SIGN_NUM,
                   rec.OSAGO_SIGN_SER,
       rec.PAYMENTOFF_TERM_ID,
       rec.POL_NUM,
       rec.POL_SER,
       rec.PREMIUM,
       rec.SIGN_DATE,
       rec.T_CASCO_PROGRAMM_END,
       rec.T_CASCO_PROGRAMM_ID,
       rec.T_CASCO_PROGRAMM_START,
       rec.T_CASCO_PROG_CARD_NUMBER );
  
      for rec_p in cur_rol(rec.EXT_ID)
      loop
        select ins.sq_P_POLICY_CONTACT.nextval into sq_pol_cont from dual;
     insert into ins.P_POLICY_CONTACT (ID, CONTACT_ID, CONTACT_POLICY_ROLE_ID, POLICY_ID)
       values(sq_pol_cont,
       (select T.CONTACT_ID from ins.VEN_CONTACT T where T.ext_id = rec_p.EXT_KONTR_ID),
        rec_p.EXT_POLICY_ROLY_ID,
        p_sq_pol);
      end loop;
  
      select  ins.sq_doc_status.nextval into sq_doc_status from dual;
  
      insert into doc_status(DOC_STATUS_ID,DOCUMENT_ID,DOC_STATUS_REF_ID,START_DATE)
           values(sq_doc_status,p_sq_pol,rec.DOC_STATUS_REF_ID,rec.SIGN_DATE);
  
      update ins.ven_p_pol_header t set t.POLICY_ID = p_sq_pol
     where t.POLICY_HEADER_ID = p_sq_pol_header;
  
   pkg_convert.UpdateConvert('ins.convert_policy',rec.rrw);
  
  return pkg_convert.c_true;
  exception
    when others then
       pkg_convert.SP_EVENTERROR('ошибка при вставке договора','PKG_CONVERT_BLogic','insert_ppolicy',sqlcode,sqlerrm);
       if (cur_rol%isopen)then
       close cur_rol;
    end if;
    return pkg_convert.c_exept;
  end insert_ppolicy;
  */

  FUNCTION FN_POLIСY_CONTACT(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO VEN_P_POLICY_CONTACT
      (CONTACT_ID, CONTACT_POLICY_ROLE_ID, POLICY_ID)
      SELECT (SELECT V.CONTACT_ID FROM ins.VEN_CONTACT V WHERE V.EXT_ID = c.EXT_KONTR_ID)
            ,C.EXT_POLICY_ROLY_ID
            ,(SELECT V.POLICY_ID FROM ins.VEN_P_POLICY V WHERE V.EXT_ID = c.EXT_POLICY_ID)
        FROM CONVERT_P_POLICY_CONTACT C;
  
    INSERT INTO VEN_CN_CONTACT_ROLE C
      (ID, CONTACT_ID, ROLE_ID, EXT_ID)
      SELECT SQ_CN_CONTACT_ROLE.NEXTVAL
            ,BB.contact_ID
            ,BB.EXT_POLICY_ROLY_ID
            ,BB.contact_ID || '_' || BB.EXT_POLICY_ROLY_ID
        FROM (SELECT A.contact_ID
                    ,(SELECT TC.ID AS POL_ROLE_CODE
                        FROM t_contact_pol_role tp
                            ,t_contact_role     tc
                       WHERE tp.description = tc.description
                         AND tp.ID = A.EXT_POLICY_ROLY_ID) AS EXT_POLICY_ROLY_ID
                FROM (SELECT DISTINCT cn.contact_ID
                                     ,c.EXT_POLICY_ROLY_ID
                        FROM CONVERT_P_POLICY_CONTACT c
                            ,CONTACT                  cn
                       WHERE cn.EXT_ID = c.EXT_KONTR_ID) A
               WHERE NOT EXISTS (SELECT 1
                        FROM ins.CN_CONTACT_ROLE C
                       WHERE C.ROLE_ID = A.EXT_POLICY_ROLY_ID
                         AND C.contact_id = A.contact_ID)) BB;
  
    DELETE FROM cn_contact_role c
     WHERE c.ID IN (SELECT ID
                      FROM (SELECT COUNT(*) OVER(PARTITION BY contact_id, role_id ORDER BY ID) qty
                                  ,contact_id
                                  ,role_id
                                  ,ID
                              FROM cn_contact_role) A
                     WHERE A.qty > 1);
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EVENTERROR('ошибка при вставке контакта к договору'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_POLIСY_CONTACT'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_exept;
  END FN_POLIСY_CONTACT;

  FUNCTION FN_CONTACT_UR(p_valid NUMBER) RETURN NUMBER IS
    CURSOR cur_bank
    (
      P_BIK  VARCHAR2
     ,P_KORR VARCHAR2
     ,P_INN  VARCHAR2
     ,P_NAME VARCHAR2
    ) IS
      WITH doc_sel AS
       (SELECT UPPER(tt.BRIEF) AS BRIEF
              ,cci.CONTACT_ID
              ,cci.ID_VALUE
          FROM ins.cn_contact_ident cci
              ,ins.t_id_type        tt
         WHERE cci.id_type = tt.id)
      SELECT c.NAME
            ,doc_korr.ID_VALUE AS KORR_VALUE
            ,doc_inn.ID_VALUE  AS INN_VALUE
            ,doc_bik.ID_VALUE  AS BIK_VALUE
            ,c.CONTACT_ID
        FROM ins.contact c
            ,doc_sel     doc_korr
            ,doc_sel     doc_bik
            ,doc_sel     doc_inn
       WHERE doc_korr.BRIEF = UPPER('KORR')
         AND doc_bik.BRIEF = UPPER('BIK')
         AND doc_inn.BRIEF = UPPER('INN')
         AND c.CONTACT_ID = doc_inn.CONTACT_ID
         AND c.CONTACT_ID = doc_korr.CONTACT_ID
         AND c.CONTACT_ID = doc_bik.CONTACT_ID
         AND doc_korr.ID_VALUE = P_KORR
         AND doc_bik.ID_VALUE = P_BIK
         AND doc_inn.ID_VALUE = P_INN
         AND c.name = P_NAME
         AND rownum = 1;
  
    l_res            NUMBER;
    rec_bank         cur_bank%ROWTYPE;
    rev_val          NUMBER(1) := 0;
    sq_contact       NUMBER;
    sq_addres        NUMBER;
    sq_val           NUMBER;
    cotnact_is       NUMBER := 0;
    name_tabl        VARCHAR2(30);
    name_contact     VARCHAR2(255);
    ID_TYPE          NUMBER(9);
    inn_contact      VARCHAR2(20);
    id_fund          NUMBER(9);
    id_fund_acc_bank NUMBER(9);
    id_country       NUMBER(9);
    id_country_tel   NUMBER(9);
    l_EXIT_ID        NUMBER;
  
    PROCEDURE insert_tel
    (
      p_TELEPHONE_COUNTRY_ID NUMBER
     ,p_TELEPHONE_PREFIX     VARCHAR2
     ,p_TELEPHONE_NUMBER     VARCHAR2
     ,P_TELEPHONE_EXTENSION  VARCHAR2
     ,P_TELEPHONE_REMARKS    VARCHAR2
     ,P_TELEPHONE_TYPE       NUMBER
    ) IS
    BEGIN
      SELECT INS.SQ_CN_CONTACT_TELEPHONE.nextval INTO sq_val FROM dual;
    
      INSERT INTO INS.CN_CONTACT_TELEPHONE
        (ID
        ,CONTACT_ID
        ,COUNTRY_ID
        ,TELEPHONE_TYPE
        ,TELEPHONE_PREFIX
        ,TELEPHONE_NUMBER
        ,TELEPHONE_EXTENSION
        ,REMARKS
        ,ENT_ID)
      VALUES
        (sq_val
        ,sq_contact
        ,(SELECT T.ID FROM T_COUNTRY_DIAL_CODE T WHERE t.COUNTRY_ID = P_TELEPHONE_COUNTRY_ID)
        ,P_TELEPHONE_TYPE
        ,P_TELEPHONE_PREFIX
        ,P_TELEPHONE_NUMBER
        ,P_TELEPHONE_EXTENSION
        ,P_TELEPHONE_REMARKS
        ,221);
    END;
  
    PROCEDURE insert_doc
    (
      p_brief   VARCHAR2
     ,p_contact NUMBER
     ,p_val     VARCHAR2
     ,p_country NUMBER
    ) IS
    BEGIN
      INSERT INTO CN_CONTACT_IDENT
        (TABLE_ID, CONTACT_ID, ID_TYPE, ID_VALUE, COUNTRY_ID)
      VALUES
        (SQ_CN_CONTACT_IDENT.nextval
        ,p_contact
        ,(SELECT T.ID FROM INS.T_ID_TYPE T WHERE UPPER(T.BRIEF) = UPPER(p_brief))
        ,p_val
        ,p_country);
    END insert_doc;
  
    PROCEDURE insert_account
    (
      p_bik        VARCHAR2
     ,p_inn        VARCHAR2
     ,p_korr       VARCHAR2
     ,p_name_bank  VARCHAR2
     ,p_acc_number VARCHAR2
     ,p_acc_notice VARCHAR2
     ,p_contact    NUMBER
     ,p_fund       NUMBER
    ) IS
    BEGIN
      OPEN cur_bank(p_bik, p_korr, p_inn, p_name_bank);
      FETCH cur_bank
        INTO rec_bank;
      pkg_convert.Raise_ExB(cur_bank%NOTFOUND, TRUE);
      CLOSE cur_bank;
    
      INSERT INTO INS.CN_CONTACT_BANK_ACC
        (ID
        ,CONTACT_ID
        ,BANK_ID
        ,ACCOUNT_NR
        ,BANK_ACCOUNT_CURRENCY_ID
        ,bank_name
        ,bic_code
        ,account_corr
        ,remarks)
      VALUES
        (INS.SQ_CN_CONTACT_BANK_ACC.nextval
        ,p_contact
        ,rec_bank.contact_id
        ,p_acc_number
        ,(SELECT f.FUND_ID FROM ins.fund f WHERE f.code = p_fund)
        ,p_name_bank
        ,p_bik
        ,p_korr
        ,p_acc_notice);
    EXCEPTION
      WHEN pkg_convert.res_exception THEN
        CLOSE cur_bank;
        RETURN;
    END insert_account;
  
  BEGIN
    FOR rec IN cur_contact_UR
    LOOP
      name_contact := rec.NAME;
      inn_contact  := rec.INN;
      l_EXIT_ID    := rec.EXT_ID;
      l_res        := pkg_convert.c_true;
    
      SELECT f.FUND_ID INTO id_fund FROM ins.fund f WHERE f.CODE = rec.CURRENCY_ID;
    
      id_country := 643;
    
      IF (l_res = pkg_convert.c_true)
      THEN
      
        SELECT ins.sq_contact.nextval INTO sq_contact FROM dual;
      
        INSERT INTO INS.CONTACT
          (CONTACT_ID, NAME, SHORT_NAME, RESIDENT_FLAG, T_CONTACT_STATUS_ID, CONTACT_TYPE_ID, EXT_ID)
        VALUES
          (sq_contact
          ,rec.NAME
          ,rec.SHORT_NAME
          ,rec.RESIDENT_FLAG
          ,1
          ,rec.TYPE_CONTACT_ID
          ,rec.EXT_ID);
      
        IF (rec.TELEPHONE_NUMBER IS NOT NULL)
        THEN
          insert_tel(643, NULL, rec.TELEPHONE_NUMBER, NULL, NULL, rec.TELEPHONE_TYPE);
        END IF;
      
        IF (rec.INN IS NOT NULL)
        THEN
          insert_doc('INN', sq_contact, rec.INN, id_country);
        
          INSERT INTO INS.CN_COMPANY
            (CONTACT_ID, WEB_SITE, CURRENCY_ID)
          VALUES
            (sq_contact, NULL, id_fund);
        END IF;
      
        IF (rec.KPP IS NOT NULL)
        THEN
          insert_doc('KPP', sq_contact, rec.KPP, id_country);
        END IF;
      
        IF (rec.OKPO IS NOT NULL)
        THEN
          insert_doc('OKPO', sq_contact, rec.OKPO, id_country);
        END IF;
      
        IF (FN_INSERT_ADDRESSE(rec.Ext_ID, sq_contact) <> pkg_convert.c_true)
        THEN
          RETURN pkg_convert.c_false;
        END IF;
      
        IF (rec.num_account IS NOT NULL)
        THEN
          insert_account(rec.acc_bik_bank
                        ,rec.acc_inn_bank
                        ,rec.acc_korr_bank
                        ,rec.acc_name_bank
                        ,rec.num_account
                        ,rec.account_notice
                        ,sq_contact
                        ,rec.fund_acc);
        END IF;
      
        IF (rec.num_account2 IS NOT NULL)
        THEN
          insert_account(rec.acc_bik_bank2
                        ,rec.acc_inn_bank2
                        ,rec.acc_korr_bank2
                        ,rec.acc_name_bank2
                        ,rec.num_account2
                        ,rec.account_notice2
                        ,sq_contact
                        ,rec.fund_acc2);
        END IF;
      
        pkg_convert.UpdateConvert('ins.convert_contact', rec.rrw);
      
      END IF;
    END LOOP;
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации контактов'
                               ,'PKG_CONVERT_BLOGIC'
                               ,'FN_CONTACT'
                               ,SQLCODE
                               ,SQLERRM);
      IF (cur_bank%ISOPEN)
      THEN
        CLOSE cur_bank;
      END IF;
      RETURN pkg_convert.c_exept;
  END FN_CONTACT_UR;

  FUNCTION FN_CONTACT_FIS(p_valid NUMBER) RETURN NUMBER IS
    l_res          NUMBER;
    rec_bank       cur_contact_FIS%ROWTYPE;
    rev_val        NUMBER(1) := 0;
    sq_contact     NUMBER;
    sq_addres      NUMBER;
    sq_val         NUMBER;
    cotnact_is     NUMBER := 0;
    name_tabl      VARCHAR2(30);
    name_contact   VARCHAR2(255);
    ID_TYPE        NUMBER(9);
    inn_contact    VARCHAR2(20);
    id_country_tel NUMBER(9);
    l_EXIT_ID      NUMBER;
  
    PROCEDURE insert_tel
    (
      p_TELEPHONE_COUNTRY_ID NUMBER
     ,p_TELEPHONE_PREFIX     VARCHAR2
     ,p_TELEPHONE_NUMBER     VARCHAR2
     ,P_TELEPHONE_EXTENSION  VARCHAR2
     ,P_TELEPHONE_REMARKS    VARCHAR2
     ,P_TELEPHONE_TYPE       NUMBER
    ) IS
    BEGIN
      SELECT INS.SQ_CN_CONTACT_TELEPHONE.nextval INTO sq_val FROM dual;
    
      INSERT INTO INS.VEN_CN_CONTACT_TELEPHONE
        (ID
        ,CONTACT_ID
        ,COUNTRY_ID
        ,TELEPHONE_TYPE
        ,TELEPHONE_PREFIX
        ,TELEPHONE_NUMBER
        ,TELEPHONE_EXTENSION
        ,REMARKS
        ,ENT_ID)
      VALUES
        (sq_val
        ,sq_contact
        ,(SELECT T.ID FROM T_COUNTRY_DIAL_CODE T WHERE t.COUNTRY_ID = P_TELEPHONE_COUNTRY_ID)
        ,P_TELEPHONE_TYPE
        ,P_TELEPHONE_PREFIX
        ,SUBSTR(P_TELEPHONE_NUMBER, 1, 30)
        ,P_TELEPHONE_EXTENSION
        ,P_TELEPHONE_REMARKS
        ,221);
    END;
  
    PROCEDURE insert_doc
    (
      p_brief   VARCHAR2
     ,p_contact NUMBER
     ,p_val     VARCHAR2
     ,p_country NUMBER
    ) IS
    BEGIN
      INSERT INTO VEN_CN_CONTACT_IDENT
        (TABLE_ID, CONTACT_ID, ID_TYPE, ID_VALUE, COUNTRY_ID)
      VALUES
        (SQ_CN_CONTACT_IDENT.nextval
        ,p_contact
        ,(SELECT T.ID FROM INS.T_ID_TYPE T WHERE UPPER(T.BRIEF) = UPPER(p_brief))
        ,p_val
        ,p_country);
    END insert_doc;
  
  BEGIN
    FOR rec IN cur_contact_FIS
    LOOP
      name_contact := rec.NAME;
      inn_contact  := rec.INN;
      l_EXIT_ID    := rec.EXT_ID;
    
      SELECT ins.sq_contact.nextval INTO sq_contact FROM dual;
    
      /*   insert into INS.VEN_CONTACT (CONTACT_ID, NAME, FIRST_NAME, MIDDLE_NAME,
             RESIDENT_FLAG,NOTE,T_CONTACT_STATUS_ID,CONTACT_TYPE_ID,EXT_ID)
      values();*/
      name_tabl := 1;
      INSERT INTO INS.VEN_CN_PERSON
        (CONTACT_ID
        ,NAME
        ,FIRST_NAME
        ,MIDDLE_NAME
        ,RESIDENT_FLAG
        ,NOTE
        ,T_CONTACT_STATUS_ID
        ,CONTACT_TYPE_ID
        ,EXT_ID
        ,DATE_OF_BIRTH
        ,GENDER
        ,FAMILY_STATUS
        ,TITLE)
      VALUES
        (sq_contact
        ,rec.NAME
        ,rec.FIRST_NAME
        ,rec.MIDDLE_NAME
        ,rec.RESIDENT_FLAG
        ,rec.CONTACT_NOTE
        ,1
        ,rec.TYPE_CONTACT_ID
        ,rec.EXT_ID
        ,rec.DATE_OF_BIRTH
        ,rec.GENDER
        ,rec.FAMILY_STATUS
        ,rec.PERSON_TITLE);
    
      name_tabl := 2;
      IF (rec.TELEPHONE_NUMBER IS NOT NULL)
      THEN
        insert_tel(rec.TELEPHONE_COUNTRY_ID
                  ,NULL
                  ,rec.TELEPHONE_NUMBER
                  ,NULL
                  ,NULL
                  ,rec.TELEPHONE_TYPE);
      END IF;
      name_tabl := 3;
      IF (rec.TELEPHONE_NUMBER2 IS NOT NULL)
      THEN
        insert_tel(rec.TELEPHONE_COUNTRY_ID2
                  ,NULL
                  ,rec.TELEPHONE_NUMBER2
                  ,NULL
                  ,NULL
                  ,rec.TELEPHONE_TYPE2);
      END IF;
      name_tabl := 4;
      IF (rec.TELEPHONE_NUMBER3 IS NOT NULL)
      THEN
        insert_tel(rec.TELEPHONE_COUNTRY_ID3
                  ,NULL
                  ,rec.TELEPHONE_NUMBER3
                  ,NULL
                  ,NULL
                  ,rec.TELEPHONE_TYPE3);
      END IF;
    
      name_tabl := 5;
      IF (rec.INN IS NOT NULL)
      THEN
        insert_doc('INN', sq_contact, rec.INN, 643);
      END IF;
    
      name_tabl := 6;
      IF (rec.NUMBER_PASSPORT IS NOT NULL)
      THEN
        SELECT INS.SQ_CN_CONTACT_IDENT.nextval INTO sq_val FROM dual;
        ID_TYPE := rec.PASSPORT_BRIF;
      
        name_tabl := 7;
        INSERT INTO INS.VEN_CN_CONTACT_IDENT
          (TABLE_ID, CONTACT_ID, ID_TYPE, ID_VALUE, SERIAL_NR, ISSUE_DATE, COUNTRY_ID, PLACE_OF_ISSUE)
        VALUES
          (sq_val
          ,sq_contact
          ,ID_TYPE
          ,rec.NUMBER_PASSPORT
          ,rec.SERIAL_NR_PASSPORT
          ,rec.ISSUE_DATE_PASSPORT
          ,643
          ,rec.PLACE_OF_ISSUE_PASSPORT);
      END IF;
    
      name_tabl := 8;
      IF (FN_INSERT_ADDRESSE(rec.Ext_ID, sq_contact) <> pkg_convert.c_true)
      THEN
        RETURN pkg_convert.c_false;
      END IF;
    
    --  pkg_convert.UpdateConvert('ins.convert_contact',rec.rrw);
    
    END LOOP;
    RETURN pkg_convert.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации физических лиц: ' || l_EXIT_ID || ':' ||
                                name_tabl
                               ,'PKG_CONVERT_BLOGIC'
                               ,'FN_CONTACT_FIS'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_exept;
    
  END FN_CONTACT_FIS;

  FUNCTION FN_BANK(p_valid NUMBER) RETURN NUMBER IS
  
    l_res          NUMBER;
    rev_val        NUMBER(1) := 0;
    bank_is        NUMBER(1) := 0; -- 0 = нет такого банка
    bik_bank       VARCHAR2(50);
    check_dupl     NUMBER(1);
    rec_count      NUMBER := 0;
    sq_contact     NUMBER;
    sq_addres      NUMBER;
    sq_val         NUMBER;
    ID_TYPE        NUMBER(9);
    name_contact   VARCHAR2(255);
    id_country     NUMBER(9);
    id_country_tel NUMBER(9);
    l_EXIT_ID      NUMBER;
  
  BEGIN
  
    FOR rec IN cur_contact_bank
    LOOP
      name_contact := rec.NAME;
      bik_bank     := rec.bik_bank;
      l_EXIT_ID    := rec.EXT_ID;
    
      l_res := FN_GET_ID_COUNTRY(rec.COUNTRY_ID, id_country);
      pkg_convert.Raise_Ex(l_res);
    
      SELECT ins.SQ_CONTACT.nextval INTO sq_contact FROM dual;
    
      INSERT INTO INS.CONTACT
        (CONTACT_ID, NAME, RESIDENT_FLAG, NOTE, T_CONTACT_STATUS_ID, CONTACT_TYPE_ID, EXT_ID)
      VALUES
        (sq_contact
        ,rec.NAME
        ,rec.RESIDENT_FLAG
        ,rec.CONTACT_NOTE
        ,1
        ,rec.TYPE_CONTACT_ID
        ,rec.EXT_ID);
    
      IF (FN_INSERT_ADDRESSE(rec.EXT_ID, sq_contact) <> pkg_convert.c_true)
      THEN
        RETURN pkg_convert.c_false;
      END IF;
    
      SELECT INS.SQ_CN_CONTACT_ROLE.nextval INTO sq_val FROM dual;
      INSERT INTO INS.CN_CONTACT_ROLE
        (ID, CONTACT_ID, ROLE_ID)
      VALUES
        (sq_val, sq_contact, rec.CONTACT_ROLE_ID);
    
      SELECT T.ID INTO ID_TYPE FROM INS.T_ID_TYPE T WHERE T.BRIEF = 'BIK';
      SELECT INS.SQ_CN_CONTACT_IDENT.nextval INTO sq_val FROM dual;
    
      IF (rec.BIK_BANK IS NOT NULL)
      THEN
        INSERT INTO INS.CN_CONTACT_IDENT
          (TABLE_ID, CONTACT_ID, ID_TYPE, ID_VALUE, COUNTRY_ID)
        VALUES
          (sq_val, sq_contact, ID_TYPE, rec.BIK_BANK, id_country);
      END IF;
    
      --  Корр счет
      IF (rec.KORR_ACCOUNT IS NOT NULL)
      THEN
        SELECT INS.SQ_CN_CONTACT_IDENT.nextval INTO sq_val FROM dual;
        SELECT T.ID INTO ID_TYPE FROM INS.T_ID_TYPE T WHERE T.BRIEF = 'KORR';
        INSERT INTO INS.CN_CONTACT_IDENT
          (table_id, contact_id, ID_TYPE, ID_VALUE, country_id)
        VALUES
          (sq_val, sq_contact, ID_TYPE, rec.KORR_ACCOUNT, id_country);
      END IF;
    
      IF (rec.INN IS NOT NULL)
      THEN
        SELECT INS.SQ_CN_CONTACT_IDENT.nextval INTO sq_val FROM dual;
        SELECT T.ID INTO ID_TYPE FROM INS.T_ID_TYPE T WHERE T.BRIEF = 'INN';
        INSERT INTO INS.CN_CONTACT_IDENT
          (TABLE_ID, CONTACT_ID, ID_TYPE, ID_VALUE, COUNTRY_ID)
        VALUES
          (sq_val, sq_contact, ID_TYPE, rec.INN, id_country);
      END IF;
    
      INSERT INTO INS.CN_COMPANY
        (CONTACT_ID, WEB_SITE, CURRENCY_ID)
      VALUES
        (sq_contact, NULL, (SELECT FUND_ID FROM ins.FUND WHERE CODE = 810));
    
    --     pkg_convert.UpdateConvert('ins.convert_contact',rec.rrw);
    END LOOP;
    RETURN pkg_convert.c_true;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации банков'
                               ,'PKG_CONVERT_BLOGIC'
                               ,'FN_BANK'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_exept;
  END FN_BANK;

  /* Договора */
  /* FUNCTION  FN_CHECK_POLICY1  (rec_policy cur_convert_policy%rowtype ) RETURN NUMBER
   is
   cursor cur_check(c_POL_NUM VARCHAR2, c_POL_SER VARCHAR2)
     is select pol.* from p_policy pol
       where    pol.POL_NUM = c_POL_NUM
          and pol.POL_SER = c_POL_SER;
  
   rec_check cur_check%rowtype;
   begin
       open cur_check(rec_policy.POL_NUM, rec_policy.POL_SER);
        fetch cur_check into rec_check;
        pkg_convert.Raise_ExB(cur_check%notfound,true);
      close cur_check;
       return pkg_convert.c_false;
  
  exception
        when PKG_CONVERT.res_exception  then
            if (cur_check%isopen)
          then
               close cur_check;
          end if;
          return PKG_CONVERT.c_true;
  
      when others then
          if (cur_check%isopen)
       then
          close cur_check;
       end if;
       pkg_convert.SP_EventError('ошибка при конвертации объектов','pkg_convert_blogic','FN_CHECK_POLICY1',sqlcode,sqlerrm);
       --pkg_convert.SP_InserEvent('PKG_CONVERT.FN_CHECK_POLICY1: '||sqlerrm,'проверка на дубликаты договоров','NUM -'||rec_policy.POL_NUM||' SER -'|| rec_policy.POL_SER,NULL,PKG_CONVERT.c_exept);
       return PKG_CONVERT.c_exept;
  
   END FN_CHECK_POLICY1;
    */
  /*  заполнение договоров  */
  /* FUNCTION  FN_POLIСY (p_valid number)   RETURN NUMBER
  IS
  
  rec_poliсy   cur_convert_policy%rowtype;
  
  name_view   VARCHAR2(50);
  l_res    NUMBER;
  sq_pol_header  NUMBER;
  sq_pol    NUMBER;
  sq_pol_cont  NUMBER;
  sq_doc_status  NUMBER;
  l_POL_NUM   NUMBER(9);
  l_POL_SER   VARCHAR2(1024);
  id_pol_head  NUMBER;
  l_EXIT_ID   NUMBER;
  
  begin
  for rec in cur_convert_policy
  loop
   l_POL_NUM := rec.POL_NUM;
   l_POL_SER := rec.POL_SER;
   l_EXIT_ID := rec.EXT_ID;
   l_res := pkg_convert.c_true;
  
    if (p_valid = pkg_convert.c_true)
    then
       l_res := FN_CHECK_POLICY1(rec);
    end if;
  
  if (l_res = pkg_convert.c_true ) then
  
    select ins.sq_document.nextval into sq_pol_header from dual;
    insert into INS.VEN_P_POL_HEADER (POLICY_HEADER_ID,
              PRODUCT_ID,
           POLICY_ID,
           DOC_TEMPL_ID,
           NUM,
             REG_DATE,
           CONFIRM_CONDITION_ID,
           FUND_ID,
           FUND_PAY_ID,
           PREV_EVENT_COUNT,
           SALES_CHANNEL_ID,
           FILIAL_ID,
           DOC_FOLDER_ID,
           NOTE,
           AG_CONTRACT_1_ID,
           AG_CONTRACT_2_ID,
           COMPANY_TREE_ID,
           IS_NEW,
           IS_PARK,
           PREV_POLICY_COMPANY,
           PREV_POLICY_NUM,
           PREV_POLICY_SER,
           PREV_POLICY_START_KBM,
           PREV_POL_HEADER_ID,
           START_DATE,
           T_PROD_PAYMENT_ORDER_ID,
           EXT_ID
                )
        values(sq_pol_header,
      rec.PRODUCT_ID,
      NULL,
      /* DOC_TEMPL_ID */ /* (select t.DOC_TEMPL_ID from ins.doc_templ t where t.BRIEF = 'POL_HEADER'),
     rec.NUM,
     /* REG_DATE --  TO_DATE(TO_DATE(SUBSTR(rec.Reg_Date,0,10),'YYYY-MM-DD')*/
  /*  rec.REG_DATE,
  rec.CONFIRM_CONDITION_ID,
  rec.FUND_ID,
  rec.FUND_PAY_ID,
  rec.PREV_EVENT_COUNT,
  rec.SALES_CHANNEL_ID,
  rec.FILIAL_ID,
  /*rec.DOC_FOLDER_ID*/ /*NULL,
     rec.NOTE,
     rec.AG_CONTRACT_1_ID,
     rec.AG_CONTRACT_2_ID,
     rec.COMPANY_TREE_ID,
     rec.IS_NEW,
     rec.IS_PARK,
     rec.PREV_POLICY_COMPANY,
     rec.PREV_POLICY_NUM,
     rec.PREV_POLICY_SER,
     rec.PREV_POLICY_START_KBM,
     rec.PREV_POL_HEADER_ID,
     rec.START_DATE,
     rec.T_PROD_PAYMENT_ORDER_ID ,
     rec.EXT_ID
    );

    ---l_res := insert_ppolicy(rec, sq_pol_header,sq_pol);
 pkg_convert.Raise_Ex(l_res);

    end if;
 end loop;

 return pkg_convert.c_true;

 exception
   when others  then
  pkg_convert.SP_EventError('ошибка при конвертации договора','PKG_CONVERT_BLOGIC','FN_POLIСY', sqlcode,sqlerrm);
  if (cur_convert_policy%isopen)then close cur_convert_policy;end if;
  return pkg_convert.c_exept;
 END FN_POLIСY;*/

  /*FUNCTION  FN_POLICY_ADD   (p_valid number)   RETURN NUMBER
  is
  
  cursor cur_pol_add(c_ext_id number) is
    select * from ven_p_pol_header where ext_id = c_ext_id;
  
  rec_pol_add cur_pol_add%rowtype;
  sq_pol     number;
  l_res      number;
  l_EXIT_ID    NUMBER;
  
  begin
  for rec in cur_convert_poliсy_add
  loop
    l_EXIT_ID := rec.EXT_ID;
   open cur_pol_add(rec.HEAD_EXT_ID);
      fetch cur_pol_add into  rec_pol_add;
  
      pkg_convert.raise_ExB(cur_pol_add%notfound,true);
   close cur_pol_add;
  
      l_res:=insert_ppolicy(rec, rec_pol_add.policy_header_id,sq_pol);
   pkg_convert.Raise_Ex(l_res);
  
  end loop;
  
  return pkg_convert.c_true;
  exception
  when others  then
      pkg_convert.SP_EVENTERROR('ошибка при конвертации дополнительного соглашения','PKG_CONVERT_BLogic','FN_POLICY_ADD',sqlcode,sqlerrm);
    if (cur_convert_policy%isopen)then close cur_convert_policy;end if;
       if (cur_pol_add%isopen)then close cur_pol_add;end if;
    return pkg_convert.c_exept;
  END FN_POLICY_ADD;
  
     */
  /* функци проверки существования банка */
  /* FUNCTION  FN_CHECK_BANK1   (rec_contact cur_convert_bank%rowtype ) RETURN NUMBER
  is
  
   cursor cur_check (c_contacn_bik varchar2) is
    select con.*
     from contact con,
       CN_CONTACT_IDENT ci,
       T_ID_TYPE t
        where con.contact_id = ci.contact_id
            and ci.ID_TYPE = t.id
           and t.BRIEF = 'BIK'
         and ci.ID_VALUE = c_contacn_bik;
  
   rec_check cur_check%rowtype;
  
  begin
  
     open cur_check(rec_contact.BIK_BANK);
       fetch cur_check into rec_check;
    pkg_convert.Raise_ExB(cur_check%notfound,true);
  close cur_check;
  
     return pkg_convert.c_false;
  exception
  when pkg_convert.res_exception then
      if (cur_check%isopen) then close cur_check; end if;
    return pkg_convert.c_true;
     when others then
        if (cur_check%isopen)
        then
             close cur_check;
         end if;
      pkg_convert.SP_EventError('ошибка при конвертации объектов','pkg_convert_blogic','FN_CHECK_BANK1',sqlcode,sqlerrm);
        --pkg_convert.SP_InserEvent('PKG_CONVERT.FN_CHECK_BANK1 '||sqlerrm,'проверка на дубликаты банков',rec_contact.name,'NULL','-1');
      return pkg_convert.c_exept;
  end FN_CHECK_BANK1;
  
  */
  /*юридические лица*/
  /* FUNCTION  FN_CHECK_CONTACT2   (rec_contact cur_convert_contact%rowtype ) RETURN NUMBER
  is
   cursor cur_check (c_contacn_name varchar2, c_contacn_inn varchar2) is
    select con.*
     from contact con,
       CN_CONTACT_IDENT ci,
       T_ID_TYPE t
       where con.contact_id = ci.contact_id
           and ci.ID_TYPE = t.id
          and t.BRIEF = 'INN'
        and ci.ID_VALUE = c_contacn_inn
        and con.name = c_contacn_name;
  
   rec_check cur_check%rowtype;
  
  begin
  
     open cur_check(rec_contact.name, rec_contact.inn);
     fetch cur_check into rec_check;
   pkg_convert.Raise_ExB(cur_check%notfound,true);
  close cur_check;
  
     return pkg_convert.c_false;
  exception
  when pkg_convert.res_exception then
      if (cur_check%isopen)
   then
     close cur_check;
   end if;
   return pkg_convert.c_true;
  when others then
     if (cur_check%isopen)
     then
         close cur_check;
     end if;
     pkg_convert.SP_EventError('ошибка при конвертации объектов','pkg_convert_blogic','FN_CHECK_CONTACT2',sqlcode,sqlerrm);
     --pkg_convert.SP_InserEvent('PKG_CONVERT.FN_CHECK_DUPL '||sqlerrm,'проверка на дубликаты банков',rec_contact.name,'NULL','-1');
     return pkg_convert.c_exept;
  end FN_CHECK_CONTACT2;
  
  */

  /* физические лица*/
  /* FUNCTION FN_CHECK_CONTACT1   (rec_contact cur_convert_contact%rowtype ) RETURN NUMBER
  is
    cursor cur_check (c_contacn_name varchar2, c_FIRST_NAME varchar2, c_MIDDLE_NAME varchar2,
         c_serial_pass varchar2,c_numb_pass varchar2, c_date_of_birth date)
   is
    select con.*
       from contact con, cn_person per,CN_CONTACT_IDENT pas , T_ID_TYPE t
       where con.contact_id = per.contact_id
       and con.contact_id = pas.contact_id
         and pas.ID_TYPE = t.id
         and t.BRIEF IN('PASS_RF','PASS_SSSR','KOD')
       and con.name = c_contacn_name
       and con.FIRST_NAME = c_FIRST_NAME
       and con.MIDDLE_NAME = c_MIDDLE_NAME
       and pas.SERIAL_NR  =  c_serial_pass
       and pas.ID_VALUE = c_numb_pass
       and per.date_of_birth = c_date_of_birth;
  
  rec_check cur_check%rowtype;
  begin
     open cur_check(rec_contact.name, rec_contact.FIRST_NAME, rec_contact.MIDDLE_NAME,
                rec_contact.SERIAL_NR_PASSPORT,rec_contact.NUMBER_PASSPORT,rec_contact.DATE_OF_BIRTH);
     fetch cur_check into rec_check;
   pkg_convert.Raise_ExB(cur_check%notfound,true);
    close cur_check;
  
     return pkg_convert.c_false;
  exception
       when PKG_CONVERT.res_exception  then
           if (cur_check%isopen)
         then
              close cur_check;
         end if;
         return PKG_CONVERT.c_true;
     when others then
         if (cur_check%isopen) then
        close cur_check;
      end if;
      pkg_convert.SP_EventError('ошибка при конвертации объектов','pkg_convert_blogic','FN_CHECK_CONTACT1',sqlcode,sqlerrm);
  
      return PKG_CONVERT.c_exept;
  end FN_CHECK_CONTACT1;
  */

  /* получение FUND_ID по CODE  */
  FUNCTION FN_GET_ID_FUND
  (
    p_currency_code NUMBER
   ,p_res           OUT NUMBER
  ) RETURN NUMBER IS
    CURSOR cur_fund(c_fund_code NUMBER) IS
      SELECT * FROM FUND WHERE CODE = c_fund_code;
  
    rec_fund cur_fund%ROWTYPE;
  
  BEGIN
    OPEN cur_fund(p_currency_code);
    FETCH cur_fund
      INTO rec_fund;
    pkg_convert.Raise_ExB(cur_fund%NOTFOUND, TRUE);
    CLOSE cur_fund;
  
    p_res := rec_fund.fund_id;
  
    RETURN PKG_CONVERT.c_true;
  EXCEPTION
    WHEN pkg_convert.res_exception THEN
      p_res := NULL;
      IF (cur_fund%ISOPEN)
      THEN
        CLOSE cur_fund;
      END IF;
      RETURN PKG_CONVERT.c_false;
    WHEN OTHERS THEN
      p_res := NULL;
      IF (cur_fund%ISOPEN)
      THEN
        CLOSE cur_fund;
      END IF;
      pkg_convert.SP_EventError('ошибка при конвертации объектов'
                               ,'pkg_convert_blogic'
                               ,'FN_GET_ID_FUND'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN PKG_CONVERT.c_exept;
  END FN_GET_ID_FUND;

  /*  объекты страхования */

  FUNCTION FN_ASSET(p_valid NUMBER) RETURN NUMBER IS
    sq_as_head NUMBER;
    sq_asset   NUMBER;
    l_hobby    NUMBER;
    val        NUMBER;
  BEGIN
  
    FOR rec IN cur_as_asset
    LOOP
      val := 1;
      SELECT ins.sq_P_ASSET_HEADER.nextval INTO sq_as_head FROM dual;
      INSERT INTO ins.VEN_P_ASSET_HEADER
        (P_ASSET_HEADER_ID, T_ASSET_TYPE_ID, EXT_ID)
      VALUES
        (sq_as_head
        ,(SELECT T.T_ASSET_TYPE_ID FROM T_ASSET_TYPE T WHERE rec.T_ASSET_TYPE_ID = T.BRIEF)
        ,rec.EXT_ID);
      val := 2;
    
      l_hobby := GetHobby(rec.T_HOBBY_ID);
    
      INSERT INTO VEN_AS_ASSURED
        (AS_ASSURED_ID
        ,EXT_ID
        ,CONTACT_ID
        ,END_DATE
        ,FEE
        ,INS_AMOUNT
        ,INS_LIMIT
        ,INS_PREMIUM
        ,INS_PRICE
        ,INS_VAR_ID
        ,IS_FIRST_EVENT
        ,NAME
        ,NOTE
        ,P_ASSET_HEADER_ID
        ,P_POLICY_ID
        ,START_DATE
        ,STATUS_HIST_ID
        ,T_DEDUCTIBLE_TYPE_ID
        ,T_DEDUCT_VAL_TYPE_ID
        ,ASSURED_ADD_CONTACT_ID
        ,ASSURED_CONTACT_ID
        ,AS_ASSET_ASS_STATUS_ID
        ,BSO_ID
        ,CARD_DATE
        ,CARD_NUM
        ,COEFF
        ,DEPARTMENT
        ,DMS_AGE_RANGE_ID
        ,DMS_HEALTH_GROUP_ID
        ,DMS_INS_REL_TYPE_ID
        ,GENDER
        ,HEIGHT
        ,INSURED_AGE
        ,INS_TIME_ID
        ,OFFICE
        ,POL_ASSURED_GROUP_ID
        ,RENT_PERIOD_ID
        ,SMOKE_ID
        ,TAB_NUMBER
        ,T_HOBBY_ID
        ,T_PROFESSION_ID
        ,T_PROVINCE_ID
        ,T_TERRITORY_ID
        ,WEIGHT
        ,WORK_GROUP_ID)
      VALUES
        (
         /*AS_ASSURED_ID*/SQ_AS_ASSURED.NEXTVAL
        ,
         /*EXT_ID, */rec.EXT_ID
        ,
         /*CONTACT_ID, */(SELECT T.CONTACT_ID FROM ins.CONTACT T WHERE T.ext_id = rec.EXT_CONTACT_ID)
        ,
         /*END_DATE, */NVL(rec.END_DATE
            ,(SELECT T.END_DATE
               FROM ins.VEN_P_POLICY T
              WHERE T.ext_id = rec.EXT_POLICY_ID))
        ,
         /*FEE, */S2N(rec.FEE)
        ,
         /*INS_AMOUNT, */S2N(rec.INS_AMOUNT)
        ,
         /*INS_LIMIT, */NULL
        ,
         /*INS_PREMIUM, */S2N(rec.INS_PREMIUM)
        ,
         /*INS_PRICE, */NULL
        ,
         /*INS_VAR_ID, */NULL
        ,
         /*IS_FIRST_EVENT, */NULL
        ,
         /*NAME, */rec.Name
        ,
         /*NOTE, */rec.Note
        ,
         /*P_ASSET_HEADER_ID, */sq_as_head
        ,
         /*P_POLICY_ID, */(SELECT T.POLICY_ID
            FROM ins.VEN_P_POLICY T
           WHERE T.ext_id = rec.EXT_POLICY_ID)
        ,
         /*START_DATE, */rec.START_DATE
        ,
         /*STATUS_HIST_ID, */2
        ,
         /*T_DEDUCTIBLE_TYPE_ID, */NULL
        ,
         /*T_DEDUCT_VAL_TYPE_ID, */NULL
        ,
         /*ASSURED_ADD_CONTACT_ID, */NULL
        ,
         /*ASSURED_CONTACT_ID, */(SELECT T.CONTACT_ID
            FROM ins.CONTACT T
           WHERE T.ext_id = rec.EXT_CONTACT_ID)
        ,
         /*AS_ASSET_ASS_STATUS_ID, */To_NUMBER(rec.AS_ASSET_ASS_STATUS_ID)
        ,
         /*BSO_ID, */NULL
        ,
         /*CARD_DATE, */rec.CARD_DATE
        ,
         /*CARD_NUM, */rec.CARD_NUM
        ,
         /*COEFF, */NULL
        ,
         /*DEPARTMENT, */NULL
        ,
         /*DMS_AGE_RANGE_ID, */NULL
        ,
         /*DMS_HEALTH_GROUP_ID, */NULL
        ,
         /*DMS_INS_REL_TYPE_ID, */NULL
        ,
         /*GENDER, */rec.GENDER
        ,
         /*HEIGHT, */NULL
        ,
         /*INSURED_AGE, */S2N(rec.INSURED_AG)
        ,
         /*INS_TIME_ID, */NULL
        ,
         /*OFFICE, */NULL
        ,
         /*POL_ASSURED_GROUP_ID, */NULL
        ,
         /*RENT_PERIOD_ID, */NULL
        ,
         /*SMOKE_ID, */NULL
        ,
         /*TAB_NUMBER, */NULL
        ,
         /*T_HOBBY_ID, */l_hobby
        ,
         /*T_PROFESSION_ID, */NULL
        ,
         /*T_PROVINCE_ID, */NULL
        ,
         /*T_TERRITORY_ID, */rec.T_TERRITORY_ID
        ,
         /*WEIGHT, */NULL
        ,
         /*WORK_GROUP_ID*/S2N(rec.WORK_GROUP_ID));
    END LOOP;
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации объектов ' || val
                               ,'pkg_convert_blogic'
                               ,'fn_asset'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_exept;
  END FN_ASSET;

  /* покрытия  */
  FUNCTION FN_COVER(p_valid NUMBER) RETURN NUMBER IS
    /*sq_t_prod_line_option   number;
    sq_t_prod_line_opt_peril number;
    sq_p_cover     number;*/
  
    val NUMBER;
  
  BEGIN
  
    FOR rec IN cur_cnv_p_cover
    LOOP
    
      /*   select ins.sq_T_PROD_LINE_OPTION.nextval into sq_t_prod_line_option from dual;
           insert into T_PROD_LINE_OPTION(
                 ID,
              PRODUCT_LINE_ID,
                DESCRIPTION,
                EXT_ID)
         values(
              sq_t_prod_line_option,
             rec.PRODUCT_LINE_ID,
            'тест-конвертация',
            rec.EXT_ID);
      select ins.sq_t_prod_line_opt_peril.nextval into sq_t_prod_line_opt_peril from dual;
      INSERT INTO t_prod_line_opt_peril
                 (ID,
                  product_line_option_id,
                  peril_id
                 )
          VALUES (sq_t_prod_line_opt_peril,
                     sq_t_prod_line_option,
                  rec.peril_id);*/
      val := rec.Ext_ID;
      --  select ins.sq_P_COVER.nextval into sq_p_cover from dual;
      INSERT INTO ins.ven_P_COVER
        (P_COVER_ID
        ,AS_ASSET_ID
        ,T_PROD_LINE_OPTION_ID
        ,START_DATE
        ,END_DATE
        ,INS_AMOUNT
        ,PREMIUM
        ,TARIFF
        ,T_DEDUCTIBLE_TYPE_ID
        ,T_DEDUCT_VAL_TYPE_ID
        ,DEDUCTIBLE_VALUE
        ,STATUS_HIST_ID
        ,OLD_PREMIUM
        ,COMPENSATION_TYPE
        ,FEE
        ,IS_HANDCHANGE_AMOUNT
        ,IS_HANDCHANGE_PREMIUM
        ,IS_HANDCHANGE_TARIFF
        ,IS_HANDCHANGE_DEDUCT
        ,DECLINE_DATE
        ,DECLINE_SUMM
        ,IS_DECLINE_CHARGE
        ,IS_DECLINE_COMISSION
        ,IS_HANDCHANGE_DECLINE
        ,IS_AGGREGATE
        ,INS_PRICE
        ,EXT_ID
        ,IS_PROPORTIONAL
        ,INSURED_AGE
        ,K_COEF
        ,NORMRATE_VALUE
        ,PREMIA_BASE_TYPE
        ,PREMIUM_ALL_SROK
        ,RVB_VALUE
        ,S_COEF)
      VALUES
        (ins.sq_P_COVER.nextval
        ,(SELECT T.As_ASSET_id FROM ins.As_ASSET T WHERE T.EXT_ID = rec.EXT_ASSET_ID)
        ,rec.T_PROD_LINE_OPTION_ID
        ,rec.START_DATE
        ,rec.END_DATE
        ,s2n(rec.INS_AMOUNT)
        ,s2n(rec.PREMIUM)
        ,s2n(rec.TARIFF)
        ,rec.T_DEDUCTIBLE_TYPE_ID
        ,rec.T_DEDUCT_VAL_TYPE_ID
        ,s2n(rec.DEDUCTIBLE_VALUE)
        ,(SELECT s.STATUS_HIST_ID FROM ins.status_hist s WHERE s.brief = rec.STATUS_HIST_ID)
        ,NULL
        , --                        rec.OLD_PREMIUM            ,
         NULL
        , --                        rec.COMPENSATION_TYPE      ,
         s2n(rec.FEE)
        ,NULL
        , --                        rec.IS_HANDCHANGE_AMOUNT   ,
         NULL
        , --                        rec.IS_HANDCHANGE_PREMIUM  ,
         NULL
        , --                        rec.IS_HANDCHANGE_TARIFF   ,
         NULL
        , --            rec.IS_HANDCHANGE_DEDUCT   ,
         rec.DECLINE_DATE
        ,s2n(rec.DECLINE_SUMM)
        ,NULL
        , --            rec.IS_DECLINE_CHARGE      ,
         NULL
        , --            rec.IS_DECLINE_COMISSION   ,
         NULL
        , --            rec.IS_HANDCHANGE_DECLINE  ,
         NULL
        , --            rec.IS_AGGREGATE           ,
         NULL
        , --            rec.INS_PRICE              ,
         rec.EXT_ID
        ,
         /*rec.IS_PROPORTIONAL */NULL
        ,s2n(rec.INSURED_AGE)
        ,s2n(rec.K_COEF)
        ,s2n(rec.NORMRATE_VALUE)
        ,rec.PREMIA_BASE_TYPE
        ,s2n(rec.PREMIUM_ALL_SROK)
        ,s2n(rec.RVB_VALUE)
        ,s2n(rec.S_COEF));
    
    --   pkg_convert.UpdateConvert('ins.cnv_p_cover',rec.rrw);
    END LOOP;
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации объектов: ' || val
                               ,'pkg_convert_blogic'
                               ,'FN_COVER'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_exept;
  END FN_COVER;

  /**
  * Функция загрузки начисления в разрезе покрытий
  * @param p_valid не испольуется
  */
  FUNCTION FN_POLICY_CHARGE(p_valid NUMBER) RETURN NUMBER IS
  
    sq_oper_rsbu NUMBER;
    sq_oper_msfo NUMBER;
    sq_oper_ape  NUMBER;
  
    l_A1_DT_URE_ID NUMBER;
    l_A2_DT_URE_ID NUMBER;
    l_A3_DT_URE_ID NUMBER;
    l_A4_DT_URE_ID NUMBER;
    l_A5_DT_URE_ID NUMBER;
  
    l_A1_CT_URE_ID NUMBER;
    l_A2_CT_URE_ID NUMBER;
    l_A3_CT_URE_ID NUMBER;
    l_A4_CT_URE_ID NUMBER;
    l_A5_CT_URE_ID NUMBER;
  
    rec_oper_msfo ins.OPER_TEMPL%ROWTYPE;
    rec_oper_ape  ins.OPER_TEMPL%ROWTYPE;
    rec_oper_rsbu ins.OPER_TEMPL%ROWTYPE;
  
    l_v  NUMBER;
    L_V2 NUMBER;
  
    FUNCTION GetOperTemplate(p_templ VARCHAR2) RETURN ins.OPER_TEMPL%ROWTYPE IS
    
      CURSOR cur_oper_templ(c_templ VARCHAR2) IS
        SELECT * FROM ins.OPER_TEMPL o WHERE o.brief = c_templ;
    
      l_rec ins.OPER_TEMPL%ROWTYPE;
    BEGIN
      OPEN cur_oper_templ(p_templ);
      FETCH cur_oper_templ
        INTO l_rec;
    
      CLOSE cur_oper_templ;
    
      RETURN l_rec;
    END GetOperTemplate;
  
    FUNCTION GetEntId(p_brief VARCHAR2) RETURN NUMBER IS
      l_id NUMBER;
    BEGIN
      SELECT e.ENT_ID INTO l_id FROM ins.ENTITY e WHERE e.BRIEF = p_brief;
      RETURN l_id;
    END GetEntId;
  
  BEGIN
    L_V2 := 0;
    L_V  := 0;
    FOR rec IN cur_policy_charge
    LOOP
      L_V2 := L_V2 + 1;
      SELECT SQ_OPER.NEXTVAL INTO sq_oper_rsbu FROM dual;
      SELECT SQ_OPER.NEXTVAL INTO sq_oper_msfo FROM dual;
      SELECT SQ_OPER.NEXTVAL INTO sq_oper_ape FROM dual;
    
      rec_oper_rsbu := GetOperTemplate('НачПремияНеЖизнь');
      rec_oper_msfo := GetOperTemplate('МСФОПремияНачисленаДог');
      rec_oper_ape  := GetOperTemplate('МСФОПремияНачисленаAPE');
    
      IF (s2n(rec.CHARGE_PREMIUM) IS NOT NULL)
      THEN
        INSERT INTO ins.VEN_OPER
          (OPER_ID, NAME, OPER_TEMPL_ID, DOCUMENT_ID, REG_DATE, OPER_DATE, DOC_STATUS_REF_ID, EXT_ID)
        VALUES
          (sq_oper_rsbu
          ,rec_oper_rsbu.Name
          ,rec_oper_rsbu.OPER_TEMPL_ID
          ,(SELECT v.POLICY_ID FROM VEN_P_POLICY V WHERE EXT_ID = rec.P_POLICY_ID)
          ,rec.DATE_RUS
          ,rec.DATE_RUS
          ,(SELECT v.DOC_STATUS_REF_ID FROM ins.DOC_STATUS_REF v WHERE v.brief = 'NEW')
          ,
           /*EXT_ID*/1);
      END IF;
    
      IF (s2n(rec.CHARGE_PREMIUM_IFRS) IS NOT NULL)
      THEN
        INSERT INTO ins.VEN_OPER
          (OPER_ID, NAME, OPER_TEMPL_ID, DOCUMENT_ID, REG_DATE, OPER_DATE, DOC_STATUS_REF_ID, EXT_ID)
        VALUES
          (sq_oper_msfo
          ,rec_oper_msfo.Name
          ,rec_oper_msfo.OPER_TEMPL_ID
          ,(SELECT v.POLICY_ID FROM VEN_P_POLICY V WHERE EXT_ID = rec.P_POLICY_ID)
          ,rec.DATE_IFRS
          ,rec.DATE_IFRS
          ,(SELECT v.DOC_STATUS_REF_ID FROM ins.DOC_STATUS_REF v WHERE v.brief = 'NEW')
          ,
           /*EXT_ID*/2);
      END IF;
    
      IF (s2n(rec.CHARGE_PREMIUM_APE) IS NOT NULL)
      THEN
        INSERT INTO ins.VEN_OPER
          (OPER_ID, NAME, OPER_TEMPL_ID, DOCUMENT_ID, REG_DATE, OPER_DATE, DOC_STATUS_REF_ID, EXT_ID)
        VALUES
          (sq_oper_ape
          ,rec_oper_ape.Name
          ,rec_oper_ape.OPER_TEMPL_ID
          ,(SELECT v.POLICY_ID FROM VEN_P_POLICY V WHERE EXT_ID = rec.P_POLICY_ID)
          ,rec.DATE_APE
          ,rec.DATE_APE
          ,(SELECT v.DOC_STATUS_REF_ID FROM ins.DOC_STATUS_REF v WHERE v.brief = 'NEW')
          ,
           /*EXT_ID*/3);
      END IF;
    
      l_A1_DT_URE_ID := GetEntId('CONTACT');
      l_A2_DT_URE_ID := GetEntId('P_POLICY');
      l_A3_DT_URE_ID := GetEntId('P_ASSET_HEADER');
      l_A4_DT_URE_ID := GetEntId('T_PROD_LINE_OPTION');
      l_A5_DT_URE_ID := GetEntId('P_COVER');
    
      l_A1_CT_URE_ID := GetEntId('CONTACT');
      l_A2_CT_URE_ID := GetEntId('P_POLICY');
      l_A3_CT_URE_ID := GetEntId('P_ASSET_HEADER');
      l_A4_CT_URE_ID := GetEntId('T_PROD_LINE_OPTION');
      l_A5_CT_URE_ID := GetEntId('P_COVER');
      l_v            := 1;
    
      IF (s2n(rec.CHARGE_PREMIUM) IS NOT NULL)
      THEN
        INSERT INTO ins.VEN_TRANS
          (TRANS_ID
          ,TRANS_DATE
          ,TRANS_FUND_ID
          ,TRANS_AMOUNT
          ,DT_ACCOUNT_ID
          ,CT_ACCOUNT_ID
          ,IS_ACCEPTED
          , --1
           A1_DT_URE_ID
          ,A1_DT_URO_ID
          ,A2_DT_URE_ID
          ,A2_DT_URO_ID
          ,A3_DT_URE_ID
          ,A3_DT_URO_ID
          ,A4_DT_URE_ID
          ,A4_DT_URO_ID
          ,A5_DT_URE_ID
          ,A5_DT_URO_ID
          ,A1_CT_URE_ID
          ,A1_CT_URO_ID
          ,A2_CT_URE_ID
          ,A2_CT_URO_ID
          ,A3_CT_URE_ID
          ,A3_CT_URO_ID
          ,A4_CT_URE_ID
          ,A4_CT_URO_ID
          ,A5_CT_URE_ID
          ,A5_CT_URO_ID
          ,TRANS_TEMPL_ID
          ,ACC_CHART_TYPE_ID
          ,ACC_FUND_ID
          ,ACC_AMOUNT
          ,ACC_RATE
          ,OPER_ID
          ,REG_DATE
          ,TRANS_QUANTITY
          , --0
           SOURCE
          , -- ins
           NOTE
          ,EXT_ID
          ,OBJ_URE_ID
          ,OBJ_URO_ID)
        VALUES
          (sq_TRANS.nextval
          ,
           /*TRANS_DATE*/rec.DATE_RUS
          ,
           /*TRANS_FUND_ID */(SELECT v.FUND_ID FROM ins.FUND v WHERE v.BRIEF = rec.POLICY_FUND_ID)
          ,
           /*TRANS_AMOUNT*/s2n(rec.CHARGE_PREMIUM)
          ,
           /*DT_ACCOUNT_ID*/(SELECT v.DT_ACCOUNT_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'НачПремия')
          ,
           /*CT_ACCOUNT_ID*/(SELECT v.CT_ACCOUNT_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'НачПремия')
          ,
           /*IS_ACCEPTED*/1
          ,
           /*A1_DT_URE_ID*/l_A1_DT_URE_ID
          , /*A1_DT_URO_ID*/(SELECT c.CONTACT_ID
              FROM ins.ven_p_policy         p
                  ,ins.ven_p_policy_contact c
                  ,ins.T_CONTACT_POL_ROLE   t
             WHERE c.POLICY_ID = p.POLICY_ID
               AND c.CONTACT_POLICY_ROLE_ID = t.ID
               AND t.BRIEF = 'Страхователь'
               AND p.ext_id = rec.p_policy_id)
          ,
           /*A2_DT_URE_ID*/l_A2_DT_URE_ID
          , /*A2_DT_URO_ID*/(SELECT e.policy_id
              FROM ins.VEN_P_POLICY e
             WHERE e.EXT_ID = rec.p_policy_id)
          ,
           /*A3_DT_URE_ID*/l_A3_DT_URE_ID
          , /*A3_DT_URO_ID*/(SELECT e.P_ASSET_HEADER_ID
              FROM ins.VEN_P_ASSET_HEADER e
             WHERE e.EXT_ID = rec.AS_ASSET_ASSURED_ID)
          ,
           /*A4_DT_URE_ID*/l_A4_DT_URE_ID
          , /*A4_DT_URO_ID*/(SELECT v.T_PROD_LINE_OPTION_ID
              FROM ins.VEN_P_COVER V
             WHERE V.EXT_ID = rec.P_COVER_ID)
          ,
           /*A5_DT_URE_ID*/l_A5_DT_URE_ID
          , /*A5_DT_URO_ID*/(SELECT v.P_COVER_ID
              FROM ins.VEN_P_COVER V
             WHERE V.EXT_ID = rec.P_COVER_ID)
          ,
           /*A1_CT_URE_ID*/l_A1_CT_URE_ID
          , /*A1_CT_URO_ID*/(SELECT c.CONTACT_ID
              FROM ins.ven_p_policy         p
                  ,ins.ven_p_policy_contact c
                  ,ins.T_CONTACT_POL_ROLE   t
             WHERE c.POLICY_ID = p.POLICY_ID
               AND c.CONTACT_POLICY_ROLE_ID = t.ID
               AND t.BRIEF = 'Страхователь'
               AND p.ext_id = rec.p_policy_id)
          ,
           /*A2_CT_URE_ID*/l_A2_CT_URE_ID
          , /*A2_CT_URO_ID*/(SELECT e.policy_id
              FROM ins.VEN_P_POLICY e
             WHERE e.EXT_ID = rec.p_policy_id)
          ,
           /*A3_CT_URE_ID*/l_A3_CT_URE_ID
          , /*A3_CT_URO_ID*/(SELECT e.P_ASSET_HEADER_ID
              FROM ins.VEN_P_ASSET_HEADER e
             WHERE e.EXT_ID = rec.AS_ASSET_ASSURED_ID)
          ,
           /*A4_CT_URE_ID*/l_A4_CT_URE_ID
          , /*A4_CT_URO_ID*/(SELECT v.T_PROD_LINE_OPTION_ID
              FROM ins.VEN_P_COVER V
             WHERE V.EXT_ID = rec.P_COVER_ID)
          ,
           /*A5_CT_URE_ID*/l_A5_CT_URE_ID
          , /*A5_CT_URO_ID*/(SELECT v.P_COVER_ID
              FROM ins.VEN_P_COVER V
             WHERE V.EXT_ID = rec.P_COVER_ID)
          ,
           /*TRANS_TEMPL_ID*/(SELECT e.TRANS_TEMPL_ID
              FROM ins.TRANS_TEMPL e
             WHERE e.BRIEF = 'НачПремия')
          ,
           /*ACC_CHART_TYPE_ID*/(SELECT v.ACC_CHART_TYPE_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'НачПремия')
          ,
           /*ACC_FUND_ID*/(SELECT v.FUND_ID FROM ins.FUND v WHERE v.BRIEF = 'RUR')
          ,
           /*ACC_AMOUNT*/s2n(rec.rev_CHARGE_PREMIUM)
          ,
           /*ACC_RATE*/s2n(rec.ACC_RATE)
          ,
           /*OPER_ID*/sq_oper_rsbu
          ,
           /*REG_DATE*/rec.DATE_RUS
          ,
           /*TRANS_QUANTITY*/0
          ,
           /*SOURCE*/'INS'
          ,
           /*NOTE*/'Конвертация'
          ,
           /*EXT_ID*/1
          ,
           /*OBJ_URE_ID*/(SELECT v.ENT_ID FROM ins.ENTITY v WHERE v.BRIEF = 'P_COVER')
          ,
           /*OBJ_URO_ID*/(SELECT v.P_COVER_ID FROM ins.P_COVER v WHERE v.EXT_ID = rec.P_COVER_ID));
      END IF;
      l_v := 2;
      -- Начислена премия МСФО - шаблон проводки МСФОПремияНач
      IF (s2n(rec.CHARGE_PREMIUM_IFRS) IS NOT NULL)
      THEN
        INSERT INTO ins.VEN_TRANS
          (TRANS_ID
          ,TRANS_DATE
          ,TRANS_FUND_ID
          ,TRANS_AMOUNT
          ,DT_ACCOUNT_ID
          ,CT_ACCOUNT_ID
          ,IS_ACCEPTED
          , --1
           A1_DT_URE_ID
          ,A1_DT_URO_ID
          ,A2_DT_URE_ID
          ,A2_DT_URO_ID
          ,A3_DT_URE_ID
          ,A3_DT_URO_ID
          ,A4_DT_URE_ID
          ,A4_DT_URO_ID
          ,A5_DT_URE_ID
          ,A5_DT_URO_ID
          ,A1_CT_URE_ID
          ,A1_CT_URO_ID
          ,A2_CT_URE_ID
          ,A2_CT_URO_ID
          ,A3_CT_URE_ID
          ,A3_CT_URO_ID
          ,A4_CT_URE_ID
          ,A4_CT_URO_ID
          ,A5_CT_URE_ID
          ,A5_CT_URO_ID
          ,TRANS_TEMPL_ID
          ,ACC_CHART_TYPE_ID
          ,ACC_FUND_ID
          ,ACC_AMOUNT
          ,ACC_RATE
          ,OPER_ID
          ,REG_DATE
          ,TRANS_QUANTITY
          , --0
           SOURCE
          , -- ins
           NOTE
          ,EXT_ID
          ,OBJ_URE_ID
          ,OBJ_URO_ID)
        VALUES
          (sq_TRANS.nextval
          ,
           /*TRANS_DATE*/rec.DATE_RUS
          ,
           /*TRANS_FUND_ID */(SELECT v.FUND_ID FROM ins.FUND v WHERE v.BRIEF = rec.POLICY_FUND_ID)
          ,
           /*TRANS_AMOUNT*/s2n(rec.CHARGE_PREMIUM_IFRS)
          ,
           /*DT_ACCOUNT_ID*/(SELECT v.DT_ACCOUNT_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'МСФОПремияНач')
          ,
           /*CT_ACCOUNT_ID*/(SELECT v.CT_ACCOUNT_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'МСФОПремияНач')
          ,
           /*IS_ACCEPTED*/1
          ,
           /*A1_DT_URE_ID*/l_A1_DT_URE_ID
          , /*A1_DT_URO_ID*/(SELECT c.CONTACT_ID
              FROM ins.ven_p_policy         p
                  ,ins.ven_p_policy_contact c
                  ,ins.T_CONTACT_POL_ROLE   t
             WHERE c.POLICY_ID = p.POLICY_ID
               AND c.CONTACT_POLICY_ROLE_ID = t.ID
               AND t.BRIEF = 'Страхователь'
               AND p.ext_id = rec.p_policy_id)
          ,
           /*A2_DT_URE_ID*/l_A2_DT_URE_ID
          , /*A2_DT_URO_ID*/(SELECT e.policy_id
              FROM ins.VEN_P_POLICY e
             WHERE e.EXT_ID = rec.p_policy_id)
          ,
           /*A3_DT_URE_ID*/l_A3_DT_URE_ID
          , /*A3_DT_URO_ID*/(SELECT e.P_ASSET_HEADER_ID
              FROM ins.VEN_P_ASSET_HEADER e
             WHERE e.EXT_ID = rec.AS_ASSET_ASSURED_ID)
          ,
           /*A4_DT_URE_ID*/l_A4_DT_URE_ID
          , /*A4_DT_URO_ID*/(SELECT v.T_PROD_LINE_OPTION_ID
              FROM ins.VEN_P_COVER V
             WHERE V.EXT_ID = rec.P_COVER_ID)
          ,
           /*A5_DT_URE_ID*/l_A5_DT_URE_ID
          , /*A5_DT_URO_ID*/(SELECT v.P_COVER_ID
              FROM ins.VEN_P_COVER V
             WHERE V.EXT_ID = rec.P_COVER_ID)
          ,
           /*A1_CT_URE_ID*/l_A1_CT_URE_ID
          , /*A1_CT_URO_ID*/(SELECT c.CONTACT_ID
              FROM ins.ven_p_policy         p
                  ,ins.ven_p_policy_contact c
                  ,ins.T_CONTACT_POL_ROLE   t
             WHERE c.POLICY_ID = p.POLICY_ID
               AND c.CONTACT_POLICY_ROLE_ID = t.ID
               AND t.BRIEF = 'Страхователь'
               AND p.ext_id = rec.p_policy_id)
          ,
           /*A2_CT_URE_ID*/l_A2_CT_URE_ID
          , /*A2_CT_URO_ID*/(SELECT e.policy_id
              FROM ins.VEN_P_POLICY e
             WHERE e.EXT_ID = rec.p_policy_id)
          ,
           /*A3_CT_URE_ID*/l_A3_CT_URE_ID
          , /*A3_CT_URO_ID*/(SELECT e.P_ASSET_HEADER_ID
              FROM ins.VEN_P_ASSET_HEADER e
             WHERE e.EXT_ID = rec.AS_ASSET_ASSURED_ID)
          ,
           /*A4_CT_URE_ID*/l_A4_CT_URE_ID
          , /*A4_CT_URO_ID*/(SELECT v.T_PROD_LINE_OPTION_ID
              FROM ins.VEN_P_COVER V
             WHERE V.EXT_ID = rec.P_COVER_ID)
          ,
           /*A5_CT_URE_ID*/l_A5_CT_URE_ID
          , /*A5_CT_URO_ID*/(SELECT v.P_COVER_ID
              FROM ins.VEN_P_COVER V
             WHERE V.EXT_ID = rec.P_COVER_ID)
          ,
           /*TRANS_TEMPL_ID*/(SELECT e.TRANS_TEMPL_ID
              FROM ins.TRANS_TEMPL e
             WHERE e.BRIEF = 'МСФОПремияНач')
          ,
           /*ACC_CHART_TYPE_ID*/(SELECT v.ACC_CHART_TYPE_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'МСФОПремияНач')
          ,
           /*ACC_FUND_ID*/(SELECT v.FUND_ID FROM ins.FUND v WHERE v.BRIEF = 'RUR')
          ,
           /*ACC_AMOUNT*/s2n(rec.REV_CHARGE_PREMIUM_IFRS)
          ,
           /*ACC_RATE*/s2n(rec.ACC_RATE)
          ,
           /*OPER_ID*/sq_oper_msfo
          ,
           /*REG_DATE*/rec.DATE_IFRS
          ,
           /*TRANS_QUANTITY*/0
          ,
           /*SOURCE*/'INS'
          ,
           /*NOTE*/'Конвертация'
          ,
           /*EXT_ID*/1
          ,
           /*OBJ_URE_ID*/(SELECT v.ENT_ID FROM ins.ENTITY v WHERE v.BRIEF = 'P_COVER')
          ,
           /*OBJ_URO_ID*/(SELECT v.P_COVER_ID FROM ins.P_COVER v WHERE v.EXT_ID = rec.P_COVER_ID));
      END IF;
      l_v := 3;
      --Начислена премия АРЕ - шаблон проводки МСФОПремияНачАРЕ
      IF (s2n(rec.CHARGE_PREMIUM_APE) IS NOT NULL)
      THEN
        INSERT INTO ins.VEN_TRANS
          (TRANS_ID
          ,TRANS_DATE
          ,TRANS_FUND_ID
          ,TRANS_AMOUNT
          ,DT_ACCOUNT_ID
          ,CT_ACCOUNT_ID
          ,IS_ACCEPTED
          , --1
           A1_DT_URE_ID
          ,A1_DT_URO_ID
          ,A1_CT_URE_ID
          ,A1_CT_URO_ID
          ,A2_DT_URE_ID
          ,A2_DT_URO_ID
          ,A2_CT_URE_ID
          ,A2_CT_URO_ID
          ,A3_DT_URE_ID
          ,A3_DT_URO_ID
          ,A3_CT_URE_ID
          ,A3_CT_URO_ID
          ,A4_DT_URE_ID
          ,A4_DT_URO_ID
          ,A4_CT_URE_ID
          ,A4_CT_URO_ID
          ,A5_DT_URE_ID
          ,A5_DT_URO_ID
          ,A5_CT_URE_ID
          ,A5_CT_URO_ID
          ,TRANS_TEMPL_ID
          ,ACC_CHART_TYPE_ID
          ,ACC_FUND_ID
          ,ACC_AMOUNT
          ,ACC_RATE
          ,OPER_ID
          ,REG_DATE
          ,TRANS_QUANTITY
          , --0
           SOURCE
          , -- ins
           NOTE
          ,EXT_ID
          ,OBJ_URE_ID
          ,OBJ_URO_ID)
        VALUES
          (sq_TRANS.nextval
          ,
           /*TRANS_DATE*/rec.DATE_APE
          ,
           /*TRANS_FUND_ID */(SELECT v.FUND_ID FROM ins.FUND v WHERE v.BRIEF = rec.POLICY_FUND_ID)
          ,
           /*TRANS_AMOUNT*/s2n(rec.CHARGE_PREMIUM_APE)
          ,
           /*DT_ACCOUNT_ID*/(SELECT v.DT_ACCOUNT_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'МСФОПремияНачAPE')
          ,
           /*CT_ACCOUNT_ID*/(SELECT v.CT_ACCOUNT_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'МСФОПремияНачAPE')
          ,
           /*IS_ACCEPTED*/1
          ,
           /*A1_DT_URE_ID*/NULL
          ,
           /*A1_DT_URO_ID*/NULL
          ,
           /*A1_CT_URE_ID*/NULL
          ,
           /*A1_CT_URO_ID*/NULL
          ,
           /*A2_DT_URE_ID*/NULL
          ,
           /*A2_DT_URO_ID*/NULL
          ,
           /*A2_CT_URE_ID*/NULL
          ,
           /*A2_CT_URO_ID*/NULL
          ,
           /*A3_DT_URE_ID*/NULL
          ,
           /*A3_DT_URO_ID*/NULL
          ,
           /*A3_CT_URE_ID*/NULL
          ,
           /*A3_CT_URO_ID*/NULL
          ,
           /*A4_DT_URE_ID*/NULL
          ,
           /*A4_DT_URO_ID*/NULL
          ,
           /*A4_CT_URE_ID*/NULL
          ,
           /*A4_CT_URO_ID*/NULL
          ,
           /*A5_DT_URE_ID*/NULL
          ,
           /*A5_DT_URO_ID*/NULL
          ,
           /*A5_CT_URE_ID*/NULL
          ,
           /*A5_CT_URO_ID*/NULL
          ,
           /*TRANS_TEMPL_ID*/(SELECT e.TRANS_TEMPL_ID
              FROM ins.TRANS_TEMPL e
             WHERE e.BRIEF = 'МСФОПремияНачAPE')
          ,
           /*ACC_CHART_TYPE_ID*/(SELECT v.ACC_CHART_TYPE_ID
              FROM ins.TRANS_TEMPL v
             WHERE v.BRIEF = 'МСФОПремияНачAPE')
          ,
           /*ACC_FUND_ID*/(SELECT v.FUND_ID FROM ins.FUND v WHERE v.BRIEF = 'RUR')
          ,
           /*ACC_AMOUNT*/s2n(rec.rev_CHARGE_PREMIUM_APE)
          ,
           /*ACC_RATE*/s2n(rec.ACC_RATE)
          ,
           /*OPER_ID*/sq_oper_ape
          ,
           /*REG_DATE*/rec.DATE_APE
          ,
           /*TRANS_QUANTITY*/0
          ,
           /*SOURCE*/'INS'
          ,
           /*NOTE*/'Конвертация'
          ,
           /*EXT_ID*/1
          ,
           /*OBJ_URE_ID*/(SELECT v.ENT_ID FROM ins.ENTITY v WHERE v.BRIEF = 'P_COVER')
          ,
           /*OBJ_URO_ID*/(SELECT v.P_COVER_ID FROM ins.VEN_P_COVER v WHERE v.EXT_ID = rec.P_COVER_ID));
      END IF;
      COMMIT;
    END LOOP;
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации начислений :' || l_v || ':' || L_V2
                               ,'pkg_convert_blogic'
                               ,'FN_POLICY_CHARGE'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_exept;
  END FN_POLICY_CHARGE;

  /**  Событие  */
  FUNCTION FN_EVENT(p_valid NUMBER) RETURN NUMBER IS
    sq_event      NUMBER;
    sq_event_cont NUMBER;
    l_EXT_ID      NUMBER;
  BEGIN
  
    FOR rec IN cur_event
    LOOP
      l_EXT_ID := rec.EXT_ID;
    
      SELECT ins.sq_C_EVENT.nextval INTO sq_event FROM dual;
    
      INSERT INTO ins.VEN_C_EVENT
        (C_EVENT_ID
        ,EVENT_DATE
        ,CATASTROPHE_TYPE_ID
        ,DATE_DECLARE
        ,REC_INFO_TYPE_ID
        ,CODE_OCATO
        ,DESCRIPTION_EVENT
        ,EVENT_PLACE_TYPE_ID
        ,CN_ADDRESS
        ,FILIAL_ID
        ,VEHICLE_DAMAGE_NOTE
        ,EVENT_VEHICLES
        ,AS_ASSET_ID
        ,EMERGENCY_COMMISSAR_ORG
        ,EMERGENCY_OPERATOR
        ,COMMISAR_DATE_OUT_FIO
        ,EVACUATION_ORG
        ,EVACUATION_OPERATOR
        ,EVACUATION_PLACE
        ,DISPATCHER_FIO_ID
        ,EMERGENCY_DESCRIPTION
        ,EVACUATION_DESCRIPTION
        ,ASSURED_ID
        ,INFORMATOR_ID
        ,DATE_COMPANY
        ,EXT_ID
        ,DOC_TEMPL_ID
        ,NUM
        ,REG_DATE)
      VALUES
        (sq_event
        ,rec.EVENT_DATE
        ,rec.CATASTROPHE_TYPE_ID
        ,rec.DATE_DECLARE
        ,rec.REC_INFO_TYPE_ID
        ,rec.CODE_OCATO
        ,rec.DESCRIPTION_EVENT
        ,rec.EVENT_PLACE_TYPE_ID
        ,rec.CN_ADDRESS
        ,rec.FILIAL_ID
        ,rec.VEHICLE_DAMAGE_NOTE
        ,rec.EVENT_VEHICLES
        ,
         /*  AS_ASSET_ID*/(SELECT s.AS_ASSET_ID FROM AS_ASSET s WHERE s.EXT_ID = rec.EXT_AS_ASSET_ID)
        ,rec.EMERGENCY_COMMISSAR_ORG
        ,rec.EMERGENCY_OPERATOR
        ,rec.COMMISAR_DATE_OUT_FIO
        ,rec.EVACUATION_ORG
        ,rec.EVACUATION_OPERATOR
        ,rec.EVACUATION_PLACE
        ,
         /* !  */rec.DISPATCHER_FIO_ID
        ,rec.EMERGENCY_DESCRIPTION
        ,rec.EVACUATION_DESCRIPTION
        ,
         /* ASSURED_ID */(SELECT c.CONTACT_ID FROM contact c WHERE c.EXT_ID = rec.EXT_ASSURED_ID)
        ,
         /* INFORMATOR_ID*/(SELECT c.CONTACT_ID FROM contact c WHERE c.EXT_ID = rec.EXT_ASSURED_ID)
        ,rec.DATE_COMPANY
        ,rec.EXT_ID
        ,
         /* DOC_TEMPL_ID*/(SELECT t.DOC_TEMPL_ID
            FROM ins.doc_templ t
           WHERE upper(t.BRIEF) = upper('C_EVENT'))
        ,rec.DOC_NUM
        ,rec.DOC_REG_DATE);
    
      pkg_convert.UpdateConvert('ins.cnv_c_event', rec.rrw);
    END LOOP;
    /* C_EVENT_CONTACT */
  
    FOR rec IN cur_event_contact
    LOOP
      SELECT ins.sq_C_EVENT_CONTACT.nextval INTO sq_event_cont FROM dual;
      INSERT INTO ven_C_EVENT_CONTACT
        (C_EVENT_CONTACT_id
        ,C_EVENT_ID
        ,C_EVENT_CONTACT_ROLE_ID
        ,CN_PERSON_ID
        ,T_VICTIM_OSAGO_TYPE_ID
        ,EXT_ID)
      VALUES
        (sq_event_cont
        ,
         /* C_EVENT_ID*/(SELECT ce.C_EVENT_ID FROM ven_c_event ce WHERE ce.ext_id = rec.EXT_C_EVENT_ID)
        ,rec.C_EVENT_CONTACT_ROLE_ID
        ,
         /* CN_PERSON_ID*/(SELECT c.contact_id FROM contact c WHERE c.EXT_ID = rec.EXT_CONTACT_ID)
        ,rec.T_VICTIM_OSAGO_TYPE_ID
        ,rec.EXT_ID);
    
      pkg_convert.UpdateConvert('ins.cnv_c_event_contact', rec.rrw);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации убытков'
                               ,'pkg_convert_blogic'
                               ,'FN_EVENT'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_exept;
  END FN_EVENT;

  /**  Заявление  */
  FUNCTION FN_CLAIM(p_valid NUMBER) RETURN NUMBER IS
    --c_ext_claim_id number;
  
    CURSOR cur_claim_head(c_ext_claim_id NUMBER) IS
      SELECT *
        FROM ven_c_claim vc
       WHERE vc.EXT_ID = (SELECT c.EXT_ID FROM cnv_c_claim c WHERE c.EXT_ID = c_ext_claim_id);
  
    sq_claim        NUMBER;
    sq_claim_header NUMBER;
    rec_claim_head  cur_claim_head%ROWTYPE;
    l_EXIT_ID       NUMBER;
  
  BEGIN
  
    FOR rec IN cur_claim
    LOOP
      l_EXIT_ID := rec.EXT_ID;
      SELECT ins.sq_C_CLAIM_HEADER.nextval INTO sq_claim_header FROM dual;
    
      INSERT INTO ven_c_declarants
        (c_claim_header_id, declarant_role_id, share_payment, ext_id, declarant_id)
      VALUES
        (sq_claim_header
        ,rec.DECLARANT_ROLE_ID
        ,100
        ,rec.ext_declarant_id
        ,(SELECT c.C_EVENT_CONTACT_ID FROM C_EVENT_CONTACT c WHERE c.ext_id = rec.EXT_DECLARANT_ID));
      INSERT INTO ins.ven_C_CLAIM_HEADER
        (C_CLAIM_HEADER_ID
        ,P_POLICY_ID
        ,C_EVENT_ID
        ,
         --DECLARANT_ROLE_ID, --Чирков удаление старых связей заявителей
         --DECLARANT_ID,      --Чирков удаление старых связей заявителей
         FUND_ID
        ,NOTICE_DATE
        ,NOTICE_TYPE_ID
        ,DECLARE_DATE
        ,IS_REGRESS
        ,IS_CRIMINAL
        ,DEPART_ID
        ,CURATOR_ID
        ,AS_ASSET_ID
        ,FILIAL_ID
        ,P_COVER_ID
        ,PAYMENT_TERM_ID
        ,FIRST_PAYMENT_DATE
        ,RATE_ON_DATE_ID
        ,FUND_PAY_ID
        ,DEDUCTIBLE_VALUE
        ,DOC_TEMPL_ID
        ,NUM
        ,REG_DATE
        ,EXT_ID)
      VALUES
        (sq_claim_header
        ,
         /*P_POLICY_ID*/(SELECT p.POLICY_ID FROM ven_p_policy p WHERE p.ext_id = rec.EXT_P_POLICY_ID)
        ,
         /*C_EVENT_ID*/(SELECT c.C_EVENT_ID FROM ven_c_event c WHERE c.ext_id = rec.EXT_C_EVENT_ID)
        ,
         --rec.DECLARANT_ROLE_ID,
         /* DECLARANT_ID*/
         --(select c.C_EVENT_CONTACT_ID from C_EVENT_CONTACT c where c.ext_id = rec.EXT_DECLARANT_ID),
         -- rec.DECLARANT_ID,
         rec.FUND_ID
        ,rec.NOTICE_DATE
        ,rec.NOTICE_TYPE_ID
        ,rec.DECLARE_DATE
        ,rec.IS_REGRESS
        ,rec.IS_CRIMINAL
        ,rec.DEPART_ID
        ,
         /* CURATOR_ID*/(SELECT c.CONTACT_ID FROM contact c WHERE c.EXT_ID = rec.EXT_CURATOR_ID)
        ,
         --(select c.contact_id from contact c where c.ext_id = rec.ext_CURATOR_ID)
         /* AS_ASSET_ID*/(SELECT s.AS_ASSET_ID FROM AS_ASSET s WHERE s.EXT_ID = rec.EXT_AS_ASSET_ID)
        ,rec.FILIAL_ID
        ,
         /* P_COVER_ID*/(SELECT p.P_COVER_ID FROM p_cover p WHERE p.EXT_ID = rec.EXT_P_COVER_ID)
        ,rec.PAYMENT_TERM_ID
        ,rec.FIRST_PAYMENT_DATE
        ,rec.RATE_ON_DATE_ID
        ,rec.FUND_PAY_ID
        ,rec.DEDUCTIBLE_VALUE
        ,
         /* DOC_TEMPL_ID*/(SELECT t.DOC_TEMPL_ID
            FROM ins.doc_templ t
           WHERE upper(t.BRIEF) = upper('Претензия'))
        ,rec.DOC_NUM
        ,rec.DOC_REG_DATE
        ,REC.EXT_ID);
    
      UPDATE ven_C_EVENT_CONTACT cev
         SET cev.C_CLAIM_HEADER_ID = sq_claim_header
       WHERE cev.EXT_ID = rec.EXT_DECLARANT_ID;
    
      SELECT ins.sq_C_CLAIM.nextval INTO sq_claim FROM dual;
      INSERT INTO ins.ven_C_CLAIM
        (C_CLAIM_ID
        ,C_CLAIM_HEADER_ID
        ,SEQNO
        ,CLAIM_STATUS_ID
        ,CLAIM_STATUS_DATE
        ,DECLARE_SUM
        ,ASSET_OF_VICTIM
        ,COMPENSATE_DAMAGE_SUM
        ,ACCOUNT_PAYMENT
        ,BENEFICIARY_SUM
        ,DAMAGE_PAYMENT_SUM
        ,PAYMENT_SUM
        ,INTERPAYMENT_SUM
        ,ADDITIONAL_EXPENSES_SUM
        ,ADDITIONAL_EXPENSES_OWN_SUM
        ,ADDITIONAL_EXPENSES_NOOWN_SUM
        ,FILIAL_ID
        ,IS_HANDSET_DECLINE
        ,EXT_ID
        ,DOC_TEMPL_ID
        ,NUM
        ,REG_DATE)
      VALUES
        (sq_claim
        ,sq_claim_header
        ,rec.SEQNO
        ,rec.CLAIM_STATUS_ID
        ,rec.CLAIM_STATUS_DATE
        ,rec.DECLARE_SUM
        ,rec.ASSET_OF_VICTIM
        ,rec.COMPENSATE_DAMAGE_SUM
        ,rec.ACCOUNT_PAYMENT
        ,rec.BENEFICIARY_SUM
        ,rec.DAMAGE_PAYMENT_SUM
        ,rec.PAYMENT_SUM
        ,rec.INTERPAYMENT_SUM
        ,rec.ADDITIONAL_EXPENSES_SUM
        ,rec.ADDITIONAL_EXPENSES_OWN_SUM
        ,rec.ADDITIONAL_EXPENSES_NOOWN_SUM
        ,rec.FILIAL_ID
        ,rec.IS_HANDSET_DECLINE
        ,rec.EXT_ID
        ,
         /* DOC_TEMPL_ID*/(SELECT t.DOC_TEMPL_ID
            FROM ins.doc_templ t
           WHERE upper(t.BRIEF) = upper('ПретензияСС'))
        ,rec.DOC_NUM
        ,rec.DOC_REG_DATE);
    
      pkg_convert.UpdateConvert('ins.cnv_c_claim', rec.rrw);
    END LOOP;
  
    FOR rec IN cur_claim_add
    LOOP
      l_EXIT_ID := rec.EXT_ID;
      OPEN cur_claim_head(rec.HEAD_EXT_ID);
      FETCH cur_claim_head
        INTO rec_claim_head;
      pkg_convert.raise_ExB(cur_claim_head%NOTFOUND, TRUE);
      CLOSE cur_claim_head;
    
      sq_claim_header := rec_claim_head.C_CLAIM_HEADER_ID;
    
      SELECT ins.sq_C_CLAIM.nextval INTO sq_claim FROM dual;
      INSERT INTO ins.ven_C_CLAIM
        (C_CLAIM_ID
        ,C_CLAIM_HEADER_ID
        ,SEQNO
        ,CLAIM_STATUS_ID
        ,CLAIM_STATUS_DATE
        ,DECLARE_SUM
        ,ASSET_OF_VICTIM
        ,COMPENSATE_DAMAGE_SUM
        ,ACCOUNT_PAYMENT
        ,BENEFICIARY_SUM
        ,DAMAGE_PAYMENT_SUM
        ,PAYMENT_SUM
        ,INTERPAYMENT_SUM
        ,ADDITIONAL_EXPENSES_SUM
        ,ADDITIONAL_EXPENSES_OWN_SUM
        ,ADDITIONAL_EXPENSES_NOOWN_SUM
        ,FILIAL_ID
        ,IS_HANDSET_DECLINE
        ,EXT_ID
        ,DOC_TEMPL_ID
        ,NUM
        ,REG_DATE)
      VALUES
        (sq_claim
        ,sq_claim_header
        ,rec.SEQNO
        ,rec.CLAIM_STATUS_ID
        ,rec.CLAIM_STATUS_DATE
        ,rec.DECLARE_SUM
        ,rec.ASSET_OF_VICTIM
        ,rec.COMPENSATE_DAMAGE_SUM
        ,rec.ACCOUNT_PAYMENT
        ,rec.BENEFICIARY_SUM
        ,rec.DAMAGE_PAYMENT_SUM
        ,rec.PAYMENT_SUM
        ,rec.INTERPAYMENT_SUM
        ,rec.ADDITIONAL_EXPENSES_SUM
        ,rec.ADDITIONAL_EXPENSES_OWN_SUM
        ,rec.ADDITIONAL_EXPENSES_NOOWN_SUM
        ,rec.FILIAL_ID
        ,rec.IS_HANDSET_DECLINE
        ,rec.EXT_ID
        ,
         /* DOC_TEMPL_ID*/(SELECT t.DOC_TEMPL_ID
            FROM ins.doc_templ t
           WHERE upper(t.BRIEF) = upper('ПретензияСС'))
        ,rec.DOC_NUM
        ,rec.DOC_REG_DATE);
    
      pkg_convert.UpdateConvert('ins.cnv_c_claim', rec.rrw);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации убытков'
                               ,'pkg_convert_blogic'
                               ,'FN_CLAIM'
                               ,SQLCODE
                               ,SQLERRM);
      IF (cur_claim%ISOPEN)
      THEN
        CLOSE cur_claim;
      END IF;
    
      IF (cur_claim_head%ISOPEN)
      THEN
        CLOSE cur_claim_head;
      END IF;
      IF (cur_claim_add%ISOPEN)
      THEN
        CLOSE cur_claim_add;
      END IF;
    
      RETURN pkg_convert.c_exept;
  END FN_CLAIM;

  /* убытки  */
  FUNCTION FN_DAMAGE(p_valid NUMBER) RETURN NUMBER IS
    sq_damage NUMBER;
  BEGIN
    FOR rec IN cur_damage
    LOOP
      SELECT ins.sq_C_DAMAGE.nextval INTO sq_damage FROM dual;
      INSERT INTO ven_c_damage
        (C_DAMAGE_ID
        ,C_CLAIM_ID
        ,T_DAMAGE_CODE_ID
        ,P_COVER_ID
        ,DECLARE_SUM
        ,C_DAMAGE_TYPE_ID
        ,C_DAMAGE_COST_TYPE_ID
        ,C_DAMAGE_EXGR_TYPE_ID
        ,C_DAMAGE_STATUS_ID
        ,DAMAGE_FUND_ID
        ,DOCBASIS_ID
        ,DEDUCT_SUM
        ,DECLINE_SUM
        ,DECLINE_REASON_ID
        ,DECLINE_REASON
        ,PAYMENT_SUM
        ,FILIAL_ID
        ,STATUS_HIST_ID
        ,EXT_ID)
      VALUES
        (sq_damage
        ,
         /*C_CLAIM_ID,*/(SELECT c.C_CLAIM_ID FROM ven_c_claim c WHERE c.ext_id = rec.ext_C_CLAIM_ID)
        ,rec.T_DAMAGE_CODE_ID
        ,
         /*P_COVER_ID*/(SELECT p.P_COVER_ID FROM ven_p_cover p WHERE p.ext_id = rec.ext_P_COVER_ID)
        ,rec.DECLARE_SUM
        ,rec.C_DAMAGE_TYPE_ID
        ,rec.C_DAMAGE_COST_TYPE_ID
        ,rec.C_DAMAGE_EXGR_TYPE_ID
        ,rec.C_DAMAGE_STATUS_ID
        ,rec.DAMAGE_FUND_ID
        ,rec.DOCBASIS_ID
        ,rec.DEDUCT_SUM
        ,rec.DECLINE_SUM
        ,rec.DECLINE_REASON_ID
        ,rec.DECLINE_REASON
        ,rec.PAYMENT_SUM
        ,rec.FILIAL_ID
        ,rec.STATUS_HIST_ID
        ,rec.EXT_ID);
      pkg_convert.UpdateConvert('ins.cnv_c_damage', rec.rrw);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при конвертации убытков'
                               ,'pkg_convert_blogic'
                               ,'FN_DAMAGE'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_exept;
  END FN_DAMAGE;

  FUNCTION FN_CHECK_DUBLICATE
  (
    p_ext_id     NUMBER
   ,p_table_name VARCHAR2
  ) RETURN NUMBER IS
  
    l_res NUMBER;
  BEGIN
    EXECUTE IMMEDIATE 'select count(t.CONTACT_ID)  from ' || p_table_name || ' t ' --where t.ext_id = :val2'
      INTO l_res;
    --USING out l_res;--, in p_ext_id ;
  
    IF (l_res IS NULL)
    THEN
      RETURN pkg_convert.c_false;
    END IF;
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('ошибка при проверке дубликатов контакта'
                               ,'PKG_CONVERT_BLOGIC'
                               ,'FN_CHECK_DUBLICATE'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN PKG_CONVERT.c_true;
    
  END FN_CHECK_DUBLICATE;

  PROCEDURE valid_contact IS
  
    CURSOR cur_invalid_contact_pass IS
      SELECT c.ext_id
            ,c.rowid AS rrw
        FROM convert_contact_fis c
       WHERE c.NUMBER_PASSPORT IS NOT NULL
         AND c.passport_brif IS NULL;
  
    CURSOR cur_invalid_contact_pass2 IS
      SELECT c.ext_id
            ,c.rowid AS rrw
            ,c.NUMBER_PASSPORT
        FROM convert_contact_fis c
       WHERE c.NUMBER_PASSPORT IS NOT NULL;
  
    CURSOR cur_invalid_contact_account IS
      SELECT c.ext_id
            ,c.rowid AS rrw
        FROM convert_contact_ur c
       WHERE c.NUM_ACCOUNT IS NOT NULL
         AND (c.ACC_BIK_BANK IS NULL OR c.ACC_KORR_BANK IS NULL OR c.ACC_INN_BANK IS NULL OR
             c.ACC_NAME_BANK IS NULL OR c.FUND_ACC IS NULL);
  
    CURSOR cur_invalid_contact_account2 IS
      SELECT c.ext_id
            ,c.rowid AS rrw
        FROM convert_contact_ur c
       WHERE c.NUM_ACCOUNT2 IS NOT NULL
         AND (c.ACC_BIK_BANK2 IS NULL OR c.ACC_KORR_BANK2 IS NULL OR c.ACC_INN_BANK2 IS NULL OR
             c.ACC_NAME_BANK2 IS NULL OR c.FUND_ACC2 IS NULL);
  
    FUNCTION check_valid_number(p_val VARCHAR2) RETURN NUMBER IS
      p_val_number NUMBER;
    BEGIN
    
      p_val_number := To_NUMBER(p_val);
    
      RETURN pkg_convert.c_true;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN pkg_convert.c_false;
      
    END check_valid_number;
  
  BEGIN
  
    FOR rec IN cur_invalid_contact_pass
    LOOP
      pkg_convert.UnCheckConvert('convert_contact', rec.rrw);
      pkg_convert.SP_EVENTERROR('Задан паспорт, но не задан его тип'
                               ,'PKG_CONVERT_BLogic'
                               ,'valid_contact'
                               ,'0'
                               ,rec.ext_id);
    END LOOP;
  
    FOR rec IN cur_invalid_contact_pass2
    LOOP
      IF (check_valid_number(rec.NUMBER_PASSPORT) = pkg_convert.c_false)
      THEN
        pkg_convert.SP_EVENTERROR('Номер паспорта невозможно перевести в номер'
                                 ,'PKG_CONVERT_BLogic'
                                 ,'valid_contact'
                                 ,'0'
                                 ,rec.ext_id);
        pkg_convert.UnCheckConvert('convert_contact', rec.rrw);
      END IF;
    END LOOP;
  
    FOR rec IN cur_invalid_contact_account
    LOOP
      pkg_convert.UnCheckConvert('convert_contact', rec.rrw);
      pkg_convert.SP_EVENTERROR('Задан счет, но не заданы или неполностью указаны параметры банка'
                               ,'PKG_CONVERT_BLogic'
                               ,'valid_contact'
                               ,'0'
                               ,rec.ext_id);
    END LOOP;
  
    FOR rec IN cur_invalid_contact_account2
    LOOP
      pkg_convert.UnCheckConvert('convert_contact', rec.rrw);
      pkg_convert.SP_EVENTERROR('Задан второй счет, но не заданы или неполностью указаны параметры банка'
                               ,'PKG_CONVERT_BLogic'
                               ,'valid_contact'
                               ,'0'
                               ,rec.ext_id);
    END LOOP;
  END;

  PROCEDURE convert_period IS
    CURSOR cur_convert_period IS
      SELECT * FROM convert_period;
  
    CURSOR cur_period
    (
      P_PERIOD_TYPE_ID NUMBER
     ,P_PERIOD_VALUE   NUMBER
    ) IS
      SELECT *
        FROM t_period t
       WHERE t.PERIOD_VALUE = P_PERIOD_VALUE
         AND t.PERIOD_TYPE_ID = P_PERIOD_TYPE_ID;
  
    rec_period    cur_period%ROWTYPE;
    l_description VARCHAR2(100);
  BEGIN
  
    FOR rec_convert IN cur_convert_period
    LOOP
      OPEN cur_period(rec_convert.PERIOD_TYPE_ID, rec_convert.PERIOD_VALUE);
      FETCH cur_period
        INTO rec_period;
      IF (cur_period%NOTFOUND)
      THEN
      
        SELECT (rec_convert.period_value || ' ' || decode(tt.id, 3, 'лет', tt.description))
          INTO l_description
          FROM t_period_type tt
         WHERE tt.id = rec_convert.PERIOD_TYPE_ID;
      
        /*     insert into t_period@ins11 (ID,
                              PERIOD_TYPE_ID,
                              PERIOD_VALUE,
                              DESCRIPTION,
                              EXT_ID)
        values(sq_t_period.nextval,
               rec_convert.PERIOD_TYPE_ID,
               rec_convert.period_value,
               l_description,
               rec_convert.ext_id);*/
      END IF;
      CLOSE cur_period;
    END LOOP;
  
  END convert_period;

  FUNCTION FN_AGENCY(p_valid NUMBER) RETURN NUMBER IS
    sq_val  NUMBER;
    sq_val2 NUMBER;
    center  NUMBER;
    l_num   NUMBER;
  BEGIN
    FOR rec_convert IN cur_agency
    LOOP
      SELECT ins.sq_ORGANISATION_TREE.nextval INTO sq_val FROM dual;
    
      SELECT MIN(t.ORGANISATION_TREE_ID)
        INTO center
        FROM ins.ORGANISATION_TREE t
       WHERE t.NAME = 'Центральный офис';
    
      INSERT INTO ins.ORGANISATION_TREE
        (ORGANISATION_TREE_ID, PARENT_ID, NAME, COMPANY_ID, EXT_ID, CODE)
      VALUES
        (sq_val
        ,(SELECT NVL(MAX(t.ORGANISATION_TREE_ID), center)
           FROM ins.ORGANISATION_TREE t
          WHERE t.NAME = rec_convert.ORGANISATION_TREE_NAME)
        ,rec_convert.Name
        ,(SELECT c.CONTACT_ID FROM ins.contact c WHERE c.LATIN_NAME = 'RenLife')
        ,rec_convert.EXT_ID
        ,rec_convert.CODE);
    
      SELECT ins.SQ_DEPARTMENT.NEXTVAL INTO sq_val2 FROM dual;
    
      INSERT INTO ins.DEPARTMENT
        (DEPARTMENT_ID, ORG_TREE_ID, NAME, EXT_ID, CODE, DATE_OPEN, DATE_CLOSE)
      VALUES
        (sq_val2
        ,sq_val
        ,rec_convert.Name
        ,rec_convert.EXT_ID
        ,rec_convert.CODE
        ,rec_convert.DATE_OPEN
        ,rec_convert.DATE_CLOSE);
    
      INSERT INTO ins.DEPT_EXECUTIVE
        (DEPT_EXECUTIVE_ID, EXT_ID, CONTACT_ID, DEPARTMENT_ID)
      VALUES
        (ins.SQ_DEPT_EXECUTIVE.NEXTVAL
        ,rec_convert.EXT_ID
        ,(SELECT contact_id FROM ins.contact WHERE ext_id = rec_convert.EXT_CONTACT_ID)
        ,sq_val2);
    END LOOP;
  
    UPDATE DEPARTMENT D SET D.CODE = RTRIM(D.CODE, '-');
  
    UPDATE ORGANISATION_TREE D SET D.CODE = RTRIM(D.CODE, '-');
  
    -- при дублировании записей после работы конвертации необходимо будет запустить этот патчик:
  
    -- SAI
    --Патчи
    /*
    update DEPARTMENT D set D.ORG_TREE_ID =
    (
    select MIN(TT.ORGANISATION_TREE_ID) from (
    select
    MIN(T.TL) over (partition by D.DEPARTMENT_ID) as M_LEVEL,TL,
    D.DEPARTMENT_ID, T.ORGANISATION_TREE_ID, D.CODE as D_CODE,T.CODE
     from DEPARTMENT D,
    (select o.*,level as TL from ORGANISATION_TREE O
    where ext_id is not null
    start WITH o.PARENT_ID is null
    connect by prior o.ORGANISATION_TREE_ID  = o.PARENT_ID) T
    where D.CODE = T.CODE and D.Ext_id is not null ) TT
    where TT.M_LEVEL = TT.TL and D.DEPARTMENT_ID = TT.DEPARTMENT_ID)
    where D.EXT_ID is not null
    and D.CODE is not null;
    
    delete  from ORGANISATION_TREE o where o.CODE is not null and o.EXT_ID is not null and
    not exists (select 1 from DEPARTMENT D where D.ORG_TREE_ID = O.ORGANISATION_TREE_ID);
    
    delete  from ORGANISATION_TREE o where o.EXT_ID is not null and
    not exists (select 1 from DEPARTMENT D where D.ORG_TREE_ID = O.ORGANISATION_TREE_ID);
    
    
    commit;*/
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации агентсва '
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AGENCY'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AGENCY;

  FUNCTION FN_AG_HEADER(p_valid NUMBER) RETURN NUMBER IS
    sq_doc       NUMBER;
    l_ext_id     NUMBER;
    l_line_error NUMBER;
  BEGIN
    FOR rec_convert IN cur_AG_HEADER
    LOOP
      l_line_error := 1;
      l_ext_id     := rec_convert.ext_id;
      SELECT ins.SQ_DOCUMENT.nextval INTO sq_doc FROM dual;
    
      INSERT INTO ins.VEN_AG_CONTRACT_HEADER
        (AG_CONTRACT_HEADER_ID
        ,AGENT_ID
        ,DATE_BEGIN
        ,DATE_BREAK
        ,AGENCY_ID
        ,AG_CONTRACT_TEMPL_ID
        ,EXT_ID
        ,REG_DATE
        ,NOTE
        ,NUM
        ,doc_templ_id)
      VALUES
        (sq_doc
        ,(SELECT C.CONTACT_ID FROM ins.CONTACT C WHERE C.EXT_ID = rec_convert.EXT_CONTACT_ID)
        ,rec_convert.DATE_BEGIN
        ,rec_convert.DATE_BREAK
        ,(SELECT D.DEPARTMENT_ID FROM ins.DEPARTMENT D WHERE D.EXT_ID = rec_convert.EXT_AGENCY_ID)
        ,(SELECT AG.AG_CONTRACT_HEADER_ID
           FROM ins.AG_CONTRACT_HEADER AG
          WHERE AG.TEMPL_BRIEF = rec_convert.BRIEF_AG_CONTRACT_TEMPL)
        ,rec_convert.EXT_ID
        ,rec_convert.DATE_BEGIN
        ,'Конвертация RenLife'
        ,rec_convert.NUM
        ,(SELECT DT.DOC_TEMPL_ID FROM DOC_TEMPL DT WHERE DT.BRIEF = 'AG_CONTRACT_HEADER'));
      l_line_error := 2;
      INSERT INTO ins.DOC_STATUS
        (DOC_STATUS_ID, DOCUMENT_ID, DOC_STATUS_REF_ID, START_DATE, EXT_ID, CHANGE_DATE)
      VALUES
        (ins.SQ_DOC_STATUS.NEXTVAL
        ,sq_doc
        ,(SELECT D.DOC_STATUS_REF_ID FROM ins.DOC_STATUS_REF D WHERE D.BRIEF = rec_convert.DOC_STATUS)
        ,rec_convert.DOC_STATUS_DATE
        ,rec_convert.EXT_ID
        ,rec_convert.DOC_STATUS_DATE);
      l_line_error := 3;
      --pkg_convert.UpdateConvert('ins.CONVERT_AG_HEADER',rec_convert.rrw);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации головы агенского договора:' || l_ext_id || ':' ||
                                l_line_error
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AG_HEADER'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AG_HEADER;

  FUNCTION FN_AG_CONTRACT(p_valid NUMBER) RETURN NUMBER IS
    sq_doc  NUMBER;
    l_val   NUMBER;
    l_val_e NUMBER;
  BEGIN
    FOR rec_convert IN cur_AG_CONTRACT
    LOOP
      l_val := 1;
      SELECT ins.SQ_DOCUMENT.nextval INTO sq_doc FROM dual;
    
      INSERT INTO ins.VEN_AG_CONTRACT
        (AG_CONTRACT_ID
        ,CATEGORY_ID
        ,DATE_BEGIN
        ,DATE_END
        ,CONTRACT_ID
        ,CONTRACT_LEADER_ID
        ,CONTRACT_F_LEAD_ID
        ,CONTRACT_RECRUT_ID
        ,METHOD_PAYMENT
        ,AG_CONTRACT_TEMPL_ID
        ,LEG_POS
        ,AGENCY_ID
        ,EXT_ID
        ,DOC_TEMPL_ID
        ,NOTE
        ,NUM
        ,REG_DATE)
      VALUES
        (sq_doc
        ,(SELECT A.AG_CATEGORY_AGENT_ID
           FROM ins.AG_CATEGORY_AGENT A
          WHERE A.BRIEF = rec_convert.CATEGORY_ID)
        ,rec_convert.DATE_BEGIN
        ,NVL(rec_convert.DATE_END, ADD_MONTHS(rec_convert.DATE_BEGIN, 1200))
        ,(SELECT A.AG_CONTRACT_HEADER_ID
           FROM ins.VEN_AG_CONTRACT_HEADER A
          WHERE rec_convert.HEADER_EXT_ID = A.EXT_ID)
        ,NULL
        ,NULL
        ,NULL
        ,rec_convert.METHOD_PAYMENT
        ,(SELECT A.AG_CONTRACT_HEADER_ID
           FROM ins.AG_CONTRACT_HEADER A
          WHERE rec_convert.AG_CONTRACT_TEMPL = A.TEMPL_BRIEF)
        ,rec_convert.LEG_POS
        ,(SELECT d.DEPARTMENT_ID FROM ins.DEPARTMENT d WHERE d.EXT_ID = rec_convert.EXT_AGENCY_ID)
        ,rec_convert.EXT_ID
        ,(SELECT DT.DOC_TEMPL_ID FROM DOC_TEMPL DT WHERE DT.BRIEF = 'AG_CONTRACT')
        ,'Конвертация RenLife'
        ,rec_convert.NUM
        ,rec_convert.DATE_BEGIN);
      l_val := 2;
      INSERT INTO ins.DOC_STATUS
        (DOC_STATUS_ID
        ,DOCUMENT_ID
        ,DOC_STATUS_REF_ID
        ,START_DATE
        ,EXT_ID
        ,CHANGE_DATE
        ,SRC_DOC_STATUS_REF_ID)
      VALUES
        (ins.SQ_DOC_STATUS.NEXTVAL
        ,sq_doc
        ,(SELECT D.DOC_STATUS_REF_ID FROM ins.DOC_STATUS_REF D WHERE D.BRIEF = rec_convert.DOC_STATUS)
        ,rec_convert.DOC_STATUS_DATE
        ,rec_convert.EXT_ID
        ,rec_convert.DOC_STATUS_DATE
        ,(SELECT D.DOC_STATUS_REF_ID FROM ins.DOC_STATUS_REF D WHERE D.BRIEF = 'NULL'));
    
      l_val := 3;
    END LOOP;
  
    pkg_convert.SP_EventInfo(1, 1, 1);
    UPDATE ins.ag_contract c
       SET (c.contract_f_lead_id, c.contract_recrut_id, c.contract_leader_id) =
           (SELECT lead.ag_contract_id   AS contract_f_lead_id
                  ,recrut.ag_contract_id AS contract_recrut_id
                  ,leader.ag_contract_id AS contract_leader_id
              FROM convert_ag_contract ag
                  ,ins.ven_ag_contract ag2
                  ,ins.ven_ag_contract lead
                  ,ins.ven_ag_contract recrut
                  ,ins.ven_ag_contract leader
             WHERE ag.ext_id = ag2.ext_id
               AND lead.ext_id = ag.ext_contract_f_lead_id
               AND recrut.ext_id = ag.contract_recrut_id
               AND leader.ext_id = ag.contract_leader_id
               AND ag2.AG_CONTRACT_ID = c.AG_CONTRACT_ID)
     WHERE EXISTS (SELECT 1
              FROM ven_ag_contract v
             WHERE v.EXT_ID IS NOT NULL
               AND v.AG_CONTRACT_ID = c.AG_CONTRACT_ID);
  
    pkg_convert.SP_EventInfo(2, 1, 1);
  
    UPDATE AG_CONTRACT_HEADER A
       SET A.T_SALES_CHANNEL_ID =
           (SELECT T.ID FROM T_SALES_CHANNEL T WHERE T.BRIEF = 'MLM')
     WHERE EXISTS (SELECT 1
              FROM ven_AG_CONTRACT_HEADER ag
             WHERE ag.EXT_ID IS NOT NULL
               AND ag.AG_CONTRACT_HEADER_ID = a.AG_CONTRACT_HEADER_ID);
  
    pkg_convert.SP_EventInfo(3, 1, 1);
    COMMIT;
    UPDATE ins.ven_ag_contract_header a
       SET a.last_ver_id =
           (SELECT ag.ag_contract_id
              FROM ins.ven_ag_contract ag
             WHERE ag.ext_id =
                   (SELECT agh.ext_last_ver_id FROM convert_ag_header agh WHERE agh.ext_id = a.ext_id))
     WHERE a.ext_id IS NOT NULL;
  
    pkg_convert.SP_EventInfo(4, 1, 1);
  
    UPDATE ven_ag_contract v
       SET v.num =
           (SELECT A.NUM - 1
              FROM (SELECT COUNT(ext_id) OVER(PARTITION BY contract_id ORDER BY TO_NUMBER(ext_id)) AS num
                          ,v2.EXT_ID
                      FROM ven_ag_contract v2) A
             WHERE a.EXT_ID = v.EXT_ID)
     WHERE v.ext_id IS NOT NULL;
  
    pkg_convert.SP_EventInfo(5, 1, 1);
  
    INSERT INTO ven_dept_agent
      (DEPT_AGENT_ID, EXT_ID, AGENT_ID, DEPARTMENT_ID)
      SELECT sq_dept_agent.nextval
            ,V.EXT_ID
            ,v.AGENT_ID
            ,v.agency_id
        FROM VEN_AG_CONTRACT_HEADER V
       WHERE ext_id IS NOT NULL
         AND v.agency_id IS NOT NULL;
  
    pkg_convert.SP_EventInfo(6, 1, 1);
  
    UPDATE VEN_AG_CONTRACT V
       SET v.AG_CONTRACT_TEMPL_ID =
           (SELECT h.AG_CONTRACT_HEADER_ID
              FROM VEN_AG_CONTRACT_HEADER H
             WHERE H.TEMPL_BRIEF = 'DS_MN_15_02_07')
     WHERE V.ext_id IS NOT NULL
       AND V.AG_CONTRACT_TEMPL_ID =
           (SELECT h.AG_CONTRACT_HEADER_ID FROM VEN_AG_CONTRACT_HEADER H WHERE H.TEMPL_BRIEF = 'MENED')
       AND v.NUM <> '0';
  
    pkg_convert.SP_EventInfo(7, 1, 1);
  
    UPDATE VEN_AG_CONTRACT V
       SET v.AG_CONTRACT_TEMPL_ID =
           (SELECT h.AG_CONTRACT_HEADER_ID
              FROM VEN_AG_CONTRACT_HEADER H
             WHERE H.TEMPL_BRIEF = 'DS_DR_15_02_07')
     WHERE V.ext_id IS NOT NULL
       AND V.AG_CONTRACT_TEMPL_ID =
           (SELECT h.AG_CONTRACT_HEADER_ID FROM VEN_AG_CONTRACT_HEADER H WHERE H.TEMPL_BRIEF = 'DIR')
       AND v.NUM <> '0';
  
    pkg_convert.SP_EventInfo(8, 1, 1);
  
    UPDATE VEN_AG_CONTRACT V
       SET v.AG_CONTRACT_TEMPL_ID =
           (SELECT h.AG_CONTRACT_HEADER_ID
              FROM VEN_AG_CONTRACT_HEADER H
             WHERE H.TEMPL_BRIEF = 'DS_AG_15_02_07')
     WHERE V.ext_id IS NOT NULL
       AND V.AG_CONTRACT_TEMPL_ID =
           (SELECT h.AG_CONTRACT_HEADER_ID FROM VEN_AG_CONTRACT_HEADER H WHERE H.TEMPL_BRIEF = 'AGENT')
       AND v.NUM <> '0';
  
    pkg_convert.SP_EventInfo(9, 1, 1);
  
    UPDATE VEN_AG_CONTRACT V
       SET v.AG_CONTRACT_TEMPL_ID = NULL
     WHERE V.EXT_ID IS NOT NULL
       AND v.NUM = '0';
  
    pkg_convert.SP_EventInfo(10, 1, 1);
  
    UPDATE ag_contract_header A
       SET A.AG_CONTRACT_TEMPL_ID =
           (SELECT T.ag_contract_header_id FROM ag_contract_header T WHERE T.TEMPL_BRIEF = 'CALL')
     WHERE EXISTS (SELECT 1
              FROM department d
             WHERE A.agency_id = d.department_id
               AND d.ext_id = 35254);
  
    pkg_convert.SP_EventInfo(11, 1, 1);
  
    UPDATE ag_contract_header A
       SET a.T_SALES_CHANNEL_ID =
           (SELECT TC.ID FROM T_SALES_CHANNEL TC WHERE TC.BRIEF = 'CC')
     WHERE EXISTS (SELECT 1
              FROM ag_contract_header T
             WHERE T.TEMPL_BRIEF = 'CALL'
               AND A.AG_CONTRACT_TEMPL_ID = T.ag_contract_header_id);
  
    pkg_convert.SP_EventInfo(12, 1, 1);
  
    UPDATE ag_contract A
       SET A.AG_CONTRACT_TEMPL_ID =
           (SELECT T.ag_contract_header_id
              FROM ag_contract_header T
             WHERE T.TEMPL_BRIEF = 'Call-Center')
     WHERE EXISTS (SELECT 1
              FROM ag_contract_header ah
                  ,ag_contract_header T
             WHERE A.CONTRACT_ID = ah.ag_contract_header_id
               AND ah.AG_CONTRACT_TEMPL_ID = T.ag_contract_header_id
               AND T.TEMPL_BRIEF = 'CALL');
  
    pkg_convert.SP_EventInfo(13, 1, 1);
  
    UPDATE ag_contract A
       SET a.CATEGORY_ID =
           (SELECT TC.AG_CATEGORY_AGENT_ID FROM AG_CATEGORY_AGENT TC WHERE TC.BRIEF = 'BZ')
     WHERE EXISTS (SELECT 1
              FROM ag_contract_header T
             WHERE T.TEMPL_BRIEF = 'Call-Center'
               AND A.AG_CONTRACT_TEMPL_ID = T.ag_contract_header_id);
  
    pkg_convert.SP_EventInfo(14, 1, 1);
  
    INSERT INTO ag_dav
      (AG_DAV_ID, EXT_ID, CONTRACT_ID, NOTE, PAYMENT_AG_ID, PAYMENT_TERMS_ID, PROD_COEF_TYPE_ID)
      SELECT sq_ag_dav.nextval
            ,ac.ext_id
            ,ac.AG_CONTRACT_ID
            ,'Конвертация RenLife'
            ,ad.PAYMENT_AG_ID
            ,ad.PAYMENT_TERMS_ID
            ,ad.PROD_COEF_TYPE_ID
        FROM ven_ag_contract    ac
            ,ag_contract_header t
            ,ag_dav             ad
       WHERE ac.ext_id IS NOT NULL
         AND ac.ag_contract_templ_id = t.ag_contract_header_id
         AND ad.CONTRACT_ID = t.LAST_VER_ID;
  
    pkg_convert.SP_EventInfo(15, 1, 1);
  
    INSERT INTO ag_dav
      (AG_DAV_ID, EXT_ID, CONTRACT_ID, NOTE, PAYMENT_AG_ID, PAYMENT_TERMS_ID, PROD_COEF_TYPE_ID)
      SELECT sq_ag_dav.nextval
            ,ac.ext_id
            ,ac.AG_CONTRACT_ID
            ,'Конвертация RenLife'
            ,ad.PAYMENT_AG_ID
            ,ad.PAYMENT_TERMS_ID
            ,ad.PROD_COEF_TYPE_ID
        FROM ven_ag_contract    ac
            ,ag_contract_header t
            ,ag_dav             ad
            ,ag_contract_header agh
       WHERE ac.ext_id IS NOT NULL
         AND ac.num = '0'
         AND agh.AG_CONTRACT_HEADER_ID = ac.CONTRACT_ID
         AND agh.ag_contract_templ_id = t.ag_contract_header_id
         AND ad.CONTRACT_ID = t.LAST_VER_ID;
  
    pkg_convert.SP_EventInfo(16, 1, 1);
  
    INSERT INTO ag_prod_line_contr
      (ag_prod_line_contr_id
      ,ext_id
      ,ag_contract_id
      ,ag_rate_id
      ,date_begin
      ,date_end
      ,insurance_group_id
      ,notes
      ,product_id
      ,product_line_id)
      SELECT sq_ag_prod_line_contr.NEXTVAL
            ,ag.ext_id
            ,ag.ag_contract_id
            ,ag_rate_id
            ,ag.date_begin
            ,ag.date_end
            ,ap.insurance_group_id
            ,ap.notes
            ,ap.product_id
            ,ap.product_line_id
        FROM ven_ag_prod_line_contr ap
            ,ag_contract_header     t
            ,ven_ag_contract        ag
       WHERE ap.ag_contract_id = t.last_ver_id
         AND ag.ag_contract_templ_id = t.ag_contract_header_id
         AND ag.ext_id IS NOT NULL;
  
    pkg_convert.SP_EventInfo(17, 1, 1);
  
    INSERT INTO ag_prod_line_contr
      (ag_prod_line_contr_id
      ,ext_id
      ,ag_contract_id
      ,ag_rate_id
      ,date_begin
      ,date_end
      ,insurance_group_id
      ,notes
      ,product_id
      ,product_line_id)
      SELECT sq_ag_prod_line_contr.NEXTVAL
            ,ag.ext_id
            ,ag.ag_contract_id
            ,ag_rate_id
            ,ag.date_begin
            ,ag.date_end
            ,ap.insurance_group_id
            ,ap.notes
            ,ap.product_id
            ,ap.product_line_id
        FROM ven_ag_prod_line_contr ap
            ,ag_contract_header     t
            ,ven_ag_contract        ag
            ,ven_ag_contract_header agh
       WHERE ap.ag_contract_id = t.last_ver_id
         AND ag.contract_id = agh.AG_CONTRACT_HEADER_ID
         AND agh.AG_CONTRACT_TEMPL_ID = t.ag_contract_header_id
         AND ag.ext_id IS NOT NULL
         AND ag.num = '0';
  
    pkg_convert.SP_EventInfo(18, 1, 1);
  
    INSERT INTO ag_plan_sale
      (AG_PLAN_SALE_ID
      ,EXT_ID
      ,DATE_START
      ,DATE_END
      ,K_SGP
      ,AG_COUNT
      ,PERIOD_TYPE_ID
      ,AG_CONTRACT_HEADER_ID)
      SELECT sq_ag_plan_sale.NEXTVAL
            ,b.ext_id_2
            ,ADD_MONTHS(b.date_begin_2, (cm - 1) * 3 + 12) AS dd
            ,(ADD_MONTHS(b.date_begin_2, ((cm * 3) + 12)) - 1) AS dd2
            ,b.k_sgp
            ,b.ag_count
            ,b.period_type_id
            ,b.ag_contract_header_id_2
        FROM (SELECT a.num
                    ,COUNT(*) OVER(PARTITION BY a.ag_contract_header_id ORDER BY p.date_start) cm
                    ,p.*
                    ,a.ag_contract_header_id AS ag_contract_header_id_2
                    ,agc.date_begin AS date_begin_2
                    ,agc.date_end AS date_end_2
                    ,agc.ext_id AS ext_id_2
                FROM ven_ag_plan_sale       p
                    ,ag_contract_header     t
                    ,ven_ag_contract_header a
                    ,ven_ag_contract        agc
               WHERE p.ag_contract_header_id = t.ag_contract_header_id
                 AND t.templ_brief IN ('MENED')
                 AND a.ag_contract_templ_id = t.ag_contract_header_id
                 AND a.ext_id IS NOT NULL
                 AND agc.ag_contract_id = a.last_ver_id) b;
  
    pkg_convert.SP_EventInfo(19, 1, 1);
  
    UPDATE VEN_DOC_STATUS v1
       SET v1.doc_status_ref_id =
           (SELECT D.DOC_STATUS_REF_ID FROM DOC_STATUS_REF D WHERE D.BRIEF = 'BREAK')
     WHERE EXISTS (SELECT 1
              FROM (SELECT v.AG_CONTRACT_ID
                          ,v.DATE_END
                      FROM ven_ag_contract v
                          ,doc_status      d
                     WHERE v.ag_contract_id = d.document_id
                       AND d.doc_status_ref_id = -1
                       AND v.EXT_ID IS NOT NULL) sq
             WHERE sq.AG_CONTRACT_ID = v1.DOCUMENT_ID);
  
    pkg_convert.SP_EventInfo(20, 1, 1);
  
    UPDATE ven_ag_contract_header agh
       SET agh.date_break =
           (SELECT v.date_end
              FROM ven_ag_contract v
                  ,doc_status      d
                  ,doc_status_ref  ds
             WHERE v.ag_contract_id = d.document_id
               AND d.doc_status_ref_id = ds.doc_status_ref_id
               AND v.ext_id IS NOT NULL
               AND ds.brief = 'BREAK'
               AND v.ag_contract_id = agh.last_ver_id)
     WHERE EXISTS (SELECT 1
              FROM ven_ag_contract v
                  ,doc_status      d
                  ,doc_status_ref  ds
             WHERE v.ag_contract_id = d.document_id
               AND d.doc_status_ref_id = ds.doc_status_ref_id
               AND v.ext_id IS NOT NULL
               AND ds.brief = 'BREAK'
               AND v.ag_contract_id = agh.last_ver_id);
  
    pkg_convert.SP_EventInfo(21, 1, 1);
  
    UPDATE VEN_DOC_STATUS VDS
       SET VDS.DOC_STATUS_REF_ID =
           (SELECT D.DOC_STATUS_REF_ID FROM doc_status_ref D WHERE D.BRIEF = 'BREAK')
     WHERE EXISTS (SELECT 1
              FROM ven_ag_contract        v
                  ,doc_status             d
                  ,doc_status_ref         ds
                  ,ven_ag_contract_header agh
             WHERE v.ag_contract_id = d.document_id
               AND d.doc_status_ref_id = ds.doc_status_ref_id
               AND v.ext_id IS NOT NULL
               AND ds.brief = 'BREAK'
               AND v.ag_contract_id = agh.LAST_VER_ID
               AND agh.AG_CONTRACT_HEADER_ID = VDS.DOCUMENT_ID);
  
    pkg_convert.SP_EventInfo(22, 1, 1);
  
    UPDATE ven_ag_contract_header va1
       SET va1.AGENCY_ID =
           (SELECT d.DEPARTMENT_ID FROM department d WHERE d.DEPARTMENT_ID = '35254')
     WHERE EXISTS (SELECT 1
              FROM ven_ag_contract        ag
                  ,ven_ag_contract_header va
                  ,department             d
             WHERE ag.agency_id = d.department_id
               AND d.ext_id = 35254
               AND va.ag_contract_header_id = ag.contract_id
               AND ag.NUM = '0'
               AND va.AG_CONTRACT_HEADER_ID = va1.AG_CONTRACT_HEADER_ID);
  
    pkg_convert.SP_EventInfo(23, 1, 1);
  
    UPDATE ven_ag_contract_header va1
       SET va1.AGENCY_ID =
           (SELECT d.DEPARTMENT_ID
              FROM ven_ag_contract        ag
                  ,ven_ag_contract_header va
                  ,department             d
             WHERE ag.agency_id = d.department_id
               AND d.ext_id != 35254
               AND va.ag_contract_header_id = ag.contract_id
               AND ag.NUM = '0'
               AND va.AG_CONTRACT_HEADER_ID = va1.AG_CONTRACT_HEADER_ID)
     WHERE EXISTS (SELECT 1
              FROM ven_ag_contract        ag
                  ,ven_ag_contract_header va
                  ,department             d
             WHERE ag.agency_id = d.department_id
               AND d.ext_id != 35254
               AND va.ag_contract_header_id = ag.contract_id
               AND ag.NUM = '0'
               AND va.AG_CONTRACT_HEADER_ID = va1.AG_CONTRACT_HEADER_ID);
  
    UPDATE VEN_AG_CONTRACT_HEADER A
       SET A.AGENCY_ID =
           (SELECT V.AGENCY_ID FROM AG_CONTRACT V WHERE V.AG_CONTRACT_ID = A.LAST_VER_ID)
     WHERE A.EXT_ID IS NOT NULL;
  
    pkg_convert.SP_EventInfo(2, 2, 2);
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации версии агенского договора :' || l_val
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AG_CONTRACT'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AG_CONTRACT;

  FUNCTION FN_AG_STATE(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    FOR rec_convert IN cur_AG_STATE
    LOOP
    
      INSERT INTO ins.VEN_AG_STAT_HIST
        (AG_STAT_HIST_ID
        ,EXT_ID
        ,AG_CONTRACT_HEADER_ID
        ,NUM
        ,STAT_DATE
        ,AG_STAT_AGENT_ID
        ,K_SGP
        ,K_KD
        ,K_KSP
        ,AG_CATEGORY_AGENT_ID)
      VALUES
        (ins.SQ_AG_STAT_HIST.NEXTVAL
        ,rec_convert.EXT_ID
        ,(SELECT a.AG_CONTRACT_HEADER_ID
           FROM ins.VEN_AG_CONTRACT_HEADER a
          WHERE a.EXT_ID = rec_convert.EXT_AG_CONTRACT_HEADER_ID)
        ,rec_convert.NUM
        ,rec_convert.STAT_DATE
        ,(SELECT a.AG_STAT_AGENT_ID
           FROM ins.AG_STAT_AGENT a
          WHERE a.BRIEF = rec_convert.AG_STAT_AGENT_ID)
        ,rec_convert.K_SGP
        ,rec_convert.K_KD
        ,rec_convert.K_KSP
        ,(SELECT a.AG_CATEGORY_AGENT_ID
           FROM ins.AG_CATEGORY_AGENT a
          WHERE a.BRIEF = rec_convert.AG_CATEGORY_AGENT_ID));
    
      UPDATE ag_stat_hist ah2
         SET ah2.ag_category_agent_id =
             (SELECT a.ag_category_agent_id
                FROM ag_stat_agent a
               WHERE a.ag_stat_agent_id = ah2.ag_stat_agent_id)
       WHERE EXISTS (SELECT 1
                FROM ag_stat_hist ah
               WHERE NOT EXISTS (SELECT 1
                        FROM ag_stat_agent a
                       WHERE a.ag_stat_agent_id = ah.ag_stat_agent_id
                         AND ah.ag_category_agent_id = a.ag_category_agent_id)
                 AND ah.ag_stat_hist_id = ah2.ag_stat_hist_id)
         AND ah2.ag_stat_agent_id IS NOT NULL;
    
      UPDATE AG_STAT_HIST A
         SET A.AG_CATEGORY_AGENT_ID =
             (SELECT a.ag_category_agent_id FROM ag_category_agent T WHERE T.BRIEF = 'DR')
       WHERE EXISTS (SELECT 1
                FROM CONVERT_AG_STATE C
               WHERE C.EXT_ID = A.EXT_ID
                 AND C.AG_CATEGORY_AGENT_ID = 'DR');
    
    --   pkg_convert.UpdateConvert('ins.CONVERT_AG_STATE',rec_convert.rrw);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации статусов агентов'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AG_STATE'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AG_STATE;

  FUNCTION FN_AG_PLAN_KV(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rec_convert IN cur_AG_PLAN_KV
    LOOP
      INSERT INTO ins.AG_PLAN_SALE
        (AG_PLAN_SALE_ID, EXT_ID, DATE_START, DATE_END, K_SGP, PERIOD_TYPE_ID, AG_CONTRACT_HEADER_ID)
      VALUES
        (ins.SQ_AG_PLAN_SALE.NEXTVAL
        ,rec_convert.EXT_ID
        ,rec_convert.DATE_START
        ,rec_convert.DATE_END
        ,REPLACE(rec_convert.K_SGP, '.', ',')
        ,(SELECT t.ID FROM ins.T_PERIOD_TYPE t WHERE t.brief = rec_convert.PERIOD_TYPE_ID)
        ,(SELECT agh.AG_CONTRACT_HEADER_ID
           FROM ins.VEN_AG_CONTRACT_HEADER agh
          WHERE agh.EXT_ID = rec_convert.EXT_AG_CONTRACT_HEADER_ID));
    END LOOP;
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации планов продаж'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AG_PLAN_KV'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AG_PLAN_KV;

  FUNCTION FN_AG_CONTRACT_DOVER(p_valid NUMBER) RETURN NUMBER IS
    sq_doc NUMBER;
    n      VARCHAR2(50);
  BEGIN
    FOR rec_convert IN cur_AG_CONTRACT_DOVER
    LOOP
    
      n := rec_convert.EXT_AG_CONTRACT_HEADER_ID;
    
      SELECT ins.SQ_DOCUMENT.nextval INTO sq_doc FROM dual;
    
      /*   insert into ins.DOCUMENT (DOCUMENT_ID,NUM,DOC_TEMPL_ID,NOTE,REG_DATE,EXT_ID)
      values (sq_doc,
           rec_convert.NUM_DOVER,
        (select DT.DOC_TEMPL_ID from DOC_TEMPL DT where DT.BRIEF = 'AG_CONTRACT_DOVER'),
        'Конвертация RenLife',
       rec_convert.REG_DATE,
       rec_convert.EXT_ID);
       */
    
      INSERT INTO ins.VEN_AG_CONTRACT_DOVER
        (AG_CONTRACT_DOVER_ID
        ,DATE_START
        ,DATE_END
        ,AG_CONTRACT_HEADER_ID
        ,T_DOVER_TYPE_ID
        ,NOTE
        ,NUM
        ,REG_DATE
        ,NUM_DOVER
        ,EXT_ID
        ,doc_templ_id)
      VALUES
        (sq_doc
        ,rec_convert.DATE_START
        ,rec_convert.DATE_END
        ,(SELECT agh.AG_CONTRACT_HEADER_ID
           FROM ins.VEN_AG_CONTRACT_HEADER AGH
          WHERE AGH.EXT_ID = rec_convert.EXT_AG_CONTRACT_HEADER_ID)
        ,(SELECT A.T_DOVER_TYPE_ID FROM ins.T_DOVER_TYPE A WHERE a.BRIEF = rec_convert.T_DOVER_TYPE_ID)
        ,'Конвертация RenLife'
        ,rec_convert.NUM_DOVER
        ,rec_convert.REG_DATE
        ,rec_convert.NUM_DOVER
        ,rec_convert.EXT_ID
        ,(SELECT DT.DOC_TEMPL_ID FROM DOC_TEMPL DT WHERE DT.BRIEF = 'AG_CONTRACT_DOVER'));
    
      INSERT INTO ins.DOC_STATUS
        (DOC_STATUS_ID
        ,DOCUMENT_ID
        ,DOC_STATUS_REF_ID
        ,START_DATE
        ,EXT_ID
        ,CHANGE_DATE
        ,SRC_DOC_STATUS_REF_ID)
      VALUES
        (ins.SQ_DOC_STATUS.NEXTVAL
        ,sq_doc
        ,(SELECT D.DOC_STATUS_REF_ID FROM ins.DOC_STATUS_REF D WHERE D.BRIEF = 'NEW')
        ,rec_convert.DATE_START
        ,rec_convert.EXT_ID
        ,rec_convert.DATE_START
        ,(SELECT D.DOC_STATUS_REF_ID FROM ins.DOC_STATUS_REF D WHERE D.BRIEF = 'NULL'));
    
    END LOOP;
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации довереностей: ' || n
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AG_CONTRACT_DOVER'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AG_CONTRACT_DOVER;

  FUNCTION FN_P_POLICY(p_valid NUMBER) RETURN NUMBER IS
  
    sq_doc    NUMBER;
    sq_doc_p  NUMBER;
    l_period  NUMBER;
    l_var     VARCHAR2(50);
    l_row_num NUMBER;
  
    FUNCTION get_period
    (
      p_PERIOD_VALUE NUMBER
     ,p_type_BRIEF   VARCHAR2
    ) RETURN NUMBER IS
      CURSOR cur_t_period
      (
        C_PERIOD_VALUE NUMBER
       ,c_type_BRIEF   VARCHAR2
      ) IS
        SELECT t.ID
          FROM ins.t_period      t
              ,ins.T_PERIOD_TYPE tpt
         WHERE tpt.ID = t.PERIOD_TYPE_ID
           AND t.PERIOD_VALUE = C_PERIOD_VALUE
           AND tpt.BRIEF = c_type_BRIEF;
    
      rec_t_period cur_t_period%ROWTYPE;
      sq_period    NUMBER;
    BEGIN
      OPEN cur_t_period(p_PERIOD_VALUE, p_type_BRIEF);
      FETCH cur_t_period
        INTO rec_t_period;
    
      IF (cur_t_period%NOTFOUND)
      THEN
        SELECT ins.sq_t_period.nextval INTO sq_period FROM dual;
      
        INSERT INTO ins.t_period
          (ID, PERIOD_TYPE_ID, PERIOD_VALUE, DESCRIPTION)
        VALUES
          (sq_period
          ,(SELECT t.ID FROM ins.T_PERIOD_TYPE t WHERE t.BRIEF = p_type_BRIEF)
          ,p_PERIOD_VALUE
          ,p_PERIOD_VALUE || ' ' || (SELECT DECODE(t.DESCRIPTION
                                                  ,'Месяцы'
                                                  ,'месяцев'
                                                  ,'Годы'
                                                  ,'лет'
                                                  ,'Дни'
                                                  ,'дней'
                                                  ,'Кварталы'
                                                  ,'кварталов')
                                       FROM ins.T_PERIOD_TYPE t
                                      WHERE t.BRIEF = p_type_BRIEF));
        CLOSE cur_t_period;
        RETURN sq_period;
      END IF;
      CLOSE cur_t_period;
      RETURN rec_t_period.id;
    END get_period;
  
  BEGIN
  
    FOR rec_convert IN cur_P_POLICY
    LOOP
      l_var     := rec_convert.EXT_ID;
      l_row_num := 1;
      SELECT ins.SQ_DOCUMENT.nextval INTO sq_doc FROM dual;
    
      INSERT INTO ins.VEN_P_POL_HEADER
        (POLICY_HEADER_ID
        ,PRODUCT_ID
        ,SALES_CHANNEL_ID
        ,FUND_ID
        ,FUND_PAY_ID
        ,CONFIRM_CONDITION_ID
        ,START_DATE
        ,DESCRIPTION
        ,NUM
        ,DOC_TEMPL_ID
        ,NOTE
        ,REG_DATE
        ,EXT_ID)
      VALUES
        (sq_doc
        ,rec_convert.PRODUCT_ID
        ,NVL(rec_convert.SALES_CHANNEL_ID
            ,(SELECT T.ID FROM ins.T_SALES_CHANNEL t WHERE t.BRIEF = 'DSF'))
        ,(SELECT F2.FUND_ID FROM FUND F2 WHERE F2.BRIEF = rec_convert.FUND_ID)
        ,(SELECT F.FUND_ID FROM FUND F WHERE F.CODE = rec_convert.FUND_PAY_ID)
        ,rec_convert.CONFIRM_CONDITION_ID
        ,rec_convert.START_DATE
        ,rec_convert.NOTE
        ,rec_convert.POL_NUM
        ,(SELECT DT.DOC_TEMPL_ID FROM DOC_TEMPL DT WHERE DT.BRIEF = 'POL_HEADER')
        ,rec_convert.NOTE
        ,rec_convert.REG_DATE
        ,rec_convert.EXT_ID);
    
      SELECT ins.SQ_DOCUMENT.nextval INTO sq_doc_p FROM dual;
      l_row_num := 2;
      l_period  := get_period(rec_convert.PERIOD_VALUE, rec_convert.PERIOD_TYPE_ID);
      l_row_num := 3;
      INSERT INTO ins.VEN_P_POLICY
        (POLICY_ID
        ,POL_HEADER_ID
        ,POL_NUM
        ,NOTICE_DATE
        ,SIGN_DATE
        ,CONFIRM_DATE
        ,START_DATE
        ,END_DATE
        ,INS_AMOUNT
        ,PREMIUM
        ,PAYMENT_TERM_ID
        ,PERIOD_ID
        ,VERSION_NUM
        ,FEE_PAYMENT_TERM
        ,DECLINE_DATE
        ,DECLINE_INITIATOR_ID
        ,DECLINE_REASON_ID
        ,DECLINE_SUMM
        ,IS_DECLINE_CHANGED
        ,PAYMENTOFF_TERM_ID
        ,ADMIN_COST
        ,ISSUE_DATE
        ,COMPENSATION_LIMIT
        ,NOTICE_NUM
        ,NUM
        ,DOC_TEMPL_ID
        ,NOTE
        ,REG_DATE
        ,EXT_ID
        ,IS_GROUP_FLAG)
      VALUES
        (sq_doc_p
        ,sq_doc
        ,rec_convert.POL_NUM
        ,rec_convert.NOTICE_DATE
        ,rec_convert.SIGN_DATE
        ,rec_convert.CONFIRM_DATE
        ,rec_convert.START_DATE
        ,NVL(rec_convert.END_DATE, rec_convert.START_DATE + 100 * 365)
        ,REPLACE(rec_convert.INS_AMOUNT, '.', ',')
        ,REPLACE(rec_convert.PREMIUM, '.', ',')
        ,rec_convert.PAYMENT_TERM_ID
        ,l_period
        ,1
        ,rec_convert.FEE_PAYMENT_TERM
        ,rec_convert.DECLINE_DATE
        ,(SELECT c.CONTACT_ID FROM CONTACT C WHERE c.EXT_ID = rec_convert.DECLINE_INITIATOR_ID)
        ,rec_convert.DECLINE_REASON_ID
        ,REPLACE(rec_convert.DECLINE_SUMM, '.', ',')
        ,rec_convert.IS_DECLINE_CHANGED
        ,rec_convert.PAYMENTOFF_TERM_ID
        ,REPLACE(rec_convert.ADMIN_COST, '.', ',')
        ,rec_convert.ISSUE_DATE
        ,REPLACE(rec_convert.COMPENSATION_LIMIT, '.', ',')
        ,rec_convert.NOTICE_NUM
        ,rec_convert.POL_NUM
        ,(SELECT DT.DOC_TEMPL_ID FROM DOC_TEMPL DT WHERE DT.BRIEF = 'POLICY')
        ,REPLACE(rec_convert.NOTE, '~', chr(10) || chr(13))
        ,rec_convert.REG_DATE
        ,rec_convert.EXT_ID
        ,rec_convert.IS_GROUP_FLAG);
    
      l_row_num := 4;
      UPDATE P_POL_HEADER p SET p.POLICY_ID = sq_doc_p WHERE p.POLICY_HEADER_ID = sq_doc;
    
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации договоров: ' || l_var || ' : ' || l_row_num
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_P_POLICY'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_P_POLICY;

  FUNCTION FN_ASSURED_GROUP(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
    INSERT INTO ins.VEN_P_POL_ASSURED_GROUP
      (EXT_ID, POLICY_ID, ASSURED_GROUP_ID)
      SELECT p.EXT_ID
            ,(SELECT v.POLICY_ID FROM ven_P_POLICY v WHERE v.EXT_ID = p.EXT_P_POLICY)
            ,(SELECT v.P_ASSURED_GROUP_ID
               FROM ven_P_ASSURED_GROUP v
              WHERE v.EXT_ID = p.EXT_P_ASSURED_GROUP_ID)
        FROM CONVERT_AS_ASSURED_GROUP p;
  
    UPDATE VEN_AS_ASSURED a
       SET a.POL_ASSURED_GROUP_ID =
           (SELECT vg.P_POL_ASSURED_GROUP_ID
              FROM CONVERT_AS_ASSURED_GROUP g
                  ,VEN_P_POL_ASSURED_GROUP  vg
             WHERE g.EXT_ASSURED_ID = a.EXT_ID
               AND vg.EXT_ID = g.EXT_P_ASSURED_GROUP_ID)
     WHERE a.EXT_ID IS NOT NULL;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации "Таблица отношений застрахованных к группам": '
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_ASSURED_GROUP'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_ASSURED_GROUP;

  FUNCTION FN_P_ASSURED_GROUP(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO ins.VEN_P_ASSURED_GROUP
      (EXT_ID, NAME)
      SELECT P.EXT_ID
            ,P.NAME
        FROM CONVERT_P_ASSURED_GROUP P;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации "группы застрахованных": '
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_P_ASSURED_GROUP'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_P_ASSURED_GROUP;

  FUNCTION FN_P_GROUP_PROD_LINE(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO ins.ven_P_GROUP_PROD_LINE
      (EXT_ID
      ,ASSURED_GROUP_ID
      ,END_DATE
      ,INS_AMOUNT
      ,INS_PREMIUM
      ,PROD_LINE_ID
      ,START_DATE
      ,T_PROD_LINE_TYPE_ID
      ,T_TERRITORY_ID)
      SELECT c.EXT_ID
            ,(SELECT v.P_ASSURED_GROUP_id
               FROM ven_P_ASSURED_GROUP v
              WHERE v.ext_id = c.EXT_ASSURED_GROUP_ID)
            ,c.END_DATE
            ,s2n(c.INS_AMOUNT)
            ,s2n(c.INS_PREMIUM)
            ,c.PROD_LINE_ID
            ,c.START_DATE
            ,
             /*c.T_PROD_LINE_TYPE_ID,*/NULL
            ,
             /*   c.T_TERRITORY_ID*/NULL
        FROM CONVERT_P_GROUP_PROD_LINE c;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации "Таблица привязка программы к группе": '
                               ,'PKG_CONVERT_BLogic'
                               ,' FN_P_GROUP_PROD_LINE'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_P_GROUP_PROD_LINE;

  FUNCTION FN_POLICY_STATUS(p_valid NUMBER) RETURN NUMBER IS
  
    val         NUMBER;
    start_staus NUMBER;
    last_staus  NUMBER;
    start_date  DATE;
    l_last_id   NUMBER := 0;
    l_last_hour NUMBER := 1;
    l_last_day  DATE := NULL;
  BEGIN
  
    FOR rec_convert IN cur_POLICY_STATUS
    LOOP
    
      val := rec_convert.DOC_STATUS_ID;
    
      IF (l_last_day IS NULL)
      THEN
        l_last_day := rec_convert.START_DATE;
      END IF;
    
      /*   if (l_last_id  = rec_convert.EXT_POLICY_ID) then
      
         if (l_last_day = rec_convert.START_DATE) then
          l_last_hour:=  l_last_hour +1;
            else
          l_last_hour:=1;
       l_last_day := rec_convert.START_DATE;
         end if;
      
        else
          l_last_id  := rec_convert.EXT_POLICY_ID;
          l_last_hour:=1;
       l_last_day := rec_convert.START_DATE;
      end if ;*/
    
      IF (l_last_id = rec_convert.EXT_POLICY_ID)
      THEN
        l_last_hour := l_last_hour + 1;
      ELSE
        l_last_id   := rec_convert.EXT_POLICY_ID;
        l_last_hour := 1;
      END IF;
    
      SELECT TO_date(to_char(rec_convert.START_DATE, 'dd.mm.yyyy') || ' ' ||
                     TO_CHAR(l_last_hour, '00') || To_char(SYSDATE, 'Mi:ss')
                    ,'dd.mm.yyyy hh24:mi:ss')
        INTO start_date
        FROM dual;
    
      IF (rec_convert.DOC_STATUS_REF_ID = 'DOC_REQUEST')
      THEN
        start_staus := 24;
      ELSE
        SELECT D.DOC_STATUS_REF_ID
          INTO start_staus
          FROM ins.DOC_STATUS_REF D
         WHERE D.BRIEF = rec_convert.DOC_STATUS_REF_ID;
      END IF;
    
      IF (rec_convert.SRC_DOC_STATUS_REF_ID = 'DOC_REQUEST')
      THEN
        last_staus := 24;
      ELSE
        SELECT D.DOC_STATUS_REF_ID
          INTO last_staus
          FROM ins.DOC_STATUS_REF D
         WHERE D.BRIEF = rec_convert.SRC_DOC_STATUS_REF_ID;
      END IF;
    
      INSERT INTO ins.DOC_STATUS
        (DOC_STATUS_ID
        ,DOCUMENT_ID
        ,DOC_STATUS_REF_ID
        ,START_DATE
        ,EXT_ID
        ,USER_NAME
        ,CHANGE_DATE
        ,STATUS_CHANGE_TYPE_ID
        ,NOTE
        ,SRC_DOC_STATUS_REF_ID)
      VALUES
        (ins.SQ_DOC_STATUS.NEXTVAL
        ,GetDocument(rec_convert.EXT_POLICY_ID, 'POLICY')
        ,start_staus
        ,start_date
        ,rec_convert.DOC_STATUS_ID
        ,NVL(rec_convert.USERID, 'none')
        ,rec_convert.CHANGE_DATE
        ,(SELECT T.STATUS_CHANGE_TYPE_ID
           FROM ins.STATUS_CHANGE_TYPE T
          WHERE T.BRIEF = rec_convert.STATUS_CHANGE_TYPE_ID)
        ,rec_convert.NOTE
        ,last_staus);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации статусов договоров:' || val
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_POLICY_STATUS'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_POLICY_STATUS;

  FUNCTION FN_POLICY_CASH_SURR_D(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
    FOR rec_convert IN cur_policy_cash_surr_d
    LOOP
      INSERT INTO ven_policy_cash_surr_d
        (EXT_ID
        ,POLICY_CASH_SURR_ID
        ,INSURANCE_YEAR_DATE
        ,START_CASH_SURR_DATE
        ,END_CASH_SURR_DATE
        ,INSURANCE_YEAR_NUMBER
        ,PAYMENT_NUMBER
        ,VALUE)
      VALUES
        (rec_convert.EXT_ID
        ,(SELECT P.POLICY_CASH_SURR_ID
           FROM POLICY_CASH_SURR P
          WHERE p.EXT_ID = rec_convert.POLICY_CASH_SURR_ID)
        ,rec_convert.INSURANCE_YEAR_DATE
        ,rec_convert.START_CASH_SURR_DATE
        ,rec_convert.END_CASH_SURR_DATE
        ,rec_convert.INSURANCE_YEAR_NUMBER
        ,rec_convert.PAYMENT_NUMBER
        ,s2n(rec_convert.VALUE));
    
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации выкупных сумм детализаций'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_POLICY_CASH_SURR_D'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END;

  FUNCTION FN_AS_BENEFICIARY(p_valid NUMBER) RETURN NUMBER IS
    CURSOR cur_rel
    (
      c_contact_id_a      NUMBER
     ,c_contact_id_b      NUMBER
     ,c_RELATIONSHIP_TYPE NUMBER
    ) IS
      SELECT *
        FROM ins.ven_cn_contact_rel v
       WHERE c_contact_id_a = v.contact_id_a
         AND c_contact_id_b = v.contact_id_b
         AND c_RELATIONSHIP_TYPE = v.RELATIONSHIP_TYPE;
  
    rec_rel cur_rel%ROWTYPE;
    cn_a    NUMBER;
    cn_b    NUMBER;
    rel_t   NUMBER;
  BEGIN
  
    FOR rec_convert IN cur_AS_BENEFICIARY
    LOOP
      INSERT INTO VEN_AS_BENEFICIARY
        (EXT_ID, AS_ASSET_ID, COMMENTS, CONTACT_ID, T_CURRENCY_ID, VALUE, VALUE_TYPE_ID)
      VALUES
        (rec_convert.EXT_ID
        ,(SELECT v.AS_ASSET_ID FROM ins.VEN_AS_ASSET v WHERE V.EXT_ID = rec_convert.EXT_AS_ASSET_ID)
        ,'Коневератция RenLife'
        ,(SELECT v.CONTACT_ID FROM ins.CONTACT v WHERE V.EXT_ID = rec_convert.EXT_CONTACT_ID)
        ,NULL
        ,S2n(rec_convert.VALUE)
        ,(SELECT v.T_PATH_TYPE_ID FROM ins.T_PATH_TYPE v WHERE V.BRIEF = rec_convert.VALUE_TYPE_ID));
    
      SELECT v.CONTACT_ID INTO cn_a FROM ins.CONTACT v WHERE V.EXT_ID = rec_convert.EXT_CONTACT_ID;
      SELECT v.CONTACT_ID
        INTO cn_b
        FROM ins.VEN_AS_ASSURED v
       WHERE V.EXT_ID = rec_convert.EXT_AS_ASSET_ID;
      SELECT v.ID INTO rel_t FROM VEN_T_CONTACT_REL_TYPE V WHERE V.BRIEF = rec_convert.REL_TYPE;
    
      OPEN cur_rel(cn_a, cn_b, rel_t);
      FETCH cur_rel
        INTO rec_rel;
    
      IF (cur_rel%NOTFOUND)
      THEN
        INSERT INTO ven_cn_contact_rel
          (ID, ext_id, contact_id_a, contact_id_b, RELATIONSHIP_TYPE)
        VALUES
          (sq_cn_contact_rel.nextval
          ,rec_convert.ext_id
          ,(SELECT v.CONTACT_ID FROM ins.CONTACT v WHERE V.EXT_ID = rec_convert.EXT_CONTACT_ID)
          ,(SELECT v.CONTACT_ID FROM ins.VEN_AS_ASSURED v WHERE V.EXT_ID = rec_convert.EXT_AS_ASSET_ID)
          ,(SELECT v.ID FROM VEN_T_CONTACT_REL_TYPE V WHERE V.BRIEF = rec_convert.REL_TYPE));
      END IF;
    
      CLOSE cur_rel;
    
    END LOOP;
  
    UPDATE VEN_AS_BENEFICIARY v
       SET v.T_CURRENCY_ID =
           (SELECT ph.FUND_ID
              FROM VEN_AS_ASSURED   V2
                  ,VEN_P_POL_HEADER ph
             WHERE v2.AS_ASSURED_ID = v.AS_ASSET_ID
               AND v2.P_POLICY_ID = ph.POLICY_ID)
     WHERE v.EXT_ID IS NOT NULL;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации выгодопреобреталей'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AS_BENEFICIARY'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AS_BENEFICIARY;

  FUNCTION FN_P_POL_AGENT_COM(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO VEN_P_POLICY_AGENT_COM
      (EXT_ID
      ,AG_TYPE_DEFIN_RATE_ID
      ,AG_TYPE_RATE_VALUE_ID
      ,P_POLICY_AGENT_ID
      ,T_PROD_COEF_TYPE_ID
      ,T_PRODUCT_LINE_ID
      ,VAL_COM)
      SELECT EXT_ID
            ,(SELECT t.AG_TYPE_DEFIN_RATE_ID
               FROM INS.AG_TYPE_DEFIN_RATE t
              WHERE t.BRIEF = V.AG_TYPE_DEFIN_RATE_ID)
            ,(SELECT t.AG_TYPE_RATE_VALUE_ID
               FROM INS.AG_TYPE_RATE_VALUE t
              WHERE t.BRIEF = V.AG_TYPE_RATE_VALUE_ID)
            ,(SELECT t.P_POLICY_AGENT_ID
               FROM INS.VEN_P_POLICY_AGENT t
              WHERE t.EXT_ID = V.EXT_P_POLICY_AGENT_COM_ID)
            ,NULL
            ,(SELECT t.PRODUCT_LINE_ID
               FROM INS.VEN_T_PROD_LINE_OPTION t
              WHERE t.ID = V.T_PRODUCT_LINE_ID)
            ,s2n(VAL_COM)
        FROM CONVERT_P_POLICY_AGENT_COM V;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации "cтавки КВ по агенту по договору" '
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_P_POL_AGENT_COM'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_P_POL_AGENT_COM;

  FUNCTION FN_POLICY_AGENT(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
    INSERT INTO VEN_P_POLICY_AGENT
      (EXT_ID
      ,AG_CONTRACT_HEADER_ID
      ,AG_TYPE_RATE_VALUE_ID
      ,DATE_END
      ,DATE_START
      ,PART_AGENT
      ,POLICY_HEADER_ID
      ,STATUS_DATE
      ,STATUS_ID)
      SELECT c.EXT_ID
            ,(SELECT v.AG_CONTRACT_HEADER_ID
               FROM ins.VEN_AG_CONTRACT_HEADER V
              WHERE V.EXT_ID = C.EXT_AG_CONTRACT_HEADER_ID)
            ,(SELECT v.AG_TYPE_RATE_VALUE_ID
               FROM ins.VEN_AG_TYPE_RATE_VALUE V
              WHERE V.BRIEF = UPPER(C.AG_TYPE_RATE_VALUE_ID))
            ,NVL(DATE_END
                ,(SELECT v2.END_DATE
                   FROM ins.VEN_P_POL_HEADER V
                       ,VEN_P_POLICY         V2
                  WHERE V.EXT_ID = C.EXT_POLICY_HEADER_ID
                    AND V2.POLICY_ID = V.POLICY_ID))
            ,DATE_START
            ,s2n(PART_AGENT)
            ,(SELECT v.POLICY_HEADER_ID
               FROM ins.VEN_P_POL_HEADER V
              WHERE V.EXT_ID = C.EXT_POLICY_HEADER_ID)
            ,STATUS_DATE
            ,STATUS_ID
        FROM CONVERT_p_policy_agent C;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации агентов по договору'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_POLICY_AGENT'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_POLICY_AGENT;

  FUNCTION FN_POLICY_CASH_SURR(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    FOR rec_convert IN cur_policy_cash_surr
    LOOP
      INSERT INTO VEN_POLICY_CASH_SURR
        (EXT_ID, CONTACT_ID, POLICY_ID, POL_HEADER_ID, T_LOB_LINE_ID)
      VALUES
        (rec_convert.ext_id
        ,(SELECT c.CONTACT_ID FROM contact c WHERE c.EXT_ID = rec_convert.EXT_CONTACT_ID)
        ,(SELECT c.POLICY_ID FROM ven_p_policy c WHERE c.EXT_ID = rec_convert.EXT_POLICY_ID)
        ,(SELECT c.POLICY_HEADER_ID
           FROM ven_P_POL_HEADER c
          WHERE c.EXT_ID = rec_convert.EXT_POL_HEADER_ID)
        ,(SELECT tpl.t_lob_line_id
           FROM t_prod_line_option t
               ,t_product_line     tpl
          WHERE t.ID = rec_convert.T_LOB_LINE_ID
            AND tpl.ID = t.product_line_id));
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации выкупных сумм'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_POLICY_CASH_SURR'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END;

  FUNCTION FN_AG_VEDOM_AV(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO VEN_AG_VEDOM_AV
      (AG_VEDOM_AV_ID
      ,EXT_ID
      ,DOC_TEMPL_ID
      ,NOTE
      ,NUM
      ,REG_DATE
      ,AG_CATEGORY_AGENT_ID
      ,DATE_BEGIN
      ,DATE_END
      ,T_AG_AV_ID)
      SELECT SQ_AG_VEDOM_AV.NEXTVAL
            ,C.ext_id
            ,(SELECT t.DOC_TEMPL_ID FROM doc_templ t WHERE t.brief = 'AG_VEDOM_AV')
            ,'Конвертация RenLife'
            ,c.EXT_ID
            ,c.DATE_BEGIN
            ,A.AG_CATEGORY_AGENT_ID
            ,c.DATE_BEGIN
            ,c.DATE_END
            ,TA.T_AG_AV_ID
        FROM CONVERT_AG_VEDOM_AV C
            ,AG_CATEGORY_AGENT   A
            ,T_AG_AV             TA
       WHERE A.BRIEF = C.AG_CATEGORY_AGENT_ID
         AND TA.BRIEF = C.T_AG_AV_ID;
  
    INSERT INTO DOC_STATUS
      (DOC_STATUS_ID
      ,DOCUMENT_ID
      ,DOC_STATUS_REF_ID
      ,START_DATE
      ,EXT_ID
      ,CHANGE_DATE
      ,NOTE
      ,SRC_DOC_STATUS_REF_ID)
      SELECT SQ_DOC_STATUS.nextval
            ,V.AG_VEDOM_AV_ID
            ,(SELECT T.DOC_STATUS_REF_ID FROM DOC_STATUS_REF T WHERE T.BRIEF = 'NEW')
            ,V.DATE_BEGIN
            ,V.ext_ID
            ,V.DATE_BEGIN
            ,'Конвертация RenLife'
            ,(SELECT T.DOC_STATUS_REF_ID FROM DOC_STATUS_REF T WHERE T.BRIEF = 'NULL')
        FROM VEN_AG_VEDOM_AV V
       WHERE V.EXT_ID IS NOT NULL;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации "Ведомость расчета вознаграждений посреднику"'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AG_VEDOM_AV'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AG_VEDOM_AV;

  FUNCTION FN_AGENT_REPORT(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO VEN_AGENT_REPORT
      (AGENT_REPORT_ID
      ,REPORT_DATE
      ,AG_CONTRACT_H_ID
      ,AG_VEDOM_AV_ID
      ,T_AG_AV_ID
      ,AV_SUM
      ,PR_PART_AGENT
      ,NUM
      ,NOTE
      ,REG_DATE
      ,EXT_ID)
      SELECT SQ_AGENT_REPORT.NEXTVAL
            ,T.REPORT_DATE
            ,(SELECT A.AG_CONTRACT_HEADER_ID
               FROM VEN_AG_CONTRACT_HEADER A
              WHERE T.EXT_AG_CONTRACT_H_ID = A.EXT_ID)
            ,(SELECT A.AG_VEDOM_AV_ID FROM VEN_AG_VEDOM_AV A WHERE T.EXT_AG_VEDOM_AV_ID = A.EXT_ID)
            ,(SELECT A.T_AG_AV_ID FROM T_AG_AV A WHERE A.BRIEF = T.T_AG_AV_ID)
            ,s2n(T.AV_SUM)
            ,T.PR_PART_AGENT
            ,T.NUM
            ,T.NOTE
            ,T.REG_DATE
            ,T.EXT_ID
        FROM CONVERT_AG_REPORT T;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации акта выполненных работ'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AGENT_REPORT'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_AGENT_REPORT;

  /**
  * Процедура загрузки Акты по БСО
  */
  FUNCTION FN_BSO_ACT(p_valid NUMBER) RETURN NUMBER IS
    l_val NUMBER;
  BEGIN
  
    INSERT INTO ven_BSO_DOCUMENT
      (BSO_DOCUMENT_id
      ,contact_from_id
      ,contact_to_id
      ,department_to_id
      ,department_from_id
      ,ext_id
      ,NUM
      ,DOC_TEMPL_ID)
      SELECT sq_BSO_DOCUMENT.nextval
            ,(SELECT t.contact_id FROM contact t WHERE t.ext_id = c.ext_contact_from_id)
            ,(SELECT t.contact_id FROM contact t WHERE t.ext_id = c.ext_contact_to_id)
            ,(SELECT t.department_id FROM department t WHERE t.ext_id = c.EXT_DEPARTAMENT_TO_ID)
            ,(SELECT t.department_id FROM department t WHERE t.ext_id = c.EXT_DEPARTAMENT_FROM_ID)
            ,c.ext_id
            ,c.ext_id
            ,583
        FROM convert_bso_act c;
  
    FOR rec IN (SELECT * FROM ven_BSO_DOCUMENT V)
    LOOP
      l_val := SetStatusDoc('NULL', 'NEW', rec.BSO_DOCUMENT_ID, 2);
      l_val := SetStatusDoc('NEW', 'CONFIRMED', rec.BSO_DOCUMENT_ID, 1);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации Акты по БСО'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_BSO_ACT'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_BSO_ACT;

  /**
  * Процедура загрузки Содержание актов по БСО
  */
  FUNCTION FN_BSO_DOC_CONT(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO ven_bso_doc_cont
      (ext_id
      ,bso_doc_cont_id
      ,bso_document_id
      ,num_start
      ,num_end
      ,bso_series_id
      ,bso_hist_type_id
      ,bso_notes_type_id /*,
                department_id*/)
      SELECT c.ext_id
            ,sq_bso_doc_cont.nextval
            ,(SELECT t.BSO_DOCUMENT_id FROM ven_BSO_DOCUMENT t WHERE t.ext_id = c.ext_bso_document_id)
            ,c.num_start
            ,c.num_end
            ,(SELECT t.bso_series_id FROM ven_bso_series t WHERE t.ext_id = c.bso_series_id)
            ,(SELECT t.bso_hist_type_id FROM ven_bso_hist_type t WHERE t.brief = c.bso_hist_type_id)
            ,NULL
      --,(select t.department_id from department t where t.ext_id = c.departament_id)  
        FROM convert_bso_doc_cont c;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации Содержание актов по БСО'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_BSO_DOC_CONT'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_BSO_DOC_CONT;

  /**
  * Процедура загрузки История БСО
  */
  FUNCTION FN_BSO_HISTORY(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO ven_BSO_HIST
      (bso_hist_id
      ,bso_id
      ,hist_date
      ,contact_id
      ,hist_type_id
      ,num
      ,bso_doc_cont_id
      ,department_id
      ,bso_notes_type_id
      ,ext_id)
      SELECT sq_BSO_HIST.nextval
            ,(SELECT t.bso_id FROM ven_bso t WHERE t.ext_id = c.ext_bso_id)
            ,c.hist_date
            ,(SELECT t.contact_id FROM contact t WHERE t.ext_id = c.ext_contact_id)
            ,(SELECT t.bso_hist_type_id FROM bso_hist_type t WHERE t.brief = c.hist_type_id)
            ,c.num
            ,(SELECT t.bso_doc_cont_id FROM bso_doc_cont t WHERE t.ext_id = c.bso_doc_cont_id)
            ,(SELECT t.department_id FROM department t WHERE t.ext_id = c.department_id)
            ,NULL
            ,c.ext_id
        FROM convert_bso_history c;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации История БСО'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_BSO_HISTORY'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_BSO_HISTORY;

  FUNCTION FN_BSO(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO ven_bso_type
      (bso_type_id, NAME, brief, ext_id)
      (SELECT ins.sq_bso_type.NEXTVAL
             ,c.NAME
             ,c.ext_brief_bi
             ,c.ext_brief_rens
         FROM convert_bso_series_dic c);
  
    INSERT INTO ven_bso_series
      (BSO_SERIES_ID, BSO_TYPE_ID, SERIES_NAME, IS_DEFAULT, EXT_ID, CHARS_IN_NUM)
      SELECT SQ_bso_series.nextval
            ,(SELECT t.BSO_TYPE_ID FROM ven_bso_type t WHERE t.brief = s.BSO_TYPE)
            ,s.SERIES_NAME
            ,s.IS_DEFAULT
            ,s.EXT_ID
            ,s.CHARS_IS_NUM
        FROM convert_bso_series s;
  
    INSERT INTO VEN_BSO
      (BSO_ID, BSO_SERIES_ID, NUM, BSO_HIST_ID, POL_HEADER_ID, EXT_ID, IS_POL_NUM, POLICY_ID)
      SELECT SQ_BSO.nextval
            ,(SELECT v.BSO_SERIES_ID FROM ven_bso_series v WHERE v.ext_id = c.EXT_BSO_SERIES_ID)
            ,c.NUM
            ,NULL
            ,(SELECT v.POLICY_HEADER_ID FROM ven_p_pol_header v WHERE v.ext_id = c.EXT_POLICY_ID)
            ,c.ext_id
            ,c.IS_POL_NUM
            ,(SELECT v.policy_id FROM ven_p_policy v WHERE v.ext_id = c.EXT_POLICY_ID)
        FROM CONVERT_BSO c;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации БСО'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_BSO'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_BSO;

  /**
  * Процедура загрузки Дат актов по БСО
  */
  FUNCTION FN_BSO_DOC_DATE(p_valid NUMBER) RETURN NUMBER IS
    l_val NUMBER;
  BEGIN
  
    UPDATE ven_bso_document v
       SET v.REG_DATE = NVL((SELECT t.DATE_REG FROM convert_bso_doc_date t WHERE t.DOC_ID = V.EXT_ID)
                           ,to_date('01.07.2007', 'dd.mm.yyyy'))
     WHERE v.EXT_ID IS NOT NULL;
  
    DELETE FROM ven_doc_status v
     WHERE EXISTS (SELECT 1
              FROM ven_BSO_DOCUMENT B
             WHERE b.BSO_DOCUMENT_ID = v.DOCUMENT_ID
               AND b.EXT_ID IS NOT NULL);
  
    FOR rec IN (SELECT V.BSO_DOCUMENT_ID
                      ,BB.DATE_ACT
                  FROM ven_BSO_DOCUMENT     V
                      ,CONVERT_BSO_doc_date BB
                 WHERE BB.DOC_ID = V.EXT_ID)
    LOOP
      l_val := SetStatusDoc('NULL', 'NEW', rec.BSO_DOCUMENT_ID, 2, rec.DATE_ACT);
      l_val := SetStatusDoc('NEW', 'CONFIRMED', rec.BSO_DOCUMENT_ID, 1, rec.DATE_ACT);
    END LOOP;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации Дат актов по БСО'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_BSO_DOC_DATE'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_BSO_DOC_DATE;

  /**
  * Процедура загрузки Плана оплат - Документ
  */
  FUNCTION FN_PLAN_PAYMENT_DOC(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
    INSERT INTO VEN_AC_PAYMENT
      (PAYMENT_ID
      ,EXT_ID
      ,DOC_TEMPL_ID
      ,NOTE
      ,NUM
      ,REG_DATE
      ,AMOUNT
      ,A7_CONTACT_ID
      ,COLLECTION_METOD_ID
      ,COMM_AMOUNT
      ,COMPANY_BANK_ACC_ID
      ,CONTACT_BANK_ACC_ID
      ,CONTACT_ID
      ,DATE_EXT
      ,DUE_DATE
      ,FUND_ID
      ,GRACE_DATE
      ,IS_AGENT
      ,NUM_EXT
      ,PAYMENT_DIRECT_ID
      ,PAYMENT_NUMBER
      ,PAYMENT_TEMPL_ID
      ,PAYMENT_TERMS_ID
      ,PAYMENT_TYPE_ID
      ,REAL_PAY_DATE
      ,REV_AMOUNT
      ,REV_FUND_ID
      ,REV_RATE
      ,REV_RATE_TYPE_ID)
      SELECT SQ_AC_PAYMENT.NEXTVAL
            ,C.EXT_ID
            ,
             /*C.DOC_TEMPL_ID */(SELECT D.DOC_TEMPL_ID FROM DOC_TEMPL D WHERE D.BRIEF = 'PAYMENT')
            ,C.NOTE
            ,C.NUM_EXT
            ,C.REG_DATE
            ,C.AMOUNT
            ,
             /*C.A7_CONTACT_ID*/NULL
            ,C.COLLECTION_METOD_ID
            ,C.COMM_AMOUNT
            ,C.COMPANY_BANK_ACC_ID
            ,C.CONTACT_BANK_ACC_ID
            ,cn.CONTACT_ID
            ,C.DATE_EXT
            ,C.DUE_DATE
            ,C.FUND_ID
            ,C.GRACE_DATE
            ,C.IS_AGENT
            ,C.NUM_EXT
            ,C.PAYMENT_DIRECT_ID
            ,C.PAYMENT_NUMBER
            ,
             /*C.PAYMENT_TEMPL_ID*/(SELECT A.PAYMENT_TEMPL_ID
                FROM AC_PAYMENT_TEMPL A
               WHERE A.BRIEF = 'PAYMENT')
            ,C.PAYMENT_TERMS_ID
            ,C.PAYMENT_TYPE_ID
            ,C.REAL_PAY_DATE
            ,C.REV_AMOUNT
            ,C.REV_FUND_ID
            ,C.REV_RATE
            ,C.REV_RATE_TYPE_ID
        FROM CONVERT_PLAN_PAYMENT_DOC C
            ,contact                  cn
       WHERE cn.ext_id = c.EXT_ID_CONTACT_ID;
  
    INSERT INTO DOC_STATUS
      (DOC_STATUS_ID
      ,DOCUMENT_ID
      ,SRC_DOC_STATUS_REF_ID
      ,DOC_STATUS_REF_ID
      ,START_DATE
      ,EXT_ID
      ,CHANGE_DATE
      ,NOTE)
      SELECT SQ_DOC_STATUS.NEXTVAL
            ,V.PAYMENT_ID
            ,(SELECT D.DOC_STATUS_REF_ID FROM DOC_STATUS_REF D WHERE D.BRIEF = 'NULL')
            ,(SELECT D.DOC_STATUS_REF_ID FROM DOC_STATUS_REF D WHERE D.BRIEF = 'PROJECT')
            ,C.REG_DATE
            ,C.ext_id
            ,C.REG_DATE
            ,'Конвертация RenLife'
        FROM VEN_AC_PAYMENT           V
            ,CONVERT_PLAN_PAYMENT_DOC C
       WHERE C.ext_id = V.EXT_ID;
  
    INSERT INTO DOC_STATUS
      (DOC_STATUS_ID
      ,DOCUMENT_ID
      ,SRC_DOC_STATUS_REF_ID
      ,DOC_STATUS_REF_ID
      ,START_DATE
      ,EXT_ID
      ,CHANGE_DATE
      ,NOTE)
      SELECT SQ_DOC_STATUS.NEXTVAL
            ,V.PAYMENT_ID
            ,(SELECT D.DOC_STATUS_REF_ID FROM DOC_STATUS_REF D WHERE D.BRIEF = 'PROJECT')
            ,(SELECT D.DOC_STATUS_REF_ID FROM DOC_STATUS_REF D WHERE D.BRIEF = 'TO_PAY')
            ,C.DUE_DATE
            ,C.ext_id
            ,C.DUE_DATE
            ,'Конвертация RenLife'
        FROM VEN_AC_PAYMENT           V
            ,CONVERT_PLAN_PAYMENT_DOC C
       WHERE C.ext_id = V.EXT_ID;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации Плана оплат - Документ'
                               ,'FN_PLAN_PAYMENT_DOC'
                               ,'FN_BSO'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_PLAN_PAYMENT_DOC;

  /**
  * Процедура загрузки Плана оплат - Тразнакции
  */
  FUNCTION FN_PLAN_PAYMENT_TRANS(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    NULL;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации Плана оплат - Тразнакции'
                               ,'FN_PLAN_PAYMENT_DOC'
                               ,'FN_BSO'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_PLAN_PAYMENT_TRANS;

  /**
  * Процедура загрузки Оплаты - Документ
  */
  FUNCTION FN_FACT_PAYMENT_DOC(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    NULL;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации Оплаты - Документ'
                               ,'FN_FACT_PAYMENT_DOC'
                               ,'FN_BSO'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_FACT_PAYMENT_DOC;

  /**
  * Процедура загрузки Оплаты - Тразнакции
  */
  FUNCTION FN_FACT_PAYMENT_TRANS(p_valid NUMBER) RETURN NUMBER IS
  BEGIN
  
    NULL;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при конвертации Оплаты - Тразнакции'
                               ,'FN_FACT_PAYMENT_TRANS'
                               ,'FN_BSO'
                               ,SQLCODE
                               ,SQLERRM);
      RETURN pkg_convert.c_false;
  END FN_FACT_PAYMENT_TRANS;

  PROCEDURE FN_VALID_POLICY_CASH_SURR IS
    CURSOR cur_1 IS
      SELECT CC.EXT_ID
        FROM CONVERT_POLICY_CASH_SURR CC
       WHERE NOT EXISTS (SELECT 1 FROM v_convert_contact v WHERE v.EXT_ID = cc.EXT_CONTACT_ID);
  
  BEGIN
  
    FOR rec IN cur_1
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID || ' - не найден соотвествующий контакт'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_POLICY_CASH_SURR'
                               ,SQLCODE
                               ,SQLERRM);
    
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при проверке данных заголовков выкупных сумм'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_POLICY_CASH_SURR'
                               ,SQLCODE
                               ,SQLERRM);
  END FN_VALID_POLICY_CASH_SURR;

  PROCEDURE FN_VALID_P_POLICY_CONTACT IS
    CURSOR cur_1 IS
      SELECT CC.EXT_POLICY_ID
        FROM CONVERT_P_POLICY_CONTACT CC
       WHERE NOT EXISTS (SELECT 1 FROM v_convert_contact v WHERE v.EXT_ID = cc.ext_kontr_id);
  BEGIN
  
    FOR rec IN cur_1
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_POLICY_ID ||
                                ' - не найден соотвествующий контакт'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_P_POLICY_CONTACT'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при проверке данных контактов по договору'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_P_POLICY_CONTACT'
                               ,SQLCODE
                               ,SQLERRM);
  END FN_VALID_P_POLICY_CONTACT;

  PROCEDURE FN_CONTACT_CLEAR IS
  BEGIN
    FOR rec IN cur_contact_clear
    LOOP
      BEGIN
        DELETE FROM VEN_CN_PERSON C WHERE C.CONTACT_ID = rec.contact_id;
        DELETE FROM VEN_CN_COMPANY C WHERE C.CONTACT_ID = rec.contact_id;
        DELETE FROM contact c WHERE c.contact_id = rec.contact_id;
      EXCEPTION
        WHEN OTHERS THEN
          pkg_convert.SP_EventError('Ошибка при очистке контакта = ' || rec.contact_id
                                   ,'PKG_CONVERT_BLogic'
                                   ,'FN_CONTACT_CLEAR'
                                   ,SQLCODE
                                   ,SQLERRM);
      END;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при очистке данных контакта'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_CONTACT_CLEAR'
                               ,SQLCODE
                               ,SQLERRM);
  END FN_CONTACT_CLEAR;

  PROCEDURE FN_VALID_CONTACT_UR IS
  
    CURSOR cur_1 IS
      SELECT ext_id FROM CONVERT_CONTACT_UR cc WHERE cc.INN IS NULL;
  
    CURSOR cur_2 IS
      SELECT ext_id
        FROM CONVERT_CONTACT_UR cc
       WHERE cc.NUM_ACCOUNT IS NOT NULL
         AND (cc.ACC_INN_BANK IS NULL OR cc.ACC_NAME_BANK IS NULL OR cc.ACC_KORR_BANK IS NULL OR
             cc.ACC_BIK_BANK IS NULL);
  
    CURSOR cur_3 IS
      SELECT ext_id
        FROM CONVERT_CONTACT_UR cc
       WHERE NOT EXISTS (SELECT 1
                FROM CONVERT_BANK cc2
               WHERE cc2.BIK_BANK = cc.ACC_BIK_BANK
                 AND cc2.KORR_ACCOUNT = cc.ACC_KORR_BANK
                 AND cc2.INN = cc.ACC_INN_BANK
                 AND cc2.NAME = cc.ACC_NAME_BANK)
         AND cc.NUM_ACCOUNT IS NOT NULL
         AND cc.ACC_INN_BANK IS NOT NULL
         AND cc.ACC_NAME_BANK IS NOT NULL
         AND cc.ACC_KORR_BANK IS NOT NULL
         AND cc.ACC_BIK_BANK IS NOT NULL;
  
    CURSOR cur_4 IS
      SELECT ((SELECT COUNT(*) FROM v_convert_contact) -
             (SELECT COUNT(DISTINCT(EXT_ID)) FROM v_convert_contact)) AS C
        FROM dual;
  
  BEGIN
  
    FOR rec IN cur_1
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID || ' - отсутвсвует ИНН'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_CONTACT_UR'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
    FOR rec IN cur_2
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID || ' - неправильно оформленных данные счета'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_CONTACT_UR'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
    FOR rec IN cur_3
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID || ' - для счета не найден банк'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_CONTACT_UR'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
    FOR rec IN cur_4
    LOOP
    
      IF (rec.C > 0)
      THEN
        pkg_convert.SP_EventError('Ошибка: выявлено пересечение EXT_ID в контактах'
                                 ,'PKG_CONVERT_BLogic'
                                 ,'FN_VALID_CONTACT_UR'
                                 ,SQLCODE
                                 ,SQLERRM);
      END IF;
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при проверке данных юр. контакта'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_CONTACT_UR'
                               ,SQLCODE
                               ,SQLERRM);
  END FN_VALID_CONTACT_UR;

  PROCEDURE FN_VALID_ADDRESSE IS
  
    CURSOR cur_1 IS
      SELECT CA.EXT_ID
        FROM CONVERT_ADDRESSE CA
       WHERE NOT EXISTS (SELECT 1 FROM V_CONVERT_CONTACT V WHERE CA.CONTACT_EXT_ID = V.EXT_ID);
  
  BEGIN
  
    FOR rec IN cur_1
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID || ' - для адреса не найден контакт'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_ADDRESSE'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при проверке данных адреса'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_ADDRESSE'
                               ,SQLCODE
                               ,SQLERRM);
  END FN_VALID_ADDRESSE;

  PROCEDURE FN_VALID_AG_HEADER IS
  
    CURSOR cur_1 IS
      SELECT CAH.EXT_ID
        FROM CONVERT_AG_HEADER CAH
       WHERE NOT EXISTS (SELECT 1 FROM V_CONVERT_CONTACT V WHERE CAH.EXT_CONTACT_ID = V.EXT_ID);
  
    CURSOR cur_2 IS
      SELECT CAH.EXT_ID
        FROM CONVERT_AG_HEADER CAH
       WHERE NOT EXISTS (SELECT 1 FROM CONVERT_AGENCY V WHERE CAH.EXT_AGENCY_ID = V.EXT_ID)
         AND CAH.EXT_AGENCY_ID IS NOT NULL;
  
    CURSOR cur_3 IS
      SELECT CAH.EXT_ID
        FROM CONVERT_AG_HEADER CAH
       WHERE NOT EXISTS (SELECT 1 FROM CONVERT_AG_CONTRACT V WHERE CAH.EXT_LAST_VER_ID = V.EXT_ID);
  
  BEGIN
  
    FOR rec IN cur_1
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID ||
                                ' - для заголовка агенского договора не найден контакт'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_AG_HEADER'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
    FOR rec IN cur_2
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID ||
                                ' - для заголовка агенского договора не найдено агенство'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_AG_HEADER'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
    FOR rec IN cur_3
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID ||
                                ' - для заголовка агенского договора не найдено последней версии'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_AG_HEADER'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при проверке заголовков агенских договоров'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_AG_HEADER'
                               ,SQLCODE
                               ,SQLERRM);
  END FN_VALID_AG_HEADER;

  PROCEDURE FN_VALID_AS_ASSET IS
  
    CURSOR cur_1 IS
      SELECT CAA.EXT_ID
        FROM CONVERT_AG_ASSET CAA
       WHERE NOT EXISTS (SELECT 1 FROM V_CONVERT_CONTACT V WHERE CAA.EXT_CONTACT_ID = V.EXT_ID);
  
    CURSOR cur_2 IS
      SELECT CAA.EXT_ID
        FROM CONVERT_AG_ASSET CAA
       WHERE NOT EXISTS
       (SELECT 1 FROM V_CONVERT_CONTACT V WHERE CAA.EXT_ASSURED_CONTACT_ID = V.EXT_ID);
  
  BEGIN
  
    FOR rec IN cur_1
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID ||
                                ' - для застрахованного объекта не найден контакт'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_AS_ASSET'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
    FOR rec IN cur_2
    LOOP
      pkg_convert.SP_EventError('Ошибка: ' || rec.EXT_ID ||
                                ' - для застрахованного объекта не найден EXT_ASSURED_CONTACT_ID'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_AS_ASSET'
                               ,SQLCODE
                               ,SQLERRM);
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при проверке объектов страхования'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_VALID_AS_ASSET'
                               ,SQLCODE
                               ,SQLERRM);
  END FN_VALID_AS_ASSET;

  FUNCTION S2N(p_str VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN REPLACE(p_str, '.', ',');
  END S2N;

  FUNCTION GetHobby(p_str VARCHAR2) RETURN NUMBER IS
    CURSOR cur_hobby(c_desc VARCHAR2) IS
      SELECT * FROM ins.t_hobby t WHERE t.DESCRIPTION = c_Desc;
  
    rec cur_hobby%ROWTYPE;
  
    ret NUMBER;
  
  BEGIN
  
    OPEN cur_hobby(p_str);
    FETCH cur_hobby
      INTO rec;
  
    IF (cur_hobby%NOTFOUND)
    THEN
      SELECT sq_t_hobby.nextval INTO ret FROM dual;
      INSERT INTO ins.t_hobby (T_HOBBY_ID, DESCRIPTION, EXT_ID) VALUES (ret, p_str, p_str);
    ELSE
      ret := rec.t_hobby_id;
    END IF;
  
    CLOSE cur_hobby;
  
    RETURN ret;
  
  END GetHobby;

  FUNCTION SetStatusDoc
  (
    p_from_status VARCHAR2
   ,p_to_status   VARCHAR2
   ,p_doc_id      INTEGER
   ,p_num         INTEGER
   ,p_curdate     DATE := SYSDATE
  ) RETURN NUMBER IS
  BEGIN
  
    INSERT INTO VEN_DOC_STATUS
      (DOC_STATUS_ID
      ,DOCUMENT_ID
      ,DOC_STATUS_REF_ID
      ,START_DATE
      ,EXT_ID
      ,USER_NAME
      ,CHANGE_DATE
      ,STATUS_CHANGE_TYPE_ID
      ,NOTE
      ,SRC_DOC_STATUS_REF_ID)
    VALUES
      (sq_DOC_STATUS.nextval
      ,p_doc_id
      ,(SELECT t.DOC_STATUS_REF_ID FROM DOC_STATUS_REF t WHERE t.BRIEF = p_to_status)
      ,p_curdate - p_num
      ,'Конвертация'
      ,'Конвертация'
      ,SYSDATE - p_num
      ,(SELECT t.STATUS_CHANGE_TYPE_ID FROM STATUS_CHANGE_TYPE t WHERE t.brief = 'AUTO')
      ,'Конвертация'
      ,(SELECT t.DOC_STATUS_REF_ID FROM DOC_STATUS_REF t WHERE t.BRIEF = p_from_status));
    RETURN 1;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при назначении статуса документу'
                               ,'PKG_CONVERT_BLogic'
                               ,'SetStatusDoc'
                               ,SQLCODE
                               ,SQLERRM);
  END SetStatusDoc;

  -- порядок патча не менять
  FUNCTION FN_AGENT_PATCH RETURN NUMBER IS
  BEGIN
  
    --делает дату статуса Новый равной дате начала аг.договора 
    UPDATE doc_status t2
       SET t2.start_date =
           (SELECT h.date_begin
              FROM ven_ag_contract_header h
             WHERE h.ag_contract_header_id = t2.document_id)
     WHERE t2.doc_status_ref_id = 1
       AND t2.document_id IN (SELECT h3.ag_contract_header_id
                                FROM ven_ag_contract_header h3
                               WHERE h3.ag_contract_header_id = t2.document_id);
  
    --исправляет Наличие 2-х версий в статусе Новый в одном аг. договоре, переводит в статус Напечатан                       
    BEGIN
      --обновляем статус договора
      FOR v IN (SELECT contract_id
                  FROM (SELECT COUNT(c.contract_id) vv
                              ,c.contract_id
                          FROM ven_ag_contract c
                         WHERE doc.get_doc_status_brief(c.ag_contract_id, SYSDATE) = 'NEW'
                         GROUP BY c.contract_id)
                 WHERE vv > 1)
      LOOP
        doc.set_doc_status(v.contract_id, 20, SYSDATE);
      END LOOP;
      --обновляем статус версии 
      FOR vv IN (SELECT c2.ag_contract_id
                   FROM (SELECT *
                           FROM (SELECT COUNT(c.contract_id) vv
                                       ,c.contract_id
                                   FROM ven_ag_contract c
                                  WHERE doc.get_doc_status_brief(c.ag_contract_id, SYSDATE) = 'NEW'
                                  GROUP BY c.contract_id)
                          WHERE vv > 1) v2
                       ,ven_ag_contract c2
                  WHERE c2.contract_id = v2.contract_id
                 
                 )
      LOOP
        doc.set_doc_status(vv.ag_contract_id, 20, SYSDATE);
      END LOOP;
    END;
  
    RETURN pkg_convert.c_true;
  EXCEPTION
    WHEN OTHERS THEN
      pkg_convert.SP_EventError('Ошибка при накате патчей агентов'
                               ,'PKG_CONVERT_BLogic'
                               ,'FN_AGENT_PATCH'
                               ,SQLCODE
                               ,SQLERRM);
  END FN_AGENT_PATCH;

END PKG_CONVERT_BLogic;
/
