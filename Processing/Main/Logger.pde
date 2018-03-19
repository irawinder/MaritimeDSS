class Logger {
  Table log;
  
  Logger() {
    log = new Table();
    log.addColumn("Time");
    log.addColumn("Action");
    log.addColumn(bar_left.sliders.get(0).name);
    log.addColumn(bar_left.sliders.get(1).name);
    log.addColumn(bar_left.sliders.get(2).name);
    log.addColumn(bar_left.sliders.get(3).name);
  }
  
  void addLog(String action) {
    TableRow row = log.addRow();
    row.setString("Time", hour() + ":" + minute() + ":" + second());
    row.setString("Action", action);
    row.setInt(bar_left.sliders.get(0).name, int(bar_left.sliders.get(0).value));
    row.setInt(bar_left.sliders.get(1).name, int(bar_left.sliders.get(1).value));
    row.setInt(bar_left.sliders.get(2).name, int(bar_left.sliders.get(2).value));
    row.setInt(bar_left.sliders.get(3).name, int(bar_left.sliders.get(3).value));
    save();
  }
  
  void save() {
    String fileName = "data//logs/";
    fileName += HOUR + "_" + MINUTE + "_" + SECOND + "_log.csv";
    saveTable(log, fileName);
  }
}
