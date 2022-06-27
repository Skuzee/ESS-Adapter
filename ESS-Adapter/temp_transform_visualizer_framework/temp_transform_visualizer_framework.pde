public class Coord {
  public int X;
  public int Y;
  
  Coord(int X, int Y) {
    this.X = X;
    this.Y =Y;
  }
}


public enum Transform {
  ADD {
    public Coord apply(Coord inputCoord) {
      inputCoord.X+=10;
      inputCoord.Y+=10;
      return inputCoord;
    }
  },
  SUB {
    public Coord apply(Coord inputCoord) {
      inputCoord.X+=10;
      inputCoord.Y+=10;
      return inputCoord;
    }
  };



Transform activeTransform;
//Visualize activeVisualizer;

void setup() {
  activeTransform = Transform.ADD;
  //activeVisualizer = Visualize._DOTS;
  Coord activeCoord = new Coord(1,1);
  
 //activeVisualizer.DRAW(activeCoord, activeTransform);
}

void draw() {

}
