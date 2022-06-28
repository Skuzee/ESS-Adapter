// Coord Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Coord {
  public int X;
  public int Y;

  Coord(int X, int Y) {
    this.X = X;
    this.Y =Y;
  }
  
  Coord(Coord inputCoord) {
    this.X = inputCoord.X;
    this.Y =inputCoord.Y;
  }
  
}

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

// Select Transform ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void selectTransform() {
  switch (activeTransform) {

  case addition:
    transform = new addition();
    break;

  case subtraction:
    transform = new subtraction();
    break;
  }
}

// Transforms Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Transform {
  public Coord apply(Coord inputCoord);
}

public class addition implements Transform { // Addition 
  public Coord apply(Coord inputCoord) {
    return new Coord(inputCoord.X+10,inputCoord.Y+10);
  }
}

public class subtraction implements Transform { // Subtraction
  public Coord apply(Coord inputCoord) {
    return new Coord(inputCoord.X-10,inputCoord.Y-10);
  }
}

// List of Visualizers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public static enum ListOfVisualizers { 
  dots, lines;

  private static ListOfVisualizers[] vals = values();

  public static ListOfVisualizers first()
  {
    return vals[0];
  }

  public static int length()
  {
    return vals.length;
  }

  public ListOfVisualizers next()
  {
    return vals[(this.ordinal()+1) % vals.length];
  }
  public ListOfVisualizers prev()
  {
    return vals[(this.ordinal()+vals.length-1) % vals.length];
  }
}

// Select Visualizer ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void selectVisualizer() {
  switch (activeVisualizer) {

  case dots:
    visualizer = new LotsOfDots();
    break;

  case lines:
    visualizer = new ManyLines();
    break;
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
    ellipse(outputCoord.X, outputCoord.Y, 5, 5);
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
ListOfTransforms activeTransform;
Transform transform;

ListOfVisualizers activeVisualizer;
Visualizer visualizer;

Coord activeCoord;

// Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void setup() {
  size(200, 200);
  background(255);

  activeTransform = ListOfTransforms.first();
  activeVisualizer = ListOfVisualizers.first();
  println("TRANSFORM: " + activeTransform + " | VISUALIZER: " + activeVisualizer);
  transform = new addition();
  visualizer = new LotsOfDots();
  activeCoord = new Coord(100, 100);
}

// Draw ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void draw() {
  background(255);
  visualizer.display(activeCoord, transform);
}

// Mouse Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void mousePressed() {
  if (mouseButton==LEFT) {
    activeTransform = activeTransform.next();
    selectTransform();
  }

  if (mouseButton==RIGHT) {
    activeVisualizer = activeVisualizer.next();
    selectVisualizer();
  }
  
  println("TRANSFORM: " + activeTransform + " | VISUALIZER: " + activeVisualizer);  

}
