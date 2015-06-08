CREATE OR REPLACE FORCE VIEW V_RULE_LINE AS
SELECT 1 col1 FROM dual
--Это судя по всему остатки copy paste из AC plus
/*SELECT rl.rule_id as rule_id,
       rl.line_nr as line_nr,
       pkg_rule.get_rule_factor_name(rl.factor_1) as factor_1,
       rct.dsc as condition_code,
       pkg_rule.get_rule_factor_name(rl.factor_2) as factor_2,
       rdt.dsc as do_code,
       pkg_rule.get_rule_factor_name(rl.factor_3) as factor_3,
       rat.dsc as action_code,
       pkg_rule.get_rule_factor_name(rl.factor_4) as factor_4,
       rrat.dsc result_action_code,
       pkg_rule.get_rule_factor_name(rl.factor_5) as factor_5
  FROM t_rule r,
       t_rule_line rl,
       t_rule_condition_type rct,
       t_rule_do_type rdt,
       t_rule_action_type rat,
       t_rule_result_action_type rrat
 where rl.rule_id = r.id
 and rct.t_rule_condition_type_id (+)= rl.condition_code
 and rdt.t_rule_do_type_id (+)= rl.do_code
 and rat.t_rule_action_type_id (+)= rl.action_code
 and rrat.t_rule_result_action_type_id (+)= rl.result_action_code*/
;

