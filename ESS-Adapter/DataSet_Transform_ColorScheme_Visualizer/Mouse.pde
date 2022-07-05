// Mouse Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void mouseClicked() {
  if (mouseButton==LEFT) {
    //renderDistance-=10;
    renderDistance=renderDistance>>1;
  }
  if (mouseButton==RIGHT) {
    // renderDistance+=10;
    renderDistance=renderDistance<<1;
  }
  renderDistance = constrain(renderDistance, 5, 1024);
}

void mouseWheel(MouseEvent event) {
  zoom -= event.getCount();
  zoom = constrain(zoom, 1, 40);
}

void keyPressed() {
  switch(key) {
  case ' ':
    activePregen = activePregen.next();
    selectPregen();
    println("Pregen: " + activePregen);
    break;
  }
}
