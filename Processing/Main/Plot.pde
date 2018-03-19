class GamePlot {
  ArrayList<Ilities> game;
  ArrayList<String> name;
  ArrayList<Float> minRange, maxRange;
  int xIndex, yIndex;
  
  GamePlot() {
    game = new ArrayList<Ilities>();
    name = new ArrayList<String>();
    minRange = new ArrayList<Float>();
    maxRange = new ArrayList<Float>();
    xIndex = 0;
    yIndex = 0;
  }
  
  void addResult(Table result) {
    Ilities i = new Ilities(result);
    game.add(i);
    updateRange();
  }
  
  void drawPlot(int x, int y, int w, int h) {
    int MARGIN = 20;
    pushMatrix(); translate(x+MARGIN, y);
    stroke(255); noFill();
    rect(0, 0, w-MARGIN, h);
    
    // Draw Y Axis Lable
    //
    pushMatrix(); translate(0, h/2); rotate(-PI/2);
    textAlign(CENTER, BOTTOM); text(name.get(yIndex), 0, -3);
    popMatrix();
    
    if (game.size() > 0) {
      
      // Draw Y Axis Min Range
      //
      pushMatrix(); translate(0, h); rotate(-PI/2);
      textAlign(LEFT, BOTTOM); text(int(minRange.get(yIndex)), 0, -3);
      popMatrix();
      
      // Draw Y Axis Max Range
      //
      pushMatrix(); translate(0, 0); rotate(-PI/2);
      textAlign(RIGHT, BOTTOM); text(int(maxRange.get(yIndex)), 0, -3);
      popMatrix();
      
    }
    
    // Draw X Axis Lable
    //
    pushMatrix(); translate(w/2+MARGIN/2, h+3);
    textAlign(CENTER, TOP); text(name.get(xIndex), 0, 0);
    popMatrix();
    
    if (game.size() > 0) {
 
      // Draw X Axis Min Range
      //
      pushMatrix(); translate(0, h+3);
      textAlign(LEFT, TOP); text(int(minRange.get(xIndex)), 0, 0);
      popMatrix();
      
      // Draw X Axis Max Range
      //
      pushMatrix(); translate(w-MARGIN, h+3);
      textAlign(RIGHT, TOP); text(int(maxRange.get(xIndex)), 0, 0);
      popMatrix();
    
    }
    
    // Plot points
    //
    Ilities last = new Ilities();
    for (int i=0; i<game.size(); i++) {
      float alpha = 255.0*float(i+1)/game.size();
      float x_plot = map(game.get(i).value.get(xIndex), minRange.get(xIndex), maxRange.get(xIndex), 0, w);
      float y_plot = map(game.get(i).value.get(yIndex), minRange.get(yIndex), maxRange.get(yIndex), 0, h);
      float diameter = 5;
      if (i == game.size()-1) diameter *= 2;
      fill(255, 55 + alpha); noStroke(); ellipse(x_plot, h - y_plot, diameter, diameter);
      
      if (i >= 1) {
        float x_plot_last = map(last.value.get(xIndex), minRange.get(xIndex), maxRange.get(xIndex), 0, w);
        float y_plot_last = map(last.value.get(yIndex), minRange.get(yIndex), maxRange.get(yIndex), 0, h);
        stroke(255, alpha); line(x_plot_last, h - y_plot_last, x_plot, h - y_plot);
      }
      last = game.get(i);
    }
    popMatrix();
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
        minRange.add(r.value.get(i) - 1000.0);
        maxRange.add(r.value.get(i) + 1000.0);
      }
    } else {
      for (int i=0; i<name.size(); i++) {
        float min = Float.POSITIVE_INFINITY;
        float max = Float.NEGATIVE_INFINITY;
        for (Ilities r: game) {
          if (min > r.value.get(i)) min = r.value.get(i);
          if (max < r.value.get(i)) max = r.value.get(i);
        }
        if (min != max) {
          minRange.add(min - 0.2*(max-min));
          maxRange.add(max + 0.2*(max-min));
        } else {
          minRange.add(min - 1000.0);
          maxRange.add(max + 1000.0);
        }
      }
    }
  }
}

class Ilities {
  ArrayList<Float> value;
  
  Ilities() {
    
  }
  
  Ilities(Table result) {
    value = new ArrayList<Float>();
    for (int i=0; i<result.getColumnCount(); i++) {
      float scaler = 1.0;
      if (i==1) scaler = 0.000001;
      value.add(scaler*result.getFloat (0, i));
    }
  }
}
