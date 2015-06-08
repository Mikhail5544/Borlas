CREATE OR REPLACE PACKAGE runstats_pkg AS
  PROCEDURE rs_start;
  PROCEDURE rs_middle;
  PROCEDURE rs_stop(p_difference_threshold IN NUMBER DEFAULT 0);
END;
/
CREATE OR REPLACE PACKAGE BODY runstats_pkg AS

  g_start NUMBER;
  g_run1  NUMBER;
  g_run2  NUMBER;

  PROCEDURE rs_start IS
  BEGIN
    DELETE FROM run_stats;
  
    INSERT INTO run_stats
      SELECT 'before'
            ,stats.*
        FROM stats;
  
    g_start := dbms_utility.get_time;
  END;

  PROCEDURE rs_middle IS
  BEGIN
    g_run1 := (dbms_utility.get_time - g_start);
  
    INSERT INTO run_stats
      SELECT 'after 1'
            ,stats.*
        FROM stats;
    g_start := dbms_utility.get_time;
  
  END;

  PROCEDURE rs_stop(p_difference_threshold IN NUMBER DEFAULT 0) IS
  BEGIN
    g_run2 := (dbms_utility.get_time - g_start);
  
    dbms_output.put_line('Run1 ran in ' || g_run1 || ' hsecs');
    dbms_output.put_line('Run2 ran in ' || g_run2 || ' hsecs');
    dbms_output.put_line('run 1 ran in ' || ROUND(g_run1 / g_run2 * 100, 2) || '% of the time');
    dbms_output.put_line(chr(9));
  
    INSERT INTO run_stats
      SELECT 'after 2'
            ,stats.*
        FROM stats;
  
    dbms_output.put_line(rpad('Name', 30) || lpad('Run1', 12) || lpad('Run2', 12) || lpad('Diff', 12));
  
    FOR x IN (SELECT rpad(a.name, 30) || to_char(b.value - a.value, '999,999,999') ||
                     to_char(c.value - b.value, '999,999,999') ||
                     to_char(((c.value - b.value) - (b.value - a.value)), '999,999,999') data
                FROM run_stats a
                    ,run_stats b
                    ,run_stats c
               WHERE a.name = b.name
                 AND b.name = c.name
                 AND a.runid = 'before'
                 AND b.runid = 'after 1'
                 AND c.runid = 'after 2'
                    -- and (c.value-a.value) > 0
                 AND abs((c.value - b.value) - (b.value - a.value)) > p_difference_threshold
               ORDER BY abs((c.value - b.value) - (b.value - a.value)))
    LOOP
      dbms_output.put_line(x.data);
    END LOOP;
  
    dbms_output.put_line(chr(9));
    dbms_output.put_line('Run1 latches total versus runs -- difference and pct');
    dbms_output.put_line(lpad('Run1', 12) || lpad('Run2', 12) || lpad('Diff', 12) || lpad('Pct', 10));
  
    FOR x IN (SELECT to_char(run1, '999,999,999') || to_char(run2, '999,999,999') ||
                     to_char(diff, '999,999,999') || to_char(ROUND(run1 / run2 * 100, 2), '99,999.99') || '%' data
                FROM (SELECT SUM(b.value - a.value) run1
                            ,SUM(c.value - b.value) run2
                            ,SUM((c.value - b.value) - (b.value - a.value)) diff
                        FROM run_stats a
                            ,run_stats b
                            ,run_stats c
                       WHERE a.name = b.name
                         AND b.name = c.name
                         AND a.runid = 'before'
                         AND b.runid = 'after 1'
                         AND c.runid = 'after 2'
                         AND a.name LIKE 'LATCH%'))
    LOOP
      dbms_output.put_line(x.data);
    END LOOP;
  END;

END;
/
