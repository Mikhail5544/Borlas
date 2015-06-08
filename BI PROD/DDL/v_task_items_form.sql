CREATE OR REPLACE VIEW V_TASK_ITEMS_FORM AS
SELECT file_name item_name
      ,2         item_type
      ,'FORM'    item_type_brief
  FROM t_form;
  -- Чирков комментарии 239817
/* ORDER BY file_name;*/
