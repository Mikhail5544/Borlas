CREATE OR REPLACE VIEW FV_T_PKG_COMM_LOG AS
SELECT * FROM t_pkg_comm_log;

grant select on FV_T_PKG_COMM_LOG to ins_read, ins_eul;
