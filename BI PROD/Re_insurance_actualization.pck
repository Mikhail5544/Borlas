CREATE OR REPLACE PACKAGE Re_insurance_actualization IS
  -- Пакет содержит процедуры актуализации данных перестрахования
  -- Под актуализацией данных перестрахование понимается
  -- первоначальное разовое заполнение признака перестрахования (запись as_assured_re)
  -- в договорах, которые должны быть включены хотя бы в одно пересраховочное боредро
  -- по соответствующему договору перестрахования за всю историю его действия
  -- до настоящего момента времени
  --
  -- Без актуализации договора обработанные до включения механизма перестрахования
  -- включаться в перестраховочное бореждро не будут.
  --
  -- Должен быть использован совместно с пакетом pkg_re_insurance

  PROCEDURE fill_policy_reins(par_policy_id IN NUMBER);

  PROCEDURE fill_policy_reins_contract
  (par_policy_id in number, par_re_contract_version_id in number);

  PROCEDURE fill_all_policy;

  PROCEDURE fill_all_policy1_1__1_2_S;
  PROCEDURE fill_all_policy1_1__1_2_SC;

  PROCEDURE fill_all_policy_1_2_SW;
  PROCEDURE fill_all_policy_1_2_H;
  PROCEDURE fill_all_policy_1_2_G;

  PROCEDURE unfill_all_policy(par_re_contract_version_id IN NUMBER);

  PROCEDURE Actualization_script;

END Re_insurance_actualization;
/

create or replace package body Re_insurance_actualization is
-- Пакет содержит процедуры актуализации данных перестрахования
-- Под актуализацией данных перестрахование понимается
-- первоначальное разовое заполнение признака перестрахования (запись as_assured_re)
-- в договорах, которые должны быть включены хотя бы в одно пересраховочное бордеро
-- по соответствующему договору перестрахования за всю историю его действия
-- до настоящего момента времени
--
-- Без актуализации договора обработанные до включения механизма перестрахования
-- включаться в перестраховочное бореждро не будут.
--
-- Должен быть использован совместно с пакетом pkg_re_insurance

procedure fill_policy_reins(par_policy_id in number)
is
  p_fund_id number;
  p_bordero_type number;
  p_old_bordero_type number;
  p_as_assured_re_id number;
begin
  --Определяем валюту договора
  select ph.fund_id
    into p_fund_id
    from p_pol_header ph, p_policy p
   where p.pol_header_id = ph.policy_header_id
     and p.policy_id     = par_policy_id;

-- select ph.fund_id into p_fund_id
-- from p_pol_header ph where ph.policy_header_id=par_pol_header_id;

  --Ищем договора перестрахования в статусе Действующий
  for r in (select distinct
                   mc.re_main_contract_id
                  ,mc.last_version_id
                  ,mc.reinsurer_id
              from re_main_contract mc
                  ,re_contract_version cv
                  ,re_contract_ver_fund cvf
                  ,document d
                  ,/*doc_status ds,*/doc_status_ref dsr
             where d.document_id              = cv.re_contract_version_id
               and cv.re_main_contract_id     = mc.re_main_contract_id
               and cvf.re_contract_version_id = cv.re_contract_version_id
   --            and ds.document_id=d.document_id
               and dsr.doc_status_ref_id      = d.doc_status_ref_id
               and upper(dsr.brief)           = 'CURRENT'
               and cvf.fund_id                = p_fund_id
            ) loop

      --Определяем тип перестрахования
      p_bordero_type := pkg_re_insurance.Check_policy_type(r.last_version_id, par_policy_id);

      if p_bordero_type >= 0 then --Если в версии есть риски, попадающие под перестрахование, то добавляем перестраховщика
      --  pkg_re_insurance.del_assured(par_policy_id);
      --Проверяем наличие в том договора перестраховщика с таким же типом перестрахования
        begin
          select ar.as_assured_re_id, ar.re_bordero_type_id
            into p_as_assured_re_id, p_old_bordero_type
            from as_assured_re ar
           where ar.p_policy_id=par_policy_id
             and ar.p_re_id=r.reinsurer_id
             and ar.re_contract_version_id=r.last_version_id;

--          if p_old_bordero_type < p_bordero_type then   --если есть перестраховщик с меньшим типом бордеро, то меняем тип бордеро
            update as_assured_re ar
               set ar.re_bordero_type_id = p_bordero_type
             where ar.as_assured_re_id = p_as_assured_re_id;
--          end if;
        exception when no_data_found then
          select sq_as_assured_re.nextval
            into p_as_assured_re_id
            from dual;
          insert into as_assured_re
          (as_assured_re_id, p_policy_id, p_re_id, re_bordero_type_id, re_contract_version_id)
          values
          (p_as_assured_re_id, par_policy_id, r.reinsurer_id, p_bordero_type, r.last_version_id);
        end;
      end if;
  end loop;

end fill_policy_reins;

procedure fill_policy_reins_contract(par_policy_id in number, par_re_contract_version_id in number)
is
  p_fund_id number;
  p_bordero_type number;
  p_old_bordero_type number;
  p_as_assured_re_id number;
begin
  --Определяем валюту договора
  select ph.fund_id
    into p_fund_id
    from p_pol_header ph, p_policy p
   where p.pol_header_id = ph.policy_header_id
     and p.policy_id     = par_policy_id;

-- select ph.fund_id into p_fund_id
-- from p_pol_header ph where ph.policy_header_id=par_pol_header_id;

  --Ищем договора перестрахования в статусе Действующий
  for r in (select distinct
                   mc.re_main_contract_id
                  ,mc.last_version_id
                  ,mc.reinsurer_id
              from re_main_contract mc
                  ,re_contract_version cv
                  ,re_contract_ver_fund cvf
                  ,document d
                  ,/*doc_status ds,*/doc_status_ref dsr
             where d.document_id              = cv.re_contract_version_id
               and cv.re_main_contract_id     = mc.re_main_contract_id
               and cvf.re_contract_version_id = cv.re_contract_version_id
               and cv.re_contract_version_id  = par_re_contract_version_id
   --            and ds.document_id=d.document_id
               and dsr.doc_status_ref_id      = d.doc_status_ref_id
               and upper(dsr.brief)           = 'CURRENT'
               and cvf.fund_id                = p_fund_id
            ) loop

      --Определяем тип перестрахования
      p_bordero_type := pkg_re_insurance.Check_policy_type(r.last_version_id, par_policy_id);

      if p_bordero_type >= 0 then --Если в версии есть риски, попадающие под перестрахование, то добавляем перестраховщика
      --  pkg_re_insurance.del_assured(par_policy_id);
      --Проверяем наличие в том договоре перестраховщика с таким же типом перестрахования
        begin
          select ar.as_assured_re_id, ar.re_bordero_type_id
            into p_as_assured_re_id, p_old_bordero_type
            from as_assured_re ar
           where ar.p_policy_id=par_policy_id
             and ar.p_re_id=r.reinsurer_id
             and ar.re_contract_version_id=r.last_version_id;

--          if p_old_bordero_type < p_bordero_type then   --если есть перестраховщик с меньшим типом бордеро, то меняем тип бордеро
            update as_assured_re ar
               set ar.re_bordero_type_id = p_bordero_type
             where ar.as_assured_re_id = p_as_assured_re_id;
--          end if;
        exception when no_data_found then
          select sq_as_assured_re.nextval
            into p_as_assured_re_id
            from dual;
          insert into as_assured_re
          (as_assured_re_id, p_policy_id, p_re_id, re_bordero_type_id, re_contract_version_id)
          values
          (p_as_assured_re_id, par_policy_id, r.reinsurer_id, p_bordero_type, r.last_version_id);
        end;
      end if;
  end loop;

end fill_policy_reins_contract;


procedure fill_all_policy
as
v_re_contract_version_id1_1 number := 44771088; --  Gen Re Geynts 44530374;  -- Test_2 GenRe Corp
re_start_date1_1 date := TO_DATE('01-01-2008','DD-MM-YYYY');
re_end_date1_1 date := TO_DATE('31-12-9999','DD-MM-YYYY');

v_re_contract_version_id1_2 number := 44771137;  -- S Ind Geynts
re_start_date1_2 date := TO_DATE('01-10-2011','DD-MM-YYYY');
re_end_date1_2 date := TO_DATE('31-12-2014','DD-MM-YYYY');

v_re_contract_version_id1_3 number := 44771316;  -- Swiss Re
re_start_date1_3 date := TO_DATE('01-06-2010','DD-MM-YYYY');
re_end_date1_3 date := TO_DATE('30-06-2020','DD-MM-YYYY');

v_re_contract_version_id2 number := 44771235;  -- ГРС
re_start_date2 date := TO_DATE('01-01-2012','DD-MM-YYYY');
re_end_date2 date := TO_DATE('31-12-2012','DD-MM-YYYY');

begin

/*
select rmc.start_date, rmc.end_date
into re_start_date1_1, re_end_date1_1
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id1_1;

select rmc.start_date, rmc.end_date
into re_start_date1_2, re_end_date1_2
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id1_2;

select rmc.start_date, rmc.end_date
into re_start_date1_3, re_end_date1_3
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id1_3;

select rmc.start_date, rmc.end_date
into re_start_date2, re_end_date2
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id2;
*/

--DBMS_OUTPUT.ENABLE(1000000);

  /* актуализация способом 1.1 */
  for cur1_1 in (SELECT p.policy_Id
                   FROM p_policy       p
                       ,p_pol_header   ph
                       ,doc_status     ds_initial
                       ,doc_status_ref dsr_initial
                       ,document       d
                       ,doc_status_ref dsr_current
                       ,document       dlst
                       ,doc_status     dslst
                       ,doc_status_ref dsrlst
                  WHERE trunc(re_start_date1_1) /* actualization date */
                        BETWEEN p.start_date AND p.end_date
                      -- Байтин А.
                      and p.pol_header_id         = ph.policy_header_id
                      AND ph.last_ver_id          = dlst.document_id
                      and dlst.doc_status_id      = dslst.doc_status_id
                      and dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
                      and (dsrlst.brief != 'CANCEL'
                         or dslst.start_date >= re_start_date1_1 and dsrlst.brief = 'CANCEL')
                      --
                    AND EXISTS (SELECT NULL
                                  FROM doc_status     ds
                                      ,doc_status_ref dsr
                                      ,doc_status_ref dsr1
                                 WHERE ds.document_id = p.policy_id
                                   AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                   AND dsr.brief = 'NEW' -- Новый
                                   AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                   AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект, Индексация
                                )
                    AND d.document_id = p.policy_id
                    AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
                    AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
                    AND ds_initial.doc_status_id =
                        (SELECT MIN(ds_min.doc_status_id)
                           FROM doc_status ds_min
                          WHERE ds_min.document_id = p.policy_id)
                    AND ds_initial.document_id = p.policy_id
                    AND dsr_initial.brief NOT IN ('TO_QUIT', 'READY_TO_CANCEL')
                    AND dsr_initial.doc_status_ref_id = ds_initial.doc_status_ref_id
                  ORDER BY p.policy_id
             )

  loop
    begin
       fill_policy_reins_contract(cur1_1.policy_id, v_re_contract_version_id1_1);  -- Test_2 GenRe Corp
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type 1.1. Trouble policy_id = '
        ||TO_CHAR(cur1_1.policy_id));*/
        null;
    end;

  end loop;

  for cur1_2 /* актуализация способом 1.2 */ in (

      SELECT p.policy_id
        FROM p_policy       p
            ,doc_status     ds_initial
            ,doc_status_ref dsr_initial
            ,document       d
            ,doc_status_ref dsr_current
            ,p_pol_header   ph
            ,document       dlst
            ,doc_status     dslst
            ,doc_status_ref dsrlst
       WHERE (
       -- Effective interval contains begin date of reinsurance agreement
        trunc(re_start_date1_2) /* actualization date */
        BETWEEN p.start_date AND p.end_date OR
       -- Effective interval later than begin date of reinsurance agreement
        p.start_date BETWEEN trunc(re_start_date1_2) AND trunc(re_end_date1_2))

        -- Байтин А.
        and p.pol_header_id         = ph.policy_header_id
        AND ph.last_ver_id          = dlst.document_id
        and dlst.doc_status_id      = dslst.doc_status_id
        and dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
        and (dsrlst.brief != 'CANCEL'
           or dslst.start_date >= re_start_date1_2 and dsrlst.brief = 'CANCEL')

                      --
       AND EXISTS
       (SELECT NULL
          FROM doc_status     ds
              ,doc_status_ref dsr
              ,doc_status_ref dsr1
         WHERE ds.document_id = p.policy_id
           AND ds.doc_status_ref_id = dsr.doc_status_ref_id
           AND dsr.brief = 'NEW' -- Новый
           AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
           AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект, Индексация
        )
       AND d.document_id = p.policy_id
       AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
       AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
       AND ds_initial.doc_status_id =
       (SELECT MIN(ds_min.doc_status_id) FROM doc_status ds_min WHERE ds_min.document_id = p.policy_id)
       AND ds_initial.document_id = p.policy_id
       AND dsr_initial.brief NOT IN ('TO_QUIT', 'READY_TO_CANCEL')
       AND dsr_initial.doc_status_ref_id = ds_initial.doc_status_ref_id
       ORDER BY p.policy_id)
  loop
    begin
       fill_policy_reins_contract(cur1_2.policy_id, v_re_contract_version_id1_2);  -- Test_2 GenRe Corp
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type 1.2. Trouble policy_id = '
        ||TO_CHAR(cur1_2.policy_id));*/
        null;
    end;

  end loop;

  /* актуализация способом 1.3 */
  for cur1_3 in (
    SELECT p.policy_id
      FROM p_policy       p
          ,p_pol_header   ph
          ,doc_status     ds_initial
          ,doc_status_ref dsr_initial
          ,document       d
          ,doc_status_ref dsr_current
          ,document       dlst
          ,doc_status     dslst
          ,doc_status_ref dsrlst
     WHERE ph.policy_header_id = p.pol_header_id
       AND (
          -- Версии, действующие на начало действия договора перестрахования
           trunc(re_start_date1_3) /* actualization date */
           BETWEEN p.start_date AND p.end_date
        OR
          -- Период действия всего договора в интервале действия договора перестрахования
           ph.start_date BETWEEN trunc(re_start_date1_3) AND trunc(re_end_date1_3))
          -- Байтин А.
       AND ph.last_ver_id = dlst.document_id
       AND dlst.doc_status_id = dslst.doc_status_id
       AND dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
       and (dsrlst.brief != 'CANCEL'
          or dslst.start_date >= re_start_date1_3 and dsrlst.brief = 'CANCEL')
          --

       AND EXISTS (SELECT NULL
              FROM doc_status     ds
                  ,doc_status_ref dsr
                  ,doc_status_ref dsr1
             WHERE ds.document_id = p.policy_id
               AND ds.doc_status_ref_id = dsr.doc_status_ref_id
               AND dsr.brief = 'NEW' -- Новый
               AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
               AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект
            )
       AND d.document_id = p.policy_id
       AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
       AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
       AND ds_initial.doc_status_id =
           (SELECT MIN(ds_min.doc_status_id)
              FROM doc_status ds_min
             WHERE ds_min.document_id = p.policy_id)
       AND ds_initial.document_id = p.policy_id
       AND dsr_initial.brief NOT IN ('TO_QUIT', 'READY_TO_CANCEL')
       AND dsr_initial.doc_status_ref_id = ds_initial.doc_status_ref_id
    -- Сортировка необходима для логирования процесса по сбойным записям,
    -- для того, чтобы понимать до какого ID процесс выполнен
     ORDER BY p.policy_id)

  loop
    begin
       fill_policy_reins_contract(cur1_3.policy_id, v_re_contract_version_id1_3);  -- Test_2 GenRe Corp
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type 1.3. Trouble policy_id = '
        ||TO_CHAR(cur1_3.policy_id));*/
        null;
    end;
  end loop;

  for cur2 /* актуализация 2-м способом */ in (

         SELECT p.policy_id --count(*)
           FROM p_policy       p
               ,p_pol_header   ph
               ,doc_status     ds_initial
               ,doc_status_ref dsr_initial
               ,document       d
               ,doc_status_ref dsr_current
               ,document       dlst
               ,doc_status     dslst
               ,doc_status_ref dsrlst
          WHERE
         -- Байтин А.
          p.pol_header_id = ph.policy_header_id
          AND ph.last_ver_id = dlst.document_id
          AND dlst.doc_status_id = dslst.doc_status_id
          AND dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
          and (dsrlst.brief != 'CANCEL'
             or dslst.start_date >= re_start_date2 and dsrlst.brief = 'CANCEL')
         --
          AND EXISTS (SELECT NULL
             FROM p_cover  pc
                 ,as_asset asa
            WHERE pc.as_asset_id = asa.as_asset_id
              AND asa.p_policy_id = p.policy_id
              AND pc.start_date <= trunc(re_end_date2) -- end effective date of reinsurance treaty
              AND pc.end_date >= trunc(re_start_date2) -- start effective date of reinsurance treaty
           )
          AND EXISTS (SELECT NULL
             FROM doc_status     ds
                 ,doc_status_ref dsr
                 ,doc_status_ref dsr1
            WHERE ds.document_id = p.policy_id
              AND ds.doc_status_ref_id = dsr.doc_status_ref_id
              AND dsr.brief = 'NEW' -- Новый
              AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
              AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект, Индексация
           )
          AND d.document_id = p.policy_id
          AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
          AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
          AND ds_initial.doc_status_id =
          (SELECT MIN(ds_min.doc_status_id)
             FROM doc_status ds_min
            WHERE ds_min.document_id = p.policy_id)
          AND ds_initial.document_id = p.policy_id
          AND dsr_initial.brief NOT IN ('TO_QUIT', 'READY_TO_CANCEL')
          AND dsr_initial.doc_status_ref_id = ds_initial.doc_status_ref_id)
  loop
    begin
       fill_policy_reins_contract(cur2.policy_id, v_re_contract_version_id2);  -- ГРС
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type 2. Trouble policy_id = '
        ||TO_CHAR(cur2.policy_id));*/
        null;
    end;
  end loop;
end;


procedure unfill_all_policy(par_re_contract_version_id in number)
is
begin
  delete
  from as_assured_re asr
  where asr.re_contract_version_id = par_re_contract_version_id;
  commit;
end;



procedure fill_all_policy1_1__1_2_S
is
v_re_contract_version_id_S number;-- := 63949948; -- SCOR_IND
re_start_date_S date := TO_DATE('01-10-2011','DD-MM-YYYY'); -- SCOR_CRED
re_end_date_S date := TO_DATE('31-12-2014','DD-MM-YYYY'); -- SCOR_CRED

begin
  select mc.last_version_id
    into v_re_contract_version_id_S
    from ven_re_main_contract mc
   where mc.num = 'SCOR_IND';

/*
select rmc.start_date, rmc.end_date
into re_start_date_S, re_end_date_S
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id_S;
*/

--DBMS_OUTPUT.ENABLE(1000000);
  /* актуализация способом 1.2 */
  for cur_S in (SELECT p.policy_id
                     FROM p_policy       p
                         ,p_pol_header   ph
                         ,document       d
                         ,doc_status_ref dsr_current
                         ,document       dlst
                         ,doc_status     dslst
                         ,doc_status_ref dsrlst
                    WHERE (
                          -- Effective interval contains begin date of reinsurance agreement
                           trunc(re_start_date_S) /* actualization date */
                           BETWEEN p.start_date AND p.end_date OR
                          -- Effective interval later than begin date of reinsurance agreement
                           p.start_date BETWEEN trunc(re_start_date_S) AND trunc(re_end_date_S))
                      -- Байтин А.
                      AND ph.last_ver_id          = dlst.document_id
                      and dlst.doc_status_id      = dslst.doc_status_id
                      and dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
                      and (dsrlst.brief != 'CANCEL'
                         or (dslst.start_date >= re_start_date_S and dsrlst.brief = 'CANCEL'))
                      /*and
                      (
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'NEW' -- Новый
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект, Индексация
                                )
                         OR
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'PASSED_TO_AGENT' -- Передано Агенту
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief = 'PROJECT' -- Проект
                                )
                      )*/
                      AND d.document_id = p.policy_id
                      AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
                      AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
                         -- Перебираем только индивидуальные договоры для ускорения процесса
                         -- так как договор индивидуальный
                      AND p.is_group_flag = 0

                         -- Для сужения по продуктам
                      AND ph.policy_header_id = p.pol_header_id
                      -- Сужение по версиям договоров страхования с факультативным признаком перестрахования
                      -- и не заполненным признаком перестрахования
                      and exists (
                                  select asa_re.as_assured_re_id
                                  from as_assured_re asa_re
                                  where asa_re.p_policy_id = p.policy_id
                                  and asa_re.re_contract_version_id = v_re_contract_version_id_S
                                  and asa_re.num_re is null
                                  and asa_re.re_bordero_type_id = 2 -- 2 -- Факультатив  
                                 )
                      ORDER BY p.policy_id)
  loop
    begin
       fill_policy_reins_contract(cur_S.policy_id, v_re_contract_version_id_S);
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type S. Trouble policy_id = '
        ||TO_CHAR(cur_S.policy_id));*/
        null;
    end;

  end loop;

end;


procedure fill_all_policy1_1__1_2_SC
is
v_re_contract_version_id_SC number;-- := 63949962; -- SCOR_CRED
re_start_date_SC date := TO_DATE('01-10-2011','DD-MM-YYYY'); -- SCOR_CRED
re_end_date_SC date := TO_DATE('31-12-2014','DD-MM-YYYY'); -- SCOR_CRED

begin
  select mc.last_version_id
    into v_re_contract_version_id_SC
    from ven_re_main_contract mc
   where mc.num = 'SCOR_CRED';
/*
select rmc.start_date, rmc.end_date
into re_start_date_SC, re_end_date_SC
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id_SC;
*/

--DBMS_OUTPUT.ENABLE(1000000);
  /* актуализация способом 1.2 */
  for cur_SC in (SELECT p.policy_id
                     FROM p_policy       p
                         ,p_pol_header   ph
                         ,document       d
                         ,doc_status_ref dsr_current
                         ,document       dlst
                         ,doc_status     dslst
                         ,doc_status_ref dsrlst
                    WHERE (
                          -- Effective interval contains begin date of reinsurance agreement
                           trunc(re_start_date_SC) /* actualization date */
                           BETWEEN p.start_date AND p.end_date OR
                          -- Effective interval later than begin date of reinsurance agreement
                           p.start_date BETWEEN trunc(re_start_date_SC) AND trunc(re_end_date_SC))
                      -- Байтин А.
                      AND ph.last_ver_id          = dlst.document_id
                      and dlst.doc_status_id      = dslst.doc_status_id
                      and dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
                      and (dsrlst.brief != 'CANCEL'
                         or (dslst.start_date >= re_start_date_SC and dsrlst.brief = 'CANCEL'))
                      /*and
                      (
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'NEW' -- Новый
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект, Индексация
                                )
                         OR
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'PASSED_TO_AGENT' -- Передано Агенту
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief = 'PROJECT' -- Проект
                                )
                      )*/
                      AND d.document_id = p.policy_id
                      AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
                      AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
                         -- Перебираем только индивидуальные договоры для ускорения процесса
                         -- так как договор индивидуальный
                      AND p.is_group_flag = 0

                         -- Для сужения по продуктам
                      AND ph.policy_header_id = p.pol_header_id
                      and exists (
                                  select asa_re.as_assured_re_id
                                  from as_assured_re asa_re
                                  where asa_re.p_policy_id = p.policy_id
                                  and asa_re.re_contract_version_id = v_re_contract_version_id_SC
                                  and asa_re.num_re is null
                                  and asa_re.re_bordero_type_id = 2 -- 2 -- Факультатив  
                                 )
                    ORDER BY p.policy_id)
  loop
    begin
       fill_policy_reins_contract(cur_SC.policy_id, v_re_contract_version_id_SC);
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type SC. Trouble policy_id = '
        ||TO_CHAR(cur_SC.policy_id));*/
        null;
    end;
  end loop;

end;


procedure Actualization_script
-- Тело процедуры представляет собой полную актуализацию данных

  as
begin
-- индивидуальные договора
    dbms_application_info.set_client_info('fill_all_policy1_1__1_2_S');
    Re_insurance_actualization.fill_all_policy1_1__1_2_S;
    commit;
    dbms_application_info.set_client_info('fill_all_policy1_1__1_2_SC');
    Re_insurance_actualization.fill_all_policy1_1__1_2_SC;
    commit;
    dbms_application_info.set_client_info('fill_all_policy_1_2_SW');
    Re_insurance_actualization.fill_all_policy_1_2_SW;
    commit;
    dbms_application_info.set_client_info('fill_all_policy_1_2_H');
    Re_insurance_actualization.fill_all_policy_1_2_H;
    commit;
    dbms_application_info.set_client_info('fill_all_policy_1_2_G');
    Re_insurance_actualization.fill_all_policy_1_2_G;
    commit;

end Actualization_script;

procedure fill_all_policy_1_2_SW
is
v_re_contr_ver_id_SW number;-- := 63949983; --  SWISS_IND
re_start_date_SW date := TO_DATE('01-07-2010','DD-MM-YYYY'); --  SWISS_IND
re_end_date_SW date := TO_DATE('30-06-2020','DD-MM-YYYY'); -- SWISS_IND

begin
  select mc.last_version_id
    into v_re_contr_ver_id_SW
    from ven_re_main_contract mc
   where mc.num = 'SWISS_IND';
/*
select rmc.start_date, rmc.end_date
into re_start_date_S, re_end_date_S
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id_S;
*/

--DBMS_OUTPUT.ENABLE(1000000);
  /* актуализация способом 1.2 */
  for cur_SW in (SELECT p.policy_id
                     FROM p_policy       p
                         ,p_pol_header   ph
                         ,document       d
                         ,doc_status_ref dsr_current
                         ,document       dlst
                         ,doc_status     dslst
                         ,doc_status_ref dsrlst
                    WHERE (
                          -- Effective interval later than begin date of reinsurance agreement
                           p.start_date BETWEEN trunc(re_start_date_SW) AND trunc(re_end_date_SW))
                      -- Байтин А.
                      AND ph.last_ver_id          = dlst.document_id
                      and dlst.doc_status_id      = dslst.doc_status_id
                      and dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
                      and (dsrlst.brief != 'CANCEL'
                         or (dslst.start_date >= re_start_date_SW and dsrlst.brief = 'CANCEL'))
                      --

                      /*AND
                      (
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'NEW' -- Новый
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект, Индексация
                                )
                         OR
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'PASSED_TO_AGENT' -- Передано Агенту
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief = 'PROJECT' -- Проект
                                )
                      )*/
                      AND d.document_id = p.policy_id
                      AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
                      AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
                         -- Перебираем только индивидуальные договоры для ускорения процесса
                         -- так как договор индивидуальный
                      AND p.is_group_flag = 0

                         -- Для сужения по продуктам
                      AND ph.policy_header_id = p.pol_header_id
                      and exists (
                                  select asa_re.as_assured_re_id
                                  from as_assured_re asa_re
                                  where asa_re.p_policy_id = p.policy_id
                                  and asa_re.re_contract_version_id = v_re_contr_ver_id_SW
                                  and asa_re.num_re is null
                                  and asa_re.re_bordero_type_id = 2 -- 2 -- Факультатив  
                                 )

                    ORDER BY p.policy_id)
  loop

    begin
       fill_policy_reins_contract(cur_SW.policy_id, v_re_contr_ver_id_SW);
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type Swiss_Hann. Trouble policy_id = '
        ||TO_CHAR(cur_SW.policy_id));*/
        null;
    end;

  end loop;

end;

procedure fill_all_policy_1_2_H
is
v_re_contr_ver_id_H number;-- := 63949993; --  HANN_IND
re_start_date_H date := TO_DATE('01-09-2012','DD-MM-YYYY'); -- HANN_IND
re_end_date_H date := TO_DATE('31-12-2013','DD-MM-YYYY'); -- HANN_IND

begin
  select mc.last_version_id
    into v_re_contr_ver_id_H
    from ven_re_main_contract mc
   where mc.num = 'HANN_IND';
/*
select rmc.start_date, rmc.end_date
into re_start_date_S, re_end_date_S
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id_S;
*/

--DBMS_OUTPUT.ENABLE(1000000);
  /* актуализация способом 1.2 */
  for cur_H in (SELECT p.policy_id
                     FROM p_policy       p
                         ,p_pol_header   ph
                         ,document       d
                         ,doc_status_ref dsr_current
                         ,document       dlst
                         ,doc_status     dslst
                         ,doc_status_ref dsrlst
                    WHERE (
                          -- Effective interval later than begin date of reinsurance agreement
                           p.start_date BETWEEN trunc(re_start_date_H) AND trunc(re_end_date_H))
                      -- Байтин А.
                      AND ph.last_ver_id          = dlst.document_id
                      and dlst.doc_status_id      = dslst.doc_status_id
                      and dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
                      and (dsrlst.brief != 'CANCEL'
                         or (dslst.start_date >= re_start_date_H and dsrlst.brief = 'CANCEL'))
                      --

                      /*AND
                      (
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'NEW' -- Новый
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект, Индексация
                                )
                         OR
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'PASSED_TO_AGENT' -- Передано Агенту
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief = 'PROJECT' -- Проект
                                )
                      )*/
                      AND d.document_id = p.policy_id
                      AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
                      AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
                         -- Перебираем только индивидуальные договоры для ускорения процесса
                         -- так как договор индивидуальный
                      AND p.is_group_flag = 0

                         -- Для сужения по продуктам
                      AND ph.policy_header_id = p.pol_header_id
                      and exists (
                                  select asa_re.as_assured_re_id
                                  from as_assured_re asa_re
                                  where asa_re.p_policy_id = p.policy_id
                                  and asa_re.re_contract_version_id = v_re_contr_ver_id_H
                                  and asa_re.num_re is null
                                  and asa_re.re_bordero_type_id = 2 -- 2 -- Факультатив  
                                 )                      
                    ORDER BY p.policy_id)
  loop

    begin
       fill_policy_reins_contract(cur_H.policy_id, v_re_contr_ver_id_H);
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type Hiss_Hann. Trouble policy_id = '
        ||TO_CHAR(cur_H.policy_id));*/
        null;
    end;

  end loop;

end;

procedure fill_all_policy_1_2_G
is
v_re_contr_ver_id_G number;-- := 63949971; -- GRS_IND
re_start_date_G date := TO_DATE('01-01-2012','DD-MM-YYYY'); -- GRS_IND
re_end_date_G date := TO_DATE('31-12-2013','DD-MM-YYYY'); -- GRS_IND

begin
  select mc.last_version_id
    into v_re_contr_ver_id_G
    from ven_re_main_contract mc
   where mc.num = 'GRS_IND';
/*
select rmc.start_date, rmc.end_date
into re_start_date_S, re_end_date_S
from re_main_contract rmc,
     re_contract_version rcv
where rcv.re_main_contract_id = rmc.re_main_contract_id
and rcv.re_contract_version_id = v_re_contract_version_id_S;
*/

--DBMS_OUTPUT.ENABLE(1000000);
  /* актуализация способом 1.2 */
  for cur_G in (SELECT p.policy_id
                     FROM p_policy       p
                         ,p_pol_header   ph
                         ,document       d
                         ,doc_status_ref dsr_current
                         ,document       dlst
                         ,doc_status     dslst
                         ,doc_status_ref dsrlst
                    WHERE (
                          -- Effective interval later than begin date of reinsurance agreement
                           p.start_date BETWEEN trunc(re_start_date_G) AND trunc(re_end_date_G))
                      -- Байтин А.
                      AND ph.last_ver_id          = dlst.document_id
                      and dlst.doc_status_id      = dslst.doc_status_id
                      and dslst.doc_status_ref_id = dsrlst.doc_status_ref_id
                      and (dsrlst.brief != 'CANCEL'
                         or (dslst.start_date >= re_start_date_G and dsrlst.brief = 'CANCEL'))
                      --

                      /*AND
                      (
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'NEW' -- Новый
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief IN ('PROJECT', 'INDEXATION') -- Проект, Индексация
                                )
                         OR
                         EXISTS (SELECT null
                                FROM doc_status     ds
                                    ,doc_status_ref dsr
                                    ,doc_status_ref dsr1
                                WHERE ds.document_id = p.policy_id
                                  AND ds.doc_status_ref_id = dsr.doc_status_ref_id
                                  AND dsr.brief = 'PASSED_TO_AGENT' -- Передано Агенту
                                  AND dsr1.doc_status_ref_id = ds.src_doc_status_ref_id
                                  AND dsr1.brief = 'PROJECT' -- Проект
                                )
                      )*/
                      AND d.document_id = p.policy_id
                      AND d.doc_status_ref_id = dsr_current.doc_status_ref_id
                      AND dsr_current.brief NOT IN ('PROJECT', 'INDEXATION')
                         -- Перебираем только индивидуальные договоры для ускорения процесса
                         -- так как договор индивидуальный
                      AND p.is_group_flag = 0

                         -- Для сужения по продуктам
                      AND ph.policy_header_id = p.pol_header_id
                      and exists (
                                  select asa_re.as_assured_re_id
                                  from as_assured_re asa_re
                                  where asa_re.p_policy_id = p.policy_id
                                  and asa_re.re_contract_version_id = v_re_contr_ver_id_G
                                  and asa_re.num_re is null
                                  and asa_re.re_bordero_type_id = 2 -- 2 -- Факультатив  
                                 )  
                    
                    ORDER BY p.policy_id)
  loop

    begin
       fill_policy_reins_contract(cur_G.policy_id, v_re_contr_ver_id_G);
    exception
      when others then
      -- Необходимо журналировать проблемные полисы без остановки процесса
        /*DBMS_OUTPUT.PUT_LINE('Actualization type Giss_Hann. Trouble policy_id = '
        ||TO_CHAR(cur_G.policy_id));*/
        null;
    end;

  end loop;

end;

end Re_insurance_actualization;
/
