CREATE OR REPLACE VIEW RESERVE.V_INS_VARIANT AS
SELECT l.t_lob_line_id AS "ID", l.description "DESCRIPTION",
          l.ent_id "ENT_ID",
          l.filial_id "FILIAL_ID"
     FROM ins.T_LOB_LINE l
    WHERE l.brief IN ('END', 'PEPR', 'INVEST2', 'TERM', 'DD','PEPR_A','PEPR_B','PEPR_C','PEPR_A_PLUS','PEPR_INVEST_RESERVE','OIL','GOLD');
