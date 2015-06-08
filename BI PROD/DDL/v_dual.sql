create or replace force view v_dual as
select "DUMMY" from dual where pkg_rep_utils2.iGetVal('val1') = pkg_rep_utils2.iGetVal('val2');

