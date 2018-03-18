class Fleet {
  int time, duration;
  int TIME_PAUSE = 4;
  int timePause, TIME_INCREMENT;
  ArrayList<Ship> ships;
  
  Fleet() {
    ships = new ArrayList<Ship>();
    time = 0;
    timePause = 0;
    TIME_INCREMENT = 1;
  }
  
  void update() {
    if (timePause < TIME_PAUSE) {
      timePause++;
    } else {
      timePause = 0;
    }
    if (timePause == 0) time += TIME_INCREMENT;
    if (time >= duration) time = 0;
    for (Ship s: ships) s.update(time, timePause, TIME_PAUSE);
  }
  
  void drawShipsFlat() {
    for (Ship s: ships) s.drawFlat(time);
  }
  
  void drawShips3D() {
    for (Ship s: ships) s.draw3D(time);
    for (Ship s: ships) s.drawBubbles(time);
  }
}

class Ship {
  ArrayList<PVector> location_LatLon; // Location in format (longitude, latitude) degrees
  ArrayList<PVector> location_Canvas; // Location on the 3D canvas
  float hue;
  PVector randomOffset; // Helps to prevent occlusion
  
  float heading;
  PVector canvasLocation;
  
  Ship() {
    location_LatLon = new ArrayList<PVector>();
    location_Canvas = new ArrayList<PVector>();
    hue = random(0, 255);
    float range = 10;
    randomOffset = new PVector(random(-range, range), random(-range, range), random(-1, 1));
    heading = 0;
  }
  
  void update(int time, int timePause, int TIME_PAUSE) {
    
    canvasLocation = new PVector(location_Canvas.get(time).x, location_Canvas.get(time).y);
    
    if (time > 0) {
      PVector lastLoc = location_Canvas.get(time-1);
      PVector displacement = new PVector(canvasLocation.x - lastLoc.x, canvasLocation.y - lastLoc.y);
      heading = displacement.heading();
      
      if (timePause > 0) {
        float dist = displacement.mag();
        canvasLocation.add(displacement.setMag(dist*float(timePause)/TIME_PAUSE));
      }
    }
    
  }
  
  void drawFlat(int time) {
    PVector loc = canvasLocation;
    colorMode(HSB); fill(hue, 255, 255, 255); colorMode(RGB); noStroke();
    pushMatrix(); translate(loc.x + randomOffset.x, loc.y + randomOffset.y + 5, randomOffset.z); rotate(heading);
    fill(0, 100); ellipse(0, 0, 15, 5);
    
    popMatrix();
  }
  
  void draw3D(int time) {
    PVector loc = canvasLocation;
    
    pushMatrix(); translate(loc.x + randomOffset.x, loc.y + randomOffset.y, 1.5 + randomOffset.z); rotate(heading);
    
        colorMode(HSB); fill(hue, 255, 255, 255); colorMode(RGB); noStroke();  box(15, 5, 3); 
    
            translate(-6, 0, 3.1);
            
                fill(255, 150); box(3, 6, 3);
        
    popMatrix();
  }
  
  void drawBubbles(int time) {
    PVector loc = canvasLocation;
    
    pushMatrix(); translate(loc.x + randomOffset.x, loc.y + randomOffset.y, 1.5 + randomOffset.z);
    colorMode(HSB); fill(hue, 255, 255, 50); colorMode(RGB); sphere(12);
    popMatrix();
  }
}



PVector LatLonToXY(PVector latlon, float canvasW, float canvasH, float latMin, float latMax, float lonMin, float lonMax) {
  float canvasX = canvasW * (0 + (latlon.y - lonMin) / (lonMax - lonMin) );
  float canvasY = canvasH * (1 - (latlon.x - latMin) / (latMax - latMin) );
  return new PVector(canvasX, canvasY);
}
