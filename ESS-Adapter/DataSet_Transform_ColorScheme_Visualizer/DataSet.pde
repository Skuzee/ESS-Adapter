// DataSet Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface DataSet {
  public boolean next(Coord coord);
  public void reset();
}

public class SweepXY implements DataSet { // Subtraction
  private int minX=-127; 
  private int maxX=128; 
  private int stepX=1; 
  private int indexX=minX;

  private int minY=-127; 
  private int maxY=128; 
  private int stepY=1;
  private int indexY=minY;

  SweepXY() {
  }

  SweepXY(int i_minX, int i_maxX, int i_stepX, int i_minY, int i_maxY, int i_stepY) {
    minX=-i_minX; 
    maxX=i_maxX; 
    stepX=i_stepX; 
    indexX=i_minX;

    minY=i_minY; 
    maxY=i_maxY; 
    stepY=i_stepY;
    indexY=i_minY;
  }

  public boolean next(Coord coord) {
    coord.setXY(indexX, indexY);

    indexX+=stepX;

    if (indexX>=maxX) {
      indexX=minX;
      indexY+=stepY;

      if (indexY>=maxY) {
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
  private int maxMag=128; 
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
  private int maxMag=128; 
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
