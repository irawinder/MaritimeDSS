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
  
  //zoom3d     = bar_left.sliders.get(0).value;
  //fleet.time = int(bar_left.sliders.get(3).value) - 1;

}

int x_0, y_0;
float rotate3d_init, pitch3d_init;
boolean orient;
void mousePressed() {
  if (initialized) {
    cam.pressed();
    bar_left.pressed();
    bar_right.pressed();
    if (!barHover()) {
      x_0 = mouseX;
      y_0 = mouseY;
      rotate3d_init = rotate3d;
      pitch3d_init = pitch3d;
      orient = true;
    }
  }
}

void mouseDragged() {
  if (initialized) {
    if (orient) {
      rotate3d = rotate3d_init + (mouseX - x_0)/5.0;
      pitch3d  = pitch3d_init  + (mouseY - y_0)/5.0;
    }
  }
}

void mouseReleased() {
  if (initialized) {
    cam.moved();
    bar_left.released();
    bar_right.released();
    orient = false;
  }
}

void mouseMoved() {
  if (initialized) {
    cam.moved();
  }
}

void keyPressed() {
  if (initialized) {
    cam.moved();
    bar_left.pressed();
    bar_right.pressed();
    
    switch(key) {
      case 'f':
        cam.showFrameRate = !cam.showFrameRate;
        break;
      case 'c':
        cam.reset();
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
      case 'p':
        println("cam.offset.x = " + cam.offset.x);
        println("cam.offset.y = " + cam.offset.y);
        println("cam.zoom = "     + cam.zoom);
        println("cam.rotation = " + cam.rotation);
        break;
    }
  }
}

boolean barHover() {
  boolean hoverLeft  = mouseX > bar_left.barX  && mouseX < bar_left.barX+bar_left.barW   && mouseY > bar_left.barY  && mouseY < bar_left.barY+bar_left.barH;
  boolean hoverRight = mouseX > bar_right.barX && mouseX < bar_right.barX+bar_right.barW && mouseY > bar_right.barY && mouseY < bar_right.barY+bar_right.barH;
  return hoverLeft || hoverRight;
}
