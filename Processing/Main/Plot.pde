class GamePlot {
  ArrayList<Ilities> game;
  ArrayList<String> name, unit;
  ArrayList<Float> minRange, maxRange;
  int xIndex, yIndex;
  int nearest, nearestThreshold;
  int selected;
  int col;

  boolean showPath;
  boolean showAxes;
  boolean highlight;
  boolean allowSelect;
  
  float zoom;
  float offset_x, offset_y, origin_x, origin_y;
  
  boolean isDragged;
  int x_init, y_init;
  
  PGraphics interior;
  
  GamePlot() {
    game = new ArrayList<Ilities>();
    name = new ArrayList<String>();
    unit = new ArrayList<String>();
    minRange = new ArrayList<Float>();
    maxRange = new ArrayList<Float>();
    xIndex  = 0;
    yIndex  = 0;
    nearest = 0;
    selected = 0;
    nearestThreshold = 10;
    showPath = true;
    showAxes = true;
    highlight = false;
    allowSelect = true;
    col = 255;
    
    zoom = 0.0;
    offset_x = 0;
    offset_y = 0;
    origin_x = 0;
    origin_y = 0;
    
    interior = createGraphics(10, 10);
  }
  
  void click() {
    isDragged = true;
    x_init = mouseX;
    y_init = mouseY;
  }
  
  void release() {
    isDragged = false;
    origin_x = offset_x;
    origin_y = offset_y;
    if (nearest >=0) selected = nearest;
  }
  
  void next() {
    selected++;
    if (selected >= game.size()) selected = 0;
  }
  
  void last() {
    selected--;
    if (selected <= -1) selected = game.size()-1;
  }
  
  void reset() {
    zoom = 0;
    offset_x = 0;
    offset_y = 0;
    origin_x = 0;
    origin_y = 0;
  }
  
  void addResult(Table result, int timeStamp) {
    Ilities i = new Ilities(result, timeStamp);
    game.add(i);
    updateRange();
    selected = game.size()-1;
  }

  void addResults(Table results) {
    for (int i=1; i<results.getRowCount(); i++) {
      Ilities ilit = new Ilities();
      ArrayList<Float> val = new ArrayList<Float>();
      for (int j=0; j<results.getColumnCount(); j++) {
        val.add(results.getFloat(i, j));
      }
      ilit.value = val;
      game.add(ilit);
    }
    updateRange();
    selected = game.size()-1;
  }

  void update(int x, int y, int w, int h) {
    
    // Update offsets
    //
    if (isDragged && x_init > x && x_init < x+w && y_init > y && y_init < y+h) {
      offset_x = origin_x + float(x_init - mouseX)/w;
      offset_y = origin_y + float(mouseY - y_init)/h;
    }
  }

  void drawPlot(int x, int y, int w, int h, int minTime, int maxTime) {
    
    zoom = min(0.45, zoom);
    
    float min_x = minRange.get(xIndex);
    float min_y = minRange.get(yIndex);
    float max_x = maxRange.get(xIndex);
    float max_y = maxRange.get(yIndex);
    float range_x = max_x - min_x;
    float range_y = max_y - min_y;
    min_y += + zoom*range_y + offset_y*range_y;
    max_y += - zoom*range_y + offset_y*range_y;
    min_x += + zoom*range_x + offset_x*range_x;
    max_x += - zoom*range_x + offset_x*range_x;
    
    int MARGIN = 20;
    interior = createGraphics(w-MARGIN, h);
    pushMatrix(); translate(x+MARGIN, y);
    
    if (showAxes) {
      stroke(255); strokeWeight(1); noFill();
      rect(0, 0, w-MARGIN, h);
      fill(255);
  
      // Draw Y Axis Lable
      //
      String nY = name.get(yIndex) + " " + unit.get(yIndex); 
      //if (nY.length() > 18) nY = nY.substring(0, 18);
      pushMatrix(); translate(0, h/2); rotate(-PI/2);
      textAlign(CENTER, BOTTOM); 
      text(nY, 0, -3);
      popMatrix();
  
      if (game.size() > 0) {
  
        // Draw Y Axis Min Range
        //
        nY = trimValue("" + min_y, 2); 
        pushMatrix(); translate(0, h); rotate(-PI/2);
        textAlign(LEFT, BOTTOM); 
        text(nY, 0, -3);
        popMatrix();
  
        // Draw Y Axis Max Range
        //
        nY = trimValue("" + max_y, 2); 
        pushMatrix(); translate(0, 0); rotate(-PI/2);
        textAlign(RIGHT, BOTTOM); 
        text(nY, 0, -3);
        popMatrix();
      }
  
      // Draw X Axis Lable
      //
      String nX = name.get(xIndex) + " " + unit.get(xIndex); 
      //if (nX.length() > 18) nX = nX.substring(0, 18);
      pushMatrix(); translate(w/2-MARGIN/2, h+3);
      textAlign(CENTER, TOP); 
      text(nX, 0, 0);
      popMatrix();
  
      if (game.size() > 0) {
  
        // Draw X Axis Min Range
        //
        nX = trimValue("" + min_x, 2); 
        pushMatrix(); translate(0, h+3);
        textAlign(LEFT, TOP); 
        text(nX, 0, 0);
        popMatrix();
  
        // Draw X Axis Max Range
        //
        nX = trimValue("" + max_x, 2); 
        pushMatrix(); translate(w-MARGIN, h+3);
        textAlign(RIGHT, TOP); 
        text(nX, 0, 0);
        popMatrix();
      }
    }
    
    // Derive Nearest Architecture / Game State
    //
    nearest = -1;
    if (allowSelect) {
      float minDist = Float.POSITIVE_INFINITY;
      for (int i=0; i<game.size(); i++) {
        float val_x = game.get(i).value.get(xIndex);
        float val_y = game.get(i).value.get(yIndex);
        float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
        float y_plot = map(val_y, min_y, max_y, 0, h);
        
        // Update Nearest Game State Index
        //
        float dist = sqrt( sq(mouseX - x - MARGIN - x_plot) + sq(mouseY - y - h + y_plot) );
        if (dist < nearestThreshold && dist < minDist) {
          minDist = dist;
          nearest = i;
        }
      }
    }
  
    // Plot links
    //
    float alpha, alphaScale;
    if (showPath) {
      interior.beginDraw();
      interior.clear();
      Ilities last = new Ilities();
      for (int i=0; i<game.size(); i++) {
        float val_x = game.get(i).value.get(xIndex);
        float val_y = game.get(i).value.get(yIndex);
        float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
        float y_plot = map(val_y, min_y, max_y, 0, h);
        
        alpha = 150;
        alphaScale = 1.0;
        if (!inBounds(i, minTime, maxTime)) alphaScale = 0.1;
        
        if (i >= 1) {
          val_x = last.value.get(xIndex);
          val_y = last.value.get(yIndex);
          float x_plot_last = map(val_x, min_x, max_x, 0, w-MARGIN);
          float y_plot_last = map(val_y, min_y, max_y, 0, h);
          //if ( (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) || 
          //     (x_plot_last > 0 && x_plot_last < w-MARGIN && y_plot_last > 0 && y_plot_last < h) ) {
            interior.stroke(col, alphaScale*alpha); interior.strokeWeight(3); 
            interior.line(x_plot_last, h - y_plot_last, x_plot, h - y_plot);
          //}
        }
        last = game.get(i);
      }
      image(interior, 0, 0, w-MARGIN, h);
    }
    
    // Plot Points
    //
    float diameter = 8;
    for (int i=0; i<game.size(); i++) {
      float val_x = game.get(i).value.get(xIndex);
      float val_y = game.get(i).value.get(yIndex);
      float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
      float y_plot = map(val_y, min_y, max_y, 0, h);
      
      alphaScale = 1.0;
      if (!inBounds(i, minTime, maxTime)) alphaScale = 0.1;
      
      if (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) {
        
        noStroke(); fill(col, alphaScale*255);
        if (highlight) {
          stroke(#FFFF00, alphaScale*255); 
          strokeWeight(1); 
        }
        if (i != selected) ellipse(x_plot, h - y_plot, diameter, diameter);
        
      }
    }
    
    hint(ENABLE_DEPTH_TEST); hint(DISABLE_DEPTH_TEST);
    
    //// Draw point Labels
    ////
    //for (int i=0; i<game.size(); i++) {
    //  if (showPath) {
    //    float val_x = game.get(i).value.get(xIndex);
    //    float val_y = game.get(i).value.get(yIndex);
    //    float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
    //    float y_plot = map(val_y, min_y, max_y, 0, h);
    //    if (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) {
    //      alphaScale = 1.0;
    //      if (!inBounds(i, minTime, maxTime)) alphaScale = 0.1;
    //      fill(255, alphaScale*255); stroke(255, alphaScale*255); 
    //      if (i == selected) fill(#DB8F00);
    //      text(i+1, x_plot + 12, h - y_plot - 12);
    //    }
    //  }
    //}
    
    // Draw Nearest Point Marker
    //
    if (nearest >=0 && nearest != selected && game.size() > 0) {
      
      float val_x = game.get(nearest).value.get(xIndex);
      float val_y = game.get(nearest).value.get(yIndex);
      float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
      float y_plot = map(val_y, min_y, max_y, 0, h);
      if (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) {
        strokeWeight(2); stroke(#DB8F00); noFill();
        ellipse(x_plot, h - y_plot, diameter+4, diameter+4);
        fill(#FFAA00); noStroke();
        textAlign(LEFT, BOTTOM);
      }
      for (int i=0; i<3; i++) text((nearest+1), x_plot + 8, h - y_plot - 8);
    }
    
    // Draw Selected Point Marker
    //
    if (selected >=0 && game.size() > 0 && allowSelect) {
      float val_x = game.get(selected).value.get(xIndex);
      float val_y = game.get(selected).value.get(yIndex);
      float x_plot = map(val_x, min_x, max_x, 0, w-MARGIN);
      float y_plot = map(val_y, min_y, max_y, 0, h);
      if (x_plot > 0 && x_plot < w-MARGIN && y_plot > 0 && y_plot < h) {
        fill(#DB8F00); noStroke();
        ellipse(x_plot, h - y_plot, diameter+10, diameter+10);
        textAlign(CENTER, CENTER); fill(255);
        for (int i=0; i<3; i++) text(selected+1, x_plot, h - y_plot - 1);
      }
      
      String values = "";
      values += name.get(xIndex) + ": " + trimValue("" + val_x, 2) + " " + unit.get(xIndex);
      values += "\n";
      values += name.get(yIndex) + ": " + trimValue("" + val_y, 2) + " " + unit.get(yIndex);
      textAlign(LEFT, BOTTOM); fill(#FFAA00);
      text(values, 8, h - 8);
    }
    
    popMatrix();
  }
  
  boolean inBounds(int index, int minTime, int maxTime) {
    Ilities i = game.get(index);
    if (i.timeStamp >= minTime && i.timeStamp <= maxTime) {
      return true;
    } else {
      return false;
    }
  }

  void updateRange() {
    minRange.clear();
    maxRange.clear();
    if (game.size() == 0) {
      for (int i=0; i<name.size(); i++) {
        minRange.add(-1000.0);
        maxRange.add(+1000.0);
      }
    } else if (game.size() == 1) {
      for (int i=0; i<name.size(); i++) {
        Ilities r = game.get(0);
        if (r.value.get(i) == 0) {
          minRange.add(r.value.get(i) - 1.0);
          maxRange.add(r.value.get(i) + 1.0);
        } else {
          minRange.add(r.value.get(i) - 0.25*r.value.get(i));
          maxRange.add(r.value.get(i) + 0.25*r.value.get(i));
        }
      }
    } else {
      for (int i=0; i<name.size(); i++) {
        float min = Float.POSITIVE_INFINITY;
        float max = Float.NEGATIVE_INFINITY;
        for (Ilities r : game) {
          if (min > r.value.get(i)) min = r.value.get(i);
          if (max < r.value.get(i)) max = r.value.get(i);
        }
        if (min != max) {
          minRange.add(min - 0.25*(max-min));
          maxRange.add(max + 0.25*(max-min));
        } else {
          if (min == 0) {
            minRange.add(-1.0);
            maxRange.add(+1.0);
          } else {
            minRange.add(min - 0.25*min);
            maxRange.add(max + 0.25*max);
          }
        }
      }
    }
  }
}

class Ilities {
  ArrayList<Float> value;
  int timeStamp;

  Ilities() {
    timeStamp = 0;
    value = new ArrayList<Float>();
  }

  Ilities(Table result, int timeStamp) {
    this.timeStamp = timeStamp;
    value = new ArrayList<Float>();
    for (int i=0; i<result.getColumnCount(); i++) {
      float scaler = 1.0;
      value.add(scaler*result.getFloat (0, i));
    }
  }
}

// Truncates the decimals off of a very large or small float
//
String trimValue(String val, int figures) {
  String trimmed = "";
  int counter = 0;
  boolean decimal = false;
  for (int i=0; i<val.length(); i++) {
    String letter = val.substring(i, i+1);
    if (letter.equals(".")) decimal = true;
    if (letter.equals("E")) decimal = false;
    if (counter <= figures || !decimal) trimmed += letter;
    if (decimal) counter ++;
  }
  
  return trimmed;
}
