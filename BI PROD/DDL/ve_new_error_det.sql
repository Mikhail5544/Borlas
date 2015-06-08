create or replace force view ve_new_error_det as
select "N","ID","NAME","BRIEF","SOURCE","ERR"
from ve_error_det v;

