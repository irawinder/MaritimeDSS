class GamePlot {
  ArrayList<Ilities> game;
  ArrayList<String> name;
  
  GamePlot() {
    game = new ArrayList<Ilities>();
    name = new ArrayList<String>();
  }
  
  void addResult(Table result) {
    Ilities i = new Ilities(result);
    game.add(i);
  }
  
}

class Ilities {
  ArrayList<Float> value;
  
  Ilities(Table result) {
    value = new ArrayList<Float>();
    for (int i=0; i<result.getColumnCount(); i++) {
      value.add(result.getFloat (0, i));
    }
  }
}
