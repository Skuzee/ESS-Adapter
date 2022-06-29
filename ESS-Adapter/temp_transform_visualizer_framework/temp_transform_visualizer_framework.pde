/* This is a framework for a more complicated plotter / visualizer program.
 The program will take a SET of data points (analog stick coordinates) and apply
 a TRANSFORM to the coordinate (one at a time) and plot / display the output with
 a VISUALIZER. The design is modular such that any transform and any visualizer can 
 be used on any set of coordinate points. Example:
 visualizer.display(coord, transform); 
 Displays the current coord, then applies the transform and displays the result.
 
 TODO: Figure out how to turn a list of func names into a call to that function.
 Currently need to list func name in enem, in switch, and define it in a class.
 Would prefer to only define and add to enum.
 TODO: handle SETs either dynamically, or simply.
 TODO: make VISUALIZER take arrays of transforms[] and apply them one after another.
 maybe an array of enum and then just interate and select the tranform each loop!
 maybe split transform from visualizer so I can call visualizer after each of many transforms.
 TODO: make some array list of PREGEN transforms for known uses.
 TODO: DEEP vs BROAD transform visualization. 
 All transforms one point at a time, or
 all points one transform at a time?
 */

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
    return new Coord(inputCoord.X+10, inputCoord.Y+10);
  }
}

public class subtraction implements Transform { // Subtraction
  public Coord apply(Coord inputCoord) {
    return new Coord(inputCoord.X-10, inputCoord.Y-10);
  }
}

// Array of Transform test ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void interatePREGEN (ListOfTransforms[] transformArray, ListOfVisualizers[] VisualizerArray) {
  for (ListOfTransforms currentTransform : transformArray) {
    activeTransform = currentTransform;
    selectTransform();
    visualizer.display(coord, transform);
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

Coord coord;

// Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void setup() {
  size(200, 200);
  background(255);

  activeTransform = ListOfTransforms.first();
  selectTransform();
  activeVisualizer = ListOfVisualizers.first();
  selectVisualizer();
  println("TRANSFORM: " + activeTransform + " | VISUALIZER: " + activeVisualizer);

  coord = new Coord(100, 100);
}

// Draw ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void draw() {
  background(255);
  visualizer.display(coord, transform);
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
