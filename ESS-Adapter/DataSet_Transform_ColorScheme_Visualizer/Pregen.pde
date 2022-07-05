// "Pregen" assembled lists of Pregenerated transforms and visualizations ~~~~~~~~~~~~~~~~~~~~~
public interface Pregen {
  void test(Coord inputCoord);
}


public class Pregen_WiiVCmap extends Sequence implements Pregen { 
  Pregen_WiiVCmap() {
    dataSet = new SweepXY(2);
    //this.addElement(null,        new Solid_Fade(color(0,0,100)),      new PlotAsPoints());
    this.addElement(new VCmap(), new Gradient_Fade(), new VectorField()); // new VCmap()
    this.addElement(null, new Solid_Fade(color(0, 0, 100)), new PlotAsPoints(2));
  }
  void test(Coord inputCoord) {
    this.iterateDeep(inputCoord);
  }
}


public class Pregen_MonotonicXYPlot extends Sequence implements Pregen {
  Pregen_MonotonicXYPlot() {
    //dataSet = new SweepXY(0,127,1,0,0,1);
    dataSet = new SweepRadar_Mag();
    this.addElement(new VCmap(), new Gradient_Fade(), new MonotonicXYPlot()); // new SolidColor(color(33, 100, 100))
  }
  void test(Coord inputCoord) {
    this.iterateDeep(inputCoord);
  }
}

public class Pregen_Test extends Sequence implements Pregen {
  Pregen_Test() {
    dataSet = new SweepXY(2);
    this.addElement(null, new SolidColor(color(0, 100, 100)), new PlotAsPoints(10)); // new SolidColor(color(33, 100, 100))
    for(int i = 1; i <= 10; i++) {
    this.addElement(new VCmap(), new SolidColor(color(i*10, 100, 100)), new PlotAsPoints(10-i)); // new SolidColor(color(33, 100, 100))
    }
  }
  void test(Coord inputCoord) {
    this.iterateDeep(inputCoord);
  }
}


// Types of Pregens ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public static enum TypesOfPregens { 
  Pregen_WiiVCmap, Pregen_MonotonicXYPlot, Pregen_Test;

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
    
  case Pregen_Test:
    pregen = new Pregen_Test();
    break;
  }
}
