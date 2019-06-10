import ddf.minim.*;
import ddf.minim.ugens.*;
import peasy.*;


private Object lock = new Object();

PeasyCam cam;
Minim minim;
AudioOutput out;
Gain gain;
PhyUGen simUGen;
float currAudio = 0;


void setup() {
  GeneticUtils.sketchRef = this;
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
  simUGen = new PhyUGen(this, cam);
  simUGen.patch(gain).patch(out);
}


void draw() {
  // draw scene
  //background(0, );
  fill(0, 0, 0, 255);
  strokeWeight(0);
  rect(-width*5, -height*5, width*10, height*10);
  directionalLight(126, 126, 126, 100, 0, -1);
  ambientLight(182, 182, 182);

  // find selected specimen, draw everything
  simUGen.spin();
}





void mouseReleased() {
  Specimen selected = simUGen.getSelectedSpecimen();
  if(selected != null) {
    simUGen.evolveFromSpecimen(selected, MUTATION_STDDEV);
  }
}
