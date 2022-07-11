/* This is a framework for a more complicated plotter / visualizer program.
 The program will take a SET of data points (analog stick coordinates) and apply
 a TRANSFORM to the coordinate (one at a time) and plot / display the output with
 a VISUALIZER. The design is modular such that any transform and any visualizer can 
 be used on any set of coordinate points. 
 Currently there is a Sequence class that holds a lists of Transforms and Visualizer objects.
 use NULL to skip transform or visualizations. 
 extending the Sequence class is a "Pregen" a custom list of transforms/visualizer steps.
 calling singleElement(Coord, index) or iterateAll(Coord) will apply and display the steps.
 
 a Pregen might look something like this:
 this.addElement(null,         new SolidColor,      new PlotAsPoints()); // No transform, change color scheme, display intial coordinate points as dots.
 this.addElement(new trans1(), new Gradient_Mag_Fade(), new VectorField());  // apply first transform, change color scheme, display as lines.  
 this.addElement(null,         new Solid_Fade(),    new PlotAsPoints()); // No transform, change color scheme, display coordinate points as dots.
 
 isRendered is a property of each coord and is calc each time coord is updated 
 Color is calculated by coloreScheme, stored in outputCoord
 Alpha is calculated by colorScheme, stored in outputCoord
 
 
 TODO: a way to open Pregens from files.
 TODO: make some array list of Pregen transforms for known uses.
 -Pregen that is just one of each transform/visualizer for demo mode.
 TODO: inputCoord to visualizer is the ORIGINAL coords, and not the sequential coords. this might be an issue for multi-transformed visuals.
 -might want to pass the previous output as next input.
 -seems to work as-is for now. sequential transforms are additive.
 
 TODO: FIX XY diagonal visualizer for monotonic test.
 TODO: consider a FORCERENDER option for visualizer?
 
 
 */
// Imports ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
import java.util.Iterator;

//Globals ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
int zoom = 1;
int renderDistance = 256;
Pregen pregen;
Coord coord = new Coord();
long startTime = 0;
TypesOfPregens activePregen;

// Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
final int WINDOW_WIDTH = 1024;
final int WINDOW_HEIGHT = 1024;
final int DISPLAY_X_RANGE = 128; // full range will be from -(RANGE) to +(RANGE)
final int DISPLAY_Y_RANGE = 128; // full range will be from -(RANGE) to +(RANGE)

void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT, P3D);
}

// Setup ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void setup() { 
  ortho();
  colorMode(HSB, 100, 100, 100, 100);
  background(0);
  activePregen = TypesOfPregens.first();
  selectPregen();
  //Pregen = new Pregen_MonotonicXYPlot();
}

// Draw ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void draw() {
  background(0);

  pushMatrix();
  translate(width/2, height/2);
  translate((-mouseX+width/2)*zoom, (-mouseY+height/2)*zoom);
  //rotateX(PI/4);
  drawAxisLines();

  //for (coord.setY(-100); coord.getY()<=100; coord.incY(1)) {
  //for (coord.setX(-100); coord.getX()<=100; coord.incX(1)) {
  //println(millis() - startTime);

  pregen.run(coord);

  //startTime = millis();
  //Pregen_MonotonicXYPlot test = new Pregen_MonotonicXYPlot();
  //test.iterateDeep();
  //for (coord.setXY(0,0); coord.getX()<=128; coord.incXY()) {
  //  test.iterateDeep(coord);
  //}

  popMatrix();
}

// Draw Axis Lines ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void drawAxisLines() {  
  // white x and Y axis lines
  pushStyle();
  stroke(0, 0, 120);
  strokeWeight(1);
  line(-(width)*zoom/2, 0, (width)*zoom/2, 0);
  line(0, (height)*zoom/2, 0, -(height)*zoom/2);

  // white diagonal lines
  //line(0,4*zoom,width*zoom,(height+4)*zoom);
  //line(width*zoom,0,0,height*zoom);
  popStyle();
}
