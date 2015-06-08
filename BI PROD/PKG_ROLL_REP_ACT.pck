CREATE OR REPLACE PACKAGE pkg_roll_rep_act AUTHID CURRENT_USER IS
--
-- 13.04.2015
-- Created FBondar
--

  /**
  * Формирует отчет и акт для всех АД с признаком - формировать документы,
  * и по шаблому с почтовым адресом отсылает по почте соотв. документ
  *
  * @param p_ag_roll_id - ID расчетной ведомость
  *
  */
  PROCEDURE send_docs_by_email( p_ag_roll_id IN pls_integer );

  /**
  * Приводит число к денежному формату xxx xxx xxx,xx
  * с 2-мя знаками после запятой и разделителями разрядов
  *
  * @param p_num - неформатированное число
  * @return Число в денежном формате в зависимости от p_index
  */
  FUNCTION to_money_sep(
                    p_num in number
                   ,p_index in varchar2 default 'INT'
                   )
    RETURN VARCHAR2;

END;
/
CREATE OR REPLACE PACKAGE BODY pkg_roll_rep_act IS
  -- gb_debug        BOOLEAN := true;

  gc_admin_email  CONSTANT VARCHAR2(80)  := 'av@renlife.com';
   /*
  TODO: owner="pavel.kaplya" category="Review" created="29.04.2015"
  text="Не стоит хардкодить RDF.

        Стоит добавить в таблицы с актами и шаблонами ссылку на rep_report_id с возможностью выбора через интерфейс в соответствующих справочниках (LOV'ами)"
  */
  gc_rep_file      CONSTANT VARCHAR2(100) := 'AG_WORK_ACT_DETAIL.rdf';
  gc_act_file      CONSTANT VARCHAR2(100) := 'AG_WORK_ACT.rdf';
  gc_report_name   CONSTANT VARCHAR2(100) := 'Отчет о заключенных и оплаченных договорах страхования';
  gc_act_name      CONSTANT VARCHAR2(100) := 'Акт об оказанных услугах';
  gc_subject       CONSTANT VARCHAR2(200) := '"#DOC_TITLE#" #NUMBER_AD# периодом #ROLL_FROM# - #ROLL_TO#';
  gc_text          CONSTANT VARCHAR2(300) := 'Отправка "#DOC_TITLE#" по АД #NUMBER_AD# #NAME_AD# по ведомости #ROLL_NUM# периодом #ROLL_FROM# - #ROLL_TO# ';
  gv_rep_file_id   NUMBER := null;
  gv_act_file_id   NUMBER := null;
  gv_roll_num      VARCHAR2(80) := null;
  gv_roll_dt_begin DATE;
  gv_roll_dt_end   DATE;
  --
  gv_error_body   VARCHAR2(32000);

      CURSOR cr_roll_info ( cr_ag_roll_id IN NUMBER ) IS
       select head.num, rol.date_begin, rol.date_end
         from ven_ag_roll_header head
              ,ven_ag_roll rol
        where rol.ag_roll_id = cr_ag_roll_id
          and head.ag_roll_header_id = rol.ag_roll_header_id
       ;

    procedure set_log (p_ag_roll_id IN pls_integer, p_text IN VARCHAR2 default null) is
    Begin
       null;
    End;


    procedure add_error (
                p_ag_contract_header_id IN  NUMBER,
                p_error                 IN VARCHAR2 default null
    ) is
      v_num  VARCHAR2(500);
      v_str  VARCHAR2(500);
    Begin
       begin
           select num
             into v_num
             from ven_ag_contract_header
            where ag_contract_header_id = p_ag_contract_header_id;
       exception
         when others then
            v_num := sqlerrm;
       end;

       if gv_error_body is null
         then gv_error_body := 'По следующему списку агентских договоров не были отправлены письма ('||USER||'):';
       end if;

       v_str := chr(13)||'АД='||v_num||'['||p_ag_contract_header_id||'], '||p_error;
       if length(gv_error_body)+length(v_str) > 31999
          then gv_error_body := rpad(gv_error_body,39972)||' ... остальное не вошло!!!';
          else gv_error_body := gv_error_body||v_str;
       end if;
    End;

    --
    -- Получаем Id's файлов отчета и акта по АД
    --
    PROCEDURE get_document_ids IS

     cursor cr_rep_id ( cr_rep_file IN VARCHAR ) is
         select rep_report_id
           from rep_report
          where exe_name = cr_rep_file ;

    Begin
       open  cr_rep_id(gc_act_file);
       fetch cr_rep_id into gv_act_file_id;
       close cr_rep_id;

       open  cr_rep_id(gc_rep_file);
       fetch cr_rep_id into gv_rep_file_id;
       close cr_rep_id;
    End;


    --
    -- Подготовка с отправкой отчета и акта
    --
    PROCEDURE doc_send(
                p_ag_roll_id          IN NUMBER
               ,p_contract_header_id  IN NUMBER
               ,p_report_email        IN VARCHAR2 default null
               ,p_act_email           IN VARCHAR2 default null
              )
    IS
       rep_rec   pkg_rep_utils.t_report;
       rec_file  pkg_email.t_files;
       rec_eto   pkg_email.t_recipients;
       ---
       v_file_id           NUMBER := null;
       v_subject           VARCHAR2(300);
       v_text              VARCHAR2(300);
       v_type              VARCHAR2(80);
       ----
       v_contract_num      VARCHAR2(80);
       v_contract_name     VARCHAR2(300);
    Begin

       set_log(p_ag_roll_id, 'АД['||p_contract_header_id||'] email['||p_report_email||'|'||p_act_email||']');
       --
       -- Получаем характеристики ведомости и Агентского Договора(АД)
       --
       select head.num,       cn.obj_name_orig
         into v_contract_num, v_contract_name
         from
              ven_ag_contract_header head, contact cn
        where
              ag_contract_header_id = p_contract_header_id
          and cn.contact_id = head.agent_id
       ;

       --
       -- Формирование и отправка акта и отчета
       --
       FOR docs IN (
           select 'Отчет' as doc_name, 'report' as doc_typ,
                  p_report_email as doc_email, gc_report_name as doc_title
           from dual
           union
           select 'Акт' as doc_name, 'act' as doc_typ,
                  p_act_email as doc_email, gc_act_name as doc_title
           from dual
       )
       LOOP

          if docs.doc_typ = 'act'
          then
              v_file_id := gv_act_file_id;
              ins.repcore.set_context('P_AG_ROLL_ID', p_ag_roll_id);
              ins.repcore.set_context('P_AG_CONTRACT_HEADER_ID', p_contract_header_id);
          else
              v_file_id := gv_rep_file_id;
              ins.repcore.set_context('P_ROLL_ID', p_ag_roll_id);
              ins.repcore.set_context('P_CONTRACT_HEADER_ID', p_contract_header_id);
          end if;

          --
          -- Запуск
          --
          pkg_rep_utils.exec_report(
                        PAR_REPORT_ID => v_file_id
                       ,PAR_REPORT    => rep_rec
                      );

          --
          -- Непосредственно отправка отчета
          --
             rec_eto := pkg_email.t_recipients();
             rec_eto.extend;
             rec_eto(1) := docs.doc_email;

             rec_file := pkg_email.t_files();
             rec_file.extend;
             rec_file(1).v_file_name := docs.doc_typ||'_document.pdf';
             rec_file(1).v_file_type := 'application/pdf';
             rec_file(1).v_file      := rep_rec.report_body;

             -- "#DOC_TITLE#" #NUMBER_AD# периодом #ROLL_FROM# - #ROLL_TO#'
             v_subject := gc_subject;
             v_subject := replace(v_subject,'#DOC_TITLE#',docs.doc_title);
             v_subject := replace(v_subject,'#NUMBER_AD#',v_contract_num);
             v_subject := replace(v_subject,'#ROLL_FROM#',to_char(gv_roll_dt_begin,'dd.mm.yyyy'));
             v_subject := replace(v_subject,'#ROLL_TO#',to_char(gv_roll_dt_end,'dd.mm.yyyy'));
             set_log(p_contract_header_id, 'АД['||docs.doc_email||'] SUB:'||v_subject);

             -- 'Отправка "#DOC_TITLE#" по АД #NUMBER_AD# #NAME_AD# по ведомости #ROLL_NUM# периодом #ROLL_FROM# - #ROLL_TO# ';
             v_text    := gc_text;
             v_text    := replace(v_text,'#DOC_TITLE#',docs.doc_title);
             v_text    := replace(v_text,'#NUMBER_AD#',v_contract_num);
             v_text    := replace(v_text,'#NAME_AD#',v_contract_name);
             v_text    := replace(v_text,'#ROLL_NUM#',gv_roll_num);
             v_text    := replace(v_text,'#ROLL_FROM#',to_char(gv_roll_dt_begin,'dd.mm.yyyy'));
             v_text    := replace(v_text,'#ROLL_TO#',to_char(gv_roll_dt_end,'dd.mm.yyyy'));
             set_log(p_contract_header_id, 'АД['||docs.doc_email||'] TEXT:'||v_text);

             pkg_email.send_mail_with_attachment(
                                PAR_TO          => rec_eto
                               ,PAR_SUBJECT     => v_subject
                               ,PAR_TEXT        => v_text
                               ,PAR_ATTACHMENT  => rec_file
                             );
             -- commit не нужен

             --
             -- Увеличить на 1 значение номер отчета или акта
             --
             UPDATE ag_contract_header head
                SET head.act_num = decode(docs.doc_typ,'act',nvl(act_num,0)+1,act_num)
                   ,head.report_num = decode(docs.doc_typ,'act',head.report_num, nvl(head.report_num,0) + 1)
              WHERE
                  head.ag_contract_header_id = p_contract_header_id
             ;

             rec_eto.delete;
             rec_file.delete;
             ins.repcore.clear_context;

      END LOOP;
   End;


   PROCEDURE send_docs_by_email( p_ag_roll_id IN pls_integer )
   IS
      v_count       number := 0;
      v_act_count   number := 0;
      v_bank_count  number := 0;
      v_type_av     ag_roll_type.TYPE_AV%TYPE;
   BEGIN

        gv_error_body := null;
        set_log(p_ag_roll_id, 'STEP 1');
        --
        -- Проверяем, что ведомость для банков и брокеров.  (typ.TYPE_AV = 'BANK')
        --
        SELECT typ.TYPE_AV
          INTO v_type_av
          FROM  ven_ag_roll rol
               ,ven_ag_roll_header head
               ,ag_roll_type typ
         WHERE rol.ag_roll_header_id = head.ag_roll_header_id
           AND typ.ag_roll_type_id = head.ag_roll_type_id
           AND rol.ag_roll_id = p_ag_roll_id
        ;
       --
       -- Ведомость не имеет признак Банки\Брокеры
       --
       set_log(p_ag_roll_id, 'STEP 2');
       IF v_type_av NOT IN ('BANK')
       THEN
            RETURN;
       END IF;

       set_log(p_ag_roll_id, 'STEP 3');
       -- Получакм ID отчетов
       get_document_ids;


       select count(1) into v_act_count
         from ag_perfomed_work_act
        where ag_roll_id = p_ag_roll_id;

       select count(1) into v_bank_count
         from ag_volume_bank vb
        WHERE vb.ag_roll_id = p_ag_roll_id
          -- AND vb.ag_contract_header_id = ahead.ag_contract_header_id
                         AND (
                                 ( nvl(vb.sav,0) > 0 AND nvl(vb.trans_amount,0) > 0 )
                              or ( nvl(vb.sav,0) < 0 AND nvl(vb.trans_amount,0) < 0 )
                            )
        ;

       open cr_roll_info(p_ag_roll_id);
       fetch cr_roll_info into gv_roll_num, gv_roll_dt_begin, gv_roll_dt_end;
       close cr_roll_info;

       set_log(p_ag_roll_id, 'STEP 4: Act_count='||v_act_count||' Bank_Count='||v_bank_count);
       --
       -- Ищем агентские договора с не нулевыми суммами
       -- и с признаком формирования отчета и акта для рассылки
       --
       FOR repact IN (
            SELECT
                   DISTINCT
                   wa.ag_roll_id
                  ,wa.ag_contract_header_id
                  ,apat.email AS act_email
                  ,rpat.email AS report_email
              FROM
                  ag_perfomed_work_act wa
                 ,ag_contract_header ahead
                 ,act_pattern apat
                 ,report_pattern rpat
             WHERE wa.ag_roll_id = p_ag_roll_id -- 125264178 --
               AND ahead.ag_contract_header_id = wa.ag_contract_header_id
               -- Признак формирования документов
               AND ahead.create_docs = 1
               -- Не нулевые суммы выплат агенствам
               AND EXISTS
                    ( SELECT 'AG_BONUS_EXISTS'
                        FROM ag_volume_bank vb
                       WHERE vb.ag_roll_id = wa.ag_roll_id
                         AND vb.ag_contract_header_id = ahead.ag_contract_header_id
                         AND (
                                 ( nvl(vb.sav,0) > 0 AND nvl(vb.trans_amount,0) > 0 )
                              or ( nvl(vb.sav,0) < 0 AND nvl(vb.trans_amount,0) < 0 )
                            )
                     )
               AND apat.act_pattern_id(+) = ahead.act_pattern_id
               AND rpat.report_pattern_id(+) = ahead.report_pattern_id
       ) LOOP

         Begin

            v_count := v_count + 1;
            set_log(repact.ag_roll_id, 'АД.'||v_count||'['||repact.ag_contract_header_id||'] email['||repact.report_email||'|'||repact.act_email||']');
            -- repact.report_email := 'TEST004.ry.ft.ua';

            doc_send(
                 p_ag_roll_id          => repact.ag_roll_id
                ,p_contract_header_id  => repact.ag_contract_header_id
                ,p_report_email        => repact.report_email
                ,p_act_email           => repact.act_email
               );

         Exception
           when others then
               add_error(repact.ag_contract_header_id, 'email=['||repact.report_email||'|'||repact.act_email||'] '||sqlerrm);
               set_log(p_ag_roll_id, '['||repact.report_email||'|'||repact.act_email||'] Excpt='||sqlerrm);
         End;

       END LOOP;

       set_log(p_ag_roll_id, 'STEP 5');

       if gv_error_body is not null
       then
           set_log(p_ag_roll_id, 'STEP 6');
           Declare
              rec_to  pkg_email.t_recipients;
           Begin

               -- send email to admin by error
               rec_to := pkg_email.t_recipients();
               rec_to.extend;
               rec_to(1) := gc_admin_email;

               pkg_email.send_mail_with_attachment(
                                    PAR_TO          => rec_to
                                   ,PAR_SUBJECT     => 'Ошибки отправки актов и отчетов по ведомости № '||gv_roll_num
                                   ,PAR_TEXT        => gv_error_body
                                 );

           End;
           set_log(p_ag_roll_id, 'STEP 7');
       end if;

       set_log(p_ag_roll_id, 'STEP 8 (END)');

    END; -- send_docs_by_email

    FUNCTION to_money_sep( p_num in number, p_index in varchar2 default 'INT')
    RETURN VARCHAR2 IS
       lc_mask  VARCHAR2(50) := '999G999G999G999G999G999G990';
       lm_all   VARCHAR2(50) := '999G999G999G999G999G999G990D99';
    BEGIN
       if nvl(p_index,'INT') <> 'INT'
         then lc_mask := lm_all;
       end if;
       RETURN ltrim(to_char(p_num, lc_mask, 'NLS_NUMERIC_CHARACTERS = '', '''));
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;


END;
/
