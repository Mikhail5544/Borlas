create or replace view fv_oper_templ as
SELECT ot.oper_templ_id
      ,ot.name
      ,ot.brief
      ,ot.filial_id
      ,ot.ent_id
      ,ot.date_type_id
      ,ot.templ_function
      ,dt.name date_type_name
  FROM ven_oper_templ ot
      ,date_type      dt
 WHERE ot.date_type_id = dt.date_type_id;

GRANT SELECT ON fv_oper_templ TO INS_READ;
