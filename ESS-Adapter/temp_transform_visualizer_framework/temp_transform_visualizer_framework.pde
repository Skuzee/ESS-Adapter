public static enum ListOfTransforms { 
  addition, subtraction;
  
  private static ListOfTransforms[] vals = values();
  
  public static ListOfTransforms first()
  {
    return vals[0];
  }
  
  public static int length()
  {
    return vals.length;
  }
  
  public ListOfTransforms next()
  {
    return vals[(this.ordinal()+1) % vals.length];
  }
  public ListOfTransforms prev()
  {
    return vals[(this.ordinal()+vals.length-1) % vals.length];
  }
}

public class Coord {
  public int X;
  public int Y;
  
  Coord(int X, int Y) {
    this.X = X;
    this.Y =Y;
  }
}


public interface Transform {
    public Coord apply(Coord inputCoord);
}

public class addition implements Transform {

    public Coord apply(Coord inputCoord) {
      inputCoord.X+=10;
      inputCoord.Y+=10;
      return inputCoord;
    }
}

public class subtract implements Transform {

    public Coord apply(Coord inputCoord) {
      inputCoord.X-=10;
      inputCoord.Y-=10;
      return inputCoord;
    }
}


public interface Visualizer {
    public void display(Coord inputCoord, Transform transform);
}

public class LotsOfDots implements Visualizer {

    public void display(Coord inputCoord, Transform transform) {
      stroke(0);
      noFill();
      ellipse(inputCoord.X,inputCoord.Y,5,5);
      transform.apply(inputCoord);
      ellipse(inputCoord.X,inputCoord.Y,5,5);
    }
}

public class ManyLines implements Visualizer {

    public void display(Coord inputCoord, Transform transform) {
      stroke(0);
      noFill();
      Coord outputCoord = transform.apply(inputCoord);
      line(inputCoord.X,inputCoord.Y,outputCoord.X,outputCoord.Y);
    }
}


ListOfTransforms transformList;
Transform activeTransform;
Visualizer activeVisualizer;
Coord activeCoord;

void setup() {
  size(200,200);
  background(255);
  
  transformList = ListOfTransforms.first();
  activeTransform = new addition();
  activeVisualizer = new ManyLines();
  activeCoord = new Coord(100,100);
}

void draw() {
  activeVisualizer.display(activeCoord, activeTransform);
}

void mousePressed() {
  if (mouseButton==LEFT) {
    transformList = transformList.next();
    println("TRANSFORM: " + transformList);
  }
  
  if (mouseButton==RIGHT) {
    transformList = transformList.prev();
    println("TRANSFORM: " + transformList);
  }
}
