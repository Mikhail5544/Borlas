CREATE OR REPLACE FORCE VIEW VGO_GATE_OBJ AS
SELECT gobj.gate_obj_id, gobj.ID, got.descr, grs.descr as grs_descr 
  FROM gate_obj gobj, gate_row_status grs, gate_obj_type got 
 WHERE got.gate_obj_type_id = gobj.gate_obj_type_id 
   AND gobj.gate_row_status_id = grs.gate_row_status_id;

