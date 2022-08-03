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
    
  case 'w':
  rotateX+=0.1;
  break;
  
  case 's':
  rotateX-=0.1;
  break;
  
  case 'a':
  rotateZ-=0.1;
  break;
  
  case 'd':
  rotateZ+=0.1;
  break;
  
  case 'q':
  rotateY-=0.1;
  break;
  
  case 'e':
  rotateY+=0.1;
  break;
  
  case 'r':
  rotateX=0;
  rotateY=0;
  rotateZ=0;
  break;
  }
}
