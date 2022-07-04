// Visualizer Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface Visualizer {
  public void display(Coord inputCoord, Coord outputCoord);
}

public class plotAsPoints implements Visualizer { // DOTS
  public void display(Coord inputCoord, Coord outputCoord) {
    pushStyle();
    noStroke();
    fill(outputCoord.HSBcolor, outputCoord.Acolor);
    ellipse(outputCoord.getScaledX(), outputCoord.getScaledY(), outputCoord.drawSize*zoom*2, outputCoord.drawSize*zoom*2);
    popStyle();
  }
}

public class VectorField implements Visualizer { // Draws a line from inputCoord to outputCoord
  public void display(Coord inputCoord, Coord outputCoord) {

    //println(outputCoord.getX() + " " + outputCoord.getY());
    if ((outputCoord.getX()!=0) && (outputCoord.getY()!=0) && outputCoord.isRendered) {
      pushStyle();
      stroke(outputCoord.HSBcolor, outputCoord.Acolor);
      strokeWeight(1+zoom);
      noFill();
      line(inputCoord.getScaledX(), inputCoord.getScaledY(), outputCoord.getScaledX(), outputCoord.getScaledY());
      popStyle();
    }
  }
}

public class MonotonicXYPlot implements Visualizer { // Draws a line from inputCoord to outputCoord
  Coord lastCoord = new Coord();

  public void display(Coord inputCoord, Coord outputCoord) {
    pushStyle();
    stroke(outputCoord.HSBcolor, 100);
    strokeWeight(1+zoom);
    noFill();
    pushMatrix();
    translate(0,0,outputCoord.getMag());
    //outputCoord.setY(outputCoord.getX());
    ellipse(inputCoord.getScaledX(), inputCoord.getScaledY(),zoom,zoom);

    //if ((outputCoord.getY()!=0)) {
    //  //line(lastCoord.getScaledX(), lastCoord.getScaledY(), inputCoord.getScaledX(), outputCoord.getScaledY());
    //line(lastCoord.getScaledX(), lastCoord.getScaledY(), lastCoord.getMag(),inputCoord.getScaledX(), inputCoord.getScaledY(),outputCoord.getMag());
    //}
    lastCoord.setXY(inputCoord.getX(), inputCoord.getY());
    //inputCoord.setY(inputCoord.getX());
    //outputCoord.setY(outputCoord.getX());
    popMatrix();
    popStyle();
  }
}
