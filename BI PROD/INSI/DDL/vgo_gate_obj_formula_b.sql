CREATE OR REPLACE FORCE VIEW VGO_GATE_OBJ_FORMULA_B AS
SELECT   	COUNT (gg.gate_obj_id) OVER (PARTITION BY gg.ID, gg.gate_package_id) AS c_n, gg.ID,
					COUNT (gg.gate_obj_id) OVER (PARTITION BY gg.ID, gg.gate_package_id order by gg.GATE_OBJ_ID)as NN,
					gg.GATE_OBJ_ID,
			        gg.gate_row_status_id,
					gg.GATE_OBJ_TYPE_ID,
					gg.GATE_PACKAGE_ID
    FROM (SELECT DISTINCT (a.ID), a.cc_min, a.cc_max
                     FROM (SELECT g.ID, g.gate_row_status_id,
                                  MIN (g.gate_obj_id) OVER (PARTITION BY g.ID , g.gate_package_id)
                                                                    AS cc_min,
                                  MAX (g.gate_obj_id) OVER (PARTITION BY g.ID, g.gate_package_id)
                                                                    AS cc_max
                             FROM gate_obj g
                             ) a
                 ORDER BY a.ID) b,
         gate_obj gg
   WHERE gg.ID = b.ID
     AND (gg.gate_obj_id = b.cc_min OR gg.gate_obj_id = b.cc_max)
ORDER BY gg.gate_obj_id;

