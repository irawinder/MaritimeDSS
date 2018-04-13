class Logger {
  Table log;
  String port1, port2, port3;
  
  Logger() {
    log = new Table();
    log.addColumn("Time");
    log.addColumn("Action");
    log.addColumn("Mouse X");
    log.addColumn("Mouse Y");
    log.addColumn("Screen Width");
    log.addColumn("Screen Height");
    
    //Ships
    log.addColumn(bar_left.sliders.get(0).name);
    log.addColumn(bar_left.sliders.get(1).name);
    log.addColumn(bar_left.sliders.get(2).name);
    log.addColumn(bar_left.sliders.get(3).name);
    
    //Port 1
    port1 = "Persian Gulf_";
    log.addColumn(port1 + bar_left.radios.get(0).name);
    log.addColumn(port1 + bar_left.radios.get(1).name);
    log.addColumn(port1 + bar_left.radios.get(2).name);
    log.addColumn(port1 + bar_left.radios.get(9).name);
    log.addColumn(port1 + bar_left.radios.get(10).name);
    log.addColumn(port1 + bar_left.radios.get(11).name);
    
    //Port 2
    port2 = "Japan_";
    log.addColumn(port2 + bar_left.radios.get(3).name);
    log.addColumn(port2 + bar_left.radios.get(4).name);
    log.addColumn(port2 + bar_left.radios.get(5).name);
    log.addColumn(port2 + bar_left.radios.get(12).name);
    log.addColumn(port2 + bar_left.radios.get(13).name);
    log.addColumn(port2 + bar_left.radios.get(14).name);
    
    //Port 3
    port3 = "Singapore_";
    log.addColumn(port3 + bar_left.radios.get(6).name);
    log.addColumn(port3 + bar_left.radios.get(7).name);
    log.addColumn(port3 + bar_left.radios.get(8).name);
    log.addColumn(port3 + bar_left.radios.get(15).name);
    log.addColumn(port3 + bar_left.radios.get(16).name);
    log.addColumn(port3 + bar_left.radios.get(17).name);
    
    //Timing
    log.addColumn(bar_right.sliders.get(0).name);
    log.addColumn(bar_right.radios.get(0).name);
    log.addColumn(bar_right.radios.get(1).name);
    log.addColumn(bar_right.radios.get(2).name);
    
    //XY AXIS
    log.addColumn("X_AXIS");
    log.addColumn("Y_AXIS");
    
    //SCORES ("-ILITIES")
    for(String n: result.name) {
      log.addColumn(n);
    }
  }
  
  void addLog(String action) {
    TableRow row = log.addRow();
    row.setString("Time", hour() + ":" + minute() + ":" + second());
    row.setString("Action", action);
    row.setInt("Mouse X", mouseX);
    row.setInt("Mouse Y", mouseY);
    row.setInt("Screen Width",  width);
    row.setInt("Screen Height", height);
    
    // Ships
    row.setInt(bar_left.sliders.get(0).name, int(bar_left.sliders.get(0).value));
    row.setInt(bar_left.sliders.get(1).name, int(bar_left.sliders.get(1).value));
    row.setInt(bar_left.sliders.get(2).name, int(bar_left.sliders.get(2).value));
    row.setInt(bar_left.sliders.get(3).name, int(bar_left.sliders.get(3).value));
    
    //Port1
    row.setString(port1 + bar_left.radios.get( 0).name, "" + bar_left.radios.get( 0).value);
    row.setString(port1 + bar_left.radios.get( 1).name, "" + bar_left.radios.get( 1).value);
    row.setString(port1 + bar_left.radios.get( 2).name, "" + bar_left.radios.get( 2).value);
    row.setString(port1 + bar_left.radios.get( 9).name, "" + bar_left.radios.get( 9).value);
    row.setString(port1 + bar_left.radios.get(10).name, "" + bar_left.radios.get(10).value);
    row.setString(port1 + bar_left.radios.get(11).name, "" + bar_left.radios.get(11).value);
    
    //Port2
    row.setString(port2 + bar_left.radios.get( 3).name, "" + bar_left.radios.get( 3).value);
    row.setString(port2 + bar_left.radios.get( 4).name, "" + bar_left.radios.get( 4).value);
    row.setString(port2 + bar_left.radios.get( 5).name, "" + bar_left.radios.get( 5).value);
    row.setString(port2 + bar_left.radios.get(12).name, "" + bar_left.radios.get(12).value);
    row.setString(port2 + bar_left.radios.get(13).name, "" + bar_left.radios.get(13).value);
    row.setString(port2 + bar_left.radios.get(14).name, "" + bar_left.radios.get(14).value);
    
    //Port3
    row.setString(port3 + bar_left.radios.get( 6).name, "" + bar_left.radios.get( 6).value);
    row.setString(port3 + bar_left.radios.get( 7).name, "" + bar_left.radios.get( 7).value);
    row.setString(port3 + bar_left.radios.get( 8).name, "" + bar_left.radios.get( 8).value);
    row.setString(port3 + bar_left.radios.get(15).name, "" + bar_left.radios.get(15).value);
    row.setString(port3 + bar_left.radios.get(16).name, "" + bar_left.radios.get(16).value);
    row.setString(port3 + bar_left.radios.get(17).name, "" + bar_left.radios.get(17).value);
    
    //Timing
    row.setInt(   bar_right.sliders.get(0).name,  int(bar_right.sliders.get(0).value));
    row.setString(bar_right.radios.get(0).name, "" + bar_right.radios.get(0).value);
    row.setString(bar_right.radios.get(1).name, "" + bar_right.radios.get(1).value);
    row.setString(bar_right.radios.get(2).name, "" + bar_right.radios.get(2).value);
    
    //XY AXIS
    row.setString("X_AXIS", result.name.get(result.xIndex));
    row.setString("Y_AXIS", result.name.get(result.yIndex));
    
    //SCORES
    for(int i=0; i<result.name.size(); i++) {
      float score;
      if (result.game.size() > 0) {
        score = result.game.get(result.game.size()-1).value.get(i);
        row.setFloat(result.name.get(i), score);
      }  
    }
    
    save();
  }
  
  void save() {
    String fileName = "data/logs/";
    fileName += HOUR + "_" + MINUTE + "_" + SECOND + "_log.csv";
    saveTable(log, fileName);
  }
}

class InputState {
  
  Table state;
  
  InputState() {
    state = new Table();
    state.addColumn("Simulation");
    for (ControlSlider s: bar_left.sliders) state.addColumn(s.name);
    for (RadioButton   b: bar_left.radios ) state.addColumn(b.name);
  }
  
  void addState(int index) {
    
    TableRow row = state.addRow();
    
    row.setInt("Simulation", index);
    
    int numS = bar_left.sliders.size();
    int numR = bar_left.radios.size();
    
    for (int i=0; i<numS; i++) {
      ControlSlider s = bar_left.sliders.get(i);
      row.setFloat(i+1, s.value);
    }
    
    for (int i=0; i<numR; i++) {
      RadioButton b = bar_left.radios.get(i);
      row.setInt(i+numS+1, int(b.value));
    }
    
    save();
  }
  
  void loadState(int index) {
    
    TableRow row = state.findRow("" + index, "Simulation");
    
    int numS = bar_left.sliders.size();
    int numR = bar_left.radios.size();
    
    for (int i=0; i<numS; i++) {
      ControlSlider s = bar_left.sliders.get(i);
      s.value = row.getFloat(i+1);
    }
    
    for (int i=0; i<numR; i++) {
      RadioButton b = bar_left.radios.get(i);
      b.value = boolean( row.getInt(i+numS+1) );
    }
  }
  
  void save() {
    String fileName = "data/logs/";
    fileName += HOUR + "_" + MINUTE + "_" + SECOND + "_state.csv";
    saveTable(state, fileName);
  }
}
