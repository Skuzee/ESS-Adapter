// ColorScheme Interface & Definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public interface ColorScheme {
  public void change(Coord inputCoord, Coord outputCoord);
}

public class Gradient_Fade implements ColorScheme { 
  public void change(Coord inputCoord, Coord outputCoord) {
    outputCoord.HSBcolor = color(40-inputCoord.distToCoord(outputCoord)*2, 100, 100);
    float dist1 = inputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    float dist2 = outputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.  
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
    float dist1 = outputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    float dist2 = outputCoord.distanceFrom(mouseX+mouseX*zoom-width/2, mouseY+mouseY*zoom-height/2); // Need to offset mouse transform, so wierd maths.
    outputCoord.Acolor = int(constrain(100-100*max(dist1, dist2)/(zoom*renderDistance), 0, 100)); // Set to fade in/out basd on renderDistance.;
  }
}
