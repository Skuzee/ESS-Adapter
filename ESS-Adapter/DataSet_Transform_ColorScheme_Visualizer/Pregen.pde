// "Pregen" assembled lists of Pregenerated transforms and visualizations ~~~~~~~~~~~~~~~~~~~~~
public interface Pregen {
  void run(Coord inputCoord);
}


public class Pregen_WiiVCmap extends Sequence implements Pregen { 
  Pregen_WiiVCmap() {
    dataSet = new SweepXY(-1,1,1,-1,1,1);
    this.addElement(null,        new Solid_Fade(color(0,0,100)),      new PlotAsPoints());
    //this.addElement(new VCmap(), new Gradient_Disp_Fade(), new VectorField()); // new VCmap()
    //this.addElement(null, new Solid_Fade(color(0, 0, 100)), new PlotAsPoints(2));
  }
  void run(Coord inputCoord) {
    this.iterateDeep(inputCoord);
  }
}


public class Pregen_MonotonicXYPlot extends Sequence implements Pregen {
  Pregen_MonotonicXYPlot() {
    //dataSet = new SweepXY(0,127,1,0,0,1);
    dataSet = new SweepRadar_Mag();
    this.addElement(new VCmap(), new Gradient_Mag_Fade(), new MonotonicXYPlot()); // new SolidColor(color(33, 100, 100))
  }
  void run(Coord inputCoord) {
    this.iterateDeep(inputCoord);
  }
}

public class Pregen_NotchSnapping extends Sequence implements Pregen {
  Pregen_NotchSnapping() {
    dataSet = new SweepRadar_Angle();
    CornerNotch gateArray[] ={new CornerNotch(77, 80),   // Q1
                              new CornerNotch(-70, 79),  // Q2
                              new CornerNotch(-72, -76), // Q3
                              new CornerNotch(78, -78)}; // Q4
                         
    //this.addElement(null, new SolidColor(color(0, 50, 100)), new PlotAsPoints(5)); // new SolidColor(color(33, 100, 100))
    //this.addElement(new NotchSnapping(gateArray, 20), new SolidColor(color(33, 100, 100)), new PlotAsPoints(2));
    this.addElement(new NotchSnapping(gateArray, 20),  new Gradient_Disp_Fade(), new VectorField());
    this.addElement(null, new Solid_Fade(color(33, 100, 100)), new PlotAsPoints(3)); // new SolidColor(color(33, 100, 100))
    this.addElement(new FoldQuads(), new Solid_Fade(color(66, 100, 100)), new PlotAsPoints(1));
  }
  void run(Coord inputCoord) {
    this.iterateDeep(inputCoord);
  }
}


// Types of Pregens ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public static enum TypesOfPregens { 
  Pregen_WiiVCmap, Pregen_MonotonicXYPlot, Pregen_NotchSnapping;

  private static TypesOfPregens[] vals = values();

  public static TypesOfPregens first()
  {
    return vals[0];
  }

  public static int length()
  {
    return vals.length;
  }

  public TypesOfPregens next()
  {
    return vals[(this.ordinal()+1) % vals.length];
  }
  public TypesOfPregens prev()
  {
    return vals[(this.ordinal()+vals.length-1) % vals.length];
  }
}

// Select Pregen ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void selectPregen() {
  switch (activePregen) {
  case Pregen_WiiVCmap:
    pregen = new Pregen_WiiVCmap();
    break;

  case Pregen_MonotonicXYPlot:
    pregen = new Pregen_MonotonicXYPlot();
    break;  
    
  case Pregen_NotchSnapping:
    pregen = new Pregen_NotchSnapping();
    break;
  }
}
