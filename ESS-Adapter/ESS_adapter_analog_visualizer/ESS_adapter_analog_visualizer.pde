//plots various controller coordinates in different colors to compare the effects of ess and notch calibration
// My notches 
// NE 77,80
// NW -70,79
// SW -72,-76
// SE 78,-78

// Graph colors:
//Red is raw controller data
//Orange is After Notch Calibration
//Yellow is after ESS (if enabled)
//Green is calculaton of "After VC" should match the in-game values in gz.
//Pink the best guess value of physical notch 'furthest' spot away from the origin for each corner.
//Purple The manual values entered in myNotches[]. use the pink to find what a good value is for your controller.
//Then enter values into myNotches[].

//Mouse to move graph around and zoom wheel to zoom in/out for closer analysis.

//Run program once. Look at serial list number. enter that value into line 98.

import processing.serial.*;

// GZ values of physical gate corner notches. Q1, Q2, Q3, Q4
int myNotches[] = {77,80, -70,79, -72,-76, 78,-78};

// Class that stores a coordinate point and useful information about that point including scaled coordinates for graphing, and text color
public class Coord {
  // signed -127 to 128
  private int X=0;
  private int Y=0;
  private int mag=0; // squared distance to origin
  
  private int graphX=0;
  private int graphY=0;
  public int graphTagX=0;
  public int graphTagY=0;
  
  public int tagOffset;
  public color tagColor;
  public int dotSize = 10;
  
  Coord(int inputOffset, color inputColor,int inputSize) {
    tagOffset = inputOffset;
    tagColor = inputColor;
    dotSize = inputSize;
  } 
  
  public void setCoords(int inputX, int inputY){
    X = inputX;
    Y = inputY;
    mag = int(pow(X,2) + pow(Y,2)); 
  }
  
  public void drawCoord(){
    updateGraphCoords();
    pushStyle();
    noStroke();
    fill(tagColor);
    ellipse(graphX,graphY,dotSize*(zoom+2)/3.0,dotSize*(zoom+2)/3.0);
    text("x" + graphTagX + " y" + graphTagY,graphX+5*zoom+5,graphY+tagOffset);
    popStyle();
  }
  
  private void updateGraphCoords() { // maps the analog stick coord to the screen range * zoom level
    graphX = int(map(X,-127,128,0,width*zoom));
    graphY = int(map(Y,-127,128,height*zoom,0));
    graphTagX = X;
    graphTagY = Y;
  }
  
  int getMag() {
    return mag;
  }
  
  int getX() {
    return X;
  }
  
  int getY() {
    return Y;
  }
} //<>//

// arrays of notch values, true and perfect, used for graphing.
Coord cornerNotches[] = new Coord[4]; // Guesstimation of where corner notches are
Coord actualCornerNotches[] = new Coord[4]; //GZ values, set from myNotches[]
Coord cardinalNotches[] = new Coord[4]; // Guesstimation of where cardinal notches are
Coord graphs[] = new Coord[4];
int displayValues[] = new int[8];

Serial myPort;  // Create object from Serial class
String serialString;     // Data received from the serial port
int zoom = 1;
int notchFocus =0;


void setup()
{
  initCoords();
  printArray(Serial.list());
  String portName = Serial.list()[2]; //change the 0 to a 1 or 2 etc. to match your port <<<<<<<<<<<<<<
  myPort = new Serial(this, portName, 115200);
  
  size(1024, 1024);        
  
  background(0);
  noStroke();
  frameRate(120);
  textSize(15);
}

void draw()
{
  
  pushMatrix();
  //translate(-1*actualCornerNotches[notchFocus].graphX+width/2,-1*actualCornerNotches[notchFocus].graphY+height/2);
  translate(-mouseX*zoom+width/2,-mouseY*zoom+height/2);
  background(0);

  drawLines();
  drawBullseye();
  notchOutline();
   
  for(int i=0; i<actualCornerNotches.length;i++) {
    actualCornerNotches[i].drawCoord();
  }
   
  for(int i=0; i<cornerNotches.length;i++) {
    cornerNotches[i].drawCoord();
  }
  
  for(int i=0; i<cardinalNotches.length;i++) {
    cardinalNotches[i].drawCoord();
  }
  
  graphs[3].setCoords(applyVCmap(graphs[2].graphTagX),applyVCmap(graphs[2].graphTagY));
  
  for(int i=0; i<graphs.length;i++) {
    graphs[i].drawCoord();
  }
  
  popMatrix();
   drawDebugValues();
   setLocalDebugValue(cornerNotches[0].getMag(),4);
  
}

void drawLines(){  
  // white coordinates and diagonals
  pushStyle();
  stroke(0,0,120);
  strokeWeight(1);
  line((width-4)*zoom/2,0,(width-4)*zoom/2,height*zoom);
  line(0,(height+4)*zoom/2,width*zoom,(height+4)*zoom/2);
  line(0,4*zoom,width*zoom,(height+4)*zoom);
  line(width*zoom,0,0,height*zoom);

}

void drawBullseye() {
  if(zoom > 2) {
    pushStyle();
    stroke(0,0,120);
    noFill();
    strokeWeight(1);
    for (int i = 0; i < graphs.length; i++) {
      rect(graphs[i].graphX,graphs[i].graphY-4*zoom,4*zoom,4*zoom);
      rect(graphs[i].graphX-4*zoom,graphs[i].graphY-4*zoom,4*zoom,4*zoom); 
      rect(graphs[i].graphX-4*zoom,graphs[i].graphY,4*zoom,4*zoom); 
      rect(graphs[i].graphX,graphs[i].graphY,4*zoom,4*zoom); 
    }
    popStyle();
  }
}

void notchOutline(){
  pushStyle();
  stroke(0,0,120);
  strokeWeight(1);

  for (int i = 0; i < 3; i++) {
     line(cardinalNotches[i].graphX,cardinalNotches[i].graphY,cornerNotches[i].graphX,cornerNotches[i].graphY);
     line(cornerNotches[i].graphX,cornerNotches[i].graphY,cardinalNotches[i+1].graphX,cardinalNotches[i+1].graphY);
  }
     line(cardinalNotches[3].graphX,cardinalNotches[3].graphY,cornerNotches[3].graphX,cornerNotches[3].graphY);
     line(cornerNotches[3].graphX,cornerNotches[3].graphY,cardinalNotches[0].graphX,cardinalNotches[0].graphY);
  popStyle();
}

// Reads in serial data. Expects 'S' Staring bit and 'E' Ending bit. ' ' Is delimiter.
// currently it is receiving 12 bytes of data, 2x3 (6bytes) x,y graph coordinates, and 4 bytes of general debug values.
void serialEvent (Serial myPort) {
  serialString = myPort.readStringUntil('\n');
  if (serialString != null) {
    serialString = trim(serialString);

    char startChar = serialString.charAt(0);
    char endChar = serialString.charAt(serialString.length()-1);
    
    if ((startChar == 'S') && (endChar == 'E')) {
      int[] serialArray = int(split(serialString, ' '));
      
      for (int i=0; i<6; i+=2) {
        graphs[i/2].setCoords(serialArray[i+1]-128,serialArray[i+2]-128);
      }
      for (int i=6; i<10; i++) {
        displayValues[i]=serialArray[i];
      }

      compareCornerNotches(graphs[0]);
      compareCardinalNotches(graphs[0]);
    }
    
  }
}

void compareCornerNotches(Coord current){
  // Q1
  if ((current.graphTagX > 65) && (current.graphTagY > 65) && (current.getMag() > cornerNotches[0].getMag())) {
    cornerNotches[0].setCoords(current.graphTagX,current.graphTagY);
  }
  // Q2
  else if ((current.graphTagX < -65) && (current.graphTagY > 65) && (current.getMag() > cornerNotches[1].getMag())) {
    cornerNotches[1].setCoords(current.graphTagX,current.graphTagY);
  }
  // Q3
  else if ((current.graphTagX < -65) && (current.graphTagY < -65) && (current.getMag() > cornerNotches[2].getMag())) {
    cornerNotches[2].setCoords(current.graphTagX,current.graphTagY);
  }
  // Q4
  else if ((current.graphTagX > 65) && (current.graphTagY < -65) && (current.getMag() > cornerNotches[3].getMag())) {
    cornerNotches[3].setCoords(current.graphTagX,current.graphTagY);
  }
}

void compareCardinalNotches(Coord current){
  // East 0
  if (current.graphTagX > cardinalNotches[0].graphTagX) {
    cardinalNotches[0].setCoords(current.graphTagX,current.graphTagY);
  }
  else if((current.graphTagX == cardinalNotches[0].graphTagX) && (abs(current.graphTagY) < abs(cardinalNotches[0].graphTagY))) {
    cardinalNotches[0].setCoords(current.graphTagX,current.graphTagY);
  }
  
  // North 1
  if (current.graphTagY > cardinalNotches[1].graphTagY) {
    cardinalNotches[1].setCoords(current.graphTagX,current.graphTagY);
  }
  else if((current.graphTagY == cardinalNotches[1].graphTagY) && (abs(current.graphTagX) < abs(cardinalNotches[1].graphTagX))) {
    cardinalNotches[1].setCoords(current.graphTagX,current.graphTagY);
  }
  
  // West 2
  if (current.graphTagX < cardinalNotches[2].graphTagX) {
    cardinalNotches[2].setCoords(current.graphTagX,current.graphTagY);
  }
  else if((current.graphTagX == cardinalNotches[2].graphTagX) && (abs(current.graphTagY) < abs(cardinalNotches[2].graphTagY))) {
    cardinalNotches[2].setCoords(current.graphTagX,current.graphTagY);
  }
  
  // South 3
  if (current.graphTagY < cardinalNotches[3].graphTagY) {
    cardinalNotches[3].setCoords(current.graphTagX,current.graphTagY);
  }
  else if((current.graphTagY == cardinalNotches[3].graphTagY) && (abs(current.graphTagX) < abs(cardinalNotches[3].graphTagX))) {
    cardinalNotches[3].setCoords(current.graphTagX,current.graphTagY);
  }
}

void initCoords() {
  colorMode(HSB, 120);
  
  for(int i =0; i<actualCornerNotches.length;i++) {
    actualCornerNotches[i]= new Coord(-30,color(85,120,120), 18);
    actualCornerNotches[i].setCoords(myNotches[i*2],myNotches[i*2+1]);
  }
  
  for(int i =0; i<cornerNotches.length;i++) {
    cornerNotches[i]= new Coord(0,color(100,120,120), 15);
    cornerNotches[i].setCoords(0,0);
  }
    
  for(int i =0; i<cardinalNotches.length;i++) {
    cardinalNotches[i]= new Coord(0,color(100,120,120), 15);
    cardinalNotches[i].setCoords(0,0);
  }
  
  for(int i =0; i<graphs.length;i++) {
    graphs[i]= new Coord(-15+(i*15),color(i*10,120,120), 13-(i*3));
    graphs[i].setCoords(0,0);
  }
}

void setLocalDebugValue(int inputVal, int position) {
 displayValues[position] = inputVal;
}

void drawDebugValues() {
  pushStyle();
  noStroke();
  fill(#ff0000);
  for(int i=0; i<displayValues.length;i++) {
    text(displayValues[i],20,(1+i)*20);
  }
  popStyle();
}

void mouseWheel(MouseEvent event) {
  zoom -= event.getCount();
  zoom = constrain(zoom,1,40);
}

int applyVCmap(int input) {
  int sign = constrain(int(input),-1,1);
  input = ((input * sign)-15)*sign; 
  float output = int(input * 127 / 56);
  output /= 127;
  output = 1 - sqrt(1 - abs(output));
  output *= 127;
  //output = constrain(output,0,127);
  output *= sign;
  

  return int(output);
}