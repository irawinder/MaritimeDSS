/*  MaritimeDSS
 *  Ira Winder, ira@mit.edu, 2018
 *  MIT Global Teamwork Lab
 *
 *  Update / Listening Functions (Superficially Isolated from Main.pde)
 *
 *  MIT LICENSE: Copyright 2018 Ira Winder
 *
 *               Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
 *               and associated documentation files (the "Software"), to deal in the Software without restriction, 
 *               including without limitation the rights to use, copy, modify, merge, publish, distribute, 
 *               sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
 *               furnished to do so, subject to the following conditions:
 *
 *               The above copyright notice and this permission notice shall be included in all copies or 
 *               substantial portions of the Software.
 *
 *               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
 *               NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
 *               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
 *               DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
 *               OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
  
void listen() {
  
  // Constrain Buttons to viable solutions
  //
  constrainButtons();
    
  // Trigger the Simulate Button
  //
  if (bar_left.buttons.get(0).trigger) {
    
    boolean log = true;
    recallSim(log);
    
    bar_left.buttons.get(0).trigger = false;
  }
  
  fleet.update();
  
  // Update Simulation Time
  //
  if (bar_right.radios.get(0).value) {
    fleet.timeIncrement = 0;
    fleet.pauseDuration = 0;
  } else if (bar_right.radios.get(1).value) {
    fleet.pauseDuration = 7;
    fleet.timeIncrement = 1;
  } else if (bar_right.radios.get(2).value) {
    fleet.pauseDuration = 1;
    fleet.timeIncrement = 1;
  }
  if (bar_right.sliders.get(0).isDragged) {
    fleet.time = int((bar_right.sliders.get(0).value)/TIME_STEP);
    fleet.pauseDuration = 0;
  } else {
    bar_right.sliders.get(0).value = fleet.time*4+1;
  }
  if (validConfig) {
    bar_left.buttons.get(0).enabled = true;
  } else {
    bar_left.buttons.get(0).enabled = false;
  }
  
  // Update GameResult() Axes
  //
  for (int i=0; i<7; i++) {
    if (bar_right.radios.get(i+ 3).value) result.xIndex = i;
    if (bar_right.radios.get(i+10).value) result.yIndex = i;
  }
  
  updateBunkerViz();
  
  //zoom3d     = bar_left.sliders.get(0).value;
  //fleet.time = int(bar_left.sliders.get(3).value) - 1;

}

void recallSim(boolean log) {
  
  fleet.time = 0;
    
  if (precalculated) {
    
    int caseNumber = caseNumber();
    println("Found Case: " + caseNumber);
    
    if (caseNumber >= 0) {
      String fileName1 = "simulation/result/" + caseNumber + ".csv";
      String fileName2 = "simulation/result/" + caseNumber + "_overall.csv";
      File f1 = new File(dataPath(fileName1));
      File f2 = new File(dataPath(fileName2));
      if (f1.exists()) simResult        = loadTable(fileName1, "header");
      if (f2.exists()) simResultOverall = loadTable(fileName2, "header");
      initFleet();
      initPorts();
      if (log) {
        int time = 60*60*hour() + 60*minute() + second();
        result.addResult(simResultOverall, time);
        int stateNum = result.game.size();
        userLog.addLog("Simulate_" + stateNum);
        userInput.addState(stateNum-1);
        //println(f1.exists(), f2.exists());
      }
    }
    
    showFleet = true;
    
  }
}

void mousePressed() {
  if (initialized) {
    if (displayMode.equals("flat"))  cam.pressed();
    if (displayMode.equals("globe")) spherePressed();
    bar_left.pressed();
    bar_right.pressed();
    constrainButtons();
    result.click();
    if (result.nearest >=0) {
      userInput.loadState(result.nearest);
      userLog.addLog("Recall_Click_" + (result.nearest+1));
      boolean log = false;
      recallSim(log);
    } else {
      userLog.addLog("Mouse Pressed");
    }
  }
}

void mouseDragged() {
  if (initialized) {
    if (displayMode.equals("globe")) sphereDragged();
    constrainButtons();
  }
}

void mouseReleased() {
  if (initialized) {
    if (displayMode.equals("flat"))  cam.moved();
    if (displayMode.equals("globe")) orient = false;
    bar_left.released();
    bar_right.released();
    constrainButtons();
    userLog.addLog("Mouse Released");
    result.release();
  }
}

void mouseMoved() {
  if (initialized) {
    if (displayMode.equals("flat")) cam.moved();
    constrainButtons();
  }
}

void keyPressed() {
  if (initialized) {
    if (displayMode.equals("flat")) cam.moved();
    bar_left.pressed();
    bar_right.pressed();
    
    switch(key) {
      case 'f':
        if (displayMode.equals("flat")) cam.showFrameRate = !cam.showFrameRate;
        break;
      case 'c':
        if (displayMode.equals("flat")) cam.reset();
        break;
      case 'r':
        bar_left.restoreDefault();
        bar_right.restoreDefault();
        break;
      case 'm':
        mapIndex++;
        if (mapIndex >= maps.length) mapIndex = 0;
        map = maps[mapIndex];
        break;
      //case 'd':
      //  nextDisplayMode();
      //  break;
      case 'p':
        if (displayMode.equals("flat")) {
          println("cam.offset.x = " + cam.offset.x);
          println("cam.offset.y = " + cam.offset.y);
          println("cam.zoom = "     + cam.zoom);
          println("cam.rotation = " + cam.rotation);
        }
        break;
      case '+':
        result.zoom += 0.05;
        break;
      case '-':
        result.zoom -= 0.05;
        break;
      case 'z':
        result.zoom = 0.0;
        result.offset_x = 0;
        result.offset_y = 0;
        result.origin_x = 0;
        result.origin_y = 0;
        break;
    }
    
    if (key == CODED) {
      
      boolean changed = false;
      
      if (keyCode == UP) {
        
      } else if (keyCode == DOWN) {
        
      } else if (keyCode == LEFT) {
        result.last();
        changed = true;
      } else if (keyCode == RIGHT) {
        result.next();
        changed = true;
      } 
      
      if (changed) {
        userInput.loadState(result.selected);
        userLog.addLog("Recall_Click_" + (result.selected+1));
        boolean log = false;
        recallSim(log);
      }
      
    }
    
    constrainButtons();
  }
}

boolean barHover() {
  boolean hoverLeft  = mouseX > bar_left.barX  && mouseX < bar_left.barX+bar_left.barW   && mouseY > bar_left.barY  && mouseY < bar_left.barY+bar_left.barH;
  boolean hoverRight = mouseX > bar_right.barX && mouseX < bar_right.barX+bar_right.barW && mouseY > bar_right.barY && mouseY < bar_right.barY+bar_right.barH;
  return hoverLeft || hoverRight;
}

void nextDisplayMode() {
  if(displayMode.equals("flat")) {
    displayMode = "globe";
  } else {
    displayMode = "flat";
  }
}

// Update and Constrain Slider Locations
boolean hasLNG, validBunker, validFleet;
int fleetSize;
String errorFleet = "";
String errorBunker = "";
void constrainButtons() {

  // Pre-set validation parameters
  //
  validConfig = true;
  validBunker = true;
  validFleet  = true;
  if (bar_left.sliders.get(2).value > 0 || bar_left.sliders.get(3).value > 0) {
    hasLNG = true;
  } else {
    hasLNG = false;
  }
  
  // Ships must add up to 20
  //
  int type1 = int(bar_left.sliders.get(0).value);
  int type2 = int(bar_left.sliders.get(1).value);
  int type3 = int(bar_left.sliders.get(2).value);
  int type4 = int(bar_left.sliders.get(3).value);
  fleetSize = type1+type2+type3+type4;
  if (fleetSize != 20) {
    validFleet = false;
    errorFleet = "[FLEET MUST BE 20]";
  }
  
  // Bunkering: Set mutually exclusive radios to false
  //
  for (int i=0; i<6*3; i+=3) {
    if(bar_left.radios.get(i+0).hover() && bar_left.radios.get(i+0).value) {
      bar_left.radios.get(i+1).value = false;
      bar_left.radios.get(i+2).value = false;
    } else if(bar_left.radios.get(i+1).hover() && bar_left.radios.get(i+1).value) {
      bar_left.radios.get(i+0).value = false;
      bar_left.radios.get(i+2).value = false;
    } else if(bar_left.radios.get(i+2).hover() && bar_left.radios.get(i+2).value) {
      bar_left.radios.get(i+1).value = false;
      bar_left.radios.get(i+0).value = false;
    } 
  }
  
  // Bunkering: Set redundant radios to false; 1 button is always true
  //
  for (int i=0; i<6*3; i+=3) {
    if(bar_left.radios.get(i+0).value) {
      if(bar_left.radios.get(i+1).value) bar_left.radios.get(i+1).value = false;
      if(bar_left.radios.get(i+2).value) bar_left.radios.get(i+2).value = false;
    } else if(bar_left.radios.get(i+1).value) {
      if(bar_left.radios.get(i+0).value) bar_left.radios.get(i+0).value = false;
      if(bar_left.radios.get(i+2).value) bar_left.radios.get(i+2).value = false;
    } else if(bar_left.radios.get(i+2).value) {
      if(bar_left.radios.get(i+1).value) bar_left.radios.get(i+1).value = false;
      if(bar_left.radios.get(i+0).value) bar_left.radios.get(i+0).value = false;
    } else {
      if (bar_left.radios.get(i+0).active) bar_left.radios.get(i+0).value = true;
      else if (bar_left.radios.get(i+1).active) bar_left.radios.get(i+1).value = true;
      else if (bar_left.radios.get(i+2).active) bar_left.radios.get(i+2).value = true;
    }
  }
  
  // If LNG present ...
  //
  if (type3 > 0 || type4 > 0) {
    
    // Re-enable all Bunker Buttons ...
    //
    for (int i=0; i<3; i++) {
      bar_left.radios.get(i*3 + 0).enable();
      bar_left.radios.get(i*3 + 1).enable();
      bar_left.radios.get(i*3 + 2).enable();
    }
    
    // Bunkering: Set Method to "Truck to Ship" if there are LNG AND bunk == 0...
    //
    for (int i=0; i<3; i++) {
      if(bar_left.radios.get(i*3).value) {
        bar_left.radios.get(i*3 + 3*3 + 0).value = true;
        bar_left.radios.get(i*3 + 3*3 + 1).disable();
        bar_left.radios.get(i*3 + 3*3 + 2).disable();
      } else {
        bar_left.radios.get(i*3 + 3*3 + 0).enable();
        bar_left.radios.get(i*3 + 3*3 + 1).enable();
        bar_left.radios.get(i*3 + 3*3 + 2).enable();
      }
    }
  
  //If LNG note present ...
  //
  } else {
    
    // Disable "1" and "3" Bunker options for all ports
    //
    for (int i=0; i<3; i++) {
      bar_left.radios.get(i*3 + 0).enable();
      bar_left.radios.get(i*3 + 0).value = true;
      bar_left.radios.get(i*3 + 1).disable();
      bar_left.radios.get(i*3 + 2).disable();
    }
    
    // Bunkering: Set Method to "Ship to Ship" if there are no LNG ...
    //
    for (int i=0; i<3; i++) {
      if(bar_left.radios.get(i*3).value) {
        bar_left.radios.get(i*3 + 3*3 + 0).disable();
        bar_left.radios.get(i*3 + 3*3 + 1).value = true;
        bar_left.radios.get(i*3 + 3*3 + 2).disable();
      } else {
        bar_left.radios.get(i*3 + 3*3 + 0).enable();
        bar_left.radios.get(i*3 + 3*3 + 2).enable();
      }
    }
  
  }
  
  // Check for valid bunker configuration
  //
  boolean valid1 = !bar_left.radios.get(0).value && !bar_left.radios.get(3).value;
  boolean valid2 = !bar_left.radios.get(6).value;
  if (!valid1 && !valid2 && hasLNG) {
    errorBunker = "[LNG SHIPS NEED MORE BUNKERS]\ni.e. Sing. OR Japan+Persian Gulf";
    validBunker = false;
  }
  
  // Check for Valid Configuration
  //
  if (!validBunker || !validFleet || !precalculated) validConfig = false;
  
  // Simulation Speed: Set mutually exclusive radios to false
  //
  if(bar_right.radios.get(0).hover() && bar_right.radios.get(0).value) {
    bar_right.radios.get(1).value = false;
    bar_right.radios.get(2).value = false;
  } else if(bar_right.radios.get(1).hover() && bar_right.radios.get(1).value) {
    bar_right.radios.get(0).value = false;
    bar_right.radios.get(2).value = false;
  } else if(bar_right.radios.get(2).hover() && bar_right.radios.get(2).value) {
    bar_right.radios.get(0).value = false;
    bar_right.radios.get(1).value = false;
  }
  
  // Simulation Speed: Set redundant radios to false; 1 button is always true
  //
  if(bar_right.radios.get(0).value) {
    if(bar_right.radios.get(1).value) bar_right.radios.get(1).value = false;
    if(bar_right.radios.get(2).value) bar_right.radios.get(2).value = false;
  } else if(bar_right.radios.get(1).value) {
    if(bar_right.radios.get(0).value) bar_right.radios.get(0).value = false;
    if(bar_right.radios.get(2).value) bar_right.radios.get(2).value = false;
  } else if(bar_right.radios.get(2).value) {
    if(bar_right.radios.get(1).value) bar_right.radios.get(1).value = false;
    if(bar_right.radios.get(0).value) bar_right.radios.get(0).value = false;
  } else {
    bar_right.radios.get(0).value = true;
  }
  
  // Results View: X-AXIS and Y-Axis - Set mutually exclusive radios to false
  //
  int num = result.name.size();
  int beg = 3;
  for (int i=0; i<num+1; i+=num) {
    for (int j=0; j<num; j++) {
      if(bar_right.radios.get(beg+i+j).hover() && bar_right.radios.get(beg+i+j).value) {
        for (int k=0; k<num; k++) bar_right.radios.get(beg+i+k).value = false;
        bar_right.radios.get(beg+i+j).value = true;
      }
    }
  }
  
  // Results View: X-AXIS and Y-Axis - Set redundant radios to false; 1 button is always true
  //
  for (int i=0; i<num+1; i+=num) {
    boolean found = false;
    for (int j=0; j<num; j++) {
      if(bar_right.radios.get(beg+i+j).value) {
        for (int k=0; k<num; k++) bar_right.radios.get(beg+i+k).value = false;
        bar_right.radios.get(beg+i+j).value = true;
        found = true;
      }
    }
    if (!found) bar_right.radios.get(beg+i).value = true;
  }
  
  caseNumber();
}

void updateBunkerViz() {
  // Update bunker visualization
  //
  if (bar_left.radios.get(0).value) ports.get(0).numBunkers = 0;
  if (bar_left.radios.get(1).value) ports.get(0).numBunkers = 1;
  if (bar_left.radios.get(2).value) ports.get(0).numBunkers = 3;
  if (bar_left.radios.get(3).value) ports.get(1).numBunkers = 0;
  if (bar_left.radios.get(4).value) ports.get(1).numBunkers = 1;
  if (bar_left.radios.get(5).value) ports.get(1).numBunkers = 3;
  if (bar_left.radios.get(6).value) ports.get(2).numBunkers = 0;
  if (bar_left.radios.get(7).value) ports.get(2).numBunkers = 1;
  if (bar_left.radios.get(8).value) ports.get(2).numBunkers = 3;
}

boolean precalculated;
String errorPrecalc = "Sorry! This is a valid solution but we\njust haven't precalculated the results...";
int caseNumber() {
  int index = -1;
  boolean caseFound;
  precalculated = false;
  int ship1, ship2, ship3, ship4; 
  int bunker1, bunker2, bunker3;
  String method1, method2, method3;
  for (int i=0; i<simConfig.getRowCount(); i++) {
    
    caseFound = true;
    
    ship1 = simConfig.getInt(i, 1);
    ship2 = simConfig.getInt(i, 2);
    ship3 = simConfig.getInt(i, 3);
    ship4 = simConfig.getInt(i, 4);
    
    bunker1 = simConfig.getInt   (i,  5);
    method1 = simConfig.getString(i,  6);
    
    bunker2 = simConfig.getInt   (i,  7);
    method2 = simConfig.getString(i,  8);
    
    bunker3 = simConfig.getInt   (i,  9);
    method3 = simConfig.getString(i, 10);
    
    // Ships
    
    if ( int(bar_left.sliders.get(0).value) != ship1 ) caseFound = false;
    if ( int(bar_left.sliders.get(1).value) != ship2 ) caseFound = false;
    if ( int(bar_left.sliders.get(2).value) != ship3 ) caseFound = false;
    if ( int(bar_left.sliders.get(3).value) != ship4 ) caseFound = false;
    
    // Bunkers
    
    if ( bar_left.radios.get(0).value && bunker1 != 0 ) caseFound = false;
    if ( bar_left.radios.get(1).value && bunker1 != 1 ) caseFound = false;
    if ( bar_left.radios.get(2).value && bunker1 != 3 ) caseFound = false;
    
    if ( bar_left.radios.get(3).value && bunker2 != 0 ) caseFound = false;
    if ( bar_left.radios.get(4).value && bunker2 != 1 ) caseFound = false;
    if ( bar_left.radios.get(5).value && bunker2 != 3 ) caseFound = false;
    
    if ( bar_left.radios.get(6).value && bunker3 != 0 ) caseFound = false;
    if ( bar_left.radios.get(7).value && bunker3 != 1 ) caseFound = false;
    if ( bar_left.radios.get(8).value && bunker3 != 3 ) caseFound = false;
    
    // Methods
    
    if ( bar_left.radios.get( 9).value && !method1.equals("Truck to Ship")) caseFound = false;
    if ( bar_left.radios.get(10).value && !method1.equals("Ship to Ship") ) caseFound = false;
    if ( bar_left.radios.get(11).value && !method1.equals("Shore to Ship")) caseFound = false;
    
    if ( bar_left.radios.get(12).value && !method2.equals("Truck to Ship")) caseFound = false;
    if ( bar_left.radios.get(13).value && !method2.equals("Ship to Ship") ) caseFound = false;
    if ( bar_left.radios.get(14).value && !method2.equals("Shore to Ship")) caseFound = false;
    
    if ( bar_left.radios.get(15).value && !method3.equals("Truck to Ship")) caseFound = false;
    if ( bar_left.radios.get(16).value && !method3.equals("Ship to Ship") ) caseFound = false;
    if ( bar_left.radios.get(17).value && !method3.equals("Shore to Ship")) caseFound = false;
    
    if(caseFound) {
      index = simConfig.getInt(i, 0);
      precalculated = true;
      break;
    }
  }
  
  return index;
}
