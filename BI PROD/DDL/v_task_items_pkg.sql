CREATE OR REPLACE VIEW V_TASK_ITEMS_PKG AS
SELECT decode(owner, 'INS', NULL, owner || '.') || UPPER(OBJECT_NAME) item_name
      ,1 item_type
     -- ,'0' checked
      ,UPPER(OBJECT_TYPE) item_type_brief
			,DECODE(owner, 'INS', NULL, owner) owner
			,object_name
  FROM SYS.ALL_OBJECTS o
 WHERE UPPER(OBJECT_TYPE) IN ('FUNCTION', 'PROCEDURE', 'PACKAGE')
   AND owner IN ('INS', 'INSI', 'INS_DWH', 'RESERVE');
/* -- Чирков комментарии 239817
ORDER BY DECODE(UPPER(OBJECT_TYPE), 'PACKAGE', NULL, UPPER(OBJECT_TYPE)) NULLS FIRST
         ,DECODE(owner, 'INS', NULL, owner) NULLS FIRST
         ,OBJECT_NAME;*/
