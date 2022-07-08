// ColorScheme Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface ColorScheme {
  public void change(Coord inputCoord, Coord outputCoord);
}

public class Gradient_Mag_Fade implements ColorScheme { // Shows a shift in final magnitude. where Red is a shrinking of magnitude, and purple is a stretching.
  public void change(Coord inputCoord, Coord outputCoord) {
    
    outputCoord.HSBcolor = color(30-(inputCoord.getMag()-outputCoord.getMag())*3/2, 100, 100);
    int valueX = 2*mouseX-width*zoom+(width/2+mouseX)*(zoom-1);
    int valueY = 2*mouseY-height*zoom+(height/2+mouseY)*(zoom-1);
    float dist1 = inputCoord.distanceFrom(valueX,valueY); // Need to offset mouse transform, so wierd maths.
    float dist2 = outputCoord.distanceFrom(valueX,valueY); // Need to offset mouse transform, so wierd maths.  
    outputCoord.Acolor = int(constrain(100-100*max(dist1, dist2)/(zoom*renderDistance), 0, 100)); // Set to fade in/out basd on renderDistance.

    if (outputCoord.Acolor <= 0) {
      outputCoord.isRendered = false;
    } else {
      outputCoord.isRendered = true;
    }
  }
}

public class Gradient_Disp_Fade implements ColorScheme { // Shows the relative displacment of a point, where green is no movement, and red is a lot of displacement.
  public void change(Coord inputCoord, Coord outputCoord) {
    Coord tempCoord = new Coord(inputCoord.getX()-outputCoord.getX(),inputCoord.getY()-outputCoord.getY());
    
    outputCoord.HSBcolor = color(35-tempCoord.getMag(), 100, 100);
    int valueX = 2*mouseX-width*zoom+(width/2+mouseX)*(zoom-1);
    int valueY = 2*mouseY-height*zoom+(height/2+mouseY)*(zoom-1);
    float dist1 = inputCoord.distanceFrom(valueX,valueY); // Need to offset mouse transform, so wierd maths.
    float dist2 = outputCoord.distanceFrom(valueX,valueY); // Need to offset mouse transform, so wierd maths.  
    outputCoord.Acolor = int(constrain(100-100*max(dist1, dist2)/(zoom*renderDistance), 0, 100)); // Set to fade in/out basd on renderDistance.

    if (outputCoord.Acolor <= 0) {
      outputCoord.isRendered = false;
    } else {
      outputCoord.isRendered = true;
    }
  }
}

public class SolidColor implements ColorScheme { 
  private color solidColor=0;
  private int colorAlpha=100;

  SolidColor(color inputColor) {
    solidColor = inputColor;
  }

  SolidColor(color inputColor, int inputAlpha) {
    solidColor = inputColor;
    colorAlpha = inputAlpha;
  }

  public void change(Coord inputCoord, Coord outputCoord) {
    outputCoord.HSBcolor = solidColor;
    outputCoord.Acolor = colorAlpha;
  }
}

public class Solid_Fade implements ColorScheme { 
  public color fillColor=color(0, 0, 100);
  
  Solid_Fade(color inputColor) {
    fillColor = inputColor;
  }

  public void change(Coord inputCoord, Coord outputCoord) {
    outputCoord.HSBcolor = this.fillColor;
    int valueX = 2*mouseX-width*zoom+(width/2+mouseX)*(zoom-1);
    int valueY = 2*mouseY-height*zoom+(height/2+mouseY)*(zoom-1);
    float dist1 = inputCoord.distanceFrom(valueX,valueY); // Need to offset mouse transform, so wierd maths.
    float dist2 = outputCoord.distanceFrom(valueX,valueY); // Need to offset mouse transform, so wierd maths.  
    outputCoord.Acolor = int(constrain(100-100*max(dist1, dist2)/(zoom*renderDistance), 0, 100)); // Set to fade in/out basd on renderDistance.;
  }
}
