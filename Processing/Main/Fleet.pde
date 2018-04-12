class Fleet {
  int time, duration;
  int timePause, pauseDuration, timeIncrement;
  boolean pause;
  ArrayList<Ship> ships;
  
  Fleet() {
    ships = new ArrayList<Ship>();
    
    timePause = 0;
    timeIncrement = 1;
    pause = false;
  }
  
  void update() {
    if (!pause) {
      if (timePause < pauseDuration) {
        timePause++;
      } else {
        timePause = 0;
      }
      if (timePause == 0) time += timeIncrement;
      if (time >= duration) time = 0;
      for (Ship s: ships) s.update(time, timePause, pauseDuration);
    }
  }
  
  void drawShipsFlat() {
    for (Ship s: ships) s.drawShadow(0.75);
  }
  
  void drawShips3D() {
    for (Ship s: ships) s.draw3D(0.75);
    //for (Ship s: ships) s.drawBubbles();
  }
}

class Ship {
  ArrayList<PVector> location_LatLon; // Location in format (longitude, latitude) degrees
  ArrayList<PVector> location_Canvas; // Location on the 3D canvas
  
  ArrayList<Integer> fuelList, cargoList;
  int maxFuel, maxCargo;
  String fuelType, cargoType;
  
  int col; // color
  PVector randomOffset; // Helps to prevent occlusion
  
  float heading;
  PVector canvasLocation;
  int fuel, cargo;
  
  Ship() {
    location_LatLon = new ArrayList<PVector>();
    location_Canvas = new ArrayList<PVector>();
    fuelList  = new ArrayList<Integer>();
    cargoList = new ArrayList<Integer>();
    maxFuel = 2000;
    maxCargo = 300000;
    
    float range = 10;
    randomOffset = new PVector(random(-range, range), random(-range, range), random(-.1, .1));
    heading = 0;
    col = 255;
  }
  
  void update(int time, int timePause, int pauseDuration) {
    
    canvasLocation = new PVector(location_Canvas.get(time).x, location_Canvas.get(time).y);
    fuel  =  fuelList.get(time);
    cargo = cargoList.get(time);
    
    if (time > 0) {
      PVector lastLoc = location_Canvas.get(time-1);
      PVector displacement = new PVector(canvasLocation.x - lastLoc.x, canvasLocation.y - lastLoc.y);
      heading = displacement.heading();
      
      if (timePause > 0) {
        float dist = displacement.mag();
        canvasLocation.add(displacement.setMag(dist*float(timePause)/pauseDuration));
      }
    }
    
  }
  
  void calculateLimits() {
    maxFuel  = 0;
    for (Integer f: fuelList)  if (f > maxFuel)  maxFuel  = f;
    
    maxCargo = 0;
    for (Integer c: cargoList) if (c > maxCargo) maxCargo = c;
  }
  
  void drawShadow(float scaler) {
    PVector loc = canvasLocation;
    fill(col, 255); noStroke();
    pushMatrix(); translate(loc.x + randomOffset.x, loc.y + randomOffset.y, - scaler*0.45 ); rotate(heading);
    fill(0, 100); ellipse(0, 0, scaler*20, scaler*7.5);
    popMatrix();
  }
  
  void draw3D(float scaler) {
    PVector loc = canvasLocation;
    pushMatrix(); translate(loc.x + randomOffset.x, loc.y + randomOffset.y, 0.70*scaler + randomOffset.z); rotate(heading);
    
    // Draw Hull
    //
    fill(255, 200); noStroke();  box(scaler*15, scaler*5, scaler*2); 
    
    // Draw Control Tower
    //
    pushMatrix(); translate(-scaler*6, 0, scaler*2.1);
    fill(255, 150); box(scaler*1.5, scaler*6, scaler*2);
    popMatrix(); 
    
    float ratio;
    
    // Draw Cargo Hold
    //
    ratio = float(cargo)/maxCargo;
    pushMatrix(); translate(scaler*(5.75*ratio - 4.5), 0, scaler*1.6);
    fill(colorGTL, 150); if (cargo > 0) box(scaler*ratio*11.5, scaler*4, scaler*1.5);
    popMatrix();
    
    // Draw Fuel Tank
    //
    ratio = float(fuel)/maxFuel;
    pushMatrix(); translate(-scaler*6, scaler*4.5, scaler*(4.25*ratio + 1.6));
    noFill(); stroke(255, 50); box(scaler*0.1, scaler*1.0, scaler*8.5);
    translate(0, 0, -scaler*4.25*(1-ratio));
    fill(col); noStroke(); box(scaler*0.1, scaler*1.0, scaler*ratio*8.5);
    translate(0, 0, scaler*8);
    fill(col); sphere(scaler*1.0);
    popMatrix();
        
    popMatrix();
  }
  
  void drawBubbles() {
    PVector loc = canvasLocation;
    pushMatrix(); translate(loc.x + randomOffset.x, loc.y + randomOffset.y, 1 + randomOffset.z);
    fill(col, 50); sphere(12);
    popMatrix();
  }
}

class Port {
  String name;
  PVector location;
  int numBunkers;
  String bunkerMethod;
  float s_x, s_y;
  
  Port() {
    name = "Port";
    location = new PVector(0, 0);
    numBunkers = 3;
    bunkerMethod = "Truck to Ship";
    s_x = -1000;
    s_y = -1000;
  }
  
  void getScreen() {
    s_x = screenX(location.x, location.y, 0);
    s_y = screenY(location.x, location.y, 0);
  }
  
  void draw3D(float scaler) {
    PVector loc = location;
    pushMatrix(); translate(loc.x, loc.y, 0.1);
    translate(0, 0, 1);fill(255, 100); noStroke(); ellipse(0, 0, scaler*2, scaler*2); translate(0, 0, -1);
    noFill(); stroke(255, 50); strokeWeight(2);
    rect(-scaler*10, -scaler*10, scaler*20, scaler*20);
    translate(-scaler*7.5, -scaler*7.5, scaler*0.25);
    for (int i=0; i<numBunkers; i++) {
      fill(colorLNG, 200); noStroke();
      box(scaler*3, scaler*3, scaler*0.5);
      stroke(colorLNG, 200); strokeWeight(2);
      line(0, 0, scaler*7.5*(1 - i), scaler*7.5);
      translate(scaler*7.5, 0, 0);
    }
    popMatrix();
  }
}

PVector LatLonToXY(PVector latlon, float canvasW, float canvasH, float latMin, float latMax, float lonMin, float lonMax) {
  float canvasX = canvasW * (0 + (latlon.y - lonMin) / (lonMax - lonMin) );
  float canvasY = canvasH * (1 - (latlon.x - latMin) / (latMax - latMin) );
  return new PVector(canvasX, canvasY);
}
