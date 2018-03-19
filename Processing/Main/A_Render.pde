/*  MaritimeDSS
 *  Ira Winder, ira@mit.edu, 2018
 *  MIT Global Teamwork Lab
 *
 *  Draw Functions (Superficially Isolated from Main.pde)
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

// Begin Drawing Earth Canvas
//
void renderEarth() {

  canvas.beginDraw();
  canvas.background(0);

  // Field: Draw Rectangular plane comprising boundary area 
  //
  canvas.fill(255, 50);
  canvas.rect(0, 0, map.width, map.height);

  // Field: Draw Selection Field
  //
  canvas.pushMatrix(); 
  canvas.translate(0, 0, 1);
  canvas.image(map, 0, 0);
  canvas.popMatrix();

  canvas.endDraw();
}

// Begin Drawing 3D Elements
//
void render3D() {

  // ****
  // NOTE: Objects draw earlier in the loop will obstruct 
  // objects drawn afterward (despite alpha value!)
  // ****

  hint(ENABLE_DEPTH_TEST);

  // Draw Canvas to Screen
  switch(displayMode) {
  case "flat":

    // Update camera position settings for a number of frames after key updates
    if (cam.moveTimer > 0) {
      cam.moved();
    }

    // Draw and Calculate 3D Graphics 
    cam.on();

    fill(255);
    image(canvas, 0, 0, B.x, B.y);
    break;

  case "globe":

    drawSphere(30, 60);
    break;
  }

  // Draw Ships
  //
  pushMatrix(); 
  translate(0, 0, 1);
  fleet.drawShipsFlat();
  fleet.drawShips3D();
  popMatrix();
}

void render2D() {

  hint(DISABLE_DEPTH_TEST);
  cam.off();

  // Draw Slider Bars for Controlling Zoom and Rotation (2D canvas begins)
  if (displayMode.equals("flat")) cam.drawControls();

  // Draw Margin ToolBar
  //
  bar_left.draw();
  bar_right.draw();
  simButton.drawMe();

  //// Radio Button Labels:
  ////
  //pushMatrix(); translate(bar_left.barX + bar_left.margin, int(9.5*bar_left.CONTROL_H) );
  //textAlign(LEFT, BOTTOM); fill(255); 
  //text("# Bunkers", 0, 0);
  //translate(bar_left.contentW/2, 0);
  //text("Method", 0, 0);
  //popMatrix();

  // Ships
  //
  pushMatrix(); 
  translate(bar_left.barX + bar_left.margin, int(4.0*bar_left.CONTROL_H) );
  textAlign(LEFT, BOTTOM); 
  fill(255); 
  text("# Ships", 0, 0);
  popMatrix();

  // Bunker Locations
  //
  pushMatrix(); 
  translate(bar_left.barX + bar_left.margin, int(10.5*bar_left.CONTROL_H) );
  textAlign(LEFT, BOTTOM); 
  fill(255); 
  text("Persian Gulf", 0, 0);
  translate(0, int(4*bar_left.CONTROL_H));
  text("Japan", 0, 0);
  translate(0, int(4*bar_left.CONTROL_H));
  text("Singapore", 0, 0);
  popMatrix();

  validConfig = true;

  // Ships must add up to 20
  //
  int type1 = int(bar_left.sliders.get(0).value);
  int type2 = int(bar_left.sliders.get(1).value);
  int type3 = int(bar_left.sliders.get(2).value);
  int type4 = int(bar_left.sliders.get(3).value);

  pushMatrix(); 
  translate(bar_left.barX + bar_left.barW - bar_left.margin, int(9.5*bar_left.CONTROL_H) );
  textAlign(RIGHT, BOTTOM); 
  fill(255); 
  text("Fleet Size: " + (type1+type2+type3+type4), 0, 0);
  if (type1 + type2 + type3 + type4 != 20) {
    String error = "FLEET MUST BE 20";
    translate(- bar_left.barW + 2*bar_left.margin, 0);
    textAlign(LEFT, BOTTOM); 
    fill(#FFFF00); 
    text(error, 0, 0);
    validConfig = false;
  }
  popMatrix();



  pushMatrix(); 
  translate(bar_right.barX + bar_right.margin, bar_right.barY + bar_right.margin);
  fill(255); 
  textAlign(LEFT, TOP);
  text("Simulation Time\n" + fleet.time/24 + " of " + fleet.duration/24 + " days", 0, 0);
  text("Speed:", 0, 6*16);
  popMatrix();
}

PImage loadingBG;
void loadingScreen(PImage bg, int phase, int numPhases, String status) {

  // Place Loading Bar Background
  //
  image(bg, 0, 0, width, height);
  pushMatrix(); 
  translate(width/2, height/2);
  int BAR_WIDTH  = 400;
  int BAR_HEIGHT =  48;
  int BAR_BORDER =  10;

  // Draw Loading Bar Outline
  //
  noStroke(); 
  fill(255, 200);
  rect(-BAR_WIDTH/2, -BAR_HEIGHT/2, BAR_WIDTH, BAR_HEIGHT, BAR_HEIGHT/2);
  noStroke(); 
  fill(0, 200);
  rect(-BAR_WIDTH/2+BAR_BORDER, -BAR_HEIGHT/2+BAR_BORDER, BAR_WIDTH-2*BAR_BORDER, BAR_HEIGHT-2*BAR_BORDER, BAR_HEIGHT/2);

  // Draw Loading Bar Fill
  //
  float percent = float(phase+1)/numPhases;
  noStroke(); 
  fill(255, 150);
  rect(-BAR_WIDTH/2 + BAR_HEIGHT/4, -BAR_HEIGHT/4, percent*(BAR_WIDTH - BAR_HEIGHT/2), BAR_HEIGHT/2, BAR_HEIGHT/4);

  // Draw Loading Bar Text
  //
  textAlign(CENTER, CENTER); 
  fill(255);
  text(status, 0, 0);

  popMatrix();
}
