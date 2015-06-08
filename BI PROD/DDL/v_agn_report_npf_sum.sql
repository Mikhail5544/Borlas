create or replace view ins.v_agn_report_npf_sum as
select to_char(nvl(sum(nvl(pf.vol_amount,0) * nvl(pf.vol_rate,0) + (nvl(vol.vol_amount,0) * nvl(vol.vol_rate,0))),0),'99999990D99') sum_com_npf,
act.ag_perfomed_work_act_id, rl.ag_roll_id
from ins.ag_roll_header rh 
     join ins.ag_roll rl on rh.ag_roll_header_id = rl.ag_roll_header_id
     left join ins.ag_perfomed_work_act act on act.ag_roll_id = rl.ag_roll_id
     left join ins.ag_perfom_work_det det on det.ag_perfomed_work_act_id = act.ag_perfomed_work_act_id
     join ins.ag_rate_type rt on det.ag_rate_type_id = rt.ag_rate_type_id and rt.brief = 'OAV_0510'
     left join ins.ag_perf_work_vol vol on vol.ag_perfom_work_det_id = det.ag_perfom_work_det_id
     left join ins.ag_volume av on av.ag_volume_id = vol.ag_volume_id
     join ins.ag_npf_volume_det npf on npf.ag_volume_id = av.ag_volume_id
     
     left join 
     (select vol2.vol_amount, det2.ag_perfomed_work_act_id, vol2.ag_volume_id, av2.trans_sum, vol2.vol_rate
      from ins.ag_perfom_work_det det2
     join ins.ag_rate_type rt2 on det2.ag_rate_type_id = rt2.ag_rate_type_id and rt2.brief = 'QMOPS_0510'
     join ins.ag_perf_work_vol vol2 on vol2.ag_perfom_work_det_id = det2.ag_perfom_work_det_id
     join ins.ag_volume av2 on av2.ag_volume_id = vol2.ag_volume_id
     join ins.ag_npf_volume_det npf on npf.ag_volume_id = av2.ag_volume_id) pf on pf.ag_perfomed_work_act_id = act.ag_perfomed_work_act_id 
                                                                                  and pf.ag_volume_id = av.ag_volume_id
group by act.ag_perfomed_work_act_id, rl.ag_roll_id 
