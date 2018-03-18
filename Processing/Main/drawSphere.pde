float pitch3d;
float rotate3d;
float zoom3d;

void drawSphere(int segLat, int segLon) {
  
  noStroke();
  //rotate3d += 0.1;
  //if(rotate3d >= 360) rotate3d = 0;

  float segAng = 180/segLat;

  pushMatrix();
  translate(width/2,height/2,0);
  scale(zoom3d);
  
  rotateX(-pitch3d*PI/180);
  rotateY(rotate3d*PI/180);
  
  for(int i=0; i<segLat;i++) {
    drawRing(i*segAng-90,(i+1)*segAng-90, segLon);
  }
  popMatrix();
}

void drawRing(float botPhi,float topPhi, int segments) {
  
  //This maybe saves some cpu math
  float segAng = 2*PI/segments;
  float botRad = botPhi*PI/180;
  float topRad = topPhi*PI/180;
  
  //noStroke();
  
  beginShape(TRIANGLE_STRIP);
  texture(canvas);

  for(int i=0; i<=(segments);i++) {
    vertex(getX3D(botRad,  i*segAng), -sin(botRad), getZ3D(botPhi*PI/180,  i*segAng), i*map.width/segments, map.height*(1-(botPhi+90)/180));
    vertex(getX3D(topRad,  i*segAng), -sin(topRad), getZ3D(topPhi*PI/180,  i*segAng), i*map.width/segments, map.height*(1-(topPhi+90)/180));
  }
  endShape();
}

float getX3D(float phi, float theta){
  float x = sin(theta)*cos(phi);
  return x;
}

float getZ3D(float phi, float theta){
  float z = cos(theta)*cos(phi);
  return z;
}

void defaultSphere() {
  zoom3d = 340;
  pitch3d = 15;
  rotate3d = 85;
}
