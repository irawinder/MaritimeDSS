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

// GeoLocation Parameters
//
float latCtr, lonCtr, bound, latMin, latMax, lonMin, lonMax;

// Tables Containing current simulation configuration and results
//
Table simConfig, simResult, simResultOverall;
boolean validConfig;
Fleet fleet;
boolean showFleet;
ArrayList<Port> ports;

// Objects for Viewing and Saving Results
//
GamePlot result;
Logger userLog;
int HOUR, MINUTE, SECOND; // Time when application starts

// Colors
//
int colorGTL    = #9bc151;
int colorHFO    = #AA0000;
int colorLSFO   = #6666FF;
int colorLNG    = #FF00FF;
int colorHFOLNG = #00FFFF;

// Simulation Timer Variables
//
int pauseDuration;
int TIME_INCREMENT;

// Graphics Objects
//
PImage map;
PImage[] maps;
PGraphics canvas;

// Graphics mode (Globe or Mercator)
//
String displayMode;

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

PFont f12, f18, f24;

// Counter to track which phase of initialization
boolean initialized;
int initPhase = 0;
int phaseDelay = 0;
String status[] = {
  "Initializing Canvas ...",
  "Importing Simulation Input Parameters ...",
  "Importing Simulation Results ...",
  "Initializing Toolbars and 3D Environment ...",
  "Initializing Fleet and Ports ...",
  "Initializing Key Logger ...",
  "Ready to go!"
};
int NUM_PHASES = status.length;

void init() {
  
  initialized = false;
    
  if (initPhase == 0) {
    
    // Time when application starts
    //
    HOUR = hour();
    MINUTE = minute();
    SECOND = second();
    
    // Load default background image
    //
    loadingBG = loadImage("data/loadingScreen.jpg");
    
    // Load all the images into the program 
    //
    maps = new PImage[mapFile.length];
    for (int i=0; i<maps.length; i++) {
      maps[i] = loadImage("maps/" + mapFile[i]);
      maps[i].resize(maps[0].width, maps[0].height);
    }
      
    // Select the image to display in the program 
    //
    mapIndex = 0;
    map = maps[mapIndex];
    
    //Set Font
    //
    f12 = createFont("Helvetica", 12);
    f18 = createFont("Helvetica", 18);
    f24 = createFont("Helvetica", 24);
    textFont(f12);
    
    // Create canvas for drawing everything to earth surface
    //
    canvas = createGraphics(map.width, map.height, P3D);
    B = new PVector(canvas.width, canvas.height, 0);
    
    // Graphics mode (Globe or Mercator)
    //
    displayMode = "flat";
    
    // Set up Spherical Projection Map
    //
    defaultSphere();
    
  } else if (initPhase == 1) {
    
    // Load valid inputs from CSV files
    //
    initSimConfig();
    
  } else if (initPhase == 2) {
    
    // Load pre-calculated results from CSV files
    //
    initSimResult();
    
  } else if (initPhase == 3) {
    
    // Initialize GUI3D
    //
    initToolbars();
    initCamera();
    
  } else if (initPhase == 4) {
    
    // Initialize Fleet of Ships and Ports
    //
    initFleet();
    initPorts();
    
  } else if (initPhase == 5) {
    
    // Initialize key Logger
    //
    userLog = new Logger();
    
  } else if (initPhase == 6) {
    
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
  simResultOverall = loadTable("data/simulation/result/1_overall.csv", "header");
  
  result = new GamePlot();
  result.name.add("Fuel Efficiency");
  result.name.add("Cargo Moved");
  result.name.add("CO2 Emission");
  result.name.add("NOx Emission");
  result.name.add("SOx Emission");
  result.name.add("Waiting Time");
  result.name.add("Initial Cost");
}

void initToolbars() {
  
  // Initialize Toolbar
  BAR_X = MARGIN;
  BAR_Y = MARGIN;
  BAR_W = 250;
  BAR_H = 800 - 2*MARGIN;
  
  // Left Toolbar
  bar_left = new Toolbar(BAR_X, BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_left.title = "";
  bar_left.credit = "";
  bar_left.explanation = "";
  bar_left.controlY = BAR_Y + bar_left.margin + int(1.5*bar_left.CONTROL_H);
  
  // Ship Attributes
  bar_left.addSlider("HFO fueled",             "", 0,  20, 20, 5, 'q', 'w', false);
  bar_left.addSlider("LSFO fueled",            "", 0,  20,  0, 5, 'q', 'w', false);
  bar_left.addSlider("LNG fueled",             "", 0,  20,  0, 5, 'q', 'w', false);
  bar_left.addSlider("Dual fueled (HFO + LNG)","", 0,  20,  0, 5, 'q', 'w', false);
  bar_left.sliders.get(0).col = colorHFO;
  bar_left.sliders.get(1).col = colorLSFO;
  bar_left.sliders.get(2).col = colorLNG;
  bar_left.sliders.get(3).col = colorHFOLNG;
  
  // # Bunkers
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("0 bunkers", 200, true, '1', false);
  bar_left.addRadio("1 bunkers", colorLNG, false, '1', false);
  bar_left.addRadio("3 bunkers", colorLNG, false, '1', false);
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("0 bunkers", 200, true, '1', false);
  bar_left.addRadio("1 bunkers", colorLNG, false, '1', false);
  bar_left.addRadio("3 bunkers", colorLNG, false, '1', false);
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("0 bunkers", 200, true, '1', false);
  bar_left.addRadio("1 bunkers", colorLNG, false, '1', false);
  bar_left.addRadio("3 bunkers", colorLNG, false, '1', false);
  
  // Simulate Button
  //
  bar_left.addButton("SIMULATE", colorGTL, 's', false);
  
  // Bunker Method
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("Truck to Ship",  200, false, '1', false);
  bar_left.addRadio("Ship to Ship",   200, true , '1', false);
  bar_left.addRadio("Shore to Ship",  200, false, '1', false);
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("Truck to Ship",  200, false, '1', false);
  bar_left.addRadio("Ship to Ship",   200, true , '1', false);
  bar_left.addRadio("Shore to Ship",  200, false, '1', false);
  bar_left.addRadio("Blank", 200, true, '1', false);
  bar_left.addRadio("Truck to Ship",  200, false, '1', false);
  bar_left.addRadio("Ship to Ship",   200, true , '1', false);
  bar_left.addRadio("Shore to Ship",  200, false, '1', false);
  
  for (int i=14; i<=27; i++) {   // Shift Bunker Method buttons right
    bar_left.radios.get(i).xpos = bar_left.barX + bar_left.barW/2; 
    bar_left.radios.get(i).ypos = bar_left.radios.get(i-14).ypos;
  }
  
  bar_left.radios.remove(24);
  bar_left.radios.remove(20);
  bar_left.radios.remove(16);
  bar_left.radios.remove(15);
  bar_left.radios.remove(14);
  
  bar_left.radios.remove(10);
  bar_left.radios.remove(6);
  bar_left.radios.remove(2);
  bar_left.radios.remove(1);
  bar_left.radios.remove(0);
  
  // Right Toolbar
  BAR_W  *= 1.5;
  bar_right = new Toolbar(width - (BAR_X + BAR_W), BAR_Y, BAR_W, BAR_H, MARGIN);
  bar_right.title = "";
  bar_right.credit = "";
  bar_right.explanation = "";
  bar_right.controlY = BAR_Y + bar_right.margin + 2*bar_right.CONTROL_H;
  bar_right.addSlider("Hour", "",  1,  simResult.getRowCount(), 1, 4, 'q', 'w', false);
  bar_right.addRadio("Blank", 200, true, '1', false);
  bar_right.addRadio("Pause",  200, false, '1', false);
  bar_right.addRadio("30 hr / sec",  200, true, '1', false);
  bar_right.addRadio("120 hr / sec", 200, false, '1', false);
  
  bar_right.addRadio(result.name.get(0), 200, true, '1', false);
  bar_right.addRadio(result.name.get(1), 200, false, '1', false);
  bar_right.addRadio(result.name.get(2), 200, false, '1', false);
  bar_right.addRadio(result.name.get(3), 200, false, '1', false);
  bar_right.addRadio(result.name.get(4), 200, false, '1', false);
  bar_right.addRadio(result.name.get(5), 200, false, '1', false);
  bar_right.addRadio(result.name.get(6), 200, false, '1', false);
  
  bar_right.addRadio(result.name.get(0), 200, false, '1', false);
  bar_right.addRadio(result.name.get(1), 200, true, '1', false);
  bar_right.addRadio(result.name.get(2), 200, false, '1', false);
  bar_right.addRadio(result.name.get(3), 200, false, '1', false);
  bar_right.addRadio(result.name.get(4), 200, false, '1', false);
  bar_right.addRadio(result.name.get(5), 200, false, '1', false);
  bar_right.addRadio(result.name.get(6), 200, false, '1', false);
  
  bar_right.radios.remove(0);
  bar_right.radios.get(1).xpos = bar_right.barX + 1*bar_right.barW/3; 
  bar_right.radios.get(1).ypos = bar_right.radios.get(0).ypos;
  bar_right.radios.get(2).xpos = bar_right.barX + 2*bar_right.barW/3; 
  bar_right.radios.get(2).ypos = bar_right.radios.get(0).ypos;
  for (int i=10; i<17; i++) {
    bar_right.radios.get(i).xpos = bar_right.barX + bar_right.barW/2;
    bar_right.radios.get(i).ypos = bar_right.radios.get(i-7).ypos;
  }
  for (int i=3; i<17; i++) {
    bar_right.radios.get(i).xpos += 20;
    bar_right.radios.get(i).ypos -= ((i-3)%7)*10;
  }
}

void initCamera() {
  
  // Initialize 3D World Camera Defaults
  //
  cam = new Camera (B, MARGIN);
  cam.X_DEFAULT    = -900;
  cam.Y_DEFAULT    =  220;
  cam.ZOOM_DEFAULT = 0.153;
  cam.ZOOM_POW     = 2.50;
  cam.ZOOM_MAX     = 0.05;
  cam.ZOOM_MIN     = 0.70;
  cam.ROTATION_DEFAULT = 5.0; // (0 - 2*PI)
  cam.enableChunks = false;  // Enable/Disable 3D mouse cursor field for continuous object placement
  
  // Must End with init() if any BASIC variables within Camera() are changed from default
  //
  cam.init(); 
  
  // Edit blockers and UI characteristics AFTER cam.init()
  //
  cam.vs.xpos = width - 3*MARGIN - BAR_W;
  //cam.hs.enable = false; //disable rotation
  cam.drag.addBlocker(MARGIN, MARGIN, BAR_W, BAR_H);
  cam.drag.addBlocker(width - bar_right.barW - MARGIN, MARGIN, bar_right.barW, BAR_H);
  cam.drag.addBlocker(int(cam.hs.xpos), int(cam.hs.ypos), int(cam.hs.swidth), int(cam.hs.sheight));
  cam.drag.addBlocker(int(cam.vs.xpos), int(cam.vs.ypos), int(cam.vs.swidth), int(cam.vs.sheight));
  
  // Turn cam off while still initializing
  //
  cam.off();
}

void initFleet() {
  
  fleet = new Fleet();
  fleet.duration = simResult.getRowCount();
  for (int i=0; i<20; i++) {
    Ship s = new Ship();
    for (int j=0; j<fleet.duration; j++) {
      TableRow row = simResult.getRow(j);
      float lat = row.getFloat(  9 + 11*i );
      float lon = row.getFloat( 10 + 11*i );
      PVector latlon = new PVector(lat, lon);
      s.location_LatLon.add(latlon);
      PVector xy = LatLonToXY(latlon, canvas.width, canvas.height, -90.0, 90.0, -180.0, 180.0);
      s.location_Canvas.add(xy);
      int cargo  = row.getInt( 4 + 11*i );
      s.cargoList.add(cargo);
      int fuel = row.getInt( 5 + 11*i );
      s.fuelList.add(fuel);
    }
    s.fuelType  = simResult.getString(0, 2 + 11*i);
    s.cargoType = simResult.getString(0, 3 + 11*i);
    
    if (s.fuelType.equals("HFO"))    s.col = colorHFO;
    if (s.fuelType.equals("LSFO"))   s.col = colorLSFO;
    if (s.fuelType.equals("LNG"))    s.col = colorLNG;
    if (s.fuelType.equals("HFOLNG")) s.col = colorHFOLNG;
    
    fleet.ships.add(s);
  }
  showFleet = false;
}

void initPorts() {
  ports = new ArrayList<Port>();
  Port p; 
  
  p = new Port();
  p.name = "Persian Gulf";
  p.location = new PVector(26.884, 50.082);
  p.location = LatLonToXY(p.location, B.x, B.y, -90, 90, -180, 180);
  ports.add(p);
  
  p = new Port();
  p.name = "Japan";
  p.location = new PVector(35.596, 139.78);
  p.location = LatLonToXY(p.location, B.x, B.y, -90, 90, -180, 180);
  ports.add(p);
  
  p = new Port();
  p.name = "Singapore";
  p.location = new PVector(1.352, 103.820);
  p.location = LatLonToXY(p.location, B.x, B.y, -90, 90, -180, 180);
  ports.add(p);
}
