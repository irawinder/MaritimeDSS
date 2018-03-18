/*  MaritimeDSS
 *  Ira Winder, ira@mit.edu, 2018
 *  MIT Global Teamwork Lab
 *
 *  Init Functions (Superficially Isolated from Main.pde)
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

// Output edit requests for Shinnosuke:
// - Each Column name in {case_number}.csv should be unique.  For instance, call "Lat" column "Lat_{ship_num}".

//  GeoLocation Parameters
//
float latCtr, lonCtr, bound, latMin, latMax, lonMin, lonMax;

// Tables Containing current simulation configuration and results
//
Table simConfig, simResult;
Fleet fleet;

// Graphics Objects
PImage map;
PImage[] maps;
PGraphics canvas;

// Map Setting
int mapIndex;
String[] mapFile = { // Names of map files in /data/maps folder
  "world.topo.bathy.200407.3x5400x2700.jpg",
  "Equirectangular_projection_crop.png",
  "BlankMap-Equirectangular.png",
  "BlankMap-Equirectangular_night.png",
  "Earth_night_homemade.jpg"
};

// Camera Object with built-in GUI for navigation and selection
//
Camera cam;
PVector B; // Bounding Box for 3D Environment
int MARGIN = 25; // Pixel margin allowed around edge of screen

// Semi-transparent Toolbar for information and sliders
//
Toolbar bar_left, bar_right; 
int BAR_X, BAR_Y, BAR_W, BAR_H;

// Counter to track which phase of initialization
boolean initialized;
int initPhase = 0;
int phaseDelay = 0;
String status[] = {
  "Initializing Canvas ...",
  "Initializing Toolbars and 3D Environment...",
  "Importing Simulation Input Parameters ...",
  "Importing Simulation Results ...",
  "Initializing Fleet ...",
  "Ready to go!"
};
int NUM_PHASES = status.length;

void init() {
  
  initialized = false;
    
  if (initPhase == 0) {
    
    // Load default background image
    //
    loadingBG = loadImage("data/loadingScreen.jpg");
    
    // Load all the images into the program 
    //
    maps = new PImage[mapFile.length];
    for (int i=0; i<maps.length; i++) {
      maps[i] = loadImage("maps/" + mapFile[i]);
    }
      
    // Select the image to display in the program 
    //
    mapIndex = 0;
    map = maps[mapIndex];
    
  } else if (initPhase == 1) {
    
    // Initialize GUI3D
    //
    initToolbars();
    initCamera();
    
  } else if (initPhase == 2) {
    
    // Load valid inputs from CSV files
    //
    initSimConfig();
    
  } else if (initPhase == 3) {
    
    // Load pre-calculated results from CSV files
    //
    initSimResult();
    
  } else if (initPhase == 4) {
    
    // Initialize Fleet of Ships
    //
    initWorld();
    initFleet();
    
  } else if (initPhase == 5) {
    
    initialized = true;
  }
  
  loadingScreen(loadingBG, initPhase, NUM_PHASES, status[initPhase]);
  if (!initialized) initPhase++; 
  delay(phaseDelay);

}

void initSimConfig() {
  simConfig = loadTable("data/simulation/config/case_table4Workshop.csv", "header");
}

void initSimResult() {
  simResult = loadTable("data/simulation/result/1.csv", "header");
}

void initToolbars() {
  
  // Initialize Toolbar
  BAR_X = MARGIN;
  BAR_Y = MARGIN;
  BAR_W = 250;
  BAR_H = 800 - 2*MARGIN;
  
  // Left Toolbar
  bar_left = new Toolbar(BAR_X, BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_left.title = "MaritimeDSS\n";
  bar_left.credit = "Global Teamwork Lab";
  bar_left.explanation = "";
  //bar_left.controlY = BAR_Y + bar_left.margin + 2*bar_left.CONTROL_H;
  //bar_left.addSlider("Slider A", "%", 0, 100, 25, 'q', 'w', true);
  //bar_left.addButton("Item A", 200, true, '1');
  
  // Right Toolbar
  bar_right = new Toolbar(width - (BAR_X + BAR_W), BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_right.title = "";
  bar_right.credit = "";
  bar_right.explanation = "";
  //bar_right.controlY = BAR_Y + bar_left.margin + 6*bar_left.CONTROL_H;
  //bar_right.addButton("Button A", 200, true, '!');
  //bar_right.addSlider("Slider 1", "kg", 50, 100, 72, '<', '>', true);
}

void initWorld() {
  
  //  Parameter Space for Geometric Area
  //
  latCtr = +42.350;
  lonCtr = -71.066;
  bound    =  0.035;
  latMin = latCtr - bound;
  latMax = latCtr + bound;
  lonMin = lonCtr - bound;
  lonMax = lonCtr + bound;
}

void initCamera() {
  
  // Bounding box for our 3D environment
  B = new PVector(3000, 1500, 0);
  
  // Initialize 3D World Camera Defaults
  cam = new Camera (B, MARGIN);
  // eX, eW (extentsX ...) prevents accidental dragging when interactiong with toolbar
  cam.eX = MARGIN + BAR_W;
  cam.eW = width - 2*(BAR_W + MARGIN);
  cam.ZOOM_DEFAULT = 0.25;
  cam.ZOOM_POW     = 1.75;
  cam.ZOOM_MAX     = 0.10;
  cam.ZOOM_MIN     = 0.75;
  cam.ROTATION_DEFAULT = PI; // (0 - 2*PI)
  cam.init(); //Must End with init() if any variables within Camera() are changed from default
  cam.off(); // turn cam off while still initializing
}

void initFleet() {
  
  fleet = new Fleet();
  for (int i=0; i<20; i++) {
    Ship s = new Ship();
    for (int j=0; j<simResult.getRowCount(); j++) {
      TableRow row = simResult.getRow(j);
      float lat = row.getFloat(  9 + 11*i );
      float lon = row.getFloat( 10 + 11*i );
      PVector latlon = new PVector(lat, lon);
      s.location_LatLon.add(latlon);
      PVector xy = LatLonToXY(latlon, B.x, B.y, -90.0, 90.0, -180.0, 180.0);
      s.location_Canvas.add(xy);
    }
    fleet.ships.add(s);
  }
}
