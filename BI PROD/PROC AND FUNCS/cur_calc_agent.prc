create or replace procedure CUR_CALC_AGENT
as
q number;
begin
--ÎÀÂ äåêàáğü PROD
pkg_agent_rate.av_main(2425953,to_date('01.12.2007','dd.mm.yyyy'),1,41,null,q);
commit;
pkg_agent_rate.av_main(2425969,to_date('01.12.2007','dd.mm.yyyy'),2,41,null,q);
commit;
pkg_agent_rate.av_main(2428108,to_date('01.12.2007','dd.mm.yyyy'),3,41,null,q);
commit;
pkg_agent_rate.av_main(2428354,to_date('01.12.2007','dd.mm.yyyy'),4,41,null,q);
commit;
--ÎÀÂ ÿíâàğü PROD
pkg_agent_rate.av_main(3075714,to_date('01.01.2008','dd.mm.yyyy'),1,41,null,q);
commit;
pkg_agent_rate.av_main(3075770,to_date('01.01.2008','dd.mm.yyyy'),2,41,null,q);
commit;
pkg_agent_rate.av_main(3076120,to_date('01.01.2008','dd.mm.yyyy'),3,41,null,q);
commit;
pkg_agent_rate.av_main(3076738,to_date('01.01.2008','dd.mm.yyyy'),4,41,null,q);
commit;
--ÎÀÂ ôåâğàëü PROD
pkg_agent_rate.av_main(3077352,to_date('01.02.2008','dd.mm.yyyy'),1,41,null,q);
commit;
pkg_agent_rate.av_main(3077882,to_date('01.02.2008','dd.mm.yyyy'),2,41,null,q);
commit;
pkg_agent_rate.av_main(3078057,to_date('01.02.2008','dd.mm.yyyy'),3,41,null,q);
commit;
pkg_agent_rate.av_main(3078060,to_date('01.02.2008','dd.mm.yyyy'),4,41,null,q);
commit;
--ÏĞÅÌÈÈ äåêàáğü PROD
pkg_agent_rate.av_main(2561915 ,to_date('01.12.2007','dd.mm.yyyy'),3,43,null,q);
commit;
pkg_agent_rate.av_main(2562097 ,to_date('01.12.2007','dd.mm.yyyy'),4,43,null,q);
commit;
--ÏĞÅÌÈÈ ÿíâàğü PROD
pkg_agent_rate.av_main(3076896 ,to_date('01.01.2008','dd.mm.yyyy'),3,43,null,q);
commit;
pkg_agent_rate.av_main(3077226 ,to_date('01.01.2008','dd.mm.yyyy'),4,43,null,q);
commit;
--ÏĞÅÌÈÈ ôåâğàëü PROD
pkg_agent_rate.av_main(3078067 ,to_date('01.02.2008','dd.mm.yyyy'),3,43,null,q);
commit;
pkg_agent_rate.av_main(3078089 ,to_date('01.02.2008','dd.mm.yyyy'),4,43,null,q);
commit;
end;
/

