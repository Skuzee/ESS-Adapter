/* This is a framework for a more complicated plotter / visualizer program.
 The program will take a SET of data points (analog stick coordinates) and apply
 a TRANSFORM to the coordinate (one at a time) and plot / display the output with
 a VISUALIZER. The design is modular such that any transform and any visualizer can 
 be used on any set of coordinate points. 
 Currently there is a Sequence class that holds a lists of Transforms and Visualizer objects.
 use NULL to skip transform or visualizations. 
 extending the Sequence class is a "pregen" a custom list of transforms/visualizer steps.
 calling singleElement(Coord, index) or iterateAll(Coord) will apply and display the steps.
 

 TODO: a way to open pregens from files.
 TODO: handle SETs either dynamically, or predefined data.
 TODO: make some array list of PREGEN transforms for known uses.
 pregen that is just one of each transform/visualizer for demo mode.
 ENUM of pregens: swap between pregens with keys.
 TODO:hand how color alpha and line size are store handled passed
 TODO: proximity? maybe local to vector field
 TODO: generalize render distance to mouse.
 
 
 */


// Imports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
import java.util.Iterator;

// Coord Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Coord {
  // signed -127 to 128
  private int X=0;
  private int Y=0;
  private float mag=0; // distance to origin

  public int scaledX=0; // scaled coord values for graphing porportional to window size and zoom level
  public int scaledY=0;
  public color HSBcolor = color(0, 100, 100);

  // Constructors
  Coord(){
  }
  
  Coord(int inputX, int inputY) { 
    this.setXY(inputX, inputY);
  } 

  Coord(Coord inputCoord) { 
    this.setXY(inputCoord.getX(), inputCoord.getY());
  }
  
  Coord(int inputX, int inputY, color inputColor) { 
    this.setXY(inputX, inputY);
    HSBcolor = inputColor;
  } 

  // Updater
  private void update() {
    scaledX = int(map(X, -127, 128, 0, width*zoom));
    scaledY = int(map(Y, -127, 128, height*zoom, 0));
    mag = sqrt(pow(X, 2) + pow(Y, 2));
  }

  public float distanceFrom(int inputX, int inputY) { 
    return sqrt(pow(inputX-scaledX, 2) + pow(inputY-scaledY, 2));
  }

  public float getMag() { 
    return mag;
  }
  
  public float distToCoord(Coord inputCoord) {
    return abs(this.mag - inputCoord.getMag());
  }

  public int getX() { 
    return X;
  }

  public int getY() { 
    return Y;
  }

  public void setXY(int inputX, int inputY) { 
    X = inputX; 
    Y = inputY; 
    this.update();
  }

  public void setX(int inputX) { 
    X = inputX; 
    this.update();
  }

  public void setY(int inputY) { 
    Y = inputY; 
    this.update();
  }

  public void incX() { 
    X++; 
    this.update();
  }

  public void incY() { 
    Y++; 
    this.update();
  }

  public void incX(int a) { 
    X+=a; 
    this.update();
  }

  public void incY(int a) { 
    Y+=a; 
    this.update();
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
      visualizer.display(outputCoord, zoom);
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
        visualizer.display(inputCoord, outputCoord, zoom);
      }
      //println("X1 " + inputCoord.X + " | Y1 " + inputCoord.Y + " | X2 " + outputCoord.X + " | Y2 " +outputCoord.Y);
    }
  }
}

// "Pregen" assembled lists of pregenerated transforms and visualizations ~~~~~~~~~~~~~~~~~~~~~
public class WiiVCmap extends Sequence {

  WiiVCmap() {
    //this.addElement(null, new LotsOfDots());  
    //this.addElement(new VCmap(), new VectorField());
    this.addElement(new VCmap(), new LotsOfDots());
    //this.addElement(null, new LotsOfDots());
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
    return new Coord(inputCoord.getX()+10, inputCoord.getY()+10);
  }
}

public class subtraction implements Transform { // Subtraction
  public Coord apply(Coord inputCoord) {
    return new Coord(inputCoord.getX()-10, inputCoord.getY()-10);
  }
}

public class VCmap implements Transform { // Subtraction
  public Coord apply(Coord inputCoord) {
    Coord outputCoord = new Coord();

    int signX = constrain(int(inputCoord.getX()), -1, 1);
    int signY = constrain(int(inputCoord.getY()), -1, 1);

    float outputX = ((inputCoord.getX() * signX)-15)*signX;
    outputX = int(outputX * 127 / 56); // trunc error is on purpose.
    outputX /= 127;
    outputX = 1 - sqrt(1 - abs(outputX));
    outputX *= 127;
    outputX *= signX;

    float outputY = ((inputCoord.getY() * signY)-15)*signY; 
    outputY = int(outputY * 127 / 56);
    outputY /= 127;
    outputY = 1 - sqrt(1 - abs(outputY));
    outputY *= 127;
    outputY *= signY;
    
    outputCoord.setXY(int(outputX), int(outputY));

    //int colorAlpha = int(constrain(100-100*inputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2)/(zoom*proximity)+10, 0, 100));
    outputCoord.HSBcolor = color(40-inputCoord.distToCoord(outputCoord)*2, 100, 100);
    return outputCoord;
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
  }
}

// Visualizer Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Visualizer {
  public void display(Coord inputCoord, int setting1);
  public void display(Coord inputCoord1, Coord inputCoord2, int setting1);
}

public class LotsOfDots implements Visualizer { // DOTS
  public void display(Coord inputCoord, int setting1) {
    noStroke();
    fill(inputCoord.HSBcolor);
    ellipse(inputCoord.scaledX, inputCoord.scaledY, setting1, setting1);
  }

  public void display(Coord inputCoord1, Coord inputCoord2, int setting1) {
    display(inputCoord2, setting1);
  }
}

public class VectorField implements Visualizer { // Draws a line from inputCoord1 to inputCoord2

  public void display(Coord inputCoord, int setting1) {
    println("Hey this needs two coords!");
    exit();
  }

  public void display(Coord inputCoord1, Coord inputCoord2, int setting1) {

    float dist = inputCoord1.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2);
    int lineAlpha = int(constrain(100-100*dist/(zoom*proximity)+10, 0, 100));

    if ((inputCoord2.getX()!=0) && (inputCoord2.getY()!=0) && (dist <= proximity*zoom) && (lineAlpha!=0)) {
      pushStyle();
      stroke(inputCoord2.HSBcolor, lineAlpha);
      strokeWeight(1+zoom);
      noFill();
      line(inputCoord1.scaledX, inputCoord1.scaledY, inputCoord2.scaledX, inputCoord2.scaledY);
      popStyle();
    }

    if (dist <= 2*zoom) {
      //inputCoord1.drawCoord(color(50,100,100));
      text("x" + inputCoord1.getX() + " y" + inputCoord1.getY(), inputCoord1.scaledX, inputCoord1.scaledY-3*zoom);
    }
  }
}

// Draw Axis Lines ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void drawAxisLines() {  
  // white x and Y axis lines
  pushStyle();
  stroke(0, 0, 120);
  strokeWeight(1);
  line((width-4)*zoom/2, 0, (width-4)*zoom/2, height*zoom);
  line(0, (height+4)*zoom/2, width*zoom, (height+4)*zoom/2);

  // white diagonal lines
  //line(0,4*zoom,width*zoom,(height+4)*zoom);
  //line(width*zoom,0,0,height*zoom);
  popStyle();
}

//Globals ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TypesOfTransforms activeTransform;
Transform transform;

TypesOfVisualizers activeVisualizer;
Visualizer visualizer;
Coord coord;

int zoom = 1;
int proximity = 200;

// Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void setup() {
  colorMode(HSB, 100, 100, 100, 100);
  size(1024, 1024);   
  background(0);

  activeTransform = TypesOfTransforms.first();
  selectTransform();
  activeVisualizer = TypesOfVisualizers.first();
  selectVisualizer();
  println("TRANSFORM: " + activeTransform + " | VISUALIZER: " + activeVisualizer);
  coord = new Coord();
}

// Draw ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void draw() {
  background(0);

  pushMatrix();
  translate(-mouseX*zoom+width/2, -mouseY*zoom+height/2);
  //translate(width/2,height/2);
  drawAxisLines();

  WiiVCmap test = new WiiVCmap();
  for (coord.setY(-100); coord.getY()<100; coord.incY(1)) {
    for (coord.setX(-100); coord.getX()<100; coord.incX(1)) {
      test.iterateDeep(coord);
    }
  }

  popMatrix();
}

// Mouse Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//void mousePressed() {
//  if (mouseButton==LEFT) {
//    activeTransform = activeTransform.next();
//    selectTransform();
//  }

//  if (mouseButton==RIGHT) {
//    activeVisualizer = activeVisualizer.next();
//    selectVisualizer();
//  }

//  println("TRANSFORM: " + activeTransform + " | VISUALIZER: " + activeVisualizer);
//}

void mouseClicked() {
  if (mouseButton==LEFT) {
    proximity+=5;
  }

  if (mouseButton==RIGHT) {
    proximity-=5;
  }
  proximity = constrain(proximity, 5, 200);
}

void mouseWheel(MouseEvent event) {
  zoom -= event.getCount();
  zoom = constrain(zoom, 1, 40);
}
