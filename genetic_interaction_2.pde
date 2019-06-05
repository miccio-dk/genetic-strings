import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;


private Object lock = new Object();
PeasyCam cam;

PhyUGen simUGen;
Minim minim;
AudioOutput out;
Gain gain;
float currAudio = 0;


void setup() {
  // setup view
  size(800, 800, P3D);
  cam = new PeasyCam(this, 1000);
  cam.setDistance(2500);
  cam.setActive(false);
  frameRate(BASE_FRAMERATE);
  
  // setup audio
  minim = new Minim(this);  
  out = minim.getLineOut();
  gain = new Gain(0);
  simUGen = new PhyUGen(this);
  simUGen.patch(gain).patch(out);
}


void draw() {
  // draw scene
  background(0);
  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);
  simUGen.spin();
  
  // draw on screen display
  cam.beginHUD();
  stroke(125,125,255);
  strokeWeight(2);
  fill(0,0,60, 220);
  rect(0,0, 250, 60);
  textSize(16);
  fill(255, 255, 255);
  text("Curr Audio: " + currAudio, 10, 30);
  text("FPS: " + frameRate, 10, 45);
  cam.endHUD();
}


void mouseReleased() {
  Specimen selected = simUGen.getSelectedSpecimen();
  if(selected != null) {
    simUGen.evolveFromSpecimen(selected);
  }
}
