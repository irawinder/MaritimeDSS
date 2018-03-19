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
  
  fleet.update();
  
  if (bar_right.buttons.get(0).value) {
    fleet.timeIncrement = 0;
    fleet.pauseDuration = 0;
  } else if (bar_right.buttons.get(1).value) {
    fleet.pauseDuration = 2;
    fleet.timeIncrement = 1;
  } else if (bar_right.buttons.get(2).value) {
    fleet.pauseDuration = 0;
    fleet.timeIncrement = 2;
  } 
  
  if (bar_right.sliders.get(0).isDragged) {
    fleet.time = int(bar_right.sliders.get(0).value);
    fleet.pauseDuration = 0;
  } else {
    bar_right.sliders.get(0).value = fleet.time;
  }
  
  if (validConfig) {
    simButton.enabled = true;
  } else {
    simButton.enabled = false;
  }
  
  if (simButton.trigger) {
    fleet.time = 0;
    simButton.trigger = false;
  }
  
  updateBunkerViz();
  
  //zoom3d     = bar_left.sliders.get(0).value;
  //fleet.time = int(bar_left.sliders.get(3).value) - 1;

}

void mousePressed() {
  if (initialized) {
    if (displayMode.equals("flat"))  cam.pressed();
    if (displayMode.equals("globe")) spherePressed();
    bar_left.pressed();
    bar_right.pressed();
    constrainButtons();
    simButton.listen();
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
    simButton.released();
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
      case 'd':
        nextDisplayMode();
        break;
      case 'p':
        if (displayMode.equals("flat")) {
          println("cam.offset.x = " + cam.offset.x);
          println("cam.offset.y = " + cam.offset.y);
          println("cam.zoom = "     + cam.zoom);
          println("cam.rotation = " + cam.rotation);
        }
        break;
    }
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
  
  // Bunkering: Set mutually exclusive buttons to false
  //
  for (int i=0; i<6*3; i+=3) {
    if(bar_left.buttons.get(i+0).hover() && bar_left.buttons.get(i+0).value) {
      bar_left.buttons.get(i+1).value = false;
      bar_left.buttons.get(i+2).value = false;
    } else if(bar_left.buttons.get(i+1).hover() && bar_left.buttons.get(i+1).value) {
      bar_left.buttons.get(i+0).value = false;
      bar_left.buttons.get(i+2).value = false;
    } else if(bar_left.buttons.get(i+2).hover() && bar_left.buttons.get(i+2).value) {
      bar_left.buttons.get(i+1).value = false;
      bar_left.buttons.get(i+0).value = false;
    } 
  }
  
  // Bunkering: Set redundant buttons to false; 1 button is always true
  //
  for (int i=0; i<6*3; i+=3) {
    if(bar_left.buttons.get(i+0).value) {
      if(bar_left.buttons.get(i+1).value) bar_left.buttons.get(i+1).value = false;
      if(bar_left.buttons.get(i+2).value) bar_left.buttons.get(i+2).value = false;
    } else if(bar_left.buttons.get(i+1).value) {
      if(bar_left.buttons.get(i+0).value) bar_left.buttons.get(i+0).value = false;
      if(bar_left.buttons.get(i+2).value) bar_left.buttons.get(i+2).value = false;
    } else if(bar_left.buttons.get(i+2).value) {
      if(bar_left.buttons.get(i+1).value) bar_left.buttons.get(i+1).value = false;
      if(bar_left.buttons.get(i+0).value) bar_left.buttons.get(i+0).value = false;
    } else {
      bar_left.buttons.get(i+0).value = true;
    }
  }
  
  // Check for valid bunker configuration
  //
  boolean valid1 = !bar_left.buttons.get(0).value && !bar_left.buttons.get(3).value;
  boolean valid2 = !bar_left.buttons.get(6).value;
  if (!valid1 && !valid2 && hasLNG) {
    errorBunker = "[LNG SHIPS NEED MORE BUNKERS]\ni.e. Sing. OR Japan+Persian Gulf";
    validBunker = false;
  }
  
  // Check for Valid Configuration
  //
  if (!validBunker || !validFleet) validConfig = false;
  
  // Simulation Speed: Set mutually exclusive buttons to false
  //
  if(bar_right.buttons.get(0).hover() && bar_right.buttons.get(0).value) {
    bar_right.buttons.get(1).value = false;
    bar_right.buttons.get(2).value = false;
  } else if(bar_right.buttons.get(1).hover() && bar_right.buttons.get(1).value) {
    bar_right.buttons.get(0).value = false;
    bar_right.buttons.get(2).value = false;
  } else if(bar_right.buttons.get(2).hover() && bar_right.buttons.get(2).value) {
    bar_right.buttons.get(0).value = false;
    bar_right.buttons.get(1).value = false;
  }
  
  // Simulation Speed: Set redundant buttons to false; 1 button is always true
  //
  if(bar_right.buttons.get(0).value) {
    if(bar_right.buttons.get(1).value) bar_right.buttons.get(1).value = false;
    if(bar_right.buttons.get(2).value) bar_right.buttons.get(2).value = false;
  } else if(bar_right.buttons.get(1).value) {
    if(bar_right.buttons.get(0).value) bar_right.buttons.get(0).value = false;
    if(bar_right.buttons.get(2).value) bar_right.buttons.get(2).value = false;
  } else if(bar_right.buttons.get(2).value) {
    if(bar_right.buttons.get(1).value) bar_right.buttons.get(1).value = false;
    if(bar_right.buttons.get(0).value) bar_right.buttons.get(0).value = false;
  } else {
    bar_right.buttons.get(0).value = true;
  }
}

void updateBunkerViz() {
  // Update bunker visualization
  //
  if (bar_left.buttons.get(0).value) ports.get(0).numBunkers = 0;
  if (bar_left.buttons.get(1).value) ports.get(0).numBunkers = 1;
  if (bar_left.buttons.get(2).value) ports.get(0).numBunkers = 3;
  if (bar_left.buttons.get(3).value) ports.get(1).numBunkers = 0;
  if (bar_left.buttons.get(4).value) ports.get(1).numBunkers = 1;
  if (bar_left.buttons.get(5).value) ports.get(1).numBunkers = 3;
  if (bar_left.buttons.get(6).value) ports.get(2).numBunkers = 0;
  if (bar_left.buttons.get(7).value) ports.get(2).numBunkers = 1;
  if (bar_left.buttons.get(8).value) ports.get(2).numBunkers = 3;
}
