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
 
void render3D() {
  
}

void render2D() {
  
}

PImage loadingBG;
void loadingScreen(PImage bg, int phase, int numPhases, String status) {
  image(bg, 0, 0, width, height);
  pushMatrix(); translate(width/2, height/2);
  int lW = 400;
  int lH = 48;
  int lB = 10;
  
  // Draw Loading Bar Outline
  noStroke(); fill(255, 200);
  rect(-lW/2, -lH/2, lW, lH, lH/2);
  noStroke(); fill(0, 200);
  rect(-lW/2+lB, -lH/2+lB, lW-2*lB, lH-2*lB, lH/2);
  
  // Draw Loading Bar Fill
  float percent = float(phase+1)/numPhases;
  noStroke(); fill(255, 150);
  rect(-lW/2 + lH/4, -lH/4, percent*(lW - lH/2), lH/2, lH/4);
  
  textAlign(CENTER, CENTER); fill(255);
  text(status, 0, 0);
  
  popMatrix();
}
