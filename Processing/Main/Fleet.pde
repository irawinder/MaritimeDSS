class Fleet {
  int time, duration;
  ArrayList<Ship> ships;
  
  Fleet() {
    ships = new ArrayList<Ship>();
    time = 0;
  }
  
  void drawShips() {
    for (Ship s: ships) s.draw(time);
    time+=1;
    if (time >= duration) time = 0;
  }
}

class Ship {
  ArrayList<PVector> location_LatLon; // Location in format (longitude, latitude) degrees
  ArrayList<PVector> location_Canvas; // Location on the 3D canvas
  float hue;
  
  Ship() {
    location_LatLon = new ArrayList<PVector>();
    location_Canvas = new ArrayList<PVector>();
    hue = random(0, 255);
  }
  
  void draw(int time) {
    PVector loc = location_Canvas.get(time);
    canvas.colorMode(HSB); canvas.fill(hue, 255, 255, 150); canvas.colorMode(RGB); canvas.noStroke(); 
    canvas.ellipse(loc.x, loc.y, 5, 5);
  }
}

PVector LatLonToXY(PVector latlon, float canvasW, float canvasH, float latMin, float latMax, float lonMin, float lonMax) {
  float canvasX = canvasW * (0 + (latlon.y - lonMin) / (lonMax - lonMin) );
  float canvasY = canvasH * (1 - (latlon.x - latMin) / (latMax - latMin) );
  return new PVector(canvasX, canvasY);
}
