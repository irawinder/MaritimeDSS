class Fleet {
  ArrayList<Ship> ships;
  
  Fleet() {
    ships = new ArrayList<Ship>();
  }
}

class Ship {
  ArrayList<PVector> location_LatLon; // Location in format (longitude, latitude) degrees
  ArrayList<PVector> location_Canvas; // Location on the 3D canvas
  
  
  Ship() {
    location_LatLon = new ArrayList<PVector>();
    location_Canvas = new ArrayList<PVector>();
  }
  
  void drawPath() {
    for (PVector loc: location_Canvas) {
      stroke(255); fill(0);
      point(loc.x, loc.y);
    }
  }
}

PVector LatLonToXY(PVector latlon, float canvasW, float canvasH, float latMin, float latMax, float lonMin, float lonMax) {
  float canvasX = canvasW * (0 + (latlon.y - lonMin) / (lonMax - lonMin) );
  float canvasY = canvasH * (1 - (latlon.x - latMin) / (latMax - latMin) );
  return new PVector(canvasX, canvasY);
}
