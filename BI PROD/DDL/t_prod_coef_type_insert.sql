DECLARE
  v_attr_1 PLS_INTEGER;
  v_attr_2 PLS_INTEGER;
  v_attr_3 PLS_INTEGER;
BEGIN

  MERGE INTO t_attribut ta
  USING (SELECT 'DATE_YEAR' brf,
                'Дата Год' a_n,
                'Атрибут для указания года' a_note,
                3 a_id,
                'SELECT extract( YEAR FROM SYSDATE) - 5 + ROWNUM V_ID, extract( YEAR FROM SYSDATE) - 5 + ROWNUM v_name FROM dual CONNECT BY LEVEL <= 10' v_sql
           FROM dual) D
  ON (D.brf = ta.brief)
  WHEN NOT MATCHED THEN
    INSERT
      (ta.brief,
       ta.attribut_ent_id,
       ta.NAME,
       ta.note,
       ta.t_attribut_source_id,
       ta.t_attribut_id,
       ta.obj_list_sql)
    VALUES
      (d.brf,
       21,
       d.a_n,
       d.a_note,
       d.a_id,
       sq_t_attribut.nextval,
       d.v_sql);

  MERGE INTO t_attribut ta
  USING (SELECT 'IPS_AMOUNT' brief,
                'Размер ИПС' a_n,
                'Атрибут для размера Индивидуального пенсионного счета' a_note,
                3 a_id
           FROM dual) da
  ON (da.brief = ta.brief)
  WHEN MATCHED THEN
    UPDATE SET ta.NAME = ta.NAME
  WHEN NOT MATCHED THEN
    INSERT
      (ta.brief,
       ta.NAME,
       ta.note,
       ta.t_attribut_source_id,
       ta.t_attribut_id)       
    VALUES
      (da.brief,
       da.a_n,
       da.a_note,
       da.a_id,
       sq_t_attribut.nextval);       

  SELECT ta.t_attribut_id
    INTO v_attr_1
    FROM ven_t_attribut ta
   WHERE ta.brief = 'DATE_YEAR';

  SELECT ta.t_attribut_id
    INTO v_attr_2
    FROM ven_t_attribut ta
   WHERE ta.brief = 'IPS_AMOUNT';

  SELECT ta.t_attribut_id
    INTO v_attr_3
    FROM ven_t_attribut ta
   WHERE ta.brief = 'USA';

  INSERT INTO ven_t_prod_coef_type
    (brief,
     comparator_1,
     comparator_2,
     comparator_3,
     factor_1,
     factor_2,
     factor_3,
     func_define_type_id,
     NAME,
     t_prod_coef_tariff_id)
  VALUES
    ('IPS_AWARD',
     1,
     1,
     1,
     v_attr_1,
     v_attr_2,
     v_attr_3,
     2,
     'Сумма вознаграждения за ИПС',
     1);

END;
