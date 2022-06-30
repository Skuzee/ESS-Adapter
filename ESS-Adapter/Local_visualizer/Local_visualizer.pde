// Local calculations and plotter / visualizer. //<>//
// Sweeps through all 256x256 values and calculates different maps.
// Used to test and visualize different algorithems for ESS Maps, Notch Calibrations, Etc.

// MAPS:
// 1: Standard 256x256 plot.
// 2: Invert VC (ESS Map)
// 3: N64 scale transform
// 4: VC reachable values.
// 5: Notch Gravity
// 6: Notch Snapping

// My notches 
// NE 77,80
// NW -70,79
// SW -72,-76
// SE 78,-78

// Class that stores a coordinate point and useful information about that point including scaled coordinates for graphing, and text color
public class Coord {
  // signed -127 to 128
  private int X=0;
  private int Y=0;
  public float mag=0; // distance to origin
  
  public int scaledX=0; // scaled coord values for graphing porportional to window size and zoom level
  public int scaledY=0;
  //public float distFromDiag=0; // 1/2 the difference of abs x and abs y
  public int dotSize = 3;
  
  Coord(int inputX, int inputY) {
    this.setXY(inputX, inputY);
  } 
  
  public void setXY(int inputX, int inputY){
    X = inputX;
    Y = inputY;
    
    scaledX = int(map(X,-127,128,0,width*zoom));
    scaledY = int(map(Y,-127,128,height*zoom,0));
    
    mag = sqrt(pow(X,2) + pow(Y,2));
    //distFromDiag = abs(abs(X) - abs(Y))/2.0;
  }
  
  public void drawCoord(color inputColor){
    pushStyle();
    noStroke();
    fill(inputColor);
    ellipse(scaledX,scaledY,dotSize*(zoom+2)/3.0,dotSize*(zoom+2)/3.0);
    popStyle();
  }
  
  float distanceFrom(int inputX,int inputY) {
     return sqrt(pow(inputX-scaledX,2) + pow(inputY-scaledY,2));
  }
  
  float getMag() {
    return mag;
  }
  
  int getX() {
    return X;
  }
  
  int getY() {
    return Y;
  }
}

Coord workingCoord = new Coord(0,0);
float displayValues[] = new float[8];

int zoom = 1;
int proximity = 5;
int lineBrightness = 50;

int lastx[] = {0,0};
int lasty[] = {0,0};

void setup()
{
  size(1024, 1024);        
  
  colorMode(HSB, 256, 100, 100);
  frameRate(10);
  
  background(0);
  noStroke();
  frameRate(120);
  textSize(15);

}

void draw()
{
  pushMatrix();
  translate(-mouseX*zoom+width/2,-mouseY*zoom+height/2);
  background(0);
  drawAxisLines();
  //drawDeadzone15();
  
// draw here~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  drawVCVectorField();
  
  popMatrix();
  
  //setLocalDebugValue(graphs[0].getMag(),4);
  drawDebugValues();
}

void drawAxisLines(){  
  // white coordinates and diagonals
  pushStyle();
  stroke(0,0,120);
  strokeWeight(1);
  line((width-4)*zoom/2,0,(width-4)*zoom/2,height*zoom);
  line(0,(height+4)*zoom/2,width*zoom,(height+4)*zoom/2);
  line(0,4*zoom,width*zoom,(height+4)*zoom);
  line(width*zoom,0,0,height*zoom);
  popStyle();
}

void drawDeadzone15(){
  pushStyle();
  stroke(0,0,120);
  strokeWeight(1);
  int deadZoneBound = int(map(15,-127,128,0,width*zoom));
  line(deadZoneBound,deadZoneBound,deadZoneBound,-deadZoneBound);
  popStyle();
}

void lineFromTo(Coord inputFrom, Coord inputTo) {
  pushStyle();
  stroke(64-abs(inputFrom.mag-inputTo.mag)*2,100,100,lineBrightness);
  strokeWeight(1+zoom);
  noFill();
  line(inputFrom.scaledX, inputFrom.scaledY, inputTo.scaledX, inputTo.scaledY);
  popStyle(); 
}

void drawVCVectorField(){
  displayValues[0] = float(proximity);
  Coord VCcoord = new Coord(0,0);
  
  for (int yValue=-127; yValue<128;yValue+=1) {
    for (int xValue=-127; xValue<128;xValue+=1) {
      workingCoord.setXY(xValue,yValue);

      VCcoord.setXY(VCmapTransform(xValue),VCmapTransform(yValue));

      float dist = workingCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2);
      lineBrightness = int(constrain(100-100*dist/(zoom*proximity),0,100));
      
      if ((VCmapTransform(xValue)!=0) && (VCmapTransform(yValue)!=0) && (dist <= proximity*zoom) && (lineBrightness>0)) { // && (lineBrightness>=25)
        println(lineBrightness);
        //workingCoord.drawCoord(color(50,100,100));
        lineFromTo(workingCoord,VCcoord);
        VCcoord.drawCoord(color(25,100,100,lineBrightness));
      }
      
      if (dist <= 2*zoom) {
        workingCoord.drawCoord(color(50,100,100));
        text("x" + workingCoord.getX() + " y" + workingCoord.getY(),workingCoord.scaledX,workingCoord.scaledY-3*zoom);
      }
      
    }  
  } 
}


//void drawVectorField(function<int(int)> transform) {
//  Coord primary = new Coord(0,0);
//  Coord secondary = new Coord(0,0);
  
//  for (int yValue=-127; yValue<128;yValue+=1) {
//    for (int xValue=-127; xValue<128;xValue+=1) {
//      primary.setXY(xValue,yValue);

//      secondary.setXY(VCmapTransform(xValue),VCmapTransform(yValue));

//      if ((VCmapTransform(xValue)!=0) && (VCmapTransform(yValue)!=0) && (primary.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2) <= 20*zoom)) {
//        //primary.drawCoord(color(50,100,100));
//        lineFromTo(primary,VCcoord);
//        secondary.drawCoord(color(25,100,100));
//      }
      
//      if ((primary.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2) <= 2*zoom)) {
//        primary.drawCoord(color(50,100,100));
//        text("x" + primary.getX() + " y" + primary.getY(),primary.scaledX,primary.scaledY-3*zoom);
//        secondary.drawCoord(color(25,100,100));
//        text("x" + secondary.getX() + " y" + secondary.getY(),secondary.scaledX,secondary.scaledY-3*zoom);
//      }
      
//    }  
//  } 
//}


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

int VCmapTransform(int input) {
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

void mouseClicked() {
  if (mouseButton==LEFT) {
    proximity+=5;
  }

  if (mouseButton==RIGHT) {
    proximity-=5;
  }
  proximity = constrain(proximity, 5,200);
}
