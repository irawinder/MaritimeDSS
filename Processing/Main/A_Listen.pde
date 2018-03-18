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
    fleet.TIME_PAUSE = 2;
    fleet.TIME_INCREMENT = 1;
  } else if (bar_right.buttons.get(1).value) {
    fleet.TIME_PAUSE = 0;
    fleet.TIME_INCREMENT = 1;
  } else if (bar_right.buttons.get(2).value) {
    fleet.TIME_PAUSE = 0;
    fleet.TIME_INCREMENT = 2;
  }
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
  }
}

void mouseDragged() {
  if (initialized) {
    if (displayMode.equals("globe")) sphereDragged();
  }
}

void mouseReleased() {
  if (initialized) {
    if (displayMode.equals("flat")) cam.moved();
    bar_left.released();
    bar_right.released();
    orient = false;
  }
}

void mouseMoved() {
  if (initialized) {
    if (displayMode.equals("flat")) cam.moved();
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

void constrainButtons() {
  
  // Set mutually exclusive buttons to false
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
  
  // Set redundant buttons to false; 1 button is always true
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
  
  // Set mutually exclusive buttons to false
  //
  int i=0;
  if(bar_right.buttons.get(i+0).hover() && bar_right.buttons.get(i+0).value) {
    bar_right.buttons.get(i+1).value = false;
    bar_right.buttons.get(i+2).value = false;
  } else if(bar_right.buttons.get(i+1).hover() && bar_right.buttons.get(i+1).value) {
    bar_right.buttons.get(i+0).value = false;
    bar_right.buttons.get(i+2).value = false;
  } else if(bar_right.buttons.get(i+2).hover() && bar_right.buttons.get(i+2).value) {
    bar_right.buttons.get(i+1).value = false;
    bar_right.buttons.get(i+0).value = false;
  } 
  
  // Set redundant buttons to false; 1 button is always true
  //
  if(bar_right.buttons.get(i+0).value) {
    if(bar_right.buttons.get(i+1).value) bar_right.buttons.get(i+1).value = false;
    if(bar_right.buttons.get(i+2).value) bar_right.buttons.get(i+2).value = false;
  } else if(bar_right.buttons.get(i+1).value) {
    if(bar_right.buttons.get(i+0).value) bar_right.buttons.get(i+0).value = false;
    if(bar_right.buttons.get(i+2).value) bar_right.buttons.get(i+2).value = false;
  } else if(bar_right.buttons.get(i+2).value) {
    if(bar_right.buttons.get(i+1).value) bar_right.buttons.get(i+1).value = false;
    if(bar_right.buttons.get(i+0).value) bar_right.buttons.get(i+0).value = false;
  } else {
    bar_right.buttons.get(i+0).value = true;
  }
}
