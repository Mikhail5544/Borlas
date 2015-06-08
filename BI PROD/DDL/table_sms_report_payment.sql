create table tmp$_sms_report_pol 
(contact_name varchar2(2000),
 init_name varchar2(100),
 pol_ser varchar2(25),
 pol_num varchar2(25),
 ids number,
 period varchar2(65),
 pol_status varchar2(65),
 department varchar2(2000),
 tel varchar2(65),
 policy_header_id number,
 policy_id number);

  
create table tmp$_sms_report_paym 
(PAYMENT_REGISTER_ITEM_ID number,
 PAYER_FIO varchar2(2000),
 PAYMENT_SUM number,
 PAYMENT_CURRENCY varchar2(25),
 due_date date,
 reg_date date,
 insurer_name varchar2(2000),
 pol_header_id number,
 policy_id number,
 num_ser varchar2(25),
 b_pol_num varchar2(45),
 num_ids number);