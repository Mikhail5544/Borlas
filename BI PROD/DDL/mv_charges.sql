create materialized view MV_CHARGES
refresh force on demand
as
select pol_header_id,
       tplo,
       max(c_num) c_num,
       max(c_num_MSFO) c_num_MSFO,

       sum(ta_nach92) ta_nach92,
       sum(ta_rast92) ta_rast92,
       sum(ta_nach91) ta_nach91,
       sum(ta_rast91) ta_rast91,
       sum(ta_MSFO_nach92) ta_MSFO_nach92,
       sum(ta_MSFO_rast92) ta_MSFO_rast92,
       sum(ta_MSFO_nach91) ta_MSFO_nach91,
       sum(ta_MSFO_rast91) ta_MSFO_rast91,
       sum(ta_APE_nach92) ta_APE_nach92,
       sum(ta_APE_rast92) ta_APE_rast92,
       sum(ta_APE_nach91) ta_APE_nach91,
       sum(ta_APE_rast91) ta_APE_rast91,

       sum(ta_nach92_fund) ta_nach92_fund,
       sum(ta_rast92_fund) ta_rast92_fund,
       sum(ta_nach91_fund) ta_nach91_fund,
       sum(ta_rast91_fund) ta_rast91_fund,
       sum(ta_MSFO_nach92_fund) ta_MSFO_nach92_fund,
       sum(ta_MSFO_rast92_fund) ta_MSFO_rast92_fund,
       sum(ta_MSFO_nach91_fund) ta_MSFO_nach91_fund,
       sum(ta_MSFO_rast91_fund) ta_MSFO_rast91_fund,
       sum(ta_APE_nach92_fund) ta_APE_nach92_fund,
       sum(ta_APE_rast92_fund) ta_APE_rast92_fund,
       sum(ta_APE_nach91_fund) ta_APE_nach91_fund,
       sum(ta_APE_rast91_fund) ta_APE_rast91_fund,

       sum (all_trans_amount)      all_trans_amount,
       sum(all_acc_amount)         all_acc_amount,
       sum (msfo_all_trans_amount) msfo_all_trans_amount,
       sum(msfo_all_acc_amount)    msfo_all_acc_amount,

       max(trans_date1) trans_date1,         max(doc_date1) doc_date1,
       sum(trans_amount1) trans_amount1,     sum(acc_amount1) acc_amount1,
       max(m_trans_date1) m_trans_date1,     max(m_doc_date1) m_doc_date1,
       sum(m_trans_amount1) m_trans_amount1, sum(m_acc_amount1) m_acc_amount1,

       max(trans_date2) trans_date2,         max(doc_date2) doc_date2,
       sum(trans_amount2) trans_amount2,     sum(acc_amount2) acc_amount2,
       max(m_trans_date2) m_trans_date2,     max(m_doc_date2) m_doc_date2,
       sum(m_trans_amount2) m_trans_amount2, sum(m_acc_amount2) m_acc_amount2,

       max(trans_date3) trans_date3,         max(doc_date3) doc_date3,
       sum(trans_amount3) trans_amount3,     sum(acc_amount3) acc_amount3,
       max(m_trans_date3) m_trans_date3,     max(m_doc_date3) m_doc_date3,
       sum(m_trans_amount3) m_trans_amount3, sum(m_acc_amount3) m_acc_amount3,

       max(trans_date4) trans_date4,         max(doc_date4) doc_date4,
       sum(trans_amount4) trans_amount4,     sum(acc_amount4) acc_amount4,
       max(m_trans_date4) m_trans_date4,     max(m_doc_date4) m_doc_date4,
       sum(m_trans_amount4) m_trans_amount4, sum(m_acc_amount4) m_acc_amount4,

       max(trans_date5) trans_date5,         max(doc_date5) doc_date5,
       sum(trans_amount5) trans_amount5,     sum(acc_amount5) acc_amount5,
       max(m_trans_date5) m_trans_date5,     max(m_doc_date5) m_doc_date5,
       sum(m_trans_amount5) m_trans_amount5, sum(m_acc_amount5) m_acc_amount5,

       max(trans_date6) trans_date6,         max(doc_date6) doc_date6,
       sum(trans_amount6) trans_amount6,     sum(acc_amount6) acc_amount6,
       max(m_trans_date6) m_trans_date6,     max(m_doc_date6) m_doc_date6,
       sum(m_trans_amount6) m_trans_amount6, sum(m_acc_amount6) m_acc_amount6,

       max(trans_date7) trans_date7,         max(doc_date7) doc_date7,
       sum(trans_amount7) trans_amount7,     sum(acc_amount7) acc_amount7,
       max(m_trans_date7) m_trans_date7,     max(m_doc_date7) m_doc_date7,
       sum(m_trans_amount7) m_trans_amount7, sum(m_acc_amount7) m_acc_amount7,

       max(trans_date8) trans_date8,         max(doc_date8) doc_date8,
       sum(trans_amount8) trans_amount8,     sum(acc_amount8) acc_amount8,
       max(m_trans_date8) m_trans_date8,     max(m_doc_date8) m_doc_date8,
       sum(m_trans_amount8) m_trans_amount8, sum(m_acc_amount8) m_acc_amount8,

       max(trans_date9) trans_date9,         max(doc_date9) doc_date9,
       sum(trans_amount9) trans_amount9,     sum(acc_amount9) acc_amount9,
       max(m_trans_date9) m_trans_date9,     max(m_doc_date9) m_doc_date9,
       sum(m_trans_amount9) m_trans_amount9, sum(m_acc_amount9) m_acc_amount9,

       max(trans_date10) trans_date10,         max(doc_date10) doc_date10,
       sum(trans_amount10) trans_amount10,     sum(acc_amount10) acc_amount10,
       max(m_trans_date10) m_trans_date10,     max(m_doc_date10) m_doc_date10,
       sum(m_trans_amount10) m_trans_amount10, sum(m_acc_amount10) m_acc_amount10,

       max(trans_date11) trans_date11,         max(doc_date11) doc_date11,
       sum(trans_amount11) trans_amount11,     sum(acc_amount11) acc_amount11,
       max(m_trans_date11) m_trans_date11,     max(m_doc_date11) m_doc_date11,
       sum(m_trans_amount11) m_trans_amount11, sum(m_acc_amount11) m_acc_amount11,

       max(trans_date12) trans_date12,         max(doc_date12) doc_date12,
       sum(trans_amount12) trans_amount12,     sum(acc_amount12) acc_amount12,
       max(m_trans_date12) m_trans_date12,     max(m_doc_date12) m_doc_date12,
       sum(m_trans_amount12) m_trans_amount12, sum(m_acc_amount12) m_acc_amount12,

       max(trans_date13) trans_date13,         max(doc_date13) doc_date13,
       sum(trans_amount13) trans_amount13,     sum(acc_amount13) acc_amount13,
       max(m_trans_date13) m_trans_date13,     max(m_doc_date13) m_doc_date13,
       sum(m_trans_amount13) m_trans_amount13, sum(m_acc_amount13) m_acc_amount13,

       max(trans_date14) trans_date14,         max(doc_date14) doc_date14,
       sum(trans_amount14) trans_amount14,     sum(acc_amount14) acc_amount14,
       max(m_trans_date14) m_trans_date14,     max(m_doc_date14) m_doc_date14,
       sum(m_trans_amount14) m_trans_amount14, sum(m_acc_amount14) m_acc_amount14,

       max(trans_date15) trans_date15,         max(doc_date15) doc_date15,
       sum(trans_amount15) trans_amount15,     sum(acc_amount15) acc_amount15,
       max(m_trans_date15) m_trans_date15,     max(m_doc_date15) m_doc_date15,
       sum(m_trans_amount15) m_trans_amount15, sum(m_acc_amount15) m_acc_amount15,

       max(trans_date16) trans_date16,         max(doc_date16) doc_date16,
       sum(trans_amount16) trans_amount16,     sum(acc_amount16) acc_amount16,
       max(m_trans_date16) m_trans_date16,     max(m_doc_date16) m_doc_date16,
       sum(m_trans_amount16) m_trans_amount16, sum(m_acc_amount16) m_acc_amount16,

       max(trans_date17) trans_date17,         max(doc_date17) doc_date17,
       sum(trans_amount17) trans_amount17,     sum(acc_amount17) acc_amount17,
       max(m_trans_date17) m_trans_date17,     max(m_doc_date17) m_doc_date17,
       sum(m_trans_amount17) m_trans_amount17, sum(m_acc_amount17) m_acc_amount17,

       max(trans_date18) trans_date18,         max(doc_date18) doc_date18,
       sum(trans_amount18) trans_amount18,     sum(acc_amount18) acc_amount18,
       max(m_trans_date18) m_trans_date18,     max(m_doc_date18) m_doc_date18,
       sum(m_trans_amount18) m_trans_amount18, sum(m_acc_amount18) m_acc_amount18,

       max(trans_date19) trans_date19,         max(doc_date19) doc_date19,
       sum(trans_amount19) trans_amount19,     sum(acc_amount19) acc_amount19,
       max(m_trans_date19) m_trans_date19,     max(m_doc_date19) m_doc_date19,
       sum(m_trans_amount19) m_trans_amount19, sum(m_acc_amount19) m_acc_amount19,

       max(trans_date20) trans_date20,         max(doc_date20) doc_date20,
       sum(trans_amount20) trans_amount20,     sum(acc_amount20) acc_amount20,
       max(m_trans_date20) m_trans_date20,     max(m_doc_date20) m_doc_date20,
       sum(m_trans_amount20) m_trans_amount20, sum(m_acc_amount20) m_acc_amount20,

       max(trans_date21) trans_date21,         max(doc_date21) doc_date21,
       sum(trans_amount21) trans_amount21,     sum(acc_amount21) acc_amount21,
       max(m_trans_date21) m_trans_date21,     max(m_doc_date21) m_doc_date21,
       sum(m_trans_amount21) m_trans_amount21, sum(m_acc_amount21) m_acc_amount21,

       max(trans_date22) trans_date22,         max(doc_date22) doc_date22,
       sum(trans_amount22) trans_amount22,     sum(acc_amount22) acc_amount22,
       max(m_trans_date22) m_trans_date22,     max(m_doc_date22) m_doc_date22,
       sum(m_trans_amount22) m_trans_amount22, sum(m_acc_amount22) m_acc_amount22,

       max(trans_date23) trans_date23,         max(doc_date23) doc_date23,
       sum(trans_amount23) trans_amount23,     sum(acc_amount23) acc_amount23,
       max(m_trans_date23) m_trans_date23,     max(m_doc_date23) m_doc_date23,
       sum(m_trans_amount23) m_trans_amount23, sum(m_acc_amount23) m_acc_amount23,

       max(trans_date24) trans_date24,         max(doc_date24) doc_date24,
       sum(trans_amount24) trans_amount24,     sum(acc_amount24) acc_amount24,
       max(m_trans_date24) m_trans_date24,     max(m_doc_date24) m_doc_date24,
       sum(m_trans_amount24) m_trans_amount24, sum(m_acc_amount24) m_acc_amount24,

       max(trans_date25) trans_date25,         max(doc_date25) doc_date25,
       sum(trans_amount25) trans_amount25,     sum(acc_amount25) acc_amount25,
       max(m_trans_date25) m_trans_date25,     max(m_doc_date25) m_doc_date25,
       sum(m_trans_amount25) m_trans_amount25, sum(m_acc_amount25) m_acc_amount25,

       max(trans_date26) trans_date26,         max(doc_date26) doc_date26,
       sum(trans_amount26) trans_amount26,     sum(acc_amount26) acc_amount26,
       max(m_trans_date26) m_trans_date26,     max(m_doc_date26) m_doc_date26,
       sum(m_trans_amount26) m_trans_amount26, sum(m_acc_amount26) m_acc_amount26

from(
select pol_header_id,
       tplo,
       sum(ta_nach92) ta_nach92,
       sum(ta_rast92) ta_rast92,
       sum(ta_nach91) ta_nach91,
       sum(ta_rast91) ta_rast91,
       sum(ta_MSFO_nach92) ta_MSFO_nach92,
       sum(ta_MSFO_rast92) ta_MSFO_rast92,
       sum(ta_MSFO_nach91) ta_MSFO_nach91,
       sum(ta_MSFO_rast91) ta_MSFO_rast91,
       sum(ta_APE_nach92) ta_APE_nach92,
       sum(ta_APE_rast92) ta_APE_rast92,
       sum(ta_APE_nach91) ta_APE_nach91,
       sum(ta_APE_rast91) ta_APE_rast91,

       sum(ta_nach92_fund) ta_nach92_fund,
       sum(ta_rast92_fund) ta_rast92_fund,
       sum(ta_nach91_fund) ta_nach91_fund,
       sum(ta_rast91_fund) ta_rast91_fund,
       sum(ta_MSFO_nach92_fund) ta_MSFO_nach92_fund,
       sum(ta_MSFO_rast92_fund) ta_MSFO_rast92_fund,
       sum(ta_MSFO_nach91_fund) ta_MSFO_nach91_fund,
       sum(ta_MSFO_rast91_fund) ta_MSFO_rast91_fund,
       sum(ta_APE_nach92_fund) ta_APE_nach92_fund,
       sum(ta_APE_rast92_fund) ta_APE_rast92_fund,
       sum(ta_APE_nach91_fund) ta_APE_nach91_fund,
       sum(ta_APE_rast91_fund) ta_APE_rast91_fund,

       case when trans_templ_id = 21  then sum(trans_amount) end all_trans_amount,
       case when trans_templ_id = 21  then sum(acc_amount)   end all_acc_amount,
       case when trans_templ_id = 622 then sum(trans_amount) end msfo_all_trans_amount,
       case when trans_templ_id = 622 then sum(acc_amount)   end msfo_all_acc_amount,

       case when trans_templ_id = 21  then count(trans_id) end c_num,
       case when trans_templ_id = 622 then count(trans_id) end c_num_MSFO,

       max(trans_date1) trans_date1,         max(doc_date1) doc_date1,
       sum(trans_amount1) trans_amount1,     sum(acc_amount1) acc_amount1,
       max(m_trans_date1) m_trans_date1,     max(m_doc_date1) m_doc_date1,
       sum(m_trans_amount1) m_trans_amount1, sum(m_acc_amount1) m_acc_amount1,

       max(trans_date2) trans_date2,         max(doc_date2) doc_date2,
       sum(trans_amount2) trans_amount2,     sum(acc_amount2) acc_amount2,
       max(m_trans_date2) m_trans_date2,     max(m_doc_date2) m_doc_date2,
       sum(m_trans_amount2) m_trans_amount2, sum(m_acc_amount2) m_acc_amount2,

       max(trans_date3) trans_date3,         max(doc_date3) doc_date3,
       sum(trans_amount3) trans_amount3,     sum(acc_amount3) acc_amount3,
       max(m_trans_date3) m_trans_date3,     max(m_doc_date3) m_doc_date3,
       sum(m_trans_amount3) m_trans_amount3, sum(m_acc_amount3) m_acc_amount3,

       max(trans_date4) trans_date4,         max(doc_date4) doc_date4,
       sum(trans_amount4) trans_amount4,     sum(acc_amount4) acc_amount4,
       max(m_trans_date4) m_trans_date4,     max(m_doc_date4) m_doc_date4,
       sum(m_trans_amount4) m_trans_amount4, sum(m_acc_amount4) m_acc_amount4,

       max(trans_date5) trans_date5,         max(doc_date5) doc_date5,
       sum(trans_amount5) trans_amount5,     sum(acc_amount5) acc_amount5,
       max(m_trans_date5) m_trans_date5,     max(m_doc_date5) m_doc_date5,
       sum(m_trans_amount5) m_trans_amount5, sum(m_acc_amount5) m_acc_amount5,

       max(trans_date6) trans_date6,         max(doc_date6) doc_date6,
       sum(trans_amount6) trans_amount6,     sum(acc_amount6) acc_amount6,
       max(m_trans_date6) m_trans_date6,     max(m_doc_date6) m_doc_date6,
       sum(m_trans_amount6) m_trans_amount6, sum(m_acc_amount6) m_acc_amount6,

       max(trans_date7) trans_date7,         max(doc_date7) doc_date7,
       sum(trans_amount7) trans_amount7,     sum(acc_amount7) acc_amount7,
       max(m_trans_date7) m_trans_date7,     max(m_doc_date7) m_doc_date7,
       sum(m_trans_amount7) m_trans_amount7, sum(m_acc_amount7) m_acc_amount7,

       max(trans_date8) trans_date8,         max(doc_date8) doc_date8,
       sum(trans_amount8) trans_amount8,     sum(acc_amount8) acc_amount8,
       max(m_trans_date8) m_trans_date8,     max(m_doc_date8) m_doc_date8,
       sum(m_trans_amount8) m_trans_amount8, sum(m_acc_amount8) m_acc_amount8,

       max(trans_date9) trans_date9,         max(doc_date9) doc_date9,
       sum(trans_amount9) trans_amount9,     sum(acc_amount9) acc_amount9,
       max(m_trans_date9) m_trans_date9,     max(m_doc_date9) m_doc_date9,
       sum(m_trans_amount9) m_trans_amount9, sum(m_acc_amount9) m_acc_amount9,

       max(trans_date10) trans_date10,         max(doc_date10) doc_date10,
       sum(trans_amount10) trans_amount10,     sum(acc_amount10) acc_amount10,
       max(m_trans_date10) m_trans_date10,     max(m_doc_date10) m_doc_date10,
       sum(m_trans_amount10) m_trans_amount10, sum(m_acc_amount10) m_acc_amount10,

       max(trans_date11) trans_date11,         max(doc_date11) doc_date11,
       sum(trans_amount11) trans_amount11,     sum(acc_amount11) acc_amount11,
       max(m_trans_date11) m_trans_date11,     max(m_doc_date11) m_doc_date11,
       sum(m_trans_amount11) m_trans_amount11, sum(m_acc_amount11) m_acc_amount11,

       max(trans_date12) trans_date12,         max(doc_date12) doc_date12,
       sum(trans_amount12) trans_amount12,     sum(acc_amount12) acc_amount12,
       max(m_trans_date12) m_trans_date12,     max(m_doc_date12) m_doc_date12,
       sum(m_trans_amount12) m_trans_amount12, sum(m_acc_amount12) m_acc_amount12,

       max(trans_date13) trans_date13,         max(doc_date13) doc_date13,
       sum(trans_amount13) trans_amount13,     sum(acc_amount13) acc_amount13,
       max(m_trans_date13) m_trans_date13,     max(m_doc_date13) m_doc_date13,
       sum(m_trans_amount13) m_trans_amount13, sum(m_acc_amount13) m_acc_amount13,

       max(trans_date14) trans_date14,         max(doc_date14) doc_date14,
       sum(trans_amount14) trans_amount14,     sum(acc_amount14) acc_amount14,
       max(m_trans_date14) m_trans_date14,     max(m_doc_date14) m_doc_date14,
       sum(m_trans_amount14) m_trans_amount14, sum(m_acc_amount14) m_acc_amount14,

       max(trans_date15) trans_date15,         max(doc_date15) doc_date15,
       sum(trans_amount15) trans_amount15,     sum(acc_amount15) acc_amount15,
       max(m_trans_date15) m_trans_date15,     max(m_doc_date15) m_doc_date15,
       sum(m_trans_amount15) m_trans_amount15, sum(m_acc_amount15) m_acc_amount15,

       max(trans_date16) trans_date16,         max(doc_date16) doc_date16,
       sum(trans_amount16) trans_amount16,     sum(acc_amount16) acc_amount16,
       max(m_trans_date16) m_trans_date16,     max(m_doc_date16) m_doc_date16,
       sum(m_trans_amount16) m_trans_amount16, sum(m_acc_amount16) m_acc_amount16,

       max(trans_date17) trans_date17,         max(doc_date17) doc_date17,
       sum(trans_amount17) trans_amount17,     sum(acc_amount17) acc_amount17,
       max(m_trans_date17) m_trans_date17,     max(m_doc_date17) m_doc_date17,
       sum(m_trans_amount17) m_trans_amount17, sum(m_acc_amount17) m_acc_amount17,

       max(trans_date18) trans_date18,         max(doc_date18) doc_date18,
       sum(trans_amount18) trans_amount18,     sum(acc_amount18) acc_amount18,
       max(m_trans_date18) m_trans_date18,     max(m_doc_date18) m_doc_date18,
       sum(m_trans_amount18) m_trans_amount18, sum(m_acc_amount18) m_acc_amount18,

       max(trans_date19) trans_date19,         max(doc_date19) doc_date19,
       sum(trans_amount19) trans_amount19,     sum(acc_amount19) acc_amount19,
       max(m_trans_date19) m_trans_date19,     max(m_doc_date19) m_doc_date19,
       sum(m_trans_amount19) m_trans_amount19, sum(m_acc_amount19) m_acc_amount19,

       max(trans_date20) trans_date20,         max(doc_date20) doc_date20,
       sum(trans_amount20) trans_amount20,     sum(acc_amount20) acc_amount20,
       max(m_trans_date20) m_trans_date20,     max(m_doc_date20) m_doc_date20,
       sum(m_trans_amount20) m_trans_amount20, sum(m_acc_amount20) m_acc_amount20,

       max(trans_date21) trans_date21,         max(doc_date21) doc_date21,
       sum(trans_amount21) trans_amount21,     sum(acc_amount21) acc_amount21,
       max(m_trans_date21) m_trans_date21,     max(m_doc_date21) m_doc_date21,
       sum(m_trans_amount21) m_trans_amount21, sum(m_acc_amount21) m_acc_amount21,

       max(trans_date22) trans_date22,         max(doc_date22) doc_date22,
       sum(trans_amount22) trans_amount22,     sum(acc_amount22) acc_amount22,
       max(m_trans_date22) m_trans_date22,     max(m_doc_date22) m_doc_date22,
       sum(m_trans_amount22) m_trans_amount22, sum(m_acc_amount22) m_acc_amount22,

       max(trans_date23) trans_date23,         max(doc_date23) doc_date23,
       sum(trans_amount23) trans_amount23,     sum(acc_amount23) acc_amount23,
       max(m_trans_date23) m_trans_date23,     max(m_doc_date23) m_doc_date23,
       sum(m_trans_amount23) m_trans_amount23, sum(m_acc_amount23) m_acc_amount23,

       max(trans_date24) trans_date24,         max(doc_date24) doc_date24,
       sum(trans_amount24) trans_amount24,     sum(acc_amount24) acc_amount24,
       max(m_trans_date24) m_trans_date24,     max(m_doc_date24) m_doc_date24,
       sum(m_trans_amount24) m_trans_amount24, sum(m_acc_amount24) m_acc_amount24,

       max(trans_date25) trans_date25,         max(doc_date25) doc_date25,
       sum(trans_amount25) trans_amount25,     sum(acc_amount25) acc_amount25,
       max(m_trans_date25) m_trans_date25,     max(m_doc_date25) m_doc_date25,
       sum(m_trans_amount25) m_trans_amount25, sum(m_acc_amount25) m_acc_amount25,

       max(trans_date26) trans_date26,         max(doc_date26) doc_date26,
       sum(trans_amount26) trans_amount26,     sum(acc_amount26) acc_amount26,
       max(m_trans_date26) m_trans_date26,     max(m_doc_date26) m_doc_date26,
       sum(m_trans_amount26) m_trans_amount26, sum(m_acc_amount26) m_acc_amount26
 from (
select pol_header_id,
       trans_templ_id,
       tplo,
       trans_date,
       doc_date,
       trans_amount,
       acc_amount,
       trans_id,
       ta_nach92,
       ta_rast92,
       ta_nach91,
       ta_rast91,
       ta_MSFO_nach92,
       ta_MSFO_rast92,
       ta_MSFO_nach91,
       ta_MSFO_rast91,
       ta_APE_nach92,
       ta_APE_rast92,
       ta_APE_nach91,
       ta_APE_rast91,
       ta_nach92_fund,
       ta_rast92_fund,
       ta_nach91_fund,
       ta_rast91_fund,
       ta_MSFO_nach92_fund,
       ta_MSFO_rast92_fund,
       ta_MSFO_nach91_fund,
       ta_MSFO_rast91_fund,
       ta_APE_nach92_fund,
       ta_APE_rast92_fund,
       ta_APE_nach91_fund,
       ta_APE_rast91_fund,
       case when trans_templ_id = 21 and c = 1 then trans_date end trans_date1,
       case when trans_templ_id = 21 and c = 1 then doc_date end doc_date1,
       case when trans_templ_id = 21 and c = 1 then trans_amount end trans_amount1,
       case when trans_templ_id = 21 and c = 1 then acc_amount end acc_amount1,
       case when trans_templ_id = 622 and c = 1 then trans_date end   m_trans_date1,
       case when trans_templ_id = 622 and c = 1 then doc_date end     m_doc_date1,
       case when trans_templ_id = 622 and c = 1 then trans_amount end m_trans_amount1,
       case when trans_templ_id = 622 and c = 1 then acc_amount end   m_acc_amount1,

       case when trans_templ_id = 21 and c = 2 then trans_date end trans_date2,
       case when trans_templ_id = 21 and c = 2 then doc_date end doc_date2,
       case when trans_templ_id = 21 and c = 2 then trans_amount end trans_amount2,
       case when trans_templ_id = 21 and c = 2 then acc_amount end acc_amount2,
       case when trans_templ_id = 622 and c = 2 then trans_date end   m_trans_date2,
       case when trans_templ_id = 622 and c = 2 then doc_date end     m_doc_date2,
       case when trans_templ_id = 622 and c = 2 then trans_amount end m_trans_amount2,
       case when trans_templ_id = 622 and c = 2 then acc_amount end   m_acc_amount2,

       case when trans_templ_id = 21 and c = 3 then trans_date end trans_date3,
       case when trans_templ_id = 21 and c = 3 then doc_date end doc_date3,
       case when trans_templ_id = 21 and c = 3 then trans_amount end trans_amount3,
       case when trans_templ_id = 21 and c = 3 then acc_amount end acc_amount3,
       case when trans_templ_id = 622 and c = 3 then trans_date end   m_trans_date3,
       case when trans_templ_id = 622 and c = 3 then doc_date end     m_doc_date3,
       case when trans_templ_id = 622 and c = 3 then trans_amount end m_trans_amount3,
       case when trans_templ_id = 622 and c = 3 then acc_amount end   m_acc_amount3,

       case when trans_templ_id = 21 and c = 4 then trans_date end trans_date4,
       case when trans_templ_id = 21 and c = 4 then doc_date end doc_date4,
       case when trans_templ_id = 21 and c = 4 then trans_amount end trans_amount4,
       case when trans_templ_id = 21 and c = 4 then acc_amount end acc_amount4,
       case when trans_templ_id = 622 and c = 4 then trans_date end   m_trans_date4,
       case when trans_templ_id = 622 and c = 4 then doc_date end     m_doc_date4,
       case when trans_templ_id = 622 and c = 4 then trans_amount end m_trans_amount4,
       case when trans_templ_id = 622 and c = 4 then acc_amount end   m_acc_amount4,

       case when trans_templ_id = 21 and c = 5 then trans_date end trans_date5,
       case when trans_templ_id = 21 and c = 5 then doc_date end doc_date5,
       case when trans_templ_id = 21 and c = 5 then trans_amount end trans_amount5,
       case when trans_templ_id = 21 and c = 5 then acc_amount end acc_amount5,
       case when trans_templ_id = 622 and c = 5 then trans_date end   m_trans_date5,
       case when trans_templ_id = 622 and c = 5 then doc_date end     m_doc_date5,
       case when trans_templ_id = 622 and c = 5 then trans_amount end m_trans_amount5,
       case when trans_templ_id = 622 and c = 5 then acc_amount end   m_acc_amount5,

       case when trans_templ_id = 21 and c = 6 then trans_date end trans_date6,
       case when trans_templ_id = 21 and c = 6 then doc_date end doc_date6,
       case when trans_templ_id = 21 and c = 6 then trans_amount end trans_amount6,
       case when trans_templ_id = 21 and c = 6 then acc_amount end acc_amount6,
       case when trans_templ_id = 622 and c = 6 then trans_date end   m_trans_date6,
       case when trans_templ_id = 622 and c = 6 then doc_date end     m_doc_date6,
       case when trans_templ_id = 622 and c = 6 then trans_amount end m_trans_amount6,
       case when trans_templ_id = 622 and c = 6 then acc_amount end   m_acc_amount6,

       case when trans_templ_id = 21 and c = 7 then trans_date end trans_date7,
       case when trans_templ_id = 21 and c = 7 then doc_date end doc_date7,
       case when trans_templ_id = 21 and c = 7 then trans_amount end trans_amount7,
       case when trans_templ_id = 21 and c = 7 then acc_amount end acc_amount7,
       case when trans_templ_id = 622 and c = 7 then trans_date end   m_trans_date7,
       case when trans_templ_id = 622 and c = 7 then doc_date end     m_doc_date7,
       case when trans_templ_id = 622 and c = 7 then trans_amount end m_trans_amount7,
       case when trans_templ_id = 622 and c = 7 then acc_amount end   m_acc_amount7,

       case when trans_templ_id = 21 and c = 8 then trans_date end trans_date8,
       case when trans_templ_id = 21 and c = 8 then doc_date end doc_date8,
       case when trans_templ_id = 21 and c = 8 then trans_amount end trans_amount8,
       case when trans_templ_id = 21 and c = 8 then acc_amount end acc_amount8,
       case when trans_templ_id = 622 and c = 8 then trans_date end   m_trans_date8,
       case when trans_templ_id = 622 and c = 8 then doc_date end     m_doc_date8,
       case when trans_templ_id = 622 and c = 8 then trans_amount end m_trans_amount8,
       case when trans_templ_id = 622 and c = 8 then acc_amount end   m_acc_amount8,

       case when trans_templ_id = 21 and c = 9 then trans_date end trans_date9,
       case when trans_templ_id = 21 and c = 9 then doc_date end doc_date9,
       case when trans_templ_id = 21 and c = 9 then trans_amount end trans_amount9,
       case when trans_templ_id = 21 and c = 9 then acc_amount end acc_amount9,
       case when trans_templ_id = 622 and c = 9 then trans_date end   m_trans_date9,
       case when trans_templ_id = 622 and c = 9 then doc_date end     m_doc_date9,
       case when trans_templ_id = 622 and c = 9 then trans_amount end m_trans_amount9,
       case when trans_templ_id = 622 and c = 9 then acc_amount end   m_acc_amount9,

       case when trans_templ_id = 21 and c = 10 then trans_date end trans_date10,
       case when trans_templ_id = 21 and c = 10 then doc_date end doc_date10,
       case when trans_templ_id = 21 and c = 10 then trans_amount end trans_amount10,
       case when trans_templ_id = 21 and c = 10 then acc_amount end acc_amount10,
       case when trans_templ_id = 622 and c = 10 then trans_date end   m_trans_date10,
       case when trans_templ_id = 622 and c = 10 then doc_date end     m_doc_date10,
       case when trans_templ_id = 622 and c = 10 then trans_amount end m_trans_amount10,
       case when trans_templ_id = 622 and c = 10 then acc_amount end   m_acc_amount10,

       case when trans_templ_id = 21 and c = 11 then trans_date end trans_date11,
       case when trans_templ_id = 21 and c = 11 then doc_date end doc_date11,
       case when trans_templ_id = 21 and c = 11 then trans_amount end trans_amount11,
       case when trans_templ_id = 21 and c = 11 then acc_amount end acc_amount11,
       case when trans_templ_id = 622 and c = 11 then trans_date end   m_trans_date11,
       case when trans_templ_id = 622 and c = 11 then doc_date end     m_doc_date11,
       case when trans_templ_id = 622 and c = 11 then trans_amount end m_trans_amount11,
       case when trans_templ_id = 622 and c = 11 then acc_amount end   m_acc_amount11,

       case when trans_templ_id = 21 and c = 12 then trans_date end trans_date12,
       case when trans_templ_id = 21 and c = 12 then doc_date end doc_date12,
       case when trans_templ_id = 21 and c = 12 then trans_amount end trans_amount12,
       case when trans_templ_id = 21 and c = 12 then acc_amount end acc_amount12,
       case when trans_templ_id = 622 and c = 12 then trans_date end   m_trans_date12,
       case when trans_templ_id = 622 and c = 12 then doc_date end     m_doc_date12,
       case when trans_templ_id = 622 and c = 12 then trans_amount end m_trans_amount12,
       case when trans_templ_id = 622 and c = 12 then acc_amount end   m_acc_amount12,

       case when trans_templ_id = 21 and c = 13 then trans_date end trans_date13,
       case when trans_templ_id = 21 and c = 13 then doc_date end doc_date13,
       case when trans_templ_id = 21 and c = 13 then trans_amount end trans_amount13,
       case when trans_templ_id = 21 and c = 13 then acc_amount end acc_amount13,
       case when trans_templ_id = 622 and c = 13 then trans_date end   m_trans_date13,
       case when trans_templ_id = 622 and c = 13 then doc_date end     m_doc_date13,
       case when trans_templ_id = 622 and c = 13 then trans_amount end m_trans_amount13,
       case when trans_templ_id = 622 and c = 13 then acc_amount end   m_acc_amount13,

       case when trans_templ_id = 21 and c = 14 then trans_date end trans_date14,
       case when trans_templ_id = 21 and c = 14 then doc_date end doc_date14,
       case when trans_templ_id = 21 and c = 14 then trans_amount end trans_amount14,
       case when trans_templ_id = 21 and c = 14 then acc_amount end acc_amount14,
       case when trans_templ_id = 622 and c = 14 then trans_date end   m_trans_date14,
       case when trans_templ_id = 622 and c = 14 then doc_date end     m_doc_date14,
       case when trans_templ_id = 622 and c = 14 then trans_amount end m_trans_amount14,
       case when trans_templ_id = 622 and c = 14 then acc_amount end   m_acc_amount14,

       case when trans_templ_id = 21 and c = 15 then trans_date end trans_date15,
       case when trans_templ_id = 21 and c = 15 then doc_date end doc_date15,
       case when trans_templ_id = 21 and c = 15 then trans_amount end trans_amount15,
       case when trans_templ_id = 21 and c = 15 then acc_amount end acc_amount15,
       case when trans_templ_id = 622 and c = 15 then trans_date end   m_trans_date15,
       case when trans_templ_id = 622 and c = 15 then doc_date end     m_doc_date15,
       case when trans_templ_id = 622 and c = 15 then trans_amount end m_trans_amount15,
       case when trans_templ_id = 622 and c = 15 then acc_amount end   m_acc_amount15,

       case when trans_templ_id = 21 and c = 16 then trans_date end trans_date16,
       case when trans_templ_id = 21 and c = 16 then doc_date end doc_date16,
       case when trans_templ_id = 21 and c = 16 then trans_amount end trans_amount16,
       case when trans_templ_id = 21 and c = 16 then acc_amount end acc_amount16,
       case when trans_templ_id = 622 and c = 16 then trans_date end   m_trans_date16,
       case when trans_templ_id = 622 and c = 16 then doc_date end     m_doc_date16,
       case when trans_templ_id = 622 and c = 16 then trans_amount end m_trans_amount16,
       case when trans_templ_id = 622 and c = 16 then acc_amount end   m_acc_amount16,

       case when trans_templ_id = 21 and c = 17 then trans_date end trans_date17,
       case when trans_templ_id = 21 and c = 17 then doc_date end doc_date17,
       case when trans_templ_id = 21 and c = 17 then trans_amount end trans_amount17,
       case when trans_templ_id = 21 and c = 17 then acc_amount end acc_amount17,
       case when trans_templ_id = 622 and c = 17 then trans_date end   m_trans_date17,
       case when trans_templ_id = 622 and c = 17 then doc_date end     m_doc_date17,
       case when trans_templ_id = 622 and c = 17 then trans_amount end m_trans_amount17,
       case when trans_templ_id = 622 and c = 17 then acc_amount end   m_acc_amount17,

       case when trans_templ_id = 21 and c = 18 then trans_date end trans_date18,
       case when trans_templ_id = 21 and c = 18 then doc_date end doc_date18,
       case when trans_templ_id = 21 and c = 18 then trans_amount end trans_amount18,
       case when trans_templ_id = 21 and c = 18 then acc_amount end acc_amount18,
       case when trans_templ_id = 622 and c = 18 then trans_date end   m_trans_date18,
       case when trans_templ_id = 622 and c = 18 then doc_date end     m_doc_date18,
       case when trans_templ_id = 622 and c = 18 then trans_amount end m_trans_amount18,
       case when trans_templ_id = 622 and c = 18 then acc_amount end   m_acc_amount18,

       case when trans_templ_id = 21 and c = 19 then trans_date end trans_date19,
       case when trans_templ_id = 21 and c = 19 then doc_date end doc_date19,
       case when trans_templ_id = 21 and c = 19 then trans_amount end trans_amount19,
       case when trans_templ_id = 21 and c = 19 then acc_amount end acc_amount19,
       case when trans_templ_id = 622 and c = 19 then trans_date end   m_trans_date19,
       case when trans_templ_id = 622 and c = 19 then doc_date end     m_doc_date19,
       case when trans_templ_id = 622 and c = 19 then trans_amount end m_trans_amount19,
       case when trans_templ_id = 622 and c = 19 then acc_amount end   m_acc_amount19,

       case when trans_templ_id = 21 and c = 20 then trans_date end trans_date20,
       case when trans_templ_id = 21 and c = 20 then doc_date end doc_date20,
       case when trans_templ_id = 21 and c = 20 then trans_amount end trans_amount20,
       case when trans_templ_id = 21 and c = 20 then acc_amount end acc_amount20,
       case when trans_templ_id = 622 and c = 20 then trans_date end   m_trans_date20,
       case when trans_templ_id = 622 and c = 20 then doc_date end     m_doc_date20,
       case when trans_templ_id = 622 and c = 20 then trans_amount end m_trans_amount20,
       case when trans_templ_id = 622 and c = 20 then acc_amount end   m_acc_amount20,

       case when trans_templ_id = 21 and c = 21 then trans_date end trans_date21,
       case when trans_templ_id = 21 and c = 21 then doc_date end doc_date21,
       case when trans_templ_id = 21 and c = 21 then trans_amount end trans_amount21,
       case when trans_templ_id = 21 and c = 21 then acc_amount end acc_amount21,
       case when trans_templ_id = 622 and c = 21 then trans_date end   m_trans_date21,
       case when trans_templ_id = 622 and c = 21 then doc_date end     m_doc_date21,
       case when trans_templ_id = 622 and c = 21 then trans_amount end m_trans_amount21,
       case when trans_templ_id = 622 and c = 21 then acc_amount end   m_acc_amount21,

       case when trans_templ_id = 21 and c = 22 then trans_date end trans_date22,
       case when trans_templ_id = 21 and c = 22 then doc_date end doc_date22,
       case when trans_templ_id = 21 and c = 22 then trans_amount end trans_amount22,
       case when trans_templ_id = 21 and c = 22 then acc_amount end acc_amount22,
       case when trans_templ_id = 622 and c = 22 then trans_date end   m_trans_date22,
       case when trans_templ_id = 622 and c = 22 then doc_date end     m_doc_date22,
       case when trans_templ_id = 622 and c = 22 then trans_amount end m_trans_amount22,
       case when trans_templ_id = 622 and c = 22 then acc_amount end   m_acc_amount22,

       case when trans_templ_id = 21 and c = 23 then trans_date end trans_date23,
       case when trans_templ_id = 21 and c = 23 then doc_date end doc_date23,
       case when trans_templ_id = 21 and c = 23 then trans_amount end trans_amount23,
       case when trans_templ_id = 21 and c = 23 then acc_amount end acc_amount23,
       case when trans_templ_id = 622 and c = 23 then trans_date end   m_trans_date23,
       case when trans_templ_id = 622 and c = 23 then doc_date end     m_doc_date23,
       case when trans_templ_id = 622 and c = 23 then trans_amount end m_trans_amount23,
       case when trans_templ_id = 622 and c = 23 then acc_amount end   m_acc_amount23,

       case when trans_templ_id = 21 and c = 24 then trans_date end trans_date24,
       case when trans_templ_id = 21 and c = 24 then doc_date end doc_date24,
       case when trans_templ_id = 21 and c = 24 then trans_amount end trans_amount24,
       case when trans_templ_id = 21 and c = 24 then acc_amount end acc_amount24,
       case when trans_templ_id = 622 and c = 24 then trans_date end   m_trans_date24,
       case when trans_templ_id = 622 and c = 24 then doc_date end     m_doc_date24,
       case when trans_templ_id = 622 and c = 24 then trans_amount end m_trans_amount24,
       case when trans_templ_id = 622 and c = 24 then acc_amount end   m_acc_amount24,

       case when trans_templ_id = 21 and c = 25 then trans_date end trans_date25,
       case when trans_templ_id = 21 and c = 25 then doc_date end doc_date25,
       case when trans_templ_id = 21 and c = 25 then trans_amount end trans_amount25,
       case when trans_templ_id = 21 and c = 25 then acc_amount end acc_amount25,
       case when trans_templ_id = 622 and c = 25 then trans_date end   m_trans_date25,
       case when trans_templ_id = 622 and c = 25 then doc_date end     m_doc_date25,
       case when trans_templ_id = 622 and c = 25 then trans_amount end m_trans_amount25,
       case when trans_templ_id = 622 and c = 25 then acc_amount end   m_acc_amount25,

       case when trans_templ_id = 21 and c = 26 then trans_date end trans_date26,
       case when trans_templ_id = 21 and c = 26 then doc_date end doc_date26,
       case when trans_templ_id = 21 and c = 26 then trans_amount end trans_amount26,
       case when trans_templ_id = 21 and c = 26 then acc_amount end acc_amount26,
       case when trans_templ_id = 622 and c = 26 then trans_date end   m_trans_date26,
       case when trans_templ_id = 622 and c = 26 then doc_date end     m_doc_date26,
       case when trans_templ_id = 622 and c = 26 then trans_amount end m_trans_amount26,
       case when trans_templ_id = 622 and c = 26 then acc_amount end   m_acc_amount26

 from (
SELECT pp.pol_header_id,
       t.trans_templ_id,
       case when t.trans_templ_id = 21 and rur_amount > 0 and trans_doc_date >= '01.01.2010' then rur_amount else 0 end ta_nach92,
       case when t.trans_templ_id = 21 and rur_amount < 0 and trans_doc_date >= '01.01.2010' then rur_amount else 0 end ta_rast92,
       case when t.trans_templ_id = 21 and rur_amount > 0 and trans_doc_date < '01.01.2010' then rur_amount else 0 end ta_nach91,
       case when t.trans_templ_id = 21 and rur_amount < 0 and trans_doc_date < '01.01.2010' then rur_amount else 0 end ta_rast91,
      case when t.trans_templ_id = 622 and rur_amount > 0 and trans_doc_date >= '01.01.2010' then rur_amount else 0 end ta_MSFO_nach92,
      case when t.trans_templ_id = 622 and rur_amount < 0 and trans_doc_date >= '01.01.2010' then rur_amount else 0 end ta_MSFO_rast92,
      case when t.trans_templ_id = 622 and rur_amount > 0 and trans_doc_date < '01.01.2010' then rur_amount else 0 end ta_MSFO_nach91,
      case when t.trans_templ_id = 622 and rur_amount < 0 and trans_doc_date < '01.01.2010' then rur_amount else 0 end ta_MSFO_rast91,
       case when t.trans_templ_id = 621 and rur_amount > 0 and trans_doc_date >= '01.01.2010' then rur_amount else 0 end ta_APE_nach92,
       case when t.trans_templ_id = 621 and rur_amount < 0 and trans_doc_date >= '01.01.2010' then rur_amount else 0 end ta_APE_rast92,
       case when t.trans_templ_id = 621 and rur_amount > 0 and trans_doc_date < '01.01.2010' then rur_amount else 0 end ta_APE_nach91,
       case when t.trans_templ_id = 621 and rur_amount < 0 and trans_doc_date < '01.01.2010' then rur_amount else 0 end ta_APE_rast91,

       case when t.trans_templ_id = 21 and doc_amount > 0 and trans_doc_date >= '01.01.2010'
            then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
            else 0 end ta_nach92_fund,
       case when t.trans_templ_id = 21 and doc_amount < 0 and trans_doc_date >= '01.01.2010'
            then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
            else 0 end ta_rast92_fund,
       case when t.trans_templ_id = 21 and doc_amount > 0 and trans_doc_date < '01.01.2010'
            then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
            else 0 end ta_nach91_fund,
       case when t.trans_templ_id = 21 and doc_amount < 0 and trans_doc_date < '01.01.2010'
            then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
            else 0 end ta_rast91_fund,
      case when t.trans_templ_id = 622 and doc_amount > 0 and trans_doc_date >= '01.01.2010'
           then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
           else 0 end ta_MSFO_nach92_fund,
      case when t.trans_templ_id = 622 and doc_amount < 0 and trans_doc_date >= '01.01.2010'
           then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
           else 0 end ta_MSFO_rast92_fund,
      case when t.trans_templ_id = 622 and doc_amount > 0 and trans_doc_date < '01.01.2010'
           then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
           else 0 end ta_MSFO_nach91_fund,
      case when t.trans_templ_id = 622 and doc_amount < 0 and trans_doc_date < '01.01.2010'
           then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
           else 0 end ta_MSFO_rast91_fund,
       case when t.trans_templ_id = 621 and doc_amount > 0 and trans_doc_date >= '01.01.2010'
            then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
            else 0 end ta_APE_nach92_fund,
       case when t.trans_templ_id = 621 and doc_amount < 0 and trans_doc_date >= '01.01.2010'
            then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
            else 0 end ta_APE_rast92_fund,
       case when t.trans_templ_id = 621 and doc_amount > 0 and trans_doc_date < '01.01.2010'
            then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
            else 0 end ta_APE_nach91_fund,
       case when t.trans_templ_id = 621 and doc_amount < 0 and trans_doc_date < '01.01.2010'
            then case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
                      then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100 else t.doc_amount end
            else 0 end ta_APE_rast91_fund,

       t.rur_amount trans_amount,
       case when ph.fund_id <> 122 and t.doc_fund = 'RUR'
            then round(t.doc_amount/decode(ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date),0,1,
                                                     ins.acc_new.Get_Rate_By_Id(1, ph.fund_id, t.trans_date))*100)/100
            else t.doc_amount end acc_amount,
       t.risk_type_id tplo,
       --t.p_cover_id,
       t.trans_id,
       t.trans_date,
       t.trans_doc_date doc_date,
       row_number() over (partition by ph.policy_header_id, t.doc_fund, t.trans_templ_id, t.risk_type_id
                              order by t.trans_date, t.trans_id) c
  FROM INS_DWH.FC_TRANS t,
       p_policy pp,
       p_pol_header ph,
       trans_templ  tt
 WHERE tt.trans_templ_id = t.trans_templ_id
   and tt.brief in ('Íà÷Ïğåìèÿ',
                    'ÌÑÔÎÏğåìèÿÍà÷APE',
                    'ÌÑÔÎÏğåìèÿÍà÷')
   AND ph.policy_header_id = t.pol_header_id
   and pp.policy_id = ph.policy_id
   --and ph.policy_header_id =808354---in --(11460283,9569638,9693368,9695390,7474207,7950931,8174629,13515172,13158141,13150877, 6013406)
   AND t.trans_date between '01.01.2010' and '31.05.2010'
   AND nvl(pp.is_group_flag,0) = 0

)
)
group by pol_header_id,
         tplo,
         trans_templ_id
)
group by pol_header_id,
         tplo;

