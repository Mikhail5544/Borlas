CREATE OR REPLACE FORCE VIEW V_T_Q_ANSW AS
SELECT QAL.ANSWER_VALUE,
        QAL.T_Q_ANSWER_LIST_ID,
        QPQ.T_Q_PL_QUESTIONS_ID,
        Q.Q_QUESTIONS_ID,
       CASE WHEN EXISTS (SELECT NULL
                         FROM VEN_Q_ANSWERS QA
                         WHERE QA.Q_QUESTIONS_ID = Q.Q_QUESTIONS_ID
                               AND QA.T_Q_ANSWER_LIST_ID = QAL.T_Q_ANSWER_LIST_ID) THEN 1 ELSE 0 END EX_A
  FROM T_Q_ANSWER_LIST  QAL,
       Q_QUESTIONS Q,
       T_Q_PL_QUESTIONS QPQ,
       T_Q_QUESTIONS    QQ
 WHERE Q.T_Q_PL_QUESTIONS_ID = QPQ.T_Q_PL_QUESTIONS_ID
      AND QPQ.T_Q_QUESTION_ID = QQ.T_Q_QUESTIONS_ID
   AND QQ.T_Q_QUESTIONS_ID = QAL.T_Q_QUESTION_ID
WITH READ ONLY;
comment on table V_T_Q_ANSW is 'Представление для обслуживания форм анкет';
comment on column V_T_Q_ANSW.ANSWER_VALUE is 'Значение ответа';
comment on column V_T_Q_ANSW.T_Q_ANSWER_LIST_ID is 'Ид записи';
comment on column V_T_Q_ANSW.T_Q_PL_QUESTIONS_ID is 'Ид записи вопроса на риске';
comment on column V_T_Q_ANSW.Q_QUESTIONS_ID is 'Ид записи вопрос в анкете';

