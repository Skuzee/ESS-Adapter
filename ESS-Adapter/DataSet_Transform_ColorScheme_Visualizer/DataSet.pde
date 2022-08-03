// DataSet Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface DataSet {
  public boolean next(Coord coord);
  public void reset();
}

public class SweepXY implements DataSet { // Subtraction
  private int minX=-128; 
  private int maxX=127; 
  private int stepX=1; 
  private int indexX=minX;

  private int minY=-128; 
  private int maxY=127; 
  private int stepY=1;
  private int indexY=minY;

  SweepXY() {
  }

  SweepXY(int stepXY) {
    this.stepX=stepXY; 
    this.stepY=stepXY;
  }

  SweepXY(int minX, int maxX, int stepX, int minY, int maxY, int stepY) {
    this.minX=minX; 
    this.maxX=maxX; 
    this.stepX=stepX; 
    this.indexX=minX;

    this.minY=minY; 
    this.maxY=maxY; 
    this.stepY=stepY;
    this.indexY=minY;
  }

  public boolean next(Coord coord) {
    coord.setXY(indexX, indexY);

    indexX+=stepX;

    if (indexX>maxX) {
      indexX=minX;
      indexY+=stepY;

      if (indexY>maxY) {
        indexY=minY;
        return false;
      }
    }
    return true;
  }


  public void reset() {
    indexX=minX;
    indexY=minY;
  }
}

public class SweepRadar_Angle implements DataSet { // Subtraction
  private int maxMag=127; 
  private int mag=0;
  private int stepMag=1;
  private float angle=0;
  private int angleResolution=360;
  private float stepAngle = 360/angleResolution;

  private int outputX=0;
  private int outputY=0;

  public boolean next(Coord coord) {
    outputX = int(sin(radians(angle))*mag);
    outputY = int(cos(radians(angle))*mag);
    
    coord.setXY(outputX, outputY);
    angle+=stepAngle;
    if (angle>=360) {
      angle=0;
      mag+=stepMag;
      if(mag>maxMag) {
        mag=0;
        return false;
      }
    }
    return true;
  }

  public void reset() {
  }
}

public class SweepRadar_Mag implements DataSet { // Subtraction
  private int maxMag=127; 
  private int mag=0;
  private int stepMag=2;
  private float angle=0;
  private float angleResolution=360;
  private float stepAngle = 360/angleResolution;

  private int outputX=0;
  private int outputY=0;

  public boolean next(Coord coord) {
    outputX = int(sin(radians(angle))*mag);
    outputY = int(cos(radians(angle))*mag);
    
    coord.setXY(outputX, outputY);
    
    mag+=stepMag;
    if (mag>maxMag) {
      mag=0;
      angle+=stepAngle;
      if(angle>=360) {
        angle=0;
        return false;
      }
    }
    return true;
  }

  public void reset() {
  }
}

public class RegularOct implements DataSet { // Subtraction 
  private int mag=0;
  private int magStep=10;
  private int maxMag=105;
  private int pointCounter=0;
  private int linePointCounter=0;
  
  private float startPointX=0;
  private float startPointY=0;
  private float endPointX=0;
  private float endPointY=0;
  
  private int outputX=0;
  private int outputY=0;
  
  RegularOct() { 
  }
  
  RegularOct(int magStep) {
    this.magStep = magStep;
  }

  public boolean next(Coord coord) {
    
    startPointX = mag * cos(2*pointCounter*PI/8);
    startPointY = mag * sin(2*pointCounter*PI/8);
    endPointX = mag * cos(2*((pointCounter%8)+1)*PI/8);
    endPointY = mag * sin(2*((pointCounter%8)+1)*PI/8);

    
    outputX=int(startPointX-(startPointX-endPointX)*linePointCounter/(mag/2));
    outputY=int(startPointY-(startPointY-endPointY)*linePointCounter/(mag/2));
    coord.setXY(outputX, outputY);
    
    linePointCounter++;
    
    if(linePointCounter>mag/2) {
      linePointCounter=0;
      pointCounter++;
      if (pointCounter>8) {
        pointCounter=0;
        mag+=magStep;
        if(mag>=maxMag) {
          mag=0;
          return false;
        }
      }
    }
    return true;
  }

  public void reset() {
  }
}
