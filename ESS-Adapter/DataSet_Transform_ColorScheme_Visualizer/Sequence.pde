// Sequence Class ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
public class Sequence {
  private ArrayList<Transform> transformList = new ArrayList<Transform>();
  private ArrayList<ColorScheme> colorSchemeList = new ArrayList<ColorScheme>();
  private ArrayList<Visualizer> visualizerList = new ArrayList<Visualizer>();
  protected DataSet dataSet;

  public void addElement(Transform transform, ColorScheme colorScheme, Visualizer visualizer) {
    transformList.add(transform);
    colorSchemeList.add(colorScheme);
    visualizerList.add(visualizer);
  }

  // applies single transform. Used to render all coordinates of a given transform before applying the next.
  public void singleElement(Coord inputCoord, int index) {
    Coord outputCoord = inputCoord; // Transform returns new coord as to not accidentally edit original inputCoord by reference.
    Transform transform = transformList.get(index);
    if (transform != null) {
      outputCoord = transform.apply(outputCoord);
    }

    ColorScheme colorScheme = colorSchemeList.get(index);
    if (colorScheme != null) {
      colorScheme.change(inputCoord, outputCoord);
    }

    Visualizer visualizer = visualizerList.get(index);
    if ((visualizer != null)) {
      visualizer.display(inputCoord, outputCoord);
    }
  }

  // Applies all Transforms and Visualizations to a single Coord before continuing.
  public void iterate(Coord inputCoord) {
    dataSet.next(inputCoord);
    iterateDeep(inputCoord);
  }
  public void iterateDeep(Coord inputCoord) { 
    while (dataSet.next(inputCoord)) { // get the next data point
      Iterator<Transform> transformIterator = transformList.iterator();
      Iterator<ColorScheme> colorSchemeIterator = colorSchemeList.iterator();
      Iterator<Visualizer> visualizerIterator = visualizerList.iterator();
      // Consider moving this inside first while loop if sequential transform visualization does not look right!!!!
      Coord outputCoord = inputCoord; // Transform returns new coord as to not accidentally edit original inputCoord by reference.

      while (transformIterator.hasNext() && visualizerIterator.hasNext() && colorSchemeIterator.hasNext()) { // iterate through each transform/scheme/visulizer
        Transform transform = transformIterator.next();
        if (transform != null) {
          outputCoord = transform.apply(outputCoord); // applies transforms sequentially while preserving original inputCoord object.
        }

        ColorScheme colorScheme = colorSchemeIterator.next();
        if (colorScheme != null) {
          colorScheme.change(inputCoord, outputCoord);
        }

        Visualizer visualizer = visualizerIterator.next();
        if ((visualizer != null)) { // and output isRendered???
          visualizer.display(inputCoord, outputCoord);
        }
      }
    }
  }
}
