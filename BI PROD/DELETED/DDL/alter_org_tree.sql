ALTER TABLE organisation_tree ADD (tac_id INTEGER);

comment on column ORGANISATION_TREE.TAC_ID
  is 'ИД трансфер-агентского пункта (ТАП)';
  
BEGIN
ents.gen_ent_all('ORGANISATION_TREE');
END;
/