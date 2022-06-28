// List of Transforms ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

// Coord Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Coord {
  public int X;
  public int Y;

  Coord(int X, int Y) {
    this.X = X;
    this.Y =Y;
  }
}

// Transforms Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Transform {
  public Coord apply(Coord inputCoord);
}

public class addition implements Transform { // Addition 
  public Coord apply(Coord inputCoord) {
    inputCoord.X+=10;
    inputCoord.Y+=10;
    return inputCoord;
  }
}

public class subtraction implements Transform { // Subtraction
  public Coord apply(Coord inputCoord) {
    inputCoord.X-=10;
    inputCoord.Y-=10;
    return inputCoord;
  }
}

// Visualizer Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Visualizer {
  public void display(Coord inputCoord, Transform transform);
}

public class LotsOfDots implements Visualizer { // DOTS
  public void display(Coord inputCoord, Transform transform) {
    stroke(0);
    fill(0);
    Coord outputCoord = transform.apply(inputCoord);
    ellipse(inputCoord.X, inputCoord.Y, 5, 5);
    ellipse(inputCoord.X, inputCoord.Y, 5, 5);
  }
}

public class ManyLines implements Visualizer { // LINES
  public void display(Coord inputCoord, Transform transform) {
    stroke(0);
    noFill();
    Coord outputCoord = transform.apply(inputCoord);
    line(inputCoord.X, inputCoord.Y, outputCoord.X, outputCoord.Y);
  }
}

//Globals ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ListOfTransforms transformList;
Transform activeTransform;
Visualizer activeVisualizer;
Coord activeCoord;

// Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void setup() {
  size(200, 200);
  background(255);

  transformList = ListOfTransforms.first();
  println("TRANSFORM: " + transformList);
  activeTransform = new addition();
  activeVisualizer = new LotsOfDots();
  activeCoord = new Coord(100, 100);
}

// Draw ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void draw() {
  background(255);
  activeVisualizer.display(activeCoord, activeTransform);
}

// Mouse Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void mousePressed() {
  if (mouseButton==LEFT) {
    transformList = transformList.next();
  }

  if (mouseButton==RIGHT) {
    transformList = transformList.prev();
  }
  
  println("TRANSFORM: " + transformList);  
  selectTransform();
}

// Select Transform ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void selectTransform() {
  switch (transformList) {

  case addition:
    activeTransform = new addition();
    break;

  case subtraction:
    activeTransform = new subtraction();
    break;
  }
}
