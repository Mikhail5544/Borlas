sqlldr.exe userid=ins/ii@INS  control=%1%2.ctl  data=%1%2.csv skip="1"
del %1%2.ctl
del %1%2.csv