// "Pregen" assembled lists of Pregenerated transforms and visualizations ~~~~~~~~~~~~~~~~~~~~~
public interface Pregen {
  void run(Coord inputCoord);
}

public class Pregen_Template extends Sequence implements Pregen { 
  public String title = "Pregen Template: Title Here";
  
  Pregen_Template() {
    //dataSet = new SweepXY(1);
    //dataSet = new SweepRadar_Angle();
    //dataSet = new SweepRadar_Mag();
    
    //this.addElement(null,                new Solid_Fade(color(0, 0, 100)), new PlotAsPoints(2));
    //this.addElement(new Translate(3,3),  new Gradient_Disp_Fade(),    new VectorField());
    //this.addElement(new Translate(-3,3), new Solid_Fade(color(0, 100, 100)), new PlotAsPoints(2));
  }
  void run(Coord inputCoord) {
    textSize(30);
    text(title,-width/2,-height/2-25,100);
    this.iterateDeep(inputCoord);
  }
}

public class Pregen_WiiVCmap extends Sequence implements Pregen { 
  public String title = "Pregen WiiVCmap: Emulates what VC does to GC values";
  Pregen_WiiVCmap() {
    dataSet = new SweepXY(1);
    this.addElement(new Deadzone15(), null,                             null);
    this.addElement(new VCmap(),      new Gradient_Disp_Fade(),         new VectorField());
    this.addElement(null,             new Solid_Fade(color(0, 0, 100)), new PlotAsPoints(2));
  }
  void run(Coord inputCoord) {
    textSize(30);
    text(title,-width/2,-height/2-25,100);
    this.iterateDeep(inputCoord);
  }
}


public class Pregen_MonotonicXYPlot extends Sequence implements Pregen {
  public String title = "Pregen Monotonic Test: Not working right now";
  
  Pregen_MonotonicXYPlot() {
    //dataSet = new SweepXY(0,127,1,0,0,1);
    dataSet = new SweepRadar_Mag();
    this.addElement(new VCmap(), new Gradient_Mag_Fade(), new MonotonicXYPlot()); // new SolidColor(color(33, 100, 100))
  }
  void run(Coord inputCoord) {
    textSize(30);
    text(title,-width/2,-height/2-25,100);
    this.iterateDeep(inputCoord);
  }
}


public class Pregen_NotchSnapping extends Sequence implements Pregen {
  public String title = "Pregen Notch Snapping: Snaps corners to values";
  
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
    this.addElement(new InvertVC(), new Solid_Fade(color(66, 100, 100)), new PlotAsPoints(1));
  }
  void run(Coord inputCoord) {
    textSize(30);
    text(title,-width/2,-height/2-25,100);
    this.iterateDeep(inputCoord);
  }
}


public class Pregen_MyScale extends Sequence implements Pregen {
  public String title = "Pregen MyScale: experimental gc to n64 scale/stretch";
 
  Pregen_MyScale() {
    dataSet = new RegularOct(1);
    //this.addElement(new Deadzone15(), null,                             null);
    //this.addElement(null,   new Solid_Fade(color(0,0,100)),    new PlotAsPoints(2));
    this.addElement(new MyScale(),   new Gradient_Disp_Fade(),    new VectorField());
    //this.addElement(new Translate(-3,3),   new SolidColor(color(66,100,100)),    new VectorField());
    //this.addElement(new InvertVC(),   null,     null);
    //this.addElement(new VCmap(),      new Gradient_Disp_Fade(),   new VectorField());
    //this.addElement(null,   new Solid_Fade(color(66,100,100)),    new PlotAsPoints(2));
    //this.addElement(null,     null, new PlotAsPoints(4));


  }
  void run(Coord inputCoord) {
    textSize(30);
    text(title,-width/2,-height/2-25,100);
    this.iterateDeep(inputCoord);
  }
}

public class Pregen_InvertVC extends Sequence implements Pregen {
  public String title = "Pregen Invert VC: Applies gc_to_n64 and invertVC function";
  
  Pregen_InvertVC() {
    dataSet = new RegularOct(5);

    //dataSet = new SweepXY(2);
    //this.addElement(null,   new SolidColor(color(0,100,100)),    new PlotAsPoints(4));
    //this.addElement(new Translate(3,3),   new SolidColor(color(33,100,100)),    new VectorField());
    //this.addElement(new Translate(-3,3),   new SolidColor(color(66,100,100)),    new VectorField());
    this.addElement(new InvertVC(),   null,     null);
    this.addElement(new VCmap(),      new Gradient_Disp_Fade(),   new VectorField());
    this.addElement(null,     null, new PlotAsPoints(4));


  }
  void run(Coord inputCoord) {
    textSize(30);
    text(title,-width/2,-height/2-25,100);
    this.iterateDeep(inputCoord);
  }
}


// Types of Pregens ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public static enum TypesOfPregens { 
 Pregen_MyScale, Pregen_WiiVCmap, Pregen_InvertVC, Pregen_MonotonicXYPlot, Pregen_NotchSnapping; // Pregen_Template

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
  
  //case Pregen_Template:
  //  pregen = new Pregen_NotchSnapping();
  //  break; 
    
  case Pregen_MyScale:
    pregen = new Pregen_MyScale();
    break; 
    
  case Pregen_InvertVC:
    pregen = new Pregen_InvertVC();
    break;
    
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
