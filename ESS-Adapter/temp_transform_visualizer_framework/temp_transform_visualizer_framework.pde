/* This is a framework for a more complicated plotter / visualizer program.
The program will take a SET of data points (analog stick coordinates) and apply
a TRANSFORM to the coordinate (one at a time) and plot / display the output with
a VISUALIZER. The design is modular such that any transform and any visualizer can 
be used on any set of coordinate points. 
Currently there is a Sequence class that holds a lists of Transforms and Visualizer objects.
use NULL to skip transform or visualizations. 
extending the Sequence class is a "pregen" a custom list of transforms/visualizer steps.
calling singleElement(Coord, index) or iterateAll(Coord) will apply and display the steps.
 
TODO: replace "types of transforms/visualizers" with enum list of pregens. 
  Currently need to list func name in enem, in switch, and define it in a class.
  Would prefer to only define and add to enum.
TODO: a way to open pregens from files.
TODO: handle SETs either dynamically, or predefined data.
 still need to decide who is going to be in change of deep vs broad data generation and call sequence elements
TODO: make some array list of PREGEN transforms for known uses.
TODO: copy over transforms and displays
TODO: handle drawing lines? might need to pass 2 coords to all visualizers just in case it need the next one?
  or allow visualizer to call the next transform (temporarily or permanently)
TODO: scale output of visualizers to screen pixel values.
TODO: pregen that is just one of each transform/visualizer for demo mode.

 */


// Imports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
import java.util.Iterator;  // Import the class of Iterator

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

// Sequence Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Sequence {
  private ArrayList<Transform> transformList = new ArrayList<Transform>();
  private ArrayList<Visualizer> visualizerList = new ArrayList<Visualizer>();
  
  public void addElement(Transform transform, Visualizer visualizer) {
    transformList.add(transform);
    visualizerList.add(visualizer);
  }
  
  public void singleElement(Coord inputCoord, int index) {
    Coord outputCoord = inputCoord; // Transform returns new coord as to not accidentally edit original inputCoord by reference.
      Transform transform = transformList.get(index);
      if (transform != null) {
        outputCoord = transform.apply(outputCoord); // applies transforms sequentially while preserving original inputCoord object.
      }
      
      Visualizer visualizer = visualizerList.get(index);
      if ((visualizer != null)) {
        visualizer.display(outputCoord, 1);
      }
      //println("X1 " + inputCoord.X + " | Y1 " + inputCoord.Y + " | X2 " + outputCoord.X + " | Y2 " +outputCoord.Y);
  }
  
  public void iterateDeep(Coord inputCoord) { // Applies all Transforms and Visualizations to a single Coord before continuing.
    Iterator<Transform> transformIterator = transformList.iterator();
    Iterator<Visualizer> visualizerIterator = visualizerList.iterator();
    Coord outputCoord = inputCoord; // Transform returns new coord as to not accidentally edit original inputCoord by reference.
    
    
    while (transformIterator.hasNext() && visualizerIterator.hasNext()) {
      Transform transform = transformIterator.next();
      if (transform != null) {
        outputCoord = transform.apply(outputCoord); // applies transforms sequentially while preserving original inputCoord object.
      }
      
      Visualizer visualizer = visualizerIterator.next();
      if ((visualizer != null)) {
        visualizer.display(outputCoord, 1);
      }
      //println("X1 " + inputCoord.X + " | Y1 " + inputCoord.Y + " | X2 " + outputCoord.X + " | Y2 " +outputCoord.Y);
    }
  }
}

// "Pregen" assembled lists of pregenerated transforms and visualizations ~~~~~~~~~~~~~~~~~~~~~
public class WiiVCmap extends Sequence {
  private Coord myCoord = new Coord(100,100);

  WiiVCmap() {
    this.addElement(null,new LotsOfDots());  
    this.addElement(new addition(),new LotsOfDots());
    this.addElement(new addition(),new LotsOfDots());
    this.addElement(new addition(),new LotsOfDots());
    //this.singleElement(myCoord, 1);
  }
}

// Types of Transforms ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public static enum TypesOfTransforms { 
  addition, subtraction;

  private static TypesOfTransforms[] vals = values();

  public static TypesOfTransforms first()
  {
    return vals[0];
  }

  public static int length()
  {
    return vals.length;
  }

  public TypesOfTransforms next()
  {
    return vals[(this.ordinal()+1) % vals.length];
  }
  public TypesOfTransforms prev()
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

// Types of Visualizers ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public static enum TypesOfVisualizers { 
  dots, lines;

  private static TypesOfVisualizers[] vals = values();

  public static TypesOfVisualizers first()
  {
    return vals[0];
  }

  public static int length()
  {
    return vals.length;
  }

  public TypesOfVisualizers next()
  {
    return vals[(this.ordinal()+1) % vals.length];
  }
  public TypesOfVisualizers prev()
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
  public void display(Coord inputCoord, int setting1);
}

public class LotsOfDots implements Visualizer { // DOTS
  public void display(Coord inputCoord, int setting1) {
    stroke(0);
    fill(0);
    ellipse(inputCoord.X, inputCoord.Y, setting1, setting1);
  }
}

public class ManyLines implements Visualizer { // LINES
  public void display(Coord inputCoord, int setting1) {
    stroke(0);
    noFill();

    // Need to call next transform in list?

    // line(inputCoord.X, inputCoord.Y, outputCoord.X, outputCoord.Y);
  }
}

//Globals ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TypesOfTransforms activeTransform;
Transform transform;

TypesOfVisualizers activeVisualizer;
Visualizer visualizer;
Coord coord;

// Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void setup() {
  size(200, 200);
  background(255);

  activeTransform = TypesOfTransforms.first();
  selectTransform();
  activeVisualizer = TypesOfVisualizers.first();
  selectVisualizer();
  println("TRANSFORM: " + activeTransform + " | VISUALIZER: " + activeVisualizer);

}

// Draw ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void draw() {
  background(255);
  coord = new Coord(-127,127);
  
  WiiVCmap test = new WiiVCmap();
  for (coord.Y=-127; coord.Y<128;coord.Y+=2) {
    for (coord.X=-127; coord.X<128;coord.X+=2) {
      test.iterateDeep(coord);
    }
  }
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
